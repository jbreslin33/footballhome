// frontend/js/sim/wire.js
//
// fh-sim.v1 wire codec (see sim/DESIGN.md §7). Pure functions, no I/O.
// Little-endian. Byte layouts locked by the C++ WireFormat header —
// keep in sync.
//
//   Frame header (4 bytes): [u8 ver=1][u8 msg_type][u16 payload_len]
//   HELLO_ACK payload (16, Slice 15.4):
//                           [u64 match_id][u16 slot_or_0][u32 tick_hz]
//                           [u16 wire_capability_bits]
//   SNAPSHOT payload (10 + N*30 [+ 2 + 30 optional ball trailer]):
//                           [u32 tick][u32 match_time_ms][u16 num_entities]
//                           [entities...]
//                           [u16 trailer_len][ball region (30 bytes)]?
//   Entity (30):            [u16 slot_id][u16 flags][f32 pos_x][f32 pos_y]
//                           [f32 pos_z][f32 vel_x][f32 vel_y][f32 heading]
//                           [u8 motion][u8 reserved]
//   Ball region (30):       [f32 pos_x][f32 pos_y][f32 pos_z]
//                           [f32 vel_x][f32 vel_y][f32 vel_z]
//                           [f32 spin][u16 owner_slot]
//   INPUT payload (16 baseline, 28 with kick trailer): Slice 26.2 / ADR §22.23
//                           [u32 client_tick][f32 dir_x][f32 dir_y]
//                           [u8 flags][u8 reserved[3]]
//                           [u16 trailer_len=10]                    (kick)
//                           [f32 kick_dir_x][f32 kick_dir_y]        (kick)
//                           [u16 kick_power_hint]                   (kick)

'use strict';

const WIRE_VERSION = 1;

const MSG = Object.freeze({
    HELLO:         0x01,
    HELLO_ACK:     0x02,
    SCENARIO_META: 0x03,   // Slice 17.7a
    SNAPSHOT:      0x10,
    INPUT:         0x20,
    CLAIM_SLOT:    0x30,
    RELEASE_SLOT:  0x31,
    EVENT:         0x40,
    PING:          0x50,
    PONG:          0x51,
});

const ENTITY_FLAG = Object.freeze({
    HUMAN:  0x0001,
    BALL:   0x0002,
    ACTIVE: 0x0004,
});

const INPUT_FLAG = Object.freeze({
    SPRINT: 0x01,
    WALK:   0x02,
    // 0x04, 0x08 reserved.
    // Slice 26.2 (ADR §22.23): bit 4 signals "trailing kick region present".
    // A well-formed 28-byte INPUT payload MUST set this bit; a 16-byte
    // baseline payload MUST NOT.
    KICK:   0x10,
});

const MOTION_STATE = Object.freeze({
    IDLE:   0,
    WALK:   1,
    JOG:    2,
    SPRINT: 3,
});

// Slice 15.4 (§7.1 addendum): wire_capability_bits in HELLO_ACK.
// Bit 0 = server may append the v1.1 ball trailer to SNAPSHOT payloads.
// Bit 1 = server will send one SCENARIO_META frame immediately after
//         HELLO_ACK (Slice 17.7a).
// Bit 2 reserved for Slice 28 MATCH_EVENT frame.
// Bit 3 = server accepts 28-byte INPUT payloads with kick trailer
//         (Slice 26.2 / ADR §22.23). When absent, clients MUST send
//         only 16-byte baseline payloads.
const WIRE_CAP = Object.freeze({
    SNAPSHOT_BALL_TRAILER: 0x0001,
    SCENARIO_META:         0x0002,
    INPUT_KICK_TRAILER:    0x0008,
});

// Slice 17.7a (§7.4): SCENARIO_META mode enum. Wire values are frozen
// in sim/src/net/ScenarioMetaFrame.hpp via static_assert against
// scenario::PlayableArea::Mode — keep in lock-step.
const SCENARIO_MODE = Object.freeze({
    HARD:     0,
    SOFT:     1,
    ADVISORY: 2,
});

// Slice 15.4 (§7.2 addendum): loose-ball sentinel for the ball region's
// owner_slot field. Any player slot < 0xFFFF is a real owner.
const BALL_OWNER_LOOSE = 0xFFFF;

const FRAME_HEADER_BYTES   = 4;
const HELLO_ACK_PAYLOAD    = 16;   // was 14 in M0; +2 for wire_capability_bits
const INPUT_PAYLOAD_BASELINE_BYTES   = 16;
const INPUT_TRAILER_LEN_BYTES        = 2;
const INPUT_KICK_REGION_BYTES        = 10;   // f32 dir_x + f32 dir_y + u16 power
const INPUT_PAYLOAD_WITH_KICK_BYTES  = INPUT_PAYLOAD_BASELINE_BYTES
    + INPUT_TRAILER_LEN_BYTES + INPUT_KICK_REGION_BYTES;   // 28
// Retain the old name for backward compat with any callers that read it.
const INPUT_PAYLOAD_BYTES  = INPUT_PAYLOAD_BASELINE_BYTES;
const KICK_DIR_MIN_MAGNITUDE = 0.5;
const KICK_DIR_MAX_MAGNITUDE = 1.5;
const SNAPSHOT_HEADER      = 10;
const ENTITY_BYTES         = 30;
const SNAPSHOT_TRAILER_LEN_BYTES = 2;   // u16 length prefix
const BALL_REGION_BYTES    = 30;
const SCENARIO_META_HEADER_BYTES = 3;   // u8 mode + u16 count
const SCENARIO_META_VERTEX_BYTES = 8;   // f32 x + f32 y

// ---------------------------------------------------------------------------
// Encoders
// ---------------------------------------------------------------------------

// Encode an INPUT frame (client → server). Returns an ArrayBuffer ready
// to hand to WebSocket.send(). `intent` is:
//   { clientTick: uint32, dirX: number, dirY: number,
//     wantsSprint: bool, wantsWalk: bool,
//     wantsKick?: bool, kickDirX?: number, kickDirY?: number,
//     kickPowerHint?: number }
//
// Slice 26.2 (ADR §22.23): when `intent.wantsKick` is falsy the encoder
// emits a 20-byte frame that is byte-identical to the M0 baseline — this
// preserves determinism goldens. When true, the encoder appends a
// length-prefixed kick region and sets INPUT_FLAG.KICK.
//
// Callers must ensure the server negotiated WIRE_CAP.INPUT_KICK_TRAILER
// via HELLO_ACK; otherwise the server will reject 28-byte payloads.
// Kick direction magnitude must fall in [0.5, 1.5] to be accepted by the
// server-side decoder — the encoder does NOT clamp, so out-of-range values
// will produce frames the server drops.
function encodeInput(intent) {
    const wantsKick = !!intent.wantsKick;
    const payloadBytes = wantsKick
        ? INPUT_PAYLOAD_WITH_KICK_BYTES
        : INPUT_PAYLOAD_BASELINE_BYTES;
    const buf = new ArrayBuffer(FRAME_HEADER_BYTES + payloadBytes);
    const dv  = new DataView(buf);
    dv.setUint8(0, WIRE_VERSION);
    dv.setUint8(1, MSG.INPUT);
    dv.setUint16(2, payloadBytes, /*littleEndian*/ true);
    // Baseline payload (bytes 4..19).
    dv.setUint32(4,  intent.clientTick >>> 0, true);
    dv.setFloat32(8,  intent.dirX,            true);
    dv.setFloat32(12, intent.dirY,            true);
    let flags = 0;
    if (intent.wantsSprint) flags |= INPUT_FLAG.SPRINT;
    if (intent.wantsWalk)   flags |= INPUT_FLAG.WALK;
    if (wantsKick)          flags |= INPUT_FLAG.KICK;
    dv.setUint8(16, flags);
    // bytes 17..19 remain zero
    if (wantsKick) {
        // Kick trailer (bytes 20..31): [u16 trailer_len=10][f32 x][f32 y][u16 power].
        dv.setUint16 (20, INPUT_KICK_REGION_BYTES,  true);
        dv.setFloat32(22, intent.kickDirX || 0,     true);
        dv.setFloat32(26, intent.kickDirY || 0,     true);
        dv.setUint16 (30, (intent.kickPowerHint >>> 0) & 0xFFFF, true);
    }
    return buf;
}

// ---------------------------------------------------------------------------
// Decoders
// ---------------------------------------------------------------------------

// Peek at a raw frame's header. Returns { version, msgType, payloadLen }
// or null if the buffer is too short / has the wrong version.
function peekFrameHeader(bytes) {
    if (!bytes || bytes.byteLength < FRAME_HEADER_BYTES) return null;
    const dv = bytes instanceof DataView ? bytes : new DataView(bytes.buffer || bytes, bytes.byteOffset || 0, bytes.byteLength);
    const version = dv.getUint8(0);
    if (version !== WIRE_VERSION) return null;
    return {
        version,
        msgType:    dv.getUint8(1),
        payloadLen: dv.getUint16(2, true),
    };
}

// Decode a HELLO_ACK message. Returns
//   { matchId (BigInt), slot, tickHz, wireCapabilityBits }
// or null on malformed input. Slice 15.4 widened the payload from 14 -> 16
// bytes to append wire_capability_bits — old M0 servers speaking a 14-byte
// payload will now fail this strict length check, which is intentional:
// the frontend and sim deploy together.
function decodeHelloAck(bytes) {
    const hdr = peekFrameHeader(bytes);
    if (!hdr || hdr.msgType !== MSG.HELLO_ACK) return null;
    if (bytes.byteLength !== FRAME_HEADER_BYTES + HELLO_ACK_PAYLOAD) return null;
    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    return {
        matchId:             dv.getBigUint64(FRAME_HEADER_BYTES + 0,  true),
        slot:                dv.getUint16   (FRAME_HEADER_BYTES + 8,  true),
        tickHz:              dv.getUint32   (FRAME_HEADER_BYTES + 10, true),
        wireCapabilityBits:  dv.getUint16   (FRAME_HEADER_BYTES + 14, true),
    };
}

// Decode a SNAPSHOT message. Returns:
//   { tick, matchTimeMs,
//     entities: [{slotId, flags, posX, posY, posZ,
//                 velX, velY, heading, motion}, ...],
//     ball:     null | { posX, posY, posZ, velX, velY, velZ,
//                        spin, ownerSlot }  }
// or null on malformed input.
//
// Slice 15.4: entities region is player-only. Any bytes remaining after the
// entities region MUST be a well-formed [u16 trailer_len][trailer_len bytes]
// block. If the trailer's ball region is present, `ball` is populated; if
// the trailer is absent (byte-identical to M0) or empty, `ball` is null.
function decodeSnapshot(bytes) {
    const hdr = peekFrameHeader(bytes);
    if (!hdr || hdr.msgType !== MSG.SNAPSHOT) return null;
    if (hdr.payloadLen < SNAPSHOT_HEADER) return null;

    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const base = FRAME_HEADER_BYTES;
    const tick        = dv.getUint32(base + 0, true);
    const matchTimeMs = dv.getUint32(base + 4, true);
    const numEntities = dv.getUint16(base + 8, true);

    const entitiesEnd = SNAPSHOT_HEADER + numEntities * ENTITY_BYTES;
    if (hdr.payloadLen < entitiesEnd) return null;

    const entities = new Array(numEntities);
    let off = base + SNAPSHOT_HEADER;
    for (let i = 0; i < numEntities; ++i) {
        entities[i] = {
            slotId:  dv.getUint16 (off +  0, true),
            flags:   dv.getUint16 (off +  2, true),
            posX:    dv.getFloat32(off +  4, true),
            posY:    dv.getFloat32(off +  8, true),
            posZ:    dv.getFloat32(off + 12, true),
            velX:    dv.getFloat32(off + 16, true),
            velY:    dv.getFloat32(off + 20, true),
            heading: dv.getFloat32(off + 24, true),
            motion:  dv.getUint8  (off + 28),
            // off + 29 = reserved
        };
        off += ENTITY_BYTES;
    }

    // v1.1 ball trailer (§7.2 addendum, Slice 15.4).
    let ball = null;
    const remaining = hdr.payloadLen - entitiesEnd;
    if (remaining !== 0) {
        if (remaining < SNAPSHOT_TRAILER_LEN_BYTES) return null;
        const trailerLen = dv.getUint16(off, true);
        off += SNAPSHOT_TRAILER_LEN_BYTES;
        if (remaining !== SNAPSHOT_TRAILER_LEN_BYTES + trailerLen) return null;
        if (trailerLen !== 0) {
            // Trailer present but < ball region size is malformed for v1.1.
            if (trailerLen < BALL_REGION_BYTES) return null;
            ball = {
                posX:      dv.getFloat32(off +  0, true),
                posY:      dv.getFloat32(off +  4, true),
                posZ:      dv.getFloat32(off +  8, true),
                velX:      dv.getFloat32(off + 12, true),
                velY:      dv.getFloat32(off + 16, true),
                velZ:      dv.getFloat32(off + 20, true),
                spin:      dv.getFloat32(off + 24, true),   // reserved in M1
                ownerSlot: dv.getUint16 (off + 28, true),   // 0xFFFF = loose
            };
            // Bytes [BALL_REGION_BYTES..trailerLen) reserved for future ball
            // fields (e.g. spin axis, temperature) — ignore them; the length
            // prefix is the forward-compat hook.
        }
    }

    return { tick, matchTimeMs, entities, ball };
}

// Decode a SCENARIO_META message (Slice 17.7a, §7.4). Returns:
//   { mode: 0|1|2, vertices: [{x, y}, ...] }
// or null on malformed input. See sim/src/net/ScenarioMetaFrame.cpp for
// the reference C++ decoder — the byte layout must stay byte-identical.
//
// Layout:
//   [frame hdr 4][u8 mode][u16 num_vertices][{f32 x, f32 y} × num_vertices]
//
// An `Advisory + num_vertices=0` message (3-byte payload) is legitimate:
// baseline scenarios (EmptyPitchScenario, BallOnPitchScenario) send this to
// tell the client "no overlay to draw, no clamp behaviour to expect".
function decodeScenarioMeta(bytes) {
    const hdr = peekFrameHeader(bytes);
    if (!hdr || hdr.msgType !== MSG.SCENARIO_META) return null;
    if (hdr.payloadLen < SCENARIO_META_HEADER_BYTES) return null;

    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const base = FRAME_HEADER_BYTES;
    const mode = dv.getUint8(base + 0);
    const numVertices = dv.getUint16(base + 1, true);

    const expectedPayload = SCENARIO_META_HEADER_BYTES
        + numVertices * SCENARIO_META_VERTEX_BYTES;
    if (hdr.payloadLen !== expectedPayload) return null;
    if (bytes.byteLength !== FRAME_HEADER_BYTES + expectedPayload) return null;

    const vertices = new Array(numVertices);
    let off = base + SCENARIO_META_HEADER_BYTES;
    for (let i = 0; i < numVertices; ++i) {
        vertices[i] = {
            x: dv.getFloat32(off + 0, true),
            y: dv.getFloat32(off + 4, true),
        };
        off += SCENARIO_META_VERTEX_BYTES;
    }
    return { mode, vertices };
}

// Export as a global namespace so classic <script> tags can consume it
// without ES-module glue (matches the rest of frontend/js/*).
window.FhSimWire = Object.freeze({
    WIRE_VERSION,
    MSG,
    ENTITY_FLAG,
    INPUT_FLAG,
    MOTION_STATE,
    WIRE_CAP,
    SCENARIO_MODE,
    BALL_OWNER_LOOSE,
    FRAME_HEADER_BYTES,
    HELLO_ACK_PAYLOAD,
    INPUT_PAYLOAD_BYTES,
    INPUT_PAYLOAD_BASELINE_BYTES,
    INPUT_PAYLOAD_WITH_KICK_BYTES,
    INPUT_TRAILER_LEN_BYTES,
    INPUT_KICK_REGION_BYTES,
    KICK_DIR_MIN_MAGNITUDE,
    KICK_DIR_MAX_MAGNITUDE,
    SNAPSHOT_HEADER,
    ENTITY_BYTES,
    SNAPSHOT_TRAILER_LEN_BYTES,
    BALL_REGION_BYTES,
    SCENARIO_META_HEADER_BYTES,
    SCENARIO_META_VERTEX_BYTES,
    encodeInput,
    peekFrameHeader,
    decodeHelloAck,
    decodeSnapshot,
    decodeScenarioMeta,
});
