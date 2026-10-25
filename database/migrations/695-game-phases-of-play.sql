-- 695 (2026-10-24) — game: phases of play (game/DESIGN.md §8.54, G4.58).
--
-- James: "lets have a restart from keeper option. for either team. this
-- is the MOST organized a team will ever be. we can start the learning
-- process from there and work backward" / "then we can do mid block area
-- and attack in final third/defend there. then tap off and special kicks
-- like corners" / "we want to think like coaches when designing the game
-- … coaching methodology is the most important."
--
-- A phase of play is the coach's session (FA / KNVB): set the picture,
-- play it out, stop, fix, replay. Admin RUN_PHASE (wire 1.9) places all
-- 22 in their organized shapes for that ball and starts it. New phases are
-- rows — no code.

CREATE TABLE IF NOT EXISTS game_phases (
  code text PRIMARY KEY,
  title text NOT NULL,
  kind text NOT NULL CHECK (kind IN ('keeper', 'open', 'kickoff', 'corner')),
  ball_x_pct smallint NOT NULL,   -- up the pitch from the team in possession's own goal line, 0-100
  ball_y_pct smallint NOT NULL DEFAULT 0,   -- across it, -100 right … +100 left (that team's view)
  coaching_point text NOT NULL DEFAULT '',
  sort_order smallint NOT NULL DEFAULT 0
);
COMMENT ON TABLE game_phases IS
  'Phases of play (G4.58): coaching restarts run from the game (admin). keeper/corner/kickoff = a dead ball only the team in possession may touch first; open = the ball at the feet of their nearest outfielder.';

INSERT INTO game_phases (code, title, kind, ball_x_pct, ball_y_pct, coaching_point, sort_order) VALUES
 ('keeper', 'From the keeper', 'keeper', 6, 0,
  'The most organized picture in football: build up through their first line; they press or drop.', 10),
 ('mid-block', 'Into their mid-block', 'open', 45, 0,
  'Ball with us around halfway against a set mid-block: break the lines or keep it.', 20),
 ('final-third', 'In the final third', 'open', 75, 20,
  'Ball with us at the edge of their block: create and finish; they defend the box.', 30),
 ('kickoff', 'Kick-off', 'kickoff', 50, 0, 'Both teams set in their own half.', 40),
 ('corner-left', 'Corner, left', 'corner', 99, 97, 'Attacking / defending the corner from the left.', 50),
 ('corner-right', 'Corner, right', 'corner', 99, -97, 'Attacking / defending the corner from the right.', 60)
ON CONFLICT (code) DO NOTHING;
