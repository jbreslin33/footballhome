-- 865 (2026-10-29) — #apsl-pyramid: league tables refresh once a week.
--
-- Owner 2026-10-29: "every hour? would that get us blocked lol. once a
-- week lol would work right? … 1x per week on mondays right? if we don't
-- get them all then try again tuesday?"
--
-- Until now every source was re-read whenever the page opened and its copy
-- was an hour old (max_age_minutes 60) — APSL's whole-league feed, CASA's
-- four SportsEngine seasons, ADASL, LISFL … all hourly.  Now:
--
-- pyramid_refresh_policy (one row): the week starts on week_start_dow (ISO,
--   1 = Monday) in policy_tz; a source gets attempts_per_week tries a week,
--   at most one a day.
-- fh_pyramid_source_due(id): no good read since this week began, and
--   either no try yet this week or (a try left and none today).  So the
--   first try is Monday (or the first page open after it); a failure tries
--   again the next day (Tuesday); then it waits for next Monday.
-- pyramid_sources.week_of / week_tries: counted by a trigger whenever
--   last_fetched_at moves, so the backend (PyramidSync) and the browser
--   script (pyramid-chrome-sync.js, timer Mon + Tue) both count.
-- ?refresh=1 / --all still force a read.

CREATE TABLE IF NOT EXISTS pyramid_refresh_policy (
    id                integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    week_start_dow    integer NOT NULL DEFAULT 1 CHECK (week_start_dow BETWEEN 1 AND 7),
    attempts_per_week integer NOT NULL DEFAULT 2 CHECK (attempts_per_week >= 1),
    policy_tz         text    NOT NULL DEFAULT 'America/New_York'
);
INSERT INTO pyramid_refresh_policy (id) VALUES (1) ON CONFLICT DO NOTHING;

-- The local date the week containing p_at began.
CREATE OR REPLACE FUNCTION fh_pyramid_week_of(p_at timestamptz) RETURNS date
LANGUAGE sql STABLE AS $$
  SELECT d - ((extract(isodow FROM d)::int - p.week_start_dow + 7) % 7)
    FROM pyramid_refresh_policy p,
         LATERAL (SELECT (p_at AT TIME ZONE p.policy_tz)::date AS d) x
$$;

ALTER TABLE pyramid_sources ADD COLUMN IF NOT EXISTS week_of    date;
ALTER TABLE pyramid_sources ADD COLUMN IF NOT EXISTS week_tries integer NOT NULL DEFAULT 0;

CREATE OR REPLACE FUNCTION fh_pyramid_count_try() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_week date := fh_pyramid_week_of(NEW.last_fetched_at);
BEGIN
  IF NEW.week_of IS DISTINCT FROM v_week THEN
    NEW.week_of := v_week;
    NEW.week_tries := 1;
  ELSE
    NEW.week_tries := OLD.week_tries + 1;
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_pyramid_count_try ON pyramid_sources;
CREATE TRIGGER trg_pyramid_count_try
  BEFORE UPDATE OF last_fetched_at ON pyramid_sources
  FOR EACH ROW
  WHEN (NEW.last_fetched_at IS NOT NULL AND NEW.last_fetched_at IS DISTINCT FROM OLD.last_fetched_at)
  EXECUTE FUNCTION fh_pyramid_count_try();

CREATE OR REPLACE FUNCTION fh_pyramid_source_due(p_id integer) RETURNS boolean
LANGUAGE sql STABLE AS $$
  SELECT s.is_active
     AND (s.last_ok_at IS NULL OR s.last_ok_at < (fh_pyramid_week_of(now())::timestamp AT TIME ZONE p.policy_tz))
     AND (s.week_of IS DISTINCT FROM fh_pyramid_week_of(now())
          OR (s.week_tries < p.attempts_per_week
              AND (s.last_fetched_at AT TIME ZONE p.policy_tz)::date < (now() AT TIME ZONE p.policy_tz)::date))
    FROM pyramid_sources s, pyramid_refresh_policy p
   WHERE s.id = p_id
$$;

-- Today's reads count as this week's first try.
UPDATE pyramid_sources
   SET week_of = fh_pyramid_week_of(last_fetched_at), week_tries = 1
 WHERE last_fetched_at IS NOT NULL;

ALTER TABLE pyramid_sources DROP COLUMN IF EXISTS max_age_minutes;
