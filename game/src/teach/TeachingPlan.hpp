// game/src/teach/TeachingPlan.hpp
//
// The teaching room's plan (docs/teaching-room.md): one club tactic plan — Calendar →
// Game Center 🎯 Tactics, the tactic_plans tables — as the plain structs of
// shared/tactics/TacticGeometry.hpp, the ONE placement code the board and this room
// share. Loaded once when a room opens; the sim loop never touches the database.
//
// This directory is the teaching room only. Nothing in src/ai, src/core or the live
// match reads it: the Premier League game stays as the engine models it.

#pragma once

#include "ai/Formation.hpp"
#include "persistence/FormationStore.hpp"
#include "tactics/TacticGeometry.hpp"

#include <map>
#include <optional>
#include <string>
#include <vector>

namespace fh::game::teach {

// One step of the plan: their ball with #ball_with, each of ours his job.
struct PlanState {
    int id = 0;
    int parent = 0;                                  // 0 = the root (their goal kick)
    int ball_with = 1;
    std::optional<fh::tactics::RestartLaw> law;      // the root's restart, while the ball is dead
    std::vector<fh::tactics::Job> jobs;
};

// A job kind's words on the board: the game concept it plays.
struct KindConcept {
    int id = -1;
    std::string name, title;
};

struct Plan {
    int id = 0;
    std::string us_code, them_code;                  // formations.code
    std::string block;                               // tactic_block_heights.code
    fh::tactics::PlanFrame frame;
    std::vector<PlanState> states;                   // the root first
    std::map<std::string, KindConcept> concepts;     // by tactic_job_kinds.code
    ai::FormationSpec us, them;                      // the two shapes, numbered as the board numbers them

    const PlanState* root() const { return states.empty() ? nullptr : &states.front(); }
    // The step for a pass to their #n: under `from` first, then under the root; the root
    // itself when it is their keeper again. nullptr = no step drawn (the men keep their jobs).
    const PlanState* next(const PlanState* from, int n) const;
};

// nullopt on any failure (connection, unknown plan, a formation the engine can't field).
std::optional<Plan> loadPlan(const persistence::DbConfig& db, int plan_id);

}  // namespace fh::game::teach
