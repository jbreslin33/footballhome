#include "User.h"
#include <iostream>

User::User() : Model("users", "id") {
}

bool User::save() {
    // For now, implement a basic save (would need proper validation in production)
    try {
        std::unordered_map<std::string, std::string> data;
        data["email"] = email_;
        data["name"] = name_;
        if (!password_hash_.empty()) {
            data["password_hash"] = password_hash_;
        }
        
        std::string sql = buildInsertQuery(data);
        std::vector<std::string> params;
        for (const auto& pair : data) {
            params.push_back(pair.second);
        }
        
        pqxx::result result = executeQuery(sql, params);
        if (!result.empty()) {
            id_ = result[0][0].as<std::string>();
            return true;
        }
        return false;
    } catch (const std::exception& e) {
        std::cerr << "❌ User save error: " << e.what() << std::endl;
        return false;
    }
}

bool User::load(int id) {
    auto data = findById("users", id, "id");
    if (data.empty()) {
        return false;
    }
    
    populateFromMap(data);
    return true;
}

bool User::remove() {
    if (id_.empty()) {
        return false;
    }
    
    try {
        std::string sql = "DELETE FROM users WHERE id = $1";
        executeQuery(sql, {id_});
        return true;
    } catch (const std::exception& e) {
        std::cerr << "❌ User remove error: " << e.what() << std::endl;
        return false;
    }
}

UserData User::authenticate(const std::string& email, const std::string& password) {
    UserData userData;
    userData.valid = false;
    
    std::cout << "🔍 authenticateUser called for: " << email << std::endl;
    
    try {
        // Query database for user by email with admin info
        std::string sql = "SELECT u.id, u.email, u.name, u.password_hash, a.admin_level "
                         "FROM users u "
                         "LEFT JOIN admins a ON u.id = a.id "
                         "WHERE u.email = $1 "
                         "LIMIT 1";
        
        pqxx::result result = executeQuery(sql, {email});
        std::cout << "🔍 Query returned " << result.size() << " rows" << std::endl;
        
        if (!result.empty()) {
            auto row = result[0];
            std::string stored_hash = row["password_hash"].as<std::string>();
            
            std::cout << "🔍 User found in DB: " << email << std::endl;
            
            if (verifyPassword(password, stored_hash)) {
                userData.valid = true;
                userData.id = row["id"].as<std::string>();
                userData.email = row["email"].as<std::string>();
                userData.name = row["name"].as<std::string>();
                // Check if user is an admin, otherwise default to "user"
                userData.role = row["admin_level"].is_null() ? "user" : row["admin_level"].as<std::string>();
                
                std::cout << "✅ Authentication successful for: " << email << std::endl;
            } else {
                std::cout << "❌ Password verification failed for: " << email << std::endl;
            }
        } else {
            std::cout << "🔍 No user found in DB for: " << email << std::endl;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "❌ Auth query failed: " << e.what() << std::endl;
    }
    
    return userData;
}

bool User::verifyPassword(const std::string& password, const std::string& stored_hash) {
    try {
        // Use PostgreSQL's crypt function to verify bcrypt hash
        std::string sql = "SELECT crypt($1, $2) = $2 AS password_match";
        pqxx::result result = executeQuery(sql, {password, stored_hash});
        
        bool password_match = !result.empty() && result[0]["password_match"].as<bool>();
        std::cout << "🔍 Password match result: " << (password_match ? "true" : "false") << std::endl;
        
        return password_match;
    } catch (const std::exception& e) {
        std::cerr << "❌ Password verification error: " << e.what() << std::endl;
        return false;
    }
}

UserData User::toUserData() const {
    UserData userData;
    userData.id = id_;
    userData.email = email_;
    userData.name = name_;
    userData.role = role_;
    userData.valid = !id_.empty();
    return userData;
}

bool User::loadByEmail(const std::string& email) {
    auto data = findBy("users", "email", email);
    if (data.empty()) {
        return false;
    }
    
    populateFromMap(data[0]);
    return true;
}

void User::populateFromMap(const std::unordered_map<std::string, std::string>& data) {
    auto it = data.find("id");
    if (it != data.end()) id_ = it->second;
    
    it = data.find("email");
    if (it != data.end()) email_ = it->second;
    
    it = data.find("name");
    if (it != data.end()) name_ = it->second;
    
    it = data.find("password_hash");
    if (it != data.end()) password_hash_ = it->second;
    
    it = data.find("admin_level");
    if (it != data.end()) {
        role_ = it->second.empty() ? "user" : it->second;
    } else {
        role_ = "user";
    }
}