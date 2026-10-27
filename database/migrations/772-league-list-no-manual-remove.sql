-- 772 (2026-10-27) — a player on his team's league list can't be taken
-- off that team by hand.
--
-- Owner: "i should not be able to remove a guy from official that is done
-- at league level but i can add them to non roster on any team" … "i can
-- move them but not OFF that official roster".  The #teams card drops its
-- Unassigned option for him (RosterScreenBase.renderMoveDropdown); this is
-- the server half.  Every manual remove (MensTeamAssignments, used by the
-- mens/boys/womens boards, and TeamRoster) closes the row with
-- removed_reason 'admin_remove' — LA sync, merges and migrations use
-- other reasons and are untouched.  Adding him to other teams is
-- unaffected (multi-team rows).

CREATE OR REPLACE FUNCTION fh_on_league_list(p_team_id INT, p_person_id INT)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
    SELECT EXISTS (
        SELECT 1 FROM official_roster_sources s
          JOIN official_roster_names n ON n.source_id = s.id
         WHERE s.is_active AND s.team_id = p_team_id AND n.person_id = p_person_id)
$$;
COMMENT ON FUNCTION fh_on_league_list(INT, INT) IS 'mig 772: is this person on the team''s own league list (official_roster_names via its active source)?';

CREATE OR REPLACE FUNCTION fh_team_persons_league_list_guard()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.removed_at IS NULL AND NEW.removed_at IS NOT NULL
       AND NEW.removed_reason = 'admin_remove'
       AND fh_on_league_list(NEW.team_id, NEW.person_id) THEN
        RAISE EXCEPTION 'On the league''s own roster for this team — only the league can take him off (he can still be added to other teams)';
    END IF;
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS team_persons_league_list_guard ON team_persons;
CREATE TRIGGER team_persons_league_list_guard
    BEFORE UPDATE OF removed_at ON team_persons
    FOR EACH ROW EXECUTE FUNCTION fh_team_persons_league_list_guard();

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — league list name whose FH person is not on this team', 'roster_sheet', 'board_official_off_team', NULL, 'not on this team in Football Home', 932, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_official_off_team');
