-- 1591 — youth LA description: the Teams block is one generic line.
--
-- Owner 2026-11-19: "don't mention boys divison just keep it generric we
-- have select travel teams as players are ready".  Drops the boys-division
-- / girls-on-these-squads sentence (migs 1589/1590).

UPDATE message_templates
   SET body = E'### Teams\n'
              'We have select travel teams as players are ready.',
       updated_at = now()
 WHERE kind = 'program_teams' AND tier = 'youth';
