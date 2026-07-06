-- 093-boys-roster-seed.sql (2026-07-05)
--
-- Seed the Boys Roster domain: create 5 admin teams that back the
-- roster_columns for domain='boys', then insert those column rows.
--
-- Column set (matches user directive):
--   - Lighthouse League       (feeder / travel selection)
--   - U8 Boys                 (admin bucket)
--   - U10 Boys                (admin bucket)
--   - U12 Boys                (admin bucket)
--   - Purgatory (Boys)        (parked / delinquent)
--
-- All 5 selection columns share `mutex_group='boys-selection'` so moving
-- a player between columns is atomic (drop-then-insert inside one txn,
-- see MensTeamAssignments::addAssignment).
--
-- Player registrations come from BOTH LeagueApps Boys Club (5039252) and
-- Girls Club (5039357) programs — girls can be added to the boys roster
-- per user directive.  The gender badge on the card lets admin see which
-- is which.

BEGIN;

-- ── Boys admin teams ─────────────────────────────────────────────────────
-- Reuse division 73 "Summer 2026" (same as mens Practice/Pickup/Purgatory).
-- club_id=134 (Lighthouse 1893 SC).
INSERT INTO teams (id, division_id, club_id, name, gender_category, is_pool)
VALUES
    (911, 73, 134, 'Lighthouse League (Boys)', 'boys', false),
    (912, 73, 134, 'U8 Boys (Admin)',          'boys', false),
    (913, 73, 134, 'U10 Boys (Admin)',         'boys', false),
    (914, 73, 134, 'U12 Boys (Admin)',         'boys', false),
    (915, 73, 134, 'Purgatory (Boys)',         'boys', false)
ON CONFLICT (id) DO NOTHING;

-- Bump the sequence so future auto-generated team ids don't collide.
SELECT setval('teams_id_seq', GREATEST((SELECT MAX(id) FROM teams), 915));

-- ── roster_columns for domain='boys' ─────────────────────────────────────
-- sort_order matches user ordering: LL, U8, U10, U12, Purgatory.
-- mutex_group='boys-selection' on all 4 selection columns; Purgatory joins
-- the same group so moving a kid to Purgatory clears whatever bucket they
-- were in.
INSERT INTO roster_columns (domain, team_id, label, short_label, sort_order, color, mutex_group, max_roster)
VALUES
    ('boys', 911, '🏰 Lighthouse League', 'LL',   1, '#2563eb', 'boys-selection', NULL),
    ('boys', 912, '👦 U8 Boys',            'U8',   2, '#16a34a', 'boys-selection', NULL),
    ('boys', 913, '👦 U10 Boys',           'U10',  3, '#0891b2', 'boys-selection', NULL),
    ('boys', 914, '👦 U12 Boys',           'U12',  4, '#7c3aed', 'boys-selection', NULL),
    ('boys', 915, '🚨 Purgatory',          'PURG', 999, '#ef4444', 'boys-selection', NULL)
ON CONFLICT (domain, team_id) DO NOTHING;

COMMIT;
