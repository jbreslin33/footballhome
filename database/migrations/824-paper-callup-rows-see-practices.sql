-- 824 (2026-10-29) — a 📄 paper spot (mig 619) or a call-up-only team
-- (mig 605) keeps GAMES invite-only, but the roster row still grants the
-- team's PRACTICES.  Owner: "lucca haas santos is saying he can only see
-- game not practice" … "fix it please".  Men's practices are tagged APSL
-- 35 + Liga 1 120; Lucca (Liga 1 📄 + Reserves), Armando Pena and Justin
-- Figueroa (APSL 📄) saw none.
--
-- Used by the calendar feed (#my / RSVP cards), the RSVP permission check
-- and the roll-call card.  Reminders, fines and the RSVP board keep their
-- own roster rules — these players see and answer practices, they are
-- not chased or fined for them.

CREATE OR REPLACE FUNCTION fh_roster_row_grants(p_team_id integer, p_invite_only boolean, p_event_id bigint)
RETURNS boolean LANGUAGE sql STABLE AS $$
    SELECT (SELECT kind FROM fh_events WHERE id = p_event_id) = 'practice'
        OR (NOT fh_team_callup_only(p_team_id) AND NOT p_invite_only)
$$;
COMMENT ON FUNCTION fh_roster_row_grants(integer, boolean, bigint) IS
  'mig 824: does a live team_persons row put this person on this event? Practices: always. Games: not for a paper spot (invite_only) or a call-up-only team — an invite is their door.';
