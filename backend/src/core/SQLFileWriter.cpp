#include "SQLFileWriter.h"
#include <iostream>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <sstream>

// Map entity types to their file number prefixes
const std::unordered_map<std::string, std::string> SQLFileWriter::entityFileMap_ = {
    {"users", "08"},
    {"teams", "21"},
    {"players", "22"},
    {"team_players", "23"},
    {"coaches", "24"},
    {"team_coaches", "25"},
    {"schedule", "30"},
    {"practices", "72"}
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
    
    // Add timestamp comment
    auto now = std::chrono::system_clock::now();
    auto time = std::chrono::system_clock::to_time_t(now);
    std::stringstream ss;
    ss << "\n-- Generated: " << std::put_time(std::localtime(&time), "%Y-%m-%d %H:%M:%S") << "\n";
    ss << sql;
    if (sql.back() != '\n') {
        ss << "\n";
    }
    
    return appendToFile(filePath, ss.str());
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
