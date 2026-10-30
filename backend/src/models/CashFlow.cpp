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
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
}

json CashFlow::build(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    json out = {{"months", json::array()}, {"programs", json::array()}, {"invoices", json::array()},
                {"unmapped", json::array()}};

    // The owner's starting date (cash_flow_policies).
    auto first = db->query("SELECT starts_on::text AS d FROM cash_flow_policies WHERE club_id = " + club);
    const std::string start = first.empty() ? "" : first[0]["d"].c_str();
    if (start.empty()) throw std::runtime_error("cash_flow_policies has no row for club " + club);
    out["start"] = start;
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
