#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"
#include "../models/MensRoster.h"

class MensTeamColumns;
class MensTeamAssignments;

// ────────────────────────────────────────────────────────────────────────────
// MensRosterController — REST surface for the mens dashboard.
//
// Routes (registered under prefix "/api/mens-roster"):
//   GET  /api/mens-roster[?includeAll=1]
//   POST /api/mens-roster/assign         body: {leagueAppsUserId, teamId, action}
//   POST /api/mens-roster/roster-status  body: {leagueAppsUserId, teamId, onRoster}
//
// Bearer-presence auth (same as Phases 1-7).
//
// `assigned_by_user_id` is NOT extracted from the bearer because the
// C++ backend currently uses an alg:none JWT just for presence checks
// (real userId decoding is per-controller and not yet generalised).  The
// schema column is nullable, so we write NULL — matching the test-token
// case in Node where req.userId would be undefined.
// ────────────────────────────────────────────────────────────────────────────
class MensRosterController : public Controller {
public:
    MensRosterController();
    ~MensRosterController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<MensRoster>           model_;
    std::unique_ptr<MensTeamColumns>      columns_;
    std::unique_ptr<MensTeamAssignments>  assignments_;

    Response handleGet(const Request& request, const LaSyncMap& sync);
    Response handleAssign(const Request& request);
    Response handleRosterStatus(const Request& request);
    // POST /api/mens-roster/reorder — rewrite coach_sort_order for a
    // team column after the coach drags a card to a new position.
    // Body: {teamId, userIds:[...]} — dense 1..N rank assigned in list
    // order.  Added 2026-07-04 pm (migration 089).
    Response handleReorder(const Request& request);
    // POST /api/lineups/games — create an ad-hoc match/event bound to a
    // team so the lineup column has an "upcoming match" to attach RSVPs
    // to.  Body: {team_id, opponent, date:"YYYY-MM-DD", time?:"HH:MM"}.
    Response handleCreateGame(const Request& request);
    // PUT /api/lineups/games/:matchId — edit an ad-hoc match previously
    // created via handleCreateGame.  Same body shape as create (opponent,
    // date, time?) minus team_id (immutable — a lineup match belongs to
    // one team column for its whole life).  Only matches with
    // match_type_id=2 (ad-hoc / lineup-created) are editable through
    // this endpoint — real events/matches route through EventController's
    // heavier PUT /api/matches/:matchId which owns the full event schema.
    Response handleUpdateGame(const Request& request);
    // GET  /api/mens-roster/rsvp-eligibility?leagueAppsUserId=<uid>
    // PUT  /api/mens-roster/rsvp-eligibility  body: {leagueAppsUserId, teamIds:[...]}
    //
    // Read + write the per-player `player_rsvp_eligibility` grants
    // (migration 107).  The GET returns the set of team_ids the player
    // is currently allowed to RSVP for; PUT replaces that set (delta
    // insert/delete against the existing rows).  Powers the player-card
    // "RSVP" popup on the mens Roster Board so admin can add someone
    // to just Pickup, or grant an Adult League member access to a
    // one-off APSL game, etc.
    Response handleGetRsvpEligibility(const Request& request);
    Response handlePutRsvpEligibility(const Request& request);

};
