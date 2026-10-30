-- 872 (2026-10-30) — RSVP reminders say why: the team is waiting.
--
-- Owner: "for reminders for games and practices we need a line that states
-- for your teammates so we can plan please respond … players/parents that
-- just ignore these messages."  One line in every reminder a coach sends
-- (person, parent, multi-kid, group) and the automatic one, right before
-- the link, games and practices alike.

UPDATE message_templates
   SET body = replace(body, '[[ {deadline}]] {link}', '[[ {deadline}]] Please respond for your teammates so we can plan. {link}')
 WHERE kind = 'rsvp_reminder' AND tier = 'adult' AND body NOT LIKE '%so we can plan%';

UPDATE message_templates
   SET body = replace(body, '[[ {deadline}]] {link}', '[[ {deadline}]] Please respond for {child}''s teammates so we can plan. {link}')
 WHERE kind = 'rsvp_reminder' AND tier = 'parent' AND body NOT LIKE '%so we can plan%';

UPDATE message_templates
   SET body = replace(body, '[[ {deadline}]] {link}', '[[ {deadline}]] Please respond for their teammates so we can plan. {link}')
 WHERE kind = 'rsvp_reminder' AND tier = 'multi' AND body NOT LIKE '%so we can plan%';

UPDATE message_templates
   SET body = replace(body, ': footballhome.org', ': footballhome.org Please respond for your teammates so we can plan.')
 WHERE kind = 'rsvp_reminder' AND tier IN ('group_adult', 'group_week_adult') AND body NOT LIKE '%so we can plan%';

UPDATE message_templates
   SET body = replace(body, ': footballhome.org', ': footballhome.org Please respond for your player''s teammates so we can plan.')
 WHERE kind = 'rsvp_reminder' AND tier IN ('group_parent', 'group_week_parent') AND body NOT LIKE '%so we can plan%';

UPDATE message_templates
   SET body = replace(body, 'is a team rule.', 'is a team rule. Please respond for your teammates so we can plan.')
 WHERE kind = 'auto_reminder' AND body NOT LIKE '%so we can plan%';
