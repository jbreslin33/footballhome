// frontend/js/game/pitch-planner.js
//
// Drag-and-drop pitch planner [FH] (James, 10/22: "can we make it so i can
// drag the 11v11 and the 7v7 field and rotate? ... turn it red if it is
// hitting something or too close ... calc a score for it on the fly").
//
// The DEFAULT view (James: "moving an 11v11 and 7v7 pitch should be
// default get rid of other stuff"): two outlines on the real site, the
// 11v11 (starts on cyan, the plan) and a 7v7, with pills on the left.
// 10/24 (James: "the pop up needs to be able to be hidden. i need to be
// able to turn off everything. with pills. only things movable are 7v7
// and 11v11 ... diff sizes and move and rotate them. same practice
// pitches"): the panel shows only the SELECTED item and hides (✕ / 📋
// PANEL); LAYER pills switch every kind of thing off — pitches, boxes,
// handles, match, today's pitch, water, contours, trees, buildings,
// fences, props, labels, ground (field.js setLayer) — remembered on this
// device. The 11v11, the 7v7 and each practice box take any size: drag
// a ■ corner (opposite corner stays put), type length × width, or tap a
// size chip; drag the ◯ handle off the end to turn it (or ↺ ↻ / [ ]).
// Nothing else on the site moves. Every move re-checks
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
// Boxes save with the club layout (below).
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
  const NEAR = 15 * FT;                      // legal but close: marked green
  // Rules skipped by the planner — never a problem or a mark (James 10/24:
  // "shut off all baseball and softball infields as we can visually see
  // them" / "all but 1 is getting removed by grounds crew"): the main
  // infield (still drawn) and the removed softball skin. Two fences can
  // go (James 10/24: "rodeo fence can be moved slightly so allow a toggle.
  // and the softball fence allow a toggle. all others should be static"):
  // their pill hides the fence AND drops its 10 ft rule here. The C++
  // sweep's data.ranges / ⭐ BEST still avoid all of them until the
  // exporter is rerun.
  const INFO = { main_infield: true, softball_skin: true };
  const FENCE_RULES = { softball_fences: ['fence_3B', 'backstop_1B'], rodeo_fences: ['rodeo'] };
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
  // slack (m, optional): also list things legal but within slack of
  // their limit, flagged ok (the planner's green "near" marks).
  function offences(rules, R, c, slack) {
    const out = [], rb = bbox(R), sl = slack || 0;
    const add = (n, have, need, at) => out.push({ n, have, need, r, at, ok: need > 0 && have >= need });
    let r = null;
    for (r of rules) {
      if (INFO[r.n]) continue;
      if (r.k === 'poly') {
        const b = r.bb || (r.bb = bbox(r.pts));
        const lim = r.min + sl;
        if (rb[0] - b[1] > lim || b[0] - rb[1] > lim || rb[2] - b[3] > lim || b[2] - rb[3] > lim) continue;
        const d = rectDist(R, c, r.pts, !!r.c);
        if (d < lim) add(r.n, d, r.min);
      } else if (r.k === 'inside') {
        if (R.some((p) => !inPoly(p, r.pts))) add(r.n, 0, r.min);
        else { const d = rectDist(R, c, r.pts, false); if (d < r.min + sl) add(r.n, d, r.min); }
      } else if (r.k === 'outside') {
        if (inPoly(c, r.pts) || R.some((p) => inPoly(p, r.pts))) add(r.n, 0, 0);
      } else if (r.k === 'below') {
        if (R.some((p) => p[1] >= lineZ(r.pts, r.slope, p[0]))) add(r.n, 0, 0);
      } else if (r.k === 'left') {
        if (R.some((p) => p[0] >= lineX(r.pts, p[1]))) add(r.n, 0, 0);
      } else if (r.k === 'points') {
        const reach = Math.hypot(R[0][0] - c[0], R[0][1] - c[1]) + r.min + sl;
        let worst = 1e9, at = null;
        for (const t of r.pts) {
          if (Math.abs(t[0] - c[0]) > reach || Math.abs(t[1] - c[1]) > reach) continue;
          let d = inRect(t, R) ? 0 : 1e9;
          for (let i = 0; i < 4 && d > 0; i++) d = Math.min(d, segDist(t, R[i], R[(i + 1) % 4]));
          if (d < worst) { worst = d; at = t; }
        }
        if (worst < r.min + sl) add(r.n, worst, r.min, at);
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
  // Sizes offered as one-tap chips per kind (any size can be typed or
  // dragged; the water % needs a swept size, data.ranges).
  const PRESETS = {
    '11v11': [[120, 80], [115, 74], [110, 70], [100, 65], [100, 60]],
    '7v7': SEVEN_SIZES,
    box: [[40, 30], [30, 20], [25, 20], [20, 15]],
  };
  const LIMITS = { pitch: [[20, 130], [15, 100]], box: [[5, 120], [5, 80]] };
  // LAYER pills (James 10/24: "i need to be able to turn off everything.
  // with pills"): every kind of thing on screen, on/off, remembered on this
  // device. Field layers come from field.js setLayer.
  const LAYERS = [
    ['panel', '📋 PANEL'], ['pitches', '📐 PITCHES'], ['boxes', '🟧 PRACTICE'], ['ruler', '📏 GAP'],
    ['handles', '✥ HANDLES'], ['problems', '⚠ PROBLEMS'], ['match', '🏟 MATCH'], ['paint', '🟨 TODAY\'S PITCH'], ['water', '💧 WATER'],
    ['contours', '〰 CONTOURS'], ['trees', '🌳 TREES'], ['buildings', '🏠 BUILDINGS'],
    ['softball_fences', '⛓ SOFTBALL FENCE'], ['rodeo_fences', '⛓ RODEO FENCE'],
    ['props', '🐴 PROPS'], ['labels', '🔤 LABELS'], ['ground', '🟩 GROUND'],
  ];
  const FIELD_LAYERS = ['trees', 'buildings', 'softball_fences', 'rodeo_fences', 'props', 'labels', 'ground'];

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
    const LAYER_KEY = 'fh.lighthouse.designLayers.v2';   // v2: panel starts off
    try {
      const v1 = localStorage.getItem('fh.lighthouse.designLayers.v1');
      if (v1 && !localStorage.getItem(LAYER_KEY)) {
        localStorage.setItem(LAYER_KEY, JSON.stringify(Object.assign(JSON.parse(v1), { panel: false })));
        localStorage.removeItem('fh.lighthouse.designLayers.v1');
      }
    } catch (e) { /* defaults */ }
    const snapshot = () => ({
      pitches: pitches.map((p) => ({ id: p.id, x: +p.x.toFixed(2), z: +p.z.toFixed(2), rot: +p.rot.toFixed(1), size: p.size.slice() })),
      boxes: boxes.map((b) => ({ id: b.id, name: b.name, size: b.size.slice(), x: +b.x.toFixed(2), z: +b.z.toFixed(2), rot: +b.rot.toFixed(1) })),
    });
    const readJSON = (k) => { try { return JSON.parse(localStorage.getItem(k) || 'null'); } catch (e) { return null; } };
    const writeJSON = (k, v) => { try { localStorage.setItem(k, JSON.stringify(v)); return true; } catch (e) { return false; } };
    const show = Object.assign(Object.fromEntries(LAYERS.map(([k]) => [k, k !== 'panel'])), readJSON(LAYER_KEY) || {});
    // The built-in default: cyan for the 11v11, the 7v7 on its ⭐ BEST spot.
    const builtinDefault = { pitches: snapshot().pitches };   // leaves boxes alone
    // Put pitches (and, when given, boxes) where a snapshot says.
    function restore(st) {
      for (const sp of (st && st.pitches) || []) {
        const p = pitches.find((q) => q.id === sp.id);
        if (!p) continue;
        p.x = sp.x; p.z = sp.z; p.rot = sp.rot;
        if (sp.size) p.size = [+sp.size[0], +sp.size[1]];
      }
      if (st && st.boxes) {
        for (const b of boxes) if (b.g) b.g.parent.remove(b.g);
        boxes.length = 0;
        for (const b of st.boxes) boxes.push(Object.assign({ kind: 'box' }, b, { size: [+b.size[0], +b.size[1]] }));
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
    const textIn = (ph, w) => {
      const i = document.createElement('input');
      i.placeholder = ph;
      i.style.cssText = 'min-width:0;width:' + w + 'px;padding:4px 8px;border-radius:12px;border:1px solid #889;' +
        'background:rgba(255,255,255,.08);color:#f4f6fb;font:12px system-ui,sans-serif;';
      for (const ev of ['mousedown', 'touchstart', 'keydown']) i.addEventListener(ev, (e) => e.stopPropagation());
      return i;
    };
    const row = () => mk('div', 'display:flex;gap:6px;flex-wrap:wrap;margin-top:6px;align-items:center;');

    // ── the panel: only the SELECTED item, hideable (✕ or the 📋 pill) ──
    // OFF by default and docked right under the camera buttons (James
    // 10/24: "i hate the pop up ... we need it off to side" / "i don't
    // think we even need anything on it"): the field itself carries size,
    // turn and problems; the 📋 PANEL pill opens this for typed sizes,
    // spots and defaults.
    const panel = mk('div', 'position:fixed;right:8px;top:286px;z-index:20;display:none;width:280px;' +
      'background:rgba(10,14,20,.86);color:#f4f6fb;font:11px system-ui,sans-serif;border-radius:10px;' +
      'padding:6px 8px;max-width:calc(100vw - 16px);max-height:calc(100vh - 294px);overflow-y:auto;' +
      'box-sizing:border-box;');
    document.body.appendChild(panel);
    const head = mk('div', 'display:flex;align-items:center;gap:8px;');
    const syncEl = mk('div', 'flex:1;min-width:0;font-size:11px;');
    const hideBtn = mk('button', pill + 'padding:2px 9px;', '✕ hide');
    hideBtn.title = 'Hide this panel (📋 PANEL pill brings it back)';
    tap(hideBtn, () => setLayer('panel', false));
    head.append(syncEl, hideBtn);
    panel.appendChild(head);
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
    const limits = (p) => LIMITS[p.kind === 'box' ? 'box' : 'pitch'];
    let on = false, built = false, wantOn = true, sel = pitches[1], drag = null, justDragged = false;
    // Always-on gap between the two pitches (James: "show distance always
    // between 7v7 and 11v11 as they move").
    const gapRow = mk('div', 'padding:4px 0 2px;font-weight:600;');
    panel.appendChild(gapRow);
    const detail = mk('div', 'padding:6px 8px;border-radius:8px;background:rgba(255,255,255,.08);margin-top:4px;');
    panel.appendChild(detail);

    // Edit row for the selected item: name (boxes), length × width, angle,
    // size chips, turn buttons, ⭐ BEST / 🗑.
    const ctl = mk('div', '');
    panel.appendChild(ctl);
    const inputs = {};
    function setSize(p, L, W) {
      const [[l0, l1], [w0, w1]] = limits(p);
      L = Math.round(Math.max(l0, Math.min(l1, +L || p.size[0])));
      W = Math.round(Math.max(w0, Math.min(w1, +W || p.size[1])));
      if (L === p.size[0] && W === p.size[1]) return false;
      p.size = [L, W];
      rebuild(p);
      return true;
    }
    const setRot = (p, deg) => { p.rot = ((deg % 360) + 360) % 360; };
    function paintCtl() {
      ctl.innerHTML = '';
      for (const k in inputs) delete inputs[k];
      const p = sel;
      const r1 = row();
      if (p.kind === 'box') {
        const nm = textIn('name', 110);
        nm.value = p.name;
        const rename = () => {
          const v = nm.value.trim();
          if (!v || v === p.name) return;
          p.name = v;
          rebuild(p);
          buildPills();
          update();
        };
        nm.addEventListener('change', rename);
        nm.addEventListener('keydown', (e) => { if (e.key === 'Enter') rename(); });
        r1.appendChild(nm);
      }
      const L = textIn('length', 52), W = textIn('width', 52), A = textIn('°', 52);
      L.type = W.type = A.type = 'number';
      inputs.L = L; inputs.W = W; inputs.A = A;
      const applySize = () => { if (setSize(p, L.value, W.value)) update(); else paint(); };
      const applyRot = () => { setRot(p, +A.value || 0); update(); };
      for (const i of [L, W]) {
        i.addEventListener('change', applySize);
        i.addEventListener('keydown', (e) => { if (e.key === 'Enter') applySize(); });
      }
      A.addEventListener('change', applyRot);
      A.addEventListener('keydown', (e) => { if (e.key === 'Enter') applyRot(); });
      r1.append(mk('span', 'opacity:.75;font-size:11px;', 'size'), L, mk('span', '', '×'), W,
                mk('span', 'opacity:.75', 'yd'), mk('span', 'opacity:.75;font-size:11px;margin-left:6px;', 'angle'), A,
                mk('span', 'opacity:.75', '°'));
      ctl.appendChild(r1);
      const r2 = row();
      for (const [l, w] of PRESETS[p.kind === 'box' ? 'box' : p.id] || []) {
        const b = mk('button', pill + (DATA.ranges[l + 'x' + w] ? 'border-color:#29a8ff;' : ''), l + '×' + w);
        b.title = DATA.ranges[l + 'x' + w] ? 'swept size — dry % available' : '';
        tap(b, () => { if (setSize(p, l, w)) update(); });
        r2.appendChild(b);
      }
      ctl.appendChild(r2);
      const r3 = row();
      for (const [t, d] of [['↺ 5°', -5], ['↺ 1°', -1], ['↻ 1°', 1], ['↻ 5°', 5], ['⟲ 90°', 90]]) {
        const b = mk('button', pill, t);
        let rep = null;
        const start = (e) => {
          e.preventDefault(); e.stopPropagation(); turn(d);
          if (Math.abs(d) < 90) rep = setInterval(() => turn(d), 150);
        };
        const stop = () => { if (rep) clearInterval(rep); rep = null; };
        b.addEventListener('mousedown', start);
        b.addEventListener('touchstart', start);
        for (const ev of ['mouseup', 'mouseleave', 'touchend', 'touchcancel']) b.addEventListener(ev, stop);
        r3.appendChild(b);
      }
      if (p.kind === 'box') {
        const del = mk('button', pill + 'color:#ff8a94;', '🗑 DELETE');
        tap(del, () => removeBox(p));
        r3.appendChild(del);
      } else {
        // ⭐ BEST: snap to the driest legal spot of its size (data.ranges).
        const r = DATA.ranges[p.size[0] + 'x' + p.size[1]];
        const best = mk('button', pill + 'border-color:#ffd24d;' + (r && r.at ? '' : 'opacity:.4;'), '⭐ BEST');
        best.title = r && r.at ? 'Driest legal spot for this size' : 'No sweep for this size';
        tap(best, () => {
          const rr = DATA.ranges[p.size[0] + 'x' + p.size[1]];
          if (!rr || !rr.at) return;
          p.x = rr.at[0]; p.z = rr.at[1]; p.rot = rr.at[2];
          update();
          flyTo(p);
        });
        r3.appendChild(best);
      }
      const fly = mk('button', pill, '📍 GO');
      tap(fly, () => flyTo(p));
      r3.appendChild(fly);
      ctl.appendChild(r3);
      spotBox.style.display = p.kind === 'box' ? 'none' : 'flex';
      paintSpots();
    }
    const turn = (d) => { setRot(sel, sel.rot + d); update(); };
    function removeBox(b) {
      boxes.splice(boxes.indexOf(b), 1);
      if (b.g) b.g.parent.remove(b.g);
      select(pitches[0]);
      buildPills();
      update();
    }

    // SPOTS (James: "click button to reset it there. allow for saving a
    // spot and delete a spot and give it a name"): built-in spots from
    // layout.planSpots + the club's saved ones. Tap a spot = move the
    // selected pitch there; 💾 saves where it is now; ✕ deletes a saved one.
    const SPOT_KEY = 'fh.lighthouse.planSpots.v1';
    const loadSaved = () => {
      try { return JSON.parse(localStorage.getItem(SPOT_KEY) || '[]'); } catch (e) { return []; }
    };
    const storeSaved = (list) => {
      try { localStorage.setItem(SPOT_KEY, JSON.stringify(list)); return true; } catch (e) { return false; }
    };
    const spotBox = row();
    panel.appendChild(spotBox);
    // Spots in one shape: { id?, name, pitch, x, z, rotDeg, size }.
    const spotList = () => (dbSpots
      ? dbSpots.map((s) => ({ id: s.id, name: s.name, pitch: s.pitch, x: s.x, z: s.z, rotDeg: s.rot,
                             size: [s.length_yd, s.width_yd] }))
      : loadSaved());
    const reloadSpots = () => api('GET', '').then((j) => { dbSpots = j.spots; paintSpots(); }).catch(() => {});
    function applySpot(sp) {
      const p = pitches.find((q) => q.id === sp.pitch);
      if (!p) return;
      p.x = sp.x; p.z = sp.z; p.rot = sp.rotDeg;
      if (sp.size) setSize(p, sp.size[0], sp.size[1]);
      select(p);
      update();
      flyTo(p);
    }
    function paintSpots() {
      spotBox.innerHTML = '';
      if (sel.kind === 'box') return;
      spotBox.appendChild(mk('span', 'opacity:.75;font-size:11px;', '📌 ' + sel.id + ' spots:'));
      const saved = spotList();
      const list = (LAY.planSpots || []).map((sp) => ({ sp, saved: false }))
        .concat(saved.map((sp, i) => ({ sp, saved: true, i })))
        .filter((e) => e.sp.pitch === sel.id);
      for (const e of list) {
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
            const l = loadSaved();
            l.splice(e.i, 1);
            storeSaved(l);
            paintSpots();
          });
          spotBox.appendChild(x);
        }
      }
      const name = textIn('name this spot', 120);
      const save = mk('button', pill, '💾 SAVE');
      const doSave = () => {
        const n = name.value.trim() || (sel.id + ' ' + new Date().toLocaleString());
        if (dbSpots && canWrite) {
          api('POST', '/spot', { pitch: sel.id, name: n, length_yd: sel.size[0], width_yd: sel.size[1],
                                 x: +sel.x.toFixed(2), z: +sel.z.toFixed(2), rot: +sel.rot.toFixed(1) })
            .then(reloadSpots).catch((err) => setSync('⚠ spot not saved (' + err.message + ')', false));
          return;
        }
        const l = loadSaved();
        l.push({ name: n, pitch: sel.id, x: +sel.x.toFixed(2), z: +sel.z.toFixed(2),
                 rotDeg: +sel.rot.toFixed(1), size: sel.size.slice() });
        if (!storeSaved(l)) save.textContent = '⚠ NOT SAVED';
        paintSpots();
      };
      tap(save, doSave);
      name.addEventListener('keydown', (e) => { if (e.key === 'Enter') doSave(); });
      spotBox.append(name, save);
    }

    // Whole-layout row: add a practice box, copy, default.
    const addRow = row();
    addRow.style.borderTop = '1px solid rgba(255,255,255,.15)';
    addRow.style.paddingTop = '6px';
    const addName = textIn('practice box name (Monday…)', 170);
    const addBtn = mk('button', pill + 'border-color:#ffa630;', '➕ ADD BOX');
    const addBox = () => {
      if (!on) return;   // field still loading
      // Dropped where the camera is looking, 40 x 30 yd, square to the 11v11.
      const t = renderer.field.site.worldToLocal(renderer.rig.target.clone());
      const b = { kind: 'box', id: 'box-' + Date.now(), name: addName.value.trim() || 'Practice ' + (boxes.length + 1),
                  size: [40, 30], x: t.x, z: t.z, rot: pitches[0].rot };
      boxes.push(b);
      addName.value = '';
      if (!show.boxes) setLayer('boxes', true);
      rebuild(b);
      select(b);
      buildPills();
      update();
    };
    tap(addBtn, addBox);
    addName.addEventListener('keydown', (e) => { if (e.key === 'Enter') addBox(); });
    const copyBtn = mk('button', pill, 'COPY');
    tap(copyBtn, () => {
      const txt = all().map((p) => `${title(p)} ${p.size[0]}x${p.size[1]} yd at (${p.x.toFixed(1)}, ${p.z.toFixed(1)}) ${p.rot.toFixed(0)}°` +
        ` — ${p.ev.ok ? 'OK' : 'BLOCKED'}` + (p.ev.w.pct != null ? `, dry ${p.ev.w.pct.toFixed(0)}%` : '') +
        `, main infield ${(p.ev.infield / YD).toFixed(1)} yd`).join('\n');
      if (navigator.clipboard) navigator.clipboard.writeText(txt).catch(() => {});
      copyBtn.textContent = 'COPIED';
      setTimeout(() => { copyBtn.textContent = 'COPY'; }, 1200);
    });
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
      select(pitches[0]);
      buildPills();
      update();
    });
    addRow.append(addName, addBtn, copyBtn, setDefBtn, resetBtn);
    panel.appendChild(addRow);

    // Outline (4 strips + halfway) and a faint fill, in a group per pitch
    // turned like field.js's boxes, so a drag only moves the group.
    const fillMat = (c) => new THREE.MeshBasicMaterial({ color: c, transparent: true, opacity: 0.14,
      depthWrite: false, side: THREE.DoubleSide });
    const visibleOf = (p) => on && (p.kind === 'box' ? show.boxes : show.pitches);
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
      // Big name on the grass, its size in yards under it (James 10/24:
      // "when we resize pitch it needs to say size ... on the pitch in
      // yards") — rebuilt on every size change.
      const cv = document.createElement('canvas');
      cv.width = 512; cv.height = 224;
      const c2 = cv.getContext('2d');
      const text = (t, max, y, color) => {
        c2.font = 'bold ' + max + 'px sans-serif';
        const fs = Math.min(max, Math.floor(max * 480 / Math.max(1, c2.measureText(t).width)));
        c2.font = 'bold ' + fs + 'px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
        c2.lineWidth = 14; c2.strokeStyle = 'rgba(0,0,0,.85)'; c2.strokeText(t, 256, y);
        c2.fillStyle = color; c2.fillText(t, 256, y);
      };
      text(title(p), 96, 66, p.kind === 'box' ? '#ffd29a' : '#ffffff');
      text(p.size[0] + ' × ' + p.size[1] + ' yd', 76, 172, '#ffd24d');
      const lw = Math.min(W * 0.8, L * 0.9);
      const lab = new THREE.Mesh(new THREE.PlaneGeometry(lw, lw * 224 / 512),
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
      p.cells.visible = show.water;
      g.add(p.cells);
      g.position.set(p.x, 0.6, p.z);
      g.rotation.y = -p.rot * D2R;
      g.visible = visibleOf(p);
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

    // ── handles on the selected item: ■ corners resize, ◯ turns ──
    const HCOL = 0xffd24d;
    const hMat = new THREE.MeshBasicMaterial({ color: HCOL, depthTest: false, side: THREE.DoubleSide });
    const hRim = new THREE.MeshBasicMaterial({ color: 0x10141a, depthTest: false, side: THREE.DoubleSide });
    const handles = { g: new THREE.Group(), corners: [], rot: null, stem: null };
    const flat = (geo, mat, order) => {
      const m = new THREE.Mesh(geo, mat);
      m.rotation.x = -Math.PI / 2;
      m.renderOrder = order;
      return m;
    };
    for (let i = 0; i < 4; i++) {
      const c = new THREE.Group();
      c.add(flat(new THREE.PlaneGeometry(1.25, 1.25), hRim, 65), flat(new THREE.PlaneGeometry(1, 1), hMat, 66));
      handles.corners.push(c);
      handles.g.add(c);
    }
    handles.rot = new THREE.Group();
    handles.rot.add(flat(new THREE.CircleGeometry(0.75, 24), hRim, 65), flat(new THREE.CircleGeometry(0.6, 24), hMat, 66));
    handles.stem = flat(new THREE.PlaneGeometry(1, 0.18), hMat, 64);
    handles.g.add(handles.rot, handles.stem);
    // Handle size in metres: about the same on screen at any zoom.
    const hSize = () => Math.max(1, Math.min(8, renderer.camera.position.distanceTo(renderer.rig.target) * 0.022));
    const rotOff = (p, hs) => p.size[0] * YD / 2 + Math.max(4, hs * 3);
    function placeHandles() {
      const site = renderer.field && renderer.field.site;
      if (!site) return;
      if (!handles.g.parent) site.add(handles.g);
      const vis = on && show.handles && sel && sel.g && sel.g.visible;
      handles.g.visible = !!vis;
      if (!vis) return;
      const hs = hSize(), L = sel.size[0] * YD, W = sel.size[1] * YD, ro = rotOff(sel, hs);
      handles.g.position.set(sel.x, 0.8, sel.z);
      handles.g.rotation.y = -sel.rot * D2R;
      [[-1, -1], [1, -1], [1, 1], [-1, 1]].forEach(([su, sv], i) => {
        handles.corners[i].position.set(su * L / 2, 0, sv * W / 2);
        handles.corners[i].scale.setScalar(hs);
      });
      handles.rot.position.set(ro, 0, 0);
      handles.rot.scale.setScalar(hs);
      handles.stem.position.set((L / 2 + ro) / 2, 0, 0);
      handles.stem.scale.set(Math.max(0.01, ro - L / 2), hs, 1);
    }
    (function tick() {
      if (on) { placeHandles(); if (probs.length) paintProblems(); }
      requestAnimationFrame(tick);
    })();

    function evaluate(p) {
      const th = p.rot * D2R, L = p.size[0] * YD, W = p.size[1] * YD;
      const R = rect(p.x, p.z, th, L, W), c = [p.x, p.z];
      // Problems + things within NEAR of their limit (James 10/24: "show
      // distance from fences etc in feet. as we need 10 feet").
      const found = offences(DATA.rules, R, c, NEAR);
      const off = found.filter((o) => !o.ok), near = found.filter((o) => o.ok);
      if (p.kind === 'box') {
        // Practice boxes stay off both pitches (touching is fine).
        for (const q of pitches)
          if (q.R && closest(R, q.R).d <= 0) off.push({ n: 'on_' + q.id, have: 0, need: 0, r: { k: 'poly', pts: q.R, c: 1 } });
      } else {
        const o = pitches.find((q) => q !== p);
        if (o && o.R) {
          const d = inRect(c, o.R) || inRect([o.x, o.z], R) ? 0 : rectDist(R, c, o.R, true);
          if (d < GAP) off.push({ n: 'other', have: d, need: GAP, r: { k: 'poly', pts: o.R, c: 1 } });
        }
      }
      off.sort((a, b) => (a.have - a.need) - (b.have - b.need));
      const main = DATA.rules.find((r) => r.n === 'main_infield');
      const cells = [];
      p.R = R;
      p.ev = { ok: off.length === 0, off, near,
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
    // Exact (James 10/24: "i need to know exact probs for the field. and
    // exact distance for prob"): yards to the hundredth + feet.
    const exact = (m) => (m / FT).toFixed(1) + ' ft (' + (m / YD).toFixed(2) + ' yd)';
    const feet = (m) => +(m / FT).toFixed(1) + ' ft';
    // Where a problem is: { a: point on the pitch edge, b: point on the
    // obstacle } at the measured distance; overlapping = b inside.
    const cpSeg = (p, a, b) => {
      const dx = b[0] - a[0], dz = b[1] - a[1], l2 = dx * dx + dz * dz;
      const t = l2 === 0 ? 0 : Math.max(0, Math.min(1, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dz) / l2));
      return [a[0] + t * dx, a[1] + t * dz];
    };
    function where(R, o) {
      const edges = (P, closed) => {
        const out = [];
        for (let i = 0; i + 1 < P.length + (closed ? 1 : 0); i++) out.push([P[i], P[(i + 1) % P.length]]);
        return out;
      };
      const RE = edges(R, true);
      if (o.at) {
        let best = null;
        for (const [a, b] of RE) {
          const q = cpSeg(o.at, a, b), d = Math.hypot(q[0] - o.at[0], q[1] - o.at[1]);
          if (!best || d < best.d) best = { d, a: q, b: o.at };
        }
        return best;
      }
      const r = o.r;
      if (!r || !r.pts) return null;
      if (r.k === 'below' || r.k === 'left') {
        // The corner over the line.
        const bad = R.find((p) => (r.k === 'below' ? p[1] >= lineZ(r.pts, r.slope, p[0]) : p[0] >= lineX(r.pts, p[1])));
        return bad ? { d: 0, a: bad, b: bad } : null;
      }
      const PE = edges(r.pts, !!r.c || r.k === 'outside');
      let best = null;
      for (const [a, b] of RE)
        for (const [c, e] of PE) {
          if (crosses(a, b, c, e)) {
            // Crossing point: overlapping here.
            const d1 = orient(c, e, a), d2 = orient(c, e, b), t = d1 / (d1 - d2);
            const x = [a[0] + t * (b[0] - a[0]), a[1] + t * (b[1] - a[1])];
            return { d: 0, a: x, b: x };
          }
          for (const [p, s0, s1, flip] of [[c, a, b, true], [e, a, b, true], [a, c, e, false], [b, c, e, false]]) {
            const q = cpSeg(p, s0, s1), d = Math.hypot(q[0] - p[0], q[1] - p[1]);
            if (!best || d < best.d) best = flip ? { d, a: q, b: p } : { d, a: p, b: q };
          }
        }
      if (best && o.have <= 0) {
        // Wholly inside one another: mark the obstacle point inside.
        const inside = r.pts.find((p) => inRect(p, R));
        if (inside) return { d: 0, a: inside, b: inside };
        return { d: 0, a: [R[0][0], R[0][1]], b: [R[0][0], R[0][1]] };
      }
      return best;
    }

    // ── left column: an item pill per pitch/box, then the layer pills ──
    const pillBox = mk('div', 'position:fixed;left:8px;top:116px;display:flex;flex-direction:column;gap:6px;z-index:12;' +
      'max-width:min(300px,calc(100vw - 16px));max-height:calc(100vh - 124px);overflow-y:auto;');
    const pills = {};
    const pillList = mk('div', 'display:flex;flex-direction:column;gap:6px;');
    const itemPill = 'display:flex;align-items:center;gap:6px;min-width:0;min-height:0;padding:4px 10px;' +
      'border-radius:14px;border:2px solid #33ff66;background:rgba(10,14,20,.72);color:#f4f6fb;' +
      'font:600 11px system-ui,sans-serif;cursor:pointer;text-align:left;';
    function buildPills() {
      pillList.innerHTML = '';
      for (const k in pills) delete pills[k];
      for (const p of all()) {
        const b = mk('button', itemPill + 'flex:1;');
        tap(b, () => {
          if (!on) return;
          select(p);
          flyTo(p);
        });
        pills[p.id] = b;
        const line = mk('div', 'display:flex;gap:4px;align-items:center;');
        line.appendChild(b);
        if (p.kind === 'box') {
          const x = mk('button', itemPill + 'border-color:#ff6b78;color:#ff8a94;padding:4px 8px;flex:none;', '✕');
          x.title = 'Delete "' + p.name + '"';
          tap(x, () => removeBox(p));
          line.appendChild(x);
        }
        pillList.appendChild(line);
        paintPill(p);
      }
    }
    // Every HUD hides (James 10/24: "every hud needs to have a hide mode
    // right?"): ▾ collapses the item pills and the layer pills, ✕ hides
    // the panel, ◐ HUD (bottom left) hides the whole HUD but itself.
    const fold = (key, text, body) => {
      const h = mk('button', 'min-width:0;min-height:0;padding:2px 8px;border:0;border-radius:10px;align-self:flex-start;' +
        'background:rgba(10,14,20,.72);color:#ffd24d;font:700 10px system-ui,sans-serif;cursor:pointer;');
      const paintFold = () => {
        h.textContent = (show[key] === false ? '▸ ' : '▾ ') + text;
        body.style.display = show[key] === false ? 'none' : '';
      };
      tap(h, () => { show[key] = show[key] === false; writeJSON(LAYER_KEY, show); paintFold(); });
      paintFold();
      return h;
    };
    const itemsBody = mk('div', 'display:flex;flex-direction:column;gap:6px;');
    pillBox.appendChild(fold('ui_items', 'PITCHES & BOXES', itemsBody));
    pillBox.appendChild(itemsBody);
    itemsBody.appendChild(pillList);
    const addPill = mk('button', itemPill + 'border-color:#ffa630;border-style:dashed;', '➕ PRACTICE BOX');
    addPill.title = 'Drop a 40 × 30 yd box where the camera looks';
    tap(addPill, () => addBox());
    itemsBody.appendChild(addPill);
    const layerBox = mk('div', 'display:flex;flex-wrap:wrap;gap:4px;padding:6px;border-radius:12px;' +
      'background:rgba(10,14,20,.72);');
    const layerPills = {};
    const lp = 'min-width:0;min-height:0;padding:3px 8px;border-radius:11px;border:1px solid #889;' +
      'font:600 10px system-ui,sans-serif;cursor:pointer;';
    const paintLayerPill = (k) => {
      const b = layerPills[k];
      if (!b) return;
      b.style.background = show[k] ? '#ffd24d' : 'transparent';
      b.style.color = show[k] ? '#10141a' : '#c8ccd4';
      b.style.borderColor = show[k] ? '#ffd24d' : '#667';
      b.style.textDecoration = show[k] ? 'none' : 'line-through';
    };
    for (const [k, t] of LAYERS) {
      const b = mk('button', lp, t);
      layerPills[k] = b;
      tap(b, () => setLayer(k, !show[k]));
      layerBox.appendChild(b);
      paintLayerPill(k);
    }
    for (const [t, v] of [['ALL ON', true], ['ALL OFF', false]]) {
      const b = mk('button', lp + 'background:rgba(255,255,255,.12);color:#f4f6fb;', t);
      tap(b, () => {
        // ALL OFF keeps the pitches, boxes and handles: the things being designed.
        for (const [k] of LAYERS) {
          if (k === 'panel' || FENCE_RULES[k]) continue;   // fence pills change rules: only by hand
          show[k] = v || ['pitches', 'boxes', 'handles', 'problems'].includes(k);
        }
        writeJSON(LAYER_KEY, show);
        applyLayers();
      });
      layerBox.appendChild(b);
    }
    pillBox.appendChild(fold('ui_layers', 'SHOW / HIDE', layerBox));
    pillBox.appendChild(layerBox);
    document.body.appendChild(pillBox);
    const HUD_IDS = ['mode-bar', 'back', 'btn-cam', 'btn-zoom-in', 'btn-zoom-out', 'btn-follow'];
    const hudBtn = mk('button', 'position:fixed;left:8px;bottom:calc(env(safe-area-inset-bottom, 0px) + 8px);z-index:30;' +
      'display:none;min-width:0;min-height:0;padding:5px 11px;border-radius:14px;border:2px solid #ffd24d;' +
      'background:rgba(10,14,20,.8);color:#ffd24d;font:700 11px system-ui,sans-serif;cursor:pointer;');
    document.body.appendChild(hudBtn);
    function applyHud() {
      const hide = on && show.ui_hud === false;
      hudBtn.style.display = on ? 'block' : 'none';
      hudBtn.textContent = hide ? '◑ SHOW HUD' : '◐ HUD';
      hudBtn.title = hide ? 'Bring the controls back' : 'Hide every control — just the field';
      pillBox.style.display = on && !hide ? 'flex' : 'none';
      panel.style.display = on && !hide && show.panel ? 'block' : 'none';
      for (const id of HUD_IDS) {
        const el = document.getElementById(id);
        if (el) el.style.visibility = hide ? 'hidden' : '';
      }
    }
    tap(hudBtn, () => { show.ui_hud = show.ui_hud === false; writeJSON(LAYER_KEY, show); applyHud(); });
    function setLayer(k, v) {
      show[k] = !!v;
      writeJSON(LAYER_KEY, show);
      applyLayers();
      if (FENCE_RULES[k] && built) update(true);
    }
    // Apply every layer (DESIGN on): planner layers + field.js layers +
    // the match (pitch, goals, players, ball).
    function applyLayers() {
      for (const [k] of LAYERS) paintLayerPill(k);
      // Fences hidden = gone: their 10 ft rule goes with them.
      for (const k in FENCE_RULES) for (const n of FENCE_RULES[k]) INFO[n] = !show[k];
      if (!on) return;
      const f = renderer.field;
      applyHud();
      for (const p of all()) if (p.g) p.g.visible = visibleOf(p);
      for (const p of all()) if (p.cells) p.cells.visible = show.water;
      if (f) {
        if (f.setWater) f.setWater(show.water);
        if (f.setOldPitch) f.setOldPitch(show.paint);
        if (f.setContours) f.setContours(show.contours ? 'lidar' : 'off');
        if (f.setLayer) for (const k of FIELD_LAYERS) f.setLayer(k, show[k]);
      }
      renderer.showMatch = show.match;
      for (const m of renderer.pitchParts || []) m.visible = show.match;
      paintGap();
      placeHandles();
      paint();
      paintProblems();
    }
    // Leaving DESIGN: everything back on; client.js then sets its mode's
    // contours / painted pitch.
    function resetLayers() {
      const f = renderer.field;
      if (f && f.setLayer) for (const k of FIELD_LAYERS) f.setLayer(k, true);
      if (f && f.setWater) f.setWater(false);
      for (const m of renderer.pitchParts || []) m.visible = true;
    }
    function paintPill(p) {
      const b = pills[p.id];
      if (!b) return;
      // Green when good, red when not — boxes too (James 10/24: "and turn green when good").
      const hex = !p.ev ? '#8899aa' : p.ev.ok ? '#33ff66' : '#ff3344';
      b.style.borderColor = hex;
      b.style.background = p === sel ? 'rgba(255,210,77,.28)' : 'rgba(10,14,20,.72)';
      b.innerHTML = '<span style="width:10px;height:10px;border-radius:50%;flex:none;background:' + hex + '"></span>' +
        (p === sel ? '▶ ' : '') + (p.kind === 'box' ? '🟧 ' : '📐 ') + title(p) + ' ' + p.size[0] + '×' + p.size[1] +
        (p.ev ? (p.ev.w.pct != null ? ' · dry ' + p.ev.w.pct.toFixed(0) + '%' : '') + ' · ' +
          (p.ev.ok ? 'clear' : '✗ ' + label(p.ev.off[0].n)) : '');
    }

    function select(p) {
      sel = p;
      paintCtl();
      paint();
      paintProblems();
    }
    function paint() {
      for (const p of all()) paintPill(p);
      for (const p of all()) {
        if (!p.ev || !p.lineMat) continue;
        const col = p.ev.ok ? 0x33ff66 : 0xff3344;
        p.lineMat.color.setHex(col);
        p.fill.material.color.setHex(col);
      }
      const p = sel, ev = p.ev;
      for (const [k, v] of [['L', p.size[0]], ['W', p.size[1]], ['A', +p.rot.toFixed(1)]])
        if (inputs[k] && document.activeElement !== inputs[k]) inputs[k].value = v;
      if (!ev) return;
      const w = ev.w;
      const why = ev.ok ? '<span style="color:#5f6">✓ clear of everything</span>'
        : !show.problems ? '<span style="color:#ff6b78">✗ ' + ev.off.length + ' problem' + (ev.off.length > 1 ? 's' : '') +
            '</span> <span style="opacity:.6">(⚠ PROBLEMS pill to show)</span>'
        : '<b style="color:#ff6b78">✗ ' + ev.off.length + ' problem' + (ev.off.length > 1 ? 's' : '') + ':</b>' +
          ev.off.map((o, i) => '<br><span style="color:#ff6b78">' + (i + 1) + '. ' + label(o.n) + ' — ' +
            (o.need > 0
              ? (o.have <= 0 ? 'overlapping' : exact(o.have) + ' away') + ', needs ' + exact(o.need) +
                ' → move <b>' + exact(o.need - Math.max(0, o.have)) + '</b>' + (o.have <= 0 ? ' past it' : ' further')
              : 'must not touch — it does') + '</span>').join('');
      detail.innerHTML = '<b>▶ ' + (p.kind === 'box' ? '🟧 ' : '📐 ') + title(p) + ' ' + p.size[0] + '×' + p.size[1] +
        ' yd</b> · ' + p.rot.toFixed(0) + '° · ' +
        (w.pct != null ? 'dry <b>' + w.pct.toFixed(0) + '%</b>'
          : (ev.toPitch != null ? '↔ 11v11 <b>' + (ev.toPitch <= 0 ? 'on it' : fmt(ev.toPitch)) + '</b>' : '')) +
        '<br>' + why;
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
      const vis = on && show.ruler && show.pitches;
      ruler.bar.visible = vis && g.d > 0;
      if (g.d > 0) {
        const mx = (g.a[0] + g.b[0]) / 2, mz = (g.a[1] + g.b[1]) / 2;
        ruler.bar.position.set(mx, 0.7, mz);
        ruler.bar.rotation.y = -Math.atan2(g.b[1] - g.a[1], g.b[0] - g.a[0]);
        ruler.strip.scale.x = Math.max(0.01, g.d);
        ruler.lab.position.set(mx, 0.75, mz);
      } else {
        // Overlapping: label sits at the 7v7's centre.
        ruler.lab.position.set(B.x, 0.75, B.z);
      }
      ruler.lab.visible = vis;
    }

    // PROBLEM markers: a red line from the selected item's edge to each
    // thing it is too close to, numbered like the panel list, with the
    // exact distance. ⚠ PROBLEMS pill hides them.
    const probs = [];
    function probMark() {
      const strip = new THREE.Mesh(new THREE.PlaneGeometry(1, 0.35),
        new THREE.MeshBasicMaterial({ color: 0xff3344, depthTest: false, side: THREE.DoubleSide }));
      strip.rotation.x = -Math.PI / 2;
      strip.renderOrder = 63;
      const bar = new THREE.Group();
      bar.add(strip);
      const dot = new THREE.Mesh(new THREE.CircleGeometry(0.6, 16),
        new THREE.MeshBasicMaterial({ color: 0xff3344, depthTest: false, side: THREE.DoubleSide }));
      dot.rotation.x = -Math.PI / 2;
      dot.renderOrder = 63;
      const cv = document.createElement('canvas');
      cv.width = 512; cv.height = 128;
      const tex = new THREE.CanvasTexture(cv);
      const lab = new THREE.Mesh(new THREE.PlaneGeometry(1, 0.25),
        new THREE.MeshBasicMaterial({ map: tex, transparent: true, depthWrite: false, depthTest: false }));
      lab.rotation.x = -Math.PI / 2;
      lab.renderOrder = 64;
      renderer.field.site.add(bar, dot, lab);
      return { bar, strip, dot, lab, cv, tex, txt: null, col: 0xff3344 };
    }
    function paintProblems() {
      const site = renderer.field && renderer.field.site;
      if (!site) return;
      // Every visible pitch and box shows its problems (James 10/24:
      // "practice boxes need to show obstructions too"); the green "close"
      // marks only for the selected one, to keep the grass readable.
      const list = [];
      if (on && show.problems)
        for (const p of all()) {
          if (!p.ev || !p.g || !p.g.visible) continue;
          for (const o of p.ev.off) list.push([p, o]);
          if (p === sel) for (const o of p.ev.near) list.push([p, o]);
        }
      const hs = hSize();
      let k = 0, n = 0, last = null;
      for (const [p, o] of list) {
        if (p !== last) { last = p; n = 0; }
        const w = where(p.R, o);
        if (!w) continue;
        const m = probs[k] || (probs[k] = probMark());
        k++;
        // Red = problem (numbered like the panel), green = legal but close.
        const txt = o.ok ? feet(o.have) + ' ✓ (' + feet(o.need) + ')'
          : ++n + '. ' + (o.need > 0 ? (o.have <= 0 ? 'ON IT' : feet(o.have)) + ' / ' + feet(o.need)
            : /^on_/.test(o.n) ? 'ON ' + o.n.slice(3).toUpperCase() : 'TOUCHING');
        const col = o.ok ? 0x33dd66 : 0xff3344;
        if (m.col !== col) {
          m.strip.material.color.setHex(col);
          m.dot.material.color.setHex(col);
          m.col = col;
          m.txt = null;
        }
        if (m.txt !== txt) {
          const c2 = m.cv.getContext('2d');
          c2.clearRect(0, 0, 512, 128);
          c2.font = 'bold 72px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
          c2.lineWidth = 14; c2.strokeStyle = 'rgba(0,0,0,.9)'; c2.strokeText(txt, 256, 64);
          c2.fillStyle = col === 0x33dd66 ? '#8dffaa' : '#ff8a94'; c2.fillText(txt, 256, 64);
          m.tex.needsUpdate = true;
          m.txt = txt;
        }
        const d = Math.hypot(w.b[0] - w.a[0], w.b[1] - w.a[1]);
        const mx = (w.a[0] + w.b[0]) / 2, mz = (w.a[1] + w.b[1]) / 2;
        m.bar.visible = d > 0.05;
        m.bar.position.set(mx, 0.75, mz);
        m.bar.rotation.y = -Math.atan2(w.b[1] - w.a[1], w.b[0] - w.a[0]);
        m.strip.scale.set(Math.max(0.01, d), Math.max(1, hs * 0.5), 1);
        m.dot.visible = true;
        m.dot.position.set(w.b[0], 0.76, w.b[1]);
        m.dot.scale.setScalar(Math.max(1, hs * 0.6));
        m.lab.visible = true;
        m.lab.position.set(mx, 0.8, mz + hs * 0.6);
        m.lab.scale.set(hs * 6, hs * 6, 1);
      }
      for (; k < probs.length; k++) probs[k].bar.visible = probs[k].dot.visible = probs[k].lab.visible = false;
    }

    function update(noSave) {
      for (const p of all()) if (p.g) { p.g.position.x = p.x; p.g.position.z = p.z; p.g.rotation.y = -p.rot * D2R; }
      // Each pitch's 10 yd gap reads the other's rect: settle both, twice;
      // then the boxes, which read the pitches.
      for (let k = 0; k < 2; k++) for (const p of pitches) evaluate(p);
      for (const b of boxes) evaluate(b);
      paint();
      paintGap();
      placeHandles();
      paintProblems();
      if (on && !noSave) saveState();
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
      buildPills();
      update();
      select(sel);
      built = true;
      setOn(wantOn);
    }
    // Show / hide every planner layer; showing frames both pitches.
    function setOn(v) {
      wantOn = !!v;
      if (!built) return;
      on = wantOn;
      // Sit just under the mode bar, which wraps on a phone.
      const bar = document.getElementById('mode-bar');
      if (on && bar) {
        const top = Math.round(bar.getBoundingClientRect().bottom + 6);
        pillBox.style.top = top + 'px';
        pillBox.style.maxHeight = 'calc(100vh - ' + (top + 8) + 'px)';
      }
      drag = null;
      if (on) applyLayers();
      else {
        applyHud();
        for (const p of all()) if (p.g) p.g.visible = false;
        resetLayers();
        paintGap();
        placeHandles();
        paintProblems();
      }
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
          if (sp.size) p.size = [+sp.size[0], +sp.size[1]];
        }
      }
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
    // Site point -> the item's own axes (u along its length, v across).
    const local = (p, s) => {
      const th = p.rot * D2R, c = Math.cos(th), sn = Math.sin(th), dx = s[0] - p.x, dz = s[1] - p.z;
      return [dx * c + dz * sn, -dx * sn + dz * c];
    };
    // Grab order: the selected item's handles, then any visible item under
    // the pointer (selected first, boxes over pitches).
    function grab(cx, cy) {
      const s = sitePoint(cx, cy);
      if (!s) return false;
      if (handles.g.visible && sel) {
        const hs = hSize(), [u, v] = local(sel, s), L = sel.size[0] * YD, W = sel.size[1] * YD, reach = hs * 1.3;
        if (Math.hypot(u - rotOff(sel, hs), v) < reach) {
          drag = { p: sel, kind: 'rot' };
          return true;
        }
        for (const [su, sv] of [[-1, -1], [1, -1], [1, 1], [-1, 1]]) {
          if (Math.hypot(u - su * L / 2, v - sv * W / 2) < reach) {
            // The opposite corner stays put.
            const th = sel.rot * D2R, c = Math.cos(th), sn = Math.sin(th), au = -su * L / 2, av = -sv * W / 2;
            drag = { p: sel, kind: 'size', ax: sel.x + au * c - av * sn, az: sel.z + au * sn + av * c };
            return true;
          }
        }
      }
      const order = [sel].concat(boxes.filter((p) => p !== sel), pitches.filter((p) => p !== sel));
      const p = order.find((q) => q.R && q.g && q.g.visible && inRect(s, q.R));
      if (!p) return false;
      if (p !== sel) select(p);
      drag = { p, kind: 'move', dx: p.x - s[0], dz: p.z - s[1] };
      return true;
    }
    function move(cx, cy) {
      const s = sitePoint(cx, cy);
      if (!s) return;
      const p = drag.p;
      if (drag.kind === 'move') {
        p.x = s[0] + drag.dx;
        p.z = s[1] + drag.dz;
      } else if (drag.kind === 'rot') {
        setRot(p, Math.round(Math.atan2(s[1] - p.z, s[0] - p.x) / D2R * 2) / 2);
      } else {
        const th = p.rot * D2R, c = Math.cos(th), sn = Math.sin(th);
        const dx = s[0] - drag.ax, dz = s[1] - drag.az;
        const du = dx * c + dz * sn, dv = -dx * sn + dz * c;
        setSize(p, Math.abs(du) / YD, Math.abs(dv) / YD);
        const ou = (du < 0 ? -1 : 1) * p.size[0] * YD / 2, ov = (dv < 0 ? -1 : 1) * p.size[1] * YD / 2;
        p.x = drag.ax + ou * c - ov * sn;
        p.z = drag.az + ou * sn + ov * c;
      }
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
    const endDrag = () => { if (drag && drag.kind === 'size') paintCtl(); drag = null; };
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

    // The designed pitches as they stand (GAME plays on them): null until
    // the club layout has loaded.
    const current = () => (built ? pitches.map((p) => ({ id: p.id, x: p.x, z: p.z, rot: p.rot, size: p.size.slice() })) : null);
    return { setOn, isOn: () => wantOn, current };
  }

  window.PitchPlanner = { attach, offences, water, rect };
})();
