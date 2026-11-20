-- 1588 — youth LA description: travel squads are U10 and U12 only.
--
-- Owner 2026-11-19: "don't mention u8 travel".

UPDATE message_templates
   SET body = replace(body, '- **U8, U10, U12** —', '- **U10, U12** —'),
       updated_at = now()
 WHERE kind = 'program_teams' AND tier = 'youth';
