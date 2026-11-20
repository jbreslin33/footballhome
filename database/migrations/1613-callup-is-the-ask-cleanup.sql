-- 1613 (2026-11-20) — Call-up = asking a Reserve (mig 1607), step 2: the
-- separate call-up / call-in machinery goes.
--
-- Owner 11/20 on the cleanup list: "1. ok. 2 ok 3 reomvoe it 4. yes keep"
--   1. 🎟 CALL IN on a 💤 card → gone on the event page (its 📇 Contact
--      preselects 🎟 Call up); Game Center's lineup button says 🎟 CALL UP.
--   2. "⭐ CALL-UP · X" / "🎟 INVITED · X" chip → "🎟 Called up · X".
--   3. 🙋 Request call-in (mig 1265) removed: functions dropped, the two
--      tables kept under a _retired name (10 old asks, none open).
--   4. ⬇ call-down cap + Not On Roster flag kept (⭐ CALL-DOWN chip too).

DROP FUNCTION IF EXISTS fh_event_callin(bigint, integer);
DROP FUNCTION IF EXISTS fh_event_callin_source(bigint, integer);

ALTER TABLE IF EXISTS fh_event_callin_requests RENAME TO fh_event_callin_requests_retired_1613;
ALTER TABLE IF EXISTS team_callin_sources RENAME TO team_callin_sources_retired_1613;

UPDATE message_templates SET is_active = false WHERE kind = 'callin';

UPDATE message_templates SET body = '🎟 Called up[[ · {from}]]'
 WHERE tier IN ('chip_callup_up', 'chip_invited') AND kind IN ('event_center', 'my_callup');

UPDATE message_templates SET body = '🎟 CALL UP'
 WHERE kind = 'contact_popup' AND tier = 'callin_button';
