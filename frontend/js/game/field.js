// frontend/js/game/field.js
//
// Lighthouse Field — the ground the game is played on (199 E Erie Ave,
// Philadelphia). Built from DATA, three layers:
//   lighthouse-site.js   real outlines from OpenStreetMap (roads, the
//                        recreation ground, pitches, buildings, parking,
//                        cemetery, railways) — generated, ODbL
//   lighthouse-trees.js  tree positions detected from satellite imagery
//   lighthouse-layout.js TODAY'S hand-edited layer: where the game pitch
//                        sits, bleachers, barn, rodeo, stables, horses,
//                        kids' fields (James steers this)
// Site metres are x east, z south from a fixed origin; the whole site is
// rotated/translated so the game's 105 x 68 pitch (drawn by the renderer
// at the world origin) lands exactly on layout.gamePitch.
//
// DETAILS (horses, court markings + hoops, parked cars) are drawn only
// when the camera is near them — zero cost in normal play.

(function () {
  'use strict';

  const D2R = Math.PI / 180;
  const matCache = {};
  const std = (color, extra) => {
    const k = color + JSON.stringify(extra || {});
    return matCache[k] || (matCache[k] = new THREE.MeshStandardMaterial(
      Object.assign({ color, roughness: 0.92 }, extra || {})));
  };

  // ── merged-geometry builder: one draw call per surface type ──────────
  class Merge {
    constructor() { this.pos = []; this.nrm = []; }
    add(geo, matrix) {
      const g = (geo.index ? geo.toNonIndexed() : geo).clone();
      if (matrix) g.applyMatrix4(matrix);
      if (!g.attributes.normal) g.computeVertexNormals();
      this.pos.push(...g.attributes.position.array);
      this.nrm.push(...g.attributes.normal.array);
      g.dispose();
    }
    tri(a, b, c, y) {   // flat, facing UP whatever order a/b/c arrive in
      // Front faces are counter-clockwise seen from +y; flip if not (a
      // down-facing ribbon lit from below rendered roads near-black).
      const ny = (b[1] - a[1]) * (c[0] - a[0]) - (b[0] - a[0]) * (c[1] - a[1]);
      if (ny < 0) [b, c] = [c, b];
      this.pos.push(a[0], y, a[1], b[0], y, b[1], c[0], y, c[1]);
      this.nrm.push(0, 1, 0, 0, 1, 0, 0, 1, 0);
    }
    mesh(mat, { cast = false, receive = true } = {}) {
      const g = new THREE.BufferGeometry();
      g.setAttribute('position', new THREE.Float32BufferAttribute(this.pos, 3));
      g.setAttribute('normal', new THREE.Float32BufferAttribute(this.nrm, 3));
      const m = new THREE.Mesh(g, mat);
      m.castShadow = cast;
      m.receiveShadow = receive;
      return m;
    }
  }

  const FLAT = new THREE.Matrix4().makeRotationX(-Math.PI / 2);
  function shapeOf(pts) {
    return new THREE.Shape(pts.map(([x, z]) => new THREE.Vector2(x, -z)));
  }
  function addFlat(merge, pts, y) {
    const g = new THREE.ShapeGeometry(shapeOf(pts));
    merge.add(g, new THREE.Matrix4().makeTranslation(0, y, 0).multiply(FLAT));
    g.dispose();
  }
  // Polyline ribbon of width w at height y, with round joints.
  function addRibbon(merge, pts, w, y) {
    const r = w / 2;
    for (let i = 0; i + 1 < pts.length; i++) {
      const [ax, az] = pts[i], [bx, bz] = pts[i + 1];
      const L = Math.hypot(bx - ax, bz - az);
      if (L < 0.01) continue;
      const nx = -(bz - az) / L * r, nz = (bx - ax) / L * r;
      const a1 = [ax + nx, az + nz], a2 = [ax - nx, az - nz];
      const b1 = [bx + nx, bz + nz], b2 = [bx - nx, bz - nz];
      merge.tri(a1, b1, b2, y);
      merge.tri(a1, b2, a2, y);
    }
    for (const [x, z] of pts.slice(1, -1)) {     // joint caps at interior bends only
      for (let k = 0; k < 8; k++) {
        const t0 = (k / 8) * Math.PI * 2, t1 = ((k + 1) / 8) * Math.PI * 2;
        merge.tri([x, z], [x + Math.cos(t0) * r, z + Math.sin(t0) * r],
                  [x + Math.cos(t1) * r, z + Math.sin(t1) * r], y);
      }
    }
  }
  function inPoly(x, z, poly) {
    let c = false;
    for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      const [xi, zi] = poly[i], [xj, zj] = poly[j];
      if ((zi > z) !== (zj > z) && x < ((xj - xi) * (z - zi)) / (zj - zi) + xi) c = !c;
    }
    return c;
  }
  const area = (P) => Math.abs(P.reduce((s, p, i) => {
    const q = P[(i + 1) % P.length];
    return s + p[0] * q[1] - q[0] * p[1];
  }, 0)) / 2;
  const centroid = (P) => [P.reduce((s, p) => s + p[0], 0) / P.length,
                           P.reduce((s, p) => s + p[1], 0) / P.length];
  let seed = 1893;
  const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);

  // Minimum-area oriented rectangle of a polygon (pitches, courts).
  function orientedRect(P) {
    const [cx, cz] = centroid(P);
    let best = null;
    for (let i = 0; i < P.length; i++) {
      const a = P[i], b = P[(i + 1) % P.length];
      const ang = Math.atan2(b[1] - a[1], b[0] - a[0]);
      const ca = Math.cos(ang), sa = Math.sin(ang);
      const us = P.map((p) => (p[0] - cx) * ca + (p[1] - cz) * sa);
      const vs = P.map((p) => -(p[0] - cx) * sa + (p[1] - cz) * ca);
      const L = Math.max(...us) - Math.min(...us), W = Math.max(...vs) - Math.min(...vs);
      if (!best || L * W < best.A) {
        const mu = (Math.max(...us) + Math.min(...us)) / 2, mv = (Math.max(...vs) + Math.min(...vs)) / 2;
        best = { A: L * W, L, W, ang, x: cx + mu * ca - mv * sa, z: cz + mu * sa + mv * ca };
      }
    }
    if (best.W > best.L) [best.L, best.W, best.ang] = [best.W, best.L, best.ang + Math.PI / 2];
    return best;
  }

  // ── props ─────────────────────────────────────────────────────────────
  function bleacher(len) {
    const g = new THREE.Group();
    const alu = std(0xc9ced6, { metalness: 0.6, roughness: 0.35 });
    const frame = std(0x8a9099, { metalness: 0.5, roughness: 0.5 });
    const rows = 3, rise = 0.42, run = 0.62;
    for (let r = 0; r < rows; r++) {
      const y = 0.45 + r * rise, z = -r * run;
      const seat = new THREE.Mesh(new THREE.BoxGeometry(len, 0.05, 0.28), alu);
      seat.position.set(0, y, z);
      const foot = new THREE.Mesh(new THREE.BoxGeometry(len, 0.04, 0.24), alu);
      foot.position.set(0, y - 0.38, z + 0.3);
      seat.castShadow = foot.castShadow = true;
      g.add(seat, foot);
    }
    const legs = Math.max(2, Math.round(len / 2.5) + 1);
    const topY = 0.45 + (rows - 1) * rise, back = -(rows - 1) * run;
    for (let k = 0; k < legs; k++) {
      const x = -len / 2 + 0.1 + (len - 0.2) * (k / (legs - 1));
      const front = new THREE.Mesh(new THREE.BoxGeometry(0.06, 0.45, 0.06), frame);
      front.position.set(x, 0.225, 0.1);
      const rear = new THREE.Mesh(new THREE.BoxGeometry(0.06, topY, 0.06), frame);
      rear.position.set(x, topY / 2, back - 0.1);
      const brace = new THREE.Mesh(new THREE.BoxGeometry(0.05, 0.05, Math.hypot(topY, -back)), frame);
      brace.position.set(x, topY / 2, back / 2);
      brace.rotation.x = Math.atan2(topY, -back);
      front.castShadow = rear.castShadow = brace.castShadow = true;
      g.add(front, rear, brace);
    }
    return g;
  }

  function gableBarn(w, d, wallColor, roofColor) {
    const barn = new THREE.Group();
    const siding = std(wallColor, { roughness: 0.85 });
    const trim = std(0xf2f0ea, { roughness: 0.7 });
    const roofM = std(roofColor, { roughness: 0.8 });
    const H = 4.2, R = Math.min(3.4, d * 0.45);
    const walls = new THREE.Mesh(new THREE.BoxGeometry(w, H, d), siding);
    walls.position.y = H / 2;
    barn.add(walls);
    const gable = new THREE.Shape([new THREE.Vector2(-d / 2, 0), new THREE.Vector2(d / 2, 0),
                                   new THREE.Vector2(0, R)]);
    for (const sx of [-1, 1]) {
      const end = new THREE.Mesh(new THREE.ShapeGeometry(gable), siding);
      end.rotation.y = sx * Math.PI / 2;
      end.position.set(sx * w / 2, H, 0);
      barn.add(end);
    }
    const slope = Math.hypot(d / 2, R);
    for (const sz of [-1, 1]) {
      const r = new THREE.Mesh(new THREE.BoxGeometry(w + 0.6, 0.12, slope + 0.4), roofM);
      r.position.set(0, H + R / 2, sz * d / 4);
      r.rotation.x = sz * Math.atan2(R, d / 2);
      barn.add(r);
    }
    for (const sx of [-1, 1]) {        // white X-braced doors on the gable ends
      const door = new THREE.Mesh(new THREE.BoxGeometry(0.1, 3.2, Math.min(3.2, d * 0.45)), trim);
      door.position.set(sx * (w / 2 + 0.05), 1.6, 0);
      barn.add(door);
    }
    barn.traverse((o) => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
    return barn;
  }

  function horse(coat) {
    const g = new THREE.Group();
    const c = std(coat, { roughness: 0.7 });
    const dark = std(0x1f1712);
    const body = new THREE.Mesh(new THREE.CapsuleGeometry(0.42, 1.1, 4, 10), c);
    body.rotation.z = Math.PI / 2;
    body.position.y = 1.35;
    const neck = new THREE.Group();
    neck.position.set(0.75, 1.55, 0);
    const neckM = new THREE.Mesh(new THREE.CapsuleGeometry(0.2, 0.7, 4, 8), c);
    neckM.position.set(0.25, 0.3, 0);
    neckM.rotation.z = -0.7;
    const head = new THREE.Mesh(new THREE.BoxGeometry(0.62, 0.26, 0.24), c);
    head.position.set(0.75, 0.65, 0);
    head.rotation.z = -0.5;
    const mane = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.6, 0.06), dark);
    mane.position.set(0.12, 0.45, 0);
    mane.rotation.z = -0.7;
    neck.add(neckM, head, mane);
    g.add(body, neck);
    for (const [lx, lz] of [[0.55, 0.22], [0.55, -0.22], [-0.55, 0.22], [-0.55, -0.22]]) {
      const leg = new THREE.Mesh(new THREE.CylinderGeometry(0.07, 0.06, 1.1, 6), c);
      leg.position.set(lx, 0.55, lz);
      g.add(leg);
    }
    const tail = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.1, 0.8, 6), dark);
    tail.position.set(-0.95, 1.15, 0);
    tail.rotation.z = -0.4;
    g.add(tail);
    g.traverse((o) => { if (o.isMesh) o.castShadow = true; });
    g.userData.neck = neck;
    g.userData.phase = rnd() * 10;
    return g;
  }

  function courtTexture() {
    // The League Park at Lighthouse: blue court, red keys, white lines.
    const c = document.createElement('canvas');
    c.width = 1024; c.height = 560;
    const x = c.getContext('2d');
    const sx = 1024 / 28.65, sy = 560 / 15.24;
    x.fillStyle = '#1d428a'; x.fillRect(0, 0, 1024, 560);
    x.strokeStyle = '#ffffff'; x.lineWidth = 5;
    x.strokeRect(4, 4, 1016, 552);
    x.beginPath(); x.moveTo(512, 0); x.lineTo(512, 560); x.stroke();
    x.beginPath(); x.arc(512, 280, 1.83 * sx, 0, Math.PI * 2);
    x.fillStyle = '#ed174c'; x.fill(); x.stroke();
    for (const side of [0, 1]) {
      const bx = side ? 1024 - 5.8 * sx : 0;
      x.fillStyle = '#ed174c';
      x.fillRect(bx, 280 - 2.44 * sy, 5.8 * sx, 4.88 * sy);
      x.strokeRect(bx, 280 - 2.44 * sy, 5.8 * sx, 4.88 * sy);
      const hx = side ? 1024 - 1.6 * sx : 1.6 * sx;
      x.beginPath();
      x.arc(hx, 280, 7.24 * sx, side ? Math.PI / 2 : -Math.PI / 2,
            side ? Math.PI * 1.5 : Math.PI / 2, false);
      x.stroke();
    }
    x.fillStyle = '#ffffff';
    x.font = 'bold 34px system-ui, sans-serif';
    x.textAlign = 'center';
    x.fillText('THE LEAGUE PARK', 300, 60);
    x.fillText('AT LIGHTHOUSE', 724, 520);
    return new THREE.CanvasTexture(c);
  }

  function hoop() {
    const g = new THREE.Group();
    const pole = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.1, 3.4, 8), std(0x2b2f36));
    pole.position.set(-0.9, 1.7, 0);
    const arm = new THREE.Mesh(new THREE.BoxGeometry(0.9, 0.08, 0.08), std(0x2b2f36));
    arm.position.set(-0.45, 3.2, 0);
    const board = new THREE.Mesh(new THREE.BoxGeometry(0.05, 1.05, 1.8),
                                 std(0xffffff, { transparent: true, opacity: 0.85 }));
    board.position.set(0, 3.3, 0);
    const rim = new THREE.Mesh(new THREE.TorusGeometry(0.23, 0.02, 6, 16), std(0xed174c));
    rim.rotation.x = Math.PI / 2;
    rim.position.set(0.28, 3.05, 0);
    g.add(pole, arm, board, rim);
    g.traverse((o) => { if (o.isMesh) o.castShadow = true; });
    return g;
  }

  function car(color) {
    const g = new THREE.Group();
    const body = new THREE.Mesh(new THREE.BoxGeometry(4.4, 0.75, 1.8),
                                std(color, { roughness: 0.35, metalness: 0.4 }));
    body.position.y = 0.6;
    const cab = new THREE.Mesh(new THREE.BoxGeometry(2.2, 0.6, 1.6), std(0x22262c, { roughness: 0.2 }));
    cab.position.set(-0.2, 1.25, 0);
    g.add(body, cab);
    return g;
  }

  // Baseball: OSM pitch polygons are the whole field; home plate is the
  // vertex whose two edges (the foul lines) meet nearest 90° and run
  // longest. A dirt fan + grass diamond + mound sit there.
  function baseballInfield(P) {
    let best = null;
    for (let i = 0; i < P.length; i++) {
      const v = P[i], p = P[(i - 1 + P.length) % P.length], n = P[(i + 1) % P.length];
      const a1 = Math.atan2(p[1] - v[1], p[0] - v[0]), a2 = Math.atan2(n[1] - v[1], n[0] - v[0]);
      let dA = Math.abs(((a2 - a1 + Math.PI * 3) % (Math.PI * 2)) - Math.PI);
      const L = Math.min(Math.hypot(p[0] - v[0], p[1] - v[1]), Math.hypot(n[0] - v[0], n[1] - v[1]));
      const score = L - Math.abs(dA - Math.PI / 2) * 60;
      if (!best || score > best.score) best = { score, v, a1, a2, L };
    }
    const R = Math.min(38, best.L * 0.55);
    let a1 = best.a1, a2 = best.a2;
    let span = ((a2 - a1) % (Math.PI * 2) + Math.PI * 2) % (Math.PI * 2);
    if (span > Math.PI) { [a1, a2] = [a2, a1]; span = Math.PI * 2 - span; }
    const fan = [best.v];
    for (let k = 0; k <= 16; k++) {
      const t = a1 + span * (k / 16);
      fan.push([best.v[0] + Math.cos(t) * R, best.v[1] + Math.sin(t) * R]);
    }
    const mid = a1 + span / 2, s = R * 0.62;           // the 90-ft square
    const home = best.v;
    const d1 = [Math.cos(a1), Math.sin(a1)], d2 = [Math.cos(a1 + span), Math.sin(a1 + span)];
    const diamond = [home, [home[0] + d1[0] * s, home[1] + d1[1] * s],
                     [home[0] + (d1[0] + d2[0]) * s, home[1] + (d1[1] + d2[1]) * s],
                     [home[0] + d2[0] * s, home[1] + d2[1] * s]];
    const mound = [home[0] + Math.cos(mid) * s * 0.75, home[1] + Math.sin(mid) * s * 0.75];
    return { fan, diamond, mound, home, back: mid + Math.PI };
  }

  function build(scene, hx, hy) {
    const SITE = window.LIGHTHOUSE_SITE, LAY = window.LIGHTHOUSE_LAYOUT || {};
    const TREES = window.LIGHTHOUSE_TREES || [];
    const details = [];

    // ── bleachers: in GAME-pitch coordinates (world) ───────────────────
    const planAOverlay = [];
    for (const b of (LAY.bleachers || [])) {
      const m = bleacher(b.len || 7.5);
      m.position.set(b.x, 0, b.z);
      m.rotation.y = (b.face || 0) * D2R;
      scene.add(m);
      planAOverlay.push(m);
    }
    if (!SITE) return { update() {} };

    // ── the site group, placed so layout.gamePitch lands on the world
    // origin with its long axis along world x ────────────────────────
    const M = new THREE.Matrix4(), Q = new THREE.Quaternion(),
          S = new THREE.Vector3(), Pv = new THREE.Vector3();
    const gp = LAY.gamePitch || { x: 0, z: 0, rotDeg: 0 };
    const site = new THREE.Group();
    // Place the site so pitch p (site metres + degrees) lands on the world
    // origin. setGamePitch re-runs it once the club's designed 11v11 loads
    // (James: "we need field oriented like it is in design").
    const placeSite = (p) => {
      const th = p.rotDeg * D2R;
      site.rotation.y = th;
      site.position.set(-(p.x * Math.cos(th) + p.z * Math.sin(th)), 0,
                        -(-p.x * Math.sin(th) + p.z * Math.cos(th)));
      site.updateMatrixWorld(true);
    };
    placeSite(gp);
    scene.add(site);
    // LAYERS (James 10/24: "i need to be able to turn off everything. with
    // pills"): while the site builds, every site.add lands in the group of
    // the section being built (into = ...), so DESIGN can hide each kind
    // whole — setLayer(name, on). Restored to the plain add before return.
    const layerGroups = {};
    let into = 'ground';
    const siteAdd = site.add.bind(site);
    site.add = (...objs) => {
      let g = layerGroups[into];
      if (!g) { g = new THREE.Group(); g.name = into; siteAdd(g); layerGroups[into] = g; }
      g.add(...objs);
      return site;
    };
    const toWorld = (x, z) => new THREE.Vector3(x, 0, z).applyMatrix4(site.matrixWorld);

    // ── ground layers ────────────────────────────────────────────────
    const ground = new THREE.Mesh(new THREE.PlaneGeometry(3000, 3000), std(0x8b8f94, { roughness: 1 }));
    ground.rotation.x = -Math.PI / 2;
    ground.position.y = -0.12;
    ground.receiveShadow = true;
    site.add(ground);

    // Draw-order layers: each sits a little higher AND gets a stronger
    // polygon offset — millimetre gaps alone z-fought into moiré at range.
    const LAYER_ORDER = ['campus', 'industrial', 'cemetery', 'recreation', 'parking',
                         'pitchgrass', 'playground', 'dirt', 'sand', 'infield', 'rail', 'road', 'path', 'dust', 'chalk', 'paint'];
    const COLORS = { campus: 0xb9b6ae, industrial: 0x9a958c, cemetery: 0x5f8f4a,
      recreation: 0x4f8a3a, parking: 0x55595f, pitchgrass: 0x548f3d, playground: 0xb5513c,
      dirt: 0xb8865a, sand: 0xd8c08f, infield: 0x57943f, rail: 0x6f6658, road: 0x3b3f45,
      path: 0xc9c2b1, dust: 0xc8b48e, chalk: 0xf4f4ee, paint: 0xffd400 };
    COLORS.road = 0x5a5e64; COLORS.parking = 0x6a6e73; COLORS.rail = 0x7a7064;
    const layers = {};
    LAYER_ORDER.forEach((k, i) => { layers[k] = [new Merge(), COLORS[k], -0.07 + i * 0.004, i]; });
    const buildings = new Merge();
    let cemetery = null;
    const parkings = [];
    for (const f of SITE.features) {
      const P = f.pts;
      switch (f.k) {
        case 'campus': case 'industrial': case 'recreation': case 'parking': case 'playground':
          addFlat(layers[f.k][0], P, layers[f.k][2]);
          if (f.k === 'parking') parkings.push(P);
          break;
        case 'cemetery':
          addFlat(layers.cemetery[0], P, layers.cemetery[2]);
          cemetery = P;
          break;
        case 'pitch':
          if (f.sport === 'baseball' && LAY.diamonds) {
            // Measured diamonds in the layout replace the OSM guesses.
          } else if (f.sport === 'baseball') {
            const inf = baseballInfield(P);
            addFlat(layers.dirt[0], inf.fan, layers.dirt[2]);
            addFlat(layers.infield[0], inf.diamond, layers.infield[2]);
            const m = [];
            for (let k = 0; k < 12; k++) m.push([inf.mound[0] + Math.cos(k / 12 * 6.283) * 2.7,
                                                inf.mound[1] + Math.sin(k / 12 * 6.283) * 2.7]);
            addFlat(layers.dirt[0], m, layers.dirt[2] + 0.012);
            // Backstop behind home plate.
            const bx = inf.home[0] + Math.cos(inf.back) * 6, bz = inf.home[1] + Math.sin(inf.back) * 6;
            const fence = new THREE.Mesh(new THREE.BoxGeometry(14, 4, 0.06),
              std(0x9aa1a8, { metalness: 0.5, roughness: 0.5, transparent: true, opacity: 0.5 }));
            fence.position.set(bx, 2, bz);
            fence.rotation.y = -inf.back + Math.PI / 2;
            into = 'fences'; site.add(fence); into = 'ground';
          } else if (f.sport === 'basketball') {
            const r = orientedRect(P);
            const court = new THREE.Mesh(new THREE.PlaneGeometry(r.L + 1.5, r.W + 1.5),
                                         std(0x8f949b, { roughness: 1 }));
            court.rotation.set(-Math.PI / 2, 0, -r.ang);
            court.position.set(r.x, -0.04, r.z);
            court.receiveShadow = true;
            site.add(court);
            const det = new THREE.Group();
            const lines = new THREE.Mesh(new THREE.PlaneGeometry(r.L, r.W),
              new THREE.MeshStandardMaterial({ map: courtTexture(), roughness: 0.8 }));
            lines.rotation.set(-Math.PI / 2, 0, -r.ang);
            lines.position.set(r.x, -0.03, r.z);
            lines.receiveShadow = true;
            det.add(lines);
            for (const s of [-1, 1]) {
              const h = hoop();
              const d = s * (r.L / 2 - 1.2);
              h.position.set(r.x + Math.cos(r.ang) * d, 0, r.z + Math.sin(r.ang) * d);
              h.rotation.y = -r.ang + (s > 0 ? Math.PI : 0);
              det.add(h);
            }
            site.add(det);
            const w = toWorld(r.x, r.z);
            details.push({ obj: det, x: w.x, z: w.z, lx: r.x, lz: r.z, r: 80 });
          } else {
            addFlat(layers.pitchgrass[0], P, layers.pitchgrass[2]);
          }
          break;
        case 'road': case 'path':
          addRibbon(layers[f.k][0], P, f.w, layers[f.k][2]);
          break;
        case 'rail':
          addRibbon(layers.rail[0], P, f.live ? 4 : 3, layers.rail[2]);
          break;
        case 'building': {
          const a = area(P);
          const h = f.h || ({ hospital: 22, school: 14, mosque: 10 }[f.b] ||
                    (a > 3000 ? 11 : a > 800 ? 8 : 5));
          const g = new THREE.ExtrudeGeometry(shapeOf(P), { depth: h, bevelEnabled: false });
          buildings.add(g, FLAT);
          g.dispose();
          break;
        }
        default:
      }
    }

    // ── today's layout: rodeo, barn, stables, paddock, shed, horses ────
    const L = LAY;
    into = 'fences';
    if (L.rodeo && L.rodeo.ring) {
      const { x, z, r } = L.rodeo.ring;
      const ring = [], apron = [];
      for (let k = 0; k < 40; k++) {
        const t = (k / 40) * Math.PI * 2;
        ring.push([x + Math.cos(t) * r, z + Math.sin(t) * r]);
        apron.push([x + Math.cos(t) * (r + 5), z + Math.sin(t) * (r + 5)]);
      }
      addFlat(layers.dirt[0], apron, layers.dirt[2]);
      addFlat(layers.sand[0], ring, layers.sand[2]);
      const panelM = std(0xf2f2ee, { roughness: 0.6 });
      const NP = Math.round(2 * Math.PI * r / 3);
      for (let k = 0; k < NP; k++) {
        const t = (k / NP) * Math.PI * 2;
        const p = new THREE.Mesh(new THREE.BoxGeometry(2 * Math.PI * r / NP - 0.2, 1.6, 0.1), panelM);
        p.position.set(x + Math.cos(t) * r, 0.8, z + Math.sin(t) * r);
        p.rotation.y = -t + Math.PI / 2;
        p.castShadow = true;
        site.add(p);
      }
      into = 'props';
      if (L.rodeo.ringBleachers) {
        for (const t of [0, Math.PI / 2, Math.PI, -Math.PI / 2]) {
          const b = bleacher(5);
          b.position.set(x + Math.cos(t) * (r + 3.5), 0, z + Math.sin(t) * (r + 3.5));
          b.rotation.y = Math.atan2(x - b.position.x, z - b.position.z);
          site.add(b);
        }
      }
      into = 'fences';
    }
    if (L.rodeo && L.rodeo.ovalPen) {
      const o = L.rodeo.ovalPen, oa = (o.rotDeg || 0) * D2R;
      const pts = [];
      for (let k = 0; k < 28; k++) {
        const t = (k / 28) * Math.PI * 2;
        const ex = Math.cos(t) * o.w / 2, ez = Math.sin(t) * o.d / 2;
        pts.push([o.x + ex * Math.cos(oa) - ez * Math.sin(oa), o.z + ex * Math.sin(oa) + ez * Math.cos(oa)]);
      }
      addFlat(layers.dirt[0], pts, layers.dirt[2] + 0.005);
      railFence(site, pts, true);
    }
    into = 'buildings';
    if (L.barn) {
      const b = gableBarn(L.barn.w, L.barn.d,
                          { red: 0x9b2f2a, tan: 0xb8a487 }[L.barn.walls] || 0x8a7a66,
                          L.barn.roof === 'red' ? 0x8c2a24 : 0x2f3338);
      b.position.set(L.barn.x, 0, L.barn.z);
      b.rotation.y = -(L.barn.rotDeg || 0) * D2R;
      site.add(b);
    }
    for (const sh of (L.sheds || [])) {
      const b = gableBarn(sh.w, sh.d, 0x8a7a66, sh.roof === 'red' ? 0x8c2a24 : 0x2f3338);
      b.scale.y = 0.7;
      b.position.set(sh.x, 0, sh.z);
      b.rotation.y = -(sh.rotDeg || 0) * D2R;
      site.add(b);
    }
    for (const bd of (L.buildings || [])) {
      site.add(box(bd.x, bd.z, bd.w, bd.d, bd.h || 6, bd.color || 0x7a6658, bd.rotDeg));
      site.add(box(bd.x, bd.z, bd.w + 0.6, bd.d + 0.6, 0.25, 0x2f3338, bd.rotDeg, bd.h || 6));
    }
    for (const t of (L.trailers || [])) site.add(box(t.x, t.z, t.w, t.d, 2.8, 0xe4e6ea, t.rotDeg));
    if (L.stable) {
      const s = L.stable;
      const blk = box(s.x, s.z, s.w, s.d, 4.2, 0x6d5a4a, s.rotDeg);
      site.add(blk);
      site.add(box(s.x, s.z, s.w + 0.6, s.d + 0.6, 0.25, 0x2f3338, s.rotDeg, 4.2));  // dark roof
    }
    into = 'fences';
    if (L.paddock) {
      const p = L.paddock;
      const pts = [[p.x - p.w / 2, p.z - p.d / 2], [p.x + p.w / 2, p.z - p.d / 2],
                   [p.x + p.w / 2, p.z + p.d / 2], [p.x - p.w / 2, p.z + p.d / 2]];
      addFlat(layers.dirt[0], pts, layers.dirt[2] + 0.005);
      railFence(site, pts, true);
    }
    for (const r of (L.roads || [])) {
      const ly = layers[r.kind || 'road'];
      addFlat(ly[0], r.pts, ly[2]);
    }
    into = 'props';
    for (const b of (L.booths || [])) {
      // Carnival game booth: back + side walls, striped awning roof, open
      // front; the basketball game gets two hoops on the back wall.
      const g = new THREE.Group(), H = b.h || 2.6;
      const wallM = std(0xe8e2d4), red = std(0xc0262d), white = std(0xf4f1ea);
      const back = new THREE.Mesh(new THREE.BoxGeometry(b.w, H, 0.08), wallM);
      back.position.set(0, H / 2, -b.d / 2);
      g.add(back);
      for (const sx of [-1, 1]) {
        const side = new THREE.Mesh(new THREE.BoxGeometry(0.08, H, b.d), wallM);
        side.position.set(sx * b.w / 2, H / 2, 0);
        g.add(side);
      }
      const n = 6;
      for (let i = 0; i < n; i++) {
        const st = new THREE.Mesh(new THREE.BoxGeometry(b.w / n, 0.08, b.d + 0.4), i % 2 ? white : red);
        st.position.set(-b.w / 2 + (i + 0.5) * b.w / n, H + 0.04, 0.2);
        g.add(st);
      }
      const counter = new THREE.Mesh(new THREE.BoxGeometry(b.w, 0.9, 0.3), red);
      counter.position.set(0, 0.45, b.d / 2 - 0.15);
      g.add(counter);
      if (b.kind === 'basketball') {
        const rimM = std(0xff6a13, { metalness: 0.5, roughness: 0.4 });
        for (const hx of [-b.w / 4, b.w / 4]) {
          const board = new THREE.Mesh(new THREE.BoxGeometry(0.7, 0.5, 0.04), white);
          board.position.set(hx, 2.0, -b.d / 2 + 0.06);
          g.add(board);
          const rim = new THREE.Mesh(new THREE.TorusGeometry(0.16, 0.015, 6, 16), rimM);
          rim.rotation.x = Math.PI / 2;
          rim.position.set(hx, 1.85, -b.d / 2 + 0.28);
          g.add(rim);
          const ball = new THREE.Mesh(new THREE.SphereGeometry(0.12, 10, 8), rimM);
          ball.position.set(hx, 0.95, b.d / 2 - 0.15);
          g.add(ball);
        }
      }
      g.traverse((o) => { if (o.isMesh) o.castShadow = true; });
      g.position.set(b.x, 0, b.z);
      // Local -z is the back wall: face 'south' puts the open front toward +z.
      g.rotation.y = b.face === 'north' ? Math.PI : 0;
      site.add(g);
    }
    for (const t of (L.tracks || [])) addRibbon(layers.dust[0], t.pts, t.w, layers.dust[2]);
    // Proposed lane (layout proposedLanes), James 10/24: "right behind the
    // current yellow pitch ... between that and tree roots". A straight
    // lane parallel to the yellow pitch's north goal line, ln.fenceGap m
    // behind it a fence, then ln.gap, then the lane (ln.w wide), run on at
    // both ends until it meets the tan road (a bypass for wide trucks).
    // It can't bend into the pitch, so every trunk within ln.root m of its
    // edge is ringed red (ln.blockers). See-through purple, dashed edges =
    // not built yet (orange = water channels). The fence lands in L.fences
    // (group 'proposed_lane') and pitch-planner.js makes it a 10 ft rule.
    // AVOID zones (layout avoidZones): outline each, hatched red (no-go)
    // or amber (penalty), each on its own layer 'avoid_<id>';
    // pitch-planner.js turns z.pts into a rule or a score penalty.
    for (const zn of (L.avoidZones || [])) {
      if (zn.kind === 'sector') {
        const dm = (L.diamonds || [])[zn.diamond || 0];
        if (!dm) continue;
        const b = dm.bearing * D2R, at = (a, r) => [dm.home[0] + Math.cos(b + a * D2R) * r, dm.home[1] + Math.sin(b + a * D2R) * r];
        zn.pts = [];
        for (let a = zn.a0; a <= zn.a1 + 1e-6; a += 4) zn.pts.push(at(a, zn.r1));
        for (let a = zn.a1; a >= zn.a0 - 1e-6; a -= 4) zn.pts.push(at(a, zn.r0));
      } else if (zn.kind === 'band') {
        const pt = L[zn.pitch];
        if (!pt) continue;
        const a = pt.rotDeg * D2R, at = (u, v) => [pt.x + u * Math.cos(a) - v * Math.sin(a), pt.z + u * Math.sin(a) + v * Math.cos(a)];
        const sg = zn.side === 'rodeo' ? -1 : 1, v0 = sg * (pt.width / 2 + zn.from), v1 = sg * (pt.width / 2 + zn.to), l = pt.length / 2;
        zn.pts = [at(-l, v0), at(l, v0), at(l, v1), at(-l, v1)];
      }
      if (!zn.pts) continue;
      into = 'avoid_' + zn.id;
      const col = zn.mode === 'nogo' ? 0xff2233 : 0xffb000;
      const fill = new THREE.Mesh(new THREE.ShapeGeometry(new THREE.Shape(zn.pts.map(([x, z]) => new THREE.Vector2(x, -z)))),
        new THREE.MeshBasicMaterial({ color: col, transparent: true, opacity: 0.18, depthWrite: false, depthTest: false, side: THREE.DoubleSide }));
      fill.rotation.x = -Math.PI / 2;
      fill.position.y = 0.3;
      fill.renderOrder = 55;
      site.add(fill);
      const edge = new Merge();
      addRibbon(edge, zn.pts.concat([zn.pts[0]]), 0.35, 0.31);
      // Hatching: diagonal strokes 4 m apart, clipped to the zone.
      const xs = zn.pts.map((p) => p[0]), zs = zn.pts.map((p) => p[1]);
      const x0 = Math.min(...xs), x1 = Math.max(...xs), z0 = Math.min(...zs), z1 = Math.max(...zs);
      for (let k = x0 - (z1 - z0); k < x1; k += 4)
        for (let t = 0; t < (z1 - z0); t += 1) {
          const p0 = [k + t, z0 + t], p1 = [k + t + 1, z0 + t + 1];
          if (inPoly(p0[0], p0[1], zn.pts) && inPoly(p1[0], p1[1], zn.pts)) addRibbon(edge, [p0, p1], 0.15, 0.31);
        }
      const em = edge.mesh(new THREE.MeshBasicMaterial({ color: col, transparent: true, opacity: 0.8, depthWrite: false,
        depthTest: false, side: THREE.DoubleSide }));
      em.renderOrder = 56;
      site.add(em);
    }
    into = 'proposed_lane';
    for (const ln of (L.proposedLanes || [])) {
      const pt = L[ln.behind], road = (L.tracks || []).find((t) => t.name === ln.joins);
      if (!pt || !road) continue;
      const a = pt.rotDeg * D2R, ca = Math.cos(a), sa = Math.sin(a);
      const at = (u, v) => [pt.x + u * ca - v * sa, pt.z + u * sa + v * ca];
      const sg = ln.end === 'south' ? 1 : -1, goal = sg * pt.length / 2;
      const uFence = goal + sg * (ln.fenceGap || 1), uLane = uFence + sg * ((ln.gap || 0.5) + ln.w / 2);
      // How far the lane edge is from the edge of any dirt road (the tan
      // road or its south-west spur), to find where the lane meets it.
      const roadGap = (p) => {
        let d = 1e9;
        for (const rd of (L.tracks || []))
          for (let i = 0; i + 1 < rd.pts.length; i++) {
            const [ax, az] = rd.pts[i], [bx, bz] = rd.pts[i + 1], dx = bx - ax, dz = bz - az, l2 = dx * dx + dz * dz;
            const t = l2 ? Math.max(0, Math.min(1, ((p[0] - ax) * dx + (p[1] - az) * dz) / l2)) : 0;
            d = Math.min(d, Math.hypot(p[0] - ax - t * dx, p[1] - az - t * dz) - rd.w / 2 - ln.w / 2);
          }
        return d;
      };
      ln.joined = [];
      const reach = (dir) => {   // run v outward from the touchline until the lane meets a road
        for (let v = pt.width / 2; v < pt.width / 2 + 120; v += 0.5)
          if (roadGap(at(uLane, dir * v)) <= 0) { ln.joined.push(true); return dir * v; }
        ln.joined.push(false);
        return dir * (pt.width / 2 + 5);
      };
      const v0 = reach(-1), v1 = reach(1);
      ln.pts = [];
      for (let v = v0; v <= v1 + 1e-6; v += 2) ln.pts.push(at(uLane, Math.min(v, v1)));
      if (ln.pts.length < 2) continue;
      const m = new Merge();
      addRibbon(m, ln.pts, ln.w, 0.07);
      // Purple: orange is the water channels.
      const lane = m.mesh(new THREE.MeshBasicMaterial({ color: 0xa64dff, transparent: true, opacity: 0.55,
        depthWrite: false, depthTest: false, side: THREE.DoubleSide }));
      lane.renderOrder = 57;
      site.add(lane);
      const edgeM = new Merge();
      for (const sd of [-1, 1])
        for (let v = v0; v < v1; v += 4)
          addRibbon(edgeM, [at(uLane + sd * ln.w / 2, v), at(uLane + sd * ln.w / 2, Math.min(v1, v + 2))], 0.2, 0.08);
      const edges = edgeM.mesh(new THREE.MeshBasicMaterial({ color: 0xffffff, side: THREE.DoubleSide, depthTest: false }));
      edges.renderOrder = 58;
      site.add(edges);
      // Trunks in the lane or within ln.root of its edge.
      const lim = ln.w / 2 + (ln.root || 1);
      ln.blockers = TREES.filter((t) => {
        const dx = t[0] - pt.x, dz = t[1] - pt.z, u = dx * ca + dz * sa, v = -dx * sa + dz * ca;
        return Math.abs(u - uLane) < lim && v > v0 - lim && v < v1 + lim;
      }).map((t) => {
        const dx = t[0] - pt.x, dz = t[1] - pt.z, u = dx * ca + dz * sa;
        return { x: t[0], z: t[1], edge: Math.abs(u - uLane) - ln.w / 2 };
      });
      const ringM = new THREE.MeshBasicMaterial({ color: 0xff2233, depthTest: false, side: THREE.DoubleSide });
      for (const t of ln.blockers) {
        const r = new THREE.Mesh(new THREE.RingGeometry(1.1, 1.6, 24), ringM);
        r.rotation.x = -Math.PI / 2;
        r.position.set(t.x, 0.5, t.z);
        r.renderOrder = 60;
        site.add(r);
      }
      if (ln.fence) {
        ln.fencePts = [];
        for (let v = -pt.width / 2 - 2; v <= pt.width / 2 + 2 + 1e-6; v += 4) ln.fencePts.push(at(uFence, Math.min(v, pt.width / 2 + 2)));
        (L.fences = L.fences || []).push({ name: ln.fence.name, group: 'proposed_lane', kind: ln.fence.kind || 'chain',
                                           h: ln.fence.h || 1.8, pts: ln.fencePts });
      }
    }
    into = 'fences';
    for (const rf of (L.railFences || [])) railFence(site, rf.pts, false, rf.color);
    into = 'props';
    for (const c of (L.canopies || [])) {
      const g = new THREE.Group();
      const top = new THREE.Mesh(new THREE.BoxGeometry(c.w, 0.12, c.d), std(c.color, { roughness: 0.9 }));
      top.position.y = 2.6;
      top.castShadow = true;
      g.add(top);
      const legM = std(0x9aa1a8, { metalness: 0.6, roughness: 0.4 });
      for (const sx of [-1, 1]) for (const sz of [-1, 1]) {
        const leg = new THREE.Mesh(new THREE.CylinderGeometry(0.03, 0.03, 2.6, 6), legM);
        leg.position.set(sx * (c.w / 2 - 0.1), 1.3, sz * (c.d / 2 - 0.1));
        g.add(leg);
      }
      g.position.set(c.x, 0, c.z);
      g.rotation.y = -(c.rotDeg || 0) * D2R;
      site.add(g);
    }
    into = 'fences';
    if (L.playground) {
      const pg = L.playground;
      if (pg.pad) addFlat(layers.road[0], pg.pad, layers.road[2]);
      if (pg.sand) addFlat(layers.sand[0], pg.sand, layers.sand[2]);
      if (pg.fence) railFence(site, pg.fence, false, 0x6b7178);
    }
    into = 'buildings';
    if (L.greenShed) {
      const g = L.greenShed;
      site.add(box(g.x, g.z, g.w, g.d, 2.6, 0x3f7a4a, g.rotDeg));
    }
    into = 'props';
    if (L.horses && L.horses.length) {
      const hs = new THREE.Group();
      for (const h of L.horses) {
        const m = horse(h.coat);
        m.position.set(h.x, 0, h.z);
        m.rotation.y = -(h.rotDeg || 0) * D2R;
        hs.add(m);
        const w = toWorld(h.x, h.z);
        const one = new THREE.Group();
        details.push({ obj: m, x: w.x, z: w.z, lx: h.x, lz: h.z, r: 60,
          tick(t) {
            const k = Math.sin(t * 0.6 + m.userData.phase);
            m.userData.neck.rotation.z = k > 0.2 ? -0.9 * Math.min(1, (k - 0.2) * 2) : 0;
          } });
        void one;
      }
      site.add(hs);
    }
    into = 'ground';
    for (const dm of (L.diamonds || [])) {
      const [hxp, hzp] = dm.home, b = dm.bearing * D2R;
      const at = (ang, r) => [hxp + Math.cos(ang) * r, hzp + Math.sin(ang) * r];
      // Dirt fan between the foul lines out to the arc.
      const fan = [dm.home];
      for (let k = 0; k <= 20; k++) fan.push(at(b - Math.PI / 4 + (Math.PI / 2) * (k / 20), dm.arc));
      addFlat(layers.dirt[0], fan, layers.dirt[2]);
      // Grass infield square (baseball cut) inside the base paths.
      const s = dm.base, inset = 1.4;
      if (dm.infield === 'grass') {
        const sq = [at(b, inset * 1.414), at(b - Math.PI / 4, s - inset).map((v, i) => v + (at(b + Math.PI / 4, inset)[i] - dm.home[i])),
                    at(b, s * 1.414 - inset * 1.414), at(b + Math.PI / 4, s - inset).map((v, i) => v + (at(b - Math.PI / 4, inset)[i] - dm.home[i]))];
        addFlat(layers.infield[0], sq, layers.infield[2]);
        const mound = at(b, 18.44 * s / 27.43);
        const m = [];
        for (let k = 0; k < 14; k++) m.push([mound[0] + Math.cos(k / 14 * 6.283) * 2.74, mound[1] + Math.sin(k / 14 * 6.283) * 2.74]);
        addFlat(layers.dirt[0], m, layers.dirt[2] + 0.01);
      }
      // Bases (white bags) + home plate, chalk foul lines, backstop.
      const bagM = std(0xf7f7f2);
      for (const [ang, r] of [[b - Math.PI / 4, s], [b, s * Math.SQRT2], [b + Math.PI / 4, s], [0, 0]]) {
        const [bx, bz] = r ? at(ang, r) : dm.home;
        const bag = new THREE.Mesh(new THREE.BoxGeometry(0.4, 0.08, 0.4), bagM);
        bag.position.set(bx, 0.04, bz);
        bag.rotation.y = -b + Math.PI / 4;
        site.add(bag);
      }
      for (const side of [-1, 1]) {
        const end = at(b + side * Math.PI / 4, dm.arc + 40);
        addRibbon(layers.chalk[0], [dm.home, end], 0.12, layers.chalk[2]);
      }
      const back = at(b + Math.PI, 7);
      const fence = new THREE.Mesh(new THREE.BoxGeometry(12, 3.6, 0.06),
        std(0x9aa1a8, { metalness: 0.5, roughness: 0.5, transparent: true, opacity: 0.5 }));
      fence.position.set(back[0], 1.8, back[1]);
      fence.rotation.y = -b + Math.PI / 2;
      into = 'fences'; site.add(fence); into = 'ground';
    }
    // Cemetery fence: black iron, posts every 3 m + two rails.
    into = 'fences';
    if (L.cemeteryFence && cemetery) {
      const H = L.cemeteryFence.height || 2;
      const iron = std(0x1d1f22, { metalness: 0.6, roughness: 0.5 });
      const posts = [];
      for (let k = 0; k + 1 < cemetery.length; k++) {
        const [ax, az] = cemetery[k], [bx, bz] = cemetery[k + 1];
        const len = Math.hypot(bx - ax, bz - az);
        for (const hh of [0.3, H - 0.15]) {
          const r = new THREE.Mesh(new THREE.BoxGeometry(len, 0.05, 0.05), iron);
          r.position.set((ax + bx) / 2, hh, (az + bz) / 2);
          r.rotation.y = -Math.atan2(bz - az, bx - ax);
          site.add(r);
        }
        for (let t = 0; t < len; t += 3) posts.push([ax + (bx - ax) * t / len, az + (bz - az) * t / len]);
      }
      const pm = new THREE.InstancedMesh(new THREE.BoxGeometry(0.06, H, 0.06), iron, posts.length);
      posts.forEach(([x, z], i) => { M.compose(Pv.set(x, H / 2, z), Q, S.set(1, 1, 1)); pm.setMatrixAt(i, M); });
      site.add(pm);
    }
    // Measured fences: chain-link panels (see-through) or solid metal.
    for (const fz of (L.fences || [])) {
      into = fz.group ? fz.group + '_fences' : 'fences';
      const H = fz.h || 2;
      const mat = fz.kind === 'metal'
        ? std(0x6f767e, { metalness: 0.7, roughness: 0.4 })
        : std(0x9aa1a8, { metalness: 0.5, roughness: 0.5, transparent: true, opacity: 0.45 });
      const postM = std(0x6b7178, { metalness: 0.6, roughness: 0.4 });
      for (let k = 0; k + 1 < fz.pts.length; k++) {
        const [ax, az] = fz.pts[k], [bx, bz] = fz.pts[k + 1];
        const len = Math.hypot(bx - ax, bz - az);
        const panel = new THREE.Mesh(new THREE.BoxGeometry(len, H, 0.05), mat);
        panel.position.set((ax + bx) / 2, H / 2, (az + bz) / 2);
        panel.rotation.y = -Math.atan2(bz - az, bx - ax);
        panel.castShadow = fz.kind === 'metal';
        site.add(panel);
        for (let t = 0; t <= len + 0.01; t += 3) {
          const post = new THREE.Mesh(new THREE.CylinderGeometry(0.04, 0.04, H + 0.1, 6), postM);
          post.position.set(ax + (bx - ax) * t / len, (H + 0.1) / 2, az + (bz - az) * t / len);
          site.add(post);
        }
      }
    }
    for (const kf of (L.kidsFields || [])) {
      // Kids' fields: painted lines (James to place). Simple outline for now.
      const a = (kf.rotDeg || 0) * D2R, l = kf.length / 2, w = kf.width / 2;
      const c = [[-l, -w], [l, -w], [l, w], [-l, w]].map(([u, v]) =>
        [kf.x + u * Math.cos(a) - v * Math.sin(a), kf.z + u * Math.sin(a) + v * Math.cos(a)]);
      addRibbon(layers.chalk[0], c.concat([c[0]]), 0.12, layers.chalk[2]);
    }

    // WATER layer (button): lidar runoff channels;
    // pitch-planner.js adds live per-m² cells inside the dragged pitches.
    const waterLayer = new THREE.Group();
    into = 'water';
    site.add(waterLayer);
    into = 'paint';
    let oldPitchMesh = null;
    if (L.oldPitch) {
      // The 11v11 pitch painted today (Google imagery), full markings in
      // yellow so it reads apart from the white game pitch.
      const o = L.oldPitch, a = o.rotDeg * D2R, ca = Math.cos(a), sa = Math.sin(a);
      const at = ([u, v]) => [o.x + u * ca - v * sa, o.z + u * sa + v * ca];
      const paint = new Merge();
      const ln = (pts) => addRibbon(paint, pts.map(at), 0.25, 0.08);
      const l = o.length / 2, w = o.width / 2;
      ln([[-l, -w], [l, -w], [l, w], [-l, w], [-l, -w]]);
      ln([[0, -w], [0, w]]);
      const ring = (cu, cv, r, t0, t1) => {
        const pts = [];
        for (let k = 0; k <= 32; k++) { const t = t0 + (t1 - t0) * k / 32; pts.push([cu + Math.cos(t) * r, cv + Math.sin(t) * r]); }
        ln(pts);
      };
      ring(0, 0, 9.15, 0, Math.PI * 2);
      for (const sg of [-1, 1]) {
        const e = sg * l;
        ln([[e, -20.16], [e - sg * 16.5, -20.16], [e - sg * 16.5, 20.16], [e, 20.16]]);
        ln([[e, -9.16], [e - sg * 5.5, -9.16], [e - sg * 5.5, 9.16], [e, 9.16]]);
        const spot = e - sg * 11, half = Math.acos(5.5 / 9.15);
        const mid = sg > 0 ? Math.PI : 0;
        ring(spot, 0, 9.15, mid - half, mid + half);
        ring(spot, 0, 0.2, 0, Math.PI * 2);
      }
      // Over the game pitch too (it sits at y 0.05 with a polygon offset),
      // so the whole of today's pitch reads where the two overlap.
      const pm = paint.mesh(new THREE.MeshStandardMaterial({ color: 0xffd400, roughness: 0.8,
        side: THREE.DoubleSide, polygonOffset: true, polygonOffsetFactor: -6, polygonOffsetUnits: -24 }));
      pm.renderOrder = 31;
      pm.visible = false;   // DESIGN only (setOldPitch) — James: not in GAME
      // Its size in yards on the grass (James 10/24: "can we show yellow
      // pitch dimensions?"), just outside a touchline so it never sits on
      // a designed pitch's own label.
      const cv = document.createElement('canvas');
      cv.width = 1024; cv.height = 128;
      const c2 = cv.getContext('2d');
      const t = 'TODAY\'S PITCH  ' + (o.length / 0.9144).toFixed(1) + ' × ' + (o.width / 0.9144).toFixed(1) + ' yd';
      c2.font = 'bold 84px sans-serif';
      const fs = Math.min(84, Math.floor(84 * 990 / Math.max(1, c2.measureText(t).width)));
      c2.font = 'bold ' + fs + 'px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
      c2.lineWidth = 14; c2.strokeStyle = 'rgba(0,0,0,.85)'; c2.strokeText(t, 512, 64);
      c2.fillStyle = '#ffd400'; c2.fillText(t, 512, 64);
      const lw = Math.min(48, l * 1.2);
      const lab = new THREE.Mesh(new THREE.PlaneGeometry(lw, lw / 8),
        new THREE.MeshBasicMaterial({ map: new THREE.CanvasTexture(cv), transparent: true,
          depthWrite: false, depthTest: false }));
      lab.rotation.x = -Math.PI / 2;
      lab.position.z = w + lw / 16 + 1.5;   // reads along the touchline, outside it
      lab.renderOrder = 62;
      const labG = new THREE.Group();   // pm's geometry is in site metres
      labG.position.set(o.x, 0.5, o.z);
      labG.rotation.y = -a;
      labG.add(lab);
      pm.add(labG);
      site.add(pm);
      oldPitchMesh = pm;
    }

    into = 'labels';
    for (const lb of (L.labels || [])) {
      const cv = document.createElement('canvas');
      cv.width = 256; cv.height = 128;
      const g = cv.getContext('2d');
      g.font = 'bold 84px sans-serif';
      g.textAlign = 'center'; g.textBaseline = 'middle';
      g.lineWidth = 14; g.strokeStyle = 'rgba(255,255,255,0.9)';
      g.strokeText(lb.text, 128, 64);
      g.fillStyle = '#3c4043';
      g.fillText(lb.text, 128, 64);
      const tex = new THREE.CanvasTexture(cv);
      const m = new THREE.Mesh(new THREE.PlaneGeometry(lb.size * 2, lb.size),
        new THREE.MeshBasicMaterial({ map: tex, transparent: true, depthWrite: false, depthTest: false }));
      m.rotation.x = -Math.PI / 2;
      m.position.set(lb.x, 0.3, lb.z);
      m.renderOrder = 50;
      site.add(m);
    }

    into = 'ground';
    for (const k of Object.keys(layers)) {
      const [m, color, , i] = layers[k];
      if (!m.pos.length) continue;
      const mat = new THREE.MeshStandardMaterial({ color, roughness: 1, side: THREE.DoubleSide,
        polygonOffset: true, polygonOffsetFactor: -i * 0.2, polygonOffsetUnits: -i });
      const mesh = m.mesh(mat);
      mesh.renderOrder = i;
      site.add(mesh);
    }
    into = 'buildings';
    if (buildings.pos.length) site.add(buildings.mesh(std(0xc9c4ba), { cast: true }));

    // ── trees: one per detected crown [x, z, crown radius] ─────────────
    // Trunk at the crown centre; limbs + twigs as real geometry; leaves
    // default to a see-through wire canopy (you can see the play through
    // the tree line but know the tree is there) — setLeaves(true) swaps in
    // solid foliage.
    into = 'trees';
    let leavesWire = null, leavesSolid = null;
    if (TREES.length) {
      const wood = new Merge();
      const cyl = new THREE.CylinderGeometry(0.6, 1, 1, 5, 1, true);
      const up = new THREE.Vector3(0, 1, 0), dir = new THREE.Vector3();
      const limb = (ax, ay, az, bx, by, bz, r0) => {
        dir.set(bx - ax, by - ay, bz - az);
        const len = dir.length();
        Q.setFromUnitVectors(up, dir.normalize());
        M.compose(Pv.set((ax + bx) / 2, (ay + by) / 2, (az + bz) / 2), Q, S.set(r0, len, r0));
        wood.add(cyl, M);
      };
      const wireC = new THREE.InstancedMesh(new THREE.IcosahedronGeometry(1, 1),
        new THREE.MeshBasicMaterial({ color: 0x5fae4a, wireframe: true, transparent: true, opacity: 0.45 }),
        TREES.length);
      const solidC = new THREE.InstancedMesh(new THREE.IcosahedronGeometry(1, 1),
        std(0x2f6b2a, { roughness: 1, flatShading: true }), TREES.length);
      const col = new THREE.Color();
      const I = new THREE.Quaternion();
      TREES.forEach((t, i) => {
        const [x, z] = t, r = t[2] || 3.4;
        const H = Math.min(22, Math.max(5, 4 + 1.7 * r));
        const trunkH = 0.45 * H, crownHalf = 0.55 * H / 2, cy = trunkH + crownHalf;
        const tr = 0.12 + 0.035 * r;
        limb(x, 0, z, x, trunkH + 0.4, z, tr);
        const nL = 5 + (r > 5 ? 2 : 0);
        for (let k = 0; k < nL; k++) {
          const a = (k / nL) * Math.PI * 2 + rnd() * 0.6;
          const sy = trunkH * (0.75 + rnd() * 0.25);
          const ex = x + Math.cos(a) * r * 0.85, ez = z + Math.sin(a) * r * 0.85;
          const ey = cy + (rnd() - 0.3) * crownHalf * 0.9;
          limb(x, sy, z, ex, ey, ez, tr * 0.45);
          for (let j = 0; j < 2; j++) {          // twigs off each limb
            const f = 0.55 + rnd() * 0.3;
            const bx = x + (ex - x) * f, by = sy + (ey - sy) * f, bz = z + (ez - z) * f;
            const ta = a + (j ? 0.7 : -0.7);
            limb(bx, by, bz, bx + Math.cos(ta) * r * 0.35, by + crownHalf * 0.35, bz + Math.sin(ta) * r * 0.35, tr * 0.18);
          }
        }
        M.compose(Pv.set(x, cy, z), I, S.set(r, crownHalf, r));
        wireC.setMatrixAt(i, M);
        solidC.setMatrixAt(i, M);
        col.setHSL(0.27 + rnd() * 0.05, 0.45, 0.22 + rnd() * 0.08);
        solidC.setColorAt(i, col);
      });
      const woodMesh = wood.mesh(std(0x5b4636, { side: THREE.DoubleSide }), { cast: true });
      solidC.castShadow = true;
      solidC.visible = false;
      site.add(woodMesh, wireC, solidC);
      leavesWire = wireC; leavesSolid = solidC;
    }

    // ── cemetery headstones ─────────────────────────────────────────────
    into = 'props';
    if (cemetery) {
      const xs = cemetery.map((p) => p[0]), zs = cemetery.map((p) => p[1]);
      const stones = [];
      for (let x = Math.min(...xs); x < Math.max(...xs); x += 4.5)
        for (let z = Math.min(...zs); z < Math.max(...zs); z += 6.5)
          if (inPoly(x, z, cemetery) && rnd() < 0.75) stones.push([x, z]);
      const st = new THREE.InstancedMesh(new THREE.BoxGeometry(0.7, 0.9, 0.2),
                                         std(0xc9c9c4), stones.length);
      stones.forEach(([x, z], i) => { M.compose(Pv.set(x, 0.45, z), Q, S.set(1, 1, 1)); st.setMatrixAt(i, M); });
      site.add(st);
    }

    // ── parked cars (detail) ─────────────────────────────────────────
    const colors = [0xb0b4ba, 0x1e2a44, 0x8b0000, 0xf2f2f2, 0x2b2b2b, 0x3c5a7a];
    for (const P of parkings) {
      const r = orientedRect(P);
      if (r.L * r.W > 30000) continue;
      const cars = new THREE.Group();
      const ca = Math.cos(r.ang), sa = Math.sin(r.ang);
      for (let u = -r.L / 2 + 3; u < r.L / 2 - 3; u += 2.8)
        for (let v = -r.W / 2 + 3; v < r.W / 2 - 3; v += 6.5) {
          if (rnd() < 0.4) continue;
          const x = r.x + u * ca - v * sa, z = r.z + u * sa + v * ca;
          if (!inPoly(x, z, P)) continue;
          const c = car(colors[(rnd() * colors.length) | 0]);
          c.position.set(x, 0, z);
          c.rotation.y = -r.ang + Math.PI / 2 + (rnd() < 0.5 ? 0 : Math.PI);
          cars.add(c);
        }
      site.add(cars);
      const w = toWorld(r.x, r.z);
      details.push({ obj: cars, x: w.x, z: w.z, lx: r.x, lz: r.z, r: 70 + Math.max(r.L, r.W) / 2 });
    }

    for (const d of details) d.obj.visible = false;
    // ── ground contours (USGS 3DEP lidar, 10 cm) ─────────────────────────
    into = 'contours';
    let contours = null;
    const CT = window.LIGHTHOUSE_CONTOURS;
    if (CT && CT.levels.length) {
      const pos = [], colA = [];
      const lo = CT.levels[0].z, hi = CT.levels[CT.levels.length - 1].z;
      const c = new THREE.Color(), cLo = new THREE.Color(0x1f5fd6), cHi = new THREE.Color(0xd9a441);
      for (const lv of CT.levels) {
        const major = Math.abs(lv.z * 2 - Math.round(lv.z * 2)) < 1e-6;   // every 0.5 m
        if (major) c.set(0xffffff); else c.copy(cLo).lerp(cHi, (lv.z - lo) / (hi - lo || 1));
        const s = lv.s;
        for (let k = 0; k < s.length; k += 4) {
          pos.push(s[k], 0.3, s[k + 1], s[k + 2], 0.3, s[k + 3]);
          colA.push(c.r, c.g, c.b, c.r, c.g, c.b);
        }
      }
      const g = new THREE.BufferGeometry();
      g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
      g.setAttribute('color', new THREE.Float32BufferAttribute(colA, 3));
      contours = new THREE.LineSegments(g, new THREE.LineBasicMaterial({ vertexColors: true,
        transparent: true, opacity: 0.85, depthWrite: false }));
      contours.renderOrder = 40;
      site.add(contours);
    }
    // Official contour sets, labelled in feet: City of Philadelphia 2018
    // lidar (2 ft, orange) and the USGS topo-map contours (10 ft, red).
    const footContours = (levels, color, labelColor, every) => {
      const grp = new THREE.Group(), pos = [], labelAt = [];
      for (const lv of levels) {
        for (const ln of lv.lines) {
          let run = every / 2;
          for (let k = 0; k + 3 < ln.length; k += 2) {
            pos.push(ln[k], 0.32, ln[k + 1], ln[k + 2], 0.32, ln[k + 3]);
            run += Math.hypot(ln[k + 2] - ln[k], ln[k + 3] - ln[k + 1]);
            if (run > every) { labelAt.push([ln[k], ln[k + 1], lv.ft]); run = 0; }
          }
        }
      }
      const g = new THREE.BufferGeometry();
      g.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
      const lines = new THREE.LineSegments(g, new THREE.LineBasicMaterial({ color, depthWrite: false }));
      lines.renderOrder = 41;
      grp.add(lines);
      for (const [x, z, ft] of labelAt) {
        const cv = document.createElement('canvas');
        cv.width = 128; cv.height = 48;
        const c2 = cv.getContext('2d');
        c2.font = 'bold 30px sans-serif'; c2.textAlign = 'center'; c2.textBaseline = 'middle';
        c2.lineWidth = 6; c2.strokeStyle = 'rgba(0,0,0,0.8)'; c2.strokeText(ft + ' ft', 64, 24);
        c2.fillStyle = labelColor; c2.fillText(ft + ' ft', 64, 24);
        const m = new THREE.Mesh(new THREE.PlaneGeometry(5, 1.9),
          new THREE.MeshBasicMaterial({ map: new THREE.CanvasTexture(cv), transparent: true, depthWrite: false }));
        m.rotation.x = -Math.PI / 2;
        m.position.set(x, 0.34, z);
        m.renderOrder = 42;
        grp.add(m);
      }
      grp.visible = false;
      site.add(grp);
      return grp;
    };
    // Runoff channels (lidar D8 flow): blue ribbons, wider and brighter the
    // more ground drains through them.
    let drainage = null;
    const DR = window.LIGHTHOUSE_DRAINAGE;
    if (DR && DR.segs.length) {
      drainage = new THREE.Group();
      const classes = [[300, 2000, 0x3d7fd9, 0.5], [2000, 15000, 0x29a8ff, 0.9], [15000, 1e9, 0x00d5ff, 1.4]];
      for (const [lo, hi, color, wd] of classes) {
        const mg = new Merge();
        const s = DR.segs;
        for (let k = 0; k < s.length; k += 5) {
          if (s[k + 4] < lo || s[k + 4] >= hi) continue;
          addRibbon(mg, [[s[k], s[k + 1]], [s[k + 2], s[k + 3]]], wd, 0.36);
        }
        if (!mg.pos.length) continue;
        const mesh = mg.mesh(new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 0.85,
          depthWrite: false, side: THREE.DoubleSide, polygonOffset: true,
          polygonOffsetFactor: -8, polygonOffsetUnits: -32 }));
        mesh.renderOrder = 43;
        drainage.add(mesh);
      }
      waterLayer.add(drainage);
      // The MAIN channels in bold orange on top (James 10/24: "put in
      // orange the spots that you think are the water channels"): every
      // D8 path carrying ≥ 0.5 ha of ground, wider the more drains in.
      into = 'channels';
      for (const [lo, hi, wd] of [[5000, 15000, 1.2], [15000, 40000, 2.0], [40000, 1e9, 3.0]]) {
        const mg = new Merge();
        for (let k = 0; k < DR.segs.length; k += 5) {
          const s5 = DR.segs;
          if (s5[k + 4] < lo || s5[k + 4] >= hi) continue;
          addRibbon(mg, [[s5[k], s5[k + 1]], [s5[k + 2], s5[k + 3]]], wd, 0.4);
        }
        if (!mg.pos.length) continue;
        const mesh = mg.mesh(new THREE.MeshBasicMaterial({ color: 0xff6a00, transparent: true, opacity: 0.9,
          depthWrite: false, depthTest: false, side: THREE.DoubleSide }));
        mesh.renderOrder = 59;
        site.add(mesh);
      }
      into = 'contours';
    }
    // Chalk for one 7v7 (site metres, yards → metres by the caller).
    let gameSeven = null;
    const sevenChalk = (sv, color) => {
      const a = sv.rotDeg * D2R, ca = Math.cos(a), sa = Math.sin(a);
      const at = ([u, v]) => [sv.x + u * ca - v * sa, sv.z + u * sa + v * ca];
      const chalk = new Merge();
      const ln = (pts) => addRibbon(chalk, pts.map(at), 0.12, 0.09);
      const l = sv.length / 2, w = sv.width / 2;
      ln([[-l, -w], [l, -w], [l, w], [-l, w], [-l, -w]]);
      ln([[0, -w], [0, w]]);
      const c = [];
      for (let k = 0; k <= 32; k++) c.push([Math.cos(k / 16 * Math.PI) * 6.4, Math.sin(k / 16 * Math.PI) * 6.4]);
      ln(c);
      for (const sg of [-1, 1]) {
        const e = sg * l;
        ln([[e, -9], [e - sg * 9, -9], [e - sg * 9, 9], [e, 9]]);
      }
      const m = chalk.mesh(new THREE.MeshBasicMaterial({ color, side: THREE.DoubleSide,
        polygonOffset: true, polygonOffsetFactor: -6, polygonOffsetUnits: -26 }));
      m.renderOrder = 31;
      return m;
    };
    const cityContours = CT && CT.city2ft && CT.city2ft.length
      ? footContours(CT.city2ft, 0xff7a1a, '#ffb066', 60) : null;
    const topoContours = CT && CT.usgsTopo && CT.usgsTopo.length
      ? footContours(CT.usgsTopo, 0xe0262d, '#ff8a8a', 50) : null;

    delete site.add;   // back to THREE's add: later adds (planner, 7v7 chalk) sit on the site
    // Bleachers are world-side (game-pitch coordinates): the props layer
    // hides them too.
    const setLayer = (k, v) => {
      if (layerGroups[k]) layerGroups[k].visible = !!v;
      if (k === 'props') for (const m of planAOverlay) m.visible = !!v;
    };
    return {
      site,   // site-metre group (pitch-planner.js draws into it)
      // Layer names: ground, buildings, fences, softball_fences, props,
      // trees, labels, contours, water, paint (today's pitch),
      // proposed_lane, channels.
      layers: Object.keys(layerGroups),
      setLayer,
      // Contours. mode: 'lidar' (10 cm from USGS 3DEP; white every half
      // metre), 'city' (2 ft), 'topo' (USGS topo map, 10 ft), 'all', 'off'.
      // Runoff channels live in the WATER layer (setWater).
      setContours(mode) {
        if (contours) contours.visible = mode === 'lidar' || mode === 'all';
        if (cityContours) cityContours.visible = mode === 'city' || mode === 'all';
        if (topoContours) topoContours.visible = mode === 'topo' || mode === 'all';
      },
      waterLayer,
      setWater(on) { waterLayer.visible = !!on; },
      // Move the match onto a designed pitch (site metres, degrees): the
      // whole site turns so it lands on the world origin; LOD anchors
      // follow. Bleachers + the game pitch are world-side and come along.
      setGamePitch(p) {
        placeSite(p);
        for (const d of details) {
          if (d.lx === undefined) continue;
          const w = toWorld(d.lx, d.lz);
          d.x = w.x;
          d.z = w.z;
        }
      },
      // Today's painted (yellow) pitch: a DESIGN reference only.
      setOldPitch(on) { if (oldPitchMesh) oldPitchMesh.visible = !!on; },
      // The designed 7v7 painted on the grass in GAME (chalk + centre
      // circle + goal areas, like layout.sevens); null removes it.
      setGameSeven(sv) {
        if (gameSeven) { site.remove(gameSeven); gameSeven = null; }
        if (!sv) return;
        gameSeven = sevenChalk(sv, 0xf4f6fb);
        site.add(gameSeven);
      },
      // Leaves: false = see-through wire canopy (default), true = solid.
      setLeaves(on) {
        if (leavesWire) leavesWire.visible = !on;
        if (leavesSolid) leavesSolid.visible = !!on;
      },
      update(camera, t) {
        for (const d of details) {
          const near = Math.hypot(camera.position.x - d.x, camera.position.z - d.z) <
                       d.r + camera.position.y * 0.6;
          d.obj.visible = near;
          if (near && d.tick) d.tick(t);
        }
      },
    };
  }

  function box(x, z, w, d, h, color, rotDeg, y0) {
    const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), std(color));
    m.position.set(x, (y0 || 0) + h / 2, z);
    m.rotation.y = -(rotDeg || 0) * D2R;
    m.castShadow = m.receiveShadow = true;
    return m;
  }

  // Two-rail post fence along a polyline (closed = back to the start),
  // posts every <= 2.5 m.
  function railFence(parent, pts, closed, color) {
    const rail = std(color || 0xe9e6dc);
    const n = closed ? pts.length : pts.length - 1;
    for (let k = 0; k < n; k++) {
      const [ax, az] = pts[k], [bx, bz] = pts[(k + 1) % pts.length];
      const len = Math.hypot(bx - ax, bz - az);
      for (const hh of [0.6, 1.2]) {
        const r = new THREE.Mesh(new THREE.BoxGeometry(len, 0.1, 0.08), rail);
        r.position.set((ax + bx) / 2, hh, (az + bz) / 2);
        r.rotation.y = -Math.atan2(bz - az, bx - ax);
        parent.add(r);
      }
      const np = Math.max(1, Math.ceil(len / 2.5));
      for (let i = 0; i < np + (!closed && k === n - 1 ? 1 : 0); i++) {
        const post = new THREE.Mesh(new THREE.BoxGeometry(0.15, 1.4, 0.15), rail);
        post.position.set(ax + (bx - ax) * i / np, 0.7, az + (bz - az) * i / np);
        parent.add(post);
      }
    }
  }

  window.LighthouseField = { build };
})();
