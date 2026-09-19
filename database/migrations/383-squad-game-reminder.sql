-- 383 — Game Center: a game reminder to everyone in the squad.
--
-- Owner 2026-09-19: "i got guys who set going asking if there is a game
-- … a button i can text/email to all players in lineup and alt that
-- explains their role and takes them directly to the game center with
-- pill selected for that game … its like a game reminder that also of
-- course since its game center serves as showing starters etc."
--
-- The RSVP reminders only ever reach No Response, so a player who
-- answered Going never hears about the game again.  This is ONE group
-- text / BCC email to every Starting, Bench and Alternate player of a
-- game (the parent for youth): the game, where, when to arrive, and a
-- plain link to #game-center/<match>/starters_bench — no magic link in
-- a group message.  Tokens: {event}, {where}, {arrival}, {link},
-- {sender}; the [[ … ]] lines drop out when the game has no location or
-- arrival time.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'Game reminder — squad, adults', 'squad_notice', 'group_adult',
       'Lighthouse 1893 — game reminder',
       E'Hi all — game reminder. You''re in the squad for:\n'
       '{event}\n'
       '[[Where: {where}\n]]'
       '[[Arrive by {arrival}\n]]'
       '\n'
       'Open the game to see where you are — Starting, Bench or Alternate:\n'
       '{link}\n\n'
       'Starting = on the field at kickoff. Bench = dressed and ready to go on. Alternate = first in if a spot opens, so keep the day free.\n\n'
       'Can''t make it after all? Set Not Going on that same page right away so we can fill your spot.\n\n'
       '— {sender}, Lighthouse 1893',
       20
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'squad_notice' AND tier = 'group_adult');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'Game reminder — squad, parents', 'squad_notice', 'group_parent',
       'Lighthouse 1893 — game reminder',
       E'Hi all — game reminder. Your player is in the squad for:\n'
       '{event}\n'
       '[[Where: {where}\n]]'
       '[[Arrive by {arrival}\n]]'
       '\n'
       'Open the game to see where they are — Starting, Bench or Alternate:\n'
       '{link}\n\n'
       'Starting = on the field at kickoff. Bench = dressed and ready to go on. Alternate = first in if a spot opens, so keep the day free.\n\n'
       'Can''t make it after all? Set Not Going on that same page right away so the coaches can fill the spot.\n\n'
       '— {sender}, Lighthouse 1893',
       21
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'squad_notice' AND tier = 'group_parent');

-- Who was told, about which game, in which role.  The role at send time
-- is kept so Game Center can say how many of the squad have NOT been
-- told where they stand now (added since, or moved Bench → Starting).
CREATE TABLE IF NOT EXISTS squad_notices (
    id                  bigserial PRIMARY KEY,
    match_id            integer NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    person_id           integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    recipient_person_id integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    zone                varchar(20) NOT NULL,
    channel             text NOT NULL CHECK (channel IN ('sms', 'email')),
    contact             text NOT NULL,
    sent_by_user_id     integer REFERENCES users(id) ON DELETE SET NULL,
    sent_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_squad_notices_match ON squad_notices (match_id, person_id, sent_at DESC);
