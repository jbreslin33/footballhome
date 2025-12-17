#include "SqlBuilder.h"
#include <algorithm>

std::string SqlBuilder::buildUpsert(
    const std::string& table,
    const std::string& id,
    const std::map<std::string, std::string>& columns,
    const std::string& conflictColumn
) {
    std::ostringstream sql;
    
    // Build column and value lists
    std::vector<std::string> cols;
    std::vector<std::string> vals;
    std::vector<std::string> updates;
    
    // Always include id
    cols.push_back(conflictColumn);
    vals.push_back(quote(id));
    
    // Add other columns
    for (const auto& [col, val] : columns) {
        if (col == conflictColumn) continue; // Skip id, already added
        
        cols.push_back(col);
        vals.push_back(val.empty() || val == "NULL" ? "NULL" : quote(val));
        
        // Build update clause (exclude id)
        updates.push_back(col + " = EXCLUDED." + col);
    }
    
    // Build INSERT statement
    sql << "INSERT INTO " << table << " (";
    for (size_t i = 0; i < cols.size(); ++i) {
        if (i > 0) sql << ", ";
        sql << cols[i];
    }
    sql << ") VALUES (";
    for (size_t i = 0; i < vals.size(); ++i) {
        if (i > 0) sql << ", ";
        sql << vals[i];
    }
    sql << ")";
    
    // Add ON CONFLICT clause
    sql << " ON CONFLICT (" << conflictColumn << ") DO UPDATE SET ";
    for (size_t i = 0; i < updates.size(); ++i) {
        if (i > 0) sql << ", ";
        sql << updates[i];
    }
    sql << ";";
    
    return sql.str();
}

std::string SqlBuilder::escape(const std::string& value) {
    std::string escaped;
    escaped.reserve(value.length());
    
    for (char c : value) {
        if (c == '\'') {
            escaped += "''"; // Escape single quotes
        } else if (c == '\\') {
            escaped += "\\\\"; // Escape backslashes
        } else {
            escaped += c;
        }
    }
    
    return escaped;
}

std::string SqlBuilder::quote(const std::string& value) {
    return "'" + escape(value) + "'";
}

std::string SqlBuilder::formatNull() {
    return "NULL";
}
