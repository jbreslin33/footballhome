-- 1412 (2026-11-16): every youth team row → ✅ Active, except NEEDS ONBOARD
-- (owner: "move them all to Active … then i can remove as we go" + "for
-- youth" + "except needs onboard ones").
--   Active on the board = no squad status and not invite-only
--   (RosterScreenBase.columnCategoryOf); same write as the ⋯ sheet's
--   "Plays" choice.  Needs onboard = never answered an RSVP himself
--   (fh_event_rsvps.created_via = 'manual', the PersonStanding rule) — those
--   rows stay 🔵 Practice Squad.  No youth row was 🩹 / 💤, so nothing else
--   is touched.  Applied: 72 rows moved, 8 needs-onboard rows kept — then
--   PUT BACK by the games_need_roster trigger on the next roster save;
--   superseded by mig 1413 (rule off for the winter teams).

UPDATE team_persons tp
   SET squad_status_id = NULL, invite_only = false, call_in = false
  FROM teams t
  JOIN squad_statuses ss ON ss.code = 'practice_squad'
 WHERE t.id = tp.team_id
   AND tp.removed_at IS NULL
   AND tp.squad_status_id = ss.id
   AND tp.team_id IN (912, 913, 914, 940, 942, 945, 946, 947, 949, 952, 953, 966, 967, 968)
   AND EXISTS (SELECT 1 FROM fh_event_rsvps v
                WHERE v.person_id = tp.person_id AND v.created_via = 'manual');
