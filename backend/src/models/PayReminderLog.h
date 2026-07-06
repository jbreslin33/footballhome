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

    // Bulk newest-per-user.  Returns map keyed by stringified la_user_id;
    // missing users are simply not present.
    Map latestFor(const std::vector<long long>& laUserIds);

private:
    Database* db_;
};
