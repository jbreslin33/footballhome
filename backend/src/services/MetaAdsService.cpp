#include "MetaAdsService.h"

#include <cstdlib>
#include <iostream>
#include <stdexcept>

#include "../core/HttpClient.h"

using json = nlohmann::json;

namespace {

std::string envOr(const char* name, const std::string& fallback = {}) {
    const char* v = std::getenv(name);
    return (v && *v) ? std::string{v} : fallback;
}

// JSON-encode an array of strings into a single Meta-acceptable param
// (e.g. `["abc","def"]`).  Used for the adimages?hashes=... call.
std::string jsonStringArray(const std::vector<std::string>& items) {
    json arr = json::array();
    for (const auto& s : items) arr.push_back(s);
    return arr.dump();
}

} // namespace

MetaAdsService& MetaAdsService::getInstance() {
    static MetaAdsService instance;
    return instance;
}

void MetaAdsService::ensureConfigured() {
    std::lock_guard<std::mutex> lk(mutex_);
    if (configured_) return;

    // Node: `process.env.META_ADS_TOKEN || process.env.META_LEADS_TOKEN`.
    token_ = envOr("META_ADS_TOKEN", envOr("META_LEADS_TOKEN"));
    // Node: hard-coded fallback if env unset.
    adAccountId_ = envOr("META_AD_ACCOUNT_ID", "act_1792823854148245");

    if (!http_) http_ = std::make_unique<HttpClient>();
    configured_ = true;
}

bool MetaAdsService::hasToken() {
    ensureConfigured();
    std::lock_guard<std::mutex> lk(mutex_);
    return !token_.empty();
}

std::string MetaAdsService::graphUrl(const std::string& path) const {
    return std::string{kApiBase} + "/" + path;
}

// ────────────────────────────────────────────────────────────────────────────
// /api/ads/preview backend
// ────────────────────────────────────────────────────────────────────────────
json MetaAdsService::fetchAdsForPreview() {
    ensureConfigured();
    if (token_.empty()) {
        throw std::runtime_error("Missing META_ADS_TOKEN configuration");
    }

    const std::string fields =
        "name,status,created_time,"
        "creative{name,body,title,image_url,object_story_spec}";

    const std::string url = graphUrl(adAccountId_ + "/ads")
        + "?fields=" + HttpClient::urlEncode(fields)
        + "&limit=50"
        + "&access_token=" + token_;

    auto resp = http_->get(url);
    if (!resp.error.empty()) {
        throw std::runtime_error(resp.error);
    }
    json parsed;
    try { parsed = json::parse(resp.body); }
    catch (const std::exception& e) {
        throw std::runtime_error(std::string{"Meta returned malformed JSON: "} + e.what());
    }
    if (parsed.contains("error") && parsed["error"].is_object()) {
        throw MetaApiError(parsed["error"].value("message", "Meta API error"));
    }
    if (!parsed.contains("data") || !parsed["data"].is_array()) {
        return json::array();
    }
    return parsed["data"];
}

std::vector<std::pair<std::string, std::string>>
MetaAdsService::fetchImageUrlsByHash(const std::vector<std::string>& hashes) {
    std::vector<std::pair<std::string, std::string>> out;
    if (hashes.empty()) return out;

    ensureConfigured();
    if (token_.empty()) return out;

    const std::string url = graphUrl(adAccountId_ + "/adimages")
        + "?hashes=" + HttpClient::urlEncode(jsonStringArray(hashes))
        + "&fields=hash,url"
        + "&access_token=" + token_;

    auto resp = http_->get(url);
    if (!resp.error.empty()) return out;
    json parsed;
    try { parsed = json::parse(resp.body); }
    catch (...) { return out; }
    if (!parsed.contains("data") || !parsed["data"].is_array()) return out;

    for (const auto& img : parsed["data"]) {
        if (img.contains("hash") && img.contains("url") &&
            img["hash"].is_string() && img["url"].is_string()) {
            out.emplace_back(img["hash"].get<std::string>(),
                             img["url"].get<std::string>());
        }
    }
    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// /api/ads/targeting backend
// ────────────────────────────────────────────────────────────────────────────
json MetaAdsService::fetchAdsForTargeting() {
    ensureConfigured();
    if (token_.empty()) {
        throw std::runtime_error("Missing META_ADS_TOKEN");
    }

    const std::string fields =
        "id,name,effective_status,configured_status,"
        "adset{id,name,daily_budget,start_time,effective_status,targeting},"
        "creative{object_story_spec{link_data{link,call_to_action}}},"
        "insights.date_preset(maximum){spend,impressions,clicks,actions}";

    const std::string url = graphUrl(adAccountId_ + "/ads")
        + "?fields=" + HttpClient::urlEncode(fields)
        + "&limit=200"
        + "&access_token=" + token_;

    auto resp = http_->get(url);
    if (!resp.error.empty()) {
        throw std::runtime_error(resp.error);
    }
    json parsed;
    try { parsed = json::parse(resp.body); }
    catch (const std::exception& e) {
        throw std::runtime_error(std::string{"Meta returned malformed JSON: "} + e.what());
    }
    if (parsed.contains("error") && parsed["error"].is_object()) {
        throw MetaApiError(parsed["error"].value("message", "Meta API error"));
    }
    if (!parsed.contains("data") || !parsed["data"].is_array()) {
        return json::array();
    }
    return parsed["data"];
}

json MetaAdsService::fetchRegionInsights(const std::string& adId) {
    ensureConfigured();
    if (token_.empty()) return json::array();

    const std::string url = graphUrl(adId + "/insights")
        + "?breakdowns=region"
        + "&fields=impressions,clicks,actions"
        + "&date_preset=last_30d"
        + "&limit=50"
        + "&access_token=" + token_;

    // Best-effort.  Per-ad transport or graph errors are swallowed so the
    // /api/ads/targeting response still ships with `regions: []` for the
    // failing ad (mirrors Node's try/catch around the Promise.all entry).
    auto resp = http_->get(url);
    if (!resp.error.empty()) return json::array();
    json parsed;
    try { parsed = json::parse(resp.body); }
    catch (...) { return json::array(); }
    if (parsed.contains("error")) return json::array();
    if (!parsed.contains("data") || !parsed["data"].is_array()) return json::array();
    return parsed["data"];
}

// ────────────────────────────────────────────────────────────────────────────
// /api/ads/spend backend
// ────────────────────────────────────────────────────────────────────────────
json MetaAdsService::fetchAdsForSpend() {
    ensureConfigured();
    if (token_.empty()) {
        throw std::runtime_error("Missing META_ADS_TOKEN configuration");
    }

    const std::string fields =
        "id,name,effective_status,configured_status,"
        "adset{id,daily_budget,start_time,end_time,effective_status,configured_status},"
        "creative{object_story_spec{link_data{call_to_action}}},"
        "insights.date_preset(maximum){spend,date_start,date_stop}";

    const std::string url = graphUrl(adAccountId_ + "/ads")
        + "?fields=" + HttpClient::urlEncode(fields)
        + "&limit=200"
        + "&access_token=" + token_;

    auto resp = http_->get(url);
    if (!resp.error.empty()) {
        throw std::runtime_error(resp.error);
    }
    json parsed;
    try { parsed = json::parse(resp.body); }
    catch (const std::exception& e) {
        throw std::runtime_error(std::string{"Meta returned malformed JSON: "} + e.what());
    }
    if (parsed.contains("error") && parsed["error"].is_object()) {
        throw MetaApiError(parsed["error"].value("message", "Meta API error"));
    }
    if (!parsed.contains("data") || !parsed["data"].is_array()) {
        return json::array();
    }
    return parsed["data"];
}

// ────────────────────────────────────────────────────────────────────────────
// /api/ads/:adId/preview backend
// ────────────────────────────────────────────────────────────────────────────
std::string MetaAdsService::fetchPreviewIframeSrc(const std::string& adId,
                                                  const std::string& adFormat) {
    ensureConfigured();
    if (token_.empty()) {
        throw std::runtime_error("Missing META_ADS_TOKEN on server.");
    }

    const std::string url = graphUrl(adId + "/previews")
        + "?ad_format=" + HttpClient::urlEncode(adFormat)
        + "&access_token=" + token_;

    auto resp = http_->get(url);
    if (!resp.error.empty()) {
        throw std::runtime_error(std::string{"Meta API: "} + resp.error);
    }
    json parsed;
    try { parsed = json::parse(resp.body); }
    catch (const std::exception& e) {
        throw std::runtime_error(std::string{"Meta returned malformed JSON: "} + e.what());
    }
    if (parsed.contains("error") && parsed["error"].is_object()) {
        throw MetaApiError(std::string{"Meta API: "}
            + parsed["error"].value("message", "unknown error"));
    }

    if (!parsed.contains("data") || !parsed["data"].is_array()
        || parsed["data"].empty()) {
        throw std::runtime_error(
            "Meta returned no preview body (placement may not apply to this ad).");
    }

    const auto& first = parsed["data"][0];
    if (!first.contains("body") || !first["body"].is_string()) {
        throw std::runtime_error(
            "Meta returned no preview body (placement may not apply to this ad).");
    }

    const std::string body = first["body"].get<std::string>();
    // Node: const m = body.match(/src="([^"]+)"/);
    const auto pos = body.find("src=\"");
    if (pos == std::string::npos) {
        throw std::runtime_error("Could not extract iframe src from Meta response.");
    }
    const auto start = pos + 5;
    const auto end = body.find('"', start);
    if (end == std::string::npos) {
        throw std::runtime_error("Could not extract iframe src from Meta response.");
    }
    std::string src = body.substr(start, end - start);

    // Node: m[1].replace(/&amp;/g, '&')
    std::string decoded;
    decoded.reserve(src.size());
    for (size_t i = 0; i < src.size(); ) {
        if (src.compare(i, 5, "&amp;") == 0) {
            decoded += '&';
            i += 5;
        } else {
            decoded += src[i++];
        }
    }
    return decoded;
}
