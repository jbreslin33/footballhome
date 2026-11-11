-- 1253: #payments (Tuition) hides LA pickup-program members by default
-- (owner 2026-11-11: "why are we showing pickup guys on tuition? i can see
-- having a pill for them but by default?").  Mig 1240 folded them into
-- their section with a 🔁 Pickup chip; now one 🔁 Pickup pill under the
-- section pills shows / hides them (list, status counts and stats follow).
-- Display only — fh_dues_balance_usd still counts pickup (mig 1240).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Payments', v.l, 'payments_overview', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Tuition — pickup pill, hidden ({n})',  'pickup_toggle_off',   '🔁 Pickup · {n} hidden', 1253),
    ('Tuition — pickup pill, showing ({n})', 'pickup_toggle_on',    '🔁 Pickup · showing {n}', 1254),
    ('Tuition — pickup pill tooltip',        'pickup_toggle_title', 'Members whose LA registration is in the pickup program — tap to show or hide', 1255)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'payments_overview' AND m.tier = v.t);
