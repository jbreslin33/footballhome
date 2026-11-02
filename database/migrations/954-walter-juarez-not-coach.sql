-- Owner 11/2: Walter Juarez de Leon is no longer a coach.  Ends the
-- team_coaches rows (history kept).  Any player roster row is untouched.
UPDATE team_coaches tc
   SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id
   AND c.person_id = 22536
   AND tc.ended_at IS NULL;
