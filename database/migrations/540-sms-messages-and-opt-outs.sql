-- 540 (2026-10-07) — every text in and out of (215) 769-9197 on record,
-- STOP / START honoured.  Owner: "we need to track it all".
--
--   sms_messages     one row per text: every inbound (Twilio webhook
--                    POST /api/public/twilio/sms-inbound) and every
--                    outbound the backend sends (TwilioService), with the
--                    delivery status Twilio reports back
--                    (POST /api/public/twilio/sms-status)
--   sms_opt_outs     a STOP (or Twilio's OptOutType=STOP) from a number;
--                    START / UNSTOP / YES writes a fresh sms_opt_ins row
--                    (source keyword:START) instead
--   fh_sms_opted_out_at(person)  latest STOP from any of their numbers
--   fh_sms_consented_at(person)  now NULL when a STOP came after the
--                                latest consent — the one question every
--                                server-sent text asks (mig 537)
--   fh_person_by_phone(digits)   who a number belongs to (person_phones)

CREATE TABLE IF NOT EXISTS sms_messages (
    id            BIGSERIAL PRIMARY KEY,
    direction     TEXT NOT NULL CHECK (direction IN ('in', 'out')),
    message_sid   TEXT UNIQUE,                 -- Twilio SM…/MM…; NULL when the send never reached Twilio
    from_number   TEXT NOT NULL,
    to_number     TEXT NOT NULL,
    body          TEXT NOT NULL DEFAULT '',
    status        TEXT,                        -- queued/sent/delivered/undelivered/failed (out), received (in)
    error_code    TEXT,
    opt_out_type  TEXT,                        -- STOP | START | HELP as Twilio flags it (in)
    person_id     INTEGER REFERENCES persons(id) ON DELETE SET NULL,   -- the other party, by phone
    purpose       TEXT,                        -- lockup_alert, … (out)
    raw           JSONB,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS sms_messages_created_idx ON sms_messages (created_at DESC);
CREATE INDEX IF NOT EXISTS sms_messages_person_idx  ON sms_messages (person_id, created_at DESC);
COMMENT ON TABLE sms_messages IS
  'Every text in or out of the club Twilio number (mig 540): inbound via the Twilio webhook, outbound as the backend sends it, status from the Twilio status callback.';

CREATE TABLE IF NOT EXISTS sms_opt_outs (
    id              SERIAL PRIMARY KEY,
    phone_digits    TEXT NOT NULL,              -- 10 digits
    person_id       INTEGER REFERENCES persons(id) ON DELETE SET NULL,
    sms_message_id  BIGINT REFERENCES sms_messages(id) ON DELETE SET NULL,
    keyword         TEXT NOT NULL,              -- what they sent
    received_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS sms_opt_outs_phone_idx ON sms_opt_outs (phone_digits, received_at DESC);
COMMENT ON TABLE sms_opt_outs IS 'STOP keywords received on the club number (mig 540). A later START is a new sms_opt_ins row.';

CREATE OR REPLACE FUNCTION fh_person_by_phone(p_digits text) RETURNS integer
LANGUAGE sql STABLE AS $$
    SELECT pp.person_id FROM person_phones pp
     WHERE regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g') IN (p_digits, '1' || p_digits)
     ORDER BY pp.is_primary DESC NULLS LAST, pp.person_id LIMIT 1
$$;

CREATE OR REPLACE FUNCTION fh_sms_opted_out_at(p_person_id integer) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
    SELECT max(o.received_at)
      FROM sms_opt_outs o
     WHERE o.person_id = p_person_id
        OR o.phone_digits IN (
            SELECT right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10)
              FROM person_phones pp WHERE pp.person_id = p_person_id)
$$;

-- Consent stands only while no STOP came after it.
CREATE OR REPLACE FUNCTION fh_sms_consented_at(p_person_id integer) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
    SELECT CASE WHEN c.at IS NOT NULL AND (s.at IS NULL OR c.at > s.at) THEN c.at END
      FROM (SELECT max(o.consented_at) AS at
              FROM sms_opt_ins o
             WHERE o.person_id = p_person_id
                OR o.phone_digits IN (
                    SELECT right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10)
                      FROM person_phones pp WHERE pp.person_id = p_person_id)) c,
           (SELECT fh_sms_opted_out_at(p_person_id) AS at) s
$$;
COMMENT ON FUNCTION fh_sms_consented_at(integer) IS
  'When this person last consented to club texts (sms_opt_ins by person or phone), NULL if never or if a STOP came later (mig 540). Every server-sent text checks this.';

-- ── #texts wording for a STOP ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.set_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, updated_at = now()
   WHERE kind = 'sms_opt_in' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('Texts', p_label, 'sms_opt_in', p_tier, NULL, p_body, p_sort, true, true, false);
  END IF;
END $$;
SELECT pg_temp.set_tpl('filter_stopped', 'Filter pill — replied STOP',        'Stopped', 807);
SELECT pg_temp.set_tpl('filter_none',    'Filter pill — no mobile',           'No mobile', 808);
SELECT pg_temp.set_tpl('status_stopped', 'Cell — replied STOP ({date})',      '🚫 STOP {date}', 816);
SELECT pg_temp.set_tpl('summary',        'Line over the table ({in} {total} {stopped} {nudged})',
                       '{in}/{total} opted in · {stopped} stopped · {nudged} nudged at least once', 809);
SELECT pg_temp.set_tpl('subtitle',       'Page subtitle',
  'Club texts from (215) 769-9197 go only to people who opted in at footballhome.org/sms or texted START. A tick is a consent on file for the mobile we would text — the parent''s for a youth player; 🚫 means they replied STOP since. 💬 texts them a personal link to the sign-up from your phone; keep nudging until the tick appears.', 803);
