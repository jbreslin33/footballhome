#pragma once
#include "../core/Controller.h"
#include "../models/User.h"
#include <memory>

class AuthController : public Controller {
private:
    std::unique_ptr<User> user_model_;

public:
    AuthController();
    
    // Register authentication routes
    void registerRoutes(Router& router, const std::string& prefix) override;
    
private:
    // Route handlers
    Response handleLogin(const Request& request);
    Response handleRegister(const Request& request);
    Response handleLogout(const Request& request);
    Response handleCurrentUser(const Request& request);
    Response handleUserRoles(const Request& request);
    
    // Utility methods
    std::string createJSONResponse(bool success, const std::string& message, const UserData& userData = {});
    std::string generateJWT(const UserData& userData);
    std::string extractField(const std::string& json, const std::string& field);
    std::string extractUserIdFromToken(const Request& request);
    void logLoginAttempt(const std::string& user_id, bool success, const Request& request);
};