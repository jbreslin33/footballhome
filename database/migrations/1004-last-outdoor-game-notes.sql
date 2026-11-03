-- 1004 (2026-11-03) — Last outdoor game notes: U12 Sunday too, and every
-- one says practice goes on.  Owner: "u12 has 2 games left so we can do it
-- for u12 sundday game only that its last game for outdoor fall etc. we
-- want in all of them to let parents know practice continues regardless of
-- games being scheduled in between game seasons."
-- (U12 has Wed 11/4 and Sat 11/7 too; Sun 11/8 vs Parkwood is the last.)
INSERT INTO event_reminder_notes (fh_event_id, body)
SELECT id, 'This is our LAST outdoor game of the fall season! Indoor season teams will be formed next — no extra cost and no extra signup. Practice continues as usual, even in between game seasons.'
  FROM fh_events
 WHERE id IN (69236957,   -- U8  Sat Nov 7 at West Philly
              75676613,   -- U10 Sun Nov 8 vs Torresdale
              75676713)   -- U12 Sun Nov 8 vs Parkwood
ON CONFLICT (fh_event_id) DO UPDATE SET body = EXCLUDED.body, updated_at = now();
