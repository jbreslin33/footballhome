-- ─────────────────────────────────────────────────────────────────────
-- 433-merge-uploaded-duplicate-clubs.sql (2026-09-25)
--
-- The owner's first folder upload on #logos ("the official ones") created
-- a club per file name.  Seven names did not match the club we already
-- had ("Desert Hawks FC" vs "Desert Hawks"), and four CASA Select files
-- became four clubs.  Fold each duplicate into the real club, make the
-- uploaded crest that club's current logo (owner: overwrite with the
-- latest by default), keep the older crests as history, and alias the
-- spelling so the next upload lands on the right club.  Name matching
-- itself is loosened in code (ClubLogo::nameKey) so this does not recur.
-- ─────────────────────────────────────────────────────────────────────
CREATE TEMP TABLE merge (dupe_id INT, keep_id INT, alias TEXT) ON COMMIT DROP;
INSERT INTO merge VALUES
  (20, 4,     'Desert Hawks FC'),            -- Desert Hawks
  (24, 129,   'Phila Heritage'),             -- Philadelphia Heritage SC
  (15, 20002, 'Persepolis United'),          -- Persepolis FC
  (16, 131,   'PSC II'),                     -- Philadelphia Soccer Club
  (25, 10,    'VE Reserves'),                -- Vereinigung Erzgebirge
  (29, 125,   'WC Predators II'),            -- WC Predators
  (17, 23,    'CASA Select (2)'),            -- CASA Select — one club, four files
  (19, 23,    'CasaSelect Primary'),
  (28, 23,    'CASA Select (3)');

-- Guard: only merge rows that are still the throw-away uploads from today.
DELETE FROM merge m WHERE NOT EXISTS (SELECT 1 FROM clubs c WHERE c.id = m.dupe_id AND c.organization_id IS NULL);

-- Move the uploaded crests onto the real club.
UPDATE club_logos l SET club_id = m.keep_id FROM merge m WHERE l.club_id = m.dupe_id;

-- The upload becomes the club's current crest (latest upload per club).
UPDATE clubs c
   SET logo_id = latest.id, logo_url = latest.file_path, updated_at = now()
  FROM (SELECT DISTINCT ON (l.club_id) l.club_id, l.id, l.file_path
          FROM club_logos l WHERE l.source = 'upload' ORDER BY l.club_id, l.created_at DESC) latest
 WHERE c.id = latest.club_id AND c.id IN (SELECT keep_id FROM merge);
-- …except CASA Select, where the file named "primary" is the mark to show.
UPDATE clubs SET logo_id = 21, logo_url = (SELECT file_path FROM club_logos WHERE id = 21), name = 'CASA Select'
 WHERE id = 23 AND EXISTS (SELECT 1 FROM club_logos WHERE id = 21 AND club_id = 23);

-- The spellings point at the real club from now on.
INSERT INTO club_aliases (club_id, alias, notes)
SELECT DISTINCT ON (LOWER(BTRIM(alias))) club_id, alias, notes FROM (
  SELECT keep_id AS club_id, alias, 'mig 433 — merged upload duplicate' AS notes FROM merge
  UNION ALL SELECT 23, 'CASA Select', 'mig 433'
  UNION ALL SELECT 131, 'PSC', 'mig 433'
) v
ON CONFLICT (LOWER(BTRIM(alias))) DO UPDATE SET club_id = EXCLUDED.club_id;

-- Anything else that hangs off the duplicates moves too, then they go.
UPDATE club_aliases a SET club_id = m.keep_id FROM merge m WHERE a.club_id = m.dupe_id;
UPDATE club_logo_searches s SET club_id = m.keep_id FROM merge m WHERE s.club_id = m.dupe_id;
UPDATE teams t SET club_id = m.keep_id FROM merge m WHERE t.club_id = m.dupe_id;
DELETE FROM clubs WHERE id IN (SELECT dupe_id FROM merge);
