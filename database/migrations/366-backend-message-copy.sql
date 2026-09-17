-- 366 — Every message the BACKEND writes, moved into the DB.
--
-- Owner 2026-09-17: "we need all messages in db no hard code not even for
-- nudges".  An inventory that day found 46 places where outbound copy was
-- a string literal.  This migration covers the ones composed in C++:
--
--   magic_link / magic_link_sms      🔗 LINK buttons (roster boards, #lineups,
--                                    #person) — tier 'event' | 'invite'
--   event_invite / event_invite_sms  🎟 call-up invites on #my — 'adult' | 'parent'
--   push                             web-push payloads — 'rsvp_remind' | 'test' | 'chat'
--   password_reset                   the one email the server sends itself
--   sms_link_hint                    sentence appended to every SMS with a link
--   fallback                         the word used when a token has no value
--                                    (tier = token name)
--
-- All are rendered by the MessageCopy model.  Template syntax:
--   {token}        replaced with its value; if the value is empty and a
--                  kind='fallback' row exists for that token, the fallback
--                  word is used ("Hi there,").
--   [[ … ]]        optional section — kept only when every {token} inside it
--                  has a value, so "[[ (up from {from_team})]]" disappears
--                  cleanly for a player with no from-team.  Fallback words
--                  are never used inside one.
--   {form:<code>}  club_forms link (migration 365).
-- Frontend-composed messages (dues, CONTACT, #leads chips …) follow in
-- later migrations.

-- ── Where club mail is sent from ────────────────────────────────────────
-- The Gmail compose links open as this mailbox.  It was pasted as a
-- literal into four controllers and five screens.
ALTER TABLE clubs ADD COLUMN IF NOT EXISTS outreach_email text;
COMMENT ON COLUMN clubs.outreach_email IS
  'Mailbox club messages are composed from (Gmail authuser on every compose link). Migration 366.';
UPDATE clubs SET outreach_email = 'soccer@lighthouse1893.org'
 WHERE id = 134 AND outreach_email IS NULL;

-- ── Chat push label ─────────────────────────────────────────────────────
-- Title suffix on a chat push ("Ali — Men's Chat").  Was a C++ table.
ALTER TABLE chats ADD COLUMN IF NOT EXISTS push_label text;
COMMENT ON COLUMN chats.push_label IS
  'Short name shown in push notification titles for this chat. Migration 366.';
UPDATE chats SET push_label = v.label
  FROM (VALUES ('mens', 'Men''s Chat'), ('womens', 'Women''s Chat'), ('youth', 'Youth Chat')) AS v(slug, label)
 WHERE chats.slug = v.slug AND chats.push_label IS NULL;

-- ── Copy ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.add_tpl(p_kind text, p_tier text, p_label text,
                                           p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- Fallback words.
SELECT pg_temp.add_tpl('fallback', 'first',  'Fallback — recipient has no first name', NULL, 'there', 100);
SELECT pg_temp.add_tpl('fallback', 'child',  'Fallback — player has no first name',    NULL, 'your player', 101);
SELECT pg_temp.add_tpl('fallback', 'sender', 'Fallback — sender has no name',          NULL, 'Coach', 102);
SELECT pg_temp.add_tpl('fallback', 'team',   'Fallback — event has no team label',     NULL, 'the team', 103);
SELECT pg_temp.add_tpl('fallback', 'event',  'Fallback — event has no label',          NULL, 'an upcoming event', 104);
SELECT pg_temp.add_tpl('fallback', 'chat',   'Fallback — chat has no push label',      NULL, 'Club Chat', 105);

-- Appended to every SMS that carries a link: phones show links from an
-- unknown sender as dead text until the recipient replies.
SELECT pg_temp.add_tpl('sms_link_hint', 'all', 'SMS — link not tappable hint', NULL,
  'Link not tappable? Reply YES, then reopen this text.', 110);

-- 🔗 LINK — for a specific event.
SELECT pg_temp.add_tpl('magic_link', 'event', 'Sign-in link email — RSVP for an event',
  'Football Home — RSVP for {event}',
  E'Hi {first},\n\nTap to RSVP for {event}[[ ({when_where})]]:\n{link}\n\nThis link signs you in automatically and expires in 72 hours.\n\n— Lighthouse Soccer',
  120);
SELECT pg_temp.add_tpl('magic_link_sms', 'event', 'Sign-in link text — RSVP for an event', NULL,
  'Lighthouse RSVP[[ {when}]] — {event}: {link}', 121);

-- 🔗 LINK — general invite to the schedule page.
SELECT pg_temp.add_tpl('magic_link', 'invite', 'Sign-in link email — invite to the schedule page',
  'Football Home — you''re invited',
  E'Hi {first},\n\nLighthouse 1893 posts each week''s schedule at footballhome.org so we have a clearer picture of who''s coming.\n\nTap the link below on your phone — no password needed — and you''ll land on your weekly schedule:\n{link}\n\nOn the page you can:\n  • RSVP YES / NO for each event\n  • Set default availability by day so the page fills itself in\n  • Add it to your home screen — it works like an app\n\nThis link signs you in automatically and expires in 72 hours. If you''d rather set a password for future visits, just tap "Forgot / set password" on the sign-in screen.\n\n— Lighthouse Soccer',
  122);
SELECT pg_temp.add_tpl('magic_link_sms', 'invite', 'Sign-in link text — invite to the schedule page', NULL,
  'Hey {first} — Lighthouse 1893 posts each week''s schedule at footballhome.org. Tap to see yours and let us know if you''re in (no password needed): {link}',
  123);

-- 🎟 Call-up / guest invites.  {kind} is the player-facing event name
-- from fh_event_kind_labels; never the gcal title.
SELECT pg_temp.add_tpl('event_invite', 'adult', 'Game invite email — player',
  'Invite: {team} — {kind}[[ vs {opponent}]][[ on {when}]]',
  E'Hi {first},\n\nWe''d like to invite you to play with {team}[[ (up from {from_team})]] — {kind}[[ vs {opponent}]][[ on {when}]].\n\nTap the link below on your phone to sign in — no password needed — and mark whether you''re available:\n{link}\n\nThe link works for 72 hours. Reply anytime with questions.',
  130);
SELECT pg_temp.add_tpl('event_invite', 'parent', 'Game invite email — parent',
  'Invite: {team} — {kind}[[ vs {opponent}]][[ on {when}]]',
  E'Hi {first},\n\nWe''d like to invite {child} to play with {team}[[ (up from {from_team})]] — {kind}[[ vs {opponent}]][[ on {when}]].\n\nTap the link below on your phone to sign in — no password needed — and mark whether {child} is available:\n{link}\n\nThe link works for 72 hours. Reply anytime with questions.',
  131);
SELECT pg_temp.add_tpl('event_invite_sms', 'adult', 'Game invite text — player', NULL,
  'Hi {first} — you are invited to play with {team}: {kind}[[ vs {opponent}]][[ on {when}]]. Tap to sign in and mark availability (no password needed): {link}',
  132);
SELECT pg_temp.add_tpl('event_invite_sms', 'parent', 'Game invite text — parent', NULL,
  'Hi {first} — {child} is invited to play with {team}: {kind}[[ vs {opponent}]][[ on {when}]]. Tap to sign in and mark availability (no password needed): {link}',
  133);

-- Push notifications: subject = title, body = body.
SELECT pg_temp.add_tpl('push', 'rsvp_remind', 'Push — RSVP reminder',
  'RSVP needed', 'Don''t forget to RSVP for {event}!', 140);
SELECT pg_temp.add_tpl('push', 'test', 'Push — self test',
  'Test notification', 'Push notifications are working! 🎉', 141);
SELECT pg_temp.add_tpl('push', 'chat', 'Push — new chat message',
  '{chat_sender} — {chat}', '{message}', 142);
SELECT pg_temp.add_tpl('fallback', 'chat_sender', 'Fallback — chat author has no first name', NULL, 'Someone', 106);

-- Password reset (sent by the server over SMTP).
SELECT pg_temp.add_tpl('password_reset', 'all', 'Password reset email',
  'Football Home — reset your password',
  E'Hi[[ {name}]],\n\nSomeone (hopefully you) requested a password reset for your Football Home account. Tap the link below to set a new password. This link expires in 60 minutes and can only be used once.\n\n{link}\n\nIf you didn''t request this, you can safely ignore the email — your existing password stays as-is.\n\n— Football Home',
  150);
