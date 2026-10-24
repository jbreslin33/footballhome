-- 683 (2026-10-24) — Game Center's contact sheet sees every parent.
-- With mig 682 a kid can have two parents (divorced: each texted
-- separately), so the card's contact state is one row per parent, and a
-- text mark says which parent it went to.  Owner: "any text should go
-- out separate to both … option to send to both but sep".

-- 1. One row per (player, recipient) — each parent with their own consent,
--    mobile and email; ord 1 = primary.  Self-contact adults are already
--    their own recipient (fh_message_recipients, mig 682).
DROP FUNCTION IF EXISTS fh_game_contact_states(bigint);
CREATE FUNCTION fh_game_contact_states(p_fh_event_id bigint)
RETURNS TABLE(person_id integer, recipient_person_id integer, recipient_name text, ord integer,
              consent text, phone text, email text, reply_body text, reply_at timestamptz)
LANGUAGE sql STABLE AS $$
    WITH ppl AS (
        SELECT DISTINCT p.id
          FROM persons p
         WHERE EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                        WHERE fet.fh_event_id = p_fh_event_id)
            OR EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = p_fh_event_id
                          AND i.person_id = p.id AND i.revoked_at IS NULL)
    ),
    r AS (
        SELECT ppl.id, m.recipient_person_id AS rid, m.ord
          FROM ppl CROSS JOIN LATERAL fh_message_recipients(ppl.id) m
    )
    SELECT r.id, r.rid, COALESCE(rp.first_name, '')::text, r.ord,
           CASE WHEN fh_sms_consented_at(r.rid) IS NOT NULL THEN 'in'
                WHEN fh_sms_opted_out_at(r.rid) IS NOT NULL THEN 'stopped'
                ELSE 'none' END,
           (SELECT x.phone_number FROM person_phones x WHERE x.person_id = r.rid AND x.can_receive_sms
             ORDER BY x.is_primary DESC, x.id LIMIT 1)::text,
           (SELECT e.email FROM person_emails e WHERE e.person_id = r.rid
             ORDER BY e.is_primary DESC, e.id LIMIT 1)::text,
           rep.body, rep.created_at
      FROM r
      JOIN persons rp ON rp.id = r.rid
      LEFT JOIN LATERAL (
          SELECT s.body, s.created_at FROM sms_messages s
           WHERE s.direction = 'in' AND s.opt_out_type IS NULL AND s.person_id = r.rid
             AND s.created_at > now() - interval '14 days'
           ORDER BY s.created_at DESC LIMIT 1) rep ON true
$$;

-- 2. Card marks per (player, recipient, kind): club texts know their
--    recipient by phone (sms_messages.person_id); FH Texter texts resolve
--    it from the number they went to.
DROP FUNCTION IF EXISTS fh_game_text_marks(integer, bigint);
CREATE FUNCTION fh_game_text_marks(p_match_id integer, p_fh_event_id bigint)
RETURNS TABLE(person_id integer, kind text, status text, error_code text, error_text text,
              sent_at timestamptz, opened_at timestamptz, via text, recipient_person_id integer)
LANGUAGE sql STABLE AS $$
    SELECT DISTINCT ON (t.for_person_id, t.rid, t.kind)
           t.for_person_id, t.kind, t.status, t.error_code, t.error_text, t.created_at,
           (SELECT min(o.opened_at) FROM magic_link_opens o
             WHERE o.token_id = t.token_id AND NOT o.is_preview),
           t.via, t.rid
      FROM (
        SELECT m.for_person_id, split_part(m.purpose, ':', 1) AS kind, m.status, m.error_code,
               COALESCE((SELECT e.text FROM sms_error_texts e WHERE e.code = m.error_code), m.error_code) AS error_text,
               m.created_at, m.magic_link_token_id AS token_id, 'club'::text AS via, m.person_id AS rid
          FROM sms_messages m
         WHERE m.direction = 'out' AND m.for_person_id IS NOT NULL
           AND (m.purpose = 'game_link:' || p_match_id OR m.purpose = 'reg_link:' || p_fh_event_id)
        UNION ALL
        SELECT r.for_person_id, split_part(r.purpose, ':', 1),
               CASE WHEN r.status IN ('queued', 'sending') THEN 'queued'
                    WHEN r.status = 'expired' THEN 'failed' ELSE r.status END,
               NULL,
               CASE WHEN r.status = 'expired'
                    THEN (SELECT mt.body FROM message_templates mt WHERE mt.kind = 'phone_relay' AND mt.tier = 'expired')
                    ELSE r.error END,
               r.created_at, r.magic_link_token_id, 'phone',
               fh_person_by_phone(right(regexp_replace(r.to_phone, '[^0-9]', '', 'g'), 10))
          FROM phone_relay_texts r
         WHERE r.for_person_id IS NOT NULL
           AND (r.purpose = 'game_link:' || p_match_id OR r.purpose = 'reg_link:' || p_fh_event_id)
      ) t
     ORDER BY t.for_person_id, t.rid, t.kind, t.created_at DESC
$$;

-- 3. Copy for the sheet's TO row, mixed routes and multi-send steps.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'contact_menu', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('to',            'TO label (two or more parents)',                     'To', 992),
    ('to_hint',       'TO hint — each parent gets their own message',       'each one gets their own message', 993),
    ('via_best',      'Text sub-option — best route per parent ({routes})', '✨ Best for each — {routes}', 994),
    ('route_club_short',  'Per-parent route word — club number',            'club number', 995),
    ('route_relay_short', 'Per-parent route word — FH Texter',              'your phone', 996),
    ('route_paste_short', 'Per-parent route word — copy & paste',           'you send it', 997),
    ('via_relay_all', 'Text sub-option — all through FH Texter ({device})', '📱 All from my phone — FH Texter sends them ({device})', 998),
    ('via_paste_all', 'Text sub-option — all by hand',                      '💬 I''ll send them in Messages myself', 999),
    ('via_club_all',  'Text sub-option — all from the club number',         '📲 All from the club number (215) 769-9197', 1000),
    ('why_not_all_in','Why off — not every ticked parent opted in',         'not everyone ticked opted in to club texts', 1001),
    ('none_ticked',   'Send blocked — nobody ticked',                       'Tick at least one person', 1002),
    ('next_of',       'Multi-send step ({n} of {total}, {name})',           'Next: {name} ({n} of {total})', 1003)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_menu' AND m.tier = v.t);

-- 4. "Separate messages" chooser (DesktopSms.openMany): one button per
--    parent, and the group-text parts the bulk composer splits so two
--    parents of the same kid never share a thread.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Texts', v.l, 'desktop_sms', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('many_title', 'Separate messages — title ({n})',                 '{n} separate messages', 1200),
    ('many_hint',  'Separate messages — hint',                        'Each one gets their own message — open them one at a time.', 1201),
    ('many_part',  'Group text part ({n}, {total}, {count})',         '💬 Part {n}/{total} ({count})', 1202)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'desktop_sms' AND m.tier = v.t);
