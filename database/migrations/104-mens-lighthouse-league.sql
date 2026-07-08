-- 104-mens-lighthouse-league.sql  (2026-07-07)
--
-- Add a "Lighthouse League (Mens)" bucket to the mens roster board for
-- young players (e.g., Nelson, 15) who are boys-club members on
-- LeagueApps but should be eligible to attend MENS practice + pickup
-- (not APSL/Liga 1/Liga 2 games — those are adult league).
--
-- Mirrors migration 093 (boys LL, team 911) but for mens.
--
-- Model (user directive 2026-07-07 "would be cleaner to remain a boys
-- club member but moved to adult fh rosters"):
--   • Player keeps their single LA registration on Boys Club (5039252)
--     OR Girls Club (5039357).  No LA-side duplication.
--   • FH stores a cross-domain roster_assignments row:
--       (leagueapps_user_id = <boys/girls LA id>,
--        team_id            = 122,
--        domain             = 'mens',
--        removed_at         = NULL)
--   • MensRoster::run will be extended in a follow-up commit to union
--     these cross-domain members into the mens board's LL column,
--     enriched from persons + person_phones + person_emails (no dues
--     chip — they pay boys/girls dues on their home board).
--
-- Event visibility (backend controllers updated in this changeset):
--   • Practice (match_type_id=3)         → 122 added to eligible-teams array
--   • Pickup   (match_type_id=7)         → already OK ("any active mta row" rule)
--   • Games    (match_type_id IN 1,4,6)  → 122 NOT added (LL kids can't play adult league)
--
-- Files with practice arrays updated in the same commit:
--   backend/src/controllers/EventReminderController.cpp   (mens-week-availability + reminders)
--   backend/src/services/RsvpMaterialization.cpp          (kApplyRecurringSql)
--
-- MyController::handleGetWeek uses the pure-roster model (ra.team_id =
-- m.home_team_id) — LL members are auto-added to pool teams 908/909 by
-- the fn_pool_team_membership_on_mens_assign trigger the moment their
-- team 122 row is inserted, so /api/my/week works without further code.
--
-- Idempotent: safe to re-apply.

BEGIN;

-- ── 1. Create the Lighthouse League (Mens) admin team ────────────────────
-- Reuses division 73 "Summer 2026" (same as mens Practice/Pickup and boys LL).
-- club_id=134 = Lighthouse 1893 SC.
INSERT INTO teams (id, division_id, club_id, name, gender_category, is_pool)
VALUES (122, 73, 134, 'Lighthouse League (Mens)', 'mens', false)
ON CONFLICT (id) DO NOTHING;

-- Bump the sequence so future auto-assigned team ids don't collide.
SELECT setval('teams_id_seq', GREATEST((SELECT MAX(id) FROM teams), 122));

-- ── 2. roster_columns row (renders the LL column on the mens board) ─────
-- sort_order=4 puts it after Liga 2 (which is sort_order=3).
-- mutex_group='mens-selection' → a player is in AT MOST ONE of
-- {APSL 35, Liga 1 120, Liga 2 121, LL 122}.  App-layer enforcement in
-- MensTeamAssignments::addAssignment reads mutex_group from this table,
-- so no code change is needed for the mutex to cover 122.
-- Colour matches boys LL (#2563eb, blue) for visual continuity.
-- max_roster=NULL → no cap (LL is a soft feeder bucket).
INSERT INTO roster_columns (domain, team_id, label, short_label, sort_order, color, mutex_group, max_roster)
VALUES ('mens', 122, '🏰 Lighthouse League', 'LL', 4, '#2563eb', 'mens-selection', NULL)
ON CONFLICT (domain, team_id) DO NOTHING;

-- ── 3. Extend the mens-selection uniqueness partial index ────────────────
-- Migration 102 created this index over {35, 120, 121}.  Adding 122
-- keeps the "at most one active row per user across mens-selection
-- teams" guarantee intact so promoting a player between LL / Liga 2 /
-- Liga 1 / APSL is atomic at the DB level.
DROP INDEX IF EXISTS uniq_roster_assignments_mens_selection_one_of;
CREATE UNIQUE INDEX uniq_roster_assignments_mens_selection_one_of
  ON roster_assignments (domain, leagueapps_user_id)
  WHERE removed_at IS NULL
    AND team_id IN (35, 120, 121, 122);

COMMIT;
