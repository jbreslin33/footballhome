-- 1590 — youth LA description: travel teams form as players are ready.
--
-- Owner 2026-11-19: "we have travel teams as players are reasdy i think".
-- Replaces "We add travel teams for additional age bands as interest and
-- readiness grow." (no age bands are named since mig 1589).

UPDATE message_templates
   SET body = replace(body,
                      'We add travel teams for additional age bands as interest and readiness grow.',
                      'We add travel teams as players are ready.'),
       updated_at = now()
 WHERE kind = 'program_teams' AND tier = 'youth';
