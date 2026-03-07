-- Manual attendance overrides (exported 2026-03-07)
-- 2 override(s)
-- Loaded after make sync to overlay on GroupMe-seeded attendance

INSERT INTO training_attendance (player_id, chat_event_id, attended, source, override_note)
SELECT p.id, ce.id, false, 'manual', NULL
FROM players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN chat_events ce
WHERE pe.first_name = 'James'
  AND pe.last_name = 'Breslin'
  AND ce.title = 'Liga 1 vs West Chester State Cup'
  AND ce.event_date = '2026-03-06'
ON CONFLICT (player_id, chat_event_id)
DO UPDATE SET attended = EXCLUDED.attended, source = 'manual', override_note = EXCLUDED.override_note;

INSERT INTO training_attendance (player_id, chat_event_id, attended, source, override_note)
SELECT p.id, ce.id, true, 'manual', NULL
FROM players p
JOIN persons pe ON pe.id = p.person_id
CROSS JOIN chat_events ce
WHERE pe.first_name = 'Fabian'
  AND pe.last_name = 'Padilla'
  AND ce.title = 'Friday Training'
  AND ce.event_date = '2026-03-06'
ON CONFLICT (player_id, chat_event_id)
DO UPDATE SET attended = EXCLUDED.attended, source = 'manual', override_note = EXCLUDED.override_note;

