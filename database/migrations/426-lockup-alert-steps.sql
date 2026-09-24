-- 426 — Security: two-phase call cadence (owner 2026-09-24: "have it ring
-- every 10 minutes for 1st hour, then every 1 hour 30 times").
--
-- The flat facilities.lockup_repeat_minutes / lockup_max_alerts pair can
-- only say "every N min, M times", so the cadence becomes ordered steps
-- per facility: step 1 = every 10 min × 6 (the first hour), step 2 =
-- every 60 min × 30.  36 calls in all, spanning ~31 hours.
--
-- Semantics (fh_lockup_wait_minutes): alert #1 fires at the deadline; the
-- gap AFTER alert #k is the repeat_minutes of the step that alert #k
-- belongs to.  So calls land at +0, +10, +20, +30, +40, +50, then +60,
-- +120, … (the 7th call is the first hourly one).

CREATE TABLE IF NOT EXISTS facility_lockup_alert_steps (
  id             SERIAL PRIMARY KEY,
  facility_id    INT  NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  step_no        INT  NOT NULL,
  repeat_minutes INT  NOT NULL CHECK (repeat_minutes > 0),
  times          INT  NOT NULL CHECK (times > 0),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (facility_id, step_no)
);
COMMENT ON TABLE facility_lockup_alert_steps IS
  'Ordered call cadence after the lock-up deadline: step_no → ring every repeat_minutes, times times (mig 426)';

INSERT INTO facility_lockup_alert_steps (facility_id, step_no, repeat_minutes, times)
SELECT f.id, s.step_no, s.repeat_minutes, s.times
  FROM facilities f, (VALUES (1, 10, 6), (2, 60, 30)) AS s(step_no, repeat_minutes, times)
 WHERE f.name IN ('Lighthouse Sport Complex', 'Lighthouse Community Center')
ON CONFLICT (facility_id, step_no) DO UPDATE
   SET repeat_minutes = EXCLUDED.repeat_minutes, times = EXCLUDED.times;

-- Total calls for the night before it gives up.
CREATE OR REPLACE FUNCTION fh_lockup_max_alerts(p_facility_id int)
RETURNS int LANGUAGE sql STABLE AS $$
  SELECT COALESCE(SUM(times), 0)::int FROM facility_lockup_alert_steps WHERE facility_id = p_facility_id
$$;

-- Minutes to wait after alert #p_alert_no before the next one.  Past the
-- last step (or before the first alert) it returns the last step's gap so
-- copy like "I will call again in N minutes" never reads "in  minutes".
CREATE OR REPLACE FUNCTION fh_lockup_wait_minutes(p_facility_id int, p_alert_no int)
RETURNS int LANGUAGE sql STABLE AS $$
  WITH s AS (
    SELECT repeat_minutes, SUM(times) OVER (ORDER BY step_no) AS upto
      FROM facility_lockup_alert_steps WHERE facility_id = p_facility_id
  )
  SELECT COALESCE(
    (SELECT repeat_minutes FROM s WHERE upto >= GREATEST(p_alert_no, 1) ORDER BY upto LIMIT 1),
    (SELECT repeat_minutes FROM s ORDER BY upto DESC LIMIT 1),
    0)
$$;

-- Human words for the board and the alert email, built from the rows:
-- "every 10 min for the first 6 calls, then every hour (30 more)".
CREATE OR REPLACE FUNCTION fh_lockup_cadence_text(p_facility_id int)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT string_agg(
           CASE WHEN step_no = 1
                THEN 'every ' || CASE WHEN repeat_minutes = 60 THEN 'hour' ELSE repeat_minutes || ' min' END
                     || ' for the first ' || times || ' calls'
                ELSE 'then every ' || CASE WHEN repeat_minutes = 60 THEN 'hour' ELSE repeat_minutes || ' min' END
                     || ' (' || times || ' more)'
           END, ', ' ORDER BY step_no)
    FROM facility_lockup_alert_steps WHERE facility_id = p_facility_id
$$;

-- One source of truth: the steps table.
ALTER TABLE facilities DROP COLUMN IF EXISTS lockup_repeat_minutes;
ALTER TABLE facilities DROP COLUMN IF EXISTS lockup_max_alerts;

-- Copy: the email describes the cadence in words; the call says when the
-- next ring comes ({repeat_minutes} = minutes until the NEXT call).
UPDATE message_templates
   SET body = replace(body, 'will keep calling every {repeat_minutes} minutes until one is up.',
                            'will keep calling ({cadence}) until one is up.'),
       updated_at = now()
 WHERE kind = 'lockup' AND tier = 'alert_email';
