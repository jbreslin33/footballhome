-- 615 (2026-10-20) — Soften the dues-alternate wording: a consequence that
-- COULD happen, not a label already worn.
--
-- Owner: "dont say they are an alternate. say they will be at bottom of
-- selection list for starters and bench and that could lead to being
-- listed as alternate 'if dues are not paid'."
--
-- Same soft-consequence register as the months-behind payment notices
-- ("could lead shortly …").  Copy only — migs 613/614's mechanics are
-- unchanged.

UPDATE message_templates
   SET body = 'Dues {amount} owed — you''ll be at the bottom of the selection list for starters and bench for men''s games, which could lead to being listed as an alternate if dues are not paid. Any payment moves you back up.'
 WHERE kind = 'my_dues' AND tier = 'alternate_banner';

UPDATE message_templates
   SET body = 'Dues {amount} owed — you''ll be at the bottom of the selection list for starters and bench for this game, which could lead to being listed as an alternate if dues are not paid. Any payment moves you back up.'
 WHERE kind = 'my_dues' AND tier = 'alternate_game';

UPDATE message_templates
   SET body = 'Dues owed · bottom of selection list'
 WHERE kind = 'my_dues' AND tier = 'alternate_chip';
