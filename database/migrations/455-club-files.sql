-- 455 — Files (owner 2026-09-26: "can we have a file upload on
-- footballhome where i can upload a file for you to look at? but also
-- maybe to publish for others? like maybe a files button at top level
-- with various options?").
--
-- One row per uploaded file in club_files; the bytes in the DB are the
-- only copy (no cached file under the web root, so a private file is never
-- reachable by URL).  Who may see a file is its visibility, a lookup row
-- in file_visibilities:
--   private  the uploader and super admins — the "for Claude to look at" slot
--   admins   club / super admins
--   members  anyone signed in
--   public   anyone with the link (/api/files/dl/<id>/<name>)
--
-- Served by /api/files (backend/src/controllers/ClubFileController.cpp)
-- behind the #files page (frontend/js/screens/files.js).
--
-- To read a private upload from the host (no web URL exists for it):
--   sudo podman exec -i footballhome_db psql -U footballhome_user -d footballhome \
--     -Atc "SELECT encode(bytes,'base64') FROM club_files WHERE id = N" | base64 -d > out

CREATE TABLE IF NOT EXISTS file_visibilities (
  code        TEXT PRIMARY KEY,
  label       TEXT NOT NULL,
  description TEXT NOT NULL,
  sort_order  INT  NOT NULL DEFAULT 0
);
COMMENT ON TABLE file_visibilities IS 'Who may see a club_files row (mig 455). Add levels by migration only.';

INSERT INTO file_visibilities (code, label, description, sort_order) VALUES
  ('private', 'Private', 'Only you and super admins. Leave a file here for Claude to look at.', 1),
  ('admins',  'Admins',  'Club and super admins.', 2),
  ('members', 'Members', 'Anyone signed in to Football Home.', 3),
  ('public',  'Public',  'Anyone with the link, no sign-in needed.', 4)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS club_files (
  id                SERIAL PRIMARY KEY,
  title             TEXT NOT NULL,
  note              TEXT,
  original_filename TEXT NOT NULL,
  mime              TEXT NOT NULL,
  byte_size         INT  NOT NULL,
  bytes             BYTEA NOT NULL,
  visibility        TEXT NOT NULL DEFAULT 'private' REFERENCES file_visibilities(code),
  uploaded_by       INT REFERENCES persons(id) ON DELETE SET NULL,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE club_files IS 'Uploaded files, bytes in the DB, gated by visibility (mig 455). No file cache under the web root.';
COMMENT ON COLUMN club_files.mime IS 'Sniffed server-side from the bytes, never trusted from the browser (mig 455).';
CREATE INDEX IF NOT EXISTS club_files_visibility_idx ON club_files (visibility, created_at DESC);

-- Page copy (client_side rows, read through MessageCopy.block('files', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('files', 'subtitle',      'Files — page subtitle',
  'Keep a file here, share it with members, or publish it by link. Every file is stored in the database.', 1);
SELECT pg_temp.add_client_tpl('files', 'drop_hint',     'Files — drop zone hint',
  'Drop files here or tap to choose — any type, up to {max_mb} MB each.', 2);
SELECT pg_temp.add_client_tpl('files', 'empty_admin',   'Files — empty list (admin)',
  'No files yet. Add one above.', 3);
SELECT pg_temp.add_client_tpl('files', 'empty_member',  'Files — empty list (member)',
  'Nothing has been shared with you yet.', 4);
SELECT pg_temp.add_client_tpl('files', 'private_hint',  'Files — private hint',
  'Private files never get a link. Upload one, then tell Claude its title.', 5);
SELECT pg_temp.add_client_tpl('files', 'link_copied',   'Files — link copied flash',
  'Link copied — anyone with it can open {title}.', 6);
SELECT pg_temp.add_client_tpl('files', 'delete_confirm','Files — delete confirm button',
  'Tap again to delete {title}', 7);
