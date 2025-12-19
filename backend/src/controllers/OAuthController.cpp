#include "OAuthController.h"
#include "../core/HttpStatus.h"
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
            escaped << '%' << std::setw(2) << int((unsigned char)c);
            escaped << std::nouppercase;
        }
    }

    return escaped.str();
}

// Simple JSON parser for responses
std::map<std::string, std::string> parseJsonResponse(const std::string& json) {
    std::map<std::string, std::string> result;
    
    // Very simple parser - extract "key":"value" pairs
    size_t pos = 0;
    while (pos < json.length()) {
        size_t keyStart = json.find("\"", pos);
        if (keyStart == std::string::npos) break;
        
        size_t keyEnd = json.find("\"", keyStart + 1);
        if (keyEnd == std::string::npos) break;
        
        std::string key = json.substr(keyStart + 1, keyEnd - keyStart - 1);
        
        size_t colonPos = json.find(":", keyEnd);
        if (colonPos == std::string::npos) break;
        
        size_t valueStart = json.find("\"", colonPos);
        if (valueStart == std::string::npos) {
            pos = colonPos + 1;
            continue;
        }
        
        size_t valueEnd = json.find("\"", valueStart + 1);
        if (valueEnd == std::string::npos) break;
        
        std::string value = json.substr(valueStart + 1, valueEnd - valueStart - 1);
        result[key] = value;
        
        pos = valueEnd + 1;
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

Response OAuthController::handleRequest(const Request& request) {
    if (request.method == "GET" && request.path == "/api/auth/google/login") {
        return handleGoogleLogin(request);
    } else if (request.method == "GET" && request.path == "/api/auth/google/callback") {
        return handleGoogleCallback(request);
    }
    
    return Response(HttpStatus::NOT_FOUND, "application/json", 
                   R"({"error": "OAuth endpoint not found"})");
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
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "application/json",
                       R"({"error": "OAuth configuration not set"})");
    }
    
    std::string authUrl = getGoogleAuthUrl();
    
    // Return 302 redirect to Google
    std::string headers = "Location: " + authUrl + "\r\n";
    return Response(HttpStatus::FOUND, "text/html", "", headers);
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
    
    long httpCode = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
    curl_easy_cleanup(curl);
    
    if (httpCode != 200) {
        std::cerr << "Token exchange failed with HTTP " << httpCode << std::endl;
        std::cerr << "Response: " << responseBuffer << std::endl;
        return {};
    }
    
    return parseJsonResponse(responseBuffer);
}

std::map<std::string, std::string> OAuthController::getUserInfo(const std::string& accessToken) {
    CURL* curl = curl_easy_init();
    std::string responseBuffer;
    
    if (!curl) {
        return {};
    }
    
    struct curl_slist* headers = nullptr;
    std::string authHeader = "Authorization: Bearer " + accessToken;
    headers = curl_slist_append(headers, authHeader.c_str());
    
    curl_easy_setopt(curl, CURLOPT_URL, "https://www.googleapis.com/oauth2/v2/userinfo");
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
    
    CURLcode res = curl_easy_perform(curl);
    
    curl_slist_free_all(headers);
    
    if (res != CURLE_OK) {
        std::cerr << "CURL error fetching user info: " << curl_easy_strerror(res) << std::endl;
        curl_easy_cleanup(curl);
        return {};
    }
    
    long httpCode = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
    curl_easy_cleanup(curl);
    
    if (httpCode != 200) {
        std::cerr << "User info fetch failed with HTTP " << httpCode << std::endl;
        return {};
    }
    
    return parseJsonResponse(responseBuffer);
}

std::string OAuthController::findOrCreateUser(const std::map<std::string, std::string>& userInfo) {
    auto it = userInfo.find("email");
    if (it == userInfo.end()) {
        std::cerr << "No email in user info" << std::endl;
        return "";
    }
    
    std::string email = it->second;
    std::string firstName = userInfo.count("given_name") ? userInfo.at("given_name") : "";
    std::string lastName = userInfo.count("family_name") ? userInfo.at("family_name") : "";
    
    try {
        auto conn = Database::getInstance().getConnection();
        pqxx::work txn(*conn);
        
        // Check if user exists
        pqxx::result existingUser = txn.exec_params(
            "SELECT id FROM users WHERE email = $1",
            email
        );
        
        if (!existingUser.empty()) {
            std::string userId = existingUser[0]["id"].as<std::string>();
            txn.commit();
            std::cout << "Found existing user: " << userId << std::endl;
            return userId;
        }
        
        // Create new user
        pqxx::result newUser = txn.exec_params(
            "INSERT INTO users (email, first_name, last_name, password_hash, is_active, email_verified) "
            "VALUES ($1, $2, $3, 'oauth-google', true, true) "
            "RETURNING id",
            email, firstName, lastName
        );
        
        std::string userId = newUser[0]["id"].as<std::string>();
        txn.commit();
        
        std::cout << "Created new user via Google OAuth: " << userId << std::endl;
        return userId;
        
    } catch (const std::exception& e) {
        std::cerr << "Database error in findOrCreateUser: " << e.what() << std::endl;
        return "";
    }
}

std::string OAuthController::generateJWT(const std::string& userId, const std::string& email) {
    // Simple JWT generation (for production, use a proper JWT library)
    std::string header = R"({"alg":"HS256","typ":"JWT"})";
    
    std::time_t now = std::time(nullptr);
    std::time_t exp = now + (24 * 60 * 60); // 24 hours
    
    std::ostringstream payloadStream;
    payloadStream << R"({"userId":")" << userId << R"(",)";
    payloadStream << R"("email":")" << email << R"(",)";
    payloadStream << R"("iat":)" << now << R"(,)";
    payloadStream << R"("exp":)" << exp << "}";
    std::string payload = payloadStream.str();
    
    // Note: This is simplified - in production, use base64url encoding and proper signing
    std::string token = header + "." + payload + ".signature";
    
    return token;
}

Response OAuthController::handleGoogleCallback(const Request& request) {
    // Extract code from query parameters
    std::string code;
    size_t codePos = request.path.find("code=");
    if (codePos != std::string::npos) {
        size_t codeStart = codePos + 5;
        size_t codeEnd = request.path.find("&", codeStart);
        if (codeEnd == std::string::npos) {
            code = request.path.substr(codeStart);
        } else {
            code = request.path.substr(codeStart, codeEnd - codeStart);
        }
    }
    
    if (code.empty()) {
        std::cerr << "No authorization code in callback" << std::endl;
        return Response(HttpStatus::BAD_REQUEST, "application/json",
                       R"({"error": "No authorization code received"})");
    }
    
    std::cout << "Received OAuth code, exchanging for token..." << std::endl;
    
    // Exchange code for access token
    auto tokenData = exchangeCodeForToken(code);
    if (tokenData.empty() || tokenData.count("access_token") == 0) {
        std::cerr << "Failed to exchange code for token" << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "application/json",
                       R"({"error": "Failed to exchange authorization code"})");
    }
    
    std::string accessToken = tokenData["access_token"];
    std::cout << "Got access token, fetching user info..." << std::endl;
    
    // Get user info from Google
    auto userInfo = getUserInfo(accessToken);
    if (userInfo.empty() || userInfo.count("email") == 0) {
        std::cerr << "Failed to get user info" << std::endl;
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "application/json",
                       R"({"error": "Failed to fetch user information"})");
    }
    
    std::cout << "Got user info for: " << userInfo["email"] << std::endl;
    
    // Find or create user in database
    std::string userId = findOrCreateUser(userInfo);
    if (userId.empty()) {
        return Response(HttpStatus::INTERNAL_SERVER_ERROR, "application/json",
                       R"({"error": "Failed to create or find user"})");
    }
    
    // Generate JWT token
    std::string jwt = generateJWT(userId, userInfo["email"]);
    
    // Redirect to frontend with token
    std::string frontendUrl = "http://localhost:3000/oauth-success?token=" + urlEncode(jwt);
    std::string headers = "Location: " + frontendUrl + "\r\n";
    
    return Response(HttpStatus::FOUND, "text/html", "", headers);
}
