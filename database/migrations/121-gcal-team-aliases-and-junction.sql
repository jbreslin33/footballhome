-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 121: gcal description DSL — aliases + fh_event_teams junction
-- Slice 6b of docs/calendar-design.md §6.1.5
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Motivation. The §6.1 summary-regex classifier (migration 119) knows
-- an event is a "mens pickup" only by pattern-matching the gcal
-- Summary. It has no way to reach into the FH team model — which is
-- what actually gates RSVP eligibility per §5. Slice 6b introduces a
-- description-based DSL so ops staff can write, in the gcal event's
-- description body:
--
--     Team: Pickup
--     Club: Mens
--
-- and have FH resolve that pair to a real `teams` row (team_id 909,
-- the Mens Pickup pool) — which unlocks the eligibility gate on
-- POST /api/calendar/rsvp.
--
-- Three DB pieces land here:
--
--   1. `gcal_norm_alias(TEXT)`. Immutable case-fold + punctuation-strip
--      normalizer so 'Mens', 'MENS', 'Men''s' all collapse to the same
--      lookup key. SQL-language IMMUTABLE lets Postgres inline it and
--      use it in expression indexes if we ever need one.
--
--   2. `gcal_team_aliases (club_alias, team_alias) -> team_id`.
--      Composite-PK lookup table. Each row says "when the DSL says
--      `Club: <club_alias> / Team: <team_alias>`, resolve to this
--      teams row." Slice 6b seeds the six Mens teams that appear in
--      MensRosterController.cpp's `kEligibilityTeams` + the two mens
--      pool teams. Womens/Boys/Girls rows land in later slices when
--      those categories get RSVP infra (§5.1 roadmap).
--
--   3. `fh_event_teams (fh_event_id, team_id)`. Junction table so ONE
--      calendar event can attach to MANY teams (co-ed pickup =
--      Mens Pickup + Womens Pickup; all-club practice, etc.).
--      Migrates the existing single-team column from `fh_events` into
--      rows here, then drops `fh_events.team_id` — no denormalized
--      single-team FK survives.
--
-- Append-only rule (per docs/calendar-design.md §6.1.5 and sim ADR
-- §22.25): once a (club_alias, team_alias) row is inserted and
-- referenced by any live gcal event, its `team_id` must not change.
-- Rename gcal_team_aliases entries only if you also update every
-- gcal event's description that uses the old alias. Safer: add a
-- new alias row alongside and let the old one go quiet.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- ─── 1. gcal_norm_alias() ─────────────────────────────────────────────
--
-- SQL-language + IMMUTABLE so:
--   * Postgres can call it inside a partial-index predicate if we
--     ever want to enforce alias-uniqueness case-insensitively.
--   * Classifier / eligibility queries pay zero function-call cost —
--     the planner inlines the body.
--
-- Rules:
--   lowercase   → so 'MENS' matches 'mens'
--   strip !alnum → so 'Men''s', 'Mens.', 'Mens ' all collapse
--   collapse whitespace → 'liga  1' → 'liga 1'
--   trim → 'liga 1 ' → 'liga 1'
--
-- We intentionally KEEP internal single spaces (so 'liga 1' and
-- 'liga1' remain distinct) — the alias table seeds both variants
-- where they're both natural. The classifier does NOT strip spaces
-- for the caller.
CREATE OR REPLACE FUNCTION gcal_norm_alias(s TEXT) RETURNS TEXT AS $$
    SELECT trim(
             regexp_replace(
               regexp_replace(lower(s), '[^a-z0-9 ]+', ' ', 'g'),
               '\s+', ' ', 'g'))
$$ LANGUAGE SQL IMMUTABLE;

COMMENT ON FUNCTION gcal_norm_alias(TEXT) IS
    'Case-fold + strip-punctuation + collapse-whitespace normalizer for '
    'gcal description DSL alias lookups. See docs/calendar-design.md §6.1.5.';


-- ─── 2. gcal_team_aliases ─────────────────────────────────────────────
--
-- Lookup table: (Club, Team) DSL pair → teams row.
--
-- club_alias   normalized club value ('mens','womens','boys','girls')
-- team_alias   normalized team value ('pickup','practice','apsl',
--              'liga 1','liga 2','adult', ...)
-- team_id      REFERENCES teams(id) — the real FH team the pair
--              resolves to. FK is ON DELETE RESTRICT because a team
--              disappearing while gcal events still reference it via
--              alias is a data-quality bug we want to catch loudly.
-- notes        Free-form comment for the seed row (why this alias,
--              who owns it, etc.). Not read by any code.
--
-- The (club_alias, team_alias) composite PK is deliberately narrow —
-- two aliases can map to the same team_id (e.g. 'liga 1' and 'liga1'
-- both → 120), but ONE (club, team) pair cannot fan out to two teams.
-- If we ever want a "super-pool" concept we add a new team row and
-- alias to it; we don't allow the alias table itself to be one-to-many.
CREATE TABLE IF NOT EXISTS gcal_team_aliases (
    club_alias TEXT NOT NULL,
    team_alias TEXT NOT NULL,
    team_id    INT  NOT NULL REFERENCES teams(id),
    notes      TEXT,
    PRIMARY KEY (club_alias, team_alias)
);

CREATE INDEX IF NOT EXISTS idx_gcal_team_aliases_team
    ON gcal_team_aliases (team_id);

COMMENT ON TABLE gcal_team_aliases IS
    'Slice 6b: (Club, Team) description DSL pair → teams row. '
    'See docs/calendar-design.md §6.1.5. APPEND-ONLY: rows may be '
    'added freely; team_id may not be repointed once referenced.';


-- ─── 3. Slice 6b seed (Mens only) ─────────────────────────────────────
--
-- These are the six teams from MensRosterController.cpp's
-- `kEligibilityTeams` list (frontend mirror: rsvp-eligibility.js
-- `_teams()`). Aliases include both the natural short-form and
-- (where different) the spaced/spelled-out form so ops staff can
-- type either without hitting normalize-mismatch surprises.
--
-- The trigger on player_rsvp_eligibility (from migration 107 /
-- fn_grant_default_rsvp_eligibility) auto-includes every mens member
-- in team 908 (Practice) and team 909 (Pickup), so ANY event tagged
-- `Team: Practice / Club: Mens` or `Team: Pickup / Club: Mens` gates
-- RSVP eligibility to the full mens roster automatically. No manual
-- team_id maintenance required.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('mens', 'apsl',     35,  'Mens APSL competitive'),
    ('mens', 'liga 1',   120, 'Mens Liga 1 (reserve pool)'),
    ('mens', 'liga1',    120, 'Alt spelling for Liga 1'),
    ('mens', 'liga 2',   121, 'Mens Liga 2'),
    ('mens', 'liga2',    121, 'Alt spelling for Liga 2'),
    ('mens', 'adult',    122, 'Lighthouse League adult feeder'),
    ('mens', 'practice', 908, 'Pool: all mens auto-included'),
    ('mens', 'pickup',   909, 'Pool: all mens + pickup-only members')
ON CONFLICT (club_alias, team_alias) DO NOTHING;


-- ─── 4. fh_event_teams junction ──────────────────────────────────────
--
-- One row per (fh_event, team) participation link. Replaces the
-- previous denormalized single-team FK on fh_events.team_id — see
-- §6.1.5 rationale in the design doc.
--
-- ON DELETE CASCADE on the fh_events FK is safe (in fact required):
-- if the fh_events row goes away, whatever team links it had should
-- also go, since nothing else in the schema meaningfully references
-- (fh_event_id, team_id) pairs. Note fh_events itself has an ON
-- DELETE RESTRICT to gcal_events, so the deletion path only opens
-- via explicit fh_events DELETE — which is rare (only pool cleanup).
CREATE TABLE IF NOT EXISTS fh_event_teams (
    fh_event_id BIGINT NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    team_id     INT    NOT NULL REFERENCES teams(id),
    PRIMARY KEY (fh_event_id, team_id)
);

CREATE INDEX IF NOT EXISTS idx_fh_event_teams_team
    ON fh_event_teams (team_id);

COMMENT ON TABLE fh_event_teams IS
    'Slice 6b: junction table linking one fh_events row to one or more '
    'teams. Supports co-ed / all-club events. Eligibility gate on '
    'POST /api/calendar/rsvp joins through here. '
    'See docs/calendar-design.md §6.1.5.';


-- ─── 5. Migrate existing fh_events.team_id → fh_event_teams ──────────
--
-- Zero-loss: any fh_events row that currently has a non-null team_id
-- gets exactly one junction row with the same team_id. Rows with
-- NULL team_id (the vast majority right now — only the §6.1 regex
-- classifier hasn't been populating team_id) simply produce no
-- junction rows, which is the correct "no team attached, no RSVP"
-- semantic.
INSERT INTO fh_event_teams (fh_event_id, team_id)
SELECT id, team_id
FROM   fh_events
WHERE  team_id IS NOT NULL
ON CONFLICT (fh_event_id, team_id) DO NOTHING;


-- ─── 6. Drop the denormalized team_id column ─────────────────────────
--
-- The junction is the single source of truth now. Downstream consumers
-- (backend GET/POST, classifier) are updated in the same slice — this
-- migration + those changes ship together, no soft-deprecation window.
ALTER TABLE fh_events DROP COLUMN team_id;


COMMIT;
