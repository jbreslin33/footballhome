#include "PyramidSync.h"

#include <algorithm>
#include <atomic>
#include <chrono>
#include <thread>
#include <cctype>
#include <cstdlib>
#include <iostream>
#include <map>
#include <memory>
#include <mutex>
#include <vector>

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "CarpoolRouting.h"

using json = nlohmann::json;

namespace {

std::mutex gRefreshMutex;
std::atomic<bool> gGeocoding{false};

std::string proxyUrl() {
    const char* env = std::getenv("TEAMPASS_PROXY_URL");
    return env && *env ? env : "http://footballhome_scraper:3128";
}

// ── tiny HTML helpers ──────────────────────────────────────────────────
std::string squeeze(const std::string& s) {
    std::string out;
    bool space = false;
    for (char c : s) {
        if (std::isspace((unsigned char)c)) { space = !out.empty(); continue; }
        if (space) { out += ' '; space = false; }
        out += c;
    }
    return out;
}

std::string decodeEntities(std::string s) {
    static const std::vector<std::pair<std::string, std::string>> kMap = {
        {"&amp;", "&"}, {"&#39;", "'"}, {"&apos;", "'"}, {"&quot;", "\""}, {"&nbsp;", " "}, {"&lt;", "<"}, {"&gt;", ">"}};
    for (const auto& [from, to] : kMap) {
        size_t p = 0;
        while ((p = s.find(from, p)) != std::string::npos) { s.replace(p, from.size(), to); p += to.size(); }
    }
    return s;
}

std::string stripTags(const std::string& html) {
    std::string out;
    bool inTag = false;
    for (char c : html) {
        if (c == '<') { inTag = true; out += ' '; }
        else if (c == '>') inTag = false;
        else if (!inTag) out += c;
    }
    return squeeze(decodeEntities(out));
}

int toInt(const std::string& s) {
    try { return std::stoi(squeeze(s)); } catch (...) { return 0; }
}
int toInt(const json& j, const char* key) {
    if (!j.contains(key)) return 0;
    const auto& v = j[key];
    if (v.is_number_integer()) return v.get<int>();
    if (v.is_string()) return toInt(v.get<std::string>());
    return 0;
}

// The <td> contents of one <tr>, raw.
std::vector<std::string> cellsOf(const std::string& row) {
    std::vector<std::string> cells;
    size_t p = 0;
    while ((p = row.find("<td", p)) != std::string::npos) {
        const size_t open = row.find('>', p);
        const size_t close = row.find("</td>", open);
        if (open == std::string::npos || close == std::string::npos) break;
        cells.push_back(row.substr(open + 1, close - open - 1));
        p = close + 5;
    }
    return cells;
}

// ── readers: page → [{ext_id, name, sort, teams:[…]}] ──────────────────
class PyramidReader {
public:
    virtual ~PyramidReader() = default;
    // Empty array + note on failure.
    virtual json read(const std::string& locator, std::string& note) = 0;
};

// TeamPass Jumbotron feed: one json with every division, team and club,
// and the league's own computed totals (standings.team_totals).
class TeamPassJsonReader : public PyramidReader {
public:
    json read(const std::string& locator, std::string& note) override {
        HttpClient http;
        http.setTotalTimeoutSec(60);
        http.setProxy(proxyUrl());
        auto resp = http.get("https://alta.teampass.com/App/Jumbotron/data/" + HttpClient::urlEncode(locator) + "?format=2A",
                             {{"Accept", "application/json"}});
        if (!resp.ok()) { note = "HTTP " + std::to_string(resp.status) + (resp.error.empty() ? "" : " " + resp.error); return json::array(); }
        json body = json::parse(resp.body, nullptr, false);
        if (body.is_discarded() || !body.contains("teams") || !body["teams"].is_object()
            || !body.contains("divisions") || !body["divisions"].is_object()) { note = "unexpected feed shape"; return json::array(); }
        const json& divs = body["divisions"];
        const json clubs = body.contains("clubs") && body["clubs"].is_object() ? body["clubs"] : json::object();
        const json st = body.contains("standings") && body["standings"].is_object() ? body["standings"] : json::object();
        const json totals = st.contains("team_totals") && st["team_totals"].is_object() ? st["team_totals"] : json::object();
        std::vector<std::string> sortKeys;
        if (st.contains("sort_keys") && st["sort_keys"].is_array())
            for (const auto& k : st["sort_keys"]) if (k.is_number()) sortKeys.push_back(std::to_string(k.get<long long>()));

        // team_id → its home ground: the location of most of the games it
        // hosts (t1 = home), as "street, city, ST zip" (mig 844, the map).
        const json fields = body.contains("fields") && body["fields"].is_object() ? body["fields"] : json::object();
        const json locs = body.contains("locations") && body["locations"].is_object() ? body["locations"] : json::object();
        std::map<std::string, std::map<std::string, int>> hosted;
        if (body.contains("games") && body["games"].is_array())
            for (const auto& g : body["games"]) {
                if (!g.contains("t1") || !g["t1"].is_number() || !g.contains("f") || !g["f"].is_number()) continue;
                const std::string fid = std::to_string(g["f"].get<long long>());
                if (!fields.contains(fid) || !fields[fid].contains("location_id")) continue;
                const json& lid = fields[fid]["location_id"];
                if (!lid.is_number()) continue;
                hosted[std::to_string(g["t1"].get<long long>())][std::to_string(lid.get<long long>())]++;
            }
        auto venueOf = [&](const std::string& tid, json& row) {
            auto it = hosted.find(tid);
            if (it == hosted.end()) return;
            const auto best = std::max_element(it->second.begin(), it->second.end(),
                                               [](const auto& a, const auto& b) { return a.second < b.second; });
            if (!locs.contains(best->first)) return;
            const json& l = locs[best->first];
            // Any of these may be a number (zip) or null in the feed.
            auto field = [&l](const char* k) -> std::string {
                if (!l.contains(k) || l[k].is_null()) return {};
                if (l[k].is_string()) return squeeze(l[k].get<std::string>());
                if (l[k].is_number_integer()) return std::to_string(l[k].get<long long>());
                return {};
            };
            std::string addr = field("address1");
            const std::string city = field("city"), st = field("state"), zip = field("zip");
            if (!city.empty()) addr += (addr.empty() ? "" : ", ") + city;
            if (!st.empty()) addr += (addr.empty() ? "" : ", ") + st;
            if (!zip.empty()) addr += " " + zip;
            if (city.empty() && zip.empty()) return;
            row["venue_name"] = field("name");
            row["venue_address"] = addr;
        };

        // team_id → its totals row (the feed carries the current season only).
        std::map<std::string, json> byTeam;
        for (const auto& [key, t] : totals.items())
            if (t.contains("team_id")) byTeam[std::to_string(t["team_id"].get<long long>())] = t;

        // The current season's name, for its zone rules (promotion_rules
        // carry past seasons too).
        std::string season;
        if (body.contains("seasons") && body["seasons"].is_object())
            for (const auto& [sid, sv] : body["seasons"].items()) season = sv.value("name", season);

        struct Row { json team; std::vector<int> sortVals; std::string name; };
        std::map<std::string, std::vector<Row>> perDiv;     // key: division id, or "<id>:<group>"
        std::map<std::string, std::string> divName;         // key → table name as the rules name it
        for (const auto& [tid, t] : body["teams"].items()) {
            if (!t.contains("division_id") || !t["division_id"].is_number()) continue;
            const std::string did = std::to_string(t["division_id"].get<long long>());
            if (did == "0" || !divs.contains(did)) continue;
            const std::string name = t.value("name", "");
            if (name.empty()) continue;
            std::string club;
            if (t.contains("club_id") && t["club_id"].is_number()) {
                const std::string cid = std::to_string(t["club_id"].get<long long>());
                if (clubs.contains(cid)) club = clubs[cid].value("name", "");
            }
            json row = {{"ext_id", tid}, {"name", name}, {"club", club}};
            venueOf(tid, row);
            std::vector<int> sv;
            auto it = byTeam.find(tid);
            if (it != byTeam.end()) {
                const json& x = it->second;
                row["gp"] = toInt(x, "gp"); row["w"] = toInt(x, "w"); row["d"] = toInt(x, "d"); row["l"] = toInt(x, "l");
                row["gf"] = toInt(x, "gf"); row["ga"] = toInt(x, "ga"); row["pts"] = toInt(x, "points");
                const json vals = x.contains("sort_values") && x["sort_values"].is_object() ? x["sort_values"] : json::object();
                for (const auto& k : sortKeys) sv.push_back(toInt(vals, k.c_str()));
            }
            // A conference played in groups (Delaware River A/B): each
            // group is its own table, named as the league's rules name it.
            const std::string group = t.contains("conference") && t["conference"].is_string() ? t["conference"].get<std::string>() : "";
            const std::string key = group.empty() ? did : did + ":" + group;
            divName[key] = divs[did].value("name", did) + (group.empty() ? "" : " - " + group);
            perDiv[key].push_back({row, sv, name});
        }

        const json rules = st.contains("promotion_rules") && st["promotion_rules"].is_array() ? st["promotion_rules"] : json::array();
        json out = json::array();
        for (auto& [key, rows] : perDiv) {
            const std::string did = key.substr(0, key.find(':'));
            // The league's own tie-break order (sort_keys, all descending);
            // teams with no game yet sit below, by name.
            std::stable_sort(rows.begin(), rows.end(), [](const Row& a, const Row& b) {
                if (a.sortVals.empty() != b.sortVals.empty()) return !a.sortVals.empty();
                if (a.sortVals != b.sortVals) return a.sortVals > b.sortVals;
                return a.name < b.name;
            });
            json teams = json::array();
            int pos = 0;
            for (auto& r : rows) { r.team["pos"] = ++pos; teams.push_back(r.team); }
            // The league office's marks for this table this season: edge
            // "top" counts places from 1st, "bottom" from last.
            json zones = json::array();
            const int n = (int)rows.size();
            for (const auto& rule : rules) {
                if (rule.value("season_pattern", "") != season || rule.value("division_pattern", "") != divName[key]) continue;
                if (!rule.contains("marks") || !rule["marks"].is_array()) continue;
                for (const auto& m : rule["marks"]) {
                    int from = toInt(m, "from"), to = toInt(m, "to");
                    if (from < 1 || to < from) continue;
                    if (m.value("edge", "top") == "bottom") { const int a = n - to + 1, b = n - from + 1; from = a; to = b; }
                    if (from < 1 || to > n) continue;
                    zones.push_back({{"kind", m.value("type", "")}, {"from", from}, {"to", to}, {"label", m.value("label", "")},
                                     {"color", m.value("color", "")}});
                }
            }
            out.push_back({{"ext_id", key}, {"name", divName[key]},
                           {"sort", divs[did].contains("display_order") && divs[did]["display_order"].is_number() ? divs[did]["display_order"].get<int>() : 0},
                           {"zones", zones}, {"teams", teams}});
        }
        if (out.empty()) note = "feed listed no divisions";
        return out;
    }
};

// A TeamPass /<site>/Tables/ page: accordion title per table, then
// Rank | Team | MP W D L GF GA GD Pts rows.
class TeamPassTablesReader : public PyramidReader {
public:
    json read(const std::string& locator, std::string& note) override {
        HttpClient http;
        http.setTotalTimeoutSec(45);
        http.setProxy(proxyUrl());
        auto resp = http.get(locator, {{"User-Agent", "Mozilla/5.0"}});
        if (!resp.ok()) { note = "HTTP " + std::to_string(resp.status) + (resp.error.empty() ? "" : " " + resp.error); return json::array(); }
        const std::string& s = resp.body;
        json out = json::array();
        size_t p = 0;
        int sort = 0;
        while ((p = s.find("leagueAccordTitle1", p)) != std::string::npos) {
            const size_t open = s.find('>', p);
            const size_t close = s.find("</div>", open);
            if (open == std::string::npos || close == std::string::npos) break;
            const std::string title = stripTags(s.substr(open + 1, close - open - 1));
            const size_t next = s.find("leagueAccordTitle1", close);
            const size_t tbl = s.find("<table", close);
            const size_t tblEnd = tbl == std::string::npos ? std::string::npos : s.find("</table>", tbl);
            p = close;
            if (title.empty() || tbl == std::string::npos || tblEnd == std::string::npos || (next != std::string::npos && tbl > next)) continue;
            const std::string table = s.substr(tbl, tblEnd - tbl);
            json teams = json::array();
            size_t r = 0;
            while ((r = table.find("<tr", r)) != std::string::npos) {
                const size_t rEnd = table.find("</tr>", r);
                if (rEnd == std::string::npos) break;
                const auto cells = cellsOf(table.substr(r, rEnd - r));
                r = rEnd + 5;
                if (cells.size() < 10) continue;
                const std::string name = stripTags(cells[1]);
                if (name.empty()) continue;
                std::string ext = name;
                const size_t tp = cells[1].find("/Team/");
                if (tp != std::string::npos) {
                    size_t e = tp + 6;
                    while (e < cells[1].size() && std::isdigit((unsigned char)cells[1][e])) ++e;
                    if (e > tp + 6) ext = cells[1].substr(tp + 6, e - tp - 6);
                }
                teams.push_back({{"ext_id", ext}, {"name", name}, {"pos", toInt(stripTags(cells[0]))},
                                 {"gp", toInt(stripTags(cells[2]))}, {"w", toInt(stripTags(cells[3]))},
                                 {"d", toInt(stripTags(cells[4]))}, {"l", toInt(stripTags(cells[5]))},
                                 {"gf", toInt(stripTags(cells[6]))}, {"ga", toInt(stripTags(cells[7]))},
                                 {"pts", toInt(stripTags(cells[9]))}});
            }
            if (!teams.empty()) out.push_back({{"ext_id", title}, {"name", title}, {"sort", ++sort}, {"teams", teams}});
            p = tblEnd;
        }
        if (out.empty()) note = "no tables on the page";
        return out;
    }
};

// Demosphere standings page: `var diiStand = { tms:{ "<row>":{tm, tmnm,
// tg, tgnm, tgseq, rank, TOT_GP, TOT_W, TOT_T, TOT_L, TOT_GF, TOT_GA,
// TOT_PTS}, … } … }` — strict JSON inside a script.
class DemosphereReader : public PyramidReader {
public:
    json read(const std::string& locator, std::string& note) override {
        HttpClient http;
        http.setTotalTimeoutSec(30);
        auto resp = http.get(locator, {{"User-Agent", "Mozilla/5.0"}});
        if (!resp.ok()) { note = "HTTP " + std::to_string(resp.status) + (resp.error.empty() ? "" : " " + resp.error); return json::array(); }
        const std::string& s = resp.body;
        size_t p = s.find("tms:{");
        if (p == std::string::npos) { note = "no standings data on the page"; return json::array(); }
        p += 4;
        int depth = 0;
        bool inStr = false;
        size_t end = p;
        for (; end < s.size(); ++end) {
            const char c = s[end];
            if (inStr) { if (c == '\\') ++end; else if (c == '"') inStr = false; continue; }
            if (c == '"') inStr = true;
            else if (c == '{') ++depth;
            else if (c == '}' && --depth == 0) break;
        }
        json tms = json::parse(s.substr(p, end - p + 1), nullptr, false);
        if (tms.is_discarded() || !tms.is_object()) { note = "standings data did not parse"; return json::array(); }

        std::map<std::string, json> divs;
        for (const auto& [k, t] : tms.items()) {
            const std::string tg = t.value("tg", "");
            const std::string name = squeeze(t.value("tmnm", ""));
            if (tg.empty() || name.empty() || t.value("pub", "1") == "0") continue;
            if (!divs.count(tg)) divs[tg] = {{"ext_id", tg}, {"name", squeeze(t.value("tgnm", tg))}, {"sort", toInt(t, "tgseq")}, {"teams", json::array()}};
            divs[tg]["teams"].push_back({{"ext_id", t.value("tm", name)}, {"name", name}, {"pos", toInt(t, "rank")},
                                         {"gp", toInt(t, "TOT_GP")}, {"w", toInt(t, "TOT_W")}, {"d", toInt(t, "TOT_T")},
                                         {"l", toInt(t, "TOT_L")}, {"gf", toInt(t, "TOT_GF")}, {"ga", toInt(t, "TOT_GA")},
                                         {"pts", toInt(t, "TOT_PTS")}});
        }
        json out = json::array();
        for (auto& [tg, d] : divs) out.push_back(d);
        if (out.empty()) note = "standings data listed no teams";
        return out;
    }
};

// A SportsEngine season (CASA Select regions): no standings endpoint, so
// the table is computed from the season's games — every event names its
// two teams (principals, with their division) and, once played, the score.
// 3 for a win, 1 for a draw; rank by points, goal difference, goals for.
class SportsEngineReader : public PyramidReader {
public:
    json read(const std::string& locator, std::string& note) override {
        struct Team { std::string name, division, divisionId; int gp = 0, w = 0, d = 0, l = 0, gf = 0, ga = 0;
                      std::map<std::string, int> homes; std::map<std::string, std::string> homeName; };
        std::map<std::string, Team> teams;    // season-team id → totals
        HttpClient http;
        http.setTotalTimeoutSec(30);
        int totalPages = 1;
        for (int page = 1; page <= totalPages && page <= 30; ++page) {
            auto resp = http.get("https://se-api.sportsengine.com/v3/microsites/events?page=" + std::to_string(page) +
                                 "&per_page=100&program_id=" + HttpClient::urlEncode(locator), {{"Accept", "application/json"}});
            if (!resp.ok()) { note = "HTTP " + std::to_string(resp.status) + (resp.error.empty() ? "" : " " + resp.error); return json::array(); }
            json body = json::parse(resp.body, nullptr, false);
            if (body.is_discarded() || !body.contains("result") || !body["result"].is_array()) { note = "unexpected feed shape"; return json::array(); }
            try { totalPages = body["metadata"]["pagination"].value("totalPages", 1); } catch (...) {}
            for (const auto& ev : body["result"]) {
                if (ev.value("status", "") == "cancelled" || !ev.contains("principals") || !ev["principals"].is_array()) continue;
                for (const auto& p : ev["principals"]) {
                    if (!p.contains("extended_attributes") || !p["extended_attributes"].is_object()) continue;
                    const json& ea = p["extended_attributes"];
                    const std::string id = p.value("principal_originator_id", "");
                    if (id.empty() || ea.value("division_name", "").empty() || ea.value("outside_team", false)) continue;
                    Team& t = teams[id];
                    t.name = ea.value("name", t.name);
                    t.division = ea.value("division_name", t.division);
                    t.divisionId = ea.value("division_id", t.divisionId);
                }
                if (!ev.contains("game_details") || !ev["game_details"].is_object()) continue;
                const json& g = ev["game_details"];
                // The home side's ground: where it hosts (mig 844, the map).
                const std::string where = ev.contains("location_address") && ev["location_address"].is_string() ? ev["location_address"].get<std::string>() : "";
                if (!where.empty())
                    for (const char* side : {"team_1", "team_2"})
                        if (g.contains(side) && g[side].is_object() && g[side].value("is_home_team", false)) {
                            const std::string hid = g[side].value("originator_id", "");
                            if (teams.count(hid)) {
                                teams[hid].homes[where]++;
                                if (ev.contains("location_name") && ev["location_name"].is_string()) teams[hid].homeName[where] = ev["location_name"].get<std::string>();
                            }
                        }
                if (g.value("status", "") != "completed" || !g.contains("team_1") || !g.contains("team_2")) continue;
                const json& a = g["team_1"];
                const json& b = g["team_2"];
                const std::string ida = a.value("originator_id", ""), idb = b.value("originator_id", "");
                const std::string sa = a.contains("score") && a["score"].is_string() ? a["score"].get<std::string>() : "";
                const std::string sb = b.contains("score") && b["score"].is_string() ? b["score"].get<std::string>() : "";
                if (sa.empty() || sb.empty() || !teams.count(ida) || !teams.count(idb)) continue;
                const int ga = toInt(sa), gb = toInt(sb);
                Team& ta = teams[ida];
                Team& tb = teams[idb];
                ta.gp++; tb.gp++; ta.gf += ga; ta.ga += gb; tb.gf += gb; tb.ga += ga;
                if (ga > gb) { ta.w++; tb.l++; } else if (ga < gb) { tb.w++; ta.l++; } else { ta.d++; tb.d++; }
            }
        }
        std::map<std::string, std::vector<std::pair<std::string, Team>>> perDiv;
        std::map<std::string, std::string> divName;
        for (auto& [id, t] : teams) { perDiv[t.divisionId].push_back({id, t}); divName[t.divisionId] = t.division; }
        json out = json::array();
        for (auto& [did, rows] : perDiv) {
            auto pts = [](const Team& t) { return 3 * t.w + t.d; };
            std::stable_sort(rows.begin(), rows.end(), [&](const auto& x, const auto& y) {
                const Team& a = x.second; const Team& b = y.second;
                if (pts(a) != pts(b)) return pts(a) > pts(b);
                if (a.gf - a.ga != b.gf - b.ga) return a.gf - a.ga > b.gf - b.ga;
                if (a.gf != b.gf) return a.gf > b.gf;
                return a.name < b.name;
            });
            json list = json::array();
            int pos = 0;
            for (const auto& [id, t] : rows) {
                json row = {{"ext_id", id}, {"name", t.name}, {"pos", ++pos}, {"gp", t.gp}, {"w", t.w}, {"d", t.d},
                            {"l", t.l}, {"gf", t.gf}, {"ga", t.ga}, {"pts", pts(t)}};
                if (!t.homes.empty()) {
                    const auto best = std::max_element(t.homes.begin(), t.homes.end(),
                                                       [](const auto& a, const auto& b) { return a.second < b.second; });
                    row["venue_address"] = best->first;
                    auto n = t.homeName.find(best->first);
                    if (n != t.homeName.end()) row["venue_name"] = n->second;
                }
                list.push_back(row);
            }
            out.push_back({{"ext_id", did}, {"name", divName[did]}, {"sort", 0}, {"teams", list}});
        }
        if (out.empty()) note = "season listed no teams";
        return out;
    }
};

std::unique_ptr<PyramidReader> readerFor(const std::string& system) {
    if (system == "teampass_json")   return std::make_unique<TeamPassJsonReader>();
    if (system == "teampass_tables") return std::make_unique<TeamPassTablesReader>();
    if (system == "demosphere")      return std::make_unique<DemosphereReader>();
    if (system == "sportsengine")    return std::make_unique<SportsEngineReader>();
    return nullptr;
}

void stampFailure(int sourceId, const std::string& note) {
    try {
        Database::getInstance()->query(
            "UPDATE pyramid_sources SET last_fetched_at = now(), last_fetch_ok = false, last_fetch_note = $2 WHERE id = $1::int",
            {std::to_string(sourceId), note.substr(0, 500)});
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] stamp failed: " << e.what() << std::endl;
    }
}

} // namespace

// Clubs' home grounds, then league region points, one Nominatim lookup a
// second (their usage policy), on a background thread so a page load never
// waits on it.  A miss stamps geocoded_at with a note and is not asked again
// until the address changes (the loader clears it).
void PyramidSync::geocodePending() {
    bool expected = false;
    if (!gGeocoding.compare_exchange_strong(expected, true)) return;
    std::thread([] {
        auto* db = Database::getInstance();
        auto stamp = [&](const char* table, const std::string& id, const std::optional<LatLon>& geo, const std::string& note) {
            db->query(std::string("UPDATE ") + table + " SET lat = NULLIF($2, '')::numeric, lon = NULLIF($3, '')::numeric, geocoded_at = now(), geocode_note = $4 WHERE id = $1::int",
                      {id, geo ? std::to_string(geo->lat) : "", geo ? std::to_string(geo->lon) : "", note});
        };
        try {
            for (const auto& r : db->query("SELECT id, venue_address FROM pyramid_clubs "
                                           " WHERE venue_address IS NOT NULL AND geocoded_at IS NULL ORDER BY id LIMIT 200")) {
                const std::string addr = r["venue_address"].c_str();
                auto geo = CarpoolRouting::geocode(addr);
                std::this_thread::sleep_for(std::chrono::milliseconds(1100));
                std::string note = "nominatim";
                // A venue Nominatim can't place as written (a park name, a
                // number range) → its town + zip: drop the street part.
                const size_t comma = addr.find(',');
                if (!geo && comma != std::string::npos) {
                    geo = CarpoolRouting::geocode(addr.substr(comma + 1));
                    std::this_thread::sleep_for(std::chrono::milliseconds(1100));
                    note = "nominatim (town)";
                }
                stamp("pyramid_clubs", r["id"].c_str(), geo, geo ? note : "no match: " + addr.substr(0, 80));
            }
            // A league's region ("Detroit Metro Area" + MI → "Detroit, MI");
            // a region Nominatim can't place falls back to its first state.
            for (const auto& r : db->query(
                     "SELECT c.id, coalesce(c.region, '') AS region, "
                     "       (SELECT min(s.state_code) FROM pyramid_competition_states s WHERE s.competition_id = c.id) AS st "
                     "  FROM pyramid_competitions c WHERE c.geocoded_at IS NULL AND c.kind IN ('conference', 'affiliate')")) {
                std::string region = r["region"].c_str();
                const std::string st = r["st"].is_null() ? "" : r["st"].c_str();
                for (const char* drop : {" Metro Area", " Metro"}) {
                    const size_t p = region.find(drop);
                    if (p != std::string::npos) region.erase(p, std::string(drop).size());
                }
                std::optional<LatLon> geo;
                if (!region.empty() && region.find('&') == std::string::npos && region.find('/') == std::string::npos) {
                    geo = CarpoolRouting::geocode(region + (st.empty() ? "" : ", " + st));
                    std::this_thread::sleep_for(std::chrono::milliseconds(1100));
                }
                if (!geo && !st.empty()) {
                    geo = CarpoolRouting::geocode(st + ", USA");
                    std::this_thread::sleep_for(std::chrono::milliseconds(1100));
                }
                stamp("pyramid_competitions", r["id"].c_str(), geo, geo ? "nominatim" : "no match: " + region);
            }
        } catch (const std::exception& e) {
            std::cerr << "[pyramid] geocode: " << e.what() << std::endl;
        }
        gGeocoding = false;
    }).detach();
}

json PyramidSync::refreshSource(int sourceId) {
    json result = {{"source_id", sourceId}, {"ok", false}, {"teams", 0}, {"note", ""}};
    auto* db = Database::getInstance();
    std::string note;
    try {
        auto rows = db->query("SELECT system, locator FROM pyramid_sources WHERE id = $1::int", {std::to_string(sourceId)});
        if (rows.empty()) { result["note"] = "no such source"; return result; }
        const std::string system = rows[0]["system"].c_str();
        const std::string locator = rows[0]["locator"].c_str();

        auto reader = readerFor(system);
        if (!reader) { result["note"] = "read on the host (" + system + ")"; return result; }
        json divisions = reader->read(locator, note);
        if (divisions.empty()) {
            stampFailure(sourceId, note.empty() ? "nothing read" : note);
            result["note"] = note;
            return result;
        }
        auto r = db->query("SELECT fh_pyramid_load($1::int, $2::jsonb)", {std::to_string(sourceId), divisions.dump()});
        result["ok"] = true;
        result["teams"] = r.empty() ? 0 : r[0][0].as<int>();
    } catch (const std::exception& e) {
        note = e.what();
        std::cerr << "[pyramid] source " << sourceId << ": " << note << std::endl;
        stampFailure(sourceId, note);
        result["note"] = note;
    }
    return result;
}

void PyramidSync::refreshIfStale(bool force) {
    std::unique_lock<std::mutex> lock(gRefreshMutex, std::try_to_lock);
    if (!lock.owns_lock()) return;
    try {
        auto due = Database::getInstance()->query(
            "SELECT id FROM pyramid_sources WHERE is_active AND system <> 'root_soccer' "
            "  AND ($1::boolean OR last_fetched_at IS NULL "
            "       OR last_fetched_at < now() - make_interval(mins => max_age_minutes)) ORDER BY id",
            {force ? "true" : "false"});
        for (const auto& r : due) {
            json res = refreshSource(r["id"].as<int>());
            std::cerr << "[pyramid] " << res.dump() << std::endl;
        }
        geocodePending();
    } catch (const std::exception& e) {
        std::cerr << "[pyramid] " << e.what() << std::endl;
    }
}
