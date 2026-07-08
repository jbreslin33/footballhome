#pragma once
#include <memory>
#include <string>

#include "../core/Controller.h"

class MensRoster;
class BoysRoster;

// ────────────────────────────────────────────────────────────────────────────
// ClubRostersController — cross-domain "Club Rosters" master board API.
//
// Design (2026-07-07 pivot from per-domain LL work):
//   The per-domain boards (boys-roster / mens-roster / girls-roster) are all
//   filtered views over the same underlying tables (persons +
//   roster_assignments + roster_columns).  This controller exposes that
//   union directly so the frontend can render a single Club Rosters screen
//   that lists every FH member with color-coded chips for their team
//   assignments across ALL domains, and the per-domain boards can later be
//   re-implemented as filter presets over the same data.
//
// Routes (registered under prefix "/api/club-rosters"):
//   GET  /api/club-rosters
//   POST /api/club-rosters/assign
//     body: { "leagueAppsUserId": <int|string>,
//             "teamId":           <int>,
//             "action":           "add"|"remove" }
//     Looks up the target team's domain + mutex_group from roster_columns
//     and delegates to a per-domain MensTeamAssignments instance so mutex
//     eviction, delinquent-restore, and audit history stay identical to
//     the per-domain boards.  Only teams that have a roster_columns entry
//     are assignable — pool teams (Practice / Pickup) are managed by
//     LaPool.cpp and are read-only from the coach's perspective.
//   POST /api/club-rosters/roster-status
//     body: { "leagueAppsUserId": <int|string>,
//             "teamId":           <int>,
//             "onRoster":         <bool> }
//     Match-day roster toggle.  Same domain-lookup pattern as /assign;
//     delegates to MensTeamAssignments::setRosterStatus.  Returns 404
//     when no active assignment exists for the (user, team) pair.
//   POST /api/club-rosters/reorder
//     body: { "teamId":  <int>,
//             "userIds": [<int|string>, ...] }
//     Drag-reorder within a team column.  userIds is a dense list —
//     each user is assigned rank = index+1 in `coach_sort_order`.
//     Users on the team but missing from the list are left alone
//     (NULL sort order → alpha fallback in the per-domain view).
//
// Auth: bearer-token presence (same as the domain boards).
// ────────────────────────────────────────────────────────────────────────────
class ClubRostersController : public Controller {
public:
    ClubRostersController();
    ~ClubRostersController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGet         (const Request& request);
    Response handleAssign      (const Request& request);
    Response handleRosterStatus(const Request& request);
    Response handleReorder     (const Request& request);

    // Shared per-domain enrichment models.  Held as members (not
    // constructed per-request) so their in-memory LeagueApps caches
    // survive across GETs — matches how MensRosterController manages
    // its own MensRoster instance.  See enrichWithMensBilling() and
    // enrichWithYouthFields() in ClubRostersController.cpp for how
    // the merge happens.
    std::unique_ptr<MensRoster> mensRoster_;
    std::unique_ptr<BoysRoster> boysRoster_;
};
