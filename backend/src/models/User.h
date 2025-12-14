#pragma once
#include "../database/Model.h"
#include <string>

struct UserData {
    std::string id;
    std::string email;
    std::string first_name;
    std::string last_name;
    std::string preferred_name;
    std::string name; // Computed: first_name + " " + last_name (for backward compatibility)
    std::string role;
    std::string club_id;
    std::string club_name;
    bool valid = false;
};

class User : public Model {
private:
    std::string id_;
    std::string email_;
    std::string name_;
    std::string password_hash_;
    std::string role_;

public:
    User();
    
    // Core CRUD operations
    bool save() override;
    bool load(int id) override;
    bool remove() override;
    
    // Authentication methods
    UserData authenticate(const std::string& email, const std::string& password);
    bool verifyPassword(const std::string& password, const std::string& stored_hash);
    
    // Getters and setters
    const std::string& getId() const { return id_; }
    const std::string& getEmail() const { return email_; }
    const std::string& getName() const { return name_; }
    const std::string& getRole() const { return role_; }
    
    void setEmail(const std::string& email) { email_ = email; }
    void setName(const std::string& name) { name_ = name; }
    void setRole(const std::string& role) { role_ = role; }
    
    // Utility methods
    UserData toUserData() const;
    bool loadByEmail(const std::string& email);
    UserData getUserById(const std::string& user_id);
    std::string getUserRoles(const std::string& user_id);
    
private:
    void populateFromMap(const std::unordered_map<std::string, std::string>& data);
};