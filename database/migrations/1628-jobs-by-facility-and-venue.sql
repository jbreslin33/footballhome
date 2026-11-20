-- 1628 (2026-11-20) — Jobs follow WHERE: practice jobs by facility, game
-- jobs by home / away.
--
-- Owner 11/20: "lets fix jobs. they depend on where practice is. games
-- depend on home or away and apsl or liga 1." … "so for 141 somerset its
-- futsal. so its clean up bottles, cups etc. put goals back on stage.
-- close and lock windows. put balls back in bag and then on stage. put
-- spare pinnies back in bag and then on stage"
--
--   job_definitions.facility_id   the practice's place (facilities); NULL = anywhere
--   job_definitions.venue         'home' / 'away' for a game (fh_events.is_home); NULL = both
--   fh_event_job_def_ids(event)   THE rule — which definitions an event gets
--                                 (kind + league + facility + venue, active,
--                                 not a job-free category).  JobsController
--                                 and the #my card read only this.
--
-- The indoor / outdoor split (mig 931, job_definitions.setting) is gone from
-- jobs: the Sport Complex field set is facility 1's, Somerset (facility 2,
-- futsal) gets its own set.  fh_event_job_setting stays — the practice
-- card's Indoor / Outdoor pitch (mig 1355) still reads it.
-- Somerset rows reuse the old indoor ids where the job carries over (balls,
-- clean-up, goals) so the 🏠 job homes stay; "Put nets out" is dropped.

BEGIN;

ALTER TABLE job_definitions
    ADD COLUMN IF NOT EXISTS facility_id integer REFERENCES facilities(id) ON DELETE CASCADE,
    ADD COLUMN IF NOT EXISTS venue text CHECK (venue IN ('home', 'away'));

-- Sport Complex field practice: the outdoor set (cones … generator).
UPDATE job_definitions SET facility_id = 1
 WHERE event_kind = 'practice' AND setting = 'outdoor';

-- Somerset futsal.
UPDATE job_definitions SET facility_id = 2, slug = 'cleanup', title = 'Clean up',
       description = 'Clean up the bottles, cups and trash after practice.', needed_count = 1, sort_order = 11
 WHERE id = 21;
UPDATE job_definitions SET facility_id = 2, slug = 'goals-stage', title = 'Goals to stage',
       description = 'Put the goals back on the stage.', needed_count = 2, sort_order = 12
 WHERE id = 19;
UPDATE job_definitions SET facility_id = 2, slug = 'balls-stage', title = 'Balls to stage',
       description = 'Put the balls back in the bag, then the bag on the stage.', needed_count = 1, sort_order = 14
 WHERE id = 20;
DELETE FROM job_definitions WHERE id = 18;   -- Put nets out

INSERT INTO job_definitions (event_kind, slug, title, description, needed_count, facility_id, sort_order) VALUES
    ('practice', 'windows', 'Windows', 'Close and lock the windows.', 1, 2, 13),
    ('practice', 'pinnies-stage', 'Pinnies to stage', 'Put the spare pinnies back in the bag, then the bag on the stage.', 1, 2, 15);

ALTER TABLE job_definitions DROP COLUMN setting;

DROP INDEX IF EXISTS job_definitions_set_slug;
CREATE UNIQUE INDEX job_definitions_set_slug ON job_definitions
    (event_kind, COALESCE(league_label, ''), COALESCE(facility_id, 0), COALESCE(venue, ''), slug);

CREATE OR REPLACE FUNCTION fh_event_job_def_ids(p_event bigint) RETURNS SETOF integer
LANGUAGE sql STABLE AS $$
    SELECT d.id
      FROM fh_events e
      JOIN job_definitions d ON d.event_kind = e.kind
     WHERE e.id = p_event
       AND d.is_active
       AND fh_event_has_jobs(e.id)
       AND (d.league_label IS NULL OR d.league_label = COALESCE(e.league, ''))
       AND (d.facility_id IS NULL OR d.facility_id = e.facility_id)
       AND (d.venue IS NULL OR d.venue = CASE e.is_home WHEN true THEN 'home' WHEN false THEN 'away' END)
$$;
COMMENT ON FUNCTION fh_event_job_def_ids(bigint) IS
  'The job definitions an event gets: kind + league + facility + home/away (mig 1628).';

-- Upcoming events drop jobs that no longer belong to them (the next open
-- or RSVP refills from the right set).
DELETE FROM job_assignments ja
 USING fh_events e, gcal_events g
 WHERE e.id = ja.fh_event_id AND g.id = e.gcal_event_id AND g.starts_at > now()
   AND ja.job_definition_id NOT IN (SELECT fh_event_job_def_ids(e.id));

COMMIT;
