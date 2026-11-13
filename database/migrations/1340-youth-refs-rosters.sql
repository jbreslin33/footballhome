-- 1340 (2026-11-13): youth fall refs + roster sizes.
-- Owner: "its 25 for u8, u10 in fall and 30 for u12 … for outdoor its u11 and
-- below 12. u12 and above 16 for indoor its all 12."
BEGIN;
UPDATE ref_fee_policies SET per_game_usd = 30.00, note = 'PPR fall U12: $30 per team (owner 2026-11-13)' WHERE id = 5 AND kind = 'referee';
UPDATE teams SET max_roster = 12 WHERE id IN (912, 913);   -- U8, U10 (outdoor U11 and below)
UPDATE teams SET max_roster = 16 WHERE id = 914;           -- U12 (outdoor U12 and above)
INSERT INTO schema_migrations (filename) VALUES ('1340-youth-refs-rosters.sql') ON CONFLICT DO NOTHING;
COMMIT;
