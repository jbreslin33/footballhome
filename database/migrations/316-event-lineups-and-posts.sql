-- 316: Let lineups and social posts belong to any event, not just a match.
--
-- Why: practice and pickup need the same two things a game has — a squad
-- split into groups/sides, and an Instagram post. Both tables were keyed
-- `match_id NOT NULL REFERENCES matches(id)`, so neither was reachable
-- for an event that has no match row. (Owner, 2026-08-28: "practice can
-- have groups, session information etc" / "pickup can have teams too" /
-- "then allow for putting players on teams for the pickup".)
--
-- ADDITIVE, deliberately. `match_id` stays and keeps its meaning; a new
-- nullable `fh_event_id` sits beside it. Every existing query keyed on
-- match_id keeps working untouched, game rows carry both, and
-- practice/pickup rows carry fh_event_id alone.
--
-- A hard re-key was the obvious alternative and is NOT possible here:
-- 14 of the 26 social_posts rows point at matches that have no fh_events
-- row at all (older scraped matches, from before the 278 calendar
-- bridge). Forcing fh_event_id NOT NULL would strand them. match_lineups
-- has no such orphans — all 54 rows backfill cleanly — but it gets the
-- same shape for consistency.

BEGIN;

-- ── match_lineups ──────────────────────────────────────────────────────
ALTER TABLE match_lineups
    ADD COLUMN IF NOT EXISTS fh_event_id bigint REFERENCES fh_events(id) ON DELETE CASCADE;

-- fh_events.match_id is unique, so this is a 1:1 backfill with no
-- ambiguity about which event a lineup row belongs to.
UPDATE match_lineups ml
   SET fh_event_id = fe.id
  FROM fh_events fe
 WHERE fe.match_id = ml.match_id
   AND ml.fh_event_id IS NULL;

ALTER TABLE match_lineups ALTER COLUMN match_id DROP NOT NULL;

-- A row has to hang off something.
ALTER TABLE match_lineups
    DROP CONSTRAINT IF EXISTS match_lineups_has_owner_check;
ALTER TABLE match_lineups
    ADD CONSTRAINT match_lineups_has_owner_check
    CHECK (match_id IS NOT NULL OR fh_event_id IS NOT NULL);

-- The existing UNIQUE(match_id, player_id) can't police event-keyed rows,
-- because NULL match_ids are all distinct to Postgres. This is its
-- counterpart for the rows the old one can't see.
CREATE UNIQUE INDEX IF NOT EXISTS match_lineups_event_player_key
    ON match_lineups (fh_event_id, player_id)
    WHERE fh_event_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_match_lineups_fh_event
    ON match_lineups (fh_event_id)
    WHERE fh_event_id IS NOT NULL;

-- squad_color was CHECK'd to ('white','blue') and has been dead in the
-- code since it was added. Pickup sides are named by colour (owner:
-- "they are just pickup teams like blue, green etc"), so widen it to the
-- bib colours a club actually owns. Practice groups reuse the same
-- column -- a group is just a side by another name.
ALTER TABLE match_lineups
    DROP CONSTRAINT IF EXISTS match_lineups_squad_color_check;
ALTER TABLE match_lineups
    ADD CONSTRAINT match_lineups_squad_color_check
    CHECK (squad_color IS NULL OR squad_color IN
        ('white','blue','green','orange','red','black','yellow','pink'));

COMMENT ON COLUMN match_lineups.fh_event_id IS
    'Owning fh_events row. Set for every kind; match rows carry match_id too. Practice/pickup rows have match_id NULL.';
COMMENT ON COLUMN match_lineups.squad_color IS
    'Pickup side / practice group, by bib colour. NULL for match lineups, which use zone + position_id instead.';

-- ── social_posts ───────────────────────────────────────────────────────
ALTER TABLE social_posts
    ADD COLUMN IF NOT EXISTS fh_event_id bigint REFERENCES fh_events(id) ON DELETE CASCADE;

UPDATE social_posts sp
   SET fh_event_id = fe.id
  FROM fh_events fe
 WHERE fe.match_id = sp.match_id
   AND sp.fh_event_id IS NULL;

ALTER TABLE social_posts ALTER COLUMN match_id DROP NOT NULL;

ALTER TABLE social_posts
    DROP CONSTRAINT IF EXISTS social_posts_has_owner_check;
ALTER TABLE social_posts
    ADD CONSTRAINT social_posts_has_owner_check
    CHECK (match_id IS NOT NULL OR fh_event_id IS NOT NULL);

-- Counterpart to social_posts_match_id_team_id_post_type_id_platform_key
-- for event-keyed rows, for the same NULL reason as above.
CREATE UNIQUE INDEX IF NOT EXISTS social_posts_event_team_type_platform_key
    ON social_posts (fh_event_id, team_id, post_type_id, platform)
    WHERE match_id IS NULL AND fh_event_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_social_posts_fh_event
    ON social_posts (fh_event_id)
    WHERE fh_event_id IS NOT NULL;

COMMENT ON COLUMN social_posts.fh_event_id IS
    'Owning fh_events row. NULL for the 14 legacy posts whose match predates the fh_events bridge (migration 278).';

COMMIT;
