-- 1102: a carpool is ONE CAR — owner 2026-11-05: "needs to be clear that
-- someone clicks 'I will be passenger in carpool' for a specific one. if i
-- created the carpool then i am the driver … others can't change the one
-- created" + "this has to not be confusing. it should be clear who is
-- driving and who is passenger and where they are meeting and when".
--
-- fh_event_departures (mig 1101) gains driver_person_id (= its creator;
-- the driver may hand it to someone else) and seats.  Signups are
-- passengers only from now on.  Only the driver or a club admin edits,
-- removes passengers or deletes; anyone else joins or leaves.

BEGIN;

ALTER TABLE fh_event_departures ADD COLUMN IF NOT EXISTS driver_person_id integer REFERENCES persons(id);
ALTER TABLE fh_event_departures ADD COLUMN IF NOT EXISTS seats integer CHECK (seats IS NULL OR seats BETWEEN 1 AND 12);
UPDATE fh_event_departures SET driver_person_id = created_by_person_id WHERE driver_person_id IS NULL;
-- Tonight's two were typed in by the owner; 3 seats until he says otherwise.
UPDATE fh_event_departures SET seats = 3 WHERE seats IS NULL AND fh_event_id = 75692361;
COMMENT ON COLUMN fh_event_departures.driver_person_id IS 'mig 1102: who drives this carpool (its creator unless handed on). Only they or a club admin change it.';
COMMENT ON COLUMN fh_event_departures.seats IS 'mig 1102: passenger seats in the car; full = no more "I''ll be a passenger".';

-- Words: one carpool card, plainly.
DELETE FROM message_templates WHERE kind = 'carpool' AND tier IN
  ('dep_title', 'dep_line', 'dep_riders', 'dep_drivers', 'dep_nobody', 'dep_seats', 'dep_ride', 'dep_ride_for',
   'dep_drive', 'dep_leave', 'dep_seats_ask', 'dep_add', 'dep_place_ph', 'dep_address_ph', 'dep_save', 'dep_remove', 'dep_staff_pick');
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Carpool', v.label, 'carpool', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Carpools — section title', 'car_title', '🚗 Carpools', 200),
    ('Carpool card — who drives ({driver})', 'car_driver', '{driver} is driving', 201),
    ('Carpool card — where and when ({place}, {time})', 'car_meet', 'Meet at {place} · leaves {time}', 202),
    ('Carpool card — passengers ({n}, {seats}, {names})', 'car_passengers', 'Passengers ({n} of {seats} seats): {names}', 203),
    ('Carpool card — passengers, seats unknown ({n}, {names})', 'car_passengers_open', 'Passengers ({n}): {names}', 204),
    ('Carpool card — no passengers yet ({seats})', 'car_empty', 'No passengers yet · {seats} seats', 205),
    ('Carpool card — join button ({driver})', 'car_join', '🙋 I''ll be a passenger in {driver}''s carpool', 206),
    ('Carpool card — join for a kid ({name}, {driver})', 'car_join_kid', '🙋 {name} will be a passenger in {driver}''s carpool', 207),
    ('Carpool card — leave button', 'car_leave', 'Leave this carpool', 208),
    ('Carpool card — leave for a kid ({name})', 'car_leave_kid', 'Take {name} out of this carpool', 209),
    ('Carpool card — full', 'car_full', 'Full', 210),
    ('Carpool card — you are the driver', 'car_you_drive', 'You are driving this carpool', 211),
    ('Carpool card — you are a passenger', 'car_you_ride', 'You are a passenger in this carpool', 212),
    ('Carpool card — driver: add a passenger', 'car_add_pick', 'Add a passenger…', 213),
    ('Carpool card — driver: delete', 'car_delete', 'Delete carpool', 214),
    ('Carpool card — driver: edit', 'car_edit', 'Edit', 215),
    ('Create — open button', 'car_create', '＋ Create a carpool (you drive)', 216),
    ('Create — meeting place', 'car_place_ph', 'Meet at (e.g. Lighthouse Sports Complex)', 217),
    ('Create — address', 'car_address_ph', 'Address (optional)', 218),
    ('Create — leave time label', 'car_time_label', 'Leaves at', 219),
    ('Create — seats label', 'car_seats_label', 'Passenger seats', 220),
    ('Create — save', 'car_save', 'Create carpool', 221),
    ('Edit — save', 'car_update', 'Save changes', 222),
    ('Edit — hand to another driver', 'car_handoff', 'Driver', 223)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'carpool' AND m.tier = v.tier);

COMMIT;
