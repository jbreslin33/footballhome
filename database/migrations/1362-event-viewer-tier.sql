-- 1362 (2026-11-14) — Event Center viewer tier: ONE answer to "how much does
-- this person get on this event?" (docs/event-center-design.md, slice 1).
--
-- Owner: "the coach screen should just be more enhanced then player/parent.
-- the admin just more enhanced then coach" + "we just check what they are and
-- have a class for each possibility … use correct class for each user to show
-- what needs showing".
--
-- 'admin'  — the person has an admins row (any level)
-- 'coach'  — an active team_coaches row on a team tagged on the event
--            (fh_event_teams); an off-schedule day keeps the permission, it
--            only changes the hat label my_role
-- 'player' — everyone else (players, parents, call-ups, club staff)
--
-- Same rule CalendarController::isEventCoachOrAdmin used; the C++ class
-- EventAccess and the calendar feed (viewer_tier per event) both call this.

CREATE OR REPLACE FUNCTION fh_event_viewer_tier(p_fh_event_id BIGINT, p_person_id INTEGER)
RETURNS TEXT LANGUAGE sql STABLE AS $$
  SELECT CASE
    WHEN EXISTS (SELECT 1 FROM admins a JOIN users u ON u.id = a.user_id
                  WHERE u.person_id = p_person_id) THEN 'admin'
    WHEN EXISTS (SELECT 1 FROM fh_event_teams fet
                   JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                   JOIN coaches co      ON co.id = tc.coach_id
                  WHERE fet.fh_event_id = p_fh_event_id
                    AND co.person_id = p_person_id) THEN 'coach'
    ELSE 'player'
  END
$$;
