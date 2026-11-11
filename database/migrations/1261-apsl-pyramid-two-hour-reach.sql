-- 1261 (2026-11-11) — #apsl-pyramid proposal map: conferences built around
-- one city, reaching ~2 hours; the empty land between them stays open.
--
-- Owner 2026-11-11: "the proposed conferences look to big lol. it should
-- find a city to base around and then stretch like under 2 hours each way
-- right?" / "we are more pop based then geo based right?".
--
-- * Every conference — live and proposed — is based on ONE city: a live
--   conference's main city (mig 1255); a proposal's base anchor
--   (pyramid_proposed_anchors.is_base).  Its region is the counties within
--   pyramid_territory_policy.proposal_reach_km (160 km straight line ≈ 2
--   hours' drive) of that city; a county in reach of two goes to the nearer
--   (× traffic factor, as before).  Counties in nobody's reach are open
--   ground: no conference, and the map draws a region's edge facing them.
-- * Population decides where a conference can be: a proposal's tier is its
--   people within 100 km (reach_km) of its base city against the smallest
--   live conference counted the same way around its city centre (the old
--   bar, nearest APSL ground, is retired — owner: never that measure).
-- * Second cities out of their base's reach become proposals of their own:
--   Cleveland (from Steel → Western Reserve), Raleigh (Piedmont → Triangle),
--   Portland (Cascadia → Columbia), Kansas City (Gateway → Heartland).
-- Rerun scripts/pyramid-sea-borders.py after this.

ALTER TABLE pyramid_territory_policy ADD COLUMN IF NOT EXISTS proposal_reach_km numeric NOT NULL DEFAULT 160;
COMMENT ON COLUMN pyramid_territory_policy.proposal_reach_km IS
    'mig 1261: how far a conference reaches from its city on the #apsl-pyramid proposal map — 160 km straight line ≈ 2 hours'' drive each way.';
ALTER TABLE pyramid_proposed_anchors ADD COLUMN IF NOT EXISTS is_base boolean NOT NULL DEFAULT false;

-- The split-off cities leave their old proposals …
DELETE FROM pyramid_proposed_anchors a USING pyramid_proposed_conferences p
 WHERE p.id = a.proposed_id AND (p.code, a.fips) IN (('steel', '39035'), ('piedmont', '37183'), ('cascadia', '41051'), ('gateway', '29095'));
UPDATE pyramid_proposed_conferences SET note = 'Greater Pittsburgh.' WHERE code = 'steel';
UPDATE pyramid_proposed_conferences SET note = 'Charlotte and the Triad (Greensboro, Winston-Salem).' WHERE code = 'piedmont';
UPDATE pyramid_proposed_conferences SET note = 'Seattle–Tacoma and Puget Sound.' WHERE code = 'cascadia';
UPDATE pyramid_proposed_conferences SET note = 'Greater St. Louis.' WHERE code = 'gateway';

-- … and become their own.
INSERT INTO pyramid_proposed_conferences (code, name, note, sort_order, color) VALUES
  ('western_reserve', 'Western Reserve Conference', 'Cleveland and Akron — out of Pittsburghs two-hour reach, so its own.', 75, '#ef4444'),
  ('triangle', 'Triangle Conference', 'Raleigh, Durham and Chapel Hill — over two hours from Charlotte.', 115, '#22c55e'),
  ('columbia', 'Columbia Conference', 'Portland and Vancouver WA — three hours from Seattle.', 105, '#a855f7'),
  ('heartland', 'Heartland Conference', 'Kansas City — four hours from St. Louis.', 155, '#ec4899')
ON CONFLICT (code) DO NOTHING;
INSERT INTO pyramid_proposed_anchors (proposed_id, fips, label, center_lat, center_lon, is_base)
SELECT p.id, v.fips, v.label, v.lat, v.lon, v.base
  FROM (VALUES
  ('western_reserve', '39035', 'Cleveland', 41.4993, -81.6944, true),
  ('western_reserve', '39153', 'Akron', 41.0814, -81.519, false),
  ('triangle', '37183', 'Raleigh', 35.7796, -78.6382, true),
  ('triangle', '37063', 'Durham', 35.994, -78.8986, false),
  ('columbia', '41051', 'Portland', 45.5152, -122.6784, true),
  ('heartland', '29095', 'Kansas City', 39.0997, -94.5786, true)
  ) AS v(code, fips, label, lat, lon, base)
  JOIN pyramid_proposed_conferences p ON p.code = v.code
ON CONFLICT DO NOTHING;

-- One base city per proposal: the first anchor named (the metro it is named for).
UPDATE pyramid_proposed_anchors a SET is_base = true
  FROM (VALUES ('pacific','06037'),('lakeshore','17031'),('golden_gate','06075'),('gulf_coast','48201'),
               ('sunshine','12057'),('biscayne','12086'),('steel','42003'),('alamo','48029'),
               ('buckeye','39049'),('cascadia','53033'),('piedmont','37119'),('sonoran','04013'),
               ('front_range','08031'),('north_star','27053'),('gateway','29510'),('tidewater','51760'),
               ('music_city','47037'),('wasatch','49035'),('erie_canal','36055'),('bayou','22071'),
               ('red_dirt','40109'),('mojave','32003')) AS v(code, fips)
  JOIN pyramid_proposed_conferences p ON p.code = v.code
 WHERE a.proposed_id = p.id AND a.fips = v.fips AND NOT a.is_base;

-- Region centres: live conferences' main cities; proposals' base cities only.
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
  JOIN pyramid_counties k ON k.fips = a.fips
 WHERE a.is_base;

CREATE OR REPLACE FUNCTION public.fh_pyramid_proposal_refresh()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    bar bigint;
    vkind text;
BEGIN
    -- The bar (mig 1261): the smallest live conference's core — people
    -- within 100 km (policy reach_km) of its main city's centre.  A proposal's
    -- core is counted the same way around its base city.
    SELECT min(s.pop) INTO bar FROM (
        SELECT sum(k.population) AS pop
          FROM pyramid_main_cities m
          JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
          JOIN pyramid_counties k ON fh_km(k.lat, k.lon, m.center_lat, m.center_lon) <= (SELECT reach_km FROM pyramid_territory_policy LIMIT 1)
         WHERE m.center_lat IS NOT NULL
         GROUP BY m.competition_id) s;

    UPDATE pyramid_proposed_conferences p
       SET core_population = s.pop,
           tier = CASE WHEN s.pop >= bar THEN 'ready' WHEN s.pop >= bar * 0.75 THEN 'borderline' ELSE 'developing' END,
           developing = s.pop < bar * 0.75
      FROM (SELECT a.proposed_id AS id, sum(k.population) AS pop
              FROM pyramid_proposed_anchors a
              JOIN pyramid_counties ak ON ak.fips = a.fips
              JOIN pyramid_counties k ON fh_km(k.lat, k.lon, COALESCE(a.center_lat, ak.lat), COALESCE(a.center_lon, ak.lon))
                                         <= (SELECT reach_km FROM pyramid_territory_policy LIMIT 1)
             WHERE a.is_base
             GROUP BY a.proposed_id) s
     WHERE s.id = p.id;

    -- Every lower-48 county within ~2 h of a centre → its region, two ways (mig 1255);
    -- counties out of everyone's reach stay open ground (no row, mig 1261): by straight
    -- distance to the region centres (plain_*), and by distance × the
    -- centre's traffic factor (conference_id / proposed_id — the border the
    -- map draws in colour).  Where they differ is the neutral zone.
    DELETE FROM pyramid_proposal_counties;
    INSERT INTO pyramid_proposal_counties (fips, conference_id, proposed_id, km, plain_conference_id, plain_proposed_id)
    SELECT k.fips, t.conference_id, t.proposed_id, t.km, pl.conference_id, pl.proposed_id
      FROM pyramid_counties k
      CROSS JOIN LATERAL (     -- only centres within ~2 h (policy proposal_reach_km, mig 1261)
            SELECT c.conference_id, c.proposed_id, fh_km(k.lat, k.lon, c.lat, c.lon) AS km
              FROM pyramid_region_centers c
             WHERE fh_km(k.lat, k.lon, c.lat, c.lon) <= (SELECT proposal_reach_km FROM pyramid_territory_policy LIMIT 1)
             ORDER BY fh_km(k.lat, k.lon, c.lat, c.lon) * c.factor
             LIMIT 1) t
      CROSS JOIN LATERAL (
            SELECT c.conference_id, c.proposed_id
              FROM pyramid_region_centers c
             WHERE fh_km(k.lat, k.lon, c.lat, c.lon) <= (SELECT proposal_reach_km FROM pyramid_territory_policy LIMIT 1)
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
END $function$;

-- Tiers first (with every proposal a candidate centre), then the fill with
-- only the non-developing ones — run twice so the new proposals settle.
SELECT fh_pyramid_proposal_refresh();
SELECT fh_pyramid_proposal_refresh();

UPDATE message_templates
   SET body = 'Our proposal, not APSL''s. Each conference reaches about 2 hours from its city; land out of reach stays open. Green ready · yellow borderline · grey watch — people within 100 km of the city vs the smallest live conference ({bar}).',
       updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_intro';
