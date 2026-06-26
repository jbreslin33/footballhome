#pragma once

#include "../core/Controller.h"

// EventRsvpController — FH-native, cookie-authed event-detail + RSVP
// surface ported from meta-leads-webhook/index.js (Phase 5).  Reads
// from chat_events / event_rsvps / event_rsvp_log (NOT the legacy
// internal `events` table) and operates on the signed-in person's id.
//
//   GET  /api/events/:chatEventId  — event detail + caller's RSVP
//   POST /api/rsvp                 — UPSERT event_rsvps + log append
//
// Mounted BEFORE the legacy EventController in main.cpp so that the
// :chatEventId path wins over the older /:eventId handler that hits
// the deprecated internal `events` table.
class EventRsvpController : public Controller {
public:
    EventRsvpController();
    ~EventRsvpController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetEvent(const Request& request);
    Response handlePostRsvp(const Request& request);
};
