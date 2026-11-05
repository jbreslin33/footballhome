-- 1085: the 📇 Contact popup tells you what happened after Send, and keeps a
-- log per contact (owner 2026-11-05: "yes add it and same for all messages i
-- need status after send" … "there should be a log of last messages sent to
-- that contact on the contact page viewable by clicking an arrow or
-- something. method and message, etc").
--
-- Status after Send — GET /api/phone-relay/send-status:
--   🏢 club text   → sms_messages (Twilio: queued → sent → delivered /
--                    undelivered / failed + error code)
--   📱 FH Texter   → phone_relay_texts (queued → sent → delivered / failed)
--   a sign-in link → magic_link_tokens.consumed_at (👀 opened)
--   ✉ email / 💬 regular text open the sender's own app — FH can't see that
--   step, and the popup says so.
--
-- Log — GET /api/phone-relay/history: the contact's last messages from all
-- three: sms_messages (club), phone_relay_texts (FH Texter), and the new
-- contact_sends below for ✉ / 💬 sends, which no other table records.

BEGIN;

CREATE TABLE IF NOT EXISTS contact_sends (
    id                  bigserial PRIMARY KEY,
    person_id           integer REFERENCES persons(id) ON DELETE CASCADE,   -- recipient (a parent for youth); NULL = a lead
    for_person_id       integer REFERENCES persons(id) ON DELETE SET NULL,  -- the player it was about
    sender_person_id    integer NOT NULL REFERENCES persons(id),
    via                 text    NOT NULL CHECK (via IN ('email', 'text')),
    contact             text,                                               -- the address / number it went to
    label               text,                                               -- the popup's message name ("📣 RSVP reminder")
    subject             text,
    body                text,
    magic_link_token_id integer REFERENCES magic_link_tokens(id) ON DELETE SET NULL,
    created_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS contact_sends_person ON contact_sends (person_id, created_at DESC);
CREATE INDEX IF NOT EXISTS contact_sends_for_person ON contact_sends (for_person_id, created_at DESC);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Contact', v.l, 'contact_popup', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Status — club text queued',          'st_club_queued',    '🏢 Club text queued…', 1350),
    ('Status — club text sent',            'st_club_sent',      '🏢 Sent — waiting for the phone to confirm…', 1351),
    ('Status — delivered ({time})',        'st_delivered',      '✓ Delivered {time}', 1352),
    ('Status — not delivered ({why})',     'st_failed',         '⚠ Not delivered — {why}', 1353),
    ('Status — FH Texter queued',          'st_relay_queued',   '📱 Waiting for your phone to send it…', 1354),
    ('Status — FH Texter sent ({time})',   'st_relay_sent',     '📱 Sent from your phone {time}, waiting for delivery…', 1355),
    ('Status — link opened ({time})',      'st_link_opened',    '👀 Link opened {time}', 1356),
    ('Status — link not opened yet',       'st_link_waiting',   'Link not opened yet', 1357),
    ('Status — email opened in Gmail',     'st_email_device',   '✉ Opened in Gmail — FH can''t see whether you pressed Send there.', 1358),
    ('Status — text opened in phone app',  'st_text_device',    '💬 Opened in your texting app — FH can''t see whether you pressed Send there.', 1359),
    ('Log — toggle ({n})',                 'log_toggle',        'Recent messages ({n})', 1360),
    ('Log — empty',                        'log_empty',         'Nothing sent to this contact yet.', 1361),
    ('Log — via club text',                'log_via_club',      '🏢 Club text', 1362),
    ('Log — via FH Texter',                'log_via_relay',     '📱 FH Texter', 1363),
    ('Log — via email',                    'log_via_email',     '✉ Email', 1364),
    ('Log — via regular text',             'log_via_text',      '💬 Regular text', 1365)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_popup' AND m.tier = v.t);

COMMIT;
