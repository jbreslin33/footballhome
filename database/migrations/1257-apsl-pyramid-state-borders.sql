-- 1257 (2026-11-11) — #apsl-pyramid map: state borders, clearer.
-- Owner: "show state borders clearer".  The map tiles draw state lines
-- faintly; this draws them as their own layer — every edge two counties of
-- different states share, plus river banks facing another state (Census
-- county shapes, pyramid_counties), joined into lines.  States don't move, so it is computed once here.  Served by
-- GET /api/pyramid/state-borders; ☰ Show on screen → "State borders".

CREATE TABLE IF NOT EXISTS pyramid_state_borders (
    id      serial PRIMARY KEY,
    state_a char(2) NOT NULL,
    state_b char(2) NOT NULL,
    line    jsonb NOT NULL      -- [[lat, lon], …]
);
COMMENT ON TABLE pyramid_state_borders IS 'mig 1257: state lines for the #apsl-pyramid map (shared county edges across a state line).';

DELETE FROM pyramid_state_borders;
-- (1) land lines: edges two counties of different states share;
-- (2) river lines: where a state line runs down a river the counties on the
--     two banks share no edge, so a bank edge counts when another state's
--     bank is within 5 km across the water (edge midpoints — the outlines use long edges) (Delaware, Hudson, Potomac,
--     Ohio, Mississippi …) — open coast faces no state and is left out.
INSERT INTO pyramid_state_borders (state_a, state_b, line)
WITH polys AS (
    SELECT k.fips, k.state, p.ord AS pord, p.poly
      FROM pyramid_counties k
      CROSS JOIN LATERAL jsonb_array_elements(
            CASE k.geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(k.geometry->'coordinates')
                                     WHEN 'MultiPolygon' THEN k.geometry->'coordinates' ELSE '[]'::jsonb END)
            WITH ORDINALITY p(poly, ord)
     WHERE k.state NOT IN ('AK', 'HI', 'PR')
), rings AS (
    SELECT fips, state, pord * 10000 + r.ord AS ring, r.ring AS pts
      FROM polys CROSS JOIN LATERAL jsonb_array_elements(poly) WITH ORDINALITY r(ring, ord)
), pts AS (
    SELECT fips, state, ring, q.i, round((q.pt->>1)::numeric, 4) AS lat, round((q.pt->>0)::numeric, 4) AS lon
      FROM rings CROSS JOIN LATERAL jsonb_array_elements(pts) WITH ORDINALITY q(pt, i)
), seg AS (
    SELECT fips, state, ring, i, lat, lon, lead(lat) OVER w AS lat2, lead(lon) OVER w AS lon2
      FROM pts WINDOW w AS (PARTITION BY fips, ring ORDER BY i)
), keyed AS (
    SELECT s.*, CASE WHEN (lat, lon) < (lat2, lon2) THEN lat || ',' || lon || '|' || lat2 || ',' || lon2
                     ELSE lat2 || ',' || lon2 || '|' || lat || ',' || lon END AS k
      FROM seg s WHERE lat2 IS NOT NULL AND (lat, lon) <> (lat2, lon2)
), owners AS (
    SELECT k, count(DISTINCT fips) AS n, min(state) AS s1, max(state) AS s2 FROM keyed GROUP BY k
), outer_e AS (          -- shore edges (one county owns them), with a 0.05° bucket
    SELECT ky.*, (ky.lat + ky.lat2) / 2 AS mlat, (ky.lon + ky.lon2) / 2 AS mlon,
           floor((ky.lat + ky.lat2) / 2 / 0.05)::int AS bi, floor((ky.lon + ky.lon2) / 2 / 0.05)::int AS bj
      FROM keyed ky JOIN owners o ON o.k = ky.k WHERE o.n = 1
), river AS (            -- a shore edge facing another state's shore within 5 km (edge midpoints)
    SELECT DISTINCT ON (a.fips, a.ring, a.i) a.fips, a.ring, a.i, a.lat, a.lon, a.lat2, a.lon2, a.state AS s1, b.state AS s2
      FROM outer_e a
      JOIN outer_e b ON b.bi BETWEEN a.bi - 1 AND a.bi + 1 AND b.bj BETWEEN a.bj - 1 AND a.bj + 1
                    AND b.state <> a.state
                    AND fh_km(a.mlat, a.mlon, b.mlat, b.mlon) < 5
     ORDER BY a.fips, a.ring, a.i, fh_km(a.mlat, a.mlon, b.mlat, b.mlon)
), border AS (
    SELECT ky.fips, ky.ring, ky.i, ky.lat, ky.lon, ky.lat2, ky.lon2, o.s1, o.s2
      FROM keyed ky JOIN owners o ON o.k = ky.k
     WHERE o.n = 2 AND o.s1 <> o.s2 AND ky.state = o.s1     -- each land edge once
    UNION ALL
    SELECT fips, ring, i, lat, lon, lat2, lon2, least(s1, s2), greatest(s1, s2) FROM river
), runs AS (
    SELECT b.*, i - row_number() OVER (PARTITION BY fips, ring, s2 ORDER BY i) AS grp FROM border b
)
SELECT s1, s2,
       jsonb_build_array(jsonb_build_array(min(lat) FILTER (WHERE i = first_i), min(lon) FILTER (WHERE i = first_i)))
         || jsonb_agg(jsonb_build_array(lat2, lon2) ORDER BY i)
  FROM (SELECT r.*, min(i) OVER (PARTITION BY fips, ring, s2, grp) AS first_i FROM runs r) x
 GROUP BY fips, ring, s1, s2, grp;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — menu: state borders switch', 'apsl_pyramid', 'feature_states', NULL, 'State borders', 197, true, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'feature_states');
