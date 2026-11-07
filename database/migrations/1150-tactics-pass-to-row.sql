-- 1150 (2026-11-06): Tactics 🧠 — a "⚽ Pass to:" row of their numbers above
-- the pitch (owner 11/6: "can i move the ball to the 4 or 5 for next
-- step?").  Tapping their chip already did it; this makes it visible.  A
-- new pass copies the jobs of the one before, so only changed jobs need a
-- dropdown.  Copy rows only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Tactics', v.label, 'tactics', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Pass row — label',   'pass_to',      '⚽ Pass to:', 1238),
    ('Pass row — new',     'pass_to_new',  'New pass: starts with the same jobs as now — change only who changes.', 1239)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.tier);
