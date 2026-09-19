#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../core/Controller.h"

class RsvpBoard;

// RsvpBoardController — #rsvps (owner 2026-09-17).
//
//   GET  /api/rsvp-board?section=mens|womens|boys|girls&window=week|2w|month|all
//                       &kind=all|games|practices
//        One card per rostered player: RSVP % for the window, what is still
//        unanswered in the released week, last RSVP, dues, last payment,
//        last reminder.  Club admins only for now; the coach scoping (own
//        teams, no payment amounts) is written but switched off in
//        resolveScope.
//
//   POST /api/rsvp-board/remind   { person_id, channel: 'sms' | 'email' }
//        Builds the reminder from the DB — the player's unanswered events
//        in the released week + the recipient's magic link (the parent for
//        youth) — logs it, and returns the sms:/Gmail compose href for the
//        sender's own client.  Same "send from the card, track it" shape as
//        WelcomeController.
//
//   POST /api/rsvp-board/remind-event
//        { section?, fh_event_id | match_id, team_id?, scope?: 'event' | 'week',
//          channel: 'sms' | 'email' }
//        ONE message to everybody in the section (or that team) who has
//        not answered a still-open event: group text / BCC email.  No
//        magic link — a group message never carries one — so the copy
//        (kind='rsvp_reminder' tier='group_adult'|'group_parent', mig 380)
//        points at footballhome.org.  scope 'week' (Game Center's No
//        Response section, mig 381) lists every still-open event of the
//        week those players owe, so a missing practice is caught too.
//        Logged per player (is_group); the
//        contacts go back so the browser can build the sms: / Gmail href
//        with its own device quirks (screen-base.js).
class RsvpBoardController : public Controller {
public:
    RsvpBoardController();
    ~RsvpBoardController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<RsvpBoard> model_;

    struct Scope {
        long long userId = 0;
        long long personId = 0;
        bool isAdmin = false;
        std::vector<long long> coachTeamIds;
    };
    // False (with *error set) when the caller is neither an admin nor a coach.
    bool resolveScope(const Request& request, Scope* scope, Response* error);

    Response handleList(const Request& request);
    Response handleRemind(const Request& request);
    Response handleRemindEvent(const Request& request);
    Response handleReminders(const Request& request);
    Response handleSquadNotice(const Request& request);
    Response handleSquadNoticeStatus(const Request& request);
};
