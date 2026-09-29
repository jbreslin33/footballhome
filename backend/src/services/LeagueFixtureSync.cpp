#include "LeagueFixtureSync.h"

#include <iostream>

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

} // namespace

LeagueFixtureSync::Result LeagueFixtureSync::refreshSource(long long sourceId, const std::string& programId) {
    Result out;
    auto* db = Database::getInstance();
    const std::string sid = std::to_string(sourceId);
    std::string runStart;
    try { runStart = db->query("SELECT now()::text AS t")[0]["t"].c_str(); } catch (...) {}

    HttpClient http;
    http.setTotalTimeoutSec(kTimeoutSec);
    int totalPages = 1;
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
                    {sid, extId, divisionOf(ev), startsAt, sv(ev, "end_date_time"), status,
                     sv(home, "name"), sv(away, "name"), sv(home, "originator_id"), sv(away, "originator_id"),
                     homeScore, awayScore, sv(ev, "location_name"), sv(ev, "location_description"), sv(ev, "location_address"),
                     sv(ev, "updated_at")});
                out.games++;
            } catch (const std::exception& e) { std::cerr << "[fixture sync] upsert " << extId << ": " << e.what() << std::endl; }
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
        auto rows = Database::getInstance()->query("SELECT id, program_id FROM league_fixture_sources WHERE league_label = $1 AND is_active ORDER BY season DESC, id", {leagueLabel});
        for (const auto& r : rows) {
            const long long id = r["id"].as<long long>();
            auto res = refreshSource(id, r["program_id"].c_str());
            out.push_back({{"source_id", id}, {"ok", res.ok}, {"games", res.games}, {"note", res.note}});
        }
    } catch (const std::exception& e) { std::cerr << "[fixture sync] " << leagueLabel << ": " << e.what() << std::endl; }
    return out;
}
