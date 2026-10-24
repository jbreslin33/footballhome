-- 671 (2026-10-23) — game: the aimed loft (game/DESIGN.md §8.43, G4.48).
--
-- The lofted kick had one power (12 m/s + 6 m/s rise): its first bounce
-- landed ~15 m out and it skipped on for ~45 m more, so a long ball's range
-- was a fiction and direct-ball capped itself at 30 m. A lofted pass now
-- carries a first-bounce distance; the passer drops it where the receiver
-- will be. Range = a semipro long ball.

UPDATE game_model_params
   SET value = 50,
       note = 'The passer''s lofted range: the aimed loft (G4.48) drops it at the receiver up to this far; also caps an over-the-top ball.'
 WHERE owner = 'concept' AND code = 'direct-ball' AND param = 'max_m';
