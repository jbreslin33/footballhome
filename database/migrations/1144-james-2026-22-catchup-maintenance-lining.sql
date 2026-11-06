-- Owner 2026-11-06: "add it to this one" — two calendar work stints that fall
-- in 2026.21's window (10/9–10/22, already out) go on James's 2026.22
-- (invoice 20) as catch-up hours, keyed to their gcal events:
--   Thu 10/15 12:30–17:30  Soccer Field Maintenance  5 h
--   Fri 10/16 15:30–17:30  Soccer Field Lining       2 h
-- 2026.21 (invoice 12) gets a ✗ for each so its draft check (the
-- Soccer Field Lining claim, mig 1142) can never bill them a second time.
BEGIN;
INSERT INTO invoice_work_shifts (invoice_id, work_date, start_at, end_at, note, gcal_event_id, cal_end_at)
SELECT 20, (g.starts_at AT TIME ZONE 'America/New_York')::date,
       (g.starts_at AT TIME ZONE 'America/New_York')::time, (g.ends_at AT TIME ZONE 'America/New_York')::time,
       BTRIM(g.summary) || ' (' || to_char(g.starts_at AT TIME ZONE 'America/New_York', 'FMMM/FMDD') || ', catch-up)',
       g.id, (g.ends_at AT TIME ZONE 'America/New_York')::time
  FROM gcal_events g
 WHERE g.id IN (44049, 48026) AND g.deleted_at IS NULL AND g.status IS DISTINCT FROM 'cancelled'
   AND NOT EXISTS (SELECT 1 FROM invoice_work_shifts s WHERE s.gcal_event_id = g.id);

INSERT INTO invoice_event_declines (invoice_id, gcal_event_id, is_auto)
SELECT 12, g.id, false FROM gcal_events g WHERE g.id IN (44049, 48026)
ON CONFLICT DO NOTHING;

UPDATE invoice_lines l
   SET quantity = h.hours, amount = ROUND(h.hours * l.rate, 2)
  FROM (SELECT ROUND(SUM(COALESCE(hours, EXTRACT(EPOCH FROM (end_at - start_at)) / 3600.0))::numeric, 2) AS hours
          FROM invoice_work_shifts WHERE invoice_id = 20) h
 WHERE l.invoice_id = 20 AND l.category = 'labor' AND l.rate IS NOT NULL;
UPDATE invoices SET updated_at = now() WHERE id = 20;
COMMIT;
