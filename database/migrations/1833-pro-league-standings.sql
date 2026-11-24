-- 1833 (2026-11-24) — 🔺 #apsl-pyramid: the professional leagues above the
-- APSL carry their live tables (owner: "and show the standings of mls lol"
-- · "and league one etc").
--
-- pro_league_tiers   U.S. Soccer's professional divisions (label)
-- pro_leagues        a league in a division; where its table is read
--                    (feed_system 'espn' = ESPN's public standings JSON,
--                    feed_locator its league code).  NULL feed = the league
--                    is named, no table (MLS NEXT Pro: none in that feed).
-- pro_league_tables  one table per conference (or the single table)
-- pro_league_teams   a row of a table
--
-- PyramidSync (C++) reads the feed when fh_pro_league_due() says so and
-- fh_pro_league_load() does every write.  /api/pyramid carries it as `pro`.
-- The 'label|league;league' wording rows of mig 1788 are replaced by these
-- tables and deleted.
BEGIN;

CREATE TABLE pro_league_tiers (
  tier  smallint PRIMARY KEY,
  label text NOT NULL
);

CREATE TABLE pro_leagues (
  id              serial PRIMARY KEY,
  tier            smallint NOT NULL REFERENCES pro_league_tiers(tier),
  name            text NOT NULL UNIQUE,
  sort_order      integer NOT NULL DEFAULT 0,
  feed_system     text CHECK (feed_system IN ('espn')),
  feed_locator    text,
  refresh_hours   integer NOT NULL DEFAULT 12,
  is_active       boolean NOT NULL DEFAULT true,
  last_fetched_at timestamptz,
  last_ok_at      timestamptz,
  last_fetch_note text,
  CHECK ((feed_system IS NULL) = (feed_locator IS NULL))
);

CREATE TABLE pro_league_tables (
  id         serial PRIMARY KEY,
  league_id  integer NOT NULL REFERENCES pro_leagues(id) ON DELETE CASCADE,
  name       text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  UNIQUE (league_id, name)
);

CREATE TABLE pro_league_teams (
  id            serial PRIMARY KEY,
  table_id      integer NOT NULL REFERENCES pro_league_tables(id) ON DELETE CASCADE,
  name          text NOT NULL,
  position      integer,
  played        integer NOT NULL DEFAULT 0,
  wins          integer NOT NULL DEFAULT 0,
  draws         integer NOT NULL DEFAULT 0,
  losses        integer NOT NULL DEFAULT 0,
  goals_for     integer NOT NULL DEFAULT 0,
  goals_against integer NOT NULL DEFAULT 0,
  points        integer NOT NULL DEFAULT 0,
  UNIQUE (table_id, name)
);

-- Due: has a feed, and never read or read longer ago than its refresh_hours.
CREATE FUNCTION fh_pro_league_due(p_league integer) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT is_active AND feed_system IS NOT NULL
         AND (last_fetched_at IS NULL OR last_fetched_at < now() - make_interval(hours => refresh_hours))
    FROM pro_leagues WHERE id = p_league
$$;

-- p_tables = [{name, teams:[{name, position, played, wins, draws, losses,
-- goals_for, goals_against, points}]}].  Replaces the league's tables.
-- Returns the number of teams stored.
CREATE FUNCTION fh_pro_league_load(p_league integer, p_tables jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  t jsonb; i integer := 0; tid integer; n integer := 0; k integer;
BEGIN
  DELETE FROM pro_league_tables WHERE league_id = p_league;
  FOR t IN SELECT * FROM jsonb_array_elements(p_tables) LOOP
    INSERT INTO pro_league_tables (league_id, name, sort_order) VALUES (p_league, t->>'name', i) RETURNING id INTO tid;
    i := i + 1;
    INSERT INTO pro_league_teams (table_id, name, position, played, wins, draws, losses, goals_for, goals_against, points)
    SELECT tid, x->>'name', (x->>'position')::int, COALESCE((x->>'played')::int, 0), COALESCE((x->>'wins')::int, 0),
           COALESCE((x->>'draws')::int, 0), COALESCE((x->>'losses')::int, 0), COALESCE((x->>'goals_for')::int, 0),
           COALESCE((x->>'goals_against')::int, 0), COALESCE((x->>'points')::int, 0)
      FROM jsonb_array_elements(t->'teams') x
    ON CONFLICT (table_id, name) DO NOTHING;
    GET DIAGNOSTICS k = ROW_COUNT;
    n := n + k;
  END LOOP;
  UPDATE pro_leagues SET last_fetched_at = now(), last_ok_at = now(), last_fetch_note = NULL WHERE id = p_league;
  RETURN n;
END $$;

INSERT INTO pro_league_tiers (tier, label) VALUES (1, 'Division I'), (2, 'Division II'), (3, 'Division III');
INSERT INTO pro_leagues (tier, name, sort_order, feed_system, feed_locator) VALUES
  (1, 'MLS', 1, 'espn', 'usa.1'),
  (2, 'USL Championship', 1, 'espn', 'usa.usl.1'),
  (3, 'USL League One', 1, 'espn', 'usa.usl.l1'),
  (3, 'MLS NEXT Pro', 2, NULL, NULL);

DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier ~ '^path_pro_[0-9]$';

COMMIT;
