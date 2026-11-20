-- 1631 (2026-11-20) — Lights + generator jobs only when practice runs past dusk.
--
-- Owner 11/20: "for field it depends on time of practice if we need to deal
-- with lights and generators. so check wiht daylight philadlephaia and if
-- twilight we can play wo lights and gen till end. if not we need them in
-- jobs"
--
--   facilities.latitude / longitude   where the sun is reckoned from
--   fh_civil_dusk(day, lat, lon)      end of civil twilight (sun 6° below
--                                     the horizon) — still playable light
--                                     until then.  NOAA / Almanac for
--                                     Computers sunrise-sunset algorithm,
--                                     zenith 96°; good to a minute or two.
--   job_definitions.after_dark        the job exists only when the event ends
--                                     after that day's civil dusk
--   fh_event_after_dark(event)        end (fh_events.end_at, else the gcal end)
--                                     > civil dusk at its facility
--
-- Lights — take-down, Lights — to shed, Generator are after_dark.

BEGIN;

ALTER TABLE facilities ADD COLUMN latitude  double precision,
                       ADD COLUMN longitude double precision;
UPDATE facilities SET latitude = 40.0063, longitude = -75.1268 WHERE id = 1;   -- 101-199 E Erie Ave
UPDATE facilities SET latitude = 39.9937, longitude = -75.1336 WHERE id = 2;   -- 141 W Somerset St

CREATE FUNCTION fh_civil_dusk(p_day date, p_lat double precision, p_lon double precision)
RETURNS timestamptz LANGUAGE plpgsql IMMUTABLE AS $$
DECLARE
  n int := extract(doy FROM p_day);
  lng_hour double precision := p_lon / 15;
  t double precision := n + ((18 - lng_hour) / 24);
  m double precision := 0.9856 * t - 3.289;
  l double precision;
  ra double precision;
  sin_dec double precision;
  cos_dec double precision;
  cos_h double precision;
  ut double precision;
BEGIN
  l := m + 1.916 * sind(m) + 0.020 * sind(2 * m) + 282.634;
  l := l - 360 * floor(l / 360);
  ra := atand(0.91764 * tand(l));
  ra := ra - 360 * floor(ra / 360);
  ra := (ra + floor(l / 90) * 90 - floor(ra / 90) * 90) / 15;
  sin_dec := 0.39782 * sind(l);
  cos_dec := cosd(asind(sin_dec));
  cos_h := (cosd(96) - sin_dec * sind(p_lat)) / (cos_dec * cosd(p_lat));
  IF cos_h < -1 OR cos_h > 1 THEN RETURN NULL; END IF;   -- never that dark / never that light
  ut := acosd(cos_h) / 15 + ra - 0.06571 * t - 6.622 - lng_hour;
  ut := ut - 24 * floor(ut / 24);
  RETURN (p_day::timestamp AT TIME ZONE 'UTC') + make_interval(secs => ut * 3600)
         -- an evening dusk in UTC lands after midnight UTC for US Eastern
         + CASE WHEN ut < 12 THEN interval '1 day' ELSE interval '0' END;
END $$;
COMMENT ON FUNCTION fh_civil_dusk(date, double precision, double precision) IS
  'End of civil twilight (zenith 96°) on a local day, as timestamptz; mig 1631.';

CREATE FUNCTION fh_event_after_dark(p_event bigint) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(e.end_at, g.ends_at)
           > fh_civil_dusk((g.starts_at AT TIME ZONE 'America/New_York')::date,
                           COALESCE(f.latitude, 39.9526), COALESCE(f.longitude, -75.1652))
      FROM fh_events e
      JOIN gcal_events g ON g.id = e.gcal_event_id
      LEFT JOIN facilities f ON f.id = e.facility_id
     WHERE e.id = p_event
$$;

ALTER TABLE job_definitions ADD COLUMN after_dark boolean NOT NULL DEFAULT false;
UPDATE job_definitions SET after_dark = true
 WHERE event_kind = 'practice' AND facility_id = 1 AND spot_id IS NULL
   AND slug IN ('lights', 'lights-shed', 'generator');

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
       AND (NOT d.after_dark OR fh_event_after_dark(e.id))
$$;
COMMENT ON FUNCTION fh_event_job_def_ids(bigint) IS
  'The job definitions an event gets: kind + league + facility + spot + home/away + after dark (migs 1628, 1630, 1631).';

DELETE FROM job_assignments ja
 USING fh_events e, gcal_events g
 WHERE e.id = ja.fh_event_id AND g.id = e.gcal_event_id AND g.starts_at > now()
   AND ja.job_definition_id NOT IN (SELECT fh_event_job_def_ids(e.id));

COMMIT;
