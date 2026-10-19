-- 608 (2026-10-19) — Carpool pickup plans: three timed options + private
-- "+X minutes" nudges, for games AND practices.
--
-- Owner: "carpool feature should show 3 options and the estimated time
-- based on google maps to leave and be on time with pickups etc. Option 1:
-- Goto Driver house at x time, option 2: driver does pickup at person
-- needing ride house. option 3: nuetral spot like lighthosue or elsewhere
-- for pickup. … it can even make suggestions on who is close to each other
-- based on address? but it not be publlic knowlege. it might say Carly is
-- requesting ride. it would take you an addditional x minutes to pick her
-- up for game" / "this should be for practices too!"
--
-- Times come from the stack the schedule-conflict checker already uses
-- (mig 526): OpenStreetMap Nominatim geocoding + the OSRM public router —
-- same real driving estimates, no Google key.  The arrival deadline is the
-- event's arrival_at (league matchday offsets); traffic factor and buffer
-- come from schedule_conflict_policies.  Addresses stay private: list
-- responses carry only derived minutes; the raw pickup address is shown
-- only to the requester, the accepted driver, and staff.
--
--   person_addresses.latitude/longitude — geocoded on demand (Nominatim,
--     cached on the row; a failure is noted and not re-asked).
--   carpool_spots — the neutral meeting places (option 3), DB rows.
--   carpool_drive_cache — OSRM leg cache keyed by rounded coordinates.
--   fh_carpool_requests.meet_* — the plan the driver picked on accept.

BEGIN;

ALTER TABLE person_addresses ADD COLUMN IF NOT EXISTS latitude  numeric(10,7);
ALTER TABLE person_addresses ADD COLUMN IF NOT EXISTS longitude numeric(10,7);
ALTER TABLE person_addresses ADD COLUMN IF NOT EXISTS geocoded_at timestamptz;
ALTER TABLE person_addresses ADD COLUMN IF NOT EXISTS geocode_note text;

CREATE TABLE IF NOT EXISTS carpool_spots (
    id         serial PRIMARY KEY,
    name       text NOT NULL,
    latitude   numeric(10,7) NOT NULL,
    longitude  numeric(10,7) NOT NULL,
    is_active  boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE carpool_spots IS
    'Neutral carpool meeting places (mig 608, option 3). Add rows by '
    'migration or admin tooling; the picker offers active ones nearest '
    'the route.';

-- Seed with Lighthouse: the home ground's already-geocoded event place.
INSERT INTO carpool_spots (name, latitude, longitude)
SELECT 'Lighthouse Field', ep.latitude, ep.longitude
  FROM event_places ep
 WHERE ep.latitude IS NOT NULL AND ep.location ILIKE '%lighthouse%'
   AND NOT EXISTS (SELECT 1 FROM carpool_spots)
 ORDER BY ep.id LIMIT 1;

CREATE TABLE IF NOT EXISTS carpool_drive_cache (
    from_lat   numeric(8,4) NOT NULL,   -- rounded to ~10 m; close enough
    from_lon   numeric(8,4) NOT NULL,   -- for leave-by-minute estimates
    to_lat     numeric(8,4) NOT NULL,
    to_lon     numeric(8,4) NOT NULL,
    minutes    numeric(6,1) NOT NULL,
    meters     integer,
    source     text NOT NULL DEFAULT 'osrm',
    fetched_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (from_lat, from_lon, to_lat, to_lon)
);

ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_kind text
    CHECK (meet_kind IN ('driver_home','rider_home','spot'));
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_spot_id integer REFERENCES carpool_spots(id);
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_leave_at timestamptz;   -- driver leaves home
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_pickup_at timestamptz;  -- rider is collected / both meet

-- The plan picker's and nudge's words (client_side, MessageCopy 'carpool').
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('carpool', 'nudge_extra', 'Carpool — driver nudge, extra minutes',
  '{name} is requesting a ride — picking them up adds about {minutes} min for you.', 20);
SELECT pg_temp.add_client_tpl('carpool', 'opt_driver_home', 'Carpool — option 1',
  '{rider} comes to the driver''s place — leave together by {leave}.', 21);
SELECT pg_temp.add_client_tpl('carpool', 'opt_rider_home', 'Carpool — option 2',
  'Driver picks {rider} up — leave by {leave}, pickup about {pickup} (+{minutes} min).', 22);
SELECT pg_temp.add_client_tpl('carpool', 'opt_spot', 'Carpool — option 3',
  'Meet at {spot} by {pickup} — driver leaves by {leave}.', 23);
SELECT pg_temp.add_client_tpl('carpool', 'pick_title', 'Carpool — option picker title',
  'How do you want to do the pickup?', 24);
SELECT pg_temp.add_client_tpl('carpool', 'no_geo', 'Carpool — times unavailable',
  'No drive-time estimate — an address is missing. The plan still works, just without times.', 25);
SELECT pg_temp.add_client_tpl('carpool', 'plan_line', 'Carpool — agreed plan on the card',
  '{plan}', 26);

COMMIT;
