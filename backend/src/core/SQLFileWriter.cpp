#include "SQLFileWriter.h"
#include <iostream>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

// Map entity types to their file number prefixes (3-digit, matching schema table order)
const std::unordered_map<std::string, std::string> SQLFileWriter::entityFileMap_ = {
    {"users", "019"},
    {"user_emails", "020"},
    {"user_phones", "021"},
    {"external_identities", "022"},
    {"admins", "023"},
    {"clubs", "024"},
    {"club_admins", "025"},
    {"sport_divisions", "026"},
    {"teams", "027"},
    {"team_divisions", "028"},
    {"players", "029"},
    {"team_players", "030"},
    {"coaches", "031"},
    {"team_coaches", "032"},
    {"venues", "033"},
    {"matches", "034"},
    {"player_match_stats", "035"},
    {"team_standings", "036"},
    // team_stats removed - replaced by team_season_standings view
    {"match_events", "039"},
    {"match_lineups", "040"},
    // player_season_stats removed - replaced by player_season_stats_view
    {"chats", "042"},
    {"chat_integrations", "043"},
    {"chat_members", "044"},
    {"chat_messages", "045"},
    {"chat_events", "046"},
    {"chat_event_rsvps", "047"},
    {"player_users", "048"}
};

SQLFileWriter& SQLFileWriter::getInstance() {
    static SQLFileWriter instance;
    return instance;
}

void SQLFileWriter::initialize(Environment env, const std::string& dataPath) {
    std::lock_guard<std::mutex> lock(mutex_);
    environment_ = env;
    dataPath_ = dataPath;
    
    std::cout << "📝 SQLFileWriter initialized: "
              << (env == Environment::PRODUCTION ? "PRODUCTION" : "DEVELOPMENT")
              << " mode, data path: " << dataPath << std::endl;
}

std::string SQLFileWriter::getFileSuffix() const {
    return (environment_ == Environment::PRODUCTION) ? "p" : "u";
}

std::string SQLFileWriter::getFilePath(const std::string& entityType) const {
    auto it = entityFileMap_.find(entityType);
    if (it == entityFileMap_.end()) {
        std::cerr << "❌ Unknown entity type: " << entityType << std::endl;
        return "";
    }
    
    std::string fileNumber = it->second;
    std::string suffix = getFileSuffix();
    
    return dataPath_ + "/" + fileNumber + suffix + "-" + entityType + "-app.sql";
}

bool SQLFileWriter::writeInsert(const std::string& entityType, const std::string& sql) {
    std::string filePath = getFilePath(entityType);
    if (filePath.empty()) {
        return false;
    }
    
    // Format SQL statement
    std::string formattedSql = sql;
    if (formattedSql.back() != '\n') {
        formattedSql += "\n";
    }
    
    return appendToFile(filePath, formattedSql);
}

bool SQLFileWriter::appendToFile(const std::string& filePath, const std::string& sql) {
    std::lock_guard<std::mutex> lock(mutex_);
    
    try {
        std::ofstream file(filePath, std::ios::app);
        if (!file.is_open()) {
            std::cerr << "❌ Failed to open file for writing: " << filePath << std::endl;
            return false;
        }
        
        file << sql;
        file.flush();
        file.close();
        
        std::cout << "✅ Appended SQL to: " << filePath << std::endl;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Error writing to file " << filePath << ": " << e.what() << std::endl;
        return false;
    }
}
