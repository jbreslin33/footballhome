-- 414 — Dues notices name the partial amounts we'll take.
--
-- Owner 2026-09-23: "for payment reminder. ask on all for at least
-- partial payment of $5, $10, $15, $20".
--
-- The amounts are club policy, so they live on dues_policies next to the
-- rate and the pause threshold (migration 401): partial_amounts_usd, read
-- by fh_dues_partial_amounts_usd() → DuesPolicy → the copy endpoint →
-- the {partial_amounts} token ("$5, $10, $15 or $20") in every dues
-- notice.  Same rule as the rate: a new policy row, history untouched.
-- The token sits in [[ … ]] so a club with no list keeps the old line.
ALTER TABLE dues_policies
  ADD COLUMN IF NOT EXISTS partial_amounts_usd numeric(8,2)[] NOT NULL DEFAULT '{}';
COMMENT ON COLUMN dues_policies.partial_amounts_usd IS
  'Partial payments the club asks for when a member cannot pay in full, ascending; empty = notices do not name amounts.';

INSERT INTO dues_policies (club_id, club_section_id, monthly_dues_usd, pause_after_months, effective_from, partial_amounts_usd)
SELECT 134, NULL, fh_monthly_dues_usd(134), fh_dues_pause_after_months(134), DATE '2026-09-23', '{5,10,15,20}'
 WHERE NOT EXISTS (SELECT 1 FROM dues_policies WHERE club_id = 134 AND club_section_id IS NULL AND effective_from = DATE '2026-09-23');

CREATE OR REPLACE FUNCTION fh_dues_partial_amounts_usd(p_club_id int, p_club_section_id int DEFAULT NULL)
RETURNS numeric[] LANGUAGE sql STABLE AS $$
  SELECT partial_amounts_usd
    FROM dues_policies
   WHERE club_id = p_club_id
     AND (club_section_id IS NULL OR club_section_id = p_club_section_id)
     AND effective_from <= CURRENT_DATE
   ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC
   LIMIT 1
$$;

-- The six live notices (migration 399/400): the partial ask names the amounts.
UPDATE message_templates SET updated_at = now(),
       body = replace(body, 'make a partial payment so we know', 'make a partial payment[[ of {partial_amounts}]] so we know')
 WHERE kind = 'payment_notice_email' AND tier IN ('behind_1', 'behind_2') AND is_active;
UPDATE message_templates SET updated_at = now(),
       body = replace(body, 'at least a partial payment so we know', 'at least a partial payment[[ of {partial_amounts}]] so we know')
 WHERE kind = 'payment_notice_sms' AND tier IN ('behind_1', 'behind_2') AND is_active;
UPDATE message_templates SET updated_at = now(),
       body = replace(body, 'make a partial payment and reply with a plan', 'make a partial payment[[ of at least {partial_amounts}]] and reply with a plan')
 WHERE kind IN ('payment_notice_email', 'payment_notice_sms') AND tier = 'behind_3' AND is_active;
