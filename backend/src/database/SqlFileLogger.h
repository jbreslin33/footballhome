#pragma once
#include <string>
#include <fstream>
#include <mutex>
#include <map>
#include <cstdlib>

/**
 * SQL File Logger - Logs all DB operations to ##u or ##p files
 * 
 * Writes INSERT/UPDATE/DELETE statements to appropriate app SQL files
 * based on ENVIRONMENT variable (dev→u, production→p)
 */
class SqlFileLogger {
private:
    static std::mutex mutex_;
    static std::string environment_;
    static std::string data_path_;
    
    // Table name → file number mapping
    static std::map<std::string, std::string> table_file_map_;
    
    static void initializeTableMap();
    static std::string getFileSuffix();
    static std::string getFilePath(const std::string& table);
    
public:
    /**
     * Initialize logger with environment and data path
     */
    static void initialize(const std::string& env = "", const std::string& path = "/app/database/data");
    
    /**
     * Log a SQL statement to the appropriate ##u or ##p file
     * @param table Table name (users, players, teams, etc.)
     * @param sql SQL statement (INSERT ... ON CONFLICT ... or UPDATE ...)
     */
    static void log(const std::string& table, const std::string& sql);

    /**
     * Log a SQL statement to a specific manual file (e.g., 80m-manual-links.sql)
     * @param filename The specific filename to write to
     * @param sql SQL statement
     */
    static void logToManualFile(const std::string& filename, const std::string& sql);
    
    /**
     * Check if logging is enabled for current environment
     */
    static bool isEnabled();
    
    /**
     * Get current environment (dev or production)
     */
    static std::string getEnvironment();
};
