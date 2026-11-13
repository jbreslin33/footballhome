#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class StarterCriteria;

// PracticeCriteriaController — the 📇 🏃 Practice criteria message (mig 1342,
// owner 2026-11-13: "a special message for those that set going but are
// not projected to meet criteria and who are projected … a reminder for
// them to follow through … custom itself depending on attendance and
// rsvps in future").
//
//   POST /api/practice-criteria/message  { person_id, channel, contact }
//        channel email | sms | copy.  Finds his next game he is Going to
//        (StarterCriteria::forPerson), picks the tier by where he stands —
//        short (Going to too few practices), projected (on track if he
//        follows through), met, not_met (no practices left) — lists every
//        practice day of the window with what counts, and adds his sign-in
//        link landing on that game's Game Center.  Words: message_templates
//        kind practice_criteria.  Club admins and coaches.  404 + the
//        not_going words when he has no such game.
class PracticeCriteriaController : public Controller {
public:
    PracticeCriteriaController();
    ~PracticeCriteriaController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<StarterCriteria> model_;
    Response handleMessage(const Request& request);
};
