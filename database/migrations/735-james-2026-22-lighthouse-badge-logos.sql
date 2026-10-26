-- 735: owner 2026-10-26: "add 252.11 to next cycle invoice for Lighthouse
-- Badge Logos."  Next cycle = James's 2026.22 (10/23–11/5, due 11/6).  Its
-- auto-draft would not appear until 10/30, so it is made here the way
-- Invoice::createNumbered makes one (blank labor line at the issuer's rate +
-- the next "k of N" of every running plan); the calendar's day rows fill
-- themselves on the first open of the draft.  Skipped if it already exists.
DO $$
DECLARE
    v_id  int;
    v_sort int := 2;
    p record;
BEGIN
    SELECT id INTO v_id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
    IF v_id IS NULL THEN
        INSERT INTO invoices (issuer_id, invoice_year, invoice_number, invoice_date, period_start, period_end)
        SELECT 1, 2026, 22, ps + days, ps, ps + days - 1
          FROM (SELECT fh_invoice_period_start(2026, 22) AS ps, fh_invoice_period_days(2026) AS days) x
        RETURNING id INTO v_id;

        INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
        SELECT v_id, 'labor', COALESCE(NULLIF(duty_description, ''), 'Hours'), 0, hourly_rate, 0, 1
          FROM invoice_issuers WHERE id = 1;

        FOR p IN
            SELECT pl.id, pl.category, pl.description, pl.total_amount, pl.installment_count, pl.budget_line_id,
                   COALESCE(MAX(l.installment_no), 0) + 1 AS k
              FROM invoice_installment_plans pl
              LEFT JOIN invoice_lines l ON l.plan_id = pl.id
             WHERE pl.issuer_id = 1
             GROUP BY pl.id
            HAVING COALESCE(MAX(l.installment_no), 0) < pl.installment_count
             ORDER BY pl.created_at, pl.id
        LOOP
            INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order, budget_line_id)
            SELECT v_id, p.category, p.description, 1, a, a, p.id, p.k, v_sort, p.budget_line_id
              FROM (SELECT CASE WHEN p.k = p.installment_count
                                THEN round(p.total_amount - round(p.total_amount / p.installment_count, 2) * (p.installment_count - 1), 2)
                                ELSE round(p.total_amount / p.installment_count, 2) END AS a) x;
            v_sort := v_sort + 1;
        END LOOP;
    END IF;

    INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
    SELECT v_id, 'uniforms', 'Lighthouse Badge Logos', 1, 252.11, 252.11,
           COALESCE((SELECT MAX(sort_order) FROM invoice_lines WHERE invoice_id = v_id), 0) + 1
     WHERE NOT EXISTS (SELECT 1 FROM invoice_lines WHERE invoice_id = v_id AND description = 'Lighthouse Badge Logos');

    UPDATE invoices SET updated_at = now() WHERE id = v_id;
END $$;
