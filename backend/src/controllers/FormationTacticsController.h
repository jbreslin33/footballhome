#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class FormationTactics;

// /api/formation-tactics — coach-drawn situations per formation (migration
// 1120), drawn on Game Center's 🎯 Tactics pitch.  Anyone signed in reads
// (players learn from it); coaches and admins move the pieces.
class FormationTacticsController : public Controller {
public:
    FormationTacticsController();
    ~FormationTacticsController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<FormationTactics> model_;

    // Bearer + admins row or an active team_coaches row; fills *userId,
    // else *error (401/403).
    bool requireStaff(const Request& request, long long* userId, Response* error);

    Response handleGet(const Request& request);
    Response handlePutSituation(const Request& request);
};
