-- 379 — RSVP reminders: a player below 100% for the week can be reminded
-- even when nothing is left to answer.
--
-- Owner 2026-09-18: "i need to be able to resend reminder if a player is
-- not 100% availablity set for week."
--
-- Until now REMIND on #rsvps only lit up while the player had an
-- unanswered event still ahead of them.  Somebody who skipped Tuesday's
-- practice and answered Sunday's game sat at 50% with a dead button, and
-- every intramural card went dead by Thursday.  The reminder now lists
-- every unanswered event of the released week (Monday → release window
-- end); the ones that already happened get this suffix so the message is
-- honest about what can still be answered.  Token: {line} the event line
-- ("Tue Sep 15, 7:00 PM — Practice").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — event that already happened', 'rsvp_reminder', 'missed_line',
       NULL,
       '{line} (already happened — never answered)',
       12
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'missed_line');
