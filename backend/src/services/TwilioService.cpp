#include "TwilioService.h"

#include <cctype>
#include <cstdlib>
#include <iostream>

#include "../core/HttpClient.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

std::string envOr(const char* name) {
    const char* v = std::getenv(name);
    return v ? std::string(v) : std::string();
}

// Standard base64 (with padding) for the Basic auth header — Crypto.h's
// base64UrlEncode is the URL-safe alphabet, which HTTP Basic is not.
std::string base64(const std::string& in) {
    static const char* tbl = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string out;
    int val = 0, bits = -6;
    for (unsigned char c : in) {
        val = (val << 8) + c;
        bits += 8;
        while (bits >= 0) { out.push_back(tbl[(val >> bits) & 0x3F]); bits -= 6; }
    }
    if (bits > -6) out.push_back(tbl[((val << 8) >> (bits + 8)) & 0x3F]);
    while (out.size() % 4) out.push_back('=');
    return out;
}

std::string xmlEscape(const std::string& s) {
    std::string out;
    for (char c : s) {
        switch (c) {
            case '&':  out += "&amp;";  break;
            case '<':  out += "&lt;";   break;
            case '>':  out += "&gt;";   break;
            case '"':  out += "&quot;"; break;
            case '\'': out += "&apos;"; break;
            default:   out.push_back(c);
        }
    }
    return out;
}

}  // namespace

TwilioService& TwilioService::getInstance() {
    static TwilioService instance;
    return instance;
}

TwilioService::TwilioService() {
    sid_   = envOr("TWILIO_ACCOUNT_SID");
    token_ = envOr("TWILIO_AUTH_TOKEN");
    from_  = envOr("TWILIO_FROM_NUMBER");
    configured_ = !sid_.empty() && !token_.empty() && !from_.empty();
    if (!configured_) {
        std::cerr << "[TwilioService] not configured (TWILIO_ACCOUNT_SID / TWILIO_AUTH_TOKEN / "
                     "TWILIO_FROM_NUMBER) — SMS and calls disabled" << std::endl;
    }
}

TwilioService::~TwilioService() = default;

bool TwilioService::configured() { return configured_; }
const std::string& TwilioService::fromNumber() { return from_; }

std::string TwilioService::normalizeUs(const std::string& raw) {
    std::string digits;
    for (unsigned char c : raw) if (std::isdigit(c)) digits.push_back(static_cast<char>(c));
    if (digits.size() == 10) return "+1" + digits;
    if (digits.size() == 11 && digits[0] == '1') return "+" + digits;
    if (!raw.empty() && raw[0] == '+' && digits.size() >= 11 && digits.size() <= 15) return "+" + digits;
    return "";
}

TwilioService::Result TwilioService::post(const std::string& resource, const std::string& formBody) {
    Result res;
    if (!configured_) { res.error = "twilio not configured"; return res; }
    HttpClient http;
    const std::string url = "https://api.twilio.com/2010-04-01/Accounts/" + sid_ + "/" + resource + ".json";
    HttpClient::Headers headers = {{"Authorization", "Basic " + base64(sid_ + ":" + token_)}};
    auto r = http.postForm(url, formBody, headers);
    if (!r.error.empty()) { res.error = "transport: " + r.error; return res; }
    try {
        json j = json::parse(r.body);
        if (r.status >= 200 && r.status < 300 && j.contains("sid")) {
            res.ok = true;
            res.sid = j["sid"].get<std::string>();
            return res;
        }
        res.error = "HTTP " + std::to_string(r.status);
        if (j.contains("message") && j["message"].is_string()) res.error += ": " + j["message"].get<std::string>();
        if (j.contains("code") && j["code"].is_number()) res.error += " (code " + std::to_string(j["code"].get<long long>()) + ")";
    } catch (const std::exception& e) {
        res.error = "HTTP " + std::to_string(r.status) + ": unparseable reply";
    }
    return res;
}

TwilioService::Result TwilioService::sendSms(const std::string& toE164, const std::string& body) {
    const std::string form = "From=" + HttpClient::urlEncode(from_) +
                             "&To=" + HttpClient::urlEncode(toE164) +
                             "&Body=" + HttpClient::urlEncode(body);
    auto res = post("Messages", form);
    if (!res.ok) std::cerr << "[TwilioService] sms to " << toE164 << " failed: " << res.error << std::endl;
    return res;
}

TwilioService::Result TwilioService::call(const std::string& toE164, const std::string& sayText) {
    // Say it twice with a pause — the first sentence is often lost while
    // the phone comes up to the ear.
    const std::string say = "<Say voice=\"Polly.Joanna\">" + xmlEscape(sayText) + "</Say>";
    const std::string twiml = "<Response>" + say + "<Pause length=\"1\"/>" + say + "</Response>";
    const std::string form = "From=" + HttpClient::urlEncode(from_) +
                             "&To=" + HttpClient::urlEncode(toE164) +
                             "&Twiml=" + HttpClient::urlEncode(twiml);
    auto res = post("Calls", form);
    if (!res.ok) std::cerr << "[TwilioService] call to " << toE164 << " failed: " << res.error << std::endl;
    return res;
}
