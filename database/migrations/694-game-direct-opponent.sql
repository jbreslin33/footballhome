-- 694 (2026-10-24) — game: the direct opponent, where to stand on him,
-- and losing him (game/DESIGN.md §8.53, G4.57).
--
-- James: "use lh tactic to tether to ukies … we can mark from behind or
-- cover shadow in front or tuck inside. offense we unmark. in any
-- direction" / "we call it for lh a direct opponent and it's an important
-- concept that goes beyond lh and bielsa" / "the 9's direct opponents are
-- the 4 and 5 and vice versa. that gives the -1, +1. 10:6, 7:2, 3:11, 8:8"
-- / "a universal concept, it's just that the zonal systems move in
-- relation of their zone to mark and unmark".

-- Position numbers on formation slots (2 RB, 3 LB, 4/5 CBs, 6 holding,
-- 8 central, 10 attacking/advanced, 9 striker). 7 = LEFT winger and 11 =
-- RIGHT winger here, so James's pairs 7:2 and 3:11 are face-to-face
-- (our left wing vs their right back) — flip if James numbers otherwise.
ALTER TABLE formation_slot_roles ADD COLUMN IF NOT EXISTS number smallint;
UPDATE formation_slot_roles r SET number = v.n FROM (VALUES
  ('4-3-3', 1, 1), ('4-3-3', 2, 2), ('4-3-3', 3, 5), ('4-3-3', 4, 4), ('4-3-3', 5, 3),
  ('4-3-3', 6, 8), ('4-3-3', 7, 6), ('4-3-3', 8, 10), ('4-3-3', 9, 11), ('4-3-3', 10, 9), ('4-3-3', 11, 7),
  ('4-2-3-1', 1, 1), ('4-2-3-1', 2, 2), ('4-2-3-1', 3, 5), ('4-2-3-1', 4, 4), ('4-2-3-1', 5, 3),
  ('4-2-3-1', 6, 6), ('4-2-3-1', 7, 8), ('4-2-3-1', 8, 11), ('4-2-3-1', 9, 10), ('4-2-3-1', 10, 7), ('4-2-3-1', 11, 9)
) AS v(code, slot, n)
WHERE r.formation_code = v.code AND r.slot = v.slot;

CREATE TABLE IF NOT EXISTS game_direct_opponents (
  number smallint NOT NULL,
  opponent_number smallint NOT NULL,
  note text NOT NULL DEFAULT '',
  PRIMARY KEY (number, opponent_number)
);
COMMENT ON TABLE game_direct_opponents IS
  'Direct opponents by position number (James 10/24): a player numbered `number` takes the nearest opponent numbered `opponent_number`. Two of ours may share one of theirs (the 4 and 5 on their 9: one marks, the free man is the +1); our 9 has two (their 4 and 5: the -1).';
INSERT INTO game_direct_opponents (number, opponent_number, note) VALUES
  (9, 4, 'the 9 between their centre backs — the -1'), (9, 5, 'the 9 between their centre backs — the -1'),
  (4, 9, 'two centre backs on their 9 — one marks, the free man is the +1'), (5, 9, 'two centre backs on their 9 — one marks, the free man is the +1'),
  (10, 6, ''), (6, 10, ''), (7, 2, ''), (2, 7, ''), (3, 11, ''), (11, 3, ''), (8, 8, '')
ON CONFLICT DO NOTHING;

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (158, 'mark-position', 'Where to stand on your man', 'individual', 'out_of_possession', 'core', 'u14', 'wired',
  'Always goal-side of your man; the nearer he is to the ball, the more you step ball-side into the passing line (the cover shadow in front); the further away, the more you tuck in toward the ball and help.',
  'Stands flat behind his man wherever the ball is: beaten by the ball into feet, no help on the far side, the team spread out.', 10),
 (159, 'lose-your-marker', 'Lose your marker', 'individual', 'in_possession', 'core', 'u10', 'wired',
  'Our ball and a defender is on you: move away from him — any direction with more space — staying near your job, so you can receive.',
  'Stands next to his marker waiting for the ball, and the pass to him is never on.', 2),
 (160, 'direct-opponent', 'Your direct opponent', 'individual', 'out_of_possession', 'core', 'u10', 'wired',
  'Know your direct opponent from the matchup. Man-oriented: follow him anywhere. Zonal: he is yours while he is in your zone — pass him on when he leaves it.',
  'Marks whoever is nearest: two defenders on one man, another free, and nobody knows whose he is.', 10)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (158, 'fh', 'James 10/24: "mark from behind or cover shadow in front or tuck inside"'),
  (158, 'coaching-standard', 'ball, man, goal: goal-side and ball-side near the ball, tuck in away from it (US Soccer / FA marking)'),
  (158, 'bielsa', 'man-orientation: deny the ball to your man'),
  (159, 'fh', 'James 10/24: "offense we unmark. in any direction"'),
  (159, 'coaching-standard', 'check away / create a yard of space before receiving'),
  (160, 'fh', 'James 10/24: "we call it a direct opponent … a universal concept; zonal systems move in relation to their zone to mark and unmark"; pairs 9:4/5, 10:6, 7:2, 3:11, 8:8'),
  (160, 'bielsa', 'each man takes his direct opponent; the free man behind (+1)')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'mark-position', 'near_m', 10::numeric, 'm', 'His man within this of the ball: step ball-side into the passing line.'),
 ('concept', 'mark-position', 'far_m', 30, 'm', 'At this far from the ball he is fully tucked in.'),
 ('concept', 'mark-position', 'tuck_share', 0.35, 'share', 'Fully tucked: this share of the way from his man toward the ball.'),
 ('concept', 'lose-your-marker', 'tight_m', 3, 'm', 'A defender this close is on him.'),
 ('concept', 'lose-your-marker', 'step_m', 5, 'm', 'He steps this far to lose him.'),
 ('concept', 'lose-your-marker', 'leash_m', 8, 'm', 'Never further than this from where his job wants him.'),
 ('concept', 'direct-opponent', 'zone_m', 12, 'm', 'Zonal: his direct opponent is his while within this of where his zone puts him.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
