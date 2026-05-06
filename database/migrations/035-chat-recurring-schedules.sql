-- Migration 035: Recurring chat event schedules
--
-- Adds a chat_recurring_schedules table so training/pickup events
-- are defined once and generated automatically, instead of requiring
-- manual weekly inserts into chat_events.

-- ============================================================================
-- Table
-- ============================================================================
CREATE TABLE IF NOT EXISTS chat_recurring_schedules (
    id              SERIAL PRIMARY KEY,
    chat_id         INT NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
                    -- 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday,
                    -- 4=Thursday, 5=Friday, 6=Saturday
    title           TEXT NOT NULL,
    start_time      TIME NOT NULL,   -- UTC
    end_time        TIME NOT NULL,   -- UTC
    end_is_next_day BOOLEAN NOT NULL DEFAULT false,
    location        TEXT,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chat_recurring_schedules_chat_day_unique UNIQUE (chat_id, day_of_week)
);

COMMENT ON TABLE chat_recurring_schedules IS
    'Defines weekly recurring chat events (training, pickup) per chat. '
    'Use generate_recurring_chat_events() to materialise rows into chat_events.';

-- ============================================================================
-- Lighthouse schedule (club_id = 100)
--   chat 4 = Training Lighthouse  (chat_type_id = 5, training)
--   chat 5 = Philadelphia Pickup  (chat_type_id = 3, pickup)
-- Times in UTC:  6:30 PM ET = 22:30 UTC,  8:45 PM ET = 00:45 UTC next day
--               10:30 AM ET = 14:30 UTC, 12:00 PM ET = 16:00 UTC
-- ============================================================================
INSERT INTO chat_recurring_schedules
    (chat_id, day_of_week, title, start_time, end_time, end_is_next_day, location)
VALUES
    (4, 2, 'Tuesday Training',           '22:30', '00:45', true,  'Lighthouse Sports Complex'),
    (4, 3, 'Wednesday Training',         '22:30', '00:45', true,  'Lighthouse Sports Complex'),
    (4, 4, 'Thursday Training',          '22:30', '00:45', true,  'Lighthouse Sports Complex'),
    (4, 5, 'Friday Training',            '22:30', '00:45', true,  'Lighthouse Sports Complex'),
    (5, 6, 'Saturday Morning Pickup ⚽️', '14:30', '16:00', false, 'The Lighthouse Community Center')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Function: generate_recurring_chat_events(from_date, up_to_date)
--
-- Walks every active schedule row and inserts a chat_event for each
-- matching weekday in the given date range, skipping dates where a
-- chat_event already exists for that (chat_id, event_date) pair.
--
-- Returns one row per newly-inserted event so you can audit what was created.
--
-- Typical usage:
--   -- Fill 90 days back through 90 days forward (safe to re-run):
--   SELECT * FROM generate_recurring_chat_events();
--
--   -- Extend through a specific future date:
--   SELECT * FROM generate_recurring_chat_events(CURRENT_DATE, '2026-12-31');
-- ============================================================================
CREATE OR REPLACE FUNCTION generate_recurring_chat_events(
    from_date  DATE DEFAULT CURRENT_DATE - INTERVAL '90 days',
    up_to_date DATE DEFAULT CURRENT_DATE + INTERVAL '90 days'
)
RETURNS TABLE(inserted_id INT, out_chat_id INT, out_title TEXT, out_event_date DATE)
LANGUAGE plpgsql AS $$
DECLARE
    sched    RECORD;
    d        DATE;
    ev_date  DATE;
    start_ts TIMESTAMPTZ;
    end_ts   TIMESTAMPTZ;
    new_id   INT;
BEGIN
    FOR sched IN
        SELECT * FROM chat_recurring_schedules WHERE is_active = true
        ORDER BY chat_id, day_of_week
    LOOP
        -- Advance from_date to the first occurrence of this weekday
        d := from_date;
        WHILE EXTRACT(DOW FROM d)::SMALLINT != sched.day_of_week LOOP
            d := d + 1;
        END LOOP;

        -- Walk forward in weekly steps
        WHILE d <= up_to_date LOOP
            ev_date  := d;
            start_ts := (ev_date::TEXT || ' ' || sched.start_time::TEXT || '+00')::TIMESTAMPTZ;
            end_ts   := ((ev_date + CASE WHEN sched.end_is_next_day THEN 1 ELSE 0 END)::TEXT
                         || ' ' || sched.end_time::TEXT || '+00')::TIMESTAMPTZ;

            -- Idempotent: skip if an event already exists for this chat + date
            IF NOT EXISTS (
                SELECT 1 FROM chat_events ce
                WHERE ce.chat_id  = sched.chat_id
                  AND ce.event_date = ev_date
            ) THEN
                INSERT INTO chat_events
                    (chat_id, title, event_date, start_at, end_at, location, is_active)
                VALUES
                    (sched.chat_id, sched.title, ev_date, start_ts, end_ts, sched.location, true)
                RETURNING id INTO new_id;

                inserted_id   := new_id;
                out_chat_id   := sched.chat_id;
                out_title     := sched.title;
                out_event_date := ev_date;
                RETURN NEXT;
            END IF;

            d := d + 7;
        END LOOP;
    END LOOP;
END;
$$;
