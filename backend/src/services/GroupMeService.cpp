#include "GroupMeService.h"
#include "../core/HttpClient.h"
#include "../third_party/json.hpp"
#include <cstdlib>
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

GroupMeService::Group GroupMeService::fetchGroup(const std::string& externalGroupId) {
    ensureConfigured();
    if (accessToken_.empty()) {
        throw std::runtime_error("GROUPME_ACCESS_TOKEN not configured");
    }
    if (externalGroupId.empty()) {
        throw std::runtime_error("GroupMeService::fetchGroup: empty group id");
    }

    const std::string url = std::string(kApiBase) + "/groups/"
                          + HttpClient::urlEncode(externalGroupId)
                          + "?token=" + HttpClient::urlEncode(accessToken_);

    const HttpClient::Response r = http_->get(url);
    if (!r.ok()) {
        throw std::runtime_error("GroupMe group fetch failed (status="
                                 + std::to_string(r.status)
                                 + (r.error.empty() ? "" : ", " + r.error)
                                 + "): " + r.body.substr(0, 200));
    }

    json j;
    try {
        j = json::parse(r.body);
    } catch (const std::exception& e) {
        throw std::runtime_error(std::string("GroupMe JSON parse failed: ") + e.what());
    }
    if (!j.contains("response") || !j["response"].is_object()) {
        throw std::runtime_error("GroupMe response missing `response` body");
    }
    const json& grp = j["response"];

    Group out;
    if (grp.contains("name") && grp["name"].is_string()) {
        out.name = grp["name"].get<std::string>();
    }
    if (grp.contains("members") && grp["members"].is_array()) {
        for (const auto& m : grp["members"]) {
            Member mem;
            // user_id can come back as a JSON string or number — normalise to string.
            if (m.contains("user_id")) {
                const auto& uid = m["user_id"];
                if      (uid.is_string()) mem.userId = uid.get<std::string>();
                else if (uid.is_number()) mem.userId = std::to_string(uid.get<long long>());
            }
            if (m.contains("nickname")  && m["nickname"].is_string())  mem.nickname  = m["nickname"].get<std::string>();
            if (m.contains("image_url") && m["image_url"].is_string()) mem.imageUrl  = m["image_url"].get<std::string>();
            if (!mem.userId.empty()) out.members.push_back(std::move(mem));
        }
    }
    return out;
}
