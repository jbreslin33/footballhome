-- 629: a player sees their event job on their own #my card (mig 625's
-- #jobs follow-up — "Player visibility").  No schema: the assignments
-- already live in job_assignments; this is the card copy, which is
-- never hardcoded (owner 2026-09-17).  {title} is the job_definitions
-- title; {child} the kid's first name on a guardian's card.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My page — your job on an event card', 'my_jobs', 'self_job', NULL,
       'Your job: {title}', 1, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_jobs' AND tier = 'self_job');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My page — a child''s job on an event card', 'my_jobs', 'child_job', NULL,
       '{child}''s job: {title}', 2, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_jobs' AND tier = 'child_job');
