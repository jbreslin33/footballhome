-- 425 — Security: drop the 2026-09-24 test confirmation so tonight's lock-up
-- runs for real (owner 2026-09-24: "delete the test entry so we start fresh
-- tonight").  The 10:52 AM test photo landed on tonight's real row
-- (facility_lockups id 1) and marked it confirmed, which would have silenced
-- the 45-minute prompt/call.  Deleting the row cascades to its photo/token
-- rows; LockupScheduler::syncToday recreates tonight's row from the calendar
-- on its next 60 s tick (last event ends_at + facilities.lockup_grace_minutes).
DELETE FROM facility_lockups
 WHERE id = 1 AND local_date = DATE '2026-09-24' AND confirmed_via = 'photo';
