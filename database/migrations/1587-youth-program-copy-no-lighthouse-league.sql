-- 1587 — youth LA description: no Lighthouse League.
--
-- Owner 2026-11-19: "Dont mention lh league".  The Teams block loses the
-- in-house Lighthouse League paragraph; the travel squads stand on their
-- own (still no season, per mig 1585).

UPDATE message_templates
   SET body = E'### Teams\n'
              'We field select travel squads:\n'
              '- **U8, U10, U12** — competing in a boys-division travel league. We encourage and have girls playing on these squads while we grow the girls program.\n\n'
              'We add travel teams for additional age bands as interest and readiness grow.',
       updated_at = now()
 WHERE kind = 'program_teams' AND tier = 'youth';
