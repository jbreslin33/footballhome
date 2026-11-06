// frontend/js/game/wire.js
//
// fh-game.v2 binary codec, browser side (game/PROTOCOL.md is the contract;
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
    EVENT: 0x21,
    CLAIM: 0x30,
    SPEED: 0x31,          // admin sets sim speed %; s→c the current speed
    ROSTER: 0x34,
    TEAMS: 0x38,
    RELOAD_ROSTERS: 0x39,
    BRAIN: 0x3B,          // each player's decision, ~5 Hz to watchers
    BRAIN_WATCH: 0x3C,
    BRAIN_LEGEND: 0x3D,
    TEAM_LIST: 0x45,      // 2.1 s→c: every team a match can be made of (a names list)
    NEW_MATCH: 0x46,      // 2.1 c→s admin: a TEAMS payload, names only — kick off that match
    // 2.0 (G5.23) retired with the old brain: 0x32 0x33 0x35-0x37 0x3A 0x3E-0x44.
  };

  const utf8 = new TextDecoder();



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
    // Ball record (protocol 1.1 additive tail).
    const ball = { x: fx(view, p), y: fx(view, p + 8), z: fx(view, p + 16),
                   owner: view.getUint8(p + 24) };
    p += 25;
    // Match structure (1.2 tail): score, period, clock seconds, restart.
    const match = { score0: view.getUint8(p), score1: view.getUint8(p + 1),
                    period: view.getUint8(p + 2),
                    clockSec: view.getUint16(p + 3, true),
                    restartTeam: view.getUint8(p + 5) };
    p += 6;
    // Facing (1.8 tail, G4.53): i8 x | i8 y per player, unit ×127 — the
    // body's facing apart from its velocity (a backpedal faces against it).
    if (p + 2 * count <= view.byteLength) {
      for (let i = 0; i < count; i++) {
        players[i].fx = view.getInt8(p + 2 * i) / 127;
        players[i].fy = view.getInt8(p + 2 * i + 1) / 127;
      }
      p += 2 * count;
    }
    // Officials (1.16 tail, G4.93): u8 count, then per official i64 x |
    // i64 y | i8 face x | i8 face y | u8 flags (bit0 = flag up) — the
    // referee (0) and the assistants (1 on +y, 2 on -y). Not player slots.
    let officials = null;
    if (p + 1 <= view.byteLength) {
      const n = view.getUint8(p); p += 1;
      if (p + 19 * n <= view.byteLength) {
        officials = new Array(n);
        for (let i = 0; i < n; i++) {
          officials[i] = { x: fx(view, p), y: fx(view, p + 8),
                           fx: view.getInt8(p + 16) / 127, fy: view.getInt8(p + 17) / 127,
                           flags: view.getUint8(p + 18) };
          p += 19;
        }
      }
    }
    return { tick, players, ball, match, officials };
  }

  function decodeRoster(view, at, payloadLen) {
    // 2.0: per slot a name; then each slot's position number (9 = the striker).
    const n = view.getUint8(at);
    let p = at + 1;
    const slots = [];
    for (let i = 0; i < n; i++) {
      const len = view.getUint8(p); p += 1;
      const name = utf8.decode(new Uint8Array(view.buffer, view.byteOffset + p, len));
      p += len;
      slots.push({ name });
    }
    if (payloadLen != null && p < at + payloadLen) {
      const c = view.getUint8(p); p += 1;
      for (let i = 0; i < c && i < slots.length; i++) slots[i].number = view.getUint8(p + i) || null;
    }
    return slots;
  }

  // 1.5: the two teams playing (game_demo_teams names), UTF-8.
  function decodeTeams(view, at, payloadLen) {
    let p = at;
    const out = [];
    for (let t = 0; t < 2; t++) {
      const len = view.getUint8(p); p += 1;
      out.push(utf8.decode(new Uint8Array(view.buffer, view.byteOffset + p, len)));
      p += len;
    }
    // G4.31: optional trailing kits — per team shirt/shorts/socks/trim,
    // each u8 present + r g b.
    const kits = [null, null];
    if (payloadLen != null && p + 32 <= at + payloadLen) {
      for (let t = 0; t < 2; t++) {
        const k = {};
        for (const part of ['shirt', 'shorts', 'socks', 'trim']) {
          const on = view.getUint8(p);
          const rgb = (view.getUint8(p + 1) << 16) | (view.getUint8(p + 2) << 8) | view.getUint8(p + 3);
          p += 4;
          if (on) k[part] = rgb;
        }
        kits[t] = k;
      }
    }
    return { home: out[0], away: out[1], kits };
  }

  // 1.5 admin: re-read both teams from the club DB (lineups, attributes…).
  function encodeReloadRosters() {
    return envelope(FrameType.RELOAD_ROSTERS, new ArrayBuffer(0));
  }

  // 2.1 (G5.35) admin: kick off a new match between any two teams.
  function encodeNewMatch(home, away) {
    const enc = new TextEncoder();
    const h = enc.encode(home).slice(0, 60), a = enc.encode(away).slice(0, 60);
    const p = new Uint8Array(2 + h.length + a.length);
    p[0] = h.length; p.set(h, 1);
    p[1 + h.length] = a.length; p.set(a, 2 + h.length);
    return envelope(FrameType.NEW_MATCH, p.buffer);
  }

  function decodeNames(view, at) {
    // A list of names (BRAIN_LEGEND: the decision names, index = why code).
    const n = view.getUint8(at);
    let p = at + 1;
    const names = [];
    for (let i = 0; i < n; i++) {
      const len = view.getUint8(p); p += 1;
      const name = utf8.decode(new Uint8Array(view.buffer, view.byteOffset + p, len));
      p += len;
      names.push(name);
    }
    return names;
  }

  // u8 count, per slot u8 why | i16 target x dm | i16 target y dm | u8 other (255 none).
  function decodeBrain(view, at) {
    const n = view.getUint8(at);
    const out = [];
    let p = at + 1;
    for (let i = 0; i < n; i++) {
      out.push({ why: view.getUint8(p), tx: view.getInt16(p + 1, true) / 10,
                 ty: view.getInt16(p + 3, true) / 10, other: view.getUint8(p + 5) });
      p += 6;
    }
    return out;
  }

  function encodeBrainWatch(on) {
    const p = new ArrayBuffer(1);
    new DataView(p).setUint8(0, on ? 1 : 0);
    return envelope(FrameType.BRAIN_WATCH, p);
  }

  // 1.10 (G4.61): sim speed in % of real time — 100 live, 5 slow motion,
  // 400 fast forward, 0 paused. Same ticks either way.
  function encodeSpeed(pct) {
    const p = new ArrayBuffer(2);
    new DataView(p).setUint16(0, pct, true);
    return envelope(FrameType.SPEED, p);
  }
  function decodeSpeed(view, at) {
    return view.getUint16(at, true);
  }

  function decodeEvent(view, at) {
    return {
      eventType: view.getUint8(at),
      team: view.getUint8(at + 1),
      tick: Number(view.getBigUint64(at + 2, true)),
    };
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

  // action: 0 none, 1 ground kick, 2 lofted kick (PROTOCOL.md §4).
  function encodeIntent(slot, moveX, moveY, action) {
    const p = new ArrayBuffer(18);
    const v = new DataView(p);
    v.setUint8(0, slot);
    v.setBigInt64(1, BigInt(Math.round(moveX * FX)), true);
    v.setBigInt64(9, BigInt(Math.round(moveY * FX)), true);
    v.setUint8(17, action || 0);
    return envelope(FrameType.PLAYER_INTENT, p);
  }

  window.GameWire = {
    FrameType,
    encodeReloadRosters,
    encodeNewMatch,
    decodeTeams,
    encodeSpeed,
    decodeSpeed,
    decodeRoster,
    decodeNames,
    decodeBrain,
    encodeBrainWatch,
    decodeFrame,
    decodeHello,
    decodeSnapshot,
    decodeEvent,
    encodeClaim,
    encodeIntent,
  };
})();
