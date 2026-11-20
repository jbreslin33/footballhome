-- 🖼 Barn Night graphic = James's own upload (owner 11/19 "i uplaode it
-- berfore"): club_files 54 "barn" (barn.png, uploaded 11/17, private) is the
-- same flyer as the Instagram copy mig 1584 saved (club_files 58).  Point the
-- Nov 20 event at 54, make 54 public (an event graphic must be — a plain
-- <img> loads it), drop the duplicate 58.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM club_files WHERE id = 54 AND original_filename = 'barn.png') THEN
    RAISE NOTICE 'club_files 54 (barn.png) missing — skipped';
    RETURN;
  END IF;
  UPDATE club_files SET visibility = 'public', title = 'Friday Night @ The Barn — Fri Nov 20, 2026',
         note = 'On the Barn Night event card (fh_event_graphics, mig 1586).', updated_at = now()
   WHERE id = 54;
  INSERT INTO fh_event_graphics (fh_event_id, club_file_id, source_url)
  SELECT 75824080, 54, NULL WHERE EXISTS (SELECT 1 FROM fh_events WHERE id = 75824080)
  ON CONFLICT DO NOTHING;
  DELETE FROM club_files WHERE id = 58 AND original_filename = 'barn-night-2026-11-20.jpg';   -- cascades its graphic row
END $$;
