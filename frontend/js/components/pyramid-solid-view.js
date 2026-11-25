// pyramid-solid-view.js — 🗻 the 3D pyramid on #apsl-pyramid: a real solid (three.js) with every
// table on its level and the promotion / relegation arrows on its walls.
//
// Owner, 2026-11-24, after four CSS-3D builds with the page's own boxes folded onto the walls
// ("the slant makes it hard ter read") and three solid builds side by side: "idk stil not happy
// with the 3d models. there has got to be a better way. threejs?" · "build on that version and
// do one with the arrows and stadings" · "last one is winnner as far as resourcess it runs fine
// and doesn't sllow iin browser and slow sysetem" · "drop the other versions".
//
// Each level is one band of a stepped-out pyramid, as tall as its longest table needs.  On it,
// drawn once into a canvas texture: the level number, the league, and every table in full
// (pos · club · GP · GD · Pts, the 2D chart's zone colour per row).  The APSL chart's links run
// as thin tubes on the walls from table to table, green head where a team goes up, red where it
// comes down.  It draws only when something moved — no idle frame loop.
//
// Driven by PyramidShapeView, which hands it:
//   rows  = [{ kind:'cup'|'pro'|'empty'|'own'|'feeder', level, cells:[{ slot, key, title, sub, tables, … }] }]  top first
//   slots = how many sides (one league = one side; the rest are bare)
//   hooks = { level(n) → 'Level n', head → ['GP','GD','Pts'], onPick(cell), onMove() }
//   opts  = { edges (PyramidModel.layout().edges), colors { promotion, relegation } }
// three.js 0.160 is the module the game uses, imported from the CDN the first time the view opens.
class PyramidSolid {
  static three() {
    if (!PyramidSolid._three) PyramidSolid._three = import('https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js');
    return PyramidSolid._three;
  }

  constructor(stage, rows, slots, hooks, opts) {
    this.stage = stage; this.rows = rows; this.slots = slots; this.hooks = hooks || {};
    this.edges = (opts && opts.edges) || [];                  // the promotion / relegation arrows between the tables
    this.colors = (opts && opts.colors) || {};
    this.yaw = 0; this.pitch = 0; this.dist = 10; this.panX = 0; this.panY = 0;   // where it is
    this.to = { yaw: 0, pitch: 0, dist: 10, panX: 0, panY: 0 };                   // where it is easing to
    this.dead = false; this.picked = null; this.shift = 0;
  }

  async start() {
    const T = await PyramidSolid.three();
    if (this.dead) return;
    this.T = T;
    const n = this.rows.length, slots = this.slots, half = Math.PI / slots, step = (2 * Math.PI) / slots;
    // The walls are one slope from a narrow cap to the foot.  A level is as tall as its longest
    // table needs at the width the level has there, worked out from the top down.
    const grow = 0.4, cap = n <= 4 ? 1.6 : 1.25, slopeOf = Math.hypot(1, grow);
    const tops = [0], font = getComputedStyle(this.stage).fontFamily || 'sans-serif';
    this.rows.forEach((row, i) => {
      const w = 2 * (cap + grow * tops[i]) * Math.tan(half) * 0.92;
      row.cells.forEach((cell) => { cell.plan = this._planTables(cell, w); });
      tops.push(tops[i] + Math.max(0.7, ...row.cells.map((c) => c.plan.h)) / slopeOf);
    });
    const apo = (i) => cap + grow * tops[i];            // the wall's distance from the axis at the top of level i
    this.total = tops[n]; this.lean = Math.atan(grow); this.base = apo(n); this.step = step;
    const yTop = (i) => this.total / 2 - tops[i];

    const canvas = document.createElement('canvas');
    canvas.className = 'sh-gl';
    canvas.style.cssText = 'position:absolute; inset:0; width:100%; height:100%; display:block; touch-action:none;';
    this.stage.insertBefore(canvas, this.stage.firstChild);
    this.canvas = canvas;
    const renderer = new T.WebGLRenderer({ canvas, antialias: true, alpha: true });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    this.renderer = renderer;
    const scene = new T.Scene();
    this.scene = scene;
    this.camera = new T.PerspectiveCamera(28, 1, 0.1, 400);
    scene.add(new T.AmbientLight(0xffffff, 1.15));
    const sun = new T.DirectionalLight(0xffffff, 1.9); sun.position.set(-5, 9, 12); scene.add(sun);
    const fill = new T.DirectionalLight(0x9db4ff, 0.5); fill.position.set(8, 2, 6); scene.add(fill);
    this.tilt = new T.Group(); this.spin = new T.Group();
    this.tilt.add(this.spin); scene.add(this.tilt);

    const COLOR = { cup: 0x7a5c12, pro: 0x1f3f7a, empty: 0x263041, own: 0x2456c8 };
    const feeder = [0x11655f, 0x0f5852, 0x0d4c47, 0x0b403c, 0x093532, 0x072b29];
    this.blocks = []; this.labels = []; this.own = [];
    const edge = new T.LineBasicMaterial({ color: 0x8b9bb5, transparent: true, opacity: 0.55 });
    this.own.push(edge);
    let depth = 0;
    this.rows.forEach((row, i) => {
      const a0 = apo(i), a1 = apo(i + 1), H = tops[i + 1] - tops[i];
      const geo = new T.CylinderGeometry(a0 / Math.cos(half), a1 / Math.cos(half), H, slots, 1, false);
      const mat = new T.MeshStandardMaterial({ color: row.kind === 'feeder' ? feeder[Math.min(depth++, feeder.length - 1)] : COLOR[row.kind] || COLOR.pro, flatShading: true, roughness: 0.82, metalness: 0.06 });
      const block = new T.Mesh(geo, mat);
      block.rotation.y = -half;                          // a flat side, not a corner, toward us
      block.position.y = yTop(i) - H / 2;
      block.userData.row = i;
      this.spin.add(block);
      const lines = new T.LineSegments(new T.EdgesGeometry(geo), edge);
      lines.rotation.y = -half; lines.position.y = block.position.y;
      this.spin.add(lines);
      this.blocks.push(block); this.own.push(geo, mat, lines.geometry);
      // the tables: one flat picture per league, lying on its own side of this level
      const slope = H * slopeOf;
      for (const cell of row.cells) {
        const w = 2 * a0 * Math.tan(half) * 0.92, h = slope * 0.98;
        const tex = this._tables(T, cell, row, w, h, font);
        const plane = new T.Mesh(new T.PlaneGeometry(w, h), new T.MeshBasicMaterial({ map: tex, transparent: true, depthWrite: false }));
        plane.position.set(0, yTop(i) - H / 2, (a0 + a1) / 2 + 0.012);
        plane.rotation.x = -this.lean;
        plane.userData.cell = cell; cell.row = i; cell.w = w;
        const pivot = new T.Group();
        pivot.rotation.y = cell.slot * step;
        pivot.add(plane); this.spin.add(pivot);
        this.labels.push(plane); this.own.push(plane.geometry, plane.material, tex);
      }
    });
    // the picked level's side, lit gold
    this.glowMat = new T.MeshBasicMaterial({ color: 0xfbbf24, transparent: true, opacity: 0.2, depthWrite: false, side: T.DoubleSide });
    this.ringMat = new T.LineBasicMaterial({ color: 0xfbbf24 });
    this.own.push(this.glowMat, this.ringMat);
    this._apo = apo; this._yTop = yTop;

    // start a little tipped toward us, so the leaning side is nearly square to the eye
    this.pitch = this.to.pitch = this.lean * 0.55;
    this._hands();
    this._ro = new ResizeObserver(() => this.resize());
    this._ro.observe(this.stage);
    this.resize(true);
    this._tops = tops; this._grow = grow; this._cap = cap; this._slopeOf = slopeOf;
    if (this.edges.length) this._arrows(T);
    if (this.picked) this.pick(this.picked);
  }

  // ── the tables ───────────────────────────────────────────────────────
  // Each table is one column, in full: pos · club · GP · GD ·
  // Pts, a zone colour down the left of a row (promotion / playoff / relegation, the same colours
  // as the 2D chart).  A table never folds.  More than a dozen tables (the UPSL's 35 conferences —
  // owner: "put upsl on the blank side") wrap onto further rows of tables, so the letters stay a
  // readable size instead of shrinking to nothing.
  _planTables(cell, w) {
    const tables = cell.tables && cell.tables.length ? cell.tables : [{ name: '', rows: [], teams: [] }];
    const HEAD = 0.42, perLetter = 25, MAX = 12;              // pos 2 · club 15 · three figures 2.5 each, and gaps
    const perRow = Math.min(tables.length, MAX), colW = w / perRow;
    const fs = Math.min(0.085, colW / perLetter), lh = fs * 1.32;
    const cols = tables.map((t, k) => ({ ...t, n: (t.rows && t.rows.length) || t.teams.length, gx: k % perRow, gr: Math.floor(k / perRow) }));
    const linesOf = (c) => c.n + (c.name ? 1.2 : 0) + (c.rows && c.rows.length ? 1 : 0);   // + the GP/GD/Pts head
    let gy = 0;
    for (let r = 0; r <= cols[cols.length - 1].gr; r++) {   // each row of tables as tall as its longest table
      const these = cols.filter((c) => c.gr === r);
      these.forEach((c) => { c.gy = gy; });
      gy += Math.max(...these.map(linesOf)) * lh + lh * 0.9;
    }
    return { h: HEAD + gy + 0.06, fs, cols, head: HEAD, perRow, table: true };
  }

  _tables(T, cell, row, w, h, font) {
    const plan = cell.plan, c = document.createElement('canvas');
    const PX = Math.min(360, 4096 / w);
    c.width = Math.max(64, Math.round(w * PX)); c.height = Math.max(64, Math.round(h * PX));
    const g = c.getContext('2d'), W = c.width, u = PX;
    const fit = (text, size, weight, max) => { let s = size; do { g.font = `${weight} ${s}px ${font}`; s -= 2; } while (s > 12 && g.measureText(text).width > max); };
    g.textBaseline = 'middle'; g.textAlign = 'center';
    const small = (this.hooks.level ? this.hooks.level(cell.level + 1) : '').toUpperCase();
    g.fillStyle = 'rgba(255,255,255,0.7)'; fit(small, 0.075 * u, 700, W * 0.94); g.fillText(small, W / 2, 0.07 * u);
    g.fillStyle = row.kind === 'empty' ? 'rgba(255,255,255,0.55)' : '#ffffff';
    fit(cell.title || '', 0.17 * u, 800, W * 0.94); g.fillText(cell.title || '', W / 2, 0.22 * u);
    if (cell.sub) { g.fillStyle = 'rgba(255,255,255,0.75)'; fit(cell.sub, 0.07 * u, 600, W * 0.94); g.fillText(cell.sub, W / 2, 0.36 * u); }
    const fs = plan.fs * u, lh = fs * 1.32, colW = W / (plan.perRow || plan.cols.length), pad = fs * 0.6;
    plan.cols.forEach((col) => {
      const k = col.gx, top = (plan.head + col.gy) * u;
      const x0 = k * colW + pad, x1 = (k + 1) * colW - pad, inner = x1 - x0;
      const xPos = x0 + fs * 1.1, xName = x0 + fs * 2.6, xPts = x1, xGd = x1 - fs * 2.6, xGp = x1 - fs * 5.2, nameW = xGp - fs * 2.2 - xName;
      let y = top + lh / 2;
      // the box behind the table, so it reads as one table on the wall (none for a level with no clubs)
      if (!col.n && !col.name) return;
      g.fillStyle = 'rgba(8,13,26,0.42)';
      g.fillRect(x0 - pad * 0.5, top - lh * 0.15, inner + pad, (col.n + (col.name ? 1.2 : 0) + 1) * lh + lh * 0.3);
      if (col.name) { g.textAlign = 'left'; g.font = `800 ${fs}px ${font}`; g.fillStyle = '#fcd34d'; g.fillText(col.name, x0, y, inner); y += lh * 1.2; }
      const figures = col.rows && col.rows.length;
      if (figures) {   // the head: GP GD Pts
        g.font = `700 ${fs * 0.82}px ${font}`; g.fillStyle = 'rgba(255,255,255,0.55)'; g.textAlign = 'right';
        (this.hooks.head || ['GP', 'GD', 'Pts']).forEach((t, j) => g.fillText(t, [xGp, xGd, xPts][j], y));
        y += lh;
      }
      const list = figures ? col.rows : col.teams.map((name) => ({ name }));
      list.forEach((r, j) => {
        const yy = y + j * lh;
        if (r.zc) { g.fillStyle = r.zc; g.globalAlpha = 0.28; g.fillRect(x0 - pad * 0.5, yy - lh / 2, inner + pad, lh); g.globalAlpha = 1; g.fillRect(x0 - pad * 0.5, yy - lh / 2, fs * 0.28, lh); }
        g.fillStyle = 'rgba(255,255,255,0.95)';
        g.textAlign = 'right'; g.font = `600 ${fs}px ${font}`;
        if (r.pos != null && r.pos !== '') g.fillText(String(r.pos), xPos, yy);
        g.textAlign = 'left'; g.font = `500 ${fs}px ${font}`;
        g.fillText(r.name || '', figures ? xName : x0, yy, figures ? nameW : inner);
        if (figures) {
          g.textAlign = 'right';
          g.fillText(r.gp == null ? '' : String(r.gp), xGp, yy);
          g.fillText(r.gd == null ? '' : String(r.gd), xGd, yy);
          g.font = `800 ${fs}px ${font}`; g.fillText(r.pts == null ? '' : String(r.pts), xPts, yy);
        }
      });
      // where this table sits on the wall, for the arrows: its middle across, its top and foot down the slope
      col.at = { x: ((x0 + x1) / 2 / W - 0.5) * w, l: (x0 / W - 0.5) * w, r: (x1 / W - 0.5) * w,
                 top: plan.head + col.gy - 0.06, foot: plan.head + col.gy + ((col.n + (col.name ? 1.2 : 0) + (figures ? 1 : 0)) * lh + lh * 0.2) / u };
    });
    const tex = new T.CanvasTexture(c);
    tex.colorSpace = T.SRGBColorSpace;
    tex.anisotropy = this.renderer.capabilities.getMaxAnisotropy();
    return tex;
  }

  // The arrows, drawn ON the walls: from the top of a table up to the foot of the table (or
  // conference) it goes up to, as in the 2D chart — a green head at the top where it promotes,
  // a red one at the bottom where it relegates.  All the levels lie on one slope, so a point
  // on a side is (x across, h down from the cap) and a line runs straight on from level to level.
  _arrows(T) {
    const at = new Map();   // 'd12' / 'c3' → { slot, x, l, r, top, foot } (h, the pyramid's own height)
    this.rows.forEach((row, i) => row.cells.forEach((cell) => (cell.plan.cols || []).forEach((col) => {
      if (!col.at) return;
      const slope = (this._tops[i + 1] - this._tops[i]) * this._slopeOf;
      const h = (v) => this._tops[i] + (0.01 * slope + v) / this._slopeOf;   // a distance down the plane → height
      const box = { slot: cell.slot, x: col.at.x, l: col.at.l, r: col.at.r, top: h(col.at.top), foot: h(col.at.foot) };
      if (col.node) at.set(col.node, box);
      if (col.conf) {   // a conference is the run of its tables
        const c = at.get(col.conf);
        if (!c) at.set(col.conf, { ...box });
        else { c.l = Math.min(c.l, box.l); c.r = Math.max(c.r, box.r); c.foot = Math.max(c.foot, box.foot); c.x = (c.l + c.r) / 2; }
      }
    })));
    const out = 0.03, step = this.step;
    const onWall = (slot, x, h) => {
      const a = this._cap + this._grow * h + out, th = slot * step;
      return new T.Vector3(x * Math.cos(th) + a * Math.sin(th), this.total / 2 - h, -x * Math.sin(th) + a * Math.cos(th));
    };
    const line = new T.MeshBasicMaterial({ color: 0xe2e8f0 });
    const up = new T.MeshBasicMaterial({ color: new T.Color(this.colors.promotion || '#22c55e') });
    const down = new T.MeshBasicMaterial({ color: new T.Color(this.colors.relegation || '#ef4444') });
    this.own.push(line, up, down);
    // thin lines and narrow heads (owner 2026-11-24: "change the pro/rel lines make them thinnger
    // and smaller arross") — they guide the eye between tables without covering the rows
    const R = Math.max(0.002, Math.min(0.0045, this.base * 0.001));
    const head = new T.ConeGeometry(R * 2.4, R * 11, 10);
    this.own.push(head);
    const group = new T.Group();
    for (const e of this.edges) {
      const a = at.get(`d${e.from}`), b = at.get(e.to);
      if (!a || !b || a.slot !== b.slot || b.foot >= a.top) continue;
      const x1 = a.x, h1 = a.top;
      const x2 = e.to[0] === 'c' ? Math.min(Math.max(x1, b.l + 0.05), b.r - 0.05) : b.x, h2 = b.foot;
      const pts = [];
      for (let k = 0; k <= 24; k++) {   // the 2D chart's curve: straight up, across in the middle, straight in
        const t = k / 24, mt = 1 - t;
        const x = mt * mt * mt * x1 + 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t * t * t * x2;
        const m = (h1 + h2) / 2, hh = mt * mt * mt * h1 + 3 * mt * mt * t * m + 3 * mt * t * t * m + t * t * t * h2;
        pts.push(onWall(a.slot, x, hh));
      }
      const curve = new T.CatmullRomCurve3(pts);
      const tube = new T.TubeGeometry(curve, 48, R, 6, false);
      group.add(new T.Mesh(tube, line)); this.own.push(tube);
      const tip = (p, toward, mat) => {   // a cone at p pointing away from `toward`
        const cone = new T.Mesh(head, mat);
        cone.position.copy(p);
        cone.quaternion.setFromUnitVectors(new T.Vector3(0, 1, 0), p.clone().sub(toward).normalize());
        group.add(cone);
      };
      if (e.up) tip(pts[24], pts[21], up);
      if (e.down) tip(pts[0], pts[3], down);
    }
    this.spin.add(group);
  }

  // ── where it stands ──────────────────────────────────────────────────
  resize(first) {
    if (this.dead || !this.renderer) return;
    const w = this.stage.clientWidth, h = this.stage.clientHeight;
    if (!w || !h) return;
    this.renderer.setSize(w, h, false);
    this.camera.aspect = w / h;
    this._view();
    if (first || this._auto !== false) { this.fit(true); return; }
    this.draw();
  }

  // With the panel open the pyramid moves into the room left of it.
  _view() {
    const w = this.stage.clientWidth, h = this.stage.clientHeight;
    if (this.shift) this.camera.setViewOffset(w, h, Math.round(w * this.shift), 0, w, h); else this.camera.clearViewOffset();
    this.camera.updateProjectionMatrix();
  }
  setShift(on) {
    const wide = this.stage.clientWidth > 760;
    this.shift = on && wide ? 0.23 : 0;
    if (this.camera) { this._view(); this.draw(); }
  }

  fit(now) {
    // Far enough back that every corner of the cap and of the foot is inside the frame — square
    // on a side or corner-on, at the resting tilt.  A short, wide stack (two levels) needs this:
    // its foot comes well toward the eye.
    const t = Math.tan((this.camera.fov * Math.PI) / 360), room = this.shift ? 0.54 : 1, keep = 0.94;
    const p = this.lean * 0.55, half = Math.PI / this.slots;
    let dist = 0;
    for (const [a, y] of [[this._apo(0), this.total / 2], [this.base, -this.total / 2]]) {
      const r = a / Math.cos(half), w = a * Math.tan(half);
      for (const [x, z] of [[w, a], [-w, a], [r, 0], [-r, 0], [0, r], [w, -a], [0, -r]]) {
        const y2 = y * Math.cos(p) - z * Math.sin(p), z2 = y * Math.sin(p) + z * Math.cos(p);
        dist = Math.max(dist, z2 + Math.abs(y2) / (t * keep), z2 + Math.abs(x) / (t * this.camera.aspect * room * keep));
      }
    }
    this.to.dist = this.fitDist = dist;
    this.to.panX = this.to.panY = 0;
    this.to.pitch = p;
    this.to.yaw = Math.round(this.yaw / this.step) * this.step;
    this._auto = true;
    if (now) { this.dist = this.to.dist; this.panX = this.panY = 0; this.draw(); } else this._ease();
  }
  // Zoom, keeping what is under the pointer where it is (nx, ny = the pointer, −1 … 1 across the stage).
  zoomBy(f, nx = 0, ny = 0) {
    const was = this.to.dist, t = Math.tan((this.camera.fov * Math.PI) / 360);
    this.to.dist = Math.min(this.total * 12, Math.max(this.base * 1.08, was / f));
    this.to.panX = this._clampX(this.to.panX + nx * t * this.camera.aspect * (was - this.to.dist));
    this.to.panY = this._clampY(this.to.panY + ny * t * (was - this.to.dist));
    this._auto = false;
    this._ease();
  }
  _close() { return this.fitDist && this.dist < this.fitDist * 0.8; }   // zoomed well in: a turn is not squared up on a side
  // the next side with a league on it (bare sides are passed over)
  turn(dir) {
    const has = new Set(this.rows.flatMap((r) => r.cells.map((c) => c.slot))), n = this.slots;
    const cur = Math.round(-this.to.yaw / this.step);
    let d = 1;
    while (d < n && !has.has((((cur + dir * d) % n) + n) % n)) d++;
    this.to.yaw = -(cur + dir * d) * this.step;
    this._ease();
  }
  face(slot) {
    const want = -slot * this.step, tau = 2 * Math.PI;
    this.to.yaw = this.yaw + ((((want - this.yaw) % tau) + tau * 1.5) % tau) - Math.PI;   // the short way round
    this._ease();
  }

  _ease() {
    if (this._raf || this.dead) return;
    const tick = () => {
      this._raf = null;
      if (this.dead) return;
      let far = false;
      for (const k of ['yaw', 'pitch', 'dist', 'panX', 'panY']) {
        const d = this.to[k] - this[k];
        if (Math.abs(d) > (k === 'dist' ? 0.01 : 0.0015)) { this[k] += d * 0.2; far = true; } else this[k] = this.to[k];
      }
      this.draw();
      if (far) this._raf = requestAnimationFrame(tick);
    };
    this._raf = requestAnimationFrame(tick);
  }

  draw() {
    if (this.dead || !this.renderer) return;
    this.spin.rotation.y = this.yaw;
    this.tilt.rotation.x = this.pitch;
    this.camera.position.set(this.panX, this.panY, this.dist);
    this.camera.lookAt(this.panX, this.panY, 0);
    this.renderer.render(this.scene, this.camera);
    if (this.hooks.onMove) this.hooks.onMove();
  }

  // ── the picked level ─────────────────────────────────────────────────
  pick(cell) {
    this.picked = cell;
    if (!this.T || !this.spin) return;
    const T = this.T;
    if (this.glow) { this.glow.parent.remove(this.glow); this.glow.children.forEach((c) => c.geometry.dispose()); this.glow = null; }
    if (cell && cell.row != null) {
      const a0 = this._apo(cell.row), a1 = this._apo(cell.row + 1), t = Math.tan(Math.PI / this.slots), y0 = this._yTop(cell.row), y1 = this._yTop(cell.row + 1), out = 0.006;
      const pts = [[-a0 * t, y0, a0 + out], [a0 * t, y0, a0 + out], [a1 * t, y1, a1 + out], [-a1 * t, y1, a1 + out]].map((p) => new T.Vector3(...p));
      const face = new T.BufferGeometry().setFromPoints([pts[0], pts[3], pts[1], pts[1], pts[3], pts[2]]);
      const group = new T.Group();
      group.rotation.y = cell.slot * this.step;
      group.add(new T.Mesh(face, this.glowMat), new T.LineLoop(new T.BufferGeometry().setFromPoints(pts), this.ringMat));
      this.spin.add(group);
      this.glow = group;
    }
    this.draw();
  }

  // Where a cell's side is on the stage (px), and how squarely it faces us (1 … −1).
  anchor(cell) {
    if (!this.T || !cell || cell.row == null) return null;
    const a = (this._apo(cell.row) + this._apo(cell.row + 1)) / 2, th = cell.slot * this.step;
    const v = new this.T.Vector3(a * Math.sin(th), (this._yTop(cell.row) + this._yTop(cell.row + 1)) / 2, a * Math.cos(th));
    this.spin.updateWorldMatrix(true, false);
    v.applyMatrix4(this.spin.matrixWorld).project(this.camera);
    return { x: ((v.x + 1) / 2) * this.stage.clientWidth, y: ((1 - v.y) / 2) * this.stage.clientHeight, facing: Math.cos(this.yaw + th) };
  }


  // ── hands (owner 2026-11-24: "we need it easier to spin and zoom etc. the controls are awkward") ──
  // One rule at every zoom, like a map:
  //   drag            sideways turns it, up/down moves along the levels (both at once); a flick keeps it turning
  //   right-drag / shift-drag / two fingers   moves it any way (pan); two fingers also pinch to zoom
  //   wheel / pinch / trackpad pinch          zooms toward the pointer, smoothly
  //   ctrl-drag / alt-drag                    tilts it
  //   tap a level     opens its tables · double-tap / double-click zooms in there
  //   keys            ← → turn a side · ↑ ↓ move · + − zoom · 0 or F fit
  // Letting go of a turn settles square on a side only when it is zoomed out far enough to see
  // the whole pyramid; zoomed in it stays where it was left, so reading along a level is easy.
  _hands() {
    const el = this.canvas, pts = new Map();
    el.tabIndex = 0;
    el.style.outline = 'none';
    let g = null, lastTap = 0, tapT = null;
    const per = () => (2 * Math.tan((this.camera.fov * Math.PI) / 360) * this.dist) / Math.max(1, this.stage.clientHeight);   // world units per pixel
    const ndc = (x, y) => { const r = el.getBoundingClientRect(); return [((x - r.left) / r.width) * 2 - 1, 1 - ((y - r.top) / r.height) * 2]; };
    const mid = () => { const a = [...pts.values()]; return { x: (a[0].x + a[1].x) / 2, y: (a[0].y + a[1].y) / 2, d: Math.hypot(a[0].x - a[1].x, a[0].y - a[1].y) || 1 }; };
    const begin = (e) => {
      const two = pts.size >= 2;
      const kind = two ? 'pinch' : (e.button === 2 || e.shiftKey) ? 'pan' : (e.ctrlKey || e.altKey) ? 'tilt' : 'turn';
      g = { kind, x: e.clientX, y: e.clientY, t: performance.now(), moved: two, yaw: this.yaw, pitch: this.pitch, panX: this.panX, panY: this.panY, dist: this.dist,
            hist: [{ t: performance.now(), yaw: this.yaw }], m: two ? mid() : null };
      cancelAnimationFrame(this._raf); this._raf = null;
      for (const k of ['yaw', 'pitch', 'dist', 'panX', 'panY']) this.to[k] = this[k];   // a touch stops whatever it was doing
    };
    el.addEventListener('contextmenu', (e) => e.preventDefault());
    el.addEventListener('pointerdown', (e) => {
      el.focus({ preventScroll: true });
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
      el.setPointerCapture(e.pointerId);
      begin(e);
    });
    el.addEventListener('pointermove', (e) => {
      if (!pts.has(e.pointerId) || !g) return;
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (g.kind === 'pinch' && pts.size >= 2) {
        const m = mid(), f = g.m.d / m.d, wpp = (2 * Math.tan((this.camera.fov * Math.PI) / 360) * g.dist) / this.stage.clientHeight;
        this.dist = this.to.dist = Math.min(this.total * 12, Math.max(this.base * 1.08, g.dist * f));
        // the spot between the fingers stays between the fingers
        const [nx, ny] = ndc(m.x, m.y), t = Math.tan((this.camera.fov * Math.PI) / 360);
        this.panX = this.to.panX = g.panX - (m.x - g.m.x) * wpp + nx * t * this.camera.aspect * (g.dist - this.dist);
        this.panY = this.to.panY = g.panY + (m.y - g.m.y) * wpp + ny * t * (g.dist - this.dist);
        this._auto = false; this.draw();
        return;
      }
      const dx = e.clientX - g.x, dy = e.clientY - g.y;
      if (!g.moved && Math.hypot(dx, dy) < 5) return;
      g.moved = true;
      this.stage.classList.add('dragging');
      if (g.kind === 'turn') {
        this.yaw = this.to.yaw = g.yaw + dx * 0.006;
        this.panY = this.to.panY = this._clampY(g.panY + dy * per());
        g.hist.push({ t: performance.now(), yaw: this.yaw }); if (g.hist.length > 6) g.hist.shift();
      } else if (g.kind === 'pan') {
        this.panX = this.to.panX = this._clampX(g.panX - dx * per());
        this.panY = this.to.panY = this._clampY(g.panY + dy * per());
        this._auto = false;
      } else {
        this.pitch = this.to.pitch = Math.max(-0.25, Math.min(this.lean + 0.6, g.pitch + dy * 0.005));
      }
      this.draw();
    });
    const end = (e) => {
      if (!pts.has(e.pointerId)) return;
      pts.delete(e.pointerId);
      if (!g) return;
      if (pts.size === 1) { const [id, p] = [...pts.entries()][0]; begin({ clientX: p.x, clientY: p.y, button: 0, pointerId: id }); g.moved = true; return; }   // pinch → one finger carries on
      if (pts.size) return;
      const d = g; g = null;
      this.stage.classList.remove('dragging');
      if (d.kind === 'turn' && d.moved) {
        // a flick carries on turning, then (zoomed out) settles square on a side
        const h = d.hist, a = h[0], b = h[h.length - 1], dt = Math.max(16, b.t - a.t);
        const v = performance.now() - b.t < 80 ? (b.yaw - a.yaw) / dt : 0;
        let yaw = this.yaw + v * 260;
        if (!this._close()) yaw = Math.round(yaw / this.step) * this.step;
        this.to.yaw = yaw;
        this._ease();
        return;
      }
      if (d.moved || performance.now() - d.t > 500) return;
      // a tap: open that level · two taps: zoom in there
      const now = performance.now(), at = { clientX: e.clientX, clientY: e.clientY };
      if (now - lastTap < 320) { clearTimeout(tapT); lastTap = 0; const [nx, ny] = ndc(at.clientX, at.clientY); this.zoomBy(2.2, nx, ny); return; }
      lastTap = now;
      tapT = setTimeout(() => { const cell = this._hit(at); if (cell && this.hooks.onPick) this.hooks.onPick(cell); }, 260);
    };
    el.addEventListener('pointerup', end);
    el.addEventListener('pointercancel', end);
    el.addEventListener('wheel', (e) => {
      e.preventDefault();
      const [nx, ny] = ndc(e.clientX, e.clientY);
      const line = e.deltaMode === 1 ? 33 : e.deltaMode === 2 ? 400 : 1;
      const dy = e.deltaY * line, dx = e.deltaX * line;
      if (!e.ctrlKey && Math.abs(dx) > Math.abs(dy) * 0.6 && Math.abs(dx) > 1) {   // a trackpad's sideways swipe turns it
        this.to.yaw += dx * 0.003; this._ease(); return;
      }
      this.zoomBy(Math.exp(-dy * (e.ctrlKey ? 0.01 : 0.0018)), nx, ny);   // ctrl = a trackpad pinch: it sends small numbers
    }, { passive: false });
    el.addEventListener('keydown', (e) => {
      const k = e.key, move = 0.12 * this.dist * Math.tan((this.camera.fov * Math.PI) / 360) * 2;
      if (k === 'ArrowLeft' || k === 'ArrowRight') this.turn(k === 'ArrowRight' ? 1 : -1);
      else if (k === 'ArrowUp' || k === 'ArrowDown') { this.to.panY = this._clampY(this.to.panY + (k === 'ArrowUp' ? move : -move)); this._ease(); }
      else if (k === '+' || k === '=') this.zoomBy(1.3);
      else if (k === '-' || k === '_') this.zoomBy(1 / 1.3);
      else if (k === '0' || k === 'f' || k === 'F') this.fit();
      else return;
      e.preventDefault();
    });
  }
  // keep it on the screen: never slide the pyramid wholly out of view
  _clampX(x) { return Math.max(-this.base, Math.min(this.base, x)); }
  _clampY(y) { return Math.max(-this.total / 2, Math.min(this.total / 2, y)); }

  // The league under the pointer: its words, or the side of the level they are on.
  _hit(e) {
    const T = this.T, r = this.canvas.getBoundingClientRect();
    const ray = new T.Raycaster();
    ray.setFromCamera(new T.Vector2(((e.clientX - r.left) / r.width) * 2 - 1, 1 - ((e.clientY - r.top) / r.height) * 2), this.camera);
    const hit = ray.intersectObjects([...this.labels, ...this.blocks], false)[0];
    if (!hit) return null;
    if (hit.object.userData.cell) return hit.object.userData.cell;
    const row = this.rows[hit.object.userData.row];
    if (!row || !row.cells.length) return null;
    const p = this.spin.worldToLocal(hit.point.clone()), n = this.slots;
    const slot = ((Math.round(Math.atan2(p.x, p.z) / this.step) % n) + n) % n;
    return row.cells.find((c) => c.slot === slot) || row.cells[0];   // a bare side brings that level's league round
  }

  dispose() {
    this.dead = true;
    if (this._raf) cancelAnimationFrame(this._raf);
    if (this._ro) this._ro.disconnect();
    if (this.glow) this.glow.children.forEach((c) => c.geometry.dispose());
    (this.own || []).forEach((o) => o.dispose && o.dispose());
    if (this.renderer) { this.renderer.dispose(); this.renderer.forceContextLoss(); }
    if (this.canvas) this.canvas.remove();
  }
}

window.PyramidSolid = PyramidSolid;
