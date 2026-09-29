#include "PaymentsOverview.h"

#include "../database/Database.h"

// Reached only through laGet( in PaymentsController (GET /api/payments/
// overview), which syncs all four membership programs from LeagueApps
// before build() reads person_la_memberships — LA → DB → render.

using nlohmann::json;

json PaymentsOverview::build(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    json out = {{"club_id", clubId}, {"sections", json::array()}};
    double allMembers = 0, allFree = 0, allPaying = 0, allPaidUp = 0, allBehind = 0, allBlocked = 0, allOwed = 0,
           allMonthlyAll = 0, allMonthlyCur = 0;
    // One row per section, its LA category derived from club_sections.code.
    for (const auto& r : db->query(R"SQL(
        WITH sec AS (
            SELECT s.id, s.name, s.code, s.sort_order,
                   CASE s.code WHEN 'M' THEN 'men' WHEN 'W' THEN 'women' WHEN 'B' THEN 'boys' WHEN 'G' THEN 'girls' END AS category,
                   fh_monthly_dues_usd($1::int, s.id) AS rate,
                   fh_dues_line_usd($1::int, s.id)    AS line
              FROM club_sections s
        ), mem AS (
            SELECT DISTINCT ON (lp.category, m.person_id) lp.category, m.person_id, m.la_payment_status,
                   fh_dues_balance_usd(m.person_id) AS owed
              FROM person_la_memberships m
              JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
             WHERE m.ended_at IS NULL AND lp.variant = 'active'
             ORDER BY lp.category, m.person_id, m.la_registered_at DESC NULLS LAST
        )
        SELECT sec.id, sec.name, sec.code, sec.category, sec.rate, sec.line,
               COUNT(mem.person_id)                                                        AS members,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status = 'NA_FREE')       AS free,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status <> 'NA_FREE')      AS paying,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.owed = 0) AS paid_up,
               COUNT(mem.person_id) FILTER (WHERE mem.owed > 0 AND mem.owed < sec.line)    AS behind,
               COUNT(mem.person_id) FILTER (WHERE mem.owed >= sec.line)                    AS blocked,
               COALESCE(SUM(mem.owed), 0)                                                  AS owed
          FROM sec LEFT JOIN mem ON mem.category = sec.category
         WHERE sec.category IS NOT NULL
         GROUP BY sec.id, sec.name, sec.code, sec.category, sec.rate, sec.line, sec.sort_order
         ORDER BY sec.sort_order, sec.id)SQL", {club})) {
        const double rate = r["rate"].is_null() ? 0.0 : r["rate"].as<double>();
        const double line = r["line"].is_null() ? 0.0 : r["line"].as<double>();
        const double members = r["members"].as<double>(), free = r["free"].as<double>(), paying = r["paying"].as<double>(),
                     paidUp = r["paid_up"].as<double>(), behind = r["behind"].as<double>(), blocked = r["blocked"].as<double>(),
                     owed = r["owed"].as<double>();
        const double monthlyAll = paying * rate, monthlyCur = paidUp * rate;
        out["sections"].push_back({
            {"section_id", r["id"].as<long long>()}, {"name", std::string(r["name"].c_str())}, {"code", std::string(r["code"].c_str())},
            {"category", std::string(r["category"].c_str())}, {"rate", rate}, {"line", line},
            {"members", (long long)members}, {"free", (long long)free}, {"paying", (long long)paying}, {"paid_up", (long long)paidUp},
            {"behind", (long long)behind}, {"blocked", (long long)blocked}, {"owed", owed},
            {"projections", {{"all_members", {{"count", (long long)paying}, {"monthly", monthlyAll}, {"yearly", monthlyAll * 12}}},
                             {"current_dues", {{"count", (long long)paidUp}, {"monthly", monthlyCur}, {"yearly", monthlyCur * 12}}}}}});
        allMembers += members; allFree += free; allPaying += paying; allPaidUp += paidUp; allBehind += behind; allBlocked += blocked;
        allOwed += owed; allMonthlyAll += monthlyAll; allMonthlyCur += monthlyCur;
    }
    out["all"] = {{"members", (long long)allMembers}, {"free", (long long)allFree}, {"paying", (long long)allPaying},
                  {"paid_up", (long long)allPaidUp}, {"behind", (long long)allBehind}, {"blocked", (long long)allBlocked}, {"owed", allOwed},
                  {"projections", {{"all_members", {{"count", (long long)allPaying}, {"monthly", allMonthlyAll}, {"yearly", allMonthlyAll * 12}}},
                                   {"current_dues", {{"count", (long long)allPaidUp}, {"monthly", allMonthlyCur}, {"yearly", allMonthlyCur * 12}}}}}};
    return out;
}
