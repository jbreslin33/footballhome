-- 1293 (2026-11-12): #payments → #tuition.  Owner: "should we rename payments
-- url to tuition?" → "yes".  The menu already labels the page Tuition (and
-- #fines is laid out like it); only the URL said payments.  'payments' stays
-- in screens so an old history entry still lights the Tuition pill; goTo maps
-- 'payments' → 'tuition' (navigation.js RETIRED).  /api/payments/* unchanged.
BEGIN;
UPDATE menu_pages SET screens = '{tuition,payments}' WHERE code = 'financial';
INSERT INTO schema_migrations (filename) VALUES ('1293-tuition-url.sql') ON CONFLICT DO NOTHING;
COMMIT;
