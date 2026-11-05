-- 1078: fix a mig-1074 regression.  On a games-need-roster (youth) team the
-- roster trigger re-decides ACTIVE vs Practice Squad on every Roster-status
-- write, and it only left alone statuses that were NOT per team.  1074 made
-- Inactive per team, so the next roster write (the #teams auto pull) wiped
-- youth Inactive: Yousef Mouneeb (22660, fall U10 → ACTIVE, ❄️ U10 →
-- Practice Squad), Maya Rodriguez (22707) and Ava Smalley (22713) (fall +
-- ❄️ U12 → Practice Squad).  The trigger now re-decides only rows with no
-- status or Practice Squad; Inactive (and anything else) stays.  The three
-- are Inactive again on all their youth teams, as migs 1053/1059 set them.
-- Men's teams were never affected (no games-need-roster).

BEGIN;

CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE plays boolean; ps integer;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        SELECT id INTO ps FROM squad_statuses WHERE code = 'practice_squad';
        -- Only "no status" vs Practice Squad is the roster's call; 💤
        -- Inactive is the coach's and survives every roster write.
        IF NEW.squad_status_id IS NULL OR NEW.squad_status_id = ps THEN
            plays := COALESCE((SELECT counts_as_on_roster OR board_section IN ('proposed', 'pending_add', 'no_room')
                                      OR code = 'suspended'
                                 FROM roster_statuses WHERE id = NEW.roster_status_id), false)
                  OR EXISTS (SELECT 1 FROM official_roster_names n
                               JOIN official_roster_sources s ON s.id = n.source_id
                              WHERE s.team_id = NEW.team_id AND s.is_active AND n.person_id = NEW.person_id);
            NEW.squad_status_id := CASE WHEN plays THEN NULL ELSE ps END;
        END IF;
        NEW.invite_only := NEW.squad_status_id IS NOT NULL;
        NEW.call_in     := false;
    END IF;
    RETURN NEW;
END $$;

UPDATE team_persons tp
   SET squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive'),
       invite_only = true, call_in = false
  FROM teams t
 WHERE t.id = tp.team_id AND t.club_section_id = 3
   AND tp.removed_at IS NULL AND tp.person_id IN (22660, 22707, 22713);

COMMIT;
