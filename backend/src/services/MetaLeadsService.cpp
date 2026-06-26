#include "MetaLeadsService.h"

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <stdexcept>

#include "../core/HttpClient.h"
#include "../models/Lead.h"
#include "../third_party/json.hpp"

namespace {

using nlohmann::json;

constexpr const char* kApiBase = "https://graph.facebook.com/v21.0";

const std::vector<std::string>& kDefaultFormIds() {
    static const std::vector<std::string> ids = {
        "1696381158350766",
        "1052472267432735",
        "1333581472007910",
        "2062202517690808",
        "875990184755538",
        "1552835789741946",
        "1668570657681917",
        "1773598717166962",
        "3249608418562710", // Youth (Grades 1–6)
        "1704106777282059", // Boys Club (Grades 1–6)
        "1571742281184926", // Girls Club (Grades 1–6)
    };
    return ids;
}

std::string envOrEmpty(const char* name) {
    const char* v = std::getenv(name);
    return v ? std::string(v) : std::string{};
}

long long envLongOr(const char* name, long long fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoll(v); }
    catch (const std::exception&) { return fallback; }
}

long long nowMs() {
    using namespace std::chrono;
    return duration_cast<milliseconds>(system_clock::now().time_since_epoch()).count();
}

} // namespace

MetaLeadsService& MetaLeadsService::getInstance() {
    static MetaLeadsService inst;
    return inst;
}

MetaLeadsService::MetaLeadsService()
    : http_(std::make_unique<HttpClient>()) {}

std::vector<std::string>
MetaLeadsService::parseFormIds(const std::string& csv,
                                const std::vector<std::string>& fallback) {
    if (csv.empty()) return fallback;
    std::vector<std::string> out;
    std::string cur;
    for (char c : csv) {
        if (c == ',') {
            // trim
            size_t a = 0, b = cur.size();
            while (a < b && std::isspace(static_cast<unsigned char>(cur[a]))) ++a;
            while (b > a && std::isspace(static_cast<unsigned char>(cur[b - 1]))) --b;
            if (b > a) out.emplace_back(cur.substr(a, b - a));
            cur.clear();
        } else {
            cur.push_back(c);
        }
    }
    {
        size_t a = 0, b = cur.size();
        while (a < b && std::isspace(static_cast<unsigned char>(cur[a]))) ++a;
        while (b > a && std::isspace(static_cast<unsigned char>(cur[b - 1]))) --b;
        if (b > a) out.emplace_back(cur.substr(a, b - a));
    }
    return out.empty() ? fallback : out;
}

void MetaLeadsService::ensureConfigured() {
    if (configured_) return;
    token_   = envOrEmpty("META_ADS_TOKEN");
    if (token_.empty()) token_ = envOrEmpty("META_LEADS_TOKEN");
    pageId_  = envOrEmpty("META_PAGE_ID");
    formIds_ = parseFormIds(envOrEmpty("META_LEAD_FORM_IDS"), kDefaultFormIds());
    syncTtlMs_ = envLongOr("META_LEADS_SYNC_TTL_MS", 30000);
    configured_ = true;
}

void MetaLeadsService::validateToken() {
    std::lock_guard<std::mutex> lk(mutex_);
    ensureConfigured();
    if (token_.empty() || pageId_.empty()) {
        std::cerr << "MetaLeadsService: missing META_ADS_TOKEN or META_PAGE_ID — "
                     "running in degraded mode (DB-only leads)." << std::endl;
        tokenValidated_ = false;
        return;
    }
    std::ostringstream url;
    url << kApiBase << "/" << pageId_ << "?fields=id&access_token="
        << HttpClient::urlEncode(token_);
    auto r = http_->get(url.str());
    if (!r.ok()) {
        std::cerr << "MetaLeadsService: token validation failed (status="
                  << r.status << ", error=" << r.error
                  << ") — running in degraded mode (DB-only leads)." << std::endl;
        tokenValidated_ = false;
        return;
    }
    // Even on 200, Meta returns { "error": {...} } when the token is bad.
    try {
        auto j = json::parse(r.body);
        if (j.contains("error")) {
            std::cerr << "MetaLeadsService: Meta returned error during validation: "
                      << j["error"].value("message", std::string{"(no message)"})
                      << " — running in degraded mode." << std::endl;
            tokenValidated_ = false;
            return;
        }
        tokenValidated_ = true;
        std::cout << "MetaLeadsService: token validated for page "
                  << j.value("id", std::string{"?"}) << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "MetaLeadsService: validation parse failed: "
                  << e.what() << " — running in degraded mode." << std::endl;
        tokenValidated_ = false;
    }
}

int MetaLeadsService::syncForm(const std::string& formId) {
    // The caller holds the lock during a batch sync.  Don't re-lock here.
    if (!tokenValidated_) {
        throw std::runtime_error(
            "META_LEADS_TOKEN not validated; sync disabled until token is fixed");
    }

    int inserted = 0;
    std::ostringstream first;
    first << kApiBase << "/" << formId
          << "/leads?access_token=" << HttpClient::urlEncode(token_)
          << "&limit=100"
          << "&fields=id,created_time,field_data,ad_id,form_id,page_id";

    std::string url = first.str();
    while (!url.empty()) {
        auto r = http_->get(url);
        if (!r.ok() && r.status != 0) {
            // Try to surface the Meta error message before throwing.
            try {
                auto j = json::parse(r.body);
                if (j.contains("error")) {
                    throw std::runtime_error(
                        "Form " + formId + ": "
                        + j["error"].value("message", std::string{"(no message)"}));
                }
            } catch (const std::exception&) { /* fall through */ }
            throw std::runtime_error("Form " + formId + ": HTTP "
                                     + std::to_string(r.status));
        }
        if (!r.error.empty()) {
            throw std::runtime_error("Form " + formId + ": transport error: " + r.error);
        }

        json data;
        try { data = json::parse(r.body); }
        catch (const std::exception& e) {
            throw std::runtime_error(std::string("Form ") + formId
                                     + ": JSON parse: " + e.what());
        }
        if (data.contains("error")) {
            throw std::runtime_error("Form " + formId + ": "
                + data["error"].value("message", std::string{"(no message)"}));
        }
        if (data.contains("data") && data["data"].is_array()) {
            for (const auto& lead : data["data"]) {
                // Node increments insertedOrUpdated for every record
                // returned by Meta, regardless of whether upsertLead
                // actually wrote a row (blocklisted ids are silently
                // skipped but still counted).  Mirror that exactly so
                // the report number byte-matches.
                Lead::upsertFromMeta(lead);
                ++inserted;
            }
        }

        url.clear();
        if (data.contains("paging") && data["paging"].is_object()
            && data["paging"].contains("next")
            && data["paging"]["next"].is_string()) {
            url = data["paging"]["next"].get<std::string>();
        }
    }
    return inserted;
}

MetaLeadsService::SyncResult MetaLeadsService::syncAll(bool force) {
    std::lock_guard<std::mutex> lk(mutex_);
    ensureConfigured();

    const long long start = nowMs();
    SyncResult out;
    out.formsTotal = static_cast<int>(formIds_.size());

    if (!force && (start - lastSyncAtMs_) < syncTtlMs_) {
        out.skippedByTtl  = true;
        out.lastSyncAtMs  = lastSyncAtMs_ ? lastSyncAtMs_ : start;
        return out;
    }

    for (const auto& formId : formIds_) {
        try {
            out.syncedRows += syncForm(formId);
        } catch (const std::exception& e) {
            out.failedForms.push_back({ formId, e.what() });
            std::cerr << "Meta leads sync error for form " << formId
                      << ": " << e.what() << std::endl;
        }
    }

    lastSyncAtMs_     = start;
    out.lastSyncAtMs  = lastSyncAtMs_;
    out.formsSynced   = out.formsTotal - static_cast<int>(out.failedForms.size());
    out.durationMs    = nowMs() - start;
    return out;
}
