#include "RosterWatchSync.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <cctype>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

#include "../database/Database.h"
#include "GoogleSheetRoster.h"
#include "PyramidSync.h"

using json = nlohmann::json;

namespace {

std::atomic<bool> gRunning{false};
std::atomic<int> gDone{0};
std::atomic<int> gTotal{0};

std::string trim(const std::string& s) {
    size_t a = 0, b = s.size();
    while (a < b && std::isspace(static_cast<unsigned char>(s[a]))) a++;
    while (b > a && std::isspace(static_cast<unsigned char>(s[b - 1]))) b--;
    return s.substr(a, b - a);
}
std::string lower(std::string s) {
    std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    return s;
}

// RFC 4180: quoted cells, "" for a quote, line breaks inside quotes (the
// CASA sheets' title cell has one).
std::vector<std::vector<std::string>> parseCsv(const std::string& s) {
    std::vector<std::vector<std::string>> rows;
    std::vector<std::string> row;
    std::string cell;
    bool quoted = false;
    for (size_t i = 0; i < s.size(); i++) {
        const char c = s[i];
        if (quoted) {
            if (c == '"') {
                if (i + 1 < s.size() && s[i + 1] == '"') { cell.push_back('"'); i++; }
                else quoted = false;
            } else cell.push_back(c);
        } else if (c == '"') quoted = true;
        else if (c == ',') { row.push_back(cell); cell.clear(); }
        else if (c == '\n') { row.push_back(cell); cell.clear(); rows.push_back(row); row.clear(); }
        else if (c != '\r') cell.push_back(c);
    }
    if (!cell.empty() || !row.empty()) { row.push_back(cell); rows.push_back(row); }
    return rows;
}

// One tab → its players, appended to `out` as
//   {team, division, first, last, dob, added, jersey}.
// Two layouts, told apart by their header row (the one with "First Name"
// and "Last Name"):
//   a team's own tab   "Team Name:" cell above the header; columns Date of
//                      Birth, Date Added, Jersey #
//   every team on one  a "…team…" column (and often a "…Division…" one)
//                      beside the names
// A tab with no such header (colours, counters) adds nothing.
int parseTab(const std::string& csv, const std::string& tabName, json& out) {
    const auto rows = parseCsv(csv);
    int first = -1, last = -1, dob = -1, added = -1, jersey = -1, team = -1, division = -1;
    std::string teamName;
    size_t header = rows.size();
    for (size_t r = 0; r < rows.size() && header == rows.size(); r++) {
        const auto& f = rows[r];
        for (size_t i = 0; i < f.size(); i++) {
            const std::string h = lower(trim(f[i]));
            if (h == "first name") first = static_cast<int>(i);
            else if (h == "last name") last = static_cast<int>(i);
            else if (h == "team name:") {
                for (size_t k = i + 1; k < f.size(); k++) if (!trim(f[k]).empty()) { teamName = trim(f[k]); break; }
            }
        }
        if (first < 0 || last < 0) { first = last = -1; continue; }
        header = r;
        for (size_t i = 0; i < f.size(); i++) {
            const std::string h = lower(trim(f[i]));
            if (h.find("birth") != std::string::npos) dob = static_cast<int>(i);
            else if (h == "date added" || h.find("registration date") != std::string::npos) added = static_cast<int>(i);
            else if (h.find("jersey") != std::string::npos) jersey = static_cast<int>(i);
            else if (h.find("division") != std::string::npos) division = static_cast<int>(i);
            else if (team < 0 && h.find("team") != std::string::npos) team = static_cast<int>(i);
        }
    }
    if (header == rows.size()) return 0;
    auto at = [](const std::vector<std::string>& f, int i) { return i >= 0 && i < static_cast<int>(f.size()) ? trim(f[i]) : std::string{}; };
    int n = 0;
    for (size_t r = header + 1; r < rows.size(); r++) {
        const auto& f = rows[r];
        const std::string fn = at(f, first), ln = at(f, last);
        if (fn.empty() || ln.empty()) continue;
        std::string t = team >= 0 ? at(f, team) : teamName;
        if (t.empty() && team < 0) t = tabName;
        if (t.empty()) continue;
        out.push_back({{"team", t}, {"division", at(f, division)}, {"first", fn}, {"last", ln},
                       {"dob", at(f, dob)}, {"added", at(f, added)}, {"jersey", at(f, jersey)}});
        n++;
    }
    return n;
}

void pause(int ms) { std::this_thread::sleep_for(std::chrono::milliseconds(ms)); }

// One workbook: its tabs (or the one named) → rows → the DB.
void readSheet(const std::string& sourceId, const std::string& workbook, const std::string& tabName, int pauseMs) {
    auto* db = Database::getInstance();
    auto stamp = [&](bool ok, const std::string& note) {
        db->query("UPDATE roster_sheet_sources SET last_fetched_at = now(), last_fetch_ok = $2::boolean, last_fetch_note = NULLIF($3, '') WHERE id = $1::int",
                  {sourceId, ok ? "true" : "false", note});
    };
    try {
        std::string err;
        const auto tabs = GoogleSheetRoster::tabs(workbook, err);
        if (tabs.empty()) { stamp(false, err); return; }
        json rows = json::array();
        bool found = tabName.empty();
        std::string lastErr;
        for (const auto& tab : tabs) {
            if (!tabName.empty() && trim(tab.name) != trim(tabName)) continue;
            found = true;
            pause(pauseMs);
            std::string e;
            const std::string csv = GoogleSheetRoster::csv(workbook, tab.gid, e);
            if (csv.empty()) { lastErr = "\"" + tab.name + "\": " + e; continue; }
            parseTab(csv, tab.name, rows);
        }
        if (!found) { stamp(false, "the workbook has no tab named \"" + tabName + "\""); return; }
        if (rows.empty()) { stamp(false, lastErr.empty() ? "no players found on the sheet" : lastErr); return; }
        db->query("SELECT fh_roster_sheet_load($1::int, $2::jsonb)", {sourceId, rows.dump()});
        stamp(true, lastErr);
        std::cerr << "[roster-watch] sheet source " << sourceId << ": " << rows.size() << " players" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "[roster-watch] sheet source " << sourceId << ": " << e.what() << std::endl;
        try { stamp(false, e.what()); } catch (...) {}
    }
}

void sweep(bool force) {
    auto* db = Database::getInstance();
    try {
        auto pol = db->query("SELECT stale_hours, pause_ms FROM roster_watch_policy WHERE id = 1");
        const int staleHours = pol.empty() ? 24 : pol[0]["stale_hours"].as<int>();
        const int pauseMs = pol.empty() ? 800 : pol[0]["pause_ms"].as<int>();
        const std::string f = force ? "true" : "false", h = std::to_string(staleHours);

        struct Sheet { std::string id, workbook, tab; };
        std::vector<Sheet> sheets;
        for (const auto& r : db->query(
                 "SELECT id, workbook_id, coalesce(tab_name, '') AS tab FROM roster_sheet_sources "
                 " WHERE is_active AND system = 'google_sheet' AND ($1::boolean OR last_fetched_at IS NULL OR last_fetched_at < now() - make_interval(hours => $2::int)) "
                 " ORDER BY sort_order, id", {f, h}))
            sheets.push_back({r["id"].c_str(), r["workbook_id"].c_str(), r["tab"].c_str()});

        std::vector<int> teams;
        for (const auto& r : db->query(
                 "SELECT t.id FROM pyramid_teams t "
                 "  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL "
                 "  JOIN pyramid_sources s ON s.id = d.source_id AND s.is_active AND s.team_page IS NOT NULL "
                 " WHERE t.removed_at IS NULL AND t.external_id ~ '^[0-9]+$' "
                 "   AND ($1::boolean OR t.people_fetched_at IS NULL OR t.people_fetched_at < now() - make_interval(hours => $2::int)) "
                 " ORDER BY t.people_fetched_at NULLS FIRST, t.id", {f, h}))
            teams.push_back(r["id"].as<int>());

        gDone = 0;
        gTotal = static_cast<int>(sheets.size() + teams.size());
        std::cerr << "[roster-watch] sweep: " << sheets.size() << " workbooks, " << teams.size() << " team pages" << std::endl;
        for (const auto& s : sheets) { readSheet(s.id, s.workbook, s.tab, pauseMs); ++gDone; }
        for (int id : teams) {
            PyramidSync::teamPeople(id, force ? 0 : staleHours);
            ++gDone;
            pause(pauseMs);
        }
        db->query("UPDATE roster_watch_policy SET last_sweep_at = now() WHERE id = 1");
        std::cerr << "[roster-watch] sweep done" << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "[roster-watch] sweep: " << e.what() << std::endl;
    }
    gRunning = false;
}

} // namespace

bool RosterWatchSync::start(bool force) {
    bool expected = false;
    if (!gRunning.compare_exchange_strong(expected, true)) return false;
    gDone = 0;
    gTotal = 0;
    std::thread([force] { sweep(force); }).detach();
    return true;
}

void RosterWatchSync::startIfStale() {
    if (gRunning) return;
    try {
        auto r = Database::getInstance()->query(
            "SELECT 1 FROM roster_watch_policy WHERE id = 1 "
            "   AND (last_sweep_at IS NULL OR last_sweep_at < now() - make_interval(hours => stale_hours))");
        if (!r.empty()) start(false);
    } catch (const std::exception& e) {
        std::cerr << "[roster-watch] stale check: " << e.what() << std::endl;
    }
}

json RosterWatchSync::state() {
    return {{"running", gRunning.load()}, {"done", gDone.load()}, {"total", gTotal.load()}};
}
