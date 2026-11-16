-- 1401 (2026-11-16) — the Calendar's Agenda view is gone (owner: "what is
-- point of it?" → "yes"): it was Week's tiles stretched to four weeks, and
-- Week's ‹ › already steps ahead.  Its words go quiet.
UPDATE message_templates SET is_active = false, updated_at = now()
 WHERE kind = 'event_center' AND tier IN ('view_agenda', 'agenda_empty');
