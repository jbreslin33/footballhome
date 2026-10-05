-- 526 (2026-10-05) — #my: schedule conflicts, with drive times.
-- Owner: "we need to check for conflicts for the user. so take into account
-- drive times to show that player has a conflict based on start and end
-- times of match and arrival. so you can make game time but not arrival
-- time … we should not let a user even set it if there is conflict. we
-- would suggest what time to set for their arrival or departure …
-- obviously if event is at same place there is no conflict."
--
--   event_places          one row per location text the calendar uses, with
--                         the coordinates it geocodes to (OpenStreetMap)
--   place_drive_times     driving minutes between two places (OSRM), cached
--   schedule_conflict_policies   per club: what is added to a raw drive time
--                         (traffic factor, minutes to park and walk) and how
--                         close two places are to count as the same place
--
-- scripts/drive-times.js fills the first two for the locations of upcoming
-- events, from the 5-minute calendar sync; GET /api/calendar/drive-times
-- hands them to #my, which works out per person whether two Going answers
-- can both be kept, and otherwise offers the arrival / leave time that fits.
CREATE TABLE IF NOT EXISTS event_places (
    id            SERIAL PRIMARY KEY,
    location      TEXT NOT NULL UNIQUE,            -- exactly as gcal_events.location spells it
    latitude      NUMERIC(10,7),
    longitude     NUMERIC(10,7),
    geocoded_as   TEXT,                            -- what the geocoder matched
    geocode_note  TEXT,                            -- 'ok' or why it has no coordinates
    geocoded_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE event_places IS 'Calendar location text → coordinates (mig 526), for drive times between events. Fix a wrong match by editing latitude/longitude here; geocoded_at set = not looked up again.';

CREATE TABLE IF NOT EXISTS place_drive_times (
    from_place_id INTEGER NOT NULL REFERENCES event_places(id) ON DELETE CASCADE,
    to_place_id   INTEGER NOT NULL REFERENCES event_places(id) ON DELETE CASCADE,
    minutes       NUMERIC(6,1) NOT NULL,           -- free-flow driving time
    meters        INTEGER,
    source        TEXT NOT NULL DEFAULT 'osrm',
    fetched_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (from_place_id, to_place_id)
);

CREATE TABLE IF NOT EXISTS schedule_conflict_policies (
    club_id             INTEGER PRIMARY KEY REFERENCES clubs(id) ON DELETE CASCADE,
    traffic_factor      NUMERIC(4,2) NOT NULL DEFAULT 1.25,  -- raw drive time × this
    buffer_minutes      INTEGER NOT NULL DEFAULT 10,         -- + parking and walking
    same_place_minutes  NUMERIC(4,1) NOT NULL DEFAULT 3,     -- a drive this short = the same place, never a conflict
    round_to_minutes    INTEGER NOT NULL DEFAULT 5           -- suggested times are rounded to this
);
COMMENT ON TABLE schedule_conflict_policies IS 'How #my turns a raw drive time into "can you make it" (mig 526).';
INSERT INTO schedule_conflict_policies (club_id) VALUES (134) ON CONFLICT DO NOTHING;

-- Words (kind my_schedule).  Tokens: {who} {other} {other_end} {drive}
-- {earliest} {arrival} {start} {time}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'my_schedule', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('conflict_title',       'My schedule — conflict: heading',                     '⚠ Clashes with {other}', 20),
    ('conflict_after',       'My schedule — conflict: coming from the other event', '{other} ends {other_end}; with about {drive} min to get here the earliest is {earliest}. Arrival here is {arrival}.', 21),
    ('conflict_before',      'My schedule — conflict: going on to the other event', 'To be at {other} for {arrival} you would have to leave here by {earliest} (about {drive} min away).', 22),
    ('conflict_start_ok',    'My schedule — conflict: start is fine, arrival is not', 'You can make the start ({start}) but not arrival.', 23),
    ('conflict_overlap',     'My schedule — conflict: unknown drive time',          'These two overlap and are at different places.', 24),
    ('conflict_fix_arrive',  'My schedule — conflict: fix by arriving later',       'Go · arrive {time}', 25),
    ('conflict_fix_leave',   'My schedule — conflict: fix by leaving earlier',      'Go · leave at {time}', 26),
    ('conflict_fix_other_arrive', 'My schedule — conflict: fix on the other event, arrive later', 'Go · arrive at {other} {time}', 27),
    ('conflict_fix_other_leave',  'My schedule — conflict: fix on the other event, leave earlier', 'Go · leave {other} at {time}', 28),
    ('conflict_no_fix',      'My schedule — conflict: cannot do both',              'There is no way to do both — answer No to one of them.', 29),
    ('conflict_cancel',      'My schedule — conflict: back out',                    'Cancel', 30),
    ('conflict_time_blocked','My schedule — conflict: a typed time that clashes',   'That time clashes with {other}. Use {time} or later.', 31),
    ('conflict_time_blocked_leave','My schedule — conflict: a typed leave time that clashes', 'That time clashes with {other}. Leave by {time}.', 32),
    ('conflict_day',         'My schedule — day cell: a clash that day',            '⚠ clash', 33)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_schedule' AND m.tier = v.tier);
