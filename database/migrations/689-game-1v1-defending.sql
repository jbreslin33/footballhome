-- 689 (2026-10-24) — game: 1v1 defending — side-on, and turn and run with
-- him (game/DESIGN.md §8.51, G4.54).
--
-- G4.53 let a body face apart from its travel, but its gait made 90° the
-- slowest way to move (a square shuffle) and every jockeying defender
-- backpedalled square-on — slower than a sprinting dribbler. Real
-- defenders look over their shoulder at no cost (head turn), run side-on
-- with their hips open (a crossover), and drop-step to run WITH a carrier
-- who comes at them at speed. The knowledge sweep (§8.50) named 1v1
-- defending choices the curriculum's biggest gap.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (155, 'side-on-jockey', 'Side-on, show him one way', 'individual', 'out_of_possession', 'core', 'u14', 'wired',
  'Delaying the carrier: stand side-on, body open toward the side you are showing him, so following him that way is a run, not a backpedal.',
  'Square-on, feet level: he can go either side, and whichever he picks you are backpedalling after him.', 7),
 (156, 'drop-step', 'Turn and run with him', 'individual', 'out_of_possession', 'core', 'u14', 'wired',
  'He comes at you at speed: drop-step, open the hips and run with him on the goal-side line — no backpedal holds a sprinting dribbler.',
  'Keeps backpedalling as he accelerates, and is past him in two strides.', 7)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (155, 'fifa-training-centre', 'Talent Coach: Defending in 1v1 — orientation, show the attacker one way'),
  (155, 'fa-england', 'Boot Room: Out of possession — 1v1 emergency defending (side-on, show outside / inside)'),
  (155, 'coaching-standard', 'jockeying points: staggered stance, body at an angle (St. Albert Soccer 1v1 sheet)'),
  (156, 'fa-england', 'Boot Room: 1v1 emergency defending — recover goal-side'),
  (156, 'coaching-standard', 'drop step / hip turn: open the hips by stepping back, turn from facing play to running with it (St. Albert Soccer)'),
  (156, 'fh', 'G4.54: a square backpedal (65% top speed) cannot hold a dribbler at 88% — measured in the engine')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'side-on-jockey', 'stance_deg', 40::numeric, '°', 'How far his body is turned off the carrier, open toward the side he shows.'),
 ('concept', 'drop-step', 'carrier_mps', 4.5, 'm/s', 'The carrier coming at goal at least this fast (and within within_m) → turn and run with him.'),
 ('concept', 'drop-step', 'within_m', 4, 'm', 'How close the carrier is before he turns.'),
 ('concept', 'drop-step', 'lead_m', 2, 'm', 'He runs to a point this far ahead along the carrier''s run, a metre goal-side.'),
 ('physics', 'body', 'head_turn_deg', 60, '°', 'How far a player looks off his line of running at no cost — head and eyes turn, hips stay on the run. Anatomy, shared. [FH] estimate.'),
 ('skill', 'agility', 'run_share_at0', 0.70, 'share', 'Side-on run (hips open, crossover) top speed as a share of forward, at agility 0 — facing 90° off his travel. [FH] estimate; source to pin.'),
 ('skill', 'agility', 'run_share_at50', 0.80, 'share', 'At 50.'),
 ('skill', 'agility', 'run_share_at100', 0.90, 'share', 'At 100.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- G4.53's square side-shuffle at 90° is replaced by the side-on run.
DELETE FROM game_model_params WHERE owner = 'skill' AND code = 'agility' AND param LIKE 'side_share_%';
UPDATE game_attributes
   SET scales = replace(scales, 'side-shuffle 40/50/60%', 'side-on run 70/80/90% (full speed within a 60° head turn)')
 WHERE code = 'agility';

-- When to step in: with cover behind him the nearest defender used to
-- step in on EVERY carrier (the final-third escort tally: press 61-68%,
-- delay never) — the engage half with no judgement.
INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (157, 'engage-or-contain', 'When to step in', 'individual', 'out_of_possession', 'core', 'u14', 'wired',
  'Step in to win it when your cover has arrived, he turns his back, he is pinned on the touchline (or his touch is loose); otherwise contain and delay.',
  'Dives in on every carrier because there are teammates somewhere behind — and is beaten by the first feint.', 7)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 157, id, cite FROM game_sources, (VALUES
  ('fifa-training-centre', 'Talent Coach: Defending in 1v1 — engage when cover arrives / bad touch / back to goal'),
  ('fa-england', 'Boot Room: Out of possession — 1v1 emergency defending (delay, deny, dictate)'),
  ('fh', 'G4.54: final-third tally — nearest defender pressing 61-68%, delaying never')
) AS v(code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'engage-or-contain', 'cover_m', 6::numeric, 'm', 'Cover has ARRIVED: a teammate goal-side of the carrier within this distance of him.'),
 ('concept', 'engage-or-contain', 'touchline_m', 6, 'm', 'Pinned: the carrier within this distance of the touchline.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
