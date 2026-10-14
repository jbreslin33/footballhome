-- 587 (2026-10-14) — a cup roster sheet can carry the cup's official
-- bulk-upload file (the filled USASA .xls, stored in club_files), so it
-- lives on #cup-rosters next to the Player Pool sheet instead of only on
-- #files.  Owner: "should be here right https://footballhome.org/#cup-rosters
-- and it should have pills if needed if we are in multiple cups".
-- The pills themselves are pure frontend (cups already ride the board
-- payload); this migration is the file link + pointing sheet 2 at the
-- filled upload built earlier today (club_files id 5).

ALTER TABLE cup_rosters
  ADD COLUMN IF NOT EXISTS bulk_upload_file_id int REFERENCES club_files(id) ON DELETE SET NULL;
COMMENT ON COLUMN cup_rosters.bulk_upload_file_id IS
  'The cup''s official upload file (e.g. the filled USASA bulk-upload .xls) in club_files; shown as a download button on #cup-rosters (mig 587).';

UPDATE cup_rosters r
   SET bulk_upload_file_id = cf.id
  FROM club_files cf
 WHERE r.id = 2
   AND r.bulk_upload_file_id IS NULL
   AND cf.title = 'USASA Amateur Cup - Bulk Upload (filled)';
