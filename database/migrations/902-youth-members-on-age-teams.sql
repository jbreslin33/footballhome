-- 902 (2026-10-30) — Every LeagueApps youth member sits on their age team.
--
-- Owner 2026-10-30: "all kids that are members in la should show in their
-- age cat on roster and teams pills as eiter on roster, not on roster,
-- proposed add, or whatever. there are 49 boys and 13 girls. so we sjhould
-- seee exactly 62 unique names".
--
-- Mig 899 left three members in Unassigned.  fh_youth_place puts a member
-- with no youth team on the smallest age team that fits, as a Call In (mig
-- 899: every practice, a game only by invite), and a new active boys/girls
-- membership runs it, so Unassigned is only for a member with no birth date.
-- Same age rule as WelcomeMessage's guess.
CREATE OR REPLACE FUNCTION fh_youth_place(p_person_id int) RETURNS void
LANGUAGE sql AS $$
    INSERT INTO team_persons (team_id, person_id)
    SELECT t.id, p.id
      FROM persons p
      CROSS JOIN LATERAL (
        SELECT t.id FROM teams t
         WHERE t.is_active AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$'
           AND fh_team_age(t.id) >= fh_youth_single_age(p.birth_date,
                 extract(year FROM now() AT TIME ZONE 'America/New_York')::int
                 + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END)
         ORDER BY fh_team_age(t.id), t.id LIMIT 1) t
     WHERE p.id = p_person_id AND p.birth_date IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN teams xt ON xt.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL AND xt.is_active
                          AND xt.gender_category IN ('boys', 'girls'));
$$;

CREATE OR REPLACE FUNCTION fn_youth_place_on_membership() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.ended_at IS NULL AND EXISTS (SELECT 1 FROM leagueapps_programs lp
                                         WHERE lp.program_id = NEW.la_program_id
                                           AND lp.variant = 'active' AND lp.category IN ('boys', 'girls')) THEN
        PERFORM fh_youth_place(NEW.person_id);
    END IF;
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS trg_youth_place_on_membership ON person_la_memberships;
CREATE TRIGGER trg_youth_place_on_membership
    AFTER INSERT ON person_la_memberships
    FOR EACH ROW EXECUTE FUNCTION fn_youth_place_on_membership();

SELECT fh_youth_place(m.person_id)
  FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
 WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('boys', 'girls');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', 'Team boards — youth Roster pill: on the team, not on the roster', 'roster_sheet', 'board_not_on_roster_h',
       NULL, 'NOT ON ROSTER', 0, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'board_not_on_roster_h');
