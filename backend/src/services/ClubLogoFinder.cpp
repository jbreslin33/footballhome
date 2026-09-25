#include "ClubLogoFinder.h"

#include <cstdlib>
#include <iostream>

#include "../core/HttpClient.h"
#include "../models/MessageCopy.h"

using nlohmann::json;

namespace {

std::string envOr(const char* name, const std::string& fallback = {}) {
    const char* v = std::getenv(name);
    return (v && *v) ? std::string{v} : fallback;
}

std::string base64Std(const std::string& in) {
    static const char* a = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    std::string out;
    out.reserve((in.size() + 2) / 3 * 4);
    size_t i = 0;
    while (i + 2 < in.size()) {
        unsigned n = (static_cast<unsigned char>(in[i]) << 16) | (static_cast<unsigned char>(in[i + 1]) << 8) | static_cast<unsigned char>(in[i + 2]);
        out.push_back(a[(n >> 18) & 63]); out.push_back(a[(n >> 12) & 63]); out.push_back(a[(n >> 6) & 63]); out.push_back(a[n & 63]);
        i += 3;
    }
    if (i < in.size()) {
        unsigned n = static_cast<unsigned char>(in[i]) << 16;
        if (i + 1 < in.size()) n |= static_cast<unsigned char>(in[i + 1]) << 8;
        out.push_back(a[(n >> 18) & 63]); out.push_back(a[(n >> 12) & 63]);
        out.push_back(i + 1 < in.size() ? a[(n >> 6) & 63] : '=');
        out.push_back('=');
    }
    return out;
}

// The last balanced {...} object in a text reply — the model is told to
// answer with only JSON, but a stray sentence must not break us.
json lastJsonObject(const std::string& text) {
    size_t end = text.rfind('}');
    while (end != std::string::npos) {
        int depth = 0;
        for (size_t i = end + 1; i-- > 0;) {
            if (text[i] == '}') ++depth;
            else if (text[i] == '{' && --depth == 0) {
                json j = json::parse(text.substr(i, end - i + 1), nullptr, false);
                if (!j.is_discarded() && j.is_object()) return j;
                break;
            }
        }
        end = end == 0 ? std::string::npos : text.rfind('}', end - 1);
    }
    return json();
}

std::string str(const json& j, const char* k) {
    return j.contains(k) && j[k].is_string() ? j[k].get<std::string>() : "";
}
double num(const json& j, const char* k) {
    return j.contains(k) && j[k].is_number() ? j[k].get<double>() : 0.0;
}

}  // namespace

ClubLogoFinder& ClubLogoFinder::getInstance() {
    static ClubLogoFinder instance;
    return instance;
}

void ClubLogoFinder::ensureConfigured() {
    std::lock_guard<std::mutex> lk(mutex_);
    if (configured_) return;
    apiKey_ = envOr("ANTHROPIC_API_KEY");
    model_  = envOr("ANTHROPIC_LOGO_MODEL", "claude-opus-5");
    configured_ = true;
}

std::string ClubLogoFinder::model() { ensureConfigured(); return model_; }

std::string ClubLogoFinder::complete(json body) {
    ensureConfigured();
    if (apiKey_.empty()) throw ClubLogoFinderError("Missing ANTHROPIC_API_KEY configuration");
    HttpClient http;
    http.setTotalTimeoutSec(kTimeoutSec);
    HttpClient::Headers headers = {{"x-api-key", apiKey_}, {"anthropic-version", kApiVersion}};
    body["model"] = model_;

    std::string text;
    for (int turn = 0; turn < 5; ++turn) {
        auto resp = http.postJson(kApiUrl, body.dump(), headers);
        if (!resp.error.empty()) throw ClubLogoFinderError("request failed: " + resp.error);
        json parsed = json::parse(resp.body, nullptr, false);
        if (parsed.is_discarded()) throw ClubLogoFinderError("Anthropic returned malformed JSON");
        if (!resp.ok()) {
            throw ClubLogoFinderError(parsed.contains("error") && parsed["error"].is_object()
                ? parsed["error"].value("message", "Anthropic API error")
                : "Anthropic API error (status " + std::to_string(resp.status) + ")");
        }
        const std::string stop = parsed.value("stop_reason", "");
        if (stop == "refusal") throw ClubLogoFinderError("the model declined the request");
        text.clear();
        if (parsed.contains("content") && parsed["content"].is_array()) {
            for (const auto& block : parsed["content"]) {
                if (block.value("type", "") == "text" && block.contains("text") && block["text"].is_string()) {
                    text += block["text"].get<std::string>();
                    text += "\n";
                }
            }
        }
        // Server tools may hand the turn back part-way; continue it.
        if (stop != "pause_turn") break;
        body["messages"].push_back({{"role", "assistant"}, {"content", parsed["content"]}});
    }
    return text;
}

ClubLogoFinder::Candidate ClubLogoFinder::search(const std::string& opponentText, const std::string& context) {
    MessageCopy copy;
    const auto sys  = copy.render("logo_search", "find_system", {});
    const auto user = copy.render("logo_search", "find_user", {{"opponent", opponentText}, {"context", context}});
    if (!sys.ok() || !user.ok()) throw ClubLogoFinderError("logo_search prompts missing (migration 432)");

    json body = {
        {"max_tokens", 4096},
        {"system", sys.body},
        {"tools", json::array({
            {{"type", "web_search_20260209"}, {"name", "web_search"}, {"max_uses", 8}},
            {{"type", "web_fetch_20260209"},  {"name", "web_fetch"},  {"max_uses", 8}},
        })},
        {"messages", json::array({{{"role", "user"}, {"content", user.body}}})},
    };
    const json j = lastJsonObject(complete(body));
    if (j.is_null()) throw ClubLogoFinderError("no JSON answer from the model");
    Candidate c;
    c.clubName   = str(j, "club_name");
    c.imageUrl   = str(j, "image_url");
    c.pageUrl    = str(j, "page_url");
    c.reason     = str(j, "reason");
    c.confidence = num(j, "confidence");
    if (c.imageUrl.rfind("http://", 0) != 0 && c.imageUrl.rfind("https://", 0) != 0) c.imageUrl.clear();
    return c;
}

ClubLogoFinder::Verdict ClubLogoFinder::judge(const std::string& imageBytes, const std::string& mime,
                                              const std::string& clubName) {
    MessageCopy copy;
    const auto q = copy.render("logo_search", "judge", {{"club_name", clubName}});
    if (!q.ok()) throw ClubLogoFinderError("logo_search judge prompt missing (migration 432)");
    json body = {
        {"max_tokens", 1024},
        {"messages", json::array({{
            {"role", "user"},
            {"content", json::array({
                {{"type", "image"}, {"source", {{"type", "base64"}, {"media_type", mime}, {"data", base64Std(imageBytes)}}}},
                {{"type", "text"}, {"text", q.body}},
            })},
        }})},
    };
    const json j = lastJsonObject(complete(body));
    if (j.is_null()) throw ClubLogoFinderError("no JSON verdict from the model");
    Verdict v;
    v.isCrest    = j.contains("is_crest") && j["is_crest"].is_boolean() && j["is_crest"].get<bool>();
    v.confidence = num(j, "confidence");
    v.note       = str(j, "note");
    return v;
}
