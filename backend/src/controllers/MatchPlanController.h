#pragma once
#include <string>
#include "../core/Controller.h"

// MatchPlanController — /api/match-plan, behind the 🎯 Match plan section
// of #game-center (migration 966).  Owner 2026-11-03: "we need a game
// warmup section … also part of corner tactics and free kick assignments
// … it can go through everything from warmups to tactics".
//
//   GET  /api/match-plan/:fhEventId
//        { canEdit, times: {arrival, warmup, kickoff},
//          stages:   [ { slug, title, description, minutes, time, hasJob, leaders: [name],
//                        checklist: [ {id, title, ticked} ],
//                        routine: { title, sourceUrl, level,
//                                   sections: [ { title, minutes, steps: [ {no, title, sets, description} ] } ],
//                                   teams: [ { slug, title, numbers: [shirt no], benchExtras } ] } | null } ],
//          setPieces:{ groups: [ { slug, title, roles: [ { id, title, description, needed,
//                                                          picks: [ {slot, personId, name} ] } ] } ],
//                      inheritedFrom: "<when>" | null },
//          tactics }
//        The match-day timeline (match_day_stages): getting there (a
//        checklist the viewer ticks), arrival, dress, the FIFA 11+, water,
//        the 4v4+3, ref check-in, walk out, huddle, kickoff.  A stage's
//        routine is the league's row, else the every-league row; steps at
//        the routine's level.  Leaders = holders of the stage's job
//        (job_assignments, mig 625).  Drill sides come back as shirt
//        numbers — the page maps them onto the lineup it already holds.  Set-piece
//        picks: this game's, else the team's last earlier game's
//        (inheritedFrom says which) — read only, never copied.
//   POST /api/match-plan/:fhEventId   { picks: [ {roleId, slot, personId} ], tactics }
//        Replaces the game's picks and notes.  Editors only.
//   POST /api/match-plan/:fhEventId/tick   { itemId, ticked }
//        The viewer's own checklist tick for this game.
//
// Readers: everyone on the game, their parents, its coaches, club staff,
// club/super admins (fh_match_plan_reader).  Editors: its coaches, club
// staff, club/super admins (fh_match_plan_editor).  A signed-in outsider
// gets 403, never 401 (the SPA logs out on 401).
class MatchPlanController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGet(const Request& request);
    Response handleSave(const Request& request);
    Response handleTick(const Request& request);
};
