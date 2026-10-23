-- 667 (2026-10-23) — FH Texter: a coach's own Android sends the texts a
-- coach clicks Send on in Football Home, from the coach's own number.
-- Owner: "this solution we want me on web desktop and send. no phone
-- interaction by me" → "what about the custom app" → "like it … can we
-- make an app and get it installed on my phone?" — and "i don't want
-- anything that could get us rate limited or blocked".
--
-- Never automatic: a text exists here only because a person clicked Send
-- on that one text.  Guardrails live in phone_relay_policy (one row):
-- a daily cap per sender, a gap between sends, one recipient per text,
-- and nobody who replied STOP to the club number.  Recipients must be a
-- phone on a person in the club's records — no typed-in numbers.
-- Group messages stay on the club number and email.

-- 1. Phones ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS phone_relay_devices (
    id           SERIAL PRIMARY KEY,
    person_id    INT  NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    name         TEXT NOT NULL DEFAULT 'Android',
    token_hash   TEXT NOT NULL UNIQUE,
    paired_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen_at TIMESTAMPTZ,
    app_version  TEXT,
    revoked_at   TIMESTAMPTZ
);
COMMENT ON TABLE phone_relay_devices IS 'mig 667: a coach''s Android running FH Texter, paired to that coach. The app authenticates with a device token (sha256 here); last_seen_at = its last poll.';

CREATE TABLE IF NOT EXISTS phone_relay_pair_codes (
    code_hash  TEXT PRIMARY KEY,
    person_id  INT  NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL,
    used_at    TIMESTAMPTZ
);
COMMENT ON TABLE phone_relay_pair_codes IS 'mig 667: one-time 8-character code shown on the desktop and typed into FH Texter to pair it; 15 minutes.';

-- 2. Texts -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS phone_relay_texts (
    id            BIGSERIAL PRIMARY KEY,
    device_id     INT  NOT NULL REFERENCES phone_relay_devices(id) ON DELETE CASCADE,
    sender_person_id INT NOT NULL REFERENCES persons(id),
    for_person_id INT REFERENCES persons(id) ON DELETE SET NULL,
    to_phone      TEXT NOT NULL,
    body          TEXT NOT NULL,
    purpose       TEXT,
    status        TEXT NOT NULL DEFAULT 'queued'
                  CHECK (status IN ('queued', 'sending', 'sent', 'delivered', 'failed', 'expired')),
    error         TEXT,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    not_before    TIMESTAMPTZ NOT NULL DEFAULT now(),
    claimed_at    TIMESTAMPTZ,
    sent_at       TIMESTAMPTZ,
    delivered_at  TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS phone_relay_texts_queue ON phone_relay_texts (device_id, status, not_before);
CREATE INDEX IF NOT EXISTS phone_relay_texts_sender_day ON phone_relay_texts (sender_person_id, created_at);
COMMENT ON TABLE phone_relay_texts IS 'mig 667: one text a coach clicked Send on, carried by their FH Texter phone. not_before spaces sends by phone_relay_policy.min_gap_seconds.';

-- 3. Guardrails --------------------------------------------------------
CREATE TABLE IF NOT EXISTS phone_relay_policy (
    id               INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    daily_cap        INT NOT NULL DEFAULT 30,
    min_gap_seconds  INT NOT NULL DEFAULT 20,
    online_seconds   INT NOT NULL DEFAULT 120,
    expire_minutes   INT NOT NULL DEFAULT 30,
    note             TEXT
);
COMMENT ON TABLE phone_relay_policy IS 'mig 667: keeps texts from a personal number looking like a person texting — at most daily_cap a day per sender, min_gap_seconds apart; a phone unseen for online_seconds counts as offline; a text not picked up within expire_minutes expires.';
INSERT INTO phone_relay_policy (id, daily_cap, min_gap_seconds, online_seconds, expire_minutes, note)
VALUES (1, 30, 20, 120, 30, 'owner 2026-10-23: nothing that could get us rate limited or blocked')
ON CONFLICT (id) DO NOTHING;

-- 4. Copy ----------------------------------------------------------------
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Texts', v.l, 'phone_relay', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('send',         'Desktop panel — send through FH Texter',        '📱 Send from my phone', 1100),
    ('send_hint',    'Desktop panel — what that does ({device})',     'Your {device} sends it from your number in the background — no need to touch it.', 1101),
    ('queued',       'Status — waiting for the phone',                'queued — waiting for your phone…', 1102),
    ('sending',      'Status — phone is sending',                     'your phone is sending…', 1103),
    ('sent',         'Status — sent',                                 'sent ✓', 1104),
    ('delivered',    'Status — delivered',                            'delivered ✓', 1105),
    ('failed',       'Status — failed ({error})',                     'FAILED — {error}', 1106),
    ('expired',      'Status — phone never picked it up',             'not sent — your phone didn''t pick it up (is FH Texter running?)', 1107),
    ('offline',      'Why off — phone offline ({ago})',               'your phone is offline (last seen {ago}) — open FH Texter', 1108),
    ('not_paired',   'Why off — no phone paired',                     'no phone set up yet', 1109),
    ('group',        'Why off — more than one recipient',             'one person at a time from your number — use the club number or email for groups', 1110),
    ('cap',          'Why off — daily cap ({n})',                     'daily limit reached ({n} today) — protects your number', 1111),
    ('today',        'Counter ({n}, {cap})',                          '{n} of {cap} texts from your phone today', 1112),
    ('setup',        'Link — set up FH Texter',                       '📱 Set up FH Texter (send from this computer, your phone does the rest)', 1113),
    ('setup_title',  'Setup — title',                                 '📱 FH Texter — your phone sends, you click Send here', 1114),
    ('setup_steps',  'Setup — steps ({url})',                         '1. On your Android open {url} and install FH Texter (allow installs from Chrome once).
2. Open FH Texter, allow "Send SMS" and notifications.
3. Type this code into the app:', 1115),
    ('setup_wait',   'Setup — waiting',                               'Waiting for your phone… (code works for 15 minutes)', 1116),
    ('setup_done',   'Setup — paired ({device})',                     '✓ Paired with {device}. Close this — 📱 Send from my phone is ready.', 1117)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'phone_relay' AND m.tier = v.t);
