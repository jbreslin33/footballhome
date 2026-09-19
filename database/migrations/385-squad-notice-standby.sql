-- 385 — Squad game reminder: alternates are on standby, not on hold.
--
-- Owner 2026-09-19: "we need to tailor a message for the alt players who
-- are not starter and not bench … You're on standby for the 20 man game
-- day roster, if a spot opens we will message you. In the meantime to
-- take yourself off that list for the week change availability for that
-- game if you want to make other plans."
--
-- Mig 384 told an alternate to "keep the day free" and gave them an
-- arrival time, which reads like a call-up.  Standby asks for nothing:
-- no where/arrival (a promoted player gets those in the bench or starter
-- message through "resend to changed"), and an explicit way out.
UPDATE message_templates
   SET label = 'Game reminder — standby',
       body  = E'Hi {first} — game update. You''re ON STANDBY for:\n{event}\n\n'
               'Standby means you''re an alternate for the 20-player game-day roster. If a spot opens we''ll message you right away with where and when to be there.\n\n'
               'In the meantime you don''t have to hold the day. If you''d rather make other plans, change your availability for this game to Not Going and we''ll take you off standby for the week — no password needed: {link}\n\n'
               'The roster is subject to change — if it does we''ll let you know.\n\n— {sender}, Lighthouse 1893'
 WHERE kind = 'squad_notice' AND tier = 'alternate_adult';

-- Youth game-day rosters are not 20, so the parent row names no number.
UPDATE message_templates
   SET label = 'Game reminder — standby, parent',
       body  = E'Hi {first} — game update. {child} is ON STANDBY for:\n{event}\n\n'
               'Standby means {child} is an alternate for the game-day roster. If a spot opens we''ll message you right away with where and when to be there.\n\n'
               'In the meantime you don''t have to hold the day. If you''d rather make other plans, change {child}''s availability for this game to Not Going and the coaches will take {child} off standby for the week — no password needed: {link}\n\n'
               'The roster is subject to change — if it does we''ll let you know.\n\n— {sender}, Lighthouse 1893'
 WHERE kind = 'squad_notice' AND tier = 'alternate_parent';

-- The group message's one-line legend says the same thing.
UPDATE message_templates
   SET body = replace(body,
       'Alternate = first in if a spot opens, so keep the day free.',
       'Alternate = on standby: we''ll message you if a spot opens, and you can set Not Going if you''d rather make other plans.')
 WHERE kind = 'squad_notice' AND tier IN ('group_adult', 'group_parent');
