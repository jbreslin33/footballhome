-- 1643 (2026-11-20) — 🟢 A coach's session puts them on it, whatever its teams.
-- Owner 11/20: "we should list all coaches and have them as green selected
-- that its their schedule or red that its not" · "maybe yellow that they
-- have been requested to fill in OR sub".  #coach-schedule now lists every
-- coach on every session; green must mean they are on it, so a coach with a
-- session (coach_sessions, mig 1634) is a coach on that slot's practices
-- even when none of its teams are theirs — the same door a cover opens
-- (mig 1640).  Someone covering for them on one of those still takes it.
--
-- fh_event_extra_coaches(event) = the coaches on an event beyond its teams'
-- own: whoever covers it, and everyone with its slot as a session.  Callers
-- that list coaches union it in (minus the team's own coaches);
-- fh_event_covering(event, person) asks it for one person.
BEGIN;

CREATE OR REPLACE FUNCTION fh_event_extra_coaches(p_fh_event_id bigint)
RETURNS TABLE (person_id integer, coach_id integer) LANGUAGE sql STABLE AS $$
    SELECT c.person_id, c.id
      FROM coach_covers cc JOIN coaches c ON c.id = cc.cover_coach_id
     WHERE cc.fh_event_id = p_fh_event_id AND cc.status = 'covered'
    UNION
    SELECT c.person_id, c.id
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      JOIN coach_sessions x
        ON x.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int
       AND x.starts_at = (ge.starts_at AT TIME ZONE 'America/New_York')::time
      JOIN coach_session_plans pl ON pl.coach_id = x.coach_id AND ge.starts_at >= pl.starts_at
      JOIN coaches c ON c.id = x.coach_id
     WHERE fe.id = p_fh_event_id AND fe.kind = 'practice'
       AND NOT EXISTS (SELECT 1 FROM coach_covers cc
                        WHERE cc.fh_event_id = fe.id AND cc.coach_id = c.id AND cc.status = 'covered')
$$;
COMMENT ON FUNCTION fh_event_extra_coaches(bigint) IS
  'mig 1643: coaches on this event beyond its teams'' own — covering it (mig 1640) or holding its slot as a session (mig 1634), unless covered away.';

-- One person: written out, not via the set-returning function above — the
-- calendar feed calls this per event several times, and calling
-- fh_event_extra_coaches per row stalled the signed-in feed (11/20, fixed
-- live within minutes).  Same rule.
CREATE OR REPLACE FUNCTION fh_event_covering(p_fh_event_id bigint, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM coach_covers cc JOIN coaches c ON c.id = cc.cover_coach_id
                  WHERE cc.fh_event_id = p_fh_event_id AND cc.status = 'covered' AND c.person_id = p_person_id)
      OR EXISTS (SELECT 1
                   FROM coaches c
                   JOIN coach_session_plans pl ON pl.coach_id = c.id
                   JOIN coach_sessions x ON x.coach_id = c.id
                   JOIN fh_events fe ON fe.id = p_fh_event_id AND fe.kind = 'practice'
                   JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                  WHERE c.person_id = p_person_id
                    AND ge.starts_at >= pl.starts_at
                    AND x.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int
                    AND x.starts_at = (ge.starts_at AT TIME ZONE 'America/New_York')::time
                    AND NOT EXISTS (SELECT 1 FROM coach_covers cc
                                     WHERE cc.fh_event_id = fe.id AND cc.coach_id = c.id AND cc.status = 'covered'))
$$;
COMMENT ON FUNCTION fh_event_covering(bigint, integer) IS
  'mig 1640/1643: a coach on this event beyond its teams'' own (covering it, or its slot is their session).';

UPDATE message_templates SET body = 'Every coach on every session: green = on it, red = not. Tap to change.'
 WHERE kind = 'coach_schedule' AND tier = 'session_hint';
UPDATE message_templates SET body = 'Green = on it, yellow = asked to fill in, red = not. Tap 🙋 on yours to ask for cover.'
 WHERE kind = 'coach_schedule' AND tier = 'week_hint';
UPDATE message_templates SET body = 'Green = their session, red = not. Tap to change. Weekend duty = the coach''s teams'' games.'
 WHERE kind = 'coach_schedule' AND tier = 'coach_hint';

-- "this is my screen to set schedule" · "the coaches can request sub from
-- their cal": #coach-schedule back to the admin menu; coaches ask from the
-- event page (components/coach-cover-banner.js).
UPDATE menu_pages SET audience = 'admin' WHERE code = 'coach-schedule';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Coach Schedule', v.l, 'coach_schedule', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('ask_sub',       'Event page: ask button',      '🙋 Ask for a sub', 70),
    ('ask_sub_title', 'Event page: pick who to ask', 'Who could sub for you? Pick, then Ask.', 71),
    ('ask_sub_sent',  'Event page: after asking',    'Asked. Text each one:', 72)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'coach_schedule' AND m.tier = v.t);

COMMIT;
