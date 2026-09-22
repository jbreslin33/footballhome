#include "GroupMeService.h"
#include "../core/HttpClient.h"
#include "../third_party/json.hpp"
#include <cstdlib>
#include <random>
#include <sstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>

using nlohmann::json;

namespace {
constexpr const char* kApiBase = "https://api.groupme.com/v3";
} // namespace

GroupMeService& GroupMeService::getInstance() {
    static GroupMeService instance;
    return instance;
}

GroupMeService::GroupMeService()
    : http_(std::make_unique<HttpClient>()) {}

GroupMeService::~GroupMeService() = default;

void GroupMeService::ensureConfigured() {
    if (configured_) return;
    const char* env = std::getenv("GROUPME_ACCESS_TOKEN");
    accessToken_ = env ? env : "";
    configured_ = true;
    if (accessToken_.empty()) {
        std::cerr << "[GroupMeService] WARNING: GROUPME_ACCESS_TOKEN not set"
                  << std::endl;
    }
}

std::vector<GroupMeService::Message>
GroupMeService::recentMessages(const std::string& externalGroupId, int limit) {
    std::lock_guard<std::mutex> lock(mutex_);
    ensureConfigured();
    if (accessToken_.empty()) {
        throw std::runtime_error("GROUPME_ACCESS_TOKEN not configured");
    }
    if (externalGroupId.empty()) {
        throw std::runtime_error("GroupMeService::recentMessages: empty group id");
    }

    const auto now = std::chrono::steady_clock::now();
    auto it = cache_.find(externalGroupId);
    if (it != cache_.end()
        && now - it->second.fetchedAt < std::chrono::seconds(kCacheSeconds)) {
        return it->second.messages;
    }

    try {
        auto fresh = fetchMessages(externalGroupId, limit);
        cache_[externalGroupId] = {now, fresh};
        return fresh;
    } catch (const std::exception& e) {
        // Never log the URL — it carries the token.
        std::cerr << "[GroupMeService] " << e.what() << std::endl;
        if (it != cache_.end()) {
            it->second.fetchedAt = now;   // back off for a cache window
            return it->second.messages;
        }
        throw;
    }
}

std::string GroupMeService::postMessage(const std::string& externalGroupId, const std::string& text) {
    std::lock_guard<std::mutex> lock(mutex_);
    ensureConfigured();
    if (accessToken_.empty()) throw std::runtime_error("GROUPME_ACCESS_TOKEN not configured");
    if (externalGroupId.empty()) throw std::runtime_error("GroupMeService::postMessage: empty group id");
    if (text.empty()) throw std::runtime_error("GroupMeService::postMessage: empty text");

    // source_guid: GroupMe de-duplicates on it, so it must be fresh per post.
    std::random_device rd;
    std::ostringstream guid;
    guid << std::hex << std::setfill('0');
    for (int i = 0; i < 4; ++i) guid << std::setw(8) << rd();

    const json body = {{"message", {{"source_guid", "fh-" + guid.str()}, {"text", text}}}};
    const std::string url = std::string(kApiBase) + "/groups/"
                          + HttpClient::urlEncode(externalGroupId)
                          + "/messages?token=" + HttpClient::urlEncode(accessToken_);
    const HttpClient::Response r = http_->postJson(url, body.dump());
    if (!r.ok()) {
        // Never log the URL — it carries the token.
        throw std::runtime_error("GroupMe post failed (status=" + std::to_string(r.status)
                                 + (r.error.empty() ? "" : ", " + r.error) + ")");
    }
    std::string id;
    try {
        const json j = json::parse(r.body);
        if (j.contains("response") && j["response"].contains("message")
            && j["response"]["message"].contains("id") && j["response"]["message"]["id"].is_string()) {
            id = j["response"]["message"]["id"].get<std::string>();
        }
    } catch (...) { /* id stays empty — the post went through */ }
    cache_.erase(externalGroupId);
    return id;
}

std::vector<GroupMeService::Message>
GroupMeService::fetchMessages(const std::string& externalGroupId, int limit) {
    if (limit < 1)   limit = 1;
    if (limit > 100) limit = 100;
    const std::string url = std::string(kApiBase) + "/groups/"
                          + HttpClient::urlEncode(externalGroupId)
                          + "/messages?limit=" + std::to_string(limit)
                          + "&token=" + HttpClient::urlEncode(accessToken_);

    const HttpClient::Response r = http_->get(url);
    // 304 = group has no messages yet.
    if (r.error.empty() && r.status == 304) return {};
    if (!r.ok()) {
        throw std::runtime_error("GroupMe messages fetch failed (status="
                                 + std::to_string(r.status)
                                 + (r.error.empty() ? "" : ", " + r.error) + ")");
    }

    json j;
    try {
        j = json::parse(r.body);
    } catch (const std::exception& e) {
        throw std::runtime_error(std::string("GroupMe JSON parse failed: ") + e.what());
    }
    if (!j.contains("response") || !j["response"].is_object()
        || !j["response"].contains("messages") || !j["response"]["messages"].is_array()) {
        throw std::runtime_error("GroupMe response missing `response.messages`");
    }

    std::vector<Message> out;
    for (const auto& m : j["response"]["messages"]) {
        Message msg;
        if (m.contains("id")   && m["id"].is_string())   msg.id   = m["id"].get<std::string>();
        if (m.contains("name") && m["name"].is_string()) msg.name = m["name"].get<std::string>();
        if (m.contains("text") && m["text"].is_string()) msg.text = m["text"].get<std::string>();
        if (m.contains("created_at") && m["created_at"].is_number())
            msg.createdAt = m["created_at"].get<long long>();
        if (m.contains("system") && m["system"].is_boolean())
            msg.isSystem = m["system"].get<bool>();
        if (m.contains("attachments") && m["attachments"].is_array()) {
            for (const auto& a : m["attachments"]) {
                if (a.contains("type") && a["type"] == "image"
                    && a.contains("url") && a["url"].is_string()) {
                    msg.imageUrl = a["url"].get<std::string>();
                    break;
                }
            }
        }
        if (!msg.id.empty()) out.push_back(std::move(msg));
    }
    return out;
}
