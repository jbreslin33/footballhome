-- 1535 (2026-11-19) — 🎓 clearer checklist rows (owner 11/19 "the list is
-- confusing. like 'National Sex Offender Registry (NSOR) form · Free' where
-- is the link?").  Steps with no link say where the form comes from; the
-- long NSOR title is shortened (the popup now numbers each step and puts
-- the cost with the how, not after the title).
UPDATE onboarding_steps SET label = 'NSOR form (National Sex Offender Registry)',
       how = 'No link — the club emails you this form. Fill it in and submit it the way the form says.'
 WHERE code = 'nsor';
UPDATE onboarding_steps SET how = 'No link — the club gives you this form. Fill it in and hand or email it back to the club.'
 WHERE code = 'direct_deposit';
UPDATE onboarding_steps SET how = 'No link — when your results come (a few weeks after the appointment), send the club a copy.'
 WHERE code = 'fbi_result';
UPDATE onboarding_steps SET how = 'No link — take a photo of your driver''s license or other photo ID and send it to the club.'
 WHERE code = 'photo_id';
