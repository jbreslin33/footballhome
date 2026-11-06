-- Owner 2026-11-06: "don't auto select youth."  James's default pay is men's
-- practices + APSL / Liga 1 games (mig 987, coach_pay_rules); the youth rows
-- on his 2026.22 (invoice 20) were ticked automatically before that rule
-- existed (17.75 h: youth practices 10/23, 10/26, 10/28, 11/2, 11/4 and the
-- U8 / U10 / U12 games 10/25, 11/1, 11/4).  They come off; the draft check
-- never re-adds them (it ✓s only fh_coach_paid_for events).  The hours line
-- re-sums and the overlap trims re-settle on the next open (11/4 Liga 1 gets
-- its own start back).
DELETE FROM invoice_work_shifts s
 USING fh_events e, invoices i
 WHERE s.invoice_id = 20 AND i.id = s.invoice_id AND NOT i.is_final
   AND e.id = s.fh_event_id
   AND NOT fh_coach_paid_for(i.issuer_id, e.id, e.kind);
UPDATE invoices SET updated_at = now() WHERE id = 20;
