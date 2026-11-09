-- 1189 (2026-11-09): winter planning — four age teams, everyone on Practice
-- Squad until picked, and #teams / #rosters open on Winter.
-- Owner: "separate all players on the teams page for winter tab by age and
-- default to winter when we open teams or rosters … u10 (u8,u9,u10) u12
-- (u11,u12), then we need a u13+ and a u7 … we will have trials" (a trial
-- is a practice).  Starts today.
--
--   ❄️ U7    (new, cloned from U10 942)  U6 + U7       tag "u7 winter"
--   ❄️ U10   942                          U8, U9, U10
--   ❄️ U12   940                          U11 + U12     U11 946 retired here
--   ❄️ U13+  947 (name stays U13 so fh_team_age reads it; label U13+)
--            U13 and older — fh_youth_fit_team's "else the oldest" sends
--            older kids here.
-- Every winter row that is not 💤 Inactive goes back to Not on Roster →
-- 🏋 Practice Squad (trigger): practices yes, games no.  On Roster later =
-- picked for the travel team = sees games (undoes mig 1063's all-On-Roster).
-- Adults (person_adult_overrides, e.g. Sheldon Rhoden) are never placed.
--
-- year_terms.board_default: the season #teams lights on first open
-- (fh_board_term(); NULL → today's season).

BEGIN;

-- ── Default season pill ────────────────────────────────────────────────
ALTER TABLE year_terms ADD COLUMN IF NOT EXISTS board_default boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN year_terms.board_default IS
  'mig 1189: the season the #teams/#rosters season pills light on first open; none set = fh_current_term().';
CREATE UNIQUE INDEX IF NOT EXISTS year_terms_one_board_default ON year_terms ((true)) WHERE board_default;
UPDATE year_terms SET board_default = (code = 'winter');

CREATE OR REPLACE FUNCTION fh_board_term() RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE((SELECT code FROM year_terms WHERE board_default LIMIT 1), fh_current_term())
$$;

-- ── Winter U7 (copied from winter U10 942) ─────────────────────────────
UPDATE teams SET board_sort_order = board_sort_order + 1
 WHERE club_id = 134 AND board_sort_order >= (SELECT board_sort_order FROM teams WHERE id = 942);
INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster, field_size, matchday_squad_size)
SELECT division_id, club_id, 'U7', is_pool, gender_category, roster_source, '❄️ U7', '❄️ U7', color,
       board_sort_order - 1, mutex_group, true, club_section_id, is_travel, lineup_everyone_plays,
       rsvp_board, games_need_roster, league_roster, false, max_roster, field_size, matchday_squad_size
  FROM teams WHERE id = 942
   AND NOT EXISTS (SELECT 1 FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
                    WHERE t.name = 'U7' AND t.is_active AND t.gender_category IN ('boys', 'girls'));
CREATE TEMP TABLE u7 ON COMMIT DROP AS
SELECT id FROM teams WHERE name = 'U7' AND label = '❄️ U7' AND is_active ORDER BY id DESC LIMIT 1;
INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'winter', false FROM u7 ON CONFLICT DO NOTHING;
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT u.id, r.la_program_id FROM u7 u, team_membership_requirements r WHERE r.team_id = 942 ON CONFLICT DO NOTHING;
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT u.id, tc.coach_id, tc.coach_role_id FROM u7 u, team_coaches tc WHERE tc.team_id = 942 AND tc.ended_at IS NULL;
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', a, id, 'mig 1189' FROM u7, (VALUES ('u7 winter'), ('u6 winter')) v(a)
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases g WHERE g.club_alias = 'boys' AND g.team_alias = v.a);
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', a, 942, 'mig 1189' FROM (VALUES ('u8 winter')) v(a)
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases g WHERE g.club_alias = 'boys' AND g.team_alias = v.a);

-- ── U11 retired into U12; U13 reads U13+ ───────────────────────────────
UPDATE teams SET is_active = false, updated_at = now() WHERE id = 946;
UPDATE gcal_team_aliases SET team_id = 940, notes = notes || ' · U11 retired → U12 (mig 1189)'
 WHERE club_alias = 'boys' AND team_alias = 'u11 winter';
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', 'u13+ winter', 947, 'mig 1189'
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases WHERE club_alias = 'boys' AND team_alias = 'u13+ winter');
UPDATE teams SET label = '❄️ U13+', short_label = '❄️ U13+', updated_at = now() WHERE id = 947;

-- ── Re-place every winter kid by age ───────────────────────────────────
CREATE TEMP TABLE moves ON COMMIT DROP AS
SELECT tp.id AS tp_id, tp.person_id, tp.squad_status_id,
       fh_youth_fit_team(fh_youth_us_age(p.birth_date), 'winter') AS to_team
  FROM team_persons tp
  JOIN persons p ON p.id = tp.person_id
  JOIN teams t ON t.id = tp.team_id
  JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
 WHERE tp.removed_at IS NULL AND t.gender_category IN ('boys', 'girls') AND p.birth_date IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM person_adult_overrides o WHERE o.person_id = tp.person_id);
DELETE FROM moves m USING team_persons tp WHERE tp.id = m.tp_id AND (m.to_team IS NULL OR m.to_team = tp.team_id);

UPDATE team_persons tp SET removed_at = now(), removed_reason = 'board_move',
       removed_details = jsonb_build_object('to_team_id', m.to_team, 'mig', 1189)
  FROM moves m WHERE tp.id = m.tp_id;
INSERT INTO team_persons (team_id, person_id)
SELECT DISTINCT m.to_team, m.person_id FROM moves m
 WHERE NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.to_team AND x.person_id = m.person_id AND x.removed_at IS NULL);
-- 💤 Inactive follows the kid to the new team.
UPDATE team_persons tp SET squad_status_id = m.squad_status_id, invite_only = true
  FROM moves m JOIN squad_statuses ss ON ss.id = m.squad_status_id AND ss.code = 'inactive'
 WHERE tp.team_id = m.to_team AND tp.person_id = m.person_id AND tp.removed_at IS NULL;

-- Any playing member still without a winter team (mig 1060 rule).
SELECT fh_youth_place(m.person_id)
  FROM (SELECT DISTINCT m.person_id FROM person_la_memberships m JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
         WHERE m.ended_at IS NULL AND lp.variant = 'active' AND lp.category IN ('boys', 'girls')
           AND NOT EXISTS (SELECT 1 FROM person_adult_overrides o WHERE o.person_id = m.person_id)) m;

-- ── Everyone Practice Squad until picked ───────────────────────────────
UPDATE team_persons tp SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'not_on_roster')
  FROM teams t JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
 WHERE t.id = tp.team_id AND t.is_active AND t.gender_category IN ('boys', 'girls') AND tp.removed_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM squad_statuses ss WHERE ss.id = tp.squad_status_id AND ss.code = 'inactive');

-- Rank by RSVPs (all-time, then last 14 days), Inactive last.
WITH s AS (
  SELECT tp.id,
         row_number() OVER (PARTITION BY tp.team_id ORDER BY
           (ss.code = 'inactive') NULLS FIRST, count(r.id) DESC,
           count(r.id) FILTER (WHERE r.responded_at >= now() - interval '14 days') DESC,
           p.last_name, p.first_name) AS rnk
    FROM team_persons tp
    JOIN persons p ON p.id = tp.person_id
    JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.gender_category IN ('boys', 'girls')
    JOIN team_terms tt ON tt.team_id = t.id AND tt.term = 'winter'
    LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
    LEFT JOIN fh_event_rsvps r ON r.person_id = tp.person_id
   WHERE tp.removed_at IS NULL
   GROUP BY tp.id, tp.team_id, ss.code, p.last_name, p.first_name)
UPDATE team_persons tp SET coach_sort_order = s.rnk FROM s WHERE s.id = tp.id;

COMMIT;
