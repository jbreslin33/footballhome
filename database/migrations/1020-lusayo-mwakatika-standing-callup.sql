-- 1020: Lusayo Mwakatika (person 22298) is a ⭐ CALL-UP · every game on
-- APSL (owner 2026-11-03: "Lusayo Mwakatika should be call up every game
-- cat").  Standing invite to APSL (35) from Liga 1 (120) — the same write
-- as the 🎟 Auto toggle (CalendarController, mig 617): the team_auto_invites
-- row plus an 'auto' invite for every upcoming APSL game.  His Liga 1 and
-- APSL Reserves rows are unchanged.

BEGIN;

INSERT INTO team_auto_invites (team_id, person_id, from_team_id, active)
SELECT 35, 22298, 120, true
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22298 AND first_name = 'Lusayo' AND last_name = 'Mwakatika')
ON CONFLICT (team_id, person_id) DO UPDATE SET active = true, from_team_id = EXCLUDED.from_team_id;

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT fet.fh_event_id, 22298, 120, 22298, 'auto'
  FROM fh_event_teams fet
  JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
 WHERE fet.team_id = 35
   AND EXISTS (SELECT 1 FROM team_auto_invites a WHERE a.team_id = 35 AND a.person_id = 22298 AND a.active)
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = fet.fh_event_id AND i.person_id = 22298 AND i.revoked_at IS NULL);

COMMIT;
