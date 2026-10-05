-- 523 (2026-10-05) — #my: the schedule is grouped into day cells.
-- Owner: "for rsvp screen we need separators on days. its too confusing for
-- coaches and me and prob players too. like it should look like a calendar
-- screen. with the days events in a cell in order".
--
-- Every list on #my (This week / All / Games / Practices and the past
-- ranges) now draws one bordered cell per day — weekday and date on top,
-- that day's events inside in time order.  This week also shows the days
-- in between with nothing on, so the week reads like a calendar.  The words
-- on the cells are these rows (kind my_schedule, mig 396 pattern).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'my_schedule', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES ('day_today',    'My schedule — day cell: today',          'Today',             9),
               ('day_tomorrow', 'My schedule — day cell: tomorrow',       'Tomorrow',          10),
               ('day_empty',    'My schedule — day cell: nothing that day', 'Nothing scheduled', 11)) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'my_schedule' AND m.tier = v.tier);
