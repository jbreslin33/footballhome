-- 364 — Welcome message: copy out of C++ and into the DB, built from the
-- player's real schedule.
--
-- Owner 2026-09-17: "we need the welcome email/text to be this format for
-- men, boys, girls, women … check db if no more events that week then let
-- them know … don't want parents wondering if they get welcome message
-- today and they are intramural they won't see any events so explain they
-- will show up sunday 8pm and give whoever it is basic schedule … lets
-- never hard code!"
--
-- Before this the whole welcome (email + SMS) was string literals in
-- WelcomeController.cpp, promised "practices, games and pickups" to
-- everyone, and never looked at the schedule.  Now WelcomeMessage (model)
-- assembles it from the rows below.
--
-- Skeletons — one per voice (tier 'adult' talks to the player, 'parent'
-- talks to a guardian about {child}):
--   kind 'welcome'      email subject + body
--   kind 'welcome_sms'  text body (the "Link not tappable?" hint is still
--                       appended by MagicLinkService, as for every SMS)
--
-- Blocks — picked by what the DB says about the player, then dropped into
-- the skeleton's {events_block} / {schedule_block} / {docs_block}:
--   welcome_events       released events still to come      → {events}
--   welcome_no_events    on a team, nothing left in the released window
--   welcome_no_team      not on any team yet
--   welcome_schedule     a weekly pattern could be derived  → {schedule}
--   welcome_no_schedule  on a team but no repeating pattern in gcal yet
--   welcome_docs         youth travel docs ask (parent only) → {docs_link}
--
-- Tokens: {first} recipient, {child} player, {link} magic link, {sender}
-- sending admin, {release_day} / {release_time} the moment next week's
-- schedule opens for the player's section — derived from
-- schedule_release_policies + early releases (migration 334), so the copy
-- follows the policy instead of saying "Sunday 8 PM" on its own.
-- A block with no template row (or an inactive one) renders as nothing.

-- ── Player-facing names for event kinds ─────────────────────────────────
-- One place for "what do we call a 'match' to a parent".  weekly_pattern
-- says how the kind takes part in the derived "usual week":
--   'time'  same weekday AND time repeating   → "Practice — Mon, Wed 4:30 PM"
--   'day'   same weekday, kickoff times vary  → "Game — Sun"
--   'none'  never part of the usual week
CREATE TABLE IF NOT EXISTS fh_event_kind_labels (
  kind           text PRIMARY KEY,
  player_label   text NOT NULL,
  weekly_pattern text NOT NULL DEFAULT 'none' CHECK (weekly_pattern IN ('time', 'day', 'none'))
);
COMMENT ON TABLE fh_event_kind_labels IS
  'Player/parent-facing label per fh_events.kind, and whether the kind feeds the derived "usual week" in the welcome message (migration 364). Never the gcal title.';

INSERT INTO fh_event_kind_labels (kind, player_label, weekly_pattern) VALUES
  ('practice',   'Practice',    'time'),
  ('pickup',     'Pickup',      'time'),
  ('intrasquad', 'Intra Squad', 'time'),
  ('match',      'Game',        'day'),
  ('meeting',    'Meeting',     'none'),
  ('camp',       'Camp',        'none'),
  ('barn night', 'Barn Night',  'none'),
  ('other',      'Event',       'none')
ON CONFLICT (kind) DO NOTHING;

-- ── Copy ────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.add_welcome_tpl(p_kind text, p_tier text, p_label text,
                                                   p_subject text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
  SELECT 'System', p_label, p_kind, p_tier, p_subject, p_body, p_sort
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

-- Email skeletons.
SELECT pg_temp.add_welcome_tpl('welcome', 'adult', 'Welcome email — player',
  'Welcome to Lighthouse 1893 SC!',
  E'Hi {first},\n\nWelcome to Lighthouse 1893 — we''re glad you''re playing with us.\n\nfootballhome.org is where each week''s schedule is posted, and where you set your availability so the coaches know who''s coming. Tap the link below on your phone — no password needed — and you''ll land on your schedule:\n{link}\n\n{events_block}\n\n{schedule_block}\n\nOn the page you can:\n  • RSVP YES / NO for each event\n  • Set default availability by day so the page fills itself in\n  • Add it to your home screen — it works like an app\n\nThe link signs you in automatically and expires in 72 hours. If it has expired by the time you open it, just reply and I''ll send a fresh one.\n\n{docs_block}\n\nReply anytime with questions.\n\n— {sender}\nSoccer Director\nLighthouse 1893 SC',
  20);

SELECT pg_temp.add_welcome_tpl('welcome', 'parent', 'Welcome email — parent',
  'Welcome to Lighthouse 1893 SC!',
  E'Hi {first},\n\nWelcome to Lighthouse 1893 — we''re glad {child} is playing with us.\n\nfootballhome.org is where each week''s schedule is posted, and where you set {child}''s availability so the coaches know who''s coming. Tap the link below on your phone — no password needed — and you''ll land on {child}''s schedule:\n{link}\n\n{events_block}\n\n{schedule_block}\n\nOn the page you can:\n  • RSVP YES / NO for each event\n  • Set default availability by day so the page fills itself in\n  • Add it to your home screen — it works like an app\n\nThe link signs you in automatically and expires in 72 hours. If it has expired by the time you open it, just reply and I''ll send a fresh one.\n\n{docs_block}\n\nReply anytime with questions.\n\n— {sender}\nSoccer Director\nLighthouse 1893 SC',
  21);

-- SMS skeletons.
SELECT pg_temp.add_welcome_tpl('welcome_sms', 'adult', 'Welcome text — player', NULL,
  E'Hi {first} — welcome to Lighthouse 1893! Your schedule is at footballhome.org. Tap to see it and set your availability (no password needed): {link}\n\n{events_block}\n\n{schedule_block}\n\n{docs_block}',
  22);

SELECT pg_temp.add_welcome_tpl('welcome_sms', 'parent', 'Welcome text — parent', NULL,
  E'Hi {first} — welcome to Lighthouse 1893! {child}''s schedule is at footballhome.org. Tap to see it and set {child}''s availability (no password needed): {link}\n\n{events_block}\n\n{schedule_block}\n\n{docs_block}',
  23);

-- Blocks: released events still to come.
SELECT pg_temp.add_welcome_tpl('welcome_events', 'adult', 'Welcome block — events coming up (player)', NULL,
  E'Coming up for you:\n{events}', 30);
SELECT pg_temp.add_welcome_tpl('welcome_events', 'parent', 'Welcome block — events coming up (parent)', NULL,
  E'Coming up for {child}:\n{events}', 31);

-- Blocks: on a team, but nothing left in the released window.
SELECT pg_temp.add_welcome_tpl('welcome_no_events', 'adult', 'Welcome block — nothing left this week (player)', NULL,
  E'There''s nothing left on your schedule this week, so the page will look empty for now — that''s expected. Next week''s schedule posts {release_day} at {release_time}.', 32);
SELECT pg_temp.add_welcome_tpl('welcome_no_events', 'parent', 'Welcome block — nothing left this week (parent)', NULL,
  E'There''s nothing left on {child}''s schedule this week, so the page will look empty for now — that''s expected. Next week''s schedule posts {release_day} at {release_time}.', 33);

-- Blocks: not on a team yet.
SELECT pg_temp.add_welcome_tpl('welcome_no_team', 'adult', 'Welcome block — not on a team yet (player)', NULL,
  E'You''re not placed on a team yet, so the page will look empty for now — your events appear as soon as you''re on a team. Each week''s schedule posts {release_day} at {release_time}.', 34);
SELECT pg_temp.add_welcome_tpl('welcome_no_team', 'parent', 'Welcome block — not on a team yet (parent)', NULL,
  E'{child} isn''t placed on a team yet, so the page will look empty for now — events appear as soon as {child} is on a team. Each week''s schedule posts {release_day} at {release_time}.', 35);

-- Blocks: the usual week.
SELECT pg_temp.add_welcome_tpl('welcome_schedule', 'adult', 'Welcome block — usual week (player)', NULL,
  E'Your usual week:\n{schedule}', 36);
SELECT pg_temp.add_welcome_tpl('welcome_schedule', 'parent', 'Welcome block — usual week (parent)', NULL,
  E'{child}''s usual week:\n{schedule}', 37);

-- Blocks: on a team, but gcal has no repeating pattern for it yet.
SELECT pg_temp.add_welcome_tpl('welcome_no_schedule', 'adult', 'Welcome block — no usual week yet (player)', NULL,
  E'Your team''s regular training days are still being set — they''ll show on the page as soon as they''re confirmed.', 38);
SELECT pg_temp.add_welcome_tpl('welcome_no_schedule', 'parent', 'Welcome block — no usual week yet (parent)', NULL,
  E'{child}''s regular training days are still being set — they''ll show on the page as soon as they''re confirmed.', 39);

-- Block: youth travel documents (parent voice only).
SELECT pg_temp.add_welcome_tpl('welcome_docs', 'parent', 'Welcome block — travel documents', NULL,
  E'One more thing: since {child} is on a travel team, the Philadelphia Parks & Rec league needs a copy of {child}''s birth certificate and a headshot. Please upload both here when you get a chance — travel spots are confirmed as forms come in:\n{docs_link}', 40);
