-- 875 (2026-10-30) — the Game Center game reminder carries the line too.
-- Migs 872–874 covered the rsvp_reminder and auto_reminder templates; the
-- squad_notice pool tiers (mig 593) are the other message that asks for an
-- answer.  Starter / bench / standby notices announce, so they stay as is.

UPDATE message_templates
   SET body = replace(body, 'Are you going? ', 'Are you going? Your teammates and coaches are waiting on your response so we can plan. ')
 WHERE kind = 'squad_notice' AND tier = 'pool_adult' AND body NOT LIKE '%so we can plan%';

UPDATE message_templates
   SET body = replace(body, 'Is {child} going? ', 'Is {child} going? The other players, parents and coaches on the team are waiting on your response so we can plan. ')
 WHERE kind = 'squad_notice' AND tier = 'pool_parent' AND body NOT LIKE '%so we can plan%';
