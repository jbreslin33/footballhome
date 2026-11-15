-- 1377 (2026-11-14) — 🚗 Carpool: "Leaving from" is an address, picked from
-- a dropdown.  Owner: "it should have address and departure time and number
-- of seats. what is this meet at lol. that is the address. Lighthouse and my
-- house 804 East Girard, philadelphia should be in drop down as choices".
--
-- carpool_spots (mig 600s) were the club meeting points riders' plans use.
-- They now also feed the driver's "Leaving from" dropdown, so each carries
-- its street address.  Coordinates become optional: a spot without them is
-- a departure choice only and never offered in a rider's computed plan
-- (CarpoolController computePlans skips it) — the owner's house is a place
-- he leaves from, not a public meeting point.

ALTER TABLE carpool_spots ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE carpool_spots ALTER COLUMN latitude  DROP NOT NULL;
ALTER TABLE carpool_spots ALTER COLUMN longitude DROP NOT NULL;
ALTER TABLE carpool_spots ADD COLUMN IF NOT EXISTS sort_order INTEGER NOT NULL DEFAULT 100;

UPDATE carpool_spots SET address = '101-199 E Erie Ave, Philadelphia, PA 19140', sort_order = 10
 WHERE name = 'Lighthouse Field' AND address IS NULL;

INSERT INTO carpool_spots (name, address, latitude, longitude, is_active, sort_order)
SELECT '804 East Girard', '804 E Girard Ave, Philadelphia, PA', NULL, NULL, true, 20
 WHERE NOT EXISTS (SELECT 1 FROM carpool_spots WHERE name = '804 East Girard');

-- Words: the field is "Leaving from", the card says where + when, and the
-- time field is "Departure time" (the owner's words).
UPDATE message_templates SET body = 'Departure time'
 WHERE kind = 'carpool' AND tier = 'car_time_label' AND body = 'Leaves at';
UPDATE message_templates SET body = 'Leaving from {place} · {time}'
 WHERE kind = 'carpool' AND tier = 'car_meet' AND body = 'Meet at {place} · leaves {time}';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Carpool', v.label, 'carpool', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Carpool — "Leaving from" field label',          'car_from_label', 'Leaving from',               960),
    ('Carpool — "Leaving from" first option',         'car_from_pick',  'Pick where you leave from…', 961),
    ('Carpool — "Leaving from" other-address option', 'car_from_other', 'Other address…',             962),
    ('Carpool — other address box placeholder',       'car_from_other_ph', 'Type the address',        963),
    ('Carpool — map link under a typed address',      'car_map',        'Map',                        964)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'carpool' AND m.tier = v.tier);
