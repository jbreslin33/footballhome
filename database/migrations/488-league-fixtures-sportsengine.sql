-- 488 (2026-09-28) — league fixtures in the DB, refreshed from SportsEngine.
-- Owner: "can you see casa liga 1 schedule? … for all teams? … is this in the
-- casa section on a pill? … we need it in db and refreshed on every access to
-- casa section of fh".
--
-- The CASA Select season (Liga 1 + Liga 2, every club) is one public
-- SportsEngine feed:  https://se-api.sportsengine.com/v3/microsites/events
-- ?program_id=<season program id>.  Each access to #casa (and #casa-schedule)
-- pulls that feed, upserts it here, then reads from here — so the page is
-- always current and still works from the last pull if SportsEngine is down.
--
--   league_fixture_sources  where a league season's fixtures come from
--                           (program id lives HERE, never in code — the
--                           2025/26 id was hardcoded in EventController and
--                           went stale when the season rolled over)
--   league_fixtures         one row per league game, keyed by the feed's
--                           event id; home/away resolved to clubs through
--                           club_aliases / clubs.name (mig 485 aliases)
CREATE TABLE IF NOT EXISTS league_fixture_sources (
    id              SERIAL PRIMARY KEY,
    league_id       INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    league_label    TEXT NOT NULL,                    -- matches club_competitions.league_label ('CASA')
    season          TEXT NOT NULL DEFAULT '2026/27',
    system          TEXT NOT NULL DEFAULT 'sportsengine',
    program_id      TEXT NOT NULL,                    -- SportsEngine season program id
    label           TEXT,                             -- the feed's own season name
    team_page_base  TEXT,                             -- + <season team id> = that team's public page
    is_active       BOOLEAN NOT NULL DEFAULT true,
    last_fetched_at TIMESTAMPTZ,
    last_fetch_ok   BOOLEAN,
    last_fetch_note TEXT,                             -- '84 games' or the error
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (league_label, season, program_id)
);
COMMENT ON TABLE league_fixture_sources IS 'Where a league season''s fixture list is pulled from (mig 488). One row per SportsEngine season program; refreshed on every access to the league''s section.';

CREATE TABLE IF NOT EXISTS league_fixtures (
    id                  SERIAL PRIMARY KEY,
    source_id           INTEGER NOT NULL REFERENCES league_fixture_sources(id) ON DELETE CASCADE,
    external_id         TEXT NOT NULL,                -- SportsEngine event id
    division_name       TEXT,                         -- as the feed says it ('PHL Liga 1')
    division_label      TEXT,                         -- as club_competitions says it ('Liga 1')
    starts_at           TIMESTAMPTZ NOT NULL,
    ends_at             TIMESTAMPTZ,
    status              TEXT NOT NULL,                -- scheduled | completed | postponed | cancelled …
    home_name           TEXT NOT NULL,
    away_name           TEXT NOT NULL,
    home_club_id        INTEGER REFERENCES clubs(id) ON DELETE SET NULL,
    away_club_id        INTEGER REFERENCES clubs(id) ON DELETE SET NULL,
    home_ext_team_id    TEXT,                         -- season team id → team page
    away_ext_team_id    TEXT,
    home_score          INTEGER,
    away_score          INTEGER,
    venue_name          TEXT,
    venue_detail        TEXT,                         -- 'Turf', 'Majors Field (Grass)'
    venue_address       TEXT,
    external_updated_at TIMESTAMPTZ,
    first_seen_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    removed_at          TIMESTAMPTZ,                  -- set when a full pull no longer lists it
    UNIQUE (source_id, external_id)
);
CREATE INDEX IF NOT EXISTS league_fixtures_when_idx ON league_fixtures (source_id, division_label, starts_at);
COMMENT ON TABLE league_fixtures IS 'Every game of a league season as its league publishes it (mig 488); the club''s own games are the rows whose home/away club is Lighthouse.';

-- Opponent text → club, the chain the crests and Opponents cards use.
CREATE OR REPLACE FUNCTION fh_club_id_for_name(p_name text) RETURNS integer
LANGUAGE sql STABLE AS $$
  SELECT COALESCE((SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM(p_name)) LIMIT 1),
                  (SELECT id FROM clubs WHERE LOWER(BTRIM(name)) = LOWER(BTRIM(p_name)) ORDER BY id LIMIT 1));
$$;

-- CASA Select 2026/27 = SportsEngine season "PHL | Select 11v11 | 2026-27".
INSERT INTO league_fixture_sources (league_id, league_label, season, program_id, label, team_page_base)
SELECT 2, 'CASA', '2026/27', '69f8ec901f20d170d3795cec', 'PHL | Select 11v11 | 2026-27',
       'https://season-microsites.ui.sportsengine.com/seasons/69f8ec901f20d170d3795cec/teams/'
 WHERE NOT EXISTS (SELECT 1 FROM league_fixture_sources WHERE league_label = 'CASA' AND season = '2026/27');

-- Copy, kind 'casa' (mig 486 pattern).  The hub's schedule tile now opens
-- #casa-schedule instead of unfolding outside links.
UPDATE message_templates SET subject = 'Schedule & results', body = 'Every Liga 1 and Liga 2 game with scores and venues, pulled from SportsEngine each time you open this'
 WHERE kind = 'casa' AND tier = 'tile_links';
CREATE OR REPLACE FUNCTION pg_temp.casa_tpl(p_tier text, p_label text, p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'CASA', p_label, 'casa', p_tier, p_subject, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'casa' AND tier = p_tier);
$$;
SELECT pg_temp.casa_tpl('schedule_title',     'CASA schedule — title',            NULL, 'CASA schedule & results', 20);
SELECT pg_temp.casa_tpl('schedule_subtitle',  'CASA schedule — subtitle',         NULL, 'Refreshed from SportsEngine {when}. {n} games this season.', 21);
SELECT pg_temp.casa_tpl('schedule_stale',     'CASA schedule — feed unreachable', NULL, 'SportsEngine did not answer just now — showing the list from {when}.', 22);
SELECT pg_temp.casa_tpl('schedule_links',     'CASA schedule — outside links',    NULL, 'League pages', 23);
SELECT pg_temp.casa_tpl('schedule_empty',     'CASA schedule — nothing',          NULL, 'No games match.', 24);
