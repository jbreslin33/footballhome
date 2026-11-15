-- 1374 (2026-11-14) — put back one attendance mark a test cleared.
--
-- While checking Event Center's "View as" read-only guard, a test tap on
-- the first P/A/L/E button of the 11/11 youth practice (fh_event 24534270)
-- ran as the real admin account (view-as had dropped) and DELETEd an
-- existing mark.  This restores that row exactly as the 2026-11-14 03:02
-- backup holds it (id 1118: present, marked by user 4 on 11/11).

INSERT INTO fh_event_attendance (id, fh_event_id, person_id, status, marked_by_user_id, marked_at)
SELECT 1118, 24534270, 22762, 'present', 4, '2026-11-11 22:35:58.18211+00'
 WHERE NOT EXISTS (SELECT 1 FROM fh_event_attendance WHERE fh_event_id = 24534270 AND person_id = 22762)
   AND NOT EXISTS (SELECT 1 FROM fh_event_attendance WHERE id = 1118);
