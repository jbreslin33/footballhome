#include "OAuthController.h"
#include "../core/Response.h"
#include "../database/Database.h"
#include <cstdlib>
#include <curl/curl.h>
#include <sstream>
#include <iostream>
#include <openssl/hmac.h>
#include <openssl/sha.h>
#include <ctime>
#include <iomanip>

// Helper function for CURL write callback
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

// Helper to URL encode strings
std::string urlEncode(const std::string& value) {
    std::ostringstream escaped;
    escaped.fill('0');
    escaped << std::hex;

    for (char c : value) {
        if (isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~') {
            escaped << c;
        } else {
            escaped << std::uppercase;
            escaped << '%' << std::setw(2) << int((unsigned char) c);
            escaped << std::nouppercase;
        }
    }

    return escaped.str();
}

// Simple JSON parser for responses
std::map<std::string, std::string> parseJsonResponse(const std::string& json) {
    std::map<std::string, std::string> result;
    
    size_t pos = 0;
    while (pos < json.length()) {
        // Find key
        size_t keyStart = json.find('"', pos);
        if (keyStart == std::string::npos) break;
        keyStart++;
        
        size_t keyEnd = json.find('"', keyStart);
        if (keyEnd == std::string::npos) break;
        
        std::string key = json.substr(keyStart, keyEnd - keyStart);
        
        // Find value
        size_t colonPos = json.find(':', keyEnd);
        if (colonPos == std::string::npos) break;
        
        size_t valueStart = json.find_first_not_of(" \t\n\r", colonPos + 1);
        if (valueStart == std::string::npos) break;
        
        std::string value;
        if (json[valueStart] == '"') {
            // String value
            valueStart++;
            size_t valueEnd = json.find('"', valueStart);
            if (valueEnd == std::string::npos) break;
            value = json.substr(valueStart, valueEnd - valueStart);
            pos = valueEnd + 1;
        } else {
            // Number/boolean value
            size_t valueEnd = json.find_first_of(",}", valueStart);
            if (valueEnd == std::string::npos) break;
            value = json.substr(valueStart, valueEnd - valueStart);
            pos = valueEnd;
        }
        
        result[key] = value;
    }
    
    return result;
}

OAuthController::OAuthController() {
    clientId_ = std::getenv("GOOGLE_OAUTH_CLIENT_ID") ? std::getenv("GOOGLE_OAUTH_CLIENT_ID") : "";
    clientSecret_ = std::getenv("GOOGLE_OAUTH_CLIENT_SECRET") ? std::getenv("GOOGLE_OAUTH_CLIENT_SECRET") : "";
    redirectUri_ = std::getenv("GOOGLE_OAUTH_REDIRECT_URI") ? std::getenv("GOOGLE_OAUTH_REDIRECT_URI") : "";
    
    std::cout << "OAuthController initialized with:" << std::endl;
    std::cout << "  Client ID: " << (clientId_.empty() ? "NOT SET" : "SET") << std::endl;
    std::cout << "  Client Secret: " << (clientSecret_.empty() ? "NOT SET" : "SET") << std::endl;
    std::cout << "  Redirect URI: " << redirectUri_ << std::endl;
}

void OAuthController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/login", [this](const Request& req) {
        return this->handleGoogleLogin(req);
    });
    
    router.get(prefix + "/callback", [this](const Request& req) {
        return this->handleGoogleCallback(req);
    });
}

std::string OAuthController::getGoogleAuthUrl() {
    std::string authUrl = "https://accounts.google.com/o/oauth2/v2/auth";
    authUrl += "?client_id=" + urlEncode(clientId_);
    authUrl += "&redirect_uri=" + urlEncode(redirectUri_);
    authUrl += "&response_type=code";
    authUrl += "&scope=" + urlEncode("openid email profile");
    authUrl += "&access_type=offline";
    authUrl += "&prompt=consent";
    
    return authUrl;
}

Response OAuthController::handleGoogleLogin(const Request& request) {
    if (clientId_.empty() || clientSecret_.empty() || redirectUri_.empty()) {
        return Response::internalError("OAuth configuration not set");
    }
    
    std::string authUrl = getGoogleAuthUrl();
    
    // Return 302 redirect to Google
    Response response = Response::ok();
    response.setStatus(HttpStatus::FOUND);
    response.setHeader("Location", authUrl);
    return response;
}

std::map<std::string, std::string> OAuthController::exchangeCodeForToken(const std::string& code) {
    CURL* curl = curl_easy_init();
    std::string responseBuffer;
    
    if (!curl) {
        std::cerr << "Failed to initialize CURL" << std::endl;
        return {};
    }
    
    // Build POST data
    std::string postData = "code=" + urlEncode(code);
    postData += "&client_id=" + urlEncode(clientId_);
    postData += "&client_secret=" + urlEncode(clientSecret_);
    postData += "&redirect_uri=" + urlEncode(redirectUri_);
    postData += "&grant_type=authorization_code";
    
    curl_easy_setopt(curl, CURLOPT_URL, "https://oauth2.googleapis.com/token");
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
    
    CURLcode res = curl_easy_perform(curl);
    
    if (res != CURLE_OK) {
        std::cerr << "CURL error: " << curl_easy_strerror(res) << std::endl;
        curl_easy_cleanup(curl);
        return {};
    }
    
    curl_easy_cleanup(curl);
    
    std::cout << "Token response: " << responseBuffer << std::endl;
    return parseJsonResponse(responseBuffer);
}

std::map<std::string, std::string> OAuthController::getUserInfo(const std::string& accessToken) {
    CURL* curl = curl_easy_init();
    std::string responseBuffer;
    
    if (!curl) {
        std::cerr << "Failed to initialize CURL" << std::endl;
        return {};
    }
    
    std::string url = "https://www.googleapis.com/oauth2/v2/userinfo?access_token=" + accessToken;
    
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
    
    CURLcode res = curl_easy_perform(curl);
    
    if (res != CURLE_OK) {
        std::cerr << "CURL error: " << curl_easy_strerror(res) << std::endl;
        curl_easy_cleanup(curl);
        return {};
    }
    
    curl_easy_cleanup(curl);
    
    std::cout << "User info response: " << responseBuffer << std::endl;
    return parseJsonResponse(responseBuffer);
}

std::string OAuthController::findOrCreateUser(const std::map<std::string, std::string>& userInfo) {
    auto db = Database::getInstance();
    std::string email = userInfo.at("email");
    
    // Check if user exists
    std::string query = "SELECT id FROM users WHERE email = '" + email + "'";
    auto result = db->query(query);
    
    if (!result.empty()) {
        return result[0]["id"].as<std::string>();
    }
    
    // Create new user
    std::string firstName = userInfo.count("given_name") ? userInfo.at("given_name") : "";
    std::string lastName = userInfo.count("family_name") ? userInfo.at("family_name") : "";
    
    std::string insertQuery = "INSERT INTO users (email, first_name, last_name) VALUES ('"
        + email + "', '" + firstName + "', '" + lastName + "') RETURNING id";
    
    auto insertResult = db->query(insertQuery);
    if (insertResult.empty()) {
        return "";
    }
    
    return insertResult[0]["id"].as<std::string>();
}

std::string OAuthController::generateJWT(const std::string& userId, const std::string& email) {
    // Simple JWT generation (in production, use a proper JWT library)
    std::string payload = "{\"userId\":\"" + userId + "\",\"email\":\"" + email + "\"}";
    
    // For now, just base64 encode (NOT SECURE - just for demo)
    // In production, use proper HMAC-SHA256 signing
    return "jwt_" + userId;
}

Response OAuthController::handleGoogleCallback(const Request& request) {
    std::cout << "OAuth callback received" << std::endl;
    
    // Get authorization code from query params
    auto params = request.getQueryParams();
    if (params.count("code") == 0) {
        std::cerr << "No authorization code in callback" << std::endl;
        return Response::badRequest("Missing authorization code");
    }
    
    std::string code = params.at("code");
    std::cout << "Got authorization code: " << code.substr(0, 20) << "..." << std::endl;
    
    // Exchange code for token
    auto tokenData = exchangeCodeForToken(code);
    if (tokenData.empty() || tokenData.count("access_token") == 0) {
        std::cerr << "Failed to exchange code for token" << std::endl;
        return Response::internalError("Failed to exchange authorization code");
    }
    
    std::string accessToken = tokenData["access_token"];
    std::cout << "Got access token, fetching user info..." << std::endl;
    
    // Get user info from Google
    auto userInfo = getUserInfo(accessToken);
    if (userInfo.empty() || userInfo.count("email") == 0) {
        std::cerr << "Failed to get user info" << std::endl;
        return Response::internalError("Failed to fetch user information");
    }
    
    std::cout << "Got user info for: " << userInfo["email"] << std::endl;
    
    // Find or create user in database
    std::string userId = findOrCreateUser(userInfo);
    if (userId.empty()) {
        return Response::internalError("Failed to create or find user");
    }
    
    // Generate JWT token
    std::string jwtToken = generateJWT(userId, userInfo["email"]);
    
    // Redirect to frontend with token
    std::string redirectUrl = "http://localhost:3000/oauth-success?token=" + jwtToken;
    
    Response response = Response::ok();
    response.setStatus(HttpStatus::FOUND);
    response.setHeader("Location", redirectUrl);
    return response;
}
