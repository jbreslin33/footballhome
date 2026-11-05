-- 1087: tonight's APSL game at Vidas United (fh_event 75692361, Thu 11/5)
-- — owner 2026-11-05: "make everyone green for apsl tonight" (the Game
-- Center starters/bench graphic).  The game needs 0 practices (weekday
-- game, fh_starter_needed), so only a late RSVP turned names red; waive
-- the deadline for the whole game, as mig for Liga 1 vs Desert Hawks did.
INSERT INTO rsvp_deadline_waivers (fh_event_id, reason)
SELECT 75692361, 'Owner 11/5: everyone green for APSL at Vidas United tonight'
 WHERE EXISTS (SELECT 1 FROM fh_events WHERE id = 75692361)
ON CONFLICT (fh_event_id) DO NOTHING;
