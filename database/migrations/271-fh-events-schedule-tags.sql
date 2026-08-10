-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 271: schedule-tag timestamps on fh_events
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the six new Description DSL time tags (docs/calendar-design.md
-- §6.1.5): Start:/End: (field booking window) and Arrival:/Warmup:/
-- Kickoff:/GameEnd: (player-facing schedule). Each tag carries a bare
-- time-of-day ("5:15pm"); the date is always the gcal event's own local
-- (America/New_York) calendar date — scripts/gcal-classify.js combines
-- the two into a timestamptz before writing here.
--
-- start_at/end_at are OVERRIDES ONLY — a NULL means "use the gcal
-- event's own starts_at/ends_at", so callers must read the effective
-- field window as COALESCE(fh_events.start_at, gcal_events.starts_at)
-- / COALESCE(fh_events.end_at, gcal_events.ends_at) rather than this
-- column alone. This avoids duplicating gcal's start/end on every row
-- that never overrides them.
--
-- arrival_at/warmup_at/kickoff_at/game_end_at have no default/fallback
-- — NULL means "not specified", full stop.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

ALTER TABLE fh_events
    ADD COLUMN IF NOT EXISTS start_at     TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS end_at       TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS arrival_at   TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS warmup_at    TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS kickoff_at   TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS game_end_at  TIMESTAMPTZ;

COMMENT ON COLUMN fh_events.start_at IS
    'Start: tag override for the field-booked window. NULL = use gcal_events.starts_at.';
COMMENT ON COLUMN fh_events.end_at IS
    'End: tag override for the field-booked window. NULL = use gcal_events.ends_at.';
COMMENT ON COLUMN fh_events.arrival_at IS
    'Arrival: tag — when players should show up. NULL = not specified.';
COMMENT ON COLUMN fh_events.warmup_at IS
    'Warmup: tag — warmup start. NULL = not specified.';
COMMENT ON COLUMN fh_events.kickoff_at IS
    'Kickoff: tag — whistle time. NULL = not specified.';
COMMENT ON COLUMN fh_events.game_end_at IS
    'GameEnd: tag — expected final whistle. NULL = not specified.';

COMMIT;
