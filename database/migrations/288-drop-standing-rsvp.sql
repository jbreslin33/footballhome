-- Remove the standing/recurring RSVP preference feature (2026-08-16).
--
-- Why: the frontend UI to actually set a preference had gone dead
-- (buttons never wired up after a refactor), leaving only an invisible
-- background worker (gcal-rsvp-apply-standing) that kept auto-marking
-- people "going" on whatever they'd set weeks earlier, with no way for
-- them to see or change it. 13 of the 15 active rows were a single
-- bulk-seed from 2026-07-17, not individual opt-ins. The worker,
-- systemd timer, backend endpoints (/api/calendar/my-standing), and
-- frontend dead code were removed in the same change as this
-- migration; see EligibilityController.cpp's Game-Day Analytics
-- projection queries, which used fh_recurring_rsvps as a fallback and
-- now rely on explicit fh_event_rsvps only.
--
-- fh_event_rsvps rows with created_via='standing' for this week
-- forward (2026-08-18+) were deleted separately in prod directly —
-- reverting those people to "no response" — but rows for events that
-- already happened were left alone (historical record, not reversed).

DROP INDEX IF EXISTS fh_events_applier_scan_idx;
ALTER TABLE fh_events DROP COLUMN IF EXISTS standing_applied_at;
DROP TABLE IF EXISTS fh_recurring_rsvps;
