-- 1358 (2026-11-13) — paid ads on the Budget page (owner: ad line "sure").
-- Meta year-round ads from 11/13: youth $10 + men $10 + women $5 a day =
-- $175 a week, club-wide (shared like balls / grass seed), assumed — the
-- spend is adjusted as leads come in (youth drops when indoor rosters fill,
-- no date yet; men reviewed 11/20, women 11/27).  New invoice line category
-- 'advertising' so it is its own row on the Expenses grid / #cash-flow.
BEGIN;
INSERT INTO invoice_line_categories (code, label, sort_order)
VALUES ('advertising', 'Advertising:', 13)
ON CONFLICT (code) DO NOTHING;

UPDATE message_templates SET body = body || '|advertising', updated_at = now()
 WHERE kind = 'finances' AND tier = 'category_order' AND body NOT LIKE '%advertising%';

INSERT INTO budget_lines (club_id, club_section_id, category, label, amount_usd, amount_per,
                          period_start, period_end, spread, is_assumed, is_active, sort_order,
                          note, budget_year_id, weeks_off)
SELECT 134, NULL, 'advertising', 'Meta ads — year-round (youth, men, women)', 175.00, 'week',
       '2026-11-13', '2027-07-31', 'even', true, true, 100,
       'Owner 2026-11-13: youth $10/day, men $10/day, women $5/day = $175/week; adjusted as leads come in',
       1, 0
 WHERE NOT EXISTS (SELECT 1 FROM budget_lines WHERE category = 'advertising' AND budget_year_id = 1);
COMMIT;
