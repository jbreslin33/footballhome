-- 1888 (2026-11-25): every machine state NAMED, the label a table, pressing distance on the whole time.
--
-- Owner 11/25: "lol how is the concept not in the state the whole time? when they don't have ball and
-- defending lol. Stay in pressing distance. so confusing" · "like your taking short cuts. is it a state
-- or not" · "just name the state the player is in a table field. then if you want to editorialise who he
-- is marking or whatever then use other fields".
--
-- So: the pressing-distance machine is ON whenever his side defends and he has a man (not the presser,
-- not the loose ball's man); STEPPING is the part where he corrects. The five that were the page's guess
-- (recover, press, loose ball, double-team, cover) are engine machines too. The player's label is a table:
-- Machine | State | Man | Detail — the state's name in its own field, who and how far in the others.
UPDATE game_engine_terms SET wire_index = 2, sort_order = 2, code = 'pressing_distance.stepping'
 WHERE kind = 'machine_state' AND code = 'pressing_distance.stepping';
INSERT INTO game_engine_terms (kind, code, title, note, sort_order, wire_index, parent, definition)
SELECT v.* FROM (VALUES
  ('machine_state', 'pressing_distance.on', 'Stay in pressing distance', NULL::text, 1, 1, 'pressing_distance',
   'The whole time his side is defending and he has a man: he keeps close enough to reach that man while a pass to him would travel. Whether he is in reach right now is in the Detail.'),
  ('machine', 'recover', 'Recover', 'ai/concepts/Machines — MachineId::Recover', 4, 4, NULL, 'The line is broken behind him: he gets back goal-side before anything else.'),
  ('machine', 'press', 'Press', 'ai/concepts/Machines — MachineId::Press', 5, 5, NULL, 'He is the one man who goes to their player on the ball.'),
  ('machine', 'loose_ball', 'Loose ball', 'ai/concepts/Machines — MachineId::LooseBall', 6, 6, NULL, 'Nobody has it and he is our first man to it.'),
  ('machine', 'double_team', 'Double-team', 'ai/concepts/Machines — MachineId::DoubleTeam', 7, 7, NULL, 'He is the second man on their player on the ball.'),
  ('machine', 'cover', 'Cover', 'ai/concepts/Machines — MachineId::Cover', 8, 8, NULL, 'He is the deeper of the two centre-backs, behind the one who steps out.'),
  ('machine_state', 'recover.getting_back', 'Recover goal-side', NULL, 1, 1, 'recover', 'His place in the shape is 5 m or more behind him: he sprints back onto the line between ball and goal.'),
  ('machine_state', 'press.closing', 'Close down the man on the ball', NULL, 1, 1, 'press', 'Goes to their player on the ball and stops a short distance off him, goal-side.'),
  ('machine_state', 'loose_ball.going', 'First to the loose ball', NULL, 1, 1, 'loose_ball', 'Goes to where he can take the loose ball first.'),
  ('machine_state', 'double_team.second', 'Second man on the ball', NULL, 1, 1, 'double_team', 'Joins the presser on their man near the touchline, closing his way inside.'),
  ('machine_state', 'cover.behind', 'Cover behind the presser', NULL, 1, 1, 'cover', 'Sits behind his partner who has stepped out, on the line to our goal.')
) AS v(kind, code, title, note, sort_order, wire_index, parent, definition)
WHERE NOT EXISTS (SELECT 1 FROM game_engine_terms t WHERE t.kind = v.kind AND t.code = v.code);
UPDATE game_engine_terms SET title = 'Watching his man' WHERE kind = 'machine_state' AND code = 'marking_scheme.watching';
UPDATE game_engine_terms SET title = 'Zonal marking' WHERE kind = 'machine_state' AND code = 'marking_scheme.zonal';
UPDATE game_engine_terms SET title = 'Free — the spare man' WHERE kind = 'machine_state' AND code = 'marking_scheme.free';
UPDATE game_engine_terms SET title = 'Hiding a man behind him' WHERE kind = 'machine_state' AND code = 'cover_shadow.hiding';
UPDATE game_engine_terms SET title = 'Press on the cover shadow' WHERE kind = 'machine_state' AND code = 'cover_shadow.on_the_lane';
UPDATE game_engine_terms SET title = 'Stepping into reach' WHERE kind = 'machine_state' AND code = 'pressing_distance.stepping';

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, 'game/src/ai/concepts/Machines.cpp', 1, 'concept machines 11/25', 'individual', v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = v.concept), v.other, NULL, 'high', true, true
  FROM (VALUES
    ('machine_recover', 'recover', '', 'His recover machine: on while his place in the shape is 5 m or more goal-side of him (line broken behind him).'),
    ('machine_press_chase_double', 'close-down', 'nearest-decides, double-team', 'His press, loose-ball and double-team machines: on while the engine has him as the presser, the loose ball''s man, or the second man.'),
    ('machine_cover', 'cover', '', 'His cover machine: on while he is the deeper centre-back behind the one who steps out.')
  ) AS v(code, concept, other, what)
ON CONFLICT (code) DO NOTHING;
UPDATE game_engine_behaviours SET what = 'His pressing-distance machine: ON the whole time his side defends and he has a man (not the presser, not the loose ball''s man); STEPPING when, holding his place with his man out of reach and the dial on, he corrects.'
 WHERE code = 'machine_pressing_distance';
UPDATE game_engine_behaviours SET what = 'A machine keeps its state 0.3 s before dropping to a lower one (asleep the lowest), so it does not flicker; it goes deeper at once (on → stepping), and leaves at once when what it lives in has gone.'
 WHERE code = 'machine_commit';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — state table: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('column: machine', 'tbl_machine', 'Machine', 420),
    ('column: state', 'tbl_state', 'State', 421),
    ('column: man', 'tbl_man', 'Man', 422),
    ('column: detail', 'tbl_detail', 'Detail', 423),
    ('row: team machine', 'tbl_team', 'Team', 424),
    ('row: his job machine', 'tbl_job', 'His job', 425),
    ('row: doing', 'tbl_doing', 'Doing', 426),
    ('detail: reach ({gap}, {reach}, {verdict})', 'tbl_reach', '{gap} m away · can reach {reach} m · {verdict}', 427),
    ('in', 'tbl_in', 'IN reach', 428),
    ('out', 'tbl_out', 'OUT of reach', 429),
    ('detail: hidden ({list})', 'tbl_hidden', 'hidden: {list}', 430)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
