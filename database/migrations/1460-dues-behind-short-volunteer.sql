-- 1460 (2026-11-18) — 📅 Calendar notices: behind on dues = ONE short line,
-- Pay here or 🙋 Volunteer.  Owner 11/18: "i like the volunteer spot on
-- calendar. but i think it needs to be shorter message stating they are
-- behind and need to fix and to pay here or to volunteer and let them know
-- volunteer button contains more info."
--
-- When the viewer's own dues notice and a volunteer offer (no pick yet) are
-- both up, lib/notices.js draws behind_short with two buttons; the full
-- volunteer card (rules, tick, days) unfolds from 🙋 Volunteer.  Every other
-- case keeps the existing my_dues tiers.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.label, 'my_dues', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar notice — behind on dues, pay or volunteer', 'behind_short',
     'You''re behind on dues ({amount} owed) — fix it now: pay it, or volunteer one evening a week. Tap 🙋 Volunteer for the details.', 40),
    ('Calendar notice — the volunteer button', 'volunteer_button', '🙋 Volunteer', 41)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_dues' AND m.tier = v.tier);
