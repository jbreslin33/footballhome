-- 1145 — the Laws of the Game at restarts, one statement for the club app and the game
-- (game/DESIGN.md §8.137, §8.140). James: "ok just turn it over to game".
--
-- tactic_restarts (mig 1142) held the goal kick only, as a whole-width cap (our_max_y). Each row
-- now states its Law as the IFAB Laws of the Game do:
--   law_m        the distance opponents keep from the ball (m), NULL = none;
--   zone         where they may not stand until it is in play: penalty_area (goal kick, Law 16),
--                area_and_arc (penalty, Law 14: outside the area and 9.15 m from the mark, behind
--                the ball), own_half (kick-off, Law 8), none;
--   zone_min_x / zone_max_x / zone_min_y   that zone in the plan's coordinates (0-100, our view,
--                their goal at y 100) where it is a box at their end — the penalty area: x 20.35 -
--                79.65 (40.32 m of 68), y >= 84.29 (16.5 m of 105);
--   who          opponents (of the side taking it) or all_but_taker_and_keeper (penalty);
--   until_event  when it lifts: kicked_and_moves (Laws 13-17 since 2019), thrown (Law 15);
--   wall_min_m, attackers_from_wall_m, wall_min_players   Law 13: a wall at 9.15 m; with 3+
--                defenders in it, attackers at least 1 m from it.
-- The goal kick follows the Law exactly: opponents out of the penalty AREA only (the app's cap
-- applies inside zone_min_x..zone_max_x); our_max_y stays for the app until it reads the zone.
-- The game reads law_m for throw-ins, free kicks and corners, and the penalty arc.

BEGIN;
ALTER TABLE tactic_restarts
  ADD COLUMN IF NOT EXISTS law_m numeric(5,2),
  ADD COLUMN IF NOT EXISTS zone text NOT NULL DEFAULT 'none',
  ADD COLUMN IF NOT EXISTS zone_min_x numeric(5,2),
  ADD COLUMN IF NOT EXISTS zone_max_x numeric(5,2),
  ADD COLUMN IF NOT EXISTS zone_min_y numeric(5,2),
  ADD COLUMN IF NOT EXISTS who text NOT NULL DEFAULT 'opponents',
  ADD COLUMN IF NOT EXISTS until_event text NOT NULL DEFAULT 'kicked_and_moves',
  ADD COLUMN IF NOT EXISTS wall_min_m numeric(5,2),
  ADD COLUMN IF NOT EXISTS attackers_from_wall_m numeric(5,2),
  ADD COLUMN IF NOT EXISTS wall_min_players smallint;
ALTER TABLE tactic_restarts DROP CONSTRAINT IF EXISTS tactic_restarts_zone_check;
ALTER TABLE tactic_restarts ADD CONSTRAINT tactic_restarts_zone_check
  CHECK (zone IN ('none', 'penalty_area', 'area_and_arc', 'own_half'));
ALTER TABLE tactic_restarts DROP CONSTRAINT IF EXISTS tactic_restarts_who_check;
ALTER TABLE tactic_restarts ADD CONSTRAINT tactic_restarts_who_check
  CHECK (who IN ('opponents', 'all_but_taker_and_keeper'));
ALTER TABLE tactic_restarts DROP CONSTRAINT IF EXISTS tactic_restarts_until_check;
ALTER TABLE tactic_restarts ADD CONSTRAINT tactic_restarts_until_check
  CHECK (until_event IN ('kicked_and_moves', 'thrown'));

INSERT INTO tactic_restarts (code, label, law, our_max_y, law_m, zone, zone_min_x, zone_max_x, zone_min_y,
                             who, until_event, wall_min_m, attackers_from_wall_m, wall_min_players) VALUES
  ('goal_kick', 'Goal kick', 'Law 16 — opponents outside the penalty area until the ball is in play', 84.29,
   NULL, 'penalty_area', 20.35, 79.65, 84.29, 'opponents', 'kicked_and_moves', NULL, NULL, NULL),
  ('free_kick', 'Free kick', 'Law 13 — opponents at least 9.15 m from the ball; a wall at 9.15 m, attackers 1 m from a wall of 3+', 100,
   9.15, 'none', NULL, NULL, NULL, 'opponents', 'kicked_and_moves', 9.15, 1.00, 3),
  ('corner', 'Corner kick', 'Law 17 — opponents at least 9.15 m from the corner arc until the ball is in play', 100,
   9.15, 'none', NULL, NULL, NULL, 'opponents', 'kicked_and_moves', NULL, NULL, NULL),
  ('throw_in', 'Throw-in', 'Law 15 — opponents at least 2 m from where it is taken', 100,
   2.00, 'none', NULL, NULL, NULL, 'opponents', 'thrown', NULL, NULL, NULL),
  ('kick_off', 'Kick-off', 'Law 8 — every player in his own half; opponents at least 9.15 m from the ball', 100,
   9.15, 'own_half', NULL, NULL, NULL, 'opponents', 'kicked_and_moves', NULL, NULL, NULL),
  ('penalty', 'Penalty kick', 'Law 14 — all but the taker and the defending keeper outside the area, 9.15 m from the mark, behind the ball; the keeper on his line', 100,
   9.15, 'area_and_arc', 20.35, 79.65, 84.29, 'all_but_taker_and_keeper', 'kicked_and_moves', NULL, NULL, NULL)
ON CONFLICT (code) DO UPDATE SET label = EXCLUDED.label, law = EXCLUDED.law, law_m = EXCLUDED.law_m,
  zone = EXCLUDED.zone, zone_min_x = EXCLUDED.zone_min_x, zone_max_x = EXCLUDED.zone_max_x,
  zone_min_y = EXCLUDED.zone_min_y, who = EXCLUDED.who, until_event = EXCLUDED.until_event,
  wall_min_m = EXCLUDED.wall_min_m, attackers_from_wall_m = EXCLUDED.attackers_from_wall_m,
  wall_min_players = EXCLUDED.wall_min_players;
COMMIT;
