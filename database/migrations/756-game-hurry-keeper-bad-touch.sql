-- 756 (2026-10-27) — game: hurry the keeper (178) and press the bad touch
-- (179) (game/DESIGN.md §8.71, G4.73).
--
-- James 10/27: "in any system we will go after their keeper or press on bad
-- touch etc or just drop. that is more of a game model thing." / "the norm
-- is go after if you think you can hurry a pass. if not drop." / "then also
-- if bad touch that is almost universal to press" / "can we get these in as
-- concepts?"
--
-- Both core: every side plays them at its own quality (default demand 100);
-- a game model can ask more or less. Their keeper is nobody's mark any more.

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (178, 'hurry-the-keeper', 'Hurry the keeper (or drop)', 'individual', 'out_of_possession', 'core', 'u14', 'wired',
  'Their keeper has it, or a back pass is going to him: if you can get to him before he''s ready to play, go — on the line to his nearest man. If you can''t, drop.',
  'Chases a keeper he can''t reach (and leaves his man), or stands off one he could have hurried.',
  (SELECT id FROM game_principles WHERE code = 'op-pressure')),
 (179, 'press-the-bad-touch', 'Press the bad touch', 'individual', 'out_of_possession', 'core', 'u10', 'wired',
  'One of theirs miscontrols it: you''re nearest — go, now.',
  'Watches the loose ball he could have won.',
  (SELECT id FROM game_principles WHERE code = 'op-pressure'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT c, id, cite FROM game_sources, (VALUES
  (178, 'fh', 'James 10/27: "the norm is go after if you think you can hurry a pass. if not drop."'),
  (179, 'fh', 'James 10/27: "if bad touch that is almost universal to press"')
) AS v(c, code, cite)
WHERE game_sources.code = v.code
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'hurry-the-keeper', 'hurry_m', 3::numeric, 'm', 'Within this of the keeper he''s hurried.'),
 ('concept', 'hurry-the-keeper', 'settle_s', 1.5, 's', 'The keeper is ready to play this long after he has it (a back pass: its flight first).'),
 ('concept', 'press-the-bad-touch', 'window_s', 1, 's', 'The loose ball off their bad touch is pressed for this long.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);
