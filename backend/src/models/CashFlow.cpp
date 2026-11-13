#include "CashFlow.h"

#include <stdexcept>

#include "../database/Database.h"
#include "Expenses.h"

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
        SELECT ii.id, ii.person_id, ii.hourly_rate, ii.pay_basis, pn.first_name,
               (date_trunc('month', now() AT TIME ZONE 'America/New_York') + interval '1 month')::date AS from_day
          FROM invoice_issuers ii JOIN persons pn ON pn.id = ii.person_id WHERE ii.is_active
    ), work AS (
        SELECT ii.id AS issuer, ii.first_name, NULL::text AS what, ii.hourly_rate, cash_flow_event_scope(e.id, e.category, e.league) AS scope, g.starts_at AS s,
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
           AND fh_coach_paid_for(ii.id, e.id, e.kind)   -- mig 987: what each coach is paid for
           AND (e.kind <> 'match' OR pol.id IS NULL)     -- mig 990: a policy's games come from its seasons
           AND (pol.coach_issuer_id = ii.id
                OR EXISTS (SELECT 1 FROM fh_event_teams fet
                             JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                             JOIN coaches c ON c.id = tc.coach_id
                            WHERE fet.fh_event_id = e.id AND c.person_id = ii.person_id))
        UNION ALL
        SELECT ii.id, ii.first_name, cl.label, ii.hourly_rate, cl.scope, g.starts_at, g.ends_at   -- mig 992: what the work is and where it lands
          FROM issuers ii
          JOIN invoice_issuer_event_claims cl ON cl.issuer_id = ii.id AND cl.is_active
          JOIN gcal_events g ON g.summary ~* cl.summary_pattern
                            AND (g.starts_at AT TIME ZONE 'America/New_York')::date >= ii.from_day
                            AND g.starts_at < now() + interval '13 months'
                            AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
         WHERE NOT EXISTS (SELECT 1 FROM fh_events e WHERE e.gcal_event_id = g.id)
    ), ordered AS (
        SELECT *, MAX(e) OVER (PARTITION BY issuer ORDER BY s, e ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS prior_end FROM work
    )
    SELECT to_char(s AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym, scope, first_name || COALESCE(' · ' || what, '') AS name, 'labor' AS category, '' AS detail,
           SUM(GREATEST(0, EXTRACT(EPOCH FROM (e - GREATEST(s, COALESCE(prior_end, s))))) / 3600.0 * hourly_rate)::float8 AS amount
      FROM ordered GROUP BY 1, 2, 3)SQL";
// Every invoice line from $1 up to the end of this month, split by scope.  Coach
// pay follows the hours on the sheet; referee lines follow their ticked games;
// what neither explains stays on the line, so each invoice still adds up.
const char* kOutSql = R"SQL(
    WITH inv AS (
        SELECT i.id, ii.id AS issuer_id, to_char(i.invoice_date, 'YYYY-MM') AS ym, pn.first_name, ii.hourly_rate, i.invoice_year || '.' || i.invoice_number AS inv_label
          FROM invoices i JOIN invoice_issuers ii ON ii.id = i.issuer_id JOIN persons pn ON pn.id = ii.person_id
         WHERE i.invoice_date >= $1::date
           AND i.invoice_date < date_trunc('month', now() AT TIME ZONE 'America/New_York') + interval '1 month'
    ), worked AS (
        SELECT inv.id, inv.ym, inv.first_name || COALESCE(' · ' || (fh_issuer_claim(inv.issuer_id, g.summary)).label, '') AS first_name, inv.inv_label,
               -- an event's hours follow its team; a claimed calendar title its claim (mig 992); else the coach's section
               CASE WHEN e.id IS NOT NULL THEN cash_flow_event_scope(e.id, e.category, e.league)
                    ELSE COALESCE((fh_issuer_claim(inv.issuer_id, g.summary)).scope, cash_flow_issuer_scope(inv.issuer_id)) END AS scope,
               SUM(COALESCE(s.hours, EXTRACT(EPOCH FROM (s.end_at - s.start_at)) / 3600.0, 0)) * inv.hourly_rate AS amount
          FROM inv JOIN invoice_work_shifts s ON s.invoice_id = inv.id
          LEFT JOIN fh_events e ON e.id = s.fh_event_id
          LEFT JOIN gcal_events g ON g.id = s.gcal_event_id
         GROUP BY 1, 2, 3, 4, 5, inv.hourly_rate
    ), labor AS (
        SELECT inv.id, inv.issuer_id, inv.ym, inv.first_name, inv.inv_label, SUM(l.amount) AS amount
          FROM inv JOIN invoice_lines l ON l.invoice_id = inv.id AND l.category = 'labor' GROUP BY 1, 2, 3, 4, 5
    ), refs AS (
        -- One row per game ticked on a referee line (mig 985: the roll-up lists games).
        SELECT l.id AS line_id, inv.ym, inv.inv_label, cash_flow_policy_scope(p.id) AS scope,
               p.label || ' ' || to_char(r.game_on, 'FMMM/FMDD') || ' ' || COALESCE(r.opponent, '') AS name, r.amount_usd AS amount
          FROM inv JOIN invoice_lines l ON l.invoice_id = inv.id
          JOIN ref_fee_payments r ON r.invoice_line_id = l.id
          JOIN ref_fee_policies p ON p.id = r.policy_id
    )
    SELECT ym, scope, 'coach' AS type, first_name AS name, 'labor' AS category, inv_label AS detail, amount::float8 AS amount FROM worked
    UNION ALL
    SELECT l.ym, cash_flow_issuer_scope(l.issuer_id), 'coach', l.first_name, 'labor', l.inv_label, (l.amount - COALESCE(w.amount, 0))::float8
      FROM labor l LEFT JOIN (SELECT id, SUM(amount) AS amount FROM worked GROUP BY 1) w ON w.id = l.id
     WHERE ABS(l.amount - COALESCE(w.amount, 0)) >= 0.005
    UNION ALL
    SELECT ym, scope, 'ref', name, 'referees', inv_label, amount::float8 FROM refs
    UNION ALL
    SELECT inv.ym, cash_flow_invoice_line_scope(l.id), 'line',
           l.description || CASE WHEN l.installment_no IS NOT NULL THEN ' #' || l.installment_no || COALESCE(' of ' || pl.installment_count, '') ELSE '' END,
           l.category, inv.inv_label,
           (l.amount - COALESCE((SELECT SUM(r.amount) FROM refs r WHERE r.line_id = l.id), 0))::float8
      FROM inv JOIN invoice_lines l ON l.invoice_id = inv.id AND l.category <> 'labor'
      LEFT JOIN invoice_installment_plans pl ON pl.id = l.plan_id
     WHERE ABS(l.amount - COALESCE((SELECT SUM(r.amount) FROM refs r WHERE r.line_id = l.id), 0)) >= 0.005)SQL";
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
}

json CashFlow::build(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    json out = {{"scopes", json::array()}, {"items", json::array()}, {"programs", json::array()}, {"invoices", json::array()},
                {"unmapped", json::array()}};

    // The page starts at its budget year (mig 970: Aug 1 – Jul 31, owner:
    // "pretend 1st year of club").
    auto first = db->query("SELECT y.starts_on::text AS d, p.refs_through::text AS r FROM cash_flow_policies p "
                           "  JOIN budget_years y ON y.id = p.budget_year_id WHERE p.club_id = " + club);
    if (first.empty()) throw std::runtime_error("cash_flow_policies has no row for club " + club);
    const std::string start = first[0]["d"].c_str(), refsThrough = first[0]["r"].c_str();
    out["start"] = start;
    out["refs_through"] = refsThrough;
    const std::string paidSince = "(pp.paid_at AT TIME ZONE 'America/New_York')::date >= '" + start + "'";
    const std::string invoicedToDate = "i.invoice_date >= '" + start + "' AND i.invoice_date < date_trunc('month', now() AT TIME ZONE 'America/New_York') + interval '1 month'";

    for (const auto& r : db->query("SELECT code, label, parent, section_code, team_id FROM cash_flow_scopes ORDER BY sort_order")) {
        out["scopes"].push_back({{"code", r["code"].c_str()}, {"label", r["label"].c_str()}, {"team_id", r["team_id"].is_null() ? json(nullptr) : json(r["team_id"].as<long long>())},
                                 {"parent", r["parent"].is_null() ? json(nullptr) : json(r["parent"].c_str())},
                                 {"section_code", r["section_code"].is_null() ? json(nullptr) : json(r["section_code"].c_str())}});
    }

    // The kinds of money the roll-up groups by (invoice categories, in their order).
    out["categories"] = json::array();
    for (const auto& r : db->query("SELECT code, regexp_replace(label, ':\\s*$', '') AS label FROM invoice_line_categories ORDER BY sort_order NULLS LAST, code"))
        out["categories"].push_back({{"code", r["code"].c_str()}, {"label", r["label"].c_str()}});

    // Every line of money on the page: the month table and each scope add these up.
    auto addItems = [&](const pqxx::result& rows, const char* dir, const char* type, bool ahead) {
        for (const auto& r : rows) {
            if (num(r, "amount") == 0) continue;
            out["items"].push_back({{"ym", r["ym"].c_str()}, {"dir", dir}, {"scope", r["scope"].c_str()},
                                    {"type", type ? type : r["type"].c_str()}, {"name", r["name"].c_str()},
                                    {"category", r["category"].c_str()}, {"detail", r["detail"].is_null() ? "" : r["detail"].c_str()},
                                    {"amount", num(r, "amount")}, {"ahead", ahead}});
        }
    };

    addItems(db->query(std::string("SELECT ") + kYm + " AS ym, s.group_label AS name, 'dues' AS category, '' AS detail, "
            "       cash_flow_dues_scope(fh_payment_person(pp.la_registration_id, pp.la_user_id), lp.category, pp.paid_at) AS scope, "
            "       SUM(" + kNet + ")::float8 AS amount "
            "  FROM person_payments pp JOIN leagueapps_programs lp ON lp.program_id = pp.la_program_id " + kCounted + " AND " + paidSince +
            " GROUP BY 1, 2, 5"), "in", "dues", false);
    addItems(db->query(kOutSql, {start}), "out", nullptr, false);

    // Field rentals we are paid for (mig 971): every booking on the calendar
    // from the start, club-wide; a month after this one is still ahead.
    for (const bool ahead : {false, true})
        addItems(db->query(std::string(
                "SELECT to_char(r.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym, 'club' AS scope, "
                "       p.label || ' ' || to_char(r.starts_at AT TIME ZONE 'America/New_York', 'FMMM/FMDD') || ' · ' || r.hours || ' h' AS name, "
                "       'rental' AS category, '' AS detail, SUM(r.amount_usd)::float8 AS amount "
                "  FROM fh_field_rental_income($1::int) r JOIN field_rental_policies p ON p.id = r.policy_id "
                " WHERE (r.starts_at AT TIME ZONE 'America/New_York')::date >= $2::date "
                "   AND (date_trunc('month', r.starts_at AT TIME ZONE 'America/New_York') ") + (ahead ? ">" : "<=") +
                " date_trunc('month', now() AT TIME ZONE 'America/New_York')) GROUP BY 1, 2, 3", {club, start}),
            "in", "rental", ahead);

    // A season's money paid before the year began (budget_lines.paid_before_usd,
    // e.g. APSL installments 1–13): part of the year's cost, not this year's
    // cash (owner 2026-11-03: "for year we need to account for all expenses
    // for leagues as they all are contained within aug 1 to july 31").
    for (const auto& r : db->query(
            "SELECT to_char(y.starts_on, 'YYYY-MM') AS ym, cash_flow_budget_line_scope(b.id) AS scope, b.label AS name, b.category, "
            "       '' AS detail, b.paid_before_usd::float8 AS amount "
            "  FROM budget_lines b JOIN budget_years y ON y.id = b.budget_year_id "
            "  JOIN cash_flow_policies p ON p.budget_year_id = y.id AND p.club_id = b.club_id "
            " WHERE b.club_id = $1::int AND b.is_active AND b.paid_before_usd > 0", {club})) {
        out["items"].push_back({{"ym", r["ym"].c_str()}, {"dir", "out"}, {"scope", r["scope"].c_str()}, {"type", "prepaid"},
                                {"name", r["name"].c_str()}, {"category", r["category"].c_str()}, {"detail", ""},
                                {"amount", num(r, "amount")}, {"ahead", false}, {"prepaid", true}});
    }

    // The budget year the page shows (mig 969).
    {
        auto y = db->query("SELECT y.label, y.starts_on::text AS s, y.ends_on::text AS e FROM cash_flow_policies p "
                           "  JOIN budget_years y ON y.id = p.budget_year_id WHERE p.club_id = " + club);
        out["year"] = {{"label", y[0]["label"].c_str()}, {"starts_on", y[0]["s"].c_str()}, {"ends_on", y[0]["e"].c_str()}};
    }

    // Dues ahead per team: each section's members today, by the team their
    // dues count for (fh_dues_team), as a share of the section.
    out["dues_shares"] = json::array();
    for (const auto& r : db->query(
            "WITH m AS (SELECT DISTINCT m.person_id, lp.category FROM person_la_memberships m "
            "             JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id "
            "            WHERE m.ended_at IS NULL AND lp.variant = 'active'), "
            "     x AS (SELECT CASE category WHEN 'men' THEN 'M' WHEN 'women' THEN 'W' WHEN 'boys' THEN 'B' WHEN 'girls' THEN 'G' END AS section_code, "
            "                  cash_flow_dues_scope(person_id, category, now()) AS scope FROM m) "
            "SELECT section_code, scope, (COUNT(*)::float8 / SUM(COUNT(*)) OVER (PARTITION BY section_code)) AS share "
            "  FROM x WHERE section_code IS NOT NULL GROUP BY 1, 2 ORDER BY 1, 2"))
        out["dues_shares"].push_back({{"section_code", r["section_code"].c_str()}, {"scope", r["scope"].c_str()}, {"share", num(r, "share")}});

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

    // Money out ahead: coach pay off the calendar (the rule a sheet bills by; a
    // coach on two teams at once is paid for the one stint), referee fees while
    // the plan runs, and the planned rows.
    addItems(db->query(kCoachAheadSql), "out", "coach", true);
    addItems(db->query("SELECT ym, scope, label AS name, category, '' AS detail, amount::float8 AS amount FROM cash_flow_planned WHERE is_active"), "out", "plan", true);

    // Referee fees and game coaching still to come (mig 990): the season model
    // #finances Expenses prints — games on the league feeds plus the games each
    // season still expects — from this month on.
    {
        const json proj = Expenses::projection(clubId);
        const std::string nowYm = db->query("SELECT to_char(now() AT TIME ZONE 'America/New_York', 'YYYY-MM') AS m")[0]["m"].c_str();
        for (const auto& p : proj["ref_fees"]) {
            const bool coaching = p["kind"].get<std::string>() == "coaching";
            const std::string name = p["label"].get<std::string>() + (coaching ? std::string(" games") : std::string());
            for (auto& [ym, c] : p["by_month"].items()) {
                const double amt = c["projected"].get<double>();
                if (ym < nowYm || amt == 0) continue;
                out["items"].push_back({{"ym", ym}, {"dir", "out"}, {"scope", p["scope"]}, {"type", coaching ? "coach" : "ref"},
                                        {"name", name}, {"category", coaching ? "labor" : "referees"}, {"detail", ""},
                                        {"amount", amt}, {"ahead", true}});
            }
        }
        // Teams budgeted from their fee plan (mig 1320): league payments and
        // per-game costs still to come.
        for (const auto& p : proj["plan_cash"]) {
            const std::string name = p["label"].get<std::string>();
            for (auto& [ym, c] : p["by_month"].items()) {
                const double amt = c["projected"].get<double>();
                if (ym < nowYm || amt == 0) continue;
                out["items"].push_back({{"ym", ym}, {"dir", "out"}, {"scope", p["scope"]}, {"type", "plan"},
                                        {"name", name}, {"category", p["category"]}, {"detail", ""},
                                        {"amount", amt}, {"ahead", true}});
            }
        }
    }

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
