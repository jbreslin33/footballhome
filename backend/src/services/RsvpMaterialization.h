#pragma once

#include <string>

// RsvpMaterialization — Sunday-8pm rollover engine.
//
// Two side-effects on the DB:
//   1. **Match materialisation**: for each active `match_series`, insert
//      a real `matches` row for each date in the currently-open week
//      that falls on the series' `day_of_week`, unless a row already
//      exists for that (series, date).
//   2. **Recurring RSVP application**: for each match visible in the
//      currently-open window (cancelled_at IS NULL, rsvp_opens_at is
//      set + in the past), auto-insert `player_rsvp_history` rows for
//      players who have a matching `player_recurring_rsvps` preference
//      and no existing RSVP for that match yet.
//
// "Currently-open window" = the Mon–Sun week whose preceding Sunday
// 20:00 America/New_York is <= NOW().  Sunday 20:00 is the weekly
// rollover moment agreed with the operator on 2026-07-04.
//
// This class is stateless.  Callers hit `rollover()` on a schedule
// (Sunday 8pm cron) or from an admin endpoint.  Both entry points are
// idempotent: running twice inside the same window is a no-op.

class RsvpMaterialization {
public:
    struct Result {
        int matchesInserted   = 0;
        int matchesSkipped    = 0;   // conflict on (series_id, match_date)
        int rsvpsInserted     = 0;
        int rsvpsSkipped      = 0;   // player already had an RSVP
        std::string windowStartIso;  // Sunday 20:00 America/New_York
        std::string windowEndIso;    // next Sunday 20:00 America/New_York
    };

    // Runs both steps against the currently-open window.  Safe to call
    // repeatedly; safe to call from any thread (uses the Database
    // singleton pool + transactions).
    static Result rollover();

    // Materialise matches only (no RSVP application) for a specific
    // upcoming date range.  Used by admin "Generate next N weeks" UX.
    // Inclusive on both ends.
    static Result materialiseRange(const std::string& fromDateIso,
                                    const std::string& toDateIso);
};
