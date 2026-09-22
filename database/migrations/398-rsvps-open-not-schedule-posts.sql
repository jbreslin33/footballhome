-- 398 — "the schedule posts Sunday" → "RSVPs open Sunday".
--
-- With the My Schedule pills (migration 396/397) the future schedule is
-- always visible; what the Sunday release opens is the week's RSVPs.
UPDATE message_templates SET updated_at = now(), body =
  'There''s nothing left to RSVP to this week — that''s expected. Next week''s RSVPs open {release_day} at {release_time}; tap "All" on the page to see what''s coming.'
 WHERE kind = 'welcome_no_events' AND tier = 'adult';
UPDATE message_templates SET updated_at = now(), body =
  'There''s nothing left to RSVP to for {child} this week — that''s expected. Next week''s RSVPs open {release_day} at {release_time}; tap "All" on the page to see what''s coming.'
 WHERE kind = 'welcome_no_events' AND tier = 'parent';
UPDATE message_templates SET updated_at = now(), body =
  'You''re not placed on a team yet, so the page will look empty for now — your events appear as soon as you''re on a team. Each week''s RSVPs open {release_day} at {release_time}.'
 WHERE kind = 'welcome_no_team' AND tier = 'adult';
UPDATE message_templates SET updated_at = now(), body =
  '{child} isn''t placed on a team yet, so the page will look empty for now — events appear as soon as {child} is on a team. Each week''s RSVPs open {release_day} at {release_time}.'
 WHERE kind = 'welcome_no_team' AND tier = 'parent';

-- #my, empty week: the line under "Nothing on your calendar this week".
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My Schedule — empty week, when next week opens', 'my_schedule', 'next_week_opens', NULL,
       'Next week''s RSVPs open {when}.', 8, true
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'next_week_opens');
