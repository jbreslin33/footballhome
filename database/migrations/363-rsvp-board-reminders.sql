-- 363 — RSVP board (#rsvps): reminder log + reminder copy.
--
-- Owner 2026-09-17: "a new top level page … pills for men, boys etc …
-- send text or email reminder for rsvp … the message crafted by db query
-- to see what events they didn't rsvp to and list them and give magic
-- link … this would eventually replace the reminder stuff on my page."
--
-- #my's per-event Remind buttons only remember "reminded ✓" until the
-- page reloads.  This log is what lets a card say "last reminded 💬
-- Sep 16 by Ali", and later lets us ask whether a reminder was answered.
--
-- person_id is the PLAYER on the card; recipient_person_id is who the
-- message (and its magic link) went to — the parent for youth, the
-- player themselves for adults.  Same split as person_welcomes.
CREATE TABLE IF NOT EXISTS rsvp_reminders (
  id                  bigserial PRIMARY KEY,
  person_id           integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  recipient_person_id integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  channel             text    NOT NULL CHECK (channel IN ('sms', 'email')),
  contact             text    NOT NULL,
  sent_by_user_id     integer REFERENCES users(id) ON DELETE SET NULL,
  sent_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_rsvp_reminders_person ON rsvp_reminders (person_id, sent_at DESC);

-- The unanswered events a reminder listed.
CREATE TABLE IF NOT EXISTS rsvp_reminder_events (
  rsvp_reminder_id bigint NOT NULL REFERENCES rsvp_reminders(id) ON DELETE CASCADE,
  fh_event_id      bigint NOT NULL REFERENCES fh_events(id)      ON DELETE CASCADE,
  PRIMARY KEY (rsvp_reminder_id, fh_event_id)
);

-- Copy.  tier picks the voice: 'adult' talks to the player, 'parent'
-- talks to a guardian about {child}.  Tokens: {first} recipient's first
-- name, {child}, {events} one line per unanswered event, {link} the
-- recipient's magic link, {sender} the sending coach/admin.  The SMS
-- "Link not tappable?" hint is appended in code, not stored here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — player', 'rsvp_reminder', 'adult',
       'Lighthouse 1893 — please set your availability',
       E'Hi {first} — you haven''t set your availability yet for:\n{events}\n\nTap to answer, no password needed: {link}\n\nNot sure yet? Set Not Going — you can change it any time. Setting availability for every event is a team rule.\n\n— {sender}, Lighthouse 1893',
       10
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'adult');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', 'RSVP reminder — parent', 'rsvp_reminder', 'parent',
       'Lighthouse 1893 — please set {child}''s availability',
       E'Hi {first} — {child} doesn''t have availability set yet for:\n{events}\n\nTap to answer for {child}, no password needed: {link}\n\nNot sure yet? Set Not Going — you can change it any time. It lets the coaches plan the session.\n\n— {sender}, Lighthouse 1893',
       11
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'rsvp_reminder' AND tier = 'parent');
