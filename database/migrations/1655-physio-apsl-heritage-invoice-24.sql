-- 1655 (2026-11-23): $100 physio for the last APSL game, on James's 2026.24.
--
-- Owner: "add 100 for physio for last apsl game" … "to invoice" … "for the
-- invoice currently live. we sent the one out this past friday."
--
-- The game is APSL home vs Philadelphia Heritage, Sun 2026-11-22.  2026.23
-- (period 11/6–11/19) went out Friday 11/20, so the line belongs on 2026.24
-- (period 11/20–12/3, dated 12/4).  That sheet is not drafted by the board
-- until 11/27, so this opens it the way Invoice::createNumbered does: the
-- hours line, then the next installment of every plan still running that
-- has reached 2026.24 (Invoice::openPlans).  Calendar day rows and ref fees
-- land by themselves the next time #invoices loads.  Everything is skipped if
-- the sheet already exists; the physio line is added once either way.

BEGIN;

CREATE TEMP TABLE _new_inv ON COMMIT DROP AS
WITH ins AS (
  INSERT INTO invoices (issuer_id, invoice_year, invoice_number, invoice_date, period_start, period_end)
  SELECT 1, 2026, 24,
         fh_invoice_period_start(2026, 24) + fh_invoice_period_days(2026),
         fh_invoice_period_start(2026, 24),
         fh_invoice_period_start(2026, 24) + fh_invoice_period_days(2026) - 1
   WHERE NOT EXISTS (SELECT 1 FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 24)
  RETURNING id
)
SELECT id FROM ins;

-- The hours line, blank hours at the issuer's rate.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
SELECT n.id, 'labor', COALESCE(NULLIF(i.duty_description, ''), 'Hours'), 0, i.hourly_rate, 0, 1
  FROM _new_inv n JOIN invoice_issuers i ON i.id = 1;

-- The next "k of N" of every plan still running; the last one absorbs rounding.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order, budget_line_id)
SELECT n.id, o.category, o.description, 1, o.amt, o.amt, o.id, o.used + 1,
       1 + row_number() OVER (ORDER BY o.created_at, o.id), o.budget_line_id
  FROM _new_inv n
 CROSS JOIN LATERAL (
   SELECT p.id, p.category, p.description, p.budget_line_id, p.created_at, u.used,
          CASE WHEN u.used + 1 = p.installment_count
               THEN p.total_amount - round(p.total_amount / p.installment_count, 2) * (p.installment_count - 1)
               ELSE round(p.total_amount / p.installment_count, 2) END AS amt
     FROM invoice_installment_plans p
    CROSS JOIN LATERAL (SELECT COALESCE(MAX(l.installment_no), 0) AS used FROM invoice_lines l WHERE l.plan_id = p.id) u
    WHERE p.issuer_id = 1
      AND (p.starts_invoice_number IS NULL OR (p.starts_invoice_year, p.starts_invoice_number) <= (2026, 24))
      AND u.used < p.installment_count
 ) o;

-- The physio.
INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order, line_date)
SELECT v.id, 'medical', 'Physio — APSL vs Philadelphia Heritage', 1, 100, 100, 50, DATE '2026-11-22'
  FROM invoices v
 WHERE v.issuer_id = 1 AND v.invoice_year = 2026 AND v.invoice_number = 24 AND NOT v.is_final
   AND NOT EXISTS (SELECT 1 FROM invoice_lines l WHERE l.invoice_id = v.id AND l.category = 'medical'
                      AND l.line_date = DATE '2026-11-22');

UPDATE invoices SET updated_at = now() WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 24;

INSERT INTO schema_migrations (filename) VALUES ('1655-physio-apsl-heritage-invoice-24.sql') ON CONFLICT DO NOTHING;
COMMIT;
