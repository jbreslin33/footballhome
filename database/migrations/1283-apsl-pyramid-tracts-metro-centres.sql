-- 1283 (2026-11-11) — #apsl-pyramid: Census tracts loaded; every conference
-- measured from its metro area's centre of population, not a landmark.
--
-- Owner 2026-11-11: "keep splits" / "yes get more census data" / "its not
-- city as center of mass it should be center of mass of pop of metro area
-- right?" / "for all points for borders and then scale out time of travel
-- with traffic in congested traffic areas and reg drive time".
--
-- * pyramid_tracts: every 2023 Census tract — its internal point (2023
--   Gazetteer) and people (ACS 2019-23 5-year, table B01003), loaded by
--   scripts/pyramid-load-tracts.py (Connecticut's planning-region tracts are
--   placed in our 8 old counties by their point).  A county the traced
--   border splits counts each tract's people on its own side.
-- * pyramid_metro_pop_centers: each metro area's population-weighted centre.
-- * pyramid_region_centers: a live conference is measured from its main
--   city's metro centre of population (New York's lands near the Hudson —
--   was Times Square), a proposal from its base city's metro centre; a
--   place with no metro area keeps its city point.  Traffic factor
--   unchanged: drive × factor where congested (New York 1.25), plain drive
--   elsewhere.
-- Pipeline: pyramid-load-tracts.py (once) → pyramid-county-drive.py →
-- refresh → pyramid-fine-borders.py → pyramid-sea-borders.py → pyramid-drive-times.py.

CREATE TABLE IF NOT EXISTS pyramid_tracts (
    geoid       text PRIMARY KEY,
    county_fips char(5) NOT NULL REFERENCES pyramid_counties(fips),
    lat         numeric(10,7) NOT NULL,
    lon         numeric(10,7) NOT NULL,
    population  int NOT NULL
);
CREATE INDEX IF NOT EXISTS pyramid_tracts_county ON pyramid_tracts (county_fips);
COMMENT ON TABLE pyramid_tracts IS
    'mig 1283: 2023 Census tracts — internal point (Gazetteer) + people (ACS 2019-23 B01003); scripts/pyramid-load-tracts.py.';

CREATE OR REPLACE VIEW pyramid_metro_pop_centers AS
SELECT mc.cbsa_code,
       sum(t.lat * t.population) / NULLIF(sum(t.population), 0) AS lat,
       sum(t.lon * t.population) / NULLIF(sum(t.population), 0) AS lon,
       sum(t.population) AS population
  FROM pyramid_tracts t
  JOIN pyramid_metro_counties mc ON mc.fips = t.county_fips
 GROUP BY mc.cbsa_code;
COMMENT ON VIEW pyramid_metro_pop_centers IS
    'mig 1283: each metro/micro area''s population-weighted centre (from tracts).';

CREATE OR REPLACE VIEW pyramid_region_centers AS
SELECT m.competition_id AS conference_id, NULL::int AS proposed_id,
       COALESCE(pc.lat, m.center_lat)::numeric(10,7) AS lat, COALESCE(pc.lon, m.center_lon)::numeric(10,7) AS lon,
       m.traffic_factor AS factor, 'current'::text AS plan
  FROM pyramid_main_cities m
  JOIN pyramid_competitions c ON c.id = m.competition_id AND c.kind = 'conference' AND c.is_active
  LEFT JOIN pyramid_metro_counties mc ON mc.fips = m.core_fips[1]
  LEFT JOIN pyramid_metro_areas ma ON ma.cbsa_code = mc.cbsa_code AND ma.kind = 'metro'
  LEFT JOIN pyramid_metro_pop_centers pc ON pc.cbsa_code = ma.cbsa_code
 WHERE m.center_lat IS NOT NULL
UNION ALL
SELECT NULL, a.proposed_id, COALESCE(pc.lat, a.center_lat, k.lat)::numeric(10,7), COALESCE(pc.lon, a.center_lon, k.lon)::numeric(10,7), p.traffic_factor, 'proposed'
  FROM pyramid_proposed_anchors a
  JOIN pyramid_proposed_conferences p ON p.id = a.proposed_id
  JOIN pyramid_counties k ON k.fips = a.fips
  LEFT JOIN pyramid_metro_counties mc ON mc.fips = a.fips
  LEFT JOIN pyramid_metro_areas ma ON ma.cbsa_code = mc.cbsa_code AND ma.kind = 'metro'
  LEFT JOIN pyramid_metro_pop_centers pc ON pc.cbsa_code = ma.cbsa_code
 WHERE a.is_base;
COMMENT ON VIEW pyramid_region_centers IS
    'mig 1283: where each conference is measured from — its (base) city''s metro centre of population; traffic factor per city.';

ALTER TABLE pyramid_proposal_region_stats ADD COLUMN IF NOT EXISTS tract_population bigint;
COMMENT ON COLUMN pyramid_proposal_region_stats.tract_population IS
    'mig 1283: people counted tract by tract on each side of the traced border (scripts/pyramid-fine-borders.py); population = whole counties.';

UPDATE message_templates SET body = 'Two lines in the same colours: the one nearer New York is the shortest drive with traffic (New York ×1.25), the other the shortest drive without — each from the metro area''s centre of population. Shaded between: neutral zone.', updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_lines';
