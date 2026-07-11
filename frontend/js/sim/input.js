// frontend/js/sim/input.js
//
// Player input for the fh-sim.v1 client. Two source stacks compose into
// a single Intent that client.js reads every INPUT tick:
//
//   KeyboardInput — WASD/arrow keys, Shift = sprint, Ctrl = walk.
//   TouchInput    — virtual left thumb-stick, tap-and-hold sprint pad.
//
// The Intent shape mirrors the sim's controller::Intent:
//   { dirX, dirY, wantsSprint, wantsWalk }
// where (dirX, dirY) is a unit-ish vector in WORLD space: +x = along
// the pitch length (goal-to-goal), +y = across (touchline-to-touchline,
// same direction as "up" on screen — the renderer flips it).

'use strict';

// ---------------------------------------------------------------------------
// KeyboardInput
// ---------------------------------------------------------------------------

class FhSimKeyboardInput {
    constructor() {
        this._keys = new Set();
        this._onDown = (e) => this._handle(e, true);
        this._onUp   = (e) => this._handle(e, false);
        window.addEventListener('keydown', this._onDown, { passive: false });
        window.addEventListener('keyup',   this._onUp,   { passive: false });
        window.addEventListener('blur',    () => this._keys.clear());
    }

    dispose() {
        window.removeEventListener('keydown', this._onDown);
        window.removeEventListener('keyup',   this._onUp);
        this._keys.clear();
    }

    _handle(e, pressed) {
        const k = keyOf(e);
        if (k == null) return;
        if (pressed) this._keys.add(k); else this._keys.delete(k);
        // Prevent WASD/arrows from scrolling the page while playing.
        if (k !== 'sprint' && k !== 'walk') e.preventDefault();
    }

    // Returns { dirX, dirY, wantsSprint, wantsWalk } or null if idle.
    read() {
        let dx = 0, dy = 0;
        if (this._keys.has('right')) dx += 1;
        if (this._keys.has('left'))  dx -= 1;
        if (this._keys.has('up'))    dy += 1;   // world +y = up-pitch
        if (this._keys.has('down'))  dy -= 1;
        const wantsSprint = this._keys.has('sprint');
        const wantsWalk   = this._keys.has('walk');
        if (dx === 0 && dy === 0 && !wantsSprint && !wantsWalk) return null;
        // Normalise so diagonals aren't ~1.41 fast — the sim expects
        // dir_x/dir_y magnitude ≤ 1.
        const mag = Math.hypot(dx, dy);
        if (mag > 0) { dx /= mag; dy /= mag; }
        return { dirX: dx, dirY: dy, wantsSprint, wantsWalk };
    }
}

function keyOf(e) {
    switch (e.code) {
        case 'KeyW': case 'ArrowUp':    return 'up';
        case 'KeyS': case 'ArrowDown':  return 'down';
        case 'KeyA': case 'ArrowLeft':  return 'left';
        case 'KeyD': case 'ArrowRight': return 'right';
        case 'ShiftLeft': case 'ShiftRight':     return 'sprint';
        case 'ControlLeft': case 'ControlRight': return 'walk';
        default: return null;
    }
}

// ---------------------------------------------------------------------------
// TouchInput — virtual joystick anchored where the finger lands, with a
// sprint pad in the bottom-right. Renders itself onto its own <canvas>.
// ---------------------------------------------------------------------------

class FhSimTouchInput {
    // opts.stickCanvas: HTMLCanvasElement for joystick overlay
    // opts.sprintPad:   HTMLElement for the sprint button
    constructor(opts) {
        this.stickCanvas = opts.stickCanvas;
        this.stickCtx    = this.stickCanvas.getContext('2d');
        this.sprintPad   = opts.sprintPad;

        this._pointerId = null;
        this._anchor    = null;   // { x, y } in canvas CSS pixels
        this._current   = null;
        this._sprint    = false;

        // Joystick pixels; enough to feel like a full "throw" without
        // dragging your thumb across the phone.
        this._maxRadiusPx = 60;

        this._bind();
        this.resize();
    }

    resize() {
        const dpr = window.devicePixelRatio || 1;
        const rect = this.stickCanvas.getBoundingClientRect();
        this.stickCanvas.width  = Math.max(1, Math.floor(rect.width  * dpr));
        this.stickCanvas.height = Math.max(1, Math.floor(rect.height * dpr));
        this.stickCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
        this._cssW = rect.width;
        this._cssH = rect.height;
        this._render();
    }

    dispose() {
        this._unbind();
    }

    _bind() {
        const c = this.stickCanvas;
        this._onDown = (e) => this._down(e);
        this._onMove = (e) => this._move(e);
        this._onUp   = (e) => this._up(e);
        c.addEventListener('pointerdown',   this._onDown, { passive: false });
        c.addEventListener('pointermove',   this._onMove, { passive: false });
        c.addEventListener('pointerup',     this._onUp,   { passive: false });
        c.addEventListener('pointercancel', this._onUp,   { passive: false });
        c.addEventListener('pointerleave',  this._onUp,   { passive: false });

        // Sprint pad — separate element so it can be styled/sized in CSS.
        this._onSprintDown = () => { this._sprint = true;  };
        this._onSprintUp   = () => { this._sprint = false; };
        this.sprintPad.addEventListener('pointerdown',   this._onSprintDown, { passive: true });
        this.sprintPad.addEventListener('pointerup',     this._onSprintUp,   { passive: true });
        this.sprintPad.addEventListener('pointercancel', this._onSprintUp,   { passive: true });
        this.sprintPad.addEventListener('pointerleave',  this._onSprintUp,   { passive: true });
    }

    _unbind() {
        const c = this.stickCanvas;
        c.removeEventListener('pointerdown',   this._onDown);
        c.removeEventListener('pointermove',   this._onMove);
        c.removeEventListener('pointerup',     this._onUp);
        c.removeEventListener('pointercancel', this._onUp);
        c.removeEventListener('pointerleave',  this._onUp);
        this.sprintPad.removeEventListener('pointerdown',   this._onSprintDown);
        this.sprintPad.removeEventListener('pointerup',     this._onSprintUp);
        this.sprintPad.removeEventListener('pointercancel', this._onSprintUp);
        this.sprintPad.removeEventListener('pointerleave',  this._onSprintUp);
    }

    _canvasPoint(e) {
        const rect = this.stickCanvas.getBoundingClientRect();
        return { x: e.clientX - rect.left, y: e.clientY - rect.top };
    }

    _down(e) {
        if (this._pointerId != null) return;
        e.preventDefault();
        this._pointerId = e.pointerId;
        this._anchor  = this._canvasPoint(e);
        this._current = this._anchor;
        this.stickCanvas.setPointerCapture(e.pointerId);
        this._render();
    }

    _move(e) {
        if (e.pointerId !== this._pointerId) return;
        e.preventDefault();
        this._current = this._canvasPoint(e);
        this._render();
    }

    _up(e) {
        if (e.pointerId !== this._pointerId) return;
        this._pointerId = null;
        this._anchor  = null;
        this._current = null;
        this._render();
    }

    // Returns Intent shape or null if not currently touched.
    read() {
        if (!this._anchor || !this._current) {
            if (this._sprint) return { dirX: 0, dirY: 0, wantsSprint: true, wantsWalk: false };
            return null;
        }
        const dx =  (this._current.x - this._anchor.x);
        const dy = -(this._current.y - this._anchor.y);   // flip: screen down = world −y
        const mag = Math.hypot(dx, dy);
        if (mag < 4) return { dirX: 0, dirY: 0, wantsSprint: this._sprint, wantsWalk: false };
        const clamped = Math.min(mag, this._maxRadiusPx);
        const nx = (dx / mag);
        const ny = (dy / mag);
        // Magnitude ratio drives walk/jog/sprint feel via a hint.
        const strength = clamped / this._maxRadiusPx;
        return {
            dirX: nx,
            dirY: ny,
            wantsSprint: this._sprint || strength > 0.9,
            wantsWalk:   strength < 0.3,
        };
    }

    _render() {
        const ctx = this.stickCtx;
        ctx.clearRect(0, 0, this._cssW, this._cssH);
        if (!this._anchor) return;
        // Outer ring
        ctx.strokeStyle = 'rgba(255,255,255,0.35)';
        ctx.lineWidth   = 3;
        ctx.beginPath();
        ctx.arc(this._anchor.x, this._anchor.y, this._maxRadiusPx, 0, Math.PI * 2);
        ctx.stroke();
        // Thumb
        const dx = this._current.x - this._anchor.x;
        const dy = this._current.y - this._anchor.y;
        const mag = Math.hypot(dx, dy);
        const scale = mag > this._maxRadiusPx ? this._maxRadiusPx / mag : 1;
        const tx = this._anchor.x + dx * scale;
        const ty = this._anchor.y + dy * scale;
        ctx.fillStyle = 'rgba(255,255,255,0.75)';
        ctx.beginPath();
        ctx.arc(tx, ty, 22, 0, Math.PI * 2);
        ctx.fill();
    }
}

// ---------------------------------------------------------------------------
// FhSimInput — merges keyboard + touch into one Intent stream. Latest
// non-null read wins; keyboard takes precedence when both are active.
// ---------------------------------------------------------------------------

class FhSimInput {
    constructor(opts) {
        this.keyboard = new FhSimKeyboardInput();
        this.touch    = opts && opts.stickCanvas
            ? new FhSimTouchInput(opts)
            : null;
    }

    resize() {
        if (this.touch) this.touch.resize();
    }

    dispose() {
        this.keyboard.dispose();
        if (this.touch) this.touch.dispose();
    }

    read() {
        const kb = this.keyboard.read();
        if (kb) return kb;
        if (this.touch) return this.touch.read();
        return null;
    }
}

window.FhSimInput = FhSimInput;
