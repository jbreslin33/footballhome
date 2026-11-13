-- 1305 (2026-11-12): Finances → Budget (owner: "go ahead" on the money
-- section plan — Budget = the year's plan per section/team, Money In & Out
-- = actuals only, Budget vs Actual next).  Route stays #finances so old
-- links keep working; only the words change.
UPDATE menu_pages SET label = 'Budget' WHERE code = 'finances' AND label = 'Finances';
UPDATE message_templates SET body = '📈 Budget'
 WHERE kind = 'finances' AND tier = 'title' AND body = '📈 Finances';
UPDATE message_templates
   SET body = 'The year''s plan (Aug 1 – Jul 31): what each section and team should cost and bring in. What really happened is on Money In & Out; billing stays on Payments.'
 WHERE kind = 'finances' AND tier = 'subtitle';
UPDATE message_templates
   SET body = replace(body, 'leave the projection on Finances', 'leave the projection on Budget')
 WHERE kind = 'invoices' AND tier = 'refs_hint';
INSERT INTO schema_migrations (filename) VALUES ('1305-finances-renamed-budget.sql') ON CONFLICT DO NOTHING;
