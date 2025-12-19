#include "TwilioSMSService.h"
#include <iostream>
#include <sstream>
#include <iomanip>

TwilioSMSService& TwilioSMSService::getInstance() {
    static TwilioSMSService instance;
    return instance;
}

void TwilioSMSService::initialize(const std::string& accountSid, 
                                   const std::string& authToken, 
                                   const std::string& fromPhone) {
    std::lock_guard<std::mutex> lock(mutex_);
    accountSid_ = accountSid;
    authToken_ = authToken;
    fromPhone_ = fromPhone;
    initialized_ = true;
    std::cout << "✅ TwilioSMSService initialized with from phone: " << fromPhone_ << std::endl;
}

size_t TwilioSMSService::WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::string TwilioSMSService::urlEncode(const std::string& str) {
    std::ostringstream escaped;
    escaped.fill('0');
    escaped << std::hex;

    for (char c : str) {
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

bool TwilioSMSService::sendSMS(const std::string& toPhone, const std::string& message) {
    std::lock_guard<std::mutex> lock(mutex_);
    
    if (!initialized_) {
        std::cerr << "❌ TwilioSMSService not initialized!" << std::endl;
        return false;
    }

    CURL* curl = curl_easy_init();
    if (!curl) {
        std::cerr << "❌ Failed to initialize CURL for SMS" << std::endl;
        return false;
    }

    // Twilio API endpoint
    std::string url = "https://api.twilio.com/2010-04-01/Accounts/" + accountSid_ + "/Messages.json";
    
    // Build POST data
    std::string postData = "To=" + urlEncode(toPhone) + 
                          "&From=" + urlEncode(fromPhone_) + 
                          "&Body=" + urlEncode(message);
    
    // Response buffer
    std::string responseBuffer;
    
    // Set up CURL
    curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
    curl_easy_setopt(curl, CURLOPT_POST, 1L);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, postData.c_str());
    
    // Basic auth (accountSid:authToken)
    std::string auth = accountSid_ + ":" + authToken_;
    curl_easy_setopt(curl, CURLOPT_USERPWD, auth.c_str());
    
    // Set write callback
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseBuffer);
    
    // Perform request
    CURLcode res = curl_easy_perform(curl);
    
    long httpCode = 0;
    curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &httpCode);
    
    curl_easy_cleanup(curl);
    
    if (res != CURLE_OK) {
        std::cerr << "❌ SMS send failed: " << curl_easy_strerror(res) << std::endl;
        return false;
    }
    
    if (httpCode >= 200 && httpCode < 300) {
        std::cout << "✅ SMS sent successfully to " << toPhone << std::endl;
        std::cout << "   Message: " << message << std::endl;
        return true;
    } else {
        std::cerr << "❌ SMS send failed with HTTP " << httpCode << std::endl;
        std::cerr << "   Response: " << responseBuffer << std::endl;
        return false;
    }
}
