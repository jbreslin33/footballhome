-- 1483 (2026-11-18) — ☰ in the band: the menu, by viewer class.  Owner 11/18:
-- "i think a hamburger thingy then the other stuff would be there? like rules
-- etc. because for players we want less options and clean interface. for
-- admin it will extend base class with more stuff".
--
-- ☰ at the band's right end (after 💬) opens a menu popup built from
-- Viewer.account().menuItems() (lib/viewer.js): PlayerViewer = 📋 Rules &
-- fines · 🔔 Alerts · ↪ Sign out; CoachViewer / AdminViewer extend it
-- (super.menuItems() + 👤 Account for now).  The one-row links (mig 1481) go.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('☰ menu — title',          'sheet_menu',    '☰ Menu',     1417),
    ('☰ menu — staff account',  'qlink_account', '👤 Account', 1418)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
