-- 620 (2026-10-20) — Official roster NAMES mirrored from the league sites.
--
-- Owner: "add 'roster' pill to mirror actual roster on website" — the
-- APSL roster as app.teampass.com/APSL/Team/165430 lists it, and the
-- CASA Liga 1 roster as the league's Google Sheet tab "Lighthouse Boys
-- Club" lists it.  The sources were already rows in
-- official_roster_sources (mig 501, used for the printable PDF); this
-- table keeps the PARSED player names of the latest pull so the #teams
-- board's 🌐 Roster pill can mirror the league list and mark the drift
-- against our own.  Replaced wholesale on every pull.

CREATE TABLE IF NOT EXISTS official_roster_names (
    id         serial PRIMARY KEY,
    source_id  int NOT NULL REFERENCES official_roster_sources(id) ON DELETE CASCADE,
    full_name  text NOT NULL,
    sort_order int NOT NULL DEFAULT 0,
    pulled_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS official_roster_names_source ON official_roster_names (source_id);
COMMENT ON TABLE official_roster_names IS
  'mig 620: player names of the latest official-roster pull per source (TeamPass team page / CASA sheet CSV) — the league''s spelling, exactly as the site shows it. Feeds the #teams 🌐 Roster pill.';
