-- 873 (2026-10-30) — RSVP reminder line, take two (mig 872).  Owner: "or the
-- other players/parents on team are waiting on your response so we can
-- plan?"  Parents hear the players and parents; adult players, teammates.

UPDATE message_templates
   SET body = replace(replace(replace(body,
         'Please respond for your player''s teammates so we can plan.', 'The other players and parents on the team are waiting on your response so we can plan.'),
         'Please respond for {child}''s teammates so we can plan.',     'The other players and parents on the team are waiting on your response so we can plan.'),
         'Please respond for their teammates so we can plan.',          'The other players and parents on the team are waiting on your response so we can plan.')
 WHERE kind = 'rsvp_reminder' AND tier IN ('parent', 'multi', 'group_parent', 'group_week_parent');

UPDATE message_templates
   SET body = replace(body, 'Please respond for your teammates so we can plan.', 'Your teammates are waiting on your response so we can plan.')
 WHERE (kind = 'rsvp_reminder' AND tier IN ('adult', 'group_adult', 'group_week_adult')) OR kind = 'auto_reminder';
