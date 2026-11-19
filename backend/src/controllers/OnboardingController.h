#pragma once
#include <string>
#include "../core/Controller.h"

// OnboardingController — 🎓 #onboarding, the club admins' side of the
// volunteer → paid path (mig 1526).  The person's own side (their checklist,
// "I sent it") is /api/my/onboarding on MyController.
//
//   GET  /api/onboarding                     { steps, people, candidates }
//   POST /api/onboarding/track   {person_id, track: volunteer|paid|""}   start / move / remove
//   POST /api/onboarding/step    {person_id, code, action: verified|redo|sent|clear, note}
class OnboardingController : public Controller {
public:
    OnboardingController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
};
