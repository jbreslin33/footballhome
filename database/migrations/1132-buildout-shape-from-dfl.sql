-- 1132 (2026-11-06) — The 4-3-3 goal-kick shape from real tracking data.
--
-- Owner: "check what is normally done at pro level"; then "have their 6 a
-- bit higher then box".  Migs 1129/1131 placed it by hand [FH] from
-- published descriptions.  The game session then cut it from the DFL
-- tracking set [DFL]: game/scripts/benchmarks_tracking_goalkick.py (commit
-- a69fb159), 65 of the 85 goal kicks in the 7 matches, anchored on the
-- frame the ball comes back into play from inside the kicking side's goal
-- area; kicking side by DFL PlayingPosition; full role table in
-- game/DESIGN.md §8.136.  Plan coordinates (0–100, our view, their goal at
-- y 100; their left on our right).  n = goal kicks with that role.
--
--   1 GK 50,96 (65) · 4 IVR 32,87 (65) · 5 IVL 66,86 (65)
--   2 RV 14,78 (46) · 3 LV 86,75 (44)
--   6 DMZ 50,67 (13 — centred from 54; a single pivot stands ~35 m out,
--     he does NOT drop to the D; only a back three's middle man does)
--   8 DMR 43,68 (53) · 10 DML 56,71 (50)  — mostly a double pivot's two
--     men in DFL's labels; a true 4-3-3's eights may stand a bit wider
--   7 ORM 24,52 (48) · 11 OLM 78,50 (51) · 9 STZ 53,45 (43)
--
-- What the hand version had wrong: CBs split ~12 m off centre at the edge
-- of the box (~14 m out), not deep in it; full-backs ~25 m wide and
-- 23–26 m up, not on the touchline; wingers ~18 m in from the touchlines
-- on the halfway line.  Replaces the shape and every out_of_possession
-- plan's root state (their GK on the ball) against 4-3-3.

UPDATE tactic_buildout_shapes b SET x = v.x, y = v.y
  FROM formations f, (VALUES
    (1, 50, 96), (4, 32, 87), (5, 66, 86), (2, 14, 78), (3, 86, 75),
    (6, 50, 67), (8, 43, 68), (10, 56, 71), (7, 24, 52), (11, 78, 50), (9, 53, 45)
  ) AS v(n, x, y)
 WHERE f.id = b.formation_id AND f.code = '4-3-3' AND b.number = v.n;

DELETE FROM tactic_state_opponents o
 USING tactic_states s, tactic_plans p, formations f
 WHERE o.state_id = s.id AND s.plan_id = p.id AND s.parent_state_id IS NULL
   AND p.moment = 'out_of_possession' AND p.opponent_formation_id = f.id AND f.code = '4-3-3';
INSERT INTO tactic_state_opponents (state_id, number, x, y)
SELECT s.id, b.number, b.x, b.y
  FROM tactic_states s JOIN tactic_plans p ON p.id = s.plan_id
  JOIN formations f ON f.id = p.opponent_formation_id AND f.code = '4-3-3'
  JOIN tactic_buildout_shapes b ON b.formation_id = f.id
 WHERE s.parent_state_id IS NULL AND p.moment = 'out_of_possession';
