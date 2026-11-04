-- 1032: Andy Hizdri (person 3498) → NEEDS DROP on Liga 1 (owner
-- 2026-11-04: "add andy to needs drop for liga 1").  Roster status
-- possible_drop (board_section 'drop') on his Liga 1 (120) row — still on
-- the CASA list, so he stays ↔ Call-in until CASA takes him off; the next
-- 🌐 pull then clears the drop lane (mig 777) and ends his Call-in row
-- (mig 1026).  APSL unchanged.

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'possible_drop')
 WHERE team_id = 120 AND person_id = 3498 AND removed_at IS NULL
   AND EXISTS (SELECT 1 FROM persons WHERE id = 3498 AND first_name = 'Andy' AND last_name = 'Hizdri');
