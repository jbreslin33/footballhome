-- 1053: Yousef Mouneeb (person 22660) 💤 Inactive (owner 2026-11-04: "never
-- said to put yousef in active lol. he should be inactive").  He showed
-- ACTIVE on fall U10 (913) from an older On Roster status (not on the U10
-- list file).  Inactive is one per section (mig 1009): Boys/Girls (3), so
-- his fall U10 and winter U9 rows both go Inactive — no RSVP asks, still
-- billed.  His roster status is left as it was.

INSERT INTO person_section_squad_statuses (person_id, club_section_id, squad_status_id)
SELECT 22660, 3, (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22660 AND first_name = 'Yousef' AND last_name = 'Mouneeb')
ON CONFLICT (person_id, club_section_id) DO UPDATE SET squad_status_id = EXCLUDED.squad_status_id, set_at = now();
