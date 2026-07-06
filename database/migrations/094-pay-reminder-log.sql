-- 094-pay-reminder-log.sql
--
-- Log of PAY-reminder clicks fired from the Mens/Boys roster screens.
-- Records that an admin *initiated* an SMS or email reminder to the
-- player / parent (we cannot know whether the recipient actually read
-- it; only that we clicked the button on their card).
--
-- User directive 2026-07-06:
--   "we need to show if we emailed or texted from this screen.
--    maybe a quick list of last contact and method. for the two pay buttons"
--
-- Cardinality: one row per click.  Newest row per la_user_id is the
-- one surfaced on the roster card.  Old rows kept for history.

CREATE TABLE IF NOT EXISTS pay_reminder_log (
    id                serial PRIMARY KEY,
    la_user_id        bigint      NOT NULL,
    method            text        NOT NULL
                                  CHECK (method IN ('sms', 'email')),
    sent_at           timestamptz NOT NULL DEFAULT now(),
    sent_by_user_id   integer     REFERENCES users(id) ON DELETE SET NULL,
    club              text
                                  CHECK (club IS NULL OR club IN ('mens', 'boys')),
    tier              text,       -- optional: 'nudge' | 'firm' | 'purgatory' | 'gentle' etc.
    amount            numeric(10,2),
    days_overdue      integer
);

CREATE INDEX IF NOT EXISTS idx_pay_reminder_log_la_user_sent_at
    ON pay_reminder_log (la_user_id, sent_at DESC);
