#pragma once
#include <string>

#include <pqxx/pqxx>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// VolunteerShifts — 🙋 an overdue player helps the club one evening a week
// instead of paying (migration 1222).  Owner 2026-11-10: "lets add for men
// that they can also volunteer if over due … monday wed fri … 5pm to 7pm"
// → "pick one day to help" → on time, every week, tell us ahead → "after
// they show they are reliable we can start process to actually get them
// paid".
//
// The evenings are volunteer_shifts rows per section (Men: Mon/Wed/Fri
// 5–7 PM).  A player picks ONE (volunteer_requests, after ticking the
// commitment); the owner approves, which makes him a 🙋 Volunteer
// (club_volunteers, mig 704: $0 balance, no notices, not an alternate) and
// an assistant coach for his evening — #my 📋 Coach (mig 1224).
// Until then his dues stand.  Every word is message_templates kind
// volunteer_shift.
// ────────────────────────────────────────────────────────────────────────────
class VolunteerShifts {
public:
    struct Result {
        bool ok = true;
        int status = 200;        // HTTP status when !ok
        std::string error;
        nlohmann::json body;
    };

    // #my: { offer, shifts: [{id, label}], pick: {id, shift_id, shift, status} | null }
    static nlohmann::json mine(long long personId);
    // Pick one shift (replaces a pending pick).  agreed = the commitment tick.
    static Result pick(long long personId, long long shiftId, bool agreed);
    // Cancel a pending pick.
    static Result withdraw(long long personId);

    // #payments: pending picks, oldest first.
    static nlohmann::json pending();
    // approve → club_volunteers row; deny → nothing else changes.
    static Result decide(long long requestId, const std::string& decision, long long userId);

private:
    // Approve → assistant coach on the helped section's teams, coach
    // schedule = his day (practices only when new) — #my 📋 Coach (mig 1224).
    static void assignCoachDay(pqxx::work& tx, long long personId, long long shiftId);
};
