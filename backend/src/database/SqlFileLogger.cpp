#include "SqlFileLogger.h"
#include <iostream>
#include <chrono>
#include <iomanip>
#include <sstream>

std::mutex SqlFileLogger::mutex_;
std::string SqlFileLogger::environment_;
std::string SqlFileLogger::data_path_;
std::map<std::string, std::string> SqlFileLogger::table_file_map_;

void SqlFileLogger::initialize(const std::string& env, const std::string& path) {
    std::lock_guard<std::mutex> lock(mutex_);
    
    // Get environment from parameter or environment variable
    if (!env.empty()) {
        environment_ = env;
    } else {
        const char* env_var = std::getenv("ENVIRONMENT");
        environment_ = env_var ? env_var : "dev";
    }
    
    data_path_ = path;
    initializeTableMap();
    
    std::cout << "SqlFileLogger initialized: environment=" << environment_ 
              << ", path=" << data_path_ << std::endl;
}

void SqlFileLogger::initializeTableMap() {
    // Core lookup/reference tables (use '01' for system-level static data)
    table_file_map_["schema_migrations"] = "01";
    table_file_map_["sports"] = "01";
    table_file_map_["positions"] = "01";
    table_file_map_["formations"] = "01";
    table_file_map_["attendance_statuses"] = "01";
    table_file_map_["event_types"] = "01";
    table_file_map_["home_away_statuses"] = "01";
    table_file_map_["roster_statuses"] = "01";
    table_file_map_["rsvp_statuses"] = "01";
    table_file_map_["rsvp_change_sources"] = "01";
    table_file_map_["notification_types"] = "01";
    table_file_map_["external_providers"] = "01";
    table_file_map_["permission_categories"] = "01";
    table_file_map_["permissions"] = "01";
    table_file_map_["admin_levels"] = "01";
    table_file_map_["admin_permissions"] = "01";
    
    // System admin and monitoring tables
    table_file_map_["system_settings"] = "01";
    table_file_map_["feature_flags"] = "01";
    table_file_map_["system_admins"] = "08";
    table_file_map_["system_notifications"] = "01";
    table_file_map_["system_audit_log"] = "01";
    table_file_map_["system_health_metrics"] = "01";
    table_file_map_["api_usage_log"] = "01";
    table_file_map_["notification_log"] = "01";
    table_file_map_["scraper_execution_log"] = "01";
    table_file_map_["data_import_jobs"] = "01";
    table_file_map_["change_log"] = "02";
    
    // Venue data
    table_file_map_["venues"] = "02";
    
    // League/Conference/Division structure
    table_file_map_["leagues"] = "03";
    table_file_map_["league_conferences"] = "04";
    table_file_map_["league_divisions"] = "05";
    table_file_map_["division_relationships"] = "05";
    
    // Clubs
    table_file_map_["clubs"] = "06";
    
    // Sport divisions
    table_file_map_["clubs"] = "07";
    
    // Users and authentication
    table_file_map_["users"] = "08";
    table_file_map_["user_emails"] = "08";
    table_file_map_["user_external_identities"] = "08";
    table_file_map_["external_apps"] = "08";
    table_file_map_["user_sessions"] = "08";
    table_file_map_["magic_tokens"] = "08";
    table_file_map_["login_history"] = "08";
    table_file_map_["user_notification_preferences"] = "08";
    
    // Admin roles (various levels)
    table_file_map_["league_admins"] = "08";
    table_file_map_["league_conference_admins"] = "08";
    table_file_map_["league_division_admins"] = "08";
    table_file_map_["sport_division_admins"] = "08";
    table_file_map_["organization_admins"] = "75";
    table_file_map_["team_admins"] = "21";
    
    // Teams
    table_file_map_["teams"] = "21";
    table_file_map_["team_external_apps"] = "21";
    table_file_map_["team_followers"] = "21";
    
    // Players
    table_file_map_["players"] = "22";
    table_file_map_["player_guardians"] = "22";
    table_file_map_["player_medical_status"] = "22";
    table_file_map_["player_medical_status_history"] = "22";
    table_file_map_["player_academic_status"] = "22";
    table_file_map_["player_academic_status_history"] = "22";
    
    // Team rosters
    table_file_map_["team_division_players"] = "23";
    table_file_map_["team_players_status_history"] = "23";
    
    // Coaches
    table_file_map_["coaches"] = "24";
    table_file_map_["team_coaches"] = "25";
    
    // Other team staff
    table_file_map_["managers"] = "24";
    table_file_map_["medical_staff"] = "24";
    table_file_map_["referees"] = "24";
    table_file_map_["volunteers"] = "24";
    table_file_map_["parents"] = "24";
    table_file_map_["spectators"] = "24";
    table_file_map_["team_managers"] = "25";
    table_file_map_["team_medical_staff"] = "25";
    table_file_map_["team_volunteers"] = "25";
    table_file_map_["team_parents"] = "25";
    
    // Matches and games
    table_file_map_["matches"] = "30";
    table_file_map_["match_rosters"] = "30";
    table_file_map_["match_lineups"] = "30";
    table_file_map_["match_officials"] = "30";
    
    // Events (practices, meetings, etc)
    table_file_map_["events"] = "30";
    table_file_map_["practices"] = "30";
    table_file_map_["practice_teams"] = "30";
    table_file_map_["meetings"] = "30";
    table_file_map_["meeting_teams"] = "30";
    table_file_map_["event_recurrences"] = "30";
    table_file_map_["recurrence_patterns"] = "30";
    table_file_map_["recurring_event_instances"] = "30";
    
    // RSVP and attendance
    table_file_map_["event_attendance"] = "30";
    table_file_map_["player_rsvp_history"] = "30";
    table_file_map_["coach_rsvp_history"] = "30";
    table_file_map_["parent_rsvp_history"] = "30";
    table_file_map_["attendance_cron_log"] = "30";
    
    // Tactical board tables (use '31' for tactical board data)
    table_file_map_["tactical_boards"] = "31";
    table_file_map_["tactical_board_players"] = "31";
    table_file_map_["tactical_board_arrows"] = "31";
    table_file_map_["tactical_board_annotations"] = "31";
    table_file_map_["tactical_board_entities"] = "31";
    table_file_map_["tactical_board_collaborators"] = "31";
    table_file_map_["tactical_board_tags"] = "31";
    table_file_map_["tactical_board_tag_assignments"] = "31";
    table_file_map_["tactical_board_animations"] = "31";
    table_file_map_["tactical_board_animation_frames"] = "31";
    
    // Tactical board lookup tables (static data, usually not logged but included for completeness)
    table_file_map_["tactical_board_types"] = "31";
    table_file_map_["tactical_stances"] = "31";
    table_file_map_["tactical_field_thirds"] = "31";
    table_file_map_["tactical_position_roles"] = "31";
    table_file_map_["tactical_arrow_types"] = "31";
    table_file_map_["tactical_line_styles"] = "31";
}

std::string SqlFileLogger::getFileSuffix() {
    return (environment_ == "production") ? "p" : "u";
}

std::string SqlFileLogger::getFilePath(const std::string& table) {
    auto it = table_file_map_.find(table);
    if (it == table_file_map_.end()) {
        std::cerr << "Warning: No file mapping for table '" << table << "'" << std::endl;
        return "";
    }
    
    std::string suffix = getFileSuffix();
    std::string filename = it->second + suffix + "-" + table + "-app.sql";
    return data_path_ + "/" + filename;
}

void SqlFileLogger::log(const std::string& table, const std::string& sql) {
    if (!isEnabled()) {
        return;
    }
    
    std::lock_guard<std::mutex> lock(mutex_);
    
    std::string filepath = getFilePath(table);
    if (filepath.empty()) {
        return;
    }
    
    try {
        // Open file in append mode
        std::ofstream file(filepath, std::ios::app);
        if (!file.is_open()) {
            std::cerr << "Failed to open SQL log file: " << filepath << std::endl;
            return;
        }
        
        // Add timestamp comment
        auto now = std::chrono::system_clock::now();
        auto time = std::chrono::system_clock::to_time_t(now);
        file << "\n-- Logged at: " << std::put_time(std::localtime(&time), "%Y-%m-%d %H:%M:%S") << "\n";
        
        // Write SQL statement
        file << sql;
        if (sql.back() != ';') {
            file << ";";
        }
        file << "\n";
        
        file.close();
        
        // Debug log
        std::cout << "SQL logged to " << filepath << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error logging SQL to file: " << e.what() << std::endl;
    }
}

void SqlFileLogger::logToManualFile(const std::string& filename, const std::string& sql) {
    if (!isEnabled()) {
        return;
    }
    
    std::lock_guard<std::mutex> lock(mutex_);
    
    std::string filepath = data_path_ + "/" + filename;
    
    try {
        // Open file in append mode
        std::ofstream file(filepath, std::ios::app);
        if (!file.is_open()) {
            std::cerr << "Failed to open SQL log file: " << filepath << std::endl;
            return;
        }
        
        // Add timestamp comment
        auto now = std::chrono::system_clock::now();
        auto time = std::chrono::system_clock::to_time_t(now);
        file << "\n-- Logged at: " << std::put_time(std::localtime(&time), "%Y-%m-%d %H:%M:%S") << "\n";
        
        // Write SQL statement
        file << sql;
        if (sql.back() != ';') {
            file << ";";
        }
        file << "\n";
        
        file.close();
        
        // Debug log
        std::cout << "SQL logged to " << filepath << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error logging SQL to file: " << e.what() << std::endl;
    }
}

bool SqlFileLogger::isEnabled() {
    // Only log in dev and production, not during init or tests
    return !environment_.empty() && 
           (environment_ == "dev" || environment_ == "production");
}

std::string SqlFileLogger::getEnvironment() {
    return environment_;
}
