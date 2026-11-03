-- Yancarlo Corredor (person 22221) to INACTIVE (owner 2026-11-03): still
-- pays dues, no RSVP asks.  Liga 1 (120) and the USASA Cup pool (939);
-- his Pickup (909) row is left as it is.  Same write as the #teams Team
-- pill; his own yes RSVP brings him back (mig 945).
UPDATE team_persons
   SET invite_only = true, call_in = false,
       squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE person_id = 22221 AND team_id IN (120, 939) AND removed_at IS NULL;
