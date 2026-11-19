-- 1515 (2026-11-18) — Staff tap a name on an event card (practice, pickup,
-- barn night …) → a person sheet: ✅ attendance on top from the event's day
-- (owner 11/18 "if we click a player during start of practice or game it
-- adds in attendance option"), then 📇 Contact and ⋯ the player sheet.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event card person sheet — contact',      'person_contact', '📇 Contact',      1434),
    ('Event card person sheet — player sheet', 'person_sheet',   '⋯ Player sheet', 1435)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
