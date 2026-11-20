-- 1625 (2026-11-20) — 📊 Dashboard moves from the Calendar group to Club.
-- Owner 11/20: "dashboard is under calendar. it should be under club?"
-- (menu review: "what can be rooted out … improved … and what needs moving").
UPDATE menu_pages SET group_code = 'club', sort_order = 0 WHERE code = 'dashboard';
