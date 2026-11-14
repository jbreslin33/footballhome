#include "BudgetPlayground.h"

#include <cmath>
#include <map>
#include <stdexcept>

#include "../database/Database.h"

using nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? "" : r[c].c_str(); }
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
json optInt(const pqxx::row& r, const char* c) { return r[c].is_null() ? json(nullptr) : json(r[c].as<long long>()); }

// What a field may hold: the column, its kind and bounds.
struct Field { const char* column; char kind; double lo, hi; bool nullable; };   // kind: t text, i int, n number
const std::map<std::string, Field> kTeamFields = {
    {"label",         {"label",         't', 1, 80, false}},
    {"us_age",        {"us_age",        'i', 3, 19, true}},
    {"cost_per_team", {"cost_per_team", 'n', -1e6, 1e7, false}},
    {"team_count",    {"team_count",    'i', 0, 20, false}},
    {"players",       {"players",       'i', 0, 500, false}},
    {"roster",        {"roster",        'i', 0, 500, true}},
};
const std::map<std::string, Field> kCoachFields = {
    {"label",         {"label",         't', 1, 80, false}},
    {"rate_per_hour", {"rate_per_hour", 'n', 0, 1000, false}},
    {"hours",         {"hours",         'n', 0, 168, false}},
    {"times",         {"times",         'n', 0, 366, false}},
    {"per",           {"per",           'p', 0, 0, false}},
};
const std::map<std::string, Field> kGroupFields = {
    {"dues_monthly",   {"dues_monthly",   'n', 0, 10000, false}},
    {"kit_per_player", {"kit_per_player", 'n', 0, 10000, false}},
};

// Validated SET clauses; throws std::invalid_argument on a bad value.
bool applyFields(const std::map<std::string, Field>& allowed, const json& fields, const std::string& table,
                 const std::string& where, const std::vector<std::string>& whereParams, const std::string& extraSet = "") {
    auto* db = Database::getInstance();
    bool found = false, any = false;
    for (const auto& [key, value] : fields.items()) {
        const auto it = allowed.find(key); if (it == allowed.end()) continue;
        const Field& f = it->second; any = true;
        std::vector<std::string> params = whereParams;
        std::string set;
        if (value.is_null()) {
            if (!f.nullable) throw std::invalid_argument(key + " is required");
            set = std::string(f.column) + " = NULL";
        } else {
            std::string v;
            if (f.kind == 't') {
                if (!value.is_string()) throw std::invalid_argument(key + " must be text");
                v = value.get<std::string>();
                if (v.size() < f.lo || v.size() > f.hi) throw std::invalid_argument(key + " is too short or too long");
            } else if (f.kind == 'p') {
                if (!value.is_string() || (value != "week" && value != "game")) throw std::invalid_argument("per is week or game");
                v = value.get<std::string>();
            } else {
                if (!value.is_number()) throw std::invalid_argument(key + " must be a number");
                const double d = value.get<double>();
                if (!std::isfinite(d) || d < f.lo || d > f.hi || (f.kind == 'i' && d != std::floor(d))) throw std::invalid_argument(key + " is out of range");
                char b[64]; std::snprintf(b, sizeof b, f.kind == 'i' ? "%.0f" : "%.2f", d); v = b;
            }
            params.push_back(v);
            set = std::string(f.column) + " = $" + std::to_string(params.size()) + (f.kind == 'i' ? "::int" : f.kind == 'n' ? "::numeric" : "");
        }
        if (!db->query("UPDATE " + table + " SET " + set + extraSet + " WHERE " + where + " RETURNING 1", params).empty()) found = true;
    }
    if (!any) throw std::invalid_argument("Nothing to change.");
    return found;
}

int yearIdOf(int clubId, const std::string& label) {
    auto r = label.empty()
        ? Database::getInstance()->query("SELECT id FROM budget_years WHERE club_id = $1::int AND (now() AT TIME ZONE 'America/New_York')::date BETWEEN starts_on AND ends_on", {std::to_string(clubId)})
        : Database::getInstance()->query("SELECT id FROM budget_years WHERE club_id = $1::int AND label = $2", {std::to_string(clubId), label});
    return r.empty() ? 0 : r[0]["id"].as<int>();
}
} // namespace

int BudgetPlayground::yearId(int clubId, const std::string& yearLabel) { return yearIdOf(clubId, yearLabel); }

bool BudgetPlayground::reset(int clubId, int yearId) {
    auto r = Database::getInstance()->query("SELECT fh_budget_playground_reset($1::int, id) AS ok FROM budget_years WHERE id = $2::int AND club_id = $1::int",
                                            {std::to_string(clubId), std::to_string(yearId)});
    return !r.empty() && !r[0]["ok"].is_null() && r[0]["ok"].as<bool>();
}

json BudgetPlayground::state(int clubId, const std::string& yearLabel) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    int yearId = yearIdOf(clubId, yearLabel);
    if (!yearId) yearId = yearIdOf(clubId, "");
    if (!yearId) throw std::runtime_error("No budget year");
    const std::string year = std::to_string(yearId);
    // first open of a year: build it from the real plan
    if (db->query("SELECT 1 FROM budget_playground_settings WHERE club_id = $1::int AND budget_year_id = $2::int LIMIT 1", {club, year}).empty())
        reset(clubId, yearId);

    json out = {{"years", json::array()}, {"groups", json::array()}, {"teams", json::array()}, {"coaches", json::array()}};
    // years the playground can build: those with a plan, and later ones (copied forward)
    for (const auto& r : db->query(R"SQL(
        SELECT y.id, y.label,
               (SELECT y2.label FROM budget_years y2
                 WHERE y2.club_id = y.club_id AND y2.starts_on <= y.starts_on
                   AND EXISTS (SELECT 1 FROM team_season_entries e JOIN seasons s ON s.id = e.season_id
                                WHERE e.budget_from_plan AND s.start_date BETWEEN y2.starts_on AND y2.ends_on)
                 ORDER BY y2.starts_on DESC LIMIT 1) AS source
          FROM budget_years y WHERE y.club_id = $1::int ORDER BY y.starts_on)SQL", {club})) {
        if (r["source"].is_null()) continue;
        const json y = {{"id", r["id"].as<long long>()}, {"label", str(r, "label")}, {"copied_from", str(r, "source") == str(r, "label") ? json(nullptr) : json(str(r, "source"))}};
        out["years"].push_back(y);
        if (r["id"].as<int>() == yearId) out["year"] = y;
    }
    for (const auto& r : db->query(
            "SELECT g.code, g.label, g.emoji, s.dues_monthly, s.kit_per_player, s.note FROM budget_playground_groups g "
            "  LEFT JOIN budget_playground_settings s ON s.group_code = g.code AND s.club_id = $1::int AND s.budget_year_id = $2::int "
            " ORDER BY g.sort_order", {club, year}))
        out["groups"].push_back({{"code", str(r, "code")}, {"label", str(r, "label")}, {"emoji", str(r, "emoji")},
                                 {"dues_monthly", num(r, "dues_monthly")}, {"kit_per_player", num(r, "kit_per_player")}, {"note", str(r, "note")}});
    for (const auto& r : db->query(
            "SELECT id, group_code, label, us_age, cost_per_team, team_count, players, roster, is_assumed, note FROM budget_playground_teams "
            " WHERE club_id = $1::int AND budget_year_id = $2::int ORDER BY group_code, sort_order, id", {club, year}))
        out["teams"].push_back({{"id", r["id"].as<long long>()}, {"group", str(r, "group_code")}, {"label", str(r, "label")}, {"us_age", optInt(r, "us_age")},
                                {"cost_per_team", num(r, "cost_per_team")}, {"team_count", r["team_count"].as<int>()}, {"players", r["players"].as<int>()},
                                {"roster", optInt(r, "roster")}, {"is_assumed", r["is_assumed"].as<bool>()}, {"note", str(r, "note")}});
    for (const auto& r : db->query(
            "SELECT id, group_code, team_id, label, rate_per_hour, hours, times, per, note FROM budget_playground_coaches "
            " WHERE club_id = $1::int AND budget_year_id = $2::int ORDER BY group_code, team_id NULLS FIRST, sort_order, id", {club, year}))
        out["coaches"].push_back({{"id", r["id"].as<long long>()}, {"group", str(r, "group_code")}, {"team_id", optInt(r, "team_id")}, {"label", str(r, "label")},
                                  {"rate_per_hour", num(r, "rate_per_hour")}, {"hours", num(r, "hours")}, {"times", num(r, "times")},
                                  {"per", str(r, "per")}, {"note", str(r, "note")}});
    return out;
}

bool BudgetPlayground::saveTeam(int clubId, int id, const json& fields) {
    // a typed cost replaces the assumption
    const bool cost = fields.contains("cost_per_team");
    return applyFields(kTeamFields, fields, "budget_playground_teams", "id = $1::int AND club_id = $2::int",
                       {std::to_string(id), std::to_string(clubId)}, cost ? ", is_assumed = false" : "");
}

bool BudgetPlayground::saveCoach(int clubId, int id, const json& fields) {
    return applyFields(kCoachFields, fields, "budget_playground_coaches", "id = $1::int AND club_id = $2::int",
                       {std::to_string(id), std::to_string(clubId)});
}

bool BudgetPlayground::saveGroup(int clubId, int yearId, const std::string& group, const json& fields) {
    return applyFields(kGroupFields, fields, "budget_playground_settings", "club_id = $1::int AND budget_year_id = $2::int AND group_code = $3",
                       {std::to_string(clubId), std::to_string(yearId), group});
}

long long BudgetPlayground::addTeam(int clubId, int yearId, const std::string& group, std::optional<int> copyOf, const std::string& label) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId), year = std::to_string(yearId);
    if (copyOf) {
        // the B team: same costs, roster and coaches; one team, no players yet
        auto r = db->query(
            "INSERT INTO budget_playground_teams (club_id, budget_year_id, group_code, label, us_age, cost_per_team, team_count, players, roster, is_assumed, note, sort_order) "
            "SELECT club_id, budget_year_id, group_code, label || $3, us_age, cost_per_team, 1, 0, roster, is_assumed, note, sort_order "
            "  FROM budget_playground_teams WHERE id = $1::int AND club_id = $2::int RETURNING id",
            {std::to_string(*copyOf), club, label});
        if (r.empty()) return 0;
        const std::string newId = r[0]["id"].c_str();
        db->query("INSERT INTO budget_playground_coaches (club_id, budget_year_id, group_code, team_id, label, rate_per_hour, hours, times, per, note, sort_order) "
                  "SELECT club_id, budget_year_id, group_code, $2::int, label, rate_per_hour, hours, times, per, note, sort_order "
                  "  FROM budget_playground_coaches WHERE team_id = $1::int", {std::to_string(*copyOf), newId});
        return std::stoll(newId);
    }
    auto r = db->query(
        "INSERT INTO budget_playground_teams (club_id, budget_year_id, group_code, label, team_count, players, sort_order) "
        "SELECT $1::int, y.id, g.code, $4, 1, 0, 100000 FROM budget_years y, budget_playground_groups g "
        " WHERE y.id = $2::int AND y.club_id = $1::int AND g.code = $3 RETURNING id", {club, year, group, label});
    return r.empty() ? 0 : r[0]["id"].as<long long>();
}

long long BudgetPlayground::addCoach(int clubId, int yearId, const std::string& group, std::optional<int> teamId, const std::string& label) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    // the rate: the group's other coaches', else $15
    if (teamId) {
        auto r = db->query(
            "INSERT INTO budget_playground_coaches (club_id, budget_year_id, group_code, team_id, label, rate_per_hour, hours, times, per, sort_order) "
            "SELECT t.club_id, t.budget_year_id, t.group_code, t.id, $3, "
            "       COALESCE((SELECT MAX(c.rate_per_hour) FROM budget_playground_coaches c WHERE c.club_id = t.club_id AND c.budget_year_id = t.budget_year_id AND c.group_code = t.group_code), 15), "
            "       0, 50, 'week', 100000 FROM budget_playground_teams t WHERE t.id = $1::int AND t.club_id = $2::int RETURNING id",
            {std::to_string(*teamId), club, label});
        return r.empty() ? 0 : r[0]["id"].as<long long>();
    }
    auto r = db->query(
        "INSERT INTO budget_playground_coaches (club_id, budget_year_id, group_code, label, rate_per_hour, hours, times, per, sort_order) "
        "SELECT $1::int, y.id, g.code, $4, "
        "       COALESCE((SELECT MAX(c.rate_per_hour) FROM budget_playground_coaches c WHERE c.club_id = $1::int AND c.budget_year_id = y.id AND c.group_code = g.code), 15), "
        "       0, 50, 'week', 100000 FROM budget_years y, budget_playground_groups g "
        " WHERE y.id = $2::int AND y.club_id = $1::int AND g.code = $3 RETURNING id", {club, std::to_string(yearId), group, label});
    return r.empty() ? 0 : r[0]["id"].as<long long>();
}

bool BudgetPlayground::remove(int clubId, const std::string& kind, int id) {
    const std::string table = kind == "team" ? "budget_playground_teams" : kind == "coach" ? "budget_playground_coaches" : "";
    if (table.empty()) return false;
    return !Database::getInstance()->query("DELETE FROM " + table + " WHERE id = $1::int AND club_id = $2::int RETURNING 1",
                                           {std::to_string(id), std::to_string(clubId)}).empty();
}
