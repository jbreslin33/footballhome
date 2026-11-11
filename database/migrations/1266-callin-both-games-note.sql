-- 1266 (2026-11-11) — 🙋 Call-in card: asking does NOT stop you playing Liga 1.
--
-- Owner 2026-11-11: "lets let players know that requesting call in does NOT
-- prevent them from also playing liga 1. for this weekend (and you can do
-- math and time and drive time) you can say they can leave after liga 1
-- game and they will arrive at x time for apsl and that is fine".
--
-- #my works it out per card: his own game earlier the same day (the Liga 1
-- game) → its end + the drive (place_drive_times × traffic factor + parking
-- buffer, schedule_conflict_policies — the same sum the clash check uses),
-- rounded up to the policy's minutes.  Sunday 11/15: Liga 1 ends 1:45 PM in
-- Warminster, 31 min raw → ~49 min → about 2:35 PM; APSL kicks off 2:30 PM.
-- No earlier game that day → just the "you can do both" line.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Call-in', v.label, 'callin', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('both_note',  '#my — asking does not stop the Liga game ({from})',
                   'Asking doesn''t stop you playing {from} — you can do both.', 7),
    ('after_game', '#my — leave after his earlier game ({from} {end} {place} {arrive} {minutes} {kickoff})',
                   '{from} ends about {end} in {place}. Leave right after and you''ll get here about {arrive} (~{minutes} min drive) — kickoff is {kickoff}. That''s fine.', 8)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'callin' AND t.tier = v.tier);
