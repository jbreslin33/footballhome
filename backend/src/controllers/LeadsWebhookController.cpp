#include "LeadsWebhookController.h"

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <thread>
#include <utility>

#include "../core/HttpClient.h"
#include "../models/Lead.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

constexpr const char* kApiBase = "https://graph.facebook.com/v21.0";

std::string envOrEmpty(const char* name) {
    const char* v = std::getenv(name);
    return v ? std::string(v) : std::string{};
}

// Resolve the Meta page access token the same way MetaLeadsService does:
// META_ADS_TOKEN preferred, META_LEADS_TOKEN as historical fallback.
std::string resolveMetaToken() {
    std::string t = envOrEmpty("META_ADS_TOKEN");
    if (t.empty()) t = envOrEmpty("META_LEADS_TOKEN");
    return t;
}

// Background worker: for each leadgen change in the payload, fetch the
// full field_data from the Graph API and upsert it into `leads`.  Errors
// are logged and skipped so one bad lead never poisons a whole batch.
void processCallbackAsync(json body) {
    try {
        const std::string token = resolveMetaToken();
        if (token.empty()) {
            std::cerr << "LeadsWebhookController: missing META_ADS_TOKEN "
                         "(or META_LEADS_TOKEN fallback) — callback dropped."
                      << std::endl;
            return;
        }
        if (!body.is_object() || !body.contains("entry")
            || !body["entry"].is_array()) {
            return;
        }

        HttpClient http;
        for (const auto& entry : body["entry"]) {
            if (!entry.is_object() || !entry.contains("changes")
                || !entry["changes"].is_array()) {
                continue;
            }
            for (const auto& change : entry["changes"]) {
                if (!change.is_object()) continue;
                if (change.value("field", std::string{}) != "leadgen") continue;
                if (!change.contains("value") || !change["value"].is_object()) continue;
                const auto& v = change["value"];

                const std::string leadgenId = v.value("leadgen_id", std::string{});
                if (leadgenId.empty()) continue;
                const std::string formId    = v.value("form_id",    std::string{});
                const std::string pageId    = v.value("page_id",    std::string{});
                const std::string adId      = v.value("ad_id",      std::string{});

                std::ostringstream url;
                url << kApiBase << "/" << leadgenId
                    << "?fields=field_data&access_token="
                    << HttpClient::urlEncode(token);
                auto r = http.get(url.str());
                if (!r.ok()) {
                    std::cerr << "LeadsWebhookController: Meta fetch failed for "
                              << leadgenId << " (status=" << r.status
                              << ", error=" << r.error << ')' << std::endl;
                    continue;
                }

                json fieldData = json::array();
                try {
                    auto j = json::parse(r.body);
                    if (j.contains("error")) {
                        std::cerr << "LeadsWebhookController: Meta returned error for "
                                  << leadgenId << ": "
                                  << j["error"].value("message",
                                                      std::string{"(no message)"})
                                  << std::endl;
                        continue;
                    }
                    if (j.contains("field_data") && j["field_data"].is_array()) {
                        fieldData = j["field_data"];
                    }
                } catch (const std::exception& e) {
                    std::cerr << "LeadsWebhookController: JSON parse failed for "
                              << leadgenId << ": " << e.what() << std::endl;
                    continue;
                }

                json metaLead = {
                    {"id",         leadgenId},
                    {"form_id",    formId},
                    {"field_data", fieldData},
                };
                if (!pageId.empty()) metaLead["page_id"] = pageId;
                if (!adId.empty())   metaLead["ad_id"]   = adId;
                // No created_time in the webhook payload; upsertFromMeta
                // falls back to now() when the field is absent or empty.

                try {
                    Lead::upsertFromMeta(metaLead);
                    std::cout << "LeadsWebhookController: lead saved "
                              << leadgenId << std::endl;
                } catch (const std::exception& e) {
                    std::cerr << "LeadsWebhookController: upsert failed for "
                              << leadgenId << ": " << e.what() << std::endl;
                }
            }
        }
    } catch (const std::exception& e) {
        std::cerr << "LeadsWebhookController::processCallbackAsync threw: "
                  << e.what() << std::endl;
    }
}

}  // namespace

void LeadsWebhookController::registerRoutes(Router& router,
                                            const std::string& prefix) {
    router.get(prefix + "/meta-leads", [this](const Request& req) {
        return this->handleVerify(req);
    });
    router.post(prefix + "/meta-leads", [this](const Request& req) {
        return this->handleCallback(req);
    });
}

Response LeadsWebhookController::handleVerify(const Request& request) {
    const std::string verifyToken = envOrEmpty("META_LEADS_VERIFY_TOKEN");
    const std::string mode        = request.getQueryParam("hub.mode");
    const std::string token       = request.getQueryParam("hub.verify_token");
    const std::string challenge   = request.getQueryParam("hub.challenge");

    if (mode == "subscribe" && !verifyToken.empty() && token == verifyToken) {
        std::cout << "LeadsWebhookController: Meta webhook verified" << std::endl;
        Response r(HttpStatus::OK, challenge);
        r.setHeader("Content-Type", "text/plain");
        return r;
    }
    return Response(HttpStatus::FORBIDDEN);
}

Response LeadsWebhookController::handleCallback(const Request& request) {
    // ACK immediately — Meta retries aggressively on non-2xx.  Parse the
    // body inline so an obviously malformed payload doesn't spawn a worker
    // for nothing, but otherwise let the background thread do the slow
    // Graph fetch + DB write.
    json body;
    try {
        body = json::parse(request.getBody());
    } catch (const std::exception&) {
        return Response(HttpStatus::OK);
    }

    if (body.is_object() && body.value("object", std::string{}) == "page") {
        std::thread(processCallbackAsync, std::move(body)).detach();
    }
    return Response(HttpStatus::OK);
}
