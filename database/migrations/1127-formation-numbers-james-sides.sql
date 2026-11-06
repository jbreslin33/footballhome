-- 1127 — formation_slot_roles numbers on James's sides (game/DESIGN.md §8.135).
--
-- James's numbering, "for all games/formations" (club graphic, x = 0 left → 100 right as we
-- attack): 3 LB left, 2 RB right, 5 the left centre-back, 4 the right, 11 the left wing, 7 the
-- right. Mig 643 put 5 and 11 on the right (x 60 / 80-85) and 4 and 7 on the left in 4-3-3,
-- 4-2-3-1 and 4-4-2 (found by the club-app session: a tactic plan against a 4-3-3 put their 11
-- on the wrong flank). The numbers move; the positions and roles stay (both centre-backs, both
-- wide men — the engine's play is unchanged; the shirts it shows and the club app's reads change).

BEGIN;
UPDATE formation_slot_roles r
   SET number = CASE r.number WHEN 4 THEN 5 WHEN 5 THEN 4 WHEN 7 THEN 11 WHEN 11 THEN 7 END
  FROM formations f
 CROSS JOIN LATERAL jsonb_array_elements(f.positions_json::jsonb) p
 WHERE f.code = r.formation_code AND (p->>'slot')::int = r.slot
   AND r.formation_code IN ('4-3-3', '4-2-3-1', '4-4-2')
   AND ((r.number = 5 AND (p->>'x')::int > 50) OR (r.number = 4 AND (p->>'x')::int < 50) OR
        (r.number = 11 AND (p->>'x')::int > 50) OR (r.number = 7 AND (p->>'x')::int < 50));
COMMIT;
