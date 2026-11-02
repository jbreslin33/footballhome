-- 929: the ball in the air is contested (G5.3, game/DESIGN.md §8.101).
--
-- A corner was a free control eight metres out: nobody could touch a ball
-- above 1.5 m and the nearest man under it simply took it, so 3.7 corners a
-- match gave 1.6 goals. The harness hid it: "goals within 10 s of a corner"
-- closed its watch on the shot, before the goal landed, and read 0.00.
--
-- jumping_reach and strength now play. Every number here is an FH estimate,
-- not sourced; a coach's to change.

BEGIN;

UPDATE game_attributes SET status = 'wired',
       scales = 'head reach: 2.3 m at 0, 2.6 at 50, 2.9 at 100; half of his aerial share (G5.3)'
 WHERE code = 'jumping_reach';
UPDATE game_attributes SET status = 'wired',
       scales = 'half of his aerial share (G5.3); nothing else yet'
 WHERE code = 'strength';

UPDATE game_techniques SET status = 'wired' WHERE code IN ('header-attacking', 'def-header-clear');

-- A row for radius_m is what switches it on: absent, the engine has no duels
-- (the goldens run without a DB).
INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('physics', 'aerial', 'radius_m', 1.0, 'm', 'How far from the ball''s spot he can still get his head to it [FH].'),
  ('physics', 'aerial', 'min_z_m', 1.0, 'm', 'Below this it is a control, not a header [FH].'),
  ('physics', 'aerial', 'duel_slope', 0.6, 'pct/pt', 'Chance per point of aerial share over the other man, from 50, held to 5-95 [FH].'),
  ('physics', 'aerial', 'goal_range_m', 14, 'm', 'Straight-line distance to their goal inside which a header goes at it [FH].'),
  ('physics', 'aerial', 'own_range_m', 35, 'm', 'Inside this of his own goal a header goes away [FH].'),
  ('physics', 'aerial', 'goal_speed_mps', 14, 'm/s', 'A header at goal [FH].'),
  ('physics', 'aerial', 'clear_speed_mps', 16, 'm/s', 'A defensive header, lofted [FH].'),
  ('physics', 'aerial', 'nod_keep', 0.5, 'share', 'Between the two: the ball''s speed it keeps, glanced on [FH].'),
  ('physics', 'aerial', 'goal_err_deg', 45, 'deg', 'Header at goal, unchallenged: fit to pro 28.7% on target (StatsBomb PL 2015/16, 60 matches), with the duel row [FH fit].'),
  ('physics', 'aerial', 'goal_err_duel_deg', 80, 'deg', 'Header at goal with a man on him: same fit [FH fit].'),
  ('physics', 'aerial', 'clear_err_deg', 40, 'deg', 'Defensive header or nod-on [FH].'),
  ('skill', 'jumping_reach', 'head_reach_m_at0', 2.3, 'm', 'Top of his header at rating 0 [FH].'),
  ('skill', 'jumping_reach', 'head_reach_m_at50', 2.6, 'm', 'At 50 [FH].'),
  ('skill', 'jumping_reach', 'head_reach_m_at100', 2.9, 'm', 'At 100 [FH].')
ON CONFLICT (owner, code, param) DO NOTHING;

-- Who is good in the air by position. A hand edit still wins; these reach a
-- player the next time fh-game-roll runs.
INSERT INTO game_sheet_position_profile (position_group, attribute, offset_pts) VALUES
  ('CB', 'jumping_reach', 10), ('CB', 'strength', 8),
  ('ST', 'jumping_reach', 6),  ('ST', 'strength', 4),
  ('DM', 'jumping_reach', 2),  ('DM', 'strength', 4),
  ('FB', 'jumping_reach', -2), ('FB', 'strength', -2),
  ('AM', 'jumping_reach', -4), ('AM', 'strength', -4),
  ('W',  'jumping_reach', -5), ('W',  'strength', -5)
ON CONFLICT DO NOTHING;

COMMIT;
