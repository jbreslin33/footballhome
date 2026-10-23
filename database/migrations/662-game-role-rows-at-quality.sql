-- 662 (2026-10-23) — game: no more inflated ability rows, for any team.
--
-- James: "lets fix the inflated rows from coming back on any team player".
-- Since mig 652 a player plays min(demand, ability): the team's game model
-- asks for man-marking, the line step and the cover. The lineup roles
-- (mig 639/642, GameRoster::afterLineup) still wrote ABILITY rows — marking
-- / man-mark 90 for every outfielder, line-step 68 for everyone, cover 95 /
-- libero 95 for the free CB, cover-shadow 90 for the 9 — so a 60-rated squad
-- played like a 90 one (fh-game-match: 39-12-9 vs the 71-rated Ukies; at
-- their own quality 5-9-46; DESIGN §8.38). The backend now writes only WHO
-- holds a role, at the player's own quality; this converts the rows already
-- there, for every team.
DELETE FROM game_demo_player_concepts
 WHERE (concept IN ('marking', 'man-mark') AND rating > 0)
    OR concept IN ('line-step', 'cover');
UPDATE game_demo_player_concepts c
   SET rating = COALESCE(p.quality, t.quality, 68)
  FROM game_demo_players p JOIN game_demo_teams t ON t.id = p.team_id
 WHERE p.team_id = c.team_id AND p.shirt = c.shirt
   AND c.concept IN ('libero', 'cover-shadow') AND c.rating > 0;
