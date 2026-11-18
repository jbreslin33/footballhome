-- 1495 (2026-11-18) — youth travel teams, one per season (owner: "per team
-- right? its a U10 travel team?" → "or u10 Fall Travel, u10 Winter Travel etc"
-- → "yes do 1 and 2, rename fall teams too").  Naming rule: "U<age> Travel
-- <Season>" (mig 1396).  A league entry belongs to the travel team that plays
-- it; its fees are shared by the ages that team draws from (finance_program_teams).
--   1. Winter indoor entries → U10 / U12 Travel Winter (965 / 964), not the fall teams.
--   2. New U10 / U12 Travel Spring teams; the spring Inter-County entries move
--      to them, and so does the spring term of fall U10 / U12.
--   3. Fall squads renamed U8 / U10 / U12 Travel Fall (ids, aliases, rosters unchanged;
--      calendar tags resolve by team id via gcal_team_aliases).
BEGIN;

-- 3. rename the fall squads
UPDATE teams SET name = 'U8 Travel Fall',  label = '🍂 U8 Travel Fall',  short_label = '🍂 U8 Travel'  WHERE id = 912;
UPDATE teams SET name = 'U10 Travel Fall', label = '🍂 U10 Travel Fall', short_label = '🍂 U10 Travel' WHERE id = 913;
UPDATE teams SET name = 'U12 Travel Fall', label = '🍂 U12 Travel Fall', short_label = '🍂 U12 Travel' WHERE id = 914;

-- 2. spring travel teams (settings as the winter travel teams; size as fall's;
--    no team division — the league division stays on the entry)
INSERT INTO teams (division_id, club_id, name, gender_category, roster_source, label, short_label, color, board_sort_order,
                   max_roster, is_active, club_section_id, field_size, is_travel, lineup_everyone_plays, rsvp_board,
                   games_need_roster, not_on_roster_home, on_tuition_card)
SELECT NULL::int, 134, v.name, 'boys', 'direct', '🌱 ' || v.name, '🌱 ' || v.short, v.color, v.sort,
       v.roster, true, 3, v.field, true, true, true, false, false, false
  FROM (VALUES ('U10 Travel Spring', 'U10 Travel', NULL::int, '#0891b2', 20, 12, 7),
               ('U12 Travel Spring', 'U12 Travel', NULL::int, '#7c3aed', 21, 16, 9)) AS v(name, short, div, color, sort, roster, field)
 WHERE NOT EXISTS (SELECT 1 FROM teams t WHERE t.club_id = 134 AND t.name = v.name);

INSERT INTO team_terms (team_id, term)
SELECT id, 'spring' FROM teams WHERE club_id = 134 AND name IN ('U10 Travel Spring', 'U12 Travel Spring')
ON CONFLICT DO NOTHING;
DELETE FROM team_terms WHERE team_id IN (913, 914) AND term = 'spring';

-- 1 + 2. each entry on the team that plays it
UPDATE team_season_entries SET team_id = 965 WHERE id = 7 AND team_id = 913;   -- PPR Indoor U10
UPDATE team_season_entries SET team_id = 964 WHERE id = 8 AND team_id = 914;   -- PPR Indoor U12
UPDATE team_season_entries SET team_id = (SELECT id FROM teams WHERE club_id = 134 AND name = 'U10 Travel Spring') WHERE id = 9  AND team_id = 913;   -- ICSL Spring U10
UPDATE team_season_entries SET team_id = (SELECT id FROM teams WHERE club_id = 134 AND name = 'U12 Travel Spring') WHERE id = 10 AND team_id = 914;   -- ICSL Spring U12

-- the ages each travel team draws from (shares its league money)
INSERT INTO finance_program_teams (program_id, team_id)
SELECT fp.id, t.id FROM teams t JOIN finance_programs fp
    ON (t.name IN ('U10 Travel Winter', 'U10 Travel Spring') AND fp.code IN ('u9', 'u10'))
    OR (t.name IN ('U12 Travel Winter', 'U12 Travel Spring') AND fp.code IN ('u11', 'u12'))
 WHERE t.club_id = 134
ON CONFLICT DO NOTHING;

-- calendar tags for the new teams
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id)
SELECT 'boys', a, t.id FROM teams t
  JOIN (VALUES ('U10 Travel Spring', 'u10 travel spring'), ('U12 Travel Spring', 'u12 travel spring')) AS v(name, a) ON v.name = t.name
 WHERE t.club_id = 134
ON CONFLICT DO NOTHING;
COMMIT;
