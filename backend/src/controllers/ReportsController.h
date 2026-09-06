#pragma once

#include "../core/Controller.h"
#include "../database/Database.h"
#include "../third_party/json.hpp"

#include <string>
#include <vector>

// ReportsController — read-only attendance / RSVP reporting over the
// fh_events mirror (docs/calendar-design.md).  First report screen in
// the app (frontend/js/screens/reports.js, #reports); Payments keeps
// its own screen (#payments) and the Reports screen links to it.
//
// Routes registered under prefix "/api/reports":
//
//   GET /api/reports/attendance?from=YYYY-MM-DD&to=YYYY-MM-DD[&teamId=N]
//        One row per (player, team) for every player currently on the
//        roster of a team in the caller's scope.  Each row carries a
//        stats block per event bucket — game (match + intrasquad),
//        practice, pickup, and all — plus an activity block (last RSVP,
//        last attended, last login, silent streak) so the operator can
//        sort out who has effectively quit.
//
//   GET /api/reports/attendance/events?personId=N&teamId=N&from=&to=
//        The per-event detail behind one row: every expected event in
//        the window with the player's RSVP and attendance mark.
//
// Who was EXPECTED at an event (the denominator of every percentage):
//   every player on the current active roster (team_persons.removed_at
//   IS NULL) of a team tagged on the event (fh_event_teams), minus
//   anyone whose roster status hides them from RSVP (roster_statuses.
//   show_in_rsvp = false) and anyone under an rsvp_suspensions row
//   active at the event's start.  This is the same set the event's own
//   RSVP list shows (CalendarController::handleGetUpcoming rsvps_json).
//   team_persons.joined_at is NOT consulted: it is reset whenever a
//   player is re-assigned, so 457 real RSVPs on prod pre-date the
//   player's recorded join (probe 2026-09-06).  Coaches and club-pass
//   call-ups are not "expected" and are left out.
//
// Attendance is only counted on events where attendance was TAKEN
// (at least one fh_event_attendance row on the event).  On those
// events a player with no mark counts as not there — coaches mark who
// showed up, not who didn't.
//
// Scope: a club admin (any admins row) sees every team that has an
// active roster; otherwise the caller must be an active coach
// (team_coaches.ended_at IS NULL) and sees only those teams; anyone
// else gets 403.  Session-gated like /api/calendar/* — fh_sess cookie
// or Bearer JWT — because magic-link users have no JWT.
class ReportsController : public Controller {
public:
    ReportsController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    struct Scope {
        long long              personId = 0;
        bool                   isAdmin  = false;
        std::vector<long long> teamIds;      // teams the caller may report on
    };
    struct Window {
        std::string from;   // YYYY-MM-DD inclusive
        std::string to;     // YYYY-MM-DD inclusive (query adds a day)
    };

    Response handleGetAttendance(const Request& request);
    Response handleGetAttendanceEvents(const Request& request);

    // Resolves the caller and the teams they may see.  Fills `error`
    // with a 401/403 Response when the caller may not use the report.
    bool resolveScope(const Request& request, Scope* scope, Response* error);
    // Parses ?from/?to (defaults: 90 days ago .. today).  Sets `error`
    // to a 400 when either is malformed.
    bool parseWindow(const Request& request, Window* window, Response* error);
    // "{1,2,3}" — Postgres int[] literal for `= ANY($n::int[])`.
    static std::string pgIntArray(const std::vector<long long>& ids);

    Database* db_;
};
