-- Mohamed Conde (person 22608) to INACTIVE (owner 2026-11-03): still pays
-- dues, no RSVP asks.  Both his teams: Liga 1 (120) and the USASA Cup pool
-- (939), else the cup row keeps asking him about cup games.  Same write as
-- the #teams Team pill; his own yes RSVP brings him back (mig 945).
UPDATE team_persons
   SET invite_only = true, call_in = false,
       squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE person_id = 22608 AND team_id IN (120, 939) AND removed_at IS NULL;
