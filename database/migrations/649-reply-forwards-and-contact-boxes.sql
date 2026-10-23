-- 649 (2026-10-23) — Replies to the club number reach a person, and every
-- Game Center card carries the same two contact boxes.
-- Owner: "biggest thing to handle is the transition as users opt in. or
-- out … we need the primary ways to contact them front and center …
-- maybe boxes for auto and manual text" → "auto or manual can be greyed
-- out depending on if they have number or opted in. this way cards are
-- same size" → replies: "yes build both" (forward to the owner's cell AND
-- show on the player's card).
--
-- Before this a reply to (215) 769-9197 was saved in sms_messages and
-- seen by nobody.

-- 1. Who replies are forwarded to ----------------------------------------
CREATE TABLE IF NOT EXISTS sms_reply_forward_to (
    person_id  INT PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    note       TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE sms_reply_forward_to IS 'mig 649: every non-keyword text to the club number is forwarded (from the club number) to these people''s mobiles — only while they are opted in themselves.';
INSERT INTO sms_reply_forward_to (person_id, note)
SELECT 1, 'James — club admin'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 1)
ON CONFLICT (person_id) DO NOTHING;

-- The forward for one inbound text: who it is from (named, with their
-- team or their child's), and the mobiles to send it to.  Keywords
-- (STOP/START/HELP) are not forwarded, and nor is a text FROM a forward
-- recipient (a reply to a forward would bounce back to them forever).
CREATE OR REPLACE FUNCTION fh_sms_reply_forwards(p_sms_message_id BIGINT)
RETURNS TABLE (to_phone TEXT, from_label TEXT, body TEXT)
LANGUAGE sql STABLE AS $$
    WITH m AS (
        SELECT s.*, right(regexp_replace(s.from_number, '[^0-9]', '', 'g'), 10) AS digits
          FROM sms_messages s
         WHERE s.id = p_sms_message_id AND s.direction = 'in' AND s.opt_out_type IS NULL
           AND btrim(COALESCE(s.body, '')) <> ''
    ),
    who AS (
        SELECT m.*, p.id AS pid,
               NULLIF(btrim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), '') AS name,
               -- A parent's phone: name the child too.
               (SELECT string_agg(k.first_name, ', ' ORDER BY k.first_name) FROM persons k
                 WHERE k.parent_person_id = p.id) AS kids,
               (SELECT t.name FROM team_persons tp JOIN teams t ON t.id = tp.team_id
                 WHERE tp.person_id = p.id AND tp.removed_at IS NULL
                 ORDER BY tp.id DESC LIMIT 1) AS team
          FROM m LEFT JOIN persons p ON p.id = m.person_id
    )
    SELECT ph.phone_number::text,
           COALESCE(w.name, w.from_number)
             || CASE WHEN w.kids IS NOT NULL THEN ' (parent of ' || w.kids || ')'
                     WHEN w.team IS NOT NULL THEN ' (' || w.team || ')' ELSE '' END,
           w.body
      FROM who w
      JOIN sms_reply_forward_to f ON true
      JOIN LATERAL (SELECT x.phone_number FROM person_phones x
                     WHERE x.person_id = f.person_id AND x.can_receive_sms
                     ORDER BY x.is_primary DESC, x.id LIMIT 1) ph ON true
     WHERE fh_sms_consented_at(f.person_id) IS NOT NULL
       AND w.digits NOT IN (SELECT right(regexp_replace(COALESCE(x.phone_number, ''), '[^0-9]', '', 'g'), 10)
                              FROM person_phones x JOIN sms_reply_forward_to f2 ON f2.person_id = x.person_id)
$$;

-- 2. Each card's contact state ---------------------------------------------
-- For everyone on one game (rostered on its teams, or invited): who a text
-- goes to (the parent for a child account), whether that person is opted
-- in, STOPped, or neither, their mobile and email, and the latest text
-- they sent the club number in the last 14 days.
CREATE OR REPLACE FUNCTION fh_game_contact_states(p_fh_event_id BIGINT)
RETURNS TABLE (person_id INT, recipient_person_id INT, consent TEXT, phone TEXT, email TEXT,
               reply_body TEXT, reply_at TIMESTAMPTZ)
LANGUAGE sql STABLE AS $$
    WITH ppl AS (
        SELECT DISTINCT p.id, p.parent_person_id,
               NOT EXISTS (SELECT 1 FROM person_self_contacts sc WHERE sc.person_id = p.id) AS child_ok
          FROM persons p
         WHERE EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                        WHERE fet.fh_event_id = p_fh_event_id)
            OR EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = p_fh_event_id
                          AND i.person_id = p.id AND i.revoked_at IS NULL)
    ),
    r AS (
        SELECT ppl.id, CASE WHEN ppl.parent_person_id IS NOT NULL AND ppl.child_ok
                            THEN ppl.parent_person_id ELSE ppl.id END AS rid
          FROM ppl
    )
    SELECT r.id, r.rid,
           CASE WHEN fh_sms_consented_at(r.rid) IS NOT NULL THEN 'in'
                WHEN fh_sms_opted_out_at(r.rid) IS NOT NULL THEN 'stopped'
                ELSE 'none' END,
           (SELECT x.phone_number FROM person_phones x WHERE x.person_id = r.rid AND x.can_receive_sms
             ORDER BY x.is_primary DESC, x.id LIMIT 1)::text,
           (SELECT e.email FROM person_emails e WHERE e.person_id = r.rid
             ORDER BY e.is_primary DESC, e.id LIMIT 1)::text,
           rep.body, rep.created_at
      FROM r
      LEFT JOIN LATERAL (
          SELECT s.body, s.created_at FROM sms_messages s
           WHERE s.direction = 'in' AND s.opt_out_type IS NULL AND s.person_id = r.rid
             AND s.created_at > now() - interval '14 days'
           ORDER BY s.created_at DESC LIMIT 1) rep ON true
$$;

-- 3. Copy ------------------------------------------------------------------
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.c, v.l, v.k, v.t, NULL, v.b, v.o, true, v.cs, false
  FROM (VALUES
    ('Texts',       'Reply forward ({from}, {body})',                 'club_sms',     'reply_forward', '📩 {from}: {body}', 930, false),
    ('Game Center', 'Card box — club number',                         'contact_box',  'auto',          'AUTO · club #', 931, true),
    ('Game Center', 'Card box — your phone',                          'contact_box',  'manual',        'MANUAL · your phone', 932, true),
    ('Game Center', 'Badge — opted in',                               'contact_box',  'badge_in',      '🟢 Club text', 933, true),
    ('Game Center', 'Badge — not opted in',                           'contact_box',  'badge_none',    '🟡 Your phone', 934, true),
    ('Game Center', 'Badge — replied STOP',                           'contact_box',  'badge_stopped', '🔴 Stopped', 935, true),
    ('Game Center', 'Badge — no mobile',                              'contact_box',  'badge_nophone', '⚪ No mobile', 936, true),
    ('Game Center', 'Why AUTO is greyed — not opted in',              'contact_box',  'why_none',      'not opted in to club texts', 937, true),
    ('Game Center', 'Why AUTO is greyed — STOP',                      'contact_box',  'why_stopped',   'replied STOP — call or text personally', 938, true),
    ('Game Center', 'Why greyed — no mobile',                         'contact_box',  'why_nophone',   'no mobile on file', 939, true),
    ('Game Center', 'Why greyed — no email',                          'contact_box',  'why_noemail',   'no email on file', 940, true),
    ('Game Center', 'Why REG is greyed — no gap',                     'contact_box',  'why_noreg',     'no registration needed', 941, true),
    ('Game Center', 'Call button',                                    'contact_box',  'call',          '📞 CALL', 942, true),
    ('Game Center', 'Latest reply on the card ({time}, {body})',      'contact_box',  'reply',         '📩 replied {time}: {body}', 943, true)
  ) AS v(c, l, k, t, b, o, cs)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
