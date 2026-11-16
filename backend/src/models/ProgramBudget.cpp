#include "ProgramBudget.h"

#include <cmath>
#include <map>
#include <set>
#include <string>
#include <vector>

#include "../database/Database.h"
#include "CashFlow.h"
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
struct Line { std::string group, category, key, label, detail; double amount = 0; bool assumed = false; };

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

json ProgramBudget::build(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    const std::string nowYm = db->query("SELECT to_char(now() AT TIME ZONE 'America/New_York', 'YYYY-MM') AS m")[0]["m"].c_str();

    // ── reference data ──
    std::vector<Program> programs;
    for (const auto& r : db->query(
            "SELECT p.id, p.code, p.label, p.kind, p.age_from, p.age_to, p.pays_dues, "
            "       COALESCE((SELECT MAX(t.max_roster) FROM finance_program_teams pt JOIN teams t ON t.id = pt.team_id "
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
    // Practice hours a week per program: the calendar's next whole weeks, the
    // busiest of its teams (as CapacityPlan: a session that also carries a
    // men's team counts for the men only)
    std::map<int, double> calHours;
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
    }
    // scope → programs (cash_flow_scopes): a team scope → the programs holding
    // the team; a section scope → that kind's programs; club → shared
    std::map<std::string, std::pair<std::string, int>> scopeInfo;   // code → {parent, team_id}
    for (const auto& r : db->query("SELECT code, COALESCE(parent, '') AS parent, team_id FROM cash_flow_scopes"))
        scopeInfo[str(r, "code")] = {str(r, "parent"), r["team_id"].is_null() ? 0 : r["team_id"].as<int>()};
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

    // ── the books (this year's real seasons) and the projection (money still ahead) ──
    const json flow = CashFlow::build(clubId);
    const json proj = Expenses::projection(clubId);

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
            "   AND lf.season_id IN (SELECT league_season_id FROM program_season_entries)"))
        fees.push_back({r["season_id"].as<int>(), str(r, "fee_kind"), str(r, "unit"), str(r, "band"), str(r, "category"), str(r, "label"), num(r, "amount")});

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
    struct Plan { bool has = false; int players = -1, teams = -1, games = 0; double ph = -1, weeks = -1, hpg = 0, rate = -1; bool paid = true; std::string note; };
    std::map<std::tuple<int, int, int>, Plan> plans;
    for (const auto& r : db->query("SELECT * FROM program_season_plans")) {
        Plan p; p.has = true;
        p.players = r["players"].is_null() ? -1 : r["players"].as<int>(); p.teams = r["teams"].is_null() ? -1 : r["teams"].as<int>();
        p.ph = r["practice_hours_week"].is_null() ? -1 : num(r, "practice_hours_week"); p.weeks = r["practice_weeks"].is_null() ? -1 : num(r, "practice_weeks");
        p.games = r["games"].as<int>(); p.hpg = num(r, "hours_per_game"); p.paid = r["coach_paid"].as<bool>();
        p.rate = r["coach_rate"].is_null() ? -1 : num(r, "coach_rate"); p.note = str(r, "note");
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
    json out = {{"this_year", ""}, {"now_ym", nowYm}, {"years", json::array()}, {"seasons", json::array()}, {"programs", json::array()},
                {"settings", {{"coach_rate", coachRate}, {"weeks_per_year", weeksPerYear}, {"fee_ratio", feeRatio}, {"monthly", monthly}, {"collect_rate", collectRate}}}, {"budgets", json::object()}};
    for (const auto& s : seasons) out["seasons"].push_back({{"code", s.code}, {"label", s.label}, {"from_month", s.from}, {"to_month", s.to}});
    for (const auto& p : programs) out["programs"].push_back({{"id", p.id}, {"code", p.code}, {"label", p.label}, {"kind", p.kind}, {"age_from", p.ageFrom}, {"age_to", p.ageTo},
                                                              {"pays_dues", p.paysDues}, {"capacity", p.capacity}, {"calendar_hours", round2(calHours[p.id])}});

    for (size_t yi = 0; yi < years.size(); ++yi) {
        const Year& Y = years[yi];
        out["years"].push_back(Y.label);
        if (Y.thisYear) out["this_year"] = Y.label;
        json yj = {{"seasons", json::array()}, {"programs", json::object()}};
        // per season: program → lines; the paying weights for the splits
        std::map<int, std::map<int, std::vector<Line>>> L;   // season idx → program → lines
        std::map<int, std::map<int, double>> payW;            // season idx → program → paying players
        std::map<int, std::map<int, json>> meta;              // season idx → program → {players, teams, …}
        auto split = [&](int si, const std::vector<int>& ids, double amount, Line base) {
            double w = 0; for (int id : ids) w += payW[si][id];
            for (int id : ids) {
                const double share = w > 0 ? payW[si][id] / w : 1.0 / ids.size();
                if (share <= 0 || std::fabs(amount * share) < 0.005) continue;
                Line l = base; l.amount = amount * share; L[si][id].push_back(l);
            }
        };
        auto allPaying = [&](int si) { std::vector<int> ids; for (const auto& p : programs) if (payW[si][p.id] > 0) ids.push_back(p.id); return ids; };

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
                const double rate0 = p.paysDues && collectRate.count(p.kind) ? collectRate[p.kind] : 1.0;
                const int heads0 = p.paysDues ? h.second : h.first;
                const int defPlayers = isReal ? heads0 : (int)std::lround(heads0 * rate0);
                const int players = isReal ? defPlayers : (pl.players >= 0 ? pl.players : defPlayers);
                const int cap = std::max(1, p.capacity);
                const int teams = isReal ? (players > 0 ? (players + cap - 1) / cap : 0) : (pl.teams >= 0 ? pl.teams : (players > 0 ? (players + cap - 1) / cap : 0));
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
                    if (ids.empty()) split((int)si, allPaying((int)si), amt, {"shared", cat, "item", "", "", 0, false});
                    else split((int)si, ids, amt, {"own", cat, "item", "", "", 0, false});
                }
            } else {
                for (const auto& p : programs) {
                    const json& m = meta[(int)si][p.id];
                    const int players = m["players"], teams = m["teams"];
                    auto& lines = L[(int)si][p.id];
                    // dues: players × monthly × months
                    if (p.paysDues && players > 0) {
                        const double mo = monthly.count(p.kind) ? monthly[p.kind] : 0.0;
                        const double dues = players * mo * months.size();
                        char d[96]; std::snprintf(d, sizeof d, "%d × $%.0f × %zu", players, mo, months.size());
                        lines.push_back({"dues", "dues", "dues", "", d, dues, true});
                        if (feeRatio > 0) { char f[64]; std::snprintf(f, sizeof f, "%.1f%%", 100 * feeRatio); lines.push_back({"own", "la_fees", "la_fees", "", f, dues * feeRatio, false}); }
                    }
                    // coaching: one coach per team, every practice and every game
                    if (teams > 0 && m["coach_paid"].get<bool>()) {
                        const double ph = m["practice_hours_week"], weeks = m["practice_weeks"], rate = m["coach_rate"];
                        const int games = m["games"]; const double hpg = m["hours_per_game"];
                        const double hours = teams * (ph * weeks + games * hpg);
                        if (hours > 0) {
                            char d[160]; std::snprintf(d, sizeof d, "%d × (%.1f h × %.1f wk + %d × %.2g h) × $%.0f", teams, ph, weeks, games, hpg, rate);
                            lines.push_back({"own", "labor", "coaching", "", d, hours * rate, true});
                        }
                    }
                    // youth: the leagues it enters, from the rate card
                    if (p.kind == "youth" && teams > 0 && entries.count({p.id, Y.id, S.id})) {
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
                            if (mine && std::fabs(pl.amount) >= 0.005) lines.push_back({"own", pl.category, "plan_line", pl.league + " — " + pl.label, "", pl.amount, true});
                        }
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
                        if (!ids.empty()) split((int)si, ids, v, {"own", r.value("category", ""), "plan_line", r.value("label", ""), "", 0, true});
                    }
                    for (const auto& r : proj.value("ref_fees", json::array())) {
                        if (r.value("kind", "") != "referee") continue;
                        const double v = aheadIn(r.value("by_month", json::object())); if (std::fabs(v) < 0.005) continue;
                        const auto ids = adultOnly(programsOf(r.value("scope", "club")));
                        if (!ids.empty()) split((int)si, ids, v, {"own", "referees", "plan_line", r.value("label", ""), "", 0, true});
                    }
                }
                for (const auto& b : proj.value("budget", json::array())) {
                    if (b.value("category", "") == "labor" || b.value("budget_year", "") != Y.label) continue;
                    const double v = Y.thisYear ? aheadIn(b.value("by_month", json::object())) : b.value("year_total", 0.0) * months.size() / 12.0;
                    if (std::fabs(v) < 0.005) continue;
                    const auto ids = programsOf(b.value("scope", "club"));
                    if (ids.empty()) split((int)si, allPaying((int)si), v, {"shared", b.value("category", ""), "budget_line", b.value("label", ""), "", 0, b.value("is_assumed", false)});
                    else split((int)si, ids, v, {"own", b.value("category", ""), "budget_line", b.value("label", ""), "", 0, b.value("is_assumed", false)});
                }
            }
            // CASA rental in the season, by paying players
            { double v = 0; for (const auto& ym : months) v += rentalByYm.count(ym) ? rentalByYm[ym] : 0.0;
              if (v) split((int)si, allPaying((int)si), v, {"support", "rental", "casa", "", "", 0, !isReal}); }
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
                if (amt >= 0.005) L[k.first][k.second].push_back({"support", "grant", "grant", "", "", amt, !actual.count({Y.id, seasons[k.first].id})});
            }
            yj["grant"] = {{"award", award}, {"used", round2(used)}, {"eligible", round2(total)}};
        }
        if (awardsFree.count(Y.label) && awardsFree[Y.label] > 0)
            for (size_t si = 0; si < seasons.size(); ++si) {
                const auto months = seasonMonths(seasons[si], Y.startYear, Y.startMonth);
                split((int)si, allPaying((int)si), awardsFree[Y.label] * months.size() / 12.0, {"support", "awards", "awards", "", "", 0, true});
            }

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
                json sj = meta[(int)si][p.id]; sj["lines"] = lines;
                pj[seasons[si].code] = sj;
            }
            yj["programs"][p.code] = pj;
        }
        out["budgets"][Y.label] = yj;
    }
    return out;
}
