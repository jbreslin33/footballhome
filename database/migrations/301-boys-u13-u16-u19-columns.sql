-- 301 — Give the boys board a full age ladder: U13 and U16 alongside a
--       reactivated U19.
--
-- Why (2026-08-25, owner: "i think we plan for future and have u19, u16,
-- u13. make them active teams. like the others").
--
-- Migration 276 created U19 as a single catch-all "for U13-U19", and it
-- was switched off through the Teams screen on 2026-08-15 — which is how
-- six players ended up invisible on the board (see migration 300). One
-- bucket spanning six birth years was never going to hold: a 12-year-old
-- and a 17-year-old do not play the same fixtures. Splitting it into U13,
-- U16 and U19 gives every band its own column now, before the players
-- arrive, rather than after.
--
-- "Like the others" means these are real board columns, identical in kind
-- to U6/U8/U10/U12: same division and club, same 'boys-selection'
-- mutex_group so a player lands in exactly one of them, the post-277 name
-- convention (bare 'U13', label '⚽ U13'), and a colour that no adjacent
-- column already uses.
--
-- No max_roster: like U6 and U19, these are holding teams rather than
-- squad-limited rosters, so a cap would reject real players for no reason.
-- U8/U10/U12 keep theirs (12/12/16) — untouched here.

BEGIN;

-- ── The two new columns ───────────────────────────────────────────────
INSERT INTO teams
    (division_id, club_id, name, label, short_label, color,
     gender_category, roster_source, mutex_group, board_sort_order, is_active)
VALUES
    (73, 134, 'U13', '⚽ U13', 'U13', '#ea580c', 'boys',
     'direct', 'boys-selection', 7, true),
    (73, 134, 'U16', '⚽ U16', 'U16', '#4f46e5', 'boys',
     'direct', 'boys-selection', 8, true)
ON CONFLICT (division_id, name) DO UPDATE
  SET label            = EXCLUDED.label,
      short_label      = EXCLUDED.short_label,
      color            = EXCLUDED.color,
      gender_category  = EXCLUDED.gender_category,
      mutex_group      = EXCLUDED.mutex_group,
      board_sort_order = EXCLUDED.board_sort_order,
      is_active        = EXCLUDED.is_active;

-- ── U19 back on ───────────────────────────────────────────────────────
-- It keeps its row, its colour and its six-player history; it only ever
-- needed is_active. Re-sorted to the end of the ladder so U13 and U16 sit
-- between it and U12 in age order.
UPDATE teams
   SET is_active        = true,
       board_sort_order = 9,
       board_archived_at = NULL
 WHERE id = 932;

-- ── LA registration requirements ──────────────────────────────────────
-- Copied from U19's own rows rather than retyped: a youth board column
-- accepts the boys membership (5039252) and the girls one (5039357),
-- because the boys board reads both programs. Without these, assigning a
-- player to the new columns fails the membership check and the row is
-- closed again with removed_reason 'no_valid_membership'.
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, r.la_program_id
  FROM teams t
  CROSS JOIN (SELECT DISTINCT la_program_id
                FROM team_membership_requirements
               WHERE team_id = 932) r
 WHERE t.division_id = 73 AND t.name IN ('U13', 'U16')
ON CONFLICT DO NOTHING;

-- ── Calendar tags ─────────────────────────────────────────────────────
-- `Team: u13` / `Team: u16` in a gcal description must attach the new
-- rosters. Both the plural and singular club spellings, mirroring what
-- migration 286 did for every alias pointing at an active team.
--
-- 'u16' already existed, pointing at team 911 "Lighthouse Youth League
-- U16" — one of the retired legacy rows migration 286 explicitly called
-- out as stale. It is repointed here, not duplicated: 911 has no active
-- members and is is_active=false, so nothing loses a roster.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT c.club_alias, a.team_alias, t.id, a.notes
  FROM teams t
  CROSS JOIN (VALUES ('boys'), ('boy')) AS c(club_alias)
  JOIN (VALUES
        ('U13', 'u13',      'U13 Boys — age band 12-13'),
        ('U13', 'u13 boys', 'Alt spelling for U13'),
        ('U16', 'u16',      'U16 Boys — age band 14-16 (repointed off retired team 911)'),
        ('U16', 'u16 boys', 'Alt spelling for U16')
       ) AS a(team_name, team_alias, notes) ON a.team_name = t.name
 WHERE t.division_id = 73 AND t.name IN ('U13', 'U16')
ON CONFLICT (club_alias, team_alias) DO UPDATE
  SET team_id = EXCLUDED.team_id,
      notes   = EXCLUDED.notes;

-- U19's own aliases were left unmirrored by migration 286 for the stated
-- reason that team 932 was inactive. It is active again, so the singular
-- twin lands now, and the notes stop calling it a U13-U19 catch-all.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
VALUES
    ('boy',  'u19',      932, 'Alt club spelling — accepts `Club: Boy`'),
    ('boy',  'u19 boys', 932, 'Alt club spelling'),
    ('boys', 'u19',      932, 'U19 Boys — age band 17-19'),
    ('boys', 'u19 boys', 932, 'Alt spelling for U19')
ON CONFLICT (club_alias, team_alias) DO UPDATE
  SET team_id = EXCLUDED.team_id,
      notes   = EXCLUDED.notes;

COMMIT;
