-- 1395 (2026-11-16) — the 🗓️ This Week menu group is called 📅 Calendar.
-- Owner: "why does it still say this week insstead of calendar" — after the
-- one-page fold (migs 1388/1391) the group's main page IS the Calendar.
-- The code stays 'week' (menu_pages.group_code, localStorage last-page keys).
UPDATE menu_groups SET label = 'Calendar', icon = '📅' WHERE code = 'week';
