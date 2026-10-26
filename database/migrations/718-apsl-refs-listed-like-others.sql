-- 718 (2026-10-26) — Undo 717's APSL home-only filter on invoices (owner:
-- "for now just list all apsl refs like the others and i can just say
-- didn't pay. simple").  Every APSL game is offered/auto-added again; the
-- owner turns off (red chip → invoice_ref_declines) the ones not paid.
-- The bill_home_only column stays (false everywhere) — the 2 away fees 717
-- took off James's 2026.21 come back by auto-add on its next open.
UPDATE ref_fee_policies SET bill_home_only = false WHERE bill_home_only;
