#include "OAuthController.h"
#include "../core/Crypto.h"
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

    // Lightweight config probe so the login page can hide/disable the
    // Google button when creds aren't set instead of letting the user
    // click through to a 500 error page.  Never reveals the actual
    // credential values — just a boolean.
    router.get(prefix + "/status", [this](const Request& req) {
        return this->handleGoogleStatus(req);
    });
}

std::string OAuthController::getGoogleAuthUrl() {
    // Base scopes = just what's needed for identity ("who is this user?").
    // `openid email profile` are all NON-sensitive scopes — Google does NOT
    // require app verification for them, so we can Publish the OAuth
    // consent screen immediately with no "unverified app" warning.
    //
    // `https://www.googleapis.com/auth/drive.readonly` was originally in
    // this string to power the Drive photo browser in
    // frontend/js/screens/content-posts.js.  Drive is a "sensitive" scope:
    // requesting it puts the app in Google's verification queue (4–6 weeks
    // to complete) and until verification finishes, users see a scary
    // "Google hasn't verified this app" red interstitial and refresh
    // tokens expire in 7 days.  Neither is acceptable at go-live.
    //
    // How to re-enable Drive later (post-verification) WITHOUT a redeploy:
    // set GOOGLE_OAUTH_EXTRA_SCOPES in env to the space-separated extra
    // scopes, e.g.:
    //     GOOGLE_OAUTH_EXTRA_SCOPES=https://www.googleapis.com/auth/drive.readonly
    // then `make restart`.  Existing users will need to log out + back in
    // once for the new scope to actually get granted.
    std::string scopes = "openid email profile";
    const char* extra = std::getenv("GOOGLE_OAUTH_EXTRA_SCOPES");
    if (extra && *extra) {
        scopes += " ";
        scopes += extra;
    }

    std::string authUrl = "https://accounts.google.com/o/oauth2/v2/auth";
    authUrl += "?client_id=" + urlEncode(clientId_);
    authUrl += "&redirect_uri=" + urlEncode(redirectUri_);
    authUrl += "&response_type=code";
    authUrl += "&scope=" + urlEncode(scopes);
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

Response OAuthController::handleGoogleStatus(const Request& /*request*/) {
    // No auth required — this is what the login page probes BEFORE the
    // user has a token.  Returns only booleans; no secret material leaks.
    const bool configured =
        !clientId_.empty() && !clientSecret_.empty() && !redirectUri_.empty();

    std::ostringstream body;
    body << "{\"configured\":" << (configured ? "true" : "false") << "}";

    Response response(HttpStatus::OK, body.str());
    response.setHeader("Content-Type", "application/json");
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
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
        
        // Check if email exists in person_emails table, join to users
        std::string checkEmailSql = "SELECT u.id AS user_id FROM person_emails pe "
                                   "JOIN users u ON u.person_id = pe.person_id "
                                   "WHERE pe.email = " + db->escape(email);
        pqxx::result existingEmail = db->query(checkEmailSql);
        
        if (!existingEmail.empty()) {
            std::string userId = existingEmail[0]["user_id"].as<std::string>();
            std::cout << "Found existing user via email: " << userId << std::endl;
            return userId;
        }
        
        // Create new person + user for Google OAuth users who don't exist yet
        std::string insertPersonSql = "INSERT INTO persons (first_name, last_name) "
                                     "VALUES (" + db->escape(firstName) + ", " + db->escape(lastName) + ") "
                                     "RETURNING id";
        pqxx::result newPerson = db->query(insertPersonSql);
        std::string personId = newPerson[0]["id"].as<std::string>();
        
        std::string insertUserSql = "INSERT INTO users (person_id, is_active) "
                                   "VALUES (" + db->escape(personId) + ", true) "
                                   "RETURNING id";
        pqxx::result newUser = db->query(insertUserSql);
        std::string userId = newUser[0]["id"].as<std::string>();
        
        // Add email to person_emails table
        std::string insertEmailSql = "INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified) "
                                    "VALUES (" + db->escape(personId) + ", " + db->escape(email) + ", 1, true, true)";
        db->query(insertEmailSql);
        
        std::cout << "Created new user via Google OAuth: " << userId << " (person: " << personId << ") with email: " << email << std::endl;
        return userId;
        
    } catch (const std::exception& e) {
        std::cerr << "Database error in findOrCreateUser: " << e.what() << std::endl;
        return "";
    }
}

std::string OAuthController::generateJWT(const std::string& userId, const std::string& email) {
    // HS256-signed JWT.  Payload shape MUST stay byte-compatible with
    // AuthController::generateJWT: {"userId","email","role","iat","exp"}
    // in that exact order.  role="" here because Google OAuth doesn't
    // know the app-side role yet — the frontend fetches /api/auth/me
    // after login to resolve it.  If you change one generator, change
    // the other, or Controller::requireBearer will start rejecting
    // tokens minted by whichever generator drifted.
    const std::time_t now = std::time(nullptr);
    const std::time_t exp = now + (90LL * 24 * 60 * 60);  // 90 days

    std::ostringstream payload;
    payload << "{";
    payload << "\"userId\":\"" << userId << "\",";
    payload << "\"email\":\""  << email  << "\",";
    payload << "\"role\":\"\",";
    payload << "\"iat\":" << now << ",";
    payload << "\"exp\":" << exp;
    payload << "}";

    const std::string token = fh::crypto::signJwtHS256(payload.str());
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
    
    // Store Google tokens for Drive API access — only when Drive scope
    // was actually requested (see GOOGLE_OAUTH_EXTRA_SCOPES in
    // getGoogleAuthUrl above).  If we didn't ask for Drive scope, the
    // access_token can't call Drive anyway, so persisting it is dead
    // weight and just clutters user_google_tokens with rows that expire
    // in an hour and never get used.  The row is still upserted when
    // Drive scope IS present so content-posts.js keeps working.
    const char* extraScopes = std::getenv("GOOGLE_OAUTH_EXTRA_SCOPES");
    const bool haveDriveScope =
        extraScopes && std::string(extraScopes).find("drive") != std::string::npos;

    if (haveDriveScope) try {
        auto db = Database::getInstance();
        std::string refreshToken = tokenData.count("refresh_token") ? tokenData.at("refresh_token") : "";
        int expSec = 3600;
        if (tokenData.count("expires_in")) {
            try { expSec = std::stoi(tokenData.at("expires_in")); } catch (...) {}
        }
        
        std::string upsertSql = "INSERT INTO user_google_tokens (user_id, access_token, refresh_token, expires_at) "
            "VALUES (" + db->escape(userId) + ", " + db->escape(accessToken) + ", " +
            (refreshToken.empty() ? "NULL" : db->escape(refreshToken)) + ", "
            "NOW() + INTERVAL '" + std::to_string(expSec) + " seconds') "
            "ON CONFLICT (user_id) DO UPDATE SET "
            "access_token = EXCLUDED.access_token, "
            "refresh_token = COALESCE(EXCLUDED.refresh_token, user_google_tokens.refresh_token), "
            "expires_at = EXCLUDED.expires_at, "
            "updated_at = NOW()";
        db->query(upsertSql);
        std::cout << "Stored Google tokens for user " << userId << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Failed to store Google tokens: " << e.what() << std::endl;
    }
    
    // Generate JWT token
    std::string jwt = generateJWT(userId, userInfo["email"]);
    
    // Redirect to frontend with token (FRONTEND_URL env overrides for prod)
    const char* feEnv = std::getenv("FRONTEND_URL");
    std::string frontendBase = (feEnv && *feEnv) ? feEnv : "http://localhost:3000";
    std::string frontendUrl = frontendBase + "/oauth-success?token=" + urlEncode(jwt);
    
    Response response = Response::ok();
    response.setStatus(HttpStatus::FOUND);
    response.setHeader("Location", frontendUrl);
    return response;
}
