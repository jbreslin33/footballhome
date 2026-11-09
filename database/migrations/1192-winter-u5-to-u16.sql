-- 1192 (2026-11-09): winter teams U5 … U16 (owner: "just make u5 to u16").
-- Adds U5, U14, U16 (cloned from U10 942) and reactivates U15 (941) next
-- to mig 1191's U6–U13.  Exact age everywhere except the ends: U5 takes
-- 5 and younger, U16 takes 16 and older, so no member is ever off a team.
-- Tags "u5 winter" … "u16 winter" each name their own team; u17–u19 → U16.
-- No member is U5 or U14+ today, so the new teams start empty.

BEGIN;

INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster, field_size, matchday_squad_size)
SELECT t.division_id, t.club_id, v.n, t.is_pool, t.gender_category, t.roster_source, '❄️ ' || v.n, '❄️ ' || v.n, t.color,
       t.board_sort_order, t.mutex_group, true, t.club_section_id, t.is_travel, t.lineup_everyone_plays,
       t.rsvp_board, t.games_need_roster, t.league_roster, false, t.max_roster, t.field_size, t.matchday_squad_size
  FROM teams t, (VALUES ('U5'), ('U14'), ('U16')) v(n)
 WHERE t.id = 942
   AND NOT EXISTS (SELECT 1 FROM teams x JOIN team_terms tt ON tt.team_id = x.id AND tt.term = 'winter'
                    WHERE x.name = v.n AND x.is_active AND x.gender_category IN ('boys', 'girls'));
INSERT INTO team_terms (team_id, term, roster_frozen)
SELECT id, 'winter', false FROM teams WHERE label IN ('❄️ U5', '❄️ U14', '❄️ U16') AND is_active ON CONFLICT DO NOTHING;
UPDATE teams t SET is_active = true, field_size = s.field_size, max_roster = s.max_roster,
       matchday_squad_size = s.matchday_squad_size, updated_at = now()
  FROM teams s WHERE s.id = 942 AND t.id = 941;

CREATE TEMP TABLE wt ON COMMIT DROP AS
SELECT x.name, x.id FROM teams x JOIN team_terms tt ON tt.team_id = x.id AND tt.term = 'winter'
 WHERE x.is_active AND x.gender_category IN ('boys', 'girls');

INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT w.id, r.la_program_id FROM wt w, team_membership_requirements r WHERE r.team_id = 942 ON CONFLICT DO NOTHING;
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT w.id, tc.coach_id, tc.coach_role_id FROM wt w, team_coaches tc
 WHERE tc.team_id = 942 AND tc.ended_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_coaches x WHERE x.team_id = w.id AND x.coach_id = tc.coach_id AND x.ended_at IS NULL);

UPDATE teams SET age_exact = (name NOT IN ('U5', 'U16')) WHERE id IN (SELECT id FROM wt);

WITH o AS (SELECT id, 5 + row_number() OVER (ORDER BY fh_team_age(id)) AS n FROM wt)
UPDATE teams t SET board_sort_order = o.n FROM o WHERE o.id = t.id;
UPDATE teams SET board_sort_order = 20 + id % 100 WHERE club_id = 134 AND NOT is_active AND gender_category IN ('boys', 'girls')
   AND board_sort_order BETWEEN 6 AND 17;

WITH want(alias, team_id) AS (
  SELECT 'u' || a || ' winter', (SELECT id FROM wt WHERE fh_team_age(id) = LEAST(GREATEST(a, 5), 16))
    FROM generate_series(4, 19) a)
, upd AS (
  UPDATE gcal_team_aliases g SET team_id = w.team_id, notes = COALESCE(g.notes, '') || ' · mig 1192'
    FROM want w WHERE g.club_alias = 'boys' AND g.team_alias = w.alias AND g.team_id <> w.team_id
  RETURNING 1)
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', w.alias, w.team_id, 'mig 1192' FROM want w
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases g WHERE g.club_alias = 'boys' AND g.team_alias = w.alias);

COMMIT;
