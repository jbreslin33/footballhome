-- 1796 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the PLS box's
-- caption goes on (owner: "also write this document in its current form
-- assures a giant gap between pro and amateur. thus we see amateur clubs
-- with no hope of building up to pro and pro sides that have no graceful
-- way to back off for a year or two").  Words only.
BEGIN;
UPDATE message_templates
   SET body = 'This document is placed here, between the APSL and the pro leagues, functionally and symbolically: it currently acts as a block, but it should act as a bridge. In its current form it assures a giant gap between pro and amateur. Thus we see amateur clubs with no hope of building up to pro, and pro sides that have no graceful way to back off for a year or two.'
 WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_bridge';
COMMIT;
