-- 1210 (2026-11-10) — #payments (Tuition): fine disputes on the card front.
-- Owner: "on tuition screen show the total fines for a player from the
-- "last" month friday to friday. then in parens show the amount if we
-- minus off the ones they disputed" … "on their card click a button on
-- front to accept or deny dispute".
-- The last finished period's fines box reads "$10 ($5)" while a dispute is
-- pending; a ⚖️ strip under the card header carries Approve / Deny (the
-- same POST /api/fines/disputes/:id as #fines; Approve marks present, mig
-- 691).  The strip's line and buttons reuse the 'fines' copy rows from mig
-- 691; only the words new to this screen live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Tuition', l, 'tuition_bill', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('disputed_big', 'Fines box — total with the pending-dispute amount off ({total} {left})',
                     '{total} ({left})', 820),
    ('disputed_tip', 'Fines box tooltip — pending disputes ({disputed} {left})',
                     '{disputed} under dispute — {left} if approved', 821)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tuition_bill' AND m.tier = v.t);
