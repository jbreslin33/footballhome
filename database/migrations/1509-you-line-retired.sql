-- 1509 (2026-11-18) — The "You:" line is gone: every player's status, the
-- reader's own included, is in the boxes; the card carries one explanation
-- box for everyone instead (owner 11/18 "its not a you section it should be
-- an explanation section").  The box = you_week_barn / you_week_plain +
-- strip_legend.  The You-line copy rows retire.
UPDATE message_templates SET is_active = false
 WHERE kind = 'eligibility' AND tier IN ('lineup_you_made', 'lineup_you_on_pace', 'lineup_you_short', 'chances_extra', 'chances_plain');
