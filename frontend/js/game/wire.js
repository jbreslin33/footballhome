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
    EVENT: 0x21,
    CLAIM: 0x30,
    MATCH_SETTINGS: 0x32,
    PLAYER_SETTINGS: 0x33,
    ROSTER: 0x34,
    PRESETS: 0x35,
    APPLY_PRESET: 0x36,
    PLAYER_ATTRIBUTES: 0x37,
    TEAMS: 0x38,
    RELOAD_ROSTERS: 0x39,
    CONCEPTS: 0x3A,
    BRAIN: 0x3B,          // G4.41: each player's decision, ~5 Hz to watchers
    BRAIN_WATCH: 0x3C,
    BRAIN_LEGEND: 0x3D,
  };

  // G4.30 attribute order (PROTOCOL 0x37, append-only; G4.52 the body four).
  const ATTRIBUTES = ['pace', 'passing', 'shooting', 'first_touch', 'tackling',
                      'anticipation', 'decisions', 'goalkeeping',
                      'acceleration', 'deceleration', 'agility', 'dribbling'];
  const utf8 = new TextDecoder();

  // Built-in curriculum (ids 0-30); the server's CONCEPTS frame (0x3A,
  // game_concepts) replaces it on connect.
  const CONCEPTS = ['delay', 'marking', 'cover', 'support', 'outlet',
                    'runs', 'over-top', 'sweep', 'placement', 'line-hold',
                    'jockey-angle', 'recover', 'double-team', 'width',
                    'give-and-go', 'push-up', 'counter-press', 'balance',
                    'man-mark', 'verticality', 'intercept', 'restraint',
                    'tackle-timing', 'counter-attack', 'safe-pass',
                    'shot-selection', 'libero', 'cover-shadow', 'line-step',
                    'pass-ladder', 'blind-side-run'];

  const LEVELS = ['perfect', 'u10', 'u14', 'amateur', 'semipro', 'pro', 'world'];

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
                    restartTeam: view.getUint8(p + 5),
                    levelHome: view.getUint8(p + 6),
                    levelAway: view.getUint8(p + 7) };
    return { tick, players, ball, match };
  }

  function decodeRoster(view, at) {
    // 1.4: graded knowledge — per slot a rating byte array + name.
    const n = view.getUint8(at);
    let p = at + 1;
    const slots = [];
    for (let i = 0; i < n; i++) {
      const rc = view.getUint8(p); p += 1;
      const ratings = [];
      for (let k = 0; k < rc; k++) ratings.push(view.getUint8(p + k));
      p += rc;
      const len = view.getUint8(p); p += 1;
      const name = utf8.decode(new Uint8Array(view.buffer, view.byteOffset + p, len));
      p += len;
      slots.push({ ratings, name });
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

  // 1.5 admin: one slot's attributes (ATTRIBUTES order; null = unrated → 255).
  function encodePlayerAttributes(slot, ratings) {
    const p = new ArrayBuffer(2 + ratings.length);
    const v = new DataView(p);
    v.setUint8(0, slot);
    v.setUint8(1, ratings.length);
    ratings.forEach((r, i) => v.setUint8(2 + i, r == null ? 255 : Math.max(0, Math.min(100, r | 0))));
    return envelope(FrameType.PLAYER_ATTRIBUTES, p);
  }

  // 1.5 admin: re-read both teams from the club DB (lineups, attributes…).
  function encodeReloadRosters() {
    return envelope(FrameType.RELOAD_ROSTERS, new ArrayBuffer(0));
  }

  function decodePresets(view, at) {
    // 1.4: style-preset catalog — names only; a preset's id is its index.
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

  // G4.41 (1.7): u8 count, per slot u8 why | i16 target x dm | i16 target
  // y dm | u8 other (255 none) | u8 ladder rung.
  function decodeBrain(view, at) {
    const n = view.getUint8(at);
    const out = [];
    let p = at + 1;
    for (let i = 0; i < n; i++) {
      out.push({ why: view.getUint8(p), tx: view.getInt16(p + 1, true) / 10,
                 ty: view.getInt16(p + 3, true) / 10, other: view.getUint8(p + 5),
                 rung: view.getUint8(p + 6) });
      p += 7;
    }
    return out;
  }

  function encodeBrainWatch(on) {
    const p = new ArrayBuffer(1);
    new DataView(p).setUint8(0, on ? 1 : 0);
    return envelope(FrameType.BRAIN_WATCH, p);
  }

  function encodeApplyPreset(team, presetId) {
    const p = new ArrayBuffer(2);
    const v = new DataView(p);
    v.setUint8(0, team);
    v.setUint8(1, presetId);
    return envelope(FrameType.APPLY_PRESET, p);
  }

  function encodePlayerSettings(slot, ratings) {
    const p = new ArrayBuffer(2 + ratings.length);
    const v = new DataView(p);
    v.setUint8(0, slot);
    v.setUint8(1, ratings.length);
    ratings.forEach((r, i) => v.setUint8(2 + i, Math.max(0, Math.min(100, r | 0))));
    return envelope(FrameType.PLAYER_SETTINGS, p);
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

  function encodeMatchSettings(levelHome, levelAway) {
    const p = new ArrayBuffer(2);
    const v = new DataView(p);
    v.setUint8(0, levelHome);
    v.setUint8(1, levelAway);
    return envelope(FrameType.MATCH_SETTINGS, p);
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
    LEVELS,
    CONCEPTS,
    encodeMatchSettings,
    encodePlayerSettings,
    encodePlayerAttributes,
    encodeReloadRosters,
    decodeTeams,
    ATTRIBUTES,
    encodeApplyPreset,
    decodeRoster,
    decodePresets,
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
