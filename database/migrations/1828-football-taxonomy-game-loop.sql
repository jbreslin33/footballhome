-- 1828 (2026-11-24): 🧬 Taxonomy of Football — 🎮 the concept in the game, with a live demo.
--
-- Owner 11/24: "engine ashould talk about and demo how its used. would be awesome to show the
-- players moving and demonstrating the concept in a popup game on a loop" · "the popup game
-- shold run the engine full" · "loop the concept wihg full engine running off and def etc".
-- The 🎮 chip opens a sheet (what the engine does with the concept) with ▶ a popup window on
-- the live match, /game.html?concept=<id>: the whole engine, both sides; each time the BRAIN
-- feed names the concept on a player those seconds replay on a loop (frontend/js/game/client.js).
-- The popup's bar takes its words from here, through the page.  Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('game sheet: title ({title})', 'game_title', '🎮 {title} — in the game', 170),
    ('game sheet section: watch', 'game_s_watch', 'Watch it', 171),
    ('game sheet: watch button', 'game_watch', '▶ Watch it in the game, on a loop', 172),
    ('game sheet: what the popup does', 'game_watch_note', 'Opens the live match in its own window — the whole engine, both sides, attack and defence. Each time a player does this, those few seconds replay on a loop with his label on, while the match carries on underneath and more examples queue up.', 173),
    ('game sheet: the engine does not say when', 'game_watch_unreported', 'Opens the live match in its own window — the whole engine, both sides. The engine plays this but does not yet say which player is doing it and when, so there is nothing to cut a loop on: you watch the match itself.', 174),
    ('game sheet section: how the engine uses it', 'game_s_how', 'How the engine uses it', 175),
    ('loop bar: waiting for the first example', 'loop_waiting', 'Live match — waiting for a player to do this…', 180),
    ('loop bar: the engine does not report this concept', 'loop_unreported', 'Live match. The engine does not yet say when a player is doing this, so there is no loop.', 181),
    ('loop bar: a clip looping ({player} {i} {n})', 'loop_example', '🔁 {player} — example {i} of {n}', 182),
    ('loop bar: watching live ({n})', 'loop_live', 'Live match — {n} examples ready', 183),
    ('loop bar: previous example', 'loop_prev', '‹ Earlier', 184),
    ('loop bar: next example', 'loop_next', 'Later ›', 185),
    ('loop bar: go to the live match', 'loop_go_live', 'Watch live', 186),
    ('loop bar: back to the loop', 'loop_go_loop', '🔁 Loop', 187)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

UPDATE message_templates SET body = 'The engine plays this in a match. Tap for what it does and to watch it.'
 WHERE kind = 'taxonomy' AND tier = 'where_game_tip';
