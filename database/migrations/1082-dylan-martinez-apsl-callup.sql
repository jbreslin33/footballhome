-- 1082: Dylan Martinez (22311) called up from APSL Reserves to tonight's APSL
-- game vs Vidas United (fh_event 75692361, Thu 11/5 8:50 PM) (owner
-- 2026-11-05: "add dylan to call up").  The invite row is what puts the game
-- on his #my; his Yes from 10/19 (answered before Reserves went call-up-only)
-- counts again, so he shows Going.  No message is sent by this row.

INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT 75692361, 22311, 938, 22311, NULL
 WHERE NOT EXISTS (SELECT 1 FROM fh_event_invites
                    WHERE fh_event_id = 75692361 AND person_id = 22311 AND revoked_at IS NULL);
