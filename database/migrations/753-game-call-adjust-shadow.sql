-- 753 (2026-10-27) — game: communication, first call — the full-back tells
-- our winger to adjust his cover shadow (game/DESIGN.md §8.68, G4.70).
--
-- James 10/26: "the full back would communicate to the winger the cover
-- shadow adjustment"; CONCEPTS.md queue #3: KNOWING the call (a concept per
-- call), SAYING it (the communication attribute), HEARING it (the
-- listener's picture refreshes after a short delay).

INSERT INTO game_concepts (id, name, title, family, moment, kind, taught_from, status, cue_answer, lacking, principle_id) VALUES
 (172, 'call-adjust-shadow', 'Call: adjust your shadow', 'individual', 'out_of_possession', 'style', 'amateur', 'wired',
  'You are playing off their winger and you can see him; our winger shadowing the line has him behind him. Tell him where he is so he can move the shadow.',
  'Silent: our winger shadows where their winger used to be, and the ball down the line is open.',
  (SELECT id FROM game_principles WHERE code = 'op-press-team'))
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_concept_links (concept_id, other_id, kind) VALUES
 (172, 170, 'requires'), (172, 169, 'refines')
ON CONFLICT DO NOTHING;

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 172, id, 'James 10/26: "the full back would communicate to the winger the cover shadow adjustment" — Lighthouse''s own'
  FROM game_sources WHERE code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'call-adjust-shadow', 'hear_s', 0.5::numeric, 's', 'Heard: the winger''s picture of their winger is this old (plus his own perception delay) instead of as old as his last look.'),
 ('skill', 'communication', 'at0_pct', 0, '%', 'A 0-rated communicator makes this share of his level''s calls.'),
 ('skill', 'communication', 'at100_pct', 200, '%', 'A 100-rated communicator makes this share of his level''s calls (capped at every call). 50 = his level exactly.')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

UPDATE game_attributes
   SET status = 'wired',
       scales = '0-100: the share of due calls he makes — 0 none, 50 his level''s (u10 20%, u14 40%, amateur 55%, semipro 70%, pro 85%, world 95%), 100 double it'
 WHERE code = 'communication';

-- Tactic B: the full-back playing off is the one who sees their winger.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, 172, 90, 'The full-back tells our winger to adjust his shadow (James 10/26).'
  FROM game_models m WHERE m.name = 'Lighthouse APSL — shadow the line'
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;
