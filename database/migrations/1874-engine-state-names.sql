-- 1874 (2026-11-24): each player's REAL state reaches the clip viewer.
--
-- Found while checking the new 🧠 panel (mig 1872): the page guessed his state from his
-- order of the tick, and with the ball loose it showed "TEAM: We have the ball" beside "HIM:
-- Hold his place in the team's defensive shape" — two machines that cannot both be true. The
-- engine now sends each man's state (frame STATES); this column says what the engine calls
-- each state, so the game server can send the catalogue's code.
ALTER TABLE game_engine_terms ADD COLUMN IF NOT EXISTS engine_name text;
COMMENT ON COLUMN game_engine_terms.engine_name IS
  'kind state: the engine''s own name for it (PlayerState::name() in game/src/ai) — the game server maps it to this row''s code for the STATES frame.';
UPDATE game_engine_terms t SET engine_name = v.n FROM (VALUES
  ('on_ball', 'on the ball'), ('support', 'support'), ('receive', 'receive'), ('attack_box', 'attack the box'),
  ('run_line', 'run onto the line'), ('hold_block', 'hold the block spot'), ('press_ball', 'press the ball'),
  ('chase_ball', 'chase the ball'), ('mark_man', 'mark his man'), ('keeper', 'keeper')
) AS v(code, n) WHERE t.kind = 'state' AND t.code = v.code;

-- The pressing-distance legend: the circle is live now (it no longer freezes at a pass).
UPDATE message_templates SET body = 'Gold ring = the defender · red ring = his man · the big circle = how far he can get while a pass to his man would travel, right now (green: his man is inside it; red: too far)'
 WHERE kind = 'taxonomy' AND tier = 'reach_legend';

-- KNOWS with his own team on the ball: nobody has a direct opponent then (not "the spare man").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — brain panel: knows, our ball', 'taxonomy', 'brain_knows_ourball', NULL,
       'his team has the ball — no direct opponent to mind', 355, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = 'brain_knows_ourball');
