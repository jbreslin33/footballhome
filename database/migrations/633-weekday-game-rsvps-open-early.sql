-- 633 (2026-10-22) — the early-posted weekday game takes RSVPs.
--
-- Owner: "players are saying tuesday is locked for liga 1."
--
-- Mig 627 moved the weekday-game early open off the WEEK
-- (fh_schedule_week_opens_at) onto the EVENT (fh_event_early_open_at),
-- and taught visibility (fh_event_posted / fh_event_window_end) and the
-- deadline guard about it — but not fh_event_rsvps_open_at (mig 335),
-- which still opened every game at its week's Sunday 8 PM cutover.  So
-- the Tue 10/27 Desert Hawks game showed from Tue 10/20 with its RSVP
-- buttons locked, and the server refused answers ("RSVP window not open
-- yet", CalendarController::checkRsvpWindowOpen) until Sun 10/25 20:00.
--
-- Fix: an event's RSVPs open at the earlier of its week's open and its
-- own early open.  LEAST ignores the NULL leg, so practices and weekend
-- games are unchanged.

CREATE OR REPLACE FUNCTION fh_event_rsvps_open_at(p_fh_event_id bigint)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT CASE
           WHEN fe.rsvps_open_at IS NULL AND fe.kind NOT IN ('match', 'intrasquad') THEN NULL
           ELSE COALESCE(
             (SELECT LEAST(
                       fh_schedule_week_opens_at(t.club_id, t.club_section_id,
                                                 fh_week_start(COALESCE(fe.start_at, ge.starts_at))),
                       fh_event_early_open_at(t.club_id, t.club_section_id,
                                              COALESCE(fe.start_at, ge.starts_at), fe.kind))
                FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
               WHERE fet.fh_event_id = fe.id
               ORDER BY fet.team_id LIMIT 1),
             fe.rsvps_open_at)
         END
    FROM fh_events fe
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE fe.id = p_fh_event_id
$$;
COMMENT ON FUNCTION fh_event_rsvps_open_at(bigint) IS
  'When RSVPs open for one event: its week''s open (mig 335) or — mig 633 — its own weekday-match early open (mig 627), whichever is first.';
