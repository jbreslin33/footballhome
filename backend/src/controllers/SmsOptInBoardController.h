#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../core/Controller.h"

class SmsOptInBoard;

// /api/texts-board — the #texts board (migration 537): who has opted in
// to club texts, nudge the rest.  Club admins see every board team; a
// coach sees the teams they coach (the #kit scope).
//
//   GET  /teams
//   GET  /roster?team_id=
//   POST /nudge  { team_id, person_id }  → sms_href with a personal link
//                to footballhome.org/sms, logged in sms_opt_in_nudges
class SmsOptInBoardController : public Controller {
public:
    SmsOptInBoardController();
    ~SmsOptInBoardController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<SmsOptInBoard> model_;

    struct Scope {
        long long userId = 0;
        bool isAdmin = false;
        std::vector<long long> coachTeamIds;   // empty for admins = every team
        bool covers(long long teamId) const;
    };
    bool resolveScope(const Request& request, Scope* scope, Response* error);

    Response handleTeams(const Request& request);
    Response handleRoster(const Request& request);
    Response handleNudge(const Request& request);
};
