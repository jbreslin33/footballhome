-- 1325 (2026-11-13): how many players an entry fee includes.
-- CASA Select: "State affiliation registration included for up to 25
-- players … $23 per player" — so a CASA team's planned players = 25 + the
-- extra-player quantity.  The Year plan's cost per player reads it.

BEGIN;
ALTER TABLE league_fees ADD COLUMN IF NOT EXISTS players_included integer CHECK (players_included >= 0);
COMMENT ON COLUMN league_fees.players_included IS 'Players the fee already covers (CASA entry: 25) — mig 1325';
UPDATE league_fees SET players_included = 25 WHERE season_id = 40 AND fee_kind = 'team_entry';
INSERT INTO schema_migrations (filename) VALUES ('1325-fee-players-included.sql') ON CONFLICT DO NOTHING;
COMMIT;
