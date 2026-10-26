-- 736: owner 2026-10-26: "add 10.54 for youth shirt" — onto the same next-cycle
-- invoice as mig 735 (James's 2026.22, 10/23–11/5, due 11/6), which 735 created.
-- Skipped if the line is already there.
DO $$
DECLARE
    v_id int;
BEGIN
    SELECT id INTO v_id FROM invoices WHERE issuer_id = 1 AND invoice_year = 2026 AND invoice_number = 22;
    IF v_id IS NULL THEN
        RAISE EXCEPTION 'invoice 2026.22 missing — run mig 735 first';
    END IF;

    INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, sort_order)
    SELECT v_id, 'uniforms', 'Youth Shirt', 1, 10.54, 10.54,
           COALESCE((SELECT MAX(sort_order) FROM invoice_lines WHERE invoice_id = v_id), 0) + 1
     WHERE NOT EXISTS (SELECT 1 FROM invoice_lines WHERE invoice_id = v_id AND description = 'Youth Shirt');

    UPDATE invoices SET updated_at = now() WHERE id = v_id;
END $$;
