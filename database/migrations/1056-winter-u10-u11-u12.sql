-- 1056: winter youth (PPR Indoor) = U10 / U11 / U12, max 12 ACTIVE each,
-- ranked by availability (owner 2026-11-04: "i am thinking of u12,u11,u10
-- teams for ppr indoor" → "lets do this … dont go beyond 12 on any team
-- just rank them in order of availabilty … not alpha order. do it by age"
-- → "so you decide right now who is active and practice squad").
--
-- Teams: new U11 (copied from winter U12 940); U9 (945, mig 1051)
-- retired — its coach row ends, tag "u9 winter" → U10 (942).
-- Placement by age (US Club Soccer 2026-27 chart): ≤ 10 → U10, 11 → U11,
-- 12+ → U12 (fh_youth_fit_team, oldest team when none fits).
--
-- ACTIVE (On Roster by hand, no winter league list) = top 12 per team by
-- availability: yes answers in the last 28 days, then all-time yes, then
-- all-time answers.  Only kids who may play there (no playing down; at
-- most 2 age groups up) and who have answered at least once:
--   U12 (8): Damaj Austin, Joseph Bradham, Muhammad Idris, Grace Breslin,
--     Ava Smalley, Maya Rodriguez, Ryan Terrero (back Dec 1), Josiah Gaye.
--     Jacob Almaraz (never answered) and the six U13s (can't play down):
--     Practice Squad.
--   U11 (6): Ahleem Smith, Ezra Caraballo, Ilia Armstrong Cotto, Brandon
--     Velez, Kamryn Smith, Jhon Sagbaicela.
--   U10 (12): Ian Ortiz, Mason Davila, Yigit Torres, ethan almonte, Gian
--     Silvestry, Leonardo Rodriguez, jaxel almonte, Elliot Rubero, Jamauri
--     Bradham, Elliano Hudson, Tyreece Woods, Suhaylah Jones (U8 — Jayden
--     Negron ranked 12th but is U7, three groups up).
-- Everyone else: 🏋 Practice Squad, NOT ON ROSTER.  Inactive (Yousef)
-- stays Inactive.  coach_sort_order = that ranking (ACTIVE first), so the
-- board's Rank order is availability.

BEGIN;

-- U11 team, between U10 and U12 on the board.
UPDATE teams SET board_sort_order = board_sort_order + 1
 WHERE club_id = 134 AND board_sort_order >= (SELECT board_sort_order FROM teams WHERE id = 940);
INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster)
SELECT division_id, club_id, 'U11', is_pool, gender_category, roster_source, '❄️ U11', '❄️ U11', color,
       board_sort_order - 1, mutex_group, true, club_section_id, is_travel, lineup_everyone_plays,
       rsvp_board, games_need_roster, league_roster, false, 12
  FROM teams WHERE id = 940
   AND NOT EXISTS (SELECT 1 FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
                    WHERE t.name = 'U11' AND t.is_active AND t.gender_category IN ('boys', 'girls'));
CREATE TEMP TABLE u11 ON COMMIT DROP AS
SELECT id FROM teams WHERE name = 'U11' AND label = '❄️ U11' AND is_active ORDER BY id DESC LIMIT 1;
INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'winter', false FROM u11 ON CONFLICT DO NOTHING;
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT u.id, r.la_program_id FROM u11 u, team_membership_requirements r WHERE r.team_id = 940 ON CONFLICT DO NOTHING;
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT u.id, tc.coach_id, tc.coach_role_id FROM u11 u, team_coaches tc WHERE tc.team_id = 940 AND tc.ended_at IS NULL;
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', 'u11 winter', id, 'mig 1056' FROM u11
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases WHERE club_alias = 'boys' AND team_alias = 'u11 winter');

-- U9 retired.
UPDATE team_coaches SET ended_at = now() WHERE team_id = 945 AND ended_at IS NULL;
UPDATE gcal_team_aliases SET team_id = 942, notes = COALESCE(notes, '') || ' · U9 retired → U10 (mig 1056)' WHERE team_id = 945;
UPDATE teams SET is_active = false WHERE id = 945;

-- Every winter kid on his age team.
CREATE TEMP TABLE winter_moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.person_id,
       fh_youth_fit_team(fh_youth_us_age(p.birth_date), 'winter') AS to_team, tp.team_id AS from_team
  FROM team_persons tp
  JOIN persons p ON p.id = tp.person_id AND p.birth_date IS NOT NULL
 WHERE tp.removed_at IS NULL AND tp.team_id IN (940, 942, 945);
DELETE FROM winter_moves WHERE to_team IS NULL OR to_team = from_team;
UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1056, 'why', 'winter = U10/U11/U12')
  FROM winter_moves m WHERE tp.id = m.tp_id;
INSERT INTO team_persons (team_id, person_id)
SELECT DISTINCT m.to_team, m.person_id FROM winter_moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);

CREATE TEMP TABLE wteams ON COMMIT DROP AS SELECT 940 AS id UNION SELECT 942 UNION SELECT id FROM u11;

-- Reset, then ACTIVE (the trigger re-derives the spot on each status write).
UPDATE team_persons SET roster_status_id = NULL WHERE removed_at IS NULL AND team_id IN (SELECT id FROM wteams);
UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE removed_at IS NULL AND team_id IN (SELECT id FROM wteams)
   AND person_id IN (22484, 22413, 22711, 22364, 22713, 22707, 22349, 22638,          -- U12
                     22596, 22344, 22554, 22574, 22426, 22745,                        -- U11
                     22337, 22629, 22336, 22630, 22514, 22619, 22673, 22605, 22415, 22378, 22636, 22624);  -- U10

-- Rank = availability, ACTIVE first.
WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           COALESCE(rs.counts_as_on_roster, false) DESC,
           count(r.id) FILTER (WHERE r.response = 'yes' AND r.responded_at >= now() - interval '28 days') DESC,
           count(r.id) FILTER (WHERE r.response = 'yes') DESC,
           count(r.id) DESC, p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (SELECT id FROM wteams)
   GROUP BY tp.id, tp.team_id, rs.counts_as_on_roster, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;
