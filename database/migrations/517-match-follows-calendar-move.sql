-- 517 — A bridged match follows its calendar event when the event is moved.
--
-- Owner 2026-10-03: "why is u8 travel showing as saturday game on insta
-- post lol".  The U8 Travel game at West Philly was moved on the calendar
-- from Sat 10/3 to Sun 10/4, but matches.match_date is only written when
-- the match row is first bridged (fh_event_team_create_match, on the
-- fh_event_teams insert) — nothing carried a later move across, so Game
-- Center's card and the Instagram post kept the old day while #my, which
-- reads the calendar, showed the right one.
--
-- The calendar owns a bridged game's date and time: a trigger on
-- gcal_events now copies a changed start onto the match (hand-edited
-- matches, manual_override, are left alone), and the rows that had already
-- drifted are brought back in line.

BEGIN;

CREATE OR REPLACE FUNCTION gcal_events_move_match()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    UPDATE matches m
       SET match_date = (NEW.starts_at AT TIME ZONE 'America/New_York')::date,
           match_time = (NEW.starts_at AT TIME ZONE 'America/New_York')::time
      FROM fh_events fe
     WHERE fe.gcal_event_id = NEW.id
       AND m.id = fe.match_id
       AND NOT COALESCE(m.manual_override, false);
    RETURN NULL;
END;
$$;
COMMENT ON FUNCTION gcal_events_move_match() IS
    'mig 517: a calendar event''s new start is copied to the match bridged to it (matches.match_date / match_time), unless the match is manual_override.';

DROP TRIGGER IF EXISTS gcal_events_move_match ON gcal_events;
CREATE TRIGGER gcal_events_move_match
    AFTER UPDATE OF starts_at ON gcal_events
    FOR EACH ROW WHEN (OLD.starts_at IS DISTINCT FROM NEW.starts_at)
    EXECUTE FUNCTION gcal_events_move_match();

-- Already drifted.
UPDATE matches m
   SET match_date = (ge.starts_at AT TIME ZONE 'America/New_York')::date,
       match_time = (ge.starts_at AT TIME ZONE 'America/New_York')::time
  FROM fh_events fe
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id
 WHERE m.id = fe.match_id
   AND ge.deleted_at IS NULL
   AND NOT COALESCE(m.manual_override, false)
   AND (m.match_date <> (ge.starts_at AT TIME ZONE 'America/New_York')::date
        OR m.match_time IS DISTINCT FROM (ge.starts_at AT TIME ZONE 'America/New_York')::time);

COMMIT;
