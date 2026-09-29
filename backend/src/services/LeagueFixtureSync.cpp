#include "LeagueFixtureSync.h"

#include <cctype>
#include <iostream>
#include <vector>

#include "../core/HttpClient.h"
#include "../database/Database.h"

using nlohmann::json;

namespace {

constexpr const char* kEventsApi = "https://se-api.sportsengine.com/v3/microsites/events";
constexpr int kPerPage = 100;
constexpr int kMaxPages = 20;        // 2,000 games — far past any season
constexpr long kTimeoutSec = 10;     // the hub waits on this; SportsEngine answers in ~1 s

std::string sv(const json& j, const char* k) {
    if (!j.is_object() || !j.contains(k) || j[k].is_null()) return {};
    const auto& v = j[k];
    if (v.is_string()) return v.get<std::string>();
    if (v.is_number_integer()) return std::to_string(v.get<long long>());
    if (v.is_boolean()) return v.get<bool>() ? "true" : "false";
    return {};
}

// The division as the feed states it: on a principal, either at the top or
// under extended_attributes (the feed is inconsistent between the two).
std::string divisionOf(const json& ev) {
    if (!ev.contains("principals") || !ev["principals"].is_array()) return {};
    for (const auto& p : ev["principals"]) {
        std::string d = sv(p, "division_name");
        if (d.empty() && p.contains("extended_attributes")) d = sv(p["extended_attributes"], "division_name");
        if (!d.empty()) return d;
    }
    return {};
}

// One fixture row, whatever feed it came from.  Names resolve to clubs
// through fh_club_id_for_name() (club_aliases, then clubs.name).
struct FixtureRow {
    std::string extId, division, startsAt, endsAt, status, homeName, awayName, homeExt, awayExt,
                homeScore, awayScore, venueName, venueDetail, venueAddress, updatedAt;
};

bool upsertFixture(Database* db, const std::string& sid, const FixtureRow& f) {
    try {
        db->query(R"SQL(
            INSERT INTO league_fixtures (source_id, external_id, division_name, division_label, starts_at, ends_at, status,
                                         home_name, away_name, home_club_id, away_club_id, home_ext_team_id, away_ext_team_id,
                                         home_score, away_score, venue_name, venue_detail, venue_address, external_updated_at, last_seen_at, removed_at)
            VALUES ($1::int, $2, NULLIF($3,''), NULLIF(regexp_replace($3, '^PHL\s+', ''), ''), $4::timestamptz, NULLIF($5,'')::timestamptz, $6,
                    $7, $8, fh_club_id_for_name($7), fh_club_id_for_name($8), NULLIF($9,''), NULLIF($10,''),
                    NULLIF($11,'')::int, NULLIF($12,'')::int, NULLIF($13,''), NULLIF($14,''), NULLIF($15,''), NULLIF($16,'')::timestamptz, now(), NULL)
            ON CONFLICT (source_id, external_id) DO UPDATE SET
                division_name = EXCLUDED.division_name, division_label = EXCLUDED.division_label,
                starts_at = EXCLUDED.starts_at, ends_at = EXCLUDED.ends_at, status = EXCLUDED.status,
                home_name = EXCLUDED.home_name, away_name = EXCLUDED.away_name,
                home_club_id = EXCLUDED.home_club_id, away_club_id = EXCLUDED.away_club_id,
                home_ext_team_id = EXCLUDED.home_ext_team_id, away_ext_team_id = EXCLUDED.away_ext_team_id,
                home_score = EXCLUDED.home_score, away_score = EXCLUDED.away_score,
                venue_name = EXCLUDED.venue_name, venue_detail = EXCLUDED.venue_detail, venue_address = EXCLUDED.venue_address,
                external_updated_at = EXCLUDED.external_updated_at, last_seen_at = now(), removed_at = NULL)SQL",
            {sid, f.extId, f.division, f.startsAt, f.endsAt, f.status, f.homeName, f.awayName, f.homeExt, f.awayExt,
             f.homeScore, f.awayScore, f.venueName, f.venueDetail, f.venueAddress, f.updatedAt});
        return true;
    } catch (const std::exception& e) { std::cerr << "[fixture sync] upsert " << f.extId << ": " << e.what() << std::endl; return false; }
}

// ── iCal (TeamPass, mig 490) ─────────────────────────────────────────────
// The APSL team page offers its fixtures as an .ics.  Lines end in CR only,
// continuation lines start with a space or tab, "\," is a literal comma.
// SUMMARY is "Match: <home> vs <away>"; there are no scores.
std::vector<std::string> icsLines(const std::string& raw) {
    std::vector<std::string> lines; std::string cur;
    auto flush = [&]() { if (!cur.empty()) { if ((cur[0] == ' ' || cur[0] == '\t') && !lines.empty()) lines.back() += cur.substr(1); else lines.push_back(cur); } cur.clear(); };
    for (char c : raw) { if (c == '\r' || c == '\n') flush(); else cur += c; }
    flush();
    return lines;
}
std::string icsUnescape(std::string v) {
    std::string out; out.reserve(v.size());
    for (size_t i = 0; i < v.size(); i++) {
        if (v[i] == '\\' && i + 1 < v.size()) { char n = v[i + 1]; if (n == ',' || n == ';' || n == '\\') { out += n; i++; continue; } if (n == 'n' || n == 'N') { out += '\n'; i++; continue; } }
        out += v[i];
    }
    return out;
}
// 20260913T160000Z → 2026-09-13T16:00:00Z (the feed is UTC); a bare date → midnight New York.
std::string icsTime(const std::string& v) {
    std::string d = v; auto colon = d.find(':'); if (colon != std::string::npos) d = d.substr(colon + 1);
    if (d.size() < 8) return {};
    std::string out = d.substr(0, 4) + "-" + d.substr(4, 2) + "-" + d.substr(6, 2);
    if (d.size() >= 15 && d[8] == 'T') { out += "T" + d.substr(9, 2) + ":" + d.substr(11, 2) + ":" + d.substr(13, 2); out += d.back() == 'Z' ? "Z" : " America/New_York"; }
    else out += " 00:00 America/New_York";
    return out;
}
std::string trim(std::string s) { while (!s.empty() && isspace((unsigned char)s.back())) s.pop_back(); size_t i = 0; while (i < s.size() && isspace((unsigned char)s[i])) i++; return s.substr(i); }

std::vector<FixtureRow> parseIcs(const std::string& raw) {
    std::vector<FixtureRow> out; FixtureRow cur; bool in = false;
    for (const auto& line : icsLines(raw)) {
        if (line == "BEGIN:VEVENT") { in = true; cur = FixtureRow{}; continue; }
        if (line == "END:VEVENT") { if (in && !cur.extId.empty() && !cur.startsAt.empty() && !cur.homeName.empty()) out.push_back(cur); in = false; continue; }
        if (!in) continue;
        auto colon = line.find(':'); if (colon == std::string::npos) continue;
        std::string key = line.substr(0, colon); auto semi = key.find(';'); if (semi != std::string::npos) key = key.substr(0, semi);
        const std::string val = icsUnescape(line.substr(colon + 1));
        if (key == "UID") cur.extId = val;
        else if (key == "DTSTART") cur.startsAt = icsTime(line);
        else if (key == "DTEND") cur.endsAt = icsTime(line);
        else if (key == "DTSTAMP") cur.updatedAt = icsTime(line);
        else if (key == "STATUS") cur.status = val == "CANCELLED" ? "cancelled" : "scheduled";
        else if (key == "SUMMARY") {
            std::string s = val; if (s.rfind("Match:", 0) == 0) s = trim(s.substr(6));
            auto vs = s.find(" vs "); if (vs != std::string::npos) { cur.homeName = trim(s.substr(0, vs)); cur.awayName = trim(s.substr(vs + 4)); }
        }
        else if (key == "LOCATION") {
            // "Lighthouse Field (Field Lighthouse Field), 101-109 E Erie Ave, Philadelphia, PA 19140"
            std::string s = val; auto comma = s.find(", ");
            std::string name = comma == std::string::npos ? s : s.substr(0, comma);
            if (comma != std::string::npos) cur.venueAddress = trim(s.substr(comma + 2));
            auto paren = name.find(" ("); if (paren != std::string::npos) name = name.substr(0, paren);
            cur.venueName = trim(name);
        }
    }
    for (auto& f : out) if (f.status.empty()) f.status = "scheduled";
    return out;
}

} // namespace

LeagueFixtureSync::Result LeagueFixtureSync::refreshSource(long long sourceId, const std::string& programId, const std::string& system) {
    Result out;
    auto* db = Database::getInstance();
    const std::string sid = std::to_string(sourceId);
    std::string runStart;
    try { runStart = db->query("SELECT now()::text AS t")[0]["t"].c_str(); } catch (...) {}

    HttpClient http;
    http.setTotalTimeoutSec(kTimeoutSec);
    int totalPages = 1;
    if (system == "teampass_ics") {
        const std::string url = "https://app.teampass.com/mediacontent/iCal/" + programId + ".ics";
        auto resp = http.get(url, {{"Accept", "text/calendar"}});
        if (!resp.ok()) out.note = "HTTP " + std::to_string(resp.status) + (resp.error.empty() ? "" : " " + resp.error);
        else {
            auto rows = parseIcs(resp.body);
            if (rows.empty()) out.note = "no events in the feed";
            else { for (const auto& f : rows) if (upsertFixture(db, sid, f)) out.games++; out.pages = 1; out.ok = true; }
        }
        totalPages = 0;   // skip the paged loop below
    }
    for (int page = 1; page <= totalPages && page <= kMaxPages; page++) {
        const std::string url = std::string(kEventsApi) + "?page=" + std::to_string(page) + "&per_page=" + std::to_string(kPerPage) +
                                "&program_id=" + HttpClient::urlEncode(programId) + "&order_by=starts_at&direction=asc";
        auto resp = http.get(url, {{"Accept", "application/json"}});
        if (!resp.ok()) { out.note = "HTTP " + std::to_string(resp.status) + (resp.error.empty() ? "" : " " + resp.error); break; }
        json body = json::parse(resp.body, nullptr, false);
        if (body.is_discarded() || !body.contains("result") || !body["result"].is_array()) { out.note = "unexpected feed shape"; break; }
        try {
            const auto& pg = body["metadata"]["pagination"];
            if (pg.contains("totalPages") && pg["totalPages"].is_number()) totalPages = pg["totalPages"].get<int>();
        } catch (...) {}
        out.pages = page;

        for (const auto& ev : body["result"]) {
            if (sv(ev, "event_type") != "game") continue;
            const std::string extId = sv(ev, "id");
            const std::string startsAt = sv(ev, "start_date_time");
            if (extId.empty() || startsAt.empty()) continue;
            const json gd = ev.contains("game_details") && ev["game_details"].is_object() ? ev["game_details"] : json::object();
            json home = json::object(), away = json::object();
            for (const char* k : {"team_1", "team_2"}) {
                if (!gd.contains(k) || !gd[k].is_object()) continue;
                const json& t = gd[k];
                if (t.contains("is_home_team") && t["is_home_team"].is_boolean() && t["is_home_team"].get<bool>()) home = t; else away = t;
            }
            if (home.empty() || away.empty()) {
                // No game_details — fall back to the title "Away at Home".
                const std::string title = sv(ev, "title");
                auto at = title.find(" at ");
                if (at == std::string::npos) continue;
                away = {{"name", title.substr(0, at)}}; home = {{"name", title.substr(at + 4)}};
            }
            const std::string status = sv(ev, "status").empty() ? "scheduled" : sv(ev, "status");
            std::string homeScore = sv(home, "score"), awayScore = sv(away, "score");
            if (status != "completed") { homeScore.clear(); awayScore.clear(); }
            FixtureRow f{extId, divisionOf(ev), startsAt, sv(ev, "end_date_time"), status, sv(home, "name"), sv(away, "name"),
                         sv(home, "originator_id"), sv(away, "originator_id"), homeScore, awayScore,
                         sv(ev, "location_name"), sv(ev, "location_description"), sv(ev, "location_address"), sv(ev, "updated_at")};
            if (upsertFixture(db, sid, f)) out.games++;
        }
        if (page >= totalPages) out.ok = true;
    }
    if (out.ok) out.note = std::to_string(out.games) + " games";
    else if (out.note.empty()) out.note = "incomplete pull (" + std::to_string(out.pages) + " of " + std::to_string(totalPages) + " pages)";

    try {
        if (out.ok && !runStart.empty())
            db->query("UPDATE league_fixtures SET removed_at = now() WHERE source_id = $1::int AND removed_at IS NULL AND last_seen_at < $2::timestamptz", {sid, runStart});
        db->query("UPDATE league_fixture_sources SET last_fetched_at = CASE WHEN $2::boolean THEN now() ELSE last_fetched_at END, last_fetch_ok = $2::boolean, last_fetch_note = $3 WHERE id = $1::int",
                  {sid, out.ok ? "true" : "false", out.note});
    } catch (const std::exception& e) { std::cerr << "[fixture sync] stamp: " << e.what() << std::endl; }
    if (!out.ok) std::cerr << "[fixture sync] source " << sid << ": " << out.note << std::endl;
    return out;
}

json LeagueFixtureSync::refreshLeague(const std::string& leagueLabel) {
    json out = json::array();
    try {
        auto rows = Database::getInstance()->query("SELECT id, program_id, system FROM league_fixture_sources WHERE league_label = $1 AND is_active ORDER BY season DESC, id", {leagueLabel});
        for (const auto& r : rows) {
            const long long id = r["id"].as<long long>();
            auto res = refreshSource(id, r["program_id"].c_str(), r["system"].c_str());
            out.push_back({{"source_id", id}, {"ok", res.ok}, {"games", res.games}, {"note", res.note}});
        }
    } catch (const std::exception& e) { std::cerr << "[fixture sync] " << leagueLabel << ": " << e.what() << std::endl; }
    return out;
}
