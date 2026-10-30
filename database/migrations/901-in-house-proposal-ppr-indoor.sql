-- 901 (2026-10-30) — #in-house-proposal: what PPR Indoor offers.
--
-- Owner: "ppr has u16 boys and u13 girls for indoor as oldest ages. begins in
-- january".  The start date goes into the proposal, and the older ages become
-- a question: mig 900 left U13 and up with no games.
UPDATE message_templates
   SET body = replace(body, 'PPR Indoor this winter, then Inter-County outdoors', 'PPR Indoor starting in January, then Inter-County outdoors')
 WHERE kind = 'in_house_proposal' AND tier = 'ask_body';

UPDATE message_templates
   SET body = '- PPR Indoor goes up to U16 boys and U13 girls and begins in January. Do our 7 older players get an indoor team? Girls play on our boys teams now, so a girls team would be a new decision too.' || E'\n' || body
 WHERE kind = 'in_house_proposal' AND tier = 'open_body'
   AND body NOT LIKE '%U16 boys%';
