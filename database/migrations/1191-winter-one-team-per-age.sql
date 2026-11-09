-- 1191 (2026-11-09): winter = one team per age, U6 … U13 (owner: "i feel
-- like we need all the ages on teams. and just add them to the event").
-- Replaces mig 1189's bands (U7 / U10 / U12 / U13+).  Members today run
-- U6–U13; nobody is left off: U5 and younger → ❄️ U6, U14 and older →
-- ❄️ U13 (those two take a band, the rest exact age — teams.age_exact).
-- A practice slot lists its ages in the calendar tag ("u6 winter, u7
-- winter"); every "uN winter" alias points at its own age team.
-- Moved kids stay 🏋 Practice Squad (Not on Roster); Inactive follows the kid.
--
--   U6  new (cloned from U10 942)      U7  949       U8  new
--   U9  945 reactivated                U10 942       U11 946 reactivated
--   U12 940                            U13 947 (label back from U13+)

BEGIN;

-- New U6 / U8 from winter U10.
INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster, field_size, matchday_squad_size)
SELECT t.division_id, t.club_id, v.n, t.is_pool, t.gender_category, t.roster_source, '❄️ ' || v.n, '❄️ ' || v.n, t.color,
       t.board_sort_order, t.mutex_group, true, t.club_section_id, t.is_travel, t.lineup_everyone_plays,
       t.rsvp_board, t.games_need_roster, t.league_roster, false, t.max_roster, t.field_size, t.matchday_squad_size
  FROM teams t, (VALUES ('U6'), ('U8')) v(n)
 WHERE t.id = 942
   AND NOT EXISTS (SELECT 1 FROM teams x JOIN team_terms tt ON tt.team_id = x.id AND tt.term = 'winter'
                    WHERE x.name = v.n AND x.is_active AND x.gender_category IN ('boys', 'girls'));
CREATE TEMP TABLE wt ON COMMIT DROP AS
SELECT x.name, x.id FROM teams x JOIN team_terms tt ON tt.team_id = x.id AND tt.term = 'winter'
 WHERE x.is_active AND x.gender_category IN ('boys', 'girls')
UNION
SELECT name, id FROM teams WHERE label IN ('❄️ U6', '❄️ U8') AND is_active;
INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'winter', false FROM wt WHERE name IN ('U6', 'U8') ON CONFLICT DO NOTHING;

-- U9 / U11 back.
UPDATE teams t SET is_active = true, field_size = s.field_size, max_roster = s.max_roster,
       matchday_squad_size = s.matchday_squad_size, updated_at = now()
  FROM teams s WHERE s.id = 942 AND t.id IN (945, 946);
INSERT INTO wt SELECT name, id FROM teams WHERE id IN (945, 946);
UPDATE teams SET label = '❄️ U13', short_label = '❄️ U13', updated_at = now() WHERE id = 947;

-- Same LA requirements and coaches as U10 on every age team.
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT w.id, r.la_program_id FROM wt w, team_membership_requirements r WHERE r.team_id = 942 ON CONFLICT DO NOTHING;
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT w.id, tc.coach_id, tc.coach_role_id FROM wt w, team_coaches tc
 WHERE tc.team_id = 942 AND tc.ended_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_coaches x WHERE x.team_id = w.id AND x.coach_id = tc.coach_id AND x.ended_at IS NULL);

-- Exact age, except the two ends take the band beyond them.
UPDATE teams SET age_exact = (name NOT IN ('U6', 'U13')) WHERE id IN (SELECT id FROM wt);

-- Board order U6 … U13 after the fall teams.
WITH o AS (SELECT id, 5 + row_number() OVER (ORDER BY fh_team_age(id)) AS n FROM wt)
UPDATE teams t SET board_sort_order = o.n FROM o WHERE o.id = t.id;
UPDATE teams SET board_sort_order = 14 + id % 100 WHERE club_id = 134 AND NOT is_active AND gender_category IN ('boys', 'girls')
   AND id NOT IN (SELECT id FROM wt) AND board_sort_order BETWEEN 6 AND 13;

-- Calendar tags: each age → its own team; u5 → U6, u13+ / u14–u19 → U13.
WITH want(alias, team_id) AS (
  SELECT 'u' || a || ' winter', (SELECT id FROM wt WHERE fh_team_age(id) = LEAST(GREATEST(a, 6), 13))
    FROM generate_series(5, 19) a
  UNION ALL SELECT 'u13+ winter', 947)
, upd AS (
  UPDATE gcal_team_aliases g SET team_id = w.team_id, notes = COALESCE(g.notes, '') || ' · mig 1191'
    FROM want w WHERE g.club_alias = 'boys' AND g.team_alias = w.alias AND g.team_id <> w.team_id
  RETURNING 1)
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', w.alias, w.team_id, 'mig 1191' FROM want w
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases g WHERE g.club_alias = 'boys' AND g.team_alias = w.alias);

-- Re-place every winter kid on their age team.
CREATE TEMP TABLE moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.team_id AS from_team, tp.person_id, tp.squad_status_id,
       fh_youth_fit_team(fh_youth_us_age(p.birth_date), 'winter') AS to_team
  FROM team_persons tp
  JOIN persons p ON p.id = tp.person_id
  JOIN teams t ON t.id = tp.team_id
  JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
 WHERE tp.removed_at IS NULL AND t.gender_category IN ('boys', 'girls') AND p.birth_date IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM person_adult_overrides o WHERE o.person_id = tp.person_id);
DELETE FROM moves WHERE to_team IS NULL OR to_team = from_team;
UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1191)
  FROM moves m WHERE tp.id = m.tp_id;
INSERT INTO team_persons (team_id, person_id, roster_status_id)
SELECT DISTINCT m.to_team, m.person_id, (SELECT id FROM roster_statuses WHERE code = 'not_on_roster') FROM moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);
UPDATE team_persons tp SET squad_status_id = m.squad_status_id, invite_only = true
  FROM moves m JOIN squad_statuses ss ON ss.id = m.squad_status_id AND ss.code = 'inactive'
 WHERE tp.team_id = m.to_team AND tp.person_id = m.person_id AND tp.removed_at IS NULL;

SELECT fh_youth_place(m.person_id)
  FROM (SELECT DISTINCT m.person_id FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
         WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('boys', 'girls')
           AND NOT EXISTS (SELECT 1 FROM person_adult_overrides o WHERE o.person_id = m.person_id)) m;

-- Rank by RSVPs, Inactive last.
WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           (ss.code = 'inactive') NULLS FIRST, count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC,
           p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL AND tp.team_id IN (SELECT id FROM wt)
   GROUP BY tp.id, tp.team_id, ss.code, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;
