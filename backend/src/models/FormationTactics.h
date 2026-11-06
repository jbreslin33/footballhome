#pragma once
#include <string>
#include "../third_party/json.hpp"

// FormationTactics — coach-drawn situations per formation (migration 1120).
//
// Owner 2026-11-06: "can we use the current graphic to show or add a pill
// for game to show the tactics depending on where opponents and ball are"
// → A: coach-drawn, starting with 3-5-2 (3-R2) for Sunday.
//
// Storage is the long-standing tactical board schema, used as it stands:
// one template board per formation (tactical_boards, board type
// 'template', is_template, formation_id), one frame per situation
// (tactical_frames: label = situation name, notes = the coaching cue),
// our eleven as tactical_frame_players rows keyed by position_id (= shirt
// number, mig 296; slot_number = position_id), opponents as is_opponent
// rows (slot_number 101+, generic_label = what the chip says), the ball as
// a tactical_frame_objects 'ball'.  Coordinates are 0–100: x left → right
// as we attack, y from our goal line (0) to theirs (100).
//
// Situations carry positions, never people — Game Center puts the lineup
// of the day on them by position, so every game on the formation reuses
// them.
class FormationTactics {
public:
    // { formation_id, board_id|null, situations: [{ id, label, notes,
    //   ball: {x,y}|null, players: [{position_id,x,y}],
    //   opponents: [{label,x,y}] }] } in frame order.
    nlohmann::json get(long long formationId);

    // Replaces one situation's positions.  body = { ball?: {x,y},
    // players: [{position_id,x,y}], opponents: [{label,x,y}] } — already
    // validated by the controller.  False when the frame isn't a formation
    // tactics situation.
    bool putSituation(long long frameId, const nlohmann::json& body, long long byUserId);
};
