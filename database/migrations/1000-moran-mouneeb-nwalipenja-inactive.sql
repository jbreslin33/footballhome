-- Christopher Moran (person 22300), Ahmed Mouneeb (22527) and Zion
-- Nwalipenja (3503) to INACTIVE (owner 2026-11-03: "make christopher moran
-- inactive", "make ahmed mouneeb inactive", "make zion inactive."): still
-- pay dues, no RSVP asks.  Each is on Liga 1 (120) and the USASA Cup pool
-- (939) — both rows, else the cup row keeps asking about cup games.  Same
-- write as the #teams Team pill; their own yes RSVP brings them back
-- (mig 945); the fine waiver opens by trigger (mig 997).
UPDATE team_persons
   SET invite_only = true, call_in = false,
       squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE person_id IN (22300, 22527, 3503) AND removed_at IS NULL;
