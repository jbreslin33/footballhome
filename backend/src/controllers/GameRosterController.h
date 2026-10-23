#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class GameRoster;

// /api/game — the game page's attribute editor (migration 636). Signed-in
// members read a team's players + attributes; club admins save them.
class GameRosterController : public Controller {
public:
    GameRosterController();
    ~GameRosterController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<GameRoster> model_;
    Response handleRoster(const Request& request);
    Response handleSavePlayer(const Request& request);
};
