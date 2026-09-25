-- ─────────────────────────────────────────────────────────────────────
-- 428-club-logos.sql (2026-09-25)
--
-- Owner: "make a logo upload that i can upload a folder and it will have
-- name of club in file names … its for us to upload opponent logos … it
-- should also accept a url and then capture that logo … all logos need
-- to be saved in db and normalized with club etc."
--
-- Until now an opponent's crest was a bare URL string in one of three
-- places (teams.logo_url, opponent_logo_cache.logo_url, or a file under
-- frontend/images/teams/logos added by hand + a migration).  This gives
-- every logo one home:
--
--   clubs         the club (ours or an opponent).  organization_id becomes
--                 optional — an opponent we only ever meet on a gcal
--                 "Opponent:" tag belongs to no league organization of ours.
--   club_logos    the image itself (bytes in the DB — the source of truth —
--                 plus mime/size/where it came from).  The backend writes a
--                 file copy under frontend/images/clubs/ so nginx serves it
--                 with no backend hop; ClubLogo::materialize() rewrites any
--                 copy that is missing at startup, so the files are a cache.
--   clubs.logo_id the current logo (history stays in club_logos).
--   clubs.logo_url the nginx path of that logo — kept in sync by the model,
--                 read by every crest query that already joins clubs/teams.
--   club_aliases  free-form opponent text ("KSC", "Fishtown A.C.") -> club.
--                 Crest resolution on #my / Game Center consults this first.
--
-- Served by ClubLogoController (/api/club-logos) and the #logos page.
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE clubs ALTER COLUMN organization_id DROP NOT NULL;
-- Unattached clubs are unique by name (the org-scoped unique stays for scraped rows).
CREATE UNIQUE INDEX IF NOT EXISTS clubs_unattached_name_idx
    ON clubs (LOWER(BTRIM(name))) WHERE organization_id IS NULL;

CREATE TABLE IF NOT EXISTS club_logos (
    id                SERIAL PRIMARY KEY,
    club_id           INT  NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    bytes             BYTEA NOT NULL,
    mime              TEXT NOT NULL,
    byte_size         INT  NOT NULL,
    file_path         TEXT NOT NULL UNIQUE,     -- /images/clubs/<slug>-<id>.<ext> as nginx serves it
    source            TEXT NOT NULL CHECK (source IN ('upload', 'url', 'legacy')),
    source_url        TEXT,                     -- the URL captured (source = 'url')
    original_filename TEXT,                     -- the file name uploaded (source = 'upload')
    uploaded_by       INT REFERENCES persons(id) ON DELETE SET NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE club_logos IS 'Every club crest ever uploaded/captured (mig 428). bytes is the source of truth; the file under frontend/images/clubs is a cache the backend rewrites.';
CREATE INDEX IF NOT EXISTS club_logos_club_idx ON club_logos (club_id, created_at DESC);

ALTER TABLE clubs ADD COLUMN IF NOT EXISTS logo_id INT REFERENCES club_logos(id) ON DELETE SET NULL;
COMMENT ON COLUMN clubs.logo_id  IS 'Current crest (club_logos). NULL = none uploaded yet; logo_url may still hold a legacy external URL.';
COMMENT ON COLUMN clubs.logo_url IS 'nginx path of the current crest — derived from club_logos via logo_id when set (mig 428); legacy external URL otherwise.';

CREATE TABLE IF NOT EXISTS club_aliases (
    id         SERIAL PRIMARY KEY,
    club_id    INT  NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    alias      TEXT NOT NULL,
    notes      TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS club_aliases_alias_idx ON club_aliases (LOWER(BTRIM(alias)));
COMMENT ON TABLE club_aliases IS 'Opponent text as typed in a gcal Opponent: tag -> the club (mig 428). Consulted before gcal_opponent_aliases / teams.name / opponent_logo_cache.';

-- ── Seed: the hand-placed logos + their opponent spellings become clubs +
--    aliases.  The files are imported into club_logos by the backend on its
--    first start (ClubLogo::importLegacy reads frontend/images).
CREATE TEMP TABLE seed_clubs (name TEXT, logo_url TEXT, aliases TEXT[]) ON COMMIT DROP;
INSERT INTO seed_clubs VALUES
  ('Boyertown Breakers',        '/images/teams/logos/boyertown-breakers.png',      ARRAY['Boyertown Breakers']),
  ('Colonial Soccer Club',      '/images/teams/logos/colonials.png',               ARRAY['Colonial','Colonial SC','Colonials','Colonial Soccer Club']),
  ('Desert Hawks',              '/images/teams/logos/desert-hawks.png',            ARRAY['Desert Hawks']),
  ('Feels Good FC',             '/images/teams/logos/feels-good-fc.png',           ARRAY['Feels Good FC','FeelsGood FC','Feelsgood']),
  ('Fishtown AC',               '/images/teams/logos/fishtown.png',                ARRAY['Fishtown','Fishtown AC','Fishtown A.C.']),
  ('German American Kickers',   '/images/teams/logos/german-american-kickers.png', ARRAY['German American Kickers','German American Kickers Liga 1']),
  ('Kensington Soccer Club',    '/images/teams/logos/kensington-soccer-club.png',  ARRAY['KSC','Kensington SC','Kensington Soccer Club']),
  ('Roxborough United',         '/images/teams/logos/roxborough-united.png',       ARRAY['Roxborough','Roxborough United','SC Roxborough United']),
  ('Philadelphia Sierra Stars', '/images/teams/logos/sierra-stars.png',            ARRAY['Sierra Stars','Philadelphia Sierra Stars']),
  ('Vereinigung Erzgebirge',    '/images/teams/logos/vereinigung-erzgebirge.png',  ARRAY['Vereinigung Erzgebirge','Vereinigung Erzgebirge Majors']);

INSERT INTO clubs (organization_id, name, logo_url)
SELECT NULL, s.name, s.logo_url FROM seed_clubs s
 WHERE NOT EXISTS (SELECT 1 FROM clubs c WHERE LOWER(BTRIM(c.name)) = LOWER(BTRIM(s.name)));

INSERT INTO club_aliases (club_id, alias, notes)
SELECT c.id, a.alias, 'seeded from opponent_logo_cache (mig 428)'
  FROM seed_clubs s
  JOIN clubs c ON LOWER(BTRIM(c.name)) = LOWER(BTRIM(s.name))
  CROSS JOIN LATERAL unnest(s.aliases) AS a(alias)
ON CONFLICT DO NOTHING;

-- Clubs that already exist from the APSL scrape but were reached through a
-- gcal_opponent_aliases -> teams row: point the opponent text straight at the club.
INSERT INTO club_aliases (club_id, alias, notes) VALUES
  (127, 'Oaklyn United',         'mig 428'),
  (136, 'Medford Strikers',      'mig 428'),
  (136, 'Medford Strikers APSL', 'mig 428'),
  (20002, 'Persepolis FC',       'mig 428')
ON CONFLICT DO NOTHING;
-- Oaklyn's hand-placed local crest beats the scraped light-on-dark one.
UPDATE clubs SET logo_url = '/images/teams/logos/oaklyn-united.jpg' WHERE id = 127;

-- Our own club: intra-squad fixtures name the other Lighthouse side.
INSERT INTO club_aliases (club_id, alias, notes) VALUES
  (134, 'Lighthouse',        'mig 428'),
  (134, 'Lighthouse APSL',   'mig 428'),
  (134, 'Lighthouse Liga 1', 'mig 428'),
  (134, 'Lighthouse 1893',   'mig 428')
ON CONFLICT DO NOTHING;

-- The scraped "Philadelphia Sierra Stars" club (20003) carried no crest; the
-- hand-placed file is the one to import.
UPDATE clubs SET logo_url = '/images/teams/logos/sierra-stars.png'
 WHERE COALESCE(logo_url, '') = ''
   AND id IN (SELECT club_id FROM club_aliases WHERE alias = 'Sierra Stars');
