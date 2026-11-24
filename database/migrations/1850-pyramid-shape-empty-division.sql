-- 1850 (2026-11-24) — 🔺 Spin the pyramid: a pro division with no league on the calendar being
-- shown keeps its step, empty, when divisions above and below it have one.  Owner: "usl
-- champtionsip and usl league one are spring to fall so if that is not selected then level
-- under mls is empty right? and level 3 would only have mls next pro".  Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT m.category, 'Spin view: a division with no league on this calendar', 'apsl_pyramid', 'shape_empty_level', NULL, 'No league plays this division on this calendar', m.sort_order + 1, true, true, m.is_public
  FROM message_templates m
 WHERE m.kind = 'apsl_pyramid' AND m.tier = 'shape_hint'
   AND NOT EXISTS (SELECT 1 FROM message_templates x WHERE x.kind = 'apsl_pyramid' AND x.tier = 'shape_empty_level');
