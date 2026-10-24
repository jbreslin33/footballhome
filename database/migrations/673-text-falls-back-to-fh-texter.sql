-- 673 (2026-10-24) — One "📲 Text" in Game Center's contact sheet: the
-- club number when the player opted in, else the owner's own phone via
-- FH Texter (mig 667), else the copy-and-paste panel.  Owner: "bascially
-- it should default to using twilio phone for text. then fall back to my
-- phone app if not opted in" — one click per player, never a batch.
--
-- FH Texter texts now land on the card like club texts do: the same
-- sent → delivered marks, opened ✓ from the magic link they carry, and a
-- 📱 so the coach can tell which number it went from.

-- 1. The magic link a phone text carries, for its opened ✓ ----------------
ALTER TABLE phone_relay_texts
    ADD COLUMN IF NOT EXISTS magic_link_token_id INT REFERENCES magic_link_tokens(id) ON DELETE SET NULL;
COMMENT ON COLUMN phone_relay_texts.magic_link_token_id IS
    'mig 673: the sign-in link inside this text (game link / RSVP reminder) — its real opens are the card''s opened ✓.';

-- 2. Card marks: club texts and FH Texter texts, newest per player+kind ----
DROP FUNCTION IF EXISTS fh_game_text_marks(integer, bigint);
CREATE FUNCTION fh_game_text_marks(p_match_id integer, p_fh_event_id bigint)
RETURNS TABLE(person_id integer, kind text, status text, error_code text, error_text text,
              sent_at timestamptz, opened_at timestamptz, via text)
LANGUAGE sql STABLE AS $$
    SELECT DISTINCT ON (t.for_person_id, t.kind)
           t.for_person_id, t.kind, t.status, t.error_code, t.error_text, t.created_at,
           (SELECT min(o.opened_at) FROM magic_link_opens o
             WHERE o.token_id = t.token_id AND NOT o.is_preview),
           t.via
      FROM (
        SELECT m.for_person_id, split_part(m.purpose, ':', 1) AS kind, m.status, m.error_code,
               COALESCE((SELECT e.text FROM sms_error_texts e WHERE e.code = m.error_code), m.error_code) AS error_text,
               m.created_at, m.magic_link_token_id AS token_id, 'club'::text AS via
          FROM sms_messages m
         WHERE m.direction = 'out' AND m.for_person_id IS NOT NULL
           AND (m.purpose = 'game_link:' || p_match_id OR m.purpose = 'reg_link:' || p_fh_event_id)
        UNION ALL
        -- queued/sending read as queued; a text the phone never picked up
        -- is a failure with the phone_relay 'expired' words.
        SELECT r.for_person_id, split_part(r.purpose, ':', 1),
               CASE WHEN r.status IN ('queued', 'sending') THEN 'queued'
                    WHEN r.status = 'expired' THEN 'failed' ELSE r.status END,
               NULL,
               CASE WHEN r.status = 'expired'
                    THEN (SELECT mt.body FROM message_templates mt WHERE mt.kind = 'phone_relay' AND mt.tier = 'expired')
                    ELSE r.error END,
               r.created_at, r.magic_link_token_id, 'phone'
          FROM phone_relay_texts r
         WHERE r.for_person_id IS NOT NULL
           AND (r.purpose = 'game_link:' || p_match_id OR r.purpose = 'reg_link:' || p_fh_event_id)
      ) t
     ORDER BY t.for_person_id, t.kind, t.created_at DESC
$$;

-- 3. Copy ------------------------------------------------------------------
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, v.k, v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('contact_menu', 'how_text',        'How — one Text option (route picked per player)',      '📲 Text', 977),
    ('contact_menu', 'route_club',      'Text route — club number (opted in)',                 'goes from the club number (215) 769-9197', 978),
    ('contact_menu', 'route_relay',     'Text route — FH Texter ({device})',                   'goes from your phone ({device}) — not opted in to club texts', 979),
    ('contact_menu', 'route_manual',    'Text route — copy & paste ({why})',                   'copy & paste from your phone — {why}', 980),
    ('contact_menu', 'manual_why_unpaired', 'Copy & paste because — FH Texter not set up',     'FH Texter not set up', 981),
    ('contact_menu', 'manual_why_offline',  'Copy & paste because — phone offline',            'your phone is offline (open FH Texter)', 982),
    ('contact_menu', 'manual_why_cap',      'Copy & paste because — daily cap',                'FH Texter daily limit reached', 983),
    ('contact_menu', 'manual_why_blank',    'Copy & paste because — own words',                'your own words', 984),
    ('contact_menu', 'manual_why_stopped',  'Copy & paste because — replied STOP',             'they replied STOP to the club number', 985),
    ('contact_menu', 'relay_fell_back', 'FH Texter refused — paste instead ({error})',         'FH Texter couldn''t send it ({error}) — paste it instead', 986),
    ('text_mark',    'queued',          'Card — FH Texter text waiting for the phone ({time})', 'texted {time} · waiting for your phone…', 924),
    ('text_mark',    'via_phone',       'Card — prefix on a text sent from the owner''s phone', '📱', 925)
  ) AS v(k, t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
