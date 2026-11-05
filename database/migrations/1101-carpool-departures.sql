-- 1101: 🚐 carpool DEPARTURES — a group leaves from a place at a time and
-- players tap to ride or drive (owner 2026-11-05, APSL at Vidas United:
-- "put carpool 7pm departure at 804 East Girard Avenue … 7:15pm departure
-- from Lighthouse Sports Complex. do we have easy to use functions for
-- players to click to sign up to use them for each site?").  Lives in the
-- shared 🚗 Carpool panel (#my, Event Center, Game Center) beside the
-- one-to-one ride requests (mig 601).  Staff add departures from the panel.
-- One live signup per person per event: joining one departure leaves any
-- other on the same event.

BEGIN;

CREATE TABLE IF NOT EXISTS fh_event_departures (
    id                    bigserial PRIMARY KEY,
    fh_event_id           bigint NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    place                 text NOT NULL,
    address               text,
    depart_at             timestamptz NOT NULL,
    note                  text,
    created_by_person_id  integer REFERENCES persons(id),
    created_at            timestamptz NOT NULL DEFAULT now(),
    cancelled_at          timestamptz
);
CREATE INDEX IF NOT EXISTS idx_fh_event_departures_event ON fh_event_departures (fh_event_id) WHERE cancelled_at IS NULL;
COMMENT ON TABLE fh_event_departures IS
  'mig 1101: a carpool departure for an event — place + time; players sign up to ride or drive (fh_event_departure_signups).';

CREATE TABLE IF NOT EXISTS fh_event_departure_signups (
    id                    bigserial PRIMARY KEY,
    departure_id          bigint NOT NULL REFERENCES fh_event_departures(id) ON DELETE CASCADE,
    fh_event_id           bigint NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    person_id             integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    role                  text NOT NULL CHECK (role IN ('rider', 'driver')),
    seats                 integer CHECK (seats IS NULL OR seats BETWEEN 1 AND 12),
    signed_by_person_id   integer REFERENCES persons(id),
    created_at            timestamptz NOT NULL DEFAULT now(),
    left_at               timestamptz
);
CREATE UNIQUE INDEX IF NOT EXISTS uq_departure_signup_live
    ON fh_event_departure_signups (fh_event_id, person_id) WHERE left_at IS NULL;
COMMENT ON TABLE fh_event_departure_signups IS
  'mig 1101: who rides / drives from a departure. One live row per person per event (joining another departure leaves this one); left_at = left, never deleted.';

-- Tonight's two (APSL at Vidas United, fh_event 75692361).
INSERT INTO fh_event_departures (fh_event_id, place, address, depart_at, created_by_person_id)
SELECT 75692361, v.place, v.address, v.depart_at, 1
  FROM (VALUES
    ('804 East Girard Avenue', '804 East Girard Avenue, Philadelphia, PA', timestamptz '2026-11-05 19:00 America/New_York'),
    ('Lighthouse Sports Complex', NULL, timestamptz '2026-11-05 19:15 America/New_York')
  ) AS v(place, address, depart_at)
 WHERE EXISTS (SELECT 1 FROM fh_events WHERE id = 75692361)
   AND NOT EXISTS (SELECT 1 FROM fh_event_departures d WHERE d.fh_event_id = 75692361 AND d.place = v.place);

-- Words (kind carpool).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Carpool', v.label, 'carpool', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Departures — section title', 'dep_title', '🚐 Pickup sites — tap to ride or drive', 200),
    ('Departures — one line ({time}, {place})', 'dep_line', '{time} from {place}', 201),
    ('Departures — riders list ({names})', 'dep_riders', 'Riding: {names}', 202),
    ('Departures — drivers list ({names})', 'dep_drivers', 'Driving: {names}', 203),
    ('Departures — nobody yet', 'dep_nobody', 'Nobody signed up yet.', 204),
    ('Departures — seats left ({n})', 'dep_seats', '{n} seats', 205),
    ('Departures — ride button (self)', 'dep_ride', '🙋 I''ll ride', 206),
    ('Departures — ride button ({name})', 'dep_ride_for', '🙋 {name} rides', 207),
    ('Departures — drive button (self)', 'dep_drive', '🚗 I''m driving', 208),
    ('Departures — leave button', 'dep_leave', 'Leave', 209),
    ('Departures — seats prompt label', 'dep_seats_ask', 'Seats for players', 210),
    ('Departures — staff add button', 'dep_add', '＋ Create pickup site', 211),
    ('Departures — staff form: place', 'dep_place_ph', 'Where (e.g. Lighthouse Sports Complex)', 212),
    ('Departures — staff form: address', 'dep_address_ph', 'Address (optional)', 213),
    ('Departures — staff form: save', 'dep_save', 'Create pickup site', 214),
    ('Departures — staff remove', 'dep_remove', 'Remove', 215),
    ('Departures — staff sign-someone-up dropdown', 'dep_staff_pick', 'Sign someone up to ride…', 216)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'carpool' AND m.tier = v.tier);

COMMIT;
