-- 1855 (2026-11-24): STAY IN PRESSING DISTANCE, built whole — and the presser gets his own name.
--
-- Owner 11/24: "lets focus on stay in pressing distance and fully finish it". The catalogue's
-- own cue is the meaning: "Close enough to your man to reach him while a pass to him travels,
-- and close enough to one or more other men to help on them too."
--
-- Two things were wrong before this:
--   • the engine's `press_ball` (the ONE man who steps to their carrier) was named by this
--     concept. That is closing down the man on the ball — a different thing, and one the
--     catalogue had no row for. It gets one (close-down) and the label moves.
--   • nothing in the engine read pressing distance at all.
--
-- game/src/ai/concepts/PressingDistance (on top of DirectOpponent, mig 1853):
--   recognise   every defender with a man: his REACH — how far he can cover while a pass from
--               where the ball is now travels to his man — against the gap to his man. Inside
--               it = in pressing distance. And how many other opponents he could get to.
--   choose      physics.pressdist.hold (0 … 1). NO ROW = 0: read only, the sim unchanged.
--   execute     from his place in the shape, the step toward his man that puts him in reach
--               again (never more than 6 m off his place).
-- The match sends each man's reach with the brain feed (frame REACH) so the clip viewer can
-- draw it. 175 → 178 behaviours.

-- The presser's own concept.
INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking, principle_id, definition)
SELECT (SELECT max(id) + 1 FROM game_concepts), 'close-down', 'Close down the man on the ball', 'individual', 'out_of_possession', 'u10', 'wired',
       'Their man has the ball and you are the nearest: go to him, slow down as you arrive, and stop a stride or two off him, goal-side, on his line to our goal.',
       'Nobody goes to the ball: he has time to look up and pick any pass. Or the man who goes arrives at full speed and is beaten by one touch.',
       (SELECT id FROM game_principles WHERE title = 'Pressure on the ball'),
       'The one defender who goes to the opponent with the ball. He gets close enough that the man cannot play comfortably, stops a short distance off him (the stand-off), and stays between him and our goal. One man does it — the nearest — while everyone else keeps his own job. Not this: staying in pressing distance, which is about every OTHER defender and the man each of them is responsible for; and not the tackle (when to step in is its own decision).'
 WHERE NOT EXISTS (SELECT 1 FROM game_concepts WHERE name = 'close-down');

UPDATE game_engine_acts SET concept_id = (SELECT id FROM game_concepts WHERE name = 'close-down')
 WHERE code = 'press_ball';
UPDATE game_engine_behaviours SET concept_id = (SELECT id FROM game_concepts WHERE name = 'close-down'), other_concepts = 'delay, restraint'
 WHERE code = 'press_ball';
INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT c.id, o.id, 'refines' FROM game_concepts c, game_concepts o
 WHERE c.name = 'engage-or-contain' AND o.name = 'close-down'
   AND NOT EXISTS (SELECT 1 FROM game_concept_links l WHERE l.concept_id = c.id AND l.other_id = o.id);

-- Pressing distance itself.
UPDATE game_concepts SET definition =
  'How close a defender stays to the opponent he is responsible for (his direct opponent) while that man does NOT have the ball. The test: if the ball were passed to that man right now, could the defender get to him while the ball is still travelling? If yes, he is in pressing distance and the man never gets a free first touch. So the right distance is not a fixed number — it depends on how far the ball is from his man. Ball far away: the pass takes long, he can stand well off and help cover the middle. Ball near: the pass is quick, he must be tight. Not this: closing down the man who HAS the ball (that is one player''s job), and not the tackle — it is being close enough to press, before the pass is played.'
 WHERE name = 'pressing-distance';

INSERT INTO game_engine_acts (code, concept_id, note)
SELECT 'press_distance', (SELECT id FROM game_concepts WHERE name = 'pressing-distance'),
       'HoldBlockSpot off his spot toward his man: the step that puts his man back inside his reach (ai/concepts/PressingDistance). Only with physics.pressdist.hold above 0 — no side in the sim has it yet.'
 WHERE NOT EXISTS (SELECT 1 FROM game_engine_acts WHERE code = 'press_distance');

INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, 'game/src/ai/concepts/PressingDistance.cpp', 1, 'pressing distance 11/24', 'individual', v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = 'pressing-distance'), v.other, NULL, 'high', v.is_read, v.in_sim
  FROM (VALUES
    ('pd_reach_his_man', 'direct-opponent, jump-the-pass', true, true,
     'Reads, for his own man: how long a pass from where the ball is now would take to reach him, and how far he himself can run in that time after a 0.3 s reaction (6 m/s, "on him" = within 1.5 m). That distance is his reach. His man inside his reach = in pressing distance.'),
    ('pd_help_on_others', 'cover, shadow-second-man', true, true,
     'Reads how many OTHER opponents he could also get to while a pass to them travels — the second half of the cue: close enough to help on someone else''s man too.'),
    ('pd_step_into_distance', 'mark-position, tighten-near-goal', false, false,
     'Out of pressing distance while holding his place in the shape: he steps off it toward his man, just far enough to have him in reach again and never more than 6 m. How much of that step he takes is a dial (physics.pressdist.hold); with no row it is 0 and nobody moves.')
  ) AS v(code, other, is_read, in_sim, what)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — pressing distance: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('answer: in', 'reach_in', 'IN pressing distance ✅', 290),
    ('answer: out', 'reach_out', 'OUT of pressing distance ❌', 291),
    ('caption before the pass ({num}, {player}, {man}, {gap}, {reach}, {verdict})', 'cap_reach',
     '#{num} {player}: his man #{man} is {gap} m away · he can cover {reach} m while a pass to him travels → {verdict}', 292),
    ('caption as it arrives ({num}, {player}, {man}, {d}, {verdict})', 'cap_reach_arrived',
     'The ball reaches #{man}: #{num} {player} is {d} m from him   ·   when it was played he was {verdict}', 293),
    ('caption when his man is not his to reach ({num}, {player}, {man})', 'cap_reach_none',
     '#{num} {player} — #{man} is not his man yet', 294),
    ('example line ({i}, {n}, {num}, {player}, {man}, {verdict})', 'clip_which_reach',
     'Example {i} of {n} — a pass to #{man}, the man #{num} {player} has: {verdict}', 295),
    ('legend', 'reach_legend',
     'Gold ring = the defender · red ring = his man · the big circle = how far he can get while a pass to his man travels (green: his man is inside it; red: too far) · it freezes at the moment the pass is played', 296)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
