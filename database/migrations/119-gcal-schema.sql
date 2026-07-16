-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 119: Google Calendar integration — Slice 1 schema
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- See docs/calendar-design.md §5 (schema) + §6.5 (RSVP window rule) +
-- §6.5.3 (standing/recurring RSVPs).
--
-- Adds the four tables + one seed insert that Slice 2 (sync worker),
-- Slice 3 (classifier), and Slice 6/6a (RSVP endpoints + standing
-- applier) need to exist. No behavior changes until those slices land
-- — this migration is purely additive DDL + seed data.
--
--   gcal_calendars        — one row per Google calendar we sync from
--   gcal_events           — faithful mirror of every event on those
--                           calendars (including non-soccer bookings
--                           on Ops — those get mirrored but never
--                           promoted into fh_events; see §6.0)
--   fh_events             — FH-side classification + editable extras
--                           hanging off one gcal_events row
--                           (kind, category, team, rsvps_open_at, …)
--   fh_event_rsvps        — per-event RSVP responses, keyed to
--                           fh_events.id so they survive gcal edits
--   fh_recurring_rsvps    — standing "always yes" preferences per
--                           (person, kind, category); applied at
--                           rsvps_open_at by scripts/gcal-rsvp-apply-standing.js
--
-- The hard rule from §1.1 is enforced by schema shape: fh_events has
-- an FK to gcal_events with ON DELETE RESTRICT. You cannot delete
-- the gcal_events row unless fh_events is gone first — deletion in
-- gcal must go through the tombstone path (deleted_at + hidden), not
-- physical delete of the mirror row. Whoever writes the sync worker
-- (Slice 2) must therefore always tombstone, never DELETE.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- ─── 1. gcal_calendars ────────────────────────────────────────────────
--
-- One row per Google calendar the sync worker polls. `sync_token`
-- carries Google's incremental cursor between runs; NULL means the
-- next poll must be a full sync (paginated events.list()).
CREATE TABLE IF NOT EXISTS gcal_calendars (
    id             SERIAL PRIMARY KEY,
    google_id      TEXT        NOT NULL UNIQUE,   -- e.g. soccer@lighthouse1893.org
    role           TEXT        NOT NULL CHECK (role IN ('soccer','ops')),
    can_write      BOOLEAN     NOT NULL,          -- soccer=true, ops=false
    display_name   TEXT        NOT NULL,
    time_zone      TEXT        NOT NULL,
    last_synced_at TIMESTAMPTZ,
    sync_token     TEXT,                          -- Google incremental cursor
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ─── 2. gcal_events ───────────────────────────────────────────────────
--
-- Faithful mirror. Same event mirrored to both calendars = two rows
-- here (see §5 open question — we render both, don't try to dedupe).
--
-- `hash` is a content hash the sync worker computes so it can skip
-- UPSERTs when nothing changed. `raw` keeps the full API payload so
-- future features (attendees, attachments, colors) don't need
-- schema changes.
--
-- `deleted_at` is the tombstone. Sync worker sets it when Google
-- reports status='cancelled' or the event stops appearing in
-- syncToken deltas. Physical DELETE is forbidden — see §1.1.
CREATE TABLE IF NOT EXISTS gcal_events (
    id                 BIGSERIAL PRIMARY KEY,
    calendar_id        INT       NOT NULL REFERENCES gcal_calendars(id) ON DELETE CASCADE,
    google_event_id    TEXT      NOT NULL,
    recurring_event_id TEXT,                      -- parent of a recurring instance
    summary            TEXT,
    description        TEXT,
    location           TEXT,
    starts_at          TIMESTAMPTZ NOT NULL,
    ends_at            TIMESTAMPTZ NOT NULL,
    all_day            BOOLEAN     NOT NULL DEFAULT false,
    status             TEXT        NOT NULL,      -- confirmed | tentative | cancelled
    html_link          TEXT,
    hash               TEXT        NOT NULL,
    raw                JSONB       NOT NULL,
    first_seen_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_seen_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at         TIMESTAMPTZ,               -- tombstone
    UNIQUE (calendar_id, google_event_id)
);
CREATE INDEX IF NOT EXISTS gcal_events_starts_at_idx
    ON gcal_events (starts_at);
CREATE INDEX IF NOT EXISTS gcal_events_calendar_starts_idx
    ON gcal_events (calendar_id, starts_at);
-- Fast "is this a soccer event?" filter for the §6.0 classifier query.
CREATE INDEX IF NOT EXISTS gcal_events_soccer_prefix_idx
    ON gcal_events (starts_at)
    WHERE deleted_at IS NULL AND summary ~* '^\s*Soccer\b';

-- ─── 3. fh_events ─────────────────────────────────────────────────────
--
-- One row per gcal_events row that passed the §6.0 "Soccer" prefix
-- filter AND was classified by §6.1 (pattern-match) or §6.2 (manual
-- override). NOT NULL FK with ON DELETE RESTRICT enforces §1.1 —
-- fh_events cannot outlive its gcal_events parent physically.
--
-- `rsvps_open_at` = most recent Sunday 20:00 America/New_York that is
--   <= gcal_events.starts_at, for kind='pickup'. NULL for kinds that
--   don't have a windowed RSVP (see §6.5.4 for extending later).
--
-- `standing_applied_at` = when the standing-RSVP applier (§6.5.3) ran
--   for this event. NULL = applier hasn't run yet.
CREATE TABLE IF NOT EXISTS fh_events (
    id                  BIGSERIAL PRIMARY KEY,
    gcal_event_id       BIGINT      NOT NULL REFERENCES gcal_events(id) ON DELETE RESTRICT,
    kind                TEXT        NOT NULL CHECK (kind IN ('practice','pickup','match','meeting','camp','other')),
    category            TEXT        CHECK (category IS NULL OR category IN ('mens','womens','boys','girls','staff')),
    team_id             INT         REFERENCES teams(id),
    is_home             BOOLEAN,
    facility_id         INT,                     -- future: facilities table
    rsvps_open_at       TIMESTAMPTZ,             -- §6.5 window
    standing_applied_at TIMESTAMPTZ,             -- §6.5.3 applier bookkeeping
    fh_notes            TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (gcal_event_id)
);
CREATE INDEX IF NOT EXISTS fh_events_kind_category_idx
    ON fh_events (kind, category);
-- Applier scan: "events whose window has opened and haven't been applied yet".
CREATE INDEX IF NOT EXISTS fh_events_applier_scan_idx
    ON fh_events (rsvps_open_at)
    WHERE standing_applied_at IS NULL AND rsvps_open_at IS NOT NULL;

-- ─── 4. fh_event_rsvps ────────────────────────────────────────────────
--
-- Per-event RSVP responses. Keyed to fh_events.id (not gcal_events)
-- so they survive gcal edits — even if the gcal_events row tombstones
-- and later resurrects (see §1.1), the fh_events id is stable and
-- these rows come back with it.
--
-- `created_via` distinguishes manual clicks from automated inserts by
-- the standing-RSVP applier (§6.5.3) or admin overrides — useful for
-- audit and for the UI to show "auto-registered via standing pref".
CREATE TABLE IF NOT EXISTS fh_event_rsvps (
    id           BIGSERIAL PRIMARY KEY,
    fh_event_id  BIGINT      NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    person_id    INT         NOT NULL REFERENCES persons(id)    ON DELETE CASCADE,
    response     TEXT        NOT NULL CHECK (response IN ('yes','no','maybe')),
    responded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_via  TEXT        NOT NULL DEFAULT 'manual'
                             CHECK (created_via IN ('manual','standing','admin')),
    UNIQUE (fh_event_id, person_id)
);
CREATE INDEX IF NOT EXISTS fh_event_rsvps_person_idx
    ON fh_event_rsvps (person_id);

-- ─── 5. fh_recurring_rsvps ────────────────────────────────────────────
--
-- Standing "always YES for pickup/mens" preferences (§6.5.3). One row
-- per (person, kind, category) tuple the user has opted into.
-- `category` NULL means "any category" — e.g. a user could set
-- kind='pickup', category=NULL to auto-RSVP for BOTH mens and womens
-- pickup, though the profile UI will likely just expose specific
-- combinations.
--
-- The applier joins this table to fh_events rows whose
-- rsvps_open_at has passed AND standing_applied_at IS NULL.
CREATE TABLE IF NOT EXISTS fh_recurring_rsvps (
    id         BIGSERIAL PRIMARY KEY,
    person_id  INT         NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    kind       TEXT        NOT NULL,             -- matches fh_events.kind
    category   TEXT,                             -- matches fh_events.category, NULL = any
    response   TEXT        NOT NULL CHECK (response IN ('yes','no','maybe')),
    active     BOOLEAN     NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Postgres treats NULLs as distinct in a plain UNIQUE constraint, so we
-- need a functional unique index that folds NULL category to '' for
-- the "one standing pref per (person, kind, category)" invariant.
CREATE UNIQUE INDEX IF NOT EXISTS fh_recurring_rsvps_unique_idx
    ON fh_recurring_rsvps (person_id, kind, COALESCE(category, ''));
CREATE INDEX IF NOT EXISTS fh_recurring_rsvps_kind_cat_active_idx
    ON fh_recurring_rsvps (kind, category)
    WHERE active = true;

-- ─── 6. Seed the two calendars ────────────────────────────────────────
--
-- These IDs match what env vars GCAL_SOCCER_CALENDAR_ID and
-- GCAL_OPS_CALENDAR_ID hold (see scripts/gcal-test.js header for the
-- setup path).
INSERT INTO gcal_calendars (google_id, role, can_write, display_name, time_zone)
VALUES
    ('soccer@lighthouse1893.org', 'soccer', true,  'Lighthouse Soccer', 'America/New_York'),
    ('sports@lighthouse1893.org', 'ops',    false, 'Lighthouse Ops',    'America/New_York')
ON CONFLICT (google_id) DO NOTHING;

COMMIT;
