-- 1033: youth Needs Add sees games, like Men (owner 2026-11-04: "they
-- should work the same way like men. practice squad is deliberate. we
-- want them to see practice and not games. needs ad lets them see games
-- so we can decide to add them if available").
-- The youth rule (fh_team_persons_games_need_roster, mig 1031) now gives a
-- full spot to a kid on the team's league list OR on an add step of the
-- Roster pill (roster_statuses.board_section proposed / pending_add /
-- no_room: Needs Add, Needs Docs, Has Docs, ITC/transfer, Awaiting
-- Approval).  Only a kid on neither stays 🏋 Practice Squad.
-- Applied now: re-reading the youth rows moves the one U8 Needs Docs kid.

BEGIN;

CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE plays boolean; ps integer; sec boolean;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        plays := COALESCE((SELECT counts_as_on_roster OR board_section IN ('proposed', 'pending_add', 'no_room')
                             FROM roster_statuses WHERE id = NEW.roster_status_id), false)
              OR EXISTS (SELECT 1 FROM official_roster_names n
                           JOIN official_roster_sources s ON s.id = n.source_id
                          WHERE s.team_id = NEW.team_id AND s.is_active AND n.person_id = NEW.person_id);
        SELECT id INTO ps FROM squad_statuses WHERE code = 'practice_squad';
        sec := NEW.squad_status_id IS NOT NULL
               AND NOT COALESCE((SELECT per_team FROM squad_statuses WHERE id = NEW.squad_status_id), false);
        IF NOT sec THEN
            NEW.squad_status_id := CASE WHEN plays THEN NULL ELSE ps END;
        END IF;
        NEW.invite_only := NEW.squad_status_id IS NOT NULL;
        NEW.call_in     := false;
    END IF;
    RETURN NEW;
END $$;

UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
  FROM teams t WHERE t.id = tp.team_id AND t.games_need_roster AND tp.removed_at IS NULL;

COMMIT;
