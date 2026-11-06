-- 1111: Sunday's APSL game vs Westtown FC (fh_event 75728095, match 9356,
-- Sun 11/8) — owner 2026-11-06: "take out red color for players for
-- sunday apsl ... andy is in red".  The game needs 0 practices (weekday
-- game this week, fh_starter_needed), so only a late RSVP turns a name
-- red: the deadline was Fri 11/6 00:00 ET and Andy Hizdri (3498) first
-- answered at 1:14 AM.  Waive the deadline for the whole game, as mig
-- 1087 did for Thursday's APSL game at Vidas.
INSERT INTO rsvp_deadline_waivers (fh_event_id, reason)
SELECT 75728095, 'Owner 11/6: no red for APSL vs Westtown FC Sunday'
 WHERE EXISTS (SELECT 1 FROM fh_events WHERE id = 75728095)
ON CONFLICT (fh_event_id) DO NOTHING;
