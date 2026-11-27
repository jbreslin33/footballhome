#pragma once
#include <memory>
#include "../core/Controller.h"

class NewMemberOnboarding;

// 🆕 New-member onboarding report (mig 1896) — club/super admins only.
//   GET  /api/new-members/report                  onboarding report (laGet: LA synced first)
//   POST /api/new-members/dismiss {person_ids}    ✓ Done — off the report
class NewMemberController : public Controller {
public:
    NewMemberController();
    ~NewMemberController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    std::unique_ptr<NewMemberOnboarding> model_;
    Response handleReport(const Request& request);
    Response handleDismiss(const Request& request);
};
