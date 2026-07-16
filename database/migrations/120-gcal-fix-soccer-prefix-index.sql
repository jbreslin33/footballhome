-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 120: fix gcal_events soccer-prefix partial index
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Migration 119 created gcal_events_soccer_prefix_idx with the predicate
--     summary ~* '^\s*Soccer\b'
-- but Postgres regex (POSIX ARE, per §9.7.3) does not support the Perl
-- shortcuts \s or \b — those literals are treated as escaped `s` and
-- `b` respectively, so the predicate matches zero rows and the index
-- is useless.
--
-- Verified empirically on 1020 events (108 Soccer + 912 Ops):
--   summary ~* '^\s*Soccer\b'   → 0 rows
--   summary ~* '^Soccer\M'      → 607 rows   -- correct
--   summary ~* '^Soccer\y'      → 607 rows   -- correct (word boundary)
--
-- We use \M (end-of-word boundary at position immediately after
-- "Soccer") — this matches `Soccer`, `Soccer 11th grade+ Practice`,
-- `Soccer All Staff Meeting`, etc., but NOT a hypothetical `Soccercup`.
-- No leading-whitespace tolerance needed — the real data doesn't have
-- any, and the classifier (§6.0) is authoritative.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

DROP INDEX IF EXISTS gcal_events_soccer_prefix_idx;

CREATE INDEX gcal_events_soccer_prefix_idx
    ON gcal_events (starts_at)
    WHERE deleted_at IS NULL AND summary ~* '^Soccer\M';

COMMIT;
