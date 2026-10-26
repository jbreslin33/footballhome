-- 707: undo 701's placement — James reimburses Luke himself this week, so
-- the $160 youth-game ref fees ride James's 2026.21 sheet instead (owner:
-- "put the 160 rolled into the other ref fees on mine").  It stays its own
-- Referees row: the picked Referees line is rebuilt from ref_fee_payments
-- (Expenses::syncRefLine), so a $160 folded into it would vanish.
UPDATE invoice_lines l
   SET invoice_id = j.id, sort_order = 7
  FROM invoices k, invoices j
 WHERE l.invoice_id = k.id AND k.issuer_id = 2 AND k.invoice_year = 2026 AND k.invoice_number = 21
   AND j.issuer_id = 1 AND j.invoice_year = 2026 AND j.invoice_number = 21
   AND l.description = 'Youth games ref fees';
UPDATE invoices SET updated_at = now()
 WHERE invoice_year = 2026 AND invoice_number = 21 AND issuer_id IN (1, 2);
