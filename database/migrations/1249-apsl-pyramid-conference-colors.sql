-- 1249 (2026-11-11) — #apsl-pyramid: a colour per conference; two-tone borders.
--
-- Owner 2026-11-11: "color code the conferences pill then make border
-- thicker but with color of one conference on dividing line and other on
-- the divide line so line is 2 tone color".
--
-- color: every live conference (pyramid_competitions) and every proposed one
-- (pyramid_proposed_conferences, mig 1241) gets one; no two regions that
-- share a border on the proposal map share a colour (greedy colouring over
-- pyramid_proposal_borders, 2026-11-11), and the eight live ones are all
-- different.  The ☰ conference pills, the map's conference bubbles, and the
-- proposal's border halves use it.  Change a colour = update the row.
--
-- a_left: which side of a border line is region_a — the line runs along a
-- county ring of region_a, so a counter-clockwise ring (signed area > 0)
-- puts region_a on the left of the line's direction.  The map offsets each
-- half a few pixels to its own side.

ALTER TABLE pyramid_competitions ADD COLUMN IF NOT EXISTS color text;
ALTER TABLE pyramid_proposed_conferences ADD COLUMN IF NOT EXISTS color text;
ALTER TABLE pyramid_proposal_borders ADD COLUMN IF NOT EXISTS a_left boolean;
COMMENT ON COLUMN pyramid_competitions.color IS 'mig 1249: the conference''s colour on #apsl-pyramid (☰ pills, map bubbles, border halves).';

UPDATE pyramid_competitions c SET color = v.color
  FROM (VALUES
  (2, '#3b82f6'),
  (3, '#ef4444'),
  (5, '#f59e0b'),
  (6, '#a855f7'),
  (7, '#14b8a6'),
  (8, '#ec4899'),
  (9, '#84cc16'),
  (4, '#22c55e')
  ) AS v(id, color)
 WHERE c.id = v.id AND c.color IS DISTINCT FROM v.color;

UPDATE pyramid_proposed_conferences p SET color = v.color
  FROM (VALUES
  (1, '#a855f7'),
  (2, '#3b82f6'),
  (3, '#14b8a6'),
  (4, '#06b6d4'),
  (5, '#84cc16'),
  (6, '#94a3b8'),
  (7, '#94a3b8'),
  (8, '#ec4899'),
  (9, '#06b6d4'),
  (10, '#f97316'),
  (11, '#ef4444'),
  (12, '#22c55e'),
  (13, '#6366f1'),
  (14, '#f59e0b'),
  (15, '#f97316'),
  (16, '#6366f1')
  ) AS v(id, color)
 WHERE p.id = v.id AND p.color IS DISTINCT FROM v.color;

CREATE OR REPLACE FUNCTION fh_pyramid_proposal_refresh() RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    bar bigint;
BEGIN
    -- The bar: the smallest live conference's ground (mig 852 rule).
    SELECT min(pop) INTO bar FROM (
        SELECT sum(k.population) AS pop
          FROM pyramid_county_conference cc JOIN pyramid_counties k ON k.fips = cc.fips
         WHERE cc.conference_id IS NOT NULL
         GROUP BY cc.conference_id) s;

    -- Each proposal's core: people within 100 km (policy reach) of an anchor.
    UPDATE pyramid_proposed_conferences p
       SET core_population = s.pop,
           tier = CASE WHEN s.pop >= bar THEN 'ready' WHEN s.pop >= bar * 0.75 THEN 'borderline' ELSE 'developing' END,
           developing = s.pop < bar * 0.75
      FROM (SELECT p2.id, sum(k.population) AS pop
              FROM pyramid_proposed_conferences p2
              JOIN pyramid_counties k ON EXISTS (
                     SELECT 1 FROM pyramid_proposed_anchors a JOIN pyramid_counties ak ON ak.fips = a.fips
                      WHERE a.proposed_id = p2.id
                        AND fh_km(k.lat, k.lon, ak.lat, ak.lon) <= (SELECT reach_km FROM pyramid_territory_policy LIMIT 1))
             GROUP BY p2.id) s
     WHERE s.id = p.id;

    -- Every lower-48 county → its nearest point: a live conference's APSL
    -- ground, or a non-developing proposal's anchor.
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (fips, conference_id, proposed_id, km)
    SELECT k.fips, n.conference_id, n.proposed_id, n.km
      FROM pyramid_counties k
      CROSS JOIN LATERAL (
            SELECT pt.conference_id, pt.proposed_id, fh_km(k.lat, k.lon, pt.lat, pt.lon) AS km
              FROM (SELECT tc.conference_id, NULL::int AS proposed_id, tc.lat, tc.lon FROM pyramid_team_conference tc
                    UNION ALL
                    SELECT NULL, a.proposed_id, ak.lat, ak.lon
                      FROM pyramid_proposed_anchors a
                      JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id AND NOT p.developing
                      JOIN pyramid_counties ak ON ak.fips = a.fips) pt
             ORDER BY fh_km(k.lat, k.lon, pt.lat, pt.lon)
             LIMIT 1) n
     WHERE k.state NOT IN ('AK', 'HI', 'PR');

    -- Border lines: county ring edges shared by two counties of different
    -- regions, drawn once (from the side whose region key sorts first),
    -- consecutive edges of a ring joined into one line.
    DELETE FROM pyramid_proposal_borders;
    INSERT INTO pyramid_proposal_borders (region_a, region_b, line, a_left)
    WITH reg AS (
        SELECT fips, COALESCE('c' || conference_id, 'p' || proposed_id) AS r FROM pyramid_proposal_counties
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
    ), runs AS (
        SELECT b.*, i - row_number() OVER (PARTITION BY fips, ring, rb ORDER BY i) AS grp FROM border b
    )
    SELECT ra, rb,
           jsonb_build_array(jsonb_build_array(min(lat) FILTER (WHERE i = first_i), min(lon) FILTER (WHERE i = first_i)))
             || jsonb_agg(jsonb_build_array(lat2, lon2) ORDER BY i),
           bool_or(o.ccw)
      FROM (SELECT r.*, min(i) OVER (PARTITION BY fips, ring, rb, grp) AS first_i FROM runs r) x
      JOIN orient o USING (fips, ring)
     GROUP BY x.fips, x.ring, rb, ra, grp;
END $$;


SELECT fh_pyramid_proposal_refresh();
