#include "FilmController.h"

#include <iostream>

#include "../database/Database.h"
#include "../services/FilmSync.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

// Fuzzy game resolution: the alias names the club, and the closest APSL
// fixture involving that club within window ±3 days is the game — inside
// the stated window beats outside it, then nearest to the window's middle.
// Our feed only carries Lighthouse's fixtures, so a resolved game is ours
// by construction; everyone else's film stays matchday + home team.
constexpr const char* kListSql = R"SQL(
    SELECT l.matchday_label, l.window_start::text AS from_d, l.window_end::text AS till_d,
           l.home_team_text, l.url,
           g.game_on, g.day_label, g.opponent, g.home_name, g.away_name
      FROM film_links l
      JOIN film_sources s ON s.id = l.source_id AND s.is_active
      LEFT JOIN film_team_aliases a ON a.alias = lower(BTRIM(l.home_team_text))
      LEFT JOIN LATERAL (
            SELECT (f.starts_at AT TIME ZONE 'America/New_York')::date AS game_on,
                   to_char(f.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS day_label,
                   CASE WHEN f.home_club_id = 134 THEN f.away_name
                        WHEN f.away_club_id = 134 THEN f.home_name END AS opponent,
                   -- Since mig 607 league_fixtures carries the whole
                   -- division (per-team .ics feeds), so EVERY film row can
                   -- name both sides, not just ours (owner 2026-10-19:
                   -- "players may not know easy who the away team was").
                   f.home_name, f.away_name
              FROM league_fixtures f
              JOIN league_fixture_sources fs ON fs.id = f.source_id AND fs.league_label = s.league_label
             WHERE f.removed_at IS NULL AND f.status <> 'cancelled'
               -- Prefix either way: the feeds drop/add suffixes per team
               -- ("Vereinigung Erzgebirge" vs "… Majors").
               AND (lower(f.home_name) LIKE lower(a.feed_name) || '%' OR lower(a.feed_name) LIKE lower(f.home_name) || '%'
                    OR lower(f.away_name) LIKE lower(a.feed_name) || '%' OR lower(a.feed_name) LIKE lower(f.away_name) || '%'
                    OR (a.feed_name = 'Lighthouse 1893 SC' AND (f.home_club_id = 134 OR f.away_club_id = 134)))
               AND (f.starts_at AT TIME ZONE 'America/New_York')::date
                     BETWEEN l.window_start - 3 AND l.window_end + 3
               -- An out-of-window (fuzzy) match yields to a sibling row
               -- whose stated window properly holds the fixture: VE's
               -- matchday-4 film must not steal our 9/30 VE game, which
               -- matchday 3's own VE row already names.
               AND ((f.starts_at AT TIME ZONE 'America/New_York')::date
                      BETWEEN l.window_start AND l.window_end
                    OR NOT EXISTS (SELECT 1 FROM film_links l2
                                    WHERE l2.source_id = l.source_id AND l2.id <> l.id
                                      AND l2.removed_at IS NULL
                                      AND lower(BTRIM(l2.home_team_text)) = a.alias
                                      AND (f.starts_at AT TIME ZONE 'America/New_York')::date
                                            BETWEEN l2.window_start AND l2.window_end))
             ORDER BY ((f.starts_at AT TIME ZONE 'America/New_York')::date
                         BETWEEN l.window_start AND l.window_end) DESC,
                      ABS((f.starts_at AT TIME ZONE 'America/New_York')::date
                            - (l.window_start + (l.window_end - l.window_start) / 2))
             LIMIT 1) g ON true
     WHERE l.removed_at IS NULL
     ORDER BY l.window_start DESC, l.id)SQL";
} // namespace

FilmController::FilmController() {}

void FilmController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleList(r); });
}

Response FilmController::handleList(const Request& request) {
    if (!requireBearer(request)) return jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
    try {
        FilmSync::refreshIfStale(60);
        json rows = json::array();
        for (const auto& r : Database::getInstance()->query(kListSql, {})) {
            json game = nullptr;
            if (!r["game_on"].is_null()) {
                game = {{"on", str(r, "game_on")}, {"day_label", str(r, "day_label")},
                        {"opponent", r["opponent"].is_null() ? json(nullptr) : json(str(r, "opponent"))},
                        {"home", str(r, "home_name")}, {"away", str(r, "away_name")}};
            }
            rows.push_back({{"matchday", str(r, "matchday_label")}, {"from", str(r, "from_d")}, {"till", str(r, "till_d")},
                            {"home_team", str(r, "home_team_text")}, {"url", str(r, "url")}, {"game", game}});
        }
        return jsonOut(HttpStatus::OK, {{"rows", rows}});
    } catch (const std::exception& e) {
        std::cerr << "[film] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
