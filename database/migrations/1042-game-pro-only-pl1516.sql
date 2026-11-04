-- 1042-game-pro-only-pl1516.sql — the game starts clean: pro only, the 2015/16 Premier League.
--
-- James 11/4: "since we are now modeling that premier league season we should … not have lh
-- but actual teams from that year as the test cases … blow it all up. i believe in fresh clean
-- starts … all teams should be pro right now". Every game-side team that is not one of the 20
-- PL 2015/16 sides goes (Lighthouse APSL, Ukrainian Nationals, Lighthouse XI, the curriculum
-- sides), with their players, the team-kind models (Lighthouse and its variants, the Ukies), and
-- the APSL / CASA records and strength that rated them. The model the PL sides play is renamed
-- from "Semi Pro Standard" to "Premier League 2015/16": its concept demands are inherited and
-- are to be re-derived from PL data only (game/DESIGN.md §8.113).
--
-- Kept: the taxonomy — concepts, techniques, attributes, skills, principles, phases, roles,
-- officials, laws, sources, benchmarks — the global game-model params, formations, and the
-- school / federation / formation models (Bielsa, Sacchi, U.S. Soccer, Curriculum …) as a
-- library no team plays yet. Git and the earlier migrations (628-886) hold everything removed.
--
-- Safe where no PL teams exist (live today): the rename still runs, the deletes leave no game
-- teams, and the daemon falls back to its built-in sandbox squads.
BEGIN;

DELETE FROM game_demo_players
 WHERE team_id IN (SELECT id FROM game_demo_teams WHERE level_band <> 'pro');   -- their rows cascade
DELETE FROM game_demo_teams WHERE level_band <> 'pro';

DELETE FROM game_team_records;
-- game_team_strength is a view over the two: empty with them.
DELETE FROM game_division_quality;

UPDATE game_models
   SET name = 'Premier League 2015/16',
       note = 'The 2015/16 Premier League (all 20 sides, load_pl1516.py). Concept demands inherited '
              'from the semi-pro standard 4-2-3-1 (mig 1042) — to be re-derived from PL data only.'
 WHERE name = 'Semi Pro Standard';

-- Team-kind models (Lighthouse, Lighthouse APSL and its variants, Ukrainian Nationals): no team
-- plays them now. Children and parents go in one statement; ladder / concept rows cascade.
DELETE FROM game_models
 WHERE kind = 'team'
   AND NOT EXISTS (SELECT 1 FROM game_demo_teams t WHERE t.game_model = game_models.name);

COMMIT;
