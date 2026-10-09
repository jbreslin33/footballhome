-- 551 (2026-10-09) — #dashboard: the RSVP fraction is answered over
-- expected.  Owner: "lets reverse the fraction lol. so amount that rsvp
-- over total possible".  {n} is now the answered count.
UPDATE message_templates SET body = '{n}/{of} rsvp', label = 'RSVP cell — one event row ({n} answered {of} expected)'
 WHERE kind = 'dashboard' AND tier = 'rsvp_row';
UPDATE message_templates SET body = 'Released games this week · rsvp''d of expected'    WHERE kind = 'dashboard' AND tier = 'rsvp_games_sub';
UPDATE message_templates SET body = 'Released practices this week · rsvp''d of expected' WHERE kind = 'dashboard' AND tier = 'rsvp_practices_sub';
