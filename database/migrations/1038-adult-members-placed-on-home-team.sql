-- 1038: a new adult member lands on his section's home team (owner
-- 2026-11-04: "get rid of that left column … by default put new players
-- in needs onboard for liga1 and for youth just dump in age fit").
-- Youth already do (fh_youth_place, migs 902/1034).  Now a new active
-- men's / women's LeagueApps membership puts the person on the
-- not_on_roster_home team of that gender (mig 1037: Men → Liga 1 120;
-- Women → the Women's team 901, flagged here) when he is on no active team
-- of that gender.  A full spot: he has never answered an RSVP, so the
-- Team pill shows him under NEEDS ONBOARD; the Roster pill under that
-- team's NOT ON ROSTER.  With every member placed, #teams drops its left
-- Unassigned column.

BEGIN;

UPDATE teams SET not_on_roster_home = true WHERE id = 901;
COMMENT ON COLUMN teams.not_on_roster_home IS
  'mig 1037/1038: the home team of its gender — a new adult LeagueApps member is placed here (fh_adult_place), and the #teams Roster pill lists the board''s members on no league roster under it. No such team on a board = each under his own team (youth: age group).';

CREATE OR REPLACE FUNCTION fh_adult_place(p_person_id integer, p_category text) RETURNS void
LANGUAGE sql AS $$
    INSERT INTO team_persons (team_id, person_id)
    SELECT t.id, p_person_id
      FROM teams t
     WHERE t.is_active AND t.not_on_roster_home AND t.gender_category = p_category || 's'
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN teams xt ON xt.id = x.team_id
                        WHERE x.person_id = p_person_id AND x.removed_at IS NULL
                          AND xt.is_active AND xt.gender_category = p_category || 's')
     ORDER BY t.id LIMIT 1;
$$;
COMMENT ON FUNCTION fh_adult_place(integer, text) IS
  'mig 1038: put a men''s / women''s member with no team of that gender on its home team (teams.not_on_roster_home).';

CREATE OR REPLACE FUNCTION fn_adult_place_on_membership() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE cat text;
BEGIN
    IF NEW.ended_at IS NULL THEN
        SELECT lp.category INTO cat FROM leagueapps_programs lp
         WHERE lp.program_id = NEW.la_program_id AND lp.variant = 'active' AND lp.category IN ('men', 'women');
        IF cat IS NOT NULL THEN PERFORM fh_adult_place(NEW.person_id, cat); END IF;
    END IF;
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS trg_adult_place_on_membership ON person_la_memberships;
CREATE TRIGGER trg_adult_place_on_membership
    AFTER INSERT ON person_la_memberships
    FOR EACH ROW EXECUTE FUNCTION fn_adult_place_on_membership();

-- Anyone active and unplaced today (none on 11/4).
SELECT fh_adult_place(m.person_id, lp.category)
  FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
 WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('men', 'women');

COMMIT;
