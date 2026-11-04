-- 1023: Andy Hizdri (person 3498) is a ⭐ CALL-UP · every game on APSL and
-- a ↔ Call-in on Liga 1 (owner 2026-11-04: "Andy Hizdri should be CALL UP
-- every game for apsl and for liga 1 should not see it unless he gets
-- called in").
--   APSL (35): same shape as Lusayo (mig 1020) — his APSL roster row comes
--     off and a standing invite from Liga 1 (120) takes its place (the 🎟
--     Auto toggle's write: team_auto_invites + an 'auto' invite for every
--     upcoming APSL game), so the APSL column lists him under ⭐ CALL-UPS.
--   Liga 1 (120): invite_only + call_in (as Evan Watson, mig 1019) — no
--     Liga 1 game grants; only a CALL UP invite in Game Center shows him one.
-- USASA Cup (939) unchanged.

BEGIN;

UPDATE team_persons SET removed_at = now()
 WHERE team_id = 35 AND person_id = 3498 AND removed_at IS NULL
   AND EXISTS (SELECT 1 FROM persons WHERE id = 3498 AND first_name = 'Andy' AND last_name = 'Hizdri');

UPDATE team_persons SET invite_only = true, call_in = true
 WHERE team_id = 120 AND person_id = 3498 AND removed_at IS NULL;

INSERT INTO team_auto_invites (team_id, person_id, from_team_id, active)
SELECT 35, 3498, 120, true
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 3498 AND first_name = 'Andy' AND last_name = 'Hizdri')
ON CONFLICT (team_id, person_id) DO UPDATE SET active = true, from_team_id = EXCLUDED.from_team_id;

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT fet.fh_event_id, 3498, 120, 3498, 'auto'
  FROM fh_event_teams fet
  JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
 WHERE fet.team_id = 35
   AND EXISTS (SELECT 1 FROM team_auto_invites a WHERE a.team_id = 35 AND a.person_id = 3498 AND a.active)
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = fet.fh_event_id AND i.person_id = 3498 AND i.revoked_at IS NULL);

COMMIT;
