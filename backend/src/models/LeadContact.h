#pragma once
#include <map>
#include <optional>
#include <string>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// LeadContact — model for the `lead_contacts` table (one row per outbound
// touch the operator logged from the Leads page: text/email/whatsapp/call).
//
// The Leads page wants two things from this table:
//   1) Per-lead "last contacted" badge counts (text + email).
//   2) Aggregate windowed counts for the rate-limit warnings on the SMS
//      composer (texts in the last 5min / hour / day / week, etc.).
//
// `LeadContact::insert` is the write side used by POST /api/leads/:id/contact;
// `LeadContact::fetchStats` returns everything GET /api/leads/contact-stats
// needs in two round-trips.
// ────────────────────────────────────────────────────────────────────────────
class LeadContact {
public:
    // The single inserted row, returned to the caller verbatim.
    struct Row {
        int id = 0;
        int leadId = 0;
        std::string channel;
        std::string sentAtIso;       // YYYY-MM-DDTHH:MM:SS.sssZ
        std::optional<std::string> status;
    };

    // Per-lead aggregate (text + email counts + last-touched timestamps).
    struct PerLead {
        int textCount = 0;
        int emailCount = 0;
        std::optional<std::string> lastTextAtIso;
        std::optional<std::string> lastEmailAtIso;
    };

    // Rolling-window aggregates over the entire lead_contacts table.
    struct Aggregates {
        int texts5min   = 0;
        int textsHour   = 0;
        int textsDay    = 0;
        int textsWeek   = 0;
        int emailsDay   = 0;
        int emailsWeek  = 0;
    };

    struct Stats {
        std::map<int, PerLead> perLead;   // keyed by lead_id
        Aggregates             aggregates;
    };

    // INSERT a contact row.  `contactedBy` is allowed to be null when the
    // caller couldn't decode the JWT bearer (matches Node behavior).
    // `templateId` is the multi-touch sequence identifier (touch1 / touch2
    // / touch3 / ...) added in migration 072 — pass std::nullopt to leave
    // it NULL (legacy / untemplated send).
    static Row insert(int leadId,
                      const std::string& channel,
                      std::optional<int>          contactedBy,
                      std::optional<std::string>  messageBody,
                      std::optional<std::string>  status,
                      std::optional<std::string>  templateId = std::nullopt);

    // One row in the Edit-modal "Recent touches" list.
    struct LogRow {
        int                        id        = 0;
        int                        leadId    = 0;
        std::string                channel;
        std::string                sentAtIso;
        std::optional<std::string> status;
        std::optional<std::string> templateId;
    };

    // Last N contact rows for a lead, newest first.  Used to render the
    // "Recent touches" list in the Edit modal so coaches can audit /
    // delete accidental sends.
    static std::vector<LogRow> listForLead(int leadId, int limit = 20);

    // Delete a single contact row + any sibling rows that were inserted
    // by the same fan-out batch (same channel, same lead-set by
    // email/phone match, sent_at within ±5s).  Returns the list of
    // lead_ids whose aggregates need re-rendering.  Empty vector means
    // nothing matched (already deleted, or wrong lead).
    static std::vector<int> removeWithFanout(int contactId, int leadId);

    static Stats fetchStats();
};
