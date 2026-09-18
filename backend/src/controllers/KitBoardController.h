#pragma once
#include <memory>
#include <string>
#include <vector>
#include "../core/Controller.h"

class KitBoard;

// /api/kit-board — the #kit board (uniform numbers + kit handed out).
// Club admins see every board team; a coach sees the teams they coach.
class KitBoardController : public Controller {
public:
    KitBoardController();
    ~KitBoardController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<KitBoard> model_;

    struct Scope {
        long long userId = 0;
        bool isAdmin = false;
        std::vector<long long> coachTeamIds;   // empty for admins = every team
        bool covers(long long teamId) const;
    };
    bool resolveScope(const Request& request, Scope* scope, Response* error);

    Response handleTeams(const Request& request);
    Response handleRoster(const Request& request);
    Response handleSetNumber(const Request& request);
    Response handleSetIssued(const Request& request);
};
