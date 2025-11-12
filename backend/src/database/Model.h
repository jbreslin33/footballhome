#pragma once
#include "Database.h"
#include <string>
#include <vector>
#include <memory>
#include <unordered_map>

class Model {
protected:
    Database* db_;
    std::string table_name_;
    std::string primary_key_;
    
public:
    Model(const std::string& table_name, const std::string& primary_key = "id");
    virtual ~Model() = default;
    
    // Core CRUD operations (to be implemented by derived classes)
    virtual bool save() = 0;
    virtual bool load(int id) = 0;
    virtual bool remove() = 0;
    
    // Static finder methods
    static std::vector<std::unordered_map<std::string, std::string>> findAll(const std::string& table_name);
    static std::unordered_map<std::string, std::string> findById(const std::string& table_name, int id, const std::string& primary_key = "id");
    static std::vector<std::unordered_map<std::string, std::string>> findBy(const std::string& table_name, const std::string& column, const std::string& value);
    
    // Utility methods
    std::string escape(const std::string& value) const;
    bool exists(int id) const;
    int getLastInsertId() const;
    
    // Getters
    const std::string& getTableName() const { return table_name_; }
    const std::string& getPrimaryKey() const { return primary_key_; }
    
protected:
    // Helper methods for derived classes
    pqxx::result executeQuery(const std::string& sql) const;
    pqxx::result executeQuery(const std::string& sql, const std::vector<std::string>& params) const;
    
    // Build common SQL queries
    std::string buildInsertQuery(const std::unordered_map<std::string, std::string>& data) const;
    std::string buildUpdateQuery(const std::unordered_map<std::string, std::string>& data, int id) const;
    std::string buildSelectQuery(const std::string& where_clause = "") const;
    std::string buildDeleteQuery(int id) const;
    
    // Result set conversion
    static std::unordered_map<std::string, std::string> resultToMap(const pqxx::row& row);
    static std::vector<std::unordered_map<std::string, std::string>> resultToVector(const pqxx::result& result);
};