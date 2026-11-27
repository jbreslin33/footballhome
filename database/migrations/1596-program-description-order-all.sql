-- 1596 — men's and women's LA descriptions in the youth order.
--
-- Owner 2026-11-19: "do the same order for men and women" (youth got it
-- in mig 1592).  The 'all' skeleton — what men (men → adult → all) and
-- women (women → all) read — takes the order: Schedule → Teams →
-- Membership → Billing → Changes & questions → About Lighthouse 1893.
-- With every audience on the same order the youth-tier skeleton is a
-- copy, so it goes: one skeleton again.

UPDATE message_templates
   SET body = E'### Schedule\n[[{program_schedule}\n]]- **Games:** {program_games}\n- **Home Outdoor Facility:** {venue_outdoor}\n- **Home Indoor Facility:** {venue_indoor}\n\n'
              '[[{program_teams}\n\n]]'
              '{program_membership}\n\n'
              '{program_billing}\n\n'
              '### Changes & questions\n{program_changes}\n\n'
              '### About Lighthouse 1893\n{program_intro}',
       updated_at = now()
 WHERE kind = 'program_description' AND tier = 'all';

DELETE FROM message_templates WHERE kind = 'program_description' AND tier = 'youth';
