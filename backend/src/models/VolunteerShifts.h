#pragma once
#include <string>

#include <pqxx/pqxx>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// VolunteerShifts — 🙋 a player who is behind on dues coaches the kids instead
// (migrations 1222 → 1461).
//
// Owner 2026-11-18 (mig 1461): volunteers pick youth-practice SLOTS off the
// calendar — weekdays only, at least volunteer_policies.min_weekly_minutes
// (Men: 2 hours) a week, "whole day" = every slot that day.  The owner
// approves; approval makes him an assistant coach for exactly those slots
// (coach_schedule_slots) so they show on his calendar.  His back balance
// stays owed; while approved he stays eligible and is never an alternate
// (SQL, mig 1461).  Each month's dues are waived when every week is met —
// one told-ahead miss a month is OK, a no-show or a second miss bills the
// month (VolunteerLedger below).  Nothing ends a volunteer automatically:
// the owner does.  Every word is message_templates kind volunteer_shift.
// ────────────────────────────────────────────────────────────────────────────

// One volunteer's weeks and months, from the coach's attendance marks on his
// slot practices and his own RSVPs (fh_volunteer_occurrences).
class VolunteerLedger {
public:
    struct Policy {
        int minWeeklyMinutes = 120;
        int missesPerMonth = 1;
        int reviewAfterMonths = 3;
        double monthlyDues = 0.0;
    };

    // Week (Mon–Sun): met · told · noshow · short · unmarked · coming · off.
    // Month: waived · billed · open · pending · none, with flags.
    // Months newest first; at most `months` of them (current included).
    static nlohmann::json months(long long requestId, const Policy& policy, int months);

    static Policy policyFor(long long personId);
};

class VolunteerShifts {
public:
    struct Result {
        bool ok = true;
        int status = 200;        // HTTP status when !ok
        std::string error;
        nlohmann::json body;
    };

    // His card: { offer, policy, slots:[…options], pick:{…, slots, ledger} | null }
    static nlohmann::json mine(long long personId);
    // Pick slots ([{isodow, starts_at:"16:45"}]) — replaces a pending pick.
    static Result pick(long long personId, const nlohmann::json& slots, bool agreed);
    // Cancel a pending pick.
    static Result withdraw(long long personId);

    // #payments: pending picks, oldest first.
    static nlohmann::json pending();
    // #payments: every approved volunteer — this month + last month, flags.
    static nlohmann::json ledger();
    // approve → coach for his slots; deny → nothing else; end → coach slots off.
    static Result decide(long long requestId, const std::string& decision, long long userId);

private:
    static void assignCoachSlots(pqxx::work& tx, long long personId, long long requestId);
    static void removeCoachSlots(pqxx::work& tx, long long personId, long long requestId);
    static nlohmann::json pickSlots(long long requestId);
};
