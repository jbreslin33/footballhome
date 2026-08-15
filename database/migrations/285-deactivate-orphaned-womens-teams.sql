-- ─────────────────────────────────────────────────────────────────────
-- 285-deactivate-orphaned-womens-teams.sql (2026-08-15)
--
-- Tri County Women (901) is the only real, club-scoped women's team.
-- Two other women-related team rows are still is_active=true but are
-- orphaned/retired: 583 "Lighthouse Women's Club" (club_id was never
-- set — never club-scoped) and 902 "U23 Women" (detached from club
-- 134 and its rosters closed by migration 065). Both have zero open
-- rosters. Their team_membership_requirements rows are dead weight —
-- no backend code reads that table today.
--
-- Setting is_active=false makes Tri County Women the only active
-- women's team, matching how the Teams screen's Women's pill
-- (/api/clubs/:id?gender=womens) is meant to read.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

UPDATE teams SET is_active = false WHERE id IN (583, 902);

COMMIT;
