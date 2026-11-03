-- 1022-game-442-slot-roles.sql — G5.12 (game/DESIGN.md §8.109): the 4-4-2 gets
-- its roles and position numbers. formation_slot_roles had 4-3-3, 4-2-3-1 and
-- 3-3-1-3 only, so every 4-4-2 side (Leicester City, Watford in the PL 2015/16
-- load) played with every slot numbered 0: no back line, no wingers, no
-- position-by-position marking. Numbers as mig 694 (7 = LEFT, 11 = RIGHT
-- winger; 6 the right-hand central mid as in the 4-2-3-1); the second striker
-- is the 10 so one man is "their 9".
INSERT INTO formation_slot_roles (formation_code, slot, role, number) VALUES
  ('4-4-2', 1, 'keeper', 1),
  ('4-4-2', 2, 'full-back', 2),
  ('4-4-2', 3, 'centre-back', 5),
  ('4-4-2', 4, 'centre-back', 4),
  ('4-4-2', 5, 'full-back', 3),
  ('4-4-2', 6, 'wide-forward', 11),
  ('4-4-2', 7, 'double-pivot', 6),
  ('4-4-2', 8, 'double-pivot', 8),
  ('4-4-2', 9, 'wide-forward', 7),
  ('4-4-2', 10, 'nine', 9),
  ('4-4-2', 11, 'ten', 10)
ON CONFLICT (formation_code, slot) DO UPDATE SET role = EXCLUDED.role, number = EXCLUDED.number;
