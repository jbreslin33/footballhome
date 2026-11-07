-- 1151: Women's dues follow the Men's rule (owner 2026-11-06: "women don't
-- pay so have it match men but we won't use it").  A Women's dues_policies
-- row with alternate_on_balance = true (same rate / line / partials as the
-- Men's row), so a Women's member who ever owes gets the *_selection
-- notices (mig 1149) and sinks in selection like a man.  No Women's member
-- carries a balance at this writing — nothing changes for anyone today.
-- The selection copy goes section-neutral ("men's games" → games).
INSERT INTO dues_policies (club_id, club_section_id, monthly_dues_usd, pause_after_months, effective_from,
                           partial_amounts_usd, blocks_eligibility, alternate_on_balance)
SELECT 134, cs.id, 35.00, 2, DATE '2026-11-06', '{5.00,10.00,15.00,20.00}', false, true
  FROM club_sections cs
 WHERE cs.name = 'Womens'
   AND NOT EXISTS (SELECT 1 FROM dues_policies d WHERE d.club_id = 134 AND d.club_section_id = cs.id);

UPDATE message_templates
   SET body = replace(body, ' on men''s games', ''), updated_at = now()
 WHERE kind IN ('payment_notice_email', 'payment_notice_sms') AND tier LIKE '%\_selection' AND body LIKE '% on men''s games%';

UPDATE message_templates
   SET body = replace(body, ' for men''s games', ' for games'), updated_at = now()
 WHERE kind = 'my_dues' AND tier = 'alternate_banner' AND body LIKE '% for men''s games%';
