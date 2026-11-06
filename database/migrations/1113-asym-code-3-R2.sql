-- 1113 (2026-11-06) — Asymmetric shapes say which row is off-center.
--
-- Owner: "don't mirror we need to be specif. could be a code. 352(3R2)
-- for what we talked about. or 352(21R2) get it?"  In the bracket (the
-- inside five read bottom-up, mig 1109) an R before a row = that row sits
-- right of center (an L would be left).  No shape is mirrored for free —
-- each asymmetric code is its own row, added when it's wanted.
--
-- mig 1112's '3-5-2 (3-2) asym' is 3-R2: 11 10 8 / 9 central + 7 in the
-- right half-space.  Same id, so nothing saved on it moves.

UPDATE formations SET code = '3-5-2 (3-R2)', name = 'Asymmetric 3-5-2 (3-R2)'
 WHERE code = '3-5-2 (3-2) asym';
