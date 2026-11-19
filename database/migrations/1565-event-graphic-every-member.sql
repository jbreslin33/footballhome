-- 1565 (2026-11-19) — Event graphic lists every member: 🪑 Reserves, 🩹 Injured, ⛔ Suspended.
-- Owner, on the Thu 11/19 APSL + Liga 1 practice: "i am admin why do i not
-- see inactive" → "dont hide anythng" → "i cant see it on gprhic" → "i
-- should see all mens members for liga 1" → "like even ghosts right" →
-- "yes that is it they are reserves".  Under the pitch, staff now get
-- No response · Not going · 🪑 Reserves (Reserve rows + never-answered) ·
-- 🩹 Injured · ⛔ Suspended · 💤 Inactive.  All 65 on that practice now
-- appear on the graphic (Fathy Elhadidy, injured, was the one missing).
-- Every fold on event pages starts open (frontend, commit 14b1974d).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', 'Event graphic: suspended row under the pitch (staff)', 'event_center', 'sec_suspended_card', '⛔ Suspended', 900, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'sec_suspended_card');
