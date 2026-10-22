// frontend/js/game/pitch-planner.js
//
// Drag-and-drop pitch planner [FH] (James, 10/22: "can we make it so i can
// drag the 11v11 and the 7v7 field and rotate? ... turn it red if it is
// hitting something or too close ... calc a score for it on the fly").
//
// The DEFAULT view (James: "moving an 11v11 and 7v7 pitch should be
// default get rid of other stuff"): two outlines on the real site, the
// 11v11 (starts on cyan, the plan) and a 7v7, with pills on the left.
// Drag one to move it; ↺ / ↻ (or [ / ]) turn the selected one; SIZE
// cycles the 7v7's size; WATER toggles the water layer (runoff, flood
// areas, and live per-m² cells inside each pitch). Every move re-checks
// the rules the C++ sweep uses (lighthouse-planner-data.js, exported by
// game/scripts/export_lighthouse_planner_input.py --js; the geometry is a
// port of game/src/tools/field_planner_main.cpp) plus 10 yd between the
// two pitches, and re-scores the water: green = legal, red = the closest
// offences listed in the panel. Water rating (James: "percent of the
// perfect spot to the worst legal spot at 0 percent") = 100 % at the
// driest legal spot of that size anywhere in the park, 0 % at the
// wettest (data.ranges, from the sweep).

(function () {
  'use strict';

  const YD = 0.9144, FT = 0.3048, D2R = Math.PI / 180;
  const GAP = 10 * YD;                       // between the two pitches
  // Rules shown as a distance only, never an offence (James, 10/22: "don't
  // do 15 yards from main diamond just show how far").
  const INFO = { main_infield: true };
  const SEVEN_SIZES = [[70, 35], [65, 35], [60, 35], [55, 35], [60, 30]];
  const NAMES = {
    main_infield: 'main diamond infield', softball_skin: 'softball infield dirt',
    fence_3B: 'softball 3rd-base fence', backstop_1B: 'softball backstop / 1st-base fence',
    vendor: 'vendor fence', rodeo: 'rodeo fence', west_of_rodeo: 'past the rodeo fence',
    trees: 'a tree', north_of_vendor: 'past the vendor fence line', park: 'the park edge',
    cemetery: 'the cemetery', cemetery_edge: 'the cemetery', barn: 'the barn (event hall)',
    playground: 'the playground fence', rail_fence_0: 'village rail fence',
    rail_fence_1: 'village rail fence (east)', dirt_road_0: 'cemetery dirt road',
    dirt_road_1: 'dirt road spur', other: 'the other pitch',
  };

  // ── geometry (field_planner_main.cpp) ────────────────────────────────
  const segDist = (p, a, b) => {
    const dx = b[0] - a[0], dz = b[1] - a[1], l2 = dx * dx + dz * dz;
    const t = l2 === 0 ? 0 : Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dz) / l2));
    return Math.hypot(p[0] - a[0] - t * dx, p[1] - a[1] - t * dz);
  };
  const orient = (p, q, r) => (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0]);
  const crosses = (a, b, c, d) => orient(a, b, c) * orient(a, b, d) < 0 && orient(c, d, a) * orient(c, d, b) < 0;
  const inRect = (p, R) => {
    let sg = 0;
    for (let i = 0; i < 4; i++) {
      const s = orient(R[i], R[(i + 1) % 4], p) > 0 ? 1 : -1;
      if (!sg) sg = s; else if (s !== sg) return false;
    }
    return true;
  };
  const inPoly = (p, P) => {
    let c = false;
    for (let i = 0, j = P.length - 1; i < P.length; j = i++) {
      const a = P[i], b = P[j];
      if ((a[1] > p[1]) !== (b[1] > p[1]) && p[0] < (b[0] - a[0]) * (p[1] - a[1]) / (b[1] - a[1]) + a[0]) c = !c;
    }
    return c;
  };
  const rect = (cx, cz, th, L, W) => {
    const c = Math.cos(th), s = Math.sin(th);
    return [[-L / 2, -W / 2], [L / 2, -W / 2], [L / 2, W / 2], [-L / 2, W / 2]]
      .map(([u, v]) => [cx + u * c - v * s, cz + u * s + v * c]);
  };
  const rectDist = (R, rc, P, closed) => {
    const pts = closed ? P.concat([P[0]]) : P;
    let d = 1e9;
    for (let i = 0; i < 4; i++) {
      const a = R[i], b = R[(i + 1) % 4];
      for (let j = 0; j + 1 < pts.length; j++) {
        const c = pts[j], e = pts[j + 1];
        if (crosses(a, b, c, e)) return 0;
        d = Math.min(d, segDist(c, a, b), segDist(e, a, b), segDist(a, c, e), segDist(b, c, e));
      }
    }
    for (const p of P) if (inRect(p, R)) return 0;
    if (closed && inPoly(rc, P)) return 0;
    return d;
  };
  const lineZ = (P, slope, x) => {
    const n = P.length;
    if (x >= P[n - 1][0]) return P[n - 1][1] + slope * (x - P[n - 1][0]);
    if (x <= P[0][0]) return P[0][1];
    for (let i = 0; i + 1 < n; i++)
      if (P[i][0] <= x && x <= P[i + 1][0])
        return P[i][1] + (P[i + 1][1] - P[i][1]) * (x - P[i][0]) / (P[i + 1][0] - P[i][0]);
    return P[n - 1][1];
  };
  const lineX = (P, z) => {
    const n = P.length;
    if (z <= P[0][1]) return P[0][0];
    if (z >= P[n - 1][1]) return 1e9;
    for (let i = 0; i + 1 < n; i++)
      if (P[i][1] <= z && z <= P[i + 1][1])
        return P[i][0] + (P[i + 1][0] - P[i][0]) * (z - P[i][1]) / (P[i + 1][1] - P[i][1]);
    return 1e9;
  };
  const bbox = (P) => {
    const b = [1e18, -1e18, 1e18, -1e18];
    for (const [x, z] of P) { b[0] = Math.min(b[0], x); b[1] = Math.max(b[1], x); b[2] = Math.min(b[2], z); b[3] = Math.max(b[3], z); }
    return b;
  };

  // Every offence (not just the first), nearest-to-legal last so the panel
  // can show the worst first. have/need in metres; need 0 = must not touch.
  function offences(rules, R, c) {
    const out = [], rb = bbox(R);
    const add = (n, have, need) => out.push({ n, have, need });
    for (const r of rules) {
      if (INFO[r.n]) continue;
      if (r.k === 'poly') {
        const b = r.bb || (r.bb = bbox(r.pts));
        if (rb[0] - b[1] > r.min || b[0] - rb[1] > r.min || rb[2] - b[3] > r.min || b[2] - rb[3] > r.min) continue;
        const d = rectDist(R, c, r.pts, !!r.c);
        if (d < r.min) add(r.n, d, r.min);
      } else if (r.k === 'inside') {
        if (R.some((p) => !inPoly(p, r.pts))) add(r.n, 0, r.min);
        else { const d = rectDist(R, c, r.pts, false); if (d < r.min) add(r.n, d, r.min); }
      } else if (r.k === 'outside') {
        if (inPoly(c, r.pts) || R.some((p) => inPoly(p, r.pts))) add(r.n, 0, 0);
      } else if (r.k === 'below') {
        if (R.some((p) => p[1] >= lineZ(r.pts, r.slope, p[0]))) add(r.n, 0, 0);
      } else if (r.k === 'left') {
        if (R.some((p) => p[0] >= lineX(r.pts, p[1]))) add(r.n, 0, 0);
      } else if (r.k === 'points') {
        const reach = Math.hypot(R[0][0] - c[0], R[0][1] - c[1]) + r.min;
        let worst = 1e9;
        for (const t of r.pts) {
          if (Math.abs(t[0] - c[0]) > reach || Math.abs(t[1] - c[1]) > reach) continue;
          let d = inRect(t, R) ? 0 : 1e9;
          for (let i = 0; i < 4 && d > 0; i++) d = Math.min(d, segDist(t, R[i], R[(i + 1) % 4]));
          worst = Math.min(worst, d);
        }
        if (worst < r.min) add(r.n, worst, r.min);
      }
    }
    return out;
  }

  // Water on the lidar classes, sampled every metre over the pitch; cells
  // (optional) collects [u, v, class] for the live water layer. range =
  // data.ranges[size]: percent of the way from the wettest legal spot (0)
  // to the driest (100).
  function water(G, cx, cz, th, L, W, range, cells) {
    const ca = Math.cos(th), sa = Math.sin(th);
    let n = 0, pond = 0, flow = 0, flat = 0;
    for (let u = -L / 2 + 0.5; u < L / 2; u += 1)
      for (let v = -W / 2 + 0.5; v < W / 2; v += 1) {
        const i = Math.round(cx + u * ca - v * sa - G.x0), j = Math.round(cz + u * sa + v * ca - G.z0);
        n++;
        if (i < 0 || j < 0 || i >= G.nx || j >= G.nz) continue;
        const k = G.cls.charCodeAt(j * G.nx + i) - 48;
        if (k === 1) pond++; else if (k === 2) flow++; else if (k === 3) flat++;
        if (k && cells) cells.push(u, v, k);
      }
    const dens = (3 * pond + 1.5 * flow + 0.5 * flat) / n;
    const pct = range ? Math.max(0, Math.min(100, 100 * (range.worst - dens) / (range.worst - range.best))) : null;
    return { pond, flow, flat, n, dens, pct };
  }

  // ── the planner ──────────────────────────────────────────────────────
  function attach(renderer) {
    const DATA = window.LIGHTHOUSE_PLANNER;
    const LAY = window.LIGHTHOUSE_LAYOUT || {};
    if (!DATA || !window.THREE) return;
    const rp = LAY.realPitch || { x: 30, z: -33.5, rotDeg: 155 };
    const pitches = [
      { id: '11v11', size: [115, 74], x: rp.x, z: rp.z, rot: rp.rotDeg },
      // Driest legal 70 x 35 >= 10 yd off cyan (sweep, 10/22): beside the
      // main diamond, 31 yd off cyan.
      { id: '7v7', size: SEVEN_SIZES[0], x: -73, z: -9, rot: 52 },
    ];
    let on = false, sel = pitches[1], drag = null, justDragged = false, waterOn = true;
    const panel = document.createElement('div');
    panel.style.cssText = 'position:fixed;left:50%;transform:translateX(-50%);top:8px;z-index:20;display:block;' +
      'background:rgba(10,14,20,.86);color:#f4f6fb;font:12px system-ui,sans-serif;border-radius:10px;' +
      'padding:8px 10px;max-width:min(560px,calc(100vw - 16px));box-sizing:border-box;';
    document.body.appendChild(panel);

    const mk = (tag, css, text) => {
      const e = document.createElement(tag);
      e.style.cssText = css;
      if (text != null) e.textContent = text;
      return e;
    };
    const tap = (el, fn) => {
      el.addEventListener('click', (e) => { e.preventDefault(); e.stopPropagation(); fn(); });
      el.addEventListener('touchstart', (e) => { e.preventDefault(); e.stopPropagation(); fn(); });
    };
    const pill = 'min-width:0;min-height:0;padding:4px 9px;border-radius:12px;border:1px solid #889;' +
      'background:rgba(255,255,255,.1);color:#f4f6fb;font:600 12px system-ui,sans-serif;cursor:pointer;';
    const rows = {};
    for (const p of pitches) {
      const r = mk('div', 'display:flex;gap:6px;align-items:flex-start;padding:4px 6px;border-radius:8px;' +
        'cursor:pointer;margin-bottom:4px;');
      const go = mk('button', pill + 'flex:none;', '📍');
      go.title = 'Fly the camera to this pitch';
      tap(go, () => { sel = p; flyTo(p); paint(); });
      const txt = mk('div', 'flex:1;min-width:0;');
      r.appendChild(go);
      r.appendChild(txt);
      tap(txt, () => { sel = p; paint(); });
      panel.appendChild(r);
      rows[p.id] = txt;
    }
    const bar = mk('div', 'display:flex;gap:6px;flex-wrap:wrap;margin-top:4px;');
    const turn = (d) => { sel.rot = ((sel.rot + d) % 360 + 360) % 360; update(); };
    for (const [t, d] of [['↺ 5°', -5], ['↺ 1°', -1], ['↻ 1°', 1], ['↻ 5°', 5]]) {
      const b = mk('button', pill, t);
      let rep = null;
      const start = (e) => { e.preventDefault(); e.stopPropagation(); turn(d); rep = setInterval(() => turn(d), 150); };
      const stop = () => { if (rep) clearInterval(rep); rep = null; };
      b.addEventListener('mousedown', start);
      b.addEventListener('touchstart', start);
      for (const ev of ['mouseup', 'mouseleave', 'touchend', 'touchcancel']) b.addEventListener(ev, stop);
      bar.appendChild(b);
    }
    // ⭐ BEST: snap the selected pitch to the driest legal spot of its size
    // (the 100 % spot, data.ranges[size].at).
    const bestBtn = mk('button', pill + 'border-color:#ffd24d;', '⭐ BEST');
    tap(bestBtn, () => {
      const r = DATA.ranges[sel.size[0] + 'x' + sel.size[1]];
      if (!r || !r.at) return;
      sel.x = r.at[0]; sel.z = r.at[1]; sel.rot = r.at[2];
      update();
      flyTo(sel);
    });
    bar.appendChild(bestBtn);
    const sizeBtn = mk('button', pill);
    tap(sizeBtn, () => {
      const p = pitches[1];
      p.size = SEVEN_SIZES[(SEVEN_SIZES.indexOf(sizeOf(p.size)) + 1) % SEVEN_SIZES.length];
      rebuild(p);
      update();
    });
    bar.appendChild(sizeBtn);
    const copyBtn = mk('button', pill, 'COPY');
    tap(copyBtn, () => {
      const txt = pitches.map((p) => `${p.id} ${p.size[0]}x${p.size[1]} yd at (${p.x.toFixed(1)}, ${p.z.toFixed(1)}) ${p.rot.toFixed(0)}°` +
        ` — ${p.ev.ok ? 'OK' : 'BLOCKED'}, dry ${p.ev.w.pct.toFixed(0)}%, main infield ${(p.ev.infield / YD).toFixed(1)} yd`).join('\n');
      if (navigator.clipboard) navigator.clipboard.writeText(txt).catch(() => {});
      copyBtn.textContent = 'COPIED';
      setTimeout(() => { copyBtn.textContent = 'COPY'; }, 1200);
    });
    bar.appendChild(copyBtn);
    panel.appendChild(bar);

    // SPOTS (James: "click button to reset it there. allow for saving a
    // spot and delete a spot and give it a name"): built-in spots from
    // layout.planSpots + ones saved in this browser (localStorage). Tap a
    // spot = move the selected pitch there; 💾 saves where it is now; ✕
    // deletes a saved one.
    const SPOT_KEY = 'fh.lighthouse.planSpots.v1';
    const loadSaved = () => {
      try { return JSON.parse(localStorage.getItem(SPOT_KEY) || '[]'); } catch (e) { return []; }
    };
    const storeSaved = (list) => {
      try { localStorage.setItem(SPOT_KEY, JSON.stringify(list)); return true; } catch (e) { return false; }
    };
    const spotBox = mk('div', 'display:flex;gap:6px;flex-wrap:wrap;margin-top:6px;align-items:center;');
    panel.appendChild(spotBox);
    const sizeOf = (sz) => SEVEN_SIZES.find((q) => q[0] === sz[0] && q[1] === sz[1]) || sz;
    function applySpot(sp) {
      const p = pitches.find((q) => q.id === sp.pitch);
      if (!p) return;
      sel = p;
      p.x = sp.x; p.z = sp.z; p.rot = sp.rotDeg;
      if (sp.size && (sp.size[0] !== p.size[0] || sp.size[1] !== p.size[1])) { p.size = sizeOf(sp.size); rebuild(p); }
      update();
      flyTo(p);
    }
    function paintSpots() {
      spotBox.innerHTML = '';
      spotBox.appendChild(mk('span', 'opacity:.75;font-size:11px;', '📌 ' + sel.id + ' spots:'));
      const saved = loadSaved();
      const all = (LAY.planSpots || []).map((sp) => ({ sp, saved: false }))
        .concat(saved.map((sp, i) => ({ sp, saved: true, i })))
        .filter((e) => e.sp.pitch === sel.id);
      for (const e of all) {
        const b = mk('button', pill + (e.saved ? '' : 'border-color:#ffd24d;'), e.sp.name);
        b.title = `(${e.sp.x.toFixed(1)}, ${e.sp.z.toFixed(1)}) ${e.sp.rotDeg.toFixed(0)}°` +
          (e.sp.size ? ` ${e.sp.size[0]}×${e.sp.size[1]} yd` : '');
        tap(b, () => applySpot(e.sp));
        spotBox.appendChild(b);
        if (e.saved) {
          const x = mk('button', pill + 'padding:4px 7px;color:#ff8a94;', '✕');
          x.title = 'Delete "' + e.sp.name + '"';
          tap(x, () => {
            const list = loadSaved();
            list.splice(e.i, 1);
            storeSaved(list);
            paintSpots();
          });
          spotBox.appendChild(x);
        }
      }
      const name = document.createElement('input');
      name.placeholder = 'name this spot';
      name.style.cssText = 'min-width:0;width:130px;padding:4px 8px;border-radius:12px;border:1px solid #889;' +
        'background:rgba(255,255,255,.08);color:#f4f6fb;font:12px system-ui,sans-serif;';
      for (const ev of ['mousedown', 'touchstart', 'keydown']) name.addEventListener(ev, (e) => e.stopPropagation());
      const save = mk('button', pill, '💾 SAVE');
      const doSave = () => {
        const n = name.value.trim() || (sel.id + ' ' + new Date().toLocaleString());
        const list = loadSaved();
        list.push({ name: n, pitch: sel.id, x: +sel.x.toFixed(2), z: +sel.z.toFixed(2),
                    rotDeg: +sel.rot.toFixed(1), size: sel.size.slice() });
        if (!storeSaved(list)) save.textContent = '⚠ NOT SAVED';
        paintSpots();
      };
      tap(save, doSave);
      name.addEventListener('keydown', (e) => { if (e.key === 'Enter') doSave(); });
      spotBox.appendChild(name);
      spotBox.appendChild(save);
    }
    panel.appendChild(mk('div', 'opacity:.7;margin-top:4px;font-size:11px;',
      'Drag a pitch to move it · ↺ ↻ or [ ] to turn the selected one · red = too close to something (the main diamond is distance only)'));

    // Outline (4 strips + halfway) and a faint fill, in a group per pitch
    // turned like field.js's boxes, so a drag only moves the group.
    const fillMat = (c) => new THREE.MeshBasicMaterial({ color: c, transparent: true, opacity: 0.14,
      depthWrite: false, side: THREE.DoubleSide });
    function rebuild(p) {
      const site = renderer.field && renderer.field.site;
      if (!site) return;
      if (p.g) site.remove(p.g);
      const L = p.size[0] * YD, W = p.size[1] * YD, t = 0.6;
      const g = new THREE.Group();
      p.lineMat = new THREE.MeshBasicMaterial({ color: 0x33ff66, depthTest: false, side: THREE.DoubleSide });
      p.fill = new THREE.Mesh(new THREE.PlaneGeometry(L, W), fillMat(0x33ff66));
      p.fill.rotation.x = -Math.PI / 2;
      p.fill.renderOrder = 60;
      g.add(p.fill);
      for (const [w, d, x, z] of [[L, t, 0, -W / 2], [L, t, 0, W / 2], [t, W, -L / 2, 0], [t, W, L / 2, 0], [t, W, 0, 0]]) {
        const m = new THREE.Mesh(new THREE.PlaneGeometry(w, d), p.lineMat);
        m.rotation.x = -Math.PI / 2;
        m.position.set(x, 0, z);
        m.renderOrder = 61;
        g.add(m);
      }
      // Big name on the grass so it reads apart from the candidate outlines.
      const cv = document.createElement('canvas');
      cv.width = 512; cv.height = 128;
      const c2 = cv.getContext('2d');
      c2.font = 'bold 96px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
      c2.lineWidth = 14; c2.strokeStyle = 'rgba(0,0,0,.85)'; c2.strokeText(p.id, 256, 64);
      c2.fillStyle = '#ffffff'; c2.fillText(p.id, 256, 64);
      const lab = new THREE.Mesh(new THREE.PlaneGeometry(W * 0.8, W * 0.2),
        new THREE.MeshBasicMaterial({ map: new THREE.CanvasTexture(cv), transparent: true,
          depthWrite: false, depthTest: false }));
      lab.rotation.x = -Math.PI / 2;
      lab.rotation.z = Math.PI / 2;     // reads along the short side
      lab.position.x = L / 4;
      lab.renderOrder = 62;
      g.add(lab);
      // Live water cells (1 m squares, pitch-local), refilled on every move.
      const n = Math.ceil(L) * Math.ceil(W);
      const cg = new THREE.PlaneGeometry(0.96, 0.96);
      cg.rotateX(-Math.PI / 2);
      p.cells = new THREE.InstancedMesh(cg, new THREE.MeshBasicMaterial({ transparent: true, opacity: 0.6,
        depthWrite: false, side: THREE.DoubleSide }), n);
      p.cells.count = 0;
      p.cells.renderOrder = 59;
      p.cells.position.y = -0.2;
      p.cells.visible = waterOn;
      g.add(p.cells);
      g.position.y = 0.6;
      g.visible = on;
      site.add(g);
      p.g = g;
    }
    const CELL_COL = [null, new THREE.Color(0x1e5bff), new THREE.Color(0x00d5ff), new THREE.Color(0xffb000)];
    const mtx = new THREE.Matrix4();
    function fillCells(p, cells) {
      if (!p.cells) return;
      let k = 0;
      for (let i = 0; i < cells.length && k < p.cells.instanceMatrix.count; i += 3, k++) {
        mtx.makeTranslation(cells[i], 0, cells[i + 1]);
        p.cells.setMatrixAt(k, mtx);
        p.cells.setColorAt(k, CELL_COL[cells[i + 2]]);
      }
      p.cells.count = k;
      p.cells.instanceMatrix.needsUpdate = true;
      if (p.cells.instanceColor) p.cells.instanceColor.needsUpdate = true;
    }

    function evaluate(p) {
      const th = p.rot * D2R, L = p.size[0] * YD, W = p.size[1] * YD;
      const R = rect(p.x, p.z, th, L, W), c = [p.x, p.z];
      const off = offences(DATA.rules, R, c);
      const o = pitches.find((q) => q !== p);
      if (o && o.R) {
        const d = inRect(c, o.R) || inRect([o.x, o.z], R) ? 0 : rectDist(R, c, o.R, true);
        if (d < GAP) off.push({ n: 'other', have: d, need: GAP });
      }
      off.sort((a, b) => (a.have - a.need) - (b.have - b.need));
      const main = DATA.rules.find((r) => r.n === 'main_infield');
      const cells = [];
      p.R = R;
      p.ev = { ok: off.length === 0, off,
               w: water(DATA.grid, p.x, p.z, th, L, W, DATA.ranges[p.size[0] + 'x' + p.size[1]], cells),
               infield: main ? rectDist(R, c, main.pts, !!main.c) : null };
      fillCells(p, cells);
    }
    // Rule name -> words: layout structures by their layout name.
    const label = (n) => {
      const m = /^(buildings|canopies|sheds|trailers|booths)_(\d+)$/.exec(n);
      if (m && LAY[m[1]] && LAY[m[1]][+m[2]]) return LAY[m[1]][+m[2]].name || m[1];
      return NAMES[n] || n.replace(/_\d+$/, '').replace(/_/g, ' ');
    };
    const fmt = (m) => (m < 9.144 ? (m / FT).toFixed(1) + ' ft' : (m / YD).toFixed(1) + ' yd');

    // A pill per plan pitch at the top of the candidate pill list (James:
    // "it should show with pills like others"): tap = PLAN on + fly there.
    const pills = {};
    for (const p of pitches) {
      const b = mk('button', 'display:flex;align-items:center;gap:6px;min-width:0;min-height:0;padding:4px 10px;' +
        'border-radius:14px;border:2px solid #33ff66;background:rgba(10,14,20,.72);color:#f4f6fb;' +
        'font:600 11px system-ui,sans-serif;cursor:pointer;text-align:left;');
      tap(b, () => {
        if (!on) return;
        sel = p;
        flyTo(p);
        paint();
      });
      pills[p.id] = b;
    }
    const pillBox = mk('div', 'position:fixed;left:8px;top:84px;display:flex;flex-direction:column;gap:6px;z-index:12;');
    for (const p of pitches) pillBox.appendChild(pills[p.id]);
    // WATER: the field's water layer + the live cells in both pitches.
    const waterPill = mk('button', 'display:flex;align-items:center;gap:6px;min-width:0;min-height:0;padding:4px 10px;' +
      'border-radius:14px;border:2px solid #29a8ff;background:rgba(10,14,20,.72);color:#f4f6fb;' +
      'font:600 11px system-ui,sans-serif;cursor:pointer;text-align:left;');
    const paintWater = () => {
      waterPill.innerHTML = '<span style="width:10px;height:10px;border-radius:50%;flex:none;background:' +
        (waterOn ? '#29a8ff' : 'transparent') + ';border:1px solid #29a8ff"></span>💧 WATER ' + (waterOn ? 'ON' : 'OFF') +
        (waterOn ? ' · <span style="color:#6f95ff">■ pond</span> <span style="color:#00d5ff">■ runoff</span> ' +
          '<span style="color:#ffb000">■ flat</span>' : '');
    };
    tap(waterPill, () => {
      waterOn = !waterOn;
      if (renderer.field && renderer.field.setWater) renderer.field.setWater(waterOn);
      for (const p of pitches) if (p.cells) p.cells.visible = waterOn;
      paintWater();
    });
    paintWater();
    pillBox.appendChild(waterPill);
    document.body.appendChild(pillBox);
    const paintPill = (p) => {
      const b = pills[p.id], hex = !p.ev ? '#8899aa' : p.ev.ok ? '#33ff66' : '#ff3344';
      b.style.borderColor = hex;
      b.innerHTML = '<span style="width:10px;height:10px;border-radius:50%;flex:none;background:' + hex + '"></span>' +
        '📐 ' + p.id + ' ' + p.size[0] + '×' + p.size[1] +
        (p.ev ? ' · dry ' + p.ev.w.pct.toFixed(0) + '% · ' + (p.ev.ok ? 'clear' : '✗ ' + label(p.ev.off[0].n)) : ' · tap to plan');
    };
    for (const p of pitches) paintPill(p);

    function paint() {
      for (const p of pitches) paintPill(p);
      for (const p of pitches) {
        const ev = p.ev;
        if (!ev) continue;
        const col = ev.ok ? 0x33ff66 : 0xff3344;
        if (p.lineMat) { p.lineMat.color.setHex(col); p.fill.material.color.setHex(col); }
        const w = ev.w, pct = (k) => (100 * w[k] / w.n).toFixed(1) + '%';
        const why = ev.ok ? '<span style="color:#5f6">✓ clear of everything</span>'
          : ev.off.slice(0, 3).map((o) => '<span style="color:#ff6b78">✗ ' + label(o.n) +
            (o.need > 0 ? ': ' + (o.have <= 0 ? 'overlapping' : fmt(o.have)) + ' (needs ' + fmt(o.need) + ')' : '') +
            '</span>').join('<br>');
        rows[p.id].parentNode.style.background = p === sel ? 'rgba(255,255,255,.12)' : 'transparent';
        rows[p.id].innerHTML = '<b>' + (p === sel ? '▶ ' : '') + p.id + ' ' + p.size[0] + '×' + p.size[1] + ' yd</b> · ' +
          p.rot.toFixed(0) + '° · dry <b>' + w.pct.toFixed(0) + '%</b> <span style="opacity:.7">(100% = driest legal spot)</span> · pond ' + pct('pond') + ', runoff ' +
          pct('flow') + ', flat ' + pct('flat') +
          (ev.infield != null ? '<br><span style="opacity:.85">⚾ main diamond infield: ' +
            (ev.infield <= 0 ? 'overlapping' : fmt(ev.infield) + ' away') + '</span>' : '') + '<br>' + why;
      }
      if (paintSpots.for !== sel) { paintSpots.for = sel; paintSpots(); }
      sizeBtn.textContent = '7v7 SIZE ' + pitches[1].size[0] + '×' + pitches[1].size[1];
    }

    function update() {
      for (const p of pitches) if (p.g) { p.g.position.x = p.x; p.g.position.z = p.z; p.g.rotation.y = -p.rot * D2R; }
      // Each pitch's 10 yd gap reads the other's rect: settle both, twice.
      for (let k = 0; k < 2; k++) for (const p of pitches) evaluate(p);
      paint();
    }

    // Park the camera over a pitch (FOLLOW OFF), looking down at it.
    function flyTo(p) {
      const rig = renderer.rig, v = new THREE.Vector3(p.x, 0, p.z);
      renderer.field.site.localToWorld(v);
      if (rig.follow) {
        rig.setFollow(false);
        const fb = document.getElementById('btn-follow');
        if (fb) { fb.textContent = 'FOLLOW OFF'; fb.style.background = 'rgba(255,204,0,.5)'; }
      }
      rig.target.set(v.x, 0, v.z);
      rig.user.dist = p.size[0] * YD * 1.3;
      rig.user.pitch = 1.2;
    }

    // On by default: wait for the field, build, frame both pitches.
    function start() {
      if (!renderer.field || !renderer.field.site) { setTimeout(start, 300); return; }
      on = true;
      for (const p of pitches) rebuild(p);
      update();
      flyTo({ x: (pitches[0].x + pitches[1].x) / 2, z: (pitches[0].z + pitches[1].z) / 2,
              size: [Math.hypot(pitches[0].x - pitches[1].x, pitches[0].z - pitches[1].z) / YD + 70, 0] });
    }
    start();

    // Screen point -> site metres on the ground plane.
    const ray = new THREE.Raycaster(), plane = new THREE.Plane(new THREE.Vector3(0, 1, 0), 0),
          hit = new THREE.Vector3();
    function sitePoint(cx, cy) {
      ray.setFromCamera(new THREE.Vector2(cx / window.innerWidth * 2 - 1, -(cy / window.innerHeight) * 2 + 1),
                        renderer.camera);
      if (!ray.ray.intersectPlane(plane, hit)) return null;
      const v = renderer.field.site.worldToLocal(hit.clone());
      return [v.x, v.z];
    }
    function grab(cx, cy) {
      const s = sitePoint(cx, cy);
      if (!s) return false;
      const order = [sel].concat(pitches.filter((p) => p !== sel));
      const p = order.find((q) => q.R && inRect(s, q.R));
      if (!p) return false;
      sel = p;
      drag = { p, dx: p.x - s[0], dz: p.z - s[1] };
      paint();
      return true;
    }
    function move(cx, cy) {
      const s = sitePoint(cx, cy);
      if (!s) return;
      drag.p.x = s[0] + drag.dx;
      drag.p.z = s[1] + drag.dz;
      justDragged = true;
      update();
    }
    // Capture on window so a grab beats the camera orbit and the tap-to-claim.
    const canvas = renderer.canvas;
    const stop = (e) => { e.stopPropagation(); if (e.cancelable) e.preventDefault(); };
    window.addEventListener('mousedown', (e) => {
      if (on && e.target === canvas && grab(e.clientX, e.clientY)) stop(e);
    }, true);
    window.addEventListener('mousemove', (e) => { if (drag) { move(e.clientX, e.clientY); stop(e); } }, true);
    window.addEventListener('mouseup', () => { drag = null; }, true);
    window.addEventListener('click', (e) => {
      if (justDragged && e.target === canvas) { justDragged = false; stop(e); }
    }, true);
    window.addEventListener('touchstart', (e) => {
      if (on && e.target === canvas && e.touches.length === 1 &&
          grab(e.touches[0].clientX, e.touches[0].clientY)) stop(e);
    }, { capture: true, passive: false });
    window.addEventListener('touchmove', (e) => {
      if (drag && e.touches.length === 1) { move(e.touches[0].clientX, e.touches[0].clientY); stop(e); }
    }, { capture: true, passive: false });
    window.addEventListener('touchend', (e) => {
      if (drag) { drag = null; stop(e); justDragged = false; }
    }, { capture: true, passive: false });
    window.addEventListener('keydown', (e) => {
      if (!on) return;
      if (e.key === '[') turn(-1);
      else if (e.key === ']') turn(1);
    });
  }

  window.PitchPlanner = { attach, offences, water, rect };
})();
