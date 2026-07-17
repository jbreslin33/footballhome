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
class CalendarController : public Controller {
public:
    CalendarController();
    ~CalendarController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetUpcoming(const Request& request);
    Response handlePostRsvp   (const Request& request);
};
