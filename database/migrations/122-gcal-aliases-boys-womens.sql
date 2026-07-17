-- ═══════════════════════════════════════════════════════════════════════
-- 122-gcal-aliases-boys-womens.sql
-- ═══════════════════════════════════════════════════════════════════════
--
-- W3 from calendar-design.md §0.2 — option (B): alias only to REAL
-- rosters. Adds `gcal_team_aliases` rows for Boys + Womens so ops can
-- start DSL-tagging (§6.1.5) their calendar events with:
--
--   Team: U8      Club: Boys
--   Team: U12     Club: Boys
--   Team: U16     Club: Boys
--   Team: Tri County   Club: Womens   (or `Club: Women`)
--
-- Explicitly NOT creating virtual Practice/Pickup pool teams for
-- Boys / Womens / Girls in this migration — that's option (C) from
-- the plan, deferred until ops has real practice/pickup events on
-- those calendars. Any DSL like `Team: Pickup / Club: Boys` will
-- correctly land in classifier's `missingClub`/`unresolved` bucket
-- rather than fake-attach.
--
-- Girls: no `gender_category='girls'` teams exist in `teams` yet, so
-- nothing to seed. Same append-only rule as migration 121 — a future
-- 123 migration can add Girls rows once the roster lands.
--
-- Append-only rule (§6.1.5): the team_id column on any row here must
-- never be repointed. To rename, add a new alias row alongside; to
-- drop an alias, grep gcal descriptions first.

BEGIN;

-- ─── Boys (real youth league teams) ─────────────────────────────────
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('boys', 'u8',  916, 'Lighthouse Youth League U8'),
    ('boys', 'u12', 917, 'Lighthouse Youth League U12'),
    ('boys', 'u16', 911, 'Lighthouse Youth League U16')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

-- ─── Womens (real senior team) ──────────────────────────────────────
-- Two club spellings so ops can write either `Club: Womens` or
-- `Club: Women` (gcal_norm_alias() strips whitespace/punct but does
-- not un-pluralize). Same for the team alias — with/without space.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('womens', 'tri county', 901, 'Tri County Women'),
    ('womens', 'tricounty',  901, 'Alt spelling for Tri County'),
    ('women',  'tri county', 901, 'Alt club spelling — accepts `Club: Women`'),
    ('women',  'tricounty',  901, 'Alt club + alt team spelling')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

COMMIT;
