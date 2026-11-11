-- 1285 (2026-11-11) — #apsl-pyramid: a conference with two (or more) big
-- metro areas is measured from all of them, weighted by their people.
--
-- Owner 2026-11-11: "if there are 2 cities in a conference do we need to
-- take a center of mass of both and find a point?" → not one midpoint (it
-- lands where nobody lives) but the population-weighted average drive to
-- each metro's centre of population → "good, continue".
--
-- * pyramid_region_points: where each conference is measured from — its
--   base metro's centre of population (weight = its people) plus every other
--   metro area of policy region_metro_min_population (750 000) or more whose
--   centre lies in that conference by drive (decided by a first pass from
--   the base points only), weight = its people.  Fixed threshold, so no one
--   can add a "second city" to move a border.  Baltimore joins
--   Mid-Atlantic, New Haven / Bridgeport Constitution, Providence /
--   Worcester Mayflower, Orlando Sunshine, Austin Alamo, and so on.
-- * Score of a conference for a county / club / grid point =
--   Σ weight × drive minutes × traffic factor ÷ Σ weight (traffic factor
--   per metro: New York 1.25, others plain); the plain line drops the
--   factor; the Current plan's 2 h reach = within 2 h of any of its points.
-- * pyramid_conference_rules rule 4 rewritten.
-- Pipeline: refresh → pyramid-county-drive.py (fetches drives to the new
-- points) → refresh → pyramid-fine-borders.py → pyramid-sea-borders.py →
-- pyramid-drive-times.py.

ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS region_metro_min_population int NOT NULL DEFAULT 750000;
COMMENT ON COLUMN pyramid_territory_policy.region_metro_min_population IS
    'mig 1285: another metro area this big inside a conference (by drive) becomes one of its measuring points, weighted by people.';

CREATE TABLE IF NOT EXISTS pyramid_region_points (
    plan          text NOT NULL,
    conference_id int,
    proposed_id   int,
    cbsa_code     text,
    label         text,
    lat           numeric(10,7) NOT NULL,
    lon           numeric(10,7) NOT NULL,
    factor        numeric NOT NULL DEFAULT 1,
    weight        numeric NOT NULL,
    is_base       boolean NOT NULL
);
COMMENT ON TABLE pyramid_region_points IS
    'mig 1285: each conference''s measuring points — base metro centre of population + other metros ≥ policy size inside it — with people as weights; refreshed by fh_pyramid_proposal_refresh().';

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
      LEFT JOIN pyramid_metro_pop_centers pc ON round(pc.lat::numeric, 5) = round(c.lat::numeric, 5) AND round(pc.lon::numeric, 5) = round(c.lon::numeric, 5)
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
    'mig 1285: measuring points per conference (base metro + other metros ≥ policy size, people-weighted), both plans by weighted drive × traffic, region stats, border lines. Pipeline: refresh → pyramid-county-drive.py → refresh → pyramid-fine-borders.py → pyramid-sea-borders.py → pyramid-drive-times.py.';

-- Clubs: the same weighted drive over the live conferences' points.
CREATE OR REPLACE VIEW pyramid_team_nearest_conference AS
SELECT t.id AS team_id, t.division_id, n.conference_id, n.km, n.minutes
  FROM pyramid_teams t
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions fc ON fc.id = d.competition_id AND fc.kind = 'affiliate'
  JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
  CROSS JOIN LATERAL (
        SELECT p.conference_id, min(fh_km(v.lat, v.lon, p.lat, p.lon)) AS km,
               sum(p.weight * COALESCE(dt.minutes, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1)) / sum(p.weight) AS minutes,
               sum(p.weight * COALESCE(dt.minutes, fh_km(v.lat, v.lon, p.lat, p.lon) * 1.1) * p.factor) / sum(p.weight) AS score
          FROM pyramid_region_points p
          LEFT JOIN pyramid_venue_drive_times dt
                 ON dt.venue_id = v.id AND dt.from_lat = round(v.lat::numeric, 4) AND dt.from_lon = round(v.lon::numeric, 4)
                AND dt.to_lat = round(p.lat::numeric, 4) AND dt.to_lon = round(p.lon::numeric, 4)
         WHERE p.plan = 'current'
         GROUP BY p.conference_id
         ORDER BY 4
         LIMIT 1) n
 WHERE t.removed_at IS NULL;
COMMENT ON VIEW pyramid_team_nearest_conference IS
    'mig 1285: each located feeder team → the live conference with the lowest people-weighted drive from its ground over that conference''s measuring points × traffic factor.';

UPDATE pyramid_conference_rules SET title = 'Measured from where its people are',
       body = 'Each conference is measured from its metro area''s centre of population, not a landmark. A conference that also holds another metro area of 750 000+ people (by drive) is measured from both, weighted by their people — never from an empty midpoint, and never by adding a city by choice.'
 WHERE rank = 4;
