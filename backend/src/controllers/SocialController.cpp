#include "SocialController.h"
#include <sstream>
#include <iostream>
#include <iomanip>
#include <regex>
#include <fstream>
#include <vector>
#include <cstdlib>
#include <thread>
#include <chrono>
#include <curl/curl.h>
#include <sys/stat.h>

static size_t SocialWriteCallback(void* contents, size_t size, size_t nmemb, std::string* out) {
    out->append(static_cast<char*>(contents), size * nmemb);
    return size * nmemb;
}

static std::string base64Decode(const std::string& encoded) {
    static const std::string chars =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::vector<int> T(256, -1);
    for (int i = 0; i < 64; i++) T[static_cast<unsigned char>(chars[i])] = i;

    std::string decoded;
    int val = 0, valb = -8;
    for (unsigned char c : encoded) {
        if (T[c] == -1) break;
        val = (val << 6) + T[c];
        valb += 6;
        if (valb >= 0) {
            decoded.push_back(static_cast<char>((val >> valb) & 0xFF));
            valb -= 8;
        }
    }
    return decoded;
}

SocialController::SocialController() {
    db_ = Database::getInstance();
}

SocialController::~SocialController() {
    stopScheduler();
}

void SocialController::startScheduler() {
    if (schedulerRunning_) return;
    schedulerRunning_ = true;
    schedulerThread_ = std::thread(&SocialController::schedulerLoop, this);
    schedulerThread_.detach();
    std::cout << "⏰ Social post scheduler started (checks every 60s)" << std::endl;
}

void SocialController::stopScheduler() {
    schedulerRunning_ = false;
}

void SocialController::schedulerLoop() {
    while (schedulerRunning_) {
        try {
            checkScheduledPosts();
        } catch (const std::exception& e) {
            std::cerr << "⏰ Scheduler error: " << e.what() << std::endl;
        }
        // Sleep 60 seconds, checking every second so we can stop quickly
        for (int i = 0; i < 60 && schedulerRunning_; i++) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
    }
}

void SocialController::checkScheduledPosts() {
    ensurePromotionalPostsSchema();

    // Find promo posts that are due for publishing
    pqxx::result rows = db_->query(
        "SELECT id FROM promotional_posts "
        "WHERE status = 'scheduled' AND scheduled_at <= NOW() "
        "AND image_url IS NOT NULL "
        "ORDER BY scheduled_at ASC"
    );

    for (const auto& row : rows) {
        std::string promoId = std::to_string(row["id"].as<int>());
        std::cout << "⏰ Auto-publishing scheduled promo #" << promoId << std::endl;
        std::string errorMsg;
        bool ok = publishPromoById(promoId, errorMsg);
        if (ok) {
            std::cout << "⏰ ✅ Promo #" << promoId << " auto-published successfully" << std::endl;
        } else {
            std::cerr << "⏰ ❌ Promo #" << promoId << " auto-publish failed: " << errorMsg << std::endl;
        }
    }
}

void SocialController::ensurePromotionalPostsSchema() {
    db_->query(
        "CREATE TABLE IF NOT EXISTS promotional_posts ("
        "id SERIAL PRIMARY KEY, "
        "title VARCHAR(200) NOT NULL, "
        "caption TEXT, "
        "image_path TEXT, "
        "image_url TEXT, "
        "status VARCHAR(20) NOT NULL DEFAULT 'draft', "
        "scheduled_at TIMESTAMPTZ, "
        "posted_at TIMESTAMPTZ, "
        "external_media_id VARCHAR(100), "
        "error_message TEXT, "
        "created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), "
        "updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()"
        ")"
    );

    db_->query(
        "CREATE INDEX IF NOT EXISTS idx_promotional_posts_status "
        "ON promotional_posts(status)"
    );

    db_->query("ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS heading VARCHAR(200)");
    db_->query("ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS subheading VARCHAR(200)");
    db_->query("ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS body_lines TEXT");
    db_->query("ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS footer VARCHAR(200)");
    db_->query("ALTER TABLE promotional_posts ADD COLUMN IF NOT EXISTS overlay_logos TEXT");
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

    // POST /api/social/posts/:postId/media - Upload media (base64 video/image)
    router.post(prefix + "/posts/:postId/media", [this](const Request& request) {
        return this->handleUploadMedia(request);
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

    // ---------- Holiday Posts ----------

    // GET /api/social/holidays - List all holiday posts
    router.get(prefix + "/holidays", [this](const Request& request) {
        return this->handleGetHolidayPosts(request);
    });

    // POST /api/social/holidays - Create or update a holiday post
    router.post(prefix + "/holidays", [this](const Request& request) {
        return this->handleSaveHolidayPost(request);
    });

    // POST /api/social/holidays/:holidayId/media - Upload media for holiday post
    router.post(prefix + "/holidays/:holidayId/media", [this](const Request& request) {
        return this->handleUploadHolidayMedia(request);
    });

    // POST /api/social/holidays/:holidayId/publish - Publish holiday post to Instagram
    router.post(prefix + "/holidays/:holidayId/publish", [this](const Request& request) {
        return this->handlePublishHolidayPost(request);
    });

    // ---------- Promotional Posts ----------

    // GET /api/social/promos - List all promotional posts
    router.get(prefix + "/promos", [this](const Request& request) {
        return this->handleGetPromoPosts(request);
    });

    // POST /api/social/promos - Create or update a promo post
    router.post(prefix + "/promos", [this](const Request& request) {
        return this->handleSavePromoPost(request);
    });

    // POST /api/social/promos/:promoId/media - Upload media for promo post
    router.post(prefix + "/promos/:promoId/media", [this](const Request& request) {
        return this->handleUploadPromoMedia(request);
    });

    // POST /api/social/promos/:promoId/publish - Publish promo post to Instagram
    router.post(prefix + "/promos/:promoId/publish", [this](const Request& request) {
        return this->handlePublishPromoPost(request);
    });

    // ---------- Content Posts (User-uploaded media) ----------

    // GET /api/social/content - List all content posts
    router.get(prefix + "/content", [this](const Request& request) {
        return this->handleGetContentPosts(request);
    });

    // POST /api/social/content - Create or update a content post
    router.post(prefix + "/content", [this](const Request& request) {
        return this->handleSaveContentPost(request);
    });

    // POST /api/social/content/:contentId/media - Upload media for content post
    router.post(prefix + "/content/:contentId/media", [this](const Request& request) {
        return this->handleUploadContentMedia(request);
    });

    // POST /api/social/content/:contentId/publish - Publish content post to Instagram
    router.post(prefix + "/content/:contentId/publish", [this](const Request& request) {
        return this->handlePublishContentPost(request);
    });

    // DELETE /api/social/content/:contentId - Delete a content post
    router.del(prefix + "/content/:contentId", [this](const Request& request) {
        return this->handleDeleteContentPost(request);
    });

    // ---------- Google Drive Media Browser ----------

    // GET /api/social/drive/media - List photos/videos from Google Drive
    router.get(prefix + "/drive/media", [this](const Request& request) {
        return this->handleListDriveMedia(request);
    });

    // GET /api/social/drive/download?fileId=xxx - Download a file from Drive
    router.get(prefix + "/drive/download", [this](const Request& request) {
        return this->handleDownloadDriveFile(request);
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
                if (static_cast<unsigned char>(c) < 0x20) {
                    output << "\\u" << std::hex << std::setw(4) << std::setfill('0') << static_cast<unsigned int>(static_cast<unsigned char>(c));
                } else {
                    output << c;
                }
        }
    }
    return output.str();
}

std::string SocialController::escapeSql(const std::string& input) {
    std::string output;
    output.reserve(input.size());
    for (char c : input) {
        if (c == '\'') output += "''";
        else output += c;
    }
    return output;
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
            "  m.home_team_id, "
            "  m.away_team_id, "
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
            json << "\"home_team_id\":" << row["home_team_id"].as<int>() << ",";
            json << "\"away_team_id\":" << row["away_team_id"].as<int>() << ",";
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
                )" + (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + R"(,
                )" + (imagePath.empty() ? "NULL" : "'" + escapeSql(imagePath) + "'") + R"(,
                )" + (imageUrl.empty() ? "NULL" : "'" + escapeSql(imageUrl) + "'") + R"(,
                ')" + escapeSql(status) + R"(',
                )" + (scheduledAt.empty() ? "NULL" : "'" + escapeSql(scheduledAt) + "'") + R"()
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

Response SocialController::handleUploadMedia(const Request& request) {
    try {
        std::string postId = extractPostIdFromPath(request.getPath());
        if (postId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing post ID"));
        }

        std::string body = request.getBody();

        // Extract "data" field manually (efficient for large base64 payloads)
        size_t keyPos = body.find("\"data\"");
        if (keyPos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing 'data' field"));
        }
        size_t colonPos = body.find(':', keyPos + 6);
        size_t quoteStart = body.find('"', colonPos + 1);
        size_t quoteEnd = body.find('"', quoteStart + 1);
        if (quoteStart == std::string::npos || quoteEnd == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid data format"));
        }
        std::string dataValue = body.substr(quoteStart + 1, quoteEnd - quoteStart - 1);

        // Detect media type from data URL prefix
        bool isVideo = (dataValue.find("data:video/") == 0);
        std::string mediaType = isVideo ? "video" : "image";

        // Strip data URL prefix (e.g. "data:image/png;base64," or "data:video/webm;base64,")
        std::string b64Data = dataValue;
        size_t commaPos = b64Data.find(',');
        if (commaPos != std::string::npos) {
            b64Data = b64Data.substr(commaPos + 1);
        }

        // Decode base64
        std::string mediaBytes = base64Decode(b64Data);
        if (mediaBytes.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Failed to decode media data"));
        }

        // Ensure directory exists
        const std::string mediaDir = "/app/images/posts";
        mkdir(mediaDir.c_str(), 0755);

        if (isVideo) {
            // Save WebM to temp file
            std::string webmFile = mediaDir + "/post_" + postId + ".webm";
            std::string mp4File = mediaDir + "/post_" + postId + ".mp4";
            {
                std::ofstream outFile(webmFile, std::ios::binary);
                if (!outFile.is_open()) {
                    return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Failed to write video file"));
                }
                outFile.write(mediaBytes.data(), mediaBytes.size());
                outFile.close();
            }

            // Convert WebM to MP4 with ffmpeg (Instagram-compatible)
            std::string ffmpegCmd = "ffmpeg -y -i " + webmFile +
                " -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p"
                " -movflags +faststart -an " + mp4File + " 2>&1";
            std::cout << "🎬 Converting video: " << ffmpegCmd << std::endl;
            int ffResult = system(ffmpegCmd.c_str());
            // Remove temp WebM
            std::remove(webmFile.c_str());

            if (ffResult != 0) {
                return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                    createJSONResponse(false, "FFmpeg conversion failed"));
            }

            std::string videoFilename = "post_" + postId + ".mp4";
            std::string videoPublicUrl = "https://footballhome.org/images/posts/" + videoFilename;

            // Also save a poster image (first frame)
            std::string posterFile = mediaDir + "/post_" + postId + ".jpg";
            std::string posterCmd = "ffmpeg -y -i " + mp4File +
                " -vframes 1 -q:v 2 " + posterFile + " 2>&1";
            system(posterCmd.c_str());
            std::string imageFilename = "post_" + postId + ".jpg";
            std::string imagePublicUrl = "https://footballhome.org/images/posts/" + imageFilename;

            // Update DB
            db_->query(
                "UPDATE social_posts SET video_path = '" + escapeSql(videoFilename) +
                "', video_url = '" + escapeSql(videoPublicUrl) +
                "', image_path = '" + escapeSql(imageFilename) +
                "', image_url = '" + escapeSql(imagePublicUrl) +
                "', media_type = 'video'"
                ", updated_at = NOW() WHERE id = " + postId
            );

            std::cout << "🎬 Video uploaded for post " << postId << ": " << mp4File << std::endl;

            return Response(HttpStatus::OK,
                createJSONResponse(true, "Video uploaded and converted",
                    "{\"video_url\":\"" + escapeJson(videoPublicUrl) +
                    "\",\"image_url\":\"" + escapeJson(imagePublicUrl) +
                    "\",\"media_type\":\"video\"}"));
        } else {
            // Image upload (existing flow)
            std::string filename = "post_" + postId + ".jpg";
            std::string filepath = mediaDir + "/" + filename;
            std::ofstream outFile(filepath, std::ios::binary);
            if (!outFile.is_open()) {
                return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                    createJSONResponse(false, "Failed to write image file"));
            }
            outFile.write(mediaBytes.data(), mediaBytes.size());
            outFile.close();

            std::string publicUrl = "https://footballhome.org/images/posts/" + filename;

            db_->query(
                "UPDATE social_posts SET image_path = '" + escapeSql(filename) +
                "', image_url = '" + escapeSql(publicUrl) +
                "', media_type = 'image'"
                ", updated_at = NOW() WHERE id = " + postId
            );

            std::cout << "📸 Media uploaded for post " << postId << ": " << filepath << std::endl;

            return Response(HttpStatus::OK,
                createJSONResponse(true, "Media uploaded",
                    "{\"image_url\":\"" + escapeJson(publicUrl) + "\",\"filename\":\"" + escapeJson(filename) + "\",\"media_type\":\"image\"}"));
        }
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

std::string SocialController::urlEncode(CURL* curl, const std::string& value) {
    char* encoded = curl_easy_escape(curl, value.c_str(), static_cast<int>(value.length()));
    if (!encoded) return value;
    std::string result(encoded);
    curl_free(encoded);
    return result;
}

std::string SocialController::httpGet(const std::string& url) {
    std::string response;
    CURL* curl = curl_easy_init();
    if (!curl) return "";
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, SocialWriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        std::cerr << "❌ curl GET failed: " << curl_easy_strerror(res) << std::endl;
    }
    curl_easy_cleanup(curl);
    return response;
}

std::string SocialController::httpPost(const std::string& url, const std::string& postData) {
    std::string response;
    CURL* curl = curl_easy_init();
    if (!curl) return "";

    std::cout << "🌐 curl POST to: " << url << std::endl;

    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, SocialWriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_DNS_SERVERS, "8.8.8.8,8.8.4.4");

    CURLcode res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        std::cerr << "❌ curl POST failed: " << curl_easy_strerror(res)
                  << " (url=" << url << ")" << std::endl;
    }
    curl_easy_cleanup(curl);
    return response;
}

Response SocialController::handlePostToInstagram(const Request& request) {
    try {
        std::string postId = extractPostIdFromPath(request.getPath());
        if (postId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing post ID"));
        }

        // Get post from DB
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
        std::string imageUrl = row["image_url"].is_null() ? "" : row["image_url"].c_str();
        std::string videoUrl = row["video_url"].is_null() ? "" : row["video_url"].c_str();
        std::string caption = row["caption"].is_null() ? "" : row["caption"].c_str();
        std::string mediaType = row["media_type"].is_null() ? "image" : row["media_type"].c_str();

        if (mediaType == "video" && videoUrl.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "No video uploaded for this post. Upload media first."));
        }
        if (mediaType == "image" && imageUrl.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "No image uploaded for this post. Upload media first."));
        }

        // Get Instagram credentials from environment
        const char* accessToken = std::getenv("INSTAGRAM_ACCESS_TOKEN");
        const char* userId = std::getenv("INSTAGRAM_USER_ID");
        if (!accessToken || std::string(accessToken).empty()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "INSTAGRAM_ACCESS_TOKEN not configured"));
        }
        std::string igUserId = userId ? std::string(userId) : "26233831926285183";
        std::string igToken(accessToken);
        std::string apiBase = "https://graph.instagram.com/v21.0";

        // Mark as publishing
        db_->query(
            "UPDATE social_posts SET status = 'publishing', updated_at = NOW() "
            "WHERE id = " + postId
        );

        // Step 1: Create media container (URL-encode values for form POST)
        CURL* encoderCurl = curl_easy_init();
        std::string createUrl = apiBase + "/" + igUserId + "/media";
        std::string createData;
        if (mediaType == "video") {
            // Instagram Reels API
            createData = "media_type=REELS"
                "&video_url=" + urlEncode(encoderCurl, videoUrl) +
                "&caption=" + urlEncode(encoderCurl, caption) +
                "&access_token=" + urlEncode(encoderCurl, igToken);
            std::cout << "📤 Instagram: Creating REELS container for post " << postId << std::endl;
        } else {
            createData = "image_url=" + urlEncode(encoderCurl, imageUrl) +
                "&caption=" + urlEncode(encoderCurl, caption) +
                "&access_token=" + urlEncode(encoderCurl, igToken);
            std::cout << "📤 Instagram: Creating image container for post " << postId << std::endl;
        }
        curl_easy_cleanup(encoderCurl);
        std::string createResponse = httpPost(createUrl, createData);
        std::cout << "📤 Instagram create response: " << createResponse << std::endl;

        std::string creationId = extractJsonField(createResponse, "id");
        if (creationId.empty()) {
            // Check for error
            std::string errorMsg = extractJsonField(createResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to create media container";
            db_->query(
                "UPDATE social_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + postId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        // Step 1.5: Poll for media container to be ready (Instagram needs processing time)
        // Video (Reels) takes longer to process — use more attempts with longer interval
        int maxAttempts = (mediaType == "video") ? 30 : 10;
        int pollInterval = (mediaType == "video") ? 5 : 3;
        std::string statusUrl = apiBase + "/" + creationId + "?fields=status_code&access_token=" + igToken;
        for (int attempt = 0; attempt < maxAttempts; attempt++) {
            std::this_thread::sleep_for(std::chrono::seconds(pollInterval));
            std::string statusResp = httpGet(statusUrl);
            std::string statusCode = extractJsonField(statusResp, "status_code");
            std::cout << "📤 Instagram: Container status (attempt " << attempt+1 << "/" << maxAttempts << "): " << statusCode << std::endl;
            if (statusCode == "FINISHED") break;
            if (statusCode == "ERROR") {
                db_->query("UPDATE social_posts SET status = 'error', error_message = 'Instagram media processing failed', updated_at = NOW() WHERE id = " + postId);
                return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Instagram media processing failed"));
            }
        }

        // Step 2: Publish the container
        std::string publishUrl = apiBase + "/" + igUserId + "/media_publish";
        std::string publishData = "creation_id=" + creationId +
            "&access_token=" + igToken;

        std::cout << "📤 Instagram: Publishing container " << creationId << std::endl;
        std::string publishResponse = httpPost(publishUrl, publishData);
        std::cout << "📤 Instagram publish response: " << publishResponse << std::endl;

        std::string mediaId = extractJsonField(publishResponse, "id");
        if (mediaId.empty()) {
            std::string errorMsg = extractJsonField(publishResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to publish to Instagram";
            db_->query(
                "UPDATE social_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + postId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        // Success - update DB
        db_->query(
            "UPDATE social_posts SET status = 'posted', external_media_id = '" +
            escapeSql(mediaId) + "', posted_at = NOW(), error_message = NULL, "
            "updated_at = NOW() WHERE id = " + postId
        );

        std::cout << "✅ Instagram: Post " << postId << " published! Media ID: " << mediaId << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Posted to Instagram!",
                "{\"media_id\":\"" + escapeJson(mediaId) + "\"}"));
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
            VALUES ()" + teamId + ", " + postTypeId + R"(, 'instagram', )" + daysBefore + R"(, ')" + escapeSql(postTime) + R"(', )" + enabled + R"()
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
                    (')" + matchDate + R"('::date - interval ')" + std::to_string(daysBefore) + R"( days')::date + ')" + escapeSql(postTime) + R"('::time
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

// ---------- Holiday Posts ----------

std::string SocialController::extractHolidayIdFromPath(const std::string& path) {
    std::regex r(R"(/api/social/holidays/(\d+))");
    std::smatch m;
    if (std::regex_search(path, m, r)) {
        return m[1].str();
    }
    return "";
}

Response SocialController::handleGetHolidayPosts(const Request& request) {
    try {
        pqxx::result result = db_->query(
            "SELECT id, holiday_name, holiday_date, caption, image_path, image_url, "
            "status, scheduled_at, posted_at, external_media_id, error_message, "
            "created_at, updated_at "
            "FROM holiday_posts ORDER BY holiday_date DESC"
        );

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"holiday_name\":\"" << escapeJson(row["holiday_name"].c_str()) << "\",";
            json << "\"holiday_date\":\"" << row["holiday_date"].c_str() << "\",";
            json << "\"caption\":" << (row["caption"].is_null() ? "null" : "\"" + escapeJson(row["caption"].c_str()) + "\"") << ",";
            json << "\"image_path\":" << (row["image_path"].is_null() ? "null" : "\"" + escapeJson(row["image_path"].c_str()) + "\"") << ",";
            json << "\"image_url\":" << (row["image_url"].is_null() ? "null" : "\"" + escapeJson(row["image_url"].c_str()) + "\"") << ",";
            json << "\"status\":\"" << escapeJson(row["status"].c_str()) << "\",";
            json << "\"scheduled_at\":" << (row["scheduled_at"].is_null() ? "null" : "\"" + std::string(row["scheduled_at"].c_str()) + "\"") << ",";
            json << "\"posted_at\":" << (row["posted_at"].is_null() ? "null" : "\"" + std::string(row["posted_at"].c_str()) + "\"") << ",";
            json << "\"external_media_id\":" << (row["external_media_id"].is_null() ? "null" : "\"" + escapeJson(row["external_media_id"].c_str()) + "\"") << ",";
            json << "\"error_message\":" << (row["error_message"].is_null() ? "null" : "\"" + escapeJson(row["error_message"].c_str()) + "\"");
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Holiday posts", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleSaveHolidayPost(const Request& request) {
    try {
        std::string body = request.getBody();
        std::string holidayName = extractJsonField(body, "holiday_name");
        std::string holidayDate = extractJsonField(body, "holiday_date");
        std::string caption = extractJsonField(body, "caption");
        std::string status = extractJsonField(body, "status");
        std::string scheduledAt = extractJsonField(body, "scheduled_at");

        if (holidayName.empty() || holidayDate.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "holiday_name and holiday_date are required"));
        }

        if (status.empty()) status = "draft";

        std::string query = R"(
            INSERT INTO holiday_posts (holiday_name, holiday_date, caption, status, scheduled_at)
            VALUES (')" + escapeSql(holidayName) + "', '" + escapeSql(holidayDate) + R"(',
                )" + (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + R"(,
                ')" + escapeSql(status) + R"(',
                )" + (scheduledAt.empty() ? "NULL" : "'" + escapeSql(scheduledAt) + "'") + R"()
            ON CONFLICT (holiday_name, holiday_date)
            DO UPDATE SET
                caption = EXCLUDED.caption,
                status = EXCLUDED.status,
                scheduled_at = EXCLUDED.scheduled_at,
                updated_at = NOW()
            RETURNING id
        )";

        pqxx::result result = db_->query(query);

        if (!result.empty()) {
            int id = result[0]["id"].as<int>();
            return Response(HttpStatus::OK,
                createJSONResponse(true, "Holiday post saved", "{\"id\":" + std::to_string(id) + "}"));
        }

        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to save holiday post"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleUploadHolidayMedia(const Request& request) {
    try {
        std::string holidayId = extractHolidayIdFromPath(request.getPath());
        if (holidayId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing holiday ID"));
        }

        std::string body = request.getBody();

        size_t keyPos = body.find("\"data\"");
        if (keyPos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing 'data' field"));
        }
        size_t colonPos = body.find(':', keyPos + 6);
        size_t quoteStart = body.find('"', colonPos + 1);
        size_t quoteEnd = body.find('"', quoteStart + 1);
        if (quoteStart == std::string::npos || quoteEnd == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid data format"));
        }
        std::string dataValue = body.substr(quoteStart + 1, quoteEnd - quoteStart - 1);

        std::string b64Data = dataValue;
        size_t commaPos = b64Data.find(',');
        if (commaPos != std::string::npos) {
            b64Data = b64Data.substr(commaPos + 1);
        }

        std::string imageBytes = base64Decode(b64Data);
        if (imageBytes.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Failed to decode image data"));
        }

        const std::string imageDir = "/app/images/posts";
        mkdir(imageDir.c_str(), 0755);

        std::string filename = "holiday_" + holidayId + ".jpg";
        std::string filepath = imageDir + "/" + filename;
        std::ofstream outFile(filepath, std::ios::binary);
        if (!outFile.is_open()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to write image file"));
        }
        outFile.write(imageBytes.data(), imageBytes.size());
        outFile.close();

        std::string publicUrl = "https://footballhome.org/images/posts/" + filename;

        db_->query(
            "UPDATE holiday_posts SET image_path = '" + escapeSql(filename) +
            "', image_url = '" + escapeSql(publicUrl) +
            "', updated_at = NOW() WHERE id = " + holidayId
        );

        std::cout << "📸 Holiday media uploaded for " << holidayId << ": " << filepath << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Media uploaded",
                "{\"image_url\":\"" + escapeJson(publicUrl) + "\",\"filename\":\"" + escapeJson(filename) + "\"}"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handlePublishHolidayPost(const Request& request) {
    try {
        std::string holidayId = extractHolidayIdFromPath(request.getPath());
        if (holidayId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing holiday ID"));
        }

        pqxx::result result = db_->query(
            "SELECT * FROM holiday_posts WHERE id = " + holidayId
        );

        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                createJSONResponse(false, "Holiday post not found"));
        }

        const auto& row = result[0];
        std::string imageUrl = row["image_url"].is_null() ? "" : row["image_url"].c_str();
        std::string caption = row["caption"].is_null() ? "" : row["caption"].c_str();

        if (imageUrl.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "No image uploaded. Upload media first."));
        }

        const char* accessToken = std::getenv("INSTAGRAM_ACCESS_TOKEN");
        const char* userId = std::getenv("INSTAGRAM_USER_ID");
        if (!accessToken || std::string(accessToken).empty()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "INSTAGRAM_ACCESS_TOKEN not configured"));
        }
        std::string igUserId = userId ? std::string(userId) : "26233831926285183";
        std::string igToken(accessToken);
        std::string apiBase = "https://graph.instagram.com/v21.0";

        db_->query(
            "UPDATE holiday_posts SET status = 'publishing', updated_at = NOW() "
            "WHERE id = " + holidayId
        );

        // Step 1: Create media container (URL-encode values for form POST)
        CURL* encoderCurl = curl_easy_init();
        std::string createUrl = apiBase + "/" + igUserId + "/media";
        std::string createData = "image_url=" + urlEncode(encoderCurl, imageUrl) +
            "&caption=" + urlEncode(encoderCurl, caption) +
            "&access_token=" + urlEncode(encoderCurl, igToken);
        curl_easy_cleanup(encoderCurl);

        std::cout << "📤 Instagram: Creating media container for holiday " << holidayId << std::endl;
        std::string createResponse = httpPost(createUrl, createData);
        std::cout << "📤 Instagram create response: " << createResponse << std::endl;

        std::string creationId = extractJsonField(createResponse, "id");
        if (creationId.empty()) {
            std::string errorMsg = extractJsonField(createResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to create media container";
            db_->query(
                "UPDATE holiday_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + holidayId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        // Step 1.5: Poll for media container to be ready (Instagram needs processing time)
        std::string statusUrl = apiBase + "/" + creationId + "?fields=status_code&access_token=" + igToken;
        for (int attempt = 0; attempt < 10; attempt++) {
            std::this_thread::sleep_for(std::chrono::seconds(3));
            std::string statusResp = httpGet(statusUrl);
            std::string statusCode = extractJsonField(statusResp, "status_code");
            std::cout << "📤 Instagram: Container status (attempt " << attempt+1 << "): " << statusCode << std::endl;
            if (statusCode == "FINISHED") break;
            if (statusCode == "ERROR") {
                db_->query("UPDATE holiday_posts SET status = 'error', error_message = 'Instagram media processing failed', updated_at = NOW() WHERE id = " + holidayId);
                return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Instagram media processing failed"));
            }
        }

        // Step 2: Publish the container
        std::string publishUrl = apiBase + "/" + igUserId + "/media_publish";
        std::string publishData = "creation_id=" + creationId +
            "&access_token=" + igToken;

        std::cout << "📤 Instagram: Publishing holiday container " << creationId << std::endl;
        std::string publishResponse = httpPost(publishUrl, publishData);
        std::cout << "📤 Instagram publish response: " << publishResponse << std::endl;

        std::string mediaId = extractJsonField(publishResponse, "id");
        if (mediaId.empty()) {
            std::string errorMsg = extractJsonField(publishResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to publish to Instagram";
            db_->query(
                "UPDATE holiday_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + holidayId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        // Success
        db_->query(
            "UPDATE holiday_posts SET status = 'posted', external_media_id = '" +
            escapeSql(mediaId) + "', posted_at = NOW(), error_message = NULL, "
            "updated_at = NOW() WHERE id = " + holidayId
        );

        std::cout << "✅ Instagram: Holiday " << holidayId << " published! Media ID: " << mediaId << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Posted to Instagram!",
                "{\"media_id\":\"" + escapeJson(mediaId) + "\"}"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

// ---------- Promotional Posts ----------

std::string SocialController::extractPromoIdFromPath(const std::string& path) {
    std::regex r(R"(/api/social/promos/(\d+))");
    std::smatch m;
    if (std::regex_search(path, m, r)) {
        return m[1].str();
    }
    return "";
}

Response SocialController::handleGetPromoPosts(const Request& request) {
    try {
        ensurePromotionalPostsSchema();

        pqxx::result result = db_->query(
            "SELECT id, title, caption, image_path, image_url, "
            "status, scheduled_at, posted_at, external_media_id, error_message, "
            "heading, subheading, body_lines, footer, overlay_logos, "
            "created_at, updated_at "
            "FROM promotional_posts ORDER BY created_at DESC"
        );

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"title\":\"" << escapeJson(row["title"].c_str()) << "\",";
            json << "\"caption\":" << (row["caption"].is_null() ? "null" : "\"" + escapeJson(row["caption"].c_str()) + "\"") << ",";
            json << "\"image_path\":" << (row["image_path"].is_null() ? "null" : "\"" + escapeJson(row["image_path"].c_str()) + "\"") << ",";
            json << "\"image_url\":" << (row["image_url"].is_null() ? "null" : "\"" + escapeJson(row["image_url"].c_str()) + "\"") << ",";
            json << "\"status\":\"" << escapeJson(row["status"].c_str()) << "\",";
            json << "\"scheduled_at\":" << (row["scheduled_at"].is_null() ? "null" : "\"" + std::string(row["scheduled_at"].c_str()) + "\"") << ",";
            json << "\"posted_at\":" << (row["posted_at"].is_null() ? "null" : "\"" + std::string(row["posted_at"].c_str()) + "\"") << ",";
            json << "\"external_media_id\":" << (row["external_media_id"].is_null() ? "null" : "\"" + escapeJson(row["external_media_id"].c_str()) + "\"") << ",";
            json << "\"error_message\":" << (row["error_message"].is_null() ? "null" : "\"" + escapeJson(row["error_message"].c_str()) + "\"") << ",";
            json << "\"heading\":" << (row["heading"].is_null() ? "null" : "\"" + escapeJson(row["heading"].c_str()) + "\"") << ",";
            json << "\"subheading\":" << (row["subheading"].is_null() ? "null" : "\"" + escapeJson(row["subheading"].c_str()) + "\"") << ",";
            json << "\"body_lines\":" << (row["body_lines"].is_null() ? "null" : "\"" + escapeJson(row["body_lines"].c_str()) + "\"") << ",";
            json << "\"footer\":" << (row["footer"].is_null() ? "null" : "\"" + escapeJson(row["footer"].c_str()) + "\"") << ",";
            json << "\"overlay_logos\":" << (row["overlay_logos"].is_null() ? "null" : "\"" + escapeJson(row["overlay_logos"].c_str()) + "\"");
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Promotional posts", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleSavePromoPost(const Request& request) {
    try {
        ensurePromotionalPostsSchema();

        std::string body = request.getBody();
        std::string title = extractJsonField(body, "title");
        std::string caption = extractJsonField(body, "caption");
        std::string status = extractJsonField(body, "status");
        std::string scheduledAt = extractJsonField(body, "scheduled_at");
        std::string id = extractJsonField(body, "id");
        std::string heading = extractJsonField(body, "heading");
        std::string subheading = extractJsonField(body, "subheading");
        std::string bodyLines = extractJsonField(body, "body_lines");
        std::string footer = extractJsonField(body, "footer");
        std::string overlayLogos = extractJsonField(body, "overlay_logos");

        if (title.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "title is required"));
        }

        if (status.empty()) status = "draft";

        std::string query;
        if (!id.empty()) {
            query = "UPDATE promotional_posts SET "
                "title = '" + escapeSql(title) + "', "
                "caption = " + (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + ", "
                "status = '" + escapeSql(status) + "', "
                "scheduled_at = " + (scheduledAt.empty() ? "NULL" : "'" + escapeSql(scheduledAt) + "'") + ", "
                "heading = " + (heading.empty() ? "NULL" : "'" + escapeSql(heading) + "'") + ", "
                "subheading = " + (subheading.empty() ? "NULL" : "'" + escapeSql(subheading) + "'") + ", "
                "body_lines = " + (bodyLines.empty() ? "NULL" : "'" + escapeSql(bodyLines) + "'") + ", "
                "footer = " + (footer.empty() ? "NULL" : "'" + escapeSql(footer) + "'") + ", "
                "overlay_logos = " + (overlayLogos.empty() ? "NULL" : "'" + escapeSql(overlayLogos) + "'") + ", "
                "updated_at = NOW() "
                "WHERE id = " + escapeSql(id) + " RETURNING id";
        } else {
            query = "INSERT INTO promotional_posts (title, caption, status, scheduled_at, heading, subheading, body_lines, footer, overlay_logos) "
                "VALUES ('" + escapeSql(title) + "', " +
                (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + ", '" +
                escapeSql(status) + "', " +
                (scheduledAt.empty() ? "NULL" : "'" + escapeSql(scheduledAt) + "'") + ", " +
                (heading.empty() ? "NULL" : "'" + escapeSql(heading) + "'") + ", " +
                (subheading.empty() ? "NULL" : "'" + escapeSql(subheading) + "'") + ", " +
                (bodyLines.empty() ? "NULL" : "'" + escapeSql(bodyLines) + "'") + ", " +
                (footer.empty() ? "NULL" : "'" + escapeSql(footer) + "'") + ", " +
                (overlayLogos.empty() ? "NULL" : "'" + escapeSql(overlayLogos) + "'") +
                ") RETURNING id";
        }

        pqxx::result result = db_->query(query);

        if (!result.empty()) {
            int newId = result[0]["id"].as<int>();
            return Response(HttpStatus::OK,
                createJSONResponse(true, "Promotional post saved", "{\"id\":" + std::to_string(newId) + "}"));
        }

        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to save promotional post"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleUploadPromoMedia(const Request& request) {
    try {
        ensurePromotionalPostsSchema();

        std::string promoId = extractPromoIdFromPath(request.getPath());
        if (promoId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing promo ID"));
        }

        std::string body = request.getBody();

        size_t keyPos = body.find("\"data\"");
        if (keyPos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing 'data' field"));
        }
        size_t colonPos = body.find(':', keyPos + 6);
        size_t quoteStart = body.find('"', colonPos + 1);
        size_t quoteEnd = body.find('"', quoteStart + 1);
        if (quoteStart == std::string::npos || quoteEnd == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid data format"));
        }
        std::string dataValue = body.substr(quoteStart + 1, quoteEnd - quoteStart - 1);

        std::string b64Data = dataValue;
        size_t commaPos = b64Data.find(',');
        if (commaPos != std::string::npos) {
            b64Data = b64Data.substr(commaPos + 1);
        }

        std::string imageBytes = base64Decode(b64Data);
        if (imageBytes.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Failed to decode image data"));
        }

        const std::string imageDir = "/app/images/posts";
        mkdir(imageDir.c_str(), 0755);

        std::string filename = "promo_" + promoId + ".jpg";
        std::string filepath = imageDir + "/" + filename;
        std::ofstream outFile(filepath, std::ios::binary);
        if (!outFile.is_open()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to write image file"));
        }
        outFile.write(imageBytes.data(), imageBytes.size());
        outFile.close();

        std::string publicUrl = "https://footballhome.org/images/posts/" + filename;

        db_->query(
            "UPDATE promotional_posts SET image_path = '" + escapeSql(filename) +
            "', image_url = '" + escapeSql(publicUrl) +
            "', updated_at = NOW() WHERE id = " + promoId
        );

        std::cout << "📸 Promo media uploaded for " << promoId << ": " << filepath << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Media uploaded",
                "{\"image_url\":\"" + escapeJson(publicUrl) + "\",\"filename\":\"" + escapeJson(filename) + "\"}"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handlePublishPromoPost(const Request& request) {
    try {
        ensurePromotionalPostsSchema();

        std::string promoId = extractPromoIdFromPath(request.getPath());
        if (promoId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing promo ID"));
        }

        std::string errorMsg;
        bool ok = publishPromoById(promoId, errorMsg);
        if (!ok) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Posted to Instagram!"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

bool SocialController::publishPromoById(const std::string& promoId, std::string& errorOut) {
    ensurePromotionalPostsSchema();

    pqxx::result result = db_->query(
        "SELECT * FROM promotional_posts WHERE id = " + escapeSql(promoId)
    );

    if (result.empty()) {
        errorOut = "Promotional post not found";
        return false;
    }

    const auto& row = result[0];
    std::string imageUrl = row["image_url"].is_null() ? "" : row["image_url"].c_str();
    std::string caption = row["caption"].is_null() ? "" : row["caption"].c_str();

    if (imageUrl.empty()) {
        errorOut = "No image uploaded. Upload media first.";
        return false;
    }

    const char* accessToken = std::getenv("INSTAGRAM_ACCESS_TOKEN");
    const char* userId = std::getenv("INSTAGRAM_USER_ID");
    if (!accessToken || std::string(accessToken).empty()) {
        errorOut = "INSTAGRAM_ACCESS_TOKEN not configured";
        return false;
    }
    std::string igUserId = userId ? std::string(userId) : "26233831926285183";
    std::string igToken(accessToken);
    std::string apiBase = "https://graph.instagram.com/v21.0";

    db_->query(
        "UPDATE promotional_posts SET status = 'publishing', updated_at = NOW() "
        "WHERE id = " + escapeSql(promoId)
    );

    CURL* encoderCurl = curl_easy_init();
    std::string createUrl = apiBase + "/" + igUserId + "/media";
    std::string createData = "image_url=" + urlEncode(encoderCurl, imageUrl) +
        "&caption=" + urlEncode(encoderCurl, caption) +
        "&access_token=" + urlEncode(encoderCurl, igToken);
    curl_easy_cleanup(encoderCurl);

    std::cout << "📤 Instagram: Creating media container for promo " << promoId << std::endl;
    std::string createResponse = httpPost(createUrl, createData);
    std::cout << "📤 Instagram create response: " << createResponse << std::endl;

    std::string creationId = extractJsonField(createResponse, "id");
    if (creationId.empty()) {
        errorOut = extractJsonField(createResponse, "message");
        if (errorOut.empty()) errorOut = "Failed to create media container";
        db_->query(
            "UPDATE promotional_posts SET status = 'error', error_message = '" +
            escapeSql(errorOut) + "', updated_at = NOW() WHERE id = " + escapeSql(promoId)
        );
        return false;
    }

    std::string statusUrl = apiBase + "/" + creationId + "?fields=status_code&access_token=" + igToken;
    for (int attempt = 0; attempt < 10; attempt++) {
        std::this_thread::sleep_for(std::chrono::seconds(3));
        std::string statusResp = httpGet(statusUrl);
        std::string statusCode = extractJsonField(statusResp, "status_code");
        std::cout << "📤 Instagram: Container status (attempt " << attempt+1 << "): " << statusCode << std::endl;
        if (statusCode == "FINISHED") break;
        if (statusCode == "ERROR") {
            errorOut = "Instagram media processing failed";
            db_->query("UPDATE promotional_posts SET status = 'error', error_message = 'Instagram media processing failed', updated_at = NOW() WHERE id = " + escapeSql(promoId));
            return false;
        }
    }

    std::string publishUrl = apiBase + "/" + igUserId + "/media_publish";
    std::string publishData = "creation_id=" + creationId +
        "&access_token=" + igToken;

    std::cout << "📤 Instagram: Publishing promo container " << creationId << std::endl;
    std::string publishResponse = httpPost(publishUrl, publishData);
    std::cout << "📤 Instagram publish response: " << publishResponse << std::endl;

    std::string mediaId = extractJsonField(publishResponse, "id");
    if (mediaId.empty()) {
        errorOut = extractJsonField(publishResponse, "message");
        if (errorOut.empty()) errorOut = "Failed to publish to Instagram";
        db_->query(
            "UPDATE promotional_posts SET status = 'error', error_message = '" +
            escapeSql(errorOut) + "', updated_at = NOW() WHERE id = " + escapeSql(promoId)
        );
        return false;
    }

    db_->query(
        "UPDATE promotional_posts SET status = 'posted', external_media_id = '" +
        escapeSql(mediaId) + "', posted_at = NOW(), error_message = NULL, "
        "updated_at = NOW() WHERE id = " + escapeSql(promoId)
    );

    std::cout << "✅ Instagram: Promo " << promoId << " published! Media ID: " << mediaId << std::endl;
    return true;
}

// ========== Content Posts (User-uploaded media) ==========

Response SocialController::handleDeleteContentPost(const Request& request) {
    try {
        std::string contentId = extractContentIdFromPath(request.getPath());
        if (contentId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing content ID"));
        }

        // Delete associated files
        const std::string mediaDir = "/app/images/posts";
        std::string imgFile = mediaDir + "/content_" + contentId + ".jpg";
        std::string vidFile = mediaDir + "/content_" + contentId + ".mp4";
        std::remove(imgFile.c_str());
        std::remove(vidFile.c_str());

        db_->query("DELETE FROM content_posts WHERE id = " + escapeSql(contentId));

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Content post deleted"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

std::string SocialController::extractContentIdFromPath(const std::string& path) {
    std::regex re("/api/social/content/([^/]+)");
    std::smatch match;
    if (std::regex_search(path, match, re)) {
        return match[1].str();
    }
    return "";
}

Response SocialController::handleGetContentPosts(const Request& request) {
    try {
        pqxx::result result = db_->query(
            "SELECT id, title, caption, format, original_path, original_url, "
            "image_path, image_url, video_path, video_url, media_type, "
            "include_sponsor, overlay_logos, status, scheduled_at, posted_at, "
            "external_media_id, error_message, created_at, updated_at "
            "FROM content_posts ORDER BY created_at DESC"
        );

        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"title\":\"" << escapeJson(row["title"].c_str()) << "\",";
            json << "\"caption\":" << (row["caption"].is_null() ? "null" : "\"" + escapeJson(row["caption"].c_str()) + "\"") << ",";
            json << "\"format\":\"" << escapeJson(row["format"].c_str()) << "\",";
            json << "\"original_url\":" << (row["original_url"].is_null() ? "null" : "\"" + escapeJson(row["original_url"].c_str()) + "\"") << ",";
            json << "\"image_url\":" << (row["image_url"].is_null() ? "null" : "\"" + escapeJson(row["image_url"].c_str()) + "\"") << ",";
            json << "\"video_url\":" << (row["video_url"].is_null() ? "null" : "\"" + escapeJson(row["video_url"].c_str()) + "\"") << ",";
            json << "\"media_type\":\"" << escapeJson(row["media_type"].c_str()) << "\",";
            json << "\"include_sponsor\":" << (row["include_sponsor"].as<bool>() ? "true" : "false") << ",";
            json << "\"overlay_logos\":" << (row["overlay_logos"].is_null() ? "null" : "\"" + escapeJson(row["overlay_logos"].c_str()) + "\"") << ",";
            json << "\"status\":\"" << escapeJson(row["status"].c_str()) << "\",";
            json << "\"scheduled_at\":" << (row["scheduled_at"].is_null() ? "null" : "\"" + std::string(row["scheduled_at"].c_str()) + "\"") << ",";
            json << "\"posted_at\":" << (row["posted_at"].is_null() ? "null" : "\"" + std::string(row["posted_at"].c_str()) + "\"") << ",";
            json << "\"external_media_id\":" << (row["external_media_id"].is_null() ? "null" : "\"" + escapeJson(row["external_media_id"].c_str()) + "\"") << ",";
            json << "\"error_message\":" << (row["error_message"].is_null() ? "null" : "\"" + escapeJson(row["error_message"].c_str()) + "\"");
            json << "}";
        }
        json << "]";

        return Response(HttpStatus::OK, createJSONResponse(true, "Content posts", json.str()));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleSaveContentPost(const Request& request) {
    try {
        std::string body = request.getBody();
        std::string title = extractJsonField(body, "title");
        std::string caption = extractJsonField(body, "caption");
        std::string format = extractJsonField(body, "format");
        std::string overlayLogos = extractJsonField(body, "overlay_logos");
        std::string includeSponsor = extractJsonField(body, "include_sponsor");
        std::string id = extractJsonField(body, "id");

        if (title.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "title is required"));
        }
        if (format.empty()) format = "post";
        // Backward compat: if overlay_logos not set, derive from include_sponsor
        if (overlayLogos.empty()) {
            overlayLogos = (includeSponsor != "false") ? "sponsor" : "";
        }
        bool sponsor = (overlayLogos.find("sponsor") != std::string::npos);

        std::string query;
        if (!id.empty()) {
            query = "UPDATE content_posts SET "
                "title = '" + escapeSql(title) + "', "
                "caption = " + (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + ", "
                "format = '" + escapeSql(format) + "', "
                "include_sponsor = " + (sponsor ? "true" : "false") + ", "
                "overlay_logos = " + (overlayLogos.empty() ? "NULL" : "'" + escapeSql(overlayLogos) + "'") + ", "
                "updated_at = NOW() "
                "WHERE id = " + escapeSql(id) + " RETURNING id";
        } else {
            query = "INSERT INTO content_posts (title, caption, format, include_sponsor, overlay_logos) "
                "VALUES ('" + escapeSql(title) + "', " +
                (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + ", '" +
                escapeSql(format) + "', " + (sponsor ? "true" : "false") + ", " +
                (overlayLogos.empty() ? "NULL" : "'" + escapeSql(overlayLogos) + "'") +
                ") RETURNING id";
        }

        pqxx::result result = db_->query(query);

        if (!result.empty()) {
            int newId = result[0]["id"].as<int>();
            return Response(HttpStatus::OK,
                createJSONResponse(true, "Content post saved", "{\"id\":" + std::to_string(newId) + "}"));
        }

        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, "Failed to save content post"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleUploadContentMedia(const Request& request) {
    try {
        std::string contentId = extractContentIdFromPath(request.getPath());
        if (contentId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing content ID"));
        }

        std::string body = request.getBody();

        size_t keyPos = body.find("\"data\"");
        if (keyPos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing 'data' field"));
        }
        size_t colonPos = body.find(':', keyPos + 6);
        size_t quoteStart = body.find('"', colonPos + 1);
        size_t quoteEnd = body.find('"', quoteStart + 1);
        if (quoteStart == std::string::npos || quoteEnd == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Invalid data format"));
        }
        std::string dataValue = body.substr(quoteStart + 1, quoteEnd - quoteStart - 1);

        bool isVideo = (dataValue.find("data:video/") == 0);

        std::string b64Data = dataValue;
        size_t commaPos = b64Data.find(',');
        if (commaPos != std::string::npos) {
            b64Data = b64Data.substr(commaPos + 1);
        }

        std::string mediaBytes = base64Decode(b64Data);
        if (mediaBytes.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Failed to decode media data"));
        }

        const std::string mediaDir = "/app/images/posts";
        mkdir(mediaDir.c_str(), 0755);

        if (isVideo) {
            // Save raw video to temp file
            std::string tempFile = mediaDir + "/content_" + contentId + "_raw.mp4";
            std::string mp4File = mediaDir + "/content_" + contentId + ".mp4";
            {
                std::ofstream outFile(tempFile, std::ios::binary);
                if (!outFile.is_open()) {
                    return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                        createJSONResponse(false, "Failed to write video file"));
                }
                outFile.write(mediaBytes.data(), mediaBytes.size());
                outFile.close();
            }

            // Re-encode to Instagram-compatible MP4
            std::string ffmpegCmd = "ffmpeg -y -i " + tempFile +
                " -c:v libx264 -preset fast -crf 23 -pix_fmt yuv420p"
                " -movflags +faststart -an " + mp4File + " 2>&1";
            std::cout << "🎬 Converting content video: " << ffmpegCmd << std::endl;
            int ffResult = system(ffmpegCmd.c_str());
            std::remove(tempFile.c_str());

            if (ffResult != 0) {
                return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                    createJSONResponse(false, "FFmpeg conversion failed"));
            }

            std::string videoFilename = "content_" + contentId + ".mp4";
            std::string videoPublicUrl = "https://footballhome.org/images/posts/" + videoFilename;

            // Generate poster image
            std::string posterFile = mediaDir + "/content_" + contentId + ".jpg";
            std::string posterCmd = "ffmpeg -y -i " + mp4File +
                " -vframes 1 -q:v 2 " + posterFile + " 2>&1";
            system(posterCmd.c_str());
            std::string imageFilename = "content_" + contentId + ".jpg";
            std::string imagePublicUrl = "https://footballhome.org/images/posts/" + imageFilename;

            db_->query(
                "UPDATE content_posts SET "
                "original_path = '" + escapeSql(videoFilename) + "', "
                "original_url = '" + escapeSql(videoPublicUrl) + "', "
                "video_path = '" + escapeSql(videoFilename) + "', "
                "video_url = '" + escapeSql(videoPublicUrl) + "', "
                "image_path = '" + escapeSql(imageFilename) + "', "
                "image_url = '" + escapeSql(imagePublicUrl) + "', "
                "media_type = 'video', "
                "updated_at = NOW() WHERE id = " + contentId
            );

            std::cout << "🎬 Content video uploaded: " << mp4File << std::endl;

            return Response(HttpStatus::OK,
                createJSONResponse(true, "Video uploaded",
                    "{\"video_url\":\"" + escapeJson(videoPublicUrl) +
                    "\",\"image_url\":\"" + escapeJson(imagePublicUrl) +
                    "\",\"media_type\":\"video\"}"));
        } else {
            // Image upload
            std::string filename = "content_" + contentId + ".jpg";
            std::string filepath = mediaDir + "/" + filename;
            std::ofstream outFile(filepath, std::ios::binary);
            if (!outFile.is_open()) {
                return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                    createJSONResponse(false, "Failed to write image file"));
            }
            outFile.write(mediaBytes.data(), mediaBytes.size());
            outFile.close();

            std::string publicUrl = "https://footballhome.org/images/posts/" + filename;

            db_->query(
                "UPDATE content_posts SET "
                "original_path = '" + escapeSql(filename) + "', "
                "original_url = '" + escapeSql(publicUrl) + "', "
                "image_path = '" + escapeSql(filename) + "', "
                "image_url = '" + escapeSql(publicUrl) + "', "
                "media_type = 'image', "
                "updated_at = NOW() WHERE id = " + contentId
            );

            std::cout << "📸 Content image uploaded: " << filepath << std::endl;

            return Response(HttpStatus::OK,
                createJSONResponse(true, "Image uploaded",
                    "{\"image_url\":\"" + escapeJson(publicUrl) +
                    "\",\"media_type\":\"image\"}"));
        }
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handlePublishContentPost(const Request& request) {
    try {
        std::string contentId = extractContentIdFromPath(request.getPath());
        if (contentId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing content ID"));
        }

        pqxx::result result = db_->query(
            "SELECT * FROM content_posts WHERE id = " + contentId
        );

        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                createJSONResponse(false, "Content post not found"));
        }

        const auto& row = result[0];
        std::string imageUrl = row["image_url"].is_null() ? "" : row["image_url"].c_str();
        std::string videoUrl = row["video_url"].is_null() ? "" : row["video_url"].c_str();
        std::string mediaType = row["media_type"].c_str();
        std::string caption = row["caption"].is_null() ? "" : row["caption"].c_str();
        std::string format = row["format"].c_str();

        if (imageUrl.empty() && videoUrl.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "No media uploaded. Upload media first."));
        }

        const char* accessToken = std::getenv("INSTAGRAM_ACCESS_TOKEN");
        const char* userId = std::getenv("INSTAGRAM_USER_ID");
        if (!accessToken || std::string(accessToken).empty()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "INSTAGRAM_ACCESS_TOKEN not configured"));
        }
        std::string igUserId = userId ? std::string(userId) : "26233831926285183";
        std::string igToken(accessToken);
        std::string apiBase = "https://graph.instagram.com/v21.0";

        db_->query(
            "UPDATE content_posts SET status = 'publishing', updated_at = NOW() "
            "WHERE id = " + contentId
        );

        CURL* encoderCurl = curl_easy_init();
        std::string createUrl = apiBase + "/" + igUserId + "/media";
        std::string createData;

        bool isVideoPost = (mediaType == "video");

        if (isVideoPost) {
            // Video: use REELS media type
            createData = "media_type=REELS"
                "&video_url=" + urlEncode(encoderCurl, videoUrl) +
                "&caption=" + urlEncode(encoderCurl, caption) +
                "&access_token=" + urlEncode(encoderCurl, igToken);
        } else if (format == "story") {
            // Story: use STORIES media type
            createData = "media_type=STORIES"
                "&image_url=" + urlEncode(encoderCurl, imageUrl) +
                "&access_token=" + urlEncode(encoderCurl, igToken);
        } else {
            // Regular image post
            createData = "image_url=" + urlEncode(encoderCurl, imageUrl) +
                "&caption=" + urlEncode(encoderCurl, caption) +
                "&access_token=" + urlEncode(encoderCurl, igToken);
        }
        curl_easy_cleanup(encoderCurl);

        std::cout << "📤 Instagram: Creating media container for content " << contentId << " (format: " << format << ")" << std::endl;
        std::string createResponse = httpPost(createUrl, createData);
        std::cout << "📤 Instagram create response: " << createResponse << std::endl;

        std::string creationId = extractJsonField(createResponse, "id");
        if (creationId.empty()) {
            std::string errorMsg = extractJsonField(createResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to create media container";
            db_->query(
                "UPDATE content_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + contentId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        // Poll for processing completion
        int maxAttempts = isVideoPost ? 30 : 10;
        int waitSeconds = isVideoPost ? 5 : 3;
        std::string statusUrl = apiBase + "/" + creationId + "?fields=status_code&access_token=" + igToken;
        for (int attempt = 0; attempt < maxAttempts; attempt++) {
            std::this_thread::sleep_for(std::chrono::seconds(waitSeconds));
            std::string statusResp = httpGet(statusUrl);
            std::string statusCode = extractJsonField(statusResp, "status_code");
            std::cout << "📤 Instagram: Container status (attempt " << attempt+1 << "): " << statusCode << std::endl;
            if (statusCode == "FINISHED") break;
            if (statusCode == "ERROR") {
                db_->query("UPDATE content_posts SET status = 'error', error_message = 'Instagram media processing failed', updated_at = NOW() WHERE id = " + contentId);
                return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Instagram media processing failed"));
            }
        }

        std::string publishUrl = apiBase + "/" + igUserId + "/media_publish";
        std::string publishData = "creation_id=" + creationId +
            "&access_token=" + igToken;

        std::cout << "📤 Instagram: Publishing content container " << creationId << std::endl;
        std::string publishResponse = httpPost(publishUrl, publishData);
        std::cout << "📤 Instagram publish response: " << publishResponse << std::endl;

        std::string mediaId = extractJsonField(publishResponse, "id");
        if (mediaId.empty()) {
            std::string errorMsg = extractJsonField(publishResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to publish to Instagram";
            db_->query(
                "UPDATE content_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + contentId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        db_->query(
            "UPDATE content_posts SET status = 'posted', external_media_id = '" +
            escapeSql(mediaId) + "', posted_at = NOW(), error_message = NULL, "
            "updated_at = NOW() WHERE id = " + contentId
        );

        std::cout << "✅ Instagram: Content " << contentId << " published! Media ID: " << mediaId << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Posted to Instagram!",
                "{\"media_id\":\"" + escapeJson(mediaId) + "\"}"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

// ============ Google Drive Media Browser ============

std::string SocialController::extractUserIdFromJWT(const Request& request) {
    std::string authHeader = request.getHeader("authorization");
    if (authHeader.empty() || authHeader.substr(0, 7) != "Bearer ") {
        return "";
    }
    std::string token = authHeader.substr(7);

    // JWT is header.payload.signature — decode the payload (second part)
    size_t dot1 = token.find('.');
    size_t dot2 = token.find('.', dot1 + 1);
    if (dot1 == std::string::npos || dot2 == std::string::npos) return "";

    std::string payloadB64 = token.substr(dot1 + 1, dot2 - dot1 - 1);

    // Convert base64url back to standard base64
    for (auto& c : payloadB64) {
        if (c == '-') c = '+';
        else if (c == '_') c = '/';
    }
    // Add padding
    while (payloadB64.size() % 4 != 0) payloadB64 += '=';

    std::string payload = base64Decode(payloadB64);
    // Extract userId from {"userId":"<id>", ...}
    std::string key = "\"userId\":\"";
    size_t pos = payload.find(key);
    if (pos == std::string::npos) return "";
    pos += key.size();
    size_t end = payload.find('"', pos);
    if (end == std::string::npos) return "";
    return payload.substr(pos, end - pos);
}

std::string SocialController::getGoogleAccessToken(const std::string& userId) {
    try {
        pqxx::result result = db_->query(
            "SELECT access_token, refresh_token, expires_at FROM user_google_tokens "
            "WHERE user_id = " + db_->escape(userId)
        );
        if (result.empty()) return "";

        std::string accessToken = result[0]["access_token"].c_str();
        std::string refreshToken = result[0]["refresh_token"].is_null() ? "" : result[0]["refresh_token"].c_str();

        // Check if token is expired
        pqxx::result timeCheck = db_->query(
            "SELECT CASE WHEN expires_at < NOW() THEN 1 ELSE 0 END AS expired "
            "FROM user_google_tokens WHERE user_id = " + db_->escape(userId)
        );
        if (!timeCheck.empty() && timeCheck[0]["expired"].as<int>() == 1) {
            if (refreshToken.empty()) return "";
            return refreshGoogleToken(userId, refreshToken);
        }

        return accessToken;
    } catch (const std::exception& e) {
        std::cerr << "Error getting Google access token: " << e.what() << std::endl;
        return "";
    }
}

std::string SocialController::refreshGoogleToken(const std::string& userId, const std::string& refreshToken) {
    const char* clientId = std::getenv("GOOGLE_OAUTH_CLIENT_ID");
    const char* clientSecret = std::getenv("GOOGLE_OAUTH_CLIENT_SECRET");
    if (!clientId || !clientSecret) return "";

    CURL* curl = curl_easy_init();
    if (!curl) return "";

    std::string postData = "grant_type=refresh_token";
    postData += "&refresh_token=" + urlEncode(curl, refreshToken);
    postData += "&client_id=" + urlEncode(curl, std::string(clientId));
    postData += "&client_secret=" + urlEncode(curl, std::string(clientSecret));

    std::string response;
    curl_easy_setopt(curl, CURLOPT_URL, "https://oauth2.googleapis.com/token");
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, SocialWriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);

    if (res != CURLE_OK) {
        std::cerr << "Token refresh failed: " << curl_easy_strerror(res) << std::endl;
        return "";
    }

    std::string newAccessToken = extractJsonField(response, "access_token");
    if (newAccessToken.empty()) {
        std::cerr << "Token refresh response missing access_token: " << response << std::endl;
        return "";
    }

    int expSec = 3600;
    std::string expiresIn = extractJsonField(response, "expires_in");
    if (!expiresIn.empty()) {
        try { expSec = std::stoi(expiresIn); } catch (...) {}
    }

    try {
        db_->query(
            "UPDATE user_google_tokens SET access_token = " + db_->escape(newAccessToken) +
            ", expires_at = NOW() + INTERVAL '" + std::to_string(expSec) + " seconds'"
            ", updated_at = NOW() WHERE user_id = " + db_->escape(userId)
        );
    } catch (...) {}

    return newAccessToken;
}

Response SocialController::handleListDriveMedia(const Request& request) {
    try {
        std::string userId = extractUserIdFromJWT(request);
        if (userId.empty()) {
            return Response(HttpStatus::UNAUTHORIZED,
                createJSONResponse(false, "Not authenticated"));
        }

        std::string accessToken = getGoogleAccessToken(userId);
        if (accessToken.empty()) {
            return Response(HttpStatus::UNAUTHORIZED,
                createJSONResponse(false, "Google Drive not connected. Please log in again."));
        }

        std::string pageToken = request.getQueryParam("pageToken");

        // Build Drive API query — list images and videos
        std::string query = "(mimeType contains 'image/' or mimeType contains 'video/')";
        query += " and trashed = false";

        CURL* curl = curl_easy_init();
        if (!curl) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to initialize HTTP client"));
        }

        std::string url = "https://www.googleapis.com/drive/v3/files"
            "?q=" + urlEncode(curl, query) +
            "&fields=" + urlEncode(curl, "nextPageToken,files(id,name,mimeType,thumbnailLink,createdTime,size)") +
            "&orderBy=createdTime desc"
            "&pageSize=50";
        if (!pageToken.empty()) {
            url += "&pageToken=" + urlEncode(curl, pageToken);
        }

        std::string response;
        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, ("Authorization: Bearer " + accessToken).c_str());
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, SocialWriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        CURLcode res = curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);

        if (res != CURLE_OK) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to fetch Drive files"));
        }

        Response resp(HttpStatus::OK, response);
        resp.setHeader("Content-Type", "application/json");
        return resp;
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}

Response SocialController::handleDownloadDriveFile(const Request& request) {
    try {
        std::string userId = extractUserIdFromJWT(request);
        if (userId.empty()) {
            return Response(HttpStatus::UNAUTHORIZED,
                createJSONResponse(false, "Not authenticated"));
        }

        std::string fileId = request.getQueryParam("fileId");
        if (fileId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing fileId parameter"));
        }

        std::string accessToken = getGoogleAccessToken(userId);
        if (accessToken.empty()) {
            return Response(HttpStatus::UNAUTHORIZED,
                createJSONResponse(false, "Google Drive not connected"));
        }

        CURL* curl = curl_easy_init();
        if (!curl) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to initialize HTTP client"));
        }

        // Validate fileId format (alphanumeric, hyphens, underscores only)
        for (char c : fileId) {
            if (!std::isalnum(c) && c != '-' && c != '_') {
                curl_easy_cleanup(curl);
                return Response(HttpStatus::BAD_REQUEST,
                    createJSONResponse(false, "Invalid file ID"));
            }
        }

        // Get file metadata
        std::string metaUrl = "https://www.googleapis.com/drive/v3/files/" + fileId
            + "?fields=id,name,mimeType,size";

        std::string metaResponse;
        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, ("Authorization: Bearer " + accessToken).c_str());
        curl_easy_setopt(curl, CURLOPT_URL, metaUrl.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, SocialWriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &metaResponse);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 10L);
        CURLcode res = curl_easy_perform(curl);
        curl_slist_free_all(headers);

        if (res != CURLE_OK) {
            curl_easy_cleanup(curl);
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to get file metadata"));
        }

        std::string mimeType = extractJsonField(metaResponse, "mimeType");
        std::string fileName = extractJsonField(metaResponse, "name");

        // Download the actual file content
        std::string downloadUrl = "https://www.googleapis.com/drive/v3/files/" + fileId + "?alt=media";
        std::string fileContent;
        headers = nullptr;
        headers = curl_slist_append(headers, ("Authorization: Bearer " + accessToken).c_str());
        curl_easy_setopt(curl, CURLOPT_URL, downloadUrl.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &fileContent);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 60L);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        res = curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);

        if (res != CURLE_OK) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to download file"));
        }

        Response resp(HttpStatus::OK, fileContent);
        resp.setHeader("Content-Type", mimeType);
        resp.setHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
        return resp;
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}
