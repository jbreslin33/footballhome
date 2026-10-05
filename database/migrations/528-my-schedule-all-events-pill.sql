-- 528 (2026-10-05) — #my: the first whose-schedule pill reads "All events".
-- Owner: "i like 'All events' instead of 'Everyone'".
UPDATE message_templates SET body = 'All events' WHERE kind = 'my_schedule' AND tier = 'who_all';
