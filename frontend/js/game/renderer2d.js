// frontend/js/game/renderer2d.js
//
// The top-down 2D view of the authoritative world (James 11/16: "nhl 94 style now and later add the
// 3d client … allow for both views"). The same surface client.js drives on the 3D GameRenderer
// (renderer.js): HELLO builds the pitch, snapshots go into a buffer + 2-minute history, frame()
// interpolates between the two snapshots bracketing the render tick [QUAKE], replay renders from
// the history, pickSlot / screenToPitch / rig answer the controls. Pure dressing: nothing here
// affects gameplay, and the server is the same one the 3D client talks to.
//
// The engine is 2D for the players (PlayerState z stays 0) with a ball that has height; here the
// ball's height shows the way the 16-bit top-down games did it: its shadow stays on the grass, the
// ball rises up the screen off it and grows. A phone held upright gets the pitch running up the
// screen; landscape runs it across.
//
// Camera (Rig2D): BALL follows the ball, FULL fits the whole pitch, WATCH follows one man; + / −
// zoom, a mouse drag pans (and turns follow off). Kits come from the TEAMS frame via
// PlayerFigure.setKits, the same call the 3D figures take (a stand-in is defined here when the 3D
// files aren't loaded).

(function () {
  'use strict';

  const INTERP_DELAY_TICKS = 4;  // ~133 ms behind live at 30 Hz, as renderer.js
  const NO_OWNER = 255;
  const BALL_R = 0.109;          // the engine's kBallRadius (core/Ball.hpp), a size 5

  // Kits: the 3D figures' defaults (players.js KIT); the TEAMS frame overrides the outfield ones.
  const KIT = {
    home:   { shirt: 0x14326e, trim: 0xffcc00, shorts: 0xf4f6fb, socks: 0x14326e },
    away:   { shirt: 0xeef1f6, trim: 0x14326e, shorts: 0x14326e, socks: 0xeef1f6 },
    homeGk: { shirt: 0x2e9e44, trim: 0x111111 },
    awayGk: { shirt: 0xff8a1f, trim: 0x111111 },
  };
  const hex = (n) => '#' + (n >>> 0).toString(16).padStart(6, '0').slice(-6);
  if (!window.PlayerFigure) {
    window.PlayerFigure = {
      setKits(home, away) {
        if (home) Object.assign(KIT.home, home);
        if (away) Object.assign(KIT.away, away);
      },
    };
  } else {
    const base = window.PlayerFigure.setKits;
    window.PlayerFigure.setKits = (home, away) => {
      base(home, away);
      if (home) Object.assign(KIT.home, home);
      if (away) Object.assign(KIT.away, away);
    };
  }

  // One per slot: what client.js asks of a figure (identity, keeper, kit rebuild, glow, celebrate).
  class Figure2D {
    constructor(slot, home) {
      this.slot = slot;
      this.home = home;
      this.keeper = false;
      this.number = null;
      this.tagName = '';
      this.celebrateAt = 0;
      this.sx = 0; this.sy = 0; this.drawn = false;   // last screen position (pickSlot)
    }
    setKeeper(k) { this.keeper = k; }
    setIdentity(number, name) {
      if (number) this.number = number;
      this.tagName = String(name || '').trim().split(/\s+/).pop().toUpperCase();
    }
    build(home, keeper) { this.home = home; this.keeper = keeper; }   // kits are read when drawn
    setGlow() {}
    celebrate() { this.celebrateAt = performance.now(); }
    kit() {
      if (this.keeper) return this.home ? KIT.homeGk : KIT.awayGk;
      return this.home ? KIT.home : KIT.away;
    }
  }

  const LABEL = { ball: 'BALL', full: 'FULL', watch: 'WATCH' };

  class Rig2D {
    constructor(r) {
      this.r = r;
      this.mode = 'ball';
      this.follow = true;
      this.dragged = false;
      this.onModeChange = null;
      this.span = 46;            // metres of pitch across the screen's short side (BALL / WATCH)
      this.cx = 0; this.cy = 0;  // view centre, pitch metres
      this.cur = { dist: 0 };    // renderer.js reads rig.cur.dist; kept for the shared surface
      this.attachPointer(r.canvas);
    }
    label() { return LABEL[this.mode] || 'BALL'; }
    setMode(m) {
      if (m === 'broadcast' || !LABEL[m]) m = m === 'watch' ? 'watch' : 'ball';
      if (m === this.mode) return;
      this.mode = m;
      if (this.onModeChange) this.onModeChange(this.label());
    }
    cycle() { this.setMode(this.mode === 'full' ? 'ball' : 'full'); }
    setFollow(on) { this.follow = on; }
    zoom(f) {
      if (this.mode === 'full') this.setMode('ball');
      this.span = Math.min(160, Math.max(12, this.span * f));
    }
    attachPointer(canvas) {
      let down = null;
      canvas.addEventListener('mousedown', (e) => { down = { x: e.clientX, y: e.clientY, cx: this.cx, cy: this.cy }; this.dragged = false; });
      window.addEventListener('mousemove', (e) => {
        if (!down) return;
        const dx = e.clientX - down.x, dy = e.clientY - down.y;
        if (!this.dragged && Math.hypot(dx, dy) < 6) return;
        this.dragged = true;
        if (this.follow) { this.follow = false; this.r.onFollowLost && this.r.onFollowLost(); }
        if (this.mode === 'full') this.setMode('ball');
        const p = this.r.screenDelta(-dx, -dy);
        this.cx = down.cx + p.x; this.cy = down.cy + p.y;
      });
      window.addEventListener('mouseup', () => { down = null; });
      canvas.addEventListener('wheel', (e) => { e.preventDefault(); this.zoom(e.deltaY > 0 ? 1.1 : 1 / 1.1); }, { passive: false });
    }
    // The view for this frame: centre (pitch m) and scale (px per m).
    update(dt, s) {
      const r = this.r, W = r.W, H = r.H;
      if (!W || !H) return;
      const long = r.portrait ? H : W, short = r.portrait ? W : H;
      if (this.mode === 'full') {
        const sc = Math.min(long / (2 * r.hx + 10), short / (2 * r.hy + 10));
        this.scale = sc;
        this.cx = 0; this.cy = 0;
        return;
      }
      this.scale = short / this.span;
      if (!this.follow) return;
      const t = this.mode === 'watch' && s.watch ? s.watch : s.ball || s.me;
      if (!t) return;
      // Ease toward the target (a quarter-second lag), clamped so the view stays on the pitch.
      const k = 1 - Math.exp(-dt * 4);
      this.cx += (t.x - this.cx) * k;
      this.cy += (t.y - this.cy) * k;
      const halfLong = long / 2 / this.scale, halfShort = short / 2 / this.scale;
      const mx = Math.max(0, r.hx + 4 - halfLong), my = Math.max(0, r.hy + 4 - halfShort);
      this.cx = Math.min(mx, Math.max(-mx, this.cx));
      this.cy = Math.min(my, Math.max(-my, this.cy));
    }
  }

  class GameRenderer2D {
    constructor(canvas) {
      this.canvas = canvas;
      this.ctx = canvas.getContext('2d');
      this.figures = [];
      this.buffer = [];
      this.tickRate = 30;
      this.speed = 1;
      this.history = [];
      this.replay = null;
      this.heldTick = null;
      this.timeOffset = null;
      this.lastSnapshotAt = 0;
      this.lastFrameAt = 0;
      this.mySlots = new Set();
      this.activeSlot = null;
      this.watchSlot = null;
      this.halfN = 11;
      this.hx = 52.5; this.hy = 34;
      this.brain = null;
      this.flashUntil = 0;
      this.showMatch = true;
      this.is2d = true;
      // The 3D field's calls (client.js mode switching): nothing to switch in 2D.
      this.field = { setContours() {}, setOldPitch() {}, setGamePitch() {}, setGameSeven() {}, setLeaves() {}, update() {} };
      this.rig = new Rig2D(this);
      window.addEventListener('resize', () => this.resize());
      this.resize();
    }

    resize() {
      const dpr = Math.min(window.devicePixelRatio || 1, 2);
      this.dpr = dpr;
      this.W = window.innerWidth; this.H = window.innerHeight;
      this.canvas.width = Math.round(this.W * dpr);
      this.canvas.height = Math.round(this.H * dpr);
      this.portrait = this.H > this.W * 1.05;
    }

    buildWorld(hello) {
      this.tickRate = hello.tickRate || 30;
      this.hx = hello.pitchHalfX; this.hy = hello.pitchHalfY;
      const n = hello.slotCount || 22;
      this.halfN = Math.floor(n / 2);
      this.figures = [];
      for (let i = 0; i < n; i++) this.figures.push(new Figure2D(i, i < this.halfN));
    }

    setSpeed(pct) {
      const s = pct / 100;
      if (s === this.speed) return;
      this.speed = s;
      this.timeOffset = null;
    }

    pushSnapshot(snap) {
      const now = performance.now();
      this.lastSnapshotAt = now;
      const last = this.buffer.length ? this.buffer[this.buffer.length - 1].tick : -1;
      if (snap.tick === last) return;
      const dt = 1000 / (this.tickRate * (this.speed || 1));
      const offset = now - snap.tick * dt;
      if (this.timeOffset === null || offset < this.timeOffset) this.timeOffset = offset;
      else this.timeOffset += (offset - this.timeOffset) * 0.002;
      if (snap.players && this.figures.length)
        snap.players.forEach((p, i) => { if (this.figures[i]) this.figures[i].setKeeper(!!(p.flags & 2)); });
      this.buffer.push({ tick: snap.tick, snap });
      if (this.buffer.length > 90) this.buffer.splice(0, 30);
      this.history.push({ tick: snap.tick, snap });
      if (this.history.length > 3600 + 300) this.history.splice(0, 300);
    }

    setWatchSlot(slot) { this.watchSlot = slot; }
    leadTicks() { return INTERP_DELAY_TICKS; }
    setMySlots(slots, activeSlot) { this.mySlots = slots; this.activeSlot = activeSlot; }

    // Pitch metres ↔ CSS pixels. Landscape: +x right, +y up. Portrait: rotated a quarter turn
    // anticlockwise, +x up the screen, +y to the left (a rotation, never a mirror).
    toScreen(x, y) {
      const s = this.rig.scale || 1, dx = x - this.rig.cx, dy = y - this.rig.cy;
      return this.portrait ? { x: this.W / 2 - dy * s, y: this.H / 2 - dx * s }
                           : { x: this.W / 2 + dx * s, y: this.H / 2 - dy * s };
    }
    // A screen move (px, y down) as pitch metres.
    screenDelta(sx, sy) {
      const s = this.rig.scale || 1;
      return this.portrait ? { x: -sy / s, y: -sx / s } : { x: sx / s, y: -sy / s };
    }
    // The controls are screen-relative: "up" on the keys / joystick is up the screen.
    screenToPitch(v) {
      return this.portrait ? { x: -v.y, y: -v.x } : { x: v.x, y: -v.y };
    }

    frame() {
      const now = performance.now();
      const dt = this.lastFrameAt ? Math.min((now - this.lastFrameAt) / 1000, 0.1) : 0.016;
      this.lastFrameAt = now;
      const rp = this.replay;
      const buf = rp ? this.history : this.buffer;
      const n = buf.length;
      let a = null, b = null, alpha = 0;
      if (n >= 1 && (rp || this.timeOffset !== null)) {
        let renderTick;
        if (rp) {
          if (rp.playing) rp.tick += dt * this.tickRate * rp.rate;
          const first = buf[0].tick, last = buf[n - 1].tick;
          if (rp.tick < first) rp.tick = first;
          if (rp.tick >= last) { rp.tick = last; rp.playing = false; }
          renderTick = rp.tick;
        } else {
          const tdt = 1000 / (this.tickRate * (this.speed || 1));
          const delay = Math.max(1.5, this.leadTicks() * this.speed);
          renderTick = (now - this.timeOffset) / tdt - delay;
          if (this.speed === 0 && this.heldTick !== null) renderTick = this.heldTick;
          else if (this.speed === 0) this.heldTick = renderTick;
          else this.heldTick = null;
        }
        this.renderTick = renderTick;
        let lo = 0, hi = n - 1;
        while (hi - lo > 1) {
          const mid = (lo + hi) >> 1;
          if (buf[mid].tick <= renderTick) lo = mid; else hi = mid;
        }
        a = buf[lo]; b = buf[hi];
        if (renderTick <= a.tick) b = a;
        const span = Math.max(b.tick - a.tick, 1);
        alpha = Math.min(Math.max((renderTick - a.tick) / span, 0), 1);
      }
      const lerp = (u, v) => u + (v - u) * alpha;
      let ball = null, me = null, watch = null;
      const players = [];
      if (a && b) {
        if (a.snap.ball && b.snap.ball) ball = { x: lerp(a.snap.ball.x, b.snap.ball.x), y: lerp(a.snap.ball.y, b.snap.ball.y), z: Math.max(0, lerp(a.snap.ball.z, b.snap.ball.z)), owner: b.snap.ball.owner };
        const count = Math.min(this.figures.length, b.snap.players.length, a.snap.players.length);
        for (let i = 0; i < count; i++) {
          const pa = a.snap.players[i], pb = b.snap.players[i];
          const p = { i, x: lerp(pa.x, pb.x), y: lerp(pa.y, pb.y), vx: lerp(pa.vx, pb.vx), vy: lerp(pa.vy, pb.vy), fx: pb.fx, fy: pb.fy, flags: pb.flags };
          players.push(p);
          if (i === this.activeSlot) me = p;
          if (i === this.watchSlot) watch = p;
        }
      }
      if (!me && ball && ball.owner !== NO_OWNER && players[ball.owner]) me = players[ball.owner];
      this.rig.update(dt, { ball, me, watch });
      this.draw(a, b, alpha, ball, players, now);
    }

    draw(a, b, alpha, ball, players, now) {
      const c = this.ctx, dpr = this.dpr;
      c.setTransform(dpr, 0, 0, dpr, 0, 0);
      c.fillStyle = '#2f6b2a';
      c.fillRect(0, 0, this.W, this.H);
      this.drawPitch(c);
      const s = this.rig.scale || 1;
      // Officials: small black discs.
      if (a && b && a.snap.officials && b.snap.officials) {
        const oc = Math.min(a.snap.officials.length, b.snap.officials.length);
        for (let i = 0; i < oc; i++) {
          const oa = a.snap.officials[i], ob = b.snap.officials[i];
          const q = this.toScreen(oa.x + (ob.x - oa.x) * alpha, oa.y + (ob.y - oa.y) * alpha);
          const r = Math.max(4, 0.4 * s);
          c.beginPath(); c.arc(q.x, q.y, r, 0, Math.PI * 2);
          c.fillStyle = '#111'; c.fill();
          c.lineWidth = Math.max(1, r * 0.3); c.strokeStyle = '#ffd400'; c.stroke();
        }
      }
      // Brain overlay lines under the men.
      if (this.brain && this.brain.entries && this.brain.show) this.drawBrainLines(c, players);
      // Players.
      const R = Math.max(7, 0.55 * s);
      const showNum = R >= 8;
      const showName = s >= 12;   // names only zoomed in; the whole pitch would be a wall of tags
      for (const p of players) {
        const f = this.figures[p.i];
        const q = this.toScreen(p.x, p.y);
        f.sx = q.x; f.sy = q.y; f.drawn = true;
        const kit = f.kit();
        const down = (p.flags & 4) !== 0;
        let hop = 0;
        if (f.celebrateAt && now - f.celebrateAt < 2500) hop = Math.abs(Math.sin((now - f.celebrateAt) / 120)) * R * 0.5;
        // shadow
        c.beginPath(); c.ellipse(q.x + R * 0.25, q.y + R * 0.3, R, R * 0.8, 0, 0, Math.PI * 2);
        c.fillStyle = 'rgba(0,0,0,0.28)'; c.fill();
        // rings: the man you drive (gold), the one you watch (cyan), your other held men (faint gold)
        if (p.i === this.activeSlot || p.i === this.watchSlot || this.mySlots.has(p.i)) {
          c.beginPath(); c.arc(q.x, q.y, R * 1.45, 0, Math.PI * 2);
          c.lineWidth = Math.max(2, R * 0.28);
          c.strokeStyle = p.i === this.activeSlot ? '#ffcc00' : p.i === this.watchSlot ? '#00e5ff' : 'rgba(255,204,0,0.45)';
          c.stroke();
        }
        c.save();
        c.translate(q.x, q.y - hop);
        if (down) { c.scale(1.35, 0.6); }
        // body
        c.beginPath(); c.arc(0, 0, R, 0, Math.PI * 2);
        c.fillStyle = hex(kit.shirt); c.fill();
        c.lineWidth = Math.max(1.5, R * 0.22); c.strokeStyle = hex(kit.trim); c.stroke();
        c.restore();
        // facing: a notch toward where he looks (face vector, else his run)
        let fx = p.fx, fy = p.fy;
        if (!fx && !fy) { fx = p.vx; fy = p.vy; }
        const fl = Math.hypot(fx || 0, fy || 0);
        if (fl > 1e-3) {
          const tip = this.toScreen(p.x + fx / fl, p.y + fy / fl);
          const ux = (tip.x - q.x), uy = (tip.y - q.y), ul = Math.hypot(ux, uy) || 1;
          const nx = ux / ul, ny = uy / ul;
          c.beginPath();
          c.moveTo(q.x + nx * R * 1.35, q.y - hop + ny * R * 1.35);
          c.lineTo(q.x + nx * R * 0.7 - ny * R * 0.45, q.y - hop + ny * R * 0.7 + nx * R * 0.45);
          c.lineTo(q.x + nx * R * 0.7 + ny * R * 0.45, q.y - hop + ny * R * 0.7 - nx * R * 0.45);
          c.closePath();
          c.fillStyle = hex(kit.trim); c.fill();
        }
        if (showNum && f.number) {
          c.font = `700 ${Math.round(R * 1.05)}px system-ui, sans-serif`;
          c.textAlign = 'center'; c.textBaseline = 'middle';
          c.fillStyle = hex(kit.trim);
          c.fillText(String(f.number), q.x, q.y - hop + R * 0.05);
        }
        if (showName && f.tagName) {
          c.font = `700 ${Math.round(Math.max(9, R * 0.8))}px system-ui, sans-serif`;
          c.textAlign = 'center'; c.textBaseline = 'bottom';
          c.lineWidth = 3; c.strokeStyle = 'rgba(0,0,0,0.65)';
          c.strokeText(f.tagName, q.x, q.y - hop - R * 1.55);
          c.fillStyle = '#fff';
          c.fillText(f.tagName, q.x, q.y - hop - R * 1.55);
        }
      }
      if (this.brain && this.brain.entries && this.brain.show) this.drawBrainLabels(c, players, R);
      // Ball: shadow on the grass, the ball lifted up the screen by its height and grown with it.
      if (ball) {
        const g = this.toScreen(ball.x, ball.y);
        const br = Math.max(5, BALL_R * 2.6 * s) * (1 + Math.min(ball.z, 12) / 8);
        const lift = ball.z * s * 0.9;
        c.beginPath(); c.ellipse(g.x, g.y, Math.max(3, BALL_R * 2.2 * s) * (1 - Math.min(ball.z, 10) / 25), Math.max(2, BALL_R * 1.6 * s), 0, 0, Math.PI * 2);
        c.fillStyle = `rgba(0,0,0,${Math.max(0.15, 0.4 - ball.z / 40)})`; c.fill();
        c.beginPath(); c.arc(g.x, g.y - lift - br * 0.4, br, 0, Math.PI * 2);
        c.fillStyle = '#fff'; c.fill();
        c.lineWidth = Math.max(1.5, br * 0.3); c.strokeStyle = '#111'; c.stroke();
      }
      if (now < this.flashUntil) {
        c.fillStyle = 'rgba(255,204,0,0.28)';
        c.fillRect(0, 0, this.W, this.H);
      }
    }

    drawPitch(c) {
      const hx = this.hx, hy = this.hy, s = this.rig.scale || 1;
      // Mowing stripes across the length, 12 of them, grass beyond the lines.
      const stripes = 12, w = (2 * hx) / stripes;
      for (let k = -1; k <= stripes; k++) {
        const x0 = -hx + k * w;
        this.poly(c, [[x0, -hy - 6], [x0 + w, -hy - 6], [x0 + w, hy + 6], [x0, hy + 6]]);
        c.fillStyle = k % 2 ? '#3d8a35' : '#378030'; c.fill();
      }
      c.strokeStyle = 'rgba(255,255,255,0.9)';
      c.lineWidth = Math.max(1.2, 0.12 * s);
      this.poly(c, [[-hx, -hy], [hx, -hy], [hx, hy], [-hx, hy]]); c.stroke();
      this.poly(c, [[0, -hy], [0, hy]], true); c.stroke();
      this.circle(c, 0, 0, 9.15); c.stroke();
      this.dot(c, 0, 0, 0.25);
      for (const e of [-1, 1]) {
        const gx = e * hx;
        // penalty area 16.5 x 40.32, goal area 5.5 x 18.32, the spot at 11, the D
        this.poly(c, [[gx, -20.16], [gx - e * 16.5, -20.16], [gx - e * 16.5, 20.16], [gx, 20.16]], true); c.stroke();
        this.poly(c, [[gx, -9.16], [gx - e * 5.5, -9.16], [gx - e * 5.5, 9.16], [gx, 9.16]], true); c.stroke();
        this.dot(c, gx - e * 11, 0, 0.22);
        const t = Math.acos(5.5 / 9.15);
        this.arc(c, gx - e * 11, 0, 9.15, e > 0 ? Math.PI - t : -t, e > 0 ? Math.PI + t : t); c.stroke();
        for (const sy of [-1, 1]) {   // corner arcs, 1 m: the quarter facing into the pitch
          const tc = Math.atan2(-sy, -e);
          this.arc(c, gx, sy * hy, 1, tc - Math.PI / 4, tc + Math.PI / 4); c.stroke();
        }
        // the goal: 7.32 wide, 2 m deep net behind the line
        this.poly(c, [[gx, -3.66], [gx + e * 2, -3.66], [gx + e * 2, 3.66], [gx, 3.66]]);
        c.fillStyle = 'rgba(255,255,255,0.22)'; c.fill();
        c.save(); c.lineWidth = Math.max(2, 0.2 * s); c.strokeStyle = '#fff';
        this.poly(c, [[gx, -3.66], [gx + e * 2, -3.66], [gx + e * 2, 3.66], [gx, 3.66]], true); c.stroke();
        c.restore();
      }
    }
    poly(c, pts, open) {
      c.beginPath();
      pts.forEach(([x, y], k) => { const q = this.toScreen(x, y); if (k) c.lineTo(q.x, q.y); else c.moveTo(q.x, q.y); });
      if (!open) c.closePath();
    }
    arc(c, cx, cy, r, a0, a1) {
      const pts = [];
      for (let k = 0; k <= 32; k++) { const t = a0 + (a1 - a0) * k / 32; pts.push([cx + Math.cos(t) * r, cy + Math.sin(t) * r]); }
      this.poly(c, pts, true);
    }
    circle(c, cx, cy, r) { this.arc(c, cx, cy, r, 0, Math.PI * 2); }
    dot(c, x, y, r) {
      const q = this.toScreen(x, y);
      c.beginPath(); c.arc(q.x, q.y, Math.max(1.5, r * (this.rig.scale || 1)), 0, Math.PI * 2);
      c.fillStyle = 'rgba(255,255,255,0.9)'; c.fill();
    }

    // Brain overlay (G4.41, after [Buckland]'s Simple Soccer debug view), as renderer.js draws it:
    // a line to where he's going, a dashed line to the man he acts on, his decision's label.
    drawBrainLines(c, players) {
      const v = this.brain;
      for (const p of players) {
        const e = v.entries[p.i];
        if (!v.show.has(p.i) || !e) continue;
        const q = this.toScreen(p.x, p.y), t = this.toScreen(e.tx, e.ty);
        c.setLineDash([]);
        c.lineWidth = 1.5; c.strokeStyle = p.i < this.halfN ? 'rgba(43,123,255,0.9)' : 'rgba(255,51,85,0.9)';
        c.beginPath(); c.moveTo(q.x, q.y); c.lineTo(t.x, t.y); c.stroke();
        c.beginPath(); c.arc(t.x, t.y, 4, 0, Math.PI * 2); c.stroke();
        if (e.other !== 255 && players[e.other]) {
          const o = this.toScreen(players[e.other].x, players[e.other].y);
          c.setLineDash([5, 4]); c.strokeStyle = '#ffcc00';
          c.beginPath(); c.moveTo(q.x, q.y); c.lineTo(o.x, o.y); c.stroke();
          c.setLineDash([]);
        }
      }
    }
    drawBrainLabels(c, players, R) {
      const v = this.brain;
      c.font = '700 11px system-ui, sans-serif';
      c.textAlign = 'center'; c.textBaseline = 'middle';
      for (const p of players) {
        const e = v.entries[p.i];
        if (!v.show.has(p.i) || !e) continue;
        const concept = e.concept !== undefined && e.concept !== 255 && v.concepts ? v.concepts[e.concept] : null;
        const text = concept ? concept.title : (v.legend && v.legend[e.why]) || '?';
        const q = this.toScreen(p.x, p.y);
        const w = c.measureText(text).width + 10, y = q.y + R * 1.6 + 9;
        c.fillStyle = concept ? 'rgba(127,215,255,0.94)' : 'rgba(255,204,0,0.92)';
        c.fillRect(q.x - w / 2, y - 8, w, 16);
        c.fillStyle = '#10161f';
        c.fillText(text, q.x, y);
      }
    }

    startReplay(ticksBack) {
      const h = this.history;
      if (!h.length) return;
      const last = h[h.length - 1].tick;
      this.replay = { tick: Math.max(h[0].tick, last - ticksBack), rate: 0.5, playing: false };
    }
    stopReplay() { this.replay = null; }
    historySpan() {
      const h = this.history;
      return h.length ? { first: h[0].tick, last: h[h.length - 1].tick } : null;
    }
    setBrain(view) { this.brain = view; }
    celebrate(team) {
      for (const f of this.figures) if ((f.slot < this.halfN ? 0 : 1) === team) f.celebrate();
    }
    goalFlash() { this.flashUntil = performance.now() + 600; }

    // The slot under a tap: the nearest drawn man within a finger's reach.
    pickSlot(clientX, clientY) {
      const reach = Math.max(18, 1.4 * (this.rig.scale || 1));
      let best = null, bd = reach * reach;
      for (const f of this.figures) {
        if (!f.drawn) continue;
        const d = (f.sx - clientX) ** 2 + (f.sy - clientY) ** 2;
        if (d < bd) { bd = d; best = f.slot; }
      }
      return best;
    }
  }

  window.GameRenderer2D = GameRenderer2D;
})();
