-- Owner 2026-11-06: "don't auto select youth" … "unless i set going" … "but
-- leave them there in red so i can flip the ones i went to to green".
-- On an issuer's sheet, an event outside their pay rules (coach_pay_rules) is
-- green only when they RSVP'd Going; otherwise the sheet marks it red itself
-- (is_auto).  A later Going turns an automatic red green; a ✗ the issuer
-- tapped stays.  A tap on a red chip makes it green.
-- (Soccer events carry no Google Calendar guest list, so "going" = the FH RSVP.)
BEGIN;
ALTER TABLE invoice_event_declines ADD COLUMN IF NOT EXISTS is_auto boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN invoice_event_declines.is_auto IS
  'mig 1141: red set by the sheet (event outside the issuer''s pay rules, no RSVP Going) — a later Going turns it green; false = a ✗ the issuer tapped.';
UPDATE message_templates SET body = 'tap: ✓ worked ⇄ ✗ not there', updated_at = now()
 WHERE kind = 'invoices' AND tier = 'cycle_tip';
COMMIT;
