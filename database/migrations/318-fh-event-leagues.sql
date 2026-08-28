-- ─────────────────────────────────────────────────────────────────────
-- 318-fh-event-leagues.sql (2026-08-28)
--
-- One event can belong to two leagues. Intra-squad APSL vs Liga 1 is
-- the case that surfaced it, but cross-league friendlies and cup ties
-- are the same shape (owner: "shouldn't we allow for 2 leagues to play
-- each other?" / "make it a join table instead of field right").
--
-- fh_events.league is a single text column holding the `League:` tag
-- verbatim, and every consumer matched that whole string against
-- gcal_league_aliases. So "APSL" resolved, and "APSL, Liga 1" resolved
-- to NOTHING -- a two-league event got no crest at all, which is worse
-- than the one-league case the column was written for.
--
-- Splitting the string on commas at every call site would work and is
-- what a first pass did; this is that pass done properly. The resolved
-- leagues are a many-to-many relationship, so they get the same shape
-- fh_event_teams already uses for the `Team:` tag: composite PK, cascade
-- on the event, plain FK to the owning row.
--
-- fh_events.league STAYS. The two are not redundant: `league` is ops'
-- own wording, kept verbatim because it is the display label (see
-- LEAGUE_CREST_SQL's contract in EventController -- "the League: tag
-- verbatim, since ops' own wording is the display wording"), while this
-- table is the resolved identity behind it. Exactly the split between
-- gcal `Team:` text and fh_event_teams.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

CREATE TABLE IF NOT EXISTS fh_event_leagues (
    fh_event_id     bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    organization_id integer NOT NULL REFERENCES organizations(id),
    PRIMARY KEY (fh_event_id, organization_id)
);

CREATE INDEX IF NOT EXISTS idx_fh_event_leagues_org
    ON fh_event_leagues (organization_id);

-- Backfill every event whose tag resolves, one row per distinct league.
-- Events tagged with something not in gcal_league_aliases simply get no
-- rows, which is the same "no crest to show" they have today.
INSERT INTO fh_event_leagues (fh_event_id, organization_id)
SELECT DISTINCT fe.id, gla.organization_id
  FROM fh_events fe
  CROSS JOIN LATERAL regexp_split_to_table(fe.league, '[[:space:]]*,[[:space:]]*') AS tok
  JOIN gcal_league_aliases gla
    ON LOWER(BTRIM(gla.alias)) = LOWER(BTRIM(tok))
 WHERE fe.league IS NOT NULL AND BTRIM(fe.league) <> ''
ON CONFLICT DO NOTHING;

COMMENT ON TABLE fh_event_leagues IS
    'Leagues an event belongs to, resolved from the gcal League: tag via gcal_league_aliases. Many-to-many: an intra-squad or cross-league fixture has two rows. fh_events.league keeps the raw tag for display.';

COMMIT;
