-- =======================================================================
-- Migration 221 - sim_decode_event: surface Slice 28 Goal event
--                                    (ADR §22.25 versioned payload)
--
-- Slice 28.1 lands the first sim_match_events row whose `payload` is
-- versioned in the ADR §22.25 sense:
--
--   event_type = 9 (Goal), payload = 5 bytes:
--     [u8 version]           offset 0     — always 1 in Slice 28
--     [u8 goal_region_index] offset 1     — index into Scenario::goalRegions()
--     [u16 kicker_slot_id]   offset 2..3  — little-endian; 0 = unknown
--     [u8 reserved]          offset 4     — MUST be 0 in v1 emitters
--
-- Convention (ADR §22.25 — read the ADR before touching this file):
--
--   * event_type in (1..8) are GRANDFATHERED UNVERSIONED. Their payload
--     shapes are exactly what migration 201's sim_decode_event() reads.
--     DO NOT retrofit a version byte onto them — MatchEnd's 8-byte hash
--     is memcmp'd by fh-sim-replay --verify, and every existing row
--     would need a rewrite.
--
--   * event_type >= 9 MUST start with a [u8 version] byte at offset 0.
--     Version bumps are APPEND-ONLY per §22.9 style: v2 layout MUST be
--     a strict superset of v1 (add fields at the tail, never rearrange).
--     A schema-breaking change requires a NEW event_type id, not v2.
--
--   * Unknown versions decode as {version:N, payload_hex:'…'} — the
--     decoder never rejects unknown-version rows; ops tooling degrades.
--
-- Migration 201's function body is NOT amended (migrations are
-- append-only per §22.11). This file is the source of truth for the
-- current shape of sim_decode_event() and sim_event_type_name().
--
-- See sim/DESIGN.md §22.25 (this migration's ADR), §24.3 Slice 28.1
-- (implementation slice this migration is part of), §8 (schema).
-- =======================================================================

-- -----------------------------------------------------------------------
-- Add 'Goal' to the event-type name lookup so \x-hex sim_match_events
-- rows show up with a human-readable label in psql.
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
        WHEN 9 THEN 'Goal'            -- Slice 28 (ADR §22.25)
        ELSE NULL
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

COMMENT ON FUNCTION sim_event_type_name(SMALLINT) IS
    'Maps sim_match_events.event_type to a human-readable name. Extended in migration 221 for Goal (9).';

-- -----------------------------------------------------------------------
-- sim_decode_event(event_type, payload)
--
-- Extended in migration 221 to:
--   1. surface Goal (event_type=9) payload per ADR §22.25 v1 layout;
--   2. install the general "event_type >= 9 => payload[0] is a version
--      tag" branch so future versioned event types (10, 11, …) only
--      need a new inner IF block rather than a new outer function.
--
-- Unversioned event_type in (1..8) retain their original migration 201
-- semantics byte-for-byte.
-- -----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION sim_decode_event(event_type SMALLINT, payload BYTEA)
RETURNS jsonb AS $$
DECLARE
    result           jsonb;
    hash_hex         TEXT;
    payload_len      INTEGER;
    version_byte     INTEGER;
    goal_region      INTEGER;
    kicker_slot      INTEGER;
    reserved_byte    INTEGER;
BEGIN
    result := jsonb_build_object(
        'event_type',      event_type,
        'event_type_name', sim_event_type_name(event_type));

    payload_len := COALESCE(octet_length(payload), 0);

    -- ---------------------------------------------------------------
    -- Grandfathered unversioned event types (ADR §22.25).
    -- Migration 201 semantics preserved for event_type in (1..8).
    -- ---------------------------------------------------------------
    IF event_type = 2 THEN   -- MatchEnd
        IF payload IS NULL OR payload_len <> 8 THEN
            result := result || jsonb_build_object(
                'error',        'MatchEnd payload must be 8 bytes',
                'payload_bytes', payload_len);
        ELSE
            hash_hex := encode(payload, 'hex');
            result := result || jsonb_build_object(
                'hash_hex_be', hash_hex,
                'hash_u64',    ('x' || hash_hex)::bit(64)::bigint);
        END IF;
        RETURN result;
    END IF;

    IF event_type BETWEEN 1 AND 8 THEN
        IF payload IS NOT NULL AND payload_len > 0 THEN
            -- Unknown non-empty payload on a grandfathered type — surface
            -- the hex so ops can eyeball it (identical to migration 201).
            result := result || jsonb_build_object(
                'payload_hex', encode(payload, 'hex'));
        END IF;
        RETURN result;
    END IF;

    -- ---------------------------------------------------------------
    -- Versioned event types (event_type >= 9). ADR §22.25 rule:
    -- payload[0] is the version tag; per-event-type branches decode
    -- the remaining bytes according to their version-specific layout.
    -- ---------------------------------------------------------------
    IF event_type < 9 THEN
        -- Impossible given the two IFs above, but keep the guard so a
        -- future refactor can't accidentally route unversioned events
        -- into the versioned branch below.
        result := result || jsonb_build_object(
            'error', 'unhandled event_type in unversioned range');
        RETURN result;
    END IF;

    IF payload IS NULL OR payload_len < 1 THEN
        result := result || jsonb_build_object(
            'error',         'versioned event missing version byte',
            'payload_bytes', payload_len);
        RETURN result;
    END IF;

    version_byte := get_byte(payload, 0);

    -- Goal (event_type = 9) --------------------------------------------------
    IF event_type = 9 THEN
        IF version_byte = 1 THEN
            IF payload_len <> 5 THEN
                result := result || jsonb_build_object(
                    'error',         'Goal v1 payload must be 5 bytes',
                    'version',        1,
                    'payload_bytes',  payload_len,
                    'payload_hex',    encode(payload, 'hex'));
                RETURN result;
            END IF;

            goal_region   := get_byte(payload, 1);
            kicker_slot   := get_byte(payload, 2) | (get_byte(payload, 3) << 8);
            reserved_byte := get_byte(payload, 4);

            result := result || jsonb_build_object(
                'version',            1,
                'goal_region_index',  goal_region,
                'kicker_slot_id',     kicker_slot,
                'kicker_slot_known',  kicker_slot <> 0,
                'reserved',           reserved_byte,
                'payload_hex',        encode(payload, 'hex'));

            IF reserved_byte <> 0 THEN
                -- v1 emitters MUST zero the reserved byte; a nonzero here
                -- means a v2-aware emitter wrote a v1 header. Surface it
                -- so ops notices — do not reject (forward-compat rule).
                result := result || jsonb_build_object(
                    'note', 'reserved byte nonzero — possibly v2 emitter tagged as v1');
            END IF;
            RETURN result;
        END IF;

        -- Unknown Goal version — degrade gracefully per ADR §22.25.
        result := result || jsonb_build_object(
            'version',      version_byte,
            'payload_hex',  encode(payload, 'hex'),
            'note',         'unknown Goal payload version');
        RETURN result;
    END IF;

    -- Future versioned event types (10, 11, …) branch here. Until then,
    -- an unknown versioned event_type surfaces the version + hex so ops
    -- tooling still has something to look at.
    result := result || jsonb_build_object(
        'version',     version_byte,
        'payload_hex', encode(payload, 'hex'),
        'note',        'unknown versioned event type');

    RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;   -- NOT STRICT: payload is legitimately NULL for match-transport events.

COMMENT ON FUNCTION sim_decode_event(SMALLINT, BYTEA) IS
    'Decodes a sim_match_events row (event_type + payload) into a jsonb object. As of migration 221 the function recognises Goal (event_type=9, ADR §22.25 v1 layout: [u8 version][u8 goal_region_index][u16 kicker_slot_id][u8 reserved]) and reserves the event_type >= 9 range for versioned payloads. Grandfathered event_type in (1..8) retain migration 201 semantics.';
