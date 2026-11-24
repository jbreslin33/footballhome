-- 1761 (2026-11-23): the Werner Fricker Open Cup reads "State Open Cup".
--
-- Owner 2026-11-23: "put open cup as state open cup. because next year we
-- will have also us open cup".  Label only (pills, bands and roll-up lines on
-- #competitions / #finances); the scope code stays open_cup.

BEGIN;
UPDATE cash_flow_scopes SET label = 'State Open Cup' WHERE code = 'open_cup';
INSERT INTO schema_migrations (filename) VALUES ('1761-state-open-cup-label.sql') ON CONFLICT DO NOTHING;
COMMIT;
