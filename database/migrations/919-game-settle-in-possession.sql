-- 919 (2026-10-31) — game: settle in possession, counter or keep (G5.1,
-- game/DESIGN.md §8.99).
--
-- With the ball just past halfway a pro side has 5.3 mates ahead of it (Euro
-- 2020 / World Cup 2022 freeze frames, benchmarks_statsbomb_rest.py); ours had
-- 1.8. Given time the team does get up (3.7 in a 30 s spell), but 91% of our
-- time there is in spells under 15 s: the ball goes in behind before anyone
-- arrives. Both concepts were in the taxonomy, queued, with no taught_from,
-- so nobody could know them.

BEGIN;

UPDATE game_concepts
   SET status = 'wired', taught_from = COALESCE(taught_from, 'amateur'),
       cue_answer = 'On the ball, not pressed, the team stretched behind you: no ball in behind. Play what is in front of their line or walk it, until everyone is up.'
 WHERE id = 89 AND name = 'settle-in-possession';

UPDATE game_concepts
   SET status = 'wired', taught_from = COALESCE(taught_from, 'u14')
 WHERE id = 140 AND name = 'counter-or-keep';

INSERT INTO game_concept_sources (concept_id, source_id, citation)
SELECT 89, s.id, 'U.S. Soccer U17+ "minimum 5 ahead of the ball"; StatsBomb 360 freeze frames for the pro numbers (G5.1). FH wiring.'
  FROM game_sources s WHERE s.code = 'fh'
ON CONFLICT DO NOTHING;

INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT v.* FROM (VALUES
 ('concept', 'settle-in-possession', 'ahead_min', 5::numeric, 'men', 'G5.1: fewer mates than this ahead of the ball and the team is stretched. U.S. Soccer U17+ "minimum 5 ahead of the ball"; pro mean 5.3 just past halfway, 3.7 from 40 to 20 yd out.'),
 ('concept', 'settle-in-possession', 'until_m', 20, 'm', 'G5.1: this close to their goal nobody settles: pro mean 1.4 mates ahead in the last 20 yd. [FH]')
) AS v(owner, code, param, value, unit, note)
WHERE NOT EXISTS (SELECT 1 FROM game_model_params g WHERE g.owner = v.owner AND g.code = v.code AND g.param = v.param);

-- Both sides in the real matchup. Bielsa's school row stays 20: it is his
-- verticality; Lighthouse APSL states its own.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, 89, 80, 'G5.1: first number, to be coached from the live game [FH].'
  FROM game_models m WHERE m.name IN ('Lighthouse APSL', 'Semi Pro Standard')
ON CONFLICT (model_id, concept_id) DO UPDATE SET demand = EXCLUDED.demand, citation = EXCLUDED.citation;

COMMIT;
