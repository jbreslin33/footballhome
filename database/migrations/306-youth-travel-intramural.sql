-- 306 — Split the boys board into Travel and Intramural.
--
-- Why (2026-08-25, owner: "we need to rename all teams for youth. they
-- should be u8 travel, u10 travel, u12 travel. u8 intramural, u10
-- intramural, u12 intramural, u16 intramural, u19 intramural", then "u6
-- becomes u6 intramural, current teams are travel, boys only").
--
-- The board has been a single age ladder, which cannot say the thing the
-- club actually needs to say: whether a kid is on a selected travel squad
-- or in the house programme. Age was doing double duty as both, so the
-- older kids ended up in catch-all buckets (U13/U16/U19, migration 301)
-- that were really "not travel" wearing an age label.
--
-- The existing teams are the travel side — owner's call, and the rosters
-- agree: U8/U10/U12 carry 18/21/14 players and the max_roster caps
-- (12/12/16) were written for squads. They keep their ids, their players,
-- their caps and their colours, and only gain the word. U6 has no travel
-- side at that age, so it moves across to Intramural with its 6 players.
--
-- Intramural gets no max_roster, the same reasoning as the old catch-all
-- teams: it is where everyone who is not on a squad belongs, and a cap
-- would turn a real kid away for no reason.
--
-- Board order is programme-then-age rather than pure age, so the three
-- travel squads read as a group at the top instead of interleaving with
-- the house teams.
--
-- Girls are deliberately out of scope ("boys only"). There are no
-- gender_category='girls' teams at all today — the 20 girls LA members
-- land in this board's Unassigned — so nothing here needs to pretend
-- otherwise. A parallel girls structure is a separate decision.

BEGIN;

-- ── Travel: rename in place, players and caps untouched ───────────────
UPDATE teams SET name = 'U8 Travel',  label = '⚽ U8 Travel',  short_label = 'U8 Trav',  board_sort_order = 3 WHERE id = 912;
UPDATE teams SET name = 'U10 Travel', label = '⚽ U10 Travel', short_label = 'U10 Trav', board_sort_order = 4 WHERE id = 913;
UPDATE teams SET name = 'U12 Travel', label = '⚽ U12 Travel', short_label = 'U12 Trav', board_sort_order = 5 WHERE id = 914;

-- ── Intramural: the three that already exist, renamed ─────────────────
-- 931 keeps its 6 players; 934 and 932 are empty (their six were returned
-- to Unassigned by migration 300) but keep their ids so the calendar
-- aliases pointing at them stay valid.
UPDATE teams SET name = 'U6 Intramural',  label = '⚽ U6 Intramural',  short_label = 'U6 Intra',  board_sort_order = 6  WHERE id = 931;
UPDATE teams SET name = 'U16 Intramural', label = '⚽ U16 Intramural', short_label = 'U16 Intra', board_sort_order = 10 WHERE id = 934;
UPDATE teams SET name = 'U19 Intramural', label = '⚽ U19 Intramural', short_label = 'U19 Intra', board_sort_order = 11 WHERE id = 932;

-- ── Intramural: the three new ones ────────────────────────────────────
-- Colours are near neighbours of their travel counterparts so the age
-- pairing reads down the board, while the label carries the distinction.
INSERT INTO teams
    (division_id, club_id, name, label, short_label, color,
     gender_category, roster_source, mutex_group, board_sort_order, is_active)
VALUES
    (73, 134, 'U8 Intramural',  '⚽ U8 Intramural',  'U8 Intra',  '#65a30d', 'boys', 'direct', 'boys-selection', 7, true),
    (73, 134, 'U10 Intramural', '⚽ U10 Intramural', 'U10 Intra', '#0e7490', 'boys', 'direct', 'boys-selection', 8, true),
    (73, 134, 'U12 Intramural', '⚽ U12 Intramural', 'U12 Intra', '#a855f7', 'boys', 'direct', 'boys-selection', 9, true)
ON CONFLICT (division_id, name) DO UPDATE
  SET label = EXCLUDED.label, short_label = EXCLUDED.short_label,
      color = EXCLUDED.color, gender_category = EXCLUDED.gender_category,
      mutex_group = EXCLUDED.mutex_group,
      board_sort_order = EXCLUDED.board_sort_order, is_active = EXCLUDED.is_active;

-- ── U13 goes ──────────────────────────────────────────────────────────
-- Not in the owner's list, and empty: it was a guess from migration 301
-- that this split replaces. Aliases and event attachments cleared first
-- (both FKs are NO ACTION); gcal-classify.js rebuilds fh_event_teams from
-- the tags on every run, so nothing is permanently lost.
DELETE FROM gcal_team_aliases WHERE team_id = 933;
DELETE FROM fh_event_teams    WHERE team_id = 933;
DELETE FROM teams             WHERE id = 933;

-- ── Membership requirements for the new teams ─────────────────────────
-- Copied from U8 Travel rather than retyped: both the boys (5039252) and
-- girls (5039357) LA programs, because the board reads both. Without
-- these an assignment fails the membership check and is closed again with
-- removed_reason 'no_valid_membership'.
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, r.la_program_id
  FROM teams t
  CROSS JOIN (SELECT DISTINCT la_program_id FROM team_membership_requirements WHERE team_id = 912) r
 WHERE t.division_id = 73
   AND t.name IN ('U8 Intramural', 'U10 Intramural', 'U12 Intramural')
ON CONFLICT DO NOTHING;

-- ── Calendar tags ─────────────────────────────────────────────────────
-- Explicit spellings for the new names, in both club spellings (migration
-- 286's convention). The BARE age tags ('u8', 'u10', 'u12', 'u6', 'u16',
-- 'u19') are left pointing exactly where they point today — u8/u10/u12 at
-- the travel squads, u6/u16/u19 at their now-Intramural teams — so no
-- existing calendar event changes meaning on this deploy. Ops can start
-- tagging `Team: u10 travel, u10 intramural` when they want both.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT c.club_alias, a.team_alias, t.id, a.notes
  FROM teams t
  CROSS JOIN (VALUES ('boys'), ('boy')) AS c(club_alias)
  JOIN (VALUES
        ('U8 Travel',      'u8 travel',       'Travel squad'),
        ('U10 Travel',     'u10 travel',      'Travel squad'),
        ('U12 Travel',     'u12 travel',      'Travel squad'),
        ('U6 Intramural',  'u6 intramural',   'House programme'),
        ('U8 Intramural',  'u8 intramural',   'House programme'),
        ('U10 Intramural', 'u10 intramural',  'House programme'),
        ('U12 Intramural', 'u12 intramural',  'House programme'),
        ('U16 Intramural', 'u16 intramural',  'House programme'),
        ('U19 Intramural', 'u19 intramural',  'House programme')
       ) AS a(team_name, team_alias, notes) ON a.team_name = t.name
 WHERE t.division_id = 73
ON CONFLICT (club_alias, team_alias) DO UPDATE
  SET team_id = EXCLUDED.team_id, notes = EXCLUDED.notes;

COMMIT;
