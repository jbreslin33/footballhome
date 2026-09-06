-- "Club: Men" as a spelling of the mens club (owner 2026-09-05).
--
-- The 9/13 APSL game was tagged `Club: Men | Team: Liga 1, APSL`.  The
-- alias table only knew club_alias='mens', so Club x Team resolved to
-- nothing and the event never got an fh_events row — invisible to both
-- squads.  "Men" is a natural way to type it (the Boys/Girls clubs are
-- singular), so teach the classifier both spellings rather than making
-- ops remember the s.  Idempotent.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'men', a.team_alias, a.team_id, 'Spelling variant of club_alias=mens (migration 331)'
  FROM gcal_team_aliases a
 WHERE a.club_alias = 'mens'
   AND NOT EXISTS (SELECT 1 FROM gcal_team_aliases b
                    WHERE b.club_alias = 'men' AND b.team_alias = a.team_alias);
