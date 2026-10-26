-- 737 (2026-10-26) — game: what a player can see (game/DESIGN.md §8.64,
-- G4.66; CONCEPTS.md build queue NEXT #2).
--
-- James 10/26 queue: "What a player can see — men BEHIND him are known only
-- as of his last shoulder check; scanning becomes a rated skill. Foundation
-- for communication."
--
-- The body (physics.vision): men within view_half_deg of where he faces —
-- and anyone within feel_m — are seen as they are; the rest are where they
-- were at his last look, never more than max_age_s old. On the ball he
-- plays a mate he can't see only if he looked within blind_pass_s.
-- The skill: two core concepts set how often he looks. scan-before-receive
-- (33, queued since mig 650) is wired: in possession, plus a fresh look
-- while the pass is on its way to him. scan-defending (171) is new: out of
-- possession, checking the runner and his man behind him. A rating of 1
-- looks every every_s_at1, 100 every every_s_at100 [Jordet et al. 2013:
-- the best Premier League midfielders scan ~0.6-0.8 times a second].

UPDATE game_concepts SET status = 'wired' WHERE name = 'scan-before-receive';

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (171, 'scan-defending', 'Check your shoulder when defending', 'individual', 'out_of_possession', 'core', 'u14', 'wired',
  'Don''t only watch the ball: keep looking — where''s my man, who''s running in behind me? Look away from the ball, then back, again and again.',
  'Ball-watches: the runner goes past his back and he never knew he was there.',
  (SELECT id FROM game_principles WHERE code = 'op-mark'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind)
SELECT 171, c.id, 'refines' FROM game_concepts c WHERE c.name IN ('man-mark', 'direct-opponent')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (171, 'coaching-standard', 'scanning when defending: ball, man, space — look away from the ball and back'),
  (171, 'fh', 'James 10/26: men behind him are known only as of his last shoulder check'),
  (33, 'fh', 'James 10/26: scanning becomes a rated skill — how often he looks (G4.66)')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('physics', 'vision', 'view_half_deg', 100::numeric, 'deg', 'Field of view: men within this angle of where he faces are seen as they are (a human sees ~180-200 degrees).'),
 ('physics', 'vision', 'feel_m', 2, 'm', 'A man this close is felt / heard, wherever he is.'),
 ('physics', 'vision', 'max_age_s', 3, 's', 'His picture of the men behind him is never older than this (a man who never looks).'),
 ('physics', 'vision', 'blind_pass_s', 0.5, 's', 'On the ball he plays a mate he can''t see only if he looked within this — no blind ball to where a man used to be.'),
 ('concept', 'scan-before-receive', 'every_s_at1', 5, 's', 'A 1-rated player looks over his shoulder this often in possession.'),
 ('concept', 'scan-before-receive', 'every_s_at100', 1.25, 's', 'A 100-rated player looks this often (~0.8 a second, the best midfielders).'),
 ('concept', 'scan-defending', 'every_s_at1', 5, 's', 'A 1-rated player looks behind him this often out of possession.'),
 ('concept', 'scan-defending', 'every_s_at100', 1.25, 's', 'A 100-rated player looks this often out of possession.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
