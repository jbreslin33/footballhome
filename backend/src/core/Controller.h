#pragma once
#include "Router.h"
#include "Request.h"
#include "Response.h"
#include <memory>

// Forward declaration to avoid circular dependency
class Router;

class Controller {
public:
    Controller() = default;
    virtual ~Controller() = default;
    
    // Pure virtual method that subclasses must implement
    virtual void registerRoutes(Router& router, const std::string& prefix) = 0;
    
protected:
    // Utility methods for controllers
    Response jsonResponse(const std::string& json);
    Response jsonResponse(HttpStatus status, const std::string& json);
    Response errorResponse(HttpStatus status, const std::string& message);
    Response successResponse(const std::string& message = "Success");
    
    // Request parsing helpers
    bool validateJsonRequest(const Request& request, Response& error_response);
    std::string extractJsonField(const std::string& json, const std::string& field);
    
    // Path parameter extraction (for future enhancement)
    std::string getPathParam(const Request& request, const std::string& param_name);
};