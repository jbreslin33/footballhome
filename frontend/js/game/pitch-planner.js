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
// PRACTICE BOXES (James: "create practice boxes so we stay off pitch ...
// name them like Monday, Tuesday"): ➕ ADD BOX drops a named box where the
// camera looks; drag / turn it like a pitch, set its size, rename or
// delete it. Red when it's on the 11v11 or 7v7 or breaks a site rule.
// Boxes live in this browser (localStorage), like saved spots.
// GAME / PLAN (James: "clear all measurement and rain stuff so we can
// focus on game"): attach() returns { setOn }; client.js's 🎮/📐 button
// hides or shows every planner layer — outlines, boxes, ruler, water,
// panel, pills. Built once either way, so switching is instant.
// SAVING (James: "your saves are not working it reverts ... make sure it
// saves" / "yes of course db lol"): the layout lives in the club DB
// (/api/field-plan, migration 635) so every device sees the same one; this
// browser keeps a copy for offline. Every move of a pitch or box saves a
// moment after it stops; club admins write, everyone else reads. The first
// admin load uploads whatever this browser already had (boxes, spots,
// default) when the DB has none yet. 📌 SET DEFAULT stores the whole layout as the default;
// ↺ DEFAULT snaps everything back to it (before one is set: cyan + the
// 7v7's ⭐ BEST spot).

(function () {
  'use strict';

  const YD = 0.9144, FT = 0.3048, D2R = Math.PI / 180;
  const GAP = 10 * YD;                       // between the two pitches
  // Rules shown as a distance only, never an offence ('info' kind).
  const INFO = {};
  const SEVEN_SIZES = [[70, 35], [65, 35], [60, 35], [55, 35], [60, 30]];
  const NAMES = {
    main_infield: 'main diamond infield', softball_skin: 'softball infield dirt',
    fence_3B: 'softball 3rd-base fence', backstop_1B: 'softball backstop / 1st-base fence',
    vendor: 'vendor fence', rodeo: 'rodeo fence', west_of_rodeo: 'past the rodeo fence',
    trees: 'a tree trunk', on_11v11: 'on the 11v11', on_7v7: 'on the 7v7', north_of_vendor: 'past the vendor fence line', park: 'the park edge',
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
  // Nearest points between two rects, edge to edge: { d, a, b } (d 0 and
  // no points when they overlap).
  const closest = (A, B) => {
    const cp = (p, a, b) => {
      const dx = b[0] - a[0], dz = b[1] - a[1], l2 = dx * dx + dz * dz;
      const t = l2 === 0 ? 0 : Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dz) / l2));
      return [a[0] + t * dx, a[1] + t * dz];
    };
    for (let i = 0; i < 4; i++)
      for (let j = 0; j < 4; j++)
        if (crosses(A[i], A[(i + 1) % 4], B[j], B[(j + 1) % 4])) return { d: 0 };
    if (A.some((p) => inRect(p, B)) || B.some((p) => inRect(p, A))) return { d: 0 };
    let best = { d: 1e9 };
    for (const [P, Q, flip] of [[A, B, false], [B, A, true]])
      for (const p of P)
        for (let j = 0; j < 4; j++) {
          const q = cp(p, Q[j], Q[(j + 1) % 4]), d = Math.hypot(p[0] - q[0], p[1] - q[1]);
          if (d < best.d) best = flip ? { d, a: q, b: p } : { d, a: p, b: q };
        }
    return best;
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
      // Starts on the driest legal 70 x 35 (⭐ BEST's spot).
      { id: '7v7', size: SEVEN_SIZES[0], x: 0, z: 0, rot: 0 },
    ];
    const best7 = DATA.ranges['70x35'] && DATA.ranges['70x35'].at;
    if (best7) [pitches[1].x, pitches[1].z, pitches[1].rot] = best7;
    const BOX_KEY = 'fh.lighthouse.practiceBoxes.v1';
    const boxes = (() => {
      try { return JSON.parse(localStorage.getItem(BOX_KEY) || '[]'); } catch (e) { return []; }
    })().map((b) => Object.assign(b, { kind: 'box' }));
    const saveBoxes = () => {
      try {
        localStorage.setItem(BOX_KEY, JSON.stringify(boxes.map((b) => ({ id: b.id, name: b.name, size: b.size,
          x: +b.x.toFixed(2), z: +b.z.toFixed(2), rot: +b.rot.toFixed(1) }))));
      } catch (e) { /* private window: boxes last until reload */ }
    };
    const all = () => pitches.concat(boxes);
    const STATE_KEY = 'fh.lighthouse.planState.v1', DEFAULT_KEY = 'fh.lighthouse.planDefault.v1';
    const snapshot = () => ({
      pitches: pitches.map((p) => ({ id: p.id, x: +p.x.toFixed(2), z: +p.z.toFixed(2), rot: +p.rot.toFixed(1), size: p.size.slice() })),
      boxes: boxes.map((b) => ({ id: b.id, name: b.name, size: b.size.slice(), x: +b.x.toFixed(2), z: +b.z.toFixed(2), rot: +b.rot.toFixed(1) })),
    });
    const readJSON = (k) => { try { return JSON.parse(localStorage.getItem(k) || 'null'); } catch (e) { return null; } };
    const writeJSON = (k, v) => { try { localStorage.setItem(k, JSON.stringify(v)); return true; } catch (e) { return false; } };
    // The built-in default: cyan for the 11v11, the 7v7 on its ⭐ BEST spot.
    const builtinDefault = { pitches: snapshot().pitches };   // leaves boxes alone
    // Put pitches (and, when given, boxes) where a snapshot says.
    function restore(st) {
      for (const sp of (st && st.pitches) || []) {
        const p = pitches.find((q) => q.id === sp.id);
        if (!p) continue;
        p.x = sp.x; p.z = sp.z; p.rot = sp.rot;
        if (sp.size) p.size = SEVEN_SIZES.find((q) => q[0] === sp.size[0] && q[1] === sp.size[1]) || sp.size;
      }
      if (st && st.boxes) {
        for (const b of boxes) if (b.g) b.g.parent.remove(b.g);
        boxes.length = 0;
        for (const b of st.boxes) boxes.push(Object.assign({ kind: 'box' }, b));
      }
    }
    // ── the club DB (/api/field-plan); localStorage stays as this device's copy ──
    const API = '/api/field-plan';
    const token = () => { try { return localStorage.getItem('token') || ''; } catch (e) { return ''; } };
    let canWrite = !!token(), dbDefault = null, dbSpots = null;
    const api = (method, path, body) => fetch(API + path, {
      method,
      headers: Object.assign({ 'Content-Type': 'application/json' }, token() ? { Authorization: 'Bearer ' + token() } : {}),
      body: body ? JSON.stringify(body) : undefined,
    }).then(async (r) => {
      const j = await r.json().catch(() => ({}));
      if (!r.ok) throw Object.assign(new Error(j.error || 'HTTP ' + r.status), { status: r.status });
      return j;
    });
    const toItems = (st) => (st.pitches || []).map((p) => ({ key: p.id, kind: 'pitch', length_yd: p.size[0],
      width_yd: p.size[1], x: p.x, z: p.z, rot: p.rot }))
      .concat((st.boxes || []).map((b) => ({ key: b.id, kind: 'practice_box', name: b.name, length_yd: b.size[0],
        width_yd: b.size[1], x: b.x, z: b.z, rot: b.rot })));
    const fromItems = (items) => ({
      pitches: items.filter((i) => i.kind === 'pitch').map((i) => ({ id: i.key, x: i.x, z: i.z, rot: i.rot,
        size: [i.length_yd, i.width_yd] })),
      boxes: items.filter((i) => i.kind === 'practice_box').map((i) => ({ id: i.key, name: i.name,
        size: [i.length_yd, i.width_yd], x: i.x, z: i.z, rot: i.rot })),
    });
    const syncEl = document.createElement('div');
    syncEl.style.cssText = 'padding:0 6px 4px;font-size:11px;';
    const setSync = (msg, ok) => { syncEl.textContent = msg; syncEl.style.color = ok ? '#7dff9a' : '#ffb000'; };
    function pushLayout(kind, st) {
      if (!canWrite) {
        setSync('⚠ saved on this device only — sign in as a club admin to save it for everyone', false);
        return Promise.resolve(false);
      }
      setSync('☁ saving…', true);
      return api('PUT', '/layout', { kind, items: toItems(st) })
        .then(() => { setSync('☁ saved for everyone' + (kind === 'default' ? ' (default)' : ''), true); return true; })
        .catch((e) => {
          if (e.status === 401 || e.status === 403) canWrite = false;
          setSync('⚠ not saved to the club (' + e.message + ') — kept on this device', false);
          return false;
        });
    }
    let saveTimer = null;
    const saveState = () => {
      clearTimeout(saveTimer);
      saveTimer = setTimeout(() => {
        const st = snapshot();
        writeJSON(STATE_KEY, st);
        saveBoxes();
        pushLayout('current', st);
      }, 600);
    };
    const title = (p) => (p.kind === 'box' ? p.name : p.id);
    let on = false, built = false, wantOn = true, sel = pitches[1], drag = null, justDragged = false, waterOn = true;
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
    // Always-on gap between the two pitches (James: "show distance always
    // between 7v7 and 11v11 as they move").
    const gapRow = mk('div', 'padding:2px 6px 6px;font-weight:600;');
    panel.appendChild(syncEl);
    panel.appendChild(gapRow);
    const rows = {};
    const rowsBox = mk('div', 'max-height:38vh;overflow-y:auto;');
    panel.appendChild(rowsBox);
    function buildRows() {
      rowsBox.innerHTML = '';
      for (const k in rows) delete rows[k];
      for (const p of all()) {
        const r = mk('div', 'display:flex;gap:6px;align-items:flex-start;padding:4px 6px;border-radius:8px;' +
          'cursor:pointer;margin-bottom:4px;');
        const go = mk('button', pill + 'flex:none;', '📍');
        go.title = 'Fly the camera to it';
        tap(go, () => { sel = p; flyTo(p); paint(); });
        const txt = mk('div', 'flex:1;min-width:0;');
        r.appendChild(go);
        r.appendChild(txt);
        tap(txt, () => { sel = p; paint(); });
        rowsBox.appendChild(r);
        rows[p.id] = txt;
      }
    }
    buildRows();
    const bar = mk('div', 'display:flex;gap:6px;flex-wrap:wrap;margin-top:4px;');
    const turn = (d) => {
      sel.rot = ((sel.rot + d) % 360 + 360) % 360;
      update();
      if (sel.kind === 'box') saveBoxes();
    };
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
      if (sel.kind === 'box') return;
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
      const txt = all().map((p) => `${title(p)} ${p.size[0]}x${p.size[1]} yd at (${p.x.toFixed(1)}, ${p.z.toFixed(1)}) ${p.rot.toFixed(0)}°` +
        ` — ${p.ev.ok ? 'OK' : 'BLOCKED'}` + (p.ev.w.pct != null ? `, dry ${p.ev.w.pct.toFixed(0)}%` : '') +
        `, main infield ${(p.ev.infield / YD).toFixed(1)} yd`).join('\n');
      if (navigator.clipboard) navigator.clipboard.writeText(txt).catch(() => {});
      copyBtn.textContent = 'COPIED';
      setTimeout(() => { copyBtn.textContent = 'COPY'; }, 1200);
    });
    bar.appendChild(copyBtn);
    const setDefBtn = mk('button', pill, '📌 SET DEFAULT');
    tap(setDefBtn, () => {
      const st = snapshot();
      dbDefault = st;
      writeJSON(DEFAULT_KEY, st);
      pushLayout('default', st).then((ok) => {
        setDefBtn.textContent = ok ? '✓ DEFAULT SET' : '✓ SET (this device)';
        setTimeout(() => { setDefBtn.textContent = '📌 SET DEFAULT'; }, 1500);
      });
    });
    const resetBtn = mk('button', pill, '↺ DEFAULT');
    tap(resetBtn, () => {
      restore(dbDefault || readJSON(DEFAULT_KEY) || builtinDefault);
      for (const p of all()) rebuild(p);
      sel = pitches[0];
      buildLists();
      update();
      saveBoxes();
    });
    bar.append(setDefBtn, resetBtn);
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
    // Spots in one shape: { id?, name, pitch, x, z, rotDeg, size }.
    const spotList = () => (dbSpots
      ? dbSpots.map((s) => ({ id: s.id, name: s.name, pitch: s.pitch, x: s.x, z: s.z, rotDeg: s.rot,
                             size: [s.length_yd, s.width_yd] }))
      : loadSaved());
    const reloadSpots = () => api('GET', '').then((j) => { dbSpots = j.spots; paintSpots(); }).catch(() => {});
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
      const saved = spotList();
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
            if (dbSpots && e.sp.id) {
              api('DELETE', '/spot?id=' + e.sp.id).then(reloadSpots)
                .catch((err) => setSync('⚠ spot not deleted (' + err.message + ')', false));
              return;
            }
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
        if (dbSpots && canWrite) {
          api('POST', '/spot', { pitch: sel.id, name: n, length_yd: sel.size[0], width_yd: sel.size[1],
                                 x: +sel.x.toFixed(2), z: +sel.z.toFixed(2), rot: +sel.rot.toFixed(1) })
            .then(reloadSpots).catch((err) => setSync('⚠ spot not saved (' + err.message + ')', false));
          return;
        }
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
    // ── practice boxes ──
    const textIn = (ph, w) => {
      const i = document.createElement('input');
      i.placeholder = ph;
      i.style.cssText = 'min-width:0;width:' + w + 'px;padding:4px 8px;border-radius:12px;border:1px solid #889;' +
        'background:rgba(255,255,255,.08);color:#f4f6fb;font:12px system-ui,sans-serif;';
      for (const ev of ['mousedown', 'touchstart', 'keydown']) i.addEventListener(ev, (e) => e.stopPropagation());
      return i;
    };
    const boxCtl = mk('div', 'display:none;gap:6px;flex-wrap:wrap;margin-top:6px;align-items:center;');
    panel.appendChild(boxCtl);
    function paintBoxCtl() {
      boxCtl.innerHTML = '';
      if (sel.kind !== 'box') { boxCtl.style.display = 'none'; return; }
      boxCtl.style.display = 'flex';
      const b = sel;
      boxCtl.appendChild(mk('span', 'opacity:.75;font-size:11px;', '🟧 box:'));
      const nm = textIn('name', 110);
      nm.value = b.name;
      const L = textIn('length', 52), W = textIn('width', 52);
      L.type = W.type = 'number';
      L.value = b.size[0]; W.value = b.size[1];
      const apply = () => {
        const nl = Math.max(5, Math.min(120, +L.value || b.size[0])), nw = Math.max(5, Math.min(80, +W.value || b.size[1]));
        const rename = nm.value.trim() && nm.value.trim() !== b.name;
        if (rename) b.name = nm.value.trim();
        if (nl !== b.size[0] || nw !== b.size[1] || rename) { b.size = [nl, nw]; rebuild(b); buildLists(); }
        saveBoxes();
        update();
      };
      for (const i of [nm, L, W]) {
        i.addEventListener('change', apply);
        i.addEventListener('keydown', (e) => { if (e.key === 'Enter') apply(); });
      }
      const del = mk('button', pill + 'color:#ff8a94;', '🗑 DELETE');
      tap(del, () => {
        boxes.splice(boxes.indexOf(b), 1);
        if (b.g) b.g.parent.remove(b.g);
        sel = pitches[0];
        saveBoxes();
        buildLists();
        update();
      });
      boxCtl.append(nm, L, mk('span', '', '×'), W, mk('span', 'opacity:.75', 'yd'), del);
    }
    const addRow = mk('div', 'display:flex;gap:6px;flex-wrap:wrap;margin-top:6px;align-items:center;');
    const addName = textIn('practice box name (Monday…)', 190);
    const addBtn = mk('button', pill + 'border-color:#ffa630;', '➕ ADD BOX');
    const addBox = () => {
      if (!on) return;   // field still loading
      // Dropped where the camera is looking, 40 x 30 yd, square to the 11v11.
      const t = renderer.field.site.worldToLocal(renderer.rig.target.clone());
      const b = { kind: 'box', id: 'box-' + Date.now(), name: addName.value.trim() || 'Practice ' + (boxes.length + 1),
                  size: [40, 30], x: t.x, z: t.z, rot: pitches[0].rot };
      boxes.push(b);
      addName.value = '';
      rebuild(b);
      sel = b;
      buildLists();
      saveBoxes();
      update();
    };
    tap(addBtn, addBox);
    addName.addEventListener('keydown', (e) => { if (e.key === 'Enter') addBox(); });
    addRow.append(mk('span', 'opacity:.75;font-size:11px;', '🟧 practice:'), addName, addBtn);
    panel.appendChild(addRow);
    panel.appendChild(mk('div', 'opacity:.7;margin-top:4px;font-size:11px;',
      'Drag a pitch to move it · ↺ ↻ or [ ] to turn the selected one · red = too close to something or on a diamond'));

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
      const lines = [[L, t, 0, -W / 2], [L, t, 0, W / 2], [t, W, -L / 2, 0], [t, W, L / 2, 0]];
      if (p.kind !== 'box') lines.push([t, W, 0, 0]);       // halfway
      p.fill = new THREE.Mesh(new THREE.PlaneGeometry(L, W), fillMat(0x33ff66));
      p.fill.rotation.x = -Math.PI / 2;
      p.fill.renderOrder = 60;
      g.add(p.fill);
      for (const [w, d, x, z] of lines) {
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
      const name = title(p);
      c2.font = 'bold 96px sans-serif';
      const fs = Math.min(96, Math.floor(96 * 480 / Math.max(1, c2.measureText(name).width)));
      c2.font = 'bold ' + fs + 'px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
      c2.lineWidth = 14; c2.strokeStyle = 'rgba(0,0,0,.85)'; c2.strokeText(name, 256, 64);
      c2.fillStyle = p.kind === 'box' ? '#ffd29a' : '#ffffff'; c2.fillText(name, 256, 64);
      const lab = new THREE.Mesh(new THREE.PlaneGeometry(W * 0.8, W * 0.2),
        new THREE.MeshBasicMaterial({ map: new THREE.CanvasTexture(cv), transparent: true,
          depthWrite: false, depthTest: false }));
      lab.rotation.x = -Math.PI / 2;
      lab.rotation.z = Math.PI / 2;     // reads along the short side
      lab.position.x = p.kind === 'box' ? 0 : L / 4;
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
      if (p.kind === 'box') {
        // Practice boxes stay off both pitches (touching is fine).
        for (const q of pitches)
          if (q.R && closest(R, q.R).d <= 0) off.push({ n: 'on_' + q.id, have: 0, need: 0 });
      } else {
        const o = pitches.find((q) => q !== p);
        if (o && o.R) {
          const d = inRect(c, o.R) || inRect([o.x, o.z], R) ? 0 : rectDist(R, c, o.R, true);
          if (d < GAP) off.push({ n: 'other', have: d, need: GAP });
        }
      }
      off.sort((a, b) => (a.have - a.need) - (b.have - b.need));
      const main = DATA.rules.find((r) => r.n === 'main_infield');
      const cells = [];
      p.R = R;
      p.ev = { ok: off.length === 0, off,
               w: water(DATA.grid, p.x, p.z, th, L, W, DATA.ranges[p.size[0] + 'x' + p.size[1]], cells),
               infield: main ? rectDist(R, c, main.pts, !!main.c) : null,
               toPitch: p.kind === 'box' && pitches[0].R ? closest(R, pitches[0].R).d : null };
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
    const pillList = mk('div', 'display:flex;flex-direction:column;gap:6px;max-height:60vh;overflow-y:auto;');
    function buildPills() {
      pillList.innerHTML = '';
      for (const k in pills) delete pills[k];
      for (const p of all()) {
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
      pillList.appendChild(b);
      paintPill(p);
      }
    }
    const buildLists = () => { buildRows(); buildPills(); paintSpots.for = null; if (on) paint(); };
    // Under the 🎮/📐 mode pill (client.js, top 84px).
    const pillBox = mk('div', 'position:fixed;left:8px;top:116px;display:flex;flex-direction:column;gap:6px;z-index:12;');
    pillBox.appendChild(pillList);
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
      if (renderer.field && renderer.field.setWater) renderer.field.setWater(on && waterOn);
      for (const p of all()) if (p.cells) p.cells.visible = waterOn;
      paintWater();
    });
    paintWater();
    pillBox.appendChild(waterPill);
    document.body.appendChild(pillBox);
    function paintPill(p) {
      const b = pills[p.id];
      if (!b) return;
      const hex = !p.ev ? '#8899aa' : p.ev.ok ? (p.kind === 'box' ? '#ffa630' : '#33ff66') : '#ff3344';
      b.style.borderColor = hex;
      b.innerHTML = '<span style="width:10px;height:10px;border-radius:50%;flex:none;background:' + hex + '"></span>' +
        (p.kind === 'box' ? '🟧 ' : '📐 ') + title(p) + ' ' + p.size[0] + '×' + p.size[1] +
        (p.ev ? (p.ev.w.pct != null ? ' · dry ' + p.ev.w.pct.toFixed(0) + '%' : '') + ' · ' +
          (p.ev.ok ? 'clear' : '✗ ' + label(p.ev.off[0].n)) : '');
    }
    buildPills();

    function paint() {
      for (const p of all()) paintPill(p);
      for (const p of all()) {
        const ev = p.ev;
        if (!ev || !rows[p.id]) continue;
        const col = ev.ok ? (p.kind === 'box' ? 0xffa630 : 0x33ff66) : 0xff3344;
        if (p.lineMat) { p.lineMat.color.setHex(col); p.fill.material.color.setHex(col); }
        const w = ev.w, pct = (k) => (100 * w[k] / w.n).toFixed(1) + '%';
        const why = ev.ok ? '<span style="color:#5f6">✓ clear of everything</span>'
          : ev.off.slice(0, 3).map((o) => '<span style="color:#ff6b78">✗ ' + label(o.n) +
            (o.need > 0 ? ': ' + (o.have <= 0 ? 'overlapping' : fmt(o.have)) + ' (needs ' + fmt(o.need) + ')' : '') +
            '</span>').join('<br>');
        rows[p.id].parentNode.style.background = p === sel ? 'rgba(255,255,255,.12)' : 'transparent';
        rows[p.id].innerHTML = '<b>' + (p === sel ? '▶ ' : '') + (p.kind === 'box' ? '🟧 ' : '') + title(p) + ' ' +
          p.size[0] + '×' + p.size[1] + ' yd</b> · ' + p.rot.toFixed(0) + '° · ' +
          (w.pct != null ? 'dry <b>' + w.pct.toFixed(0) + '%</b> <span style="opacity:.7">(100% = driest legal spot)</span> · '
            : (ev.toPitch != null ? '↔ 11v11 <b>' + (ev.toPitch <= 0 ? 'on it' : fmt(ev.toPitch)) + '</b> · ' : '')) +
          'pond ' + pct('pond') + ', runoff ' +
          pct('flow') + ', flat ' + pct('flat') +
          (ev.infield != null ? '<br><span style="opacity:.85">⚾ main diamond infield: ' +
            (ev.infield <= 0 ? 'overlapping' : fmt(ev.infield) + ' away') + '</span>' : '') + '<br>' + why;
      }
      if (paintSpots.for !== sel) {
        paintSpots.for = sel;
        paintSpots();
        paintBoxCtl();
        spotBox.style.display = sel.kind === 'box' ? 'none' : 'flex';
      }
      sizeBtn.textContent = '7v7 SIZE ' + pitches[1].size[0] + '×' + pitches[1].size[1];
    }

    // Gap ruler on the grass: white strip between the nearest edges and a
    // label at its middle, redrawn on every move.
    let ruler = null;
    function paintGap() {
      const [A, B] = pitches;
      if (!A.R || !B.R) return;
      const g = closest(A.R, B.R), ok = g.d >= GAP;
      const txt = g.d <= 0 ? 'overlapping' : (g.d / YD).toFixed(1) + ' yd';
      gapRow.innerHTML = '↔ 11v11 to 7v7: <span style="color:' + (ok ? '#5f6' : '#ff6b78') + '">' + txt + '</span>' +
        ' <span style="opacity:.6;font-weight:400">(10 yd apart to be clear)</span>';
      const site = renderer.field && renderer.field.site;
      if (!site) return;
      if (!ruler) {
        const strip = new THREE.Mesh(new THREE.PlaneGeometry(1, 0.5),
          new THREE.MeshBasicMaterial({ color: 0xffffff, depthTest: false, side: THREE.DoubleSide }));
        strip.rotation.x = -Math.PI / 2;
        strip.renderOrder = 63;
        const bar = new THREE.Group();
        bar.add(strip);
        const cv = document.createElement('canvas');
        cv.width = 512; cv.height = 128;
        const tex = new THREE.CanvasTexture(cv);
        const lab = new THREE.Mesh(new THREE.PlaneGeometry(16, 4),
          new THREE.MeshBasicMaterial({ map: tex, transparent: true, depthWrite: false, depthTest: false }));
        lab.rotation.x = -Math.PI / 2;
        lab.renderOrder = 64;
        site.add(bar, lab);
        ruler = { bar, strip, lab, cv, tex };
      }
      const c2 = ruler.cv.getContext('2d');
      c2.clearRect(0, 0, 512, 128);
      c2.font = 'bold 84px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
      c2.lineWidth = 14; c2.strokeStyle = 'rgba(0,0,0,.85)'; c2.strokeText(txt, 256, 64);
      c2.fillStyle = ok ? '#7dff9a' : '#ff6b78'; c2.fillText(txt, 256, 64);
      ruler.tex.needsUpdate = true;
      const show = on && g.d > 0;
      ruler.bar.visible = show;
      if (show) {
        const mx = (g.a[0] + g.b[0]) / 2, mz = (g.a[1] + g.b[1]) / 2;
        ruler.bar.position.set(mx, 0.7, mz);
        ruler.bar.rotation.y = -Math.atan2(g.b[1] - g.a[1], g.b[0] - g.a[0]);
        ruler.strip.scale.x = Math.max(0.01, g.d);
        ruler.lab.position.set(mx, 0.75, mz);
      } else {
        // Overlapping: label sits at the 7v7's centre.
        ruler.lab.position.set(B.x, 0.75, B.z);
      }
      ruler.lab.visible = on;
      if (!on) ruler.bar.visible = false;
    }

    function update() {
      for (const p of all()) if (p.g) { p.g.position.x = p.x; p.g.position.z = p.z; p.g.rotation.y = -p.rot * D2R; }
      // Each pitch's 10 yd gap reads the other's rect: settle both, twice;
      // then the boxes, which read the pitches.
      for (let k = 0; k < 2; k++) for (const p of pitches) evaluate(p);
      for (const b of boxes) evaluate(b);
      paint();
      paintGap();
      if (on) saveState();
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

    // On by default: wait for the field, read the club's layout, build,
    // frame both pitches.
    const dbLoad = api('GET', '').catch(() => null);
    async function start() {
      if (!renderer.field || !renderer.field.site) { setTimeout(start, 300); return; }
      const db = await Promise.race([dbLoad, new Promise((r) => setTimeout(() => r(null), 5000))]);
      on = true;   // build + evaluate with everything on, then apply wantOn
      if (db && db.current) {
        restore(fromItems(db.current.items));
        setSync('☁ the club layout' + (canWrite ? '' : ' (view only — sign in as a club admin to change it)'), true);
      } else {
        localStart();
        if (db) {
          // DB empty: this browser's layout becomes the club's (admins).
          writeJSON(STATE_KEY, snapshot());
          pushLayout('current', snapshot());
        } else setSync('⚠ club layout unreachable — using this device\'s copy', false);
      }
      if (db) {
        dbDefault = db.default ? fromItems(db.default.items) : null;
        if (!dbDefault && readJSON(DEFAULT_KEY) && canWrite) {
          dbDefault = readJSON(DEFAULT_KEY);
          pushLayout('default', dbDefault);
        }
        dbSpots = db.spots;
        const local = loadSaved();
        if (!dbSpots.length && local.length && canWrite) {
          // Upload this browser's saved spots once.
          Promise.all(local.map((sp) => api('POST', '/spot', { pitch: sp.pitch, name: String(sp.name),
            length_yd: (sp.size || [115, 74])[0], width_yd: (sp.size || [115, 74])[1], x: sp.x, z: sp.z, rot: sp.rotDeg })
            .catch(() => null))).then(reloadSpots);
        }
      }
      for (const p of all()) rebuild(p);
      buildLists();
      update();
      built = true;
      setOn(wantOn);
    }
    // Show / hide every planner layer; showing frames both pitches.
    function setOn(v) {
      wantOn = !!v;
      if (!built) return;
      on = wantOn;
      panel.style.display = on ? 'block' : 'none';
      pillBox.style.display = on ? 'flex' : 'none';
      // Sit just under the mode bar, which wraps on a phone.
      const bar = document.getElementById('mode-bar');
      if (on && bar) pillBox.style.top = Math.round(bar.getBoundingClientRect().bottom + 6) + 'px';
      for (const p of all()) if (p.g) p.g.visible = on;
      if (renderer.field && renderer.field.setWater) renderer.field.setWater(on && waterOn);
      drag = null;
      paintGap();
      if (on) flyTo({ x: (pitches[0].x + pitches[1].x) / 2, z: (pitches[0].z + pitches[1].z) / 2,
                      size: [Math.hypot(pitches[0].x - pitches[1].x, pitches[0].z - pitches[1].z) / YD + 70, 0] });
    }
    // No club layout yet (or offline): this device's last layout, else
    // its default, else spots saved as "now".
    function localStart() {
      const st = readJSON(STATE_KEY) || readJSON(DEFAULT_KEY);
      if (st) restore({ pitches: st.pitches });
      else {
        // First run of the auto-save: pick up spots saved as "now" (James's
        // layout from before saving was automatic, 10/22).
        for (const sp of loadSaved()) {
          const p = pitches.find((q) => q.id === sp.pitch);
          if (!p || String(sp.name).trim().toLowerCase() !== 'now') continue;
          p.x = sp.x; p.z = sp.z; p.rot = sp.rotDeg;
          if (sp.size) p.size = sizeOf(sp.size);
        }
      }
    }
    start();
    return { setOn, isOn: () => wantOn };

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
      const order = [sel].concat(boxes.filter((p) => p !== sel), pitches.filter((p) => p !== sel));
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
    const endDrag = () => { if (drag && drag.p.kind === 'box') saveBoxes(); drag = null; };
    window.addEventListener('mouseup', endDrag, true);
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
      if (drag) { endDrag(); stop(e); justDragged = false; }
    }, { capture: true, passive: false });
    window.addEventListener('keydown', (e) => {
      if (!on) return;
      if (e.key === '[') turn(-1);
      else if (e.key === ']') turn(1);
    });
  }

  window.PitchPlanner = { attach, offences, water, rect };
})();
