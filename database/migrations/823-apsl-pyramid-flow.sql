-- 823 (2026-10-29) — #apsl as a flow chart: tables, arrows, zones.
--
-- Owner 2026-10-29, on the first cut (mig 819): "so lets take delaware
-- river conference. i want the conference shown in a container with
-- relegation and playoff spots in red and green. then under it are the
-- feeder leagues connected by arrows like a flow chart … the feeder leagues
-- for delaware river are CASA Select Philadelphia, Lancaster, North Jersey
-- and Central Jersey, then some of these feeders have liga 2 feeding it and
-- maybe liga 3 … (some rare occurrences will have like North Jersey casa
-- feed into delaware river and metropolitan depending on team location)."
--
-- 1. The unit of the chart is a TABLE.  pyramid_flows holds the arrows:
--    a table feeds a table, or a whole conference.  Many-to-many, so North
--    Jersey Liga 1 → Delaware River AND Metropolitan.  Keyed by source +
--    table name (names survive a new season; feed ids do not).
-- 2. pyramid_division_zones: the coloured spots of a table (playoff,
--    relegation playoff, relegation …) as the source states them — APSL's
--    feed carries the league office's marks per table.
-- 3. CASA Select is four regional leagues (Philadelphia, Lancaster, North
--    Jersey, Central Jersey), each read straight from its SportsEngine
--    season ('sportsengine' source: standings computed from the season's
--    games).  Replaces mig 819's 'league_fixtures' source, so the NJ games
--    never enter league_fixtures / the #casa hub.

-- ── Sources: sportsengine replaces league_fixtures ─────────────────────
ALTER TABLE pyramid_sources DROP CONSTRAINT IF EXISTS pyramid_sources_system_check;
UPDATE pyramid_sources SET system = 'sportsengine', locator = '69f8ec901f20d170d3795cec', season_prefix = 'PHL '
 WHERE system = 'league_fixtures' AND locator = '1';
ALTER TABLE pyramid_sources ADD CONSTRAINT pyramid_sources_system_check
  CHECK (system IN ('teampass_json', 'teampass_tables', 'demosphere', 'sportsengine', 'root_soccer'));

-- ── CASA Select: four regional leagues ─────────────────────────────────
UPDATE pyramid_competitions
   SET name = 'CASA Select Philadelphia', short_name = 'CASA Philadelphia', region = 'Philadelphia',
       website_url = 'https://www.casasoccerleagues.com/page/show/9496152-philadelphia-select-divisions-2026-27-season',
       standings_url = 'https://www.casasoccerleagues.com/page/show/9496152-philadelphia-select-divisions-2026-27-season'
 WHERE name = 'Casa League of Pennsylvania';
UPDATE pyramid_competitions
   SET name = 'CASA Select North Jersey', short_name = 'CASA North Jersey', region = 'North Jersey', league_id = 2,
       website_url = 'https://www.casasoccerleagues.com/page/show/9457922-north-new-jersey-select-divisions-2026-27-season',
       standings_url = 'https://www.casasoccerleagues.com/page/show/9457922-north-new-jersey-select-divisions-2026-27-season'
 WHERE name = 'Casa League of New Jersey';

INSERT INTO pyramid_competitions (parent_id, kind, tier, name, short_name, region, league_id, website_url, standings_url, sort_order)
SELECT conf.id, 'affiliate', 2, v.name, v.short, v.region, 2, v.url, v.url, v.o
  FROM pyramid_competitions conf
  JOIN (VALUES ('CASA Select Lancaster',      'CASA Lancaster',      'Lancaster',
                'https://www.casasoccerleagues.com/page/show/9496174-lancaster-select-divisions-2026-27-season', 15),
               ('CASA Select Central Jersey', 'CASA Central Jersey', 'Central Jersey',
                'https://www.casasoccerleagues.com/page/show/9458758-central-new-jersey-select-divisions-2026-27-season', 30)
       ) AS v(name, short, region, url, o) ON true
 WHERE conf.name = 'Delaware River Conference' AND conf.kind = 'conference'
ON CONFLICT (parent_id, name) DO NOTHING;
UPDATE pyramid_competitions SET sort_order = 10 WHERE name = 'CASA Select Philadelphia';
UPDATE pyramid_competitions SET sort_order = 20 WHERE name = 'CASA Select North Jersey';

INSERT INTO pyramid_competition_states (competition_id, state_code)
SELECT c.id, v.code FROM pyramid_competitions c
  JOIN (VALUES ('CASA Select Lancaster', 'PA'), ('CASA Select Central Jersey', 'NJ')) AS v(name, code) ON v.name = c.name
ON CONFLICT DO NOTHING;

INSERT INTO pyramid_sources (competition_id, system, locator)
SELECT c.id, 'sportsengine', v.program
  FROM pyramid_competitions c
  JOIN (VALUES ('CASA Select Lancaster',      '69f8ef1c3192794de241e5ea'),
               ('CASA Select North Jersey',   '69c6e4582220efde33915d58'),
               ('CASA Select Central Jersey', '69c6edcbaf6215a2ff583d9b')) AS v(name, program) ON v.name = c.name
ON CONFLICT (system, locator) DO NOTHING;

-- ── Zones ──────────────────────────────────────────────────────────────
-- kind: playoff | promotion | relegation_playoff | relegation |
-- conditional_relegation.  Positions are table places, 1 = top.
CREATE TABLE IF NOT EXISTS pyramid_division_zones (
    division_id integer NOT NULL REFERENCES pyramid_divisions(id) ON DELETE CASCADE,
    kind        text NOT NULL,
    from_pos    integer NOT NULL,
    to_pos      integer NOT NULL,
    label       text NOT NULL,
    PRIMARY KEY (division_id, kind, from_pos)
);

-- ── Arrows ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_flows (
    id                 serial PRIMARY KEY,
    from_source_id     integer NOT NULL REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    from_division      text NOT NULL,
    to_competition_id  integer REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    to_source_id       integer REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    to_division        text,
    CHECK ((to_competition_id IS NOT NULL) <> (to_source_id IS NOT NULL AND to_division IS NOT NULL)),
    UNIQUE NULLS NOT DISTINCT (from_source_id, from_division, to_competition_id, to_source_id, to_division)
);

-- Into a conference: each feeder's top table.  Within a league: each
-- level into the one above.  MIPSL Open → Premier is read off the names.
WITH src AS (
    SELECT s.id, c.name FROM pyramid_sources s JOIN pyramid_competitions c ON c.id = s.competition_id),
conf AS (SELECT id, name FROM pyramid_competitions WHERE kind = 'conference')
INSERT INTO pyramid_flows (from_source_id, from_division, to_competition_id)
SELECT src.id, v.division, conf.id
  FROM (VALUES
    ('CASA Select Philadelphia',             'Liga 1',               'Delaware River Conference'),
    ('CASA Select Lancaster',                'Liga 1',               'Delaware River Conference'),
    ('CASA Select North Jersey',             'Liga 1',               'Delaware River Conference'),
    ('CASA Select North Jersey',             'Liga 1',               'Metropolitan Conference'),
    ('CASA Select Central Jersey',           'Liga 1',               'Delaware River Conference'),
    ('Cosmopolitan Soccer League',           'Division 1',           'Metropolitan Conference'),
    ('Long Island Soccer Football League',   'Premier',              'Metropolitan Conference'),
    ('Michigan Premier Soccer League',       'Premier',              'Mitten Conference'),
    ('Atlanta District Adult Soccer League', 'Division 1 - Group A', 'Terminus Conference'),
    ('Atlanta District Adult Soccer League', 'Division 1 - Group B', 'Terminus Conference')
  ) AS v(league, division, conference)
  JOIN src ON src.name = v.league
  JOIN conf ON conf.name = v.conference
ON CONFLICT DO NOTHING;

WITH src AS (
    SELECT s.id, c.name FROM pyramid_sources s JOIN pyramid_competitions c ON c.id = s.competition_id)
INSERT INTO pyramid_flows (from_source_id, from_division, to_source_id, to_division)
SELECT src.id, v.lower, src.id, v.upper
  FROM (VALUES
    ('CASA Select Philadelphia',           'Liga 2',     'Liga 1'),
    ('CASA Select North Jersey',           'Liga 2',     'Liga 1'),
    ('CASA Select North Jersey',           'Liga 3',     'Liga 2'),
    ('CASA Select Central Jersey',         'Liga 2',     'Liga 1'),
    ('Cosmopolitan Soccer League',         'Division 2', 'Division 1'),
    ('Cosmopolitan Soccer League',         'Division 3', 'Division 2'),
    ('Cosmopolitan Soccer League',         'Division 4', 'Division 3'),
    ('Long Island Soccer Football League', 'Division 1', 'Premier'),
    ('Long Island Soccer Football League', 'Division 2', 'Division 1'),
    ('Michigan Premier Soccer League',     'Open',       'Premier')
  ) AS v(league, lower, upper)
  JOIN src ON src.name = v.league
ON CONFLICT DO NOTHING;

-- ── Loader: groups map to their feed division; zones replaced per read ─
-- "817:Group A" (a TeamPass group inside division 817) maps like "817".
CREATE OR REPLACE FUNCTION fh_pyramid_load(p_source_id integer, p_divisions jsonb) RETURNS integer
LANGUAGE plpgsql AS $$
DECLARE
  src     pyramid_sources%ROWTYPE;
  d       jsonb;
  t       jsonb;
  z       jsonb;
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
     WHERE fd.source_id = src.id AND fd.external_id = split_part(d->>'ext_id', ':', 1);
    v_comp := coalesce(v_comp, src.competition_id);

    INSERT INTO pyramid_divisions (source_id, competition_id, external_id, name, sort_order, counts, last_seen_at, removed_at)
    VALUES (src.id, v_comp, d->>'ext_id', d->>'name', coalesce((d->>'sort')::int, 0),
            NOT ((d->>'name') = ANY (src.uncounted_divisions)), v_seen, NULL)
    ON CONFLICT (source_id, external_id) DO UPDATE
       SET competition_id = EXCLUDED.competition_id, name = EXCLUDED.name,
           sort_order = EXCLUDED.sort_order, counts = EXCLUDED.counts,
           last_seen_at = v_seen, removed_at = NULL
    RETURNING id INTO v_div;

    DELETE FROM pyramid_division_zones WHERE division_id = v_div;
    FOR z IN SELECT * FROM jsonb_array_elements(coalesce(d->'zones', '[]'::jsonb)) LOOP
      INSERT INTO pyramid_division_zones (division_id, kind, from_pos, to_pos, label)
      VALUES (v_div, z->>'kind', (z->>'from')::int, (z->>'to')::int, coalesce(z->>'label', z->>'kind'))
      ON CONFLICT DO NOTHING;
    END LOOP;

    FOR t IN SELECT * FROM jsonb_array_elements(coalesce(d->'teams', '[]'::jsonb)) LOOP
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

-- Re-read every source on the next page open (new tables, groups, zones).
UPDATE pyramid_sources SET last_fetched_at = NULL;

-- ── Copy: the flow chart replaces mig 819's three views ────────────────
DELETE FROM message_templates
 WHERE kind = 'apsl_pyramid' AND tier IN ('view_org', 'view_pyramid', 'view_tables', 'tier_1', 'tier_2', 'feeds', 'cups', 'no_source', 'empty');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('pill_all',     'APSL pyramid — All pill',                 'All', 30),
    ('also_feeds',   'APSL pyramid — table feeds another conf', 'also feeds {conference}', 43),
    ('no_feeders',   'APSL pyramid — conference w/o feeders',   'No affiliate league mirrored for this conference yet', 44),
    ('not_mirrored', 'APSL pyramid — affiliate w/o tables',     '{league}: tables not mirrored yet', 45),
    ('none_on',      'APSL pyramid — no conference picked',     'Pick a conference above.', 54)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
UPDATE message_templates SET body = '# - GP GD Pts'
 WHERE kind = 'apsl_pyramid' AND tier = 'table_head';
