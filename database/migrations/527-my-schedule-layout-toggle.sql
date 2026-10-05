-- 527 (2026-10-05) — #my: the plain list stays available next to the day
-- cells.  Owner, after the calendar layout (mig 523): "maybe we can also
-- give the old view too by leaving that option in there? as a toggle?"
-- Two small buttons by the range picker switch between the day cells and
-- the list as it was (one card after another, no day boxes); the choice is
-- remembered on the device.  Their words:
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'my_schedule', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES ('layout_days', 'My schedule — layout: day cells', '📅 Calendar', 34),
               ('layout_list', 'My schedule — layout: plain list', '☰ List',     35)) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_schedule' AND m.tier = v.tier);
