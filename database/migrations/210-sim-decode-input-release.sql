-- =======================================================================
-- Migration 210 - sim_decode_input: surface bit 3 (wants_release)
--
-- Slice 16.4 added `kInputFlagWantsRelease = 1u << 3` to the INPUT wire
-- payload flags byte (see sim/src/net/InputFrame.hpp, DESIGN.md §7.3,
-- §23.3 Slice 16.4). The C++ decoder masks bit 3 into
-- DecodedInput.wants_release; this migration teaches the debug/replay-
-- facing SQL decoder the same trick so `SELECT sim_decode_input(payload)`
-- on stored input frames shows the release intent alongside
-- sprint/walk/dribble.
--
-- No table changes, no data changes — CREATE OR REPLACE FUNCTION only.
-- Old rows decode identically to before: bit 3 in a legacy frame was
-- guaranteed 0 by every pre-Slice-16.4 C++ encoder, so `wants_release`
-- will simply come back false for anything captured before Slice 16.4.
--
-- Additive-only per §22.11 (schema evolution): the returned JSON adds a
-- `wants_release` key; existing consumers that only read
-- `wants_sprint`/`wants_walk`/`wants_dribble` see no change.
--
-- Migration 201 + 209 function bodies are intentionally NOT amended
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
        'wants_dribble', (flags & 4) <> 0,    -- Slice 16.2 (bit 2)
        'wants_release', (flags & 8) <> 0);   -- Slice 16.4 (bit 3)
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_decode_input(BYTEA) IS
    'Decodes a sim_match_inputs.payload row (full 20-byte wire INPUT frame) into a jsonb object. As of migration 210 (Slice 16.4), the returned object includes wants_release (flags bit 3) alongside wants_dribble (bit 2), wants_sprint (bit 0) and wants_walk (bit 1).';
