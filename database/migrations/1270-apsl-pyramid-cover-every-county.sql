-- 1270 (2026-11-11) — #apsl-pyramid proposal map: the whole country fits
-- together like a 4th division abroad, and every conference has a pill.
--
-- Owner 2026-11-11: "no part of country should be left uncovered. even if
-- the conference would be sparsely populated. you have to fit the puzzle
-- together" / "need pill on each conf proposed or not proposed on map with
-- distance from furthest points and pop" / "drive time … or dist and drive
-- time" / "use all your powers of thinking and knowledge to think how to set
-- the borders and how many conferences. look to other countries as well as
-- this being the 4th division."
--
-- How other countries run their 4th division (people per group):
--   Germany  Regionalliga  5 groups for 83 M   (≈17 M each)
--   France   National 2    3 groups for 68 M   (≈23 M)
--   Spain    2ª Federación 5 groups for 48 M   (≈10 M)
--   Italy    Serie D       9 groups for 59 M   (≈6.5 M)
--   Sweden   Division 2    6 groups for 10.5 M (≈1.8 M, vast north)
--   Norway   3. divisjon   6 groups for 5.5 M  (≈0.9 M, ferries/flights)
--   Brazil   Série D       64 clubs in 8 groups of 8 across a US-sized
--            country (flights) · England's semi-pro step 2–4 is regional
--            groups of 20–24 with a ~4 h longest trip.
-- Dense Europe runs groups of 6–20 M people with a day-trip longest away
-- game (≈4 h); sparse countries accept 1–2 M and long trips rather than
-- leave land out.  Lower 48: 331 M people.  Spain/Italy density gives 35–50
-- groups; the sparse West pulls it down.  So: 40 conferences — the 8 live
-- ones plus 32 proposals — each based on its biggest city, every county
-- going to the nearest base (× traffic factor, NY 1.25) with whole metro
-- areas kept together (mig 1265), NO reach limit: nothing is left open.
-- Target: dense conference longest trip ≤ ~4½ h; sparse ones (Frontier,
-- Inland Northwest, North Star, Mojave, Rio Grande) take longer, as in
-- Norway or Brazil.  The pill shows each one's people and its two furthest
-- county centres apart — straight km and the drive (OSRM road route,
-- no traffic; scripts/pyramid-drive-times.py fills pyramid_drive_times).
--
-- 7 proposals fold into neighbours (Western Reserve → Steel, Triangle →
-- Tidewater, Bluegrass → Crossroads, Smoky Mountain → Music City, Platte →
-- Heartland, Magic City + West Michigan → nearest live conference);
-- Sacramento leaves Golden Gate as Central Valley's base; Sandia becomes Rio
-- Grande; new: Inland Northwest (Spokane), Frontier (Billings).
-- Rerun scripts/pyramid-sea-borders.py and scripts/pyramid-drive-times.py after.

-- ── The 32 proposals ────────────────────────────────────────────────────
DELETE FROM pyramid_proposed_conferences
 WHERE code IN ('western_reserve', 'triangle', 'bluegrass', 'smoky_mountain', 'platte', 'magic_city', 'west_michigan');

UPDATE pyramid_proposed_conferences SET name = 'Rio Grande Conference', note = 'Albuquerque, Santa Fe and El Paso.' WHERE code = 'sandia';
INSERT INTO pyramid_proposed_conferences (code, name, note, sort_order) VALUES
  ('inland_nw', 'Inland Northwest Conference', 'Spokane, the Palouse, north Idaho and western Montana — sparse, long trips.', 380),
  ('frontier', 'Frontier Conference', 'Montana, Wyoming and the western Dakotas — the sparsest; long trips, as in northern Norway.', 390)
ON CONFLICT (code) DO NOTHING;

-- Notes for the reshaped ones.
UPDATE pyramid_proposed_conferences p SET note = v.note FROM (VALUES
  ('steel', 'Pittsburgh, Cleveland, Akron, Youngstown and Erie.'),
  ('buckeye', 'Columbus, Cincinnati and Dayton.'),
  ('crossroads', 'Indianapolis, Louisville and Lexington.'),
  ('music_city', 'Nashville, Knoxville, Chattanooga and Huntsville.'),
  ('heartland', 'Kansas City, Omaha and Des Moines.'),
  ('red_dirt', 'Oklahoma City, Tulsa and Wichita.'),
  ('mid_south', 'Memphis, Little Rock and Jackson.'),
  ('bayou', 'New Orleans, Baton Rouge, Mobile and Pensacola.'),
  ('first_coast', 'Jacksonville, Tallahassee and Savannah.'),
  ('tidewater', 'Richmond, Norfolk–Virginia Beach and the Triangle (Raleigh, Durham).'),
  ('central_valley', 'Sacramento, Stockton, Fresno and Reno.'),
  ('golden_gate', 'San Francisco, Oakland and San Jose.'),
  ('wasatch', 'Salt Lake City, Ogden, Provo and Boise.'),
  ('erie_canal', 'Rochester, Buffalo and Syracuse.')
) AS v(code, note) WHERE p.code = v.code;

-- Bases and anchors (an anchor's metro area is the conference's home, mig 1265).
UPDATE pyramid_proposed_anchors a SET is_base = false
  FROM pyramid_proposed_conferences p WHERE p.id = a.proposed_id AND p.code = 'central_valley';
DELETE FROM pyramid_proposed_anchors a USING pyramid_proposed_conferences p
 WHERE p.id = a.proposed_id AND p.code = 'golden_gate' AND a.fips = '06067';
INSERT INTO pyramid_proposed_anchors (proposed_id, fips, label, center_lat, center_lon, is_base)
SELECT p.id, v.fips, v.label, v.lat, v.lon, v.base
  FROM (VALUES
  ('central_valley', '06067', 'Sacramento', 38.5816, -121.4944, true),
  ('central_valley', '06077', 'Stockton', 37.9577, -121.2908, false),
  ('central_valley', '32031', 'Reno', 39.5296, -119.8138, false),
  ('steel', '39035', 'Cleveland', 41.4993, -81.6944, false),
  ('steel', '39153', 'Akron', 41.0814, -81.519, false),
  ('tidewater', '37183', 'Raleigh', 35.7796, -78.6382, false),
  ('tidewater', '37063', 'Durham', 35.994, -78.8986, false),
  ('crossroads', '21111', 'Louisville', 38.2527, -85.7585, false),
  ('crossroads', '21067', 'Lexington', 38.0406, -84.5037, false),
  ('music_city', '47093', 'Knoxville', 35.9606, -83.9207, false),
  ('music_city', '47065', 'Chattanooga', 35.0456, -85.3097, false),
  ('music_city', '01089', 'Huntsville', 34.7304, -86.5861, false),
  ('heartland', '31055', 'Omaha', 41.2565, -95.9345, false),
  ('heartland', '19153', 'Des Moines', 41.5868, -93.6250, false),
  ('red_dirt', '20173', 'Wichita', 37.6872, -97.3301, false),
  ('mid_south', '05119', 'Little Rock', 34.7465, -92.2896, false),
  ('mid_south', '28049', 'Jackson', 32.2988, -90.1848, false),
  ('bayou', '01097', 'Mobile', 30.6954, -88.0399, false),
  ('bayou', '12033', 'Pensacola', 30.4213, -87.2169, false),
  ('first_coast', '12073', 'Tallahassee', 30.4383, -84.2807, false),
  ('first_coast', '13051', 'Savannah', 32.0809, -81.0912, false),
  ('sandia', '48141', 'El Paso', 31.7619, -106.4850, false),
  ('sandia', '35049', 'Santa Fe', 35.6870, -105.9378, false),
  ('wasatch', '16001', 'Boise', 43.6150, -116.2023, false),
  ('erie_canal', '36067', 'Syracuse', 43.0481, -76.1474, false),
  ('inland_nw', '53063', 'Spokane', 47.6588, -117.4260, true),
  ('frontier', '30111', 'Billings', 45.7833, -108.5007, true),
  ('frontier', '46103', 'Rapid City', 44.0805, -103.2310, false)
  ) AS v(code, fips, label, lat, lon, base)
  JOIN pyramid_proposed_conferences p ON p.code = v.code
ON CONFLICT DO NOTHING;
UPDATE pyramid_proposed_anchors a SET is_base = true
  FROM pyramid_proposed_conferences p
 WHERE p.id = a.proposed_id AND p.code = 'central_valley' AND a.fips = '06067';

-- A colour each (some had none and drew grey), neighbours apart.
UPDATE pyramid_proposed_conferences p SET color = v.color FROM (VALUES
  ('pacific', '#a855f7'), ('coronado', '#0ea5e9'), ('golden_gate', '#14b8a6'), ('central_valley', '#84cc16'),
  ('cascadia', '#f97316'), ('columbia', '#a855f7'), ('inland_nw', '#22c55e'), ('frontier', '#eab308'),
  ('wasatch', '#ef4444'), ('mojave', '#f59e0b'), ('sonoran', '#22c55e'), ('sandia', '#ec4899'),
  ('front_range', '#6366f1'), ('north_star', '#f59e0b'), ('heartland', '#ec4899'), ('red_dirt', '#ef4444'),
  ('gateway', '#f97316'), ('lakeshore', '#3b82f6'), ('crossroads', '#dc2626'), ('buckeye', '#06b6d4'),
  ('steel', '#eab308'), ('erie_canal', '#8b5cf6'), ('music_city', '#22c55e'), ('mid_south', '#f97316'),
  ('bayou', '#a855f7'), ('gulf_coast', '#06b6d4'), ('alamo', '#ec4899'), ('first_coast', '#14b8a6'),
  ('sunshine', '#84cc16'), ('biscayne', '#f43f5e'), ('piedmont', '#ef4444'), ('tidewater', '#6366f1')
) AS v(code, color) WHERE p.code = v.code;

-- ── Every proposal is a region, whatever its size (the tier is a label) ──
CREATE OR REPLACE VIEW pyramid_region_centers AS
SELECT m.competition_id AS conference_id, NULL::int AS proposed_id,
       m.center_lat AS lat, m.center_lon AS lon, m.traffic_factor AS factor
  FROM pyramid_main_cities m
  JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
 WHERE m.center_lat IS NOT NULL
UNION ALL
SELECT NULL, a.proposed_id, COALESCE(a.center_lat, k.lat), COALESCE(a.center_lon, k.lon), p.traffic_factor
  FROM pyramid_proposed_anchors a
  JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id
  JOIN pyramid_counties k ON k.fips = a.fips
 WHERE a.is_base;

CREATE OR REPLACE VIEW pyramid_region_homes AS
SELECT DISTINCT ON (fips) fips, conference_id, proposed_id
  FROM (SELECT mc.fips, m.competition_id AS conference_id, NULL::int AS proposed_id, 0 AS pri
          FROM pyramid_main_cities m
          JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
          JOIN pyramid_metro_counties h ON h.fips = ANY (m.core_fips)
          JOIN pyramid_metro_areas a ON a.cbsa_code = h.cbsa_code AND a.kind = 'metro'
          JOIN pyramid_metro_counties mc ON mc.cbsa_code = h.cbsa_code
        UNION ALL
        SELECT mc.fips, NULL, an.proposed_id, 1
          FROM pyramid_proposed_anchors an
          JOIN pyramid_metro_counties h ON h.fips = an.fips
          JOIN pyramid_metro_areas a ON a.cbsa_code = h.cbsa_code AND a.kind = 'metro'
          JOIN pyramid_metro_counties mc ON mc.cbsa_code = h.cbsa_code) s
 ORDER BY fips, pri, conference_id, proposed_id;

-- ── Per-region numbers for the pill ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_drive_times (
    a_fips     text NOT NULL,
    b_fips     text NOT NULL,
    km         numeric NOT NULL,
    minutes    numeric NOT NULL,
    fetched_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (a_fips, b_fips)
);
COMMENT ON TABLE pyramid_drive_times IS
    'mig 1270: road distance/time between two county centres (OSRM, no traffic) — filled by scripts/pyramid-drive-times.py.';

CREATE TABLE IF NOT EXISTS pyramid_proposal_region_stats (
    region        text PRIMARY KEY,          -- 'c<conference_id>' / 'p<proposed_id>'
    conference_id int,
    proposed_id   int,
    population    bigint NOT NULL,
    counties      int NOT NULL,
    a_fips        text,                      -- the two county centres furthest apart
    b_fips        text,
    span_km       numeric
);
COMMENT ON TABLE pyramid_proposal_region_stats IS
    'mig 1270: each proposal-map region''s people and its two furthest-apart county centres (straight km); drive time in pyramid_drive_times.';

CREATE OR REPLACE FUNCTION public.fh_pyramid_proposal_refresh()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    bar bigint;
    vkind text;
BEGIN
    -- The bar (mig 1265): the smallest metro area anchoring a live conference.
    SELECT b.bar INTO bar FROM pyramid_proposal_bar b;

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

    -- County → region (mig 1270): its home metro's region, else the nearest
    -- base (× traffic factor for the coloured border, straight for plain_*).
    -- No reach limit — every lower-48 county belongs somewhere.
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    SELECT k.fips, h.conference_id, h.proposed_id,
           (SELECT min(fh_km(k.lat, k.lon, c.lat, c.lon)) FROM pyramid_region_centers c
             WHERE c.conference_id IS NOT DISTINCT FROM h.conference_id AND c.proposed_id IS NOT DISTINCT FROM h.proposed_id),
           h.conference_id, h.proposed_id
      FROM pyramid_counties k
      JOIN pyramid_region_homes h ON h.fips = k.fips
     WHERE k.state NOT IN ('AK', 'HI', 'PR');

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
     WHERE k.state NOT IN ('AK', 'HI', 'PR')
       AND NOT EXISTS (SELECT 1 FROM pyramid_region_homes h WHERE h.fips = k.fips);

    -- The pill's numbers: people, and the two county centres furthest apart.
    DELETE FROM pyramid_proposal_region_stats;
    INSERT INTO pyramid_proposal_region_stats (region, conference_id, proposed_id, population, counties, a_fips, b_fips, span_km)
    WITH rc AS (
        SELECT COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id) AS region, pc.conference_id, pc.proposed_id,
               k.fips, k.lat, k.lon, k.population
          FROM pyramid_proposal_counties pc JOIN pyramid_counties k ON k.fips = pc.fips
    ), far AS (
        SELECT DISTINCT ON (a.region) a.region, a.fips AS a_fips, b.fips AS b_fips, fh_km(a.lat, a.lon, b.lat, b.lon) AS km
          FROM rc a JOIN rc b ON b.region = a.region AND b.fips > a.fips
         ORDER BY a.region, fh_km(a.lat, a.lon, b.lat, b.lon) DESC
    )
    SELECT rc.region, min(rc.conference_id), min(rc.proposed_id), sum(rc.population), count(*),
           min(far.a_fips), min(far.b_fips), round(min(far.km)::numeric, 1)
      FROM rc LEFT JOIN far USING (region)
     GROUP BY rc.region;

    DELETE FROM pyramid_proposal_borders;
    FOREACH vkind IN ARRAY ARRAY['travel', 'plain'] LOOP
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind)
    WITH reg AS (            -- open ground (no row) = region 'x', so a region's edge facing it is a border
        SELECT k0.fips,
               CASE WHEN vkind = 'travel' THEN COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x')
                    ELSE COALESCE('c' || pc.plain_conference_id, 'p' || pc.plain_proposed_id, 'x') END AS r,
               COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id, 'x') AS rt
          FROM pyramid_counties k0
          LEFT JOIN pyramid_proposal_counties pc ON pc.fips = k0.fips
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
END $function$;

COMMENT ON FUNCTION fh_pyramid_proposal_refresh() IS
    'mig 1270: proposal tiers (metro vs pyramid_proposal_bar), every lower-48 county → a region (home metro, else nearest base, no limit), region stats, border lines. Rerun scripts/pyramid-sea-borders.py and scripts/pyramid-drive-times.py after.';

SELECT fh_pyramid_proposal_refresh();

-- ── Copy ────────────────────────────────────────────────────────────────
UPDATE message_templates
   SET body = 'Our proposal, not APSL''s, modelled on 4th divisions abroad (Serie D, 2ª Federación, Regionalliga): 40 conferences cover the whole lower 48. Each holds its metro area and every county nearest its city. Green ready · yellow borderline · grey watch — people in its metro vs the smallest live conference''s metro, Hartford ({bar}).',
       updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_intro';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('pill_stats', 'APSL pyramid — map pill: people · furthest apart (km, drive)', '{pop} · ↔ {km} km · {drive}', 311),
    ('pill_far', 'APSL pyramid — map pill tooltip: the two furthest points', 'Furthest apart: {a} ↔ {b}', 312)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
