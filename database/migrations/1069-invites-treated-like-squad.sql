-- 🎟 An invite puts the player in the squad's lists for that game (owner
-- 2026-11-05: "basically the initial invite to call up dumps them into no
-- response immediately so we can treat them like everyone else for that
-- event" … "do same for call down etc" … "for all teams").
--
-- Game Center: every invitee (call-up, call-down, ↔ call-in, ⭐ standing)
-- sits in No Response / Going / Not Going with a chip naming the kind; the
-- card's 📇 leads with the RSVP reminder like everyone else's.  Before this
-- only standing call-downs did; one-game call-ups waited in the 🎟 panel.
--
-- #my: the card says CALL-UP · Reserves / CALL-DOWN · APSL / INVITED and
-- one line why the game is on their week (kind my_callup).  Replaces the
-- hard-coded "invited … to play up" text, which was wrong for a play-down.
--
-- Reminder: when it is about a game they were asked in to, it says so —
-- brief, no starter deadline, no fines (invites are never fined), no "your
-- teammates" (rsvp_reminder callup_* tiers).
--
-- The direction is fh_event_invite_badge (mig 1024): from-team board order
-- against the game's team.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.c, v.l, v.k, v.t, NULL, v.b, v.o, true, v.cs, false
  FROM (VALUES
    -- Reminder (server-built, tokens {first} {child} {event} {callup} {more} {link} {sender})
    ('RSVP reminders', 'Call-up reminder — adult', 'rsvp_reminder', 'callup_adult',
     'Hi {first}, you''re {callup} for {event} 🎟 Are you available?[[ {more}]] Tap to answer: {link} - {sender}', 1192, false),
    ('RSVP reminders', 'Call-up reminder — parent', 'rsvp_reminder', 'callup_parent',
     'Hi {first}, {child} is {callup} for {event} 🎟 Is {child} available?[[ {more}]] Tap to answer: {link} - {sender}', 1193, false),
    ('RSVP reminders', 'Call-up reminder — called up ({from})', 'rsvp_reminder', 'callup_up',
     'called up[[ from {from}]]', 1194, false),
    ('RSVP reminders', 'Call-up reminder — called down ({from})', 'rsvp_reminder', 'callup_down',
     'called down[[ from {from}]]', 1195, false),
    ('RSVP reminders', 'Call-up reminder — invited, same level ({from})', 'rsvp_reminder', 'callup_invited',
     'invited[[ from {from}]]', 1196, false),
    ('RSVP reminders', 'Call-up reminder — other open RSVPs ({more})', 'rsvp_reminder', 'callup_more',
     'You have {more} more to answer too.', 1197, false),
    -- #my card
    ('My page', '#my call-up chip — up ({from})',          'my_callup', 'chip_up',       '🎟 CALL-UP[[ · {from}]]', 1, true),
    ('My page', '#my call-up chip — down ({from})',        'my_callup', 'chip_down',     '🎟 CALL-DOWN[[ · {from}]]', 2, true),
    ('My page', '#my call-up chip — same level ({from})',  'my_callup', 'chip_invited',  '🎟 INVITED[[ · {from}]]', 3, true),
    ('My page', '#my call-up line — adult, up',   'my_callup', 'adult_up',
     'You''re called up[[ from {from}]] for this game. Please answer so the coach knows if you''re available — the coach picks the squad.', 4, true),
    ('My page', '#my call-up line — adult, down', 'my_callup', 'adult_down',
     'You''re called down[[ from {from}]] for this game. Please answer so the coach knows if you''re available — the coach picks the squad.', 5, true),
    ('My page', '#my call-up line — adult, same level', 'my_callup', 'adult_invited',
     'You''re invited to this game[[ from {from}]]. Please answer so the coach knows if you''re available — the coach picks the squad.', 6, true),
    ('My page', '#my call-up line — parent, up ({child})',   'my_callup', 'parent_up',
     '{child} is called up[[ from {from}]] for this game. Please answer so the coach knows if {child} is available — the coach picks the squad.', 7, true),
    ('My page', '#my call-up line — parent, down ({child})', 'my_callup', 'parent_down',
     '{child} is called down[[ from {from}]] for this game. Please answer so the coach knows if {child} is available — the coach picks the squad.', 8, true),
    ('My page', '#my call-up line — parent, same level ({child})', 'my_callup', 'parent_invited',
     '{child} is invited to this game[[ from {from}]]. Please answer so the coach knows if {child} is available — the coach picks the squad.', 9, true),
    -- Game Center card chip for an invite that is neither up nor down
    ('Rosters', 'Game Center chip — invited, same level', 'invite_chip', 'invited', '🎟 Invited', 887, true)
  ) AS v(c, l, k, t, b, o, cs)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
