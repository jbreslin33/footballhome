-- 1131 (2026-11-06) — Their 6 a bit higher than the box in the build-out.
--
-- Owner: "have their 6 a bit higher then box."  The 4-3-3 build-out shape
-- (mig 1129) had him at the D (y 80, the box's edge is 84.3); now y 76 —
-- about 8–9 m above the box, still the first pass in front of the split
-- centre-backs.  Applied to the shape and to every out_of_possession
-- plan's root state ("their GK") whose 6 still stood on the old spot.
UPDATE tactic_buildout_shapes b SET y = 76
  FROM formations f
 WHERE f.id = b.formation_id AND f.code = '4-3-3' AND b.number = 6 AND b.y = 80;

UPDATE tactic_state_opponents o SET y = 76
  FROM tactic_states s JOIN tactic_plans p ON p.id = s.plan_id
 WHERE o.state_id = s.id AND s.parent_state_id IS NULL AND p.moment = 'out_of_possession'
   AND o.number = 6 AND o.x = 50 AND o.y = 80;
