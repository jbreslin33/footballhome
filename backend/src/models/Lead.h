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
    int textCount  = 0;
    std::optional<std::string> lastEmailAtIso;
    // Most-recent text/SMS touch from lead_contacts (channel='text').
    // Mirrors lastEmailAtIso for the SMS channel so the leads list
    // can render an "Emailed" / "Texted" / "Emailed + Texted" label.
    std::optional<std::string> lastTextAtIso;
    // Most-recent email's `template` value (touch1 / touch2 / touch3 / ...).
    // NULL when the lead has never been emailed, or when the latest email
    // was logged before migration 072 (legacy pre-multitouch).
    std::optional<std::string> lastEmailTemplate;

    // Manual signed-up flag (migration 073).  All three are NULL for an
    // open lead.  Set together by markConverted() / cleared together by
    // unmarkConverted().  needsFollowup is a server-computed boolean —
    // true iff the lead is still open AND was last emailed >= 3 days ago.
    std::optional<std::string> convertedAtIso;       // YYYY-MM-DDTHH:MM:SS.sssZ
    std::optional<std::string> convertedSource;      // 'manual' | 'leagueapps' | ...
    std::optional<std::string> convertedNote;        // free-text
    bool needsFollowup = false;

    // Closed-lost flag (migration 074).  NULL = still in the active
    // funnel.  Set by markDead() / cleared by unmarkDead().  Wins over
    // converted_at in the computed `status` field — a lead can carry
    // both flags in the row (audit trail) but reports as 'dead' first.
    std::optional<std::string> deadAtIso;            // YYYY-MM-DDTHH:MM:SS.sssZ

    // Manual lifecycle override (migration 075).  When non-NULL,
    // trumps the derived status for display + tab filtering.  Set
    // from the Edit modal in the Leads admin screen.  Pure display
    // override — does NOT mutate converted_at / dead_at, so the
    // LeagueApps sync + audit trail are unaffected.
    std::optional<std::string> statusOverride;       // 'new'|'responded'|'signedup'|'dead'

    // Server-computed lifecycle state, one of:
    //   "new"       — never emailed, not converted, not dead
    //   "responded" — emailed at least once, not converted, not dead
    //   "signedup"  — converted_at IS NOT NULL and not dead
    //   "dead"      — dead_at IS NOT NULL (highest precedence)
    // statusOverride wins over the derived value when set.
    // Empty when this Lead came from a narrower SELECT (e.g. findById).
    std::string status;

    // GET /api/leads — DB-only LEFT JOIN aggregate.  Sorted created_at DESC.
    static std::vector<Lead> listAll();

    // GET /api/leads/:id/vcard — single-row lookup, no aggregate.
    static std::optional<Lead> findById(int leadId);

    // POST /api/leads/:id/mark-converted — set converted_at = NOW() and
    // record source + note.  Returns the refreshed Lead row (so the
    // controller can serialize the same shape /api/leads emits).  Throws
    // on DB error; returns std::nullopt if the lead id doesn't exist.
    static std::optional<Lead> markConverted(int leadId,
                                             const std::string& source,
                                             const std::optional<std::string>& note);

    // DELETE /api/leads/:id/mark-converted — clear all three converted_*
    // columns.  Same return contract as markConverted().
    static std::optional<Lead> unmarkConverted(int leadId);

    // POST /api/leads/:id/mark-dead — set dead_at = NOW().  No body /
    // reason captured in v1.  Returns the refreshed Lead row.
    static std::optional<Lead> markDead(int leadId);

    // DELETE /api/leads/:id/mark-dead — clear dead_at, reviving the
    // lead to its derived (new / responded / signedup) state.
    static std::optional<Lead> unmarkDead(int leadId);

    // POST /api/leads/:id/status-override — set or clear the manual
    // display override (migration 075).  Pass std::nullopt to clear
    // (revert to auto-derived).  Returns the refreshed Lead row.
    // Caller must have already validated the status string against
    // the allowed set ('new'|'responded'|'signedup'|'dead').
    static std::optional<Lead> setStatusOverride(int leadId,
                                                 const std::optional<std::string>& status);

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
