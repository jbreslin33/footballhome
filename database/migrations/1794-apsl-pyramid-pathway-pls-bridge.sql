-- 1794 (2026-11-24) — 🔺 #apsl-pyramid "How a club climbs": the PLS document
-- is drawn as its own box ON the line between the APSL and the pro leagues
-- (owner: "this document is placed here between the apsl and the pro
-- leagues functionally and symbolically as it currently acts as a block
-- but should act as a bridge").  Its caption row.  Words only.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — pathway: PLS block / bridge', 'apsl_pyramid', 'path_pro_bridge',
       'This document is placed here, between the APSL and the pro leagues, functionally and symbolically: it currently acts as a block, but it should act as a bridge.', 123, true, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'path_pro_bridge');
COMMIT;
