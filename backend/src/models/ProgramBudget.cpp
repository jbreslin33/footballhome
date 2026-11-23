#include "ProgramBudget.h"

#include <algorithm>

#include <cmath>
#include <chrono>
#include <map>
#include <mutex>
#include <stdexcept>
#include <set>
#include <string>
#include <vector>

#include "../database/Database.h"
#include "CashFlow.h"
#include "CoachingPlan.h"
#include "Expenses.h"

using nlohmann::json;

// Players per program read person_la_memberships, so build() is served only
// behind the laGet( route /api/finances/programs (LA → DB → render).

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
double round2(double v) { return std::round(v * 100.0) / 100.0; }
std::string ymOf(int year, int month) { char b[8]; std::snprintf(b, sizeof b, "%04d-%02d", year, month); return b; }

// LeagueApps money that counts (same rule as CashFlow: counted programs, a
// dispute posted twice lands once).
const char* kGross = "CASE WHEN pp.txn_type IN ('Refund', 'Partial Refund') THEN -pp.amount ELSE pp.amount END";
const char* kNet = "CASE WHEN pp.txn_type IN ('Refund', 'Partial Refund') THEN -pp.net_amount ELSE pp.net_amount END";
const char* kCounted =
    "JOIN la_soccer_programs s ON s.la_program_id = pp.la_program_id AND s.counts_in "
    "WHERE NOT (pp.txn_type IN ('Refund', 'Partial Refund') AND pp.raw->>'bankTransferId' IS NULL "
    "           AND pp.raw->>'notes' IN ('Automatic withdrawal for dispute on charge', 'DISPUTE FEE') "
    "           AND EXISTS (SELECT 1 FROM person_payments twin WHERE twin.la_invoice_id = pp.la_invoice_id "
    "                          AND twin.txn_type = pp.txn_type AND twin.amount = pp.amount "
    "                          AND twin.raw->>'bankTransferId' IS NOT NULL))";
// approved money only (mig 1386): cards at once, bank payments once LA paid them out
const char* kApproved = "(pp.txn_type <> 'Bank' OR pp.raw ? 'bankTransferId')";

struct Program {
    int id = 0; std::string code, label, kind; int ageFrom = 0, ageTo = 0; bool paysDues = true; int capacity = 0;
    std::vector<int> teams;
};
struct Season { int id = 0; std::string code, label; int from = 0, to = 0; };
// level / src / team / whole / with (mig 1639, 🧮 Program budgets): where the
// cost sits — the program itself, one of its teams, a shared coach, its
// section, the club, a grant — the whole cost before the split and the
// programs sharing it. Set by split() and the callers; "program" = its own.
struct Line { std::string group, category, key, label, detail; double amount = 0; bool assumed = false;
              std::string level = "program", src; int team = 0; double whole = 0; std::vector<int> with; };
Line at(Line l, const std::string& level, const std::string& src, int team = 0) { l.level = level; l.src = src; l.team = team; return l; }

// The books (CashFlow, Expenses) take seconds; a plan edit re-reads them, so
// they are kept for a minute. Plans and entries are always read fresh.
std::mutex gCacheMu;
std::chrono::steady_clock::time_point gCacheAt;
json gFlow, gProj;
std::pair<json, json> books(int clubId) {
    std::lock_guard<std::mutex> lock(gCacheMu);
    const auto now = std::chrono::steady_clock::now();
    if (gFlow.is_null() || now - gCacheAt > std::chrono::seconds(60)) {
        gFlow = CashFlow::build(clubId); gProj = Expenses::projection(clubId); gCacheAt = now;
    }
    return {gFlow, gProj};
}

// The months of a season in the budget year that starts in (startYear, startMonth).
std::vector<std::string> seasonMonths(const Season& s, int startYear, int startMonth) {
    std::vector<std::string> out;
    const int to = s.to >= s.from ? s.to : s.to + 12;
    for (int m = s.from; m <= to; ++m) {
        const int mm = (m - 1) % 12 + 1;
        out.push_back(ymOf(startYear + (mm < startMonth ? 1 : 0), mm));
    }
    return out;
}
}

json ProgramBudget::build(int clubId, const std::string& scenario) {
    const bool full = scenario == "capacity";
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    const std::string nowYm = db->query("SELECT to_char(now() AT TIME ZONE 'America/New_York', 'YYYY-MM') AS m")[0]["m"].c_str();

    // ── reference data ──
    std::vector<Program> programs;
    for (const auto& r : db->query(
            "SELECT p.id, p.code, p.label, p.kind, p.age_from, p.age_to, p.pays_dues, "
            // capacity = its own teams' roster size (a team shared with another
            // program — fall's two-year teams — only when it has no own team)
            // finance_programs.roster_size first (mig 1429: the projection's full
            // roster, apart from board caps), else the teams' max_roster
            "       COALESCE(p.roster_size, (SELECT MAX(t.max_roster) FROM finance_program_teams pt JOIN teams t ON t.id = pt.team_id "
            "                  WHERE pt.program_id = p.id AND t.is_active "
            "                    AND NOT EXISTS (SELECT 1 FROM finance_program_teams o WHERE o.team_id = pt.team_id AND o.program_id <> p.id)), "
            "                (SELECT MAX(t.max_roster) FROM finance_program_teams pt JOIN teams t ON t.id = pt.team_id "
            "                  WHERE pt.program_id = p.id AND t.is_active), 0) AS capacity, "
            "       COALESCE((SELECT array_agg(team_id ORDER BY team_id) FROM finance_program_teams WHERE program_id = p.id), '{}')::text AS teams "
            "  FROM finance_programs p WHERE p.club_id = $1::int AND p.is_active ORDER BY p.sort_order", {club})) {
        Program p; p.id = r["id"].as<int>(); p.code = str(r, "code"); p.label = str(r, "label"); p.kind = str(r, "kind");
        p.ageFrom = r["age_from"].is_null() ? 0 : r["age_from"].as<int>(); p.ageTo = r["age_to"].is_null() ? 0 : r["age_to"].as<int>();
        p.paysDues = r["pays_dues"].as<bool>(); p.capacity = r["capacity"].as<int>();
        std::string t = str(r, "teams"); if (t.size() > 2) { t = t.substr(1, t.size() - 2); size_t a = 0; while (a < t.size()) { size_t b = t.find(',', a); if (b == std::string::npos) b = t.size(); p.teams.push_back(std::stoi(t.substr(a, b - a))); a = b + 1; } }
        programs.push_back(p);
    }
    std::map<int, size_t> progIdx; for (size_t i = 0; i < programs.size(); ++i) progIdx[programs[i].id] = i;
    std::vector<Season> seasons;
    for (const auto& r : db->query("SELECT id, code, label, from_month, to_month FROM budget_seasons WHERE club_id = $1::int ORDER BY sort_order", {club}))
        seasons.push_back({r["id"].as<int>(), str(r, "code"), str(r, "label"), r["from_month"].as<int>(), r["to_month"].as<int>()});

    struct Year { int id; std::string label; int startYear, startMonth; bool thisYear; };
    std::vector<Year> years;
    for (const auto& r : db->query(
            "SELECT id, label, extract(year FROM starts_on)::int AS sy, extract(month FROM starts_on)::int AS sm, "
            "       (now() AT TIME ZONE 'America/New_York')::date BETWEEN starts_on AND ends_on AS this_year "
            "  FROM budget_years WHERE club_id = $1::int AND ends_on >= (now() AT TIME ZONE 'America/New_York')::date ORDER BY starts_on", {club}))
        years.push_back({r["id"].as<int>(), str(r, "label"), r["sy"].as<int>(), r["sm"].as<int>(), r["this_year"].as<bool>()});
    std::set<std::pair<int, int>> actual;
    for (const auto& r : db->query("SELECT budget_year_id, season_id FROM budget_season_actuals"))
        actual.insert({r["budget_year_id"].as<int>(), r["season_id"].as<int>()});

    double coachRate = 10, weeksPerYear = 50; int weeksRead = 4;
    {
        auto s = db->query("SELECT coach_rate_per_hour, weeks_per_year, practice_weeks_read FROM capacity_plan_settings "
                           " WHERE club_id = $1::int AND effective_from <= CURRENT_DATE ORDER BY effective_from DESC, id DESC LIMIT 1", {club});
        if (!s.empty()) { coachRate = num(s[0], "coach_rate_per_hour"); weeksPerYear = num(s[0], "weeks_per_year"); weeksRead = std::max(1, s[0]["practice_weeks_read"].as<int>()); }
    }
    // monthly dues per program kind (the section's latest policy)
    std::map<std::string, double> monthly;
    for (const auto& r : db->query(
            "SELECT DISTINCT ON (s.id) s.code, d.monthly_dues_usd FROM club_sections s "
            "  JOIN dues_policies d ON d.club_id = $1::int AND (d.club_section_id = s.id OR d.club_section_id IS NULL) "
            "   AND d.effective_from <= (now() AT TIME ZONE 'America/New_York')::date "
            " ORDER BY s.id, (d.club_section_id IS NULL), d.effective_from DESC, d.id DESC", {club})) {
        const std::string c = str(r, "code"), k = c == "M" ? "men" : c == "W" ? "women" : "youth";
        if (!monthly.count(k)) monthly[k] = num(r, "monthly_dues_usd");
    }
    // LeagueApps' actual fee rate this year (fees ÷ money before fees)
    double feeRatio = 0;
    {
        auto f = db->query(std::string("SELECT COALESCE(SUM(") + kGross + "),0)::float8 AS g, COALESCE(SUM(" + kGross + " - " + kNet + "),0)::float8 AS f "
                           "  FROM person_payments pp " + kCounted + " AND " + kApproved +
                           "   AND (pp.paid_at AT TIME ZONE 'America/New_York')::date >= (SELECT y.starts_on FROM cash_flow_policies c JOIN budget_years y ON y.id = c.budget_year_id WHERE c.club_id = " + club + ")");
        if (!f.empty() && num(f[0], "g") > 0) feeRatio = num(f[0], "f") / num(f[0], "g");
    }
    // Players per program, today and moved up an age per year ahead
    std::map<int, std::map<int, std::pair<int, int>>> heads;   // yearsAhead → program → {active, paying}
    for (size_t k = 0; k < years.size(); ++k)
        for (const auto& r : db->query(R"SQL(
                WITH act AS (
                    SELECT DISTINCT ON (lp.category, m.person_id) lp.category, m.person_id, m.la_payment_status
                      FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                     WHERE m.ended_at IS NULL AND lp.variant = 'active'
                     ORDER BY lp.category, m.person_id, m.la_registered_at DESC NULLS LAST)
                SELECT fh_finance_program($1::int, a.category, p.birth_date, $2::int) AS pid, COUNT(*) AS active,
                       COUNT(*) FILTER (WHERE a.la_payment_status <> 'NA_FREE' AND fh_dues_free_reason(a.person_id) IS NULL) AS paying
                  FROM act a JOIN persons p ON p.id = a.person_id GROUP BY 1)SQL", {club, std::to_string(k)})) {
            if (r["pid"].is_null()) continue;
            heads[(int)k][r["pid"].as<int>()] = {r["active"].as<int>(), r["paying"].as<int>()};
        }
    // 👥 Members today, per program (mig 1656; owner 11/23 "members is key here
    // and we need a good section for it"): everyone active, who owes tuition,
    // who of those has paid this month, who is on a league roster, and the
    // ones who don't pay (volunteers, injured, free in LeagueApps).
    // Paid up / overdue / injured are the Tuition page's own statuses (next_due_at
    // ahead = current; a current injury = its own 🩹 group), so the two pages agree.
    struct Members { int all = 0, owing = 0, paidNow = 0, overdue = 0, injured = 0, owingRostered = 0, free = 0, volunteers = 0, freeRostered = 0; };
    std::map<int, Members> membersNow;
    for (const auto& r : db->query(R"SQL(
            WITH act AS (
                SELECT DISTINCT ON (lp.category, m.person_id) lp.category, m.person_id, m.la_payment_status, m.next_due_at
                  FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                 WHERE m.ended_at IS NULL AND lp.variant = 'active'
                 ORDER BY lp.category, m.person_id, m.la_registered_at DESC NULLS LAST),
            inj AS (
                SELECT DISTINCT i.person_id FROM person_injuries i JOIN health_statuses h ON h.id = i.health_status_id AND h.is_injured
                 WHERE i.starts_at <= now() AND (i.ends_at IS NULL OR i.ends_at > now())),
            ros AS (
                SELECT DISTINCT tp.person_id FROM team_persons tp JOIN roster_statuses rs ON rs.id = tp.roster_status_id AND rs.counts_as_on_roster
                 WHERE tp.removed_at IS NULL),
            m AS (
                SELECT fh_finance_program($1::int, a.category, p.birth_date, 0) AS pid, a.person_id,
                       (a.la_payment_status <> 'NA_FREE' AND fh_dues_free_reason(a.person_id) IS NULL) AS owes,
                       fh_is_volunteer(a.person_id) AS vol, a.person_id IN (SELECT person_id FROM inj) AS hurt,
                       COALESCE(a.next_due_at > now(), false) AS paid_up
                  FROM act a JOIN persons p ON p.id = a.person_id)
            SELECT m.pid, COUNT(*) AS members, COUNT(*) FILTER (WHERE owes) AS owing,
                   COUNT(*) FILTER (WHERE owes AND NOT hurt AND paid_up) AS paid_now,
                   COUNT(*) FILTER (WHERE owes AND NOT hurt AND NOT paid_up) AS overdue,
                   COUNT(*) FILTER (WHERE owes AND hurt) AS injured,
                   COUNT(*) FILTER (WHERE owes AND m.person_id IN (SELECT person_id FROM ros)) AS owing_rostered,
                   COUNT(*) FILTER (WHERE NOT owes) AS free, COUNT(*) FILTER (WHERE NOT owes AND vol) AS volunteers,
                   COUNT(*) FILTER (WHERE NOT owes AND m.person_id IN (SELECT person_id FROM ros)) AS free_rostered
              FROM m WHERE m.pid IS NOT NULL GROUP BY 1)SQL", {club})) {
        Members m; m.all = r["members"].as<int>(); m.owing = r["owing"].as<int>(); m.paidNow = r["paid_now"].as<int>(); m.overdue = r["overdue"].as<int>(); m.injured = r["injured"].as<int>(); m.owingRostered = r["owing_rostered"].as<int>();
        m.free = r["free"].as<int>(); m.volunteers = r["volunteers"].as<int>(); m.freeRostered = r["free_rostered"].as<int>();
        membersNow[r["pid"].as<int>()] = m;
    }
    // Practice hours a week per program: the calendar's next whole weeks, the
    // busiest of its teams (as the old Full capacity did: a session that also carries a
    // men's team counts for the men only)
    std::map<int, double> calHours;
    std::map<int, json> calSlots;   // program → weekly practice slots
    {
        std::map<int, double> teamHours;
        for (const auto& r : db->query(R"SQL(
                WITH ev AS (
                  SELECT e.id, EXTRACT(EPOCH FROM (g.ends_at - g.starts_at)) / 3600.0 AS h
                    FROM gcal_events g JOIN fh_events e ON e.gcal_event_id = g.id AND e.kind = 'practice'
                   WHERE g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
                     AND g.starts_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' + interval '7 days'
                     AND g.starts_at <  date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' + make_interval(days => 7 + 7 * $1::int)
                ), mens AS (
                  SELECT DISTINCT et.fh_event_id FROM fh_event_teams et JOIN teams tm ON tm.id = et.team_id
                   WHERE et.fh_event_id IN (SELECT id FROM ev) AND tm.club_section_id = 1)
                SELECT et.team_id, SUM(ev.h) / $1::numeric AS per_week
                  FROM ev JOIN fh_event_teams et ON et.fh_event_id = ev.id JOIN teams t ON t.id = et.team_id
                 WHERE t.club_section_id IN (1, 2) OR ev.id NOT IN (SELECT fh_event_id FROM mens)
                 GROUP BY et.team_id)SQL", {std::to_string(weeksRead)}))
            teamHours[r["team_id"].as<int>()] = num(r, "per_week");
        for (const auto& p : programs) { double h = 0; for (int t : p.teams) h = std::max(h, teamHours.count(t) ? teamHours[t] : 0.0); calHours[p.id] = h; }
        // The weekly slots behind those hours (owner 11/17 "it should show the
        // schedule in there for that team"): the same calendar weeks, one row
        // per weekday + time + place that comes back at least half the weeks.
        std::map<int, std::vector<json>> teamSlots;
        for (const auto& r : db->query(R"SQL(
                WITH ev AS (
                  SELECT e.id, g.starts_at AT TIME ZONE 'America/New_York' AS s, g.ends_at AT TIME ZONE 'America/New_York' AS f,
                         split_part(COALESCE(g.location, ''), ',', 1) AS loc
                    FROM gcal_events g JOIN fh_events e ON e.gcal_event_id = g.id AND e.kind = 'practice'
                   WHERE g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
                     AND g.starts_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' + interval '7 days'
                     AND g.starts_at <  date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' + make_interval(days => 7 + 7 * $1::int))
                SELECT et.team_id, EXTRACT(ISODOW FROM ev.s)::int AS dow, to_char(ev.s, 'HH24:MI') AS st, to_char(ev.f, 'HH24:MI') AS en,
                       EXTRACT(EPOCH FROM (ev.f - ev.s)) / 3600.0 AS h, ev.loc, COUNT(*)::int AS n
                  FROM ev JOIN fh_event_teams et ON et.fh_event_id = ev.id
                 GROUP BY 1, 2, 3, 4, 5, 6
                HAVING COUNT(*) * 2 >= $1::int
                 ORDER BY 2, 3)SQL", {std::to_string(weeksRead)}))
            teamSlots[r["team_id"].as<int>()].push_back({{"dow", r["dow"].as<int>()}, {"start", str(r, "st")}, {"end", str(r, "en")},
                                                         {"hours", round2(num(r, "h"))}, {"location", str(r, "loc")}, {"weeks", r["n"].as<int>()}});
        for (const auto& p : programs) {
            std::map<std::string, json> seen;   // dow|start|end|place → slot (shared sessions once)
            for (int t : p.teams) if (teamSlots.count(t)) for (const auto& sl : teamSlots[t]) {
                const std::string k = std::to_string(sl["dow"].get<int>()) + "|" + sl["start"].get<std::string>() + "|" + sl["end"].get<std::string>() + "|" + sl["location"].get<std::string>();
                if (!seen.count(k) || seen[k]["weeks"].get<int>() < sl["weeks"].get<int>()) seen[k] = sl;
            }
            json arr = json::array(); for (auto& [k, sl] : seen) arr.push_back(sl);
            calSlots[p.id] = arr;
        }
    }
    // scope → programs (cash_flow_scopes): a team scope → the programs holding
    // the team; a section scope → that kind's programs; club → shared
    std::map<std::string, std::pair<std::string, int>> scopeInfo;   // code → {parent, team_id}
    std::map<std::string, std::string> scopeLabel;
    for (const auto& r : db->query("SELECT code, label, COALESCE(parent, '') AS parent, team_id FROM cash_flow_scopes")) {
        scopeInfo[str(r, "code")] = {str(r, "parent"), r["team_id"].is_null() ? 0 : r["team_id"].as<int>()};
        scopeLabel[str(r, "code")] = str(r, "label");
    }
    // a team's name on its pill: its budget scope's label (APSL, Liga 1) unless
    // that is also a program's name (scope "U10" = the U10 Travel Fall team)
    std::map<int, std::string> teamLabel;
    for (const auto& r : db->query("SELECT DISTINCT t.id, t.name FROM finance_program_teams pt JOIN teams t ON t.id = pt.team_id")) teamLabel[r["id"].as<int>()] = str(r, "name");
    for (const auto& [code, info] : scopeInfo) {
        if (!info.second || !teamLabel.count(info.second)) continue;
        bool isProgram = false; for (const auto& p : programs) if (p.label == scopeLabel[code]) isProgram = true;
        if (!isProgram) teamLabel[info.second] = scopeLabel[code];
    }
    auto kindOfTop = [](const std::string& top) { return top == "mens" ? std::string("men") : top == "womens" ? std::string("women") : top == "youth" ? std::string("youth") : std::string(); };
    // returns program ids; empty = shared (club-wide)
    auto programsOf = [&](const std::string& scope) {
        std::vector<int> out;
        auto it = scopeInfo.find(scope);
        if (it != scopeInfo.end() && it->second.second) {
            for (const auto& p : programs) for (int t : p.teams) if (t == it->second.second) { out.push_back(p.id); break; }
            if (!out.empty()) return out;
        }
        std::string top = scope; int guard = 0;
        while (scopeInfo.count(top) && !scopeInfo[top].first.empty() && guard++ < 10) top = scopeInfo[top].first;
        const std::string kind = kindOfTop(top);
        if (!kind.empty()) for (const auto& p : programs) if (p.kind == kind) out.push_back(p.id);
        return out;
    };
    // where a scope's cost sits: one of the programs' teams, a section (the
    // scope's top: Men's, Women's, Youth) or the club
    auto atScope = [&](Line l, const std::string& scope) {
        auto it = scopeInfo.find(scope);
        if (it != scopeInfo.end() && it->second.second)
            for (const auto& p : programs) for (int t : p.teams) if (t == it->second.second) return at(l, "team", teamLabel[t], t);
        std::string top = scope; int guard = 0;
        while (scopeInfo.count(top) && !scopeInfo[top].first.empty() && guard++ < 10) top = scopeInfo[top].first;
        if (kindOfTop(top).empty()) return at(l, "club", scopeLabel.count("club") ? scopeLabel["club"] : std::string{});
        return at(l, "section", scopeLabel[top]);
    };

    // ── the books (this year's real seasons) and the projection (money still ahead) ──
    const auto [flow, proj] = books(clubId);

    // real dues per program per month (approved money; payer → program)
    std::map<int, std::map<std::string, std::pair<double, double>>> realDues;   // program (0 = youth, no birth date) → ym → {gross, fee}
    for (const auto& r : db->query(std::string(
            "SELECT fh_finance_program($1::int, lp.category, pn.birth_date) AS pid, lp.category, "
            "       to_char(pp.paid_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym, "
            "       COALESCE(SUM(") + kGross + "), 0)::float8 AS gross, COALESCE(SUM(" + kGross + " - " + kNet + "), 0)::float8 AS fee "
            "  FROM person_payments pp JOIN leagueapps_programs lp ON lp.program_id = pp.la_program_id "
            "  LEFT JOIN persons pn ON pn.id = fh_payment_person(pp.la_registration_id, pp.la_user_id) "
            + kCounted + " AND " + kApproved +
            "   AND (pp.paid_at AT TIME ZONE 'America/New_York')::date >= (SELECT y.starts_on FROM cash_flow_policies c JOIN budget_years y ON y.id = c.budget_year_id WHERE c.club_id = $1::int) "
            " GROUP BY 1, 2, 3", {club})) {
        int pid = r["pid"].is_null() ? 0 : r["pid"].as<int>();
        if (!pid && str(r, "category") != "boys" && str(r, "category") != "girls") continue;
        auto& c = realDues[pid][str(r, "ym")]; c.first += num(r, "gross"); c.second += num(r, "fee");
    }

    // 👥 the year so far, month by month (owner 11/23 "show month by month of
    // since aug … with accurate number of paying members … full 12 month"):
    // members at each month's end (LeagueApps membership dates) and the
    // people whose tuition landed in the month.
    struct MonthReal { int members = 0, payers = 0; };
    std::map<int, std::map<std::string, MonthReal>> realMonths;   // program → ym
    for (const auto& r : db->query(R"SQL(
            WITH y AS (SELECT y.starts_on FROM cash_flow_policies c JOIN budget_years y ON y.id = c.budget_year_id WHERE c.club_id = $1::int),
            me AS (SELECT to_char(d, 'YYYY-MM') AS ym, ((d + interval '1 month')::timestamp AT TIME ZONE 'America/New_York') AS e
                     FROM y, generate_series(date_trunc('month', y.starts_on::timestamp), date_trunc('month', now() AT TIME ZONE 'America/New_York'), interval '1 month') d)
            SELECT me.ym, fh_finance_program($1::int, lp.category, p.birth_date, 0) AS pid, COUNT(DISTINCT m.person_id) AS n
              FROM me JOIN person_la_memberships m ON COALESCE(m.la_registered_at, m.joined_at) < me.e AND (m.ended_at IS NULL OR m.ended_at >= me.e)
              JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id AND lp.variant = 'active'
              JOIN persons p ON p.id = m.person_id
             GROUP BY 1, 2)SQL", {club}))
        if (!r["pid"].is_null()) realMonths[r["pid"].as<int>()][str(r, "ym")].members = r["n"].as<int>();
    for (const auto& r : db->query(std::string(
            "SELECT t.pid, t.ym, COUNT(*) AS n FROM ("
            "  SELECT fh_finance_program($1::int, lp.category, pn.birth_date) AS pid, pn.id AS person, "
            "         to_char(pp.paid_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym, SUM(") + kGross + ") AS g "
            "    FROM person_payments pp JOIN leagueapps_programs lp ON lp.program_id = pp.la_program_id "
            "    JOIN persons pn ON pn.id = fh_payment_person(pp.la_registration_id, pp.la_user_id) "
            + kCounted + " AND " + kApproved +
            "     AND (pp.paid_at AT TIME ZONE 'America/New_York')::date >= (SELECT y.starts_on FROM cash_flow_policies c JOIN budget_years y ON y.id = c.budget_year_id WHERE c.club_id = $1::int) "
            "   GROUP BY 1, 2, 3) t WHERE t.g > 0 AND t.pid IS NOT NULL GROUP BY 1, 2", {club}))
        realMonths[r["pid"].as<int>()][str(r, "ym")].payers = r["n"].as<int>();

    // Reality (feedback: projections from what really came in): the share of
    // dues actually collected over the last 3 closed months, per kind —
    // collected ÷ (today's paying players × dues × 3). A plan season's
    // default players = paying players × that share.
    std::map<std::string, double> collectRate;
    {
        std::vector<std::string> closed;
        { const int y = std::stoi(nowYm.substr(0, 4)), m = std::stoi(nowYm.substr(5, 2));
          for (int k = 1; k <= 3; ++k) { int mm = m - k, yy = y; while (mm <= 0) { mm += 12; --yy; } closed.push_back(ymOf(yy, mm)); } }
        const std::string yearStartYm = years.empty() ? nowYm : ymOf(years[0].startYear, years[0].startMonth);
        std::map<std::string, double> got, due; std::map<std::string, int> monthsIn;
        for (const auto& p : programs) {
            if (!p.paysDues) continue;
            int n = 0; for (const auto& ym : closed) if (ym >= yearStartYm) ++n;
            monthsIn[p.kind] = n;
            for (const auto& ym : closed) if (ym >= yearStartYm && realDues.count(p.id) && realDues[p.id].count(ym)) got[p.kind] += realDues[p.id][ym].first;
            const auto h = heads[0].count(p.id) ? heads[0][p.id] : std::pair<int, int>{0, 0};
            due[p.kind] += h.second * (monthly.count(p.kind) ? monthly[p.kind] : 0.0) * n;
        }
        for (const auto& [k, d] : due) collectRate[k] = d > 0 ? std::min(1.0, got[k] / d) : 1.0;
    }

    // rate card rows for every entry's league season
    struct Fee { int season; std::string kind, unit, band, category, label; double amount; };
    std::vector<Fee> fees;
    for (const auto& r : db->query(
            "SELECT lf.season_id, lf.fee_kind, lf.unit, COALESCE(lf.age_band, '') AS band, k.category, k.label, lf.amount_usd::float8 AS amount "
            "  FROM league_fees lf JOIN fee_kinds k ON k.code = lf.fee_kind "
            " WHERE NOT k.is_refundable AND lf.fee_kind <> 'game_coaching' AND (lf.tier IS NULL OR lf.tier = 'general') "
            "   AND lf.season_id IN (SELECT league_season_id FROM program_season_entries UNION SELECT season_id FROM team_season_entries)"))
        fees.push_back({r["season_id"].as<int>(), str(r, "fee_kind"), str(r, "unit"), str(r, "band"), str(r, "category"), str(r, "label"), num(r, "amount")});

    // This year's youth league entries = the travel teams that play them
    // (team_season_entries, mig 1495: U10 / U12 Travel Fall / Winter / Spring)
    // — one entry per team, its fees shared by the ages it draws from.
    struct TeamEntry { int team, season, count; std::string band, ym, year, league, seasonName; };
    std::vector<TeamEntry> teamEntries;
    for (const auto& r : db->query(
            "SELECT e.team_id, e.season_id, COALESCE(e.team_count, 1) AS n, COALESCE(substring(t.name from '^(U[0-9]+)'), '') AS band, "
            "       to_char(s.start_date, 'YYYY-MM') AS ym, y.label AS year, l.name AS league, s.name AS season_name "
            "  FROM team_season_entries e JOIN teams t ON t.id = e.team_id JOIN seasons s ON s.id = e.season_id JOIN leagues l ON l.id = s.league_id "
            "  JOIN budget_years y ON y.club_id = $1::int AND s.start_date BETWEEN y.starts_on AND y.ends_on "
            " WHERE NOT e.is_option AND t.gender_category IN ('boys', 'girls')", {club}))
        teamEntries.push_back({r["team_id"].as<int>(), r["season_id"].as<int>(), r["n"].as<int>(), str(r, "band"), str(r, "ym"), str(r, "year"), str(r, "league"), str(r, "season_name")});

    // Men's / Women's team fee plans for later years: by the league season's start
    struct PlanLine { int team; std::string year, ym, category, label, league; double amount; };
    std::vector<PlanLine> planLines;
    for (const auto& r : db->query(
            "SELECT pl.team_id, y.label AS year, to_char(s.start_date, 'YYYY-MM') AS ym, pl.category, pl.fee_label, pl.league, pl.proposed::float8 AS amount "
            "  FROM team_fee_plan_lines pl JOIN team_fee_plans p ON p.id = pl.plan_id "
            "  JOIN team_season_entries e ON e.id = pl.entry_id AND e.budget_from_plan AND NOT e.is_option "
            "  JOIN seasons s ON s.id = e.season_id "
            "  JOIN budget_years y ON y.club_id = $1::int AND s.start_date BETWEEN y.starts_on AND y.ends_on "
            " WHERE pl.category <> 'bonds' AND pl.fee_kind <> 'game_coaching' "
            "   AND (now() AT TIME ZONE 'America/New_York')::date < y.starts_on", {club}))
        planLines.push_back({r["team_id"].as<int>(), str(r, "year"), str(r, "ym"), str(r, "category"), str(r, "fee_label"), str(r, "league"), num(r, "amount")});

    // CASA rental per month (booked + projected, mig 1389)
    std::map<std::string, double> rentalByYm;
    for (const auto& r : db->query("SELECT ym, (booked_usd + projected_usd)::float8 AS amt FROM fh_field_rental_projected($1::int)", {club}))
        rentalByYm[str(r, "ym")] += num(r, "amt");

    // plans + entries
    struct Plan { bool has = false; int players = -1, teams = -1, games = 0; double ph = -1, weeks = -1, hpg = 0, rate = -1, grow = 0, collect = -1; int nonPaying = -1, nonPayingRostered = -1, payingOff = -1; bool paid = true, hasGrow = false; std::string note; };
    std::map<std::tuple<int, int, int>, Plan> plans;
    for (const auto& r : db->query("SELECT * FROM program_season_plans")) {
        Plan p; p.has = true;
        p.players = r["players"].is_null() ? -1 : r["players"].as<int>(); p.teams = r["teams"].is_null() ? -1 : r["teams"].as<int>();
        p.ph = r["practice_hours_week"].is_null() ? -1 : num(r, "practice_hours_week"); p.weeks = r["practice_weeks"].is_null() ? -1 : num(r, "practice_weeks");
        p.games = r["games"].as<int>(); p.hpg = num(r, "hours_per_game"); p.paid = r["coach_paid"].as<bool>();
        p.rate = r["coach_rate"].is_null() ? -1 : num(r, "coach_rate"); p.note = str(r, "note");
        p.hasGrow = !r["new_players_month"].is_null(); p.grow = p.hasGrow ? num(r, "new_players_month") : 0;
        p.collect = r["collect_pct"].is_null() ? -1 : num(r, "collect_pct");
        p.nonPaying = r["non_paying"].is_null() ? -1 : r["non_paying"].as<int>();
        p.nonPayingRostered = r["non_paying_on_roster"].is_null() ? -1 : r["non_paying_on_roster"].as<int>();
        p.payingOff = r["paying_off_roster"].is_null() ? -1 : r["paying_off_roster"].as<int>();
        plans[{r["program_id"].as<int>(), r["budget_year_id"].as<int>(), r["season_id"].as<int>()}] = p;
    }
    struct Entry { int leagueSeason; std::string band, league, seasonName; int teams; };
    std::map<std::tuple<int, int, int>, std::vector<Entry>> entries;
    for (const auto& r : db->query(
            "SELECT e.program_id, e.budget_year_id, e.season_id, e.league_season_id, COALESCE(e.age_band, '') AS band, e.teams, l.name AS league, ls.name AS season_name "
            "  FROM program_season_entries e JOIN seasons ls ON ls.id = e.league_season_id JOIN leagues l ON l.id = ls.league_id ORDER BY ls.start_date"))
        entries[{r["program_id"].as<int>(), r["budget_year_id"].as<int>(), r["season_id"].as<int>()}].push_back(
            {r["league_season_id"].as<int>(), str(r, "band"), str(r, "league"), str(r, "season_name"), r["teams"].is_null() ? -1 : r["teams"].as<int>()});

    // restricted grant / unrestricted awards per year
    std::map<std::string, std::pair<double, std::set<std::string>>> grants;   // year → {award, purposes}
    std::map<std::string, double> awardsFree;
    for (const auto& g : proj.value("plan_grants", json::array())) {
        const std::string y = g.value("budget_year", "");
        if (!g.value("purposes", json::array()).empty()) {
            auto& gr = grants[y]; gr.first += g.value("amount", 0.0);
            for (const auto& c : g["purposes"]) gr.second.insert(c.get<std::string>());
        } else awardsFree[y] += g.value("amount", 0.0);
    }

    // ── build ──
    json out = {{"scenario", full ? "capacity" : "expected"}, {"this_year", ""}, {"now_ym", nowYm}, {"years", json::array()}, {"seasons", json::array()}, {"programs", json::array()},
                {"settings", {{"coach_rate", coachRate}, {"weeks_per_year", weeksPerYear}, {"fee_ratio", feeRatio}, {"monthly", monthly}, {"collect_rate", collectRate}}}, {"budgets", json::object()}};
    // leagues a youth program can enter: league seasons with a rate card, by
    // budget year and the budget season their start falls in
    out["league_options"] = json::object();
    for (const auto& r : db->query(
            "SELECT ls.id, l.name AS league, ls.name, y.label AS year, extract(month FROM ls.start_date)::int AS m, "
            "       COALESCE((SELECT string_agg(DISTINCT lf.age_band, ',' ORDER BY lf.age_band) FROM league_fees lf WHERE lf.season_id = ls.id AND lf.age_band IS NOT NULL), '') AS bands "
            "  FROM seasons ls JOIN leagues l ON l.id = ls.league_id "
            "  JOIN budget_years y ON y.club_id = $1::int AND ls.start_date BETWEEN y.starts_on AND y.ends_on "
            " WHERE y.ends_on >= (now() AT TIME ZONE 'America/New_York')::date "
            "   AND EXISTS (SELECT 1 FROM league_fees lf WHERE lf.season_id = ls.id AND lf.fee_kind = 'team_entry') "
            " ORDER BY ls.start_date, l.name", {club})) {
        const int m = r["m"].as<int>(); std::string sc;
        for (const auto& se : seasons) { const int to = se.to >= se.from ? se.to : se.to + 12; for (int k = se.from; k <= to; ++k) if ((k - 1) % 12 + 1 == m) sc = se.code; }
        if (sc.empty()) continue;
        json bands = json::array(); { std::string b = str(r, "bands"); size_t a = 0; while (!b.empty() && a <= b.size()) { size_t e = b.find(',', a); if (e == std::string::npos) e = b.size(); bands.push_back(b.substr(a, e - a)); a = e + 1; } }
        out["league_options"][str(r, "year")][sc].push_back({{"id", r["id"].as<int>()}, {"league", str(r, "league")}, {"name", str(r, "name")}, {"bands", bands}});
    }
    out["teams"] = json::array();
    for (const auto& [tid, label] : teamLabel) {
        json codes = json::array(); for (const auto& p : programs) if (std::find(p.teams.begin(), p.teams.end(), tid) != p.teams.end()) codes.push_back(p.code);
        out["teams"].push_back({{"id", tid}, {"label", label}, {"programs", codes}});
    }
    for (const auto& s : seasons) out["seasons"].push_back({{"code", s.code}, {"label", s.label}, {"from_month", s.from}, {"to_month", s.to}});
    for (const auto& p : programs) out["programs"].push_back({{"id", p.id}, {"code", p.code}, {"label", p.label}, {"kind", p.kind}, {"age_from", p.ageFrom}, {"age_to", p.ageTo},
                                                              {"pays_dues", p.paysDues}, {"capacity", p.capacity}, {"calendar_hours", round2(calHours[p.id])},
                                                              {"weeks_read", weeksRead}, {"schedule", calSlots.count(p.id) ? calSlots[p.id] : json::array()}});

    // A plan season's default players = the players PAYING NOW (owner 11/18
    // "for this year and next year assume current numbers of players we have
    // now that are paying for programs") — this year and every later year,
    // youth and adults; a later year moves today's kids up an age (heads[yi]).
    // Typed boxes still win; 👥 Full capacity still fills every team.
    // Replaces 11/16 youth "full paid roster" and 11/17 adults "only grow".
    // Membership grows by the month (mig 1650; owner 11/23 "its a membership …
    // do it by year/month … a way to project to get more members each month …
    // even go over 70 … they are 'reserves'"): a plan season's
    // new_players_month is added every month, running on through the year and
    // into the next (a later year with typed players starts from those).  Only
    // the dues follow it — teams, coaching and the shared-cost split stay on
    // the season's players, so members past a full roster add no cost.
    std::map<int, double> grownBefore, grownYear;   // program → members added before this year / so far in it
    for (size_t yi = 0; yi < years.size(); ++yi) {
        const Year& Y = years[yi];
        for (auto& [pid, g] : grownYear) grownBefore[pid] += g;
        grownYear.clear();
        out["years"].push_back(Y.label);
        if (Y.thisYear) out["this_year"] = Y.label;
        json yj = {{"seasons", json::array()}, {"programs", json::object()}};
        // per season: program → lines; the paying weights for the splits
        std::map<int, std::map<int, std::vector<Line>>> L;   // season idx → program → lines
        std::map<int, std::map<int, double>> payW;            // season idx → program → paying players
        std::map<int, std::map<int, json>> meta;              // season idx → program → {players, teams, …}
        auto split = [&](int si, const std::vector<int>& ids, double amount, Line base) {
            double w = 0; for (int id : ids) w += payW[si][id];
            base.whole = amount; base.with.clear();
            for (int id : ids) if ((w > 0 ? payW[si][id] / w : 1.0 / ids.size()) > 0) base.with.push_back(id);
            for (int id : ids) {
                const double share = w > 0 ? payW[si][id] / w : 1.0 / ids.size();
                if (share <= 0 || std::fabs(amount * share) < 0.005) continue;
                Line l = base; l.amount = amount * share; L[si][id].push_back(l);
            }
        };
        auto allPaying = [&](int si) { std::vector<int> ids; for (const auto& p : programs) if (payW[si][p.id] > 0) ids.push_back(p.id); return ids; };
        // 🧑‍🏫 This year's coaching comes from the coaching plan (mig 1491,
        // CoachingPlan) when the year has one: each paid coach-session / game
        // block shared by the programs in it, by paying players — not "one
        // coach per team" (owner 11/18: Luke + Anthony at every youth session,
        // James all men's).  A year with no plan keeps the per-team estimate.
        std::map<std::string, std::vector<CoachingPlan::Item>> cpBySeason;
        try { CoachingPlan cp(clubId, Y.label); for (const auto& it : cp.items()) cpBySeason[it.season].push_back(it); }
        catch (const std::exception&) {}
        const bool useCp = !cpBySeason.empty();

        for (size_t si = 0; si < seasons.size(); ++si) {
            const Season& S = seasons[si];
            const auto months = seasonMonths(S, Y.startYear, Y.startMonth);
            const std::set<std::string> mset(months.begin(), months.end());
            const bool isReal = actual.count({Y.id, S.id}) > 0;
            yj["seasons"].push_back({{"code", S.code}, {"label", S.label}, {"real", isReal}, {"months", months}});
            const auto& hk = heads[(int)yi];
            // players and weights first (the splits need every program's)
            for (const auto& p : programs) {
                const auto h = hk.count(p.id) ? hk.at(p.id) : std::pair<int, int>{0, 0};
                const Plan pl = plans.count({p.id, Y.id, S.id}) ? plans[{p.id, Y.id, S.id}] : Plan{};
                const double rateLive = p.paysDues && collectRate.count(p.kind) ? collectRate[p.kind] : 1.0;
                const double rate0 = !isReal && p.paysDues && pl.collect >= 0 ? pl.collect / 100.0 : rateLive;   // his own share who pay (mig 1656)
                const int heads0 = p.paysDues ? h.second : h.first;
                const int cap = std::max(1, p.capacity);
                const int defPlayers = heads0;
                int players = isReal ? defPlayers : (pl.players >= 0 ? pl.players : defPlayers);
                int teams = isReal ? (players > 0 ? (players + cap - 1) / cap : 0) : (pl.teams >= 0 ? pl.teams : (players > 0 ? (players + cap - 1) / cap : 0));
                if (full && !isReal) { teams = std::max(1, pl.teams >= 0 ? pl.teams : teams); players = teams * cap; }
                payW[(int)si][p.id] = p.paysDues ? players : 0;
                const double ph = pl.ph >= 0 ? pl.ph : calHours[p.id];
                const double weeks = pl.weeks >= 0 ? pl.weeks : weeksPerYear * months.size() / 12.0;
                const double rate = pl.rate >= 0 ? pl.rate : coachRate;
                meta[(int)si][p.id] = {{"players", players}, {"players_default", defPlayers}, {"players_set", !isReal && pl.players >= 0},
                                       {"paying_now", heads0}, {"collect_rate", round2(rate0)},
                                       {"teams", teams}, {"teams_set", !isReal && pl.teams >= 0},
                                       {"practice_hours_week", round2(ph)}, {"practice_hours_set", pl.ph >= 0}, {"calendar_hours", round2(calHours[p.id])},
                                       {"practice_weeks", round2(weeks)}, {"practice_weeks_set", pl.weeks >= 0},
                                       {"games", pl.games}, {"hours_per_game", pl.hpg}, {"coach_paid", pl.paid}, {"coach_rate", rate}, {"coach_rate_set", pl.rate >= 0},
                                       {"capacity", p.capacity}, {"note", pl.note}};
                // members month by month (plan seasons): the season's players + the growth so far
                json byMonth = json::array(); double headMonths = 0;
                if (!isReal) {
                    const double g = full ? 0.0 : pl.grow;
                    for (const auto& ym : months) {
                        grownYear[p.id] += g;
                        const double n = std::max(0.0, players + grownYear[p.id] + (pl.players >= 0 || full ? 0.0 : grownBefore[p.id]));
                        byMonth.push_back({{"ym", ym}, {"players", round2(n)}}); headMonths += n;
                    }
                }
                meta[(int)si][p.id]["months"] = byMonth; meta[(int)si][p.id]["head_months"] = headMonths;
                if (isReal && yi == 0) {   // the months already lived: real members, payers, tuition
                    json lived = json::array();
                    for (const auto& ym : months) {
                        if (ym > nowYm) continue;
                        const MonthReal mr = realMonths.count(p.id) && realMonths[p.id].count(ym) ? realMonths[p.id][ym] : MonthReal{};
                        const double g = realDues.count(p.id) && realDues[p.id].count(ym) ? realDues[p.id][ym].first : 0.0;
                        lived.push_back({{"ym", ym}, {"members", mr.members}, {"paying", mr.payers}, {"tuition", round2(g)}, {"current", ym == nowYm}});
                    }
                    meta[(int)si][p.id]["months_real"] = lived;
                }
                {   // 👥 the Members section: today's counts + his own numbers (NULL = today's)
                    const Members mb = membersNow.count(p.id) ? membersNow[p.id] : Members{};
                    json& mj = meta[(int)si][p.id];
                    mj["members_now"] = {{"all", mb.all}, {"owing", mb.owing}, {"paid_now", mb.paidNow}, {"overdue", mb.overdue}, {"injured", mb.injured}, {"owing_rostered", mb.owingRostered},
                                         {"free", mb.free}, {"volunteers", mb.volunteers}, {"free_rostered", mb.freeRostered}};
                    const bool on = !isReal;
                    mj["collect_pct"] = std::round(1000 * rate0) / 10; mj["collect_pct_default"] = std::round(100 * rateLive); mj["collect_pct_set"] = on && pl.collect >= 0;
                    mj["non_paying_default"] = mb.free; mj["non_paying"] = on && pl.nonPaying >= 0 ? pl.nonPaying : mb.free; mj["non_paying_set"] = on && pl.nonPaying >= 0;
                    mj["non_paying_on_roster_default"] = mb.freeRostered; mj["non_paying_on_roster"] = on && pl.nonPayingRostered >= 0 ? pl.nonPayingRostered : mb.freeRostered; mj["non_paying_on_roster_set"] = on && pl.nonPayingRostered >= 0;
                    const int offDef = std::max(0, mb.owing - mb.owingRostered);
                    mj["paying_off_roster_default"] = offDef; mj["paying_off_roster"] = on && pl.payingOff >= 0 ? pl.payingOff : offDef; mj["paying_off_roster_set"] = on && pl.payingOff >= 0;
                }
                meta[(int)si][p.id]["new_players_month"] = pl.grow; meta[(int)si][p.id]["new_players_month_set"] = !isReal && pl.hasGrow;
            }

            if (isReal) {
                // dues: approved LeagueApps money in the season's months so far
                for (const auto& p : programs) {
                    double g = 0, f = 0;
                    if (realDues.count(p.id)) for (const auto& [ym, c] : realDues[p.id]) if (mset.count(ym)) { g += c.first; f += c.second; }
                    if (g) L[(int)si][p.id].push_back({"dues", "dues", "dues", "", "", g, false});
                    if (f) L[(int)si][p.id].push_back({"own", "la_fees", "la_fees", "", "", f, false});
                }
                if (realDues.count(0)) {   // youth payer with no birth date: split across youth by players
                    double g = 0, f = 0; for (const auto& [ym, c] : realDues[0]) if (mset.count(ym)) { g += c.first; f += c.second; }
                    std::vector<int> youth; for (const auto& p : programs) if (p.kind == "youth") youth.push_back(p.id);
                    if (g) split((int)si, youth, g, {"dues", "dues", "dues", "", "", 0, false});
                    if (f) split((int)si, youth, f, {"own", "la_fees", "la_fees", "", "", 0, false});
                }
                // costs: every real money-out item in the season (bonds are deposits)
                for (const auto& it : flow.value("items", json::array())) {
                    if (it.value("dir", "") != "out" || it.value("ahead", false)) continue;
                    const std::string ym = it.value("ym", ""), cat = it.value("category", "");
                    if (!mset.count(ym) || cat == "bonds") continue;
                    const double amt = it.value("amount", 0.0); if (std::fabs(amt) < 0.005) continue;
                    const auto ids = programsOf(it.value("scope", "club"));
                    if (ids.empty()) split((int)si, allPaying((int)si), amt, atScope({"shared", cat, "item", "", "", 0, false}, "club"));
                    else split((int)si, ids, amt, atScope({"own", cat, "item", "", "", 0, false}, it.value("scope", "club")));
                }
            } else {
                for (const auto& p : programs) {
                    const json& m = meta[(int)si][p.id];
                    const int players = m["players"], teams = m["teams"];
                    auto& lines = L[(int)si][p.id];
                    // dues: each month's members × monthly (mig 1650: they can grow)
                    const double headMonths = m.value("head_months", 0.0);
                    if (p.paysDues && headMonths > 0) {
                        const double mo = monthly.count(p.kind) ? monthly[p.kind] : 0.0;
                        // reality rule: the headcount stays whole, the money
                        // is what actually gets collected (last 3 months' share)
                        const double cr = m.value("collect_rate", 1.0);
                        const double dues = headMonths * mo * cr;
                        const double first = m["months"].front()["players"].get<double>(), last = m["months"].back()["players"].get<double>();
                        char who[48], d[160];
                        if (std::fabs(first - last) < 0.05) std::snprintf(who, sizeof who, "%.0f", first); else std::snprintf(who, sizeof who, "%.0f → %.0f", first, last);
                        if (cr < 0.995) std::snprintf(d, sizeof d, "%s × $%.0f × %zu × %.0f%% collected", who, mo, months.size(), 100 * cr);
                        else std::snprintf(d, sizeof d, "%s × $%.0f × %zu", who, mo, months.size());
                        lines.push_back({"dues", "dues", "dues", "", d, dues, true});
                        if (feeRatio > 0) { char f[64]; std::snprintf(f, sizeof f, "%.1f%%", 100 * feeRatio); lines.push_back({"own", "la_fees", "la_fees", "", f, dues * feeRatio, false}); }
                    }
                    // coaching: one coach per team, every practice and every game
                    // (only when the year has no coaching plan — see useCp)
                    if (!useCp && teams > 0 && m["coach_paid"].get<bool>()) {
                        const double ph = m["practice_hours_week"], weeks = m["practice_weeks"], rate = m["coach_rate"];
                        const int games = m["games"]; const double hpg = m["hours_per_game"];
                        // practice and game coaching on their own lines (owner 11/16
                        // "show all coaching on separate lines"); label = which
                        const double hp = teams * ph * weeks, hg = teams * games * hpg;
                        if (hp > 0) { char d[160]; std::snprintf(d, sizeof d, "%d × %.1f h × %.1f wk × $%.0f", teams, ph, weeks, rate);
                                      lines.push_back({"own", "labor", "coaching", "practice", d, hp * rate, true}); }
                        if (hg > 0) { char d[160]; std::snprintf(d, sizeof d, "%d × %d × %.2g h × $%.0f", teams, games, hpg, rate);
                                      lines.push_back({"own", "labor", "coaching", "games", d, hg * rate, true}); }
                    }
                    // youth: the leagues it enters, from the rate card
                    if (!Y.thisYear && p.kind == "youth" && teams > 0 && entries.count({p.id, Y.id, S.id})) {
                        for (const auto& e : entries[{p.id, Y.id, S.id}]) {
                            const int et = e.teams >= 0 ? e.teams : teams; if (et <= 0) continue;
                            // per fee kind + unit: the band's row if any, else the band-free one; several → the cheapest
                            std::map<std::pair<std::string, std::string>, const Fee*> pick;
                            for (const auto& f : fees) {
                                if (f.season != e.leagueSeason || (!f.band.empty() && f.band != e.band)) continue;
                                auto key = std::make_pair(f.kind, f.unit); auto it = pick.find(key);
                                if (it == pick.end()) { pick[key] = &f; continue; }
                                const Fee* cur = it->second;
                                if ((cur->band.empty() && !f.band.empty()) || (cur->band.empty() == f.band.empty() && f.amount < cur->amount)) it->second = &f;
                            }
                            const int games = m["games"];
                            for (const auto& [key, f] : pick) {
                                double qty = 0;
                                if (f->unit == "per_team_season" || f->unit == "per_entry") qty = et;
                                else if (f->unit == "per_player") qty = players;
                                else if (f->unit == "per_game") qty = (double)games * et;
                                else if (f->unit == "per_home_game") qty = std::ceil(games / 2.0) * et;
                                if (qty <= 0) continue;
                                char d[96]; std::snprintf(d, sizeof d, "$%.2f × %g", f->amount, qty);
                                lines.push_back({"own", f->category, "entry", e.league + " " + e.seasonName + " — " + f->label, d, f->amount * qty, true});
                            }
                        }
                    }
                    // Men's / Women's later years: their team fee plans, by season start
                    if (p.kind != "youth" && !Y.thisYear)
                        for (const auto& pl : planLines) {
                            if (pl.year != Y.label || !mset.count(pl.ym)) continue;
                            bool mine = false; for (int t : p.teams) if (t == pl.team) mine = true;
                            if (mine && std::fabs(pl.amount) >= 0.005) lines.push_back(at({"own", pl.category, "plan_line", pl.league + " — " + pl.label, "", pl.amount, true}, "team", teamLabel[pl.team], pl.team));
                        }
                }
                // this year's youth leagues: each travel team's entry once, from
                // the rate card (refs come from the referee policies below)
                if (Y.thisYear)
                    for (const auto& e : teamEntries) {
                        if (e.year != Y.label || !mset.count(e.ym)) continue;
                        std::vector<int> ids; for (const auto& p : programs) if (p.kind == "youth") for (int t : p.teams) if (t == e.team) { ids.push_back(p.id); break; }
                        if (ids.empty()) continue;
                        std::map<std::pair<std::string, std::string>, const Fee*> pick;
                        for (const auto& f : fees) {
                            if (f.season != e.season || f.kind == "referee" || (!f.band.empty() && f.band != e.band)) continue;
                            auto key = std::make_pair(f.kind, f.unit); auto it = pick.find(key);
                            if (it == pick.end()) { pick[key] = &f; continue; }
                            const Fee* cur = it->second;
                            if ((cur->band.empty() && !f.band.empty()) || (cur->band.empty() == f.band.empty() && f.amount < cur->amount)) it->second = &f;
                        }
                        for (const auto& [key, f] : pick) {
                            if (f->unit != "per_team_season" && f->unit != "per_entry") continue;
                            char d[96]; std::snprintf(d, sizeof d, "$%.2f × %d team", f->amount, e.count);
                            split((int)si, ids, f->amount * e.count, at({"own", f->category, "entry", e.league + " " + e.seasonName + " — " + f->label, d, 0, true}, "team", teamLabel[e.team], e.team));
                        }
                    }
                // coaching plan: each item split over its programs that pay a
                // coach this season (🧑‍🏫 volunteer = that program's share drops)
                if (useCp && cpBySeason.count(S.code))
                    for (const auto& it : cpBySeason[S.code]) {
                        std::vector<int> paid; double wAll = 0, wPaid = 0;
                        for (int id : it.programs) {
                            if (!progIdx.count(id)) continue;
                            const double w = payW[(int)si][id]; wAll += w;
                            if (meta[(int)si][id].value("coach_paid", true)) { paid.push_back(id); wPaid += w; }
                        }
                        if (paid.empty()) continue;
                        const double amt = it.amount() * (wAll > 0 ? wPaid / wAll : (double)paid.size() / it.programs.size());
                        char d[160]; std::snprintf(d, sizeof d, "%s — %s %d × %.2g h × $%.0f", it.coach.c_str(), it.label.c_str(), it.times, it.hoursEach, it.rate);
                        split((int)si, paid, amt, at({"own", "labor", "coaching", it.kind == "game" ? "games" : "practice", d, 0, true}, "coach", it.coach));
                    }
                // This year's plan seasons, Men's / Women's: league money and
                // refs still ahead (Expenses), by scope; budget lines (every
                // program) — the projected months in the season
                auto aheadIn = [&](const json& byMonth) { double v = 0; for (auto it = byMonth.begin(); it != byMonth.end(); ++it) if (mset.count(it.key()) && it.key() > nowYm) v += it.value().value("projected", 0.0); return v; };
                if (Y.thisYear) {
                    auto adultOnly = [&](std::vector<int> ids) { std::vector<int> o; for (int id : ids) if (programs[progIdx[id]].kind != "youth") o.push_back(id); return o; };
                    for (const auto& r : proj.value("plan_cash", json::array())) {
                        if (r.value("category", "") == "labor") continue;
                        const double v = aheadIn(r.value("by_month", json::object())); if (std::fabs(v) < 0.005) continue;
                        const auto ids = adultOnly(programsOf(r.value("scope", "club")));
                        if (!ids.empty()) split((int)si, ids, v, atScope({"own", r.value("category", ""), "plan_line", r.value("label", ""), "", 0, true}, r.value("scope", "club")));
                    }
                    // refs: every referee policy, youth too (its team's ages share it)
                    for (const auto& r : proj.value("ref_fees", json::array())) {
                        if (r.value("kind", "") != "referee") continue;
                        const double v = aheadIn(r.value("by_month", json::object())); if (std::fabs(v) < 0.005) continue;
                        const auto ids = programsOf(r.value("scope", "club"));
                        if (!ids.empty()) split((int)si, ids, v, atScope({"own", "referees", "plan_line", r.value("label", ""), "", 0, true}, r.value("scope", "club")));
                    }
                }
                for (const auto& b : proj.value("budget", json::array())) {
                    if (b.value("category", "") == "labor" || b.value("budget_year", "") != Y.label) continue;
                    const double v = Y.thisYear ? aheadIn(b.value("by_month", json::object())) : b.value("year_total", 0.0) * months.size() / 12.0;
                    if (std::fabs(v) < 0.005) continue;
                    const auto ids = programsOf(b.value("scope", "club"));
                    if (ids.empty()) split((int)si, allPaying((int)si), v, atScope({"shared", b.value("category", ""), "budget_line", b.value("label", ""), "", 0, b.value("is_assumed", false)}, "club"));
                    else split((int)si, ids, v, atScope({"own", b.value("category", ""), "budget_line", b.value("label", ""), "", 0, b.value("is_assumed", false)}, b.value("scope", "club")));
                }
            }
            // CASA rental in the season, by paying players
            { double v = 0; for (const auto& ym : months) v += rentalByYm.count(ym) ? rentalByYm[ym] : 0.0;
              if (v) split((int)si, allPaying((int)si), v, atScope({"support", "rental", "casa", "", "", 0, !isReal}, "club")); }
        }

        // the grant: used = min(award, the year's spend on its purposes), shared
        // by each program-season's spend on them; unrestricted awards by players
        if (grants.count(Y.label)) {
            const auto& [award, purposes] = grants[Y.label];
            std::map<std::pair<int, int>, double> elig; double total = 0;
            for (auto& [si, byP] : L) for (auto& [pid, lines] : byP) for (const auto& l : lines)
                if ((l.group == "own" || l.group == "shared") && purposes.count(l.category)) { elig[{si, pid}] += l.amount; total += l.amount; }
            const double used = std::min(award, total);
            if (total > 0) for (const auto& [k, v] : elig) {
                const double amt = used * v / total;
                if (amt < 0.005) continue;
                Line g = at({"support", "grant", "grant", "", "", amt, !actual.count({Y.id, seasons[k.first].id})}, "grant", "");
                g.whole = used; for (const auto& [k2, v2] : elig) if (k2.first == k.first && v2 > 0) g.with.push_back(k2.second);
                L[k.first][k.second].push_back(g);
            }
            yj["grant"] = {{"award", award}, {"used", round2(used)}, {"eligible", round2(total)}};
        }
        if (awardsFree.count(Y.label) && awardsFree[Y.label] > 0)
            for (size_t si = 0; si < seasons.size(); ++si) {
                const auto months = seasonMonths(seasons[si], Y.startYear, Y.startMonth);
                split((int)si, allPaying((int)si), awardsFree[Y.label] * months.size() / 12.0, at({"support", "awards", "awards", "", "", 0, true}, "grant", ""));
            }

        // 🧑‍🏫 Coach pay from the hours really worked (mig 1644; owner 11/20
        // "for coach pay just look at my current hours for coaching and
        // project. but separate practice from games and have games listed
        // by team then a total"): this year's invoice shifts on a practice
        // or a game, per coach — hours so far × (365 ÷ days since that
        // coach's first shift) × his rate.  An event's hours are shared by
        // the programs of its teams, by paying players; a game is listed
        // under its team.  Shifts on no event (other duties) are not coaching.
        if (Y.thisYear) {
            std::map<int, double> wYear; for (auto& [si, byP] : payW) for (auto& [pid, w] : byP) wYear[pid] += w;
            struct CH { std::string kind, coach, team; double hours = 0, yearHours = 0, rate = 0, amount = 0; int days = 0; };
            std::map<int, std::map<std::tuple<std::string, std::string, std::string>, CH>> byProg;
            for (const auto& r : db->query(R"SQL(
                WITH sh AS (
                    SELECT i.issuer_id, e.kind, s.work_date,
                           ARRAY(SELECT et.team_id FROM fh_event_teams et WHERE et.fh_event_id = e.id ORDER BY 1) AS teams,
                           COALESCE(NULLIF(s.hours, 0), EXTRACT(epoch FROM (s.end_at - s.start_at)) / 3600.0
                                    + CASE WHEN s.end_at <= s.start_at THEN 24 ELSE 0 END) AS hours
                      FROM invoice_work_shifts s JOIN invoices i ON i.id = s.invoice_id JOIN fh_events e ON e.id = s.fh_event_id
                      JOIN cash_flow_policies cp ON cp.club_id = $1::int JOIN budget_years y ON y.id = cp.budget_year_id
                     WHERE e.kind IN ('practice', 'match') AND s.work_date BETWEEN y.starts_on AND (now() AT TIME ZONE 'America/New_York')::date)
                SELECT sh.issuer_id, COALESCE(NULLIF(BTRIM(pn.first_name || ' ' || pn.last_name), ''), ii.payable_to) AS coach, ii.hourly_rate::float8 AS rate,
                       CASE WHEN sh.kind = 'match' THEN 'game' ELSE 'practice' END AS kind, sh.teams::text AS teams,
                       (SELECT t.name FROM teams t WHERE t.id = sh.teams[1]) AS team_name,
                       SUM(sh.hours)::float8 AS hours,
                       ((now() AT TIME ZONE 'America/New_York')::date - MIN(MIN(sh.work_date)) OVER (PARTITION BY sh.issuer_id) + 1)::int AS days
                  FROM sh JOIN invoice_issuers ii ON ii.id = sh.issuer_id LEFT JOIN persons pn ON pn.id = ii.person_id
                 GROUP BY 1, 2, 3, 4, 5, 6)SQL", {club})) {
                std::vector<int> tids; { std::string cur; for (char ch : std::string(r["teams"].c_str())) { if (ch >= '0' && ch <= '9') cur += ch; else if (!cur.empty()) { tids.push_back(std::stoi(cur)); cur.clear(); } } }
                std::vector<int> ids;
                for (const auto& p : programs) for (int t : p.teams) if (std::find(tids.begin(), tids.end(), t) != tids.end()) { ids.push_back(p.id); break; }
                if (ids.empty()) continue;
                const double hours = num(r, "hours"), rate = num(r, "rate"); const int days = std::max(1, r["days"].as<int>());
                const std::string kind = str(r, "kind");
                const std::string team = kind == "game" ? (!tids.empty() && teamLabel.count(tids[0]) ? teamLabel[tids[0]] : str(r, "team_name")) : std::string{};
                double w = 0; for (int id : ids) w += wYear[id];
                for (int id : ids) {
                    const double share = w > 0 ? wYear[id] / w : 1.0 / ids.size(); if (share <= 0) continue;
                    CH& c = byProg[id][std::make_tuple(kind, team, str(r, "coach"))];
                    c.kind = kind; c.coach = str(r, "coach"); c.team = team; c.rate = rate; c.days = days;
                    c.hours += hours * share; c.yearHours += hours * share * 365.0 / days; c.amount += hours * share * 365.0 / days * rate;
                }
            }
            yj["coach_hours"] = json::object();
            for (const auto& p : programs) {
                json arr = json::array();
                if (byProg.count(p.id)) for (const auto& [k, c] : byProg[p.id]) if (c.amount >= 0.5)
                    arr.push_back({{"kind", c.kind}, {"coach", c.coach}, {"team", c.team}, {"hours", round2(c.hours)}, {"days", c.days},
                                   {"year_hours", round2(c.yearHours)}, {"rate", c.rate}, {"amount", round2(c.amount)}});
                yj["coach_hours"][p.code] = arr;
            }
        }
        // what the owner changed on 🧮 Program budgets (mig 1644): line → {on, amount}
        yj["adjust"] = json::object();
        for (const auto& r : db->query("SELECT fp.code, a.line_key, a.is_on, a.amount_usd::float8 AS amount FROM program_budget_adjustments a "
                                       "  JOIN finance_programs fp ON fp.id = a.program_id WHERE a.budget_year_id = $1::int AND fp.club_id = $2::int", {std::to_string(Y.id), club}))
            yj["adjust"][str(r, "code")][str(r, "line_key")] = {{"on", r["is_on"].as<bool>()}, {"amount", r["amount"].is_null() ? json(nullptr) : json(r["amount"].as<double>())}};

        // out: program → season → {meta, lines}
        for (const auto& p : programs) {
            json pj = json::object();
            for (size_t si = 0; si < seasons.size(); ++si) {
                // fold same group/category/key/label lines together
                std::map<std::tuple<std::string, std::string, std::string, std::string>, Line> folded;
                for (const auto& l : L[(int)si][p.id]) {
                    auto k = std::make_tuple(l.group, l.category, l.key, l.label);
                    auto it = folded.find(k);
                    if (it == folded.end()) folded[k] = l; else { it->second.amount += l.amount; it->second.assumed = it->second.assumed || l.assumed; if (it->second.detail != l.detail) it->second.detail.clear(); }
                }
                json lines = json::array();
                for (const auto& [k, l] : folded) if (std::fabs(l.amount) >= 0.005)
                    lines.push_back({{"group", l.group}, {"category", l.category}, {"key", l.key}, {"label", l.label}, {"detail", l.detail}, {"amount", round2(l.amount)}, {"assumed", l.assumed}});
                // 🧮 the same money by where it sits (mig 1639): one part per
                // level + source + line, with the whole cost and its sharers
                std::map<std::tuple<std::string, std::string, int, std::string, std::string, std::string, std::string>, Line> byPart;
                for (Line l : L[(int)si][p.id]) {
                    if (l.with.empty()) { l.whole = l.amount; l.with = {p.id}; }
                    auto k = std::make_tuple(l.level, l.src, l.team, l.group, l.category, l.key, l.label);
                    auto it = byPart.find(k);
                    if (it == byPart.end()) { byPart[k] = l; continue; }
                    Line& o = it->second; o.amount += l.amount; o.whole += l.whole; o.assumed = o.assumed || l.assumed;
                    if (o.detail != l.detail) o.detail.clear();
                    for (int id : l.with) if (std::find(o.with.begin(), o.with.end(), id) == o.with.end()) o.with.push_back(id);
                }
                json parts = json::array();
                for (const auto& [k, l] : byPart) {
                    if (std::fabs(l.amount) < 0.005) continue;
                    json with = json::array(); for (const auto& q : programs) if (std::find(l.with.begin(), l.with.end(), q.id) != l.with.end()) with.push_back(q.code);
                    parts.push_back({{"level", l.level}, {"src", l.src}, {"team", l.team}, {"group", l.group}, {"category", l.category}, {"key", l.key}, {"label", l.label},
                                     {"detail", l.detail}, {"amount", round2(l.amount)}, {"whole", round2(l.whole)}, {"with", with}, {"assumed", l.assumed}});
                }
                json sj = meta[(int)si][p.id]; sj["lines"] = lines; sj["parts"] = parts;
                sj["entries"] = json::array();
                if (entries.count({p.id, Y.id, seasons[si].id}))
                    for (const auto& e : entries[{p.id, Y.id, seasons[si].id}])
                        sj["entries"].push_back({{"league_season_id", e.leagueSeason}, {"league", e.league}, {"name", e.seasonName}, {"age_band", e.band}, {"teams", e.teams >= 0 ? json(e.teams) : json(nullptr)}});
                pj[seasons[si].code] = sj;
            }
            yj["programs"][p.code] = pj;
        }
        out["budgets"][Y.label] = yj;
    }
    return out;
}

namespace {
// program id, year id and the plan seasons a save touches (never a real one)
struct Target { int program; int year; std::vector<int> seasons; };
Target target(int clubId, const std::string& program, const std::string& year, const std::string& season) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    auto p = db->query("SELECT id FROM finance_programs WHERE club_id = $1::int AND code = $2 AND is_active", {club, program});
    if (p.empty()) throw std::invalid_argument("Which program?");
    auto y = db->query("SELECT id FROM budget_years WHERE club_id = $1::int AND label = $2 AND ends_on >= (now() AT TIME ZONE 'America/New_York')::date", {club, year});
    if (y.empty()) throw std::invalid_argument("Which year?");
    Target t{p[0]["id"].as<int>(), y[0]["id"].as<int>(), {}};
    for (const auto& r : db->query(
            "SELECT s.id FROM budget_seasons s WHERE s.club_id = $1::int AND ($2 = 'all' OR s.code = $2) "
            "   AND NOT EXISTS (SELECT 1 FROM budget_season_actuals a WHERE a.budget_year_id = $3::int AND a.season_id = s.id) ORDER BY s.sort_order",
            {club, season, std::to_string(t.year)}))
        t.seasons.push_back(r["id"].as<int>());
    if (t.seasons.empty()) throw std::invalid_argument("That season is real (from the books) — it can't be planned.");
    return t;
}
}

void ProgramBudget::savePlan(int clubId, const std::string& program, const std::string& year, const std::string& season,
                             const json& fields, long long userId) {
    auto* db = Database::getInstance();
    const Target t = target(clubId, program, year, season);
    // column → kind; nullable ones go back to the live default on null
    struct Col { const char* name; char kind; bool nullable; double lo, hi; };
    static const Col cols[] = {
        {"players", 'i', true, 0, 500}, {"teams", 'i', true, 0, 20}, {"practice_hours_week", 'n', true, 0, 40},
        {"practice_weeks", 'n', true, 0, 30}, {"games", 'i', false, 0, 60}, {"hours_per_game", 'n', false, 0, 6},
        {"coach_paid", 'b', false, 0, 0}, {"coach_rate", 'n', true, 0, 200}, {"note", 't', true, 0, 0},
        {"new_players_month", 'n', true, -20, 50}, {"collect_pct", 'n', true, 0, 100},
        {"non_paying", 'i', true, 0, 500}, {"non_paying_on_roster", 'i', true, 0, 500}, {"paying_off_roster", 'i', true, 0, 500}};
    std::vector<std::pair<std::string, std::string>> sets;   // column, value ('' = NULL)
    for (auto it = fields.begin(); it != fields.end(); ++it) {
        const Col* c = nullptr; for (const auto& x : cols) if (it.key() == x.name) c = &x;
        if (!c) throw std::invalid_argument("Unknown field: " + it.key());
        const json& v = it.value();
        if (v.is_null()) {
            if (c->kind == 'i' && !c->nullable) sets.push_back({c->name, "0"});
            else if (!c->nullable) throw std::invalid_argument(std::string(c->name) + " needs a value.");
            else sets.push_back({c->name, ""});
            continue;
        }
        if (c->kind == 'b') { if (!v.is_boolean()) throw std::invalid_argument(std::string(c->name) + " is yes / no."); sets.push_back({c->name, v.get<bool>() ? "true" : "false"}); continue; }
        if (c->kind == 't') { if (!v.is_string()) throw std::invalid_argument("Note is text."); sets.push_back({c->name, v.get<std::string>().substr(0, 500)}); continue; }
        if (!v.is_number()) throw std::invalid_argument(std::string(c->name) + " is a number.");
        const double d = v.get<double>();
        if (d < c->lo || d > c->hi) throw std::invalid_argument(std::string(c->name) + " must be between " + std::to_string((int)c->lo) + " and " + std::to_string((int)c->hi) + ".");
        char b[32]; if (c->kind == 'i') std::snprintf(b, sizeof b, "%d", (int)std::lround(d)); else std::snprintf(b, sizeof b, "%.2f", d);
        sets.push_back({c->name, b});
    }
    if (sets.empty()) throw std::invalid_argument("Nothing to change.");
    const std::string uid = userId > 0 ? std::to_string(userId) : std::string{};
    for (const int sid : t.seasons) {
        db->query("INSERT INTO program_season_plans (program_id, budget_year_id, season_id) VALUES ($1::int, $2::int, $3::int) "
                  "ON CONFLICT (program_id, budget_year_id, season_id) DO NOTHING",
                  {std::to_string(t.program), std::to_string(t.year), std::to_string(sid)});
        for (const auto& [col, val] : sets)
            db->query("UPDATE program_season_plans SET " + col + " = NULLIF($1, '')::" +
                      (col == "coach_paid" ? "boolean" : col == "note" ? "text" : (col == "players" || col == "teams" || col == "games" || col == "non_paying" || col == "non_paying_on_roster" || col == "paying_off_roster") ? "integer" : "numeric") +
                      ", updated_at = now(), updated_by_user_id = NULLIF($2, '')::int "
                      " WHERE program_id = $3::int AND budget_year_id = $4::int AND season_id = $5::int",
                      {val, uid, std::to_string(t.program), std::to_string(t.year), std::to_string(sid)});
    }
}

void ProgramBudget::saveEntry(int clubId, const std::string& program, const std::string& year, const std::string& season,
                              int leagueSeasonId, const std::string& ageBand, const json& teams, bool remove) {
    auto* db = Database::getInstance();
    if (season == "all") throw std::invalid_argument("Pick one season.");
    const Target t = target(clubId, program, year, season);
    const std::string p = std::to_string(t.program), y = std::to_string(t.year), s = std::to_string(t.seasons[0]), ls = std::to_string(leagueSeasonId);
    if (remove) {
        db->query("DELETE FROM program_season_entries WHERE program_id = $1::int AND budget_year_id = $2::int AND season_id = $3::int AND league_season_id = $4::int", {p, y, s, ls});
        return;
    }
    if (db->query("SELECT 1 FROM seasons WHERE id = $1::int", {ls}).empty()) throw std::invalid_argument("Which league season?");
    std::string tv; if (teams.is_number()) { const int n = teams.get<int>(); if (n < 0 || n > 20) throw std::invalid_argument("Teams must be between 0 and 20."); tv = std::to_string(n); }
    db->query("INSERT INTO program_season_entries (program_id, budget_year_id, season_id, league_season_id, age_band, teams, note) "
              "VALUES ($1::int, $2::int, $3::int, $4::int, NULLIF($5, ''), NULLIF($6, '')::int, 'Set on the page') "
              "ON CONFLICT (program_id, budget_year_id, season_id, league_season_id) DO UPDATE SET age_band = EXCLUDED.age_band, teams = EXCLUDED.teams",
              {p, y, s, ls, ageBand.substr(0, 10), tv});
}

// 🧮 Who pays for a team (mig 1639): add / drop one program on a budget team
// (finance_program_teams). Only teams already in the budget; a team always
// keeps at least one payer.
void ProgramBudget::saveTeamProgram(int clubId, int teamId, const std::string& program, bool on) {
    auto* db = Database::getInstance();
    auto p = db->query("SELECT id FROM finance_programs WHERE club_id = $1::int AND code = $2 AND is_active", {std::to_string(clubId), program});
    if (p.empty()) throw std::invalid_argument("Which program?");
    const std::string pid = std::to_string(p[0]["id"].as<int>()), tid = std::to_string(teamId);
    auto n = db->query("SELECT COUNT(*) AS n, COUNT(*) FILTER (WHERE fpt.program_id = $2::int) AS mine FROM finance_program_teams fpt "
                       "  JOIN finance_programs fp ON fp.id = fpt.program_id AND fp.club_id = $3::int WHERE fpt.team_id = $1::int", {tid, pid, std::to_string(clubId)});
    const int all = n[0]["n"].as<int>(), mine = n[0]["mine"].as<int>();
    if (all == 0) throw std::invalid_argument("That team is not in the budget.");
    if (on) db->query("INSERT INTO finance_program_teams (program_id, team_id) VALUES ($1::int, $2::int) ON CONFLICT DO NOTHING", {pid, tid});
    else {
        if (mine && all <= 1) throw std::invalid_argument("A team needs at least one program paying for it.");
        db->query("DELETE FROM finance_program_teams WHERE program_id = $1::int AND team_id = $2::int", {pid, tid});
    }
}

// 🧮 One line of a program's year, as the owner wants it (mig 1644): off and /
// or his own amount.  fields {on: bool, amount: number | null}; a line that is
// on with no amount of his own has no row (= the worked-out number).
void ProgramBudget::saveLine(int clubId, const std::string& program, const std::string& year, const std::string& key, const json& fields, long long userId) {
    auto* db = Database::getInstance();
    if (key.empty() || key.size() > 400) throw std::invalid_argument("Which line?");
    auto p = db->query("SELECT id FROM finance_programs WHERE club_id = $1::int AND code = $2 AND is_active", {std::to_string(clubId), program});
    if (p.empty()) throw std::invalid_argument("Which program?");
    auto y = db->query("SELECT id FROM budget_years WHERE club_id = $1::int AND label = $2", {std::to_string(clubId), year});
    if (y.empty()) throw std::invalid_argument("Which year?");
    const std::string pid = std::to_string(p[0]["id"].as<int>()), yid = std::to_string(y[0]["id"].as<int>());
    auto cur = db->query("SELECT is_on, amount_usd::float8 AS amount FROM program_budget_adjustments WHERE program_id = $1::int AND budget_year_id = $2::int AND line_key = $3", {pid, yid, key});
    bool on = cur.empty() ? true : cur[0]["is_on"].as<bool>();
    bool hasAmount = !cur.empty() && !cur[0]["amount"].is_null();
    double amount = hasAmount ? cur[0]["amount"].as<double>() : 0.0;
    if (fields.contains("on")) { if (!fields["on"].is_boolean()) throw std::invalid_argument("On is yes / no."); on = fields["on"].get<bool>(); }
    if (fields.contains("amount")) {
        if (fields["amount"].is_null()) hasAmount = false;
        else if (!fields["amount"].is_number()) throw std::invalid_argument("The amount is a number.");
        else { amount = fields["amount"].get<double>(); hasAmount = true; if (amount < 0 || amount > 10000000) throw std::invalid_argument("The amount must be between 0 and 10,000,000."); }
    }
    if (on && !hasAmount) { db->query("DELETE FROM program_budget_adjustments WHERE program_id = $1::int AND budget_year_id = $2::int AND line_key = $3", {pid, yid, key}); return; }
    char b[32]; std::snprintf(b, sizeof b, "%.2f", amount);
    db->query("INSERT INTO program_budget_adjustments (program_id, budget_year_id, line_key, is_on, amount_usd, updated_by_user_id) "
              "VALUES ($1::int, $2::int, $3, $4::boolean, NULLIF($5, '')::numeric, NULLIF($6, '')::int) "
              "ON CONFLICT (program_id, budget_year_id, line_key) DO UPDATE SET is_on = EXCLUDED.is_on, amount_usd = EXCLUDED.amount_usd, updated_at = now(), updated_by_user_id = EXCLUDED.updated_by_user_id",
              {pid, yid, key, on ? "true" : "false", hasAmount ? std::string(b) : std::string{}, userId > 0 ? std::to_string(userId) : std::string{}});
}
