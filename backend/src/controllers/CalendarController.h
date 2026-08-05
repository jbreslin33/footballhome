#pragma once

#include "../core/Controller.h"

// CalendarController — read-only view over the fh_events + gcal_events
// mirror populated by scripts/gcal-sync.js (Slice 2) and classified by
// scripts/gcal-classify.js (Slice 3). See docs/calendar-design.md
// §1.1 for the hard rule (FH never authors events), §10 for the
// frontend layering this endpoint feeds.
//
// Routes registered under prefix "/api":
//
//   GET /api/calendar/upcoming?days=<int>
//        Return classified upcoming events for the next N days
//        (default 14, min 1, max 90) as a JSON array sorted by
//        starts_at ascending. Only rows that are:
//          * present in gcal_events with deleted_at IS NULL
//          * status <> 'cancelled'
//          * classified into fh_events by the pattern table
//        appear. Non-classified soccer rows (§6.4) and non-soccer
//        rows (§6.0) are omitted — they exist in gcal_events only
//        for the admin "Needs classification" queue (Slice 8).
//
//        The read is public — no auth required — so it exposes only
//        scheduling metadata (title, time, location, kind).  If the
//        caller happens to be signed in (via the fh_sess cookie or a
//        Bearer JWT) each event additionally carries `my_rsvp`
//        ('yes' | 'no' | 'maybe' | null) — the caller's current
//        response for that fh_event.  Anonymous callers always see
//        `my_rsvp: null`.
//
//   POST /api/calendar/rsvp    (Slice 6)
//        Body: { fh_event_id:int, response:'yes'|'no'|'maybe',
//                note?:string }
//        Session-gated (fh_sess cookie OR Bearer JWT, same pattern
//        as MyController).  Upserts one fh_event_rsvps row for the
//        caller with created_via='manual'.  Rejects with 409 when
//        now() < fh_events.rsvps_open_at (§6.5.2 window rule),
//        with 404 when the target fh_event is unknown or its
//        gcal_events parent is tombstoned/cancelled.
//
//        NB: the design doc originally called this endpoint
//        `POST /api/rsvp`, but that path is already owned by
//        EventRsvpController (the chat-driven RSVP flow).  Scoped
//        under /api/calendar/* to mirror the read endpoint above
//        and keep the two RSVP systems non-overlapping.
//
//   GET /api/calendar/my-standing     (Slice 6a — see §6.5.3)
//        Session-gated.  Return the caller's fh_recurring_rsvps
//        rows as JSON: { prefs: [{ kind, category, response,
//        active }...] }.  Never returns rows for a different
//        person_id.  Empty array is normal (new user, hasn't
//        opted in yet).
//
//   POST /api/calendar/my-standing    (Slice 6a — see §6.5.3)
//        Session-gated.  Body: { kind:string, category:string|null,
//        response:'yes'|'no'|'maybe', active:bool }.  Upserts one
//        row keyed on (person_id, kind, COALESCE(category,'')) — the
//        functional unique index from migration 119.  Setting
//        active=false leaves the row present (for audit) but the
//        applier §6.5.3 will skip it on future events.
//
//        This endpoint does NOT retroactively apply the standing
//        pref to past-window events — those already have an
//        RSVP (or the applier ran with the pref absent).  The
//        change takes effect for the NEXT event whose
//        rsvps_open_at trips past now() while the row is active.
//
//   GET /api/calendar/events/:fhEventId/attendance
//        Session-gated.  Returns the roster for the event — every
//        player (fh_event_teams/team_persons) AND every coach
//        (fh_event_teams/team_coaches) of an attached team, tagged
//        `is_coach:bool` — left-joined to their fh_event_attendance
//        mark, plus `can_mark:bool` — true when the caller is a club
//        admin or a coach of one of the event's teams. 404 when the
//        fh_event doesn't exist. Read is not restricted to
//        can_mark==true callers (matches my_rsvp_eligible's
//        read-is-open stance); the frontend uses can_mark to decide
//        whether to render the tap-to-mark buttons or a read-only list.
//
//   POST /api/calendar/events/:fhEventId/attendance
//        Body: { person_id:int, status:'present'|'absent'|'late'|
//        'excused' }.  Re-checks the coach/admin EXISTS subquery
//        server-side (this is the first write endpoint in the app
//        with a real permission bar above "bearer present" — do not
//        weaken it to a client-supplied role flag). 403 when the
//        caller isn't a coach/admin for this event's team(s), 400
//        when person_id isn't a player OR coach on one of those
//        teams (coaches can mark each other, not just players).
//        Upserts fh_event_attendance on (fh_event_id, person_id).
//
//   DELETE /api/calendar/events/:fhEventId/attendance
//        Body: { person_id:int }.  Clears a mark back to "not yet
//        marked" (deletes the fh_event_attendance row) rather than
//        setting it to some fifth status — same coach/admin + roster
//        checks as POST. 404 if there was no mark to clear.
class CalendarController : public Controller {
public:
    CalendarController();
    ~CalendarController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetUpcoming         (const Request& request);
    Response handlePostRsvp            (const Request& request);
    Response handleGetMyStanding       (const Request& request);
    Response handlePostMyStanding      (const Request& request);
    Response handleGetEventAttendance  (const Request& request);
    Response handlePostEventAttendance (const Request& request);
    Response handleDeleteEventAttendance(const Request& request);
};
