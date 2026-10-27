-- 754 (2026-10-27) — game: every player listens (or doesn't), and the
-- other calls — man on, turn, time, squeeze, line (game/DESIGN.md §8.69,
-- G4.71).
--
-- James 10/27: "yes we need whether he listens to communicaiton. really for
-- all players. same with the other calls"
--
-- KNOWING = a concept per call (core: every side plays it at its own
-- quality, from the level it's taught at). SAYING = the communication
-- attribute (G4.70). HEARING = the concentration attribute, now wired: the
-- share of calls made to him that he takes in, within the voice's range.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (173, 'call-man-on', 'Call: man on', 'individual', 'in_possession', 'core', 'u10', 'wired',
  'Your teammate has the ball (or it''s coming to him) and a man is closing on him from where he can''t see — tell him: "man on!"',
  'Silent: he turns into the man he didn''t know was there.',
  (SELECT id FROM game_principles WHERE code = 'ip-secure')),
 (174, 'call-turn', 'Call: turn', 'individual', 'in_possession', 'core', 'u10', 'wired',
  'Your teammate has his back to their goal and nobody near him, and he hasn''t looked — tell him: "turn!"',
  'Silent: he plays it back with all the time in the world to turn.',
  (SELECT id FROM game_principles WHERE code = 'ip-progress')),
 (175, 'call-time', 'Call: time', 'individual', 'in_possession', 'core', 'u14', 'wired',
  'Your teammate is facing up with nobody near him and he hasn''t looked — tell him: "time!" — take a touch, look up.',
  'Silent: he rushes a pass he had time to pick.',
  (SELECT id FROM game_principles WHERE code = 'ip-secure')),
 (176, 'call-squeeze', 'Call: squeeze', 'keeper', 'out_of_possession', 'core', 'u14', 'wired',
  'The ball is covered (going backwards, or their man is turned or pressed): you see the whole line — tell it to step up together: "squeeze!"',
  'Silent: half the line steps and half doesn''t, and their man is onside.',
  (SELECT id FROM game_principles WHERE code = 'op-compact')),
 (177, 'call-line', 'Call: line', 'keeper', 'out_of_possession', 'core', 'u14', 'wired',
  'One of the back line has dropped off it and is playing their man onside — tell them: "line!"',
  'Silent: one man deep keeps their runner onside.',
  (SELECT id FROM game_principles WHERE code = 'op-compact'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (176, 28, 'requires'), (177, 9, 'requires')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (173, 'fh', 'James 10/27: "same with the other calls" — man on, turn, time, line, squeeze (CONCEPTS.md queue #3)'),
  (173, 'football-australia', 'FFA: communication is a "constant" — "man on" the first call'),
  (174, 'fh', 'James 10/27: the other calls (CONCEPTS.md queue #3)'),
  (175, 'fh', 'James 10/27: the other calls (CONCEPTS.md queue #3)'),
  (176, 'sacchi', 'the back line steps up together on a covered ball — the organiser calls it'),
  (176, 'fh', 'James 10/27: the other calls (CONCEPTS.md queue #3)'),
  (177, 'fh', 'James 10/27: the other calls (CONCEPTS.md queue #3)')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'call-man-on', 'near_m', 5::numeric, 'm', 'A man this close to ours, out of his sight, is a "man on".'),
 ('concept', 'call-man-on', 'hear_s', 0.3, 's', 'Heard: his picture of that man is this old (plus his perception delay).'),
 ('concept', 'call-turn', 'free_m', 7, 'm', 'Nobody within this of him, back to their goal, and he hasn''t looked: "turn".'),
 ('concept', 'call-turn', 'hear_s', 0.5, 's', 'Heard: his picture behind him is this old (plus his perception delay).'),
 ('concept', 'call-time', 'free_m', 7, 'm', 'Nobody within this of him, facing up, and he hasn''t looked: "time".'),
 ('concept', 'call-time', 'hear_s', 0.5, 's', 'Heard: his picture behind him is this old (plus his perception delay).'),
 ('concept', 'call-squeeze', 'hear_s', 0.5, 's', 'How long the call takes to land (the back line steps the second it''s heard).'),
 ('concept', 'call-line', 'gap_m', 2, 'm', 'A back-line man this far under the line, with one of theirs between him and it: "line".'),
 ('concept', 'call-line', 'hear_s', 0.5, 's', 'How long the call takes to land.'),
 ('physics', 'voice', 'range_m', 40, 'm', 'A call carries this far on a pitch; further, nobody hears it.'),
 ('skill', 'concentration', 'at0_pct', 0, '%', 'A 0-rated listener hears this share of his level''s calls.'),
 ('skill', 'concentration', 'at100_pct', 200, '%', 'A 100-rated listener hears this share of his level''s (capped at every call). 50 = his level exactly.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_attributes
   SET status = 'wired',
       scales = '0-100: the share of calls made to him that he hears — 0 none, 50 his level''s (u10 40%, u14 55%, amateur 70%, semipro 80%, pro 90%, world 95%), 100 double it'
 WHERE code = 'concentration';
