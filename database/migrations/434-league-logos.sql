-- ─────────────────────────────────────────────────────────────────────
-- 434-league-logos.sql (2026-09-25)
--
-- Owner: "we should do same for league logo functionality we did for
-- club right?"  Same shape as club_logos (mig 428), hung off
-- organizations: the image bytes live in the DB, organizations.logo_id
-- says which is current, organizations.logo_url mirrors its nginx path
-- (/images/league-logos/<slug>-<id>.<ext>) so every league-crest query
-- (CalendarController league_logo_url, EventController LEAGUE_CREST_SQL)
-- keeps working unchanged.  The hand-placed /images/leagues files are
-- imported on the backend's next start (LeagueLogo::importLegacy).
-- League text -> organization already exists: gcal_league_aliases.
-- ─────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS organization_logos (
    id                SERIAL PRIMARY KEY,
    organization_id   INT  NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    bytes             BYTEA NOT NULL,
    mime              TEXT NOT NULL,
    byte_size         INT  NOT NULL,
    file_path         TEXT NOT NULL UNIQUE,
    source            TEXT NOT NULL CHECK (source IN ('upload', 'url', 'legacy')),
    source_url        TEXT,
    original_filename TEXT,
    uploaded_by       INT REFERENCES persons(id) ON DELETE SET NULL,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE organization_logos IS 'Every league/organization crest ever uploaded or captured (mig 434). bytes is the source of truth; the file under frontend/images/league-logos is a cache the backend rewrites.';
CREATE INDEX IF NOT EXISTS organization_logos_org_idx ON organization_logos (organization_id, created_at DESC);

ALTER TABLE organizations ADD COLUMN IF NOT EXISTS logo_id INT REFERENCES organization_logos(id) ON DELETE SET NULL;
COMMENT ON COLUMN organizations.logo_id  IS 'Current crest (organization_logos). NULL = none stored; logo_url may still hold a legacy path.';
COMMENT ON COLUMN organizations.logo_url IS 'nginx path of the current crest — derived from organization_logos via logo_id when set (mig 434).';
