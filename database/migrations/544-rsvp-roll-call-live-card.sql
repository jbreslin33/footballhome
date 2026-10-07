-- 544 (2026-10-07) — the live roll call card: footballhome.org/rc/<slug>.
-- Owner: "it should be in picture form … sent individually but it will be
-- a picture of the game that week. if 2 games then a photo with both
-- games" / "it def needs to be a link to a dynamic graphic so a parent
-- who notices they are the 'not answered' lol can quickly answer and then
-- everyone sees the new one with them on it" / "can they answer on the
-- linked card? with a going not going button?".
--
--   rsvp_roll_call_links   one slug per (section, set of teams); the card
--                          always shows that set's released games, so the
--                          same link stays right all season
--   magic_link_tokens.landing   where a sign-in link lands instead of #my:
--                          'rc/<slug>' puts the per-player RSVP reminder
--                          on the card, signed in, with Going / Not Going
--                          buttons for themself and their children
--   club_sections          roll call on for every section; what the card
--                          may name: no-response names (Men only) and the
--                          name style (full "First L." for adults, first
--                          names for the youth)
ALTER TABLE magic_link_tokens ADD COLUMN IF NOT EXISTS landing TEXT;
COMMENT ON COLUMN magic_link_tokens.landing IS 'Site path the verify endpoint lands on instead of #my (mig 544), e.g. rc/<slug>.';

CREATE TABLE IF NOT EXISTS rsvp_roll_call_links (
    id                  BIGSERIAL PRIMARY KEY,
    slug                TEXT NOT NULL UNIQUE,
    section_code        TEXT NOT NULL,              -- club_sections.code (no unique key there)
    team_ids            BIGINT[] NOT NULL,          -- sorted, distinct
    created_by_user_id  INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    opens               INTEGER NOT NULL DEFAULT 0,
    last_opened_at      TIMESTAMPTZ,
    UNIQUE (section_code, team_ids)
);
COMMENT ON TABLE rsvp_roll_call_links IS 'Public roll call card links (mig 544): /rc/<slug> shows the released games of these teams, who is Going / Not Going / unanswered, live.';

ALTER TABLE club_sections
    ADD COLUMN IF NOT EXISTS roll_call_no_response_names BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS roll_call_name_style TEXT NOT NULL DEFAULT 'first' CHECK (roll_call_name_style IN ('full', 'first'));
COMMENT ON COLUMN club_sections.roll_call_no_response_names IS 'The roll call card names who has not answered (true) or shows only how many (false) — mig 544.';
COMMENT ON COLUMN club_sections.roll_call_name_style IS 'How the roll call card names people: full = "First L.", first = first name only (mig 544).';
UPDATE club_sections SET rsvp_roll_call = true;
UPDATE club_sections SET roll_call_no_response_names = true,  roll_call_name_style = 'full'  WHERE code = 'M';
UPDATE club_sections SET roll_call_no_response_names = false, roll_call_name_style = 'full'  WHERE code = 'W';
UPDATE club_sections SET roll_call_no_response_names = false, roll_call_name_style = 'first' WHERE code IN ('B', 'G');

-- ── Wording ───────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.set_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int, p_client boolean, p_public boolean)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, is_public = p_public, updated_at = now()
   WHERE kind = p_kind AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('RSVP', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, p_client, p_public);
  END IF;
END $$;
-- The card page (public rows, read by rollcall.html).
SELECT pg_temp.set_tpl('rsvp_roll_call', 'page_title',   'Card — title',                         'Roll call', 40, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'col_going',    'Card — column',                        'Going', 41, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'col_not',      'Card — column',                        'Not going', 42, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'col_none',     'Card — column',                        'Still to answer', 43, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'none_count',   'Card — unanswered as a count ({n})',   '{n} still to answer', 44, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'none_zero',    'Card — everyone answered',             'Everyone has answered 👏', 45, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'empty_list',   'Card — an empty column',               '—', 46, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'live_note',    'Card — under the title',               'Live — answer below and you move across.', 47, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'no_games',     'Card — no released game',              'No game is open for RSVPs this week yet.', 48, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'answer_title', 'Card — over the buttons ({first})',    'Your answer, {first}:', 49, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'btn_going',    'Card — button',                        '✅ Going', 50, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'btn_not',      'Card — button',                        '❌ Not going', 51, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'saved',        'Card — after a tap',                   'Saved — you''re on the card.', 52, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'signin_hint',  'Card — opened without a sign-in',      'To answer, open the link from your own reminder, or sign in to Football Home.', 53, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'signin_btn',   'Card — button to the app',             'Open Football Home', 54, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'my_btn',       'Card — button to #my when signed in',  'Open my page', 55, false, true);
SELECT pg_temp.set_tpl('rsvp_roll_call', 'updated',      'Card — refresh stamp ({time})',        'Updated {time}', 56, false, true);
-- The messages: the per-player link now opens the card; the group text
-- and the roll call text carry the shared card link.
UPDATE message_templates SET body = replace(body, 'Going or Not Going, one tap: {link}', 'Going or Not Going, one tap — and see who''s in: {link}'), updated_at = now()
 WHERE kind = 'rsvp_reminder' AND tier IN ('adult', 'parent') AND body LIKE '%Going or Not Going, one tap: {link}%';
UPDATE message_templates SET body = replace(body, 'Going or Not Going, one tap for everyone: {link}', 'Going or Not Going, one tap for everyone — and see who''s in: {link}'), updated_at = now()
 WHERE kind = 'rsvp_reminder' AND tier = 'multi' AND body LIKE '%one tap for everyone: {link}%';
UPDATE message_templates SET body = body || E'[[\n\nWho''s in so far: {roll_call}]]', updated_at = now()
 WHERE kind = 'rsvp_reminder' AND tier IN ('group_adult', 'group_parent', 'group_week_adult', 'group_week_parent')
   AND body NOT LIKE '%{roll_call}%';
UPDATE message_templates SET body = replace(body, 'Going or Not Going takes one tap at https://footballhome.org — {sender}', 'See it live and answer in one tap: {link} — {sender}'), updated_at = now()
 WHERE kind = 'rsvp_roll_call' AND tier = 'body' AND body LIKE '%takes one tap at https://footballhome.org%';
