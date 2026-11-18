-- 1501 (2026-11-18) — Your line names what the chances are.
-- Owner 11/18: "should we say at top You: .... x of practices?" → "yes go
-- with that": "You: 0 of 5 (4 practices + barn night) · need 1", or
-- "You: 0 of 4 practices · need 1" in a week without barn night.
-- {what} is filled from chances_extra / chances_plain.  The notes under
-- each name stay the short "0 of 5 · need 1" (mig 1499).
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.label, 'eligibility', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Chances — with a non-practice day', 'chances_extra', '({held} practices + {extra_label})', 76),
    ('Chances — practices only',          'chances_plain', 'practices',                         77)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'eligibility' AND m.tier = v.tier);

UPDATE message_templates SET body = 'You: ✓ {attended} of {chances} {what}'
 WHERE kind = 'eligibility' AND tier = 'lineup_you_made';
UPDATE message_templates SET body = 'You: {attended} of {chances} {what} · need {needed}'
 WHERE kind = 'eligibility' AND tier IN ('lineup_you_on_pace', 'lineup_you_short');

COMMIT;
