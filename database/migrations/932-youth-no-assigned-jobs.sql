-- 932-youth-no-assigned-jobs.sql
--
-- Owner 11/2: "youth we tell the players what to clean up" — coaches
-- handle it on the night, so youth events get no assigned jobs, indoors
-- or outdoors.  From `since` on; earlier practices keep their history.

CREATE TABLE IF NOT EXISTS job_free_categories (
    category text PRIMARY KEY,
    since    timestamptz NOT NULL
);

INSERT INTO job_free_categories (category, since)
VALUES ('boys',  '2026-11-02 00:00:00-05'),
       ('girls', '2026-11-02 00:00:00-05')
ON CONFLICT (category) DO NOTHING;

CREATE OR REPLACE FUNCTION fh_event_has_jobs(p_event bigint) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT NOT EXISTS (
        SELECT 1
          FROM fh_events e
          JOIN gcal_events g ON g.id = e.gcal_event_id
          JOIN job_free_categories c ON c.category = e.category AND c.since <= g.starts_at
         WHERE e.id = p_event)
$$;

DELETE FROM job_assignments ja
 WHERE NOT fh_event_has_jobs(ja.fh_event_id);
