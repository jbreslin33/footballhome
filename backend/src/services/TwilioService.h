#pragma once
#include <memory>
#include <string>

class HttpClient;

// ────────────────────────────────────────────────────────────────────────────
// TwilioService — the backend's only way to send an SMS or place a phone
// call (2026-09-24, for the facility lock-up alert; see LockupScheduler).
//
// Env: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_FROM_NUMBER (E.164).
// When any is missing configured() is false and every send returns
// !ok with error "twilio not configured" — callers log and carry on,
// the same way fh::mail::send() degrades without SMTP.
//
// SMS to US numbers only delivers once the A2P 10DLC campaign on the
// Twilio account is approved (submitted 2026-09-24); until then Twilio
// answers with error 30034 and that lands in Result.error.  Voice calls
// need no registration.  A call speaks `sayText` twice via inline TwiML
// (no webhook to host).
//
// Never throws.  Safe to call from any thread (fresh HttpClient per
// call, config read once).
// ────────────────────────────────────────────────────────────────────────────
class TwilioService {
public:
    struct Result {
        bool        ok = false;
        std::string sid;      // Twilio message / call SID on success
        std::string error;    // human-readable failure
    };

    static TwilioService& getInstance();

    bool configured();
    const std::string& fromNumber();

    // Digits → E.164 for US numbers: "(215) 555-1212" → "+12155551212".
    // Returns "" when the input cannot be a phone number.
    static std::string normalizeUs(const std::string& raw);

    Result sendSms(const std::string& toE164, const std::string& body);
    Result call(const std::string& toE164, const std::string& sayText);

private:
    TwilioService();
    ~TwilioService();
    TwilioService(const TwilioService&) = delete;
    TwilioService& operator=(const TwilioService&) = delete;

    Result post(const std::string& resource, const std::string& formBody);

    std::string sid_, token_, from_;
    bool configured_ = false;
};
