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
    // Map table names to file numbers
    table_file_map_["users"] = "08";
    table_file_map_["teams"] = "21";
    table_file_map_["players"] = "22";
    table_file_map_["team_players"] = "23";
    table_file_map_["coaches"] = "24";
    table_file_map_["team_coaches"] = "25";
    table_file_map_["matches"] = "30";
    table_file_map_["events"] = "30";
    table_file_map_["practices"] = "30";
    table_file_map_["event_rsvps"] = "30";
    table_file_map_["event_attendance"] = "30";
    table_file_map_["match_rosters"] = "30";
    table_file_map_["player_rsvp_history"] = "30";
    table_file_map_["coach_rsvp_history"] = "30";
    table_file_map_["parent_rsvp_history"] = "30";
    table_file_map_["player_medical_status"] = "22";
    table_file_map_["player_academic_status"] = "22";
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

bool SqlFileLogger::isEnabled() {
    // Only log in dev and production, not during init or tests
    return !environment_.empty() && 
           (environment_ == "dev" || environment_ == "production");
}

std::string SqlFileLogger::getEnvironment() {
    return environment_;
}
