-- 1789 (2026-11-24): 🎓 Teaching room — the page's words and the board's button.
--
-- Owner 11/24: "i want a teaching room/sandbox that does not touch game" · "the
-- sandbox/teaching room uses the game engine right though? maybe it extends the
-- classes" · "i would rather the game screen stay pure sim of premier league".
--
-- /teach.html?plan=<tactic_plans.id> opens a private room on the game daemon
-- (game/src/teach/TeachingServer, a GameServer child; docs/teaching-room.md):
-- their side is the engine's own Premier League build-out from a goal kick, ours
-- stand where their JOBS on the 🎯 Tactics board put them, solved live by
-- shared/tactics/TacticGeometry.hpp.  The live match is untouched.
--
-- Copy only: the button on Calendar → Game Center 🎯 Tactics (kind 'tactics',
-- tiers teach / teach_href) and every word on the page (kind 'teach').  The two
-- sides are game_demo_teams names; both line up in the plan's own formations,
-- so the names choose the kits and the players, nothing else.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Game Center', v.l, v.k, v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('Game Center — 🎯 Tactics: watch this plan play in the teaching room', 'tactics', 'teach', '🎓 Watch it play', 1254),
    ('Game Center — 🎯 Tactics: the teaching room link ({plan} = tactic_plans.id, {us} / {them} = the two formations, {block} = block height)',
     'tactics', 'teach_href', '/teach.html?plan={plan}&us={us}&them={them}&block={block}', 1255),
    ('Teaching room — page title', 'teach', 'title', '🎓 Teaching room', 1260),
    ('Teaching room — the match-up line ({us} / {them} = formations, {block} = block height)', 'teach', 'matchup', '{us} pressing · {them} building out · {block} block', 1261),
    ('Teaching room — our side (game_demo_teams.name)', 'teach', 'us_team', 'Lighthouse', 1262),
    ('Teaching room — their side (game_demo_teams.name)', 'teach', 'them_team', 'West Ham United', 1263),
    ('Teaching room — back to the board', 'teach', 'back', '‹ Back', 1264),
    ('Teaching room — step button', 'teach', 'step', '⏭ Next pass', 1265),
    ('Teaching room — play button', 'teach', 'play', '▶ Play on', 1266),
    ('Teaching room — pause button', 'teach', 'pause', '⏸ Freeze', 1267),
    ('Teaching room — start over', 'teach', 'restart', '↺ Goal kick again', 1268),
    ('Teaching room — speed label', 'teach', 'speed', 'Speed', 1269),
    ('Teaching room — status: opening', 'teach', 'st_connecting', 'Opening the room…', 1270),
    ('Teaching room — status: the room would not open', 'teach', 'st_closed', 'The room closed. Tap ↺ to open it again.', 1271),
    ('Teaching room — status: their goal kick', 'teach', 'st_goal_kick', 'Their goal kick. Everyone on his job.', 1272),
    ('Teaching room — status: their man has it ({n} = his number)', 'teach', 'st_with', 'Ball with their #{n}', 1273),
    ('Teaching room — status: the pass is travelling', 'teach', 'st_flight', 'The ball is travelling — we move while it does', 1274),
    ('Teaching room — status: we won it ({n} = our number)', 'teach', 'st_ours', 'Our #{n} won it', 1275),
    ('Teaching room — status: dead ball', 'teach', 'st_dead', 'Ball out of play', 1276),
    ('Teaching room — the jobs list heading', 'teach', 'jobs_title', 'Who does what', 1277),
    ('Teaching room — a job''s man ({n} = their number)', 'teach', 'job_on', 'their #{n}', 1278),
    ('Teaching room — a man off his plan job (chasing a loose ball, cutting out a pass)', 'teach', 'job_engine', 'goes for the ball', 1279),
    ('Teaching room — what the room is', 'teach', 'note',
     'Their side is the game engine''s own Premier League build-out — nothing told to it. Ours stand where their jobs on the 🎯 Tactics board put them, worked out live from where their men really are.', 1280),
    ('Teaching room — no plan in the link', 'teach', 'no_plan', 'Open this from a plan on the 🎯 Tactics board.', 1281),
    ('Teaching room — what a room with no plan is (two engine sides)', 'teach', 'note_pl',
     'Both sides are the game engine''s own Premier League sides — nothing told to either. Freeze a moment and 📋 copy it to the 🎯 Tactics board.', 1282),
    ('Teaching room — copy a frozen moment to the board', 'teach', 'copy', '📋 Copy to our tactics', 1283),
    ('Teaching room — copying', 'teach', 'copy_busy', '📋 Copying…', 1284),
    ('Teaching room — copied ({us} / {them} = formations, {block} = block height)', 'teach', 'copy_done', '📋 Copied: {us} v {them}, {block} block', 1285),
    ('Teaching room — copy failed ({why} = the reason)', 'teach', 'copy_fail', '📋 Not copied: {why}', 1286)
  ) AS v(l, k, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);

-- The 🎮 3D trainer button (mig 1200) opened a practice room inside game.html.  The game
-- page is the pure sim now (owner 11/24: "it should be minimal options in the game its a
-- sim right and should just play"), so the same two Premier League sides open in the
-- teaching room page instead — no plan, both sides the engine's own, 📋 copy included.
UPDATE message_templates
   SET body = '/teach.html?us_team=Arsenal&them_team=West%20Ham%20United',
       label = 'Game Center — 🎯 Tactics: the PL trainer link (teach.html, us_team / them_team = game_demo_teams.name; them takes the goal kick)'
 WHERE kind = 'tactics' AND tier = 'trainer_href' AND body LIKE '/game.html?trainer=1%';
UPDATE message_templates SET body = '🎮 PL sides'
 WHERE kind = 'tactics' AND tier = 'trainer' AND body = '🎮 3D trainer';
