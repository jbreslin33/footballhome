-- 1630 (2026-11-20) — Spots inside a facility; the Sport Court's jobs.
--
-- Owner 11/20: "sport court is put away nets, put away balls in bag, put
-- spare pinnies in bag. clean up trash. thats it"
--
-- The Sport Court is part of the Lighthouse Sport Complex (same address,
-- same gate lock-up), so it is a SPOT of facility 1, not a facility:
--
--   facility_spots        a named area of a facility, recognised by a
--                         pattern on the calendar title ("Soccer Sport
--                         Court Practice …")
--   fh_events.spot_id     filled from the title (fh_spot_for), kept current
--                         when the title or the facility changes
--   job_definitions.spot_id   a spot's own set; NULL = the facility's main
--                         area (the Sport Complex field set: cones … generator)
--
-- fh_event_job_def_ids (mig 1628) now matches facility AND spot.

BEGIN;

CREATE TABLE facility_spots (
    id            serial PRIMARY KEY,
    facility_id   integer NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
    name          text NOT NULL,
    title_pattern text NOT NULL,          -- case-insensitive regex on gcal_events.summary
    UNIQUE (facility_id, name)
);
COMMENT ON TABLE facility_spots IS
  'A named area of a facility (Sport Court), matched on the calendar title; mig 1630.';

INSERT INTO facility_spots (facility_id, name, title_pattern)
VALUES (1, 'Sport Court', '\msport\s*court\M');

ALTER TABLE fh_events ADD COLUMN spot_id integer REFERENCES facility_spots(id) ON DELETE SET NULL;
ALTER TABLE job_definitions ADD COLUMN spot_id integer REFERENCES facility_spots(id) ON DELETE CASCADE;

CREATE FUNCTION fh_spot_for(p_facility integer, p_title text) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT s.id FROM facility_spots s
     WHERE s.facility_id = p_facility AND COALESCE(p_title, '') ~* s.title_pattern
     ORDER BY s.id LIMIT 1
$$;

-- fh_events: after the facility is filled (fh_events_fill_facility runs
-- first — triggers fire by name), set the spot.
CREATE FUNCTION fh_events_fill_spot() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  SELECT fh_spot_for(NEW.facility_id, g.summary) INTO NEW.spot_id
    FROM gcal_events g WHERE g.id = NEW.gcal_event_id;
  RETURN NEW;
END $$;
CREATE TRIGGER fh_events_fill_spot BEFORE INSERT OR UPDATE OF gcal_event_id, facility_id ON fh_events
    FOR EACH ROW EXECUTE FUNCTION fh_events_fill_spot();

-- A renamed calendar event moves spots.
CREATE FUNCTION gcal_events_refresh_spot() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  UPDATE fh_events SET spot_id = fh_spot_for(facility_id, NEW.summary), updated_at = now()
   WHERE gcal_event_id = NEW.id
     AND spot_id IS DISTINCT FROM fh_spot_for(facility_id, NEW.summary);
  RETURN NULL;
END $$;
CREATE TRIGGER gcal_events_refresh_spot AFTER UPDATE OF summary ON gcal_events
    FOR EACH ROW EXECUTE FUNCTION gcal_events_refresh_spot();

UPDATE fh_events e SET spot_id = fh_spot_for(e.facility_id, g.summary)
  FROM gcal_events g
 WHERE g.id = e.gcal_event_id AND fh_spot_for(e.facility_id, g.summary) IS NOT NULL;

INSERT INTO job_definitions (event_kind, slug, title, description, needed_count, facility_id, spot_id, sort_order)
SELECT 'practice', v.slug, v.title, v.description, 1, 1, s.id, v.sort
  FROM facility_spots s,
       (VALUES ('nets-away',   'Put nets away',    'Put the nets away after practice.', 21),
               ('balls-bag',   'Balls in bag',     'Put the balls away in the bag.', 22),
               ('pinnies-bag', 'Pinnies in bag',   'Put the spare pinnies in the bag.', 23),
               ('trash',       'Clean up trash',   'Clean up the trash after practice.', 24)) AS v(slug, title, description, sort)
 WHERE s.name = 'Sport Court';

DROP INDEX job_definitions_set_slug;
CREATE UNIQUE INDEX job_definitions_set_slug ON job_definitions
    (event_kind, COALESCE(league_label, ''), COALESCE(facility_id, 0), COALESCE(spot_id, 0), COALESCE(venue, ''), slug);

CREATE OR REPLACE FUNCTION fh_event_job_def_ids(p_event bigint) RETURNS SETOF integer
LANGUAGE sql STABLE AS $$
    SELECT d.id
      FROM fh_events e
      JOIN job_definitions d ON d.event_kind = e.kind
     WHERE e.id = p_event
       AND d.is_active
       AND fh_event_has_jobs(e.id)
       AND (d.league_label IS NULL OR d.league_label = COALESCE(e.league, ''))
       AND (d.facility_id IS NULL OR (d.facility_id = e.facility_id AND d.spot_id IS NOT DISTINCT FROM e.spot_id))
       AND (d.venue IS NULL OR d.venue = CASE e.is_home WHEN true THEN 'home' WHEN false THEN 'away' END)
$$;
COMMENT ON FUNCTION fh_event_job_def_ids(bigint) IS
  'The job definitions an event gets: kind + league + facility + spot + home/away (migs 1628, 1630).';

-- Upcoming Sport Court practices drop the field jobs.
DELETE FROM job_assignments ja
 USING fh_events e, gcal_events g
 WHERE e.id = ja.fh_event_id AND g.id = e.gcal_event_id AND g.starts_at > now()
   AND ja.job_definition_id NOT IN (SELECT fh_event_job_def_ids(e.id));

COMMIT;
