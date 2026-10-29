-- 860 (2026-10-29) — #apsl-pyramid map: each conference's main city —
-- city proper, collar counties, further out.
--
-- Owner 2026-10-29: "all of the conferences have a city as its center of
-- mass basically right? can we border that city and show how many teams in
-- the conf 'main' city are in the city proper and how many in collar
-- counties and how many further removed?"
--
-- pyramid_main_cities      a conference's main city: its name, the query
--                          that finds its boundary (OpenStreetMap, fetched
--                          once into geometry) and the county or counties
--                          it sits in (core_fips)
-- pyramid_county_neighbours counties that share a border (from the county
--                          shapes — scripts/pyramid-counties-load.py)
-- A conference's APSL teams then fall in three rings: inside the city
-- limits; in a core or bordering (collar) county; further out.

CREATE TABLE IF NOT EXISTS pyramid_main_cities (
    competition_id integer PRIMARY KEY REFERENCES pyramid_competitions(id) ON DELETE CASCADE,
    name           text NOT NULL,
    query          text NOT NULL,
    core_fips      text[] NOT NULL,
    geometry       jsonb,
    fetched_at     timestamptz,
    fetch_note     text
);

CREATE TABLE IF NOT EXISTS pyramid_county_neighbours (
    fips      char(5) NOT NULL REFERENCES pyramid_counties(fips) ON DELETE CASCADE,
    neighbour char(5) NOT NULL REFERENCES pyramid_counties(fips) ON DELETE CASCADE,
    PRIMARY KEY (fips, neighbour)
);

INSERT INTO pyramid_main_cities (competition_id, name, query, core_fips)
SELECT c.id, v.city, v.q, v.core
  FROM pyramid_competitions c
  JOIN (VALUES
    ('Mayflower Conference',      'Boston',       'Boston, Massachusetts',      ARRAY['25025']),
    ('Constitution Conference',   'Hartford',     'Hartford, Connecticut',      ARRAY['09003']),
    ('Delaware River Conference', 'Philadelphia', 'Philadelphia, Pennsylvania', ARRAY['42101']),
    ('Metropolitan Conference',   'New York',     'New York City, New York',    ARRAY['36005','36047','36061','36081','36085']),
    ('Mid-Atlantic Conference',   'Washington',   'Washington, District of Columbia', ARRAY['11001']),
    ('Mitten Conference',         'Detroit',      'Detroit, Michigan',          ARRAY['26163']),
    ('Terminus Conference',       'Atlanta',      'Atlanta, Georgia',           ARRAY['13121','13089']),
    ('Trinity Conference',        'Dallas',       'Dallas, Texas',              ARRAY['48113'])
  ) AS v(conf, city, q, core) ON v.conf = c.name AND c.kind = 'conference'
ON CONFLICT (competition_id) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', 'APSL pyramid — map HUD: city rings', 'apsl_pyramid', 'map_rings', NULL,
       '{city}: {city_n} in the city · {collar_n} in the collar counties · {far_n} further out', 155, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = 'map_rings');
