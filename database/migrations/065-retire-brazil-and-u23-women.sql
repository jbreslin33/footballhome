-- Migration 065: Retire Brazil + U23 Women; categorize Tri County as women's
-- ============================================================================
-- Two changes:
--   1. Brazil (904) and U23 Women (902) are retired — detached from club
--      134 and their open rosters closed.  Team rows remain so historical
--      matches/rosters still resolve, but they no longer show on any
--      /lineups view.
--   2. Tri County Women (901) gets categorized as 'womens' so the mens
--      lineup screen can filter it out.  All other club-134 teams get
--      categorized as 'mens'.  A future womens-roster page will filter
--      with ?gender=womens.
--
-- New column: teams.gender_category text NULL allowed.  Values: 'mens',
-- 'womens', 'youth', or NULL (unspecified — treated as mens for backward
-- compat by the lineup screen).

BEGIN;

ALTER TABLE teams
  ADD COLUMN IF NOT EXISTS gender_category TEXT;

COMMENT ON COLUMN teams.gender_category IS
  'Coarse gender bucket used by /api/clubs/:id team filtering: '
  '"mens" | "womens" | "youth" | NULL.  The /lineups (mens) screen filters '
  'to gender_category=mens or NULL; a future womens lineup screen will '
  'pass ?gender=womens to surface women''s teams instead.';

-- Retire Brazil + U23 Women.
UPDATE rosters SET left_at = NOW()
 WHERE team_id IN (902, 904) AND left_at IS NULL;

UPDATE teams SET club_id = NULL
 WHERE id IN (902, 904);

-- Categorize remaining club-134 teams.
UPDATE teams SET gender_category = 'womens'
 WHERE id = 901;

UPDATE teams SET gender_category = 'mens'
 WHERE club_id = 134
   AND id <> 901
   AND gender_category IS NULL;

COMMIT;
