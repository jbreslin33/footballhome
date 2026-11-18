-- 1493 (2026-11-18) — Your availability on an event: one line.  Owner 11/18:
-- "too much space for the your availability for this game. too busy. needs
-- to be more concise".
--
--   Going?  [✓ Going] [✗ Not going]     (a parent: a line per kid, by name)
-- The heading (answer_title), the "You · ✅ Going" word and the "Plans
-- changed?" note (answer_note) are no longer drawn; the line under the
-- buttons speaks only when the event is over / not open, or on an error.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Event — your answer: the question', 'answer_q',   'Going?',       1420),
    ('Event — your answer: going',        'answer_yes', '✓ Going',      1421),
    ('Event — your answer: not going',    'answer_no',  '✗ Not going',  1422)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
