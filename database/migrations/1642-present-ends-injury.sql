-- 1642 (2026-11-20) — 🩹 Injured on every event's graphic; marked Present
-- ends the injury.  Owner: "we need to have injured players list on the
-- graphic for all events. if they set going or not going they show in the
-- new cat for that event but go right back for next one" → "actually if
-- they are marked Present they would come off injury".
--
-- The list itself is page work (event card + game card now show 🩹 Injured
-- to everyone; an answer of their own puts them in Going / Not going for
-- that event only — the injury row stays open, so the next event lists
-- them as injured again).  This migration: a player marked Present or Late
-- at any event has trained / played, so his open injury ends then.

CREATE OR REPLACE FUNCTION fh_attendance_ends_injury() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.status IN ('present', 'late') THEN
    UPDATE person_injuries
       SET ends_at = now()
     WHERE person_id = NEW.person_id
       AND starts_at < now()
       AND (ends_at IS NULL OR ends_at > now());
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS fh_event_attendance_ends_injury ON fh_event_attendance;
CREATE TRIGGER fh_event_attendance_ends_injury
  AFTER INSERT OR UPDATE OF status ON fh_event_attendance
  FOR EACH ROW EXECUTE FUNCTION fh_attendance_ends_injury();
