-- 396 — Games open for RSVP with their week, like practices.
--
-- Owner 2026-09-21: the whole future schedule becomes visible on #my
-- (This week / All / Games / Practices pills), but "they can only rsvp to
-- events up to Sunday night" and "we should also not accept an rsvp in db
-- ... if outside window".
--
-- Until now a game was only protected by being hidden: fh_events.rsvps_open_at
-- is NULL for matches, so fh_event_rsvps_open_at() returned NULL = always
-- open.  Games and intra-squads now derive their open time from the
-- section's release rule (schedule_release_policies + early releases),
-- exactly as practices do.  Everything that reads the function follows:
-- the RSVP write check (409 outside the window), the feed's
-- rsvps_open_now, and the #my buttons.  Meetings stay ungated.
CREATE OR REPLACE FUNCTION public.fh_event_rsvps_open_at(p_fh_event_id bigint)
 RETURNS timestamp with time zone
 LANGUAGE sql
 STABLE
AS $function$
  SELECT CASE
           WHEN fe.rsvps_open_at IS NULL AND fe.kind NOT IN ('match', 'intrasquad') THEN NULL
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
$function$;
