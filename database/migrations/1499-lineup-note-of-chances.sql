-- 1499 (2026-11-18) — "1 of 5": practices made out of the week's chances.
-- Owner 11/18: "shouldnt it be this week out of 5 (since 1 of the days is
-- barn night?) so 1 of 5 makes it?" → "yes do it, 1 of 5".
-- The bar is unchanged (mig 1497: 4 practice days held − 3 = 1 needed); the
-- words now count every chance, barn night included ({chances} = days in
-- the week's window, computed client-side from the practice list).
--   Under each name:  ✓ 1 of 5  (green) · 0 of 5 · need 1  (yellow on pace /
--   red short — the colour says which).
--   Card rule line:   rule_week_extra when a non-held day (barn night) is in
--   the week; rule_week reworded to the same shape.
BEGIN;

UPDATE message_templates SET body = '✓ {attended} of {chances}'
 WHERE kind = 'eligibility' AND tier = 'lineup_note_made';
UPDATE message_templates SET body = '{attended} of {chances} · need {needed}'
 WHERE kind = 'eligibility' AND tier IN ('lineup_note_on_pace', 'lineup_note_short');

UPDATE message_templates SET body = '{chances} practice days this week (Mon–Sat) — make {needed} of {chances} to start. Last week''s don''t count. Attendance is taken at every practice; a Going RSVP shows as projected until you are marked present.'
 WHERE kind = 'eligibility' AND tier = 'rule_week';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', 'Week rule — with barn night', 'eligibility', 'rule_week_extra', NULL,
       '{chances} chances this week ({held} practices + {extra_label}) — make {needed} of {chances} to start. Last week''s don''t count. Attendance is taken at every one; a Going RSVP shows as projected until you are marked present.',
       (SELECT sort_order FROM message_templates WHERE kind = 'eligibility' AND tier = 'rule_week' LIMIT 1), true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'eligibility' AND tier = 'rule_week_extra');

COMMIT;
