#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class FieldPlan;

// /api/field-plan — the game page's pitch planner layout (migration 635).
// Anyone may read it (pitch positions, no people); club admins write.
class FieldPlanController : public Controller {
public:
    FieldPlanController();
    ~FieldPlanController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<FieldPlan> model_;

    // Bearer + admins row; fills *userId, else *error (401/403).
    bool requireAdmin(const Request& request, long long* userId, Response* error);
    long long facility(const Request& request);

    Response handleGet(const Request& request);
    Response handlePutLayout(const Request& request);
    Response handleAddSpot(const Request& request);
    Response handleDeleteSpot(const Request& request);
    Response handleAddSave(const Request& request);
    Response handleDeleteSave(const Request& request);
};
