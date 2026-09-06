-- RSVP window derives from the release rule (owner 2026-09-05, follow-up
-- to 334).
--
-- gcal-classify.js stamps fh_events.rsvps_open_at on every practice and
-- pickup with its own copy of "Sunday 8 PM before the week" — a second,
-- stored copy of the rule migration 334 moved into schedule_release_
-- policies.  Result: the owner opened the week of 9/7 early and every
-- practice still said "RSVP window not open yet".
--
-- fh_event_rsvps_open_at() is now the one answer: NULL (always open) when
-- the stored column is NULL (games), otherwise the week's effective open
-- moment — policy cutover or early release, whichever is earlier — for
-- the event's club/section.  The stored column survives only as a
-- fallback for an event with no team.  CalendarController reads this on
-- both the read (upcoming) and write (RSVP) paths.
CREATE OR REPLACE FUNCTION fh_event_rsvps_open_at(p_fh_event_id bigint) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
  SELECT CASE
           WHEN fe.rsvps_open_at IS NULL THEN NULL
           ELSE COALESCE(
             (SELECT fh_schedule_week_opens_at(t.club_id, t.club_section_id,
                                               fh_week_start(COALESCE(fe.start_at, ge.starts_at)))
                FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
               WHERE fet.fh_event_id = fe.id
               ORDER BY fet.team_id LIMIT 1),
             fe.rsvps_open_at)
         END
    FROM fh_events fe
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE fe.id = p_fh_event_id
$$;
