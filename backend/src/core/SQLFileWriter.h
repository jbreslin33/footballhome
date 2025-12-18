#pragma once

#include <string>
#include <fstream>
#include <memory>
#include <unordered_map>
#include <mutex>

/**
 * SQLFileWriter - OOP system for persisting app-generated data to SQL files
 * 
 * Purpose: Ensures data created through the web UI persists across database rebuilds
 * by appending INSERT statements to environment-specific SQL files.
 * 
 * File Naming Convention:
 * - ##u-<entity>-app.sql: Development/update environment data
 * - ##p-<entity>-app.sql: Production environment data
 * 
 * Thread-safe: Uses mutex for file operations
 */
class SQLFileWriter {
public:
    enum class Environment {
        DEVELOPMENT,
        PRODUCTION
    };

    // Singleton pattern - only one writer per application
    static SQLFileWriter& getInstance();
    
    // Initialize with environment and base path
    void initialize(Environment env, const std::string& dataPath = "/app/database/data");
    
    // Write INSERT statement for a specific entity type
    bool writeInsert(const std::string& entityType, const std::string& sql);
    
    // Get current environment
    Environment getEnvironment() const { return environment_; }
    
    // Get file path for entity type
    std::string getFilePath(const std::string& entityType) const;

private:
    SQLFileWriter() = default;
    ~SQLFileWriter() = default;
    
    // Delete copy/move constructors for singleton
    SQLFileWriter(const SQLFileWriter&) = delete;
    SQLFileWriter& operator=(const SQLFileWriter&) = delete;
    SQLFileWriter(SQLFileWriter&&) = delete;
    SQLFileWriter& operator=(SQLFileWriter&&) = delete;
    
    // Append SQL to file (thread-safe)
    bool appendToFile(const std::string& filePath, const std::string& sql);
    
    // Get file suffix based on environment
    std::string getFileSuffix() const;
    
    Environment environment_ = Environment::DEVELOPMENT;
    std::string dataPath_ = "/app/database/data";
    mutable std::mutex mutex_;
    
    // Map entity types to file numbers
    static const std::unordered_map<std::string, std::string> entityFileMap_;
};
