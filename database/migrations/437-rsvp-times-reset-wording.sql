-- 437 (2026-09-25) — owner: the link that clears an edited arrive/leave
-- time "should say 'Switch back to on time'".
UPDATE message_templates SET body = 'Switch back to on time', updated_at = now()
 WHERE kind = 'rsvp_times' AND tier = 'reset';
