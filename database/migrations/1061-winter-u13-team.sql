-- 1061: winter U13 team (owner 2026-11-04: "lets make a u13 team too.
-- want to see something").  Copied from winter U12 (940): PPR Indoor 5v5,
-- roster 12, match-day squad 12, LA Boys + Girls requirements, James as
-- coach, after U12 on the board, tag "u13 winter".  The age rule
-- (fh_youth_fit_team, youngest team at or above the age) now sends U13s
-- here; the six on U12 move over as 🏋 Practice Squad.  Ranked by RSVPs.

BEGIN;

UPDATE teams SET board_sort_order = board_sort_order + 1
 WHERE club_id = 134 AND board_sort_order > (SELECT board_sort_order FROM teams WHERE id = 940);
INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster, field_size, matchday_squad_size)
SELECT division_id, club_id, 'U13', is_pool, gender_category, roster_source, '❄️ U13', '❄️ U13', color,
       board_sort_order + 1, mutex_group, true, club_section_id, is_travel, lineup_everyone_plays,
       rsvp_board, games_need_roster, league_roster, false, 12, 5, 12
  FROM teams WHERE id = 940
   AND NOT EXISTS (SELECT 1 FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
                    WHERE t.name = 'U13' AND t.is_active AND t.gender_category IN ('boys', 'girls'));
CREATE TEMP TABLE u13 ON COMMIT DROP AS
SELECT id FROM teams WHERE name = 'U13' AND label = '❄️ U13' AND is_active ORDER BY id DESC LIMIT 1;
INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'winter', false FROM u13 ON CONFLICT DO NOTHING;
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT u.id, r.la_program_id FROM u13 u, team_membership_requirements r WHERE r.team_id = 940 ON CONFLICT DO NOTHING;
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT u.id, tc.coach_id, tc.coach_role_id FROM u13 u, team_coaches tc WHERE tc.team_id = 940 AND tc.ended_at IS NULL;
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', 'u13 winter', id, 'mig 1061' FROM u13
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases WHERE club_alias = 'boys' AND team_alias = 'u13 winter');

-- U13s off U12 onto U13 (not the ACTIVE ones — none are U13).
CREATE TEMP TABLE moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.person_id, fh_youth_fit_team(fh_youth_us_age(p.birth_date), 'winter') AS to_team
  FROM team_persons tp JOIN persons p ON p.id = tp.person_id
  LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
 WHERE tp.team_id = 940 AND tp.removed_at IS NULL AND NOT COALESCE(rs.counts_as_on_roster, false);
DELETE FROM moves WHERE to_team IS NULL OR to_team = 940;
UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1061)
  FROM moves m WHERE tp.id = m.tp_id;
INSERT INTO team_persons (team_id, person_id)
SELECT DISTINCT m.to_team, m.person_id FROM moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);

WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           COALESCE(rs.counts_as_on_roster, false) DESC, count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC,
           p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (940, (SELECT id FROM u13))
   GROUP BY tp.id, tp.team_id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;
