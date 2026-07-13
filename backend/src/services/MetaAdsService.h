#pragma once
#include <memory>
#include <mutex>
#include <stdexcept>
#include <string>
#include <vector>

#include "../third_party/json.hpp"

class HttpClient;

// Thrown when the Meta Graph API returns {error:{message:...}}.  Lets the
// controller distinguish "upstream rejected us" (HTTP 502) from "our own
// transport or JSON parse broke" (HTTP 500).  Mirrors Node's distinction
// between the inline `if (j.error) return 502` and the outer `catch → 500`.
class MetaApiError : public std::runtime_error {
public:
    explicit MetaApiError(const std::string& m) : std::runtime_error(m) {}
};

// ────────────────────────────────────────────────────────────────────────────
// MetaAdsService — singleton wrapper around the Meta Graph Marketing API
// (https://graph.facebook.com/v21.0/<ad_account_id>/ads).
//
// Why a service: keeps the OOP layering consistent with MetaLeadsService
// (one network/state-owning class per upstream surface) and gives all
// /api/ads/* handlers a single configured HttpClient + token + ad-account.
//
// Required environment (read at first use via ensureConfigured()):
//   META_ADS_TOKEN        — page/system-user access token (falls back to
//                           META_LEADS_TOKEN to match the Node code path).
//   META_AD_ACCOUNT_ID    — account id including the "act_" prefix.
//                           Defaults to act_1792823854148245 (Node's same
//                           hard-coded fallback) when unset.
//
// Thread-safety: HttpClient::perform creates a private curl_easy handle
// per call, so multiple service methods (or std::async fan-outs) can
// share one MetaAdsService instance without contention.  The internal
// HttpClient pointer itself is allocated once under mutex_ at first use.
// ────────────────────────────────────────────────────────────────────────────
class MetaAdsService {
public:
    static MetaAdsService& getInstance();

    // GET /v21.0/<account>/ads — full ad-creative payload for the preview
    // page.  Returns the parsed json array (Meta's `data` field).  Throws
    // std::runtime_error with the Meta API error message on graph-level
    // failure, or std::runtime_error("Missing META_ADS_TOKEN") if env is
    // unset.
    nlohmann::json fetchAdsForPreview();

    // Bulk lookup of full-res image URLs by hash.  Returns map keyed by
    // hash.  Best-effort: returns {} on transport failure to mirror Node
    // which silently leaves the hashToUrl map empty.
    std::vector<std::pair<std::string, std::string>>
    fetchImageUrlsByHash(const std::vector<std::string>& hashes);

    // GET /v21.0/<account>/ads — targeting-rundown payload (includes
    // adset+creative+insights subfields).  Throws on graph error.
    nlohmann::json fetchAdsForTargeting();

    // GET /v21.0/<adId>/insights?breakdowns=region — best-effort, swallows
    // errors per Node's try/catch.  Returns an empty array on failure.
    nlohmann::json fetchRegionInsights(const std::string& adId);

    // GET /v21.0/<account>/ads — minimal spend payload (insights{spend}).
    nlohmann::json fetchAdsForSpend();

    // GET /v21.0/<account>/ads — richer per-ad spend + performance payload
    // for a caller-supplied `date_preset` (today, last_7d, last_30d,
    // last_90d, this_month, last_month, maximum, …).  Fields include
    // ad name/status, adset daily budget, and full insights (spend,
    // impressions, clicks, actions) for the requested window so the
    // Leads Analytics screen can render totals + CPL per time-frame
    // without a second round-trip.  Throws on graph error.
    nlohmann::json fetchAdsSpendBreakdown(const std::string& datePreset);

    // GET /v21.0/<adId>/previews?ad_format=... — returns the iframe `src`
    // url extracted from the first preview body.  Throws std::runtime_error
    // with a user-facing message on any failure (missing token, Meta
    // error, no preview body, no iframe src).
    std::string fetchPreviewIframeSrc(const std::string& adId,
                                      const std::string& adFormat);

    // Helper: empty-on-unset means the service is unusable.
    bool hasToken();

private:
    MetaAdsService() = default;
    ~MetaAdsService() = default;
    MetaAdsService(const MetaAdsService&) = delete;
    MetaAdsService& operator=(const MetaAdsService&) = delete;

    void ensureConfigured();
    std::string graphUrl(const std::string& path) const;

    std::mutex mutex_;
    std::unique_ptr<HttpClient> http_;
    std::string token_;
    std::string adAccountId_;
    bool configured_ = false;

    static constexpr const char* kApiBase = "https://graph.facebook.com/v21.0";
};
