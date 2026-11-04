-- 1028: Team pill drops ⚠ WANTS IN (owner 2026-11-04: "I don't want a
-- wants in section … cleaner like with the 'needs ad' from roster
-- mirror").  ACTIVE is one list again; men the Roster pill has in an add
-- lane show under 🟢 NEEDS ADD (board_needs_add_h, one sub-group per
-- step), still RSVPing.  The two ACTIVE sub-headings are retired; the
-- small "not on the list" card chip stays.
--   Cole Vennis (22771): Liga 1 → Needs Add (soon on the CASA sheet; the
--     🌐 pull moves him to On Roster).
--   James Breslin (1): 💤 Inactive as a player (Men's section, mig 1009 —
--     all his Men's player rows).

BEGIN;

UPDATE message_templates SET is_active = false
 WHERE kind = 'roster_sheet' AND tier IN ('board_listed_sub', 'board_wants_in_sub');

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_add')
 WHERE team_id = 120 AND person_id = 22771 AND removed_at IS NULL
   AND EXISTS (SELECT 1 FROM persons WHERE id = 22771 AND first_name = 'Cole' AND last_name = 'Vennis');

INSERT INTO person_section_squad_statuses (person_id, club_section_id, squad_status_id)
SELECT 1, 1, (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 1 AND first_name = 'James' AND last_name = 'Breslin')
ON CONFLICT (person_id, club_section_id) DO UPDATE SET squad_status_id = EXCLUDED.squad_status_id, set_at = now();

COMMIT;
