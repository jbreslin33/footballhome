// frontend/js/sim/interpolator.js
//
// Buffers server SNAPSHOTs and produces a smooth 60 FPS view at any
// wall-clock instant by linearly interpolating between the two most
// recent snapshots.
//
// Approach:
//   * The server ticks at a fixed rate (tick_hz from HELLO_ACK, 20 in M0)
//     so nominal snapshot period = 1000/tick_hz ms.
//   * We time each incoming snapshot with the local receive-clock, then
//     render at (now - renderDelayMs) so we are always looking BACK
//     into the buffered stream. renderDelayMs = ~1.5 tick periods
//     absorbs jitter without an unresponsive feeling on WASD.
//   * If we get more than kMaxBufferedSnapshots we drop the oldest —
//     bounded memory even on a stalled tab.

'use strict';

class FhSimInterpolator {
    constructor(tickHz) {
        this.setTickHz(tickHz || 20);
        this._buf = [];            // { recvAt: ms, snap: {...} }
        this._maxBuffered = 8;     // ~400 ms at 20 Hz
    }

    setTickHz(hz) {
        if (!hz || hz <= 0) hz = 20;
        this._tickPeriodMs = 1000 / hz;
        this._renderDelayMs = this._tickPeriodMs * 1.5;
    }

    pushSnapshot(snap, recvAt) {
        if (!snap) return;
        this._buf.push({ recvAt: recvAt || performance.now(), snap });
        while (this._buf.length > this._maxBuffered) this._buf.shift();
    }

    // Produce an interpolated view for wall-clock `now`. Returns:
    //   { tick, matchTimeMs, entities: [{slotId, flags, posX, posY,
    //                                    velX, velY, heading, motion}, ...] }
    // or null if nothing has arrived yet.
    sample(now) {
        if (this._buf.length === 0) return null;
        if (this._buf.length === 1) return this._buf[0].snap;

        const target = now - this._renderDelayMs;

        // Find the pair [a, b] straddling `target`.
        let a = this._buf[0];
        let b = this._buf[this._buf.length - 1];
        for (let i = 0; i < this._buf.length - 1; ++i) {
            if (this._buf[i + 1].recvAt >= target) {
                a = this._buf[i];
                b = this._buf[i + 1];
                break;
            }
        }
        // Older than everything we have — clamp to newest so movement
        // continues smoothly if the network stalls briefly.
        if (target >= b.recvAt) return b.snap;
        // Newer than everything — before we ever receive, clamp to oldest.
        if (target <= a.recvAt) return a.snap;

        const span = b.recvAt - a.recvAt;
        const t = span > 0 ? (target - a.recvAt) / span : 0;
        return this._blend(a.snap, b.snap, t);
    }

    _blend(a, b, t) {
        // Blend by slotId to survive slot-count changes across snapshots.
        const bySlot = new Map();
        for (const e of a.entities) bySlot.set(e.slotId, { a: e, b: null });
        for (const e of b.entities) {
            const row = bySlot.get(e.slotId);
            if (row) row.b = e;
            else bySlot.set(e.slotId, { a: null, b: e });
        }
        const out = [];
        for (const [, row] of bySlot) {
            if (row.a && row.b) {
                out.push({
                    slotId:  row.b.slotId,
                    flags:   row.b.flags,
                    posX:    row.a.posX + (row.b.posX - row.a.posX) * t,
                    posY:    row.a.posY + (row.b.posY - row.a.posY) * t,
                    posZ:    row.a.posZ + (row.b.posZ - row.a.posZ) * t,
                    velX:    row.b.velX,
                    velY:    row.b.velY,
                    heading: lerpAngle(row.a.heading, row.b.heading, t),
                    motion:  row.b.motion,
                });
            } else if (row.b) {
                out.push({ ...row.b });
            }
            // Entities that vanish are dropped.
        }
        return {
            tick: b.tick,
            matchTimeMs: Math.round(a.matchTimeMs + (b.matchTimeMs - a.matchTimeMs) * t),
            entities: out,
        };
    }
}

function lerpAngle(a, b, t) {
    // Shortest-path angular lerp in radians on (-π, π].
    let diff = b - a;
    while (diff >  Math.PI) diff -= 2 * Math.PI;
    while (diff < -Math.PI) diff += 2 * Math.PI;
    return a + diff * t;
}

window.FhSimInterpolator = FhSimInterpolator;
