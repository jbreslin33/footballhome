-- 1137 (2026-11-06) — Their build-out: CBs beside the keeper, wide men on the
-- touchlines.  (Numbered 1137: another session claimed 1136 first.)
--
-- Owner: "move opp 4 and 5 in between edge of 6 and 18 box a little ahead
-- of keeper."  Sideways halfway between the goal area's side (x 36.5 /
-- 63.5) and the penalty area's side (x 20.4 / 79.6) → x 28 / 72; a little
-- in front of the keeper (y 96) → y 92.  [FH], owner's call — replaces the
-- DFL cut's 32,87 / 66,86 (mig 1132) for the 4-3-3 shape and the plans'
-- root states still on those spots.
UPDATE tactic_buildout_shapes b SET x = v.x, y = v.y
  FROM formations f, (VALUES (4, 28, 92), (5, 72, 92)) AS v(n, x, y)
 WHERE f.id = b.formation_id AND f.code = '4-3-3' AND b.number = v.n;

UPDATE tactic_state_opponents o SET x = v.x, y = v.y
  FROM tactic_states s, tactic_plans p, formations f,
       (VALUES (4, 32, 87, 28, 92), (5, 66, 86, 72, 92)) AS v(n, ox, oy, x, y)
 WHERE o.state_id = s.id AND s.plan_id = p.id AND s.parent_state_id IS NULL
   AND p.moment = 'out_of_possession' AND p.opponent_formation_id = f.id AND f.code = '4-3-3'
   AND o.number = v.n AND o.x = v.ox AND o.y = v.oy;

-- Then: "move 2 and 3 opp to touchline" and "move opp 7 and 11 wide to
-- touch line too" — full-backs and wingers on the touchlines (x 3 / 97),
-- each at his own height (full-backs 78 / 75, wingers 52 / 50).  Their
-- right side (2, 7) is on our left.
UPDATE tactic_buildout_shapes b SET x = v.x
  FROM formations f, (VALUES (2, 3), (7, 3), (3, 97), (11, 97)) AS v(n, x)
 WHERE f.id = b.formation_id AND f.code = '4-3-3' AND b.number = v.n;

UPDATE tactic_state_opponents o SET x = v.x
  FROM tactic_states s, tactic_plans p, formations f,
       (VALUES (2, 3), (7, 3), (3, 97), (11, 97)) AS v(n, x)
 WHERE o.state_id = s.id AND s.plan_id = p.id AND s.parent_state_id IS NULL
   AND p.moment = 'out_of_possession' AND p.opponent_formation_id = f.id AND f.code = '4-3-3'
   AND o.number = v.n;
