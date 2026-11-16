#include "CapacityPlan.h"

#include <cmath>

#include "../database/Database.h"

using nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
double round2(double v) { return std::round(v * 100.0) / 100.0; }
}

json CapacityPlan::state(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    json out = json::object();

    auto s = db->query(
        "SELECT coach_rate_per_hour, weeks_per_year, practice_weeks_read, note FROM capacity_plan_settings "
        "WHERE club_id = $1::int AND effective_from <= CURRENT_DATE ORDER BY effective_from DESC, id DESC LIMIT 1", {club});
    if (s.empty()) { out["teams"] = json::array(); out["settings"] = nullptr; return out; }
    const int weeksRead = std::max(1, s[0]["practice_weeks_read"].as<int>());
    out["settings"] = { {"coach_rate_per_hour", num(s[0], "coach_rate_per_hour")}, {"weeks_per_year", num(s[0], "weeks_per_year")},
                        {"practice_weeks_read", weeksRead}, {"note", str(s[0], "note")} };

    // Practice hours a week per team: the calendar's next whole weeks (from
    // next Monday), cancelled / deleted events out. Cheap filters first
    // (date window on gcal_events) before the team joins.
    auto rows = db->query(R"SQL(
        WITH ev AS (
          SELECT e.id, EXTRACT(EPOCH FROM (g.ends_at - g.starts_at)) / 3600.0 AS h
            FROM gcal_events g
            JOIN fh_events e ON e.gcal_event_id = g.id AND e.kind = 'practice'
           WHERE g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
             AND g.starts_at >= date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' + interval '7 days'
             AND g.starts_at <  date_trunc('week', now() AT TIME ZONE 'America/New_York') AT TIME ZONE 'America/New_York' + make_interval(days => 7 + 7 * $2::int)
        ), mens AS (
          SELECT DISTINCT et.fh_event_id FROM fh_event_teams et JOIN teams tm ON tm.id = et.team_id
           WHERE et.fh_event_id IN (SELECT id FROM ev) AND tm.club_section_id = 1
        ), hours AS (
          SELECT et.team_id, SUM(ev.h) / $2::numeric AS per_week
            FROM ev JOIN fh_event_teams et ON et.fh_event_id = ev.id JOIN teams t ON t.id = et.team_id
           WHERE t.club_section_id IN (1, 2) OR ev.id NOT IN (SELECT fh_event_id FROM mens)
           GROUP BY et.team_id
        )
        SELECT p.team_id, t.name, t.club_section_id, COALESCE(t.max_roster, 0) AS max_roster,
               p.games, p.hours_per_game, p.pays_dues, p.note, COALESCE(h.per_week, 0) AS practice_hours_week
          FROM capacity_plan_teams p
          JOIN teams t ON t.id = p.team_id
          LEFT JOIN hours h ON h.team_id = p.team_id
         WHERE p.club_id = $1::int
         ORDER BY p.sort_order, t.name)SQL", {club, std::to_string(weeksRead)});

    json teams = json::array();
    for (const auto& r : rows) {
        teams.push_back({ {"team_id", r["team_id"].as<int>()}, {"name", str(r, "name")}, {"section_id", r["club_section_id"].is_null() ? 0 : r["club_section_id"].as<int>()},
                          {"max_roster", r["max_roster"].as<int>()}, {"games", r["games"].as<int>()}, {"hours_per_game", num(r, "hours_per_game")},
                          {"pays_dues", r["pays_dues"].as<bool>()}, {"note", str(r, "note")},
                          {"practice_hours_week", round2(num(r, "practice_hours_week"))}, {"coaches", json::object()} });
    }
    for (const auto& c : db->query(
            "SELECT c.team_id, c.budget_year, c.is_paid, c.rate_per_hour FROM capacity_plan_coaches c "
            "JOIN capacity_plan_teams p ON p.team_id = c.team_id WHERE p.club_id = $1::int", {club})) {
        const int id = c["team_id"].as<int>();
        for (auto& t : teams) if (t["team_id"].get<int>() == id)
            t["coaches"][str(c, "budget_year")] = { {"is_paid", c["is_paid"].as<bool>()}, {"rate_per_hour", c["rate_per_hour"].is_null() ? json(nullptr) : json(num(c, "rate_per_hour"))} };
    }
    out["teams"] = teams;
    return out;
}

bool CapacityPlan::saveCoach(int clubId, int teamId, const std::string& budgetYear, bool isPaid,
                             std::optional<double> ratePerHour, std::optional<int> userId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    if (db->query("SELECT 1 FROM capacity_plan_teams WHERE club_id = $1::int AND team_id = $2::int", {club, std::to_string(teamId)}).empty()) return false;
    if (db->query("SELECT 1 FROM budget_years WHERE club_id = $1::int AND label = $2", {club, budgetYear}).empty()) return false;
    if (ratePerHour && (*ratePerHour < 0 || *ratePerHour > 1000)) throw std::invalid_argument("Rate must be between $0 and $1,000 an hour.");
    db->query(R"SQL(
        INSERT INTO capacity_plan_coaches (team_id, budget_year, is_paid, rate_per_hour, updated_at, updated_by_user_id)
        VALUES ($1::int, $2, $3::boolean, NULLIF($4, '')::numeric, now(), NULLIF($5, '')::int)
        ON CONFLICT (team_id, budget_year) DO UPDATE
           SET is_paid = EXCLUDED.is_paid, rate_per_hour = EXCLUDED.rate_per_hour,
               updated_at = now(), updated_by_user_id = EXCLUDED.updated_by_user_id)SQL",
        {std::to_string(teamId), budgetYear, isPaid ? "true" : "false",
         ratePerHour ? std::to_string(round2(*ratePerHour)) : std::string{}, userId ? std::to_string(*userId) : std::string{}});
    return true;
}
