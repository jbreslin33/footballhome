-- 1883 (2026-11-25): the first concept MACHINES run in the engine.
--
-- Owner 11/25: "commit and push then start the engine machines" — the design agreed that day
-- (docs/taxonomy-one-system.md, "Player brain as parallel machines"). game/src/ai/concepts/
-- Machines: beside his job state every player now has real machines, each in one state, asleep
-- ("nothing to do") until there is something to do, several awake at once, an awake one
-- committed for 0.3 s. The first three:
--   marking scheme     asleep · watching his man · zonal on #x · free (the spare man)
--   cover shadow       asleep · hiding (passive: someone is in his shadow from where he stands) ·
--                      pressing on the lane (the presser bends onto the line to the man he hides)
--   pressing distance  asleep · stepping into reach
-- The two bends that sat inside "Hold his place" and "Press the man on the ball" are now these
-- machines' proposals. With no dial rows the sim is byte-identical (goldens unchanged). The
-- match sends the awake machines (frame MACHINES); the clip viewer reads them, no longer a guess.
ALTER TABLE game_engine_terms DROP CONSTRAINT IF EXISTS game_engine_terms_kind_check;
ALTER TABLE game_engine_terms ADD CONSTRAINT game_engine_terms_kind_check
  CHECK (kind = ANY (ARRAY['phase', 'state', 'decision', 'role', 'machine', 'machine_state']));
INSERT INTO game_engine_terms (kind, code, title, note, sort_order, wire_index, parent, definition)
SELECT v.* FROM (VALUES
  ('machine', 'marking_scheme', 'Marking scheme', 'ai/concepts/Machines — MachineId::Marking', 1, 1, NULL::text,
   'How he is minding the opponents right now: watching his direct opponent, marking a man in his zone goal-side, or free — the spare man with nobody of his own.'),
  ('machine', 'cover_shadow', 'Cover shadow', 'ai/concepts/Machines — MachineId::CoverShadow', 2, 2, NULL,
   'Whether someone is hidden behind him from the ball, and whether he is pressing along the line to a receiver so that pass goes through him.'),
  ('machine', 'pressing_distance', 'Pressing distance', 'ai/concepts/Machines — MachineId::PressingDistance', 3, 3, NULL,
   'Whether, holding his place, he is stepping toward his man so a pass to that man would not be a free first touch.'),
  ('machine_state', 'marking_scheme.watching', 'watching his man', NULL, 1, 1, 'marking_scheme', 'He has a direct opponent and keeps an eye on him; he is not tight on him.'),
  ('machine_state', 'marking_scheme.zonal', 'zonal — goal-side of the man in his zone', NULL, 2, 2, 'marking_scheme', 'The man in his zone is his: goal-side of him while he is there.'),
  ('machine_state', 'marking_scheme.free', 'free — the spare man', NULL, 3, 3, 'marking_scheme', 'Nobody of his own: one more at the back to cover.'),
  ('machine_state', 'cover_shadow.hiding', 'someone is hidden behind him', NULL, 1, 1, 'cover_shadow', 'Passive: from where he stands, a ground pass to that man goes through him. He is not doing anything for it.'),
  ('machine_state', 'cover_shadow.on_the_lane', 'pressing along the lane', NULL, 2, 2, 'cover_shadow', 'The presser comes in on the line from the carrier to the receiver he hides, so that pass is blocked by his body.'),
  ('machine_state', 'pressing_distance.stepping', 'stepping into reach', NULL, 1, 1, 'pressing_distance', 'Holding his place, his man too far to reach if the ball goes to him: he steps toward him until he could.')
) AS v(kind, code, title, note, sort_order, wire_index, parent, definition)
WHERE NOT EXISTS (SELECT 1 FROM game_engine_terms t WHERE t.kind = v.kind AND t.code = v.code);

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, v.file, 1, 'concept machines 11/25', 'individual', v.what, v.status,
       (SELECT id FROM game_concepts WHERE name = v.concept), v.other, NULL, 'high', v.is_read, v.in_sim
  FROM (VALUES
    ('machine_tick', 'game/src/ai/Brain.cpp', NULL::text, 'unnamed', '', true, true,
     'Every tick, after the job states: each player''s concept machines read the situation (his job, whose ball, his direct opponent, his reach, his shadow) and move.'),
    ('machine_commit', 'game/src/ai/concepts/Machines.cpp', NULL, 'unnamed', '', true, true,
     'An awake machine stays awake at least 0.3 s, so it does not flicker on and off — unless what it lives in has gone (he stopped holding his place, his team won the ball).'),
    ('machine_marking_scheme', 'game/src/ai/concepts/Machines.cpp', 'direct-opponent', 'concept', 'zonal-marking, libero', true, true,
     'His marking-scheme machine: asleep with our ball, watching his direct opponent, zonal on the man in his zone, or free (the spare man).'),
    ('machine_cover_shadow', 'game/src/ai/concepts/Machines.cpp', 'cover-shadow', 'concept', 'shadow-second-man', true, true,
     'His cover-shadow machine: asleep, hiding someone just from where he stands, or — the presser, with the dial on — pressing along the lane to the receiver he hides.'),
    ('machine_pressing_distance', 'game/src/ai/concepts/Machines.cpp', 'pressing-distance', 'concept', '', true, true,
     'His pressing-distance machine: asleep, or — holding his place, his man out of reach, the dial on — stepping into reach.'),
    ('pd_bend_his_place', 'game/src/ai/concepts/Machines.cpp', 'pressing-distance', 'concept', 'mark-position', false, false,
     'The pressing-distance machine''s proposal: his place moves toward his man by the dial''s share of the step back into reach (physics.pressdist.hold; no row = nothing moves).')
  ) AS v(code, file, concept, status, other, is_read, in_sim, what)
ON CONFLICT (code) DO NOTHING;
UPDATE game_engine_behaviours SET file = 'game/src/ai/concepts/Machines.cpp',
       what = 'The cover-shadow machine''s proposal while he presses: his stand-off spot moves off the carrier''s line to our goal onto the carrier''s line to the receiver he hides, the same distance off him, by the dial''s share (physics.shadow.press; no row = he stands goal-side as fitted).'
 WHERE code = 'cs_press_along_the_lane';
UPDATE game_engine_behaviours SET what = 'Reads the step from his place in the shape toward his man that leaves the gap equal to his reach (never more than 6 m). The pressing-distance machine proposes it.'
 WHERE code = 'pd_step_into_distance';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — engine machines: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('mark on a machine the engine runs', 'm_engine_mark', '⚙', 400),
    ('note on the marks', 'm_engine_note', '⚙ = a machine the engine runs (ai/concepts/Machines). The others are still read from his job state — they become machines next.', 401),
    ('machine: marking scheme', 'm_scheme', 'Marking scheme', 402),
    ('knows: hiding ({list})', 'brain_knows_hiding', 'hidden behind him just from where he stands: {list}', 403)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
UPDATE message_templates SET body = 'scheme,recover,press,chase,double,mark,shadow,cover,pdist'
 WHERE kind = 'taxonomy' AND tier = 'machine_order';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — engine machines: cover shadow on the lane ({man})', 'taxonomy', 'm_shadow_lane', NULL,
       'pressing along the line to {man} — that pass goes through him', 404, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'm_shadow_lane');

-- Beside the pitch (owner 11/25 "can we have the states 1 line each and then you click for info on
-- them? can they be right next to pitch"): a line with no definition yet says so.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — beside the pitch: no definition yet', 'taxonomy', 'm_nodef', NULL, 'No definition written for this yet.', 405, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'm_nodef');

-- Simplified (owner 11/25: "don't have states in multi places its confusing" · "states. then a
-- explanation of concept at hand" · "simple interface" · "too much clutter"): states only in the
-- label that follows the player; one panel for the concept, its game / engine detail folded away.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — panel: more (game + engine)', 'taxonomy', 'clip_more', NULL, 'In the game and in the engine code ▸', 406, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'clip_more');

-- The player label in plain words (owner 11/25: "what is him? what is action? isn't there a possibility of multi states"): ONE AT A TIME (team, his job, doing — only when more than his job) and ALSO ON (the awake machines, several at once).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — player label: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('group: one at a time', 'strip_one', 'One at a time', 410),
    ('group: also on', 'strip_also', 'Also on — several can be on at once', 411),
    ('row: team', 'strip_team', 'Team', 412),
    ('row: his job', 'strip_job', 'His job', 413),
    ('row: doing (only when more than his job)', 'strip_doing', 'Doing', 414)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- Side panel (owner 11/25: "the team him action should be on side" · "the side def should be accessible with click popup" · "save space"): states one line each on the side, machines on the player, every meaning in one popup.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — side panel: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('which match: the concept''s room', 'room_on_short', '▶ Private match — switched ON for both teams', 415),
    ('which match: the live sim', 'room_live_short', 'The live match — nobody is told to do it', 416)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- The state label's two places (owner 11/25: "it can stay if transparent but if not it has to go on side of pitch. maybe have a toggle for either option").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — label toggle: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('on the player (see-through)', 'label_follow', '🏷 Label: on the player', 417),
    ('beside the pitch (solid)', 'label_side', '🏷 Label: beside the pitch', 418)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
