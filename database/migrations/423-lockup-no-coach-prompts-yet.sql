-- 423 — Lock-up: don't prompt the last event's coaches yet (owner 2026-09-24:
-- "don't send to coaches yet").  Only the people listed in
-- facility_lockup_people (James) are asked to confirm.  Flip back by
-- migration when the coaches should be brought in.
UPDATE facilities SET lockup_prompt_last_event_coaches = false, updated_at = now()
 WHERE name = 'Lighthouse Sport Complex';
