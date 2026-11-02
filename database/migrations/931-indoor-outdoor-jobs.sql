-- 931-indoor-outdoor-jobs.sql
--
-- Owner 11/2: jobs break down by indoor / outdoor.  Indoor: put nets out,
-- put nets away, put balls away, clean up bench.  The six practice jobs
-- from mig 625 (lights, generator, shed) become the outdoor set.
--
-- An event is indoor when its facility has indoor_jobs_from and the event
-- starts on or after it, so earlier practices keep the jobs they really
-- had.  APSL game jobs stay setting NULL = any.

ALTER TABLE facilities ADD COLUMN IF NOT EXISTS indoor_jobs_from timestamptz;

ALTER TABLE job_definitions ADD COLUMN IF NOT EXISTS setting text
    CHECK (setting IN ('indoor', 'outdoor'));

UPDATE facilities SET indoor_jobs_from = '2026-11-02 00:00:00-05'
 WHERE name = 'Lighthouse Community Center';

UPDATE job_definitions SET setting = 'outdoor'
 WHERE event_kind = 'practice' AND league_label IS NULL;

INSERT INTO job_definitions (event_kind, slug, title, description, needed_count, setting, sort_order)
VALUES
    ('practice', 'nets-out',   'Put nets out',   'Put the nets out before practice.',  1, 'indoor', 11),
    ('practice', 'nets-away',  'Put nets away',  'Put the nets away after practice.',  1, 'indoor', 12),
    ('practice', 'balls-away', 'Put balls away', 'Put the balls away after practice.', 1, 'indoor', 13),
    ('practice', 'bench',      'Clean up bench', 'Clean up the bench after practice.', 1, 'indoor', 14);

CREATE OR REPLACE FUNCTION fh_event_job_setting(p_event bigint) RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN f.indoor_jobs_from <= g.starts_at THEN 'indoor' ELSE 'outdoor' END
      FROM fh_events e
      JOIN gcal_events g ON g.id = e.gcal_event_id
      LEFT JOIN facilities f ON f.id = e.facility_id
     WHERE e.id = p_event
$$;

-- Upcoming indoor practices drop the outdoor jobs already handed out.
DELETE FROM job_assignments ja
 USING job_definitions d
 WHERE d.id = ja.job_definition_id
   AND d.setting IS NOT NULL
   AND d.setting <> fh_event_job_setting(ja.fh_event_id);
