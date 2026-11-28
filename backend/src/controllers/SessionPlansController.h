#pragma once
#include <string>
#include "../core/Controller.h"

// SessionPlansController — 🗓 exercises tied to practices and games (mig 5020).
//
//   GET    /api/session-plans/teams                  teams this person may plan for
//   GET    /api/session-plans/team/:teamId           that team's week (slots + exercises)
//   POST   /api/session-plans/team/:teamId/items     {slot, exercise_id, minutes?} add to a slot
//   PUT    /api/session-plans/team/:teamId/theme     {slot, theme}
//   PUT    /api/session-plans/items/:kind/:id        {minutes?, note?, move?}  kind = template | event
//   DELETE /api/session-plans/items/:kind/:id
//   GET    /api/session-plans/event/:fhEventId       the session for one practice / game
//   POST   /api/session-plans/event/:fhEventId/edit  copy the plan onto this event
//   DELETE /api/session-plans/event/:fhEventId/edit  back to the plan
//   POST   /api/session-plans/event/:fhEventId/items {exercise_id, minutes?}
//
// Team plans: club admins or that team's coaches.  One event: EventAccess
// coach tier (coach of a team on the event, or admin).  Reading an event's
// session: any signed-in member who can open the event.
class SessionPlansController : public Controller {
public:
    SessionPlansController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handle(const Request& request, const std::string& method);
};
