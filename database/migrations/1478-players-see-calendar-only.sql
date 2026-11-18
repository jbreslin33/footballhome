-- 1478 (2026-11-18) — Players and parents see the 📅 Calendar only.
-- Owner 11/18: "i think for now players/parents who are not coaches or admin
-- only need calendar right?" → "game is not ready".
--
-- Their menu was 📅 Calendar · ⚽ Game · ⚙️ Files.  Game isn't ready (admins
-- only until it is); Files holds nothing players may open (all 52 files are
-- private / admins), so it moves to coaches + admins — what coaches had.
-- Players / parents: 📅 Calendar + 👤 Account; the 🚦 band, Team Rules,
-- Rosters, Players and Schedules links ride on the Calendar.
UPDATE menu_pages SET audience = 'admin' WHERE code = 'game'  AND audience = 'everyone';
UPDATE menu_pages SET audience = 'coach' WHERE code = 'files' AND audience = 'everyone';
