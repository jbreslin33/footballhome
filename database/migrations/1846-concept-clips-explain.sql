-- 1846 (2026-11-24): 🎬 the concept clip viewer explains the concept three ways.
--
-- Owner 11/24: "the popup needs to explain also what the concept is in real life, the game
-- and the engine code".  The side panel gets a second tab beside the state machine:
--   ⚽ in real football   the catalogue row — what you see and the answer, what it looks like
--                        without it, its principle, who it is taught from, how it relates
--   🎮 in the game        what the sim does with it today (its behaviours), and whether the
--                        sim uses it or it sits at zero
--   ⚙️ in the engine code  the class and its parents, where it is, what the code says about
--                        itself, and the code
-- Words only; the content is the taxonomy's own rows.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('tab: state machine', 'clip_tab_machine', '🧠 State machine', 230),
    ('tab: what it is', 'clip_tab_explain', '📖 What it is', 231),
    ('section: real football', 'clip_x_real', '⚽ In real football', 232),
    ('real: cue and answer', 'clip_x_cue', 'What you see → what you do', 233),
    ('real: without it', 'clip_x_lacking', 'Without it', 234),
    ('real: principle ({p})', 'clip_x_principle', 'Principle: {p}', 235),
    ('real: taught from ({a})', 'clip_x_taught', 'Taught from: {a}', 236),
    ('real: sources ({n})', 'clip_x_sources', 'Coaching sources behind it: {n}', 237),
    ('section: the game', 'clip_x_game', '🎮 In the game', 238),
    ('game: the sim uses it', 'clip_x_used', 'The sim plays this in every match.', 239),
    ('game: built, at zero', 'clip_x_zero', 'Built and tested, but no side in the sim uses it yet (it is at zero).', 240),
    ('game: nothing', 'clip_x_nogame', 'The engine does not do this yet. It is football waiting to be used.', 241),
    ('game: built in ({tag})', 'clip_x_built', 'Built in {tag}', 242),
    ('section: the code', 'clip_x_code', '⚙️ In the engine code', 243),
    ('code: no code', 'clip_x_nocode', 'No engine code for this yet.', 244),
    ('code: where ({file}, {line})', 'clip_x_where', '{file}, line {line}', 245),
    ('code: class chain label', 'clip_x_chain', 'Class', 246),
    ('code: a function, not a class ({symbol})', 'clip_x_func', 'A function, not a class of its own: {symbol}', 247),
    ('code: show', 'clip_x_show', 'Show the code', 248),
    ('code: hide', 'clip_x_hide', 'Hide the code', 249),
    ('code: unavailable', 'clip_x_nosrc', 'The code is not available to this account.', 250)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
DELETE FROM message_templates WHERE kind = 'taxonomy' AND tier = 'clip_engine';   -- the header line it fed is the 🎮 section now

-- "and the animation should show exactly what is happening": the clip narrates itself — a
-- tag over the player with the state he is in, a caption under the pitch (the state, what it
-- means, who has the ball, the gap and whether he is closing), and a short freeze each time
-- his state changes.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — caption: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('who and what ({num}, {player}, {state})', 'cap_line', '#{num} {player} — {state}', 260),
    ('state change flash ({state})', 'cap_now', 'NOW → {state}', 261),
    ('ball with a player ({num}, {player})', 'cap_ball_with', '⚽ with #{num} {player}', 262),
    ('ball loose', 'cap_ball_loose', '⚽ loose — nobody has it', 263),
    ('gap ({d}, {num})', 'cap_gap', '{d} m from #{num}', 264),
    ('gap: closing', 'cap_closing', 'closing him down', 265),
    ('gap: opening', 'cap_opening', 'the gap is growing', 266),
    ('gap: steady', 'cap_steady', 'holding that distance', 267)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
