-- 518 — A bridged match mirrors its calendar event: date, time, title and
-- whether it is still on — by trigger, and re-checked on every sync.
--
-- Owner 2026-10-03, after the Saturday/Sunday U8 post (mig 517): "how do we
-- prevent this in future? we should always be polling gcal on all things
-- related to schedule right? and thus refresh the fh db?" … "yes build both".
--
-- The calendar was polled and right all along; the match row held a copy
-- that was written once.  mig 517 carried a moved start across.  This
-- finishes the job with one function, fh_matches_follow_gcal():
--   • date / time / title follow the calendar event;
--   • an event deleted or cancelled on the calendar cancels its match
--     (matches.cancelled_at), and one that comes back un-cancels it —
--     nothing else writes cancelled_at on a bridged match.  Only a game
--     still to come (today or later, Eastern): events are also removed
--     from the calendar after the fact (the whole 9/27 slate, played, with
--     lineups and RSVPs), and a played game must not turn into a
--     cancelled one.  A gone event changes nothing else on its match;
--   • a hand-edited match (manual_override) is left alone.
-- The gcal_events trigger calls it for the event that changed; gcal-sync.js
-- calls it for everything at the end of each 5-minute run, so a case the
-- trigger missed heals itself and is logged.

BEGIN;

CREATE OR REPLACE FUNCTION fh_matches_follow_gcal(p_gcal_event_id bigint DEFAULT NULL)
RETURNS int LANGUAGE sql AS $$
  WITH want AS (
    -- One calendar event per match; a live one wins over a deleted one.
    SELECT DISTINCT ON (fe.match_id)
           fe.match_id,
           (ge.starts_at AT TIME ZONE 'America/New_York')::date AS match_date,
           (ge.starts_at AT TIME ZONE 'America/New_York')::time AS match_time,
           left(ge.summary, 255)                                AS title,
           (ge.deleted_at IS NOT NULL OR ge.status = 'cancelled') AS gone
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE fe.match_id IS NOT NULL
       AND (p_gcal_event_id IS NULL
            OR fe.match_id IN (SELECT match_id FROM fh_events WHERE gcal_event_id = p_gcal_event_id))
     ORDER BY fe.match_id, (ge.deleted_at IS NOT NULL OR ge.status = 'cancelled'), ge.id DESC
  ), upd AS (
    UPDATE matches m
       SET match_date   = CASE WHEN w.gone THEN m.match_date ELSE w.match_date END,
           match_time   = CASE WHEN w.gone THEN m.match_time ELSE w.match_time END,
           title        = CASE WHEN w.gone THEN m.title      ELSE w.title      END,
           cancelled_at = CASE WHEN w.gone THEN COALESCE(m.cancelled_at, now()) END
      FROM want w
     WHERE m.id = w.match_id
       AND NOT COALESCE(m.manual_override, false)
       AND CASE WHEN w.gone
                THEN m.cancelled_at IS NULL
                     AND m.match_date >= (now() AT TIME ZONE 'America/New_York')::date
                ELSE m.match_date <> w.match_date
                     OR m.match_time IS DISTINCT FROM w.match_time
                     OR m.title IS DISTINCT FROM w.title
                     OR m.cancelled_at IS NOT NULL
           END
    RETURNING 1
  )
  SELECT count(*)::int FROM upd
$$;
COMMENT ON FUNCTION fh_matches_follow_gcal(bigint) IS
  'mig 518: realigns bridged matches with their calendar event (date, time, title; an upcoming match is cancelled when its event is deleted or cancelled, un-cancelled when it is back) — one event''s matches, or all when NULL; returns how many rows changed. manual_override matches are left alone.';

CREATE OR REPLACE FUNCTION gcal_events_move_match()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    PERFORM fh_matches_follow_gcal(NEW.id);
    RETURN NULL;
END;
$$;
COMMENT ON FUNCTION gcal_events_move_match() IS
    'mig 517/518: a changed calendar event (start, title, status, deletion) is mirrored onto the match bridged to it via fh_matches_follow_gcal().';

DROP TRIGGER IF EXISTS gcal_events_move_match ON gcal_events;
CREATE TRIGGER gcal_events_move_match
    AFTER UPDATE OF starts_at, summary, status, deleted_at ON gcal_events
    FOR EACH ROW EXECUTE FUNCTION gcal_events_move_match();

-- Already drifted: the four upcoming matches whose event was deleted, the
-- two stale titles, and any older ones.
SELECT fh_matches_follow_gcal() AS realigned;

COMMIT;
