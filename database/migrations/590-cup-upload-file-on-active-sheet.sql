-- 590 (2026-10-15) — re-point the cup's official upload file at the live
-- sheet.  Mig 587 linked the filled USASA bulk-upload .xls (club_files 5) to
-- sheet 2, which was deleted since; today's sheet (id 4, USASA Amateur Cup,
-- form_version cup_player_pool per mig 589) gets the link so the
-- "⬇ Cup upload (.xls)" button is back on #cup-rosters.

UPDATE cup_rosters r
   SET bulk_upload_file_id = cf.id
  FROM club_files cf
 WHERE r.id = 4
   AND r.bulk_upload_file_id IS NULL
   AND cf.title = 'USASA Amateur Cup - Bulk Upload (filled)';
