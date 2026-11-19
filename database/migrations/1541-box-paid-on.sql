-- 1541 (2026-11-19) — #teams team-card box: the last payment's date after
-- the dues (owner: "also would like a date paid").  Admins only — the box
-- line is PersonStanding (admin-gated) and the board's lastPaidAt is now
-- stripped for everyone else (RosterBoardExtras::redactForViewer).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Person standing', v.label, 'person_standing', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('box_paid_on',     'Team card box: last payment date ({date})', '{date}', 80),
    ('box_paid_on_tip', 'Team card box: last payment date — hover',  'Last payment {date}', 81)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'person_standing' AND m.tier = v.tier);
