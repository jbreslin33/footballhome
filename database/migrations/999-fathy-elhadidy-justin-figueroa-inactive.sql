-- Fathy Elhadidy (person 22765) and Justin Figueroa (person 22299) to
-- INACTIVE (owner 2026-11-03: "make fathy inactive", "make justin inactive
-- figueroa"): still pay dues, no RSVP asks.  Every live team row — Fathy on
-- Liga 1 (120), APSL Reserves (938) and the USASA Cup pool (939); Justin on
-- Mens Club 1893 (35) and the cup pool (939) — else the cup row keeps
-- asking about cup games.  Same write as the #teams Team pill; their own
-- yes RSVP brings them back (mig 945); the fine waiver opens by trigger
-- (mig 997).
UPDATE team_persons
   SET invite_only = true, call_in = false,
       squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive')
 WHERE person_id IN (22765, 22299) AND removed_at IS NULL;
