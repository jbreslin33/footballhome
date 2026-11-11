-- 1255 (2026-11-11) — #apsl-pyramid proposal map: city centres, a traffic
-- factor, two borders and the neutral zone between them.
--
-- Owner 2026-11-11, on Bulldogs SC (Old Bridge NJ) landing in Delaware River
-- because Feelsgood (Manalapan) is the nearest Delaware River ground:
-- "feels good should not pull them … center of philly and center of ny" /
-- "with a nudge to a higher line near ny city due to the traffic" / "use
-- city centers lol" / "make 2 lines though for the border the dist and dist
-- plus travel factor. so show a neutral zone".
--
-- Region centres (view pyramid_region_centers):
--   live conference  its main city's centre — pyramid_main_cities.center_*
--                    (City Hall or the downtown landmark; Times Square for
--                    New York) — with traffic_factor (New York 1.25: a km
--                    toward New York counts 1.25 km; everyone else 1.0)
--   proposed         each anchor city's downtown — pyramid_proposed_anchors
--                    .center_* (county middle if unset) — with the
--                    proposal's traffic_factor (1.0)
-- Every county gets two regions: plain_* = nearest centre by distance;
-- conference_id / proposed_id = nearest by distance × traffic factor (the
-- coloured border).  Counties where they differ = the neutral zone.
-- Borders: kind 'travel' (coloured, two-tone) and kind 'plain' (straight
-- distance, drawn only where it runs apart from the travel border).
-- The outlier lines (mig 1238) use the same rule: a feeder team belongs to
-- the conference whose centre is nearest × traffic factor.
-- Rerun scripts/pyramid-sea-borders.py after this (it reads the new fill).

ALTER TABLE pyramid_main_cities ADD COLUMN IF NOT EXISTS center_lat numeric(10,7);
ALTER TABLE pyramid_main_cities ADD COLUMN IF NOT EXISTS center_lon numeric(10,7);
ALTER TABLE pyramid_main_cities ADD COLUMN IF NOT EXISTS traffic_factor numeric NOT NULL DEFAULT 1.0;
COMMENT ON COLUMN pyramid_main_cities.traffic_factor IS
    'mig 1255: distance toward this city counts × this (traffic) when drawing #apsl-pyramid borders. New York 1.25.';
ALTER TABLE pyramid_proposed_conferences ADD COLUMN IF NOT EXISTS traffic_factor numeric NOT NULL DEFAULT 1.0;
ALTER TABLE pyramid_proposed_anchors ADD COLUMN IF NOT EXISTS center_lat numeric(10,7);
ALTER TABLE pyramid_proposed_anchors ADD COLUMN IF NOT EXISTS center_lon numeric(10,7);
ALTER TABLE pyramid_proposal_counties ADD COLUMN IF NOT EXISTS plain_conference_id integer REFERENCES pyramid_competitions(id) ON DELETE CASCADE;
ALTER TABLE pyramid_proposal_counties ADD COLUMN IF NOT EXISTS plain_proposed_id integer REFERENCES pyramid_proposed_conferences(id) ON DELETE CASCADE;
ALTER TABLE pyramid_proposal_borders ADD COLUMN IF NOT EXISTS kind text NOT NULL DEFAULT 'travel';
DO $do$ BEGIN
    ALTER TABLE pyramid_proposal_borders ADD CONSTRAINT pyramid_proposal_borders_kind_check CHECK (kind IN ('travel', 'plain'));
EXCEPTION WHEN duplicate_object THEN NULL; END $do$;

UPDATE pyramid_main_cities m SET center_lat = v.lat, center_lon = v.lon, traffic_factor = v.f
  FROM (VALUES
    ('Hartford', 41.7640, -72.6822, 1.0),        -- State Capitol
    ('Philadelphia', 39.9526, -75.1652, 1.0),    -- City Hall
    ('Boston', 42.3603, -71.0580, 1.0),          -- City Hall
    ('New York', 40.7580, -73.9855, 1.25),       -- Times Square; traffic
    ('Washington', 38.8899, -77.0091, 1.0),      -- the Capitol
    ('Detroit', 42.3314, -83.0458, 1.0),         -- Campus Martius
    ('Atlanta', 33.7537, -84.3901, 1.0),         -- Five Points
    ('Dallas', 32.7767, -96.7970, 1.0)           -- City Hall
  ) AS v(name, lat, lon, f)
 WHERE m.name = v.name;

UPDATE pyramid_proposed_anchors a SET center_lat = v.lat, center_lon = v.lon
  FROM (VALUES
    ('pacific', '06037', 34.0537, -118.2428),
    ('pacific', '06059', 33.7455, -117.8677),
    ('lakeshore', '17031', 41.8781, -87.6298),
    ('golden_gate', '06075', 37.7793, -122.4193),
    ('golden_gate', '06001', 37.8044, -122.2712),
    ('golden_gate', '06085', 37.3382, -121.8863),
    ('gulf_coast', '48201', 29.7604, -95.3698),
    ('sunshine', '12057', 27.9506, -82.4572),
    ('sunshine', '12095', 28.5384, -81.3789),
    ('biscayne', '12086', 25.7617, -80.1918),
    ('biscayne', '12011', 26.1224, -80.1373),
    ('steel', '42003', 40.4406, -79.9959),
    ('steel', '39035', 41.4993, -81.6944),
    ('alamo', '48453', 30.2672, -97.7431),
    ('alamo', '48029', 29.4241, -98.4936),
    ('buckeye', '39049', 39.9612, -82.9988),
    ('buckeye', '39113', 39.7589, -84.1916),
    ('buckeye', '39061', 39.1031, -84.512),
    ('cascadia', '53033', 47.6062, -122.3321),
    ('cascadia', '41051', 45.5152, -122.6784),
    ('piedmont', '37119', 35.2271, -80.8431),
    ('piedmont', '37081', 36.0726, -79.792),
    ('piedmont', '37183', 35.7796, -78.6382),
    ('sonoran', '04013', 33.4484, -112.074),
    ('front_range', '08031', 39.7392, -104.9903),
    ('north_star', '27053', 44.9778, -93.265),
    ('gateway', '29510', 38.627, -90.1994),
    ('gateway', '29189', 38.6426, -90.3237),
    ('gateway', '29095', 39.0997, -94.5786),
    ('tidewater', '51760', 37.5407, -77.436),
    ('tidewater', '51810', 36.8529, -75.978),
    ('music_city', '47037', 36.1627, -86.7816),
    ('wasatch', '49035', 40.7608, -111.891),
    ('erie_canal', '36029', 42.8864, -78.8784),
    ('erie_canal', '36055', 43.1566, -77.6088),
    ('bayou', '22071', 29.9511, -90.0715),
    ('bayou', '22033', 30.4515, -91.1871),
    ('red_dirt', '40109', 35.4676, -97.5164),
    ('red_dirt', '40143', 36.154, -95.9928),
    ('mojave', '32003', 36.1699, -115.1398)
  ) AS v(code, fips, lat, lon)
  JOIN pyramid_proposed_conferences p ON p.code = v.code
 WHERE a.proposed_id = p.id AND a.fips = v.fips;

CREATE OR REPLACE VIEW pyramid_region_centers AS
SELECT m.competition_id AS conference_id, NULL::int AS proposed_id,
       m.center_lat AS lat, m.center_lon AS lon, m.traffic_factor AS factor
  FROM pyramid_main_cities m
  JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
 WHERE m.center_lat IS NOT NULL
UNION ALL
SELECT NULL, a.proposed_id, COALESCE(a.center_lat, k.lat), COALESCE(a.center_lon, k.lon), p.traffic_factor
  FROM pyramid_proposed_anchors a
  JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id AND NOT p.developing
  JOIN pyramid_counties k ON k.fips = a.fips;
COMMENT ON VIEW pyramid_region_centers IS
    'mig 1255: the points #apsl-pyramid borders are drawn from — each live conference''s main-city centre, each proposed conference''s city centres — with a traffic factor.';

-- Feeder teams → the conference whose centre is nearest × traffic factor
-- (was: nearest APSL ground, mig 1238).
CREATE OR REPLACE VIEW pyramid_team_nearest_conference AS
SELECT t.id AS team_id, t.division_id, n.conference_id, n.km
  FROM pyramid_teams t
  JOIN pyramid_divisions d ON d.id = t.division_id AND d.removed_at IS NULL
  JOIN pyramid_competitions fc ON fc.id = d.competition_id AND fc.kind = 'affiliate'
  JOIN pyramid_venues v ON v.id = t.venue_id AND v.lat IS NOT NULL
  CROSS JOIN LATERAL (
        SELECT c.conference_id, fh_km(v.lat, v.lon, c.lat, c.lon) AS km
          FROM pyramid_region_centers c
         WHERE c.conference_id IS NOT NULL
         ORDER BY fh_km(v.lat, v.lon, c.lat, c.lon) * c.factor
         LIMIT 1) n
 WHERE t.removed_at IS NULL;

CREATE OR REPLACE FUNCTION fh_pyramid_proposal_refresh() RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    bar bigint;
    vkind text;
BEGIN
    -- The bar: the smallest live conference's ground (mig 852 rule).
    SELECT min(pop) INTO bar FROM (
        SELECT sum(k.population) AS pop
          FROM pyramid_county_conference cc JOIN pyramid_counties k ON k.fips = cc.fips
         WHERE cc.conference_id IS NOT NULL
         GROUP BY cc.conference_id) s;

    -- Each proposal's core: people within 100 km (policy reach) of one of its city centres.
    UPDATE pyramid_proposed_conferences p
       SET core_population = s.pop,
           tier = CASE WHEN s.pop >= bar THEN 'ready' WHEN s.pop >= bar * 0.75 THEN 'borderline' ELSE 'developing' END,
           developing = s.pop < bar * 0.75
      FROM (SELECT p2.id, sum(k.population) AS pop
              FROM pyramid_proposed_conferences p2
              JOIN pyramid_counties k ON EXISTS (
                     SELECT 1 FROM pyramid_proposed_anchors a JOIN pyramid_counties ak ON ak.fips = a.fips
                      WHERE a.proposed_id = p2.id
                        AND fh_km(k.lat, k.lon, COALESCE(a.center_lat, ak.lat), COALESCE(a.center_lon, ak.lon))
                            <= (SELECT reach_km FROM pyramid_territory_policy LIMIT 1))
             GROUP BY p2.id) s
     WHERE s.id = p.id;

    -- Every lower-48 county → its region, two ways (mig 1255): by straight
    -- distance to the region centres (plain_*), and by distance × the
    -- centre's traffic factor (conference_id / proposed_id — the border the
    -- map draws in colour).  Where they differ is the neutral zone.
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    SELECT k.fips, t.conference_id, t.proposed_id, t.km, pl.conference_id, pl.proposed_id
      FROM pyramid_counties k
      CROSS JOIN LATERAL (
            SELECT c.conference_id, c.proposed_id, fh_km(k.lat, k.lon, c.lat, c.lon) AS km
              FROM pyramid_region_centers c
             ORDER BY fh_km(k.lat, k.lon, c.lat, c.lon) * c.factor
             LIMIT 1) t
      CROSS JOIN LATERAL (
            SELECT c.conference_id, c.proposed_id
              FROM pyramid_region_centers c
             ORDER BY fh_km(k.lat, k.lon, c.lat, c.lon)
             LIMIT 1) pl
     WHERE k.state NOT IN ('AK', 'HI', 'PR');

    -- Border lines: county ring edges shared by two counties of different
    -- regions, drawn once (from the side whose region key sorts first),
    -- consecutive edges of a ring joined into one line.  Twice: 'travel'
    -- (the coloured border) and 'plain' (straight distance) — plain only
    -- where it runs apart from the travel border (both counties on the same
    -- side of it), so the two lines frame the neutral zone.
    DELETE FROM pyramid_proposal_borders;
    FOREACH vkind IN ARRAY ARRAY['travel', 'plain'] LOOP
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind)
    WITH reg AS (
        SELECT fips,
               CASE WHEN vkind = 'travel' THEN COALESCE('c' || conference_id, 'p' || proposed_id)
                    ELSE COALESCE('c' || plain_conference_id, 'p' || plain_proposed_id) END AS r,
               COALESCE('c' || conference_id, 'p' || proposed_id) AS rt
          FROM pyramid_proposal_counties
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
    ), orient AS (      -- ring's signed area (x = lon, y = lat): > 0 = counter-clockwise = inside on the left
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
END $$;



SELECT fh_pyramid_proposal_refresh();

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — proposal: how the two borders read', 'apsl_pyramid', 'proposal_lines', NULL,
       'Coloured line: halfway between conference city centres with traffic (New York ×1.25). Dashed white: straight distance. Shaded between: neutral zone.', 309, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'proposal_lines');
