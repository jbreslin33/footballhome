-- 1059: Maya Rodriguez (22707) and Ava Smalley (22713) 💤 Inactive (owner
-- 2026-11-04: "move maya and ava to inactive").  Inactive is one per
-- section (mig 1009): Boys/Girls (3) — fall U12 and winter U12 both.
-- Their winter U12 On Roster (mig 1056) is cleared so they don't count
-- toward its 12.

BEGIN;

INSERT INTO person_section_squad_statuses (person_id, club_section_id, squad_status_id)
SELECT p.id, 3, (SELECT id FROM squad_statuses WHERE code = 'inactive')
  FROM persons p WHERE p.id IN (22707, 22713)
ON CONFLICT (person_id, club_section_id) DO UPDATE SET squad_status_id = EXCLUDED.squad_status_id, set_at = now();

UPDATE team_persons SET roster_status_id = NULL
 WHERE team_id = 940 AND removed_at IS NULL AND person_id IN (22707, 22713);

COMMIT;
