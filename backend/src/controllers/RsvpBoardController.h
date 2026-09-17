#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../core/Controller.h"

class RsvpBoard;

// RsvpBoardController — #rsvps (owner 2026-09-17).
//
//   GET  /api/rsvp-board?section=mens|womens|boys|girls&window=week|2w|month|all
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
};
