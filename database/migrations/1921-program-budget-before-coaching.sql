-- 1921 (2026-11-25) — Program budgets: BALANCE BEFORE COACHING.
-- Owner: "for budget progream budgets we need a before coaing and before
-- grant total".  #finances → Program budgets → Overview: money in less the
-- program's own costs and competitions, just above the 🧑‍🏫 Coaching block;
-- BALANCE BEFORE GRANT (pg_gp_before) stays below coaching + the shares.
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Finances', 'Program budgets: balance before coaching (money in − own costs − competitions)',
       'finances', 'pb_before_coach', 'BALANCE BEFORE COACHING', 376, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'pb_before_coach');
