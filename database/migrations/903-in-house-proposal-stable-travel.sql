-- 903 (2026-10-30) — #in-house-proposal: in-house is the base, travel grows from it.
--
-- Owner: "this would allow us to build travel teams as needed.", "stable
-- travel teams".
UPDATE message_templates
   SET body = replace(body, E'then Inter-County outdoors.\n', E'then Inter-County outdoors.\n- In-house is the base. We build a travel team as needed, when an age group has the players to keep it stable.\n')
 WHERE kind = 'in_house_proposal' AND tier = 'ask_body'
   AND body NOT LIKE '%In-house is the base%';

UPDATE message_templates
   SET body = replace(body, 'When an age group has the players for it, we build another travel team, as needed.', 'We build a travel team as needed, when an age group has the players to keep it stable.')
 WHERE kind = 'in_house_proposal' AND tier = 'ask_body';

UPDATE message_templates
   SET body = replace(body, 'Before U12 we would have nothing to offer them, and they could leave.', 'Until we build a travel team at their age, we would have nothing to offer them, and they could leave.')
 WHERE kind = 'in_house_proposal' AND tier = 'risk_body';

-- Mig 902 placed the last three members, so the counts move to all 62.
UPDATE message_templates
   SET body = replace(replace(replace(body, 'U8 (ages 6–8)|19|', 'U8 (ages 6–8)|20|'), 'U10 (ages 9–10)|19|', 'U10 (ages 9–10)|20|'), 'U12 (ages 11–12)|14|', 'U12 (ages 11–12)|15|')
 WHERE kind = 'in_house_proposal' AND tier = 'plan_rows';

UPDATE message_templates SET body = '12 of 33'
 WHERE kind = 'in_house_proposal' AND tier = 'stat_3_value';

UPDATE message_templates
   SET body = replace(replace(body, '19 players is thin', '20 players is thin'), '14 players at U12 for 12 indoor spots leaves two out', '15 players at U12 for 12 indoor spots leaves three out')
 WHERE kind = 'in_house_proposal' AND tier = 'risk_body';

UPDATE message_templates
   SET body = replace(body, 'each of 38 U8 and U10 players', 'each of 40 U8 and U10 players')
 WHERE kind = 'in_house_proposal' AND tier = 'open_body';
