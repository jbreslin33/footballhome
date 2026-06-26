-- 052: short pill labels for mens columns.
-- The full `label` (e.g. "🇧🇷 Brazil") is great for column headers but
-- too wide for the tiny per-card pills.  `short_label` lets each row
-- pick a compact identifier (flag for country teams, abbreviation for
-- league teams like "U23" / "APSL" / "L1").

ALTER TABLE mens_team_columns
  ADD COLUMN IF NOT EXISTS short_label TEXT;

UPDATE mens_team_columns SET short_label = '🇧🇷'  WHERE team_id = 904 AND short_label IS NULL;
UPDATE mens_team_columns SET short_label = '🇵🇷'  WHERE team_id = 905 AND short_label IS NULL;
UPDATE mens_team_columns SET short_label = 'U23' WHERE team_id = 903 AND short_label IS NULL;
