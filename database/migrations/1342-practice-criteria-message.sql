-- 1342 (2026-11-13) — 📇 🏃 Practice criteria message.
--
-- Owner 2026-11-13: "we need in contacts a special message for those that
-- set going but are not projected to meet criteria and who are projected
-- but its still projected so just a reminder for them to follow through.
-- could be called practice criteria message? and it would custom itself
-- depending on attendance and rsvps in future?"
--
-- Men's contact popup (SectionContact) gains 🏃 Practice criteria.  The
-- server writes it when sent (POST /api/practice-criteria/message,
-- PracticeCriteriaController): his next game he is Going to, the Game
-- Center criterion (StarterCriteria — the same query as the criteria card),
-- and the tier by where he stands:
--   short     Going to too few practices to get there
--   projected on track only if he makes the practices he said Going to
--   met       already has the days
--   not_met   short and no practices left this window
-- {practices} = one line per practice day of the window (attended / missed
-- / excused / Going / Out / no answer); {link} = his sign-in link, landing
-- on that game's Game Center (criteria card + Going buttons).
-- Tokens: {first} {game} (opponent) {when} (kickoff) {needed} {short}
-- (as "N practice day(s)") {attended} {projected} {practices} {link};
-- [[ … ]] drops when a token inside is empty.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Practice criteria', v.label, 'practice_criteria', v.tier, NULL, v.body, v.sort, true, false
  FROM (VALUES
    ('subject',   'Practice criteria — email subject',
     'Practice criteria[[ — vs {game}]], {when}', 1),
    ('short',     'Practice criteria — Going to the game, not enough practices to start',
     E'Hi {first}, you''re Going to the game[[ vs {game}]] ({when}). To be eligible to start you need {needed} at practice this week. So far you have {attended}, plus {projected} you said Going to — that leaves you {short} short.\n\n{practices}\n\nTap Going on the practices you can make: {link}', 10),
    ('projected', 'Practice criteria — on track only if he follows through',
     E'Hi {first}, you''re Going to the game[[ vs {game}]] ({when}) and you''re on track to be eligible to start — as long as you make the practices you said Going to. You need {needed}; so far you have {attended}.\n\n{practices}\n\nPlease follow through. If anything changes, update your RSVP: {link}', 11),
    ('met',       'Practice criteria — already has the practice days',
     E'Hi {first}, you''ve met the practice criteria for the game[[ vs {game}]] ({when}) — {needed} needed, you have {attended}. Thanks!\n\n{practices}\n\nYour game page: {link}', 12),
    ('not_met',   'Practice criteria — short and no practices left',
     E'Hi {first}, you''re Going to the game[[ vs {game}]] ({when}), but with {attended} of {needed} at practice and no practices left this week you won''t be eligible to start this one.\n\n{practices}\n\nYour game page: {link}', 13),
    ('line_attended', 'Practice criteria — practice line: attended ({when})', '✅ {when} — attended', 20),
    ('line_excused',  'Practice criteria — practice line: excused ({when})',  '✅ {when} — excused', 21),
    ('line_missed',   'Practice criteria — practice line: missed ({when})',   '❌ {when} — missed', 22),
    ('line_going',    'Practice criteria — practice line: future, Going ({when})', '👍 {when} — you said Going', 23),
    ('line_out',      'Practice criteria — practice line: future, Out ({when})',   '👎 {when} — you said Out', 24),
    ('line_open',     'Practice criteria — practice line: future, no answer ({when})', '❔ {when} — no answer yet', 25),
    ('day_one',   'Practice criteria — "1 practice day" ({n})', '{n} practice day', 30),
    ('day_many',  'Practice criteria — "N practice days" ({n})', '{n} practice days', 31),
    ('not_going', 'Practice criteria — error: no game he is Going to ({first})',
     '{first} isn''t Going to a game in the next week — nothing to remind.', 40)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'practice_criteria' AND t.tier = v.tier);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Contact', 'Contact popup — message: practice criteria', 'contact_popup', 'msg_practice_criteria', NULL,
       '🏃 Practice criteria', 1366, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'contact_popup' AND t.tier = 'msg_practice_criteria');
