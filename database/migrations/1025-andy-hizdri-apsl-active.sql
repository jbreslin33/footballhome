-- 1025: Andy Hizdri (person 3498) is a regular APSL player, not a call-up
-- (owner 2026-11-04: "oh then he doesn't go in call ups lol" — he is on the
-- APSL TeamPass Active Roster).  Undoes the APSL half of mig 1023: his APSL
-- (35) row comes back as a full spot, the standing invite from Liga 1 is
-- off, and its leftover 'auto' invites for upcoming APSL games are revoked
-- (the roster row shows him every game).  Liga 1 stays ↔ Call-in (mig 1023).

BEGIN;

INSERT INTO team_persons (team_id, person_id)
SELECT 35, 3498
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 3498 AND first_name = 'Andy' AND last_name = 'Hizdri')
   AND NOT EXISTS (SELECT 1 FROM team_persons WHERE team_id = 35 AND person_id = 3498 AND removed_at IS NULL);

UPDATE team_auto_invites SET active = false
 WHERE team_id = 35 AND person_id = 3498 AND active;

UPDATE fh_event_invites i SET revoked_at = now()
  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
 WHERE i.fh_event_id = fe.id AND i.person_id = 3498 AND i.channel = 'auto'
   AND i.revoked_at IS NULL AND ge.starts_at > now()
   AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = 35)
   AND NOT EXISTS (SELECT 1 FROM team_auto_invites a WHERE a.team_id = 35 AND a.person_id = 3498 AND a.active);

COMMIT;
