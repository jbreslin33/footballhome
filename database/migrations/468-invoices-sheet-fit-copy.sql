-- 468 (2026-09-27) — #invoices: copy for the sheet-fit warning.
-- Owner: "i want to enter expenses to for my invoice. and have it
-- categoriezed but fit on sheet … there is limited space on their
-- prefereed sheet."  Lighthouse's template has 14 rows; past that the
-- sheet shrinks its rows to stay on one page and the editor says so.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'Invoices — sheet fit warning', 'invoices', 'sheet_fit', NULL,
       '{n} lines — the sheet holds {max} at full size, so the rows shrink to keep it on one page. Combine lines (e.g. several referee fees into one) if it gets hard to read.',
       9, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'sheet_fit');
