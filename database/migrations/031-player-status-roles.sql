-- Migration 031: Add internal role, injury, and suspension status to players
-- internal_role: APSL/Liga-level starter/bench assignment (purely internal, may differ from league rosters)
-- is_injured, is_suspended_league, is_suspended_inhouse: per-player status flags

ALTER TABLE players
  ADD COLUMN IF NOT EXISTS internal_role VARCHAR(20)
    CHECK (internal_role IN ('apsl_starter','apsl_bench','liga1_starter','liga1_bench','liga2_starter','liga2_bench'))
    DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS is_injured BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_suspended_league BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_suspended_inhouse BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN players.internal_role IS 'Internal classification: which team/level this player is a starter or bench player for. Independent of external league roster assignments.';
COMMENT ON COLUMN players.is_injured IS 'Player is currently injured and should not be selected for lineups.';
COMMENT ON COLUMN players.is_suspended_league IS 'Player is under an external league suspension.';
COMMENT ON COLUMN players.is_suspended_inhouse IS 'Player is under an internal/in-house suspension.';

INSERT INTO migrations (name) VALUES ('031-player-status-roles') ON CONFLICT DO NOTHING;
