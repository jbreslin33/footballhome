// frontend/js/game/wire.js
//
// fh-game.v1 binary codec, browser side (game/PROTOCOL.md is the contract;
// this mirrors the layouts locked in G0.3). Little-endian throughout.
//
// Fixed64 (Q32.32) raw values cross the wire as i64. The sim's determinism
// lives server-side only, so the client may convert to JS floats freely —
// rendering is cosmetic dressing over authoritative state (DESIGN.md §2).

(function () {
  'use strict';

  const FX = 4294967296; // 2^32

  const FrameType = {
    HELLO: 0x01,
    GOODBYE: 0x02,
    PLAYER_INTENT: 0x10,
    SNAPSHOT: 0x20,
    CLAIM: 0x30,
  };

  // i64 raw (Q32.32) → JS float. BigInt keeps 64-bit exactness before the
  // one deliberate float conversion at the boundary.
  function fx(view, at) {
    return Number(view.getBigInt64(at, true)) / FX;
  }

  function decodeFrame(buf) {
    // One WebSocket message = one or more envelope frames.
    const view = new DataView(buf);
    const frames = [];
    let at = 0;
    while (at + 4 <= buf.byteLength) {
      const len = view.getUint16(at, true);
      const type = view.getUint8(at + 2);
      if (at + 4 + len > buf.byteLength) break; // truncated tail: stop
      frames.push({ type, payloadAt: at + 4, payloadLen: len });
      at += 4 + len;
    }
    return frames;
  }

  function decodeHello(view, at) {
    return {
      major: view.getUint8(at),
      minor: view.getUint8(at + 1),
      patch: view.getUint8(at + 2),
      matchId: Number(view.getBigUint64(at + 3, true)),
      tickRate: view.getUint8(at + 11),
      capabilities: view.getUint8(at + 12),
      slotCount: view.getUint8(at + 13),
      pitchHalfX: fx(view, at + 14),
      pitchHalfY: fx(view, at + 22),
    };
  }

  function decodeSnapshot(view, at) {
    const tick = Number(view.getBigUint64(at, true));
    const count = view.getUint8(at + 8);
    const players = new Array(count);
    let p = at + 9;
    for (let i = 0; i < count; i++) {
      players[i] = {
        x: fx(view, p),
        y: fx(view, p + 8),
        vx: fx(view, p + 16),
        vy: fx(view, p + 24),
        flags: view.getUint8(p + 32),
      };
      p += 33;
    }
    return { tick, players };
  }

  // ── encoders (client → server) ────────────────────────────────────────

  function envelope(type, payload) {
    const buf = new ArrayBuffer(4 + payload.byteLength);
    const view = new DataView(buf);
    view.setUint16(0, payload.byteLength, true);
    view.setUint8(2, type);
    view.setUint8(3, 0);
    new Uint8Array(buf, 4).set(new Uint8Array(payload));
    return buf;
  }

  function encodeClaim(slot, claim) {
    const p = new ArrayBuffer(2);
    const v = new DataView(p);
    v.setUint8(0, slot);
    v.setUint8(1, claim ? 1 : 0);
    return envelope(FrameType.CLAIM, p);
  }

  function encodeIntent(slot, moveX, moveY) {
    const p = new ArrayBuffer(18);
    const v = new DataView(p);
    v.setUint8(0, slot);
    v.setBigInt64(1, BigInt(Math.round(moveX * FX)), true);
    v.setBigInt64(9, BigInt(Math.round(moveY * FX)), true);
    v.setUint8(17, 0); // action: none (G0)
    return envelope(FrameType.PLAYER_INTENT, p);
  }

  window.GameWire = {
    FrameType,
    decodeFrame,
    decodeHello,
    decodeSnapshot,
    encodeClaim,
    encodeIntent,
  };
})();
