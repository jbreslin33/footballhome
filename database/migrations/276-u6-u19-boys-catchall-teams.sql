-- ═══════════════════════════════════════════════════════════════════════
-- 276-u6-u19-boys-catchall-teams.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- U8/U10/U12 Boys only cover the travel-age band. Kids U6-and-under
-- and U13-U19 have no travel team of their own, so this adds two
-- catch-all boys teams to hold them: U6 Boys (sort before U8) and
-- U19 Boys (sort after U12). No max_roster cap — these are holding
-- teams, not squad-limited rosters, per real-team-building period.

BEGIN;

INSERT INTO teams
    (division_id, club_id, name, label, short_label, color, gender_category,
     roster_source, kind, mutex_group, board_sort_order, is_active)
VALUES
    (73, 134, 'U6 Boys',  '👦 U6 Boys',  'U6',  '#ca8a04', 'boys',
     'direct', 'official', 'boys-selection', 3, true),
    (73, 134, 'U19 Boys', '👦 U19 Boys', 'U19', '#be123c', 'boys',
     'direct', 'official', 'boys-selection', 7, true);

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'boys', 'u6', id, 'U6 Boys — catch-all for U6-and-under'
  FROM teams WHERE name = 'U6 Boys'
UNION ALL
SELECT 'boys', 'u6 boys', id, 'Alt spelling for U6 Boys'
  FROM teams WHERE name = 'U6 Boys'
UNION ALL
SELECT 'boys', 'u19', id, 'U19 Boys — catch-all for U13-U19'
  FROM teams WHERE name = 'U19 Boys'
UNION ALL
SELECT 'boys', 'u19 boys', id, 'Alt spelling for U19 Boys'
  FROM teams WHERE name = 'U19 Boys'
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
