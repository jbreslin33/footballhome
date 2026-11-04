-- 1066: RSVP total on every player card (owner 2026-11-04: "show on the
-- cards rsvp totals 'R:27' etc").  GET /api/payments/standing sends
-- rsvpTotal (every RSVP on record, games and practices — the number the
-- boards rank by); PersonStanding's card chip shows it before the last-RSVP
-- date.  Copy rows here.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Person standing', v.label, 'person_standing', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Card chip — RSVP total', 'chip_rsvp_total', 'R:{n}', 30),
    ('Card chip tooltip — RSVP total', 'chip_rsvp_total_tip', '{n} RSVPs on record — games and practices', 31)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'person_standing' AND m.tier = v.tier);
