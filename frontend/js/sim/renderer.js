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
// Slice 25.1 camera model: the visible region is a (viewportLenM,
// viewportWidM) rectangle centered on (focusX, focusY) in world metres.
// Aspect ratio always matches the pitch (viewportWidM = viewportLenM *
// PITCH_ASPECT). Ball-less scenarios (EmptyPitch, HalfPitch, SoftDrill)
// use the full pitch (viewportLenM = 105). Ball scenarios zoom to
// VIEWPORT_ZOOM_LEN_M (40 m) and follow the client's own slot — this
// makes sprint speed *feel* correct (7.5 m/s crosses the visible frame
// in ~5 s) while the underlying physics is unchanged and 100 %
// realistic. Player and ball are drawn at their real physical radii
// (0.25 m and 0.11 m respectively) with a minimum pixel clamp so they
// remain legible when the camera zooms out.
//
// The renderer never mutates the snapshot — it only reads.

'use strict';

const PITCH_LEN_M   = 105;
const PITCH_WIDTH_M = 68;
const PITCH_ASPECT  = PITCH_WIDTH_M / PITCH_LEN_M;

// Slice 25.1: real physical radii for realistic on-pitch proportions.
// Player footprint ≈ 0.5 m Ø (shoulder width top-down); regulation ball
// = 0.22 m Ø. Min-pixel clamps keep them visible when the camera is
// zoomed all the way out to the full 105 × 68 pitch.
const PLAYER_RADIUS_M = 0.25;
const BALL_RADIUS_M   = 0.11;
const PLAYER_MIN_PX   = 4;
const BALL_MIN_PX     = 3;

// Slice 25.1: viewport lengths. Ball scenarios zoom to VIEWPORT_ZOOM
// so a real-scale sprint (7.5 m/s) crosses the visible frame in ~5 s
// and the player dot looks correctly proportioned relative to the
// pitch markings. Ball-less scenarios (M0 wander demos) keep the
// classic fit-whole-pitch camera.
const VIEWPORT_FULL_LEN_M = PITCH_LEN_M;   // 105 m
const VIEWPORT_ZOOM_LEN_M = 40;            // ~ half penalty area to half-way line

class FhSimRenderer {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx    = canvas.getContext('2d');
        this.dpr    = 1;
        this.cssW   = 0;
        this.cssH   = 0;

        // Slice 25.1: camera state — viewport size + world-space focus.
        // Recomputed every render() via _updateCamera() so viewport
        // changes (ball scenarios auto-zoom) and focus tracking (follow
        // this.mySlot when present) happen in one place.
        this.viewportLenM = VIEWPORT_FULL_LEN_M;
        this.focusX       = 0;
        this.focusY       = 0;

        // World → screen scale (pixels per metre). Recomputed on resize
        // and by _updateCamera() when the viewport changes.
        this.pxPerM = 1;

        // The slot id owned by this client, if any — highlighted in HUD
        // AND used by _updateCamera() as the primary follow target.
        this.mySlot = 0;

        // Slice 17.7b: SCENARIO_META polygon overlay. Null until the
        // server sends a SCENARIO_META frame right after HELLO_ACK.
        // Shape: { mode: 0|1|2, vertices: [{x,y}, ...] } — see wire.js
        // decodeScenarioMeta. drawPlayableArea() no-ops on null / <3
        // vertices (Advisory + empty polygon is the M0 baseline).
        this.scenarioMeta = null;

        this.resize();
    }

    setMySlot(slot) { this.mySlot = slot | 0; }

    setScenarioMeta(meta) {
        // Accept null explicitly (unset). Anything else stored verbatim;
        // renderer reads mode + vertices at draw time.
        this.scenarioMeta = meta || null;
    }

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

        this._recomputePxPerM();
    }

    // Slice 25.1: shared scale-recompute used by both resize() (canvas
    // dimensions change) and _updateCamera() (viewport length changes).
    // 16 px padding keeps player dots on the touchline from being
    // clipped by the canvas edge.
    _recomputePxPerM() {
        const pad = 16;
        const availW = Math.max(1, this.cssW - pad * 2);
        const availH = Math.max(1, this.cssH - pad * 2);
        const viewWidM = this.viewportLenM * PITCH_ASPECT;
        this.pxPerM = Math.min(availW / this.viewportLenM,
                               availH / viewWidM);
    }

    // Slice 25.1: pick viewport length + focus point from the current
    // snapshot. Called once per render() before any drawing so all
    // downstream _wx/_wy calls see a consistent camera.
    //
    // Default policy (learning-mode friendly): ALWAYS show the whole
    // pitch, centered on origin, no scrolling. Real-scale physics on a
    // fixed camera is the right teaching view — you see the whole
    // field, players are small dots labelled with floating chips (see
    // drawEntities "auto-hoist"), and the ball is proportionally
    // smaller than the players. No motion the human eye has to chase.
    //
    // The camera *state* (viewportLenM, focusX, focusY) and the clamp
    // logic below are kept as first-class so a future HUD toggle /
    // scenario request can opt into a smaller viewport ("half pitch",
    // "penalty area drill") or follow-cam without any wire changes.
    // Today nothing sets those overrides, so the branch below is dead
    // code — but it's the right shape for when it's needed.
    _updateCamera(snap) {
        // Fixed camera: fit the whole pitch, focus on the centre spot.
        // No auto-zoom based on snap.ball. No follow-cam based on
        // this.mySlot. See method header for rationale.
        this.viewportLenM = VIEWPORT_FULL_LEN_M;
        this.focusX       = 0;
        this.focusY       = 0;
        this._recomputePxPerM();

        // --- OPT-IN FOLLOW-CAM (unused today) --------------------------
        // Future: gate the following block on e.g. this.followCam and
        // pick focus from mySlot/ball. Preserved verbatim so re-enabling
        // is a two-line change, not a re-derivation.
        //
        //   const hasBall = !!(snap && snap.ball);
        //   this.viewportLenM = hasBall ? VIEWPORT_ZOOM_LEN_M : VIEWPORT_FULL_LEN_M;
        //   let fx = 0, fy = 0, focused = false;
        //   if (this.mySlot > 0 && snap && snap.entities) {
        //     for (const e of snap.entities) {
        //       if (e.slotId === this.mySlot) { fx = e.posX; fy = e.posY; focused = true; break; }
        //     }
        //   }
        //   if (!focused && hasBall) { fx = snap.ball.posX; fy = snap.ball.posY; }
        //   const halfViewLen  = this.viewportLenM / 2;
        //   const halfViewWid  = (this.viewportLenM * PITCH_ASPECT) / 2;
        //   const halfPitchLen = PITCH_LEN_M / 2;
        //   const halfPitchWid = PITCH_WIDTH_M / 2;
        //   if (halfViewLen >= halfPitchLen) fx = 0;
        //   else fx = Math.max(-halfPitchLen + halfViewLen, Math.min(halfPitchLen - halfViewLen, fx));
        //   if (halfViewWid >= halfPitchWid) fy = 0;
        //   else fy = Math.max(-halfPitchWid + halfViewWid, Math.min(halfPitchWid - halfViewWid, fy));
        //   this.focusX = fx; this.focusY = fy;
        //   this._recomputePxPerM();
    }

    // World-metre → canvas-CSS-pixel (Slice 25.1: relative to camera
    // focus so any world point translates through the viewport).
    _wx(x) { return this.cssW / 2 + (x - this.focusX) * this.pxPerM; }
    _wy(y) { return this.cssH / 2 - (y - this.focusY) * this.pxPerM; }

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

    // Slice 17.7b: draw the scenario's playable-area polygon as a
    // mode-specific line-dash overlay on top of the pitch. Drawn AFTER
    // drawPitch() (so it sits over the mown stripes) and BEFORE
    // drawEntities() / drawBall() (so player + ball dots stay on top
    // and remain legible). No-ops when:
    //   * setScenarioMeta() never got a frame (this.scenarioMeta null)
    //   * polygon has < 3 vertices (M0 baseline: Advisory + empty)
    //
    // Line style by mode (see FhSimWire.SCENARIO_MODE):
    //   HARD (0)     → solid warm red — server clamps position AND
    //                  zeros outward velocity every tick; visually a
    //                  hard wall.
    //   SOFT (1)     → dotted cyan — server applies inward velocity
    //                  delta proportional to penetration depth;
    //                  visually a springy fence.
    //   ADVISORY (2) → dashed faint yellow — server does NOT constrain
    //                  motion; overlay is purely informational (e.g.
    //                  "drill zone" hint for the user).
    drawPlayableArea() {
        const meta = this.scenarioMeta;
        if (!meta || !meta.vertices || meta.vertices.length < 3) return;

        const ctx = this.ctx;
        ctx.save();
        switch (meta.mode) {
            case FhSimWire.SCENARIO_MODE.HARD:
                ctx.strokeStyle = 'rgba(255, 90, 60, 0.95)';
                ctx.setLineDash([]);          // solid
                ctx.lineWidth = 3;
                break;
            case FhSimWire.SCENARIO_MODE.SOFT:
                ctx.strokeStyle = 'rgba(90, 210, 255, 0.9)';
                ctx.setLineDash([2, 6]);      // dotted (short dash + long gap)
                ctx.lineWidth = 2.5;
                break;
            case FhSimWire.SCENARIO_MODE.ADVISORY:
            default:
                ctx.strokeStyle = 'rgba(255, 220, 90, 0.7)';
                ctx.setLineDash([10, 6]);     // dashed
                ctx.lineWidth = 2;
                break;
        }
        ctx.beginPath();
        const v0 = meta.vertices[0];
        ctx.moveTo(this._wx(v0.x), this._wy(v0.y));
        for (let i = 1; i < meta.vertices.length; ++i) {
            const v = meta.vertices[i];
            ctx.lineTo(this._wx(v.x), this._wy(v.y));
        }
        ctx.closePath();
        ctx.stroke();
        ctx.restore();
    }

    drawEntities(snap) {
        if (!snap || !snap.entities) return;
        const ctx = this.ctx;
        const humanColor = '#ffd54a';
        const aiColor    = '#e94a4a';
        const myColor    = '#4ac8ff';

        // Slice 16.5: which slot currently owns the ball? Wire trailer
        // reports 0xFFFF for a loose ball; anything else is the owning
        // player's SlotId. When a match has no ball trailer at all
        // (`snap.ball === null`), no ring is ever drawn.
        const ownerSlot = (snap.ball &&
                           snap.ball.ownerSlot !== FhSimWire.BALL_OWNER_LOOSE)
                          ? snap.ball.ownerSlot
                          : null;

        // Slice 25.1: real-scale player marker. Radius is the actual
        // physical footprint (0.25 m) converted through the current
        // camera scale, clamped to PLAYER_MIN_PX so the dot never
        // vanishes on the full-pitch view. "Self" gets a +2 px bump
        // so the client's own player pops even at real scale.
        const geomPlayerR = PLAYER_RADIUS_M * this.pxPerM;
        const basePlayerR = Math.max(PLAYER_MIN_PX, geomPlayerR);

        for (const e of snap.entities) {
            const isHuman = (e.flags & FhSimWire.ENTITY_FLAG.HUMAN) !== 0;
            const isMe    = isHuman && e.slotId === this.mySlot;
            const color   = isMe ? myColor : (isHuman ? humanColor : aiColor);

            const px = this._wx(e.posX);
            const py = this._wy(e.posY);
            const dotR = isMe ? basePlayerR + 2 : basePlayerR;

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
            ctx.arc(px, py, dotR, 0, Math.PI * 2);
            ctx.fill();

            // Slice 16.5: owner ring. Drawn UNDER the slot label but
            // OVER the player dot. Purely cosmetic — the ownership
            // truth lives on the server; the client just renders it.
            // Ring is offset outside the player dot so a self-owned
            // ball doesn't visually merge with the "me" cyan dot.
            if (ownerSlot !== null && e.slotId === ownerSlot) {
                ctx.strokeStyle = '#ffffff';
                ctx.lineWidth   = 2;
                ctx.beginPath();
                ctx.arc(px, py, dotR + 4, 0, Math.PI * 2);
                ctx.stroke();
            }

            // Slice 25.1: slot number label. When the dot is big enough
            // (zoomed-in ball scenarios: dotR ≈ 5-10 px), render the
            // label INSIDE the dot the classic way. When the dot is
            // smaller than the glyph (full-pitch views on M0 wander
            // demos: dotR ≈ 2-3 px), auto-hoist the label ABOVE the dot
            // with a translucent chip so identity survives the zoom-
            // out. This is the "labels above" pattern used by top-down
            // football games / tactical tools; the marker stays at
            // real physical scale, identity moves to a floating tag.
            const label = String(e.slotId);
            ctx.font = 'bold 10px sans-serif';
            ctx.textAlign    = 'center';
            const kInsideThreshold = 6;   // px: dot big enough to hold "12"
            if (dotR >= kInsideThreshold) {
                ctx.fillStyle    = '#000';
                ctx.textBaseline = 'middle';
                ctx.fillText(label, px, py + 1);
            } else {
                // Floating chip above the dot. Sized to the glyph +
                // 4 px padding, positioned so the chip's bottom sits
                // ~2 px above the top of the dot.
                const metrics    = ctx.measureText(label);
                const chipW      = Math.max(12, metrics.width + 6);
                const chipH      = 12;
                const chipX      = px - chipW / 2;
                const chipY      = py - dotR - 2 - chipH;
                ctx.fillStyle    = 'rgba(0, 0, 0, 0.65)';
                ctx.fillRect(chipX, chipY, chipW, chipH);
                ctx.fillStyle    = color;
                ctx.textBaseline = 'middle';
                ctx.fillText(label, px, chipY + chipH / 2 + 1);
            }
        }
    }

    // Slice 15.5: draw the ball, when present, as a filled white circle
    // with a thin black outline. Real football is 22 cm diameter; at
    // typical pxPerM the geometric size is ~2 px, which is invisible at
    // a glance, so we clamp to a minimum BALL_MIN_PX radius the way
    // FIFA/PES do for readability. Slice 25.1: uses BALL_RADIUS_M
    // (0.11 m) via the shared camera scale so the ball is proportional
    // to the player marker at every zoom level.
    // Draw AFTER entities so the ball floats on top during possession /
    // near-player situations (in M1 the ball is always loose, so overlap
    // is rare — but the order is the correct one for future slices).
    drawBall(snap) {
        if (!snap || !snap.ball) return;
        const ctx = this.ctx;
        const ball = snap.ball;

        const px = this._wx(ball.posX);
        const py = this._wy(ball.posY);

        const geomR = BALL_RADIUS_M * this.pxPerM;
        const r     = Math.max(BALL_MIN_PX, geomR);

        // Optional velocity tick (short line) — helps visualize decay.
        // Only when the ball is actually moving (avoid a lonely dot).
        const speed = Math.hypot(ball.velX, ball.velY);
        if (speed > 0.05) {
            ctx.strokeStyle = 'rgba(255,255,255,0.55)';
            ctx.lineWidth   = 1.5;
            ctx.beginPath();
            ctx.moveTo(px, py);
            // Scale so a 1 m/s ball draws a 1 m tick — proportional to speed.
            ctx.lineTo(px + ball.velX * this.pxPerM,
                       py - ball.velY * this.pxPerM);
            ctx.stroke();
        }

        // Ball body: white fill, thin dark rim so it pops against pitch green.
        ctx.fillStyle   = '#ffffff';
        ctx.strokeStyle = '#1a1a1a';
        ctx.lineWidth   = 1.5;
        ctx.beginPath();
        ctx.arc(px, py, r, 0, Math.PI * 2);
        ctx.fill();
        ctx.stroke();
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
        // Slice 25.1: refresh camera (viewport + focus + pxPerM) BEFORE
        // any drawing so drawPitch()/drawPlayableArea()/drawEntities()/
        // drawBall() all see a consistent world→screen transform.
        this._updateCamera(snap);

        this.clear();
        this.drawPitch();
        this.drawPlayableArea();
        this.drawEntities(snap);
        this.drawBall(snap);
        this.drawHud(status || {});
    }
}

window.FhSimRenderer = FhSimRenderer;
