-- 279 — Adds a simple, per-team "starter eligible / bench eligible"
-- designation, coach-editable on the fly from the game-lineup screen.
--
-- Deliberately NOT reusing player_eligibilities (category IN
-- starter/bench already existed there) — that table is entangled with
-- the now-deleted chat_events-based eligibility engine (multi-league
-- source_system_id/subdivision model, policy-driven auto-computation).
-- This is a plain manual flag, one column, on the table that's already
-- the live per-player-per-team roster row (team_persons, read by
-- Team::getTeamRoster).

BEGIN;

ALTER TABLE team_persons
    ADD COLUMN IF NOT EXISTS lineup_role VARCHAR(10)
        CHECK (lineup_role IS NULL OR lineup_role IN ('starter', 'bench'));

COMMENT ON COLUMN team_persons.lineup_role IS
    'Coach-set "eligible for starting lineup" / "eligible for bench" designation, manually edited from the game-lineup screen. NULL = no designation.';

COMMIT;
