-- 1268 (2026-11-11) — 🙋 Call-in card: say exactly what to do for THIS pair
-- of games (owner 2026-11-11: "basically just tell them what to do for that
-- particular games set").  Tokens worked out per card (mig 1266): {from}
-- his earlier game's team, {start} / {end} / {place} that game, {to} the
-- APSL venue, {minutes} the drive, {arrive}, {kickoff}.

UPDATE message_templates
   SET body = 'Play {from} first ({start} in {place}). Leave as soon as it ends (~{end}) and drive straight to {to} (~{minutes} min). You''ll get there about {arrive} for the {kickoff} kickoff — that''s fine.',
       label = '#my — what to do with his earlier game ({from} {start} {end} {place} {to} {minutes} {arrive} {kickoff})'
 WHERE kind = 'callin' AND tier = 'after_game';

-- And the other order (owner 2026-11-11: "if apsl was first they would
-- leave apsl when over and goto liga 1"): {start} / {place} the APSL game,
-- {end} its end, {to} the Liga town, {kickoff} the Liga kick-off.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Call-in', '#my — APSL first, then his Liga game ({from} {start} {end} {place} {to} {minutes} {arrive} {kickoff})',
       'callin', 'before_game', NULL,
       'APSL is first ({start} at {place}). Leave as soon as it ends (~{end}) and drive straight to {from} in {to} (~{minutes} min). You''ll get there about {arrive} for the {kickoff} {from} kickoff — that''s fine.',
       9, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'callin' AND t.tier = 'before_game');
