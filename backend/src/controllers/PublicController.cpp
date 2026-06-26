#include "PublicController.h"
#include <sstream>
#include <regex>
#include <iostream>

PublicController::PublicController() {
    db_ = Database::getInstance();
}

void PublicController::registerRoutes(Router& router, const std::string& prefix) {
    // prefix == "/api/public"
    router.get(prefix + "/teams/:slug",          [this](const Request& r) { return handleGetTeam(r); });
    router.get(prefix + "/teams/:slug/gameday",  [this](const Request& r) { return handleGetGameday(r); });
    router.get(prefix + "/teams/:slug/lineup",   [this](const Request& r) { return handleGetLineup(r); });
    router.get(prefix + "/teams/:slug/schedule", [this](const Request& r) { return handleGetSchedule(r); });
}

// ─── Live match resolution ──────────────────────────────────────────────────
// Single SQL using COALESCE of subqueries:
//   1) manually pinned match (when live_match_pinned=true)
//   2) earliest scheduled/in_progress/postponed match (status NOT IN completed/cancelled)
//   3) fallback: most recent completed match
int PublicController::resolveLiveMatchId(int team_id) {
    try {
        std::string sql =
            "SELECT COALESCE("
            "  CASE WHEN t.live_match_pinned THEN t.live_match_id END,"
            "  (SELECT m.id FROM matches m"
            "    WHERE (m.home_team_id = t.id OR m.away_team_id = t.id)"
            "      AND m.match_status_id NOT IN (3, 4)"
            "    ORDER BY m.match_date ASC, m.match_time ASC NULLS FIRST"
            "    LIMIT 1),"
            "  (SELECT m.id FROM matches m"
            "    WHERE (m.home_team_id = t.id OR m.away_team_id = t.id)"
            "      AND m.match_status_id = 3"
            "    ORDER BY m.match_date DESC, m.match_time DESC NULLS LAST"
            "    LIMIT 1)"
            ") AS live_match_id "
            "FROM teams t WHERE t.id = $1::int";
        pqxx::result r = db_->query(sql, {std::to_string(team_id)});
        if (r.empty() || r[0]["live_match_id"].is_null()) return 0;
        return r[0]["live_match_id"].as<int>();
    } catch (const std::exception& e) {
        std::cerr << "❌ resolveLiveMatchId(" << team_id << "): " << e.what() << std::endl;
        return 0;
    }
}

// ─── Team lookup by slug ────────────────────────────────────────────────────
bool PublicController::loadTeamBySlug(const std::string& slug,
                                     int& team_id, std::string& team_name,
                                     std::string& logo_url,
                                     bool& live_pinned, int& pinned_match_id) {
    team_id = 0;
    pinned_match_id = 0;
    live_pinned = false;
    try {
        std::string sql =
            "SELECT id, name, COALESCE(logo_url,'') AS logo_url, "
            "       live_match_pinned, "
            "       COALESCE(live_match_id, 0) AS live_match_id "
            "FROM teams WHERE slug = $1 LIMIT 1";
        pqxx::result r = db_->query(sql, {slug});
        if (r.empty()) return false;
        team_id         = r[0]["id"].as<int>();
        team_name       = r[0]["name"].as<std::string>();
        logo_url        = r[0]["logo_url"].as<std::string>();
        live_pinned     = r[0]["live_match_pinned"].as<bool>();
        pinned_match_id = r[0]["live_match_id"].as<int>();
        return true;
    } catch (const std::exception& e) {
        std::cerr << "❌ loadTeamBySlug(" << slug << "): " << e.what() << std::endl;
        return false;
    }
}

// ─── Shared match JSON snippet ──────────────────────────────────────────────
// Returns a JSON *object* like:
//   {"id":42,"date":"2026-06-08","time":"19:30","status":"scheduled",
//    "home":{...},"away":{...},"venue":"...","home_score":null,"away_score":null,
//    "gameday_hidden":false,"lineup_hidden":true,"is_home":true}
// home_team_id is the slug-resolved team's id, used to compute is_home convenience flag.
std::string PublicController::buildMatchJson(int match_id, int viewing_team_id) {
    if (match_id <= 0) return "";
    try {
        std::string sql =
            "SELECT m.id, "
            "       to_char(m.match_date, 'YYYY-MM-DD') AS match_date, "
            "       to_char(m.match_time, 'HH24:MI') AS match_time, "
            "       COALESCE(ms.name, 'scheduled') AS status, "
            "       m.home_team_id, m.away_team_id, "
            "       ht.name AS home_name, COALESCE(ht.logo_url,'') AS home_logo, COALESCE(ht.slug,'') AS home_slug, "
            "       at.name AS away_name, COALESCE(at.logo_url,'') AS away_logo, COALESCE(at.slug,'') AS away_slug, "
            "       COALESCE(v.name,'') AS venue_name, COALESCE(v.address,'') AS venue_address, "
            "       m.home_score, m.away_score, "
            "       m.gameday_hidden, m.lineup_hidden "
            "FROM matches m "
            "LEFT JOIN match_statuses ms ON ms.id = m.match_status_id "
            "LEFT JOIN teams ht ON ht.id = m.home_team_id "
            "LEFT JOIN teams at ON at.id = m.away_team_id "
            "LEFT JOIN venues v ON v.id = m.venue_id "
            "WHERE m.id = $1::int";
        pqxx::result r = db_->query(sql, {std::to_string(match_id)});
        if (r.empty()) return "";
        auto row = r[0];
        int home_id = row["home_team_id"].is_null() ? 0 : row["home_team_id"].as<int>();
        std::ostringstream j;
        j << "{";
        j << "\"id\":" << row["id"].as<int>() << ",";
        j << "\"date\":\"" << escapeJSON(row["match_date"].c_str()) << "\",";
        j << "\"time\":\"" << escapeJSON(row["match_time"].c_str()) << "\",";
        j << "\"status\":\"" << escapeJSON(row["status"].c_str()) << "\",";
        j << "\"is_home\":" << ((home_id == viewing_team_id) ? "true" : "false") << ",";
        j << "\"home\":{\"id\":" << home_id
          << ",\"name\":\"" << escapeJSON(row["home_name"].c_str()) << "\""
          << ",\"logo_url\":\"" << escapeJSON(row["home_logo"].c_str()) << "\""
          << ",\"slug\":\"" << escapeJSON(row["home_slug"].c_str()) << "\"},";
        int away_id = row["away_team_id"].is_null() ? 0 : row["away_team_id"].as<int>();
        j << "\"away\":{\"id\":" << away_id
          << ",\"name\":\"" << escapeJSON(row["away_name"].c_str()) << "\""
          << ",\"logo_url\":\"" << escapeJSON(row["away_logo"].c_str()) << "\""
          << ",\"slug\":\"" << escapeJSON(row["away_slug"].c_str()) << "\"},";
        j << "\"venue\":{\"name\":\"" << escapeJSON(row["venue_name"].c_str())
          << "\",\"address\":\"" << escapeJSON(row["venue_address"].c_str()) << "\"},";
        if (row["home_score"].is_null()) j << "\"home_score\":null,";
        else                              j << "\"home_score\":" << row["home_score"].as<int>() << ",";
        if (row["away_score"].is_null()) j << "\"away_score\":null,";
        else                              j << "\"away_score\":" << row["away_score"].as<int>() << ",";
        j << "\"gameday_hidden\":" << (row["gameday_hidden"].as<bool>() ? "true" : "false") << ",";
        j << "\"lineup_hidden\":"  << (row["lineup_hidden"].as<bool>()  ? "true" : "false");
        j << "}";
        return j.str();
    } catch (const std::exception& e) {
        std::cerr << "❌ buildMatchJson(" << match_id << "): " << e.what() << std::endl;
        return "";
    }
}

// ─── GET /api/public/teams/:slug ────────────────────────────────────────────
Response PublicController::handleGetTeam(const Request& request) {
    try {
        std::string slug = extractSlugFromPath(request.getPath());
        if (slug.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                            createJSONResponse(false, "Missing team slug"));
        }
        int team_id = 0, pinned_match_id = 0;
        bool live_pinned = false;
        std::string team_name, logo_url;
        if (!loadTeamBySlug(slug, team_id, team_name, logo_url, live_pinned, pinned_match_id)) {
            return Response(HttpStatus::NOT_FOUND,
                            createJSONResponse(false, "Team not found"));
        }
        int live_match_id = resolveLiveMatchId(team_id);
        std::string match_json = buildMatchJson(live_match_id, team_id);

        std::ostringstream data;
        data << "{";
        data << "\"team\":{"
             << "\"id\":" << team_id
             << ",\"slug\":\"" << escapeJSON(slug) << "\""
             << ",\"name\":\"" << escapeJSON(team_name) << "\""
             << ",\"logo_url\":\"" << escapeJSON(logo_url) << "\""
             << ",\"live_match_pinned\":" << (live_pinned ? "true" : "false")
             << "},";
        data << "\"live_match\":" << (match_json.empty() ? "null" : match_json);
        data << "}";
        return Response(HttpStatus::OK,
                        createJSONResponse(true, "OK", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ handleGetTeam: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Internal error"));
    }
}

// ─── GET /api/public/teams/:slug/gameday ────────────────────────────────────
// Returns the 18/20 man roster (starters ∪ bench), alphabetical by last name.
// If gameday_hidden=true, returns just the count placeholder.
Response PublicController::handleGetGameday(const Request& request) {
    try {
        std::string slug = extractSlugFromPath(request.getPath());
        int team_id = 0, pinned_match_id = 0;
        bool live_pinned = false;
        std::string team_name, logo_url;
        if (!loadTeamBySlug(slug, team_id, team_name, logo_url, live_pinned, pinned_match_id)) {
            return Response(HttpStatus::NOT_FOUND,
                            createJSONResponse(false, "Team not found"));
        }
        int live_match_id = resolveLiveMatchId(team_id);
        if (live_match_id == 0) {
            std::ostringstream data;
            data << "{\"team\":{\"id\":" << team_id
                 << ",\"slug\":\"" << escapeJSON(slug) << "\""
                 << ",\"name\":\"" << escapeJSON(team_name) << "\""
                 << ",\"logo_url\":\"" << escapeJSON(logo_url) << "\"},"
                 << "\"match\":null,\"hidden\":false,\"players\":[]}";
            return Response(HttpStatus::OK,
                            createJSONResponse(true, "No live match", data.str()));
        }
        std::string match_json = buildMatchJson(live_match_id, team_id);

        // Check the visibility flag straight from the match row (cheap)
        bool hidden = false;
        {
            pqxx::result vr = db_->query(
                "SELECT gameday_hidden FROM matches WHERE id = $1::int",
                {std::to_string(live_match_id)});
            if (!vr.empty()) hidden = vr[0]["gameday_hidden"].as<bool>();
        }

        std::ostringstream players_json;
        players_json << "[";
        int player_count = 0;
        if (!hidden) {
            // Load starters + bench (NOT alternates) for this team in this match.
            // Sort alphabetically by last name, then first name.
            std::string lineup_sql =
                "SELECT p.id, p.first_name, p.last_name, "
                "       COALESCE(p.jersey_number, '') AS jersey_number, "
                "       COALESCE(pos.abbreviation, '') AS position, "
                "       ml.zone, ml.is_starter "
                "FROM match_lineups ml "
                "JOIN players p ON p.id = ml.player_id "
                "LEFT JOIN positions pos ON pos.id = ml.position_id "
                "WHERE ml.match_id = $1::int "
                "  AND ml.team_id  = $2::int "
                "  AND ml.zone IN ('starter','bench') "
                "ORDER BY LOWER(p.last_name) ASC, LOWER(p.first_name) ASC";
            pqxx::result pr = db_->query(lineup_sql,
                {std::to_string(live_match_id), std::to_string(team_id)});
            for (size_t i = 0; i < pr.size(); ++i) {
                if (i > 0) players_json << ",";
                players_json << "{"
                    << "\"id\":" << pr[i]["id"].as<int>()
                    << ",\"first_name\":\"" << escapeJSON(pr[i]["first_name"].c_str()) << "\""
                    << ",\"last_name\":\""  << escapeJSON(pr[i]["last_name"].c_str())  << "\""
                    << ",\"jersey_number\":\"" << escapeJSON(pr[i]["jersey_number"].c_str()) << "\""
                    << ",\"position\":\"" << escapeJSON(pr[i]["position"].c_str()) << "\""
                    << ",\"zone\":\"" << escapeJSON(pr[i]["zone"].c_str()) << "\""
                    << "}";
                player_count++;
            }
        } else {
            // When hidden, also fetch the count so the placeholder card can
            // still say "18 players to be announced soon"
            pqxx::result cr = db_->query(
                "SELECT COUNT(*) AS n FROM match_lineups "
                "WHERE match_id = $1::int AND team_id = $2::int "
                "  AND zone IN ('starter','bench')",
                {std::to_string(live_match_id), std::to_string(team_id)});
            if (!cr.empty()) player_count = cr[0]["n"].as<int>();
        }
        players_json << "]";

        std::ostringstream data;
        data << "{";
        data << "\"team\":{\"id\":" << team_id
             << ",\"slug\":\"" << escapeJSON(slug) << "\""
             << ",\"name\":\"" << escapeJSON(team_name) << "\""
             << ",\"logo_url\":\"" << escapeJSON(logo_url) << "\"},";
        data << "\"match\":" << (match_json.empty() ? "null" : match_json) << ",";
        data << "\"hidden\":" << (hidden ? "true" : "false") << ",";
        data << "\"player_count\":" << player_count << ",";
        data << "\"players\":" << players_json.str();
        data << "}";
        return Response(HttpStatus::OK,
                        createJSONResponse(true, "OK", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ handleGetGameday: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Internal error"));
    }
}

// ─── GET /api/public/teams/:slug/lineup ─────────────────────────────────────
// Returns starters[], bench[], formation, custom_positions.
// When lineup_hidden=true, returns the SAME structure with empty-string names
// and zeroed ids so the UI can render the layout (formation/slots) without
// revealing who is in each slot.
Response PublicController::handleGetLineup(const Request& request) {
    try {
        std::string slug = extractSlugFromPath(request.getPath());
        int team_id = 0, pinned_match_id = 0;
        bool live_pinned = false;
        std::string team_name, logo_url;
        if (!loadTeamBySlug(slug, team_id, team_name, logo_url, live_pinned, pinned_match_id)) {
            return Response(HttpStatus::NOT_FOUND,
                            createJSONResponse(false, "Team not found"));
        }
        int live_match_id = resolveLiveMatchId(team_id);
        if (live_match_id == 0) {
            std::ostringstream data;
            data << "{\"team\":{\"id\":" << team_id
                 << ",\"slug\":\"" << escapeJSON(slug) << "\""
                 << ",\"name\":\"" << escapeJSON(team_name) << "\""
                 << ",\"logo_url\":\"" << escapeJSON(logo_url) << "\"},"
                 << "\"match\":null,\"hidden\":true,"
                 << "\"starters\":[],\"bench\":[],"
                 << "\"formation_id\":null,\"custom_positions\":null,\"roster_size\":20}";
            return Response(HttpStatus::OK,
                            createJSONResponse(true, "No live match", data.str()));
        }
        std::string match_json = buildMatchJson(live_match_id, team_id);

        bool hidden = true;
        {
            pqxx::result vr = db_->query(
                "SELECT lineup_hidden FROM matches WHERE id = $1::int",
                {std::to_string(live_match_id)});
            if (!vr.empty()) hidden = vr[0]["lineup_hidden"].as<bool>();
        }

        // Pull metadata (formation, custom_positions, roster_size)
        std::string formation_id_json = "null";
        std::string custom_positions_json = "null";
        int roster_size = 20;
        try {
            pqxx::result mr = db_->query(
                "SELECT formation_id, COALESCE(custom_positions::text, '') AS custom_positions, "
                "       COALESCE(roster_size, 20) AS roster_size "
                "FROM match_lineup_metadata "
                "WHERE match_id = $1::int AND team_id = $2::int LIMIT 1",
                {std::to_string(live_match_id), std::to_string(team_id)});
            if (!mr.empty()) {
                if (!mr[0]["formation_id"].is_null())
                    formation_id_json = std::to_string(mr[0]["formation_id"].as<int>());
                std::string cp = mr[0]["custom_positions"].as<std::string>();
                if (!cp.empty()) custom_positions_json = cp;
                roster_size = mr[0]["roster_size"].as<int>();
            }
        } catch (const std::exception& e) {
            // Metadata table may not have a row yet — that's fine.
            std::cerr << "ℹ️  lineup_meta lookup: " << e.what() << std::endl;
        }

        auto buildZoneArray = [&](const char* zone) {
            std::ostringstream arr; arr << "[";
            std::string sql =
                "SELECT p.id, p.first_name, p.last_name, "
                "       COALESCE(p.jersey_number,'') AS jersey_number, "
                "       COALESCE(pos.abbreviation,'') AS position, "
                "       COALESCE(ml.slot_number, -1) AS slot_number "
                "FROM match_lineups ml "
                "JOIN players p ON p.id = ml.player_id "
                "LEFT JOIN positions pos ON pos.id = ml.position_id "
                "WHERE ml.match_id = $1::int AND ml.team_id = $2::int AND ml.zone = $3 "
                "ORDER BY ml.slot_number ASC NULLS LAST, LOWER(p.last_name) ASC";
            pqxx::result pr = db_->query(sql,
                {std::to_string(live_match_id), std::to_string(team_id), zone});
            for (size_t i = 0; i < pr.size(); ++i) {
                if (i > 0) arr << ",";
                int pid = pr[i]["id"].as<int>();
                std::string fn = pr[i]["first_name"].c_str();
                std::string ln = pr[i]["last_name"].c_str();
                std::string jn = pr[i]["jersey_number"].c_str();
                std::string ps = pr[i]["position"].c_str();
                int slot = pr[i]["slot_number"].as<int>();
                // Anonymize when hidden: keep slot/position so layout renders,
                // but null id and empty names/jersey.
                if (hidden) { pid = 0; fn = ""; ln = ""; jn = ""; }
                arr << "{"
                    << "\"id\":" << pid
                    << ",\"first_name\":\"" << escapeJSON(fn) << "\""
                    << ",\"last_name\":\""  << escapeJSON(ln) << "\""
                    << ",\"jersey_number\":\"" << escapeJSON(jn) << "\""
                    << ",\"position\":\"" << escapeJSON(ps) << "\""
                    << ",\"slot_number\":" << slot
                    << "}";
            }
            arr << "]";
            return arr.str();
        };

        std::string starters = buildZoneArray("starter");
        std::string bench    = buildZoneArray("bench");

        std::ostringstream data;
        data << "{";
        data << "\"team\":{\"id\":" << team_id
             << ",\"slug\":\"" << escapeJSON(slug) << "\""
             << ",\"name\":\"" << escapeJSON(team_name) << "\""
             << ",\"logo_url\":\"" << escapeJSON(logo_url) << "\"},";
        data << "\"match\":" << (match_json.empty() ? "null" : match_json) << ",";
        data << "\"hidden\":" << (hidden ? "true" : "false") << ",";
        data << "\"formation_id\":" << formation_id_json << ",";
        data << "\"custom_positions\":" << custom_positions_json << ",";
        data << "\"roster_size\":" << roster_size << ",";
        data << "\"starters\":" << starters << ",";
        data << "\"bench\":" << bench;
        data << "}";
        return Response(HttpStatus::OK,
                        createJSONResponse(true, "OK", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ handleGetLineup: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Internal error"));
    }
}

// ─── GET /api/public/teams/:slug/schedule ───────────────────────────────────
Response PublicController::handleGetSchedule(const Request& request) {
    try {
        std::string slug = extractSlugFromPath(request.getPath());
        int team_id = 0, pinned_match_id = 0;
        bool live_pinned = false;
        std::string team_name, logo_url;
        if (!loadTeamBySlug(slug, team_id, team_name, logo_url, live_pinned, pinned_match_id)) {
            return Response(HttpStatus::NOT_FOUND,
                            createJSONResponse(false, "Team not found"));
        }
        int live_match_id = resolveLiveMatchId(team_id);

        std::string sql =
            "SELECT m.id, "
            "       to_char(m.match_date, 'YYYY-MM-DD') AS match_date, "
            "       to_char(m.match_time, 'HH24:MI') AS match_time, "
            "       COALESCE(ms.name,'scheduled') AS status, "
            "       m.home_team_id, m.away_team_id, "
            "       ht.name AS home_name, COALESCE(ht.logo_url,'') AS home_logo, "
            "       at.name AS away_name, COALESCE(at.logo_url,'') AS away_logo, "
            "       COALESCE(v.name,'') AS venue_name, "
            "       m.home_score, m.away_score "
            "FROM matches m "
            "LEFT JOIN match_statuses ms ON ms.id = m.match_status_id "
            "LEFT JOIN teams ht ON ht.id = m.home_team_id "
            "LEFT JOIN teams at ON at.id = m.away_team_id "
            "LEFT JOIN venues v ON v.id = m.venue_id "
            "WHERE m.home_team_id = $1::int OR m.away_team_id = $1::int "
            "ORDER BY m.match_date ASC, m.match_time ASC NULLS FIRST";
        pqxx::result r = db_->query(sql, {std::to_string(team_id)});

        std::ostringstream arr; arr << "[";
        for (size_t i = 0; i < r.size(); ++i) {
            if (i > 0) arr << ",";
            int mid = r[i]["id"].as<int>();
            int home_id = r[i]["home_team_id"].is_null() ? 0 : r[i]["home_team_id"].as<int>();
            arr << "{"
                << "\"id\":" << mid
                << ",\"date\":\"" << escapeJSON(r[i]["match_date"].c_str()) << "\""
                << ",\"time\":\"" << escapeJSON(r[i]["match_time"].c_str()) << "\""
                << ",\"status\":\"" << escapeJSON(r[i]["status"].c_str()) << "\""
                << ",\"is_home\":" << ((home_id == team_id) ? "true" : "false")
                << ",\"is_live\":" << ((mid == live_match_id) ? "true" : "false")
                << ",\"home\":{\"name\":\"" << escapeJSON(r[i]["home_name"].c_str())
                    << "\",\"logo_url\":\"" << escapeJSON(r[i]["home_logo"].c_str()) << "\"}"
                << ",\"away\":{\"name\":\"" << escapeJSON(r[i]["away_name"].c_str())
                    << "\",\"logo_url\":\"" << escapeJSON(r[i]["away_logo"].c_str()) << "\"}"
                << ",\"venue\":\"" << escapeJSON(r[i]["venue_name"].c_str()) << "\"";
            if (r[i]["home_score"].is_null()) arr << ",\"home_score\":null";
            else                              arr << ",\"home_score\":" << r[i]["home_score"].as<int>();
            if (r[i]["away_score"].is_null()) arr << ",\"away_score\":null";
            else                              arr << ",\"away_score\":" << r[i]["away_score"].as<int>();
            arr << "}";
        }
        arr << "]";

        std::ostringstream data;
        data << "{";
        data << "\"team\":{\"id\":" << team_id
             << ",\"slug\":\"" << escapeJSON(slug) << "\""
             << ",\"name\":\"" << escapeJSON(team_name) << "\""
             << ",\"logo_url\":\"" << escapeJSON(logo_url) << "\"},";
        data << "\"live_match_id\":" << live_match_id << ",";
        data << "\"matches\":" << arr.str();
        data << "}";
        return Response(HttpStatus::OK,
                        createJSONResponse(true, "OK", data.str()));
    } catch (const std::exception& e) {
        std::cerr << "❌ handleGetSchedule: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Internal error"));
    }
}

// ─── helpers ─────────────────────────────────────────────────────────────────
std::string PublicController::extractSlugFromPath(const std::string& path) {
    // Matches /api/public/teams/<slug>[/<rest>]
    std::regex re(R"(/api/public/teams/([^/]+))");
    std::smatch m;
    if (std::regex_search(path, m, re)) return m[1].str();
    return "";
}


