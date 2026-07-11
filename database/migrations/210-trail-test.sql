-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 210: Trail Test — Learning Game 1 (TMT-inspired)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Backs the first Tactical Games "learning game": a Trail-Making-Test
-- variant played by dragging a finger (or mouse) across a football
-- pitch drawn on a canvas. See frontend/trail-test.html for the
-- interaction; this migration owns storage.
--
-- Two tables, one purpose each:
--
--   trail_test_results   — one row per COMPLETE Part A + Part B
--                          session. This is the durable, player-facing
--                          record. Every row here is comparable to
--                          every other row of the same variant because
--                          our client enforces:
--                            * A and B played back-to-back in one
--                              session (no lift between the countdown
--                              and Part B).
--                            * Only saved when BOTH parts finish.
--                            * No "resume" — interruption restarts A.
--                          These guarantees keep B-A ("flexibility
--                          cost") a valid measure of task-switching.
--
--   trail_test_attempts  — every session started, complete or not,
--                          with a terminal reason. Player never sees
--                          this table; it exists so WE can answer
--                          product questions like completion rate,
--                          where users quit, whether Part B is too
--                          hard, etc.
--
-- Path geometry is stored as compact JSONB (array of [x,y,tick]
-- triples in pitch-local coordinates) so a coach can later replay a
-- player's route without needing the sim server.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- ----------------------------------------------------------------------
-- 1) Durable results — one row per complete A+B session.
-- ----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trail_test_results (
    id                   BIGSERIAL PRIMARY KEY,
    person_id            INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,

    -- 'kids' = A(1-10), B(1-A-2-B-3-C-4-D-5-E)
    -- 'standard' = A(1-25), B(1-A-...-13)
    variant              TEXT NOT NULL CHECK (variant IN ('kids','standard')),

    -- Seed used to place the circles for this session. Along with
    -- variant this fully reproduces the layout for replay.
    layout_seed          BIGINT NOT NULL,

    -- Raw timings + error counts per part. Times are integer
    -- milliseconds so downstream math is exact (avoids float drift).
    part_a_time_ms       INTEGER NOT NULL CHECK (part_a_time_ms > 0),
    part_a_errors        INTEGER NOT NULL DEFAULT 0 CHECK (part_a_errors >= 0),
    part_b_time_ms       INTEGER NOT NULL CHECK (part_b_time_ms > 0),
    part_b_errors        INTEGER NOT NULL DEFAULT 0 CHECK (part_b_errors >= 0),

    -- Derived: pure cognitive-flexibility cost. Denormalised so
    -- leaderboards and history queries never have to compute it live.
    -- Persisted as GENERATED so it can never disagree with the raw
    -- times.
    flexibility_cost_ms  INTEGER GENERATED ALWAYS AS
                             (part_b_time_ms - part_a_time_ms) STORED,

    -- Path geometry for coach replay. Each is a JSON array of
    -- [x_m, y_m, t_ms] triples in pitch-local coordinates (0..105 m
    -- long, 0..68 m wide). NULL is allowed for future space savings
    -- but v1 always stores paths.
    path_a               JSONB,
    path_b               JSONB,

    -- Optional: client-reported user agent for debugging touch vs
    -- mouse behaviour differences. Not used for scoring.
    client_user_agent    TEXT,

    played_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS trail_test_results_person_played_at_idx
    ON trail_test_results (person_id, played_at DESC);

CREATE INDEX IF NOT EXISTS trail_test_results_variant_time_idx
    ON trail_test_results (variant, part_a_time_ms, part_b_time_ms);

-- ----------------------------------------------------------------------
-- 2) Attempts — every session started, for our product telemetry.
-- ----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trail_test_attempts (
    id                BIGSERIAL PRIMARY KEY,
    person_id         INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    variant           TEXT NOT NULL CHECK (variant IN ('kids','standard')),
    layout_seed       BIGINT NOT NULL,

    -- Where the session ended.
    --   'completed'         — user finished A+B, a matching row exists
    --                          in trail_test_results.
    --   'abandoned_before_a'— started page, never touched circle 1.
    --   'abandoned_in_a'    — lifted / released during Part A.
    --   'abandoned_in_b'    — lifted / released during Part B.
    --   'client_error'      — JS crash / bad state reported by client.
    outcome           TEXT NOT NULL CHECK (outcome IN (
                          'completed',
                          'abandoned_before_a',
                          'abandoned_in_a',
                          'abandoned_in_b',
                          'client_error'
                      )),

    -- Best-effort partial timings for abandoned sessions. Nullable.
    partial_ms        INTEGER,
    partial_errors    INTEGER,
    partial_part      TEXT CHECK (partial_part IN ('a','b') OR partial_part IS NULL),

    client_user_agent TEXT,
    recorded_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS trail_test_attempts_outcome_idx
    ON trail_test_attempts (outcome, recorded_at DESC);

CREATE INDEX IF NOT EXISTS trail_test_attempts_person_idx
    ON trail_test_attempts (person_id, recorded_at DESC);

COMMIT;
