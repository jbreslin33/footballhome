-- 🎯 Tactics: their 6 (4-3-3) drops toward their 18 (owner 2026-11-07:
-- "their 6 needs to be closer to 18").  The 18-yard line is y = 84.29
-- (16.5 m of 105); the 6 moves from 67 (18 m off it) to 80, 4.5 m outside
-- the box.  He changes in the 4-3-3 goal-kick shape (new plans start from
-- it) and in every saved state where he still stands on the old spot;
-- states where a coach has dragged him are left alone.
UPDATE tactic_buildout_shapes s SET y = 80.00
  FROM formations f
 WHERE f.id = s.formation_id AND f.code = '4-3-3' AND s.number = 6 AND s.x = 50.00 AND s.y = 67.00;

UPDATE tactic_state_opponents o SET y = 80.00
  FROM tactic_states st JOIN tactic_plans p ON p.id = st.plan_id JOIN formations f ON f.id = p.opponent_formation_id
 WHERE o.state_id = st.id AND f.code = '4-3-3' AND o.number = 6 AND o.x = 50.00 AND o.y = 67.00;
