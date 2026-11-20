-- 1589 — youth LA description: travel squads with no age bands named.
--
-- Owner 2026-11-19: "just u10 and u12 for now" → "actually dont mention
-- any speciffic travel".  Replaces the U10/U12 line of mig 1588.

UPDATE message_templates
   SET body = E'### Teams\n'
              'We field select travel squads competing in a boys-division travel league. We encourage and have girls playing on these squads while we grow the girls program.\n\n'
              'We add travel teams for additional age bands as interest and readiness grow.',
       updated_at = now()
 WHERE kind = 'program_teams' AND tier = 'youth';
