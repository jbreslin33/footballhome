-- 1051: winter U9 team (owner 2026-11-04: "add a u9 team for winter and
-- then of course move to NOT ON ROSTER all u9 and under").  Winter youth is
-- now U9 / U10 / U12 (mig 1046 had U10 + U12).
--   • New team "U9" copied from winter U10 (942): boys/girls section 3,
--     division 76, games_need_roster, LA Boys + Girls membership
--     requirements, winter term, James as coach, board order just before
--     U10; calendar tag "u9 winter" moves to it.
--   • Every winter kid aged 9 and under (US Club Soccer 2026-27 chart,
--     fh_youth_us_age) not On Roster moves U10 → U9, where the youth rule
--     makes him 🏋 Practice Squad with no status: Roster pill NOT ON ROSTER,
--     Team pill PRACTICE SQUAD.  The 12 ACTIVE U10 kids (mig 1050) are all
--     U10 and stay.

BEGIN;

UPDATE teams SET board_sort_order = board_sort_order + 1 WHERE board_sort_order >= 6 AND club_id = 134;

INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home)
SELECT division_id, club_id, 'U9', is_pool, gender_category, roster_source, '❄️ U9', '❄️ U9', color,
       6, mutex_group, true, club_section_id, is_travel, lineup_everyone_plays,
       rsvp_board, games_need_roster, league_roster, false
  FROM teams WHERE id = 942
   AND NOT EXISTS (SELECT 1 FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
                    WHERE t.name = 'U9' AND t.is_active AND t.gender_category IN ('boys', 'girls'));

CREATE TEMP TABLE new_u9 ON COMMIT DROP AS
SELECT t.id FROM teams t WHERE t.name = 'U9' AND t.label = '❄️ U9' AND t.is_active ORDER BY t.id DESC LIMIT 1;

INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'winter', false FROM new_u9 ON CONFLICT DO NOTHING;
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT n.id, r.la_program_id FROM new_u9 n, team_membership_requirements r WHERE r.team_id = 942 ON CONFLICT DO NOTHING;
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT n.id, tc.coach_id, tc.coach_role_id FROM new_u9 n, team_coaches tc WHERE tc.team_id = 942 AND tc.ended_at IS NULL;
UPDATE gcal_team_aliases SET team_id = (SELECT id FROM new_u9), notes = 'mig 1051'
 WHERE club_alias = 'boys' AND team_alias = 'u9 winter';

-- Re-place the winter kids aged 9 and under who are not On Roster.
CREATE TEMP TABLE winter_moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.person_id, tp.roster_status_id,
       fh_youth_fit_team(fh_youth_us_age(p.birth_date), 'winter') AS to_team, tp.team_id AS from_team
  FROM team_persons tp
  JOIN persons p ON p.id = tp.person_id AND p.birth_date IS NOT NULL
  LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
 WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 942)
   AND NOT COALESCE(rs.counts_as_on_roster, false);
DELETE FROM winter_moves WHERE to_team IS NULL OR to_team = from_team;

UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1051, 'why', 'winter U9 added')
  FROM winter_moves m WHERE tp.id = m.tp_id;

INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT DISTINCT m.to_team, m.person_id, m.roster_status_id FROM winter_moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);

COMMIT;
