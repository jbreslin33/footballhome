#pragma once
#include <optional>
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// Lead — model for the `leads` table (rows ingested from Meta lead-form
// webhooks + REST sync).  Mirrors the columns selected by GET /api/leads
// in the Node webhook one-to-one so the controller can build a
// byte-identical JSON response.
//
// `rawFields` holds whatever Meta sent under `field_data` (an array of
// {name, values}) as the parsed JSON.  Postgres stores it as jsonb.
//
// Date strings are emitted as the same ISO-with-milliseconds-and-trailing-Z
// shape Node's pg driver produces when JSON.stringify-ing a Date object
// (`YYYY-MM-DDTHH:MM:SS.sssZ`).  We cast in SQL so the format is server-
// side and matches the Node output without round-tripping through C++
// time-zone math.
// ────────────────────────────────────────────────────────────────────────────
class Lead {
public:
    int id = 0;
    std::string leadgenId;
    std::string formId;
    std::optional<std::string> pageId;
    std::optional<std::string> adId;
    std::optional<std::string> name;
    std::optional<std::string> email;
    std::optional<std::string> phone;
    nlohmann::json rawFields;                  // array of {name, values}
    std::optional<std::string> preferredChannel;
    std::string createdAtIso;                  // YYYY-MM-DDTHH:MM:SS.sssZ
    int emailCount = 0;
    std::optional<std::string> lastEmailAtIso;

    // GET /api/leads — DB-only LEFT JOIN aggregate.  Sorted created_at DESC.
    static std::vector<Lead> listAll();

    // GET /api/leads/:id/vcard — single-row lookup, no aggregate.
    static std::optional<Lead> findById(int leadId);

    // Upsert one Meta lead-form record into `leads`.  Returns false iff the
    // lead was in the blocklist and skipped.  Throws on DB error.
    static bool upsertFromMeta(const nlohmann::json& metaLead);

    // Stable canonical for the preferred_channel radio.
    //   text/sms/phone text → "text"
    //   email               → "email"
    //   whatsapp/whats app/wa → "whatsapp"
    //   anything else       → std::nullopt
    static std::optional<std::string>
    normalizePreferredChannel(const std::string& raw);

private:
    // Hard-coded set of leadgen_ids we never want to re-ingest (California
    // strays from a misconfigured ad).  Same list as the Node webhook.
    static const std::vector<std::string>& excludedLeadgenIds();
};
