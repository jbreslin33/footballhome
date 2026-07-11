// frontend/js/sim/renderer.js
//
// Canvas2D renderer for the fh-sim.v1 world.
//
// Coordinate system:
//   World: origin at pitch center, +x = right (along length),
//          +y = up-pitch (toward opponent goal, away from viewer).
//   Canvas: origin at top-left, +x = right, +y = DOWN.
//   Renderer flips Y so world +y maps to canvas -y (i.e. up on screen).
//
// HiDPI: the backing store is scaled to devicePixelRatio; drawing
// commands are all in CSS pixels. resize() is safe to call repeatedly.
//
// The renderer never mutates the snapshot — it only reads.

'use strict';

const PITCH_LEN_M   = 105;
const PITCH_WIDTH_M = 68;

class FhSimRenderer {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx    = canvas.getContext('2d');
        this.dpr    = 1;
        this.cssW   = 0;
        this.cssH   = 0;

        // World → screen scale (pixels per metre). Recomputed on resize.
        this.pxPerM = 1;

        // The slot id owned by this client, if any — highlighted in HUD.
        this.mySlot = 0;

        this.resize();
    }

    setMySlot(slot) { this.mySlot = slot | 0; }

    resize() {
        const rect = this.canvas.getBoundingClientRect();
        const dpr = window.devicePixelRatio || 1;
        const cssW = Math.max(1, Math.floor(rect.width));
        const cssH = Math.max(1, Math.floor(rect.height));
        this.canvas.width  = Math.floor(cssW * dpr);
        this.canvas.height = Math.floor(cssH * dpr);
        this.ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        this.dpr  = dpr;
        this.cssW = cssW;
        this.cssH = cssH;

        // Fit pitch (with padding) into the canvas. 12px padding is a
        // comfortable frame that stops player dots on the touchline
        // from being clipped by the canvas edge.
        const pad = 16;
        const availW = Math.max(1, cssW - pad * 2);
        const availH = Math.max(1, cssH - pad * 2);
        this.pxPerM = Math.min(availW / PITCH_LEN_M, availH / PITCH_WIDTH_M);
    }

    // World-metre → canvas-CSS-pixel.
    _wx(x) { return this.cssW / 2 + x * this.pxPerM; }
    _wy(y) { return this.cssH / 2 - y * this.pxPerM; }

    clear() {
        const ctx = this.ctx;
        ctx.fillStyle = '#0b3d1a';
        ctx.fillRect(0, 0, this.cssW, this.cssH);
    }

    drawPitch() {
        const ctx = this.ctx;
        const L = PITCH_LEN_M / 2;
        const W = PITCH_WIDTH_M / 2;

        // Alternating mown-stripe bands (5m wide) — pure aesthetic.
        const bandStep = 5;
        for (let x = -L; x < L; x += bandStep) {
            const stripe = Math.floor((x + L) / bandStep) % 2;
            ctx.fillStyle = stripe === 0 ? '#0e4620' : '#0b3d1a';
            ctx.fillRect(
                this._wx(x),
                this._wy( W),
                this.pxPerM * bandStep + 1,
                this.pxPerM * PITCH_WIDTH_M
            );
        }

        ctx.strokeStyle = 'rgba(255,255,255,0.85)';
        ctx.lineWidth   = 2;

        // Touchlines
        ctx.strokeRect(this._wx(-L), this._wy( W),
                       PITCH_LEN_M * this.pxPerM, PITCH_WIDTH_M * this.pxPerM);

        // Halfway line
        ctx.beginPath();
        ctx.moveTo(this._wx(0), this._wy( W));
        ctx.lineTo(this._wx(0), this._wy(-W));
        ctx.stroke();

        // Centre circle (9.15 m radius)
        ctx.beginPath();
        ctx.arc(this._wx(0), this._wy(0), 9.15 * this.pxPerM, 0, Math.PI * 2);
        ctx.stroke();

        // Penalty boxes (16.5 m deep × 40.32 m wide)
        const pbDepth = 16.5;
        const pbWidth = 40.32;
        ctx.strokeRect(this._wx(-L),               this._wy( pbWidth / 2),
                       pbDepth * this.pxPerM,       pbWidth * this.pxPerM);
        ctx.strokeRect(this._wx( L - pbDepth),      this._wy( pbWidth / 2),
                       pbDepth * this.pxPerM,       pbWidth * this.pxPerM);

        // Goal boxes (5.5 m deep × 18.32 m wide)
        const gbDepth = 5.5;
        const gbWidth = 18.32;
        ctx.strokeRect(this._wx(-L),               this._wy( gbWidth / 2),
                       gbDepth * this.pxPerM,       gbWidth * this.pxPerM);
        ctx.strokeRect(this._wx( L - gbDepth),      this._wy( gbWidth / 2),
                       gbDepth * this.pxPerM,       gbWidth * this.pxPerM);

        // Centre spot
        ctx.fillStyle = 'rgba(255,255,255,0.85)';
        ctx.beginPath();
        ctx.arc(this._wx(0), this._wy(0), 3, 0, Math.PI * 2);
        ctx.fill();
    }

    drawEntities(snap) {
        if (!snap || !snap.entities) return;
        const ctx = this.ctx;
        const humanColor = '#ffd54a';
        const aiColor    = '#e94a4a';
        const myColor    = '#4ac8ff';

        for (const e of snap.entities) {
            const isHuman = (e.flags & FhSimWire.ENTITY_FLAG.HUMAN) !== 0;
            const isMe    = isHuman && e.slotId === this.mySlot;
            const color   = isMe ? myColor : (isHuman ? humanColor : aiColor);

            const px = this._wx(e.posX);
            const py = this._wy(e.posY);

            // Direction tick (heading vector, 1 m long)
            ctx.strokeStyle = color;
            ctx.lineWidth   = 2;
            ctx.beginPath();
            ctx.moveTo(px, py);
            ctx.lineTo(px + Math.cos(e.heading) * this.pxPerM,
                       py - Math.sin(e.heading) * this.pxPerM);
            ctx.stroke();

            // Player dot
            ctx.fillStyle = color;
            ctx.beginPath();
            ctx.arc(px, py, isMe ? 8 : 6, 0, Math.PI * 2);
            ctx.fill();

            // Slot number label
            ctx.fillStyle = '#000';
            ctx.font = 'bold 10px sans-serif';
            ctx.textAlign    = 'center';
            ctx.textBaseline = 'middle';
            ctx.fillText(String(e.slotId), px, py + 1);
        }
    }

    drawHud(status) {
        const ctx = this.ctx;
        ctx.font = '12px monospace';
        ctx.textAlign    = 'left';
        ctx.textBaseline = 'top';
        ctx.fillStyle    = 'rgba(0,0,0,0.55)';
        ctx.fillRect(8, 8, 240, 74);
        ctx.fillStyle = '#fff';
        const lines = [
            'match: '    + (status.matchId  != null ? status.matchId  : '—'),
            'slot: '     + (status.slot     != null ? status.slot     : '—'),
            'tick: '     + (status.tick     != null ? status.tick     : '—'),
            'clients: '  + (status.clients  != null ? status.clients  : '—') +
                '   ping: ' + (status.pingMs  != null ? status.pingMs.toFixed(0) + 'ms' : '—'),
            'state: '    + (status.state    || '—'),
        ];
        for (let i = 0; i < lines.length; ++i) {
            ctx.fillText(lines[i], 16, 14 + i * 14);
        }
    }

    render(snap, status) {
        this.clear();
        this.drawPitch();
        this.drawEntities(snap);
        this.drawHud(status || {});
    }
}

window.FhSimRenderer = FhSimRenderer;
