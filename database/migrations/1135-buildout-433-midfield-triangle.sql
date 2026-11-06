-- 1135 (2026-11-06) — Their 4-3-3 build-out midfield as a triangle.
--
-- Owner: "opp team does not look like 433 lol" / "their midfield is all
-- jumbled".  The DFL cut (mig 1132) put their 8 and 10 at x 43 / 56 beside
-- the 6 at 50, all ~30–35 m out — a clump: in DFL's labels those two are
-- mostly a 4-2-3-1's double pivot (DML/DMR), and the 7 matches lack enough
-- true 4-3-3 goal kicks to split the eights out (the game session's own
-- caveat, game/DESIGN.md §8.136).  A 4-3-3's build-out has the 6 deepest
-- and the two eights AHEAD of him in the half-spaces, so [FH] on those
-- two only: 8 → 32,61 and 10 → 68,61 (our view; their 8 on our left).
-- The 9 centres (53 → 50).  Everyone else stays on the DFL cut.

UPDATE tactic_buildout_shapes b SET x = v.x, y = v.y
  FROM formations f, (VALUES (8, 32, 61), (10, 68, 61), (9, 50, 45)) AS v(n, x, y)
 WHERE f.id = b.formation_id AND f.code = '4-3-3' AND b.number = v.n;

-- Plans' root states (their GK on the ball) still on the DFL spots.
UPDATE tactic_state_opponents o SET x = v.x, y = v.y
  FROM tactic_states s, tactic_plans p, formations f,
       (VALUES (8, 43, 68, 32, 61), (10, 56, 71, 68, 61), (9, 53, 45, 50, 45)) AS v(n, ox, oy, x, y)
 WHERE o.state_id = s.id AND s.plan_id = p.id AND s.parent_state_id IS NULL
   AND p.moment = 'out_of_possession' AND p.opponent_formation_id = f.id AND f.code = '4-3-3'
   AND o.number = v.n AND o.x = v.ox AND o.y = v.oy;
