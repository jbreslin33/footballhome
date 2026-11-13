-- 1308 (2026-11-13) — #apsl-pyramid map: a second pill row, MEASURE BY —
-- Drive time · Drive, no traffic · Straight line — beside the Measured-from
-- pills (City centre · Metro average · Most people), so all nine maps are a
-- tap apart.  City centre + Drive time is now the official (current) model.
--
-- Owner 2026-11-13: "we want current model (drive time), drive time model,
-- but also center of city(s), center of metro(s), center of pop, we want all
-- these things clickable" → "current would be drive time" → "from center of
-- city" → "that is standard prob but maybe not best".
--
-- * pyramid_measures: one row a Measure-by pill.  The codes are the border
--   kinds already in pyramid_proposal_borders / pyramid_model_borders:
--   travel = drive × the city's traffic factor (NY 1.25), plain = drive
--   minutes alone (was the second, dashed line), straight = km as the crow
--   flies (new).  Assignments (clubs, feeders, outlier lines, county tint)
--   use the official measure of the official centre model.
-- * pyramid_proposal_counties / pyramid_model_counties: straight_* owner.
-- * fh_pyramid_proposal_refresh(): straight owner = lowest people-weighted
--   km over the conference's measuring points (same eligibility as drive);
--   every measure now draws its WHOLE border — before, the plain line was
--   only drawn where it parted from travel, because both were on screen at
--   once; now the map shows one measure at a time.
-- * scripts/pyramid-fine-borders.py traces the straight line too (no OSRM);
--   pyramid-sea-borders.py carries it to the water.
-- * Official model: city (was dense, mig 1297).  Policy centre_model follows.
-- Rerun scripts/pyramid-pipeline.sh after this migration.

CREATE TABLE IF NOT EXISTS pyramid_measures (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    blurb       text NOT NULL,
    sort_order  int NOT NULL,
    is_official boolean NOT NULL DEFAULT false
);
CREATE UNIQUE INDEX IF NOT EXISTS pyramid_measures_one_official ON pyramid_measures (is_official) WHERE is_official;
COMMENT ON TABLE pyramid_measures IS
    'mig 1308: how distance to a conference is measured — one Measure-by pill each on the #apsl-pyramid map; code = border kind; is_official = the one assignments use.';
INSERT INTO pyramid_measures (code, label, blurb, sort_order, is_official) VALUES
    ('travel',   'Drive time',        'Road minutes, with each city''s traffic (New York × 1.25). Official.', 1, true),
    ('plain',    'Drive, no traffic', 'Road minutes as the route planner gives them, no traffic allowance.', 2, false),
    ('straight', 'Straight line',     'Kilometres as the crow flies — ignores roads, bridges and water.', 3, false)
ON CONFLICT (code) DO NOTHING;

-- A border's kind is a measure now (the check allowed travel/plain only).
ALTER TABLE pyramid_proposal_borders     DROP CONSTRAINT IF EXISTS pyramid_proposal_borders_kind_check;
ALTER TABLE pyramid_proposal_sea_borders DROP CONSTRAINT IF EXISTS pyramid_proposal_sea_borders_kind_check;
ALTER TABLE pyramid_proposal_borders     DROP CONSTRAINT IF EXISTS pyramid_proposal_borders_kind_fk;
ALTER TABLE pyramid_proposal_sea_borders DROP CONSTRAINT IF EXISTS pyramid_proposal_sea_borders_kind_fk;
ALTER TABLE pyramid_proposal_borders     ADD CONSTRAINT pyramid_proposal_borders_kind_fk     FOREIGN KEY (kind) REFERENCES pyramid_measures(code);
ALTER TABLE pyramid_proposal_sea_borders ADD CONSTRAINT pyramid_proposal_sea_borders_kind_fk FOREIGN KEY (kind) REFERENCES pyramid_measures(code);

ALTER TABLE pyramid_proposal_counties ADD COLUMN IF NOT EXISTS straight_conference_id int, ADD COLUMN IF NOT EXISTS straight_proposed_id int;
ALTER TABLE pyramid_model_counties    ADD COLUMN IF NOT EXISTS straight_conference_id int, ADD COLUMN IF NOT EXISTS straight_proposed_id int;
COMMENT ON COLUMN pyramid_proposal_counties.straight_conference_id IS
    'mig 1308: the county''s conference by straight-line km (people-weighted over the measuring points), the Straight line pill.';

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
    INSERT INTO pyramid_proposal_counties (plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id, straight_conference_id, straight_proposed_id)
    WITH cand AS (
        SELECT p.plan, cp.fips, p.conference_id, p.proposed_id,
               sum(p.weight * COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, p.lat, p.lon) * 1.1) * p.factor) / sum(p.weight) AS tmin,
               sum(p.weight * COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, p.lat, p.lon) * 1.1)) / sum(p.weight) AS pmin,
               sum(p.weight * fh_km(cp.lat, cp.lon, p.lat, p.lon)) / sum(p.weight) AS skm,   -- mig 1308: straight line, no traffic
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
    ), sl AS (
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id FROM ok ORDER BY plan, fips, skm
    ), filled AS (
        SELECT t.plan, t.fips, t.conference_id, t.proposed_id, t.km, s.conference_id AS pc, s.proposed_id AS pp,
               sl.conference_id AS sc, sl.proposed_id AS sp
          FROM t JOIN s USING (plan, fips) JOIN sl USING (plan, fips)
        UNION ALL
        SELECT h.plan, h.fips, h.conference_id, h.proposed_id, NULL, h.conference_id, h.proposed_id, h.conference_id, h.proposed_id
          FROM pyramid_region_homes h
          JOIN pyramid_counties k ON k.fips = h.fips AND k.state NOT IN ('AK', 'HI', 'PR')
         WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.plan = h.plan AND t.fips = h.fips)
    )
    SELECT plan, fips, conference_id, proposed_id, km, pc, pp, sc, sp FROM filled;

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
    FOREACH vkind IN ARRAY ARRAY['travel', 'plain', 'straight'] LOOP
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind)
    WITH reg AS (
        SELECT k0.fips,
               CASE vkind WHEN 'travel' THEN COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x')
                          WHEN 'plain' THEN COALESCE('c' || pc.plain_conference_id, 'p' || pc.plain_proposed_id, 'x')
                          ELSE COALESCE('c' || pc.straight_conference_id, 'p' || pc.straight_proposed_id, 'x') END AS r
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
           -- mig 1308: every measure draws its WHOLE border (one pill each), not just where it parts from travel
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
    'mig 1308 (body mig 1285/1298): measuring points per conference for the model in policy centre_model; each county''s conference by drive × traffic, drive alone and straight km; region stats; whole border lines per measure. Run the whole pipeline with scripts/pyramid-pipeline.sh.';

CREATE OR REPLACE FUNCTION fh_pyramid_model_snapshot() RETURNS text
LANGUAGE plpgsql AS $$
DECLARE m text;
BEGIN
    SELECT centre_model INTO m FROM pyramid_territory_policy LIMIT 1;
    DELETE FROM pyramid_model_counties WHERE model = m;
    INSERT INTO pyramid_model_counties (model, plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id, straight_conference_id, straight_proposed_id)
    SELECT m, plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id, straight_conference_id, straight_proposed_id FROM pyramid_proposal_counties;
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
    'mig 1308 (mig 1298 + straight owner): copy the live pipeline output into pyramid_model_* for the model in policy centre_model; last step of scripts/pyramid-pipeline.sh.';

-- City centre is the official (current) model now — owner: "current would be
-- drive time … from center of city … that is standard prob but maybe not best".
UPDATE pyramid_centre_models SET is_official = false WHERE is_official AND code <> 'city';
UPDATE pyramid_centre_models SET is_official = true WHERE code = 'city';
UPDATE pyramid_centre_models SET blurb = 'From the city itself — City Hall, Times Square, a downtown. Official — the standard way.' WHERE code = 'city';
UPDATE pyramid_centre_models SET blurb = 'From the spot with the most people within 10 km (in Philly, Broad & Allegheny).' WHERE code = 'dense';
UPDATE pyramid_territory_policy SET centre_model = 'city';
ALTER TABLE pyramid_territory_policy ALTER COLUMN centre_model SET DEFAULT 'city';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('measure_heading', 'APSL pyramid — menu: measure pills heading', 'Measure by', 208)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

UPDATE pyramid_conference_rules
   SET title = 'Measured from its city',
       body = 'Each conference is measured from its city — City Hall, Times Square, a downtown — by drive time with that city''s traffic. A conference that also holds another metro area of 750 000+ people (by drive) is measured from both, weighted by their people — never from an empty midpoint, and never by adding a city by choice. The map''s pills show the same rules from the metro average or the spot with the most people, and by drive without traffic or straight line, for comparison; assignments use City centre + Drive time.'
 WHERE rank = 4;

UPDATE message_templates
   SET body = 'One border at a time, in the two conferences'' colours — pick how it is measured (Measure by) and from where (Measured from). Faint lines: the same measure from the other centres. Shaded: counties this measure gives a different conference than Drive time does (on Drive time: than drive without traffic).'
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_lines';
