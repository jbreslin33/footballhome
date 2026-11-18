-- 1481 (2026-11-18) — Players / parents: one small row of links under the
-- band, not buried in 👤 Mine under the calendar.  Owner 11/18: "the stuff at
-- bottom. teamrules, rosters etc. where should that go?" → "feel like it needs
-- to be small and 1 row on phone. its buried being under cal" → "i think
-- rules is all we need now. rosters and players are not needed. schedules
-- honestly is what cal is for. signout should be top right right?"
--
--   📋 Rules · ⚖️ Fines · 🔔 Alerts                          ↪ Sign out
-- On every screen for PlayerViewer (lib/viewer.js showsQuickLinks); Fines and
-- Alerts open in the band's popup; 👤 Mine leaves the player Calendar.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Player links row — team rules', 'qlink_rules',   '📋 Rules',    1412),
    ('Player links row — fines',      'qlink_fines',   '⚖️ Fines',    1413),
    ('Player links row — alerts',     'qlink_alerts',  '🔔 Alerts',   1414),
    ('Player links row — sign out',   'qlink_signout', '↪ Sign out',  1415),
    ('Status popup — alerts title',   'sheet_alerts',  '🔔 Alerts',   1416)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
