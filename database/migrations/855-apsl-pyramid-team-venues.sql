-- 855 (2026-10-29) — #apsl-pyramid: a home ground belongs to a TEAM.
--
-- Owner 2026-10-29: "use home field for teams of most common home field in
-- there schedule! oaklyn has 2 teams apsl and liga 1 and at diff sites for
-- each."  Mig 844 kept one venue per CLUB (the first a feed named); now:
--   pyramid_venues   one row per ground (address), geocoded once however
--                    many teams play there
--   pyramid_teams.venue_id   the ground of most of the games that team
--                    hosts, per the feed (TeamPass locations, SportsEngine
--                    home-game addresses) — refreshed every read
-- The club columns go; their geocodes move to pyramid_venues (no
-- re-geocoding).  Territories (mig 852) and drive times use the APSL
-- teams' grounds.

CREATE TABLE IF NOT EXISTS pyramid_venues (
    id           serial PRIMARY KEY,
    address      text NOT NULL UNIQUE,
    name         text,
    lat          numeric(10,7),
    lon          numeric(10,7),
    geocoded_at  timestamptz,
    geocode_note text
);
INSERT INTO pyramid_venues (address, name, lat, lon, geocoded_at, geocode_note)
SELECT DISTINCT ON (venue_address) venue_address, venue_name, lat, lon, geocoded_at, geocode_note
  FROM pyramid_clubs WHERE venue_address IS NOT NULL
 ORDER BY venue_address, lat IS NULL
ON CONFLICT (address) DO NOTHING;

ALTER TABLE pyramid_teams ADD COLUMN IF NOT EXISTS venue_id integer REFERENCES pyramid_venues(id) ON DELETE SET NULL;
-- Until each source is re-read, a team starts at its club's old venue.
UPDATE pyramid_teams t SET venue_id = v.id
  FROM pyramid_clubs c JOIN pyramid_venues v ON v.address = c.venue_address
 WHERE c.id = t.pyramid_club_id AND t.venue_id IS NULL;

DROP VIEW IF EXISTS pyramid_county_conference;
DROP VIEW IF EXISTS pyramid_club_conference;
ALTER TABLE pyramid_clubs DROP COLUMN IF EXISTS venue_name, DROP COLUMN IF EXISTS venue_address,
                          DROP COLUMN IF EXISTS lat, DROP COLUMN IF EXISTS lon,
                          DROP COLUMN IF EXISTS geocoded_at, DROP COLUMN IF EXISTS geocode_note;

-- Each APSL team (a team in an active conference's table) at a located
-- ground → its conference.  Only these draw borders (mig 852).
CREATE OR REPLACE VIEW pyramid_team_conference AS
SELECT t.id AS team_id, t.pyramid_club_id AS club_id, d.competition_id AS conference_id, v.lat, v.lon
  FROM pyramid_teams t
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions c ON c.id = d.competition_id AND c.kind = 'conference' AND c.is_active
  JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
 WHERE t.removed_at IS NULL;

CREATE OR REPLACE VIEW pyramid_county_conference AS
SELECT k.fips, k.population,
       CASE WHEN o.fips IS NOT NULL THEN o.competition_id ELSE n.conference_id END AS conference_id,
       n.km AS nearest_km
  FROM pyramid_counties k
  LEFT JOIN pyramid_county_overrides o ON o.fips = k.fips
  LEFT JOIN LATERAL (
        SELECT tc.conference_id, fh_km(k.lat, k.lon, tc.lat, tc.lon) AS km
          FROM pyramid_team_conference tc
         ORDER BY fh_km(k.lat, k.lon, tc.lat, tc.lon)
         LIMIT 1) n0 ON true
  LEFT JOIN LATERAL (
        SELECT n0.conference_id, n0.km
         WHERE n0.km <= (SELECT reach_km FROM pyramid_territory_policy)) n ON true;

-- Drive times are between teams' grounds now.
DELETE FROM pyramid_conference_travel;
ALTER TABLE pyramid_conference_travel DROP COLUMN IF EXISTS from_club_id, DROP COLUMN IF EXISTS to_club_id;
ALTER TABLE pyramid_conference_travel ADD COLUMN IF NOT EXISTS from_team_id integer REFERENCES pyramid_teams(id) ON DELETE SET NULL;
ALTER TABLE pyramid_conference_travel ADD COLUMN IF NOT EXISTS to_team_id integer REFERENCES pyramid_teams(id) ON DELETE SET NULL;
ALTER TABLE pyramid_conference_travel RENAME COLUMN club_set TO team_set;

-- Re-read every source so each team gets its own ground.
UPDATE pyramid_sources SET last_fetched_at = NULL;

-- ── Loader: the team's ground (upserted by address), each read ─────────
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
  v_venue integer;
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
      CONTINUE WHEN nullif(z->>'kind', '') IS NULL;
      INSERT INTO pyramid_zone_kinds (code, label, sort_order)
      VALUES (z->>'kind', coalesce(nullif(z->>'label', ''), z->>'kind'), 90)
      ON CONFLICT (code) DO NOTHING;
      INSERT INTO pyramid_division_zones (division_id, kind, from_pos, to_pos, label)
      VALUES (v_div, z->>'kind', (z->>'from')::int, (z->>'to')::int, coalesce(nullif(z->>'label', ''), z->>'kind'))
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
      v_venue := NULL;
      IF nullif(btrim(t->>'venue_address'), '') IS NOT NULL THEN
        INSERT INTO pyramid_venues (address, name) VALUES (btrim(t->>'venue_address'), nullif(btrim(t->>'venue_name'), ''))
        ON CONFLICT (address) DO UPDATE SET name = coalesce(EXCLUDED.name, pyramid_venues.name)
        RETURNING id INTO v_venue;
      END IF;

      INSERT INTO pyramid_teams (division_id, external_id, name, pyramid_club_id, position,
                                 played, wins, draws, losses, goals_for, goals_against, points,
                                 last_seen_at, removed_at, venue_id)
      VALUES (v_div, coalesce(nullif(t->>'ext_id', ''), btrim(t->>'name')), btrim(t->>'name'), v_club,
              (t->>'pos')::int,
              coalesce((t->>'gp')::int, 0), coalesce((t->>'w')::int, 0), coalesce((t->>'d')::int, 0),
              coalesce((t->>'l')::int, 0), coalesce((t->>'gf')::int, 0), coalesce((t->>'ga')::int, 0),
              coalesce((t->>'pts')::int, 0), v_seen, NULL, v_venue)
      ON CONFLICT (division_id, external_id) DO UPDATE
         SET name = EXCLUDED.name, pyramid_club_id = EXCLUDED.pyramid_club_id,
             position = EXCLUDED.position, played = EXCLUDED.played, wins = EXCLUDED.wins,
             draws = EXCLUDED.draws, losses = EXCLUDED.losses, goals_for = EXCLUDED.goals_for,
             goals_against = EXCLUDED.goals_against, points = EXCLUDED.points,
             last_seen_at = v_seen, removed_at = NULL,
             venue_id = coalesce(EXCLUDED.venue_id, pyramid_teams.venue_id);
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


-- The HUD counts teams now (a dot per team ground).
UPDATE message_templates SET body = '{located} of {clubs} teams at their home ground'
 WHERE kind = 'apsl_pyramid' AND tier = 'map_located';
