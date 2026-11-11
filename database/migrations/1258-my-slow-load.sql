-- 1258 (2026-11-11) — #my says so when the first load is slow.
-- A player sat on "Loading…" this morning while the server was overloaded
-- (the fetch had no limit).  After 15 s #my shows these words and a retry
-- button; the request keeps going and the week replaces the note if it lands.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'My schedule', v.label, 'my_schedule', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('slow_load',  '#my — first load past 15 s', 'Taking longer than usual…', 900),
    ('slow_retry', '#my — retry button',          'Tap to try again', 901)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'my_schedule' AND t.tier = v.tier);
