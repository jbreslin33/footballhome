-- Migration 214: sim_matches.first_tick_at
--
-- Context (sim/DESIGN.md §21.7 item 2):
--   The load test's §5.5 effective-Hz measurement,
--
--     effective_hz = MAX(sim_match_events.tick_num)
--                    / (ended_at - started_at)
--
--   uses started_at, which is populated by the sim's upsertMatch call
--   at daemon boot BEFORE the tick loop's first iteration. §21.7 item 2
--   step-3 empirically established that under 20-way load the tick
--   loop itself runs at perfect fixed cadence (185,801 ticks / 20
--   daemons with zero catch-up-skips AND zero sub-skip jitter), yet
--   effective_hz shows min=18.84 p50=19.36 max=19.86 vs the §23.4
--   target of 19.9 — the deficit is the ~1.5 s pre-first-tick boot
--   floor (see §21.7 item 1) landing in the denominator against a
--   numerator that only counts ticks the loop actually ran.
--
-- Fix (this migration + companion sim change):
--   Add first_tick_at, a nullable TIMESTAMPTZ. The sim writes it
--   exactly once per match lifetime, on the first tick body, using a
--   `WHERE first_tick_at IS NULL` guard so a crash-restart of the same
--   match_id does NOT bump it (semantics: "when the loop first began
--   ticking this match", not "when the current daemon incarnation
--   started ticking"). §5.5 SQL flips to
--
--     (ended_at - COALESCE(first_tick_at, started_at))
--
--   so pre-migration matches continue to compute against started_at
--   with no regression.
--
-- Why NOT reuse started_at:
--   started_at semantics are "when the sim_matches row was first
--   created", which is a valid product-side signal (e.g. lobby list
--   ordering). Repurposing it would silently mangle any consumer that
--   already reads it. A new column preserves both meanings cleanly.
--
-- Idempotence:
--   IF NOT EXISTS on the column add — safe to re-run against a DB
--   that already has this migration applied.

ALTER TABLE sim_matches
    ADD COLUMN IF NOT EXISTS first_tick_at TIMESTAMPTZ;

COMMENT ON COLUMN sim_matches.first_tick_at IS
    'Wall-clock instant of the first tick body execution for this '
    'match id. Written exactly once per match lifetime by the sim '
    'daemon via updateMatchFirstTick (guard: WHERE first_tick_at IS '
    'NULL, so a crash-restart does not rewrite it). NULL for '
    'pre-migration matches or for matches that never fired a tick. '
    'Used by the load test''s effective-Hz measurement to isolate '
    'steady-state throughput from boot-lag overhead (§21.7 item 2).';
