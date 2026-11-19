-- 1555 (2026-11-19) — 🤝 Committed counts practices: P3 on the box, the tiebreak in each group.
--
-- Owner: "commited should also factor in number of practices attended in
-- last 2 weeks? or what do you think?" → "yes build it".
--   · /api/payments/standing sends practicesRecent = present / late marks
--     on practices that started in the last practice_days (14)
--   · 🤝 Committed: up to date → behind RSVP → behind dues → behind both,
--     and INSIDE each group most practices first, then A–Z (0 practices
--     stays in its group, at the bottom of it)
--   · the #teams box's top line: RSVP · P3
ALTER TABLE rsvp_box_policy ADD COLUMN IF NOT EXISTS practice_days integer NOT NULL DEFAULT 14;
COMMENT ON COLUMN rsvp_box_policy.practice_days IS
  'mig 1555: window for the #teams box P<n> and the 🤝 Committed tiebreak — practices attended (present/late) in the last N days.';

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Person standing', v.label, 'person_standing', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('box_practices',     'Team card box: practices attended lately ({n})', 'P{n}', 77),
    ('box_practices_tip', 'Team card box: practices attended — hover', 'Came to {n} practices in the last {days} days', 78)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'person_standing' AND m.tier = v.tier);
