-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 201: footballhome_sim — SQL decode helpers
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Deferred function pack from sim/DESIGN.md §8.1. Every gameplay-relevant
-- BYTEA column in the sim schema is opaque without these — the wire
-- format is packed for determinism (§22.4), which means `psql` shows you
-- \x1234 not `{"walk": 2.0}`. These functions bridge that gap:
--
--   sim_decode_attributes(payload)   → TABLE(attr_id, key, category, value)
--   sim_decode_concepts(payload)     → TABLE(concept_id, key, category, value)
--   sim_decode_recognition(payload)  → TABLE(pattern_id, key, category, value)
--   sim_decode_input(payload)        → jsonb  (single wire INPUT frame)
--   sim_decode_event(evt_type, pl)   → jsonb  (single sim_match_events row)
--
-- Used by:
--   * Backend `SimDebugController` (§16.6 sub-slice 8) — planned.
--   * Ops for ad-hoc queries. Example:
--       SELECT tick_num, slot_id, sim_decode_input(payload)
--       FROM sim_match_inputs WHERE match_id = 1 ORDER BY tick_num;
--
-- All functions are `CREATE OR REPLACE ... IMMUTABLE STRICT` — safe to
-- re-run and cache-friendly for the planner. `STRICT` means NULL input
-- yields NULL output, matching Postgres convention.
--
-- Wire formats decoded here MUST stay in lockstep with:
--   * sim/src/profile/PackedU16F32.cpp    (attributes / concepts / recognition)
--   * sim/src/net/InputFrame.cpp          (INPUT wire frame)
--   * sim/src/persistence/EventTypes.hpp  (event_type enum values)
--
-- See sim/DESIGN.md §7 (wire), §8 (schema), §8.1 (this migration's spec),
-- §16.6 sub-slice 7 (planning), §22.4 (bytea rationale).
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

-- -----------------------------------------------------------------------
-- Helper: little-endian 32-bit float reader.
--
-- Reconstructs IEEE-754 single-precision from four consecutive bytes at
-- `off` in `payload`. Uses BIGINT for the intermediate bit-blob to avoid
-- the sign-extension trap that hits INT4 the moment bit 31 is set (a
-- perfectly legal negative or high-exponent finite value would come
-- back garbled). NaN / Inf / subnormal paths handled explicitly so
-- callers don't have to guard against them.
--
-- Returns NULL when the payload is too short (STRICT already covers NULL
-- payload).
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_read_f32_le(payload BYTEA, off INTEGER)
RETURNS REAL AS $$
DECLARE
    bits BIGINT;
    sign INTEGER;
    exp  INTEGER;
    mant INTEGER;
    val  DOUBLE PRECISION;
BEGIN
    IF off < 0 OR (off + 4) > octet_length(payload) THEN
        RETURN NULL;
    END IF;

    bits := get_byte(payload, off)::bigint
          | (get_byte(payload, off + 1)::bigint << 8)
          | (get_byte(payload, off + 2)::bigint << 16)
          | (get_byte(payload, off + 3)::bigint << 24);

    sign := ((bits >> 31) & 1)::integer;
    exp  := ((bits >> 23) & 255)::integer;
    mant := (bits & 8388607)::integer;   -- 2^23 - 1

    IF exp = 0 THEN
        IF mant = 0 THEN
            val := 0.0;
        ELSE
            -- Subnormal: 0.<mantissa> * 2^-126
            val := (mant::double precision / 8388608.0)
                 * power(2.0::double precision, (-126)::double precision);
        END IF;
    ELSIF exp = 255 THEN
        IF mant = 0 THEN
            val := 'infinity'::double precision;
        ELSE
            val := 'nan'::double precision;
        END IF;
    ELSE
        -- Normal: (1 + mant / 2^23) * 2^(exp - 127)
        val := (1.0 + mant::double precision / 8388608.0)
             * power(2.0::double precision, (exp - 127)::double precision);
    END IF;

    IF sign = 1 AND val = val THEN   -- val = val filters NaN so we don't flip its sign
        val := -val;
    END IF;

    RETURN val::real;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_read_f32_le(BYTEA, INTEGER) IS
    'Reads a little-endian IEEE-754 single at byte offset `off` in `payload`. '
    'Returns NULL if the payload does not have 4 bytes available at `off`. '
    'Handles ±0, ±Inf, NaN, and subnormals.';

-- -----------------------------------------------------------------------
-- Helper: event_type enum → human-readable name (see EventTypes.hpp).
--
-- Kept as a lookup function rather than joining a lookup table so this
-- migration file is self-contained — the C++ enum is the authority for
-- these numbers, and adding a table would create a second source of
-- truth (§22.9 style problem).
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_event_type_name(evt_type SMALLINT)
RETURNS TEXT AS $$
BEGIN
    RETURN CASE evt_type
        WHEN 1 THEN 'MatchStart'
        WHEN 2 THEN 'MatchEnd'
        WHEN 3 THEN 'ClientConnect'
        WHEN 4 THEN 'ClientDisconnect'
        WHEN 5 THEN 'SlotClaim'
        WHEN 6 THEN 'SlotRelease'
        WHEN 7 THEN 'ScenarioSuccess'
        WHEN 8 THEN 'ScenarioReset'
        ELSE NULL
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- -----------------------------------------------------------------------
-- sim_decode_attributes(payload)
--
-- Decodes a `PackedU16F32` byte string (see sim/src/profile/PackedU16F32.cpp):
--
--   [u16 n LE]
--   n × [ u16 attr_id LE, f32 value LE ]     -- 6 bytes each
--
-- Returns one row per attribute joined to sim_attribute_registry so the
-- reader gets the key + category alongside the value. Unknown attr_ids
-- (registry drift / stale profile) still surface with NULL key so the
-- reader notices — silent skips would be worse than a visible gap.
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_decode_attributes(payload BYTEA)
RETURNS TABLE(attr_id INTEGER, key TEXT, category TEXT, value REAL) AS $$
DECLARE
    n     INTEGER;
    i     INTEGER;
    aid   INTEGER;
    val   REAL;
    total INTEGER;
BEGIN
    total := octet_length(payload);
    IF total < 2 THEN
        RETURN;
    END IF;

    n := get_byte(payload, 0) | (get_byte(payload, 1) << 8);
    IF total < 2 + n * 6 THEN
        RETURN;      -- truncated payload; decode as much as fits? no, fail loud.
    END IF;

    FOR i IN 0..(n - 1) LOOP
        aid := get_byte(payload, 2 + i * 6)
             | (get_byte(payload, 3 + i * 6) << 8);
        val := sim_read_f32_le(payload, 2 + i * 6 + 2);

        RETURN QUERY
            SELECT aid,
                   r.key,
                   r.category,
                   val
            FROM sim_attribute_registry r
            WHERE r.id = aid::smallint
            UNION ALL
            SELECT aid, NULL::text, NULL::text, val
            WHERE NOT EXISTS (
                SELECT 1 FROM sim_attribute_registry r WHERE r.id = aid::smallint
            );
    END LOOP;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_attributes(BYTEA) IS
    'Decodes a sim_player_profile.attributes bytea into (attr_id, key, category, value) rows.';

-- -----------------------------------------------------------------------
-- sim_decode_concepts(payload)  — same wire format, joins sim_concept_registry.
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_decode_concepts(payload BYTEA)
RETURNS TABLE(concept_id INTEGER, key TEXT, category TEXT, value REAL) AS $$
DECLARE
    n     INTEGER;
    i     INTEGER;
    cid   INTEGER;
    val   REAL;
    total INTEGER;
BEGIN
    total := octet_length(payload);
    IF total < 2 THEN
        RETURN;
    END IF;

    n := get_byte(payload, 0) | (get_byte(payload, 1) << 8);
    IF total < 2 + n * 6 THEN
        RETURN;
    END IF;

    FOR i IN 0..(n - 1) LOOP
        cid := get_byte(payload, 2 + i * 6)
             | (get_byte(payload, 3 + i * 6) << 8);
        val := sim_read_f32_le(payload, 2 + i * 6 + 2);

        RETURN QUERY
            SELECT cid,
                   r.key,
                   r.category,
                   val
            FROM sim_concept_registry r
            WHERE r.id = cid::smallint
            UNION ALL
            SELECT cid, NULL::text, NULL::text, val
            WHERE NOT EXISTS (
                SELECT 1 FROM sim_concept_registry r WHERE r.id = cid::smallint
            );
    END LOOP;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_concepts(BYTEA) IS
    'Decodes a sim_player_profile.concepts bytea into (concept_id, key, category, value) rows.';

-- -----------------------------------------------------------------------
-- sim_decode_recognition(payload) — same wire format, joins sim_pattern_registry.
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_decode_recognition(payload BYTEA)
RETURNS TABLE(pattern_id INTEGER, key TEXT, category TEXT, value REAL) AS $$
DECLARE
    n     INTEGER;
    i     INTEGER;
    pid   INTEGER;
    val   REAL;
    total INTEGER;
BEGIN
    total := octet_length(payload);
    IF total < 2 THEN
        RETURN;
    END IF;

    n := get_byte(payload, 0) | (get_byte(payload, 1) << 8);
    IF total < 2 + n * 6 THEN
        RETURN;
    END IF;

    FOR i IN 0..(n - 1) LOOP
        pid := get_byte(payload, 2 + i * 6)
             | (get_byte(payload, 3 + i * 6) << 8);
        val := sim_read_f32_le(payload, 2 + i * 6 + 2);

        RETURN QUERY
            SELECT pid,
                   r.key,
                   r.category,
                   val
            FROM sim_pattern_registry r
            WHERE r.id = pid::smallint
            UNION ALL
            SELECT pid, NULL::text, NULL::text, val
            WHERE NOT EXISTS (
                SELECT 1 FROM sim_pattern_registry r WHERE r.id = pid::smallint
            );
    END LOOP;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_recognition(BYTEA) IS
    'Decodes a sim_player_profile.recognition bytea into (pattern_id, key, category, value) rows.';

-- -----------------------------------------------------------------------
-- sim_decode_input(payload)
--
-- Decodes ONE wire INPUT frame (§7.3). `sim_match_inputs.payload` stores
-- the full 20-byte wire frame — header + body — exactly as the sim
-- server received it. Layout:
--
--   [u8  version=1]
--   [u8  msg_type=0x20 (Input)]
--   [u16 payload_size=16 LE]
--   ---- 16-byte body ----
--   [u32 client_tick LE]
--   [f32 desired_dir_x LE]
--   [f32 desired_dir_y LE]
--   [u8  flags]                  -- bit 0 = wants_sprint, bit 1 = wants_walk
--   [u8[3] reserved]
--
-- Returns a jsonb object with all decoded fields plus `version` and
-- `msg_type` so a bad row is diagnosable without recomputing bytes by
-- hand. Malformed input yields
-- `{"error": "…", "version": …, "msg_type": …}` so `SELECT`s stay
-- lossless — never NULL, never silent.
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_decode_input(payload BYTEA)
RETURNS jsonb AS $$
DECLARE
    total   INTEGER;
    version INTEGER;
    mtype   INTEGER;
    psize   INTEGER;
    client_tick BIGINT;
    dx      REAL;
    dy      REAL;
    flags   INTEGER;
BEGIN
    total := octet_length(payload);
    IF total < 4 THEN
        RETURN jsonb_build_object(
            'error',         'frame shorter than 4-byte header',
            'payload_bytes', total);
    END IF;

    version := get_byte(payload, 0);
    mtype   := get_byte(payload, 1);
    psize   := get_byte(payload, 2) | (get_byte(payload, 3) << 8);

    IF version <> 1 THEN
        RETURN jsonb_build_object(
            'error',    'unknown wire version',
            'version',  version,
            'msg_type', mtype);
    END IF;
    IF mtype <> 32 THEN   -- MsgType::Input = 0x20 = 32
        RETURN jsonb_build_object(
            'error',    'msg_type is not Input (0x20)',
            'version',  version,
            'msg_type', mtype);
    END IF;
    IF psize <> 16 OR total < 20 THEN
        RETURN jsonb_build_object(
            'error',        'INPUT payload_size mismatch',
            'payload_size', psize,
            'total_bytes',  total);
    END IF;

    client_tick := get_byte(payload,  4)::bigint
                 | (get_byte(payload,  5)::bigint << 8)
                 | (get_byte(payload,  6)::bigint << 16)
                 | (get_byte(payload,  7)::bigint << 24);
    dx    := sim_read_f32_le(payload,  8);
    dy    := sim_read_f32_le(payload, 12);
    flags := get_byte(payload, 16);

    RETURN jsonb_build_object(
        'version',      version,
        'msg_type',     mtype,
        'client_tick',  client_tick,
        'dir_x',        dx,
        'dir_y',        dy,
        'flags',        flags,
        'wants_sprint', (flags & 1) <> 0,
        'wants_walk',   (flags & 2) <> 0);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_input(BYTEA) IS
    'Decodes a sim_match_inputs.payload row (full 20-byte wire INPUT frame) into a jsonb object.';

-- -----------------------------------------------------------------------
-- sim_decode_event(event_type, payload)
--
-- Decodes ONE sim_match_events row. Event payload semantics vary by
-- event_type — see sim/src/persistence/EventTypes.hpp. Currently:
--
--   MatchStart (1)       — no payload
--   MatchEnd   (2)       — 8 bytes big-endian FNV-1a-64 canonical hash
--   ClientConnect (3)    — no payload
--   ClientDisconnect (4) — no payload
--   SlotClaim (5)        — no payload (M0 limitation, see DESIGN §22.13)
--   SlotRelease (6)      — no payload
--   ScenarioSuccess (7)  — M1+ (unrecognized here for now)
--   ScenarioReset (8)    — M1+
--
-- Always returns a jsonb object with at least `event_type` and
-- `event_type_name` so a row is never opaque.
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_decode_event(event_type SMALLINT, payload BYTEA)
RETURNS jsonb AS $$
DECLARE
    result jsonb;
    hash_hex TEXT;
BEGIN
    result := jsonb_build_object(
        'event_type',      event_type,
        'event_type_name', sim_event_type_name(event_type));

    IF event_type = 2 THEN   -- MatchEnd
        IF payload IS NULL OR octet_length(payload) <> 8 THEN
            result := result || jsonb_build_object(
                'error',        'MatchEnd payload must be 8 bytes',
                'payload_bytes', COALESCE(octet_length(payload), 0));
        ELSE
            hash_hex := encode(payload, 'hex');
            result := result || jsonb_build_object(
                'hash_hex_be', hash_hex,
                'hash_u64',    ('x' || hash_hex)::bit(64)::bigint);
        END IF;
    ELSIF payload IS NOT NULL AND octet_length(payload) > 0 THEN
        -- Unknown non-empty payload: surface the hex so ops can eyeball it.
        result := result || jsonb_build_object(
            'payload_hex', encode(payload, 'hex'));
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;   -- NOT STRICT: payload is legitimately NULL for most event types.

COMMENT ON FUNCTION sim_decode_event(SMALLINT, BYTEA) IS
    'Decodes a sim_match_events row (event_type + payload) into a jsonb object. Payload semantics vary by event_type.';

COMMIT;
