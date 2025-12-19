#include "Response.h"
#include <algorithm>
#include <cctype>

Response::Response() : status_(HttpStatus::OK) {
    // Set default headers
    setHeader("Server", "FootballHome/1.0");
    setHeader("Connection", "close");
}

Response::Response(HttpStatus status) : status_(status) {
    setHeader("Server", "FootballHome/1.0");
    setHeader("Connection", "close");
}

Response::Response(HttpStatus status, const std::string& body) 
    : status_(status), body_(body) {
    setHeader("Server", "FootballHome/1.0");
    setHeader("Connection", "close");
    setHeader("Content-Length", std::to_string(body.length()));
}

std::string Response::getStatusText(HttpStatus status) const {
    switch (status) {
        case HttpStatus::OK: return "OK";
        case HttpStatus::CREATED: return "Created";
        case HttpStatus::NO_CONTENT: return "No Content";
        case HttpStatus::FOUND: return "Found";
        case HttpStatus::BAD_REQUEST: return "Bad Request";
        case HttpStatus::UNAUTHORIZED: return "Unauthorized";
        case HttpStatus::FORBIDDEN: return "Forbidden";
        case HttpStatus::NOT_FOUND: return "Not Found";
        case HttpStatus::METHOD_NOT_ALLOWED: return "Method Not Allowed";
        case HttpStatus::INTERNAL_SERVER_ERROR: return "Internal Server Error";
        case HttpStatus::NOT_IMPLEMENTED: return "Not Implemented";
        default: return "Unknown";
    }
}

void Response::setHeader(const std::string& name, const std::string& value) {
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    headers_[lower_name] = value;
    
    // Update Content-Length if body is set
    if (lower_name == "content-type" && !body_.empty()) {
        setHeader("Content-Length", std::to_string(body_.length()));
    }
}

void Response::addHeader(const std::string& name, const std::string& value) {
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    
    if (headers_.find(lower_name) != headers_.end()) {
        headers_[lower_name] += ", " + value;
    } else {
        headers_[lower_name] = value;
    }
}

std::string Response::getHeader(const std::string& name) const {
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    
    auto it = headers_.find(lower_name);
    return (it != headers_.end()) ? it->second : "";
}

bool Response::hasHeader(const std::string& name) const {
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    return headers_.find(lower_name) != headers_.end();
}

void Response::setJson(const std::string& json) {
    setBody(json);
    setHeader("Content-Type", "application/json; charset=utf-8");
}

void Response::setHtml(const std::string& html) {
    setBody(html);
    setHeader("Content-Type", "text/html; charset=utf-8");
}

void Response::setText(const std::string& text) {
    setBody(text);
    setHeader("Content-Type", "text/plain; charset=utf-8");
}

void Response::setCorsHeaders() {
    setHeader("Access-Control-Allow-Origin", "*");
    setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With");
    setHeader("Access-Control-Max-Age", "86400");
}

void Response::setCorsHeaders(const std::string& origin) {
    setHeader("Access-Control-Allow-Origin", origin);
    setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Requested-With");
    setHeader("Access-Control-Allow-Credentials", "true");
    setHeader("Access-Control-Max-Age", "86400");
}

// Static factory methods
Response Response::ok() {
    return Response(HttpStatus::OK);
}

Response Response::ok(const std::string& body) {
    Response resp(HttpStatus::OK, body);
    resp.setHeader("Content-Type", "text/plain; charset=utf-8");
    return resp;
}

Response Response::json(const std::string& json_body) {
    Response resp(HttpStatus::OK);
    resp.setJson(json_body);
    return resp;
}

Response Response::badRequest(const std::string& message) {
    Response resp(HttpStatus::BAD_REQUEST);
    resp.setJson("{\"error\":\"" + message + "\"}");
    return resp;
}

Response Response::unauthorized(const std::string& message) {
    Response resp(HttpStatus::UNAUTHORIZED);
    resp.setJson("{\"error\":\"" + message + "\"}");
    return resp;
}

Response Response::notFound(const std::string& message) {
    Response resp(HttpStatus::NOT_FOUND);
    resp.setJson("{\"error\":\"" + message + "\"}");
    return resp;
}

Response Response::internalError(const std::string& message) {
    Response resp(HttpStatus::INTERNAL_SERVER_ERROR);
    resp.setJson("{\"error\":\"" + message + "\"}");
    return resp;
}

std::string Response::toHttpString() const {
    std::ostringstream response;
    
    // Status line
    response << "HTTP/1.1 " << static_cast<int>(status_) << " " << getStatusText(status_) << "\r\n";
    
    // Headers
    for (const auto& header : headers_) {
        // Capitalize first letter of each word for proper HTTP header format
        std::string name = header.first;
        bool capitalize_next = true;
        for (char& c : name) {
            if (capitalize_next && std::isalpha(c)) {
                c = std::toupper(c);
                capitalize_next = false;
            } else if (c == '-') {
                capitalize_next = true;
            }
        }
        response << name << ": " << header.second << "\r\n";
    }
    
    // Ensure Content-Length is set
    if (!hasHeader("content-length") && !body_.empty()) {
        response << "Content-Length: " << body_.length() << "\r\n";
    }
    
    // End of headers
    response << "\r\n";
    
    // Body
    response << body_;
    
    return response.str();
}

std::string Response::toString() const {
    std::ostringstream oss;
    oss << "Response{";
    oss << "status=" << static_cast<int>(status_);
    oss << ", headers=" << headers_.size();
    oss << ", body_size=" << body_.size();
    oss << "}";
    return oss.str();
}