-- =======================================================================
-- Migration 209 - sim_decode_input: surface bit 2 (wants_dribble)
--
-- Slice 16.2 added `kInputFlagWantsDribble = 1u << 2` to the INPUT wire
-- payload flags byte (see sim/src/net/InputFrame.hpp, DESIGN.md §7.3).
-- The C++ decoder already masks bit 2 into DecodedInput.wants_dribble;
-- this migration teaches the debug/replay-facing SQL decoder the same
-- trick so `SELECT sim_decode_input(payload)` on stored input frames
-- shows the dribble intent alongside sprint/walk.
--
-- No table changes, no data changes — CREATE OR REPLACE FUNCTION only.
-- Old rows decode identically to before: bit 2 in a legacy frame was
-- guaranteed 0 by the previous C++ encoder, so `wants_dribble` will
-- simply come back false for anything captured before Slice 16.2.
--
-- Additive-only per §22.11 (schema evolution): the returned JSON adds
-- a `wants_dribble` key; existing consumers that only read
-- `wants_sprint`/`wants_walk` see no change.
--
-- Comment on migration 201's function body is intentionally NOT amended
-- (migrations are append-only). This file is the source of truth for
-- the current shape of sim_decode_input.
-- =======================================================================

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
        'version',       version,
        'msg_type',      mtype,
        'client_tick',   client_tick,
        'dir_x',         dx,
        'dir_y',         dy,
        'flags',         flags,
        'wants_sprint',  (flags & 1) <> 0,
        'wants_walk',    (flags & 2) <> 0,
        'wants_dribble', (flags & 4) <> 0);   -- Slice 16.2 (bit 2)
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_input(BYTEA) IS
    'Decodes a sim_match_inputs.payload row (full 20-byte wire INPUT frame) into a jsonb object. As of migration 209 (Slice 16.2), the returned object includes wants_dribble (flags bit 2) alongside wants_sprint (bit 0) and wants_walk (bit 1).';
