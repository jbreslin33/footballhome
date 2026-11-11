-- 1278 (2026-11-11) — #apsl-pyramid map: counties go to a conference by
-- DRIVE time from its city, not straight distance.
--
-- Owner 2026-11-11, on Jersey Shore Boca showing as Metropolitan (Ocean
-- County is in the Census New York metro, so mig 1265's metro rule handed
-- it over though Philly is 1 h 24 away and Times Square 1 h 47): "travel
-- time and travel time+traffic i should say because distance may go across
-- water lol right?".
--
-- * pyramid_county_drive_times: road minutes/km from a county's point to a
--   conference city (OSRM, no traffic) for each county's nearest few cities
--   — filled by scripts/pyramid-county-drive.py, keyed by both points so a
--   moved city or county point refetches.
-- * pyramid_county_points: where a county is measured from — the city
--   point of an anchor / main city in it, else its centre.
-- * The refresh: travel+traffic = drive minutes × the city's traffic factor
--   (New York 1.25) decides the coloured border; plain drive minutes the
--   second line (neutral zone between).  A pair not fetched yet is
--   estimated at 1.1 min per straight km.  Current plan: cities within
--   policy proposal_reach_min (120 min, no traffic) of the county; a metro
--   county out of every city's reach still goes to its home conference
--   (the metro rule only fills, never overrides).  Proposed: nearest city by
--   travel+traffic, every county, then the balancer's pins.
-- Pipeline: scripts/pyramid-county-drive.py → pyramid-balance.py →
-- pyramid-sea-borders.py → pyramid-drive-times.py.

ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS proposal_reach_min numeric NOT NULL DEFAULT 120;
COMMENT ON COLUMN pyramid_territory_policy.proposal_reach_min IS
    'mig 1278: Current plan — a county belongs to today''s conference whose city is within this many drive minutes (no traffic).';

CREATE TABLE IF NOT EXISTS pyramid_county_drive_times (
    fips       char(5) NOT NULL REFERENCES pyramid_counties(fips),
    from_lat   numeric(9,4) NOT NULL,
    from_lon   numeric(9,4) NOT NULL,
    to_lat     numeric(9,4) NOT NULL,
    to_lon     numeric(9,4) NOT NULL,
    minutes    numeric NOT NULL,
    km         numeric NOT NULL,
    fetched_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (fips, to_lat, to_lon)
);
COMMENT ON TABLE pyramid_county_drive_times IS
    'mig 1278: road drive (OSRM, no traffic) from a county''s point to a conference city — scripts/pyramid-county-drive.py.';

CREATE OR REPLACE VIEW pyramid_county_points AS
SELECT k.fips,
       round(COALESCE(p.lat, k.lat), 4) AS lat, round(COALESCE(p.lon, k.lon), 4) AS lon
  FROM pyramid_counties k
  LEFT JOIN LATERAL (
        SELECT a.center_lat AS lat, a.center_lon AS lon FROM pyramid_proposed_anchors a
         WHERE a.fips = k.fips AND a.center_lat IS NOT NULL
        UNION ALL
        SELECT m.center_lat, m.center_lon FROM pyramid_main_cities m
         WHERE m.core_fips[1] = k.fips AND m.center_lat IS NOT NULL
        LIMIT 1) p ON true
 WHERE k.state NOT IN ('AK', 'HI', 'PR');
COMMENT ON VIEW pyramid_county_points IS
    'mig 1278: the point a county''s drive times are measured from — a named city in it (anchor / main city), else its centre.';

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
BEGIN
    SELECT b.bar INTO bar FROM pyramid_proposal_bar b;
    SELECT span_min_population, proposal_reach_min INTO minpop, reach FROM pyramid_territory_policy LIMIT 1;

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

    -- County → region by drive time (mig 1278).
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    WITH cand AS (
        SELECT c.plan, cp.fips, c.conference_id, c.proposed_id, c.factor,
               fh_km(cp.lat, cp.lon, c.lat, c.lon) AS km,
               COALESCE(dt.minutes, fh_km(cp.lat, cp.lon, c.lat, c.lon) * 1.1) AS mins
          FROM pyramid_county_points cp
          JOIN pyramid_region_centers c ON true
          LEFT JOIN pyramid_county_drive_times dt
                 ON dt.fips = cp.fips AND dt.from_lat = cp.lat AND dt.from_lon = cp.lon
                AND dt.to_lat = round(c.lat::numeric, 4) AND dt.to_lon = round(c.lon::numeric, 4)
    ), ok AS (               -- current plan: only cities within reach
        SELECT * FROM cand WHERE plan = 'proposed' OR mins <= reach
    ), t AS (                -- travel + traffic: the coloured border
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id, km
          FROM ok ORDER BY plan, fips, mins * factor
    ), s AS (                -- plain travel time: the second line
        SELECT DISTINCT ON (plan, fips) plan, fips, conference_id, proposed_id
          FROM ok ORDER BY plan, fips, mins
    ), filled AS (
        SELECT t.plan, t.fips, t.conference_id, t.proposed_id, t.km, s.conference_id AS pc, s.proposed_id AS pp
          FROM t JOIN s USING (plan, fips)
        UNION ALL            -- a metro county out of everyone's reach: its home conference
        SELECT h.plan, h.fips, h.conference_id, h.proposed_id, NULL, h.conference_id, h.proposed_id
          FROM pyramid_region_homes h
          JOIN pyramid_counties k ON k.fips = h.fips AND k.state NOT IN ('AK', 'HI', 'PR')
         WHERE NOT EXISTS (SELECT 1 FROM t WHERE t.plan = h.plan AND t.fips = h.fips)
    )
    SELECT plan, fips, conference_id, proposed_id, km, pc, pp FROM filled;

    -- The balancer's moves (proposed plan only).
    UPDATE pyramid_proposal_counties pc
       SET conference_id = pin.conference_id, proposed_id = pin.proposed_id,
           plain_conference_id = pin.conference_id, plain_proposed_id = pin.proposed_id
      FROM pyramid_proposal_county_pins pin
     WHERE pc.plan = 'proposed' AND pin.fips = pc.fips;

    -- The pill's numbers, every region of both plans (keys are distinct).
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
    'mig 1278: both plans by drive time (pyramid_county_drive_times; × traffic factor for the coloured border), region stats, border lines. Pipeline: scripts/pyramid-county-drive.py → pyramid-balance.py → pyramid-sea-borders.py → pyramid-drive-times.py.';

UPDATE message_templates SET body = 'Today''s 8 APSL conferences: each county goes to the city it is the shortest drive from (× traffic — New York 1.25) within 2 hours; a metro county beyond that stays with its city; the rest is open.', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'plan_current_intro';
UPDATE message_templates SET body = 'Two lines in the same colours: the one nearer New York is the shortest drive with traffic (New York ×1.25), the other the shortest drive without. Shaded between: neutral zone.', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_lines';
