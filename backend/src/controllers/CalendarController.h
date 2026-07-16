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
// This endpoint is UNAUTHENTICATED for now. It exposes only
// scheduling metadata (title, time, location, kind) — no PII, no
// RSVP identities. When Slice 6's per-user RSVP surface lands the
// write endpoints will be session-gated separately; this read
// endpoint stays open so unauthenticated visitors can see the
// public schedule.
class CalendarController : public Controller {
public:
    CalendarController();
    ~CalendarController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetUpcoming(const Request& request);
};
