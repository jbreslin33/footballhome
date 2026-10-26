-- 740 (2026-10-26) — game: a 1-rated player barely looks (game/DESIGN.md
-- §8.64, G4.66 follow-up).
--
-- James 10/26: "1 rate player should basically look less then that lol" —
-- every 5 s at 1 was too often. A 1 now looks every 20 s; the rating sets
-- LOOKS PER SECOND on a straight line between 1 and 100 (a 60 looks about
-- every 2 s). max_age_s no longer caps how old his look is — only how far
-- back the stale picture places a moving man (pos − vel × age, the
-- stateless approximation, meaningless over long ages).

UPDATE game_model_params SET value = 20,
       note = 'A 1-rated player looks over his shoulder this often in possession (barely ever); looks per second run in a straight line to the 100.'
 WHERE owner = 'concept' AND code = 'scan-before-receive' AND param = 'every_s_at1';
UPDATE game_model_params SET value = 20,
       note = 'A 1-rated player looks behind him this often out of possession (barely ever); looks per second run in a straight line to the 100.'
 WHERE owner = 'concept' AND code = 'scan-defending' AND param = 'every_s_at1';
UPDATE game_model_params
   SET note = 'A man he can''t see is placed back along his run by at most this much time (the look itself can be older).'
 WHERE owner = 'physics' AND code = 'vision' AND param = 'max_age_s';
