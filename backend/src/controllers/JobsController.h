#pragma once
#include <string>
#include "../core/Controller.h"

// JobsController — /api/jobs, behind the #jobs page (mig 625).
//
// Event jobs for games and practices, auto-assigned from who is actually
// going (RSVP yes / attendance present), owner's rules:
//   - STICKY: each player keeps a "home job" per set (one practice home,
//     one game home) — no forced rotation, home holders never bumped.
//   - Gaps fill with someone who has done the job before first, then
//     whoever has done the fewest jobs in the last 60 days.
//   - Late RSVPs re-run the fill on every open; only gap-fills move.
//   - Check-off defaults to DONE — only exceptions get flagged not_done.
//   - Definitions + copy are job_definitions rows per event kind (the
//     APSL game-day set is scoped by league_label).
//
//   GET  /api/jobs/board?from=&days=       events of the window + counts
//   GET  /api/jobs/event/:id               one event, assignments ensured
//   POST /api/jobs/event/:id/mark          { assignment_id, not_done }
//   POST /api/jobs/event/:id/toggle        { job_definition_id, on }   (tents)
//   POST /api/jobs/event/:id/assign        { job_definition_id, person_id }  manual add
//   POST /api/jobs/event/:id/unassign      { assignment_id }
//
// Admins and active coaches only.
class JobsController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

    // The auto-assigner — also run by CalendarController after every
    // RSVP write, so a late Going / Not going refills jobs right away
    // and the player's #my card (which only READS assignments) is
    // never waiting on a coach to open #jobs.  Harmless no-op for
    // event kinds without job_definitions.
    static void ensureAssignments(long long eventId);

private:
    bool gate(const Request& request, Response* error);

    Response handleBoard(const Request& request);
    Response handleEvent(const Request& request);
    Response handleMark(const Request& request);
    Response handleToggle(const Request& request);
    Response handleAssign(const Request& request);
    Response handleUnassign(const Request& request);
};
