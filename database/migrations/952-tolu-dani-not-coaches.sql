-- Owner 11/2: Tolu Asekun-Masha and Dani Ortiz are no longer coaches.  Ends
-- their team_coaches rows (history kept).  Player rosters and Tolu's volunteer
-- row are untouched.
UPDATE team_coaches tc
   SET ended_at = now()
  FROM coaches c
 WHERE c.id = tc.coach_id
   AND c.person_id IN (22598, 22607)
   AND tc.ended_at IS NULL;
