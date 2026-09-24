-- 427 — Security: the call ladder after the night's last event (owner
-- 2026-09-24: "call at 30 minutes after, then every 5 for next 30, then
-- every 1/2 hour for 2 hours, then every hour for next 15 hours").
--
-- Grace 45 → 30 min, and the mig 426 steps become three:
--   step 1  every  5 min × 6   calls at +30, +35, +40, +45, +50, +55
--   step 2  every 30 min × 4   calls at +60, +90, +120, +150
--   step 3  every 60 min × 15  calls at +180 … +1020 (17 h after the end)
-- 25 calls in all; the gap AFTER call #k is the repeat_minutes of the
-- step #k belongs to (fh_lockup_wait_minutes, mig 426).
UPDATE facilities SET lockup_grace_minutes = 30, updated_at = now()
 WHERE name IN ('Lighthouse Sport Complex', 'Lighthouse Community Center');

INSERT INTO facility_lockup_alert_steps (facility_id, step_no, repeat_minutes, times)
SELECT f.id, s.step_no, s.repeat_minutes, s.times
  FROM facilities f, (VALUES (1, 5, 6), (2, 30, 4), (3, 60, 15)) AS s(step_no, repeat_minutes, times)
 WHERE f.name IN ('Lighthouse Sport Complex', 'Lighthouse Community Center')
ON CONFLICT (facility_id, step_no) DO UPDATE
   SET repeat_minutes = EXCLUDED.repeat_minutes, times = EXCLUDED.times;

DELETE FROM facility_lockup_alert_steps s USING facilities f
 WHERE f.id = s.facility_id AND s.step_no > 3
   AND f.name IN ('Lighthouse Sport Complex', 'Lighthouse Community Center');
