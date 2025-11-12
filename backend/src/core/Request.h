#pragma once
#include <string>
#include <unordered_map>
#include <sstream>

enum class HttpMethod {
    GET,
    POST,
    PUT,
    DELETE,
    OPTIONS,
    UNKNOWN
};

class Request {
private:
    HttpMethod method_;
    std::string path_;
    std::string query_string_;
    std::unordered_map<std::string, std::string> headers_;
    std::string body_;
    std::unordered_map<std::string, std::string> query_params_;
    
    void parseQueryString();
    HttpMethod parseMethod(const std::string& method_str);

public:
    Request() = default;
    Request(const std::string& raw_request);
    
    // Getters
    HttpMethod getMethod() const { return method_; }
    const std::string& getPath() const { return path_; }
    const std::string& getBody() const { return body_; }
    const std::string& getQueryString() const { return query_string_; }
    
    // Header operations
    std::string getHeader(const std::string& name) const;
    bool hasHeader(const std::string& name) const;
    const std::unordered_map<std::string, std::string>& getHeaders() const { return headers_; }
    
    // Query parameter operations
    std::string getQueryParam(const std::string& name) const;
    bool hasQueryParam(const std::string& name) const;
    const std::unordered_map<std::string, std::string>& getQueryParams() const { return query_params_; }
    
    // Utility methods
    bool isMethod(HttpMethod method) const { return method_ == method; }
    bool isPost() const { return method_ == HttpMethod::POST; }
    bool isGet() const { return method_ == HttpMethod::GET; }
    bool isPut() const { return method_ == HttpMethod::PUT; }
    bool isDelete() const { return method_ == HttpMethod::DELETE; }
    
    // JSON parsing
    bool isJson() const;
    std::string getJson() const { return body_; }
    
    // Debug
    std::string toString() const;
};