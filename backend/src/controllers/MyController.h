#pragma once

#include "../core/Controller.h"

// MyController — signed-in-player self-service surface.
//
// Routes registered under prefix "/api/my":
//   GET  /api/my/week
//        Return the caller's upcoming eligible events (rsvp_opens_at
//        <= NOW, match_date >= today, cancelled_at IS NULL) with the
//        caller's current RSVP per event (or null).
//
//   POST /api/my/rsvp
//        Body: {match_id:int, rsvp_status_id:int, note?:string}
//        Insert a `player_rsvp_history` row for the caller with
//        change_source_id=1 ('app').  Requires the caller to be
//        rostered (mens_team_assignments) to the match's home_team.
//
//   GET  /api/my/recurring
//        Return the caller's `player_recurring_rsvps` rows.
//
//   PUT  /api/my/recurring
//        Body: {prefs:[{day_of_week:int, match_type_id:int, rsvp_status_id:int}, ...]}
//        Replace the caller's entire preference set (delete-then-insert
//        inside a single transaction).
//
// All four endpoints are cookie-session gated (see SessionService::
// requireSession).  No bearer / no CSRF token required — the cookie
// is HttpOnly + SameSite=Lax and the routes are same-origin only.
class MyController : public Controller {
public:
    MyController();
    ~MyController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetWeek(const Request& request);
    Response handlePostRsvp(const Request& request);
    Response handleGetRecurring(const Request& request);
    Response handlePutRecurring(const Request& request);
};
