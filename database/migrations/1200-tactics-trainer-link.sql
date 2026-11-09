-- 1200 (2026-11-09): 🎯 Tactics — 🎮 3D trainer link on the Tactics panel.
--
-- The game session built the tactics trainer (docs/tactics-trainer.md,
-- game ee3ee2ae): /game.html?trainer=1&home=<team>&away=<team>&gk=home|away
-- opens a private room, paused on the goal kick, two Premier League 15/16
-- sides (game_demo_teams.name), live match untouched.  Owner: PL sides
-- teach; Lighthouse out of scope — so the link names PL sides, never the
-- live match's teams.  Default: West Ham United (4-3-3, the shape the board's
-- plans face) on the goal kick v Arsenal; the viewer re-picks in the game.
-- Change the teams by editing trainer_href.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Game Center', v.l, 'tactics', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('Game Center — 🎯 Tactics: open the 3D tactics trainer (PL sides)', 'trainer', '🎮 3D trainer', 1252),
    ('Game Center — 🎯 Tactics: the 3D trainer link (game.html ?trainer=1, teams = game_demo_teams.name, gk = whose goal kick)', 'trainer_href',
     '/game.html?trainer=1&home=Arsenal&away=West%20Ham%20United&gk=away', 1253)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
