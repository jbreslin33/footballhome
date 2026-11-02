-- 920 (2026-10-31) — #apsl-pyramid: Maryland Major Soccer League gets its tables.
--
-- Mig 819 left MMSL without a source (no public tables found).  The league's
-- own /page/show/3301803-standings is a 2022 widget, but its Fall 2026 season
-- is a SportsEngine season (marylandmajorsoccer.com/page/show/9675532 →
-- tab_schedule's program id): two tables, Baltimore Metro and Capital
-- Beltway, read by the 'sportsengine' reader like CASA.  The program id
-- changes each season.
--
-- Links: both tables feed the Mid-Atlantic Conference, side by side.
--
-- The feed spells one table "Captial Beltway", with a trailing space on both.
-- pyramid_division_names keeps the FH spelling; a trigger applies it on every
-- load, and any other name just loses its stray spaces.

BEGIN;

CREATE TABLE IF NOT EXISTS pyramid_division_names (
    source_id integer NOT NULL REFERENCES pyramid_sources(id) ON DELETE CASCADE,
    feed_name text    NOT NULL,
    name      text    NOT NULL,
    PRIMARY KEY (source_id, feed_name)
);

CREATE OR REPLACE FUNCTION fh_pyramid_division_name() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.name := coalesce((SELECT n.name FROM pyramid_division_names n
                         WHERE n.source_id = NEW.source_id AND n.feed_name = btrim(NEW.name)),
                       btrim(NEW.name));
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS pyramid_division_name ON pyramid_divisions;
CREATE TRIGGER pyramid_division_name BEFORE INSERT OR UPDATE OF name ON pyramid_divisions
  FOR EACH ROW EXECUTE FUNCTION fh_pyramid_division_name();

INSERT INTO pyramid_sources (competition_id, system, locator)
SELECT c.id, 'sportsengine', '6a3b0a5c58e6f804d7e1783b'
  FROM pyramid_competitions c
 WHERE c.name = 'Maryland Major Soccer League'
ON CONFLICT (system, locator) DO NOTHING;

INSERT INTO pyramid_division_names (source_id, feed_name, name)
SELECT s.id, 'Captial Beltway', 'Capital Beltway'
  FROM pyramid_sources s
 WHERE s.system = 'sportsengine' AND s.locator = '6a3b0a5c58e6f804d7e1783b'
ON CONFLICT DO NOTHING;

INSERT INTO pyramid_links (lower_source_id, lower_division, upper_competition_id)
SELECT s.id, v.division, c.id
  FROM pyramid_sources s,
       (VALUES ('Baltimore Metro'), ('Capital Beltway')) AS v(division),
       pyramid_competitions c
 WHERE s.system = 'sportsengine' AND s.locator = '6a3b0a5c58e6f804d7e1783b'
   AND c.kind = 'conference' AND c.name = 'Mid-Atlantic Conference'
ON CONFLICT DO NOTHING;

COMMIT;
