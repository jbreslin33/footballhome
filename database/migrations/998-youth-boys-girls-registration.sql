-- 998 (2026-11-03) — Youth Contact popup offers BOTH the Boys and the
-- Girls LeagueApps registration.
-- Owner: "we need contact card to allow for boys and girls reg in case i
-- don't know which gender".
--
-- The youth 📇 Contact popup (section-contact.js) lists every active
-- kind='registration' row in category 'Youth Travel' for boys AND girls
-- alike, so two rows here put ⚽ Boys registration and ⚽ Girls
-- registration on every youth card — pick the one that fits the kid.
--
-- Links stay per-category (never the bare club URL): two club_forms codes
-- copied from leagueapps_programs (category, 'active').registration_url,
-- the source of truth since migration 291, resolved by {form:<code>}.
-- sort_order 10/11 keeps the 📄 Docs reminder (sort_order 0) first, which
-- boys-roster.js reads as cardTemplates('Youth Travel')[0].

BEGIN;

INSERT INTO club_forms (club_id, code, label, url)
SELECT 134, 'la_' || p.category || '_registration',
       CASE p.category WHEN 'boys' THEN 'LeagueApps — Boys Club membership registration'
                       ELSE 'LeagueApps — Girls Club membership registration' END,
       p.registration_url
  FROM leagueapps_programs p
 WHERE p.category IN ('boys', 'girls') AND p.variant = 'active'
ON CONFLICT (club_id, code) DO UPDATE SET url = EXCLUDED.url, label = EXCLUDED.label, updated_at = NOW();

INSERT INTO message_templates (category, label, kind, tier, icon, subject, body, sort_order)
VALUES
  ('Youth Travel', '⚽ Boys registration', 'registration', 'card', '⚽',
   'Lighthouse Boys Club — register on LeagueApps',
   E'Hi! To get your son playing with Lighthouse Boys Club, please register (and set up dues) on LeagueApps here:\n\n{form:la_boys_registration}\n\nOnce that''s done he''ll see his practices and games on Football Home. Thanks!\n\n— Lighthouse Soccer',
   10),
  ('Youth Travel', '⚽ Girls registration', 'registration', 'card', '⚽',
   'Lighthouse Girls Club — register on LeagueApps',
   E'Hi! To get your daughter playing with Lighthouse Girls Club, please register (and set up dues) on LeagueApps here:\n\n{form:la_girls_registration}\n\nOnce that''s done she''ll see her practices and games on Football Home. Thanks!\n\n— Lighthouse Soccer',
   11);

DO $$
DECLARE n INT;
BEGIN
  SELECT count(*) INTO n FROM club_forms
   WHERE club_id = 134 AND code IN ('la_boys_registration', 'la_girls_registration')
     AND is_active AND url LIKE 'https://lighthouse1893.leagueapps.com/leagues/%';
  IF n <> 2 THEN RAISE EXCEPTION 'expected 2 LeagueApps youth registration forms, found %', n; END IF;
END $$;

COMMIT;
