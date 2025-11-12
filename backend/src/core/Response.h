#pragma once
#include <string>
#include <unordered_map>
#include <sstream>

enum class HttpStatus {
    OK = 200,
    CREATED = 201,
    NO_CONTENT = 204,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    METHOD_NOT_ALLOWED = 405,
    INTERNAL_SERVER_ERROR = 500
};

class Response {
private:
    HttpStatus status_;
    std::unordered_map<std::string, std::string> headers_;
    std::string body_;
    
    std::string getStatusText(HttpStatus status) const;

public:
    Response();
    Response(HttpStatus status);
    Response(HttpStatus status, const std::string& body);
    
    // Status operations
    void setStatus(HttpStatus status) { status_ = status; }
    HttpStatus getStatus() const { return status_; }
    int getStatusCode() const { return static_cast<int>(status_); }
    
    // Header operations
    void setHeader(const std::string& name, const std::string& value);
    void addHeader(const std::string& name, const std::string& value);
    std::string getHeader(const std::string& name) const;
    bool hasHeader(const std::string& name) const;
    const std::unordered_map<std::string, std::string>& getHeaders() const { return headers_; }
    
    // Body operations
    void setBody(const std::string& body) { body_ = body; }
    void addBody(const std::string& content) { body_ += content; }
    const std::string& getBody() const { return body_; }
    void clearBody() { body_.clear(); }
    
    // Content type helpers
    void setJson(const std::string& json);
    void setHtml(const std::string& html);
    void setText(const std::string& text);
    
    // CORS helpers
    void setCorsHeaders();
    void setCorsHeaders(const std::string& origin);
    
    // Common responses
    static Response ok();
    static Response ok(const std::string& body);
    static Response json(const std::string& json_body);
    static Response badRequest(const std::string& message = "Bad Request");
    static Response unauthorized(const std::string& message = "Unauthorized");
    static Response notFound(const std::string& message = "Not Found");
    static Response internalError(const std::string& message = "Internal Server Error");
    
    // HTTP response generation
    std::string toHttpString() const;
    size_t getContentLength() const { return body_.size(); }
    
    // Debug
    std::string toString() const;
};