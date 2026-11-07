-- 1156: Tolu Asekun-Masha (person 22598, Men's 1893) is no longer a
-- Volunteer (owner 2026-11-06: "remove tolu from volunteers").  His LA
-- dues balance applies again: notices, the alternate flag and fines.
DELETE FROM club_volunteers WHERE person_id = 22598;
