-- Migration 045: Public team views (gameday + lineup share URLs)
--
-- Adds the data model needed to expose two permanent per-team public URLs
-- that players can pin in chats:
--   /t/:slug/gameday  -- 18/20 man roster card (default visible)
--   /t/:slug/lineup   -- starters + bench + pitch (default hidden until coach publishes)
--   /t/:slug/schedule -- full team schedule with the "live" match highlighted
--
-- The "live match" pointer auto-resolves on the server to the earliest
-- non-completed match for the team. Coaches can manually pin a match
-- (live_match_pinned=true) to override the auto-resolution. When a match
-- transitions to completed, the auto pointer naturally rolls forward.
-- If no upcoming match exists, the most recent completed match remains live.

-- ── teams: slug + live-match pointer ────────────────────────────────────
ALTER TABLE teams ADD COLUMN IF NOT EXISTS slug VARCHAR(100);
ALTER TABLE teams ADD COLUMN IF NOT EXISTS live_match_id INTEGER REFERENCES matches(id) ON DELETE SET NULL;
ALTER TABLE teams ADD COLUMN IF NOT EXISTS live_match_pinned BOOLEAN NOT NULL DEFAULT false;

COMMENT ON COLUMN teams.slug IS 'URL-safe identifier for public pinnable team links (e.g. /t/u23-men/gameday). Unique.';
COMMENT ON COLUMN teams.live_match_id IS 'Manually pinned live match (only honored when live_match_pinned=true). Otherwise server resolves dynamically.';
COMMENT ON COLUMN teams.live_match_pinned IS 'When true, live_match_id is sticky until coach unpins. When false, server resolves the live match dynamically (earliest non-completed, or most recent completed as fallback).';

-- ── matches: per-match visibility flags for public views ────────────────
ALTER TABLE matches ADD COLUMN IF NOT EXISTS gameday_hidden BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE matches ADD COLUMN IF NOT EXISTS lineup_hidden  BOOLEAN NOT NULL DEFAULT true;

COMMENT ON COLUMN matches.gameday_hidden IS 'When true, public /gameday view shows "Players to be selected soon" instead of the 18/20 roster. Default false (visible).';
COMMENT ON COLUMN matches.lineup_hidden  IS 'When true, public /lineup view shows "Lineup will be posted closer to kickoff" instead of starters/bench/pitch. Default true (hidden until coach publishes).';

-- ── slug backfill ───────────────────────────────────────────────────────
-- Lower-case + replace any non-alnum run with a single hyphen, trim hyphens.
-- Falls back to "team-<id>" for unprintable / collision cases.
UPDATE teams
SET slug = trim(both '-' from regexp_replace(lower(name), '[^a-z0-9]+', '-', 'g'))
WHERE slug IS NULL;

-- Resolve any duplicate slugs (e.g. same team name in two divisions) by
-- appending the team id to the duplicates. Keeps the first occurrence clean.
WITH dupes AS (
  SELECT id, slug,
         ROW_NUMBER() OVER (PARTITION BY slug ORDER BY id) AS rn
  FROM teams
  WHERE slug IS NOT NULL
)
UPDATE teams t
SET slug = t.slug || '-' || t.id
FROM dupes d
WHERE t.id = d.id AND d.rn > 1;

-- Guarantee no NULL/empty slugs remain
UPDATE teams
SET slug = 'team-' || id
WHERE slug IS NULL OR slug = '';

-- Now we can safely add the unique constraint + index
ALTER TABLE teams ADD CONSTRAINT teams_slug_unique UNIQUE (slug);
CREATE INDEX IF NOT EXISTS idx_teams_slug ON teams(slug);
CREATE INDEX IF NOT EXISTS idx_teams_live_match ON teams(live_match_id);
