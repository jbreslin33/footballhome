-- 521 (2026-10-05) — CASA: a score a manager entered counts before the game
-- is marked final.  Owner, looking at the first score chase (mig 520):
-- "wait aren't some of the scores in se already?" — 5 of the 8 games of
-- Oct 4 had a score in the SportsEngine feed but still status "scheduled",
-- and LeagueFixtureSync kept a score only for a "completed" game.  The sync
-- now keeps any score on a game that is not called off; the pages show it
-- with this tag until SportsEngine has the game as completed, and the table
-- counts it.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'CASA', 'CASA scores — score entered, game not marked final', 'casa', 'scores_not_final', NULL, 'not final', 41, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'casa' AND tier = 'scores_not_final');
