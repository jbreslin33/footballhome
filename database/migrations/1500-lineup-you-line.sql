-- 1500 (2026-11-18) — The viewer's own practice line above the lineup.
-- Owner 11/18: "for a player they only need to know about themselves … so
-- maybe we make it more explicit for them. in a line above the lineup" →
-- "if we can show everyone else to the player then that is optimal".
-- Everyone keeps the "1 of 5" notes under each name (mig 1499); a player
-- (not staff) also gets this line about themselves.  Tokens as the card:
-- {attended} {chances} {needed} {left}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', v.label, 'eligibility', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Lineup — your line, made it', 'lineup_you_made',    'You: ✓ {attended} of {chances} — you made it this week', 73),
    ('Lineup — your line, on pace', 'lineup_you_on_pace', 'You: {attended} of {chances} · need {needed} — on pace if you make the practice you said Going to', 74),
    ('Lineup — your line, short',   'lineup_you_short',   'You: {attended} of {chances} · need {needed} — say Going to a practice and make it', 75)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'eligibility' AND m.tier = v.tier);
