-- ─────────────────────────────────────────────────────────────────────
-- 289-opponent-logo-cache.sql (2026-08-17)
--
-- Match-event crests on #my fell back to the Lighthouse crest for any
-- opponent without a hand-seeded gcal_opponent_aliases row or an exact
-- teams.name match — which is every real external club we don't
-- already track (e.g. "Real Central NJ", "German American Kickers").
--
-- This table caches a live lookup against TheSportsDb's public team
-- search API, keyed by the opponent text as typed in the gcal
-- description's `Opponent:` tag. logo_url = '' (not NULL) means "we
-- looked and found nothing" — distinguishes "never checked" from
-- "checked, no result" so CalendarController only hits the external
-- API once per distinct opponent name, not on every request.
-- ─────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS opponent_logo_cache (
    id             SERIAL PRIMARY KEY,
    opponent_text  TEXT NOT NULL,
    logo_url       TEXT NOT NULL DEFAULT '',
    source         TEXT,
    fetched_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS opponent_logo_cache_text_idx
    ON opponent_logo_cache (LOWER(BTRIM(opponent_text)));
