-- 886 (2026-10-30) — game: preventive marking, position by position (G5.0,
-- game/DESIGN.md §8.98).
--
-- James 10/30: "intelligent direct opponent unmarking … our 4,5,6,2 & 3 to
-- unmark 'goal' side of their do … our 8,10,7,11 and 9 would be encouraged
-- to unmark forward (diagonal and strait) then side ways. then back"; "i want
-- 2 and 3 to unmark NOT wide of do. we can get that width from our 7/11 and
-- our 8/10 popping out"; "is their a 'read' option for the unmarking? like
-- closed ball, open ball". The football name is preventive marking
-- (marcature preventive), how rest defence is done, so rest-defense (70) and
-- inverted-fullback (55), queued since the taxonomy, are wired rather than a
-- new concept minted. Only the read is new: nothing in the taxonomy said it.
--
-- The tactic is a model. gap_m is 0 globally, so no other model changes;
-- demand by position is game_model_role_concepts, read for the first time.

BEGIN;

UPDATE game_concepts
   SET status = 'wired',
       cue_answer = 'While we attack, if you are one of the men staying back: once the ball is past your direct opponent, stand goal-side of him on his line to our goal, ready for the counter.'
 WHERE id = 70 AND name = 'rest-defense';

UPDATE game_concepts
   SET status = 'wired', taught_from = COALESCE(taught_from, 'semipro'),
       cue_answer = 'While we attack: never wider than your direct opponent — inside him, beside the 6. The winger or a midfielder gives the width.'
 WHERE id = 55 AND name = 'inverted-fullback';

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (185, 'open-closed-ball', 'Open ball, closed ball', 'individual', 'in_possession', 'u14', 'wired',
  'Read the man on the ball before you move. Open (no pressure, facing forward, he can play it): go forward. Closed (pressed, or his back to their goal): check in toward him, then sideways, and only then forward.',
  'Makes the same run whatever the ball is doing: gone in behind when the carrier can''t play it, standing still when he can.',
  (SELECT id FROM game_principles WHERE code = 'ip-shape'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT v.id, s.id, v.cit FROM (VALUES
 (185, 'fh', 'James 10/30: "closed ball, open ball concepts of when to unmark forward and check in" (G5.0). Standard coaching read; FH wiring, pressure_m is ours.'),
 (70, 'fh', 'James 10/30: goal-side of the direct opponent while we attack (G5.0). Preventive marking, It. marcature preventive.'),
 (55, 'fh', 'James 10/30: the 2 and 3 unmark NOT wide of their direct opponent (G5.0).')
) AS v(id, code, cit) JOIN game_sources s ON s.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'rest-defense', 'gap_m', 0::numeric, 'm', 'G5.0: goal-side of his direct opponent by this much once the ball is past him. 0 = the model does not play preventive marking. [FH]'),
 ('concept', 'rest-defense', 'wing_band_m', 16, 'm', 'G5.0: the wide channel, from the touchline. A 7 or 11 unmarks no further in. [FH]'),
 ('concept', 'rest-defense', 'wide_m', 6, 'm', 'G5.0: an 8 or 10 popping out stands this far off the touchline. [FH]'),
 ('concept', 'rest-defense', 'reach_m', 15, 'm', 'G5.0: a mate in the channel within this along the field already holds the width. [FH]'),
 ('concept', 'inverted-fullback', 'inside_m', 2, 'm', 'G5.0: the full-back stands at least this far inside his direct opponent. [FH]'),
 ('concept', 'lose-your-marker', 'free_m', 4, 'm', 'G5.0: the front five take the first direction, in order, giving this much room. [FH]'),
 ('concept', 'open-closed-ball', 'pressure_m', 3, 'm', 'G5.0: an opponent this close to the carrier closes the ball. [FH]'),
 ('concept', 'lose-your-marker', 'wide_first', 0, 'flag', 'G5.0: 1 = the model''s full-backs unmark toward the touchline first. [FH]')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- Every top-level model asks for the read: any good team does it (mig 762).
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, 185, CASE WHEN m.name = 'Curriculum' THEN 100 ELSE 90 END,
       'G5.0: a read, not a style — every coach asks for it [FH].'
  FROM game_models m
 WHERE m.parent_id IS NULL
ON CONFLICT (model_id, concept_id) DO NOTHING;

INSERT INTO game_models (name, kind, parent_id, formation_code, note)
SELECT 'Lighthouse APSL — preventive marking', 'team', p.id, '4-3-3',
       'Lighthouse APSL, third tactic: 4, 5, 6, 2 and 3 goal-side of their direct opponents while we attack; the 2 and 3 never wider than theirs; the front five read open or closed ball; width from the 7 and 11, the 8 and 10 popping out (James 10/30).'
  FROM game_models p
 WHERE p.name = 'Lighthouse APSL'
   AND NOT EXISTS (SELECT 1 FROM game_models g WHERE g.name = 'Lighthouse APSL — preventive marking');

INSERT INTO game_model_concept_params (model_id, concept_id, param, value, unit, citation)
SELECT m.id, 70, 'gap_m', 3, 'm', 'G5.0 first number, to be coached from the live game [FH].'
  FROM game_models m WHERE m.name = 'Lighthouse APSL — preventive marking'
ON CONFLICT DO NOTHING;

-- The position's job. 4, 5 and 6 carry the model's rest-defense; the front
-- five don't; the full-backs don't overlap or hold the touchline.
INSERT INTO game_model_role_concepts (model_id, role, concept_id, demand, citation)
SELECT m.id, v.role, v.concept_id, v.demand, v.cit
  FROM game_models m, (VALUES
   ('eight', 70, 0, 'Goes forward: the 8 and 10 (James 10/30).'),
   ('ten', 70, 0, 'Goes forward (James 10/30).'),
   ('wide-forward', 70, 0, 'Goes forward and holds the width (James 10/30).'),
   ('nine', 70, 0, 'Goes forward (James 10/30).'),
   ('full-back', 41, 0, 'Never wide of his direct opponent, so no overlap (James 10/30).'),
   ('full-back', 13, 0, 'Width comes from the 7, 11 and the 8 and 10 popping out (James 10/30).')
  ) AS v(role, concept_id, demand, cit)
 WHERE m.name = 'Lighthouse APSL — preventive marking'
ON CONFLICT DO NOTHING;

-- James 10/30: "ukies should look to get 2,3 wide during unmark".
INSERT INTO game_model_concept_params (model_id, concept_id, param, value, unit, citation)
SELECT m.id, 159, 'wide_first', 1, 'flag', 'The Ukies full-backs unmark toward the touchline (James 10/30).'
  FROM game_models m WHERE m.name = 'Ukrainian Nationals'
ON CONFLICT DO NOTHING;

-- James 10/30: "i want to try a new tactic for lh".
UPDATE game_demo_teams SET game_model = 'Lighthouse APSL — preventive marking' WHERE name = 'Lighthouse APSL';

-- Flank bug: both teams carry 7 on one touchline and 11 on the other (the
-- away team isn't mirrored in y), so 2:7, 3:11, 7:2 and 11:3 paired men on
-- opposite touchlines: our 3 marked a man the width of the pitch away.
-- James 10/30: "fix that bug". Number by where they stand: each pairs across
-- the same touchline.
UPDATE game_direct_opponents
   SET opponent_number = CASE number WHEN 2 THEN 11 WHEN 3 THEN 7 WHEN 7 THEN 3 WHEN 11 THEN 2 END
 WHERE number IN (2, 3, 7, 11);

COMMIT;
