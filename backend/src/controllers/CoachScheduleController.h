#pragma once
#include <string>
#include "../core/Controller.h"

// CoachScheduleController — /api/coach-schedule, behind #coach-schedule
// (mig 955).  Club admins set which weekdays each coach covers per section.
// fh_coach_off_schedule() then decides what that coach sees and RSVPs to.
//
//   GET  /api/coach-schedule       { sections: [{ id, name, coaches: [{ coach_id, name, days }] }] }
//   POST /api/coach-schedule       { coach_id, club_section_id, days: [1..7] }
//
// A coach with no row counts as every day.  No days = call in if needed.
class CoachScheduleController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    bool gate(const Request& request, Response* error);
    Response handleGet(const Request& request);
    Response handleSave(const Request& request);
};
