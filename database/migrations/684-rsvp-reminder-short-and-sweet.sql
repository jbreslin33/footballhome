-- 684 (2026-10-24) — RSVP reminders short and sweet.  Owner: "can we
-- change the rsvp reminders for all players parents to a simpler smaller
-- message? like short and sweet. we need the custom link but … the
-- current one may be igonred due to length".
--
-- Kept: the personal sign-in link, what is missing, the start-eligibility
-- deadline, the sender's name, the Men's fine line (one short line), and
-- the reply-YES hint (iPhones keep a link from an unknown number dead
-- until a reply; reminders go from the coach's own phone, where replies
-- can't be seen, so it stays on every one).
-- Dropped: the game-day-card framing, the privacy sentence, the travel
-- line, the per-child breakdown.
-- Plain ASCII on purpose: one em dash or emoji drops a text to 70
-- characters per SMS segment instead of 160 — today's ran 7-8 segments.

UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('adult',  'Hi {first}, you haven''t answered for {missing} yet. One tap: {link}[[
{deadline}]][[
{fine_note}]]
- {sender}, Lighthouse 1893'),
    ('parent', 'Hi {first}, {child} hasn''t answered for {missing} yet. One tap: {link}[[
{deadline}]]
- {sender}, Lighthouse 1893'),
    ('multi',  'Hi {first}, {children} haven''t answered everything yet. One tap: {link}[[
{deadline}]][[
{fine_note}]]
- {sender}, Lighthouse 1893'),
    ('missing_games',         '{games} game[[{games_s}]]'),
    ('missing_practices',     '{practices} practice[[{practices_s}]]'),
    ('missing_both',          '{games} game[[{games_s}]] and {practices} practice[[{practices_s}]]'),
    ('fine_note',             'Missed RSVPs are fined.'),
    ('deadline_passed',       'Was due {day} midnight to be eligible to start, please still answer.'),
    ('deadline_plain_passed', 'Was due {day} midnight, please answer now.'),
    ('group_adult',  'Hi all, still no answer for {event}. Going or Not Going: footballhome.org[[
Who''s in: {roll_call}]]
- {sender}, Lighthouse 1893'),
    ('group_parent', 'Hi all, your player still has no answer for {event}. Going or Not Going: footballhome.org[[
Who''s in: {roll_call}]]
- {sender}, Lighthouse 1893'),
    ('group_week_adult',  'Hi all, you still have answers due:
{events}
Going or Not Going: footballhome.org[[
Who''s in: {roll_call}]]
- {sender}, Lighthouse 1893'),
    ('group_week_parent', 'Hi all, your player still has answers due:
{events}
Going or Not Going: footballhome.org[[
Who''s in: {roll_call}]]
- {sender}, Lighthouse 1893')
  ) AS v(t, b)
 WHERE message_templates.kind = 'rsvp_reminder' AND message_templates.tier = v.t;

-- The hint every text with a link carries (mig 366), shorter and ASCII.
UPDATE message_templates SET body = 'Link not working? Reply YES.'
 WHERE kind = 'sms_link_hint' AND tier = 'all';
