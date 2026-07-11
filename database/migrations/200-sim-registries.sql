-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 200: footballhome_sim — registries, scenarios, profiles,
--                matches, inputs, events + Milestone 0 seed data
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Adds the full DB surface described in sim/DESIGN.md §8 for the tactical
-- simulator. The sim binary loads registries from these tables at startup;
-- matches / inputs / events are populated at runtime.
--
-- Seed data mirrors the M0 constants baked into
-- sim/src/common/M0Attributes.{hpp,cpp}. If you change one, change the
-- other in the same PR — attr_id / concept_id are the wire contract between
-- the C++ code and every PlayerProfile ever persisted.
--
-- See sim/DESIGN.md §5.2, §8, §12.5, §16.2, §16.3.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- -----------------------------------------------------------------------
-- 1) Attribute registry (physical / technical / mental scalars).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_attribute_registry (
    id           SMALLSERIAL PRIMARY KEY,
    key          TEXT UNIQUE NOT NULL,
    category     TEXT NOT NULL,
    weight       REAL NOT NULL DEFAULT 1.0,
    description  TEXT
);

-- -----------------------------------------------------------------------
-- 2) Concept registry (learned skills the player has "plugged in").
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_concept_registry (
    id           SMALLSERIAL PRIMARY KEY,
    key          TEXT UNIQUE NOT NULL,
    category     TEXT NOT NULL,
    weight       REAL NOT NULL DEFAULT 1.0,
    description  TEXT
);

-- -----------------------------------------------------------------------
-- 3) Pattern registry (perception labels; empty in M0, first rows in M4).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_pattern_registry (
    id           SMALLSERIAL PRIMARY KEY,
    key          TEXT UNIQUE NOT NULL,
    category     TEXT NOT NULL,
    description  TEXT
);

-- -----------------------------------------------------------------------
-- 4) Scenarios (metadata only; logic lives in C++).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_scenarios (
    id          SMALLSERIAL PRIMARY KEY,
    code_id     TEXT UNIQUE NOT NULL,
    display     TEXT NOT NULL,
    description TEXT,
    milestone   SMALLINT NOT NULL,
    enabled     BOOLEAN NOT NULL DEFAULT TRUE
);

-- -----------------------------------------------------------------------
-- 5) Player profiles (binary-packed attributes + concepts + recognition).
--    persons.id is INTEGER (SERIAL) in this DB; using INTEGER here to
--    match the FK type exactly (DESIGN.md §8 shows BIGINT aspirationally).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_player_profile (
    person_id    INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    attributes   BYTEA NOT NULL,
    concepts     BYTEA NOT NULL,
    recognition  BYTEA NOT NULL DEFAULT '\x0000'::bytea,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- -----------------------------------------------------------------------
-- 6) Matches. A row per sim session, kept for replay + telemetry.
--    server_version = git sha of the sim binary (recorded for replay
--    compatibility guarantees, §10 rule 7).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_matches (
    id             BIGSERIAL PRIMARY KEY,
    scenario_id    SMALLINT NOT NULL REFERENCES sim_scenarios(id),
    seed           BIGINT NOT NULL,
    tick_hz        SMALLINT NOT NULL,
    server_version TEXT NOT NULL,
    created_by     INTEGER REFERENCES persons(id) ON DELETE SET NULL,
    visibility     SMALLINT NOT NULL DEFAULT 0,   -- 0=public 1=club 2=private
    started_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at       TIMESTAMPTZ,
    result         BYTEA
);
CREATE INDEX IF NOT EXISTS sim_matches_open_idx
    ON sim_matches (ended_at) WHERE ended_at IS NULL;

-- -----------------------------------------------------------------------
-- 7) Per-tick inputs (deterministic replay source).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_match_inputs (
    match_id    BIGINT NOT NULL REFERENCES sim_matches(id) ON DELETE CASCADE,
    tick_num    INTEGER NOT NULL,
    slot_id     SMALLINT NOT NULL,
    payload     BYTEA NOT NULL,
    PRIMARY KEY (match_id, tick_num, slot_id)
);

-- -----------------------------------------------------------------------
-- 8) Semantic events (goals, turnovers, scenario success, slot join/leave).
-- -----------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sim_match_events (
    id         BIGSERIAL PRIMARY KEY,
    match_id   BIGINT NOT NULL REFERENCES sim_matches(id) ON DELETE CASCADE,
    tick_num   INTEGER NOT NULL,
    event_type SMALLINT NOT NULL,
    payload    BYTEA
);
CREATE INDEX IF NOT EXISTS sim_match_events_match_tick_idx
    ON sim_match_events (match_id, tick_num);

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Milestone 0 seed data
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- IDs here MUST match the constants in sim/src/common/M0Attributes.hpp.
-- Written with explicit ids so the SMALLSERIAL sequence stays aligned; the
-- setval at the end bumps the sequence past the last hand-assigned id.
INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (1, 'physical.max_walk_speed',        'physical', 1.0, 'Ceiling m/s while walking'),
    (2, 'physical.max_jog_speed',         'physical', 1.0, 'Ceiling m/s while jogging'),
    (3, 'physical.max_sprint_speed',      'physical', 1.0, 'Ceiling m/s while sprinting'),
    (4, 'physical.acceleration',          'physical', 1.0, 'm/s² when speeding up'),
    (5, 'physical.deceleration',          'physical', 1.0, 'm/s² when slowing down'),
    (6, 'physical.agility',               'physical', 1.0, 'rad/s max heading change rate'),
    (7, 'physical.stamina_max',           'physical', 1.0, 'Stamina pool ceiling'),
    (8, 'physical.stamina_drain_rate',    'physical', 1.0, 'Pool drained /s while sprinting'),
    (9, 'physical.stamina_recovery_rate', 'physical', 1.0, 'Pool restored /s while walk/idle')
ON CONFLICT (key) DO NOTHING;
SELECT setval(
    pg_get_serial_sequence('sim_attribute_registry', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_attribute_registry), 1)
);

INSERT INTO sim_concept_registry (id, key, category, weight, description) VALUES
    (1, 'run_to_point', 'movement', 1.0, 'Move body toward a target position (M0 baseline)')
ON CONFLICT (key) DO NOTHING;
SELECT setval(
    pg_get_serial_sequence('sim_concept_registry', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_concept_registry), 1)
);

-- No pattern rows in M0. First inserts land in the M4 migration (§12.5).

INSERT INTO sim_scenarios (id, code_id, display, description, milestone, enabled) VALUES
    (1, 'empty_pitch', 'Empty Pitch',
     '105×68 m pitch with 12 slots (4×3 grid). One human, eleven wanderers. M0 baseline.',
     0, TRUE)
ON CONFLICT (code_id) DO NOTHING;
SELECT setval(
    pg_get_serial_sequence('sim_scenarios', 'id'),
    GREATEST((SELECT MAX(id) FROM sim_scenarios), 1)
);

COMMIT;
