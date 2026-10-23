-- 647 (2026-10-23) — Ask for text opt-in on RSVP; club-number texts from
-- Game Center with delivered / opened marks.
-- Owner: "can we build the opt in into the rsvps? like if they are not
-- opted in when they click going or not going it prompts them to opt in"
-- → "it should ask once for each event"; agreed: at most once a day,
-- "Don't ask me again" sticks, never after STOP, youth asks the parent.
-- And: "we don't want messages going into the void. does it show if
-- delivered? if opened?"
--
-- The ask never collects consent itself: it links to footballhome.org/sms
-- pre-filled (the nudge's magic-link prefill, mig 537), the sign-up page
-- the A2P campaign registers as the opt-in path — so the campaign's
-- message flow stays true without an edit.

-- 1. Asks ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS sms_opt_in_asks (
    id          BIGSERIAL PRIMARY KEY,
    person_id   INT    NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    fh_event_id BIGINT NOT NULL,
    asked_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    answer      TEXT CHECK (answer IN ('opened', 'later', 'never')),
    answered_at TIMESTAMPTZ,
    UNIQUE (person_id, fh_event_id)
);
COMMENT ON TABLE sms_opt_in_asks IS 'mig 647: the "get reminders by text?" card shown after an RSVP — one per person per event. answer: opened (went to /sms), later (Not now), never (Don''t ask me again — sticks).';

-- Should this signed-in person see the ask after answering this event?
-- Not opted in, never STOPped, never said "don't ask", not yet asked
-- about this event, not asked anything in the last 20 hours, and not a
-- child account (the parent is asked — a youth row with a parent and no
-- self-contact flag).
CREATE OR REPLACE FUNCTION fh_sms_opt_in_should_ask(p_person_id INT, p_fh_event_id BIGINT)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
    SELECT fh_sms_consented_at(p_person_id) IS NULL
       AND fh_sms_opted_out_at(p_person_id) IS NULL
       AND NOT EXISTS (SELECT 1 FROM persons p WHERE p.id = p_person_id AND p.parent_person_id IS NOT NULL
                          AND NOT EXISTS (SELECT 1 FROM person_self_contacts sc WHERE sc.person_id = p.id))
       AND NOT EXISTS (SELECT 1 FROM sms_opt_in_asks a WHERE a.person_id = p_person_id
                          AND (a.answer = 'never' OR a.fh_event_id = p_fh_event_id
                               OR a.asked_at > now() - interval '20 hours'))
$$;

-- 2. Link opens ---------------------------------------------------------
-- Every hit on a magic link, not just the last: a messaging app's link
-- preview (Google Messages fetched ~300 of them before 10/23) is not the
-- player tapping it.

CREATE TABLE IF NOT EXISTS magic_link_opens (
    id         BIGSERIAL PRIMARY KEY,
    token_id   INT NOT NULL REFERENCES magic_link_tokens(id) ON DELETE CASCADE,
    opened_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    user_agent TEXT,
    is_preview BOOLEAN NOT NULL DEFAULT false
);
CREATE INDEX IF NOT EXISTS magic_link_opens_token ON magic_link_opens (token_id, opened_at);
COMMENT ON TABLE magic_link_opens IS 'mig 647: each GET of a magic link. is_preview = a link-preview fetcher (fh_is_link_preview), not the person.';

CREATE TABLE IF NOT EXISTS link_preview_agents (
    pattern TEXT PRIMARY KEY,
    note    TEXT
);
COMMENT ON TABLE link_preview_agents IS 'mig 647: case-insensitive regex on User-Agent naming a link-preview fetcher — its opens never count as the person opening the link.';
INSERT INTO link_preview_agents (pattern, note) VALUES
    ('googlemessages',     'Google Messages link preview'),
    ('facebookexternalhit','Meta preview'),
    ('facebot',            'Meta preview'),
    ('twitterbot',         'X preview'),
    ('whatsapp',           'WhatsApp preview'),
    ('telegrambot',        'Telegram preview'),
    ('slackbot',           'Slack preview'),
    ('discordbot',         'Discord preview'),
    ('skypeuripreview',    'Skype/Teams preview'),
    ('microsoftpreview',   'Outlook preview'),
    ('googleimageproxy',   'Gmail image proxy'),
    ('bot\b|crawler|spider','generic crawlers'),
    ('^curl/',             'command-line fetch')
ON CONFLICT (pattern) DO NOTHING;

CREATE OR REPLACE FUNCTION fh_is_link_preview(p_ua TEXT) RETURNS BOOLEAN
LANGUAGE sql STABLE AS $$
    SELECT COALESCE(p_ua, '') = '' OR EXISTS (SELECT 1 FROM link_preview_agents a WHERE p_ua ~* a.pattern)
$$;

-- 3. Texts sent from the club number about one game -----------------------
-- sms_messages.purpose carries 'game_link:<match_id>' / 'reg_link:<fh_event_id>';
-- these columns tie the row to the person it was for and the link it carried.
ALTER TABLE sms_messages ADD COLUMN IF NOT EXISTS for_person_id INT REFERENCES persons(id) ON DELETE SET NULL;
ALTER TABLE sms_messages ADD COLUMN IF NOT EXISTS magic_link_token_id INT REFERENCES magic_link_tokens(id) ON DELETE SET NULL;
COMMENT ON COLUMN sms_messages.for_person_id IS 'mig 647: the player the text was about (the recipient may be their parent) — Game Center card marks.';
COMMENT ON COLUMN sms_messages.magic_link_token_id IS 'mig 647: the magic link the text carried — its real opens are the card''s "opened" mark.';

-- Twilio's delivery error codes in words (status callback error_code).
CREATE TABLE IF NOT EXISTS sms_error_texts (
    code TEXT PRIMARY KEY,
    text TEXT NOT NULL
);
COMMENT ON TABLE sms_error_texts IS 'mig 647: Twilio error code → the words a Game Center card shows on a failed text.';
INSERT INTO sms_error_texts (code, text) VALUES
    ('30003', 'phone off or unreachable'),
    ('30004', 'the number blocks our texts'),
    ('30005', 'number does not exist'),
    ('30006', 'landline — can''t take texts'),
    ('30007', 'carrier filtered it as spam'),
    ('30008', 'carrier error — try again'),
    ('21610', 'they replied STOP'),
    ('21211', 'not a valid phone number'),
    ('30034', 'club number not registered')
ON CONFLICT (code) DO NOTHING;

-- Latest club-number text per player for one game's cards, with its
-- delivery state and the first real open of the link it carried.
CREATE OR REPLACE FUNCTION fh_game_text_marks(p_match_id INT, p_fh_event_id BIGINT)
RETURNS TABLE (person_id INT, kind TEXT, status TEXT, error_code TEXT, error_text TEXT, sent_at TIMESTAMPTZ, opened_at TIMESTAMPTZ)
LANGUAGE sql STABLE AS $$
    SELECT DISTINCT ON (m.for_person_id, k.kind)
           m.for_person_id, k.kind, m.status, m.error_code,
           COALESCE((SELECT e.text FROM sms_error_texts e WHERE e.code = m.error_code), m.error_code), m.created_at,
           (SELECT min(o.opened_at) FROM magic_link_opens o
             WHERE o.token_id = m.magic_link_token_id AND NOT o.is_preview)
      FROM sms_messages m
      CROSS JOIN LATERAL (SELECT split_part(m.purpose, ':', 1) AS kind) k
     WHERE m.direction = 'out' AND m.for_person_id IS NOT NULL
       AND (m.purpose = 'game_link:' || p_match_id OR m.purpose = 'reg_link:' || p_fh_event_id)
     ORDER BY m.for_person_id, k.kind, m.created_at DESC
$$;

-- 4. Copy ------------------------------------------------------------------

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.c, v.l, v.k, v.t, NULL, v.b, v.o, true, v.cs, false
  FROM (VALUES
    -- Every club-number text opens with the brand and ends with opt-out
    -- (the A2P campaign promises both).
    ('Texts',       'Club-number text — opening (brand)',            'club_sms',      'prefix',   'Football Home (Lighthouse 1893 SC): ', 910, false),
    ('Texts',       'Club-number text — closing (opt-out)',          'club_sms',      'footer',   ' Reply STOP to opt out.', 911, false),
    -- The RSVP ask card.
    ('Texts',       'RSVP ask — title',                              'sms_opt_in_ask','title',    'Get game reminders by text?', 912, true),
    ('Texts',       'RSVP ask — body ({phone})',                     'sms_opt_in_ask','body',     'Your answer is saved. Want reminders, lineups and schedule changes by text instead of hunting for them? It takes 10 seconds on the sign-up page — tick the box and send.', 913, true),
    ('Texts',       'RSVP ask — yes button',                         'sms_opt_in_ask','yes',      'Yes, text me', 914, true),
    ('Texts',       'RSVP ask — not now',                            'sms_opt_in_ask','later',    'Not now', 915, true),
    ('Texts',       'RSVP ask — never',                              'sms_opt_in_ask','never',    'Don''t ask me again', 916, true),
    -- Game Center card marks.
    ('Game Center', 'Card — club-number text button',                'text_mark',     'button',   '📲 CLUB TEXT', 917, true),
    ('Game Center', 'Card — club text button hover',                 'text_mark',     'button_tip','Send from the club number (215) 769-9197 — shows sent, delivered and opened here. Only players who opted in to texts.', 918, true),
    ('Game Center', 'Card — not opted in',                           'text_mark',     'no_consent','not opted in to texts — use 💬 from your phone', 919, true),
    ('Game Center', 'Card — queued/sent',                            'text_mark',     'sent',     'texted {time} · sending…', 920, true),
    ('Game Center', 'Card — delivered',                              'text_mark',     'delivered','texted {time} · delivered ✓', 921, true),
    ('Game Center', 'Card — failed ({error})',                       'text_mark',     'failed',   'text FAILED {time} — {error}', 922, true),
    ('Game Center', 'Card — opened ({time})',                        'text_mark',     'opened',   'opened ✓ {time}', 923, true)
  ) AS v(c, l, k, t, b, o, cs)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
