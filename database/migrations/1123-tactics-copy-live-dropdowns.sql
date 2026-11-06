-- 1123 (2026-11-06) — 🧠 Game model: job dropdowns are always live for
-- coaches (owner: "i need to be able to set tactics via drop down when
-- keeper has it on out of possession high block ... this is the initial
-- instructions when keeper places ball down"); each change saves.  The
-- ✏️ button now only moves THEIR players, so its copy says so.  Tapping one
-- of ours opens his sheet (job + the concept's cue, the words the game's
-- AI plays from) — players get it read-only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Game Center — Tactics: player hint', 'tactics', 'player_hint', NULL, 'Tap yourself on the pitch to read your job in this moment.', 1232, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = 'player_hint');
UPDATE message_templates SET body = '✏️ Move their players'
 WHERE kind = 'tactics' AND tier = 'edit';
UPDATE message_templates SET body = 'Drag their players where they stand, then Save. Our spots follow from the jobs.'
 WHERE kind = 'tactics' AND tier = 'editing';
UPDATE message_templates SET body = 'Tap one of ours for his job (or use the list below) — it saves as you go. Tap one of theirs to play the ball to him.'
 WHERE kind = 'tactics' AND tier = 'pass_hint';

-- ✏️ Drawn situations (mig 1120) still drag every piece — own rows.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'tactics', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('edit_drawn',    'Game Center — Drawn: coach starts moving pieces', '✏️ Move pieces', 1230),
    ('editing_drawn', 'Game Center — Drawn: coach editing hint',         'Drag any piece — us, them or the ball — then Save.', 1231)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.t);
