-- 1516 (2026-11-19) — Marked Present / Late without saying Going → the
-- event card puts them on the pitch, the box tagged with what they said
-- (owner 11/19 "if we say that a player attended who was no response or not
-- going we need to put them on pitch. but show that they set not going but
-- went or no response but went").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event card box tag — said Not going, came', 'card_came_notgoing', '✗ said no',  1436),
    ('Event card box tag — no response, came',    'card_came_noresp',   '– no reply', 1437)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
