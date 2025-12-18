#include "SystemAdminController.h"
#include <sstream>
#include <regex>
#include <iostream>

SystemAdminController::SystemAdminController() {
    db_ = Database::getInstance();
}

void SystemAdminController::registerRoutes(Router& router, const std::string& prefix) {
    std::cout << "📋 Registering system admin routes with prefix: " << prefix << std::endl;
    
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

Response SystemAdminController::handleGetDashboard(const Request& request) {
    try {
        std::cout << "📊 Getting super admin dashboard..." << std::endl;
        
        // Get counts
        std::string users_query = "SELECT COUNT(*) as count FROM users WHERE is_active = true";
        std::string teams_query = "SELECT COUNT(*) as count FROM teams WHERE is_active = true";
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
        // Parse query parameters for pagination
        std::string limit = request.getQueryParam("limit");
        if (limit.empty()) limit = "50";
        std::string offset = request.getQueryParam("offset");
        if (offset.empty()) offset = "0";
        
        std::string query = "SELECT u.id, u.email, u.first_name, u.last_name, u.is_active, u.created_at FROM users u "
                          "ORDER BY u.created_at DESC LIMIT $1 OFFSET $2";
        std::vector<std::string> params = {limit, offset};
        auto result = db_->query(query, params);
        
        // Build JSON array
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"email\":\"" + result[i]["email"].as<std::string>() + "\",";
            json += "\"first_name\":\"" + result[i]["first_name"].as<std::string>() + "\",";
            json += "\"last_name\":\"" + result[i]["last_name"].as<std::string>() + "\",";
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false") + ",";
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
            json += "}";
        }
        json += "]";
        
        return Response(HttpStatus::OK, json);
    } catch (const std::exception& e) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, 
                       "{\"error\":\"Failed to fetch users: " + std::string(e.what()) + "\"}");
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
                          "sa.created_at, sa.updated_at, "
                          "u.email, u.first_name, u.last_name, "
                          "appointer.first_name as appointer_first_name, appointer.last_name as appointer_last_name "
                          "FROM system_admins sa "
                          "JOIN users u ON sa.user_id = u.id "
                          "LEFT JOIN users appointer ON sa.appointed_by = appointer.id "
                          "WHERE sa.is_active = true "
                          "ORDER BY sa.created_at DESC";
        
        auto result = db_->query(query, {});
        
        // Build JSON array
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"user_id\":\"" + result[i]["user_id"].as<std::string>() + "\",";
            json += "\"email\":\"" + result[i]["email"].as<std::string>() + "\",";
            json += "\"first_name\":\"" + result[i]["first_name"].as<std::string>() + "\",";
            json += "\"last_name\":\"" + result[i]["last_name"].as<std::string>() + "\",";
            json += "\"appointed_by\":\"" + result[i]["appointed_by"].as<std::string>() + "\",";
            
            // Appointer name (may be null)
            if (!result[i]["appointer_first_name"].is_null()) {
                json += "\"appointer_first_name\":\"" + result[i]["appointer_first_name"].as<std::string>() + "\",";
                json += "\"appointer_last_name\":\"" + result[i]["appointer_last_name"].as<std::string>() + "\",";
            } else {
                json += "\"appointer_first_name\":null,";
                json += "\"appointer_last_name\":null,";
            }
            
            json += "\"notes\":\"" + result[i]["notes"].as<std::string>() + "\",";
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false") + ",";
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\",";
            json += "\"updated_at\":\"" + result[i]["updated_at"].as<std::string>() + "\"";
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
                          "ON CONFLICT (user_id) DO UPDATE SET is_active = true, appointed_by = $2, notes = $3, updated_at = CURRENT_TIMESTAMP "
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
        std::string query = "UPDATE system_admins SET is_active = false, updated_at = CURRENT_TIMESTAMP "
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
        std::string table_name = request.getQueryParam("table_name");
        
        // Build query with optional filters
        std::string query = "SELECT sal.id, sal.admin_id, sal.action_type, sal.table_name, sal.record_id, "
                          "sal.old_values, sal.new_values, sal.created_at, "
                          "u.email, u.first_name, u.last_name "
                          "FROM system_audit_log sal "
                          "JOIN users u ON sal.admin_id = u.id "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!action_type.empty()) {
            params.push_back(action_type);
            query += "AND sal.action_type = $" + std::to_string(++param_count) + " ";
        }
        
        if (!table_name.empty()) {
            params.push_back(table_name);
            query += "AND sal.table_name = $" + std::to_string(++param_count) + " ";
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
            json += "\"admin_id\":\"" + result[i]["admin_id"].as<std::string>() + "\",";
            json += "\"admin_email\":\"" + result[i]["email"].as<std::string>() + "\",";
            json += "\"admin_name\":\"" + result[i]["first_name"].as<std::string>() + " " + result[i]["last_name"].as<std::string>() + "\",";
            json += "\"action_type\":\"" + result[i]["action_type"].as<std::string>() + "\",";
            json += "\"table_name\":\"" + result[i]["table_name"].as<std::string>() + "\",";
            json += "\"record_id\":\"" + result[i]["record_id"].as<std::string>() + "\",";
            json += "\"old_values\":" + result[i]["old_values"].as<std::string>() + ",";
            json += "\"new_values\":" + result[i]["new_values"].as<std::string>() + ",";
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
        
        std::string query = "SELECT id, job_type, status, total_records, processed_records, "
                          "error_message, started_at, completed_at, created_at "
                          "FROM import_jobs "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!status.empty()) {
            params.push_back(status);
            query += "AND status = $" + std::to_string(++param_count) + " ";
        }
        
        query += "ORDER BY created_at DESC ";
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
            json += "\"status\":\"" + result[i]["status"].as<std::string>() + "\",";
            json += "\"total_records\":" + result[i]["total_records"].as<std::string>() + ",";
            json += "\"processed_records\":" + result[i]["processed_records"].as<std::string>() + ",";
            
            if (!result[i]["error_message"].is_null()) {
                json += "\"error_message\":\"" + result[i]["error_message"].as<std::string>() + "\",";
            } else {
                json += "\"error_message\":null,";
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
        
        std::string query = "INSERT INTO import_jobs (job_type, status, total_records, processed_records) "
                          "VALUES ($1, 'pending', 0, 0) RETURNING id";
        std::vector<std::string> params = {job_type};
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
        
        std::string query = "SELECT id, scraper_type, status, records_scraped, error_message, "
                          "started_at, completed_at, created_at "
                          "FROM scraper_logs "
                          "WHERE 1=1 ";
        
        std::vector<std::string> params;
        int param_count = 0;
        
        if (!scraper_type.empty()) {
            params.push_back(scraper_type);
            query += "AND scraper_type = $" + std::to_string(++param_count) + " ";
        }
        
        query += "ORDER BY created_at DESC ";
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
            json += "\"scraper_type\":\"" + result[i]["scraper_type"].as<std::string>() + "\",";
            json += "\"status\":\"" + result[i]["status"].as<std::string>() + "\",";
            json += "\"records_scraped\":" + result[i]["records_scraped"].as<std::string>() + ",";
            
            if (!result[i]["error_message"].is_null()) {
                json += "\"error_message\":\"" + result[i]["error_message"].as<std::string>() + "\",";
            } else {
                json += "\"error_message\":null,";
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
        std::string query = "INSERT INTO scraper_logs (scraper_type, status, records_scraped, started_at) "
                          "VALUES ($1, 'running', 0, CURRENT_TIMESTAMP) RETURNING id";
        std::vector<std::string> params = {scraper_type};
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
        
        std::string query = "SELECT id, notification_type, title, message, severity, is_active, "
                          "display_from, display_until, created_at "
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
            json += "\"severity\":\"" + result[i]["severity"].as<std::string>() + "\",";
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false") + ",";
            
            if (!result[i]["display_from"].is_null()) {
                json += "\"display_from\":\"" + result[i]["display_from"].as<std::string>() + "\",";
            } else {
                json += "\"display_from\":null,";
            }
            
            if (!result[i]["display_until"].is_null()) {
                json += "\"display_until\":\"" + result[i]["display_until"].as<std::string>() + "\",";
            } else {
                json += "\"display_until\":null,";
            }
            
            json += "\"created_at\":\"" + result[i]["created_at"].as<std::string>() + "\"";
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
        std::string notification_type = "system";
        std::string title = "System Notification";
        std::string message = "Notification message";
        std::string severity = "info";
        
        std::string query = "INSERT INTO system_notifications (notification_type, title, message, severity, is_active) "
                          "VALUES ($1, $2, $3, $4, true) RETURNING id";
        std::vector<std::string> params = {notification_type, title, message, severity};
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
        size_t pos = path.find("/api/system-admin/lookups/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string table_name = path.substr(pos + 27); // length of prefix
        
        if (table_name.empty()) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Table name is required\"}");
        }
        
        // Query the specific lookup table
        std::string query = "SELECT id, name, description, display_order, is_active FROM " + table_name + " "
                          "ORDER BY display_order, name";
        auto result = db_->query(query, {});
        
        std::string json = "[";
        for (size_t i = 0; i < result.size(); ++i) {
            if (i > 0) json += ",";
            json += "{";
            json += "\"id\":\"" + result[i]["id"].as<std::string>() + "\",";
            json += "\"name\":\"" + result[i]["name"].as<std::string>() + "\",";
            
            if (!result[i]["description"].is_null()) {
                json += "\"description\":\"" + result[i]["description"].as<std::string>() + "\",";
            } else {
                json += "\"description\":null,";
            }
            
            json += "\"display_order\":" + result[i]["display_order"].as<std::string>() + ",";
            json += "\"is_active\":" + std::string(result[i]["is_active"].as<bool>() ? "true" : "false");
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
        size_t pos = path.find("/api/system-admin/lookups/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + 27);
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
        size_t pos = path.find("/api/system-admin/lookups/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + 27);
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
        size_t pos = path.find("/api/system-admin/lookups/");
        if (pos == std::string::npos) {
            return Response(HttpStatus::BAD_REQUEST, "{\"error\":\"Invalid path\"}");
        }
        
        std::string after_prefix = path.substr(pos + 27);
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
