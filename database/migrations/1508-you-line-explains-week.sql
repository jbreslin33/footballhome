-- 1508 (2026-11-18) — The "You:" line on the men's game card explains the
-- week.  Owner 11/18: "the YOU: section is confusing. it should explain that
-- because its a barn week and not all players can attend barn night because
-- you need to be 21 then we are in a 4 day practice week so 1 practice is
-- needed to be starter eligible. but barn night attendance counts as a
-- practice too".
--   line 1  You: Made 0 · Projected 1 · Need 1
--   line 2  {week} — why the need is what it is
--   line 3  what Projected means
-- {week}: you_week_barn on a barn-night week (mig 1497), you_week_plain else.
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.label, 'eligibility', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('You line — barn-night week', 'you_week_barn',
     'Barn night week: barn night is 21+ only, so this is a {held}-practice week and {needed} practice{needed_s} makes you starter eligible. Going to barn night counts as a practice too.', 79),
    ('You line — normal week', 'you_week_plain',
     '{held} practice days this week, so {needed} practice{needed_s} makes you starter eligible.', 80)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'eligibility' AND m.tier = v.tier);

UPDATE message_templates SET body = E'You: ✓ Made {attended} · Projected {proj_total} · Needed {needed}\n{week}\nProjected = made + practices you said Going to.'
 WHERE kind = 'eligibility' AND tier = 'lineup_you_made';
UPDATE message_templates SET body = E'You: Made {attended} · Projected {proj_total} · Need {needed}\n{week}\nProjected = made + practices you said Going to.'
 WHERE kind = 'eligibility' AND tier IN ('lineup_you_on_pace', 'lineup_you_short');

COMMIT;
