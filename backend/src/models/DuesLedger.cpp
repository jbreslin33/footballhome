#include "DuesLedger.h"

#include "../database/Database.h"

using nlohmann::json;

json DuesLedger::byMonth(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    json out = {{"start", nullptr}, {"now_ym", ""}, {"sections", json::object()}};
    auto y = db->query("SELECT y.starts_on::text AS s, to_char(now() AT TIME ZONE 'America/New_York', 'YYYY-MM') AS now_ym "
                       "  FROM cash_flow_policies p JOIN budget_years y ON y.id = p.budget_year_id WHERE p.club_id = $1::int", {club});
    if (y.empty()) return out;
    out["start"] = y[0]["s"].c_str(); out["now_ym"] = y[0]["now_ym"].c_str();
    for (const auto& r : db->query(R"SQL(
        SELECT lp.category, to_char(pp.paid_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym,
               COALESCE(SUM(CASE WHEN pp.txn_type IN ('Refund', 'Partial Refund') THEN -pp.amount ELSE pp.amount END)
                        FILTER (WHERE pp.txn_type <> 'Bank' OR pp.raw ? 'bankTransferId'), 0)::float8 AS amount,
               COALESCE(SUM(pp.amount) FILTER (WHERE pp.txn_type = 'Bank' AND NOT (pp.raw ? 'bankTransferId')), 0)::float8 AS pending
          FROM person_payments pp
          JOIN leagueapps_programs lp ON lp.program_id = pp.la_program_id
          JOIN la_soccer_programs s ON s.la_program_id = pp.la_program_id AND s.counts_in
         WHERE (pp.paid_at AT TIME ZONE 'America/New_York')::date >= $1::date
           AND NOT (pp.txn_type IN ('Refund', 'Partial Refund') AND pp.raw->>'bankTransferId' IS NULL
                    AND pp.raw->>'notes' IN ('Automatic withdrawal for dispute on charge', 'DISPUTE FEE')
                    AND EXISTS (SELECT 1 FROM person_payments twin WHERE twin.la_invoice_id = pp.la_invoice_id
                                   AND twin.txn_type = pp.txn_type AND twin.amount = pp.amount
                                   AND twin.raw->>'bankTransferId' IS NOT NULL))
         GROUP BY 1, 2 ORDER BY 1, 2)SQL", {out["start"].get<std::string>()})) {
        out["sections"][r["category"].c_str()][r["ym"].c_str()] = {{"amount", r["amount"].as<double>()}, {"pending", r["pending"].as<double>()}};
    }
    return out;
}
