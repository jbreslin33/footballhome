-- 537 (2026-10-07) — #texts: who has opted in to club texts, nudge the rest.
--
-- The Twilio A2P campaign was approved 2026-10-05 on the basis that club
-- texts go only to people who opted in at footballhome.org/sms.  Owner:
-- "we need an opt in message? that tracks who opted in and we can remind
-- them manually until they do? have a tracker page for that at top level?
-- ... like we do for numbers/kits".
--
-- So, like #kit: a board, one team at a time, one row per player — the
-- mobile we would text (the parent's for a youth player), whether that
-- person has consented (an sms_opt_ins row, by person or by phone), and
-- how many times they have been nudged.  The 💬 nudge is a text from the
-- operator's own phone (not Twilio — asking for consent by A2P text is
-- itself unsolicited) carrying a per-person magic link to /sms, which
-- lands pre-filled; the consent row it writes is tied to the person.
--
--   sms_opt_in_nudges            every nudge sent (who, to whom, when, by whom)
--   sms_opt_ins.magic_link_token_id   the link a consent came in on
--   fh_sms_consented_at(person)  latest consent for a person — by person_id
--                                or by any of their phone numbers; the one
--                                question every server-sent text must ask
--   message_templates            kind sms_opt_in (page + nudge wording),
--                                legal_sms tiers hello / already (the
--                                pre-filled /sms page)

CREATE TABLE IF NOT EXISTS sms_opt_in_nudges (
    id                  SERIAL PRIMARY KEY,
    person_id           INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,   -- the player the row is about
    recipient_person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,   -- who was texted (parent for youth)
    channel             TEXT NOT NULL DEFAULT 'sms',
    contact             TEXT NOT NULL,
    sent_by_user_id     INTEGER REFERENCES users(id) ON DELETE SET NULL,
    sent_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS sms_opt_in_nudges_person_idx ON sms_opt_in_nudges (person_id, sent_at DESC);
COMMENT ON TABLE sms_opt_in_nudges IS
  'Opt-in nudges sent from #texts (mig 537): a personal link to footballhome.org/sms, texted from the operator''s phone.';

ALTER TABLE sms_opt_ins
    ADD COLUMN IF NOT EXISTS magic_link_token_id INTEGER REFERENCES magic_link_tokens(id) ON DELETE SET NULL;
COMMENT ON COLUMN sms_opt_ins.magic_link_token_id IS
  'The nudge link this consent came in on (mig 537) — NULL for a walk-up sign-up.';

-- Latest consent on file for a person: a row tied to them, or a row whose
-- phone is one of theirs.  NULL = never consented (or the number changed).
CREATE OR REPLACE FUNCTION fh_sms_consented_at(p_person_id integer) RETURNS timestamptz
LANGUAGE sql STABLE AS $$
    SELECT max(o.consented_at)
      FROM sms_opt_ins o
     WHERE o.person_id = p_person_id
        OR o.phone_digits IN (
            SELECT right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10)
              FROM person_phones pp WHERE pp.person_id = p_person_id)
$$;
COMMENT ON FUNCTION fh_sms_consented_at(integer) IS
  'When this person last consented to club texts (sms_opt_ins by person or phone), NULL if never. Every server-sent text checks this (mig 537).';

-- ── Wording ───────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.set_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int,
                                          p_client boolean, p_public boolean, p_category text)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, updated_at = now()
   WHERE kind = p_kind AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES (p_category, p_label, p_kind, p_tier, NULL, p_body, p_sort, true, p_client, p_public);
  END IF;
END $$;

-- The page (#texts) — client side.
SELECT pg_temp.set_tpl('sms_opt_in', 'tile_title',   'Picker tile — title',          'Texts', 800, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'tile_sub',     'Picker tile — line under',     'Who has said yes to club texts — nudge the rest until they do', 801, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'title',        'Page title',                   '📲 Texts', 802, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'subtitle',     'Page subtitle',
  'Club texts from (215) 769-9197 go only to people who opted in at footballhome.org/sms. A tick is a consent on file for the mobile we would text — the parent''s for a youth player. 💬 texts them a personal link to the sign-up from your phone; keep nudging until the tick appears.', 803, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'filter_all',   'Filter pill — everyone',       'Everyone', 804, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'filter_not',   'Filter pill — not opted in',   'Not yet', 805, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'filter_in',    'Filter pill — opted in',       'Opted in', 806, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'filter_none',  'Filter pill — no mobile',      'No mobile', 807, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'summary',      'Line over the table ({in} {total} {nudged})', '{in}/{total} opted in · {nudged} nudged at least once', 808, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'col_player',   'Column — player',              'Player', 809, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'col_mobile',   'Column — mobile',              'Mobile', 810, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'col_optin',    'Column — opted in',            'Opted in', 811, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'col_nudged',   'Column — nudged',              'Nudged', 812, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'status_in',    'Cell — consent on file ({date})', '✅ {date}', 813, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'status_not',   'Cell — no consent yet',        '—', 814, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'status_none',  'Cell — no mobile on file',     'no mobile on file', 815, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'parent_tag',   'Tag next to a parent''s mobile', 'parent', 816, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'nudge_btn',    'Button — first nudge',         '💬 Nudge', 817, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'nudge_btn_sent','Button — nudged before ({sent})', '💬 Nudge ×{sent}', 818, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'nudged_cell',  'Cell — nudged ({sent} {date})', '×{sent}, last {date}', 819, true, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'empty',        'No one on the team',           'Nobody is on this team.', 820, true, false, 'Texts');

-- The nudge itself — rendered on the server with the magic link.
SELECT pg_temp.set_tpl('sms_opt_in', 'adult', 'Nudge text — adult player ({first} {sender} {link})',
  'Hi {first}, it''s {sender} from Lighthouse 1893. Can we text you game and practice reminders through Football Home? Your link: {link} — tick the text-message box and send. Takes 10 seconds. Reply STOP to any text to stop them.', 830, false, false, 'Texts');
SELECT pg_temp.set_tpl('sms_opt_in', 'parent', 'Nudge text — parent ({first} {child} {sender} {link})',
  'Hi {first}, it''s {sender} from Lighthouse 1893. Can we text you {child}''s game and practice reminders through Football Home? Your link: {link} — tick the text-message box and send. Takes 10 seconds. Reply STOP to any text to stop them.', 831, false, false, 'Texts');

-- The pre-filled /sms page (public, read by sms.html).
SELECT pg_temp.set_tpl('legal_sms', 'hello',   'Pre-filled page — greeting ({first} {phone})',
  'Hi {first} — this link is yours. Your details are filled in below: tick the text-message box and send, and club texts come to {phone}.', 40, false, true, 'System');
SELECT pg_temp.set_tpl('legal_sms', 'already', 'Pre-filled page — already opted in ({date})',
  'You already said yes on {date} — nothing more to do. Send again only to change your number.', 41, false, true, 'System');
