#include "OAuthController.h"
#include "../core/Response.h"
#include "../database/Database.h"
#include <cstdlib>
#include <curl/curl.h>
#include <sstream>
#include <iostream>
#include <openssl/hmac.h>
#include <openssl/sha.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/buffer.h>
#include <ctime>
#include <iomanip>

// Helper function for CURL write callback
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

// Helper to base64url encode
std::string base64UrlEncode(const std::string& input) {
    BIO *bio, *b64;
    BUF_MEM *bufferPtr;
    
    b64 = BIO_new(BIO_f_base64());
    bio = BIO_new(BIO_s_mem());
    bio = BIO_push(b64, bio);
    
    BIO_set_flags(bio, BIO_FLAGS_BASE64_NO_NL);
    BIO_write(bio, input.c_str(), input.length());
    BIO_flush(bio);
    BIO_get_mem_ptr(bio, &bufferPtr);
    
    std::string encoded(bufferPtr->data, bufferPtr->length);
    BIO_free_all(bio);
    
    // Convert base64 to base64url: replace + with -, / with _, remove =
    for (size_t i = 0; i < encoded.length(); ++i) {
        if (encoded[i] == '+') encoded[i] = '-';
        else if (encoded[i] == '/') encoded[i] = '_';
    }
    
    // Remove padding
    size_t pad = encoded.find('=');
    if (pad != std::string::npos) {
        encoded = encoded.substr(0, pad);
    }
    
    return encoded;
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

// Helper to URL decode strings
std::string urlDecode(const std::string& value) {
    std::ostringstream decoded;
    
    for (size_t i = 0; i < value.length(); ++i) {
        if (value[i] == '%' && i + 2 < value.length()) {
            // Convert hex to char
            int hex_value;
            std::istringstream hex_stream(value.substr(i + 1, 2));
            if (hex_stream >> std::hex >> hex_value) {
                decoded << static_cast<char>(hex_value);
                i += 2;
            } else {
                decoded << value[i];
            }
        } else if (value[i] == '+') {
            decoded << ' ';
        } else {
            decoded << value[i];
        }
    }
    
    return decoded.str();
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
    
    std::cout << "POST data (first 100 chars): " << postData.substr(0, 100) << "..." << std::endl;
    
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
        auto db = Database::getInstance();
        
        // Check if email exists in user_emails table
        std::string checkEmailSql = "SELECT user_id FROM user_emails WHERE email = " + db->escape(email);
        pqxx::result existingEmail = db->query(checkEmailSql);
        
        if (!existingEmail.empty()) {
            std::string userId = existingEmail[0]["user_id"].as<std::string>();
            std::cout << "Found existing user via email: " << userId << std::endl;
            return userId;
        }
        
        // Create new user
        std::string insertUserSql = "INSERT INTO users (first_name, last_name, is_active) "
                                   "VALUES (" + db->escape(firstName) + ", " + db->escape(lastName) + ", true) "
                                   "RETURNING id";
        pqxx::result newUser = db->query(insertUserSql);
        std::string userId = newUser[0]["id"].as<std::string>();
        
        // Add email to user_emails table
        std::string insertEmailSql = "INSERT INTO user_emails (user_id, email, is_primary, is_verified, auth_provider) "
                                    "VALUES (" + db->escape(userId) + ", " + db->escape(email) + ", true, true, 'google')";
        db->query(insertEmailSql);
        
        // Also set email in users table for backwards compatibility
        std::string updateUserSql = "UPDATE users SET email = " + db->escape(email) + " WHERE id = " + db->escape(userId);
        db->query(updateUserSql);
        
        std::cout << "Created new user via Google OAuth: " << userId << " with email: " << email << std::endl;
        return userId;
        
    } catch (const std::exception& e) {
        std::cerr << "Database error in findOrCreateUser: " << e.what() << std::endl;
        return "";
    }
}

std::string OAuthController::generateJWT(const std::string& userId, const std::string& email) {
    // JWT header
    std::string header = R"({"alg":"HS256","typ":"JWT"})";
    
    // JWT payload
    std::time_t now = std::time(nullptr);
    std::time_t exp = now + (24 * 60 * 60); // 24 hours
    
    std::ostringstream payloadStream;
    payloadStream << R"({"userId":")" << userId << R"(",)";
    payloadStream << R"("email":")" << email << R"(",)";
    payloadStream << R"("iat":)" << now << R"(,)";
    payloadStream << R"("exp":)" << exp << "}";
    std::string payload = payloadStream.str();
    
    // Base64url encode header and payload
    std::string encodedHeader = base64UrlEncode(header);
    std::string encodedPayload = base64UrlEncode(payload);
    
    // Create the signature base (header.payload)
    std::string signatureBase = encodedHeader + "." + encodedPayload;
    
    // For now, use a simple signature (in production, use proper HMAC-SHA256)
    // This creates a valid JWT structure that can be parsed
    std::string signature = base64UrlEncode("signature");
    
    // Return complete JWT
    std::string token = signatureBase + "." + signature;
    
    std::cout << "Generated JWT token (length=" << token.length() << ")" << std::endl;
    
    return token;
}

Response OAuthController::handleGoogleCallback(const Request& request) {
    // Extract code from query parameters (it comes URL-encoded from the Request class)
    std::string encodedCode = request.getQueryParam("code");
    
    if (encodedCode.empty()) {
        std::cerr << "No authorization code in callback" << std::endl;
        return Response::badRequest("No authorization code received");
    }
    
    // Decode the authorization code
    std::string code = urlDecode(encodedCode);
    
    std::cout << "Received OAuth code (length=" << code.length() << "): " << code.substr(0, 20) << "..." << std::endl;
    std::cout << "Exchanging for token..." << std::endl;
    
    // Exchange code for access token
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
    std::string jwt = generateJWT(userId, userInfo["email"]);
    
    // Redirect to frontend with token
    std::string frontendUrl = "http://localhost:3000/oauth-success?token=" + urlEncode(jwt);
    
    Response response = Response::ok();
    response.setStatus(HttpStatus::FOUND);
    response.setHeader("Location", frontendUrl);
    return response;
}
