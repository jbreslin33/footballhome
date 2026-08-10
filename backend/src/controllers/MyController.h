#pragma once

#include "../core/Controller.h"

// MyController — signed-in-player self-service surface.
//
// Post 2026-07-17 (pickup/practice moved onto gcal → fh_events →
// fh_event_rsvps), most of this controller is chat-only.  RSVPs live in
// the CalendarController surface (`/api/calendar/*`); standing
// preferences live in `fh_recurring_rsvps` and are toggled via the same
// calendar surface.  The one exception is push-remind (2026-08-10)
// below — it's a write against WebPushService, not chat, but it's
// small enough not to warrant its own controller.
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
//   POST /api/my/events/push-remind
//        Body: {fh_event_id:int, person_id:int}
//        Sends one Web Push RSVP nudge to person_id for fh_event_id.
//        Caller must be a coach of one of the event's teams or a club
//        admin (same gate as CalendarController::isEventCoachOrAdmin,
//        duplicated here rather than shared across controllers).
//        person_id must be on the event's roster with no RSVP response
//        on file yet — a stale UI can't re-ping someone who already
//        answered. Returns {sent:N} — N is 0 when the target has no
//        active push subscription (not an error).
//
//   POST /api/my/push-test
//        No body. Sends one Web Push test notification to the CALLER's
//        own person_id only — there is no target parameter, by design,
//        so this can never be pointed at anyone else (see push-remind
//        above for the real, other-person nudge path, which is gated
//        to coaches/admins for exactly that reason). Returns {sent:N}.
//
// All endpoints are gated by SessionService cookie OR JWT bearer.
class MyController : public Controller {
public:
    MyController();
    ~MyController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGetChatMessages(const Request& request);
    Response handlePostChatMessage(const Request& request);
    Response handlePushRemind(const Request& request);
    Response handlePushTest(const Request& request);
};
