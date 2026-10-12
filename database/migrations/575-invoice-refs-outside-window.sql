-- 575 (2026-10-12) — #invoices: referee fees outside the sheet's covered
-- dates sit apart.  Owner: "mark off expenses like refs that are outside
-- the window of invoice as its confusing."  The tick-off list shows the
-- window's own games first; earlier/later unbilled ones follow dimmed
-- under this divider (still tickable — a missed fee is swept onto a
-- later sheet).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', 'Invoices — ref fees outside the window divider', 'invoices', 'refs_outside', NULL,
       'Outside this invoice''s window ({from} – {till}) — still unbilled', 783, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invoices' AND m.tier = 'refs_outside');
