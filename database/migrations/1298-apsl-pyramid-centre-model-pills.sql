-- 1298 (2026-11-12) — #apsl-pyramid: pills to pick what a conference is
-- measured from — City centre · Metro average · Most people — each a whole
-- map of its own, with the other two models' borders as faint ghost lines.
--
-- Owner 2026-11-12: "lets actually have pills to select diff models. city(s)
-- center, metro(s) center, pop center of mass" → "yes go ahead, ghost lines on".
-- Conference assignments (clubs, feeders, outlier lines) always follow the
-- OFFICIAL model (Most people, mig 1297); the pills are a map comparison.
--
-- * pyramid_centre_models: one row a model (code, pill label, what it means,
--   ghost line dash, official flag).  A new model = a row + its case in
--   pyramid_metro_pop_centers / pyramid_region_centers.
-- * pyramid_territory_policy.centre_model: the model the pipeline is
--   computing right now (scripts/pyramid-pipeline.sh sets it, runs the
--   pipeline, snapshots, and leaves it on the official one).
-- * pyramid_metro_areas.city_lat/lon: each metro's main city point
--   (scripts/pyramid-load-metro-cities.py, Census Gazetteer places) — the
--   City centre model's point for a conference's second big metro.  Live
--   conferences keep their landmark (pyramid_main_cities: City Hall, Times
--   Square…), proposals their downtown (pyramid_proposed_anchors.center_*).
-- * pyramid_metro_pop_centers / pyramid_region_centers: follow the model
--   (city → city point, mean → mig 1283 average of everyone, dense → mig
--   1297 densest spot); pyramid_region_centers gains cbsa_code so the
--   refresh matches a base point to its metro by code, not by coordinates.
-- * pyramid_model_*: each model's finished map (counties, stats, borders
--   incl. fine + sea lines, measuring points, centres), copied by
--   fh_pyramid_model_snapshot() at the end of a pipeline run.
--   GET /api/pyramid/proposal?model=<code> reads them.

CREATE TABLE IF NOT EXISTS pyramid_centre_models (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    blurb       text NOT NULL,
    ghost_dash  text NOT NULL,
    sort_order  int NOT NULL,
    is_official boolean NOT NULL DEFAULT false,
    computed_at timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS pyramid_centre_models_one_official ON pyramid_centre_models (is_official) WHERE is_official;
COMMENT ON TABLE pyramid_centre_models IS
    'mig 1298: what a conference is measured from — one pill each on the #apsl-pyramid map; is_official = the one assignments use.';
INSERT INTO pyramid_centre_models (code, label, blurb, ghost_dash, sort_order, is_official) VALUES
    ('city',  'City centre',   'From the city itself — City Hall, Times Square, a downtown.', '2 6', 1, false),
    ('mean',  'Metro average', 'From the average position of everyone in the metro area.', '10 6', 2, false),
    ('dense', 'Most people',   'From the spot with the most people within 10 km (in Philly, Broad & Allegheny). Official.', '1 0', 3, true)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS centre_model text NOT NULL DEFAULT 'dense' REFERENCES pyramid_centre_models(code);
COMMENT ON COLUMN pyramid_territory_policy.centre_model IS
    'mig 1298: the model the pipeline computes now; scripts/pyramid-pipeline.sh always leaves it on the official one.';

ALTER TABLE pyramid_metro_areas ADD COLUMN IF NOT EXISTS city_lat numeric(10,7), ADD COLUMN IF NOT EXISTS city_lon numeric(10,7);
COMMENT ON COLUMN pyramid_metro_areas.city_lat IS
    'mig 1298: the metro''s first named city (Census Gazetteer place internal point) — scripts/pyramid-load-metro-cities.py.';

CREATE OR REPLACE VIEW pyramid_metro_pop_centers AS
WITH mean AS (
    SELECT mc.cbsa_code,
           sum(t.lat * t.population) / NULLIF(sum(t.population), 0) AS lat,
           sum(t.lon * t.population) / NULLIF(sum(t.population), 0) AS lon,
           sum(t.population) AS population
      FROM pyramid_tracts t
      JOIN pyramid_metro_counties mc ON mc.fips = t.county_fips
     GROUP BY mc.cbsa_code
), pol AS (SELECT centre_model FROM pyramid_territory_policy LIMIT 1)
SELECT m.cbsa_code,
       CASE pol.centre_model WHEN 'city' THEN COALESCE(a.city_lat, d.lat, m.lat)
                             WHEN 'mean' THEN m.lat ELSE COALESCE(d.lat, m.lat) END AS lat,
       CASE pol.centre_model WHEN 'city' THEN COALESCE(a.city_lon, d.lon, m.lon)
                             WHEN 'mean' THEN m.lon ELSE COALESCE(d.lon, m.lon) END AS lon,
       m.population
  FROM mean m
  CROSS JOIN pol
  JOIN pyramid_metro_areas a ON a.cbsa_code = m.cbsa_code
  LEFT JOIN pyramid_metro_dense_centers d ON d.cbsa_code = m.cbsa_code;
COMMENT ON VIEW pyramid_metro_pop_centers IS
    'mig 1298: each metro/micro area''s measuring point for the model being computed (policy centre_model): city point, average of everyone, or densest spot; population = whole area.';

CREATE OR REPLACE VIEW pyramid_region_centers AS
SELECT m.competition_id AS conference_id, NULL::int AS proposed_id,
       (CASE WHEN pol.centre_model = 'city' THEN m.center_lat ELSE COALESCE(pc.lat, m.center_lat) END)::numeric(10,7) AS lat,
       (CASE WHEN pol.centre_model = 'city' THEN m.center_lon ELSE COALESCE(pc.lon, m.center_lon) END)::numeric(10,7) AS lon,
       m.traffic_factor AS factor, 'current'::text AS plan, ma.cbsa_code
  FROM pyramid_main_cities m
  CROSS JOIN (SELECT centre_model FROM pyramid_territory_policy LIMIT 1) pol
  JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
  LEFT JOIN pyramid_metro_counties mc ON mc.fips = m.core_fips[1]
  LEFT JOIN pyramid_metro_areas ma ON ma.cbsa_code = mc.cbsa_code AND ma.kind = 'metro'
  LEFT JOIN pyramid_metro_pop_centers pc ON pc.cbsa_code = ma.cbsa_code
 WHERE m.center_lat IS NOT NULL
UNION ALL
SELECT NULL, a.proposed_id,
       (CASE WHEN pol.centre_model = 'city' THEN COALESCE(a.center_lat, k.lat) ELSE COALESCE(pc.lat, a.center_lat, k.lat) END)::numeric(10,7),
       (CASE WHEN pol.centre_model = 'city' THEN COALESCE(a.center_lon, k.lon) ELSE COALESCE(pc.lon, a.center_lon, k.lon) END)::numeric(10,7),
       p.traffic_factor, 'proposed', ma.cbsa_code
  FROM pyramid_proposed_anchors a
  CROSS JOIN (SELECT centre_model FROM pyramid_territory_policy LIMIT 1) pol
  JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id
  JOIN pyramid_counties k ON k.fips = a.fips
  LEFT JOIN pyramid_metro_counties mc ON mc.fips = a.fips
  LEFT JOIN pyramid_metro_areas ma ON ma.cbsa_code = mc.cbsa_code AND ma.kind = 'metro'
  LEFT JOIN pyramid_metro_pop_centers pc ON pc.cbsa_code = ma.cbsa_code
 WHERE a.is_base;
COMMENT ON VIEW pyramid_region_centers IS
    'mig 1298: where each conference is measured from under the model being computed — city: its landmark/downtown; mean/dense: its metro''s point (pyramid_metro_pop_centers); cbsa_code = that metro.';

CREATE OR REPLACE FUNCTION public.fh_pyramid_proposal_refresh()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    bar bigint;
    vkind text;
    vplan text;
    minpop int;
    reach numeric;
    metromin int;
BEGIN
    SELECT b.bar INTO bar FROM pyramid_proposal_bar b;
    SELECT span_min_population, proposal_reach_min, region_metro_min_population INTO minpop, reach, metromin FROM pyramid_territory_policy LIMIT 1;

    UPDATE pyramid_proposed_conferences p
       SET core_population = s.pop,
           tier = CASE WHEN s.pop >= bar THEN 'ready' WHEN s.pop >= bar * 0.75 THEN 'borderline' ELSE 'developing' END,
           developing = s.pop < bar * 0.75
      FROM (SELECT a.proposed_id AS id, max(mp.population) AS pop
              FROM pyramid_proposed_anchors a
              JOIN pyramid_metro_counties mc ON mc.fips = a.fips
              JOIN pyramid_metro_population mp ON mp.cbsa_code = mc.cbsa_code
             WHERE a.is_base
             GROUP BY a.proposed_id) s
     WHERE s.id = p.id;

    -- Pass 1: base points only — which conference each county falls in.
    DROP TABLE IF EXISTS _pz_base;
    CREATE TEMP TABLE _pz_base AS
    WITH cand AS (
        SELECT c.plan, cp.fips, c.conference_id, c.proposed_id, c.factor,
               COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, c.lat, c.lon) * 1.1) AS mins
          FROM pyramid_county_points cp
          JOIN pyramid_region_centers c ON true
          LEFT JOIN pyramid_county_drive_times dt
                 ON dt.fips = cp.fips AND dt.from_lat = cp.lat AND dt.from_lon = cp.lon
                AND dt.to_lat = round(c.lat::numeric, 4) AND dt.to_lon = round(c.lon::numeric, 4)
    )
    SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id
      FROM cand WHERE plan = 'proposed' OR mins <= reach
     ORDER BY plan, fips, mins * factor;

    -- The measuring points (mig 1285).
    DELETE FROM pyramid_region_points;
    INSERT INTO pyramid_region_points (plan, conference_id, proposed_id, cbsa_code, label, lat, lon, factor, weight, is_base)
    SELECT c.plan, c.conference_id, c.proposed_id, pc.cbsa_code, split_part(a.title, ',', 1),
           c.lat, c.lon, c.factor, COALESCE(pc.population, 100000), true
      FROM pyramid_region_centers c
      LEFT JOIN pyramid_metro_pop_centers pc ON pc.cbsa_code = c.cbsa_code   -- mig 1298: by metro, not by matching coordinates (city points never match)
      LEFT JOIN pyramid_metro_areas a ON a.cbsa_code = pc.cbsa_code;
    INSERT INTO pyramid_region_points (plan, conference_id, proposed_id, cbsa_code, label, lat, lon, factor, weight, is_base)
    SELECT b.plan, b.conference_id, b.proposed_id, pc.cbsa_code, split_part(a.title, ',', 1),
           pc.lat, pc.lon, 1, pc.population, false
      FROM pyramid_metro_pop_centers pc
      JOIN pyramid_metro_areas a ON a.cbsa_code = pc.cbsa_code AND a.kind = 'metro'
      CROSS JOIN LATERAL (SELECT t.county_fips FROM pyramid_tracts t
                           ORDER BY (t.lat - pc.lat) ^ 2 + (t.lon - pc.lon) ^ 2 LIMIT 1) home
      JOIN _pz_base b ON b.fips = home.county_fips
     WHERE pc.population >= metromin
       AND NOT EXISTS (SELECT 1 FROM pyramid_region_points x WHERE x.is_base AND x.plan = b.plan AND x.cbsa_code = pc.cbsa_code);

    -- County → region: lowest population-weighted drive over its points.
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    WITH cand AS (
        SELECT p.plan, cp.fips, p.conference_id, p.proposed_id,
               sum(p.weight * COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, p.lat, p.lon) * 1.1) * p.factor) / sum(p.weight) AS tmin,
               sum(p.weight * COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, p.lat, p.lon) * 1.1)) / sum(p.weight) AS pmin,
               min(COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, p.lat, p.lon) * 1.1)) AS nearest,
               min(fh_km(cp.lat, cp.lon, p.lat, p.lon)) AS km
          FROM pyramid_county_points cp
          JOIN pyramid_region_points p ON true
          LEFT JOIN pyramid_county_drive_times dt
                 ON dt.fips = cp.fips AND dt.from_lat = cp.lat AND dt.from_lon = cp.lon
                AND dt.to_lat = round(p.lat::numeric, 4) AND dt.to_lon = round(p.lon::numeric, 4)
         GROUP BY p.plan, cp.fips, p.conference_id, p.proposed_id
    ), ok AS (
        SELECT * FROM cand WHERE plan = 'proposed' OR nearest <= reach
    ), t AS (
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id, km FROM ok ORDER BY plan, fips, tmin
    ), s AS (
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id FROM ok ORDER BY plan, fips, pmin
    ), filled AS (
        SELECT t.plan, t.fips, t.conference_id, t.proposed_id, t.km, s.conference_id AS pc, s.proposed_id AS pp
          FROM t JOIN s USING (plan, fips)
        UNION ALL
        SELECT h.plan, h.fips, h.conference_id, h.proposed_id, NULL, h.conference_id, h.proposed_id
          FROM pyramid_region_homes h
          JOIN pyramid_counties k ON k.fips = h.fips AND k.state NOT IN ('AK', 'HI', 'PR')
         WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.plan = h.plan AND t.fips = h.fips)
    )
    SELECT plan, fips, conference_id, proposed_id, km, pc, pp FROM filled;

    DELETE FROM pyramid_proposal_region_stats;
    INSERT INTO pyramid_proposal_region_stats (region, conference_id, proposed_id, population, counties, area_km2, a_fips, b_fips, span_km)
    WITH rc AS (
        SELECT COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id) AS region, pc.conference_id, pc.proposed_id,
               k.fips, k.lat, k.lon, k.population, k.area_km2,
               row_number() OVER (PARTITION BY pc.plan, pc.conference_id, pc.proposed_id ORDER BY k.population DESC) AS rk
          FROM pyramid_proposal_counties pc JOIN pyramid_counties k ON k.fips = pc.fips
    ), cand AS (
        SELECT * FROM rc WHERE population >= minpop OR rk <= 2
    ), far AS (
        SELECT DISTINCT ON (a.region) a.region, a.fips AS a_fips, b.fips AS b_fips, fh_km(a.lat, a.lon, b.lat, b.lon) AS km
          FROM cand a JOIN cand b ON b.region = a.region AND b.fips > a.fips
         ORDER BY a.region, fh_km(a.lat, a.lon, b.lat, b.lon) DESC
    )
    SELECT rc.region, min(rc.conference_id), min(rc.proposed_id), sum(rc.population), count(*), round(sum(rc.area_km2)),
           min(far.a_fips), min(far.b_fips), round(min(far.km)::numeric, 1)
      FROM rc LEFT JOIN far USING (region)
     GROUP BY rc.region;

    DELETE FROM pyramid_proposal_borders;
    FOREACH vplan IN ARRAY ARRAY['current', 'proposed'] LOOP
    FOREACH vkind IN ARRAY ARRAY['travel', 'plain'] LOOP
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind)
    WITH reg AS (
        SELECT k0.fips,
               CASE WHEN vkind = 'travel' THEN COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x')
                    ELSE COALESCE('c' || pc.plain_conference_id, 'p' || pc.plain_proposed_id, 'x') END AS r,
               COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x') AS rt
          FROM pyramid_counties k0
          LEFT JOIN pyramid_proposal_counties pc ON pc.fips = k0.fips AND pc.plan = vplan
         WHERE k0.state NOT IN ('AK', 'HI', 'PR')
    ), polys AS (
        SELECT k.fips, p.ord AS pord, p.poly
          FROM pyramid_counties k
          JOIN reg USING (fips)
          CROSS JOIN LATERAL jsonb_array_elements(
                CASE k.geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(k.geometry->'coordinates')
                                         WHEN 'MultiPolygon' THEN k.geometry->'coordinates' ELSE '[]'::jsonb END)
                WITH ORDINALITY p(poly, ord)
    ), rings AS (
        SELECT fips, pord * 10000 + r.ord AS ring, r.ring AS pts
          FROM polys CROSS JOIN LATERAL jsonb_array_elements(poly) WITH ORDINALITY r(ring, ord)
    ), pts AS (
        SELECT fips, ring, q.i,
               round((q.pt->>1)::numeric, 4) AS lat, round((q.pt->>0)::numeric, 4) AS lon
          FROM rings CROSS JOIN LATERAL jsonb_array_elements(pts) WITH ORDINALITY q(pt, i)
    ), seg AS (
        SELECT fips, ring, i, lat, lon,
               lead(lat) OVER w AS lat2, lead(lon) OVER w AS lon2
          FROM pts WINDOW w AS (PARTITION BY fips, ring ORDER BY i)
    ), orient AS (
        SELECT fips, ring, sum(lon * lat2 - lon2 * lat) > 0 AS ccw FROM seg WHERE lat2 IS NOT NULL GROUP BY fips, ring
    ), keyed AS (
        SELECT s.*, CASE WHEN (lat, lon) < (lat2, lon2) THEN lat || ',' || lon || '|' || lat2 || ',' || lon2
                         ELSE lat2 || ',' || lon2 || '|' || lat || ',' || lon END AS k
          FROM seg s WHERE lat2 IS NOT NULL AND (lat, lon) <> (lat2, lon2)
    ), owners AS (
        SELECT k, min(fips) AS f1, max(fips) AS f2 FROM keyed GROUP BY k HAVING count(DISTINCT fips) = 2
    ), border AS (
        SELECT ky.fips, ky.ring, ky.i, ky.lat, ky.lon, ky.lat2, ky.lon2, ra.r AS ra, rb.r AS rb
          FROM keyed ky
          JOIN owners o ON o.k = ky.k
          JOIN reg ra ON ra.fips = ky.fips
          JOIN reg rb ON rb.fips = CASE WHEN o.f1 = ky.fips THEN o.f2 ELSE o.f1 END
         WHERE ra.r < rb.r
           AND ra.r <> 'x'                  -- open ground on both sides: no border
           AND (vkind = 'travel' OR ra.rt = rb.rt)
    ), runs AS (
        SELECT b.*, i - row_number() OVER (PARTITION BY fips, ring, rb ORDER BY i) AS grp FROM border b
    )
    SELECT ra, rb,
           jsonb_build_array(jsonb_build_array(min(lat) FILTER (WHERE i = first_i), min(lon) FILTER (WHERE i = first_i)))
             || jsonb_agg(jsonb_build_array(lat2, lon2) ORDER BY i),
           bool_or(o.ccw), vkind
      FROM (SELECT r.*, min(i) OVER (PARTITION BY fips, ring, rb, grp) AS first_i FROM runs r) x
      JOIN orient o USING (fips, ring)
     GROUP BY x.fips, x.ring, rb, ra, grp;
    END LOOP;
    END LOOP;
END $function$;


COMMENT ON FUNCTION fh_pyramid_proposal_refresh() IS
    'mig 1298 (body mig 1285; base point → metro by cbsa_code): measuring points per conference for the model in policy centre_model, both plans by weighted drive × traffic, region stats, border lines. Run the whole pipeline with scripts/pyramid-pipeline.sh.';

-- Each model's finished map.
CREATE TABLE IF NOT EXISTS pyramid_model_counties (
    model text NOT NULL REFERENCES pyramid_centre_models(code), plan text NOT NULL, fips char(5) NOT NULL,
    conference_id int, proposed_id int, km double precision, plain_conference_id int, plain_proposed_id int,
    PRIMARY KEY (model, plan, fips));
CREATE TABLE IF NOT EXISTS pyramid_model_region_stats (
    model text NOT NULL REFERENCES pyramid_centre_models(code), region text NOT NULL,
    conference_id int, proposed_id int, population bigint NOT NULL, counties int NOT NULL,
    a_fips text, b_fips text, span_km numeric, area_km2 numeric, tract_population bigint,
    PRIMARY KEY (model, region));
CREATE TABLE IF NOT EXISTS pyramid_model_borders (
    model text NOT NULL REFERENCES pyramid_centre_models(code), region_a text NOT NULL, region_b text NOT NULL,
    line jsonb NOT NULL, a_left boolean NOT NULL, kind text NOT NULL, sea boolean NOT NULL);
CREATE INDEX IF NOT EXISTS pyramid_model_borders_model ON pyramid_model_borders (model);
CREATE TABLE IF NOT EXISTS pyramid_model_region_points (
    model text NOT NULL REFERENCES pyramid_centre_models(code), plan text NOT NULL, conference_id int, proposed_id int,
    cbsa_code text, label text, lat numeric(10,7) NOT NULL, lon numeric(10,7) NOT NULL,
    factor numeric NOT NULL, weight numeric NOT NULL, is_base boolean NOT NULL);
CREATE TABLE IF NOT EXISTS pyramid_model_region_centers (
    model text NOT NULL REFERENCES pyramid_centre_models(code), plan text NOT NULL, conference_id int, proposed_id int,
    lat numeric(10,7), lon numeric(10,7));
COMMENT ON TABLE pyramid_model_counties IS 'mig 1298: per centre model, the finished map (copied by fh_pyramid_model_snapshot()); also pyramid_model_region_stats / _borders / _region_points / _region_centers.';

CREATE OR REPLACE FUNCTION fh_pyramid_model_snapshot() RETURNS text
LANGUAGE plpgsql AS $$
DECLARE m text;
BEGIN
    SELECT centre_model INTO m FROM pyramid_territory_policy LIMIT 1;
    DELETE FROM pyramid_model_counties WHERE model = m;
    INSERT INTO pyramid_model_counties SELECT m, plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id FROM pyramid_proposal_counties;
    DELETE FROM pyramid_model_region_stats WHERE model = m;
    INSERT INTO pyramid_model_region_stats SELECT m, region, conference_id, proposed_id, population, counties, a_fips, b_fips, span_km, area_km2, tract_population FROM pyramid_proposal_region_stats;
    DELETE FROM pyramid_model_borders WHERE model = m;
    INSERT INTO pyramid_model_borders SELECT m, region_a, region_b, line, COALESCE(a_left, false), kind, false FROM pyramid_proposal_borders;
    INSERT INTO pyramid_model_borders SELECT m, region_a, region_b, line, a_left, kind, true FROM pyramid_proposal_sea_borders;
    DELETE FROM pyramid_model_region_points WHERE model = m;
    INSERT INTO pyramid_model_region_points SELECT m, plan, conference_id, proposed_id, cbsa_code, label, lat, lon, factor, weight, is_base FROM pyramid_region_points;
    DELETE FROM pyramid_model_region_centers WHERE model = m;
    INSERT INTO pyramid_model_region_centers SELECT m, plan, conference_id, proposed_id, lat, lon FROM pyramid_region_centers;
    UPDATE pyramid_centre_models SET computed_at = now() WHERE code = m;
    RETURN m;
END $$;
COMMENT ON FUNCTION fh_pyramid_model_snapshot() IS
    'mig 1298: copy the live pipeline output into pyramid_model_* for the model in policy centre_model; last step of scripts/pyramid-pipeline.sh.';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('feature_ghosts', 'APSL pyramid — menu: other models'' borders', 'Other models'' borders (faint)', 205),
    ('model_heading', 'APSL pyramid — menu: centre model pills heading', 'Measured from', 206),
    ('model_pending', 'APSL pyramid — map: model not computed yet', 'This model''s map is still being worked out — showing the official one.', 207)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

UPDATE pyramid_conference_rules
   SET body = 'Each conference is measured from where most of its metro area''s people are — the spot with the most people within 10 km (in Philly, Broad & Allegheny) — not a landmark or the average of the whole area. A conference that also holds another metro area of 750 000+ people (by drive) is measured from both, weighted by their people — never from an empty midpoint, and never by adding a city by choice. The map''s pills show the same rules from the city centre or the metro average, for comparison; assignments use Most people.'
 WHERE rank = 4;
