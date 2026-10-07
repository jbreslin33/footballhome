-- 543 (2026-10-07) — the RSVP roll call: one message with who's Going, who's
-- Not Going and who still hasn't answered a game.
-- Owner: "we always get some stragglers on game rsvp. some are always the
-- same. what about a little public shaming lol to spur action since
-- individual messages don't work for some" / "a message (not sure what
-- medium yet) that has the going and not going list but shows the non
-- respondants lol".
--
-- Per section, by policy: club_sections.rsvp_roll_call says whether the
-- #rsvps board offers it (Men yes; the youth are children and the women
-- have not asked), and rsvp_roll_call_chat_slug names the chat whose
-- GroupMe integration takes the post.  Every roll call sent is a
-- rsvp_roll_calls row.  Players only — coaches and staff never appear.
ALTER TABLE club_sections
    ADD COLUMN IF NOT EXISTS rsvp_roll_call BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS rsvp_roll_call_chat_slug TEXT;
COMMENT ON COLUMN club_sections.rsvp_roll_call IS 'The #rsvps board offers the roll call message (Going / Not going / still to answer) for this section''s games (mig 543).';
COMMENT ON COLUMN club_sections.rsvp_roll_call_chat_slug IS 'chats.slug whose GroupMe integration takes a posted roll call (mig 543).';
UPDATE club_sections SET rsvp_roll_call = true, rsvp_roll_call_chat_slug = 'mens' WHERE code = 'M';

CREATE TABLE IF NOT EXISTS rsvp_roll_calls (
    id               BIGSERIAL PRIMARY KEY,
    fh_event_id      BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    channel          TEXT NOT NULL,            -- sms | groupme | copy
    sent_by_user_id  INTEGER REFERENCES users(id) ON DELETE SET NULL,
    going            INTEGER NOT NULL,
    not_going        INTEGER NOT NULL,
    no_response      INTEGER NOT NULL,
    body             TEXT NOT NULL,
    external_id      TEXT,                     -- GroupMe message id when posted
    sent_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS rsvp_roll_calls_event_idx ON rsvp_roll_calls (fh_event_id, sent_at DESC);

CREATE OR REPLACE FUNCTION pg_temp.set_tpl(p_tier text, p_label text, p_body text, p_sort int, p_client boolean)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, updated_at = now()
   WHERE kind = 'rsvp_roll_call' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('RSVP', p_label, 'rsvp_roll_call', p_tier, NULL, p_body, p_sort, true, p_client, false);
  END IF;
END $$;
-- The message itself (server side).
SELECT pg_temp.set_tpl('body', 'Roll call message ({event} {n_going} {going} {n_not} {not_going} {n_none} {no_response} {deadline} {sender})',
E'📣 Roll call — {event}\n\n✅ Going ({n_going}): {going}\n❌ Not going ({n_not}): {not_going}\n❓ Still haven''t answered ({n_none}): {no_response}[[\n\n{deadline}]]\n\nGoing or Not Going takes one tap at https://footballhome.org — {sender}', 10, false);
SELECT pg_temp.set_tpl('nobody',   'An empty list reads as',            'nobody', 11, false);
SELECT pg_temp.set_tpl('name_sep', 'Between names',                     ', ', 12, false);
-- The board (client side).
SELECT pg_temp.set_tpl('intro',        'Line over the roll call buttons',   'Or put the whole roll call in front of the squad — who''s going, who''s not, and who still hasn''t answered:', 20, true);
SELECT pg_temp.set_tpl('btn_sms',      'Button — group text',               '📣 ROLL CALL TEXT', 21, true);
SELECT pg_temp.set_tpl('btn_groupme',  'Button — post to GroupMe',          '📣 ROLL CALL → GROUPME', 22, true);
SELECT pg_temp.set_tpl('btn_copy',     'Button — copy',                     '📋 COPY ROLL CALL', 23, true);
SELECT pg_temp.set_tpl('done_sms',     'Result — text drafted ({n})',       'Roll call text drafted to {n} — everyone on the team, not just the stragglers.', 24, true);
SELECT pg_temp.set_tpl('done_groupme', 'Result — posted',                   'Roll call posted to GroupMe.', 25, true);
SELECT pg_temp.set_tpl('done_copy',    'Result — copied',                   'Roll call copied — paste it where you like.', 26, true);
SELECT pg_temp.set_tpl('preview',      'Preview label',                     'Preview', 27, true);
