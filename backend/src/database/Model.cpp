#include "Model.h"
#include <iostream>
#include <sstream>

Model::Model(const std::string& table_name, const std::string& primary_key)
    : table_name_(table_name), primary_key_(primary_key) {
    db_ = Database::getInstance();
}

// Static methods
std::vector<std::unordered_map<std::string, std::string>> Model::findAll(const std::string& table_name) {
    Database* db = Database::getInstance();
    
    try {
        std::string sql = "SELECT * FROM " + table_name + " ORDER BY id";
        pqxx::result result = db->query(sql);
        return resultToVector(result);
    } catch (const std::exception& e) {
        std::cerr << "❌ Error in findAll for table " << table_name << ": " << e.what() << std::endl;
        return {};
    }
}

std::unordered_map<std::string, std::string> Model::findById(const std::string& table_name, int id, const std::string& primary_key) {
    Database* db = Database::getInstance();
    
    try {
        std::string sql = "SELECT * FROM " + table_name + " WHERE " + primary_key + " = $1";
        pqxx::result result = db->query(sql, {std::to_string(id)});
        
        if (result.empty()) {
            return {};
        }
        
        return resultToMap(result[0]);
    } catch (const std::exception& e) {
        std::cerr << "❌ Error in findById for table " << table_name << ", id " << id << ": " << e.what() << std::endl;
        return {};
    }
}

std::vector<std::unordered_map<std::string, std::string>> Model::findBy(const std::string& table_name, const std::string& column, const std::string& value) {
    Database* db = Database::getInstance();
    
    try {
        std::string sql = "SELECT * FROM " + table_name + " WHERE " + column + " = $1";
        pqxx::result result = db->query(sql, {value});
        return resultToVector(result);
    } catch (const std::exception& e) {
        std::cerr << "❌ Error in findBy for table " << table_name << ", " << column << " = " << value << ": " << e.what() << std::endl;
        return {};
    }
}

// Instance methods
std::string Model::escape(const std::string& value) const {
    return db_->escape(value);
}

bool Model::exists(int id) const {
    try {
        std::string sql = "SELECT COUNT(*) FROM " + table_name_ + " WHERE " + primary_key_ + " = $1";
        pqxx::result result = executeQuery(sql, {std::to_string(id)});
        
        if (!result.empty()) {
            return result[0][0].as<int>() > 0;
        }
        return false;
    } catch (const std::exception& e) {
        std::cerr << "❌ Error checking existence: " << e.what() << std::endl;
        return false;
    }
}

int Model::getLastInsertId() const {
    try {
        std::string sql = "SELECT lastval()";
        pqxx::result result = executeQuery(sql);
        
        if (!result.empty()) {
            return result[0][0].as<int>();
        }
        return -1;
    } catch (const std::exception& e) {
        std::cerr << "❌ Error getting last insert ID: " << e.what() << std::endl;
        return -1;
    }
}

// Protected helper methods
pqxx::result Model::executeQuery(const std::string& sql) const {
    return db_->query(sql);
}

pqxx::result Model::executeQuery(const std::string& sql, const std::vector<std::string>& params) const {
    return db_->query(sql, params);
}

std::string Model::buildInsertQuery(const std::unordered_map<std::string, std::string>& data) const {
    if (data.empty()) {
        throw std::invalid_argument("Cannot build INSERT query with empty data");
    }
    
    std::ostringstream sql;
    sql << "INSERT INTO " << table_name_ << " (";
    
    // Column names
    bool first = true;
    for (const auto& pair : data) {
        if (!first) sql << ", ";
        sql << pair.first;
        first = false;
    }
    
    sql << ") VALUES (";
    
    // Parameter placeholders
    first = true;
    int param_num = 1;
    for (const auto& pair : data) {
        if (!first) sql << ", ";
        sql << "$" << param_num++;
        first = false;
    }
    
    sql << ") RETURNING " << primary_key_;
    
    return sql.str();
}

std::string Model::buildUpdateQuery(const std::unordered_map<std::string, std::string>& data, int id) const {
    if (data.empty()) {
        throw std::invalid_argument("Cannot build UPDATE query with empty data");
    }
    
    std::ostringstream sql;
    sql << "UPDATE " << table_name_ << " SET ";
    
    bool first = true;
    int param_num = 1;
    for (const auto& pair : data) {
        if (!first) sql << ", ";
        sql << pair.first << " = $" << param_num++;
        first = false;
    }
    
    sql << " WHERE " << primary_key_ << " = $" << param_num;
    
    return sql.str();
}

std::string Model::buildSelectQuery(const std::string& where_clause) const {
    std::string sql = "SELECT * FROM " + table_name_;
    if (!where_clause.empty()) {
        sql += " WHERE " + where_clause;
    }
    return sql;
}

std::string Model::buildDeleteQuery(int id) const {
    return "DELETE FROM " + table_name_ + " WHERE " + primary_key_ + " = " + std::to_string(id);
}

// Static utility methods
std::unordered_map<std::string, std::string> Model::resultToMap(const pqxx::row& row) {
    std::unordered_map<std::string, std::string> map;
    
    for (int i = 0; i < static_cast<int>(row.size()); ++i) {
        std::string column_name = row[i].name();
        std::string value = row[i].is_null() ? "" : row[i].c_str();
        map[column_name] = value;
    }
    
    return map;
}

std::vector<std::unordered_map<std::string, std::string>> Model::resultToVector(const pqxx::result& result) {
    std::vector<std::unordered_map<std::string, std::string>> vector;
    
    for (const auto& row : result) {
        vector.push_back(resultToMap(row));
    }
    
    return vector;
}