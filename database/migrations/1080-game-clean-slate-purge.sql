-- 1080 — Game G5.22 (game/DESIGN.md §8.120): the clean slate's database side.
--
-- James 11/5: "we need to again purge old stuff and start anew" — keep the
-- concept catalogue (knowledge, no code), the attribute list, the Premier League
-- 2015/16 model; purge the coach-style models, every model demand, and the
-- derived (made-up) player attribute values (to be re-derived from each PL
-- player's own 2015/16 StatsBomb events).
--
-- Game tables only. Applied to fh_game_scratch first; the live game DB takes it
-- with the PL team load (as mig 1042).

BEGIN;

-- Mig 762's rule "every top-level model states every concept" enforced the
-- demand model this purge removes: the rule goes with it.
DROP TRIGGER IF EXISTS game_models_complete ON game_models;
DROP TRIGGER IF EXISTS game_model_concepts_complete ON game_model_concepts;
DROP TRIGGER IF EXISTS game_model_ladder_complete ON game_model_ladder;
DROP TRIGGER IF EXISTS game_concepts_models_complete ON game_concepts;
DROP FUNCTION IF EXISTS fh_game_models_complete();

-- The three numbers the receive read carried as concept.meet-the-pass.* move to
-- physics.receive.* (Reads::configure reads both; same values).
INSERT INTO game_model_params (owner, code, param, value, unit, note)
SELECT 'physics', 'receive', param, value, unit,
       'G5.22: was concept.meet-the-pass.' || param || ' (mig 1080)'
FROM game_model_params
WHERE owner = 'concept' AND code = 'meet-the-pass' AND param IN ('horizon_ticks', 'early_s', 'on_line_m')
ON CONFLICT DO NOTHING;

-- Every model's demands, its concept numbers, its role demands, its ladder.
-- The PL model's 186 demands were inherited semi-pro; 108 were read by no code (§8.114).
DELETE FROM game_model_concepts;
DELETE FROM game_model_concept_params;
DELETE FROM game_model_role_concepts;
DELETE FROM game_model_ladder;
DELETE FROM game_role_concepts;

-- The concept classes' own numbers (their code is deleted, §8.120).
DELETE FROM game_model_params WHERE owner = 'concept';

-- The coach-style models (Sacchi, Bielsa, Gegenpress, Mourinho, Simeone, Lobanovskyi,
-- Zeman, Gasperini, De Zerbi, Herrera, Positional Play, Classic 4-2-3-1, U.S. Soccer
-- U17+, Curriculum): only the Premier League 2015/16 model stays.
UPDATE game_models SET parent_id = NULL WHERE parent_id IS NOT NULL;
DELETE FROM game_models WHERE name <> 'Premier League 2015/16';

-- Made-up player numbers: gone until derived from StatsBomb PL 2015/16.
DELETE FROM game_demo_player_attributes WHERE source = 'derived';
DELETE FROM game_demo_player_tendencies;
DELETE FROM game_demo_player_concepts;

COMMIT;
