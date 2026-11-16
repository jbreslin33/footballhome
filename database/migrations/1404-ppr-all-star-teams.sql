-- 1404 (2026-11-16): ⭐ PPR All-Star teams — U8, U10, U12 from fall (owner:
-- "we need to add all star games. its 3 kids per team for ppr. u8, u10, u12
-- from fall … we need it to show in calendar for parents" → "yes it needs
-- to be its own teams").
--
--   • Cloned from fall ⚽ U8 (912) / U10 (913) / U12 (914), the same way
--     as the winter travel teams (mig 1392).
--   • A kid KEEPS his fall team; the All-Star team is a second
--     team_persons row (the ⋯ sheet's ⚽ "Add", or a migration), like APSL
--     Reserves. Only those kids' parents see an All-Star game.
--   • games_need_roster false: the kids are picked, so a kid added is on
--     the squad at once (no 🏋 Practice Squad step). No league roster.
--   • Never auto-filled: fh_youth_fit_team only picks names ~ '^U[0-9]+$'.
--   • Off the tuition card (dues unchanged; the fall team already counts
--     him). Fall term, not frozen.
--   • Coaches + LA membership requirement copied from the fall team.
--   • Calendar: description `Club: Boys` + `Team: U10 All-Stars`
--     ("all stars" / "allstars" / "all star" spellings all match).

BEGIN;

CREATE TEMP TABLE nt (src int, name text, short text, sort int) ON COMMIT DROP;
INSERT INTO nt VALUES (912, 'U8 All-Stars',  '⭐ U8 AS',  20),
                      (913, 'U10 All-Stars', '⭐ U10 AS', 21),
                      (914, 'U12 All-Stars', '⭐ U12 AS', 22);

INSERT INTO teams (division_id, club_id, name, is_pool, gender_category, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, is_active, club_section_id, is_travel, lineup_everyone_plays,
                   rsvp_board, games_need_roster, league_roster, not_on_roster_home, max_roster, field_size,
                   matchday_squad_size, age_exact, on_tuition_card)
SELECT t.division_id, t.club_id, nt.name, t.is_pool, t.gender_category, t.roster_source, '⭐ ' || nt.name, nt.short, t.color,
       nt.sort, NULL, true, t.club_section_id, true, true,
       t.rsvp_board, false, false, false, NULL, t.field_size,
       t.matchday_squad_size, t.age_exact, false
  FROM nt JOIN teams t ON t.id = nt.src
 WHERE NOT EXISTS (SELECT 1 FROM teams x WHERE x.name = nt.name AND x.is_active);

CREATE TEMP TABLE nm ON COMMIT DROP AS
SELECT nt.src, t.id, regexp_replace(lower(nt.name), ' all-stars$', '') AS age
  FROM nt JOIN teams t ON t.name = nt.name AND t.is_active;

INSERT INTO team_terms (team_id, term, roster_frozen) SELECT id, 'fall', false FROM nm ON CONFLICT DO NOTHING;

INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT nm.id, r.la_program_id FROM team_membership_requirements r JOIN nm ON nm.src = r.team_id
ON CONFLICT DO NOTHING;

INSERT INTO team_coaches (team_id, coach_id, coach_role_id, roster_status_id)
SELECT nm.id, c.coach_id, c.coach_role_id, c.roster_status_id
  FROM team_coaches c JOIN nm ON nm.src = c.team_id
 WHERE c.ended_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_coaches x WHERE x.team_id = nm.id AND x.coach_id = c.coach_id AND x.ended_at IS NULL);

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', nm.age || v.suffix, nm.id, 'mig 1404 PPR All-Stars'
  FROM nm CROSS JOIN (VALUES (' all stars'), (' allstars'), (' all star')) AS v(suffix)
 WHERE NOT EXISTS (SELECT 1 FROM gcal_team_aliases a WHERE a.club_alias = 'boys' AND a.team_alias = nm.age || v.suffix);

COMMIT;
