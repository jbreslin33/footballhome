-- 087-match-series.sql (2026-07-04)
--
-- Adds recurring event series support to `matches`.
--
-- Two changes:
--   1. New table `match_series` capturing the template for a weekly
--      recurring event (practice / pickup / etc.).  Coach edits the
--      series once; matches are materialised from it week-by-week by
--      the Sunday-8pm cron.
--
--   2. Extend `matches` with:
--        series_id       INT NULL       -- back-reference to the series
--                                          this instance was materialised
--                                          from (NULL for one-off).
--        is_override     BOOLEAN        -- TRUE means this specific
--                                          instance was edited manually
--                                          via "This event only" and
--                                          must NOT be overwritten by
--                                          future "Edit series" ops.
--        cancelled_at    TIMESTAMPTZ    -- soft-cancel a single instance
--                                          without deleting it.  Series
--                                          re-materialisation checks
--                                          this and skips.  NULL = live.
--        rsvp_opens_at   TIMESTAMPTZ    -- earliest moment players may
--                                          see + RSVP this event on the
--                                          /my page.  Coach admin ignores
--                                          this filter.
--
-- Design notes:
--   • `day_of_week` uses 0=Sunday..6=Saturday to match Postgres EXTRACT
--     (DOW FROM …).
--   • `starts_on` / `ends_on` bound the series' active date range.
--     ends_on NULL = open-ended.
--   • `home_team_id` / `away_team_id` may both be NULL for pool events
--     (Pickup team 909, Practice team 908) that don't need opponents.
--     The check_match_teams constraint on `matches` allows this for
--     match_type_id IN (2,3,5,7).
--   • Series edit modes (implemented in backend service, not schema):
--       "this event only"        → UPDATE matches row + set is_override
--       "this and future events" → UPDATE match_series row + UPDATE all
--                                  future non-override matches
--       "all events"             → same as above but bulk-overwrites
--                                  overrides too (requires confirm)
--   • rsvp_opens_at population strategy (set by application code, not
--     schema):
--       practice / pickup match  → prev Sunday 8pm before match_date
--       league game (type 1/2)   → match_date - INTERVAL '6 days'
--       one-off custom           → coach-supplied or default -6 days

BEGIN;

CREATE TABLE IF NOT EXISTS match_series (
  id              SERIAL       PRIMARY KEY,
  name            VARCHAR(120) NOT NULL,
  match_type_id   INTEGER      NOT NULL REFERENCES match_types(id),
  home_team_id    INTEGER      REFERENCES teams(id),
  away_team_id    INTEGER      REFERENCES teams(id),
  venue_id        INTEGER      REFERENCES venues(id),
  day_of_week     SMALLINT     NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time      TIME         NOT NULL,
  end_time        TIME,
  duration_min    INTEGER,
  title           VARCHAR(255),
  description     TEXT,
  starts_on       DATE         NOT NULL,
  ends_on         DATE,
  active          BOOLEAN      NOT NULL DEFAULT TRUE,
  created_by_user_id INTEGER   REFERENCES users(id),
  created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  CHECK (ends_on IS NULL OR ends_on >= starts_on)
);

CREATE INDEX IF NOT EXISTS idx_match_series_active_dow
  ON match_series (active, day_of_week) WHERE active = TRUE;

CREATE TRIGGER trg_match_series_updated_at
  BEFORE UPDATE ON match_series
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Add series linkage + override + cancel + rsvp-window columns to matches.
ALTER TABLE matches
  ADD COLUMN IF NOT EXISTS series_id     INTEGER      REFERENCES match_series(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS is_override   BOOLEAN      NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS cancelled_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS rsvp_opens_at TIMESTAMPTZ;

CREATE INDEX IF NOT EXISTS idx_matches_series
  ON matches (series_id) WHERE series_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_matches_rsvp_window
  ON matches (rsvp_opens_at, match_date) WHERE cancelled_at IS NULL;

-- One materialised match per (series, date).  If a coach ever needs a
-- second instance of a series on the same day, they must create it as
-- a one-off (series_id NULL).
CREATE UNIQUE INDEX IF NOT EXISTS idx_matches_series_date_unique
  ON matches (series_id, match_date) WHERE series_id IS NOT NULL;

COMMIT;
