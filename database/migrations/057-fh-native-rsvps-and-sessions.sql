-- 057-fh-native-rsvps-and-sessions.sql
--
-- Phase A of the GroupMe → footballhome RSVP migration.
--
-- Adds the FH-native RSVP track that runs in parallel with the existing
-- chat_event_rsvps (GM) track, plus the session + magic-link tables that
-- let a player sign in via an admin-minted email/SMS link.
--
-- DESIGN NOTES
--   * Every event (match / training / pickup) already has a chat_events
--     row in this schema — the GM webhook materialises one even for
--     practices and pickups.  Both RSVP tracks therefore key off
--     chat_event_id, which means the lineup screen can UNION the two
--     tables to get "current RSVP for person X on event Y" regardless
--     of which channel it was set on.
--
--   * Latest-write-wins on event_rsvps.  No reconciliation between
--     tracks at write time — they live independently.  The reading
--     side (UI / lineup card) decides how to merge (typically: prefer
--     FH track if present, fall back to GM track).
--
--   * event_rsvp_log is append-only.  Foreign keys are intentionally
--     OMITTED so the log survives event/person deletions (matches the
--     pattern used by person_merges).
--
--   * sessions stores SHA-256 of the cookie value, never the cookie
--     value itself.  Sliding 1-year expiry: every authenticated
--     request bumps expires_at = now() + interval '1 year'.
--
--   * magic_link_tokens also store SHA-256 of the URL-token.  Single
--     use (consumed_at set on verify).  24h TTL by default; admin
--     can re-mint if it expires.
--
--   * No new lookup tables: rsvp_statuses (1=yes,2=no,3=maybe) and
--     rsvp_change_sources (1=app,2=groupme,3=admin) are reused as-is.

-- ──────────────────────────────────────────────────────────────────
-- 1. event_rsvps — FH-native current state
-- ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_rsvps (
  id              SERIAL PRIMARY KEY,
  chat_event_id   INTEGER     NOT NULL REFERENCES chat_events(id)    ON DELETE CASCADE,
  person_id       INTEGER     NOT NULL REFERENCES persons(id)        ON DELETE CASCADE,
  rsvp_status_id  INTEGER     NOT NULL REFERENCES rsvp_statuses(id),
  response_note   TEXT,
  source_id       INTEGER              REFERENCES rsvp_change_sources(id),
  recorded_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (chat_event_id, person_id)
);

CREATE INDEX IF NOT EXISTS idx_event_rsvps_event  ON event_rsvps(chat_event_id);
CREATE INDEX IF NOT EXISTS idx_event_rsvps_person ON event_rsvps(person_id);
CREATE INDEX IF NOT EXISTS idx_event_rsvps_status ON event_rsvps(rsvp_status_id);

-- Bump updated_at on every UPSERT update.
CREATE OR REPLACE FUNCTION trg_event_rsvps_bump_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS event_rsvps_bump_updated_at ON event_rsvps;
CREATE TRIGGER event_rsvps_bump_updated_at
  BEFORE UPDATE ON event_rsvps
  FOR EACH ROW EXECUTE FUNCTION trg_event_rsvps_bump_updated_at();

-- ──────────────────────────────────────────────────────────────────
-- 2. event_rsvp_log — append-only audit
-- ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS event_rsvp_log (
  id                  BIGSERIAL PRIMARY KEY,
  chat_event_id       INTEGER     NOT NULL,
  person_id           INTEGER     NOT NULL,
  rsvp_status_id      INTEGER     NOT NULL,
  response_note       TEXT,
  source_id           INTEGER,
  changed_by_user_id  INTEGER              REFERENCES users(id) ON DELETE SET NULL,
  changed_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_event_rsvp_log_event_person
  ON event_rsvp_log(chat_event_id, person_id, changed_at DESC);

-- ──────────────────────────────────────────────────────────────────
-- 3. sessions — sliding 1-year cookie sessions
-- ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS sessions (
  id            UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  person_id     INTEGER     NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  token_hash    TEXT        NOT NULL UNIQUE,
  user_agent    TEXT,
  ip            INET,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_used_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at    TIMESTAMPTZ NOT NULL,
  revoked_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_sessions_person_active
  ON sessions(person_id) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_sessions_expires_active
  ON sessions(expires_at) WHERE revoked_at IS NULL;

-- ──────────────────────────────────────────────────────────────────
-- 4. magic_link_tokens — single-use admin-minted sign-in links
-- ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS magic_link_tokens (
  id                 SERIAL      PRIMARY KEY,
  token_hash         TEXT        NOT NULL UNIQUE,
  person_id          INTEGER     NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  chat_event_id      INTEGER              REFERENCES chat_events(id) ON DELETE SET NULL,
  channel            TEXT        NOT NULL CHECK (channel IN ('email', 'sms')),
  contact            TEXT        NOT NULL,
  minted_by_user_id  INTEGER              REFERENCES users(id) ON DELETE SET NULL,
  expires_at         TIMESTAMPTZ NOT NULL,
  consumed_at        TIMESTAMPTZ,
  consumed_session_id UUID                REFERENCES sessions(id) ON DELETE SET NULL,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_person  ON magic_link_tokens(person_id);
CREATE INDEX IF NOT EXISTS idx_magic_link_tokens_active
  ON magic_link_tokens(expires_at) WHERE consumed_at IS NULL;

-- ──────────────────────────────────────────────────────────────────
-- 5. v_event_rsvps_merged — convenience UNION view for the lineup UI
-- ──────────────────────────────────────────────────────────────────
-- Returns one row per (chat_event_id, person_id) representing the
-- "current best" RSVP — preferring the FH-native track if present,
-- otherwise falling back to the GM track.  Cards bind to this view
-- so they don't have to know about the dual-track storage.
CREATE OR REPLACE VIEW v_event_rsvps_merged AS
WITH fh AS (
  SELECT
    chat_event_id,
    person_id,
    rsvp_status_id,
    response_note,
    'footballhome'::text AS track,
    updated_at
  FROM event_rsvps
),
gm AS (
  SELECT
    cer.chat_event_id,
    cer.person_id,
    COALESCE(cer.override_rsvp_status_id, cer.rsvp_status_id) AS rsvp_status_id,
    cer.response_note,
    'groupme'::text AS track,
    COALESCE(cer.overridden_at, cer.responded_at) AS updated_at
  FROM chat_event_rsvps cer
  WHERE cer.person_id IS NOT NULL
)
SELECT DISTINCT ON (chat_event_id, person_id)
  chat_event_id,
  person_id,
  rsvp_status_id,
  response_note,
  track,
  updated_at
FROM (
  SELECT * FROM fh
  UNION ALL
  SELECT * FROM gm
) merged
ORDER BY chat_event_id, person_id, updated_at DESC;
