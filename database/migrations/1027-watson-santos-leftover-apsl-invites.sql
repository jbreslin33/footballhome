-- 1027: revoke Evan Watson's (22589) and Lucca Santos's (22698) leftover
-- 'auto' invites "from Liga 1" for upcoming APSL games (owner 2026-11-04:
-- "yes").  Both are full ACTIVE spots on APSL now (migs 1016, 1018) and
-- their standing call-ups are off (migs 1013, 1018), but the per-game rows
-- stayed — so Event Center could show them as ⭐ CALL-UP instead of with
-- the team.  Same revoke as mig 1021: future games, channel auto only,
-- only while no standing call-up is active.

UPDATE fh_event_invites i SET revoked_at = now()
  FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
 WHERE i.fh_event_id = fe.id AND i.person_id IN (22589, 22698) AND i.channel = 'auto'
   AND i.revoked_at IS NULL AND ge.starts_at > now()
   AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = 35)
   AND NOT EXISTS (SELECT 1 FROM team_auto_invites a WHERE a.team_id = 35 AND a.person_id = i.person_id AND a.active);
