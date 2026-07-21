-- 242 — DB-backed copy for the auto-sent event availability reminder
-- (EventReminderController's SMS/email "nudge non-responders" flow).
-- Distinct from the 098 "Men's Club" copy-paste snippet (that one feeds
-- the Messages screen only; this one is read directly by the backend
-- when a coach taps "Remind").
--
-- Placeholders substituted by the backend before sending:
--   {first}         -> player's first name
--   {event_phrase}  -> "today's practice" / "tomorrow's practice" /
--                       "practice on Wed, Jul 22" (computed from the
--                       event's kind + date relative to send time)
--
-- Body uses dollar-quoting with real embedded newlines (NOT the
-- literal two-character "\n" escape) so the stored text renders with
-- actual line breaks in SMS/email bodies.
BEGIN;

INSERT INTO message_templates (category, label, kind, tier, subject, body, html_body, sort_order)
VALUES (
    'System',
    'Auto-sent event availability reminder (SMS/Email)',
    'auto_reminder',
    'transactional',
    NULL,
    $body$Hi {first} — this is a gentle reminder that setting availability for {event_phrase} is a team rule.

If you are not sure, set Not Going. Please set your availability here https://footballhome.org/#my whether you are going or not, and change it if going. Team Rules: https://footballhome.org/#player-team-rules

Thanks — Lighthouse 1893$body$,
    NULL,
    0
)
ON CONFLICT DO NOTHING;

COMMIT;

