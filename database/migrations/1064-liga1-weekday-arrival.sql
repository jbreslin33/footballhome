-- 1064: Liga 1 weekday games arrive 30 minutes before kickoff (owner
-- 2026-11-04: "switch arrival for liga to 730pm since its a weekday game",
-- "its only liga 1 lol. apsl we need to keep the standard even during
-- weekday").
--   • league_matchday_offsets (mig 395) gains weekday_arrival/warmup
--     minutes: used for a Mon–Fri kickoff (America/New_York) when set,
--     else the standard ones.  scripts/gcal-classify.js reads them; the
--     lookup fingerprint includes them, so every event re-walks once.
--   • CASA (organization 2 — Liga 1; Liga 2 / CASA Traditional share it,
--     we field only Liga 1): weekday arrival 30, warm-up 30 (warm up on
--     arrival).  APSL (1) and the rest: no weekday override.
--   • Tonight's game (fh_event 75692413, at Phoenix SCM, 8:00 PM, no
--     Arrival:/Warmup: tag) set now — arrival and warm-up 7:30 PM — so it
--     doesn't wait for the next classifier tick.

BEGIN;

ALTER TABLE league_matchday_offsets
  ADD COLUMN IF NOT EXISTS weekday_arrival_minutes_before integer CHECK (weekday_arrival_minutes_before >= 0),
  ADD COLUMN IF NOT EXISTS weekday_warmup_minutes_before  integer CHECK (weekday_warmup_minutes_before >= 0);
ALTER TABLE league_matchday_offsets DROP CONSTRAINT IF EXISTS league_matchday_offsets_weekday_check;
ALTER TABLE league_matchday_offsets ADD CONSTRAINT league_matchday_offsets_weekday_check
  CHECK (weekday_arrival_minutes_before IS NULL OR weekday_warmup_minutes_before IS NULL
         OR weekday_arrival_minutes_before >= weekday_warmup_minutes_before);
COMMENT ON COLUMN league_matchday_offsets.weekday_arrival_minutes_before IS
  'mig 1064: arrival minutes before a Mon–Fri kickoff; NULL = the standard arrival_minutes_before.';
COMMENT ON COLUMN league_matchday_offsets.weekday_warmup_minutes_before IS
  'mig 1064: warm-up minutes before a Mon–Fri kickoff; NULL = the standard warmup_minutes_before.';

UPDATE league_matchday_offsets SET weekday_arrival_minutes_before = 30, weekday_warmup_minutes_before = 30
 WHERE organization_id = 2;

UPDATE fh_events SET arrival_at = kickoff_at - interval '30 minutes', warmup_at = kickoff_at - interval '30 minutes', updated_at = now()
 WHERE id = 75692413 AND kickoff_at IS NOT NULL;

COMMIT;
