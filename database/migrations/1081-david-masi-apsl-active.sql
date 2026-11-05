-- 1081: David Masi (3500) ACTIVE on APSL (35) (owner 2026-11-05: "put masi
-- as active").  He was 💤 Inactive there since mig 1074 (his old 📄 paper
-- spot) and rode every APSL game on a ⭐ standing call-up (mig 1030).  As a
-- full APSL player the standing call-up is redundant: it is turned off and
-- its future automatic invites withdrawn, so his card reads as a squad
-- player, not a call-up.  His answers stay.  Liga 1 unchanged (ACTIVE).

BEGIN;

UPDATE team_persons SET squad_status_id = NULL, invite_only = false, call_in = false
 WHERE team_id = 35 AND person_id = 3500 AND removed_at IS NULL;

UPDATE team_auto_invites SET active = false WHERE team_id = 35 AND person_id = 3500;

UPDATE fh_event_invites i SET revoked_at = now()
  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
 WHERE i.fh_event_id = fe.id AND i.person_id = 3500 AND i.channel = 'auto'
   AND i.revoked_at IS NULL AND ge.starts_at > now()
   AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = 35);

COMMIT;
