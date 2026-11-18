-- 1464 (2026-11-18) — 🙋 Say it plainly: the slots land on his calendar.
-- Owner 11/18: "we need to let them know that the coach slots they vol for
-- will then show up like their practices and games do as a player right?"
--
-- Approval makes him an assistant coach for exactly his slots (mig 1461),
-- so they show on his 📅 Calendar beside his own practices and games, with
-- the same ✓ / ✗ — and ✗ before it starts is how he tells us ahead.
UPDATE message_templates SET body =
  'Help coach the kids {min} a week and that month''s dues ({dues}) are waived. Pick youth practice slots below — they must add up to at least {min}. Tap a day to take all of it. Once the club approves, your slots show up on your 📅 Calendar right alongside your own practices and games, with the same ✓ / ✗ buttons. What you already owe stays owed — pay it off when you can.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'intro';
UPDATE message_templates SET body =
  'Don''t miss — the kids and coaches are counting on you. We know life happens: if you truly can''t make it, tap ✗ on that slot on your calendar before it starts. One told-ahead miss a month is OK. A no-show, or a second miss in the month, means that month''s dues are billed.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'terms';
UPDATE message_templates SET body =
  'You picked {shift} — {total} a week. Once the club approves, they show up on your 📅 Calendar like your own practices and games. Until then your dues stand.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'pending';
UPDATE message_templates SET body =
  'You''re a club volunteer: {shift} — {total} a week. Your slots are on your 📅 Calendar next to your own practices and games. Make your {min} every week and that month''s dues are waived.',
       updated_at = now()
 WHERE kind = 'volunteer_shift' AND tier = 'approved';
