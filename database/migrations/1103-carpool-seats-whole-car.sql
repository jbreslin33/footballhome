-- 1103: carpool seats = the WHOLE car, driver included (owner 2026-11-05:
-- "we need a set number of seats in total. 1 seat is taken by driver but
-- include it. my car seats 8 total").  Passengers fit in seats − 1; the
-- card says "8 seats · 3 taken (driver + 2) · 5 open".  The owner's two
-- carpools tonight: 8 seats each.
BEGIN;
COMMENT ON COLUMN fh_event_departures.seats IS
  'mig 1103: seats in the whole car, driver included — passengers fit in seats - 1.';
UPDATE fh_event_departures SET seats = 8 WHERE fh_event_id = 75692361 AND driver_person_id = 1 AND cancelled_at IS NULL;
UPDATE message_templates SET body = 'Seats in the car (count the driver)', label = 'Create — seats label (whole car)'
 WHERE kind = 'carpool' AND tier = 'car_seats_label';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Carpool', v.label, 'carpool', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Carpool card — seats ({seats}, {taken}, {open})', 'car_seats', '{seats} seats · {taken} taken (driver included) · {open} open', 224),
    ('Carpool card — no passengers yet', 'car_empty_v2', 'No passengers yet', 225)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'carpool' AND m.tier = v.tier);
COMMIT;
