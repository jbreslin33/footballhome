-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 263: cosmetic team rename + drop confirmed-dead roster tables
--
-- Executes items 1, 5, 6 from the "Session update (2026-08-05)" queue in
-- docs/adr/2026-07-30-roster-membership-rsvp-normalization.md. Item 3
-- (team 915 "Dues Owed (Boys)" disposition) and the club_sections
-- migration are deliberately NOT part of this pass — separate scope.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- ─── Item 1: drop the "(Admin)" suffix on 912/913/914 ─────────────────
-- Cosmetic only — `kind='internal'` (set by migration 250) already
-- carries the real "this is a bookkeeping/roster-board team, not an
-- official league team" semantic. The "(Admin)" suffix was a stand-in
-- for that before `kind` existed.
UPDATE teams SET name = 'U8 Boys'  WHERE id = 912 AND name = 'U8 Boys (Admin)';
UPDATE teams SET name = 'U10 Boys' WHERE id = 913 AND name = 'U10 Boys (Admin)';
UPDATE teams SET name = 'U12 Boys' WHERE id = 914 AND name = 'U12 Boys (Admin)';

-- ─── Item 5: drop confirmed-dead roster_columns + coach_rsvp_eligibility ──
-- roster_columns: folded into `teams` by migration 250 (label,
-- short_label, color, board_sort_order, mutex_group, max_roster,
-- board_archived_at). Zero backend/frontend reads of the table itself
-- remain — only stale comments and an unrelated same-named local
-- variable in EventController.cpp.
--
-- coach_rsvp_eligibility: mirror of team_coaches via
-- fn_sync_coach_rsvp_eligibility_from_team_coaches(), created by
-- migration 111. Zero backend/frontend reads found — the eligibility
-- check that would have used it instead queries team_coaches directly
-- (see CalendarController's `eligible` subquery). Drop the trigger and
-- function first so team_coaches writes don't error once the table's
-- gone.
DROP TRIGGER IF EXISTS trg_sync_coach_rsvp_eligibility ON team_coaches;
DROP FUNCTION IF EXISTS fn_sync_coach_rsvp_eligibility_from_team_coaches();
DROP TABLE IF EXISTS coach_rsvp_eligibility;
DROP TABLE IF EXISTS roster_columns;

-- ─── Item 6: drop dead clubs rows ──────────────────────────────────────
-- Confirmed zero references across every table with a club_id FK
-- (teams, chat_clubs, club_admins, eligibility_policies,
-- tactical_boards, club_game_model, club_game_model_content) before
-- this migration was written.
DELETE FROM clubs WHERE id IN (20004, 20010);

COMMIT;
