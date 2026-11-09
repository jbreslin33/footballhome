#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class TacticPlans;

// /api/tactic-plans — jobs per ball position (migration 1121), edited in
// Game Center's 🎯 Tactics pill and played by the game engine.  Anyone
// signed in reads; coaches and admins write.
class TacticPlansController : public Controller {
public:
    TacticPlansController();
    ~TacticPlansController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<TacticPlans> model_;

    bool requireStaff(const Request& request, long long* userId, Response* error);

    Response handleGet(const Request& request);          // ?formation_id&opponent_formation_id&moment&block
    Response handleCreate(const Request& request);       // POST
    Response handleAddState(const Request& request);     // POST /states
    Response handleSolve(const Request& request);        // POST /solve (shared geometry, nothing saved)
    Response handlePutState(const Request& request);     // PUT /states/:stateId
    Response handleDeleteState(const Request& request);  // DELETE /states/:stateId
    Response handleShortcut(const Request& request);    // POST /shortcuts { kind, on }
    Response handleCopy(const Request& request);        // POST /copies (a frozen game moment → a new state)
};
