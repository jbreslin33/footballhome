#pragma once
#include <chrono>
#include <mutex>
#include <unordered_map>
#include <vector>

#include "WelcomeLog.h"

// ────────────────────────────────────────────────────────────────────────────
// DuesPolicy — the club's monthly dues rate and months-behind pause
// threshold, read from `dues_policies` (migration 401) through
// fh_monthly_dues_usd() / fh_dues_pause_after_months().
//
// Owner 2026-09-22: "move the $35 monthly rate into the db too".  Nothing
// in C++ may carry the number any more.  Cached per club for a minute so
// LaProgramSync's per-member loop does not hit the DB per row; a missing
// policy throws rather than falling back to an invented rate.
// ────────────────────────────────────────────────────────────────────────────
class DuesPolicy {
public:
    struct Row {
        double monthlyDuesUsd   = 0.0;
        int    pauseAfterMonths = 0;
        // Partial payments the notices ask for when a member can't pay
        // in full (migration 414), ascending; empty = notices name none.
        std::vector<double> partialAmountsUsd;
    };

    // Policy in force today for the club.  Throws std::runtime_error when
    // the club has none.
    static Row current(int clubId = WelcomeLog::kLighthouseClubId);

    // Drop the cache (tests / after a policy insert in the same process).
    static void invalidate();

private:
    struct Cached {
        Row row;
        std::chrono::steady_clock::time_point fetchedAt;
    };
    static std::mutex                       mutex_;
    static std::unordered_map<int, Cached>  cache_;
};
