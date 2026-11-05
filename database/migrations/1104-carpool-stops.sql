-- 1104: a carpool can make more than one PICKUP STOP — owner 2026-11-05:
-- "we need to add the 2 together. a person can only pick one carpool"
-- (his car: 804 East Girard Avenue at 7:00 PM, then Lighthouse Sports
-- Complex at 7:15 PM, 8 seats in all).
--
-- fh_event_departures.stop_of: NULL = the carpool itself (driver, seats,
-- first stop); a row with stop_of = another pickup stop of that carpool.
-- Seats are shared across the stops; a passenger picks one carpool and
-- the stop they're picked up at (one live signup per person per event,
-- mig 1101).

BEGIN;

ALTER TABLE fh_event_departures ADD COLUMN IF NOT EXISTS stop_of bigint REFERENCES fh_event_departures(id);
COMMENT ON COLUMN fh_event_departures.stop_of IS
  'mig 1104: NULL = a carpool (driver + seats + first stop); else another pickup stop of that carpool — seats are shared.';

-- Tonight: Lighthouse at 7:15 becomes the second stop of the 804 E Girard carpool.
UPDATE fh_event_departures SET stop_of = 1, seats = NULL, driver_person_id = NULL
 WHERE id = 2 AND fh_event_id = 75692361 AND stop_of IS NULL
   AND EXISTS (SELECT 1 FROM fh_event_departures WHERE id = 1 AND fh_event_id = 75692361);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Carpool', v.label, 'carpool', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Carpool card — stops heading', 'car_stops', 'Pickup stops — pick the one you''ll be at:', 226),
    ('Carpool card — one stop ({place}, {time})', 'car_stop', '{place} · {time}', 227),
    ('Carpool card — join at a stop ({driver}, {place}, {time})', 'car_join_stop', '🙋 Ride with {driver} — pick me up at {place}, {time}', 228),
    ('Carpool card — kid joins at a stop ({name}, {driver}, {place}, {time})', 'car_join_stop_kid', '🙋 {name} rides with {driver} — pick up at {place}, {time}', 229),
    ('Carpool card — you ride ({driver}, {place}, {time})', 'car_you_ride_stop', '✓ You''re riding with {driver} — pickup at {place}, {time}', 230),
    ('Carpool card — move to this stop', 'car_move_here', 'Pick me up here instead', 231),
    ('Carpool card — driver: add a stop', 'car_add_stop', '＋ Add a pickup stop', 232),
    ('Carpool card — driver: remove a stop', 'car_remove_stop', 'Remove stop', 233),
    ('Create stop — save', 'car_save_stop', 'Add stop', 234)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'carpool' AND m.tier = v.tier);

COMMIT;
