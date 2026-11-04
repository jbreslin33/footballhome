-- 1030: David Masi (person 3500) is a ⭐ CALL-UP · every game on APSL
-- (owner 2026-11-04: "make masi call ups every game … 19 field players
-- who see apsl rsvp and 2 keepers … we need david as standing call up").
-- Standing invite to APSL (35) from Liga 1 (120) — the 🎟 Auto toggle's
-- write, as Lusayo (mig 1020): team_auto_invites + an 'auto' invite for
-- every upcoming APSL game.  His APSL 📄 paper spot (he is on the APSL
-- Active list) and his Liga 1 / Cup rows are unchanged.

BEGIN;

INSERT INTO team_auto_invites (team_id, person_id, from_team_id, active)
SELECT 35, 3500, 120, true
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 3500 AND first_name = 'David' AND last_name = 'Masi')
ON CONFLICT (team_id, person_id) DO UPDATE SET active = true, from_team_id = EXCLUDED.from_team_id;

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT fet.fh_event_id, 3500, 120, 3500, 'auto'
  FROM fh_event_teams fet
  JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
 WHERE fet.team_id = 35
   AND EXISTS (SELECT 1 FROM team_auto_invites a WHERE a.team_id = 35 AND a.person_id = 3500 AND a.active)
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = fet.fh_event_id AND i.person_id = 3500 AND i.revoked_at IS NULL);

COMMIT;
