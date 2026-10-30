-- 887 (2026-10-30) — #cash-flow: from October, the 8 soccer programs, no dups.
--
-- Owner: "the only in should be from la actual money in from the 8 soccer
-- programs (careful not to dup!) so total came in to coffers", "lets just
-- start from oct".  The 8 are the four sections' membership and pickup
-- programs; the two inactive programs and the earlier programs stay listed
-- but no longer count.  The dup itself is handled in CashFlow::build.

ALTER TABLE la_soccer_programs ADD COLUMN IF NOT EXISTS counts_in BOOLEAN NOT NULL DEFAULT false;
UPDATE la_soccer_programs s SET counts_in = true
  FROM leagueapps_programs lp
 WHERE lp.program_id = s.la_program_id AND lp.variant IN ('active', 'pickup');

CREATE TABLE IF NOT EXISTS cash_flow_policies (
    club_id   INT  PRIMARY KEY,
    starts_on DATE NOT NULL
);
COMMENT ON TABLE cash_flow_policies IS 'mig 887: the date #cash-flow starts from.';
INSERT INTO cash_flow_policies (club_id, starts_on) VALUES (134, '2026-10-01') ON CONFLICT (club_id) DO NOTHING;

UPDATE message_templates SET body = 'Since {date}' WHERE kind = 'cash_flow' AND tier = 'card_since';
UPDATE message_templates SET body = 'Money in is what LeagueApps paid out after its fees, less refunds, from the 8 soccer programs only. Money out is James''s and the coaches'' invoices, drafts included, by invoice date, and nothing else. It all starts {date}. Running is not a bank balance.'
 WHERE kind = 'cash_flow' AND tier = 'months_note';

DELETE FROM message_templates WHERE kind = 'cash_flow' AND tier = 'from';
