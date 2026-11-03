-- 1021: revoke Armando Pena's (person 22710) leftover 'auto' invites for
-- upcoming Liga 1 games (owner 2026-11-03: "yes clean up pena's leftover
-- invites").  They came from his standing call-down, switched off in mig
-- 1015 when he went back on Liga 1 as a full spot; the per-game rows were
-- left behind (the 🎟 Auto toggle's OFF path revokes them — the migration
-- didn't).  Same revoke as that path: future games, channel auto only.

UPDATE fh_event_invites i SET revoked_at = now()
  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
 WHERE i.fh_event_id = fe.id AND i.person_id = 22710 AND i.channel = 'auto'
   AND i.revoked_at IS NULL AND ge.starts_at > now()
   AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = 120)
   AND NOT EXISTS (SELECT 1 FROM team_auto_invites a WHERE a.team_id = 120 AND a.person_id = 22710 AND a.active);
