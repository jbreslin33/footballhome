-- 876 (2026-10-30) — a moved event drops the Arrive / Leave times on its answers.
--
-- Owner: "why is it saying friday men practice clashes with vidas game" …
-- "everything is clashing with vidas almost".  The APSL game at Vidas moved
-- from Sun 10/25 to Thu 11/5 and kept the answers' times, which stay absolute:
-- Going with an arrival of 10/25 reads as being there from 10/25 to 11/5, so
-- the #my conflict check flagged every Going in between.  The answer stands;
-- its times were for the old date, so the card goes back to the event's own.

CREATE OR REPLACE FUNCTION fh_gcal_event_moved_clear_rsvp_times()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE fh_event_rsvps r
       SET arrive_at = NULL, leave_at = NULL
      FROM fh_events fe
     WHERE fe.gcal_event_id = NEW.id AND r.fh_event_id = fe.id
       AND (r.arrive_at IS NOT NULL OR r.leave_at IS NOT NULL);
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS gcal_events_moved_clear_rsvp_times ON gcal_events;
CREATE TRIGGER gcal_events_moved_clear_rsvp_times
    AFTER UPDATE OF starts_at ON gcal_events
    FOR EACH ROW WHEN (OLD.starts_at IS DISTINCT FROM NEW.starts_at)
    EXECUTE FUNCTION fh_gcal_event_moved_clear_rsvp_times();

-- the answers already holding a time from before a move
UPDATE fh_event_rsvps r
   SET arrive_at = NULL, leave_at = NULL
  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
 WHERE r.fh_event_id = fe.id
   AND ((r.arrive_at IS NOT NULL AND abs(extract(epoch FROM r.arrive_at - ge.starts_at)) > 6 * 3600)
     OR (r.leave_at  IS NOT NULL AND abs(extract(epoch FROM r.leave_at  - ge.ends_at))   > 6 * 3600));
