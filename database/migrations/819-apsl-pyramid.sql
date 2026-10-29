-- 819 (2026-10-29) — #apsl: the APSL pyramid, live.
--
-- Owner 2026-10-29: "i want to build an apsl pyramid. with multiple views
-- with its feeder leagues and standings live … we want to show how big the
-- apsl and feeder system is. show keep club/team totals too."
--
-- The tree is data: pyramid_competitions holds APSL (the root), its
-- conferences (tier 1) and the "Affiliates - Tier 2" leagues listed on
-- apslsoccer.com/APSL/Affilates/ (tier 2).  parent_id = what a node feeds:
-- a conference's parent is APSL, an affiliate's parent is the conference
-- it feeds (read off its region; the affiliates page does not say).
--
-- Standings are mirrored, never typed: pyramid_sources says where each
-- league publishes its tables and in what shape; the backend (PyramidSync,
-- on #apsl open) and the host Chrome reader (scripts/pyramid-chrome-sync.js,
-- for sites that only render in a browser) both write through ONE function,
-- fh_pyramid_load(), so the two writers cannot drift.
--
-- These tables are a mirror of everyone's teams and deliberately NOT our
-- `teams` table (that one drives rosters, boards and RSVPs); the old
-- `standings` table stays the scraper-era APSL table keyed to it.
-- A club is matched across leagues by fh_pyramid_name_key() — "Peachtree
-- FC II" in ADASL is the same club as "Peachtree FC" in Terminus — and to
-- our own clubs row (crests, contacts) when the key matches it or one of
-- its club_aliases.

-- ── Tree ────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_competitions (
    id            serial PRIMARY KEY,
    parent_id     integer REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    slug          text UNIQUE,                 -- roots only: /api/pyramid?root=<slug>
    kind          text NOT NULL CHECK (kind IN ('league', 'conference', 'affiliate')),
    tier          smallint NOT NULL,
    name          text NOT NULL,
    short_name    text,
    region        text,
    league_id     integer REFERENCES leagues(id) ON DELETE SET NULL,
    website_url   text,
    standings_url text,
    sort_order    integer NOT NULL DEFAULT 0,
    is_active     boolean NOT NULL DEFAULT true,
    created_at    timestamptz NOT NULL DEFAULT now(),
    UNIQUE (parent_id, name)
);

CREATE TABLE IF NOT EXISTS pyramid_competition_states (
    competition_id integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    state_code     char(2) NOT NULL,
    PRIMARY KEY (competition_id, state_code)
);

-- ── Where the tables come from ─────────────────────────────────────────
-- system:  teampass_json   locator = TeamPass league id (Jumbotron feed, via
--                          the scraper proxy — whole league in one json)
--          teampass_tables locator = a TeamPass /<site>/Tables/ page URL
--          demosphere      locator = the Demosphere standings .html (the
--                          table data rides in the page as JSON)
--          league_fixtures locator = league_fixture_sources.id — standings
--                          computed from the scored fixtures we already sync
--          root_soccer     locator = the league's /standings page; renders
--                          only in a browser → scripts/pyramid-chrome-sync.js
CREATE TABLE IF NOT EXISTS pyramid_sources (
    id                  serial PRIMARY KEY,
    competition_id      integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    system              text NOT NULL CHECK (system IN ('teampass_json', 'teampass_tables', 'demosphere', 'league_fixtures', 'root_soccer')),
    locator             text NOT NULL,
    max_age_minutes     integer NOT NULL DEFAULT 60,
    -- Division names this source lists that are NOT counted in the totals
    -- (a feeder's table of teams that are already counted elsewhere).
    uncounted_divisions text[] NOT NULL DEFAULT '{}',
    -- A page that lists several seasons (ADASL's Tables page): keep only
    -- the tables whose name starts with this, shown without it.  Changes
    -- each season, like a season id in a locator.
    season_prefix       text,
    is_active           boolean NOT NULL DEFAULT true,
    last_fetched_at     timestamptz,
    last_ok_at          timestamptz,
    last_fetch_ok       boolean,
    last_fetch_note     text,
    created_at          timestamptz NOT NULL DEFAULT now(),
    UNIQUE (system, locator)
);

-- A source covering several nodes (APSL's one feed = every conference):
-- which of the feed's divisions belongs under which node.  Unmapped
-- divisions hang under the source's own competition.
CREATE TABLE IF NOT EXISTS pyramid_feed_divisions (
    source_id      integer NOT NULL REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    external_id    text NOT NULL,
    competition_id integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    PRIMARY KEY (source_id, external_id)
);

-- ── The mirror ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_divisions (
    id             serial PRIMARY KEY,
    source_id      integer NOT NULL REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    competition_id integer NOT NULL REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    external_id    text NOT NULL,
    name           text NOT NULL,
    sort_order     integer NOT NULL DEFAULT 0,
    counts         boolean NOT NULL DEFAULT true,
    last_seen_at   timestamptz NOT NULL DEFAULT now(),
    removed_at     timestamptz,
    UNIQUE (source_id, external_id)
);

CREATE TABLE IF NOT EXISTS pyramid_clubs (
    id         serial PRIMARY KEY,
    name       text NOT NULL,
    name_key   text NOT NULL UNIQUE,
    club_id    integer REFERENCES clubs(id) ON DELETE SET NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS pyramid_teams (
    id              serial PRIMARY KEY,
    division_id     integer NOT NULL REFERENCES pyramid_divisions(id) ON DELETE CASCADE,
    external_id     text NOT NULL,
    name            text NOT NULL,
    pyramid_club_id integer NOT NULL REFERENCES pyramid_clubs(id),
    position        integer,
    played          integer NOT NULL DEFAULT 0,
    wins            integer NOT NULL DEFAULT 0,
    draws           integer NOT NULL DEFAULT 0,
    losses          integer NOT NULL DEFAULT 0,
    goals_for       integer NOT NULL DEFAULT 0,
    goals_against   integer NOT NULL DEFAULT 0,
    goal_diff       integer GENERATED ALWAYS AS (goals_for - goals_against) STORED,
    points          integer NOT NULL DEFAULT 0,
    last_seen_at    timestamptz NOT NULL DEFAULT now(),
    removed_at      timestamptz,
    UNIQUE (division_id, external_id)
);
CREATE INDEX IF NOT EXISTS idx_pyramid_teams_club ON pyramid_teams(pyramid_club_id);

-- ── Club identity across leagues ───────────────────────────────────────
-- lower case; drop "(W)", "(APSL)", "(-3)"; drop an age tail ("O-35
-- White", "Over-30"); punctuation to spaces; drop trailing reserve marks
-- (II, III, B, Reserves, 1–4); squeeze spaces.
CREATE OR REPLACE FUNCTION fh_pyramid_name_key(p text) RETURNS text
LANGUAGE sql IMMUTABLE AS $$
  SELECT NULLIF(btrim(regexp_replace(
           regexp_replace(
             regexp_replace(
               regexp_replace(
                 regexp_replace(lower(coalesce(p, '')), '\([^)]*\)', ' ', 'g'),
                 '\s+(o|over)\s*-?\s*\d{2}\M.*$', ''),
               '[^a-z0-9 ]+', ' ', 'g'),
             '(\s+(ii|iii|iv|b|c|reserves?|res|[1-4]))+\s*$', ''),
           '\s+', ' ', 'g')), '')
$$;

-- ── The one writer ─────────────────────────────────────────────────────
-- p_divisions: [{ext_id, name, sort, teams: [{ext_id, name, club, pos,
--               gp, w, d, l, gf, ga, pts}]}] — the source's WHOLE read.
-- Upserts, retires what the read no longer lists, links clubs, stamps the
-- source.  A read with no teams raises (a broken parse must not wipe the
-- tables); the caller then stamps the failure on the source row.
CREATE OR REPLACE FUNCTION fh_pyramid_load(p_source_id integer, p_divisions jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  src     pyramid_sources%ROWTYPE;
  d       jsonb;
  t       jsonb;
  v_comp  integer;
  v_div   integer;
  v_club  integer;
  v_key   text;
  v_cname text;
  v_explicit boolean;
  v_teams integer;
  v_seen  timestamptz := clock_timestamp();
BEGIN
  SELECT * INTO src FROM pyramid_sources WHERE id = p_source_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'pyramid source % not found', p_source_id; END IF;

  IF src.season_prefix IS NOT NULL THEN
    SELECT coalesce(jsonb_agg(x || jsonb_build_object('name', btrim(substr(x->>'name', length(src.season_prefix) + 1)))), '[]'::jsonb)
      INTO p_divisions
      FROM jsonb_array_elements(coalesce(p_divisions, '[]'::jsonb)) x
     WHERE starts_with(x->>'name', src.season_prefix);
  END IF;

  SELECT count(*) INTO v_teams
    FROM jsonb_array_elements(coalesce(p_divisions, '[]'::jsonb)) x,
         jsonb_array_elements(coalesce(x->'teams', '[]'::jsonb)) y;
  IF v_teams = 0 THEN
    RAISE EXCEPTION 'pyramid source %: the read found no teams — previous tables kept', p_source_id;
  END IF;

  FOR d IN SELECT * FROM jsonb_array_elements(p_divisions) LOOP
    v_comp := NULL;
    SELECT fd.competition_id INTO v_comp
      FROM pyramid_feed_divisions fd
     WHERE fd.source_id = src.id AND fd.external_id = d->>'ext_id';
    v_comp := coalesce(v_comp, src.competition_id);

    INSERT INTO pyramid_divisions (source_id, competition_id, external_id, name, sort_order, counts, last_seen_at, removed_at)
    VALUES (src.id, v_comp, d->>'ext_id', d->>'name', coalesce((d->>'sort')::int, 0),
            NOT ((d->>'name') = ANY (src.uncounted_divisions)), v_seen, NULL)
    ON CONFLICT (source_id, external_id) DO UPDATE
       SET competition_id = EXCLUDED.competition_id, name = EXCLUDED.name,
           sort_order = EXCLUDED.sort_order, counts = EXCLUDED.counts,
           last_seen_at = v_seen, removed_at = NULL
    RETURNING id INTO v_div;

    FOR t IN SELECT * FROM jsonb_array_elements(coalesce(d->'teams', '[]'::jsonb)) LOOP
      -- The league's own club name when it states one (TeamPass), else the
      -- team's; "(APSL)", "(W)" never shown.  A stated club name wins over
      -- one made from a team name.
      v_explicit := nullif(btrim(t->>'club'), '') IS NOT NULL;
      v_cname := btrim(regexp_replace(coalesce(nullif(btrim(t->>'club'), ''), btrim(t->>'name')), '\s*\([^)]*\)', '', 'g'));
      v_key := fh_pyramid_name_key(v_cname);
      CONTINUE WHEN v_key IS NULL;
      INSERT INTO pyramid_clubs (name, name_key) VALUES (v_cname, v_key)
      ON CONFLICT (name_key) DO UPDATE SET name = EXCLUDED.name WHERE v_explicit;
      SELECT id INTO v_club FROM pyramid_clubs WHERE name_key = v_key;

      INSERT INTO pyramid_teams (division_id, external_id, name, pyramid_club_id, position,
                                 played, wins, draws, losses, goals_for, goals_against, points,
                                 last_seen_at, removed_at)
      VALUES (v_div, coalesce(nullif(t->>'ext_id', ''), btrim(t->>'name')), btrim(t->>'name'), v_club,
              (t->>'pos')::int,
              coalesce((t->>'gp')::int, 0), coalesce((t->>'w')::int, 0), coalesce((t->>'d')::int, 0),
              coalesce((t->>'l')::int, 0), coalesce((t->>'gf')::int, 0), coalesce((t->>'ga')::int, 0),
              coalesce((t->>'pts')::int, 0), v_seen, NULL)
      ON CONFLICT (division_id, external_id) DO UPDATE
         SET name = EXCLUDED.name, pyramid_club_id = EXCLUDED.pyramid_club_id,
             position = EXCLUDED.position, played = EXCLUDED.played, wins = EXCLUDED.wins,
             draws = EXCLUDED.draws, losses = EXCLUDED.losses, goals_for = EXCLUDED.goals_for,
             goals_against = EXCLUDED.goals_against, points = EXCLUDED.points,
             last_seen_at = v_seen, removed_at = NULL;
    END LOOP;
  END LOOP;

  UPDATE pyramid_teams pt SET removed_at = v_seen
    FROM pyramid_divisions pd
   WHERE pd.id = pt.division_id AND pd.source_id = src.id
     AND pt.removed_at IS NULL AND pt.last_seen_at < v_seen;
  UPDATE pyramid_divisions SET removed_at = v_seen
   WHERE source_id = src.id AND removed_at IS NULL AND last_seen_at < v_seen;

  UPDATE pyramid_clubs pc SET club_id = c.id
    FROM clubs c
   WHERE pc.club_id IS NULL AND fh_pyramid_name_key(c.name) = pc.name_key;
  UPDATE pyramid_clubs pc SET club_id = a.club_id
    FROM club_aliases a
   WHERE pc.club_id IS NULL AND fh_pyramid_name_key(a.alias) = pc.name_key;

  UPDATE pyramid_sources
     SET last_fetched_at = v_seen, last_ok_at = v_seen, last_fetch_ok = true, last_fetch_note = NULL
   WHERE id = src.id;
  RETURN v_teams;
END $$;

-- ── Seed: APSL 2026/27 + its Tier 2 affiliates ─────────────────────────
INSERT INTO pyramid_competitions (slug, kind, tier, name, short_name, league_id, website_url, standings_url, sort_order)
SELECT 'apsl', 'league', 1, 'American Premier Soccer League', 'APSL', 1,
       'https://www.apslsoccer.com', 'https://app.teampass.com/APSL/Tables/', 0
WHERE NOT EXISTS (SELECT 1 FROM pyramid_competitions WHERE slug = 'apsl');

INSERT INTO pyramid_competitions (parent_id, kind, tier, name, short_name, region, standings_url, sort_order)
SELECT root.id, 'conference', 1, v.name, v.short, v.region, 'https://app.teampass.com/APSL/Tables/', v.o
  FROM pyramid_competitions root,
       (VALUES ('Constitution Conference',   'Constitution',   'Connecticut',               10),
               ('Delaware River Conference', 'Delaware River', 'Pennsylvania & New Jersey', 20),
               ('Mayflower Conference',      'Mayflower',      'Massachusetts',             30),
               ('Metropolitan Conference',   'Metropolitan',   'New York & New Jersey',     40),
               ('Mid-Atlantic Conference',   'Mid-Atlantic',   'Maryland & Virginia',       50),
               ('Mitten Conference',         'Mitten',         'Michigan',                  60),
               ('Terminus Conference',       'Terminus',       'Georgia',                   70),
               ('Trinity Conference',        'Trinity',        'Texas',                     80)) AS v(name, short, region, o)
 WHERE root.slug = 'apsl'
ON CONFLICT (parent_id, name) DO NOTHING;

INSERT INTO pyramid_competitions (parent_id, kind, tier, name, short_name, region, league_id, website_url, standings_url, sort_order)
SELECT conf.id, 'affiliate', 2, v.name, v.short, v.region, v.league_id, v.web, v.tables, v.o
  FROM pyramid_competitions root
  JOIN pyramid_competitions conf ON conf.parent_id = root.id
  JOIN (VALUES
    ('Delaware River Conference', 'Casa League of Pennsylvania',         'CASA PA',   'Pennsylvania',                 2,    'https://www.casasoccerleagues.com/page/show/9386241-pennsylvania', 'https://www.casasoccerleagues.com/page/show/9386241-pennsylvania', 10),
    ('Delaware River Conference', 'Casa League of New Jersey',           'CASA NJ',   'New Jersey',                   NULL, 'https://www.casasoccerleagues.com/newjersey',    'https://www.casasoccerleagues.com/newjersey',    20),
    ('Mayflower Conference',      'Casa League of Massachusetts',        'CASA MA',   'Boston Metro Area',            NULL, 'https://www.casasoccerleagues.com/massachusetts', 'https://www.casasoccerleagues.com/massachusetts', 10),
    ('Metropolitan Conference',   'Cosmopolitan Soccer League',          'Cosmo',     'New York Metro Area',          4,    'https://cosmosoccerleague.com',                  'https://app.teampass.com/CSL/Tables/',           10),
    ('Metropolitan Conference',   'Long Island Soccer Football League',  'LISFL',     'Long Island',                  NULL, 'https://www.lisfl.org',                          'https://www.lisfl.org/standings',                20),
    ('Mid-Atlantic Conference',   'Maryland Major Soccer League',        'MMSL',      'Washington/Baltimore Metro',   NULL, 'https://www.marylandmajorsoccer.com',            NULL,                                             10),
    ('Mitten Conference',         'Michigan Premier Soccer League',      'MIPSL',     'Detroit Metro Area',           NULL, 'https://www.mipsl.com',                          'https://www.mipsl.com/standings',                10),
    ('Terminus Conference',       'Atlanta District Adult Soccer League', 'ADASL',    'Atlanta Metro Area',           NULL, 'https://www.adasl.com',                          'https://app.teampass.com/adasl/Tables/',         10)
  ) AS v(conf, name, short, region, league_id, web, tables, o) ON v.conf = conf.name
 WHERE root.slug = 'apsl'
ON CONFLICT (parent_id, name) DO NOTHING;

INSERT INTO pyramid_competition_states (competition_id, state_code)
SELECT c.id, s.code
  FROM pyramid_competitions c
  JOIN (VALUES ('Constitution Conference', 'CT'),
               ('Delaware River Conference', 'PA'), ('Delaware River Conference', 'NJ'),
               ('Mayflower Conference', 'MA'),
               ('Metropolitan Conference', 'NY'), ('Metropolitan Conference', 'NJ'),
               ('Mid-Atlantic Conference', 'MD'), ('Mid-Atlantic Conference', 'VA'),
               ('Mitten Conference', 'MI'),
               ('Terminus Conference', 'GA'),
               ('Trinity Conference', 'TX'),
               ('Casa League of Pennsylvania', 'PA'),
               ('Casa League of New Jersey', 'NJ'),
               ('Casa League of Massachusetts', 'MA'),
               ('Cosmopolitan Soccer League', 'NY'),
               ('Long Island Soccer Football League', 'NY'),
               ('Maryland Major Soccer League', 'MD'),
               ('Michigan Premier Soccer League', 'MI'),
               ('Atlanta District Adult Soccer League', 'GA')) AS s(name, code) ON s.name = c.name
ON CONFLICT DO NOTHING;

-- CASA NJ / CASA MA (SportsEngine, programs not found yet) and MMSL (no
-- public tables found) get no source: the page shows them as structure
-- with a link to the league's site.
INSERT INTO pyramid_sources (competition_id, system, locator, uncounted_divisions, season_prefix)
SELECT c.id, v.system, v.locator, v.uncounted,
       CASE WHEN v.system = 'teampass_tables' THEN 'Major 26 - 27 - ' END
  FROM pyramid_competitions c
  JOIN (VALUES
    ('American Premier Soccer League',       'teampass_json',   '3841', '{}'::text[]),
    ('Cosmopolitan Soccer League',           'teampass_json',   '3840', '{}'::text[]),
    ('Atlanta District Adult Soccer League', 'teampass_tables', 'https://app.teampass.com/adasl/Tables/', '{}'::text[]),
    ('Long Island Soccer Football League',   'demosphere',      'https://elements.demosphere.com/72839/standings/2026-2027/117020670.html', '{}'::text[]),
    ('Casa League of Pennsylvania',          'league_fixtures', '1', '{}'::text[]),
    -- MIPSL's own "APSL" table lists the Mitten clubs already counted
    -- under the conference.
    ('Michigan Premier Soccer League',       'root_soccer',     'https://www.mipsl.com/standings', '{APSL}'::text[])
  ) AS v(name, system, locator, uncounted) ON v.name = c.name
ON CONFLICT (system, locator) DO NOTHING;

-- The APSL feed's divisions (TeamPass division ids, 2026/27) → conferences.
-- Mid-Atlantic plays as two divisions, Chesapeake and Old Dominion.
INSERT INTO pyramid_feed_divisions (source_id, external_id, competition_id)
SELECT s.id, v.ext, c.id
  FROM pyramid_sources s
  JOIN (VALUES ('18604', 'Constitution Conference'),
               ('817',   'Delaware River Conference'),
               ('17825', 'Mayflower Conference'),
               ('818',   'Metropolitan Conference'),
               ('24397', 'Mid-Atlantic Conference'),
               ('24398', 'Mid-Atlantic Conference'),
               ('22958', 'Mitten Conference'),
               ('20083', 'Terminus Conference'),
               ('22901', 'Trinity Conference')) AS v(ext, conf) ON true
  JOIN pyramid_competitions c ON c.name = v.conf AND c.kind = 'conference'
 WHERE s.system = 'teampass_json' AND s.locator = '3841'
ON CONFLICT DO NOTHING;

-- ── Copy ───────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('tile_title',  'APSL pyramid — picker tile title',    'APSL Pyramid', 10),
    ('tile_sub',    'APSL pyramid — picker tile subtitle', 'Every conference and feeder league, live tables, club and team totals', 11),
    ('title',       'APSL pyramid — page title',           '🔺 APSL Pyramid', 20),
    ('subtitle',    'APSL pyramid — page subtitle',        'The APSL, its conferences and the Tier 2 leagues that feed them', 21),
    ('totals',      'APSL pyramid — totals strip',         '{leagues} leagues · {clubs} clubs · {teams} teams · {states} states', 22),
    ('view_org',    'APSL pyramid — org chart pill',       'Org chart', 30),
    ('view_pyramid','APSL pyramid — pyramid pill',         'Pyramid', 31),
    ('view_tables', 'APSL pyramid — standings pill',       'Standings', 32),
    ('tier_1',      'APSL pyramid — tier 1 label',         'Tier 1 · APSL conferences', 40),
    ('tier_2',      'APSL pyramid — tier 2 label',         'Tier 2 · Affiliate leagues', 41),
    ('node_counts', 'APSL pyramid — box counts',           '{clubs} clubs · {teams} teams', 42),
    ('feeds',       'APSL pyramid — feeds line',           'feeds {parent}', 43),
    ('cups',        'APSL pyramid — cups heading',         'Cups', 44),
    ('no_source',   'APSL pyramid — no live tables',       'Tables not mirrored yet — open the league''s site', 50),
    ('stale',       'APSL pyramid — last read failed',     'Last read failed — showing the tables from {when}', 51),
    ('read_at',     'APSL pyramid — read time',            'read {when}', 52),
    ('site_link',   'APSL pyramid — league site link',     'League site ↗', 53),
    ('empty',       'APSL pyramid — nothing yet',          'No tables read yet — tap Refresh.', 54)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

-- Table column heads, space-separated in table order; '-' = the (blank)
-- team column's head.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — table column heads', 'apsl_pyramid', 'table_head', NULL, '# - GP W D L GF GA GD Pts', 55, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'table_head');
