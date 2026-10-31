-- 870 (2026-10-30) — #apsl-pyramid is public: no login to read it.
--
-- Owner 2026-10-30: "make it public u can leave staff and rosters".
--
-- GET /api/pyramid, /territory and /club answer anyone; edits stay club
-- admin, and so does ⟳ (a forced re-read of every league site).  A visitor
-- has no /api/messages/templates/copy, so the page's wording comes from
-- /api/public/program-copy, which serves is_public rows only.  A new
-- apsl_pyramid row must be is_public too, or its label is blank logged out.
UPDATE message_templates SET is_public = true WHERE kind = 'apsl_pyramid' AND NOT is_public;
