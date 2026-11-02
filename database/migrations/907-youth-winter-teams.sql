-- 907 (2026-10-30) — Winter youth teams: U10, U13, U16, U19, auto-filled.
--
-- Owner 2026-10-30: "for winter lets do u19, u16, u13, u10", "and auto fill
-- them but 'official roster' is empty because we are not in league yet".
--
-- The three empty PPR Indoor teams (mig 788) become U13, U16 and U10, and U19
-- is new: winter needs its own teams because a kid's age group differs by
-- season (a 13-year-old is U19 in fall, U13 in winter).  Each member holds
-- one fall team and one winter team.  They are games_need_roster, and with
-- no official list everyone is Not on Roster until marked.
--
-- A team's season is team_terms, so anything choosing a team by age must
-- look at the term too: fh_youth_place fills fall and winter, and spring
-- runs on the fall teams.  New Google Calendar tags: "u10 winter" etc.
UPDATE teams SET name = 'U10', label = '❄️ U10', short_label = '❄️ U10', board_sort_order = 6, max_roster = NULL, games_need_roster = true WHERE id = 942;
UPDATE teams SET name = 'U13', label = '❄️ U13', short_label = '❄️ U13', board_sort_order = 7, max_roster = NULL, games_need_roster = true WHERE id = 940;
UPDATE teams SET name = 'U16', label = '❄️ U16', short_label = '❄️ U16', board_sort_order = 8, max_roster = NULL, games_need_roster = true WHERE id = 941;

INSERT INTO teams (division_id, club_id, name, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel,
                   rsvp_board, uniform_set_id, lineup_everyone_plays, games_need_roster)
SELECT division_id, club_id, 'U19', gender_category, roster_source, '❄️ U19', '❄️ U19', '#be123c',
       9, mutex_group, true, club_section_id, is_travel,
       rsvp_board, uniform_set_id, lineup_everyone_plays, true
  FROM teams WHERE id = 942
   AND NOT EXISTS (SELECT 1 FROM teams x WHERE x.division_id = teams.division_id AND x.name = 'U19');

INSERT INTO team_terms (team_id, term)
SELECT id, 'winter' FROM teams t WHERE t.division_id = 76 AND t.name = 'U19'
ON CONFLICT DO NOTHING;

INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, r.la_program_id
  FROM teams t CROSS JOIN (SELECT la_program_id FROM team_membership_requirements WHERE team_id = 912) r
 WHERE t.division_id = 76 AND t.name ~ '^U[0-9]+$'
ON CONFLICT DO NOTHING;

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', lower(t.name) || ' winter', t.id, 'mig 907' FROM teams t WHERE t.division_id = 76 AND t.name ~ '^U[0-9]+$'
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_youth_place(p_person_id int) RETURNS void
LANGUAGE sql AS $$
    INSERT INTO team_persons (team_id, person_id)
    SELECT DISTINCT t.id, p.id
      FROM persons p
      CROSS JOIN (VALUES ('fall'), ('winter')) AS season(term)
      CROSS JOIN LATERAL (
        SELECT t.id FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = season.term
         WHERE t.is_active AND t.gender_category IN ('boys', 'girls') AND t.name ~ '^U[0-9]+$'
           AND fh_team_age(t.id) >= fh_youth_single_age(p.birth_date,
                 extract(year FROM now() AT TIME ZONE 'America/New_York')::int
                 + CASE WHEN extract(month FROM now() AT TIME ZONE 'America/New_York') >= 6 THEN 1 ELSE 0 END)
         ORDER BY fh_team_age(t.id), t.id LIMIT 1) t
     WHERE p.id = p_person_id AND p.birth_date IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM team_persons x
                         JOIN teams xt ON xt.id = x.team_id
                         JOIN team_terms xtt ON xtt.team_id = xt.id AND xtt.term = season.term
                        WHERE x.person_id = p.id AND x.removed_at IS NULL AND xt.is_active
                          AND xt.gender_category IN ('boys', 'girls'));
$$;

SELECT fh_youth_place(m.person_id)
  FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
 WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('boys', 'girls');
