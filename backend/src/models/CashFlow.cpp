#include "CashFlow.h"

#include <algorithm>
#include <stdexcept>

#include "../database/Database.h"

using nlohmann::json;

namespace {
// One transaction's money: refunds are stored positive and come off.
const char* kNet = "CASE WHEN pp.txn_type IN ('Refund', 'Partial Refund') THEN -pp.net_amount ELSE pp.net_amount END";
const char* kGross = "CASE WHEN pp.txn_type IN ('Refund', 'Partial Refund') THEN -pp.amount ELSE pp.amount END";
const char* kYm = "to_char(pp.paid_at AT TIME ZONE 'America/New_York', 'YYYY-MM')";
// The programs that count, without a dispute LeagueApps posted twice: the
// withdrawal lands once on the day's books and again with its payout, so the
// entry with no payout goes when its twin has one.
const char* kCounted =
    "JOIN la_soccer_programs s ON s.la_program_id = pp.la_program_id AND s.counts_in "
    "WHERE NOT (pp.txn_type IN ('Refund', 'Partial Refund') AND pp.raw->>'bankTransferId' IS NULL "
    "           AND pp.raw->>'notes' IN ('Automatic withdrawal for dispute on charge', 'DISPUTE FEE') "
    "           AND EXISTS (SELECT 1 FROM person_payments twin WHERE twin.la_invoice_id = pp.la_invoice_id "
    "                          AND twin.txn_type = pp.txn_type AND twin.amount = pp.amount "
    "                          AND twin.raw->>'bankTransferId' IS NOT NULL))";
const char* kCoachAheadSql = R"SQL(
    WITH issuers AS (
        SELECT ii.id, ii.person_id, ii.hourly_rate, ii.pay_basis,
               (date_trunc('month', now() AT TIME ZONE 'America/New_York') + interval '1 month')::date AS from_day
          FROM invoice_issuers ii WHERE ii.is_active
    ), work AS (
        SELECT ii.id AS issuer, ii.hourly_rate, g.starts_at AS s,
               g.starts_at + COALESCE(pol.hours_per_game * interval '1 hour', g.ends_at - g.starts_at) AS e
          FROM issuers ii
          JOIN gcal_events g ON (g.starts_at AT TIME ZONE 'America/New_York')::date >= ii.from_day
                            AND g.starts_at < now() + interval '13 months'
                            AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
          JOIN fh_events e ON e.gcal_event_id = g.id AND e.kind IN ('match', 'practice')
          LEFT JOIN LATERAL (
                SELECT p.* FROM ref_fee_policies p
                 WHERE p.kind = 'coaching' AND p.is_active AND e.kind = 'match'
                   AND (p.event_category IS NULL OR e.category = p.event_category)
                   AND e.league = ANY (p.event_league_labels)
                   AND (p.age_band IS NULL OR g.summary ~* ('\m' || p.age_band || '\M'))
                 ORDER BY p.sort_order, p.id LIMIT 1) pol ON true
         WHERE (ii.pay_basis = 'weekly' OR e.kind = 'match')
           AND (pol.coach_issuer_id = ii.id
                OR EXISTS (SELECT 1 FROM fh_event_teams fet
                             JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                             JOIN coaches c ON c.id = tc.coach_id
                            WHERE fet.fh_event_id = e.id AND c.person_id = ii.person_id))
        UNION ALL
        SELECT ii.id, ii.hourly_rate, g.starts_at, g.ends_at
          FROM issuers ii
          JOIN invoice_issuer_event_claims cl ON cl.issuer_id = ii.id AND cl.is_active
          JOIN gcal_events g ON g.summary ~* cl.summary_pattern
                            AND (g.starts_at AT TIME ZONE 'America/New_York')::date >= ii.from_day
                            AND g.starts_at < now() + interval '13 months'
                            AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
         WHERE NOT EXISTS (SELECT 1 FROM fh_events e WHERE e.gcal_event_id = g.id)
    ), ordered AS (
        SELECT *, MAX(e) OVER (PARTITION BY issuer ORDER BY s, e ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS prior_end FROM work
    ), stints AS (
        SELECT *, SUM(CASE WHEN s <= prior_end THEN 0 ELSE 1 END) OVER (PARTITION BY issuer ORDER BY s, e) AS stint FROM ordered
    ), merged AS (
        SELECT issuer, hourly_rate, MIN(s) AS s, MAX(e) AS e FROM stints GROUP BY issuer, hourly_rate, stint
    )
    SELECT to_char(s AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym,
           SUM(EXTRACT(EPOCH FROM (e - s)) / 3600.0 * hourly_rate)::float8 AS amount
      FROM merged GROUP BY 1 ORDER BY 1)SQL";
// Referee fees for home games on the calendar, next month up to refs_through.
const char* kRefsAheadSql = R"SQL(
    SELECT to_char(g.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym, SUM(p.per_game_usd)::float8 AS amount
      FROM fh_events e
      JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
      JOIN LATERAL (
            SELECT p.* FROM ref_fee_policies p
             WHERE p.kind = 'referee' AND p.is_active
               AND (p.event_category IS NULL OR e.category = p.event_category)
               AND e.league = ANY (p.event_league_labels)
               AND (p.age_band IS NULL OR g.summary ~* ('\m' || p.age_band || '\M'))
             ORDER BY p.sort_order, p.id LIMIT 1) p ON true
     WHERE e.kind = 'match' AND (e.is_home OR NOT p.home_only)
       AND (g.starts_at AT TIME ZONE 'America/New_York')::date >= (date_trunc('month', now() AT TIME ZONE 'America/New_York') + interval '1 month')::date
       AND (g.starts_at AT TIME ZONE 'America/New_York')::date <= $1::date
     GROUP BY 1)SQL";
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
}

json CashFlow::build(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    json out = {{"months", json::array()}, {"programs", json::array()}, {"invoices", json::array()},
                {"unmapped", json::array()}};

    // The owner's starting date (cash_flow_policies).
    auto first = db->query("SELECT starts_on::text AS d, refs_through::text AS r FROM cash_flow_policies WHERE club_id = " + club);
    if (first.empty()) throw std::runtime_error("cash_flow_policies has no row for club " + club);
    const std::string start = first[0]["d"].c_str(), refsThrough = first[0]["r"].c_str();
    out["start"] = start;
    out["refs_through"] = refsThrough;
    const std::string paidSince = "(pp.paid_at AT TIME ZONE 'America/New_York')::date >= '" + start + "'";
    const std::string invoicedSince = "i.invoice_date >= '" + start + "'";
    const std::string invoicedToDate = invoicedSince + " AND i.invoice_date < date_trunc('month', now() AT TIME ZONE 'America/New_York') + interval '1 month'";

    // Money in per month.
    for (const auto& r : db->query(std::string("SELECT ") + kYm + " AS ym, SUM(" + kNet + ")::float8 AS net, SUM(" + kGross + ")::float8 AS gross "
            "  FROM person_payments pp " + kCounted + " AND " + paidSince + " GROUP BY 1 ORDER BY 1")) {
        out["months"].push_back({{"ym", r["ym"].c_str()}, {"net", num(r, "net")}, {"gross", num(r, "gross")}, {"final", 0.0}, {"draft", 0.0}});
    }

    // Money out per month: every invoice line by its invoice's date.
    for (const auto& r : db->query(
            std::string("SELECT to_char(i.invoice_date, 'YYYY-MM') AS ym, ")
            + "       COALESCE(SUM(l.amount) FILTER (WHERE i.is_final), 0)::float8 AS final, "
            "       COALESCE(SUM(l.amount) FILTER (WHERE NOT i.is_final), 0)::float8 AS draft "
            "  FROM invoices i JOIN invoice_lines l ON l.invoice_id = i.id WHERE " + invoicedSince + " GROUP BY 1 ORDER BY 1")) {
        const std::string ym = r["ym"].c_str();
        json* row = nullptr;
        for (auto& m : out["months"]) if (m["ym"] == ym) row = &m;
        if (!row) {
            out["months"].push_back({{"ym", ym}, {"net", 0.0}, {"gross", 0.0}, {"final", 0.0}, {"draft", 0.0}});
            row = &out["months"].back();
        }
        (*row)["final"] = num(r, "final");
        (*row)["draft"] = num(r, "draft");
    }
    std::sort(out["months"].begin(), out["months"].end(),
              [](const json& a, const json& b) { return a["ym"].get<std::string>() < b["ym"].get<std::string>(); });

    // Money in per program group.
    for (const auto& r : db->query(std::string("SELECT s.group_label, MIN(s.sort_order) AS so, SUM(") + kNet + ")::float8 AS since "
            "  FROM person_payments pp " + kCounted + " AND " + paidSince + " GROUP BY s.group_label ORDER BY so, s.group_label")) {
        if (num(r, "since") == 0) continue;
        out["programs"].push_back({{"label", r["group_label"].c_str()}, {"since", num(r, "since")}});
    }

    // Money out per category, in the category table's order.
    for (const auto& r : db->query(
            std::string("SELECT l.category, COALESCE(c.label, l.category) AS label, ")
            + "       COALESCE(SUM(l.amount) FILTER (WHERE i.is_final), 0)::float8 AS final, "
            "       COALESCE(SUM(l.amount) FILTER (WHERE NOT i.is_final), 0)::float8 AS draft "
            "  FROM invoice_lines l JOIN invoices i ON i.id = l.invoice_id "
            "  LEFT JOIN invoice_line_categories c ON c.code = l.category "
            " WHERE " + invoicedToDate + " GROUP BY 1, 2, c.sort_order ORDER BY c.sort_order NULLS LAST, 2")) {
        out["invoices"].push_back({{"category", r["category"].c_str()}, {"label", r["label"].c_str()}, {"final", num(r, "final")}, {"draft", num(r, "draft")}});
    }

    // Money out ahead, by month: coach pay off the calendar (the rule a sheet
    // bills by; a coach on two teams at once is paid for the one stint),
    // referee fees while the plan runs, and the planned purchases.
    json ahead = json::object();
    auto addAhead = [&](const pqxx::result& rows) {
        for (const auto& r : rows) ahead[r["ym"].c_str()] = ahead.value(r["ym"].c_str(), 0.0) + num(r, "amount");
    };
    addAhead(db->query(kCoachAheadSql));
    addAhead(db->query(kRefsAheadSql, {refsThrough}));
    addAhead(db->query("SELECT ym, SUM(amount)::float8 AS amount FROM cash_flow_planned GROUP BY 1"));
    out["ahead_out"] = ahead;

    // What LeagueApps keeps, the last 12 months: projections are in net money too.
    {
        auto r = db->query(std::string("SELECT SUM(") + kNet + ")::float8 AS net, SUM(" + kGross + ")::float8 AS gross "
            "  FROM person_payments pp " + kCounted + " AND pp.paid_at >= now() - interval '12 months'");
        const double gross = r.empty() ? 0.0 : num(r[0], "gross"), net = r.empty() ? 0.0 : num(r[0], "net");
        out["net_ratio"] = gross > 0 ? net / gross : 1.0;
    }

    // Soccer-looking money nobody has placed yet, so a new program cannot go
    // missing from the totals in silence.
    for (const auto& r : db->query(
            "SELECT MAX(pp.program_name) AS name FROM person_payments pp "
            " WHERE pp.paid_at >= now() - interval '90 days' AND pp.program_name ~* 'soccer|travel team|apsl|casa' "
            "   AND pp.program_name !~* 'food|vendor' "
            "   AND pp.la_program_id NOT IN (SELECT la_program_id FROM la_soccer_programs) "
            " GROUP BY pp.la_program_id ORDER BY 1")) {
        out["unmapped"].push_back(r["name"].c_str());
    }
    return out;
}
