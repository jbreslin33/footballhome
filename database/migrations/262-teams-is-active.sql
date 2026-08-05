-- 262-teams-is-active.sql (2026-08-05)
--
-- Adds teams.is_active as the canonical "is this team currently
-- operational" flag, decoupled from board display config.
--
-- board_sort_order/board_archived_at (added by migration 250, copied
-- off the old roster_columns table) are read in two unrelated places:
-- MensTeamColumns::loadAll() (which teams get a roster-board column)
-- and AuthController::handleCoachTeams (which teams a coach can pick
-- in the team-picker). Both currently treat board_archived_at IS NULL
-- as "team is active", but board_sort_order/board_archived_at are
-- meant to be about board *presentation* (whether/where a team gets a
-- column), not whether the team operationally exists. A team that's
-- never been given a board_sort_order (never opted into board
-- display) isn't necessarily inactive — those are different concepts
-- that happened to share one signal.
--
-- is_active becomes the one true activity gate everywhere; board_sort_
-- order/board_archived_at go back to being purely about board layout.
-- board_archived_at itself is left in place (still useful as "when
-- was this archived", and nothing currently writes it — no admin UI
-- exists for it — so there's no write path to migrate).

BEGIN;

ALTER TABLE teams ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT true;

-- Backfill: only the 7 teams already explicitly archived become
-- inactive. Teams with no board_sort_order (never opted into board
-- display) stay active — that's a display gap, not an activity signal.
UPDATE teams SET is_active = false WHERE board_archived_at IS NOT NULL;

COMMIT;
