-- 1073 (owner 2026-11-05):
--  1. "rename to paper spot": the #teams Team pill heading said
--     📄 NOT FUNCTIONAL while the card dropdown said 📄 Paper spot.  One
--     name now: 📄 PAPER SPOT.
--  2. "a standing call up should see the practice for the team they are
--     standing call to": ⭐ team_auto_invites now invite to that team's
--     PRACTICES as well as its games (mig 617 was games only).  Same
--     machinery — an fh_event_invites row, channel 'auto' — so #my, Event
--     Center, reminders and the RSVP board treat it like any invite.  A
--     practice invite is skipped when the person already sees that
--     practice from a roster row of their own (men's practices tag both
--     Liga 1 and APSL, so today's four standing call-ups gain nothing
--     new; the rule is for squads with their own practices).

BEGIN;

UPDATE message_templates SET body = '📄 PAPER SPOT'
 WHERE kind = 'roster_sheet' AND tier = 'board_not_functional_h';

-- Wanted: a game, or a practice they would not see anyway.
CREATE OR REPLACE FUNCTION fh_auto_invite_wanted(p_fh_event_id bigint, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT CASE (SELECT kind FROM fh_events WHERE id = p_fh_event_id)
           WHEN 'match' THEN true
           WHEN 'practice' THEN NOT EXISTS (
             SELECT 1 FROM fh_event_teams fet
               JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
              WHERE fet.fh_event_id = p_fh_event_id AND tp.person_id = p_person_id)
           ELSE false END
$$;

CREATE OR REPLACE FUNCTION fh_apply_team_auto_invites()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
  SELECT NEW.fh_event_id, a.person_id, a.from_team_id, a.person_id, 'auto'
    FROM team_auto_invites a
   WHERE a.team_id = NEW.team_id AND a.active
     AND fh_auto_invite_wanted(NEW.fh_event_id, a.person_id)
     AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                      WHERE i.fh_event_id = NEW.fh_event_id
                        AND i.person_id = a.person_id AND i.revoked_at IS NULL);
  RETURN NEW;
END $$;

-- Upcoming games + practices of one team for one standing call-up (the ⭐
-- toggle's backfill, CalendarController::handlePostAutoInvite).
CREATE OR REPLACE FUNCTION fh_team_auto_invites_backfill(p_team_id integer, p_person_id integer, p_from_team_id integer)
RETURNS integer LANGUAGE sql AS $$
  WITH ins AS (
    INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
    SELECT DISTINCT fet.fh_event_id, p_person_id, p_from_team_id, p_person_id, 'auto'
      FROM fh_event_teams fet
      JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind IN ('match', 'practice')
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
     WHERE fet.team_id = p_team_id
       AND fh_auto_invite_wanted(fet.fh_event_id, p_person_id)
       AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                        WHERE i.fh_event_id = fet.fh_event_id AND i.person_id = p_person_id
                          AND i.revoked_at IS NULL)
    RETURNING 1)
  SELECT count(*)::int FROM ins
$$;

-- Today's standing call-ups: their teams' upcoming practices.
SELECT a.person_id, fh_team_auto_invites_backfill(a.team_id, a.person_id, a.from_team_id) AS added
  FROM team_auto_invites a WHERE a.active;

COMMIT;
