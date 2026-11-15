-- 1380 (2026-11-14) — the 3-year $50k grant is a guaranteed (unconditional)
-- promise, so it is booked the standard way (ASC 958-605): all $150,000 is
-- revenue with donor restrictions in the year it was promised (2026-27).
-- Later years' installments are grants receivable (split due within one year /
-- in later years) and stay restricted by time until their year comes; spending
-- on their purposes then releases them.
--
-- Owner 2026-11-14: "its gauranteed".
--
-- income_awards.promised_on = the date the promise was made (the year it is
-- recognised in). NULL → the row's created date.

ALTER TABLE income_awards ADD COLUMN IF NOT EXISTS promised_on date;
COMMENT ON COLUMN income_awards.promised_on IS
  'Date the (unconditional) promise was made; awarded/received awards are revenue in the budget year containing this date (mig 1380). NULL = created_at date.';

UPDATE income_awards
   SET promised_on = DATE '2026-11-14'
 WHERE club_id = 134 AND kind = 'grant' AND status IN ('awarded', 'received')
   AND amount_usd = 50000 AND promised_on IS NULL;

UPDATE message_templates t SET body = v.body
  FROM (VALUES
    ('sfp_grants_recv', 'Grants and sponsorships receivable, due within one year'),
    ('sfp_note', 'What soccer owns and owes, club-wide. Soccer is a Lighthouse program with no bank account of its own: Lighthouse receives all the money and pays soccer''s invoices, so cash is what Lighthouse holds for soccer — everything received since soccer''s books began on Aug 1, minus invoices paid (paid once final). Grants promised for later years are receivable at their full amount (not discounted). Net assets with donor restrictions = grant money not yet spent on what it may pay for, including later years'' installments.'),
    ('soa_note', 'Revenue, expenses and the change in net assets since soccer''s books began on Aug 1, club-wide. Expenses are recorded when invoiced; dues when paid through LeagueApps, plus what members owe now. A guaranteed grant or sponsorship is revenue in full when promised — every year of a multi-year promise — with donor restrictions when it names what it may pay for or is for a later year. Spending on a grant''s purposes in its own year releases that much from restriction.')
  ) AS v(tier, body)
 WHERE t.kind = 'finances' AND t.tier = v.tier;

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — SFP: grants receivable in later years', 'sfp_grants_recv_later', 'Grants and sponsorships receivable, due in later years', 237)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
