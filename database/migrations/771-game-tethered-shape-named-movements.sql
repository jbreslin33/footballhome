-- 771 (2026-10-27) — game: semi-pros stay on their position; the named
-- ways off it — the full-back's overlap (41), the winger coming short
-- (182), the midfielder checking in (183); braking to arrive
-- (game/DESIGN.md §8.77, G4.80).
--
-- James 10/27: "guys are just over running the ball and look like the are
-- on skates lol" and "semi pro players also don't bunch up like we are
-- seeing. they are 'lazy' unlike little kids. unless they are told to
-- rotate or its in ther profile or game model they tend to stay tethered
-- to position. there are exceptions a winger droppping down a mid checking
-- in. a full making an overlap.. put them in"
--
-- The ball pull on the shape (the kids' swarm) is 0 from semi-pro up in
-- code (Levels.hpp shape_pull_pct); with the ball the shape itself moves up
-- (physics.shape.ours_*). These rows are the exceptions, each a
-- core concept a level knows and every top-level model asks for (mig 762:
-- a new concept names every root's demand).

BEGIN;

UPDATE game_concepts SET status = 'wired', taught_from = 'amateur'
 WHERE id = 41 AND name = 'overlap';

INSERT INTO game_concepts (id, name, title, family, moment, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (182, 'winger-come-short', 'Winger: come short for it', 'individual', 'in_possession', 'amateur', 'wired',
  'Our ball deep on your side and you''re 18 m beyond it: come back on your line to 10 m in front of it and give the full-back the pass.',
  'Stays high on the touchline while the full-back has nobody to give it to.',
  (SELECT id FROM game_principles WHERE code = 'ip-build-up')),
 (183, 'mid-check-in', 'Check in to the ball', 'individual', 'in_possession', 'u14', 'wired',
  'A man is on you and the ball is far behind you: come to it, 8 m from the carrier on the line between you — his marker follows or you turn.',
  'Stands marked out of the game, waiting for a pass that can''t come.',
  (SELECT id FROM game_principles WHERE code = 'ip-build-up'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT v.cid, s.id, v.cit FROM (VALUES
 (41, 'fh', 'James 10/27: "a full making an overlap.. put them in"'),
 (182, 'fh', 'James 10/27: "a winger droppping down"'),
 (183, 'fh', 'James 10/27: "a mid checking in"'),
 (183, 'us-soccer-u17', 'Check away, then check to the ball (run-check).')
) AS v(cid, code, cit) JOIN game_sources s ON s.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'overlap', 'ahead_m', 8::numeric, 'm', 'The full-back runs to this far beyond the wide man on the ball.'),
 ('concept', 'overlap', 'wide_m', 4, 'm', '… this far in from the touchline (around the OUTSIDE of him).'),
 ('concept', 'overlap', 'infield_m', 8, 'm', 'Only while the wide man is at least this far infield of the touchline (outside him is free).'),
 ('concept', 'overlap', 'from_halfway_m', 5, 'm', 'Only with the ball no more than this far short of halfway.'),
 ('concept', 'winger-come-short', 'ahead_m', 10, 'm', 'The winger comes to this far in front of the ball, on his own line.'),
 ('concept', 'winger-come-short', 'gap_m', 18, 'm', 'Only when he is this far or more beyond the ball (our ball in our half, on his side).'),
 ('concept', 'mid-check-in', 'show_m', 8, 'm', 'He shows this far from the carrier, on the line between them.'),
 ('concept', 'mid-check-in', 'far_m', 14, 'm', 'Only when the ball is this far or more from him, behind him.'),
 ('concept', 'mid-check-in', 'tight_m', 4, 'm', 'Only when an opponent is this close to him (he is marked).'),
 ('physics', 'body', 'arrive_decel_mps2', 4.5, 'm/s²', 'A player plans his arrival on this deceleration: he runs no faster than he can still stop from, v ≤ √(2·b·d) [Reynolds arrive; soccer decelerations past −3 m/s² are high intensity, maxima −5 to −8 — Harper, Carling & Kiely 2019].'),
 ('physics', 'body', 'arrive_through_mps', 3, 'm/s', 'The speed he still has on reaching a ball he is running onto (meets it moving, under control).'),
 ('physics', 'shape', 'ours_slope', 0.45, '', 'In possession the shape''s middle stands at this × the ball''s x (attack direction) + ours_offset_m — the block moves up with its own ball [FH; team centroids move in phase with the ball — Frencken et al. 2011].'),
 ('physics', 'shape', 'ours_offset_m', 2, 'm', 'In possession: the shape''s middle with the ball on halfway, this far into their half.'),
 ('physics', 'shape', 'ours_depth_k', 1.4, '', 'In possession the lines'' spacing of the kick-off shape × this (4-3-3: ~38 m back line to front).'),
 ('skill', 'deceleration', 'brake_tau_s_at0', 0.5, 's', 'How fast his braking bites at deceleration 0 — speed falls on this, not on his sprint τ.'),
 ('skill', 'deceleration', 'brake_tau_s_at50', 0.35, 's', 'At 50: from 8 m/s he is stopped in ~1.3 s and ~5 m (was a ~9 m glide on τ 1.1).'),
 ('skill', 'deceleration', 'brake_tau_s_at100', 0.25, 's', 'At 100.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- Every top-level model says what it asks. The overlap is Bielsa's and
-- Gasperini's full-back game [Bielsa-Leeds f52]; the Curriculum teaches
-- everything; the rest ask for the ordinary semi-pro amount.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id,
       CASE WHEN m.name = 'Curriculum' THEN 100
            WHEN c.id = 41 AND m.name IN ('Bielsa', 'Gasperini') THEN 90
            WHEN m.name = 'Lighthouse' THEN 80
            WHEN c.id = 183 THEN 70
            ELSE 60 END,
       'G4.80: James 10/27 — the named ways off a position.'
  FROM game_models m CROSS JOIN (VALUES (41), (182), (183)) AS c(id)
 WHERE m.parent_id IS NULL
ON CONFLICT (model_id, concept_id) DO NOTHING;

COMMIT;
