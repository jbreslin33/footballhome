#pragma once

#include "../core/Controller.h"

// MyController — signed-in-player self-service surface.
//
// Post 2026-07-17 (pickup/practice moved onto gcal → fh_events →
// fh_event_rsvps), this controller is chat-only.  RSVPs live in the
// CalendarController surface (`/api/calendar/*`); standing preferences
// live in `fh_recurring_rsvps` and are toggled via the same calendar
// surface.
//
// Routes registered under prefix "/api/my":
//   GET  /api/my/chat/messages?since_id=<int>
//        Return up to 200 most recent messages from the men's club
//        chat (chats.slug='mens'), oldest first.  If since_id is
//        supplied, only rows with id > since_id are returned (poll
//        delta).  Membership: caller must have an un-removed row in
//        `roster_assignments` (domain='mens') OR any row in `admins`.
//
//   POST /api/my/chat/messages
//        Body: {message:string}
//        Insert a `chat_messages` row for the men's chat as the caller.
//        Same membership rule as GET.  Rate-limit 3 msgs / 10 sec /
//        user.  Message body is trimmed, must be 1..2000 chars.
//
// Both endpoints are gated by SessionService cookie OR JWT bearer.
class MyController : public Controller {
public:
    MyController();
    ~MyController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetChatMessages(const Request& request);
    Response handlePostChatMessage(const Request& request);
};
