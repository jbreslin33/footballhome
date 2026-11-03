-- 994-auto-invites-on-team-change.sql
--
-- Owner 11/3: "evan watson not seeing apsl games! why?"  Evan, Isaac
-- Anderson and Lucca Santos ride every APSL game by standing call-down
-- (team_auto_invites, mig 617), but Thursday's APSL at Vidas United
-- (fh_event 75692361) had no invite for any of them — the only game
-- released this week, so they saw no APSL game at all.  Mig 617's trigger
-- fires only on INSERT into fh_event_teams; a game whose team link is
-- changed in place (UPDATE of team_id) never invited anyone.
--
-- Now the trigger also fires on UPDATE OF team_id / fh_event_id, and every
-- upcoming game is back-filled (same rule as mig 617: a revoked invite is
-- left revoked — only people with no live invite get one).

DROP TRIGGER IF EXISTS trg_team_auto_invites ON fh_event_teams;
CREATE TRIGGER trg_team_auto_invites
AFTER INSERT OR UPDATE OF team_id, fh_event_id ON fh_event_teams
FOR EACH ROW EXECUTE FUNCTION fh_apply_team_auto_invites();

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT DISTINCT fet.fh_event_id, a.person_id, a.from_team_id, a.person_id, 'auto'
  FROM team_auto_invites a
  JOIN fh_event_teams fet ON fet.team_id = a.team_id
  JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
 WHERE a.active
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = fet.fh_event_id AND i.person_id = a.person_id);
