// frontend/js/sim/wire.js
//
// fh-sim.v1 wire codec (see sim/DESIGN.md §7). Pure functions, no I/O.
// Little-endian. Byte layouts locked by the C++ WireFormat header —
// keep in sync.
//
//   Frame header (4 bytes): [u8 ver=1][u8 msg_type][u16 payload_len]
//   HELLO_ACK payload (14): [u64 match_id][u16 slot_or_0][u32 tick_hz]
//   SNAPSHOT payload (10 + N*30):
//                           [u32 tick][u32 match_time_ms][u16 num_entities]
//                           [entities...]
//   Entity (30):            [u16 slot_id][u16 flags][f32 pos_x][f32 pos_y]
//                           [f32 pos_z][f32 vel_x][f32 vel_y][f32 heading]
//                           [u8 motion][u8 reserved]
//   INPUT payload (16):     [u32 client_tick][f32 dir_x][f32 dir_y]
//                           [u8 flags][u8 reserved[3]]

'use strict';

const WIRE_VERSION = 1;

const MSG = Object.freeze({
    HELLO:        0x01,
    HELLO_ACK:    0x02,
    SNAPSHOT:     0x10,
    INPUT:        0x20,
    CLAIM_SLOT:   0x30,
    RELEASE_SLOT: 0x31,
    EVENT:        0x40,
    PING:         0x50,
    PONG:         0x51,
});

const ENTITY_FLAG = Object.freeze({
    HUMAN:  0x0001,
    BALL:   0x0002,
    ACTIVE: 0x0004,
});

const INPUT_FLAG = Object.freeze({
    SPRINT: 0x01,
    WALK:   0x02,
});

const MOTION_STATE = Object.freeze({
    IDLE:   0,
    WALK:   1,
    JOG:    2,
    SPRINT: 3,
});

const FRAME_HEADER_BYTES   = 4;
const HELLO_ACK_PAYLOAD    = 14;
const INPUT_PAYLOAD_BYTES  = 16;
const SNAPSHOT_HEADER      = 10;
const ENTITY_BYTES         = 30;

// ---------------------------------------------------------------------------
// Encoders
// ---------------------------------------------------------------------------

// Encode an INPUT frame (client → server). Returns an ArrayBuffer ready
// to hand to WebSocket.send(). `intent` is:
//   { clientTick: uint32, dirX: number, dirY: number,
//     wantsSprint: bool, wantsWalk: bool }
function encodeInput(intent) {
    const buf = new ArrayBuffer(FRAME_HEADER_BYTES + INPUT_PAYLOAD_BYTES);
    const dv  = new DataView(buf);
    dv.setUint8(0, WIRE_VERSION);
    dv.setUint8(1, MSG.INPUT);
    dv.setUint16(2, INPUT_PAYLOAD_BYTES, /*littleEndian*/ true);
    // payload
    dv.setUint32(4,  intent.clientTick >>> 0, true);
    dv.setFloat32(8,  intent.dirX,            true);
    dv.setFloat32(12, intent.dirY,            true);
    let flags = 0;
    if (intent.wantsSprint) flags |= INPUT_FLAG.SPRINT;
    if (intent.wantsWalk)   flags |= INPUT_FLAG.WALK;
    dv.setUint8(16, flags);
    // bytes 17..19 remain zero
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

// Decode a HELLO_ACK message. Returns { matchId (BigInt), slot, tickHz }
// or null on malformed input.
function decodeHelloAck(bytes) {
    const hdr = peekFrameHeader(bytes);
    if (!hdr || hdr.msgType !== MSG.HELLO_ACK) return null;
    if (bytes.byteLength !== FRAME_HEADER_BYTES + HELLO_ACK_PAYLOAD) return null;
    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    return {
        matchId: dv.getBigUint64(FRAME_HEADER_BYTES + 0,  true),
        slot:    dv.getUint16   (FRAME_HEADER_BYTES + 8,  true),
        tickHz:  dv.getUint32   (FRAME_HEADER_BYTES + 10, true),
    };
}

// Decode a SNAPSHOT message. Returns:
//   { tick, matchTimeMs, entities: [{slotId, flags, posX, posY, posZ,
//                                     velX, velY, heading, motion}, ...] }
// or null on malformed input.
function decodeSnapshot(bytes) {
    const hdr = peekFrameHeader(bytes);
    if (!hdr || hdr.msgType !== MSG.SNAPSHOT) return null;
    if (hdr.payloadLen < SNAPSHOT_HEADER) return null;

    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    const base = FRAME_HEADER_BYTES;
    const tick        = dv.getUint32(base + 0, true);
    const matchTimeMs = dv.getUint32(base + 4, true);
    const numEntities = dv.getUint16(base + 8, true);

    const expected = SNAPSHOT_HEADER + numEntities * ENTITY_BYTES;
    if (hdr.payloadLen !== expected) return null;

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
    return { tick, matchTimeMs, entities };
}

// Export as a global namespace so classic <script> tags can consume it
// without ES-module glue (matches the rest of frontend/js/*).
window.FhSimWire = Object.freeze({
    WIRE_VERSION,
    MSG,
    ENTITY_FLAG,
    INPUT_FLAG,
    MOTION_STATE,
    FRAME_HEADER_BYTES,
    HELLO_ACK_PAYLOAD,
    INPUT_PAYLOAD_BYTES,
    SNAPSHOT_HEADER,
    ENTITY_BYTES,
    encodeInput,
    peekFrameHeader,
    decodeHelloAck,
    decodeSnapshot,
});
