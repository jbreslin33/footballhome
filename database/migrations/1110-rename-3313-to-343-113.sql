-- 1110 (2026-11-06) — The 3-3-1-3 joins the bowl family (mig 1109) as
-- 3-4-3 (1-1-3).
--
-- Owner: "retire the 3-3-1-3 ... the 3313 is really what in the new
-- system?" → "Rename to 3-4-3 (1-1-3)".  Same bowl (3, 5, 6, 4, 2), the
-- inside five bottom-up: 8 / 10 / 11 9 7.  Same numbers, same id, so the
-- 10/21 game on it (match 9330) keeps its lineup.
--
-- formation_slot_roles still carries game rows under the old code
-- '3-3-1-3'; the game is pro shapes only (mig 1042) and nothing in game/
-- asks for this formation, so they are left for the game side.

UPDATE formations SET code = '3-4-3 (1-1-3)', name = 'Classic 3-4-3 (1-1-3)'
 WHERE code = '3-3-1-3';
