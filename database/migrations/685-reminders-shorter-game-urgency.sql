-- 685 (2026-10-24) — Every reminder shorter still, and game reminders
-- urgent when the game is close.  Owner: "lol they all need to be
-- shorter" → "the game one needs urgency but short and sweet. if game is
-- tomorrow it needs to stress that lol" → "yes do it for all teams etc".
--
-- Game reminders (squad_notice): {when} = TODAY / TOMORROW / Sat + time,
-- {event} = "vs Opponent", {urgent} = the role's nudge, set only when the
-- game is today or tomorrow (RsvpBoardController::handleSquadNotice).
-- Address, date and role explanations dropped — the link shows them.
-- RSVP reminders: who still needs to answer, the deadline if any, link.
-- Plain ASCII so a text stays in 160-character SMS segments.

UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('starter_adult',    'Hi {first}, you''re STARTING {when} {event}.[[ Arrive {arrival}.]] [[{urgent} ]]{link} - {sender}'),
    ('starter_parent',   'Hi {first}, {child} is STARTING {when} {event}.[[ Arrive {arrival}.]] [[{urgent} ]]{link} - {sender}'),
    ('bench_adult',      'Hi {first}, you''re on the BENCH {when} {event}.[[ Arrive {arrival}.]] [[{urgent} ]]{link} - {sender}'),
    ('bench_parent',     'Hi {first}, {child} is on the BENCH {when} {event}.[[ Arrive {arrival}.]] [[{urgent} ]]{link} - {sender}'),
    ('alternate_adult',  'Hi {first}, you''re on STANDBY {when} {event}. We''ll text if a spot opens.[[ {urgent}]] {link} - {sender}'),
    ('alternate_parent', 'Hi {first}, {child} is on STANDBY {when} {event}. We''ll text if a spot opens.[[ {urgent}]] {link} - {sender}'),
    ('pool_adult',       'Hi {first}, game {when} {event}. Are you going? [[{urgent} ]]{link} - {sender}'),
    ('pool_parent',      'Hi {first}, game {when} {event}. Is {child} going? [[{urgent} ]]{link} - {sender}'),
    ('group_adult',      'GAME {when} {event}.[[ Arrive {arrival}.]] Lineup: {link} - {sender}'),
    ('group_parent',     'GAME {when} {event}.[[ Arrive {arrival}.]] Lineup: {link} - {sender}'),
    ('standby_dropped_adult',  'You''re off standby for this game. Enjoy your plans. If that changes, tell a coach.'),
    ('standby_dropped_parent', '{child} is off standby for this game. Enjoy your plans. If that changes, tell a coach.')
  ) AS v(t, b)
 WHERE message_templates.kind = 'squad_notice' AND message_templates.tier = v.t;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game reminder', v.l, 'squad_notice', v.t, NULL, v.b, v.o, true, false, false
  FROM (VALUES
    ('day_today',       'Day word — game is today',                   'TODAY', 900),
    ('day_tomorrow',    'Day word — game is tomorrow',                'TOMORROW', 901),
    ('nudge_starter',   'Urgent line, today/tomorrow — starter',      'Can''t make it? Tell us now:', 902),
    ('nudge_bench',     'Urgent line, today/tomorrow — bench',        'Can''t make it? Tell us now:', 903),
    ('nudge_alternate', 'Urgent line, today/tomorrow — standby',      'Keep your phone close.', 904),
    ('nudge_pool',      'Urgent line, today/tomorrow — no role yet',  'Answer now:', 905),
    ('nudge_group',     'Urgent line, today/tomorrow — group',        '', 906)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'squad_notice' AND m.tier = v.t);

UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('adult',  'Hi {first}, you still need to RSVP.[[ {deadline}]] {link} - {sender}'),
    ('parent', 'Hi {first}, {child} still needs to RSVP.[[ {deadline}]] {link} - {sender}'),
    ('multi',  'Hi {first}, {children} still need to RSVP.[[ {deadline}]] {link} - {sender}'),
    ('deadline',              'Due {day} midnight to start.'),
    ('deadline_passed',       'Was due {day} midnight to start, answer now.'),
    ('deadline_plain',        'Due {day} midnight.'),
    ('deadline_plain_passed', 'Was due {day} midnight, answer now.'),
    ('group_adult',       'Hi all, still need your RSVP for {event}: footballhome.org[[ Who''s in: {roll_call}]] - {sender}'),
    ('group_parent',      'Hi all, your player still needs to RSVP for {event}: footballhome.org[[ Who''s in: {roll_call}]] - {sender}'),
    ('group_week_adult',  'Hi all, you still have RSVPs due: footballhome.org[[ Who''s in: {roll_call}]] - {sender}'),
    ('group_week_parent', 'Hi all, your player still has RSVPs due: footballhome.org[[ Who''s in: {roll_call}]] - {sender}')
  ) AS v(t, b)
 WHERE message_templates.kind = 'rsvp_reminder' AND message_templates.tier = v.t;
