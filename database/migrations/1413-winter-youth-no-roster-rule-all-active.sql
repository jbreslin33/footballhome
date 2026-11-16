-- 1413 (2026-11-16): winter youth teams have no league roster, so ✅ Active
-- vs 🏋 Practice Squad can't come from one (owner: "active for like generic
-- u11 means nothing. there is no roster lol", after mig 1412's move was put
-- back by the roster rule).
--   teams.games_need_roster (mig 1031/1033) derives a youth row's status
--   from the league list / Roster-pill add steps on every roster_status
--   save — that's what reverted 1412.  Turned OFF for the eight winter
--   youth teams with no league list (U6 952, U7 949, U8 953, U9 945,
--   U10 942, U11 946, U12 940, U13 947).  Fall U8/U10/U12 (912/913/914)
--   have a real league list and keep the rule.
--   Then every live row on those eight → Active (no status, not
--   invite-only), except NEEDS ONBOARD (never answered an RSVP himself:
--   no fh_event_rsvps row with created_via = 'manual') — those stay
--   Practice Squad.  Owner removes kids by hand from here.

BEGIN;

UPDATE teams SET games_need_roster = false
 WHERE id IN (940, 942, 945, 946, 947, 949, 952, 953);

UPDATE team_persons tp
   SET squad_status_id = NULL, invite_only = false, call_in = false
  FROM squad_statuses ss
 WHERE ss.code = 'practice_squad'
   AND tp.squad_status_id = ss.id
   AND tp.removed_at IS NULL
   AND tp.team_id IN (940, 942, 945, 946, 947, 949, 952, 953)
   AND EXISTS (SELECT 1 FROM fh_event_rsvps v
                WHERE v.person_id = tp.person_id AND v.created_via = 'manual');

COMMIT;
