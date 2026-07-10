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
//   GET  /api/my/event-rsvps?match_id=<int>
//        Return the full eligible roster for the given match, bucketed
//        into `going` / `not_going` / `no_response`, plus
//        aggregate counts.  Same eligibility rules as /api/my/week
//        (pickup=any mens; practice=team ∈ {35,120,121}; APSL-home
//        games=team ∈ {35,120}; other games=home_team).  Caller must
//        themselves be eligible OR be an admin.
//
// All endpoints are cookie-session gated (see SessionService::
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
    Response handleGetChatMessages(const Request& request);
    Response handlePostChatMessage(const Request& request);
    Response handleGetEventRsvps(const Request& request);
};
