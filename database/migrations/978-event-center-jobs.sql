-- 978-event-center-jobs.sql
--
-- Owner 11/3: "i should also see jobs in event center for that event" →
-- "yes build it".  The event screen's All Players pill gets a 🧹 Jobs
-- section (the same /api/jobs/event/:id the #jobs board uses, which also
-- runs the auto-fill).  Staff only, like #jobs; editing stays on #jobs.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.* FROM (VALUES
  ('Event Center', 'Jobs: section heading',            'event_center', 'sec_jobs',      NULL, '🧹 Jobs', 1199, true, true, false),
  ('Event Center', 'Jobs: filled count ({filled} {needed})', 'event_center', 'jobs_filled', NULL, '{filled} of {needed} filled', 1199, true, true, false),
  ('Event Center', 'Jobs: button to the #jobs board',  'event_center', 'jobs_edit',     NULL, '✏️ Edit on Jobs board', 1199, true, true, false),
  ('Event Center', 'Jobs: an unfilled spot',           'event_center', 'jobs_open_slot', NULL, 'Open', 1199, true, true, false),
  ('Event Center', 'Jobs: a job switched off for this event', 'event_center', 'jobs_off', NULL, 'Off for this event', 1199, true, true, false),
  ('Event Center', 'Jobs: flagged not done',           'event_center', 'jobs_not_done', NULL, 'not done', 1199, true, true, false)
) AS v(category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.kind AND m.tier = v.tier);
