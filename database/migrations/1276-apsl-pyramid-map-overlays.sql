-- 1276 (2026-11-11) — #apsl-pyramid map: declutter switches — a plain base
-- map, and place names, roads, rivers and county lines as ☰ "Show on
-- screen" checkboxes.
--
-- Owner 2026-11-11: "also check box for county borders and roads etc so it
-- declutters map lines when needed" / "rivers etc".
--
-- The OpenStreetMap tiles bake roads, county lines and rivers into the
-- picture, so they can't be switched off.  New default base 'plain' (Esri
-- World Shaded Relief — relief only, no lines or names); each detail is its
-- own layer on top, switched in ☰ (pyramid_map_overlays): place names +
-- boundaries, roads (Esri reference tiles), rivers & lakes (Esri hydro
-- reference), county lines (ours — every shared county edge, computed once
-- into pyramid_county_lines, GET /api/pyramid/county-lines).  The detailed
-- bases (Streets, Satellite, Terrain) stay; the overlays add to any base.

INSERT INTO pyramid_map_layers (code, label, tile_url, overlay_url, attribution, max_zoom, darken, is_default, sort_order)
VALUES ('plain', 'Plain', 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}',
        NULL, 'Tiles © Esri — Source: Esri', 13, true, false, 0)
ON CONFLICT (code) DO NOTHING;
UPDATE pyramid_map_layers SET is_default = (code = 'plain');

CREATE TABLE IF NOT EXISTS pyramid_map_overlays (
    code        text PRIMARY KEY,           -- the ☰ switch is feature 'ov_<code>', its label copy tier 'feature_<code>'
    kind        text NOT NULL CHECK (kind IN ('tiles', 'county_lines')),
    tile_url    text,
    attribution text,
    max_zoom    int NOT NULL DEFAULT 18,
    def_on      boolean NOT NULL DEFAULT false,
    sort_order  int NOT NULL DEFAULT 0
);
COMMENT ON TABLE pyramid_map_overlays IS
    'mig 1276: #apsl-pyramid map detail layers switched in ☰ Show on screen (place names, roads, rivers, county lines).';

INSERT INTO pyramid_map_overlays (code, kind, tile_url, attribution, max_zoom, def_on, sort_order) VALUES
  ('places', 'tiles', 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}', 'Labels © Esri', 18, true, 1),
  ('roads', 'tiles', 'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Transportation/MapServer/tile/{z}/{y}/{x}', 'Roads © Esri', 18, false, 2),
  ('rivers', 'tiles', 'https://tiles.arcgis.com/tiles/P3ePLMYs2RVChkJx/arcgis/rest/services/Esri_Hydro_Reference_Overlay/MapServer/tile/{z}/{y}/{x}', 'Hydro © Esri', 13, true, 3),
  ('counties', 'county_lines', NULL, NULL, 18, false, 4)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('feature_places', 'APSL pyramid — menu: place names', 'Place names', 201),
    ('feature_roads', 'APSL pyramid — menu: roads', 'Roads', 202),
    ('feature_rivers', 'APSL pyramid — menu: rivers and lakes', 'Rivers & lakes', 203),
    ('feature_counties', 'APSL pyramid — menu: county lines', 'County lines', 204)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

-- County lines: every outline edge two lower-48 counties share, consecutive
-- edges of a ring joined into one line (drawn once, from the lower fips).
CREATE TABLE IF NOT EXISTS pyramid_county_lines (
    id   serial PRIMARY KEY,
    line jsonb NOT NULL                     -- [[lat, lon], …]
);
COMMENT ON TABLE pyramid_county_lines IS
    'mig 1276: shared county edges for the #apsl-pyramid "County lines" switch (GET /api/pyramid/county-lines).';
DELETE FROM pyramid_county_lines;
INSERT INTO pyramid_county_lines (line)
WITH polys AS (
    SELECT k.fips, p.ord AS pord, p.poly FROM pyramid_counties k
     CROSS JOIN LATERAL jsonb_array_elements(
           CASE k.geometry->>'type' WHEN 'Polygon' THEN jsonb_build_array(k.geometry->'coordinates')
                                    WHEN 'MultiPolygon' THEN k.geometry->'coordinates' ELSE '[]'::jsonb END)
           WITH ORDINALITY p(poly, ord)
     WHERE k.state NOT IN ('AK', 'HI', 'PR')
), rings AS (
    SELECT fips, pord * 10000 + r.ord AS ring, r.ring AS pts
      FROM polys CROSS JOIN LATERAL jsonb_array_elements(poly) WITH ORDINALITY r(ring, ord)
), pts AS (
    SELECT fips, ring, q.i, round((q.pt->>1)::numeric, 4) AS lat, round((q.pt->>0)::numeric, 4) AS lon
      FROM rings CROSS JOIN LATERAL jsonb_array_elements(pts) WITH ORDINALITY q(pt, i)
), seg AS (
    SELECT fips, ring, i, lat, lon, lead(lat) OVER w AS lat2, lead(lon) OVER w AS lon2
      FROM pts WINDOW w AS (PARTITION BY fips, ring ORDER BY i)
), keyed AS (
    SELECT s.*, CASE WHEN (lat, lon) < (lat2, lon2) THEN lat || ',' || lon || '|' || lat2 || ',' || lon2
                     ELSE lat2 || ',' || lon2 || '|' || lat || ',' || lon END AS k
      FROM seg s WHERE lat2 IS NOT NULL AND (lat, lon) <> (lat2, lon2)
), owners AS (
    SELECT k, min(fips) AS f1 FROM keyed GROUP BY k HAVING count(DISTINCT fips) = 2
), mine AS (
    SELECT ky.* FROM keyed ky JOIN owners o ON o.k = ky.k AND o.f1 = ky.fips
), runs AS (
    SELECT m.*, i - row_number() OVER (PARTITION BY fips, ring ORDER BY i) AS grp FROM mine m
)
SELECT jsonb_build_array(jsonb_build_array(min(lat) FILTER (WHERE i = first_i), min(lon) FILTER (WHERE i = first_i)))
         || jsonb_agg(jsonb_build_array(lat2, lon2) ORDER BY i)
  FROM (SELECT r.*, min(i) OVER (PARTITION BY fips, ring, grp) AS first_i FROM runs r) x
 GROUP BY fips, ring, grp;
