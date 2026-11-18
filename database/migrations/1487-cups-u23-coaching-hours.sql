-- 1487 (2026-11-18) — Cups and U23 game coaching at Liga 1's hours (owner:
-- "put them as same hours as liga 1 2.75 each").  Was Cups 3.0, U23 2.45.
BEGIN;
UPDATE ref_fee_policies SET hours_per_game = 2.75 WHERE kind = 'coaching' AND id IN (25, 26) AND label IN ('Cups', 'U23');
COMMIT;
