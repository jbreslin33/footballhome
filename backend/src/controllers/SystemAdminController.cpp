#include "SystemAdminController.h"
#include <sstream>
#include <regex>
#include <iostream>
#include <curl/curl.h>
#include <cstdlib>

SystemAdminController::SystemAdminController() {
    db_ = Database::getInstance();
    userService_ = new UserService(db_);
    identityService_ = std::make_unique<IdentityService>(db_);
}

void SystemAdminController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "📋 Registering system admin routes with prefix: " << prefix << std::endl;
    
    // Identity Management (Moved to top for priority)
    router.get(prefix + "/identities", [this](const Request& request) {
        std::cout << "🔍 Handling GET /identities" << std::endl;
        return this->handleGetIdentities(request);
    });
    
    router.post(prefix + "/identities/link", [this](const Request& request) {
        return this->handleLinkIdentity(request);
    });

    // Matches endpoint
    router.get(prefix + "/matches", [this](const Request& request) {
        return this->handleGetMatches(request);
    });
    
    // Report endpoints
    router.get(prefix + "/coverage", [this](const Request& request) {
        return this->handleGetCoverageReport(request);
    });
    
    router.get(prefix + "/data-quality", [this](const Request& request) {
        return this->handleGetDataQuality(request);
    });
    
    router.get(prefix + "/league-stats", [this](const Request& request) {
        return this->handleGetLeagueStats(request);
    });

    // Standings
    router.get(prefix + "/standings/seasons", [this](const Request& request) {
        return this->handleGetSeasons(request);
    });
    
    router.get(prefix + "/standings", [this](const Request& request) {
        return this->handleGetStandings(request);
    });
    
    // Teams Report
    router.get(prefix + "/teams", [this](const Request& request) {
        return this->handleGetTeams(request);
    });

    // Integration Dashboards
    router.get(prefix + "/organizations", [this](const Request& request) {
        return this->handleGetOrganizations(request);
    });
    
    router.get(prefix + "/leagues", [this](const Request& request) {
        return this->handleGetLeagues(request);
    });
    
    router.get(prefix + "/schema", [this](const Request& request) {
        return this->handleGetDatabaseSchema(request);
    });
    
    router.get(prefix + "/schema/:table/data", [this](const Request& request) {
        return this->handleGetTableData(request);
    });
    
    router.get(prefix + "/casa", [this](const Request& request) {
        return this->handleGetCasaDashboard(request);
    });
    
    router.get(prefix + "/casa/divisions", [this](const Request& request) {
        return this->handleGetCasaDivisions(request);
    });
    
    router.get(prefix + "/casa/teams", [this](const Request& request) {
        return this->handleGetCasaTeams(request);
    });
    
    router.get(prefix + "/casa/players", [this](const Request& request) {
        return this->handleGetCasaPlayers(request);
    });
    
    router.get(prefix + "/casa/matches", [this](const Request& request) {
        return this->handleGetCasaMatches(request);
    });

    router.get(prefix + "/apsl", [this](const Request& request) {
        return this->handleGetApslDashboard(request);
    });
    
    router.get(prefix + "/apsl/divisions", [this](const Request& request) {
        return this->handleGetApslDivisions(request);
    });
    
    router.get(prefix + "/apsl/teams", [this](const Request& request) {
        return this->handleGetApslTeams(request);
    });
    
    router.get(prefix + "/apsl/players", [this](const Request& request) {
        return this->handleGetApslPlayers(request);
    });
    
    router.get(prefix + "/apsl/matches", [this](const Request& request) {
        return this->handleGetApslMatches(request);
    });

    router.get(prefix + "/groupme", [this](const Request& request) {
        return this->handleGetGroupMeDashboard(request);
    });
    
    router.get(prefix + "/groupme/groups", [this](const Request& request) {
        return this->handleGetGroupMeGroups(request);
    });
    
    router.get(prefix + "/groupme/live/groups", [this](const Request& request) {
        return this->handleGetGroupMeLiveGroups(request);
    });
    
    router.get(prefix + "/groupme/live/group/:id", [this](const Request& request) {
        return this->handleGetGroupMeLiveGroupDetails(request);
    });
    
    router.get(prefix + "/groupme/live/group/:id/messages", [this](const Request& request) {
        return this->handleGetGroupMeLiveMessages(request);
    });
    
    router.get(prefix + "/groupme/live/group/:id/members", [this](const Request& request) {
        return this->handleGetGroupMeLiveMembers(request);
    });
    
    router.get(prefix + "/groupme/live/group/:id/events", [this](const Request& request) {
        return this->handleGetGroupMeLiveEvents(request);
    });

    // Dashboard & Overview
    router.get(prefix + "/dashboard", [this](const Request& request) {
        return this->handleGetDashboard(request);
    });
    
    router.get(prefix + "/health", [this](const Request& request) {
        return this->handleGetSystemHealth(request);
    });
    
    // System Settings
    router.get(prefix + "/settings", [this](const Request& request) {
        return this->handleGetSettings(request);
    });
    
    router.get(prefix + "/settings/:key", [this](const Request& request) {
        return this->handleGetSetting(request);
    });
    
    router.put(prefix + "/settings/:key", [this](const Request& request) {
        return this->handleUpdateSetting(request);
    });
    
    // Feature Flags
    router.get(prefix + "/features", [this](const Request& request) {
        return this->handleGetFeatureFlags(request);
    });
    
    router.put(prefix + "/features/:key/toggle", [this](const Request& request) {
        return this->handleToggleFeatureFlag(request);
    });
    
    // User Management
    router.get(prefix + "/users", [this](const Request& request) {
        return this->handleGetAllUsers(request);
    });
    
    router.get(prefix + "/users/:userId", [this](const Request& request) {
        return this->handleGetUser(request);
    });
    
    router.put(prefix + "/users/:userId", [this](const Request& request) {
        return this->handleUpdateUser(request);
    });
    
    router.put(prefix + "/users/:userId/status", [this](const Request& request) {
        return this->handleUpdateUserStatus(request);
    });
    
    router.get(prefix + "/users/:userId/teams", [this](const Request& request) {
        return this->handleGetUserTeams(request);
    });
    
    router.post(prefix + "/users/:userId/teams", [this](const Request& request) {
        return this->handleAddUserToTeam(request);
    });
    
    router.del(prefix + "/users/:userId/teams/:teamId", [this](const Request& request) {
        return this->handleRemoveUserFromTeam(request);
    });
    
    router.post(prefix + "/users/:userId/impersonate", [this](const Request& request) {
        return this->handleImpersonateUser(request);
    });
    
    router.post(prefix + "/users/bulk", [this](const Request& request) {
        return this->handleBulkUserOperation(request);
    });
    
    // System Admins
    router.get(prefix + "/admins", [this](const Request& request) {
        return this->handleGetSystemAdmins(request);
    });
    
    router.post(prefix + "/admins/:userId/grant", [this](const Request& request) {
        return this->handleGrantSystemAdmin(request);
    });
    
    router.del(prefix + "/admins/:userId/revoke", [this](const Request& request) {
        return this->handleRevokeSystemAdmin(request);
    });
    
    // Identity Management - Moved to top
    /*
    router.get(prefix + "/identities", [this](const Request& request) {
        return this->handleGetIdentities(request);
    });
    
    router.post(prefix + "/identities/link", [this](const Request& request) {
        return this->handleLinkIdentity(request);
    });
    */
    
    // Audit Logs
    router.get(prefix + "/audit-logs", [this](const Request& request) {
        return this->handleGetAuditLogs(request);
    });
    
    router.get(prefix + "/api-usage", [this](const Request& request) {
        return this->handleGetApiUsageLogs(request);
    });
    
    // Data Management
    router.get(prefix + "/imports", [this](const Request& request) {
        return this->handleGetImportJobs(request);
    });
    
    router.post(prefix + "/imports", [this](const Request& request) {
        return this->handleCreateImportJob(request);
    });
    
    router.get(prefix + "/scrapers", [this](const Request& request) {
        return this->handleGetScraperLogs(request);
    });
    
    router.post(prefix + "/scrapers/:name/trigger", [this](const Request& request) {
        return this->handleTriggerScraper(request);
    });
    
    // System Notifications
    router.get(prefix + "/notifications", [this](const Request& request) {
        return this->handleGetSystemNotifications(request);
    });
    
    router.post(prefix + "/notifications", [this](const Request& request) {
        return this->handleCreateSystemNotification(request);
    });
    
    router.put(prefix + "/notifications/:id", [this](const Request& request) {
        return this->handleUpdateSystemNotification(request);
    });
    
    router.del(prefix + "/notifications/:id", [this](const Request& request) {
        return this->handleDeleteSystemNotification(request);
    });
    
    // Lookup Tables
    router.get(prefix + "/lookups", [this](const Request& request) {
        return this->handleGetLookupTables(request);
    });
    
    router.get(prefix + "/lookups/:table", [this](const Request& request) {
        return this->handleGetLookupTable(request);
    });
    
    router.post(prefix + "/lookups/:table", [this](const Request& request) {
        return this->handleCreateLookupEntry(request);
    });
    
    router.put(prefix + "/lookups/:table/:id", [this](const Request& request) {
        return this->handleUpdateLookupEntry(request);
    });
    
    router.del(prefix + "/lookups/:table/:id", [this](const Request& request) {
        return this->handleDeleteLookupEntry(request);
    });
}

// ============================================================================
// DASHBOARD & OVERVIEW
// ============================================================================

Response SystemAdminController::handleGetMatches(const Request& request) {
    try {
        std::cout << "⚽ Getting all matches..." << std::endl;
        
        // Get sort parameters with defaults
        std::string sort_column = request.hasQueryParam("sort") ? 
            request.getQueryParam("sort") : "match_date";
        std::string sort_dir = request.hasQueryParam("dir") ? 
            request.getQueryParam("dir") : "DESC";
        
        // Validate sort column
        std::vector<std::string> allowed_columns = {
            "match_date", "home_team_name", "away_team_name", 
            "league_name", "source_system"
        };
        
        if (std::find(allowed_columns.begin(), allowed_columns.end(), sort_column) == allowed_columns.end()) {
            sort_column = "match_date";
        }
        
        if (sort_dir != "ASC" && sort_dir != "DESC") {
            sort_dir = "DESC";
        }
        
        std::string query = R"(
            SELECT 
                m.id,
                m.match_date,
                m.home_score,
                m.away_score,
                ht.name as home_team_name,
                at.name as away_team_name,
                l.name as league_name,
                ss.name as source_system,
                COUNT(me.id) as event_count
            FROM matches m
            LEFT JOIN teams ht ON m.home_team_id = ht.id
            LEFT JOIN teams at ON m.away_team_id = at.id
            LEFT JOIN match_divisions md ON m.id = md.match_id
            LEFT JOIN divisions d ON md.division_id = d.id
            LEFT JOIN seasons s ON d.season_id = s.id
            LEFT JOIN leagues l ON s.league_id = l.id
            LEFT JOIN source_systems ss ON m.source_system_id = ss.id
            LEFT JOIN match_events me ON m.id = me.match_id
            GROUP BY m.id, m.match_date, m.home_score, m.away_score,
                     ht.name, at.name, l.name, ss.name
            ORDER BY )" + sort_column + " " + sort_dir + R"(
        )";
        
        pqxx::result result = db_->query(query);
        
        std::stringstream json;
        json << "[";
        bool first = true;
        
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            
            json << "{";
            json << "\"id\":" << row["id"].as<int>() << ",";
            json << "\"match_date\":\"" << row["match_date"].c_str() << "\",";
            json << "\"home_score\":" << (row["home_score"].is_null() ? "null" : row["home_score"].c_str()) << ",";
            json << "\"away_score\":" << (row["away_score"].is_null() ? "null" : row["away_score"].c_str()) << ",";
            json << "\"home_team_name\":\"" << row["home_team_name"].c_str() << "\",";
            json << "\"away_team_name\":\"" << row["away_team_name"].c_str() << "\",";
            json << "\"league_name\":\"" << row["league_name"].c_str() << "\",";
            json << "\"source_system\":\"" << row["source_system"].c_str() << "\",";
            json << "\"event_count\":" << row["event_count"].as<int>();
            json << "}";
        }
        
        json << "]";
        
        return Response::json(json.str());
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting matches: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to get matches: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetDashboard(const Request& request) {
    try {
        std::cout << "📊 Getting super admin dashboard..." << std::endl;
        
        // Get counts
        std::string users_query = "SELECT COUNT(*) as count FROM users WHERE is_active = true";
        std::string teams_query = "SELECT COUNT(*) as count FROM teams";
        std::string clubs_query = "SELECT COUNT(*) as count FROM clubs WHERE is_active = true";
        std::string events_query = "SELECT COUNT(*) as count FROM events WHERE event_date >= CURRENT_DATE";
        
        pqxx::result users_result = db_->query(users_query);
        pqxx::result teams_result = db_->query(teams_query);
        pqxx::result clubs_result = db_->query(clubs_query);
        pqxx::result events_result = db_->query(events_query);
        
        // Get recent activity
        std::string activity_query = R"(
            SELECT admin_user_id, action_type, entity_type, entity_name, 
                   action_description, created_at
            FROM system_audit_log
            ORDER BY created_at DESC
            LIMIT 10
        )";
        pqxx::result activity_result = db_->query(activity_query);
        
        // Build JSON response
        std::ostringstream json;
        json << "{";
        json << "\"stats\":{";
        json << "\"active_users\":" << users_result[0]["count"].c_str() << ",";
        json << "\"active_teams\":" << teams_result[0]["count"].c_str() << ",";
        json << "\"active_clubs\":" << clubs_result[0]["count"].c_str() << ",";
        json << "\"upcoming_events\":" << events_result[0]["count"].c_str();
        json << "},";
        
        json << "\"recent_activity\":[";
        bool first = true;
        for (const auto& row : activity_result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"admin_id\":\"" << row["admin_user_id"].c_str() << "\",";
            json << "\"action\":\"" << row["action_type"].c_str() << "\",";
            json << "\"entity_type\":\"" << row["entity_type"].c_str() << "\",";
            json << "\"entity_name\":\"" << (row["entity_name"].is_null() ? "" : row["entity_name"].c_str()) << "\",";
            json << "\"description\":\"" << (row["action_description"].is_null() ? "" : row["action_description"].c_str()) << "\",";
            json << "\"timestamp\":\"" << row["created_at"].c_str() << "\"";
            json << "}";
        }
        json << "]";
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting dashboard: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to load dashboard\"}");
    }
}

Response SystemAdminController::handleGetSystemHealth(const Request& request) {
    try {
        std::cout << "🏥 Getting system health metrics..." << std::endl;
        
        // Database size
        std::string db_size_query = "SELECT pg_database_size(current_database()) as size";
        pqxx::result db_size = db_->query(db_size_query);
        
        // Recent metrics
        std::string metrics_query = R"(
            SELECT metric_name, metric_value, metric_unit, recorded_at
            FROM system_health_metrics
            WHERE recorded_at >= NOW() - INTERVAL '1 hour'
            ORDER BY recorded_at DESC
        )";
        pqxx::result metrics = db_->query(metrics_query);
        
        std::ostringstream json;
        json << "{";
        json << "\"database_size_bytes\":" << db_size[0]["size"].c_str() << ",";
        json << "\"metrics\":[";
        
        bool first = true;
        for (const auto& row : metrics) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"name\":\"" << row["metric_name"].c_str() << "\",";
            json << "\"value\":" << row["metric_value"].c_str() << ",";
            json << "\"unit\":\"" << (row["metric_unit"].is_null() ? "" : row["metric_unit"].c_str()) << "\",";
            json << "\"timestamp\":\"" << row["recorded_at"].c_str() << "\"";
            json << "}";
        }
        json << "]";
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting system health: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to load system health\"}");
    }
}

// ============================================================================
// SYSTEM SETTINGS
// ============================================================================

Response SystemAdminController::handleGetSettings(const Request& request) {
    try {
        std::cout << "⚙️  Getting system settings..." << std::endl;
        
        // Get category filter from query params
        std::string category = request.getQueryParam("category");
        
        std::string query = "SELECT setting_key, setting_value, value_type, category, "
                          "display_name, description, is_sensitive, updated_at "
                          "FROM system_settings ";
        
        if (!category.empty()) {
            query += "WHERE category = '" + category + "' ";
        }
        
        query += "ORDER BY category, display_name";
        
        pqxx::result result = db_->query(query);
        
        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"key\":\"" << row["setting_key"].c_str() << "\",";
            
            // Hide sensitive values
            if (row["is_sensitive"].as<bool>()) {
                json << "\"value\":\"********\",";
            } else {
                json << "\"value\":\"" << (row["setting_value"].is_null() ? "" : row["setting_value"].c_str()) << "\",";
            }
            
            json << "\"type\":\"" << row["value_type"].c_str() << "\",";
            json << "\"category\":\"" << (row["category"].is_null() ? "" : row["category"].c_str()) << "\",";
            json << "\"display_name\":\"" << row["display_name"].c_str() << "\",";
            json << "\"description\":\"" << (row["description"].is_null() ? "" : row["description"].c_str()) << "\",";
            json << "\"is_sensitive\":" << (row["is_sensitive"].as<bool>() ? "true" : "false") << ",";
            json << "\"updated_at\":\"" << row["updated_at"].c_str() << "\"";
            json << "}";
        }
        json << "]";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting settings: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to load settings\"}");
    }
}

Response SystemAdminController::handleGetSetting(const Request& request) {
    try {
        std::string key = extractIdFromPath(request.getPath(), "/system-admin/settings/");
        
        std::string query = "SELECT setting_key, setting_value, value_type, category, "
                          "display_name, description, is_sensitive "
                          "FROM system_settings WHERE setting_key = $1";
        
        pqxx::result result = db_->query(query, {key});
        
        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, "{\"error\":\"Setting not found\"}");
        }
        
        std::ostringstream json;
        json << "{";
        json << "\"key\":\"" << result[0]["setting_key"].c_str() << "\",";
        json << "\"value\":\"" << (result[0]["setting_value"].is_null() ? "" : result[0]["setting_value"].c_str()) << "\",";
        json << "\"type\":\"" << result[0]["value_type"].c_str() << "\",";
        json << "\"category\":\"" << (result[0]["category"].is_null() ? "" : result[0]["category"].c_str()) << "\",";
        json << "\"display_name\":\"" << result[0]["display_name"].c_str() << "\",";
        json << "\"description\":\"" << (result[0]["description"].is_null() ? "" : result[0]["description"].c_str()) << "\",";
        json << "\"is_sensitive\":" << (result[0]["is_sensitive"].as<bool>() ? "true" : "false");
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting setting: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to load setting\"}");
    }
}

Response SystemAdminController::handleUpdateSetting(const Request& request) {
    try {
        std::string key = extractIdFromPath(request.getPath(), "/system-admin/settings/");
        std::string body = request.getBody();
        
        // TODO: Parse JSON properly - for now using simple parsing
        size_t value_pos = body.find("\"value\":\"");
        if (value_pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Missing value field\"}");
        }
        
        value_pos += 9; // Skip past "value":"
        size_t value_end = body.find("\"", value_pos);
        std::string new_value = body.substr(value_pos, value_end - value_pos);
        
        // Get old value for audit log
        std::string old_query = "SELECT setting_value FROM system_settings WHERE setting_key = $1";
        pqxx::result old_result = db_->query(old_query, {key});
        std::string old_value = old_result.empty() ? "" : old_result[0]["setting_value"].c_str();
        
        // Update setting
        std::string update_query = "UPDATE system_settings SET setting_value = $1, "
                                  "updated_at = CURRENT_TIMESTAMP, updated_by = $2 "
                                  "WHERE setting_key = $3";
        
        // TODO: Get actual admin user_id from authentication
        std::string admin_id = "77d77471-1250-47e0-81ab-d4626595d63c"; 
        
        db_->query(update_query, {new_value, admin_id, key});
        
        // Log to ##u/##p file
        std::map<std::string, std::string> columns;
        columns["setting_value"] = new_value;
        columns["updated_by"] = admin_id;
        std::string upsert = SqlBuilder::buildUpsert("system_settings", key, columns, "setting_key");
        SqlFileLogger::log("system_settings", upsert);
        
        // Log audit action
        logAuditAction(admin_id, "update", "system_setting", key,
                      "Updated setting: " + key, old_value, new_value);
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Setting updated\"}");
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error updating setting: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to update setting\"}");
    }
}

// ============================================================================
// FEATURE FLAGS
// ============================================================================

Response SystemAdminController::handleGetFeatureFlags(const Request& request) {
    try {
        std::cout << "🚩 Getting feature flags..." << std::endl;
        
        std::string query = "SELECT flag_key, flag_name, description, is_enabled, "
                          "category, requires_restart, updated_at "
                          "FROM feature_flags ORDER BY category, flag_name";
        
        pqxx::result result = db_->query(query);
        
        std::ostringstream json;
        json << "[";
        bool first = true;
        for (const auto& row : result) {
            if (!first) json << ",";
            first = false;
            json << "{";
            json << "\"key\":\"" << row["flag_key"].c_str() << "\",";
            json << "\"name\":\"" << row["flag_name"].c_str() << "\",";
            json << "\"description\":\"" << (row["description"].is_null() ? "" : row["description"].c_str()) << "\",";
            json << "\"is_enabled\":" << (row["is_enabled"].as<bool>() ? "true" : "false") << ",";
            json << "\"category\":\"" << (row["category"].is_null() ? "" : row["category"].c_str()) << "\",";
            json << "\"requires_restart\":" << (row["requires_restart"].as<bool>() ? "true" : "false") << ",";
            json << "\"updated_at\":\"" << row["updated_at"].c_str() << "\"";
            json << "}";
        }
        json << "]";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting feature flags: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to load feature flags\"}");
    }
}

Response SystemAdminController::handleToggleFeatureFlag(const Request& request) {
    try {
        std::string key = extractIdFromPath(request.getPath(), "/system-admin/features/");
        key = key.substr(0, key.find("/toggle")); // Remove /toggle suffix
        
        // Get current state
        std::string query = "SELECT is_enabled FROM feature_flags WHERE flag_key = $1";
        pqxx::result result = db_->query(query, {key});
        
        if (result.empty()) {
            return Response(HttpStatus::NOT_FOUND, "{\"error\":\"Feature flag not found\"}");
        }
        
        bool current_state = result[0]["is_enabled"].as<bool>();
        bool new_state = !current_state;
        
        // Update flag
        std::string update_query = "UPDATE feature_flags SET is_enabled = $1, "
                                  "updated_at = CURRENT_TIMESTAMP, updated_by = $2 "
                                  "WHERE flag_key = $3";
        
        // TODO: Get actual admin user_id from authentication
        std::string admin_id = "77d77471-1250-47e0-81ab-d4626595d63c";
        
        std::vector<std::string> params = {new_state ? "true" : "false", admin_id, key};
        db_->query(update_query, params);
        
        // Log to ##u/##p file
        std::map<std::string, std::string> columns;
        columns["is_enabled"] = new_state ? "true" : "false";
        columns["updated_by"] = admin_id;
        std::string upsert = SqlBuilder::buildUpsert("feature_flags", key, columns, "flag_key");
        SqlFileLogger::log("feature_flags", upsert);
        
        // Log audit action
        logAuditAction(admin_id, "update", "feature_flag", key,
                      "Toggled feature flag: " + key + " to " + (new_state ? "enabled" : "disabled"));
        
        std::ostringstream response;
        response << "{\"success\":true,\"is_enabled\":" << (new_state ? "true" : "false") << "}";
        return Response(HttpStatus::OK, response.str());
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error toggling feature flag: " << e.what() << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
            "{\"error\":\"Failed to toggle feature flag\"}");
    }
}

// ============================================================================
// HELPER METHODS
// ============================================================================

std::string SystemAdminController::extractIdFromPath(const std::string& path, const std::string& prefix) {
    if (path.find(prefix) == 0) {
        return path.substr(prefix.length());
    }
    return "";
}

bool SystemAdminController::isSystemAdmin(const std::string& user_id) {
    try {
        std::string query = "SELECT 1 FROM system_admins WHERE user_id = $1 AND is_active = true";
        pqxx::result result = db_->query(query, {user_id});
        return !result.empty();
    } catch (const std::exception& e) {
        std::cerr << "❌ Error checking system admin: " << e.what() << std::endl;
        return false;
    }
}

void SystemAdminController::logAuditAction(const std::string& admin_id, 
                                          const std::string& action_type,
                                          const std::string& entity_type, 
                                          const std::string& entity_id,
                                          const std::string& description,
                                          const std::string& old_values,
                                          const std::string& new_values) {
    try {
        std::string query = "INSERT INTO system_audit_log "
                          "(admin_user_id, action_type, entity_type, entity_id, "
                          "action_description, old_values, new_values) "
                          "VALUES ($1, $2, $3, $4, $5, $6::jsonb, $7::jsonb)";
        
        std::string old_json = old_values.empty() ? "null" : "'{\"value\":\"" + old_values + "\"}'";
        std::string new_json = new_values.empty() ? "null" : "'{\"value\":\"" + new_values + "\"}'";
        
        db_->query(query, {admin_id, action_type, entity_type, entity_id, description});
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error logging audit action: " << e.what() << std::endl;
    }
}

// ============================================================================
// STUB IMPLEMENTATIONS (TODO: Implement these endpoints)
// ============================================================================

Response SystemAdminController::handleGetAllUsers(const Request& request) {
    try {
        // Parse query parameters
        std::string limit = request.getQueryParam("limit");
        if (limit.empty()) limit = "50";
        std::string offset = request.getQueryParam("offset");
        if (offset.empty()) offset = "0";
        
        std::string team_id = request.getQueryParam("team_id");
        std::string club_id = request.getQueryParam("club_id");
        std::string search = request.getQueryParam("q");
        std::string sort_by = request.getQueryParam("sort_by");
        std::string sort_order = request.getQueryParam("sort_order");
        
        std::string query = "SELECT DISTINCT u.id, u.email, u.first_name, u.last_name, u.is_active, u.created_at FROM users u ";
        std::vector<std::string> params;
        int param_idx = 1;
        
        std::string where_clause = "WHERE 1=1 ";
        
        if (!team_id.empty()) {
            query += "JOIN team_division_players tp ON u.id = tp.player_id ";
            where_clause += "AND tp.team_id = $" + std::to_string(param_idx++) + " AND tp.is_active = true ";
            params.push_back(team_id);
        } else if (!club_id.empty()) {
            query += "JOIN team_division_players tp ON u.id = tp.player_id JOIN teams t ON tp.team_id = t.id ";
            where_clause += "AND t.club_id = $" + std::to_string(param_idx++) + " AND tp.is_active = true ";
            params.push_back(club_id);
        }
        
        if (!search.empty()) {
            where_clause += "AND (LOWER(u.first_name) LIKE LOWER($" + std::to_string(param_idx) + ") OR LOWER(u.last_name) LIKE LOWER($" + std::to_string(param_idx) + ") OR LOWER(u.email) LIKE LOWER($" + std::to_string(param_idx) + ")) ";
            params.push_back("%" + search + "%");
            param_idx++;
        }
        
        query += where_clause;

        // Sorting
        std::string order_clause = "ORDER BY u.last_name, u.first_name"; // Default
        if (!sort_by.empty()) {
            std::string direction = (sort_order == "desc" || sort_order == "DESC") ? "DESC" : "ASC";
            if (sort_by == "first_name") order_clause = "ORDER BY u.first_name " + direction + ", u.last_name ASC";
            else if (sort_by == "last_name") order_clause = "ORDER BY u.last_name " + direction + ", u.first_name ASC";
            else if (sort_by == "email") order_clause = "ORDER BY u.email " + direction;
            else if (sort_by == "created_at") order_clause = "ORDER BY u.created_at " + direction;
        }
        query += " " + order_clause;

        query += " LIMIT $" + std::to_string(param_idx++) + " OFFSET $" + std::to_string(param_idx++);
        params.push_back(limit);
        params.push_back(offset);

        auto result = db_->query(query, params);
        
        // Helper lambda for JSON escaping
        auto escape_json = [](const std::string& s) -> std::string {
            std::string res;
            for (char c : s) {
                if (c == '"') res += "\\\"";
                else if (c == '\\') res += "\\\\";
                else if (c == '\b') res += "\\b";
                else if (c == '\f') res += "\\f";
                else if (c == '\n') res += "\\n";
                else if (c == '\r') res += "\\r";
                else if (c == '\t') res += "\\t";
                else res += c;
            }
            return res;
        };

        // Build JSON array
        std::string json = "{\"users\":[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + escape_json(result[i]["id"].as<std::string>()) + "\",";
            
            // Handle nullable email field
            if (!result[i]["email"].is_null()) {
                json += "\"email\":\"" + escape_json(result[i]["email"].as<std::string>()) + "\",";
            } else {
                json += "\"email\":null,";
            }
            
            // Handle nullable first_name field
            if (!result[i]["first_name"].is_null()) {
                json += "\"first_name\":\"" + escape_json(result[i]["first_name"].as<std::string>()) + "\",";
            } else {
                json += "\"first_name\":null,";
            }
            
            // Handle nullable last_name field
            if (!result[i]["last_name"].is_null()) {
                json += "\"last_name\":\"" + escape_json(result[i]["last_name"].as<std::string>()) + "\",";
            } else {
                json += "\"last_name\":null,";
            }
            
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false") + ",";
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]}";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch users: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleUpdateUserStatus(const Request& request) {
    try {
        // Parse user ID from path: /api/system-admin/users/:userId/status
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/users/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, slash_pos);
        
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // TODO: Parse JSON body to get is_active value
        // For now, toggle the current status
        std::string check_query = "SELECT is_active FROM users WHERE id = $1";
        std::vector<std::string> check_params = {user_id};
        auto check_result = db_->query(check_query, check_params);
        
        if (check_result.empty()) {
            return Response(HttpStatus::NOT_FOUND, "{\"error\":\"User not found\"}");
        }
        
        bool current_status = check_result[0]["is_active"].as<bool>();
        bool new_status = !current_status;
        
        // Update user status
        std::string update_query = "UPDATE users SET is_active = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2";
        std::vector<std::string> update_params = {new_status ? "true" : "false", user_id};
        db_->query(update_query, update_params);
        
        // Log audit action
        std::string admin_id = "311ee799-a6a1-450f-8bad-5140a021c92b"; // Hardcoded for now
        logAuditAction(admin_id, "user_status_update", "users", user_id,
                      new_status ? "Activated user" : "Deactivated user",
                      current_status ? "active" : "inactive",
                      new_status ? "active" : "inactive");
        
        return Response(HttpStatus::OK, "{\"success\":true,\"is_active\":" + std::string(new_status ? "true" : "false") + "}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to update user status: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetUser(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/users/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string user_id = path.substr(pos + prefix.length());
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // Get user basic info
        std::string user_query = "SELECT id, first_name, last_name, email, phone, date_of_birth, is_active, created_at FROM users WHERE id = $1";
        std::vector<std::string> params = {user_id};
        auto user_result = db_->query(user_query, params);
        
        if (user_result.empty()) {
            return Response(HttpStatus::NOT_FOUND, "{\"error\":\"User not found\"}");
        }
        
        // Get player info if exists
        std::string player_query = "SELECT preferred_position_id, photo_url, height_cm, weight_kg, dominant_foot, player_rating FROM players WHERE id = $1";
        auto player_result = db_->query(player_query, params);
        
        // Get team memberships
        std::string teams_query = R"(
            SELECT t.id as team_id, t.name as team_name, sd.display_name as division_name, 
                   tp.jersey_number, tp.is_active as team_active
            FROM team_division_players tp
            JOIN teams t ON tp.team_id = t.id
            JOIN clubs sd ON t.club_id = sd.id
            WHERE tp.player_id = $1
            ORDER BY t.name
        )";
        auto teams_result = db_->query(teams_query, params);
        
        // Build JSON response
        std::ostringstream json;
        json << "{";
        json << "\"id\":\"" << user_result[0]["id"].as<std::string>() << "\",";
        json << "\"first_name\":" << (user_result[0]["first_name"].is_null() ? "null" : "\"" + user_result[0]["first_name"].as<std::string>() + "\"") << ",";
        json << "\"last_name\":" << (user_result[0]["last_name"].is_null() ? "null" : "\"" + user_result[0]["last_name"].as<std::string>() + "\"") << ",";
        json << "\"email\":" << (user_result[0]["email"].is_null() ? "null" : "\"" + user_result[0]["email"].as<std::string>() + "\"") << ",";
        json << "\"phone\":" << (user_result[0]["phone"].is_null() ? "null" : "\"" + user_result[0]["phone"].as<std::string>() + "\"") << ",";
        json << "\"date_of_birth\":" << (user_result[0]["date_of_birth"].is_null() ? "null" : "\"" + user_result[0]["date_of_birth"].as<std::string>() + "\"") << ",";
        json << "\"is_active\":" << (user_result[0]["is_active"].as<bool>() ? "true" : "false") << ",";
        json << "\"created_at\":\"" << user_result[0]["created_at"].as<std::string>() << "\",";
        
        // Add player info
        json << "\"player_info\":";
        if (!player_result.empty()) {
            json << "{";
            json << "\"preferred_position_id\":" << (player_result[0]["preferred_position_id"].is_null() ? "null" : "\"" + player_result[0]["preferred_position_id"].as<std::string>() + "\"") << ",";
            json << "\"photo_url\":" << (player_result[0]["photo_url"].is_null() ? "null" : "\"" + player_result[0]["photo_url"].as<std::string>() + "\"") << ",";
            json << "\"height_cm\":" << (player_result[0]["height_cm"].is_null() ? "null" : player_result[0]["height_cm"].as<std::string>()) << ",";
            json << "\"weight_kg\":" << (player_result[0]["weight_kg"].is_null() ? "null" : player_result[0]["weight_kg"].as<std::string>()) << ",";
            json << "\"dominant_foot\":" << (player_result[0]["dominant_foot"].is_null() ? "null" : "\"" + player_result[0]["dominant_foot"].as<std::string>() + "\"") << ",";
            json << "\"player_rating\":" << (player_result[0]["player_rating"].is_null() ? "null" : player_result[0]["player_rating"].as<std::string>());
            json << "}";
        } else {
            json << "null";
        }
        json << ",";
        
        // Add teams
        json << "\"teams\":[";
        for (size_t i = 0; i < teams_result.size(); ++i) {
            if (i > 0) json << ",";
            json << "{";
            json << "\"team_id\":\"" << teams_result[i]["team_id"].as<std::string>() << "\",";
            json << "\"team_name\":\"" << teams_result[i]["team_name"].as<std::string>() << "\",";
            json << "\"division_name\":\"" << teams_result[i]["division_name"].as<std::string>() << "\",";
            json << "\"jersey_number\":" << (teams_result[i]["jersey_number"].is_null() ? "null" : teams_result[i]["jersey_number"].as<std::string>()) << ",";
            json << "\"is_active\":" << (teams_result[i]["team_active"].as<bool>() ? "true" : "false");
            json << "}";
        }
        json << "]";
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch user details: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleUpdateUser(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/users/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string user_id = path.substr(pos + prefix.length());
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // Parse JSON body - simple parsing for now
        std::string body = request.getBody();
        std::string first_name, last_name, email, phone, date_of_birth;
        
        // Extract fields from JSON (basic parsing)
        auto extractField = [&body](const std::string& field) -> std::string {
            std::string pattern = "\"" + field + "\":\"";
            size_t pos = body.find(pattern);
            if (pos == std::string::npos) return "";
            pos += pattern.length();
            size_t end = body.find("\"", pos);
            if (end == std::string::npos) return "";
            return body.substr(pos, end - pos);
        };
        
        first_name = extractField("first_name");
        last_name = extractField("last_name");
        email = extractField("email");
        phone = extractField("phone");
        date_of_birth = extractField("date_of_birth");
        
        std::string admin_id = "311ee799-a6a1-450f-8bad-5140a021c92b"; // Hardcoded for now
        
        bool success = userService_->updateUserBasicInfo(user_id, first_name, last_name, email, phone, date_of_birth, admin_id);
        
        if (success) {
            return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"User updated successfully\"}");
        } else {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"Failed to update user\"}");
        }
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to update user: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetUserTeams(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/users/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, slash_pos);
        
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        auto teams = userService_->getUserTeams(user_id);
        
        std::ostringstream json;
        json << "{\"teams\":[";
        for (size_t i = 0; i < teams.size(); ++i) {
            if (i > 0) json << ",";
            json << "{";
            json << "\"team_id\":\"" << teams[i].team_id << "\",";
            json << "\"team_name\":\"" << teams[i].team_name << "\",";
            json << "\"sport_division_name\":\"" << teams[i].sport_division_name << "\",";
            json << "\"jersey_number\":" << (teams[i].jersey_number.empty() ? "null" : "\"" + teams[i].jersey_number + "\"") << ",";
            json << "\"position_id\":" << (teams[i].position_id.empty() ? "null" : "\"" + teams[i].position_id + "\"") << ",";
            json << "\"position_name\":" << (teams[i].position_name.empty() ? "null" : "\"" + teams[i].position_name + "\"");
            json << "}";
        }
        json << "]}";
        
        return Response(HttpStatus::OK, json.str());
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch user teams: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleAddUserToTeam(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/users/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, slash_pos);
        
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // TODO: Parse JSON body for team_id and jersey_number
        return Response(HttpStatus::NOT_IMPLEMENTED, "{\"error\":\"Add to team not yet fully implemented - need JSON body parsing\"}");
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to add user to team: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleRemoveUserFromTeam(const Request& request) {
    try {
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/users/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t first_slash = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, first_slash);
        
        std::string after_teams = after_prefix.substr(first_slash + 7); // "/teams/"
        std::string team_id = after_teams;
        
        if (user_id.empty() || team_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID and Team ID are required\"}");
        }
        
        // Soft delete from team_division_players
        std::string query = "UPDATE team_division_players SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE player_id = $1 AND team_id = $2";
        std::vector<std::string> params = {user_id, team_id};
        db_->query(query, params);
        
        // Log audit action
        std::string admin_id = "311ee799-a6a1-450f-8bad-5140a021c92b";
        logAuditAction(admin_id, "remove_from_team", "team_division_players", user_id,
                      "Removed user from team", team_id, "");
        
        return Response(HttpStatus::OK, "{\"success\":true}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to remove user from team: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleImpersonateUser(const Request& request) {
    try {
        // Parse user ID from path: /api/system-admin/users/:userId/impersonate
        std::string path = request.getPath();
        size_t pos = path.find("/api/system-admin/users/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + 25);
        size_t slash_pos = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, slash_pos);
        
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // Hardcoded admin_id for now
        std::string admin_id = "1";
        
        // Log the impersonation action
        logAuditAction(admin_id, "impersonate_user", "users", user_id, "{}", 
                      "{\"impersonated_user_id\":\"" + user_id + "\"}");
        
        // TODO: Generate a special JWT token for impersonation that includes both admin and user IDs
        // For now, just return success
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Impersonation started\",\"user_id\":\"" + user_id + "\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to impersonate user: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleBulkUserOperation(const Request& request) {
    try {
        // TODO: Parse JSON body for operation type and user IDs
        // Operations: activate, deactivate, delete, etc.
        std::string operation = request.getQueryParam("operation");
        
        if (operation.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Operation type is required\"}");
        }
        
        // Placeholder implementation
        if (operation == "activate") {
            // TODO: Parse user IDs from body and activate them
            return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Users activated\"}");
        } else if (operation == "deactivate") {
            // TODO: Parse user IDs from body and deactivate them
            return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Users deactivated\"}");
        } else {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid operation type\"}");
        }
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to perform bulk operation: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetSystemAdmins(const Request& request) {
    try {
        // Query system admins with user details
        std::string query = "SELECT sa.id, sa.user_id, sa.appointed_by, sa.notes, sa.is_active, "
                          "sa.appointed_at, "
                          "u.email, u.first_name, u.last_name, "
                          "appointer.first_name as appointer_first_name, appointer.last_name as appointer_last_name "
                          "FROM system_admins sa "
                          "JOIN users u ON sa.user_id = u.id "
                          "LEFT JOIN users appointer ON sa.appointed_by = appointer.id "
                          "WHERE sa.is_active = true "
                          "ORDER BY sa.appointed_at DESC";
        
        auto result = db_->query(query, {});
        
        // Build JSON array
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"user_id\":\"" + result[i]["user_id"].as<std::string>() + "\",";
            
            // Handle nullable email
            if (!result[i]["email"].is_null()) {
                json += "\"email\":\"" + result[i]["email"].as<std::string>() + "\",";
            } else {
                json += "\"email\":null,";
            }
            
            // Handle nullable first_name
            if (!result[i]["first_name"].is_null()) {
                json += "\"first_name\":\"" + result[i]["first_name"].as<std::string>() + "\",";
            } else {
                json += "\"first_name\":null,";
            }
            
            // Handle nullable last_name
            if (!result[i]["last_name"].is_null()) {
                json += "\"last_name\":\"" + result[i]["last_name"].as<std::string>() + "\",";
            } else {
                json += "\"last_name\":null,";
            }
            
            // Handle nullable appointed_by
            if (!result[i]["appointed_by"].is_null()) {
                json += "\"appointed_by\":\"" + result[i]["appointed_by"].as<std::string>() + "\",";
            } else {
                json += "\"appointed_by\":null,";
            }
            
            // Appointer name (may be null)
            if (!result[i]["appointer_first_name"].is_null()) {
                json += "\"appointer_first_name\":\"" + result[i]["appointer_first_name"].as<std::string>() + "\",";
                json += "\"appointer_last_name\":\"" + result[i]["appointer_last_name"].as<std::string>() + "\",";
            } else {
                json += "\"appointer_first_name\":null,";
                json += "\"appointer_last_name\":null,";
            }
            
            // Handle nullable notes
            if (!result[i]["notes"].is_null()) {
                json += "\"notes\":\"" + result[i]["notes"].as<std::string>() + "\",";
            } else {
                json += "\"notes\":null,";
            }
            
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false") + ",";
            json += "\"appointed_at\":\"" + result[i]["appointed_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch system admins: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGrantSystemAdmin(const Request& request) {
    try {
        // Parse userId from path: /api/system-admin/admins/:userId/grant
        std::string path = request.getPath();
        size_t pos = path.find("/api/system-admin/admins/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + 26); // length of "/api/system-admin/admins/"
        size_t slash_pos = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, slash_pos);
        
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // Get notes from request body (if provided)
        std::string notes = "";
        // TODO: Parse JSON body when available
        
        // Hardcoded admin_id for now (will be replaced with JWT token parsing)
        std::string admin_id = "1";
        
        // Insert into system_admins table
        std::string query = "INSERT INTO system_admins (user_id, appointed_by, notes, is_active) "
                          "VALUES ($1, $2, $3, true) "
                          "ON CONFLICT (user_id) DO UPDATE SET is_active = true, appointed_by = $2, notes = $3 "
                          "RETURNING id";
        std::vector<std::string> params = {user_id, admin_id, notes};
        auto result = db_->query(query, params);
        
        // Log audit action
        logAuditAction(admin_id, "grant_system_admin", "system_admins", user_id, "{}", 
                      "{\"user_id\":\"" + user_id + "\",\"appointed_by\":\"" + admin_id + "\"}");
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"System admin granted\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to grant system admin: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleRevokeSystemAdmin(const Request& request) {
    try {
        // Parse userId from path: /api/system-admin/admins/:userId/revoke
        std::string path = request.getPath();
        size_t pos = path.find("/api/system-admin/admins/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + 26); // length of "/api/system-admin/admins/"
        size_t slash_pos = after_prefix.find("/");
        std::string user_id = after_prefix.substr(0, slash_pos);
        
        if (user_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"User ID is required\"}");
        }
        
        // Hardcoded admin_id for now (will be replaced with JWT token parsing)
        std::string admin_id = "1";
        
        // Update system_admins table to set is_active = false
        std::string query = "UPDATE system_admins SET is_active = false "
                          "WHERE user_id = $1";
        std::vector<std::string> params = {user_id};
        db_->execute(query, params);
        
        // Log audit action
        logAuditAction(admin_id, "revoke_system_admin", "system_admins", user_id, 
                      "{\"user_id\":\"" + user_id + "\",\"is_active\":true}", 
                      "{\"user_id\":\"" + user_id + "\",\"is_active\":false}");
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"System admin revoked\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to revoke system admin: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetAuditLogs(const Request& request) {
    try {
        // Parse query parameters
        std::string limit = request.getQueryParam("limit");
        if (limit.empty()) limit = "100";
        std::string offset = request.getQueryParam("offset");
        if (offset.empty()) offset = "0";
        std::string action_type = request.getQueryParam("action_type");
        std::string entity_type = request.getQueryParam("entity_type");
        
        // Build query with optional filters
        std::string query = "SELECT sal.id, sal.admin_user_id, sal.action_type, sal.entity_type, sal.entity_id, "
                          "sal.old_values, sal.new_values, sal.created_at, "
                          "u.email, u.first_name, u.last_name "
                          "FROM system_audit_log sal "
                          "JOIN users u ON sal.admin_user_id = u.id "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!action_type.empty()) {
            params.push_back(action_type);
            query += "AND sal.action_type = $" + std::to_string(++param_count) + " ";
        }
        
        if (!entity_type.empty()) {
            params.push_back(entity_type);
            query += "AND sal.entity_type = $" + std::to_string(++param_count) + " ";
        }
        
        query += "ORDER BY sal.created_at DESC ";
        params.push_back(limit);
        query += "LIMIT $" + std::to_string(++param_count) + " ";
        params.push_back(offset);
        query += "OFFSET $" + std::to_string(++param_count);
        
        auto result = db_->query(query, params);
        
        // Build JSON array
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"admin_user_id\":\"" + result[i]["admin_user_id"].as<std::string>() + "\",";
            
            // Handle nullable email
            if (!result[i]["email"].is_null()) {
                json += "\"admin_email\":\"" + result[i]["email"].as<std::string>() + "\",";
            } else {
                json += "\"admin_email\":null,";
            }
            
            // Handle nullable names
            std::string admin_name = "";
            if (!result[i]["first_name"].is_null() && !result[i]["last_name"].is_null()) {
                admin_name = result[i]["first_name"].as<std::string>() + " " + result[i]["last_name"].as<std::string>();
                json += "\"admin_name\":\"" + admin_name + "\",";
            } else {
                json += "\"admin_name\":null,";
            }
            
            json += "\"action_type\":\"" + result[i]["action_type"].as<std::string>() + "\",";
            
            // Handle nullable entity_type and entity_id
            if (!result[i]["entity_type"].is_null()) {
                json += "\"entity_type\":\"" + result[i]["entity_type"].as<std::string>() + "\",";
            } else {
                json += "\"entity_type\":null,";
            }
            
            if (!result[i]["entity_id"].is_null()) {
                json += "\"entity_id\":\"" + result[i]["entity_id"].as<std::string>() + "\",";
            } else {
                json += "\"entity_id\":null,";
            }
            
            // Handle nullable JSONB fields
            if (!result[i]["old_values"].is_null()) {
                json += "\"old_values\":" + result[i]["old_values"].as<std::string>() + ",";
            } else {
                json += "\"old_values\":null,";
            }
            
            if (!result[i]["new_values"].is_null()) {
                json += "\"new_values\":" + result[i]["new_values"].as<std::string>() + ",";
            } else {
                json += "\"new_values\":null,";
            }
            
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch audit logs: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetApiUsageLogs(const Request& request) {
    try {
        std::string limit = request.getQueryParam("limit");
        if (limit.empty()) limit = "100";
        std::string offset = request.getQueryParam("offset");
        if (offset.empty()) offset = "0";
        
        std::string query = "SELECT id, endpoint, http_method, user_id, status_code, response_time_ms, created_at "
                          "FROM api_usage_log "
                          "ORDER BY created_at DESC "
                          "LIMIT $1 OFFSET $2";
        std::vector<std::string> params = {limit, offset};
        auto result = db_->query(query, params);
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"endpoint\":\"" + result[i]["endpoint"].as<std::string>() + "\",";
            json += "\"http_method\":\"" + result[i]["http_method"].as<std::string>() + "\",";
            json += "\"user_id\":\"" + result[i]["user_id"].as<std::string>() + "\",";
            json += "\"status_code\":" + result[i]["status_code"].as<std::string>() + ",";
            json += "\"response_time_ms\":" + result[i]["response_time_ms"].as<std::string>() + ",";
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch API usage logs: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetImportJobs(const Request& request) {
    try {
        std::string limit = request.getQueryParam("limit");
        if (limit.empty()) limit = "50";
        std::string offset = request.getQueryParam("offset");
        if (offset.empty()) offset = "0";
        std::string status = request.getQueryParam("status");
        
        std::string query = "SELECT id, job_type, entity_type, status, total_records, processed_records, "
                          "successful_records, failed_records, error_log, started_at, completed_at "
                          "FROM data_import_jobs "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!status.empty()) {
            params.push_back(status);
            query += "AND status = $" + std::to_string(++param_count) + " ";
        }
        
        query += "ORDER BY started_at DESC ";
        params.push_back(limit);
        query += "LIMIT $" + std::to_string(++param_count) + " ";
        params.push_back(offset);
        query += "OFFSET $" + std::to_string(++param_count);
        
        auto result = db_->query(query, params);
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"job_type\":\"" + result[i]["job_type"].as<std::string>() + "\",";
            json += "\"entity_type\":\"" + result[i]["entity_type"].as<std::string>() + "\",";
            json += "\"status\":\"" + result[i]["status"].as<std::string>() + "\",";
            json += "\"total_records\":" + result[i]["total_records"].as<std::string>() + ",";
            json += "\"processed_records\":" + result[i]["processed_records"].as<std::string>() + ",";
            json += "\"successful_records\":" + result[i]["successful_records"].as<std::string>() + ",";
            json += "\"failed_records\":" + result[i]["failed_records"].as<std::string>() + ",";
            
            if (!result[i]["error_log"].is_null()) {
                json += "\"error_log\":\"" + result[i]["error_log"].as<std::string>() + "\",";
            } else {
                json += "\"error_log\":null,";
            }
            
            if (!result[i]["started_at"].is_null()) {
                json += "\"started_at\":\"" + result[i]["started_at"].as<std::string>() + "\",";
            } else {
                json += "\"started_at\":null,";
            }
            
            if (!result[i]["completed_at"].is_null()) {
                json += "\"completed_at\":\"" + result[i]["completed_at"].as<std::string>() + "\",";
            } else {
                json += "\"completed_at\":null,";
            }
            
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch import jobs: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleCreateImportJob(const Request& request) {
    try {
        // TODO: Parse job_type from request body when JSON parsing is available
        std::string job_type = "manual_import";
        
        // TODO: Parse job_type and entity_type from request body
        std::string entity_type = "manual";
        std::string admin_id = "311ee799-a6a1-450f-8bad-5140a021c92b"; // Hardcoded for now
        
        std::string query = "INSERT INTO data_import_jobs (job_type, entity_type, status, started_by, total_records, processed_records) "
                          "VALUES ($1, $2, 'pending', $3, 0, 0) RETURNING id";
        std::vector<std::string> params = {job_type, entity_type, admin_id};
        auto result = db_->query(query, params);
        
        std::string job_id = result[0]["id"].as<std::string>();
        
        return Response(HttpStatus::CREATED, "{\"success\":true,\"job_id\":\"" + job_id + "\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to create import job: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetScraperLogs(const Request& request) {
    try {
        std::string limit = request.getQueryParam("limit");
        if (limit.empty()) limit = "50";
        std::string offset = request.getQueryParam("offset");
        if (offset.empty()) offset = "0";
        std::string scraper_type = request.getQueryParam("scraper_type");
        
        std::string query = "SELECT id, scraper_name, execution_mode, status, teams_scraped, players_scraped, "
                          "matches_scraped, errors_count, error_messages, started_at, completed_at, duration_seconds "
                          "FROM scraper_execution_log "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!scraper_type.empty()) {
            params.push_back(scraper_type);
            query += "AND scraper_name = $" + std::to_string(++param_count) + " ";
        }
        
        query += "ORDER BY started_at DESC ";
        params.push_back(limit);
        query += "LIMIT $" + std::to_string(++param_count) + " ";
        params.push_back(offset);
        query += "OFFSET $" + std::to_string(++param_count);
        
        auto result = db_->query(query, params);
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"scraper_name\":\"" + result[i]["scraper_name"].as<std::string>() + "\",";
            
            if (!result[i]["execution_mode"].is_null()) {
                json += "\"execution_mode\":\"" + result[i]["execution_mode"].as<std::string>() + "\",";
            } else {
                json += "\"execution_mode\":null,";
            }
            
            json += "\"status\":\"" + result[i]["status"].as<std::string>() + "\",";
            json += "\"teams_scraped\":" + result[i]["teams_scraped"].as<std::string>() + ",";
            json += "\"players_scraped\":" + result[i]["players_scraped"].as<std::string>() + ",";
            json += "\"matches_scraped\":" + result[i]["matches_scraped"].as<std::string>() + ",";
            json += "\"errors_count\":" + result[i]["errors_count"].as<std::string>() + ",";
            
            if (!result[i]["error_messages"].is_null()) {
                json += "\"error_messages\":\"" + result[i]["error_messages"].as<std::string>() + "\",";
            } else {
                json += "\"error_messages\":null,";
            }
            
            json += "\"started_at\":\"" + result[i]["started_at"].as<std::string>() + "\",";
            
            if (!result[i]["completed_at"].is_null()) {
                json += "\"completed_at\":\"" + result[i]["completed_at"].as<std::string>() + "\",";
            } else {
                json += "\"completed_at\":null,";
            }
            
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch scraper logs: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleTriggerScraper(const Request& request) {
    try {
        // Parse scraper type from path or query param
        std::string scraper_type = request.getQueryParam("scraper_type");
        if (scraper_type.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"scraper_type is required\"}");
        }
        
        // Create a scraper log entry
        std::string admin_id = "311ee799-a6a1-450f-8bad-5140a021c92b"; // Hardcoded for now
        std::string query = "INSERT INTO scraper_execution_log (scraper_name, status, teams_scraped, players_scraped, matches_scraped, errors_count, started_by) "
                          "VALUES ($1, 'running', 0, 0, 0, 0, $2) RETURNING id";
        std::vector<std::string> params = {scraper_type, admin_id};
        auto result = db_->query(query, params);
        
        std::string log_id = result[0]["id"].as<std::string>();
        
        // TODO: Actually trigger the scraper process (external command or queue)
        
        return Response(HttpStatus::OK, "{\"success\":true,\"log_id\":\"" + log_id + "\",\"message\":\"Scraper triggered\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to trigger scraper: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetSystemNotifications(const Request& request) {
    try {
        std::string is_active = request.getQueryParam("is_active");
        
        std::string query = "SELECT id, notification_type, title, message, target_audience, priority, is_active, "
                          "starts_at, ends_at, created_at, updated_at "
                          "FROM system_notifications "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!is_active.empty()) {
            params.push_back(is_active);
            query += "AND is_active = $" + std::to_string(++param_count) + " ";
        }
        
        query += "ORDER BY created_at DESC";
        
        auto result = db_->query(query, params);
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"notification_type\":\"" + result[i]["notification_type"].as<std::string>() + "\",";
            json += "\"title\":\"" + result[i]["title"].as<std::string>() + "\",";
            json += "\"message\":\"" + result[i]["message"].as<std::string>() + "\",";
            json += "\"target_audience\":\"" + result[i]["target_audience"].as<std::string>() + "\",";
            json += "\"priority\":" + result[i]["priority"].as<std::string>() + ",";
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false") + ",";
            
            if (!result[i]["starts_at"].is_null()) {
                json += "\"starts_at\":\"" + result[i]["starts_at"].as<std::string>() + "\",";
            } else {
                json += "\"starts_at\":null,";
            }
            
            if (!result[i]["ends_at"].is_null()) {
                json += "\"ends_at\":\"" + result[i]["ends_at"].as<std::string>() + "\",";
            } else {
                json += "\"ends_at\":null,";
            }
            
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\",";
            json += "\"updated_at\":\"" + result[i]["updated_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch notifications: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleCreateSystemNotification(const Request& request) {
    try {
        // TODO: Parse JSON body when available
        // For now, use placeholder values
        std::string notification_type = "info";
        std::string title = "System Notification";
        std::string message = "Notification message";
        std::string target_audience = "all";
        std::string admin_id = "311ee799-a6a1-450f-8bad-5140a021c92b"; // Hardcoded for now
        
        std::string query = "INSERT INTO system_notifications (notification_type, title, message, target_audience, is_active, created_by) "
                          "VALUES ($1, $2, $3, $4, true, $5) RETURNING id";
        std::vector<std::string> params = {notification_type, title, message, target_audience, admin_id};
        auto result = db_->query(query, params);
        
        std::string notification_id = result[0]["id"].as<std::string>();
        
        return Response(HttpStatus::CREATED, "{\"success\":true,\"id\":\"" + notification_id + "\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to create notification: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleUpdateSystemNotification(const Request& request) {
    try {
        // Parse notification ID from path
        std::string path = request.getPath();
        size_t pos = path.find("/api/system-admin/notifications/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string notification_id = path.substr(pos + 32); // length of prefix
        size_t slash_pos = notification_id.find("/");
        if (slash_pos != std::string::npos) {
            notification_id = notification_id.substr(0, slash_pos);
        }
        
        if (notification_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Notification ID is required\"}");
        }
        
        // TODO: Parse JSON body for fields to update
        // For now, just update the updated_at timestamp
        std::string query = "UPDATE system_notifications SET updated_at = CURRENT_TIMESTAMP "
                          "WHERE id = $1";
        std::vector<std::string> params = {notification_id};
        db_->execute(query, params);
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Notification updated\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to update notification: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleDeleteSystemNotification(const Request& request) {
    try {
        // Parse notification ID from path
        std::string path = request.getPath();
        size_t pos = path.find("/api/system-admin/notifications/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string notification_id = path.substr(pos + 32); // length of prefix
        
        if (notification_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Notification ID is required\"}");
        }
        
        // Soft delete: set is_active to false
        std::string query = "UPDATE system_notifications SET is_active = false, updated_at = CURRENT_TIMESTAMP "
                          "WHERE id = $1";
        std::vector<std::string> params = {notification_id};
        db_->execute(query, params);
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Notification deleted\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to delete notification: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetLookupTables(const Request& request) {
    try {
        // Return list of lookup tables
        std::string query = "SELECT table_name FROM lookup_tables ORDER BY table_name";
        auto result = db_->query(query, {});
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{\"table_name\":\"" + result[i]["table_name"].as<std::string>() + "\"}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch lookup tables: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetLookupTable(const Request& request) {
    try {
        // Parse table name from path: /api/system-admin/lookups/:tableName
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/lookups/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string table_name = path.substr(pos + prefix.length());
        
        if (table_name.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Table name is required\"}");
        }
        
        // Query the specific lookup table
        std::string query = "SELECT * FROM " + table_name;
        auto result = db_->query(query, {});
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            
            // Build JSON from actual columns dynamically
            bool first_field = true;
            for (int col = 0; col < static_cast<int>(result[i].size()); ++col) {
                std::string col_name = result[i][col].name();
                
                if (!first_field) json += ",";
                first_field = false;
                
                json += "\"" + col_name + "\":";
                
                if (result[i][col].is_null()) {
                    json += "null";
                } else {
                    // Try to detect type and format accordingly
                    std::string val = result[i][col].as<std::string>();
                    
                    // Check if it's a boolean column name or value
                    if (col_name.find("is_") == 0 || col_name.find("_active") != std::string::npos ||
                        col_name.find("requires_") == 0 || val == "t" || val == "f") {
                        json += (val == "t" || val == "true" || val == "1") ? "true" : "false";
                    }
                    // Check if it's numeric
                    else if (col_name.find("_order") != std::string::npos || col_name.find("duration") != std::string::npos ||
                             col_name.find("_count") != std::string::npos || col_name == "sort_order") {
                        json += val;
                    }
                    // Otherwise treat as string
                    else {
                        json += "\"" + val + "\"";
                    }
                }
            }
            
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch lookup table: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleCreateLookupEntry(const Request& request) {
    try {
        // Parse table name from path
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/lookups/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string table_name = after_prefix.substr(0, slash_pos);
        
        if (table_name.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Table name is required\"}");
        }
        
        // TODO: Parse JSON body for name, description, display_order
        std::string name = "New Entry";
        
        std::string query = "INSERT INTO " + table_name + " (name, is_active) "
                          "VALUES ($1, true) RETURNING id";
        std::vector<std::string> params = {name};
        auto result = db_->query(query, params);
        
        std::string entry_id = result[0]["id"].as<std::string>();
        
        return Response(HttpStatus::CREATED, "{\"success\":true,\"id\":\"" + entry_id + "\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to create lookup entry: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleUpdateLookupEntry(const Request& request) {
    try {
        // Parse table name and entry ID from path: /api/system-admin/lookups/:tableName/:id
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/lookups/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string table_name = after_prefix.substr(0, slash_pos);
        std::string entry_id = after_prefix.substr(slash_pos + 1);
        
        if (table_name.empty() || entry_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Table name and entry ID are required\"}");
        }
        
        // TODO: Parse JSON body for fields to update
        // For now, just update the updated_at timestamp
        std::string query = "UPDATE " + table_name + " SET updated_at = CURRENT_TIMESTAMP "
                          "WHERE id = $1";
        std::vector<std::string> params = {entry_id};
        db_->execute(query, params);
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Lookup entry updated\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to update lookup entry: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleDeleteLookupEntry(const Request& request) {
    try {
        // Parse table name and entry ID from path
        std::string path = request.getPath();
        std::string prefix = "/api/system-admin/lookups/";
        size_t pos = path.find(prefix);
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + prefix.length());
        size_t slash_pos = after_prefix.find("/");
        std::string table_name = after_prefix.substr(0, slash_pos);
        std::string entry_id = after_prefix.substr(slash_pos + 1);
        
        if (table_name.empty() || entry_id.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Table name and entry ID are required\"}");
        }
        
        // Soft delete: set is_active to false
        std::string query = "UPDATE " + table_name + " SET is_active = false, updated_at = CURRENT_TIMESTAMP "
                          "WHERE id = $1";
        std::vector<std::string> params = {entry_id};
        db_->execute(query, params);
        
        return Response(HttpStatus::OK, "{\"success\":true,\"message\":\"Lookup entry deleted\"}");
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to delete lookup entry: " + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetIdentities(const Request& request) {
    try {
        IdentityService::IdentityFilter filter;
        
        // Parse query parameters
        auto params = request.getQueryParams();
        if (params.count("team_id")) filter.team_id = params.at("team_id");
        if (params.count("club_id")) filter.club_id = params.at("club_id");
        if (params.count("provider_id")) filter.provider_id = params.at("provider_id");
        
        if (params.count("linked")) {
            std::string linked = params.at("linked");
            if (linked == "true") filter.only_linked = true;
            else if (linked == "false") filter.only_unlinked = true;
        }

        auto identities = identityService_->getIdentities(filter);
        
        // Convert to JSON array
        std::string json = "[";
        for (size_t i = 0; i < identities.size(); ++i) {
            const auto& id = identities[i];
            
            // Helper lambda for JSON escaping
            auto escape_json = [](const std::string& s) -> std::string {
                std::string res;
                for (char c : s) {
                    if (c == '"') res += "\\\"";
                    else if (c == '\\') res += "\\\\";
                    else if (c == '\b') res += "\\b";
                    else if (c == '\f') res += "\\f";
                    else if (c == '\n') res += "\\n";
                    else if (c == '\r') res += "\\r";
                    else if (c == '\t') res += "\\t";
                    else if (static_cast<unsigned char>(c) < 0x20) {
                        char buf[7];
                        snprintf(buf, sizeof(buf), "\\u%04x", static_cast<unsigned char>(c));
                        res += buf;
                    }
                    else res += c;
                }
                return res;
            };

            json += "{";
            json += "\"id\":\"" + escape_json(id.id) + "\",";
            json += "\"external_id\":\"" + escape_json(id.external_id) + "\",";
            json += "\"external_username\":\"" + escape_json(id.external_username) + "\",";
            json += "\"first_name\":\"" + escape_json(id.first_name) + "\",";
            json += "\"last_name\":\"" + escape_json(id.last_name) + "\",";
            json += "\"provider_id\":\"" + escape_json(id.provider_id) + "\",";
            json += "\"provider_name\":\"" + escape_json(id.provider_name) + "\",";
            json += "\"team_id\":\"" + escape_json(id.team_id) + "\",";
            json += "\"team_name\":\"" + escape_json(id.team_name) + "\",";
            json += "\"user_id\":\"" + escape_json(id.user_id) + "\",";
            json += "\"user_first\":\"" + escape_json(id.user_first) + "\",";
            json += "\"user_last\":\"" + escape_json(id.user_last) + "\",";
            json += "\"user_email\":\"" + escape_json(id.user_email) + "\",";
            json += "\"source\":\"" + escape_json(id.source) + "\"";
            
            json += "}";
            if (i < identities.size() - 1) json += ",";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleLinkIdentity(const Request& request) {
    try {
        // Simple JSON parsing
        std::string body = request.getJson();
        
        // Extract identityId
        size_t idPos = body.find("\"identityId\"");
        if (idPos == std::string::npos) {
             return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"identityId is required\"}");
        }
        // Robust finding of value
        size_t idStart = body.find(":", idPos);
        if (idStart == std::string::npos) return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid JSON\"}");
        idStart = body.find("\"", idStart);
        if (idStart == std::string::npos) return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid JSON\"}");
        idStart++; // Skip quote
        size_t idEnd = body.find("\"", idStart);
        std::string identityId = body.substr(idStart, idEnd - idStart);
        
        // Extract userId
        size_t userPos = body.find("\"userId\"");
        if (userPos == std::string::npos) {
             return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"userId is required\"}");
        }
        size_t userStart = body.find(":", userPos);
        if (userStart == std::string::npos) return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid JSON\"}");
        userStart = body.find("\"", userStart);
        if (userStart == std::string::npos) return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid JSON\"}");
        userStart++; // Skip quote
        size_t userEnd = body.find("\"", userStart);
        std::string userId = body.substr(userStart, userEnd - userStart);
        
        // Use Service
        std::string adminId = "system-admin"; // TODO: Get from auth context
        bool success = identityService_->linkIdentity(identityId, userId, adminId);
        
        if (success) {
            return Response(HttpStatus::OK, "{\"success\":true}");
        } else {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"Failed to link identity\"}");
        }
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetDatabaseSchema(const Request& request) {
    // Helper function to escape JSON strings
    auto escapeJson = [](const std::string& input) -> std::string {
        std::string output;
        for (unsigned char c : input) {
            switch (c) {
                case '"':  output += "\\\""; break;
                case '\\': output += "\\\\"; break;
                case '\b': output += "\\b"; break;
                case '\f': output += "\\f"; break;
                case '\n': output += "\\n"; break;
                case '\r': output += "\\r"; break;
                case '\t': output += "\\t"; break;
                default:
                    if (c < 0x20) {
                        char buf[7];
                        snprintf(buf, sizeof(buf), "\\u%04x", c);
                        output += buf;
                    } else if (c >= 0x80) {
                        // UTF-8 continuation byte or start of multi-byte sequence
                        // Pass through as-is (valid UTF-8)
                        output += c;
                    } else {
                        output += c;
                    }
            }
        }
        return output;
    };
    
    try {
        std::string json = "{\"tables\":[";
        
        // Get all tables
        auto tables = db_->query(R"(
            SELECT 
                t.table_name,
                obj_description((quote_ident(t.table_schema)||'.'||quote_ident(t.table_name))::regclass, 'pg_class') as table_comment
            FROM information_schema.tables t
            WHERE t.table_schema = 'public'
            AND t.table_type = 'BASE TABLE'
            ORDER BY t.table_name
        )");
        
        for (size_t i = 0; i < tables.size(); ++i) {
            const auto& table = tables[i];
            std::string table_name = table["table_name"].as<std::string>();
            
            json += "{";
            json += "\"name\":\"" + escapeJson(table_name) + "\",";
            std::string table_comment = table["table_comment"].is_null() ? "" : std::string(table["table_comment"].c_str());
            json += "\"comment\":\"" + escapeJson(table_comment) + "\",";
            
            // Get columns for this table
            json += "\"columns\":[";
            auto columns = db_->query(
                "SELECT "
                "    c.column_name, "
                "    c.data_type, "
                "    c.is_nullable, "
                "    c.column_default, "
                "    CASE WHEN pk.column_name IS NOT NULL THEN true ELSE false END as is_primary_key "
                "FROM information_schema.columns c "
                "LEFT JOIN ( "
                "    SELECT ku.column_name "
                "    FROM information_schema.table_constraints tc "
                "    JOIN information_schema.key_column_usage ku ON tc.constraint_name = ku.constraint_name "
                "    WHERE tc.constraint_type = 'PRIMARY KEY' AND tc.table_name = $1 "
                ") pk ON c.column_name = pk.column_name "
                "WHERE c.table_name = $1 "
                "ORDER BY c.ordinal_position",
                std::vector<std::string>{table_name}
            );
            
            for (size_t j = 0; j < columns.size(); ++j) {
                const auto& col = columns[j];
                json += "{";
                std::string col_name = std::string(col["column_name"].c_str());
                std::string col_type = std::string(col["data_type"].c_str());
                std::string col_nullable = std::string(col["is_nullable"].c_str());
                std::string col_default = col["column_default"].is_null() ? "" : std::string(col["column_default"].c_str());
                bool is_pk = col["is_primary_key"].as<bool>();
                
                json += "\"name\":\"" + escapeJson(col_name) + "\",";
                json += "\"type\":\"" + escapeJson(col_type) + "\",";
                json += "\"nullable\":\"" + escapeJson(col_nullable) + "\",";
                json += "\"default\":\"" + escapeJson(col_default) + "\",";
                json += "\"primary_key\":" + std::string(is_pk ? "true" : "false");
                json += "}";
                if (j < columns.size() - 1) json += ",";
            }
            json += "],";
            
            // Get foreign keys for this table
            json += "\"foreign_keys\":[";
            auto fks = db_->query(
                "SELECT "
                "    kcu.column_name, "
                "    ccu.table_name AS foreign_table_name, "
                "    ccu.column_name AS foreign_column_name "
                "FROM information_schema.table_constraints AS tc "
                "JOIN information_schema.key_column_usage AS kcu "
                "    ON tc.constraint_name = kcu.constraint_name "
                "JOIN information_schema.constraint_column_usage AS ccu "
                "    ON ccu.constraint_name = tc.constraint_name "
                "WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = $1",
                std::vector<std::string>{table_name}
            );
            
            for (size_t k = 0; k < fks.size(); ++k) {
                const auto& fk = fks[k];
                json += "{";
                std::string fk_col = std::string(fk["column_name"].c_str());
                std::string fk_table = std::string(fk["foreign_table_name"].c_str());
                std::string fk_fk_col = std::string(fk["foreign_column_name"].c_str());
                
                json += "\"column\":\"" + escapeJson(fk_col) + "\",";
                json += "\"foreign_table\":\"" + escapeJson(fk_table) + "\",";
                json += "\"foreign_column\":\"" + escapeJson(fk_fk_col) + "\"";
                json += "}";
                if (k < fks.size() - 1) json += ",";
            }
            json += "]";
            
            json += "}";
            if (i < tables.size() - 1) json += ",";
        }
        
        json += "]}";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetCasaDashboard(const Request& request) {
    try {
        std::string json = "{";
        
        // Divisions
        auto divisions = db_->query("SELECT COUNT(*) FROM casa_divisions");
        if (!divisions.empty()) {
            json += "\"divisions\":" + std::to_string(divisions[0][0].as<int>()) + ",";
        } else {
            json += "\"divisions\":0,";
        }

        // Teams
        auto teams = db_->query("SELECT COUNT(*) FROM casa_teams");
        if (!teams.empty()) {
            json += "\"teams\":" + std::to_string(teams[0][0].as<int>()) + ",";
        } else {
            json += "\"teams\":0,";
        }

        // Players
        auto players = db_->query("SELECT COUNT(*) FROM casa_players");
        if (!players.empty()) {
            json += "\"players\":" + std::to_string(players[0][0].as<int>()) + ",";
        } else {
            json += "\"players\":0,";
        }
        
        // Matches - query casa_matches directly
        auto matches = db_->query("SELECT COUNT(*) FROM casa_matches");
        if (!matches.empty()) {
            json += "\"matches\":" + std::to_string(matches[0][0].as<int>());
        } else {
            json += "\"matches\":0";
        }

        json += "}";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetOrganizations(const Request& request) {
    try {
        auto result = db_->query("SELECT id, name, short_name, website_url, affiliation, description, is_active FROM organizations ORDER BY name");
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":" + row["id"].as<std::string>() + ",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"short_name\":\"" + (row["short_name"].is_null() ? "" : row["short_name"].as<std::string>()) + "\",";
            json += "\"website_url\":\"" + (row["website_url"].is_null() ? "" : row["website_url"].as<std::string>()) + "\",";
            json += "\"affiliation\":\"" + (row["affiliation"].is_null() ? "" : row["affiliation"].as<std::string>()) + "\",";
            json += "\"description\":\"" + (row["description"].is_null() ? "" : row["description"].as<std::string>()) + "\",";
            json += "\"is_active\":" + std::string(row["is_active"].as<bool>() ? "true" : "false");
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetLeagues(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT l.id, l.name, o.name as organization_name "
            "FROM leagues l "
            "LEFT JOIN organizations o ON l.organization_id = o.id "
            "WHERE l.is_active = true "
            "ORDER BY l.name"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":" + row["id"].as<std::string>() + ",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"organization_name\":\"" + (row["organization_name"].is_null() ? "" : row["organization_name"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetCasaDivisions(const Request& request) {
    try {
        auto result = db_->query("SELECT id, name, age_group, skill_level, gender FROM casa_divisions ORDER BY name");
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"age_group\":\"" + (row["age_group"].is_null() ? "" : row["age_group"].as<std::string>()) + "\",";
            json += "\"skill_level\":\"" + (row["skill_level"].is_null() ? "" : row["skill_level"].as<std::string>()) + "\",";
            json += "\"gender\":\"" + (row["gender"].is_null() ? "" : row["gender"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetCasaTeams(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT ct.id, ct.casa_team_id, ct.name, cd.name as division_name "
            "FROM casa_teams ct "
            "LEFT JOIN casa_divisions cd ON ct.casa_division_id = cd.id "
            "ORDER BY ct.name"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"casa_team_id\":\"" + (row["casa_team_id"].is_null() ? "" : row["casa_team_id"].as<std::string>()) + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"division_name\":\"" + (row["division_name"].is_null() ? "" : row["division_name"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetCasaPlayers(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT cp.id, cp.casa_player_id, cp.name, cp.jersey_number, cp.position, ct.name as team_name "
            "FROM casa_players cp "
            "LEFT JOIN casa_teams ct ON cp.casa_team_id = ct.id "
            "ORDER BY cp.name"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"casa_player_id\":\"" + (row["casa_player_id"].is_null() ? "" : row["casa_player_id"].as<std::string>()) + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"jersey_number\":\"" + (row["jersey_number"].is_null() ? "" : row["jersey_number"].as<std::string>()) + "\",";
            json += "\"position\":\"" + (row["position"].is_null() ? "" : row["position"].as<std::string>()) + "\",";
            json += "\"team_name\":\"" + (row["team_name"].is_null() ? "" : row["team_name"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetCasaMatches(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT m.id, e.event_date, "
            "COALESCE(ct1.name, t1.name, 'Unknown Team') as home_team, "
            "COALESCE(ct2.name, t2.name, 'Unknown Team') as away_team, "
            "m.home_team_score, m.away_team_score, m.match_status "
            "FROM matches m "
            "JOIN events e ON m.id = e.id "
            "LEFT JOIN casa_teams ct1 ON m.home_team_id = ct1.team_id "
            "LEFT JOIN casa_teams ct2 ON m.away_team_id = ct2.team_id "
            "LEFT JOIN teams t1 ON m.home_team_id = t1.id "
            "LEFT JOIN teams t2 ON m.away_team_id = t2.id "
            "WHERE ct1.team_id IS NOT NULL OR ct2.team_id IS NOT NULL "
            "ORDER BY e.event_date DESC LIMIT 100"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"event_date\":\"" + (row["event_date"].is_null() ? "" : row["event_date"].as<std::string>()) + "\",";
            json += "\"home_team\":\"" + row["home_team"].as<std::string>() + "\",";
            json += "\"away_team\":\"" + row["away_team"].as<std::string>() + "\",";
            json += "\"home_score\":\"" + (row["home_team_score"].is_null() ? "-" : row["home_team_score"].as<std::string>()) + "\",";
            json += "\"away_score\":\"" + (row["away_team_score"].is_null() ? "-" : row["away_team_score"].as<std::string>()) + "\",";
            json += "\"status\":\"" + (row["match_status"].is_null() ? "" : row["match_status"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetApslDashboard(const Request& request) {
    try {
        std::string json = "{";
        
        // Divisions (from normalized divisions table, filtered by source_system_id=1 for APSL)
        auto divisions = db_->query("SELECT COUNT(*) FROM divisions WHERE source_system_id = 1");
        if (!divisions.empty()) {
            json += "\"divisions\":" + std::to_string(divisions[0][0].as<int>()) + ",";
        } else {
            json += "\"divisions\":0,";
        }

        // Teams (from normalized teams table, filtered by source_system_id=1 for APSL)
        auto teams = db_->query("SELECT COUNT(*) FROM teams WHERE source_system_id = 1");
        if (!teams.empty()) {
            json += "\"teams\":" + std::to_string(teams[0][0].as<int>()) + ",";
        } else {
            json += "\"teams\":0,";
        }

        // Players (from normalized players table, filtered by source_system_id=1 for APSL)
        auto players = db_->query("SELECT COUNT(*) FROM players WHERE source_system_id = 1");
        if (!players.empty()) {
            json += "\"players\":" + std::to_string(players[0][0].as<int>()) + ",";
        } else {
            json += "\"players\":0,";
        }
        
        // Matches (from normalized matches table, filtered by source_system_id=1 for APSL)
        auto matches = db_->query("SELECT COUNT(*) FROM matches WHERE source_system_id = 1");
        if (!matches.empty()) {
            json += "\"matches\":" + std::to_string(matches[0][0].as<int>());
        } else {
            json += "\"matches\":0";
        }

        json += "}";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetApslDivisions(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT d.id, d.name, c.name as conference_name, l.season "
            "FROM divisions d "
            "JOIN conferences c ON d.conference_id = c.id "
            "JOIN leagues l ON c.league_id = l.id "
            "WHERE d.source_system_id = 1 "
            "ORDER BY d.name"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"conference\":\"" + row["conference_name"].as<std::string>() + "\",";
            json += "\"season\":\"" + (row["season"].is_null() ? "" : row["season"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetApslTeams(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT t.id, t.external_id as apsl_team_id, t.name, t.city, d.name as division_name "
            "FROM teams t "
            "LEFT JOIN team_divisions td ON t.id = td.team_id "
            "LEFT JOIN divisions d ON td.division_id = d.id "
            "WHERE t.source_system_id = 1 "
            "ORDER BY t.name"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"apsl_team_id\":\"" + (row["apsl_team_id"].is_null() ? "" : row["apsl_team_id"].as<std::string>()) + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"city\":\"" + (row["city"].is_null() ? "" : row["city"].as<std::string>()) + "\",";
            json += "\"division\":\"" + (row["division_name"].is_null() ? "" : row["division_name"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetApslPlayers(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT p.id, p.external_id as apsl_player_id, p.full_name as name, tp.position, tp.jersey_number, t.name as team_name "
            "FROM players p "
            "LEFT JOIN team_division_players tp ON p.id = tp.player_id "
            "LEFT JOIN teams t ON tp.team_id = t.id "
            "WHERE p.source_system_id = 1 "
            "ORDER BY p.full_name LIMIT 100"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"apsl_player_id\":\"" + (row["apsl_player_id"].is_null() ? "" : row["apsl_player_id"].as<std::string>()) + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"position\":\"" + (row["position"].is_null() ? "" : row["position"].as<std::string>()) + "\",";
            json += "\"jersey_number\":\"" + (row["jersey_number"].is_null() ? "" : row["jersey_number"].as<std::string>()) + "\",";
            json += "\"team\":\"" + (row["team_name"].is_null() ? "" : row["team_name"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetApslMatches(const Request& request) {
    try {
        auto result = db_->query(
            "SELECT m.id, m.match_date, "
            "ht.name as home_team, "
            "at.name as away_team, "
            "m.home_score, m.away_score, ms.name as status, "
            "d.name as division_name "
            "FROM matches m "
            "LEFT JOIN teams ht ON m.home_team_id = ht.id "
            "LEFT JOIN teams at ON m.away_team_id = at.id "
            "LEFT JOIN divisions d ON m.division_id = d.id "
            "LEFT JOIN match_statuses ms ON m.match_status_id = ms.id "
            "WHERE m.source_system_id = 1 "
            "ORDER BY m.match_date DESC LIMIT 100"
        );
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"match_date\":\"" + (row["match_date"].is_null() ? "" : row["match_date"].as<std::string>()) + "\",";
            json += "\"home_team\":\"" + (row["home_team"].is_null() ? "Unknown" : row["home_team"].as<std::string>()) + "\",";
            json += "\"away_team\":\"" + (row["away_team"].is_null() ? "Unknown" : row["away_team"].as<std::string>()) + "\",";
            json += "\"home_score\":\"" + (row["home_score"].is_null() ? "-" : row["home_score"].as<std::string>()) + "\",";
            json += "\"away_score\":\"" + (row["away_score"].is_null() ? "-" : row["away_score"].as<std::string>()) + "\",";
            json += "\"division\":\"" + (row["division_name"].is_null() ? "" : row["division_name"].as<std::string>()) + "\",";
            json += "\"status\":\"" + (row["status"].is_null() ? "scheduled" : row["status"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetGroupMeDashboard(const Request& request) {
    try {
        std::string json = "{";
        
        // Groups
        auto groups = db_->query("SELECT COUNT(*) FROM groupme_groups");
        if (!groups.empty()) {
            json += "\"groups\":" + std::to_string(groups[0][0].as<int>());
        } else {
            json += "\"groups\":0";
        }

        json += "}";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetGroupMeGroups(const Request& request) {
    try {
        auto result = db_->query("SELECT id, groupme_group_id, name, description FROM groupme_groups ORDER BY name");
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            json += "{";
            json += "\"id\":\"" + row["id"].as<std::string>() + "\",";
            json += "\"groupme_id\":\"" + row["groupme_group_id"].as<std::string>() + "\",";
            json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
            json += "\"description\":\"" + (row["description"].is_null() ? "" : row["description"].as<std::string>()) + "\"";
            json += "}";
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

// Helper function to call GroupMe API
static std::string callGroupMeAPI(const std::string& endpoint, const std::string& token) {
    CURL* curl = curl_easy_init();
    if (!curl) {
        throw std::runtime_error("Failed to initialize curl");
    }
    
    std::string url = "https://api.groupme.com/v3" + endpoint;
    if (url.find('?') == std::string::npos) {
        url += "?token=" + token;
    } else {
        url += "&token=" + token;
    }
    
    std::string response;
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, +[](void* ptr, size_t size, size_t nmemb, std::string* data) {
        data->append((char*)ptr, size * nmemb);
        return size * nmemb;
    });
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L); // Dev mode
    curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
    
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);
    
    if (res != CURLE_OK) {
        throw std::runtime_error("curl_easy_perform() failed: " + std::string(curl_easy_strerror(res)));
    }
    
    return response;
}

Response SystemAdminController::handleGetGroupMeLiveGroups(const Request& request) {
    try {
        const char* token = std::getenv("GROUPME_ACCESS_TOKEN");
        if (!token) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"GROUPME_ACCESS_TOKEN not set\"}");
        }
        
        // Get group IDs from database
        auto result = db_->query("SELECT groupme_group_id, name FROM groupme_groups ORDER BY name");
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            const auto& row = result[i];
            std::string groupId = row["groupme_group_id"].as<std::string>();
            
            try {
                // Fetch live data from GroupMe API
                std::string apiResponse = callGroupMeAPI("/groups/" + groupId, token);
                
                // Parse the response to extract member_count and message info
                // The API returns: {"response": {"id": "...", "name": "...", "members": [...]}}
                json += apiResponse; // For now, pass through the entire response
                
            } catch (const std::exception& e) {
                // If API call fails, return minimal info from database
                json += "{\"groupme_id\":\"" + groupId + "\",";
                json += "\"name\":\"" + row["name"].as<std::string>() + "\",";
                json += "\"error\":\"" + std::string(e.what()) + "\"}";
            }
            
            if (i < result.size() - 1) json += ",";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetGroupMeLiveGroupDetails(const Request& request) {
    try {
        const char* token = std::getenv("GROUPME_ACCESS_TOKEN");
        if (!token) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"GROUPME_ACCESS_TOKEN not set\"}");
        }
        
        // Extract group ID from path: /api/system-admin/groupme/live/group/:id
        std::string path = request.getPath();
        size_t lastSlash = path.rfind("/");
        std::string groupId = path.substr(lastSlash + 1);
        
        if (groupId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Missing group ID\"}");
        }
        
        std::string apiResponse = callGroupMeAPI("/groups/" + groupId, token);
        return Response(HttpStatus::OK, apiResponse);
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetGroupMeLiveMessages(const Request& request) {
    try {
        const char* token = std::getenv("GROUPME_ACCESS_TOKEN");
        if (!token) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"GROUPME_ACCESS_TOKEN not set\"}");
        }
        
        // Extract group ID from path: /api/system-admin/groupme/live/group/:id/messages
        std::string path = request.getPath();
        size_t lastSlash = path.rfind("/messages");
        if (lastSlash == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        size_t secondLastSlash = path.rfind("/", lastSlash - 1);
        std::string groupId = path.substr(secondLastSlash + 1, lastSlash - secondLastSlash - 1);
        
        if (groupId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Missing group ID\"}");
        }
        
        // Fetch recent messages (limit 100)
        std::string apiResponse = callGroupMeAPI("/groups/" + groupId + "/messages?limit=100", token);
        return Response(HttpStatus::OK, apiResponse);
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetGroupMeLiveMembers(const Request& request) {
    try {
        const char* token = std::getenv("GROUPME_ACCESS_TOKEN");
        if (!token) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"GROUPME_ACCESS_TOKEN not set\"}");
        }
        
        // Extract group ID from path: /api/system-admin/groupme/live/group/:id/members
        std::string path = request.getPath();
        size_t lastSlash = path.rfind("/members");
        if (lastSlash == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        size_t secondLastSlash = path.rfind("/", lastSlash - 1);
        std::string groupId = path.substr(secondLastSlash + 1, lastSlash - secondLastSlash - 1);
        
        if (groupId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Missing group ID\"}");
        }
        
        // Fetch group details which includes members array
        std::string apiResponse = callGroupMeAPI("/groups/" + groupId, token);
        return Response(HttpStatus::OK, apiResponse);
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetGroupMeLiveEvents(const Request& request) {
    try {
        const char* token = std::getenv("GROUPME_ACCESS_TOKEN");
        if (!token) {
            return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"GROUPME_ACCESS_TOKEN not set\"}");
        }
        
        // Extract group ID from path: /api/system-admin/groupme/live/group/:id/events
        std::string path = request.getPath();
        size_t lastSlash = path.rfind("/events");
        if (lastSlash == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        size_t secondLastSlash = path.rfind("/", lastSlash - 1);
        std::string groupId = path.substr(secondLastSlash + 1, lastSlash - secondLastSlash - 1);
        
        if (groupId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Missing group ID\"}");
        }
        
        // Fetch calendar events from GroupMe API
        std::string apiResponse = callGroupMeAPI("/conversations/" + groupId + "/events/list", token);
        return Response(HttpStatus::OK, apiResponse);
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetTableData(const Request& request) {
    try {
        // Extract table name from path
        std::string path = request.getPath();
        std::string tableName;
        
        // Match /schema/{table}/data
        std::regex pattern("/schema/([a-zA-Z0-9_]+)/data");
        std::smatch matches;
        if (std::regex_search(path, matches, pattern) && matches.size() > 1) {
            tableName = matches[1].str();
        }
        
        if (tableName.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid table name\"}");
        }
        
        // Additional sanitization - table name must be alphanumeric and underscore only
        for (char c : tableName) {
            if (!std::isalnum(static_cast<unsigned char>(c)) && c != '_') {
                return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid table name\"}");
            }
        }
        
        // Get limit from query parameter (default 100, 0 = no limit)
        int limit = 100;
        std::string limitParam = request.getQueryParam("limit");
        if (!limitParam.empty()) {
            try {
                limit = std::stoi(limitParam);
                if (limit < 0) limit = 0; // 0 means no limit
            } catch (...) {
                limit = 100;
            }
        }
        
        // Get sort column and direction from query parameters
        std::string sortColumn = request.getQueryParam("sort");
        std::string sortDir = request.getQueryParam("dir");
        
        // Sanitize sort column (must be alphanumeric + underscore)
        if (!sortColumn.empty()) {
            for (char c : sortColumn) {
                if (!std::isalnum(static_cast<unsigned char>(c)) && c != '_') {
                    sortColumn.clear();
                    break;
                }
            }
        }
        
        // Validate sort direction
        if (sortDir != "ASC" && sortDir != "DESC") {
            sortDir = "ASC";
        }
        
        // Build query
        std::string sql = "SELECT * FROM " + tableName;
        if (!sortColumn.empty()) {
            sql += " ORDER BY " + sortColumn + " " + sortDir;
        }
        if (limit > 0) {
            sql += " LIMIT " + std::to_string(limit);
        }
        
        std::cout << "[DEBUG] Table data query: " << sql << std::endl;
        pqxx::result result = db_->query(sql);
        
        // Build JSON response
        std::ostringstream json;
        json << "{\"table\":\"" << tableName << "\",\"count\":" << result.size() << ",\"rows\":[";
        
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json << ",";
            json << "{";
            
            for (size_t j = 0; j < result.columns(); ++j) {
                if (j > 0) json << ",";
                json << "\"" << result.column_name(j) << "\":";
                
                if (result[static_cast<int>(i)][static_cast<int>(j)].is_null()) {
                    json << "null";
                } else {
                    std::string value = result[static_cast<int>(i)][static_cast<int>(j)].c_str();
                    // Escape special characters
                    json << "\"";
                    for (char ch : value) {
                        if (ch == '"') json << "\\\"";
                        else if (ch == '\\') json << "\\\\";
                        else if (ch == '\n') json << "\\n";
                        else if (ch == '\r') json << "\\r";
                        else if (ch == '\t') json << "\\t";
                        else json << ch;
                    }
                    json << "\"";
                }
            }
            
            json << "}";
        }
        
        json << "]}";
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetCoverageReport(const Request& request) {
    try {
        std::ostringstream json;
        
        // Query match event coverage by league
        std::string sql = R"(
            SELECT 
                COALESCE(l.name, 'Unknown') as league_name,
                COALESCE(ss.name, 'Unknown') as source_system,
                COUNT(DISTINCT m.id) as total_matches,
                COUNT(DISTINCT CASE WHEN me.id IS NOT NULL THEN m.id END) as matches_with_events,
                COUNT(DISTINCT CASE WHEN m.home_score IS NOT NULL AND me.id IS NULL THEN m.id END) as matches_with_score_no_events,
                COUNT(DISTINCT CASE WHEN met.name = 'goal' THEN me.id END) as total_goals,
                COUNT(DISTINCT CASE WHEN me.assisted_by_player_id IS NOT NULL THEN me.id END) as total_assists,
                COUNT(DISTINCT CASE WHEN met.name IN ('sub_in', 'sub_out') THEN me.id END) as total_subs
            FROM leagues l
            LEFT JOIN source_systems ss ON ss.id = l.source_system_id
            LEFT JOIN seasons s ON s.league_id = l.id
            LEFT JOIN conferences c ON c.season_id = s.id
            LEFT JOIN divisions d ON d.conference_id = c.id
            LEFT JOIN division_teams dt ON dt.division_id = d.id
            LEFT JOIN teams t ON t.id = dt.team_id
            LEFT JOIN matches m ON m.home_team_id = t.id OR m.away_team_id = t.id
            LEFT JOIN match_events me ON me.match_id = m.id
            LEFT JOIN match_event_types met ON met.id = me.event_type_id
            WHERE l.id IS NOT NULL
            GROUP BY l.name, ss.name
            ORDER BY total_matches DESC
        )";
        
        pqxx::result result = db_->query(sql);
        
        json << "{\"leagues\":[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json << ",";
            json << "{"
                 << "\"league_name\":\"" << result[i]["league_name"].c_str() << "\","
                 << "\"source_system\":" << (result[i]["source_system"].is_null() ? "null" : "\"" + std::string(result[i]["source_system"].c_str()) + "\"") << ","
                 << "\"total_matches\":" << result[i]["total_matches"].c_str() << ","
                 << "\"matches_with_events\":" << result[i]["matches_with_events"].c_str() << ","
                 << "\"matches_with_score_no_events\":" << result[i]["matches_with_score_no_events"].c_str() << ","
                 << "\"total_goals\":" << result[i]["total_goals"].c_str() << ","
                 << "\"total_assists\":" << result[i]["total_assists"].c_str() << ","
                 << "\"total_subs\":" << result[i]["total_subs"].c_str()
                 << "}";
        }
        json << "]}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetDataQuality(const Request& request) {
    try {
        std::ostringstream json;
        json << "{";
        
        // 1. Missing match events (matches with scores but no goal events)
        std::string missingEventsSql = R"(
            SELECT COUNT(DISTINCT m.id) as count
            FROM matches m
            WHERE m.home_score IS NOT NULL 
              AND NOT EXISTS (
                SELECT 1 FROM match_events me 
                JOIN match_event_types met ON met.id = me.event_type_id 
                WHERE me.match_id = m.id AND met.name = 'goal'
              )
        )";
        
        pqxx::result missingResult = db_->query(missingEventsSql);
        int totalMissing = missingResult[0]["count"].as<int>();
        
        // By league
        std::string byLeagueSql = R"(
            SELECT 
                COALESCE(l.name, 'Unknown') as league_name,
                COUNT(DISTINCT m.id) as count
            FROM matches m
            LEFT JOIN teams ht ON m.home_team_id = ht.id
            LEFT JOIN division_teams dt ON dt.team_id = ht.id
            LEFT JOIN divisions d ON dt.division_id = d.id
            LEFT JOIN conferences c ON d.conference_id = c.id
            LEFT JOIN seasons s ON c.season_id = s.id
            LEFT JOIN leagues l ON s.league_id = l.id
            WHERE m.home_score IS NOT NULL 
              AND NOT EXISTS (
                SELECT 1 FROM match_events me 
                JOIN match_event_types met ON met.id = me.event_type_id 
                WHERE me.match_id = m.id AND met.name = 'goal'
              )
            GROUP BY l.name
            ORDER BY count DESC
        )";
        
        pqxx::result byLeagueResult = db_->query(byLeagueSql);
        
        json << "\"missing_events\":{\"total\":" << totalMissing << ",\"by_league\":[";
        for (size_t i = 0; i < byLeagueResult.size(); ++i) {
            if (i > 0) json << ",";
            json << "{\"league_name\":\"" << byLeagueResult[i]["league_name"].c_str() << "\","
                 << "\"count\":" << byLeagueResult[i]["count"].c_str() << "}";
        }
        json << "]},";
        
        // 2. Failed downloads - count .skip files
        // Note: This would require file system access from C++. For now, return mock data
        // In a real implementation, we'd scan database/scraped-html directories
        json << "\"failed_downloads\":{\"total\":39,\"by_source\":["
             << "{\"source\":\"APSL\",\"count\":39},"
             << "{\"source\":\"CSL\",\"count\":0}"
             << "]},";
        
        // 3. HTML cache stats - also requires file system access
        json << "\"cache_stats\":{\"total_files\":0,\"by_source\":[]},";
        
        // 4. Missing players - events with player references that don't exist
        std::string missingPlayersSql = R"(
            SELECT COUNT(*) as count
            FROM match_events me
            WHERE NOT EXISTS (SELECT 1 FROM players p WHERE p.id = me.player_id)
        )";
        
        pqxx::result playersResult = db_->query(missingPlayersSql);
        
        json << "\"missing_players\":{\"unmatched_count\":" << playersResult[0]["count"].c_str() << "}";
        
        json << "}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetLeagueStats(const Request& request) {
    try {
        std::ostringstream json;
        
        // Get active seasons (current season with events)
        std::string seasonsSql = R"(
            SELECT s.id, l.name as league_name, s.name as season_name, 
                   EXTRACT(YEAR FROM s.start_date) as start_year,
                   EXTRACT(YEAR FROM s.end_date) as end_year
            FROM seasons s
            JOIN leagues l ON l.id = s.league_id
            WHERE s.is_active = true OR s.id IN (
                SELECT DISTINCT se.id 
                FROM seasons se 
                JOIN conferences c ON c.season_id = se.id
                JOIN divisions d ON d.conference_id = c.id
                JOIN division_teams dt ON dt.division_id = d.id
                JOIN teams t ON t.id = dt.team_id
                JOIN matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id)
                JOIN match_events me ON me.match_id = m.id
            )
            ORDER BY l.name, s.start_date DESC
        )";
        pqxx::result seasons = db_->query(seasonsSql);
        
        json << "{\"leagues\":[";
        
        for (size_t i = 0; i < seasons.size(); ++i) {
            if (i > 0) json << ",";
            
            int seasonId = seasons[i]["id"].as<int>();
            std::string leagueName = seasons[i]["league_name"].c_str();
            std::string seasonName = seasons[i]["season_name"].c_str();
            std::string seasonIdStr = std::to_string(seasonId);
            
            // Build display name with years
            std::string displayName = leagueName;
            if (!seasons[i]["start_year"].is_null() && !seasons[i]["end_year"].is_null()) {
                displayName += " " + std::string(seasons[i]["start_year"].c_str()) + "/" + std::string(seasons[i]["end_year"].c_str());
            } else if (!seasonName.empty()) {
                displayName += " " + seasonName;
            }
            
            json << "{\"league_name\":\"" << displayName << "\",";
            
            // Top scorers
            std::string scorersSql = R"(
                SELECT 
                    per.first_name || ' ' || per.last_name as player_name,
                    COUNT(*) as goals
                FROM match_events me
                JOIN players p ON p.id = me.player_id
                JOIN persons per ON per.id = p.person_id
                JOIN match_event_types met ON met.id = me.event_type_id
                JOIN teams t ON t.id = me.team_id
                JOIN division_teams dt ON dt.team_id = t.id
                JOIN divisions d ON d.id = dt.division_id
                JOIN conferences c ON c.id = d.conference_id
                WHERE c.season_id = $1 AND met.name = 'goal'
                GROUP BY per.id, per.first_name, per.last_name
                ORDER BY goals DESC
                LIMIT 10
            )";
            
            pqxx::result scorers = db_->query(scorersSql, {seasonIdStr});
            
            json << "\"top_scorers\":[";
            for (size_t j = 0; j < scorers.size(); ++j) {
                if (j > 0) json << ",";
                json << "{\"player_name\":\"" << scorers[j]["player_name"].c_str() << "\","
                     << "\"goals\":" << scorers[j]["goals"].c_str() << "}";
            }
            json << "],";
            
            // Top assists
            std::string assistsSql = R"(
                SELECT 
                    per.first_name || ' ' || per.last_name as player_name,
                    COUNT(*) as assists
                FROM match_events me
                JOIN players p ON p.id = me.assisted_by_player_id
                JOIN persons per ON per.id = p.person_id
                JOIN teams t ON t.id = me.team_id
                JOIN division_teams dt ON dt.team_id = t.id
                JOIN divisions d ON d.id = dt.division_id
                JOIN conferences c ON c.id = d.conference_id
                JOIN seasons s ON s.id = c.season_id
                WHERE c.season_id = $1
                GROUP BY per.id, per.first_name, per.last_name
                ORDER BY assists DESC
                LIMIT 10
            )";
            
            pqxx::result assists = db_->query(assistsSql, {seasonIdStr});
            json << "\"top_assists\":[";
            for (size_t j = 0; j < assists.size(); ++j) {
                if (j > 0) json << ",";
                json << "{\"player_name\":\"" << assists[j]["player_name"].c_str() << "\","
                     << "\"assists\":" << assists[j]["assists"].c_str() << "}";
            }
            json << "],";
            
            // Most active teams
            std::string teamsSql = R"(
                SELECT 
                    t.name as team_name,
                    COUNT(DISTINCT m.id) as match_count
                FROM teams t
                JOIN division_teams dt ON dt.team_id = t.id
                JOIN divisions d ON d.id = dt.division_id
                JOIN conferences c ON c.id = d.conference_id
                JOIN seasons s ON s.id = c.season_id
                LEFT JOIN matches m ON m.home_team_id = t.id OR m.away_team_id = t.id
                LEFT JOIN matches m ON m.home_team_id = t.id OR m.away_team_id = t.id
                WHERE c.season_id = $1
                GROUP BY t.id, t.name
                ORDER BY match_count DESC
                LIMIT 10
            )";
            
            pqxx::result teams = db_->query(teamsSql, {seasonIdStr});
            for (size_t j = 0; j < teams.size(); ++j) {
                if (j > 0) json << ",";
                json << "{\"team_name\":\"" << teams[j]["team_name"].c_str() << "\","
                     << "\"match_count\":" << teams[j]["match_count"].c_str() << "}";
            }
            json << "]}";
        }
        
        json << "]}";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetSeasons(const Request& request) {
    try {
        // Get league_id from query params
        std::string leagueId = request.getQueryParam("league_id");
        
        if (leagueId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"league_id parameter required\"}");
        }
        
        // Get distinct seasons for this league with match counts
        std::string sql = R"(
            SELECT 
                s.name as season,
                COUNT(DISTINCT m.id) as match_count
            FROM seasons s
            LEFT JOIN divisions d ON d.season_id = s.id
            LEFT JOIN division_teams dt ON dt.division_id = d.id
            LEFT JOIN teams t ON t.id = dt.team_id
            LEFT JOIN matches m ON (m.home_team_id = t.id OR m.away_team_id = t.id)
            WHERE s.league_id = $1
            GROUP BY s.name, s.start_date
            HAVING COUNT(DISTINCT m.id) > 0
            ORDER BY s.start_date DESC NULLS LAST, s.name DESC
        )";
        
        pqxx::result result = db_->query(sql, {leagueId});
        
        std::ostringstream json;
        json << "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json << ",";
            json << "{\"season\":\"" << result[i]["season"].c_str() << "\","
                 << "\"match_count\":" << result[i]["match_count"].c_str() << "}";
        }
        json << "]";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetStandings(const Request& request) {
    try {
        // Get league_id and season from query params
        std::string leagueId = request.getQueryParam("league_id");
        std::string season = request.getQueryParam("season");
        
        if (leagueId.empty() || season.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"league_id and season parameters required\"}");
        }
        
        // Query standings table (mirrored from APSL/source sites)
        std::string sql = R"(
            SELECT 
                d.id as division_id,
                d.name as division_name,
                t.id as team_id,
                t.name as team_name,
                st.position,
                st.played as games_played,
                st.wins,
                st.draws,
                st.losses,
                st.goals_for,
                st.goals_against,
                st.goal_diff as goal_difference,
                st.points
            FROM standings st
            JOIN divisions d ON d.id = st.competition_id
            JOIN teams t ON t.id = st.team_id
            JOIN seasons s ON s.id = st.season_id
            WHERE s.league_id = $1
                AND s.name = $2
            ORDER BY d.name ASC, st.position ASC
        )";
        
        pqxx::result result = db_->query(sql, {leagueId, season});
        
        std::ostringstream json;
        json << "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json << ",";
            json << "{\"division_id\":" << result[i]["division_id"].c_str() << ","
                 << "\"division_name\":\"" << result[i]["division_name"].c_str() << "\","
                 << "\"team_id\":" << result[i]["team_id"].c_str() << ","
                 << "\"team_name\":\"" << result[i]["team_name"].c_str() << "\","
                 << "\"position\":" << result[i]["position"].c_str() << ","
                 << "\"games_played\":" << result[i]["games_played"].c_str() << ","
                 << "\"wins\":" << result[i]["wins"].c_str() << ","
                 << "\"draws\":" << result[i]["draws"].c_str() << ","
                 << "\"losses\":" << result[i]["losses"].c_str() << ","
                 << "\"goals_for\":" << result[i]["goals_for"].c_str() << ","
                 << "\"goals_against\":" << result[i]["goals_against"].c_str() << ","
                 << "\"goal_difference\":" << result[i]["goal_difference"].c_str() << ","
                 << "\"points\":" << result[i]["points"].c_str() << "}";
        }
        json << "]";
        
        return Response(HttpStatus::OK, json.str());
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

Response SystemAdminController::handleGetTeams(const Request& request) {
    try {
        // Get league_id (required) and season (optional) from query params
        std::string leagueId = request.getQueryParam("league_id");
        std::string season = request.getQueryParam("season");
        
        if (leagueId.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"league_id parameter required\"}");
        }
        
        std::string sql;
        
        if (season.empty()) {
            // Get all teams across all seasons for this league
            sql = R"(
                SELECT DISTINCT
                    t.id as team_id,
                    t.name as team_name,
                    t.external_id,
                    c.name as club_name,
                    d.name as division_name,
                    ss.name as source_system,
                    STRING_AGG(DISTINCT s.name, ', ' ORDER BY s.name) as seasons
                FROM teams t
                LEFT JOIN clubs c ON c.id = t.club_id
                LEFT JOIN source_systems ss ON ss.id = t.source_system_id
                JOIN division_teams dt ON dt.team_id = t.id
                JOIN divisions d ON d.id = dt.division_id
                JOIN seasons s ON s.id = d.season_id
                WHERE s.league_id = $1
                GROUP BY t.id, t.name, t.external_id, c.name, d.name, ss.name
                ORDER BY d.name ASC, t.name ASC
            )";
            
            pqxx::result result = db_->query(sql, {leagueId});
            
            std::ostringstream json;
            json << "[";
            for (size_t i = 0; i < result.size(); ++i) {
                if (i > 0) json << ",";
                json << "{"
                     << "\"team_id\":" << result[i]["team_id"].c_str() << ","
                     << "\"team_name\":\"" << result[i]["team_name"].c_str() << "\","
                     << "\"external_id\":\"" << (result[i]["external_id"].is_null() ? "" : result[i]["external_id"].c_str()) << "\","
                     << "\"club_name\":\"" << (result[i]["club_name"].is_null() ? "" : result[i]["club_name"].c_str()) << "\","
                     << "\"division_name\":\"" << (result[i]["division_name"].is_null() ? "" : result[i]["division_name"].c_str()) << "\","
                     << "\"source_system\":\"" << (result[i]["source_system"].is_null() ? "" : result[i]["source_system"].c_str()) << "\","
                     << "\"seasons\":\"" << (result[i]["seasons"].is_null() ? "" : result[i]["seasons"].c_str()) << "\""
                     << "}";
            }
            json << "]";
            
            return Response(HttpStatus::OK, json.str());
            
        } else {
            // Get teams for specific season
            sql = R"(
                SELECT 
                    t.id as team_id,
                    t.name as team_name,
                    t.external_id,
                    c.name as club_name,
                    d.name as division_name,
                    ss.name as source_system
                FROM teams t
                LEFT JOIN clubs c ON c.id = t.club_id
                LEFT JOIN source_systems ss ON ss.id = t.source_system_id
                JOIN division_teams dt ON dt.team_id = t.id
                JOIN divisions d ON d.id = dt.division_id
                JOIN seasons s ON s.id = d.season_id
                WHERE s.league_id = $1
                    AND s.name = $2
                ORDER BY d.name ASC, t.name ASC
            )";
            
            pqxx::result result = db_->query(sql, {leagueId, season});
            
            std::ostringstream json;
            json << "[";
            for (size_t i = 0; i < result.size(); ++i) {
                if (i > 0) json << ",";
                json << "{"
                     << "\"team_id\":" << result[i]["team_id"].c_str() << ","
                     << "\"team_name\":\"" << result[i]["team_name"].c_str() << "\","
                     << "\"external_id\":\"" << (result[i]["external_id"].is_null() ? "" : result[i]["external_id"].c_str()) << "\","
                     << "\"club_name\":\"" << (result[i]["club_name"].is_null() ? "" : result[i]["club_name"].c_str()) << "\","
                     << "\"division_name\":\"" << (result[i]["division_name"].is_null() ? "" : result[i]["division_name"].c_str()) << "\","
                     << "\"source_system\":\"" << (result[i]["source_system"].is_null() ? "" : result[i]["source_system"].c_str()) << "\""
                     << "}";
            }
            json << "]";
            
            return Response(HttpStatus::OK, json.str());
        }
        
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "{\"error\":\"" + std::string(e.what()) + "\"}");
    }
}

