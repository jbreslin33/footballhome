-- 1392 (2026-11-16): ❄️ U12 Travel Winter + ❄️ U10 Travel Winter (owner:
-- "def u12 travel winter indoor, possibly u10 travel indoor … add them as
-- teams so we can start sending players over to see what roster might look
-- like while still keeping each kid in the generic age for winter";
-- naming "u12 Travel Winter, so for fall it would have been u12 Travel Fall").
--
--   • Winter-term teams cloned from the generic ❄️ U12 (940) / ❄️ U10 (942).
--   • A kid KEEPS his generic winter age row; the travel team is a second
--     team_persons row (⋯ sheet ⚽ "Add"), like APSL Reserves.
--   • Never auto-filled: fh_youth_fit_team only picks names ~ '^U[0-9]+$'.
--   • games_need_roster: a kid added starts 🏋 Practice Squad (Not on Roster)
--     until marked On Roster.
--   • Off the tuition card (dues unchanged; the generic team already counts
--     him) and out of finance / capacity plans.
--   • Calendar tags "u12 travel winter" / "u10 travel winter" (exact-match
--     aliases; the old "u12 travel" still means fall U12 914). No events yet,
--     so nobody is asked or reminded of anything.
--   • Next season the squad rolls over as a cohort (U12 → U13 Travel Winter)
--     by a later migration/button — not built now.

BEGIN;

CREATE TEMP TABLE nt (src int, name text, short text, sort int) ON COMMIT DROP;
INSERT INTO nt VALUES (940, 'U12 Travel Winter', '❄️ U12 Travel', 18),
                      (942, 'U10 Travel Winter', '❄️ U10 Travel', 19);

INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster, field_size,
                   matchday_squad_size, age_exact, on_tuition_card)
SELECT t.division_id, t.club_id, nt.name, t.is_pool, t.gender_category, t.roster_source, '❄️ ' || nt.name, nt.short, t.color,
       nt.sort, NULL, true, t.club_section_id, true, t.lineup_everyone_plays,
       t.rsvp_board, true, t.league_roster, false, NULL, t.field_size,
       t.matchday_squad_size, t.age_exact, false
  FROM nt JOIN teams t ON t.id = nt.src
 WHERE NOT EXISTS (SELECT 1 FROM teams x WHERE x.name = nt.name AND x.is_active);

CREATE TEMP TABLE nm ON COMMIT DROP AS
SELECT nt.src, t.id, lower(nt.name) AS tag FROM nt JOIN teams t ON t.name = nt.name AND t.is_active;

INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'winter', false FROM nm ON CONFLICT DO NOTHING;

INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT nm.id, r.la_program_id FROM team_membership_requirements r JOIN nm ON nm.src = r.team_id
ON CONFLICT DO NOTHING;

INSERT INTO team_coaches (team_id, coach_id, coach_role_id, roster_status_id)
SELECT nm.id, c.coach_id, c.coach_role_id, c.roster_status_id
  FROM team_coaches c JOIN nm ON nm.src = c.team_id
 WHERE c.ended_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_coaches x WHERE x.team_id = nm.id AND x.coach_id = c.coach_id AND x.ended_at IS NULL);

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', nm.tag, nm.id, 'mig 1392' FROM nm
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases a WHERE a.club_alias = 'boys' AND a.team_alias = nm.tag);

COMMIT;
