-- 883 (2026-10-30) — #cash-flow starts at the first invoice carrying expenses.
--
-- Owner: "start analysis from when you started getting invoices sent from fh",
-- "otherwise you don't have data".  CashFlow::build now reads that date from
-- the invoices themselves, so the wording takes {date} and the program table
-- has one column.

UPDATE message_templates SET body = 'Since invoices began ({date})' WHERE kind = 'cash_flow' AND tier = 'card_since';
UPDATE message_templates SET body = 'Money in is what LeagueApps paid out after its fees, less refunds. Money out is every invoice, drafts included, by invoice date, plus the #finances projection ahead. It all starts {date}, the first invoice carrying the club''s expenses: before that there is no money out on file to compare. Running starts from zero at the top row: it is not a bank balance.'
 WHERE kind = 'cash_flow' AND tier = 'months_note';

DELETE FROM message_templates WHERE kind = 'cash_flow' AND tier IN ('last_12', 'this_year');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Finances', l, 'cash_flow', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('since', 'Program money column ({date})',      'Since {date}', 22),
    ('from',  'The first month''s row ({date})',    'from {date}', 31)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cash_flow' AND m.tier = v.t);
