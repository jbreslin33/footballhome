-- 088-player-event-reminders.sql (2026-07-04)
--
-- Coach-issued reminder log.  When a coach clicks "Remind" on a player
-- who has not RSVPed for an open event, we send SMS / email with a
-- magic-link to /my and record a row here.
--
-- Purposes:
--   1. Rate-limit reminders: 1 per (person, match) per 24h.  UI checks
--      MAX(sent_at) and disables the button until cooldown clears.
--   2. Coach visibility: "Last reminded 2h ago" badge.
--   3. Attribution: know which coach sent which reminder.
--   4. Response correlation: if a player RSVPs via a reminder magic-link,
--      the resulting player_rsvp_history row uses change_source_id=5
--      ('reminder') from migration 086 — linkable back to this row by
--      (event_id, player_id) ± time proximity.
--
-- Design notes:
--   • `channel` is TEXT with a CHECK, not a lookup table, to keep it
--     simple.  Values match the enum used in preferred_channel across
--     the codebase: 'sms' | 'email' | 'whatsapp'.
--   • `delivered_at` optional — populated by webhook callback from the
--     SMS / email provider if we get one.  Never blocks the row from
--     being written.
--   • `magic_token` is a random 32-char base32 that unlocks /my for
--     that specific (person, match) without login.  Single-use in the
--     sense that clicking it lands them authed, but the row itself is
--     kept for audit; tokens are not stored anywhere else.

BEGIN;

CREATE TABLE IF NOT EXISTS player_event_reminders (
  id            SERIAL       PRIMARY KEY,
  match_id      INTEGER      NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  person_id     INTEGER      NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  channel       TEXT         NOT NULL CHECK (channel IN ('sms', 'email', 'whatsapp')),
  magic_token   VARCHAR(64)  NOT NULL,
  sent_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  sent_by       INTEGER      REFERENCES users(id),
  delivered_at  TIMESTAMPTZ,
  error         TEXT,
  UNIQUE (magic_token)
);

CREATE INDEX IF NOT EXISTS idx_player_event_reminders_match_person
  ON player_event_reminders (match_id, person_id, sent_at DESC);

CREATE INDEX IF NOT EXISTS idx_player_event_reminders_person
  ON player_event_reminders (person_id, sent_at DESC);

COMMIT;
