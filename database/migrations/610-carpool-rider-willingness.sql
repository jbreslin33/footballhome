-- 610 (2026-10-19) — Carpool: the rider says what they're willing to do;
-- the driver picks ONE of those.
--
-- Owner: "why am i seeing ride request for everyone lol. it should be
-- personalized for each user right? so if i am Andy Hizdri i can click
-- button request ride. then have option to set what i am willing to do.
-- get pickedup only, go to person driving house, get picked up at
-- lighthouse field, get picked up at an agreed upon neutral site (which
-- you should help calculate and give address)" / "the person that accepts
-- to drive him can select which one he will do. That shuold be single
-- selection. whereas andy wuold select multi."
--
--   willing_* on the request — the rider's multi-select (mig 608's three
--     kinds plus 'midpoint': a neutral point computed between the two
--     homes and reverse-geocoded to a street address).
--   meet_kind gains 'midpoint'; meet_lat/lon/address pin the agreed spot.
--   carpool_revgeo_cache — Nominatim reverse-geocode cache (same polite
--     usage as the forward cache on person_addresses).

BEGIN;

ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS willing_rider_home  boolean NOT NULL DEFAULT true;
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS willing_driver_home boolean NOT NULL DEFAULT false;
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS willing_spot        boolean NOT NULL DEFAULT false;
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS willing_midpoint    boolean NOT NULL DEFAULT false;

-- Requests from before this migration carried no preference — treat them
-- as open to everything, which is what mig 608's picker offered.
UPDATE fh_carpool_requests
   SET willing_driver_home = true, willing_spot = true, willing_midpoint = true
 WHERE created_at < now() - interval '1 minute';

ALTER TABLE fh_carpool_requests DROP CONSTRAINT IF EXISTS fh_carpool_requests_meet_kind_check;
ALTER TABLE fh_carpool_requests ADD CONSTRAINT fh_carpool_requests_meet_kind_check
    CHECK (meet_kind IN ('driver_home','rider_home','spot','midpoint'));

-- The agreed meeting point, pinned at accept (midpoint moves if homes
-- change; the plan the two people agreed to must not).
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_lat     numeric(10,7);
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_lon     numeric(10,7);
ALTER TABLE fh_carpool_requests ADD COLUMN IF NOT EXISTS meet_address text;

CREATE TABLE IF NOT EXISTS carpool_revgeo_cache (
    lat        numeric(8,4) NOT NULL,   -- rounded like carpool_drive_cache
    lon        numeric(8,4) NOT NULL,
    address    text NOT NULL,           -- '' = asked, no answer; don't re-ask
    fetched_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (lat, lon)
);

-- Wording (client_side MessageCopy kind 'carpool'), same helper shape as 608.
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('carpool', 'request_mine', 'Carpool — my own request button',
  '🚗 Request a ride', 30);
SELECT pg_temp.add_client_tpl('carpool', 'request_kid', 'Carpool — request for own child',
  '🚗 Request a ride for {name}', 31);
SELECT pg_temp.add_client_tpl('carpool', 'staff_pick', 'Carpool — staff behalf-of picker label',
  'Request on someone''s behalf…', 32);
SELECT pg_temp.add_client_tpl('carpool', 'will_title', 'Carpool — willingness title on the request form',
  'What works for you? Pick everything you''d be OK with — the driver chooses one.', 33);
SELECT pg_temp.add_client_tpl('carpool', 'will_rider_home', 'Carpool — willing: picked up at my address',
  'Pick me up at my address', 34);
SELECT pg_temp.add_client_tpl('carpool', 'will_driver_home', 'Carpool — willing: go to driver',
  'I can get to the driver''s place', 35);
SELECT pg_temp.add_client_tpl('carpool', 'will_spot', 'Carpool — willing: known meeting spot',
  'Meet at a club spot (like Lighthouse Field)', 36);
SELECT pg_temp.add_client_tpl('carpool', 'will_midpoint', 'Carpool — willing: computed neutral point',
  'Meet somewhere in the middle — we''ll suggest the address', 37);
SELECT pg_temp.add_client_tpl('carpool', 'opt_midpoint', 'Carpool — option 4, neutral midpoint',
  'Meet in the middle at {spot} by {pickup} — driver leaves by {leave}.', 38);
SELECT pg_temp.add_client_tpl('carpool', 'willing_line', 'Carpool — willingness summary on an open request',
  '{name} is OK with: {list}.', 39);

COMMIT;
