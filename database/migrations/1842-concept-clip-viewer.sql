-- 1842 (2026-11-24): 🎮 the concept clip viewer — a concept shown so it cannot be missed.
--
-- Owner 11/24, of the first popup (the live 3D match with one small label): "its trash lol.
-- can't tell what is happening. it should show the concept so clear!!!" · "i should be able
-- to hit replay to see the example again. it should be clear what example i am on" · "i
-- should be able run it in slow mo … or sped up" · "i should see the full state machine on
-- side for that player(s) in the concept".
--
-- /concept.html?concept=<game_concepts id> (frontend/js/teach/concept.js) replaces
-- game.html?concept=: top-down and zoomed on the player and the man he is acting on, the
-- rest dimmed, his path and where he is heading drawn, the metres between them, BEFORE /
-- DOING IT / AFTER, a freeze where it starts; each example plays once and stops; ↺ Replay,
-- ‹ Previous / Next ›, "Example 2 of 5", ⅛× … 2×; and beside it the player's state machine.
--
-- For that panel the engine's vocabulary (game_engine_terms, mig 1810) learns two things the
-- page needs to read a BRAIN frame: wire_index — a decision's number on the wire (ai::Why) —
-- and parent — the player state a decision belongs to.  The match sends each man's decision
-- and concept, not his state; the panel works the state out from these until the engine
-- reports it.
ALTER TABLE game_engine_terms ADD COLUMN IF NOT EXISTS wire_index smallint;
ALTER TABLE game_engine_terms ADD COLUMN IF NOT EXISTS parent text;
UPDATE game_engine_terms t SET wire_index = v.i, parent = v.p
  FROM (VALUES
    ('hold', 0, 'hold_block'), ('shoot', 1, 'on_ball'), ('pass', 2, 'on_ball'), ('cross', 3, 'on_ball'),
    ('dribble', 4, 'on_ball'), ('clear', 5, 'on_ball'), ('keeper_punt', 6, 'keeper'), ('keeper_pos', 7, 'keeper'),
    ('keeper_dive', 8, 'keeper'), ('press', 9, 'press_ball'), ('chase', 10, 'chase_ball'), ('meet_pass', 11, 'receive'),
    ('restart', 13, 'on_ball'), ('throw_in', 14, 'on_ball'), ('corner', 15, 'on_ball'), ('law_distance', 16, 'hold_block'),
    ('attack_box', 17, 'attack_box'), ('in_behind', 18, 'on_ball'), ('run_line', 19, 'run_line'), ('into_space', 20, 'on_ball'),
    ('mark', 21, 'mark_man')
  ) AS v(code, i, p)
 WHERE t.kind = 'decision' AND t.code = v.code;
-- A state belongs to a side of the ball.
UPDATE game_engine_terms SET parent = 'with' WHERE kind = 'state' AND code IN ('on_ball', 'support', 'receive', 'attack_box', 'run_line');
UPDATE game_engine_terms SET parent = 'without' WHERE kind = 'state' AND code IN ('hold_block', 'press_ball', 'chase_ball', 'mark_man');
UPDATE game_engine_terms SET parent = 'keeper' WHERE kind = 'state' AND code = 'keeper';

-- mig 1828's popup words go with the popup.
DELETE FROM message_templates WHERE kind = 'taxonomy' AND tier LIKE 'loop\_%';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('page title when the concept is unknown', 'clip_title', 'Concept', 200),
    ('which example ({i} of {n}, {player}, {num})', 'clip_which', 'Example {i} of {n} — #{num} {player}', 201),
    ('waiting for the first example', 'clip_waiting', 'Watching the live match for the first example… (it has to happen, then five seconds more)', 202),
    ('the engine does not name this concept', 'clip_unreported', 'The engine does not yet say when a player is doing this, so there are no examples to cut.', 203),
    ('what the engine does ({what})', 'clip_engine', 'In the engine: {what}', 204),
    ('phase: before', 'clip_before', 'BEFORE', 205),
    ('phase: doing it', 'clip_doing', '▶ DOING IT', 206),
    ('phase: after', 'clip_after', 'AFTER', 207),
    ('button: previous', 'clip_prev', '‹ Previous', 208),
    ('button: next', 'clip_next', 'Next ›', 209),
    ('button: replay', 'clip_replay', '↺ Replay', 210),
    ('button: pause', 'clip_pause', '⏸ Pause', 211),
    ('button: play', 'clip_play', '▶ Play', 212),
    ('speed label', 'clip_speed', 'Speed', 213),
    ('legend under the pitch', 'clip_legend', 'Gold ring = the player doing it · red ring = who he is acting on · dots = where he has come from · dashed line = where he is heading', 214),
    ('panel heading ({num}, {player})', 'clip_sm_title', '#{num} {player} — his state machine', 215),
    ('panel: side of the ball', 'clip_sm_side', 'His side', 216),
    ('side: has the ball', 'clip_sm_with', 'has the ball', 217),
    ('side: does not have the ball', 'clip_sm_without', 'does not have the ball', 218),
    ('panel: states', 'clip_sm_states', 'His states (the one he is in is lit)', 219),
    ('panel: decision', 'clip_sm_decision', 'Right now', 220),
    ('panel: concept', 'clip_sm_concept', 'Concept he is playing', 221),
    ('panel: none', 'clip_sm_none', '—', 222),
    ('panel: through this example', 'clip_sm_path', 'Through this example', 223),
    ('panel: the other player ({num}, {player})', 'clip_sm_other', 'Acting on: #{num} {player}', 224),
    ('panel: note', 'clip_sm_note', 'The match sends each player''s decision and concept; his state is worked out from them.', 225)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
