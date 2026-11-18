-- 1479 (2026-11-18) — Players and parents: no menu bar.  Owner 11/18: "i
-- think for now players/parents who are not coaches or admin only need
-- calendar right?" → "i don't even think they need account".
--
-- With the Calendar their only page (mig 1478), the top bar (groups + 👤
-- Account) is hidden for anyone who isn't a coach / admin / marketing
-- (lib/main-menu.js).  Account held Logout + Tactical Board for them; Sign
-- out moves to the Calendar's 👤 Mine links.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', 'Calendar 👤 Mine — sign out', 'event_center', 'link_sign_out', NULL, 'Sign out', 1407, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = 'link_sign_out');
