-- 1267 (2026-11-11) — 🙋 Call-in card wording, plainer (owner 2026-11-11:
-- "you can do both. just leave after liga 1 is over to goto apsl. etc").
-- Rows from mig 1266; the arrival time stays (worked out per card).

UPDATE message_templates SET body = 'You can do both — just leave after {from} is over and head to APSL.'
 WHERE kind = 'callin' AND tier = 'both_note';
UPDATE message_templates SET body = 'You can do both — just leave after {from} is over and head to APSL. You''ll get here about {arrive} (kickoff {kickoff}) and that''s fine.'
 WHERE kind = 'callin' AND tier = 'after_game';
