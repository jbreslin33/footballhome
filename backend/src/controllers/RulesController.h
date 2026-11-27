#pragma once
#include <string>
#include "../core/Controller.h"

// RulesController — 📋 #player-team-rules (mig 4002).
//
//   GET /api/rules   { layers: [...] }   — the signed-in person's layers:
//     🏠 club, their club sections, their teams with rules (ClubRules).
//     Club / super admins get every layer.
class RulesController : public Controller {
public:
    RulesController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleRules(const Request& request);
};
