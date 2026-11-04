-- 1049: Ryan Terrero (person 22349) back on December 1, the winter start
-- (owner 2026-11-04: "add ryan to ACTIVE because he will be healthy by
-- then").  His open long-term injury (since 10/2) gets a back-on day of
-- 2026-12-01 — healthy from then on its own; until then fall stays excused
-- and dues waived (mig 715).  The Team pill already shows him ACTIVE on
-- winter U12: an injury ending by the lit season's start no longer counts
-- there (GET /api/teams/terms `starts`, same day).  His winter U12 On
-- Roster row is mig 1048.

UPDATE person_injuries SET ends_at = (timestamp '2026-12-01 00:00' AT TIME ZONE 'America/New_York')
 WHERE person_id = 22349 AND ends_at IS NULL
   AND EXISTS (SELECT 1 FROM persons WHERE id = 22349 AND first_name = 'Ryan' AND last_name = 'Terrero');
