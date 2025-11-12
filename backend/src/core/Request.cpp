#include "Request.h"
#include <iostream>
#include <algorithm>
#include <cctype>

Request::Request(const std::string& raw_request) {
    std::istringstream stream(raw_request);
    std::string line;
    
    // Parse request line (method, path, version)
    if (std::getline(stream, line)) {
        std::istringstream request_line(line);
        std::string method_str, full_path, version;
        
        if (request_line >> method_str >> full_path >> version) {
            method_ = parseMethod(method_str);
            
            // Split path and query string
            size_t query_pos = full_path.find('?');
            if (query_pos != std::string::npos) {
                path_ = full_path.substr(0, query_pos);
                query_string_ = full_path.substr(query_pos + 1);
                parseQueryString();
            } else {
                path_ = full_path;
            }
        }
    }
    
    // Parse headers
    while (std::getline(stream, line) && !line.empty() && line != "\r") {
        size_t colon_pos = line.find(':');
        if (colon_pos != std::string::npos) {
            std::string name = line.substr(0, colon_pos);
            std::string value = line.substr(colon_pos + 1);
            
            // Trim whitespace
            name.erase(0, name.find_first_not_of(" \t\r\n"));
            name.erase(name.find_last_not_of(" \t\r\n") + 1);
            value.erase(0, value.find_first_not_of(" \t\r\n"));
            value.erase(value.find_last_not_of(" \t\r\n") + 1);
            
            // Convert header name to lowercase
            std::transform(name.begin(), name.end(), name.begin(), ::tolower);
            headers_[name] = value;
        }
    }
    
    // Parse body (remaining content)
    std::string body_line;
    while (std::getline(stream, body_line)) {
        if (!body_.empty()) body_ += "\n";
        body_ += body_line;
    }
}

void Request::parseQueryString() {
    if (query_string_.empty()) return;
    
    std::istringstream stream(query_string_);
    std::string pair;
    
    while (std::getline(stream, pair, '&')) {
        size_t eq_pos = pair.find('=');
        if (eq_pos != std::string::npos) {
            std::string key = pair.substr(0, eq_pos);
            std::string value = pair.substr(eq_pos + 1);
            query_params_[key] = value;
        } else {
            query_params_[pair] = "";
        }
    }
}

HttpMethod Request::parseMethod(const std::string& method_str) {
    if (method_str == "GET") return HttpMethod::GET;
    if (method_str == "POST") return HttpMethod::POST;
    if (method_str == "PUT") return HttpMethod::PUT;
    if (method_str == "DELETE") return HttpMethod::DELETE;
    if (method_str == "OPTIONS") return HttpMethod::OPTIONS;
    return HttpMethod::UNKNOWN;
}

std::string Request::getHeader(const std::string& name) const {
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    
    auto it = headers_.find(lower_name);
    return (it != headers_.end()) ? it->second : "";
}

bool Request::hasHeader(const std::string& name) const {
    std::string lower_name = name;
    std::transform(lower_name.begin(), lower_name.end(), lower_name.begin(), ::tolower);
    return headers_.find(lower_name) != headers_.end();
}

std::string Request::getQueryParam(const std::string& name) const {
    auto it = query_params_.find(name);
    return (it != query_params_.end()) ? it->second : "";
}

bool Request::hasQueryParam(const std::string& name) const {
    return query_params_.find(name) != query_params_.end();
}

bool Request::isJson() const {
    std::string content_type = getHeader("content-type");
    return content_type.find("application/json") != std::string::npos;
}

std::string Request::toString() const {
    std::ostringstream oss;
    oss << "Request{";
    oss << "method=" << static_cast<int>(method_);
    oss << ", path=" << path_;
    oss << ", query=" << query_string_;
    oss << ", headers=" << headers_.size();
    oss << ", body_size=" << body_.size();
    oss << "}";
    return oss.str();
}