#include "Controller.h"
#include <sstream>
#include <regex>

Response Controller::jsonResponse(const std::string& json) {
    return Response::json(json);
}

Response Controller::jsonResponse(HttpStatus status, const std::string& json) {
    Response response(status);
    response.setJson(json);
    return response;
}

Response Controller::errorResponse(HttpStatus status, const std::string& message) {
    std::ostringstream json;
    json << "{\"success\":false,\"error\":\"" << message << "\"}";
    return jsonResponse(status, json.str());
}

Response Controller::successResponse(const std::string& message) {
    std::ostringstream json;
    json << "{\"success\":true,\"message\":\"" << message << "\"}";
    return jsonResponse(json.str());
}

bool Controller::validateJsonRequest(const Request& request, Response& error_response) {
    if (!request.isJson()) {
        error_response = errorResponse(HttpStatus::BAD_REQUEST, "Content-Type must be application/json");
        return false;
    }
    
    if (request.getBody().empty()) {
        error_response = errorResponse(HttpStatus::BAD_REQUEST, "Request body is required");
        return false;
    }
    
    return true;
}

std::string Controller::extractJsonField(const std::string& json, const std::string& field) {
    // Simple JSON field extraction using regex
    // For production use, consider a proper JSON library like nlohmann/json
    
    std::string pattern = "\"" + field + "\"\\s*:\\s*\"([^\"]+)\"";
    std::regex field_regex(pattern);
    std::smatch match;
    
    if (std::regex_search(json, match, field_regex)) {
        return match[1].str();
    }
    
    return "";
}

std::string Controller::getPathParam(const Request& request, const std::string& param_name) {
    // This is a placeholder for path parameter extraction
    // Would need to be implemented with proper route matching
    // For now, return empty string
    return "";
}