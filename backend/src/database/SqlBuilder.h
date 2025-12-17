#pragma once
#include <string>
#include <vector>
#include <map>
#include <sstream>

/**
 * SQL Builder - Generates upsert SQL statements for logging
 * 
 * Creates INSERT ... ON CONFLICT DO UPDATE statements that can be
 * safely replayed multiple times (idempotent)
 */
class SqlBuilder {
public:
    /**
     * Build an upsert statement for a single record
     * @param table Table name
     * @param id Primary key value (UUID)
     * @param columns Map of column name → value
     * @param conflictColumn Column to check for conflicts (default: "id")
     * @return Complete SQL upsert statement
     */
    static std::string buildUpsert(
        const std::string& table,
        const std::string& id,
        const std::map<std::string, std::string>& columns,
        const std::string& conflictColumn = "id"
    );
    
    /**
     * Escape a string value for SQL
     */
    static std::string escape(const std::string& value);
    
    /**
     * Quote a string value for SQL ('value')
     */
    static std::string quote(const std::string& value);
    
    /**
     * Format NULL values
     */
    static std::string formatNull();
};
