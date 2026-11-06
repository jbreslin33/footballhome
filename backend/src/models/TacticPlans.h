#pragma once
#include <string>
#include "../third_party/json.hpp"

// TacticPlans — jobs per ball position (migration 1121), shared by Game
// Center's 🎯 Tactics pill and the game engine.
//
// A plan is our formation vs theirs, a moment (game_moments) and a block
// height.  Its states are "ball with their #N", linked by passes from the
// root (their GK has it).  Each state stores where their eleven stand and
// one job per our outfield position: a tactic_job_kinds row (= a
// game_concepts concept) plus their numbers.  Our spots are not stored —
// both the app and the engine compute them from the jobs.
class TacticPlans {
public:
    // { moments: [{code,title}], blocks: [{code,label,gk_y}],
    //   kinds: [{code,concept_id,concept,concept_title,cue,label,target_a_label,target_b_label,dist_m,press_m}] }
    nlohmann::json lookups();

    // The plan for a matchup, or null; with its states (root first, then by
    // id), each { id, parent_state_id, ball_with, opponents: [{number,x,y}],
    // jobs: [{position_id,kind,target_a,target_b}] }.  Also our formation's
    // spots (our_positions) and theirs mirrored (opponent_base) for states
    // without stored opponents.
    nlohmann::json find(long long formationId, long long opponentFormationId,
                        const std::string& moment, const std::string& block);

    // Creates the plan with its root state (their GK on the ball, their
    // formation mirrored as the opponents, no jobs).  Returns the plan id;
    // an existing plan's id when it is already there.  0 = bad inputs.
    long long create(long long formationId, long long opponentFormationId,
                     const std::string& moment, const std::string& block, long long byUserId);

    // The state reached by passing from parent to their #ballWith — made by
    // copying the parent's opponents and jobs when new.  0 = no such parent.
    long long addState(long long parentStateId, int ballWith);

    // Replaces a state's opponents and jobs (validated by the controller).
    // False when there is no such state.
    bool putState(long long stateId, const nlohmann::json& body);

    // Deletes a non-root state and everything after it.  False when there is
    // no such state or it is the root.
    bool deleteState(long long stateId);
};
