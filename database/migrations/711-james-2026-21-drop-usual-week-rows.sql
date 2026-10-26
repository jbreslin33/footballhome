-- 711 (2026-10-26) — same cleanup as mig 576 did for 2026.20, now for
-- James's 2026.21 (invoice id 12): the draft was auto-made 10/11, before
-- "NO standard week anywhere", and still carried 12 bare usual-week rows
-- (no event, no note — owner: "i see on calendar a 5p to 9pm lol there is
-- no event in gcal like that").  38.25 h; they also caused most of the
-- sheet's overlaps.  Removed rows, for the record (date start–end / hours):
--   10/9 17:00–21:00, 10/10 11:00–13:00, 10/12 16:00–19:00, 10/13 18:30–21:00,
--   10/14 16:00–21:00, 10/15 18:30–21:00, 10/16 4.25 h, 10/17 11:00–13:00,
--   10/19 16:00–19:00, 10/20 18:30–21:00, 10/21 16:00–21:00, 10/22 18:30–21:00
DELETE FROM invoice_work_shifts
 WHERE invoice_id = 12 AND fh_event_id IS NULL AND gcal_event_id IS NULL
   AND note IS NULL AND created_at < '2026-10-12'
   AND (SELECT NOT is_final FROM invoices WHERE id = 12);
-- labor line = the remaining stints (Invoice::syncLabor's sum)
WITH h AS (SELECT COALESCE(SUM(COALESCE(hours, EXTRACT(EPOCH FROM (end_at - start_at)) / 3600.0)), 0) AS hours
             FROM invoice_work_shifts WHERE invoice_id = 12)
UPDATE invoice_lines l SET quantity = ROUND(h.hours::numeric, 2),
       amount = CASE WHEN l.rate IS NULL THEN l.amount ELSE ROUND(ROUND(h.hours::numeric, 2) * l.rate, 2) END
  FROM h WHERE l.invoice_id = 12 AND l.category = 'labor'
   AND (SELECT NOT is_final FROM invoices WHERE id = 12);
UPDATE invoices SET updated_at = now() WHERE id = 12;
