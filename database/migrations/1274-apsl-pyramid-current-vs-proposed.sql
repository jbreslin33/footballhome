-- 1274 (2026-11-11) — #apsl-pyramid map: two plans side by side — Current
-- (today's 8 conferences) and Proposed (the whole country re-imagined, the 8
-- included) — and the proposed plan split to ~50 conferences.
--
-- Owner 2026-11-11: "yes" (split the conferences over 8 h toward ~50) /
-- "also we need pill toggle to show proposed and current because it gives
-- you freedom to move borders or delete or re imagine current to fit new".
--
-- * pyramid_proposal_counties.plan: 'current' rows = today's conferences,
--   each its main city's metro area plus the counties nearest it within the
--   two-hour reach (mig 1261; the rest open, as today); 'proposed' rows = the
--   re-imagined map, every county covered (mig 1270/1272).  Region keys stay
--   distinct: 'c<conference>' current, 'p<proposal>' proposed.
-- * Each live conference gets a proposal of its own that re-imagines it
--   (pyramid_proposed_conferences.from_conference_id): same name, colour,
--   city and traffic factor to start, but free to move, shrink, split, merge
--   or go — the proposed plan has no fixed live borders any more.
-- * 13 splits of the 8 h+ conferences (53 in the proposed plan): Dakota
--   (Sioux Falls) and Northwoods (Green Bay) from North Star / Lakeshore;
--   Permian (Midland) and Rio Grande Valley (McAllen) from Alamo; Pine Tree
--   (Portland ME) from Mayflower; Chihuahuan (El Paso) from Rio Grande;
--   Platte (Omaha) and Hawkeye (Des Moines) from Heartland; Jefferson
--   (Medford) from Central Valley / Columbia; San Joaquin (Fresno) from
--   Central Valley; Inland Empire (Riverside) from Pacific; Saguaro (Tucson)
--   from Sonoran; Lowcountry (Charleston SC) from Piedmont.
-- Pipeline: scripts/pyramid-balance.py → pyramid-sea-borders.py → pyramid-drive-times.py.

-- ── Live conferences re-imagined as proposals ───────────────────────────
ALTER TABLE pyramid_proposed_conferences ADD COLUMN IF NOT EXISTS from_conference_id int REFERENCES pyramid_competitions(id);
COMMENT ON COLUMN pyramid_proposed_conferences.from_conference_id IS
    'mig 1274: the live conference this proposal re-imagines (the proposed plan is free to change it).';

INSERT INTO pyramid_proposed_conferences (code, name, note, sort_order, color, traffic_factor, from_conference_id)
SELECT 'live_' || c.id, c.name, 'Today''s ' || COALESCE(c.short_name, c.name) || ', re-imagined.', c.id, c.color, m.traffic_factor, c.id
  FROM pyramid_competitions c
  JOIN pyramid_main_cities m ON m.competition_id = c.id
 WHERE c.kind = 'conference' AND c.is_active
ON CONFLICT (code) DO NOTHING;
INSERT INTO pyramid_proposed_anchors (proposed_id, fips, label, center_lat, center_lon, is_base)
SELECT p.id, m.core_fips[1], m.name, m.center_lat, m.center_lon, true
  FROM pyramid_proposed_conferences p
  JOIN pyramid_main_cities m ON m.competition_id = p.from_conference_id
ON CONFLICT DO NOTHING;

-- ── Splits ──────────────────────────────────────────────────────────────
INSERT INTO pyramid_proposed_conferences (code, name, note, sort_order, color) VALUES
  ('dakota', 'Dakota Conference', 'Sioux Falls and Fargo — the eastern Dakotas.', 400, '#14b8a6'),
  ('northwoods', 'Northwoods Conference', 'Green Bay, the Fox Valley, northern Wisconsin and the Upper Peninsula.', 410, '#22c55e'),
  ('permian', 'Permian Conference', 'Midland–Odessa and Lubbock — West Texas.', 420, '#f59e0b'),
  ('rgv', 'Rio Grande Valley Conference', 'McAllen and Brownsville.', 430, '#14b8a6'),
  ('pine_tree', 'Pine Tree Conference', 'Portland and Bangor — Maine and northern New Hampshire.', 440, '#0ea5e9'),
  ('chihuahuan', 'Chihuahuan Conference', 'El Paso and Las Cruces.', 450, '#f97316'),
  ('platte', 'Platte Conference', 'Omaha and Lincoln.', 460, '#be185d'),
  ('hawkeye', 'Hawkeye Conference', 'Des Moines and Cedar Rapids.', 470, '#eab308'),
  ('jefferson', 'Jefferson Conference', 'Medford and Redding — southern Oregon and far northern California.', 480, '#ef4444'),
  ('san_joaquin', 'San Joaquin Conference', 'Fresno and Bakersfield.', 490, '#f59e0b'),
  ('inland_empire', 'Inland Empire Conference', 'Riverside and San Bernardino — its own 4.7 M metro.', 500, '#ef4444'),
  ('saguaro', 'Saguaro Conference', 'Tucson and southern Arizona.', 510, '#f97316'),
  ('lowcountry', 'Lowcountry Conference', 'Charleston and Columbia, South Carolina.', 520, '#0ea5e9')
ON CONFLICT (code) DO NOTHING;

-- Anchors that leave their old conference for a split.
DELETE FROM pyramid_proposed_anchors a USING pyramid_proposed_conferences p
 WHERE p.id = a.proposed_id AND (p.code, a.fips) IN
       (('heartland', '31055'), ('heartland', '19153'), ('central_valley', '06019'),
        ('sandia', '48141'), ('pacific', '06065'));
UPDATE pyramid_proposed_conferences SET note = 'Albuquerque and Santa Fe.' WHERE code = 'sandia';
UPDATE pyramid_proposed_conferences SET note = 'Kansas City and Topeka.' WHERE code = 'heartland';
UPDATE pyramid_proposed_conferences SET note = 'Sacramento, Stockton and Reno.' WHERE code = 'central_valley';
UPDATE pyramid_proposed_conferences SET note = 'Los Angeles, Orange County and Ventura.' WHERE code = 'pacific';
UPDATE pyramid_proposed_conferences SET note = 'Phoenix and central Arizona.' WHERE code = 'sonoran';

INSERT INTO pyramid_proposed_anchors (proposed_id, fips, label, center_lat, center_lon, is_base)
SELECT p.id, v.fips, v.label, v.lat, v.lon, v.base
  FROM (VALUES
  ('dakota', '46099', 'Sioux Falls', 43.5446, -96.7311, true),
  ('dakota', '38017', 'Fargo', 46.8772, -96.7898, false),
  ('northwoods', '55009', 'Green Bay', 44.5133, -88.0133, true),
  ('permian', '48329', 'Midland', 31.9973, -102.0779, true),
  ('permian', '48303', 'Lubbock', 33.5779, -101.8552, false),
  ('rgv', '48215', 'McAllen', 26.2034, -98.2300, true),
  ('rgv', '48061', 'Brownsville', 25.9017, -97.4975, false),
  ('pine_tree', '23005', 'Portland', 43.6591, -70.2568, true),
  ('pine_tree', '23019', 'Bangor', 44.8016, -68.7712, false),
  ('chihuahuan', '48141', 'El Paso', 31.7619, -106.4850, true),
  ('platte', '31055', 'Omaha', 41.2565, -95.9345, true),
  ('platte', '31109', 'Lincoln', 40.8136, -96.7026, false),
  ('hawkeye', '19153', 'Des Moines', 41.5868, -93.6250, true),
  ('hawkeye', '19113', 'Cedar Rapids', 41.9779, -91.6656, false),
  ('jefferson', '41029', 'Medford', 42.3265, -122.8756, true),
  ('jefferson', '06089', 'Redding', 40.5865, -122.3917, false),
  ('san_joaquin', '06019', 'Fresno', 36.7378, -119.7871, true),
  ('san_joaquin', '06029', 'Bakersfield', 35.3733, -119.0187, false),
  ('inland_empire', '06065', 'Riverside', 33.9806, -117.3755, true),
  ('inland_empire', '06071', 'San Bernardino', 34.1083, -117.2898, false),
  ('saguaro', '04019', 'Tucson', 32.2226, -110.9747, true),
  ('lowcountry', '45019', 'Charleston', 32.7765, -79.9311, true),
  ('lowcountry', '45079', 'Columbia', 34.0007, -81.0348, false)
  ) AS v(code, fips, label, lat, lon, base)
  JOIN pyramid_proposed_conferences p ON p.code = v.code
ON CONFLICT DO NOTHING;

-- ── Plans ───────────────────────────────────────────────────────────────
ALTER TABLE pyramid_proposal_counties ADD COLUMN IF NOT EXISTS plan text NOT NULL DEFAULT 'proposed'
    CHECK (plan IN ('current', 'proposed'));
ALTER TABLE pyramid_proposal_counties DROP CONSTRAINT IF EXISTS pyramid_proposal_counties_pkey;
ALTER TABLE pyramid_proposal_counties ADD PRIMARY KEY (plan, fips);
COMMENT ON COLUMN pyramid_proposal_counties.plan IS
    'mig 1274: current = today''s conferences (main city metro + nearest within 2 h); proposed = the re-imagined map covering every county.';
DELETE FROM pyramid_proposal_county_pins;   -- the balancer rewrites them for the new plan

-- Centres: today's main cities (current) and every proposal's base (proposed).
CREATE OR REPLACE VIEW pyramid_region_centers AS
SELECT m.competition_id AS conference_id, NULL::int AS proposed_id,
       m.center_lat AS lat, m.center_lon AS lon, m.traffic_factor AS factor, 'current'::text AS plan
  FROM pyramid_main_cities m
  JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
 WHERE m.center_lat IS NOT NULL
UNION ALL
SELECT NULL, a.proposed_id, COALESCE(a.center_lat, k.lat), COALESCE(a.center_lon, k.lon), p.traffic_factor, 'proposed'
  FROM pyramid_proposed_anchors a
  JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id
  JOIN pyramid_counties k ON k.fips = a.fips
 WHERE a.is_base;

CREATE OR REPLACE VIEW pyramid_region_homes AS
SELECT DISTINCT ON (plan, fips) fips, conference_id, proposed_id, plan
  FROM (SELECT mc.fips, m.competition_id AS conference_id, NULL::int AS proposed_id, 'current'::text AS plan
          FROM pyramid_main_cities m
          JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
          JOIN pyramid_metro_counties h ON h.fips = ANY (m.core_fips)
          JOIN pyramid_metro_areas a ON a.cbsa_code = h.cbsa_code AND a.kind = 'metro'
          JOIN pyramid_metro_counties mc ON mc.cbsa_code = h.cbsa_code
        UNION ALL
        SELECT mc.fips, NULL, an.proposed_id, 'proposed'
          FROM pyramid_proposed_anchors an
          JOIN pyramid_metro_counties h ON h.fips = an.fips
          JOIN pyramid_metro_areas a ON a.cbsa_code = h.cbsa_code AND a.kind = 'metro'
          JOIN pyramid_metro_counties mc ON mc.cbsa_code = h.cbsa_code) s
 ORDER BY plan, fips, conference_id, proposed_id;
COMMENT ON VIEW pyramid_region_homes IS
    'mig 1274: per plan, county → the region whose metro area it is in (current: live main cities; proposed: every proposal anchor).';

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
    SELECT span_min_population, proposal_reach_km INTO minpop, reach FROM pyramid_territory_policy LIMIT 1;

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

    DELETE FROM pyramid_proposal_counties;

    -- Both plans: a county in a region's home metro is that region's.
    INSERT INTO pyramid_proposal_counties (plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    SELECT h.plan, k.fips, h.conference_id, h.proposed_id,
           (SELECT min(fh_km(k.lat, k.lon, c.lat, c.lon)) FROM pyramid_region_centers c
             WHERE c.plan = h.plan AND c.conference_id IS NOT DISTINCT FROM h.conference_id AND c.proposed_id IS NOT DISTINCT FROM h.proposed_id),
           h.conference_id, h.proposed_id
      FROM pyramid_counties k
      JOIN pyramid_region_homes h ON h.fips = k.fips
     WHERE k.state NOT IN ('AK', 'HI', 'PR');

    -- Current: the nearest of today's cities within the two-hour reach; the rest open.
    -- Proposed: the nearest base, no limit — every county covered.
    INSERT INTO pyramid_proposal_counties (plan, fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    SELECT pl.plan, k.fips, t.conference_id, t.proposed_id, t.km, s.conference_id, s.proposed_id
      FROM pyramid_counties k
      CROSS JOIN (VALUES ('current'), ('proposed')) pl(plan)
      CROSS JOIN LATERAL (
            SELECT c.conference_id, c.proposed_id, fh_km(k.lat, k.lon, c.lat, c.lon) AS km
              FROM pyramid_region_centers c
             WHERE c.plan = pl.plan AND (pl.plan = 'proposed' OR fh_km(k.lat, k.lon, c.lat, c.lon) <= reach)
             ORDER BY fh_km(k.lat, k.lon, c.lat, c.lon) * c.factor
             LIMIT 1) t
      CROSS JOIN LATERAL (
            SELECT c.conference_id, c.proposed_id
              FROM pyramid_region_centers c
             WHERE c.plan = pl.plan AND (pl.plan = 'proposed' OR fh_km(k.lat, k.lon, c.lat, c.lon) <= reach)
             ORDER BY fh_km(k.lat, k.lon, c.lat, c.lon)
             LIMIT 1) s
     WHERE k.state NOT IN ('AK', 'HI', 'PR')
       AND NOT EXISTS (SELECT 1 FROM pyramid_region_homes h WHERE h.plan = pl.plan AND h.fips = k.fips);

    -- The balancer's moves (proposed plan only).
    UPDATE pyramid_proposal_counties pc
       SET conference_id = pin.conference_id, proposed_id = pin.proposed_id,
           plain_conference_id = pin.conference_id, plain_proposed_id = pin.proposed_id
      FROM pyramid_proposal_county_pins pin
     WHERE pc.plan = 'proposed' AND pin.fips = pc.fips
       AND NOT EXISTS (SELECT 1 FROM pyramid_region_homes h WHERE h.plan = 'proposed' AND h.fips = pc.fips);

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
    'mig 1274: both plans — current (today''s conferences, 2 h reach) and proposed (re-imagined, every county) — region stats and border lines. Pipeline: scripts/pyramid-balance.py → pyramid-sea-borders.py → pyramid-drive-times.py.';

-- ── Copy ────────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('plan_current', 'APSL pyramid — map plan pill: today''s conferences', 'Current', 320),
    ('plan_proposed', 'APSL pyramid — map plan pill: the re-imagined map', 'Proposed', 321),
    ('plan_current_intro', 'APSL pyramid — Current plan: how it is drawn', 'Today''s 8 APSL conferences: each its city''s metro area plus the counties within about 2 hours; the rest is open.', 322),
    ('proposal_count_current', 'APSL pyramid — ☰ count, current plan', '{live} conferences today', 323)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

UPDATE message_templates
   SET body = 'Our proposal, not APSL''s, modelled on 4th divisions abroad (Serie D, 2ª Federación, Regionalliga): the whole lower 48, today''s 8 conferences re-imagined with the rest. Each holds its metro area and the counties nearest its city, tails trimmed toward a 4½ h longest trip. Green ready · yellow borderline · grey watch — people in its metro vs the smallest live conference''s metro, Hartford ({bar}).',
       updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_intro';
UPDATE message_templates SET body = '{live} re-imagined + {proposed} new = {total} conferences', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_count';
