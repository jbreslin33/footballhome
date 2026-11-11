-- 1272 (2026-11-11) — #apsl-pyramid proposal map: longest trip measured where
-- people live, the long tails rebalanced, and a sortable table in ☰.
--
-- Owner 2026-11-11 (after mig 1270 left 28 of 40 conferences with an 8 h+
-- longest drive): "yes but also show me data in the menu that i can sort by
-- longest trip asc,desc, sort by longest dist asc,des, sort by pop asc,desc,
-- sort by land area asc des etc".
--
-- * Furthest points = between counties where people live: counties of
--   pyramid_territory_policy.span_min_population (50 000) or more — clubs are
--   in towns — or, where a conference has fewer than two, its two biggest.
--   (A county's geographic centre can sit far out in desert or forest.)
-- * pyramid_counties.area_km2: each county's area from its outline (local
--   equal-area projection, holes subtracted); a conference's land area is
--   the sum.
-- * pyramid_proposal_county_pins: county → region moves written by
--   scripts/pyramid-balance.py, applied by the refresh after the nearest-
--   base fill.  The script moves a populated border county to the
--   neighbouring conference when that shortens the longer of the two
--   conferences' furthest-apart distance, toward
--   pyramid_territory_policy.balance_target_km (360 km straight ≈ 4½ h),
--   never splitting a metro area or cutting a conference in two.
-- Pipeline after any change: scripts/pyramid-balance.py (runs the refresh
-- itself), then scripts/pyramid-sea-borders.py, scripts/pyramid-drive-times.py.

ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS span_min_population int NOT NULL DEFAULT 50000;
ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS balance_target_km numeric NOT NULL DEFAULT 360;
COMMENT ON COLUMN pyramid_territory_policy.span_min_population IS
    'mig 1272: a conference''s furthest points are measured between counties with at least this many people (clubs are in towns).';
COMMENT ON COLUMN pyramid_territory_policy.balance_target_km IS
    'mig 1272: scripts/pyramid-balance.py trims conferences whose furthest populated points are further apart than this (straight km; 360 ≈ 4½ h drive).';

-- ── County area ─────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fh_geojson_area_km2(g jsonb) RETURNS numeric
LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
    polys jsonb;
    poly jsonb;
    ring jsonb;
    ri int;
    total numeric := 0;
    a numeric;
    i int;
    n int;
    lat0 numeric;
    kx numeric;
    x1 numeric; y1 numeric; x2 numeric; y2 numeric;
BEGIN
    polys := CASE g->>'type' WHEN 'Polygon' THEN jsonb_build_array(g->'coordinates')
                             WHEN 'MultiPolygon' THEN g->'coordinates' ELSE '[]'::jsonb END;
    FOR poly IN SELECT * FROM jsonb_array_elements(polys) LOOP
        ri := 0;
        FOR ring IN SELECT * FROM jsonb_array_elements(poly) LOOP
            n := jsonb_array_length(ring);
            IF n < 4 THEN ri := ri + 1; CONTINUE; END IF;
            SELECT avg((p->>1)::numeric) INTO lat0 FROM jsonb_array_elements(ring) p;
            kx := 111.32 * cos(radians(lat0));
            a := 0;
            FOR i IN 0 .. n - 2 LOOP
                x1 := (ring->i->>0)::numeric * kx;  y1 := (ring->i->>1)::numeric * 110.57;
                x2 := (ring->(i+1)->>0)::numeric * kx; y2 := (ring->(i+1)->>1)::numeric * 110.57;
                a := a + (x1 * y2 - x2 * y1);
            END LOOP;
            a := abs(a) / 2;
            total := total + CASE WHEN ri = 0 THEN a ELSE -a END;   -- first ring outer, the rest holes
            ri := ri + 1;
        END LOOP;
    END LOOP;
    RETURN round(total, 1);
END $$;
COMMENT ON FUNCTION fh_geojson_area_km2(jsonb) IS
    'mig 1272: area of a GeoJSON (Multi)Polygon in km² — local equal-area projection per ring, holes subtracted.';

ALTER TABLE pyramid_counties ADD COLUMN IF NOT EXISTS area_km2 numeric;
UPDATE pyramid_counties SET area_km2 = fh_geojson_area_km2(geometry) WHERE area_km2 IS NULL;

-- ── Pins from the balancer ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pyramid_proposal_county_pins (
    fips          char(5) PRIMARY KEY REFERENCES pyramid_counties(fips),
    conference_id int REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    proposed_id   int REFERENCES pyramid_proposed_conferences(id) ON DELETE CASCADE,
    CHECK ((conference_id IS NULL) <> (proposed_id IS NULL))
);
COMMENT ON TABLE pyramid_proposal_county_pins IS
    'mig 1272: county → region moves from scripts/pyramid-balance.py (shorter longest trips); the refresh applies them after the nearest-base fill.';

ALTER TABLE pyramid_proposal_region_stats ADD COLUMN IF NOT EXISTS area_km2 numeric;

-- ── Refresh: pins + populated span + area ───────────────────────────────
CREATE OR REPLACE FUNCTION public.fh_pyramid_proposal_refresh()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    bar bigint;
    vkind text;
    minpop int;
BEGIN
    SELECT b.bar INTO bar FROM pyramid_proposal_bar b;
    SELECT span_min_population INTO minpop FROM pyramid_territory_policy LIMIT 1;

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

    -- County → region: home metro, else nearest base (mig 1270) …
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

    -- … then the balancer's moves (mig 1272); a moved county is the same
    -- region both ways (no neutral zone for it).
    UPDATE pyramid_proposal_counties pc
       SET conference_id = pin.conference_id, proposed_id = pin.proposed_id,
           plain_conference_id = pin.conference_id, plain_proposed_id = pin.proposed_id
      FROM pyramid_proposal_county_pins pin
     WHERE pin.fips = pc.fips
       AND NOT EXISTS (SELECT 1 FROM pyramid_region_homes h WHERE h.fips = pc.fips);

    -- The pill's numbers: people, land area, and the two furthest-apart
    -- county centres among the counties where people live (mig 1272).
    DELETE FROM pyramid_proposal_region_stats;
    INSERT INTO pyramid_proposal_region_stats (region, conference_id, proposed_id, population, counties, area_km2, a_fips, b_fips, span_km)
    WITH rc AS (
        SELECT COALESCE('c' || pc.conference_id, 'p' || pc.proposed_id) AS region, pc.conference_id, pc.proposed_id,
               k.fips, k.lat, k.lon, k.population, k.area_km2,
               row_number() OVER (PARTITION BY pc.conference_id, pc.proposed_id ORDER BY k.population DESC) AS rk
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
    FOREACH vkind IN ARRAY ARRAY['travel', 'plain'] LOOP
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left, kind)
    WITH reg AS (
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
    'mig 1272: proposal tiers, every lower-48 county → a region (home metro, nearest base, then balancer pins), region stats (people, area, furthest populated points), border lines. Pipeline: scripts/pyramid-balance.py → pyramid-sea-borders.py → pyramid-drive-times.py.';

SELECT fh_pyramid_proposal_refresh();

-- ── Copy: the sortable table in ☰ ──────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('sort_label', 'APSL pyramid — ☰ table: sort by', 'Sort by (tap again to flip ↑↓)', 313),
    ('col_name', 'APSL pyramid — ☰ table column: conference', 'Conference', 314),
    ('col_pop', 'APSL pyramid — ☰ table column: people', 'People', 315),
    ('col_area', 'APSL pyramid — ☰ table column: land area', 'Area km²', 316),
    ('col_dist', 'APSL pyramid — ☰ table column: furthest apart (straight)', 'Furthest km', 317),
    ('col_drive', 'APSL pyramid — ☰ table column: longest drive', 'Longest drive', 318),
    ('col_counties', 'APSL pyramid — ☰ table column: counties', 'Counties', 319)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

UPDATE message_templates SET body = 'Furthest apart (where people live): {a} ↔ {b}', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'pill_far';

-- Short column labels so the table fits the ☰ panel.
UPDATE message_templates m SET body = v.body, updated_at = now() FROM (VALUES
  ('col_area', 'Area km²'), ('col_dist', 'Far km'), ('col_drive', 'Drive'), ('col_counties', 'Cnty')
) AS v(t, body) WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t;
