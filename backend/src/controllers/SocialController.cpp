#include "SocialController.h"
#include <sstream>
#include <iostream>
#include <iomanip>
#include <regex>

SocialController::SocialController() {
    db_ = Database::getInstance();
}

// ---------- Path Parameter Extraction ----------

std::string SocialController::extractMatchIdFromPath(const std::string& path) {
    // Matches /api/social/match/{id}/team/... or /api/social/schedule/apply/{id}/...
    std::regex r(R"(/api/social/(?:match|schedule/apply)/(\d+))");
    std::smatch m;
    if (std::regex_search(path, m, r)) {
        return m[1].str();
    }
    return "";
}

std::string SocialController::extractTeamIdFromPath(const std::string& path) {
    // Matches /api/social/match/{matchId}/team/{teamId}
    //      or /api/social/calendar/team/{teamId}
    //      or /api/social/schedule/team/{teamId}
    //      or /api/social/schedule/apply/{matchId}/{teamId}
    std::regex r1(R"(/api/social/(?:calendar|schedule)/team/(\d+))");
    std::smatch m;
    if (std::regex_search(path, m, r1)) {
        return m[1].str();
    }
    std::regex r2(R"(/api/social/match/\d+/team/(\d+))");
    if (std::regex_search(path, m, r2)) {
        return m[1].str();
    }
    std::regex r3(R"(/api/social/schedule/apply/\d+/(\d+))");
    if (std::regex_search(path, m, r3)) {
        return m[1].str();
    }
    return "";
}

std::string SocialController::extractPostIdFromPath(const std::string& path) {
    // Matches /api/social/posts/{id} or /api/social/posts/{id}/publish
    std::regex r(R"(/api/social/posts/(\d+))");
    std::smatch m;
    if (std::regex_search(path, m, r)) {
        return m[1].str();
    }
    return "";
}

void SocialController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "Registering social routes with prefix: " << prefix << std::endl;

    // GET /api/social/post-types - List post types
    router.get(prefix + "/post-types", [this](const Request& request) {
        return this->handleGetPostTypes(request);
    });

    // GET /api/social/match/:matchId/team/:teamId - Get social posts for a match+team
    router.get(prefix + "/match/:matchId/team/:teamId", [this](const Request& request) {
        return this->handleGetMatchPosts(request);
    });

    // GET /api/social/calendar/team/:teamId - Get all posts across upcoming matches for calendar view
    router.get(prefix + "/calendar/team/:teamId", [this](const Request& request) {
        return this->handleGetTeamCalendar(request);
    });

    // POST /api/social/posts - Create or update a social post
    router.post(prefix + "/posts", [this](const Request& request) {
        return this->handleCreateOrUpdatePost(request);
    });

    // DELETE /api/social/posts/:postId - Delete a social post
    router.del(prefix + "/posts/:postId", [this](const Request& request) {
        return this->handleDeletePost(request);
    });

    // POST /api/social/posts/:postId/publish - Post to Instagram now
    router.post(prefix + "/posts/:postId/publish", [this](const Request& request) {
        return this->handlePostToInstagram(request);
    });

    // GET /api/social/schedule/team/:teamId - Get schedule templates for a team
    router.get(prefix + "/schedule/team/:teamId", [this](const Request& request) {
        return this->handleGetScheduleTemplates(request);
    });

    // POST /api/social/schedule/team/:teamId - Save schedule templates for a team
    router.post(prefix + "/schedule/team/:teamId", [this](const Request& request) {
        return this->handleSaveScheduleTemplates(request);
    });

    // POST /api/social/schedule/apply/:matchId/:teamId - Apply schedule to a match
    router.post(prefix + "/schedule/apply/:matchId/:teamId", [this](const Request& request) {
        return this->handleApplySchedule(request);
    });
}

std::string SocialController::escapeJson(const std::string& input) {
    std::ostringstream output;
    for (char c : input) {
        switch (c) {
            case '"': output << "\\\""; break;
            case '\\': output << "\\\\"; break;
            case '\b': output << "\\b"; break;
            case '\f': output << "\\f"; break;
            case '\n': output << "\\n"; break;
            case '\r': output << "\\r"; break;
            case '\t': output << "\\t"; break;
            default:
                if (c < 0x20) {
                    output << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<int>(c);
                } else {
                    output << c;
                }
        }
    }
    return output.str();
}

std::string SocialController::createJSONResponse(bool success, const std::string& message, const std::string& data) {
    std::ostringstream json;
    json << "{";
    json << "\"success\":" << (success ? "true" : "false") << ",";
    json << "\"message\":\"" << message << "\"";
    if (!data.empty()) {
        json << ",\"data\":" << data;
    }
    json << "}";
    return json.str();
}

// ---------- Post Types ----------

Response SocialController::handleGetPostTypes(const Request& request) {
    try {
        pqxx::result result = db_->query(
            "SELECT id, name, display_name, description, sort_order "
            "FROM social_post_types ORDER BY sort_order"
        );

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"name\":\"" << escapeJson(row["name"].c_str()) << "\",";
            json << "\"display_name\":\"" << escapeJson(row["display_name"].c_str()) << "\",";
            json << "\"description\":\"" << escapeJson(row["description"].c_str()) << "\",";
            json << "\"sort_order\":" << row["sort_order"].as<int>();
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Post types", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

// ---------- Match Posts ----------

Response SocialController::handleGetMatchPosts(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string matchId = extractMatchIdFromPath(path);
        std::string teamId = extractTeamIdFromPath(path);

        // Return all 4 post types with any existing post data joined in
        std::string query = R"(
            SELECT
                spt.id as post_type_id,
                spt.name as post_type,
                spt.display_name,
                spt.sort_order,
                sp.id as post_id,
                sp.image_path,
                sp.image_url,
                sp.caption,
                sp.status,
                sp.scheduled_at,
                sp.posted_at,
                sp.external_media_id,
                sp.error_message,
                sp.created_at,
                sp.updated_at
            FROM social_post_types spt
            LEFT JOIN social_posts sp ON sp.post_type_id = spt.id
                AND sp.match_id = )" + matchId + R"(
                AND sp.team_id = )" + teamId + R"(
                AND sp.platform = 'instagram'
            ORDER BY spt.sort_order
        )";

        pqxx::result result = db_->query(query);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"post_type_id\":" << row["post_type_id"].as<int>() << ",";
            json << "\"post_type\":\"" << escapeJson(row["post_type"].c_str()) << "\",";
            json << "\"display_name\":\"" << escapeJson(row["display_name"].c_str()) << "\",";
            json << "\"sort_order\":" << row["sort_order"].as<int>() << ",";
            json << "\"post_id\":" << (row["post_id"].is_null() ? "null" : std::to_string(row["post_id"].as<int>())) << ",";
            json << "\"image_path\":" << (row["image_path"].is_null() ? "null" : "\"" + escapeJson(row["image_path"].c_str()) + "\"") << ",";
            json << "\"image_url\":" << (row["image_url"].is_null() ? "null" : "\"" + escapeJson(row["image_url"].c_str()) + "\"") << ",";
            json << "\"caption\":" << (row["caption"].is_null() ? "null" : "\"" + escapeJson(row["caption"].c_str()) + "\"") << ",";
            json << "\"status\":" << (row["status"].is_null() ? "\"draft\"" : "\"" + escapeJson(row["status"].c_str()) + "\"") << ",";
            json << "\"scheduled_at\":" << (row["scheduled_at"].is_null() ? "null" : "\"" + std::string(row["scheduled_at"].c_str()) + "\"") << ",";
            json << "\"posted_at\":" << (row["posted_at"].is_null() ? "null" : "\"" + std::string(row["posted_at"].c_str()) + "\"") << ",";
            json << "\"external_media_id\":" << (row["external_media_id"].is_null() ? "null" : "\"" + escapeJson(row["external_media_id"].c_str()) + "\"") << ",";
            json << "\"error_message\":" << (row["error_message"].is_null() ? "null" : "\"" + escapeJson(row["error_message"].c_str()) + "\"");
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Match posts", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

// ---------- Team Calendar ----------

Response SocialController::handleGetTeamCalendar(const Request& request) {
    try {
        std::string teamId = extractTeamIdFromPath(request.getPath());

        // Get all upcoming matches for this team with their social post statuses
        std::string query =
            "SELECT "
            "  m.id as match_id, "
            "  m.title as match_title, "
            "  m.match_date, "
            "  m.match_time, "
            "  m.home_score, "
            "  m.away_score, "
            "  ht.name as home_team_name, "
            "  ht.logo_url as home_team_logo, "
            "  at2.name as away_team_name, "
            "  at2.logo_url as away_team_logo, "
            "  v.name as venue_name, "
            "  ms.name as match_status, "
            "  spt.id as post_type_id, "
            "  spt.name as post_type, "
            "  spt.display_name, "
            "  spt.sort_order, "
            "  sp.id as post_id, "
            "  sp.status as post_status, "
            "  sp.scheduled_at, "
            "  sp.posted_at, "
            "  sp.caption "
            "FROM matches m "
            "LEFT JOIN teams ht ON m.home_team_id = ht.id "
            "LEFT JOIN teams at2 ON m.away_team_id = at2.id "
            "LEFT JOIN venues v ON m.venue_id = v.id "
            "LEFT JOIN match_statuses ms ON m.match_status_id = ms.id "
            "CROSS JOIN social_post_types spt "
            "LEFT JOIN social_posts sp ON sp.match_id = m.id "
            "  AND sp.team_id = " + teamId + " "
            "  AND sp.post_type_id = spt.id "
            "  AND sp.platform = 'instagram' "
            "WHERE (m.home_team_id = " + teamId + " "
            "  OR m.away_team_id = " + teamId + ") "
            "  AND m.match_date >= CURRENT_DATE - interval '7 days' "
            "ORDER BY m.match_date ASC, m.match_time ASC, spt.sort_order ASC";

        pqxx::result result = db_->query(query);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"match_id\":" << row["match_id"].as<int>() << ",";
            json << "\"match_title\":" << (row["match_title"].is_null() ? "null" : "\"" + escapeJson(row["match_title"].c_str()) + "\"") << ",";
            json << "\"match_date\":\"" << row["match_date"].c_str() << "\",";
            json << "\"match_time\":" << (row["match_time"].is_null() ? "null" : "\"" + std::string(row["match_time"].c_str()) + "\"") << ",";
            json << "\"home_score\":" << (row["home_score"].is_null() ? "null" : std::to_string(row["home_score"].as<int>())) << ",";
            json << "\"away_score\":" << (row["away_score"].is_null() ? "null" : std::to_string(row["away_score"].as<int>())) << ",";
            json << "\"home_team_name\":" << (row["home_team_name"].is_null() ? "null" : "\"" + escapeJson(row["home_team_name"].c_str()) + "\"") << ",";
            json << "\"home_team_logo\":" << (row["home_team_logo"].is_null() ? "null" : "\"" + escapeJson(row["home_team_logo"].c_str()) + "\"") << ",";
            json << "\"away_team_name\":" << (row["away_team_name"].is_null() ? "null" : "\"" + escapeJson(row["away_team_name"].c_str()) + "\"") << ",";
            json << "\"away_team_logo\":" << (row["away_team_logo"].is_null() ? "null" : "\"" + escapeJson(row["away_team_logo"].c_str()) + "\"") << ",";
            json << "\"venue_name\":" << (row["venue_name"].is_null() ? "null" : "\"" + escapeJson(row["venue_name"].c_str()) + "\"") << ",";
            json << "\"match_status\":" << (row["match_status"].is_null() ? "null" : "\"" + escapeJson(row["match_status"].c_str()) + "\"") << ",";
            json << "\"post_type_id\":" << row["post_type_id"].as<int>() << ",";
            json << "\"post_type\":\"" << escapeJson(row["post_type"].c_str()) << "\",";
            json << "\"display_name\":\"" << escapeJson(row["display_name"].c_str()) << "\",";
            json << "\"sort_order\":" << row["sort_order"].as<int>() << ",";
            json << "\"post_id\":" << (row["post_id"].is_null() ? "null" : std::to_string(row["post_id"].as<int>())) << ",";
            json << "\"post_status\":" << (row["post_status"].is_null() ? "null" : "\"" + escapeJson(row["post_status"].c_str()) + "\"") << ",";
            json << "\"scheduled_at\":" << (row["scheduled_at"].is_null() ? "null" : "\"" + std::string(row["scheduled_at"].c_str()) + "\"") << ",";
            json << "\"posted_at\":" << (row["posted_at"].is_null() ? "null" : "\"" + std::string(row["posted_at"].c_str()) + "\"") << ",";
            json << "\"caption\":" << (row["caption"].is_null() ? "null" : "\"" + escapeJson(row["caption"].c_str()) + "\"");
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Team calendar", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleCreateOrUpdatePost(const Request& request) {
    try {
        std::string body = request.getBody();
        std::string matchId = extractJsonField(body, "match_id");
        std::string teamId = extractJsonField(body, "team_id");
        std::string postTypeId = extractJsonField(body, "post_type_id");
        std::string caption = extractJsonField(body, "caption");
        std::string imagePath = extractJsonField(body, "image_path");
        std::string imageUrl = extractJsonField(body, "image_url");
        std::string status = extractJsonField(body, "status");
        std::string scheduledAt = extractJsonField(body, "scheduled_at");

        if (matchId.empty() || teamId.empty() || postTypeId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "match_id, team_id, and post_type_id are required"));
        }

        if (status.empty()) status = "draft";

        // Upsert
        std::string query = R"(
            INSERT INTO social_posts (match_id, team_id, post_type_id, platform, caption, image_path, image_url, status, scheduled_at)
            VALUES ()" + matchId + ", " + teamId + ", " + postTypeId + R"(, 'instagram',
                )" + (caption.empty() ? "NULL" : "'" + escapeJson(caption) + "'") + R"(,
                )" + (imagePath.empty() ? "NULL" : "'" + escapeJson(imagePath) + "'") + R"(,
                )" + (imageUrl.empty() ? "NULL" : "'" + escapeJson(imageUrl) + "'") + R"(,
                ')" + escapeJson(status) + R"(',
                )" + (scheduledAt.empty() ? "NULL" : "'" + escapeJson(scheduledAt) + "'") + R"()
            ON CONFLICT (match_id, team_id, post_type_id, platform)
            DO UPDATE SET
                caption = EXCLUDED.caption,
                image_path = EXCLUDED.image_path,
                image_url = EXCLUDED.image_url,
                status = EXCLUDED.status,
                scheduled_at = EXCLUDED.scheduled_at,
                updated_at = NOW()
            RETURNING id
        )";

        pqxx::result result = db_->query(query);

        if (!result.empty()) {
            int postId = result[0]["id"].as<int>();
            return Response(HttpStatus::OK,
                createJSONResponse(true, "Post saved", "{\"id\":" + std::to_string(postId) + "}"));
        }

        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to save post"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleDeletePost(const Request& request) {
    try {
        std::string postId = extractPostIdFromPath(request.getPath());
        db_->query("DELETE FROM social_posts WHERE id = " + postId);
        return Response(HttpStatus::OK, createJSONResponse(true, "Post deleted"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handlePostToInstagram(const Request& request) {
    // This endpoint marks the post as ready for publish.
    // Actual Instagram API call happens from the Node.js side
    // (post-to-instagram.js) which checks for posts with status='publishing'.
    try {
        std::string postId = extractPostIdFromPath(request.getPath());

        db_->query(
            "UPDATE social_posts SET status = 'publishing', updated_at = NOW() "
            "WHERE id = " + postId
        );

        // Return the post data so the frontend can trigger the Node posting
        pqxx::result result = db_->query(
            "SELECT sp.*, spt.name as post_type "
            "FROM social_posts sp "
            "JOIN social_post_types spt ON spt.id = sp.post_type_id "
            "WHERE sp.id = " + postId
        );

        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                createJSONResponse(false, "Post not found"));
        }

        const auto& row = result[0];
        std::ostringstream json;
        json << "{";
        json << "\"id\":" << row["id"].as<int>() << ",";
        json << "\"image_url\":" << (row["image_url"].is_null() ? "null" : "\"" + escapeJson(row["image_url"].c_str()) + "\"") << ",";
        json << "\"caption\":" << (row["caption"].is_null() ? "null" : "\"" + escapeJson(row["caption"].c_str()) + "\"") << ",";
        json << "\"post_type\":\"" << escapeJson(row["post_type"].c_str()) << "\",";
        json << "\"status\":\"publishing\"";
        json << "}";

        return Response(HttpStatus::OK, createJSONResponse(true, "Post marked for publishing", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

// ---------- Schedule Templates ----------

Response SocialController::handleGetScheduleTemplates(const Request& request) {
    try {
        std::string teamId = extractTeamIdFromPath(request.getPath());

        std::string query = R"(
            SELECT
                spt.id as post_type_id,
                spt.name as post_type,
                spt.display_name,
                spt.sort_order,
                sst.id as template_id,
                COALESCE(sst.days_before, 0) as days_before,
                COALESCE(sst.post_time::text, '10:00') as post_time,
                COALESCE(sst.enabled, false) as enabled
            FROM social_post_types spt
            LEFT JOIN social_schedule_templates sst ON sst.post_type_id = spt.id
                AND sst.team_id = )" + teamId + R"(
                AND sst.platform = 'instagram'
            ORDER BY spt.sort_order
        )";

        pqxx::result result = db_->query(query);

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"post_type_id\":" << row["post_type_id"].as<int>() << ",";
            json << "\"post_type\":\"" << escapeJson(row["post_type"].c_str()) << "\",";
            json << "\"display_name\":\"" << escapeJson(row["display_name"].c_str()) << "\",";
            json << "\"sort_order\":" << row["sort_order"].as<int>() << ",";
            json << "\"template_id\":" << (row["template_id"].is_null() ? "null" : std::to_string(row["template_id"].as<int>())) << ",";
            json << "\"days_before\":" << row["days_before"].as<int>() << ",";
            json << "\"post_time\":\"" << escapeJson(row["post_time"].c_str()) << "\",";
            json << "\"enabled\":" << (row["enabled"].as<bool>() ? "true" : "false");
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Schedule templates", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleSaveScheduleTemplates(const Request& request) {
    try {
        std::string teamId = extractTeamIdFromPath(request.getPath());

        // Expect JSON array: [{post_type_id, days_before, post_time, enabled}, ...]
        // Parse manually since we don't have nlohmann/json in this controller pattern.
        // We'll accept individual fields for simplicity:
        std::string body = request.getBody();
        std::string postTypeId = extractJsonField(body, "post_type_id");
        std::string daysBefore = extractJsonField(body, "days_before");
        std::string postTime = extractJsonField(body, "post_time");
        std::string enabled = extractJsonField(body, "enabled");

        if (postTypeId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "post_type_id is required"));
        }

        if (daysBefore.empty()) daysBefore = "0";
        if (postTime.empty()) postTime = "10:00";
        if (enabled.empty()) enabled = "true";

        std::string query = R"(
            INSERT INTO social_schedule_templates (team_id, post_type_id, platform, days_before, post_time, enabled)
            VALUES ()" + teamId + ", " + postTypeId + R"(, 'instagram', )" + daysBefore + R"(, ')" + escapeJson(postTime) + R"(', )" + enabled + R"()
            ON CONFLICT (team_id, post_type_id, platform)
            DO UPDATE SET
                days_before = EXCLUDED.days_before,
                post_time = EXCLUDED.post_time,
                enabled = EXCLUDED.enabled,
                updated_at = NOW()
            RETURNING id
        )";

        pqxx::result result = db_->query(query);

        return Response(HttpStatus::OK, createJSONResponse(true, "Schedule template saved"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleApplySchedule(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string matchId = extractMatchIdFromPath(path);
        std::string teamId = extractTeamIdFromPath(path);

        // Get match date
        pqxx::result matchResult = db_->query(
            "SELECT match_date, match_time FROM matches WHERE id = " + matchId
        );

        if (matchResult.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                createJSONResponse(false, "Match not found"));
        }

        std::string matchDate = matchResult[0]["match_date"].c_str();

        // Get enabled templates for this team
        std::string query = R"(
            SELECT sst.post_type_id, sst.days_before, sst.post_time
            FROM social_schedule_templates sst
            WHERE sst.team_id = )" + teamId + R"(
              AND sst.platform = 'instagram'
              AND sst.enabled = true
        )";

        pqxx::result templates = db_->query(query);

        int created = 0;
        for (const auto& row : templates) {
            int postTypeId = row["post_type_id"].as<int>();
            int daysBefore = row["days_before"].as<int>();
            std::string postTime = row["post_time"].c_str();

            // Calculate scheduled_at: match_date - days_before + post_time
            std::string insertQuery = R"(
                INSERT INTO social_posts (match_id, team_id, post_type_id, platform, status, scheduled_at)
                VALUES ()" + matchId + ", " + teamId + ", " + std::to_string(postTypeId) + R"(, 'instagram', 'scheduled',
                    (')" + matchDate + R"('::date - interval ')" + std::to_string(daysBefore) + R"( days')::date + ')" + escapeJson(postTime) + R"('::time
                )
                ON CONFLICT (match_id, team_id, post_type_id, platform)
                DO UPDATE SET
                    scheduled_at = EXCLUDED.scheduled_at,
                    status = CASE WHEN social_posts.status = 'posted' THEN 'posted' ELSE 'scheduled' END,
                    updated_at = NOW()
            )";

            db_->query(insertQuery);
            created++;
        }

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Schedule applied: " + std::to_string(created) + " posts scheduled"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}
