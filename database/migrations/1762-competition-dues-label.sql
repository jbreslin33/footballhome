-- 1762 (2026-11-23): "League Dues" reads "Competition Dues".
--
-- Owner 2026-11-23: "instead of league dues put competition dues?" — a cup is
-- a competition, not a league.  The category's label, so every page that
-- names it (#competitions, #finances reports, #invoices) says the same; the
-- code stays league_dues.  The one note that spelled it out follows.

BEGIN;
UPDATE invoice_line_categories SET label = 'Competition Dues:' WHERE code = 'league_dues';
UPDATE message_templates SET body = replace(replace(body, 'League Dues', 'Competition Dues'), 'league dues', 'competition dues'), updated_at = now()
 WHERE kind = 'finances' AND tier = 'var_note' AND body ILIKE '%league dues%';
INSERT INTO schema_migrations (filename) VALUES ('1762-competition-dues-label.sql') ON CONFLICT DO NOTHING;
COMMIT;
