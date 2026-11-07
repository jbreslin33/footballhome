-- 1148: Event Center — a guardian answers for their child right on the
-- week tile and on the child's card in the event (owner 2026-11-06: "same
-- with grace for me. i should be able to set hers on event center as can
-- anyone connected to them").  Rows come from the feed's guardian_targets
-- (fh_is_guardian — every guardian of the child); the write is the same
-- POST /api/calendar/rsvp with person_id #my's guardian rows make.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.category, v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event Center', 'Child row — status, going',     'kid_status_yes',  '✓ {name} is going',            1224),
    ('Event Center', 'Child row — status, not going', 'kid_status_no',   '✗ {name} is not going',        1225),
    ('Event Center', 'Child row — status, no answer', 'kid_status_none', '{name} hasn''t answered yet',  1226),
    ('Event Center', 'Child card — chip',             'kid_chip',        'YOUR PLAYER',                  1227)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
