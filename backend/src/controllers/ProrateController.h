#pragma once
#include <memory>
#include "../core/Controller.h"

class ProrateLog;

// 💵 The band's Prorate box (mig 1603) — club/super admins only.
//   GET  /api/prorates/due                     new members billed ≤ $1 (laGet: LA synced first)
//   POST /api/prorates/dismiss {person_ids}    ✓ Done without billing
class ProrateController : public Controller {
public:
    ProrateController();
    ~ProrateController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    std::unique_ptr<ProrateLog> model_;
    Response handleDue(const Request& request);
    Response handleDismiss(const Request& request);
};
