-- 862 (2026-10-29) — #apsl-pyramid: CASA Massachusetts gets its tables.
--
-- Mig 819 left CASA MA without a source ("programs not found yet").  Its
-- league is the SportsEngine season "Open 11v11 Divisions Fall 2026"
-- (casasoccerleagues.com/page/show/9560678 → tab_schedule's program id):
-- five tables, 1 Primera … 5 Quinta, read by the 'sportsengine' reader
-- like the CASA Select regions.  The program id changes each season.
--
-- Links: Primera feeds the Mayflower Conference; each table below feeds
-- the one above it.

INSERT INTO pyramid_sources (competition_id, system, locator)
SELECT c.id, 'sportsengine', '6a5a89b1bc857e8a118dfcc0'
  FROM pyramid_competitions c
 WHERE c.name = 'Casa League of Massachusetts'
ON CONFLICT (system, locator) DO NOTHING;

WITH ma AS (
    SELECT s.id FROM pyramid_sources s
     WHERE s.system = 'sportsengine' AND s.locator = '6a5a89b1bc857e8a118dfcc0')
INSERT INTO pyramid_links (lower_source_id, lower_division, upper_competition_id)
SELECT ma.id, '1 Primera', c.id
  FROM ma, pyramid_competitions c
 WHERE c.kind = 'conference' AND c.name = 'Mayflower Conference'
ON CONFLICT DO NOTHING;

WITH ma AS (
    SELECT s.id FROM pyramid_sources s
     WHERE s.system = 'sportsengine' AND s.locator = '6a5a89b1bc857e8a118dfcc0')
INSERT INTO pyramid_links (lower_source_id, lower_division, upper_source_id, upper_division)
SELECT ma.id, v.lower, ma.id, v.upper
  FROM ma, (VALUES ('2 Segunda', '1 Primera'),
                   ('3 Tercera', '2 Segunda'),
                   ('4 Cuarta',  '3 Tercera'),
                   ('5 Quinta',  '4 Cuarta')) AS v(lower, upper)
ON CONFLICT DO NOTHING;
