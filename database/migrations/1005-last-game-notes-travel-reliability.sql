-- 1005 (2026-11-03) — Last outdoor game notes (mig 1003/1004) add the
-- indoor travel rule.  Owner: "lets parents know for indoor travel we will
-- be putting players on travel rosters that have been reliable for games."
UPDATE event_reminder_notes
   SET body = 'This is our LAST outdoor game of the fall season! Indoor season teams will be formed next — no extra cost and no extra signup. For indoor travel, we will be putting players on the travel rosters who have been reliable for games. Practice continues as usual, even in between game seasons.',
       updated_at = now()
 WHERE fh_event_id IN (69236957,   -- U8  Sat Nov 7 at West Philly
                       75676613,   -- U10 Sun Nov 8 vs Torresdale
                       75676713);  -- U12 Sun Nov 8 vs Parkwood
