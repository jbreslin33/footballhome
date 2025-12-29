-- 24-add-player-match-minutes.sql
-- Add per-match minutes and sub info to player_stats
ALTER TABLE player_stats
  ADD COLUMN is_starter BOOLEAN,
  ADD COLUMN sub_in_minute INTEGER,
  ADD COLUMN sub_out_minute INTEGER,
  ADD COLUMN minutes_played INTEGER;
