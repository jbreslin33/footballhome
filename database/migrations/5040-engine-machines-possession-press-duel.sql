-- 5040 (2026-11-27): the design's machines in the engine, as recognitions first (they label what each player
-- is doing; nothing in the sim reads them — goldens unchanged, ctest 31/31). MachineId 9 possession read, 10 press way,
-- 11 press arrival, 12 duel; the press machine gains ARRIVING (closing = the approach). Registered here so the
-- viewer names them and the 🔀 By machine view shows ⚙️ where the game now runs the designed state.
BEGIN;
INSERT INTO game_engine_behaviours (code, file, line, symbol, class_name, tag, who, what, status, concept_id, is_read, in_sim) VALUES
 ('machine_possession_read', 'game/src/ai/concepts/Machines.cpp', 28, 'PlayerMachines::update', 'PlayerMachines', 'concept machines 11/27', 'individual', 'His possession read: whose ball he thinks it is — his own phase read (with his reaction), the loose ball and who looks like getting it, the dead ball.', 'unnamed', NULL, true, true),
 ('machine_press_approach_arrival', 'game/src/ai/concepts/Machines.cpp', 68, 'PlayerMachines::update', 'PlayerMachines', 'concept machines 11/27', 'individual', 'His press machine has two states: closing (the approach) and arriving (the last arrive_m metres to the carrier).', 'concept', (SELECT id FROM game_concepts WHERE name = 'close-down'), true, true),
 ('machine_press_way', 'game/src/ai/concepts/Machines.cpp', 74, 'PlayerMachines::update', 'PlayerMachines', 'concept machines 11/27', 'individual', 'How the presser approaches: curved onto the lane he hides (cover shadow on the lane), from the carrier''s blind side, or straight.', 'concept', (SELECT id FROM game_concepts WHERE name = 'cover-shadow'), true, true),
 ('machine_press_arrival', 'game/src/ai/concepts/Machines.cpp', 86, 'PlayerMachines::update', 'PlayerMachines', 'concept machines 11/27', 'individual', 'How the presser arrives: stopping short (slowing into his stand-off) or following through (still running in, or on the ground from his tackle).', 'concept', (SELECT id FROM game_concepts WHERE name = 'stop-short'), true, true),
 ('machine_duel', 'game/src/ai/concepts/Machines.cpp', 93, 'PlayerMachines::update', 'PlayerMachines', 'concept machines 11/27', 'individual', 'His duel machine: on the man with the ball (within duel_m) as presser, second man or marker — containing him, or running with him when he goes.', 'concept', (SELECT id FROM game_concepts WHERE name = 'win-duel'), true, true),
 ('read_loose_ball_lean', 'game/src/ai/Brain.cpp', 252, 'Brain::tick', 'Brain', 'concept machines 11/27', 'team', 'The loose ball''s lean: each side''s nearest man; the other side''s nearest loose_margin_m further = that side''s ball, inside the margin = 50/50.', 'unnamed', NULL, true, true);
UPDATE game_engine_behaviours SET line = 1194 WHERE code = 'block_recover' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 365 WHERE code = 'block_shift_while_ball_travels' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 314 WHERE code = 'block_slide_across' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1009 WHERE code = 'block_tracks_carrier' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 328 WHERE code = 'block_width_narrow' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 680 WHERE code = 'corner_delivery' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 127 WHERE code = 'cs_press_along_the_lane' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 1166 WHERE code = 'def_danger_get_back' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1092 WHERE code = 'def_into_the_lane' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 691 WHERE code = 'fk_into_box' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 476 WHERE code = 'fk_stand_over_ball' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 996 WHERE code = 'front_man_rides_the_line' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1048 WHERE code = 'fwd_jog_back' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 468 WHERE code = 'hold_face_ball' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1208 WHERE code = 'hold_walk_far_from_ball' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 524 WHERE code = 'keeper_goal_kick_long_fallback' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 656 WHERE code = 'keeper_penalty_on_line' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 839 WHERE code = 'law_distance_at_restart' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 871 WHERE code = 'law_out_of_their_box_goal_kick' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1068 WHERE code = 'line_run_pace' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 14 WHERE code = 'machine_commit' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 108 WHERE code = 'machine_cover' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 49 WHERE code = 'machine_cover_shadow' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 93 WHERE code = 'machine_duel' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 41 WHERE code = 'machine_marking_scheme' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 28 WHERE code = 'machine_possession_read' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 68 WHERE code = 'machine_press_approach_arrival' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 86 WHERE code = 'machine_press_arrival' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 66 WHERE code = 'machine_press_chase_double' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 74 WHERE code = 'machine_press_way' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 114 WHERE code = 'machine_pressing_distance' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 60 WHERE code = 'machine_recover' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 251 WHERE code = 'machine_tick' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1002 WHERE code = 'mark_run_with_man' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 891 WHERE code = 'pass_first_time_when_pressed' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 950 WHERE code = 'pass_keep_carry_feet' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 912 WHERE code = 'pass_lead_into_path' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 141 WHERE code = 'pd_bend_his_place' AND file = 'game/src/ai/concepts/Machines.cpp';
UPDATE game_engine_behaviours SET line = 608 WHERE code = 'penalty_kick' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 646 WHERE code = 'penalty_stay_out' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 381 WHERE code = 'poss_width_by_ball' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1146 WHERE code = 'press_arrive_with_carrier' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1278 WHERE code = 'race_arrive_on_time' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 366 WHERE code = 'read_ball_destination' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1081 WHERE code = 'read_in_danger' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 252 WHERE code = 'read_loose_ball_lean' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1055 WHERE code = 'read_our_ball_live' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 232 WHERE code = 'read_possession_own' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 973 WHERE code = 'recv_track_rolling_ball' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 438 WHERE code = 'restart_shape_hold' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 489 WHERE code = 'restart_taker' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 540 WHERE code = 'restart_walk_to_spot' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1177 WHERE code = 'shape_moves_with_our_ball' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1026 WHERE code = 'shape_pace_caps_by_direction' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 1165 WHERE code = 'shape_shift_at_a_jog' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 771 WHERE code = 'sp_corner_attack_shape' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 770 WHERE code = 'sp_corner_defend_shape' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 794 WHERE code = 'sp_fk_box_lines' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 783 WHERE code = 'sp_fk_wall' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 559 WHERE code = 'throw_in_to_free_man' AND file = 'game/src/ai/Brain.cpp';
UPDATE game_engine_behaviours SET line = 344 WHERE code = 'wingback_ball_side_goes_far_tucks' AND file = 'game/src/ai/Brain.cpp';

UPDATE game_engine_terms SET title = 'Approach', definition = 'Closing: he is on his way to their player on the ball.' WHERE kind = 'machine_state' AND code = 'press.closing';
INSERT INTO game_engine_terms (kind, code, title, note, sort_order, wire_index, parent, definition) VALUES
 ('machine_state', 'press.arriving', 'Arrival', 'ai/concepts/Machines — press::Arriving (11/27)', 2, 2, 'press', 'The last metres (arrive_m) to the carrier.'),
 ('machine', 'possession_read', 'Possession read (whose ball he thinks it is)', 'ai/concepts/Machines — MachineId::PossessionRead (11/27)', 9, 9, NULL, 'His own read of who has the ball — not the truth: his phase read with his reaction, the loose ball, the dead ball.'),
 ('machine', 'press_way', 'Approach: ways', 'ai/concepts/Machines — MachineId::PressWay (11/27)', 10, 10, NULL, 'How the presser approaches the carrier.'),
 ('machine', 'press_arrival', 'Arrival: ways', 'ai/concepts/Machines — MachineId::PressArrival (11/27)', 11, 11, NULL, 'How the presser finishes his run.'),
 ('machine', 'duel', 'Duel 1v1', 'ai/concepts/Machines — MachineId::Duel (11/27)', 12, 12, NULL, 'On the man with the ball.'),
 ('machine_state', 'possession_read.ours', 'Ours: settled', NULL, 1, 1, 'possession_read', NULL),
 ('machine_state', 'possession_read.ours_won', 'Ours: we just won it', NULL, 2, 2, 'possession_read', NULL),
 ('machine_state', 'possession_read.theirs', 'Theirs: settled', NULL, 3, 3, 'possession_read', NULL),
 ('machine_state', 'possession_read.theirs_won', 'Theirs: they just won it', NULL, 4, 4, 'possession_read', NULL),
 ('machine_state', 'possession_read.loose_ours', 'Loose: likely ours', NULL, 5, 5, 'possession_read', NULL),
 ('machine_state', 'possession_read.loose_5050', 'Loose: 50/50', NULL, 6, 6, 'possession_read', NULL),
 ('machine_state', 'possession_read.loose_theirs', 'Loose: likely theirs', NULL, 7, 7, 'possession_read', NULL),
 ('machine_state', 'possession_read.dead_ours', 'Dead ball: our restart', NULL, 8, 8, 'possession_read', NULL),
 ('machine_state', 'possession_read.dead_theirs', 'Dead ball: their restart', NULL, 9, 9, 'possession_read', NULL),
 ('machine_state', 'press_way.straight', 'Straight and fast', NULL, 1, 1, 'press_way', NULL),
 ('machine_state', 'press_way.curved', 'Curved, keeping a man in his shadow', NULL, 2, 2, 'press_way', NULL),
 ('machine_state', 'press_way.blind_side', 'From his blind side', NULL, 3, 3, 'press_way', NULL),
 ('machine_state', 'press_arrival.stop_short', 'Stop short', NULL, 1, 1, 'press_arrival', NULL),
 ('machine_state', 'press_arrival.follow_through', 'Follow through', NULL, 2, 2, 'press_arrival', NULL),
 ('machine_state', 'duel.contain', 'Contain him', NULL, 1, 1, 'duel', NULL),
 ('machine_state', 'duel.run_with_him', 'Run with him', NULL, 2, 2, 'duel', NULL);

-- 🔀 By machine: the designed states the game now runs flip to ⚙️.
UPDATE game_machines SET status = 'engine', engine_code = v.ec, note = note || ' ⚙️ In the game since 11/27 (' || v.ec || ', a recognition: it labels, the job states still act).'
  FROM (VALUES ('possession-read', 'possession_read'), ('press-phases', 'press'), ('press-approach', 'press_way'), ('press-arrival', 'press_arrival'), ('duel-ways', 'duel')) v(code, ec)
 WHERE game_machines.code = v.code;
UPDATE game_machine_states s SET status = 'engine', engine_code = v.ec
  FROM (VALUES ('possession-read', 'ours', 'possession_read.ours'), ('possession-read', 'ours-won', 'possession_read.ours_won'),
               ('possession-read', 'theirs', 'possession_read.theirs'), ('possession-read', 'theirs-won', 'possession_read.theirs_won'),
               ('possession-read', 'loose-ours', 'possession_read.loose_ours'), ('possession-read', 'loose-5050', 'possession_read.loose_5050'),
               ('possession-read', 'loose-theirs', 'possession_read.loose_theirs'), ('possession-read', 'dead-ours', 'possession_read.dead_ours'),
               ('possession-read', 'dead-theirs', 'possession_read.dead_theirs'),
               ('press-phases', 'approach', 'press.closing'), ('press-phases', 'arrival', 'press.arriving'),
               ('press-approach', 'straight', 'press_way.straight'), ('press-approach', 'curved', 'press_way.curved'), ('press-approach', 'blind-side', 'press_way.blind_side'),
               ('press-arrival', 'stop-short', 'press_arrival.stop_short'), ('press-arrival', 'follow-through', 'press_arrival.follow_through'),
               ('duel-ways', 'contain-or-step', 'duel.contain'), ('duel-ways', 'run-with-him', 'duel.run_with_him')) v(mcode, scode, ec)
  JOIN game_machines m ON m.code = v.mcode
 WHERE s.machine_id = m.id AND s.code = v.scode;
-- The engine's own flat press machine now has the arrival state too.
INSERT INTO game_machine_states (machine_id, code, title, status, engine_code, sort_order)
SELECT id, 'arriving', 'Arrival', 'engine', 'press.arriving', 2 FROM game_machines WHERE code = 'engine-press';
UPDATE game_machine_states SET title = 'Approach' WHERE engine_code = 'press.closing' AND machine_id = (SELECT id FROM game_machines WHERE code = 'engine-press');
UPDATE game_machine_transitions t SET status = 'engine' FROM game_machines m WHERE t.machine_id = m.id AND m.code = 'press-phases';  -- the possession read's arrows stay ✏️: the engine reads by reaction time, not by what he sees or hears yet
COMMIT;
