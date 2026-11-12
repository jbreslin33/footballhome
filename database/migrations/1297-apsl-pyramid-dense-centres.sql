-- 1297 (2026-11-12) — #apsl-pyramid: every metro is measured from where the
-- MOST of its people are (its densest spot), not the average of all of them.
--
-- Owner 2026-11-12: "maybe better than center of metro(s) — center of mass of
-- the most people in an area and then go from that point" → shown Philly's
-- two points (mean 39.976,-75.247 Overbrook/Wynnefield v densest 40.003,
-- -75.151 Broad & Allegheny) → "north philly one looks right, build it for
-- all … that is the right spot and would be all in country".
--
-- Why: the population-weighted mean (mig 1283) is dragged by thin outer
-- suburbs — Washington's sat at Tysons, 16 km from downtown; Philly's in
-- West Philly. The densest spot is where a metro's people actually are.
--
-- * pyramid_territory_policy.dense_radius_km (10): "densest spot" = the
--   Census tract point with the most people within this many km (same metro).
-- * pyramid_metro_dense_centers: one row per metro/micro area, filled by
--   fh_pyramid_dense_centers_refresh() (tracts are static — rerun only after
--   pyramid-load-tracts.py or a radius change).
-- * pyramid_metro_pop_centers keeps its name and columns but now returns the
--   densest spot (falls back to the mean when a metro has no row), so
--   pyramid_region_centers, pyramid_region_points (mig 1285, multi-metro
--   weighting unchanged) and every script follow without edits.
-- Pipeline after applying: pyramid-county-drive.py → SELECT
-- fh_pyramid_proposal_refresh() → pyramid-fine-borders.py →
-- pyramid-sea-borders.py → pyramid-drive-times.py.

ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS dense_radius_km numeric NOT NULL DEFAULT 10;
COMMENT ON COLUMN pyramid_territory_policy.dense_radius_km IS
    'mig 1297: a metro''s centre = the tract point with the most people within this many km.';

CREATE TABLE IF NOT EXISTS pyramid_metro_dense_centers (
    cbsa_code   text PRIMARY KEY REFERENCES pyramid_metro_areas(cbsa_code),
    geoid       text NOT NULL REFERENCES pyramid_tracts(geoid),
    lat         numeric(10,7) NOT NULL,
    lon         numeric(10,7) NOT NULL,
    people_near bigint NOT NULL,
    radius_km   numeric NOT NULL
);
COMMENT ON TABLE pyramid_metro_dense_centers IS
    'mig 1297: each metro/micro area''s densest spot — tract point with the most people within policy dense_radius_km; fh_pyramid_dense_centers_refresh().';

CREATE OR REPLACE FUNCTION fh_pyramid_dense_centers_refresh() RETURNS int
LANGUAGE plpgsql AS $$
DECLARE
    r   numeric;
    dlat numeric;
    n   int;
BEGIN
    SELECT dense_radius_km INTO r FROM pyramid_territory_policy LIMIT 1;
    dlat := r / 111.0;
    CREATE TEMP TABLE _t ON COMMIT DROP AS
        SELECT mc.cbsa_code, t.geoid, t.lat, t.lon, t.population
          FROM pyramid_tracts t JOIN pyramid_metro_counties mc ON mc.fips = t.county_fips;
    CREATE INDEX ON _t (cbsa_code, lat);
    ANALYZE _t;
    DELETE FROM pyramid_metro_dense_centers;
    INSERT INTO pyramid_metro_dense_centers (cbsa_code, geoid, lat, lon, people_near, radius_km)
    SELECT DISTINCT ON (a.cbsa_code) a.cbsa_code, a.geoid, a.lat, a.lon, s.people, r
      FROM _t a
      CROSS JOIN LATERAL (
            SELECT sum(b.population) AS people FROM _t b
             WHERE b.cbsa_code = a.cbsa_code
               AND b.lat BETWEEN a.lat - dlat AND a.lat + dlat
               AND abs(b.lon - a.lon) <= dlat / cos(radians(a.lat))
               AND fh_km(a.lat, a.lon, b.lat, b.lon) <= r) s
     ORDER BY a.cbsa_code, s.people DESC NULLS LAST, a.population DESC;
    GET DIAGNOSTICS n = ROW_COUNT;
    RETURN n;
END $$;

SELECT fh_pyramid_dense_centers_refresh();

CREATE OR REPLACE VIEW pyramid_metro_pop_centers AS
SELECT mc.cbsa_code,
       COALESCE(d.lat, sum(t.lat * t.population) / NULLIF(sum(t.population), 0)) AS lat,
       COALESCE(d.lon, sum(t.lon * t.population) / NULLIF(sum(t.population), 0)) AS lon,
       sum(t.population) AS population
  FROM pyramid_tracts t
  JOIN pyramid_metro_counties mc ON mc.fips = t.county_fips
  LEFT JOIN pyramid_metro_dense_centers d ON d.cbsa_code = mc.cbsa_code
 GROUP BY mc.cbsa_code, d.lat, d.lon;
COMMENT ON VIEW pyramid_metro_pop_centers IS
    'mig 1297: each metro/micro area''s centre = its densest spot (pyramid_metro_dense_centers), mean of tracts if missing; population = whole area.';

UPDATE pyramid_conference_rules
   SET body = 'Each conference is measured from where most of its metro area''s people are — the spot with the most people within 10 km (in Philly, Broad & Allegheny) — not a landmark or the average of the whole area. A conference that also holds another metro area of 750 000+ people (by drive) is measured from both, weighted by their people — never from an empty midpoint, and never by adding a city by choice.'
 WHERE rank = 4;

UPDATE message_templates SET body = 'Two lines in the same colours: the one nearer New York is the shortest drive with traffic (New York ×1.25), the other the shortest drive without — each from the spot where most of the metro area''s people are. Shaded between: neutral zone.', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_lines';
