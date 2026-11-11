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
    double allMembers = 0, allFree = 0, allVolunteers = 0, allInjured = 0, allPaying = 0, allPaidUp = 0, allBehind = 0, allBlocked = 0, allOwed = 0,
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
                   fh_dues_free_reason(m.person_id) AS free_reason,
                   fh_dues_balance_usd(m.person_id) AS owed
              FROM person_la_memberships m
              JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
             WHERE m.ended_at IS NULL AND lp.variant IN ('active', 'pickup')   -- pickup = club member for dues (mig 1240)
             ORDER BY lp.category, m.person_id, m.la_registered_at DESC NULLS LAST
        )
        SELECT sec.id, sec.name, sec.code, sec.category, sec.rate, sec.line,
               COUNT(mem.person_id)                                                        AS members,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status = 'NA_FREE')       AS free,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason = 'volunteer') AS volunteers,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason = 'injured')   AS injured,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason IS NULL)       AS paying,
               COUNT(mem.person_id) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason IS NULL AND mem.owed = 0) AS paid_up,
               COUNT(mem.person_id) FILTER (WHERE mem.owed > 0 AND mem.owed < sec.line)    AS behind,
               COUNT(mem.person_id) FILTER (WHERE mem.owed >= sec.line)                    AS blocked,
               COALESCE(SUM(mem.owed), 0)                                                  AS owed
          FROM sec LEFT JOIN mem ON mem.category = sec.category
         WHERE sec.category IS NOT NULL
         GROUP BY sec.id, sec.name, sec.code, sec.category, sec.rate, sec.line, sec.sort_order
         ORDER BY sec.sort_order, sec.id)SQL", {club})) {
        const double rate = r["rate"].is_null() ? 0.0 : r["rate"].as<double>();
        const double line = r["line"].is_null() ? 0.0 : r["line"].as<double>();
        const double members = r["members"].as<double>(), free = r["free"].as<double>(), volunteers = r["volunteers"].as<double>(), injured = r["injured"].as<double>(), paying = r["paying"].as<double>(),
                     paidUp = r["paid_up"].as<double>(), behind = r["behind"].as<double>(), blocked = r["blocked"].as<double>(),
                     owed = r["owed"].as<double>();
        const double monthlyAll = paying * rate, monthlyCur = paidUp * rate;
        out["sections"].push_back({
            {"section_id", r["id"].as<long long>()}, {"name", std::string(r["name"].c_str())}, {"code", std::string(r["code"].c_str())},
            {"category", std::string(r["category"].c_str())}, {"rate", rate}, {"line", line},
            {"members", (long long)members}, {"free", (long long)free}, {"volunteers", (long long)volunteers}, {"injured", (long long)injured}, {"paying", (long long)paying}, {"paid_up", (long long)paidUp},
            {"behind", (long long)behind}, {"blocked", (long long)blocked}, {"owed", owed},
            {"projections", {{"all_members", {{"count", (long long)paying}, {"monthly", monthlyAll}, {"yearly", monthlyAll * 12}}},
                             {"current_dues", {{"count", (long long)paidUp}, {"monthly", monthlyCur}, {"yearly", monthlyCur * 12}}}}}});
        allMembers += members; allFree += free; allVolunteers += volunteers; allInjured += injured; allPaying += paying; allPaidUp += paidUp; allBehind += behind; allBlocked += blocked;
        allOwed += owed; allMonthlyAll += monthlyAll; allMonthlyCur += monthlyCur;
    }
    // The same counts per team (mig 986, owner: "on summary if i could break
    // down by pills for just apsl"): each member once, on the team their dues
    // count for (cash_flow_dues_scope, migs 973/975/977); no team = the section.
    out["teams"] = json::array();
    for (const auto& r : db->query(R"SQL(
        WITH sec AS (
            SELECT s.id, s.code, CASE s.code WHEN 'M' THEN 'men' WHEN 'W' THEN 'women' WHEN 'B' THEN 'boys' WHEN 'G' THEN 'girls' END AS category,
                   fh_monthly_dues_usd($1::int, s.id) AS rate, fh_dues_line_usd($1::int, s.id) AS line
              FROM club_sections s
        ), mem AS (
            SELECT DISTINCT ON (lp.category, m.person_id) lp.category, m.person_id, m.la_payment_status,
                   fh_dues_free_reason(m.person_id) AS free_reason, fh_dues_balance_usd(m.person_id) AS owed,
                   cash_flow_dues_scope(m.person_id, lp.category, now()) AS scope
              FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
             WHERE m.ended_at IS NULL AND lp.variant IN ('active', 'pickup')   -- pickup = club member for dues (mig 1240)
             ORDER BY lp.category, m.person_id, m.la_registered_at DESC NULLS LAST
        )
        SELECT mem.scope, sec.code, sec.rate, sec.line, sc.label, sc.sort_order,
               COUNT(*) AS members,
               COUNT(*) FILTER (WHERE mem.la_payment_status = 'NA_FREE') AS free,
               COUNT(*) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason = 'volunteer') AS volunteers,
               COUNT(*) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason = 'injured') AS injured,
               COUNT(*) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason IS NULL) AS paying,
               COUNT(*) FILTER (WHERE mem.la_payment_status <> 'NA_FREE' AND mem.free_reason IS NULL AND mem.owed = 0) AS paid_up,
               COUNT(*) FILTER (WHERE mem.owed > 0 AND mem.owed < sec.line) AS behind,
               COUNT(*) FILTER (WHERE mem.owed >= sec.line) AS blocked,
               COALESCE(SUM(mem.owed), 0) AS owed
          FROM mem JOIN sec ON sec.category = mem.category LEFT JOIN cash_flow_scopes sc ON sc.code = mem.scope
         GROUP BY mem.scope, sec.code, sec.rate, sec.line, sc.label, sc.sort_order
         ORDER BY sc.sort_order NULLS LAST, mem.scope)SQL", {club})) {
        const double rate = r["rate"].is_null() ? 0.0 : r["rate"].as<double>();
        const double paying = r["paying"].as<double>(), paidUp = r["paid_up"].as<double>();
        out["teams"].push_back({
            {"scope", std::string(r["scope"].c_str())}, {"label", r["label"].is_null() ? std::string(r["scope"].c_str()) : std::string(r["label"].c_str())},
            {"code", std::string(r["code"].c_str())}, {"rate", rate}, {"line", r["line"].is_null() ? 0.0 : r["line"].as<double>()},
            {"members", r["members"].as<long long>()}, {"free", r["free"].as<long long>()}, {"volunteers", r["volunteers"].as<long long>()},
            {"injured", r["injured"].as<long long>()}, {"paying", (long long)paying}, {"paid_up", (long long)paidUp},
            {"behind", r["behind"].as<long long>()}, {"blocked", r["blocked"].as<long long>()}, {"owed", r["owed"].as<double>()},
            {"projections", {{"all_members", {{"count", (long long)paying}, {"monthly", paying * rate}, {"yearly", paying * rate * 12}}},
                             {"current_dues", {{"count", (long long)paidUp}, {"monthly", paidUp * rate}, {"yearly", paidUp * rate * 12}}}}}});
    }
    out["all"] = {{"members", (long long)allMembers}, {"free", (long long)allFree}, {"volunteers", (long long)allVolunteers}, {"injured", (long long)allInjured}, {"paying", (long long)allPaying},
                  {"paid_up", (long long)allPaidUp}, {"behind", (long long)allBehind}, {"blocked", (long long)allBlocked}, {"owed", allOwed},
                  {"projections", {{"all_members", {{"count", (long long)allPaying}, {"monthly", allMonthlyAll}, {"yearly", allMonthlyAll * 12}}},
                                   {"current_dues", {{"count", (long long)allPaidUp}, {"monthly", allMonthlyCur}, {"yearly", allMonthlyCur * 12}}}}}};
    return out;
}
