#ifndef TWILIO_SMS_SERVICE_H
#define TWILIO_SMS_SERVICE_H

#include <string>
#include <curl/curl.h>
#include <mutex>

class TwilioSMSService {
public:
    static TwilioSMSService& getInstance();
    
    void initialize(const std::string& accountSid, 
                   const std::string& authToken, 
                   const std::string& fromPhone);
    
    bool sendSMS(const std::string& toPhone, const std::string& message);
    
    // Delete copy constructor and assignment operator (singleton)
    TwilioSMSService(const TwilioSMSService&) = delete;
    TwilioSMSService& operator=(const TwilioSMSService&) = delete;

private:
    TwilioSMSService() = default;
    ~TwilioSMSService() = default;
    
    static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp);
    std::string urlEncode(const std::string& str);
    
    std::string accountSid_;
    std::string authToken_;
    std::string fromPhone_;
    bool initialized_ = false;
    std::mutex mutex_;
};

#endif // TWILIO_SMS_SERVICE_H
