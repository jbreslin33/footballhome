-- =======================================================================
-- Migration 218 - sim_decode_input: surface Slice 26.2 kick trailer
--
-- Slice 26.2 (ADR §22.23, DESIGN.md §7.3) extended the INPUT wire
-- payload with an optional length-prefixed kick trailer. A well-formed
-- payload is now one of:
--
--   20-byte total frame ([hdr 4][baseline 16]) — byte-identical to M0.
--   32-byte total frame ([hdr 4][baseline 16][u16 trailer_len=10]
--                        [f32 kick_dir_x][f32 kick_dir_y]
--                        [u16 kick_power_hint]).
--
-- The baseline flags byte adds bit 4 = kInputFlagWantsKick, which MUST
-- be set on 32-byte frames and MUST be clear on 20-byte frames.
--
-- This migration teaches the SQL debug decoder the same rules the C++
-- decoder enforces (sim/src/net/InputFrame.cpp @ decodeInputFrame):
--
--   * 20-byte payload  → decode as before; wants_kick=false, kick_*=null
--     (byte-identical to migration 210 output for old rows).
--   * 32-byte payload  → decode baseline PLUS kick trailer; bit 4 MUST
--                        be set; trailer_len MUST equal 10; kick_dir
--                        magnitude squared must land in [0.25, 2.25]
--                        i.e. magnitude in [0.5, 1.5].
--   * anything else    → error (mirrors decoder rejection).
--
-- Additive-only per §22.11 (schema evolution): the returned JSON adds
-- `wants_kick`, `kick_dir_x`, `kick_dir_y`, `kick_power_hint`. Existing
-- callers that only read the M0/M1 keys see identical output for 20-
-- byte rows.
--
-- Migrations 201/209/210 function bodies are NOT amended (migrations
-- are append-only). This file is the source of truth for the current
-- shape of sim_decode_input.
-- =======================================================================

CREATE OR REPLACE FUNCTION sim_decode_input(payload BYTEA)
RETURNS jsonb AS $$
DECLARE
    total       INTEGER;
    version     INTEGER;
    mtype       INTEGER;
    psize       INTEGER;
    client_tick BIGINT;
    dx          REAL;
    dy          REAL;
    flags       INTEGER;
    with_kick   BOOLEAN;
    trailer_len INTEGER;
    kdx         REAL;
    kdy         REAL;
    kick_power  INTEGER;
    kmag2       DOUBLE PRECISION;
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

    -- Slice 26.2: accept both baseline (payload_size=16, total=20) and
    -- kick-trailer (payload_size=28, total=32) frames. Anything else
    -- is malformed.
    IF psize = 16 AND total = 20 THEN
        with_kick := FALSE;
    ELSIF psize = 28 AND total = 32 THEN
        with_kick := TRUE;
    ELSE
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

    -- Enforce the wire contract: wants_kick flag bit (0x10) MUST agree
    -- with the presence of the trailer. Mirrors the C++ decoder's
    -- (di.wants_kick != with_kick) → reject rule.
    IF ((flags & 16) <> 0) <> with_kick THEN
        RETURN jsonb_build_object(
            'error',       'wants_kick flag disagrees with payload size',
            'flags',       flags,
            'payload_size', psize);
    END IF;

    IF with_kick THEN
        trailer_len := get_byte(payload, 20) | (get_byte(payload, 21) << 8);
        IF trailer_len <> 10 THEN
            RETURN jsonb_build_object(
                'error',       'kick trailer_len must be exactly 10',
                'trailer_len', trailer_len);
        END IF;
        kdx        := sim_read_f32_le(payload, 22);
        kdy        := sim_read_f32_le(payload, 26);
        kick_power := get_byte(payload, 30) | (get_byte(payload, 31) << 8);
        kmag2      := (kdx::double precision) * kdx
                    + (kdy::double precision) * kdy;
        IF kmag2 < 0.25 OR kmag2 > 2.25 THEN
            RETURN jsonb_build_object(
                'error',           'kick direction magnitude outside [0.5, 1.5]',
                'kick_dir_x',      kdx,
                'kick_dir_y',      kdy,
                'kick_mag_squared', kmag2);
        END IF;
    END IF;

    RETURN jsonb_build_object(
        'version',         version,
        'msg_type',        mtype,
        'client_tick',     client_tick,
        'dir_x',           dx,
        'dir_y',           dy,
        'flags',           flags,
        'wants_sprint',    (flags &  1) <> 0,
        'wants_walk',      (flags &  2) <> 0,
        'wants_dribble',   (flags &  4) <> 0,   -- Slice 16.2 (bit 2)
        'wants_release',   (flags &  8) <> 0,   -- Slice 16.4 (bit 3)
        'wants_kick',      (flags & 16) <> 0,   -- Slice 26.2 (bit 4)
        'kick_dir_x',      CASE WHEN with_kick THEN to_jsonb(kdx)        ELSE 'null'::jsonb END,
        'kick_dir_y',      CASE WHEN with_kick THEN to_jsonb(kdy)        ELSE 'null'::jsonb END,
        'kick_power_hint', CASE WHEN with_kick THEN to_jsonb(kick_power) ELSE 'null'::jsonb END);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_input(BYTEA) IS
    'Decodes a sim_match_inputs.payload row (either 20-byte M0 baseline INPUT frame or 32-byte Slice 26.2 kick-trailer frame) into a jsonb object. As of migration 218 the returned object surfaces wants_kick (flags bit 4) plus kick_dir_x / kick_dir_y / kick_power_hint (null for baseline rows).';
