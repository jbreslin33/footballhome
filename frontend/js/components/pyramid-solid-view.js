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
  // the arrow lanes (units on the wall): lane spacing, the gutter between columns of tables, the
  // corridor under a row of tables — room for a few arrows side by side in each
  // (owner 2026-11-25: "lines are too close to edge of div/conf. give a little space beteeen lines and
  // confs and lines adn each other": lanes wider apart, a clear margin of CLEAR off every box)
  static LANE = 0.017;
  static CLEAR = 0.028;
  static GUTTER = 0.11;
  static CORRIDOR = 0.14;

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
    const placed = new Map();   // 'd12' / 'c3' → { slot, x } across its wall (0 left … 1 right), filled level by level
    this.rows.forEach((row, i) => {
      const w = 2 * (cap + grow * tops[i]) * Math.tan(half) * 0.92;
      row.cells.forEach((cell) => { cell.plan = this._planTables(cell, w, placed); this._noteAt(cell, placed); });
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
        plane.userData.draw = { row, w, h, font };   // to draw it again, sharper, when it is looked at close (_sharpen)
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
    if (this.hooks.crown && this.hooks.crown.length) this._crownSign(T, this.hooks.crown, font);
    if (this.picked) this.pick(this.picked);
  }

  // ── the tables ───────────────────────────────────────────────────────
  // Each table is one column, in full: pos · club · GP · GD ·
  // Pts, a zone colour down the left of a row (promotion / playoff / relegation, the same colours
  // as the 2D chart).  A table never folds.  More than a dozen tables (the UPSL's 35 conferences —
  // owner: "put upsl on the blank side") wrap onto further rows of tables, so the letters stay a
  // readable size instead of shrinking to nothing.
  // HOW MANY TABLES ACROSS (owner 2026-11-25: "it don't zoom in enogh … level 4 is where it becomws an
  // issue"): ten APSL conferences side by side on one row were ~1/25 of a tenth of the wall a letter.
  // Every count across, from all on one row down to one, is tried; the one with the BIGGEST letters
  // wins, as long as the level stays no taller than about half its width (a level never shrinks below
  // the all-on-one-row height).  Ties go to more across (a shorter level).
  _planTables(cell, w, placed) {
    const tables = cell.tables && cell.tables.length ? cell.tables : [{ name: '', rows: [], teams: [] }];
    const MAX = 12, most = Math.min(tables.length, MAX);
    const aim = this._aims(cell, tables, placed);
    let best = null;
    for (let across = most; across >= 1; across--) {
      const plan = this._planAcross(cell, tables, w, across, aim);
      if (!best) { best = plan; best.room = Math.max(plan.h, w * 0.5); continue; }
      if (plan.h > best.room) break;
      if (plan.fs > best.fs * 1.04) { plan.room = best.room; best = plan; }
    }
    return best;
  }
  // ── UNDER WHAT THEY FEED (owner 2026-11-25: "try best to avoid arrow going to far side to side. so be
  // smart about feeder and higher league placement") ──────────────────
  // A level whose tables carry promotion / relegation arrows keeps them in order ACROSS the wall
  // (column by column, not row by row), so the run of conferences reads left to right however it
  // wraps.  A feeder table sits in the column nearest the middle of what it feeds on the levels above
  // (its majority link; the outlier links of mig 1238 only when it has nothing else), as near straight
  // under as the columns allow, still in order and every table placed.  Levels without arrows (the
  // UPSL's conferences) keep their reading order.
  _parents() {
    if (this._up) return this._up;
    const up = new Map(), all = new Map();
    for (const e of this.edges) {
      const k = `d${e.from}`, to = e.to;
      if (!all.has(k)) all.set(k, []);
      all.get(k).push(to);
      if (e.majority !== false) { if (!up.has(k)) up.set(k, []); up.get(k).push(to); }
    }
    for (const [k, v] of all) if (!up.has(k)) up.set(k, v);
    const linked = new Set([...all.keys(), ...this.edges.map((e) => e.to)]);
    return (this._up = { up, linked });
  }
  // each table's aim (0 left … 1 right), or null when nothing on this level has an arrow
  _aims(cell, tables, placed) {
    if (!this.edges.length) return null;
    const { up, linked } = this._parents();
    if (!tables.some((t) => linked.has(t.node) || (t.conf && linked.has(t.conf)))) return null;
    const n = tables.length;
    return tables.map((t, k) => {
      const xs = (up.get(t.node) || []).map((p) => placed.get(p)).filter((p) => p && p.slot === cell.slot).map((p) => p.x);
      return xs.length ? xs.reduce((a, b) => a + b, 0) / xs.length : (k + 0.5) / n;   // nothing above: where it already stood
    });
  }
  // the tables into perRow columns: in aim order, each in the column nearest its aim that keeps the
  // order and leaves room for the rest; a column holds as many as the fewest rows need
  _slotsUnder(tables, perRow, aim) {
    const n = tables.length, R = Math.ceil(n / perRow), C = perRow;
    const order = tables.map((t, k) => k).sort((a, b) => (aim[a] - aim[b]) || a - b);
    const used = new Array(C).fill(0), out = new Array(n);
    let c0 = 0;
    order.forEach((k, j) => {
      while (c0 < C - 1 && used[c0] >= R) c0++;
      const left = n - j - 1;   // still to place after this one
      const room = (c) => (C - c) * R - used[c] - 1;   // seats left from column c on, once this one sits in it
      let c = Math.max(c0, Math.min(C - 1, Math.floor(aim[k] * C)));
      while (c > c0 && room(c) < left) c--;
      const t = tables[k];
      out[k] = { ...t, n: (t.rows && t.rows.length) || t.teams.length, gx: c, gr: used[c] };
      used[c]++; c0 = c;
    });
    return out;
  }
  // where this level's tables ended up, for the level under it to aim at
  _noteAt(cell, placed) {
    const plan = cell.plan;
    if (!plan || !plan.cols || !this.edges.length) return;
    const confs = new Map();
    for (const col of plan.cols) {
      const x = (col.gx + 0.5) / plan.perRow;
      if (col.node) placed.set(col.node, { slot: cell.slot, x });
      if (col.conf) { if (!confs.has(col.conf)) confs.set(col.conf, []); confs.get(col.conf).push(x); }
    }
    for (const [k, xs] of confs) placed.set(k, { slot: cell.slot, x: xs.reduce((a, b) => a + b, 0) / xs.length });
  }
  _planAcross(cell, tables, w, perRow, aim) {
    const HEAD = (cell.title ? 0.44 : 0.26) + (cell.banner ? 0.24 : 0), perLetter = 25;   // "Level N", then the league's name when it has one · pos 2 · club 15 · three figures 2.5 each, and gaps
    // ARROW LANES (owner 2026-11-25: "stacking the conferneces is better but then we need to make sure
    // there is enough space between to run the pro/rel aarroas … they should not go over or under
    // anything"): a level whose tables carry arrows leaves a gutter between columns and a corridor
    // under every row of tables, each wide enough for a few arrows side by side (PyramidSolid.LANE apart)
    const gut = aim ? PyramidSolid.GUTTER : 0, corridor = aim ? PyramidSolid.CORRIDOR : 0;
    const colW = w / perRow;
    const fs = Math.min(0.085, (colW - gut) / (perLetter - 1.2)), lh = fs * 1.32;
    const cols = aim ? this._slotsUnder(tables, perRow, aim)
      : tables.map((t, k) => ({ ...t, n: (t.rows && t.rows.length) || t.teams.length, gx: k % perRow, gr: Math.floor(k / perRow) }));
    const linesOf = (c) => c.n + (c.name ? 1.2 : 0) + (c.rows && c.rows.length ? 1 : 0);   // + the GP/GD/Pts head
    let gy = 0;
    for (let r = 0; r <= cols[cols.length - 1].gr; r++) {   // each row of tables as tall as its longest table
      const these = cols.filter((c) => c.gr === r);
      these.forEach((c) => { c.gy = gy; });
      gy += Math.max(...these.map(linesOf)) * lh + Math.max(lh * 0.9, corridor + lh * 0.45);   // + the box's own overhang
    }
    return { h: HEAD + gy + 0.06, fs, cols, head: HEAD, perRow, table: true, gut };
  }


  // px = pixels to the unit; by default a light picture (≤ 360 px a unit, ≤ 4096 wide), sharper on demand.
  _tables(T, cell, row, w, h, font, px) {
    const plan = cell.plan, c = document.createElement('canvas');
    const PX = px || Math.min(360, 4096 / w);
    c.width = Math.max(64, Math.round(w * PX)); c.height = Math.max(64, Math.round(h * PX));
    const g = c.getContext('2d'), W = c.width, u = PX;
    const fit = (text, size, weight, max) => { let s = size; do { g.font = `${weight} ${s}px ${font}`; s -= 2; } while (s > 12 && g.measureText(text).width > max); };
    g.textBaseline = 'middle'; g.textAlign = 'center';
    // "Level N" is the headline of every level (owner 2026-11-24: "the imoprtant thing is the Level x
    // txt"); the league's name, where the level has one league, sits under it, smaller
    const lvl = this.hooks.level ? this.hooks.level(cell.num) : '';   // the division number (cups: none)
    g.fillStyle = '#ffffff'; g.shadowColor = 'rgba(0,0,0,0.5)'; g.shadowBlur = 0.02 * u;
    // a league's top level carries its pyramid's header above "Level N" (owner 2026-11-25: "show at
    // top of pyramind the total amount of clubs in the pyrmaid and total levels … right above level 4")
    const B = cell.banner ? 0.24 : 0;
    // what the arrows must keep off, in the plane's units: x across from the middle, v down from its top
    const texts = plan.texts = [];
    const keep = (cx, cy, wpx, hpx) => texts.push({ l: ((cx - wpx / 2) / W - 0.5) * w, r: ((cx + wpx / 2) / W - 0.5) * w, top: (cy - hpx / 2) / u, foot: (cy + hpx / 2) / u });
    const keepText = (t, cy, size) => { if (t) keep(W / 2, cy, g.measureText(t).width, size * 1.1); };
    if (cell.banner) {
      fit(cell.banner, 0.12 * u, 800, W * 0.9);
      const bw = Math.min(W * 0.94, g.measureText(cell.banner).width + 0.14 * u), bh = 0.18 * u;
      g.shadowBlur = 0; g.fillStyle = 'rgba(251,191,36,0.95)';
      if (g.roundRect) { g.beginPath(); g.roundRect(W / 2 - bw / 2, 0.11 * u - bh / 2, bw, bh, bh / 2); g.fill(); } else g.fillRect(W / 2 - bw / 2, 0.11 * u - bh / 2, bw, bh);
      g.fillStyle = '#0b1220'; g.fillText(cell.banner, W / 2, 0.115 * u);
      keep(W / 2, 0.11 * u, bw, bh);
      g.fillStyle = '#ffffff'; g.shadowBlur = 0.02 * u;
    }
    fit(lvl, 0.16 * u, 800, W * 0.94); g.fillText(lvl, W / 2, (0.12 + B) * u); keepText(lvl, (0.12 + B) * u, 0.16 * u);
    g.shadowBlur = 0;
    g.fillStyle = row.kind === 'empty' ? 'rgba(255,255,255,0.55)' : 'rgba(255,255,255,0.88)';
    if (cell.title) { fit(cell.title, 0.1 * u, 700, W * 0.94); g.fillText(cell.title, W / 2, (0.28 + B) * u); keepText(cell.title, (0.28 + B) * u, 0.1 * u); }
    if (cell.title && cell.sub) { g.fillStyle = 'rgba(255,255,255,0.65)'; fit(cell.sub, 0.06 * u, 600, W * 0.94); g.fillText(cell.sub, W / 2, (0.38 + B) * u); keepText(cell.sub, (0.38 + B) * u, 0.06 * u); }
    const fs = plan.fs * u, lh = fs * 1.32, colW = W / (plan.perRow || plan.cols.length), pad = fs * 0.6;
    plan.cols.forEach((col) => {
      const k = col.gx, top = (plan.head + col.gy) * u;
      const gut = (plan.gut || 0) * u / 2;   // half the arrow gutter each side of the column
      const x0 = k * colW + gut + pad, x1 = (k + 1) * colW - gut - pad, inner = x1 - x0;
      const xPos = x0 + fs * 1.1, xName = x0 + fs * 2.6, xPts = x1, xGd = x1 - fs * 2.6, xGp = x1 - fs * 5.2, nameW = xGp - fs * 2.2 - xName;
      let y = top + lh / 2;
      // the box behind the table, so it reads as one table on the wall (none for a level with no clubs)
      if (!col.n && !col.name) return;
      g.fillStyle = 'rgba(8,13,26,0.42)';
      const boxH = (col.n + (col.name ? 1.2 : 0) + 1) * lh + lh * 0.3;
      g.fillRect(x0 - pad * 0.5, top - lh * 0.15, inner + pad, boxH);
      col.box = { l: ((x0 - pad * 0.5) / W - 0.5) * w, r: ((x1 + pad * 0.5) / W - 0.5) * w, top: (top - lh * 0.15) / u, foot: (top - lh * 0.15 + boxH) / u };
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
  // conference) it goes up to — a green head at the top where it promotes, a red one at the bottom
  // where it relegates.  All the levels lie on one slope, so a point on a side is (x across, h down
  // from the cap) and a straight line in (x, h) is a straight line on the wall.
  //
  // ROUTED THROUGH THE LANES (owner 2026-11-25: "they should not go over or under anything"): each
  // side is a grid of lanes PyramidSolid.LANE apart; every table box and every heading ("Level N",
  // the league, the gold header) is blocked with a margin, and so is everything off the wall.  Each
  // arrow is the cheapest path through what is left (A*: a step costs 1, a turn more, a lane another
  // arrow already took a lot more), leaving a table's top edge straight up and arriving at the foot
  // of what it feeds straight in.  Arrows that share a gutter or corridor take lanes side by side.
  // Short ones first, so the long ones go round them.  An arrow with no way through keeps the old
  // curve, so no link ever disappears.
  _arrows(T) {
    const tanHalf = Math.tan(Math.PI / this.slots), slopeOf = this._slopeOf;
    const at = new Map();     // 'd12' / 'c3' → { slot, parts: [{ l, r, x, top, foot }] } in (x, h)
    const keep = new Map();   // slot → every box and heading to keep off, in (x, h)
    const keepOf = (slot) => { if (!keep.has(slot)) keep.set(slot, []); return keep.get(slot); };
    this.rows.forEach((row, i) => row.cells.forEach((cell) => {
      const slope = (this._tops[i + 1] - this._tops[i]) * slopeOf;
      const h = (v) => this._tops[i] + (0.01 * slope + v) / slopeOf;   // a distance down the plane → height
      const toH = (b) => ({ l: b.l, r: b.r, x: (b.l + b.r) / 2, top: h(b.top), foot: h(b.foot) });
      const k = keepOf(cell.slot);
      for (const t of cell.plan.texts || []) k.push(toH(t));
      for (const col of cell.plan.cols || []) {
        if (!col.box) continue;
        const part = toH(col.box);
        k.push(part);
        for (const key of [col.node, col.conf]) {
          if (!key) continue;
          if (!at.has(key)) at.set(key, { slot: cell.slot, parts: [] });
          at.get(key).parts.push(part);   // a conference is the run of its tables
        }
      }
    }));
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
    const HEADLEN = R * 9;
    const head = new T.ConeGeometry(R * 2.4, HEADLEN, 10);
    this.own.push(head);

    // the lane grid of one side
    const s = Math.max(PyramidSolid.LANE, R * 3.5), dh = s / slopeOf, m = Math.max(PyramidSolid.CLEAR, s * 1.5), mh = m / slopeOf;
    const stub = Math.ceil((HEADLEN * 1.2) / s);   // rows of straight line at each end, for the head
    const grids = new Map();
    const gridOf = (slot) => {
      if (grids.has(slot)) return grids.get(slot);
      const X = Math.ceil(((this._cap + this._grow * this.total) * tanHalf) / s), nx = 2 * X + 1, ny = Math.ceil(this.total / dh) + 1;
      const block = new Uint8Array(nx * ny), used = new Uint8Array(nx * ny), near = new Uint8Array(nx * ny);
      for (let j = 0; j < ny; j++) {   // off the wall
        const lim = (this._cap + this._grow * j * dh) * tanHalf - s;
        for (let i = 0; i < nx; i++) if (Math.abs((i - X) * s) > lim) block[j * nx + i] = 1;
      }
      for (const b of keepOf(slot)) {
        const i0 = Math.max(0, Math.ceil((b.l - m) / s) + X), i1 = Math.min(nx - 1, Math.floor((b.r + m) / s) + X);
        const j0 = Math.max(0, Math.ceil((b.top - mh) / dh)), j1 = Math.min(ny - 1, Math.floor((b.foot + mh) / dh));
        for (let j = j0; j <= j1; j++) block.fill(1, j * nx + i0, j * nx + i1 + 1);
      }
      const g = { X, nx, ny, block, used, near };
      grids.set(slot, g);
      return g;
    };
    // the ends an arrow may use on a box: across its middle, straight off the edge (up off a table's
    // top, down off a foot) until `stub` free rows in a row — those rows are the end of the line
    const ends = (g, part, dir) => {
      const list = [], q = (part.r - part.l) * 0.3;
      const i0 = Math.ceil((part.x - q) / s) + g.X, i1 = Math.floor((part.x + q) / s) + g.X;
      for (let i = i0; i <= i1; i++) {
        if (i < 0 || i >= g.nx) continue;
        let j = Math.round((dir < 0 ? part.top : part.foot) / dh), free = 0, j0 = j;
        while (j >= 0 && j < g.ny && free < stub) {
          if (g.block[j * g.nx + i]) { if (free) break; j0 = j + dir; } else free++;
          j += dir;
        }
        if (free < stub) continue;
        list.push({ i, j: j - dir, j0, x: (i - g.X) * s, h: dir < 0 ? part.top : part.foot, cost: Math.abs(j - dir - j0) });
      }
      return list;
    };
    const route = (g, starts, goals) => {
      const jA = Math.min(...goals.map((e) => e.j)), jB = Math.max(...starts.map((e) => e.j));
      if (jA > jB) return null;
      const rows = jB - jA + 1, N = rows * g.nx * 4;
      const cost = new Float32Array(N).fill(Infinity), from = new Int32Array(N).fill(-1);
      const goalAt = new Map(goals.map((e) => [e.j * g.nx + e.i, e]));
      const gx0 = Math.min(...goals.map((e) => e.i)), gx1 = Math.max(...goals.map((e) => e.i));
      const gj = Math.max(...goals.map((e) => e.j));
      const guess = (i, j) => Math.max(0, j - gj) + Math.max(0, gx0 - i, i - gx1);   // rows still to climb + lanes still to cross
      const heap = [];   // [f, state]
      const push = (f, st) => { heap.push([f, st]); let k = heap.length - 1; while (k) { const p = (k - 1) >> 1; if (heap[p][0] <= heap[k][0]) break; [heap[p], heap[k]] = [heap[k], heap[p]]; k = p; } };
      const pop = () => { const top = heap[0], last = heap.pop(); if (heap.length) { heap[0] = last; let k = 0; for (;;) { const a = 2 * k + 1, b = a + 1; let c = k; if (a < heap.length && heap[a][0] < heap[c][0]) c = a; if (b < heap.length && heap[b][0] < heap[c][0]) c = b; if (c === k) break; [heap[c], heap[k]] = [heap[k], heap[c]]; k = c; } } return top; };
      const idx = (i, j, d) => (((j - jA) * g.nx + i) << 2) | d;
      for (const e of starts) { const k = e.j * g.nx + e.i, c0 = e.cost + (g.used[k] ? 40 : 0) + (g.near[k] ? 8 : 0), st = idx(e.i, e.j, 0); cost[st] = c0; push(c0 + guess(e.i, e.j), st); }
      const DI = [0, 0, -1, 1], DJ = [-1, 1, 0, 0], TURN = 6, BUSY = 40, NEAR = 8;
      let goal = -1;
      while (heap.length) {
        const [f, st] = pop(), c = cost[st], d = st & 3, cell = st >> 2, i = cell % g.nx, j = jA + Math.floor(cell / g.nx);
        if (f - guess(i, j) > c + 1e-6) continue;
        const ge = goalAt.get(j * g.nx + i);
        if (ge && d === 0) { goal = st; break; }   // arriving moving up, into the stub
        for (let nd = 0; nd < 4; nd++) {
          if ((d ^ nd) === 1 && d < 2 === nd < 2) continue;   // no turning straight back
          const ni = i + DI[nd], nj = j + DJ[nd];
          if (ni < 0 || ni >= g.nx || nj < jA || nj > jB) continue;
          const k = nj * g.nx + ni;
          if (g.block[k]) continue;
          const nc = c + 1 + (nd !== d ? TURN : 0) + (g.used[k] ? BUSY : 0) + (g.near[k] ? NEAR : 0), ns = idx(ni, nj, nd);
          if (nc < cost[ns]) { cost[ns] = nc; from[ns] = st; push(nc + guess(ni, nj), ns); }
        }
      }
      if (goal < 0) return null;
      const cells = [];
      for (let st = goal; st >= 0; st = from[st]) { const cell = st >> 2; cells.push([cell % g.nx, jA + Math.floor(cell / g.nx)]); }
      cells.reverse();
      const [si, sj] = cells[0], [ei, ej] = cells[cells.length - 1];
      return { cells, start: starts.find((e) => e.i === si && e.j === sj), end: goalAt.get(ej * g.nx + ei) };
    };

    const group = new T.Group();
    let lost = 0;
    const jobs = [];
    for (const e of this.edges) {
      const a = at.get(`d${e.from}`), b = at.get(e.to);
      if (!a || !b || a.slot !== b.slot) continue;
      const src = a.parts[0], tops = b.parts.filter((p) => p.foot < src.top);
      if (!src || !tops.length) continue;
      const bx = tops.reduce((t, p) => t + p.x, 0) / tops.length;
      jobs.push({ e, slot: a.slot, src, tops, far: Math.abs(bx - src.x) + (src.top - Math.max(...tops.map((p) => p.foot))) });
    }
    jobs.sort((p, q) => p.far - q.far);
    for (const { e, slot, src, tops } of jobs) {
      const g = gridOf(slot);
      const starts = ends(g, src, -1), goals = tops.flatMap((p) => ends(g, p, 1));
      const path = starts.length && goals.length ? route(g, starts, goals) : null;
      let pts;
      if (path) {
        // the corners of the path in (x, h), from the table's top edge to the foot it goes up to
        const P = [[path.start.x, path.start.h]];
        const take = (i, j) => {   // this lane is taken; the lanes either side are "near"
          g.used[j * g.nx + i] = 1;
          for (const [di, dj] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) { const a = i + di, b = j + dj; if (a >= 0 && a < g.nx && b >= 0 && b < g.ny) g.near[b * g.nx + a] = 1; }
        };
        for (const [i, j] of path.cells) { take(i, j); P.push([(i - g.X) * s, j * dh]); }
        for (let j = path.start.j0; j !== path.start.j; j += Math.sign(path.start.j - path.start.j0 || 1)) take(path.start.i, j);
        for (let j = path.end.j0; j !== path.end.j; j += Math.sign(path.end.j - path.end.j0 || 1)) take(path.end.i, j);
        P.push([path.end.x, path.end.h]);
        const C = [P[0]];
        for (let k = 1; k < P.length - 1; k++) {
          const [ax, ah] = C[C.length - 1], [bx, bh] = P[k], [cx, ch] = P[k + 1];
          if (Math.abs((bx - ax) * (ch - bh) - (bh - ah) * (cx - bx)) > 1e-9) C.push(P[k]);
        }
        C.push(P[P.length - 1]);
        pts = C.map(([x, h]) => onWall(slot, x, h));
      } else {
        lost++;
        const x1 = src.x, h1 = src.top, x2 = tops[0].x, h2 = tops[0].foot;
        pts = [];
        for (let k = 0; k <= 24; k++) {   // the old curve: straight up, across in the middle, straight in
          const t = k / 24, mt = 1 - t, mid = (h1 + h2) / 2;
          pts.push(onWall(slot, mt * mt * mt * x1 + 3 * mt * mt * t * x1 + 3 * mt * t * t * x2 + t * t * t * x2,
                          mt * mt * mt * h1 + 3 * mt * mt * t * mid + 3 * mt * t * t * mid + t * t * t * h2));
        }
      }
      // straight runs with small round corners
      const curve = new T.CurvePath();
      const rr = s * 0.9;
      let from = pts[0];
      for (let k = 1; k < pts.length; k++) {
        const p = pts[k], next = pts[k + 1];
        if (!path || !next) { curve.add(new T.LineCurve3(from, p)); from = p; continue; }
        const inLen = p.distanceTo(from), outLen = p.distanceTo(next), r = Math.min(rr, inLen / 2, outLen / 2);
        const a = p.clone().sub(from).normalize().multiplyScalar(-r).add(p), b = next.clone().sub(p).normalize().multiplyScalar(r).add(p);
        curve.add(new T.LineCurve3(from, a)); curve.add(new T.QuadraticBezierCurve3(a, p, b)); from = b;
      }
      const tube = new T.TubeGeometry(curve, Math.max(24, curve.curves.length * 6), R, 6, false);
      group.add(new T.Mesh(tube, line)); this.own.push(tube);
      const tip = (end, toward, mat) => {   // a cone whose point touches `end`, pointing away from `toward`
        const dir = end.clone().sub(toward).normalize(), cone = new T.Mesh(head, mat);
        cone.position.copy(end).addScaledVector(dir, -HEADLEN / 2);
        cone.quaternion.setFromUnitVectors(new T.Vector3(0, 1, 0), dir);
        group.add(cone);
      };
      const n = pts.length;
      if (e.up) tip(pts[n - 1], pts[n - 2], up);
      if (e.down) tip(pts[0], pts[1], down);
    }
    if (lost) console.warn(`[pyramid] ${lost} arrow(s) found no clear lane — drawn on the old curve`);
    this.spin.add(group);
  }

  // THE CROWN (owner 2026-11-25: "American pyramid at top. number of levels and number of clubs" ·
  // "make the "crown" the shape of a pyramid and viewable from all sides" · "either dup it on all sides
  // or have it wrap"): a small gold pyramid floating over the apex, as many sides as the big one and
  // turned the same way, the same words on every face — readable whichever side is toward you.
  // a face's foot wide enough to read with the whole pyramid on screen; squat, the words sit low
  _crownDims() {
    const half = Math.PI / this.slots, faceW = 2 * this.base * Math.tan(half) * 0.62;
    return { faceW, A: faceW / 2 / Math.tan(half), Hc: faceW * 0.75, gap: 0.25 };
  }
  _crownSign(T, lines, font) {
    const n = this.slots, half = Math.PI / n, step = (2 * Math.PI) / n;
    const { faceW, A, Hc, gap } = this._crownDims();
    const slant = Math.hypot(A, Hc), lean = Math.atan(A / Hc);
    // one face: a gold triangle, the words in its wide lower part
    const W = 1400, H = Math.round(W * slant / faceW), c = document.createElement('canvas');
    c.width = W; c.height = H;
    const g = c.getContext('2d');
    g.fillStyle = '#fbbf24';
    g.beginPath(); g.moveTo(W / 2, 0); g.lineTo(W, H); g.lineTo(0, H); g.closePath(); g.fill();
    g.strokeStyle = 'rgba(120,80,0,0.9)'; g.lineWidth = 10; g.stroke();
    const widthAt = (y) => (W * y) / H * 0.84;   // room across at height y, inside the slanting edges
    // largest size where the lines, stacked up from the foot, each fit across where they sit
    const plan = (size) => {
      const out = [], big = size * 1.25;
      g.font = `700 ${size}px ${font}`;
      const words = (lines[1] || '').split(' ').filter(Boolean), wrap = [];
      let y = H - size * 0.9;   // bottom line's middle
      // fill from the bottom: the widest room first, so build the deep line backwards
      let cur = [];
      for (let k = words.length - 1; k >= 0; k--) {
        const next = [words[k], ...cur].join(' ');
        if (cur.length && g.measureText(next).width > widthAt(y - size * 0.6)) { wrap.unshift({ t: cur.join(' '), y }); y -= size * 1.18; cur = [words[k]]; }
        else cur = [words[k], ...cur];
      }
      if (cur.length) { wrap.unshift({ t: cur.join(' '), y }); y -= size * 1.18; }
      if (wrap.some((l) => { g.font = `700 ${size}px ${font}`; return g.measureText(l.t).width > widthAt(l.y - size * 0.6); })) return null;
      y -= size * 0.35;
      g.font = `800 ${big}px ${font}`;
      // the headline, split at its dots onto as many lines as its room needs
      const parts = lines[0].split(' · '), head = [];
      let line = '';
      for (let k = parts.length - 1; k >= 0; k--) {
        const next = line ? `${parts[k]} · ${line}` : parts[k];
        if (line && g.measureText(next).width > widthAt(y - big * 0.6)) { head.unshift({ t: line, y }); y -= big * 1.15; line = parts[k]; }
        else line = next;
      }
      if (line) head.unshift({ t: line, y });
      if (head.some((l) => g.measureText(l.t).width > widthAt(l.y - big * 0.6)) || head[0].y - big < H * 0.12) return null;
      return { size, big, head, wrap };
    };
    let best = null;
    for (let size = 110; size >= 24 && !best; size -= 4) best = plan(size);
    if (best) {
      g.textAlign = 'center'; g.textBaseline = 'middle';
      g.fillStyle = '#0b1220'; g.font = `800 ${best.big}px ${font}`;
      best.head.forEach((l) => g.fillText(l.t, W / 2, l.y));
      g.fillStyle = 'rgba(11,18,32,0.85)'; g.font = `700 ${best.size}px ${font}`;
      best.wrap.forEach((l) => g.fillText(l.t, W / 2, l.y));
    }
    const tex = new T.CanvasTexture(c);
    tex.colorSpace = T.SRGBColorSpace;
    tex.anisotropy = this.renderer.capabilities.getMaxAnisotropy();
    const mat = new T.MeshBasicMaterial({ map: tex, alphaTest: 0.5, side: T.DoubleSide });
    const geo = new T.PlaneGeometry(faceW, slant);
    const crown = new T.Group();
    crown.position.y = this.total / 2 + gap;   // its foot, a little over the apex
    for (let k = 0; k < n; k++) {
      const plane = new T.Mesh(geo, mat);
      plane.position.set(0, Hc / 2, A / 2);
      plane.rotation.x = -lean;
      const pivot = new T.Group();
      pivot.rotation.y = k * step;
      pivot.add(plane); crown.add(pivot);
    }
    this.spin.add(crown);
    this.own.push(tex, mat, geo);
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
    // the rail on the right (PyramidShapeView) takes its width: the pyramid centres in what is left
    const off = Math.round(w * this.shift + this._inset() / 2);
    if (off) this.camera.setViewOffset(w, h, off, 0, w, h); else this.camera.clearViewOffset();
    this.camera.updateProjectionMatrix();
  }
  _inset() { const r = this.stage.querySelector('.sh-rail'); return r && r.offsetWidth ? r.offsetWidth + 10 : 0; }
  _room() { const w = this.stage.clientWidth || 1; return Math.max(0.3, (w - this._inset()) / w) * (this.shift ? 0.54 : 1); }
  setShift(on) {
    const wide = this.stage.clientWidth > 760;
    this.shift = on && wide ? 0.23 : 0;
    if (this.camera) { this._view(); this.draw(); }
  }

  fit(now) {
    // Far enough back that every corner of the cap and of the foot is inside the frame — square
    // on a side or corner-on, at the resting tilt.  A short, wide stack (two levels) needs this:
    // its foot comes well toward the eye.
    const t = Math.tan((this.camera.fov * Math.PI) / 360), room = this._room(), keep = 0.94;
    const p = this.lean * 0.55, half = Math.PI / this.slots;
    let dist = 0;
    const crown = this.hooks.crown && this.hooks.crown.length ? this._crownDims() : null;   // the crown's tip has to be on screen too
    const pts = [[this._apo(0), this.total / 2], [this.base, -this.total / 2]];
    if (crown) pts.push([crown.A, this.total / 2 + crown.gap], [0.001, this.total / 2 + crown.gap + crown.Hc]);
    for (const [a, y] of pts) {
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
    this.to.dist = Math.min(this.total * 12, Math.max(this._minDist(this.to.panY), was / f));
    this.to.panX = this._clampX(this.to.panX + nx * t * this.camera.aspect * (was - this.to.dist));
    this.to.panY = this._clampY(this.to.panY + ny * t * (was - this.to.dist));
    this._auto = false;
    this._ease();
  }
  // HOW CLOSE (owner 2026-11-25: "it don't zoom in enogh … level 4 is where it becomws an issue"): the
  // camera may come up to the facing wall AT THE HEIGHT IT LOOKS AT, not only to the foot — the old
  // floor (1.02 × the foot's apothem) kept it a long way off the narrower levels up the slope.
  // The front wall's centre line, tilted as it rests, is walked level by level to find where it
  // crosses the camera's height; the camera stops a hair in front of it.
  _wallZ(y) {
    if (!this._tops) return this.base;
    const p = this.to.pitch, n = this.rows.length;
    const at = (i) => { const yy = this._yTop(i), z = this._apo(i); return [yy * Math.cos(p) - z * Math.sin(p), yy * Math.sin(p) + z * Math.cos(p)]; };
    let prev = at(0);
    if (y >= prev[0]) return prev[1];
    for (let i = 1; i <= n; i++) {
      const cur = at(i);
      if (y >= cur[0]) { const f = (prev[0] - y) / ((prev[0] - cur[0]) || 1); return prev[1] + (cur[1] - prev[1]) * f; }
      prev = cur;
    }
    return prev[1];
  }
  _minDist(y) { return this._wallZ(y) + Math.max(0.12, this.base * 0.04); }
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
  // Turn to a side AND fill the screen with its own levels (owner 2026-11-24: "its blank" — a side
  // seen whole from the fitted distance has its tables a few pixels tall).  The close view then
  // sharpens by itself (_sharpen).
  // only = row indexes to fill the screen with (a rail level button: one level of that side)
  focus(slot, only) {
    const rows = only && only.length ? only.slice().sort((a, b) => a - b) : this.rows.map((r, i) => (r.cells.some((c) => c.slot === slot) ? i : -1)).filter((i) => i >= 0);
    if (!rows.length) return this.face(slot);
    this.face(slot);
    const first = rows[0], last = rows[rows.length - 1];
    const yT = this._yTop(first), yB = this._yTop(last + 1), mid = (yT + yB) / 2, tall = (yT - yB) / Math.cos(this.lean);
    const t = Math.tan((this.camera.fov * Math.PI) / 360), room = this._room(), keep = 0.9;
    const half = Math.PI / this.slots, wide = 2 * this._apo(last + 1) * Math.tan(half);
    const a = this._apo((first + last + 1) / 2) || this._apo(first);
    const p = this.to.pitch;
    this.to.dist = Math.max(this._minDist(this._clampY(mid * Math.cos(p) - a * Math.sin(p))), a + Math.max(tall / 2 / (t * keep), wide / 2 / (t * this.camera.aspect * room * keep)));
    this.to.panX = 0;
    this.to.panY = this._clampY(mid * Math.cos(p) - a * Math.sin(p));
    this._auto = false;
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
    clearTimeout(this._sharpT);
    this._sharpT = setTimeout(() => this._sharpen(), 280);
  }

  // SHARP CLOSE UP (owner 2026-11-24: "it don't let me zoom in enought to see levels text of teams good
  // enough").  Every side is drawn once as a light picture, so its small table text is only ~10 px
  // tall and goes soft close in.  A moment after the pyramid stops moving, zoomed in, the sides in
  // view are drawn again at the most pixels the graphics card takes (≤ 8192 a side) — the club names
  // then ~30 px tall — and only those: at most four sharp at once, the rest go back to light, and
  // all of them go back when it is zoomed out.  Memory stays where it was.
  _sharpen() {
    if (this.dead || !this.T) return;
    const T = this.T, sharp = this._sharp || (this._sharp = new Map()), close = this.fitDist && this.dist < this.fitDist * 0.55;
    const back = (plane) => { this._redraw(plane, null); sharp.delete(plane); };
    if (!close) { [...sharp.keys()].forEach(back); if (!sharp.size) return; }
    // what is in view: rays through a grid of points on the screen
    const ray = new T.Raycaster(), seen = new Set();
    for (const x of [-0.7, -0.25, 0.25, 0.7]) for (const y of [-0.7, -0.25, 0.25, 0.7]) {
      ray.setFromCamera(new T.Vector2(x, y), this.camera);
      const hit = ray.intersectObjects([...this.labels, ...this.blocks], false)[0];
      if (hit && hit.object.userData.cell) seen.add(hit.object);
    }
    let changed = false;
    for (const plane of seen) {
      if (sharp.has(plane)) { sharp.set(plane, performance.now()); continue; }
      this._redraw(plane, this._maxPx(plane)); sharp.set(plane, performance.now()); changed = true;
    }
    // keep the four looked at last
    [...sharp.entries()].sort((a, b) => b[1] - a[1]).slice(4).forEach(([plane]) => { back(plane); changed = true; });
    if (changed) { this.renderer.render(this.scene, this.camera); }
  }
  _maxPx(plane) {
    const { w, h } = plane.userData.draw, cap = Math.min(8192, this.renderer.capabilities.maxTextureSize || 4096);
    return Math.max(1, Math.min(1400, cap / w, cap / h));
  }
  _redraw(plane, px) {
    const { row, w, h, font } = plane.userData.draw, old = plane.material.map;
    const tex = this._tables(this.T, plane.userData.cell, row, w, h, font, px || undefined);
    plane.material.map = tex; plane.material.needsUpdate = true;
    const at = this.own.indexOf(old);
    if (at >= 0) this.own[at] = tex; else this.own.push(tex);
    if (old) old.dispose();
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
        this.dist = this.to.dist = Math.min(this.total * 12, Math.max(this._minDist(this.panY), g.dist * f));
        // the spot between the fingers stays between the fingers
        const [nx, ny] = ndc(m.x, m.y), t = Math.tan((this.camera.fov * Math.PI) / 360);
        this.panX = this.to.panX = 0;   // up and down only
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
  _clampX() { return 0; }   // up and down only (owner 2026-11-25: "the pyrmaid has no need to go side to side so movmennt should be restricted to up and down")
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
    clearTimeout(this._sharpT);
    if (this._raf) cancelAnimationFrame(this._raf);
    if (this._ro) this._ro.disconnect();
    if (this.glow) this.glow.children.forEach((c) => c.geometry.dispose());
    (this.own || []).forEach((o) => o.dispose && o.dispose());
    if (this.renderer) { this.renderer.dispose(); this.renderer.forceContextLoss(); }
    if (this.canvas) this.canvas.remove();
  }
}

window.PyramidSolid = PyramidSolid;
