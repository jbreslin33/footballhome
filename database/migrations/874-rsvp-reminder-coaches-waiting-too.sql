-- 874 (2026-10-30) — RSVP reminder line, mig 873 plus the coaches, who are
-- the ones planning (owner: "like the other players etc, coaches").

UPDATE message_templates
   SET body = replace(body, 'The other players and parents on the team are waiting', 'The other players, parents and coaches on the team are waiting')
 WHERE kind = 'rsvp_reminder' AND tier IN ('parent', 'multi', 'group_parent', 'group_week_parent');

UPDATE message_templates
   SET body = replace(body, 'Your teammates are waiting', 'Your teammates and coaches are waiting')
 WHERE (kind = 'rsvp_reminder' AND tier IN ('adult', 'group_adult', 'group_week_adult')) OR kind = 'auto_reminder';
