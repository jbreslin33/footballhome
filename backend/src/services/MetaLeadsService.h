#pragma once
#include <chrono>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

class HttpClient;

// ────────────────────────────────────────────────────────────────────────────
// MetaLeadsService — singleton wrapper around the Meta Graph Lead-Ads API
// (https://graph.facebook.com/v21.0/<formId>/leads).
//
// Why a service: the Node webhook keeps a process-local `lastSyncAtMs` so
// the TTL gate works across requests.  The C++ port needs the same — a
// member on a Controller would be per-instance, but a singleton mirrors
// the Node semantics exactly and survives across all request threads.
//
// State:
//   • `lastSyncAtMs_` — wall-clock ms of the last successful (or
//     attempted) sync.  Initialized to 0 → first call always runs.
//   • `tokenValidated_` — set true if the page-id introspection ping
//     succeeded at startup.  When false, syncForm() short-circuits and
//     records an error per form so the response still reports failure
//     instead of a silent "0 synced" success.
//
// Required environment (read at first use via configure()):
//   META_ADS_TOKEN       — page access token; falls back to META_LEADS_TOKEN
//   META_PAGE_ID         — the page we're listening on
//   META_LEAD_FORM_IDS   — comma-separated form ids; falls back to a hard-
//                          coded set (mirrors Node).
//   META_LEADS_SYNC_TTL_MS — TTL guard for /api/leads/sync (default 30000)
// ────────────────────────────────────────────────────────────────────────────
class MetaLeadsService {
public:
    struct FailedForm {
        std::string formId;
        std::string error;
    };

    struct SyncResult {
        int  syncedRows   = 0;
        bool skippedByTtl = false;
        int  formsSynced  = 0;
        int  formsTotal   = 0;
        std::vector<FailedForm> failedForms;
        long long durationMs = 0;
        long long lastSyncAtMs = 0;   // set even when skipped
    };

    static MetaLeadsService& getInstance();

    // Mint a small graph call (`/<pageId>?fields=id`) using the configured
    // token.  Sets `tokenValidated_` accordingly.  Safe to call multiple
    // times; the result of the most recent call wins.  Logs a warning to
    // stderr on failure (matches Node which logs "Invalid Meta token ...").
    void validateToken();

    // Top-level sync — loops every configured form id, paginates each, and
    // upserts the rows into `leads`.  Honors the TTL gate unless `force`.
    SyncResult syncAll(bool force);

    // Test seam — the controller doesn't need this but exposing it keeps
    // the surface symmetric with the Node code.
    int syncForm(const std::string& formId);

private:
    MetaLeadsService();
    ~MetaLeadsService() = default;
    MetaLeadsService(const MetaLeadsService&) = delete;
    MetaLeadsService& operator=(const MetaLeadsService&) = delete;

    void ensureConfigured();
    static std::vector<std::string> parseFormIds(const std::string& csv,
                                                  const std::vector<std::string>& fallback);

    std::unique_ptr<HttpClient> http_;
    std::mutex   mutex_;

    bool         configured_      = false;
    std::string  token_;
    std::string  pageId_;
    std::vector<std::string> formIds_;
    long long    syncTtlMs_       = 30000;

    bool         tokenValidated_  = false;
    long long    lastSyncAtMs_    = 0;
};
