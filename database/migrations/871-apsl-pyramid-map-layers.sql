-- 871 (2026-10-30) — #apsl-pyramid USA map: choose the map underneath.
--
-- Owner 2026-10-30: "the map is pretty bare can we have option of satelite
-- etc".  One row per map: its name on the pill, its tiles, its credit.  A
-- new map = a row here.  overlay_url = a transparent layer drawn on top
-- (place names on the satellite).  darken = the CSS filter that turns a
-- light map dark.  is_default = what a first-time viewer sees.
CREATE TABLE IF NOT EXISTS pyramid_map_layers (
    code        text PRIMARY KEY,
    label       text NOT NULL,
    tile_url    text NOT NULL,
    overlay_url text,
    attribution text NOT NULL,
    max_zoom    int  NOT NULL,
    darken      boolean NOT NULL DEFAULT false,
    is_default  boolean NOT NULL DEFAULT false,
    sort_order  int  NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS pyramid_map_layers_one_default ON pyramid_map_layers (is_default) WHERE is_default;

INSERT INTO pyramid_map_layers (code, label, tile_url, overlay_url, attribution, max_zoom, darken, is_default, sort_order) VALUES
    ('dark', 'Dark', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', NULL,
     '© OpenStreetMap contributors', 18, true, true, 1),
    ('streets', 'Streets', 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', NULL,
     '© OpenStreetMap contributors', 18, false, false, 2),
    ('satellite', 'Satellite', 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
     'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
     'Tiles © Esri — Source: Esri, Maxar, Earthstar Geographics, and the GIS User Community', 18, false, false, 3),
    ('terrain', 'Terrain', 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', NULL,
     'Map data © OpenStreetMap contributors, SRTM · Map style © OpenTopoMap (CC-BY-SA)', 17, false, false, 4)
ON CONFLICT (code) DO NOTHING;

-- The credit now sits on each map's row.
UPDATE message_templates SET is_active = false WHERE kind = 'apsl_pyramid' AND tier = 'map_attribution';
