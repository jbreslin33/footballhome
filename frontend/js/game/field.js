// frontend/js/game/field.js
//
// Lighthouse Field — the ground the game is played on (James: "can all
// look like lighthouse field"; "199 east erie avenue philadelphia pa").
// Mapped from satellite imagery of Lighthouse Sport Complex Field: the
// pitch sits in the open middle; the SITE group is placed around it in
// metres (+x east along Erie Ave, +z south toward Erie). Scale read off
// the map's scale bars (0.81 m/px wide view, 0.405 m/px close view).
// Approximate by design — recognisable, not a survey.
//
// Around the pitch: five portable 3-row aluminium bleachers (James:
// "3 row stands, movable, like 5 of them"). Beyond it: Front St, Erie Ave
// (it runs at an angle), Whitaker Ave, Cedar Hill Cemetery, the tree
// lines, three ball diamonds with backstops, the rodeo ring, the barn
// and paddock, the clubhouse, The League Park basketball court, parking.
//
// DETAILS (horses, the Sixers-colours court markings + hoops, parked
// cars) are only drawn when the camera comes near them ("details that
// are cool but not rendered unless we scan the field") — zero cost in
// normal play.

(function () {
  'use strict';

  const std = (color, extra) => new THREE.MeshStandardMaterial(
    Object.assign({ color, roughness: 0.9 }, extra || {}));

  function flat(pts, color, y) {
    const sh = new THREE.Shape(pts.map(([x, z]) => new THREE.Vector2(x, -z)));
    const m = new THREE.Mesh(new THREE.ShapeGeometry(sh), std(color, { roughness: 1 }));
    m.rotation.x = -Math.PI / 2;
    m.position.y = y;
    m.receiveShadow = true;
    return m;
  }
  function disc(x, z, r, color, y, opts) {
    const m = new THREE.Mesh(new THREE.CircleGeometry(r, 32, 0, (opts && opts.arc) || Math.PI * 2),
                             std(color, { roughness: 1 }));
    m.rotation.set(-Math.PI / 2, 0, (opts && opts.rot) || 0);
    m.position.set(x, y, z);
    m.receiveShadow = true;
    return m;
  }
  function box(x, z, w, d, h, color, rot, y0) {
    const m = new THREE.Mesh(new THREE.BoxGeometry(w, h, d), std(color));
    m.position.set(x, (y0 || 0) + h / 2, z);
    m.rotation.y = rot || 0;
    m.castShadow = m.receiveShadow = true;
    return m;
  }
  function inPoly(x, z, poly) {
    let c = false;
    for (let i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      const [xi, zi] = poly[i], [xj, zj] = poly[j];
      if ((zi > z) !== (zj > z) && x < ((xj - xi) * (z - zi)) / (zj - zi) + xi) c = !c;
    }
    return c;
  }
  // Deterministic scatter so the ground looks the same every load.
  let seed = 1893;
  const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);

  // ── portable aluminium bleacher: 3 seat planks + footboards, A-frames ──
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

  // ── a horse: barrel body, neck, head, legs, tail; grazes when idle ──
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
      const hoof = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.08, 0.1, 6), dark);
      hoof.position.set(lx, 0.05, lz);
      g.add(leg, hoof);
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
    // The League Park at Lighthouse: blue court, red keys, white lines —
    // Sixers colours, as the satellite shows.
    const c = document.createElement('canvas');
    c.width = 1024; c.height = 560;
    const x = c.getContext('2d');
    const sx = 1024 / 28.65, sy = 560 / 15.24;      // NBA court, metres
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
      x.arc(hx, 280, 7.24 * sx, side ? Math.PI / 2 : -Math.PI / 2, side ? Math.PI * 1.5 : Math.PI / 2, false);
      x.stroke();
    }
    x.fillStyle = '#ffffff';
    x.font = 'bold 34px system-ui, sans-serif';
    x.textAlign = 'center';
    x.fillText('THE LEAGUE PARK', 300, 60);
    x.fillText('AT LIGHTHOUSE', 724, 520);
    return new THREE.CanvasTexture(c);
  }

  function hoop(rot) {
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
    g.rotation.y = rot;
    g.traverse((o) => { if (o.isMesh) o.castShadow = true; });
    return g;
  }

  function car(color) {
    const g = new THREE.Group();
    const body = new THREE.Mesh(new THREE.BoxGeometry(4.4, 0.75, 1.8), std(color, { roughness: 0.35, metalness: 0.4 }));
    body.position.y = 0.6;
    const cab = new THREE.Mesh(new THREE.BoxGeometry(2.2, 0.6, 1.6), std(0x22262c, { roughness: 0.2 }));
    cab.position.set(-0.2, 1.25, 0);
    g.add(body, cab);
    g.traverse((o) => { if (o.isMesh) o.castShadow = true; });
    return g;
  }

  function build(scene, hx, hy) {
    const details = [];   // {obj, x, z, r, tick?}

    // ── the five bleachers round the pitch (world coords) ─────────────
    for (const sp of [
      { x: -26, z: -(hy + 3.5), len: 7.5, face: 0 },
      { x: 0, z: -(hy + 3.5), len: 7.5, face: 0 },
      { x: 26, z: -(hy + 3.5), len: 7.5, face: 0 },
      { x: -18, z: hy + 3.5, len: 6, face: Math.PI },
      { x: 18, z: hy + 3.5, len: 6, face: Math.PI },
    ]) {
      const b = bleacher(sp.len);
      b.position.set(sp.x, 0, sp.z);
      b.rotation.y = sp.face;          // seats rise AWAY from the pitch
      scene.add(b);
    }

    // ── the site, in map coordinates, offset so the pitch sits in the
    // open middle ──────────────────────────────────────────────────────
    const site = new THREE.Group();
    site.position.set(-24, 0, 16);
    scene.add(site);
    const at = (x, z) => [x - 24, z + 16];   // site → world (for LOD)

    const LOT = [[-268, 0], [-146, -36], [8, -105], [138, -142], [296, -158],
                 [186, 186], [-268, 128]];
    const CEM = [[-268, 0], [-268, -340], [340, -340], [296, -158], [138, -142],
                 [8, -105], [-146, -36]];
    const erieZ = (x) => 133 + (x + 268) * 0.12;          // Erie's north kerb
    site.add(flat([[-700, -700], [700, -700], [700, 700], [-700, 700]], 0x8b8f94, -0.07));
    site.add(flat(CEM, 0x5f8f4a, -0.06));
    site.add(flat(LOT, 0x4f8a3a, -0.05));
    // Roads.
    const asphalt = 0x3b3f45;
    site.add(flat([[-700, erieZ(-700) + 3], [700, erieZ(700) + 3],
                   [700, erieZ(700) + 26], [-700, erieZ(-700) + 26]], asphalt, -0.04));
    site.add(flat([[-292, -700], [-274, -700], [-274, 700], [-292, 700]], asphalt, -0.04));
    site.add(flat([[190, 195], [208, 195], [324, -220], [306, -220]], asphalt, -0.04));

    // Dirt: the main diamond (home plate SW, fan to the NE), two skin
    // infields east and south, the rodeo apron, the dirt track along the
    // north tree line, the paddock.
    const dirt = 0xb8865a;
    site.add(disc(-76, 89, 44, dirt, -0.03, { arc: Math.PI / 2 }));
    const infield = new THREE.Mesh(new THREE.PlaneGeometry(19, 19), std(0x4f8a3a, { roughness: 1 }));
    infield.rotation.set(-Math.PI / 2, 0, Math.PI / 4);
    infield.position.set(-76 + 13.4, -0.025, 89 - 13.4);
    site.add(infield);
    site.add(disc(-76 + 13.4, 89 - 13.4, 2.8, dirt, -0.02));        // mound
    site.add(disc(136, 45, 20, dirt, -0.03));
    site.add(disc(106, 134, 17, dirt, -0.03));
    site.add(flat([[-146, -42], [8, -112], [140, -150], [205, -110],
                   [200, -102], [138, -140], [8, -100], [-146, -30]], 0xc2a57a, -0.035));

    // Backstops (chain-link) behind home plates.
    const chain = std(0x9aa1a8, { metalness: 0.5, roughness: 0.5, transparent: true, opacity: 0.5 });
    const backstop = (x, z, rot) => {
      for (const [dx, a] of [[-4.5, 0.6], [0, 0], [4.5, -0.6]]) {
        const f = new THREE.Mesh(new THREE.BoxGeometry(5, 4, 0.06), chain);
        f.position.set(x + Math.cos(rot) * dx, 2, z - Math.sin(rot) * dx);
        f.rotation.y = rot + a;
        site.add(f);
      }
    };
    backstop(-80, 93, Math.PI / 4);
    backstop(148, 64, -0.5);
    backstop(117, 150, -0.3);
    // Benches along the main diamond's first-base line.
    site.add(box(-60, 98, 10, 0.6, 0.5, 0x6b7078, 0));

    // ── the RODEO ring (north-east): sand inside white panels, four little
    // bleachers, canopy tent + trailers south-west ─────────────────────
    const RX = 199 + 24, RZ = -79 - 16, RR = 16;
    site.add(disc(RX, RZ, RR + 5, dirt, -0.03));
    site.add(disc(RX, RZ, RR, 0xd8c08f, -0.02));
    const panelM = std(0xf2f2ee, { roughness: 0.6 });
    const NP = 28;
    for (let k = 0; k < NP; k++) {
      const a = (k / NP) * Math.PI * 2;
      const p = new THREE.Mesh(new THREE.BoxGeometry(2 * Math.PI * RR / NP - 0.2, 1.6, 0.1), panelM);
      p.position.set(RX + Math.cos(a) * RR, 0.8, RZ + Math.sin(a) * RR);
      p.rotation.y = -a + Math.PI / 2;
      p.castShadow = true;
      site.add(p);
    }
    for (const a of [0, Math.PI / 2, Math.PI, -Math.PI / 2]) {
      const b = bleacher(5);
      b.position.set(RX + Math.cos(a) * (RR + 4), 0, RZ + Math.sin(a) * (RR + 4));
      b.rotation.y = Math.atan2(RX - b.position.x, RZ - b.position.z);
      site.add(b);
    }
    site.add(box(RX - 34, RZ + 22, 10, 6, 3.2, 0xf5f5f2, 0.3));     // canopy tent
    site.add(box(RX - 22, RZ + 16, 9, 2.5, 3, 0xe4e6ea, 1.2));      // trailer
    site.add(box(RX + 22, RZ - 4, 7, 2.4, 2.8, 0xd5d8dc, 1.4));     // trailer

    // ── the BARN + paddock (by Erie): red siding, white trim, gable roof ─
    const BX = 57, BZ = 128;
    const barn = new THREE.Group();
    const siding = std(0x9b2f2a, { roughness: 0.85 });
    const trim = std(0xf2f0ea, { roughness: 0.7 });
    const roofM = std(0x2f3338, { roughness: 0.8 });
    const BW = 16, BD = 12, BH = 5;
    const walls = new THREE.Mesh(new THREE.BoxGeometry(BW, BH, BD), siding);
    walls.position.y = BH / 2;
    barn.add(walls);
    const gable = new THREE.Shape([new THREE.Vector2(-BD / 2, 0), new THREE.Vector2(BD / 2, 0),
                                   new THREE.Vector2(0, 3.6)]);
    for (const sx of [-1, 1]) {
      const end = new THREE.Mesh(new THREE.ShapeGeometry(gable), siding);
      end.rotation.y = sx * Math.PI / 2;
      end.position.set(sx * BW / 2, BH, 0);
      barn.add(end);
    }
    const slope = Math.hypot(BD / 2, 3.6);
    for (const sz of [-1, 1]) {
      const r = new THREE.Mesh(new THREE.BoxGeometry(BW + 0.8, 0.15, slope + 0.5), roofM);
      r.position.set(0, BH + 1.8, sz * BD / 4);
      r.rotation.x = sz * Math.atan2(3.6, BD / 2);
      barn.add(r);
    }
    const door = new THREE.Mesh(new THREE.BoxGeometry(4, 4, 0.1), trim);
    door.position.set(0, 2, BD / 2 + 0.05);
    const x1 = new THREE.Mesh(new THREE.BoxGeometry(5.4, 0.25, 0.12), trim);
    x1.position.set(0, 2, BD / 2 + 0.12);
    x1.rotation.z = Math.atan2(4, 4);
    const x2 = x1.clone();
    x2.rotation.z = -x1.rotation.z;
    barn.add(door, x1, x2);
    barn.traverse((o) => { if (o.isMesh) { o.castShadow = true; o.receiveShadow = true; } });
    barn.position.set(BX, 0, BZ);
    barn.rotation.y = Math.PI;      // big doors face the field
    site.add(barn);
    site.add(disc(BX - 18, BZ, 7.5, dirt, -0.02));
    const rail = std(0xe9e6dc);
    const pad = [[BX - 25, BZ - 7], [BX - 11, BZ - 7], [BX - 11, BZ + 7], [BX - 25, BZ + 7]];
    for (let k = 0; k < 4; k++) {
      const [ax, az] = pad[k], [bx, bz] = pad[(k + 1) % 4];
      const len = Math.hypot(bx - ax, bz - az);
      for (const h of [0.6, 1.2]) {
        const r = new THREE.Mesh(new THREE.BoxGeometry(len, 0.1, 0.08), rail);
        r.position.set((ax + bx) / 2, h, (az + bz) / 2);
        r.rotation.y = -Math.atan2(bz - az, bx - ax);
        site.add(r);
      }
      for (let t = 0; t <= len; t += 3.5) {
        const post = new THREE.Mesh(new THREE.BoxGeometry(0.15, 1.4, 0.15), rail);
        post.position.set(ax + (bx - ax) * t / len, 0.7, az + (bz - az) * t / len);
        site.add(post);
      }
    }
    // DETAIL: horses — three in the paddock, one at the barn door.
    const horses = new THREE.Group();
    for (const [x, z, rot, coat] of [[BX - 21, BZ - 3, 0.4, 0x6b3e26], [BX - 15, BZ + 3, 2.6, 0x2a1d15],
                                     [BX - 19, BZ + 4, -1.2, 0xb08a5a], [BX + 1, BZ - 9, 1.6, 0x8a5a3a]]) {
      const h = horse(coat);
      h.position.set(x, 0, z);
      h.rotation.y = rot;
      horses.add(h);
    }
    site.add(horses);
    const [hwx, hwz] = at(BX - 12, BZ);
    details.push({ obj: horses, x: hwx, z: hwz, r: 75,
      tick(t) {
        for (const h of horses.children) {
          // Graze: neck dips to the grass and back up, each at its own pace.
          const k = Math.sin(t * 0.6 + h.userData.phase);
          h.userData.neck.rotation.z = k > 0.2 ? -0.9 * Math.min(1, (k - 0.2) * 2) : 0;
        }
      } });

    // ── clubhouse on Erie; The League Park building + court; parking ──
    site.add(box(-38, 118, 24, 15, 7, 0x8c4a3c, 0.12));                 // the Lighthouse building
    const sign = new THREE.Mesh(new THREE.PlaneGeometry(9, 1.6), new THREE.MeshBasicMaterial({
      map: (() => {
        const c = document.createElement('canvas'); c.width = 512; c.height = 90;
        const x = c.getContext('2d');
        x.fillStyle = '#14326e'; x.fillRect(0, 0, 512, 90);
        x.fillStyle = '#ffcc00'; x.font = 'bold 46px system-ui, sans-serif';
        x.textAlign = 'center'; x.fillText('THE LIGHTHOUSE · 1893', 256, 62);
        return new THREE.CanvasTexture(c);
      })() }));
    sign.position.set(-38 + 1, 5.6, 118 - 7.6);
    sign.rotation.y = Math.PI + 0.12;
    site.add(sign);
    site.add(box(-238, 52, 12, 10, 4.5, 0x7a6a5a, -0.5));               // League Park building
    const CX = -190, CZ = 54, CROT = 0.55;
    const court = new THREE.Mesh(new THREE.PlaneGeometry(30, 16.5), std(0x8f949b, { roughness: 1 }));
    court.rotation.set(-Math.PI / 2, 0, CROT);
    court.position.set(CX, -0.02, CZ);
    site.add(court);
    // DETAIL: court markings + hoops.
    const courtD = new THREE.Group();
    const lines = new THREE.Mesh(new THREE.PlaneGeometry(28.65, 15.24),
      new THREE.MeshStandardMaterial({ map: courtTexture(), roughness: 0.8 }));
    lines.rotation.set(-Math.PI / 2, 0, CROT);
    lines.position.set(CX, -0.01, CZ);
    lines.receiveShadow = true;
    courtD.add(lines);
    for (const s of [-1, 1]) {
      const h = hoop(s > 0 ? Math.PI - CROT : -CROT);
      const d = s * 13.0;
      h.position.set(CX + Math.cos(CROT) * d, 0, CZ - Math.sin(CROT) * d);
      courtD.add(h);
    }
    site.add(courtD);
    const [cwx, cwz] = at(CX, CZ);
    details.push({ obj: courtD, x: cwx, z: cwz, r: 80 });
    site.add(flat([[-145, 47], [-95, 47], [-95, 104], [-145, 104]], 0x55595f, -0.03));  // lot
    const cars = new THREE.Group();
    const colors = [0xb0b4ba, 0x1e2a44, 0x8b0000, 0xf2f2f2, 0x2b2b2b, 0x3c5a7a];
    for (let i = 0; i < 18; i++) {
      if (rnd() < 0.25) continue;
      const c = car(colors[i % colors.length]);
      const row = i % 3, col = Math.floor(i / 3);
      c.position.set(-138 + row * 18, 0, 55 + col * 8);
      c.rotation.y = rnd() < 0.5 ? 0 : Math.PI;
      cars.add(c);
    }
    site.add(cars);
    const [lwx, lwz] = at(-120, 75);
    details.push({ obj: cars, x: lwx, z: lwz, r: 90 });

    // Neighbourhood massing: St Christopher's across Erie, police + the
    // warehouses past Whitaker, row houses west of Front St.
    for (const [x, z, w, d, h] of [[-160, 230, 70, 60, 26], [-80, 240, 60, 70, 18],
                                   [-240, 225, 40, 50, 14], [0, 225, 40, 30, 10]])
      site.add(box(x, z, w, d, h, 0xd9d6cf));
    site.add(box(250, 30, 50, 34, 9, 0xe8e8e8, -0.5));
    for (const [x, z, w, d, h] of [[330, 110, 60, 40, 12], [360, -60, 70, 60, 14],
                                   [300, 230, 80, 50, 10], [420, 60, 50, 60, 16]])
      site.add(box(x, z, w, d, h, 0x9aa0a8, -0.35));
    for (let z = -20; z < 130; z += 9) site.add(box(-305, z, 12, 8, 9 + (z % 3), 0x9a5a48));

    // ── trees (instanced): tree lines + the copse round the court ──────
    const trees = [];
    const line = (x0, z0, x1, z1, step, jitter) => {
      const n = Math.max(1, Math.round(Math.hypot(x1 - x0, z1 - z0) / step));
      for (let i = 0; i <= n; i++) {
        const t = i / n;
        trees.push([x0 + (x1 - x0) * t + (rnd() - 0.5) * jitter,
                    z0 + (z1 - z0) * t + (rnd() - 0.5) * jitter]);
      }
    };
    line(-150, -34, 8, -110, 6, 6);           // the cemetery tree line
    line(8, -110, 138, -146, 9, 5);
    line(150, -150, 205, -130, 8, 4);
    line(178, 176, 292, -150, 6, 4);           // Whitaker verge
    line(-262, 124, 176, erieZ(176) - 4, 9, 3); // Erie verge
    line(-150, -30, -150, 40, 7, 4);           // path edge
    for (let i = 0; i < 90; i++) {             // copse round the court / League Park
      const x = -268 + rnd() * 118, z = -2 + rnd() * 128;
      const inCourt = Math.hypot(x - CX, z - CZ) < 20;
      const inLot = x > -150 && z > 42 && z < 108;
      if (!inCourt && !inLot && Math.hypot(x + 238, z - 52) > 10) trees.push([x, z]);
    }
    for (let i = 0; i < 90; i++) {             // cemetery clumps
      const x = -268 + rnd() * 600, z = -340 + rnd() * 240;
      if (inPoly(x, z, CEM)) trees.push([x, z]);
    }
    const M = new THREE.Matrix4(), Q = new THREE.Quaternion(),
          S = new THREE.Vector3(), P = new THREE.Vector3();
    const trunks = new THREE.InstancedMesh(new THREE.CylinderGeometry(0.25, 0.35, 3, 6),
                                           std(0x5b4636), trees.length);
    const crowns = new THREE.InstancedMesh(new THREE.IcosahedronGeometry(3.2, 1),
      std(0x2f6b2a, { roughness: 1, flatShading: true }), trees.length);
    trees.forEach(([x, z], i) => {
      const k = 0.8 + rnd() * 0.7;
      M.compose(P.set(x, 1.5 * k, z), Q, S.set(k, k, k));
      trunks.setMatrixAt(i, M);
      M.compose(P.set(x, 5 * k, z), Q, S.set(k * 1.1, k, k * 1.1));
      crowns.setMatrixAt(i, M);
    });
    trunks.castShadow = crowns.castShadow = true;
    site.add(trunks, crowns);

    // Cedar Hill Cemetery headstones.
    const stones = [];
    for (let x = -264; x < 330; x += 4.5)
      for (let z = -330; z < -6; z += 6.5)
        if (inPoly(x, z, CEM) && !inPoly(x, z + 8, LOT) && rnd() < 0.8) stones.push([x, z]);
    const st = new THREE.InstancedMesh(new THREE.BoxGeometry(0.7, 0.9, 0.2),
                                       std(0xc9c9c4), stones.length);
    stones.forEach(([x, z], i) => { M.compose(P.set(x, 0.45, z), Q, S.set(1, 1, 1)); st.setMatrixAt(i, M); });
    site.add(st);

    // LOD: details exist only while the camera is near them.
    for (const d of details) d.obj.visible = false;
    return {
      update(camera, t) {
        for (const d of details) {
          const near = Math.hypot(camera.position.x - d.x, camera.position.z - d.z) < d.r +
                       camera.position.y * 0.6;
          d.obj.visible = near;
          if (near && d.tick) d.tick(t);
        }
      },
    };
  }

  window.LighthouseField = { build };
})();
