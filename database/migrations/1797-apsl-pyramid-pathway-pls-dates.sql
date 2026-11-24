-- 1797 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the PLS box's
-- caption adds how young the document is (owner: "This document didn't even
-- exist until (you look that up)" · "and didn't have anything about a 'net
-- worth Owner' until (look that up)").  Looked up 11/24: first Professional
-- League Standards 1995 (Wikipedia, NASL 2011–2017 article — the one source
-- found for that year); a principal owner with an individual net worth
-- (Division II, $20M, 35%) first in the August 2010 revision (the 2010 D-2
-- text, insidemnsoccer.com; kenn.com's summary of the versions).  Words only.
BEGIN;
UPDATE message_templates
   SET body = body || ' This document did not even exist until 1995, and it had nothing about an owner''s net worth until 2010.'
 WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_bridge' AND body NOT LIKE '%until 1995%';
COMMIT;
