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

        // Strip data URL prefix (e.g. "data:image/png;base64,")
        std::string b64Data = dataValue;
        size_t commaPos = b64Data.find(',');
        if (commaPos != std::string::npos) {
            b64Data = b64Data.substr(commaPos + 1);
        }

        // Decode base64
        std::string imageBytes = base64Decode(b64Data);
        if (imageBytes.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Failed to decode image data"));
        }

        // Ensure directory exists
        const std::string imageDir = "/app/images/posts";
        mkdir(imageDir.c_str(), 0755);

        // Save to file
        std::string filename = "post_" + postId + ".jpg";
        std::string filepath = imageDir + "/" + filename;
        std::ofstream outFile(filepath, std::ios::binary);
        if (!outFile.is_open()) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, "Failed to write image file"));
        }
        outFile.write(imageBytes.data(), imageBytes.size());
        outFile.close();

        // Build public URL
        std::string publicUrl = "https://footballhome.org/images/posts/" + filename;

        // Update DB with image path and URL
        db_->query(
            "UPDATE social_posts SET image_path = '" + escapeSql(filename) +
            "', image_url = '" + escapeSql(publicUrl) +
            "', updated_at = NOW() WHERE id = " + postId
        );

        std::cout << "📸 Media uploaded for post " << postId << ": " << filepath << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Media uploaded",
                "{\"image_url\":\"" + escapeJson(publicUrl) + "\",\"filename\":\"" + escapeJson(filename) + "\"}"));
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
        std::string caption = row["caption"].is_null() ? "" : row["caption"].c_str();

        if (imageUrl.empty()) {
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
        std::string createData = "image_url=" + urlEncode(encoderCurl, imageUrl) +
            "&caption=" + urlEncode(encoderCurl, caption) +
            "&access_token=" + urlEncode(encoderCurl, igToken);
        curl_easy_cleanup(encoderCurl);

        std::cout << "📤 Instagram: Creating media container for post " << postId << std::endl;
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
        std::string statusUrl = apiBase + "/" + creationId + "?fields=status_code&access_token=" + igToken;
        for (int attempt = 0; attempt < 10; attempt++) {
            std::this_thread::sleep_for(std::chrono::seconds(3));
            std::string statusResp = httpGet(statusUrl);
            std::string statusCode = extractJsonField(statusResp, "status_code");
            std::cout << "📤 Instagram: Container status (attempt " << attempt+1 << "): " << statusCode << std::endl;
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
        pqxx::result result = db_->query(
            "SELECT id, title, caption, image_path, image_url, "
            "status, scheduled_at, posted_at, external_media_id, error_message, "
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
            json << "\"error_message\":" << (row["error_message"].is_null() ? "null" : "\"" + escapeJson(row["error_message"].c_str()) + "\"");
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
        std::string body = request.getBody();
        std::string title = extractJsonField(body, "title");
        std::string caption = extractJsonField(body, "caption");
        std::string status = extractJsonField(body, "status");
        std::string scheduledAt = extractJsonField(body, "scheduled_at");
        std::string id = extractJsonField(body, "id");

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
                "updated_at = NOW() "
                "WHERE id = " + escapeSql(id) + " RETURNING id";
        } else {
            query = "INSERT INTO promotional_posts (title, caption, status, scheduled_at) "
                "VALUES ('" + escapeSql(title) + "', " +
                (caption.empty() ? "NULL" : "'" + escapeSql(caption) + "'") + ", '" +
                escapeSql(status) + "', " +
                (scheduledAt.empty() ? "NULL" : "'" + escapeSql(scheduledAt) + "'") +
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
        std::string promoId = extractPromoIdFromPath(request.getPath());
        if (promoId.empty()) {
            return Response(HttpStatus::BAD_REQUEST,
                createJSONResponse(false, "Missing promo ID"));
        }

        pqxx::result result = db_->query(
            "SELECT * FROM promotional_posts WHERE id = " + promoId
        );

        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND,
                createJSONResponse(false, "Promotional post not found"));
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
            "UPDATE promotional_posts SET status = 'publishing', updated_at = NOW() "
            "WHERE id = " + promoId
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
            std::string errorMsg = extractJsonField(createResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to create media container";
            db_->query(
                "UPDATE promotional_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + promoId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        std::string statusUrl = apiBase + "/" + creationId + "?fields=status_code&access_token=" + igToken;
        for (int attempt = 0; attempt < 10; attempt++) {
            std::this_thread::sleep_for(std::chrono::seconds(3));
            std::string statusResp = httpGet(statusUrl);
            std::string statusCode = extractJsonField(statusResp, "status_code");
            std::cout << "📤 Instagram: Container status (attempt " << attempt+1 << "): " << statusCode << std::endl;
            if (statusCode == "FINISHED") break;
            if (statusCode == "ERROR") {
                db_->query("UPDATE promotional_posts SET status = 'error', error_message = 'Instagram media processing failed', updated_at = NOW() WHERE id = " + promoId);
                return Response(HttpStatus::INTERNAL_SERVER_ERROR, createJSONResponse(false, "Instagram media processing failed"));
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
            std::string errorMsg = extractJsonField(publishResponse, "message");
            if (errorMsg.empty()) errorMsg = "Failed to publish to Instagram";
            db_->query(
                "UPDATE promotional_posts SET status = 'error', error_message = '" +
                escapeSql(errorMsg) + "', updated_at = NOW() WHERE id = " + promoId
            );
            return Response(HttpStatus::INTERNAL_SERVER_ERROR,
                createJSONResponse(false, errorMsg));
        }

        db_->query(
            "UPDATE promotional_posts SET status = 'posted', external_media_id = '" +
            escapeSql(mediaId) + "', posted_at = NOW(), error_message = NULL, "
            "updated_at = NOW() WHERE id = " + promoId
        );

        std::cout << "✅ Instagram: Promo " << promoId << " published! Media ID: " << mediaId << std::endl;

        return Response(HttpStatus::OK,
            createJSONResponse(true, "Posted to Instagram!",
                "{\"media_id\":\"" + escapeJson(mediaId) + "\"}"));
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR,
            createJSONResponse(false, std::string("Error: ") + e.what()));
    }
}
