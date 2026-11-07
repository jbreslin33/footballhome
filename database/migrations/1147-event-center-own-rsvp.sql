-- 1147: Event Center — your own card answers for you (owner 2026-11-06:
-- "you should be able to set going or not going for yourself from event
-- center … on the card … and it should show your status").  ✓/✗ on the
-- caller's card for anyone while the event is open; a YOU chip and the
-- answer in words.  Copy rows only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.category, v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event Center', 'Own card — chip',              'me_chip',        'YOU',                       1220),
    ('Event Center', 'Own card — status, going',     'me_status_yes',  '✓ You''re going',           1221),
    ('Event Center', 'Own card — status, not going', 'me_status_no',   '✗ You''re not going',       1222),
    ('Event Center', 'Own card — status, no answer', 'me_status_none', 'You haven''t answered yet', 1223)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
