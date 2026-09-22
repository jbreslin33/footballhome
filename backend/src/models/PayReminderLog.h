#pragma once
#include <string>
#include <unordered_map>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PayReminderLog — write + read for `pay_reminder_log` table (migration 094).
//
// The Mens & Boys roster screens each render a `💬 PAY` (SMS) and `✉ PAY`
// (email) button on any card whose player is overdue.  Clicking either
// button opens the native SMS composer / Gmail compose window.  The
// frontend also fires a fire-and-forget POST to /api/pay-reminder-log so
// we have a record of what we've reached out about.
//
// This model provides:
//   • record()  — insert one row per click
//   • latestFor(vec<uid>) — bulk fetch of newest row per la_user_id,
//                            keyed by stringified uid (matches how
//                            MensRoster / BoysRoster key everything else)
//
// User directive 2026-07-06:
//   "we need to show if we emailed or texted from this screen. maybe a
//    quick list of last contact and method. for the two pay buttons"
// ────────────────────────────────────────────────────────────────────────────
class PayReminderLog {
public:
    struct Latest {
        std::string method;    // "sms" | "email"
        std::string sentAtIso; // "YYYY-MM-DDTHH:MM:SS.mmmZ" (UTC)
        // Per-channel tally (owner 2026-09-22: "tally them separately …
        // so I can see oh I sent 2 emails and no response yet, let me
        // try a text").  Counts are all-time; *AtIso is that channel's
        // newest send, empty when none.
        int         smsCount   = 0;
        int         emailCount = 0;
        std::string smsAtIso;
        std::string emailAtIso;
    };

    using Map = std::unordered_map<std::string, Latest>;

    PayReminderLog();

    // Insert one row.  amount/daysOverdue < 0 → NULL.  Empty string
    // fields → NULL.  senderUserId <= 0 → NULL.
    void record(long long          laUserId,
                const std::string& method,      // sms | email
                long long          senderUserId,
                const std::string& club,        // "mens" | "boys" | ""
                const std::string& tier,        // free-form; may be empty
                double             amount,      // NaN or negative → NULL
                int                daysOverdue);// negative → NULL

    // Bulk per-user: newest send overall plus the per-channel counts and
    // newest send per channel.  Keyed by stringified la_user_id; users
    // with no rows are simply not present.
    Map latestFor(const std::vector<long long>& laUserIds);

private:
    Database* db_;
};
