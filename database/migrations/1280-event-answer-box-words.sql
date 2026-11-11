-- 1280 (2026-11-11) — "Your availability" box on every Event Center event.
--
-- Owner 2026-11-11: "they should look the same except where they need to
-- look diff as events".  Game Center's YOUR AVAILABILITY box (Going / Not
-- Going for you + each kid, or 🙋 call-in) moved into EventScreen, so a
-- practice, a pickup and any other event carry it too.  {what} = game /
-- practice / pickup / event.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('answer_title',    'Your answer box — title ({what})',             'Your availability for this {what}', 910),
    ('answer_note',     'Your answer box — line under the buttons',      'Plans changed? Change it here any time — the coaches see it right away.', 911),
    ('answer_over',     'Your answer box — event finished ({what})',     'This {what} is over', 912),
    ('answer_not_open', 'Your answer box — answers not open ({what})',   'Availability is not open for this {what} yet', 913)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'event_center' AND t.tier = v.tier);
