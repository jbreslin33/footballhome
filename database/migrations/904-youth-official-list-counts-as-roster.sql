-- 904 (2026-10-30) — On the official list is on the roster.
--
-- Mig 899 read the roster status alone, so a kid on the league's list with a
-- blank or Needs Docs status (Gabriel Rivera-Perez, Anastasiya Bembischew)
-- lost their games.  A games_need_roster team now gives games to a status
-- that counts as On Roster OR a name on the team's active official list, and
-- a list change re-reads the team.
CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE on_list boolean;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        on_list := COALESCE((SELECT counts_as_on_roster FROM roster_statuses WHERE id = NEW.roster_status_id), false)
                OR EXISTS (SELECT 1 FROM official_roster_names n
                             JOIN official_roster_sources s ON s.id = n.source_id
                            WHERE s.team_id = NEW.team_id AND s.is_active AND n.person_id = NEW.person_id);
        NEW.invite_only := NOT on_list;
        NEW.call_in     := NOT on_list;
    END IF;
    RETURN NEW;
END $$;

-- Writing the status back runs the row trigger above.
CREATE OR REPLACE FUNCTION fn_official_names_reread_games() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
      FROM teams t WHERE t.id = tp.team_id AND t.games_need_roster AND tp.removed_at IS NULL;
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS official_names_reread_games ON official_roster_names;
CREATE TRIGGER official_names_reread_games
    AFTER INSERT OR UPDATE OR DELETE ON official_roster_names
    FOR EACH STATEMENT EXECUTE FUNCTION fn_official_names_reread_games();

UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
  FROM teams t WHERE t.id = tp.team_id AND t.games_need_roster AND tp.removed_at IS NULL;
