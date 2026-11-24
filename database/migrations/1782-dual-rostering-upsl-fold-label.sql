-- 1782 (2026-11-23): #dual-rostering — the UPSL fold says what it is.
-- Owner: "why does it say add upsl clubs we want all clubs. upsl too."
-- The page is every league; the fold is only the door UPSL comes in by,
-- since the server cannot read upsl.com.  (Same day: the league pills
-- became toggles that centre the query — page code only.)

BEGIN;

UPDATE message_templates SET body = '📥 UPSL comes in here — load saved team pages (every other league is read automatically)'
 WHERE kind = 'roster_watch' AND tier = 'paste_fold';

INSERT INTO schema_migrations (filename) VALUES ('1782-dual-rostering-upsl-fold-label.sql') ON CONFLICT DO NOTHING;

COMMIT;
