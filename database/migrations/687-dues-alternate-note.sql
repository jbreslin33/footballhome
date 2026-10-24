-- 687 (2026-10-24) — A personal note for a player who owes dues and is
-- an alternate for a game: why, and how to move back up.  Owner: "we need
-- a message for players who owe money and were put on as alternates for
-- liga 1. but message should be universal … text email etc … explains
-- that system puts them as alternates if we have enough dues paying
-- players" → "needs to show that we don't always alternate them but if we
-- have enough dues payers they will be left out for playing time to go to
-- players who paid dues."
--
-- Sent from Game Center's contact sheet (WHAT "Dues: why they're an
-- alternate", only on cards the dues rule flags — mig 613) through
-- POST /api/rsvp-board/dues-note: one per parent, each with their own
-- sign-in link, which lands on #my where the balance and Pay button are.
-- Universal: no team or league named — {when} {event} is the game.
-- Plain ASCII so a text stays in 160-character SMS segments.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game reminder', v.l, 'dues_alternate_note', v.t, v.s, v.b, v.o, true, false, false
  FROM (VALUES
    ('adult',  'Dues alternate note — adult player ({amount}, {when}, {event})',
     'Dues and the lineup: {when} {event}',
     'Hi {first}, about {when} {event}: you have {amount} in dues owed. We don''t always make players who owe alternates, but when we have enough players whose dues are paid, the playing time goes to them first, so you''re an alternate for this one. Any payment moves you back up: {link} - {sender}',
     1),
    ('parent', 'Dues alternate note — parent ({child}, {amount}, {when}, {event})',
     'Dues and the lineup: {when} {event}',
     'Hi {first}, about {when} {event}: {child} has {amount} in dues owed. We don''t always make players who owe alternates, but when we have enough players whose dues are paid, the playing time goes to them first, so {child} is an alternate for this one. Any payment moves {child} back up: {link} - {sender}',
     2)
  ) AS v(t, l, s, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dues_alternate_note' AND m.tier = v.t);

-- The contact sheet's WHAT label.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'WHAT — dues alternate note', 'contact_menu', 'what_dues', NULL,
       'Dues: why they''re an alternate', 1004, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = 'what_dues');

-- The contact sheet marks the recommended message for a card's problem
-- (registration gap → form, dues alternate → this note, no answer →
-- RSVP reminder) — owner: "they recommend message to send".
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'WHAT — marks the recommended message', 'contact_menu', 'recommended', NULL, '⭐ recommended', 1005, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = 'recommended');
