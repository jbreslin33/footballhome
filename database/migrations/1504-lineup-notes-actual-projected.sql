-- 1504 (2026-11-18) — Lineup notes say actual AND projected, as totals.
-- Owner 11/18: "how do we handle Projected practices. I am not afraid of
-- extra text we can make graphic bigger" → "it just has to be clear
-- between actual and projected and actual total and projected total for
-- all players".
--   Made     = practices attended (actual total)
--   Projected = made + the ones still ahead they said Going to (projected total)
-- Under each name (two lines):   Made 0/5 · Need 1
--                                Projected 1/5
-- The viewer's own line:         You: Made 0 of 5 · Projected 1 of 5 · Need 1
--                                (4 practices + barn night · Projected = made + said Going)
-- {proj_total} is filled client-side (attended + projected).  A line break
-- in the body = a second line.
BEGIN;

UPDATE message_templates SET body = E'✓ Made {attended}/{chances} · Need {needed}\nProjected {proj_total}/{chances}'
 WHERE kind = 'eligibility' AND tier = 'lineup_note_made';
UPDATE message_templates SET body = E'Made {attended}/{chances} · Need {needed}\nProjected {proj_total}/{chances}'
 WHERE kind = 'eligibility' AND tier IN ('lineup_note_on_pace', 'lineup_note_short');

UPDATE message_templates SET body = E'You: ✓ Made {attended} of {chances} · Projected {proj_total} of {chances} · Need {needed}\n{what} · Projected = made + practices you said Going to'
 WHERE kind = 'eligibility' AND tier = 'lineup_you_made';
UPDATE message_templates SET body = E'You: Made {attended} of {chances} · Projected {proj_total} of {chances} · Need {needed}\n{what} · Projected = made + practices you said Going to'
 WHERE kind = 'eligibility' AND tier IN ('lineup_you_on_pace', 'lineup_you_short');

-- {what} now stands alone on the second line: "4 practices + barn night" / "practices".
UPDATE message_templates SET body = '{held} practices + {extra_label}' WHERE kind = 'eligibility' AND tier = 'chances_extra';
UPDATE message_templates SET body = '{chances} practices' WHERE kind = 'eligibility' AND tier = 'chances_plain';

COMMIT;
