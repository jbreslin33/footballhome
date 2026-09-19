-- 388 — The 9/19 Liga 1 (CASA) game was filed under the APSL team.
--
-- Owner 2026-09-19: "for the casa game it should not say apsl anywhere."
-- The calendar event says Team: Liga 1 and fh_event_teams agrees (120),
-- but match 9274 still had home_team_id = 35: the event was first tagged
-- APSL, a lineup was set, and fh_event_team_create_match deliberately
-- will not move a match that already has lineup rows.  So #game-center
-- and every Instagram graphic printed "Lighthouse Mens Club APSL" on a
-- CASA game.  All 22 lineup players are on team 120's roster, so the
-- match, its lineup rows and its one draft post move across together.
UPDATE matches SET home_team_id = 120
 WHERE id = 9274 AND home_team_id = 35
   AND EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id
                WHERE fe.match_id = 9274 AND fet.team_id = 120);

UPDATE match_lineups SET team_id = 120
 WHERE match_id = 9274 AND team_id = 35
   AND EXISTS (SELECT 1 FROM matches m WHERE m.id = 9274 AND m.home_team_id = 120);

UPDATE social_posts SET team_id = 120
 WHERE match_id = 9274 AND team_id = 35
   AND EXISTS (SELECT 1 FROM matches m WHERE m.id = 9274 AND m.home_team_id = 120);
