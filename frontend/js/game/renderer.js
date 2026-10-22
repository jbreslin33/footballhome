// frontend/js/game/renderer.js
//
// Three.js view of the authoritative world: a full-markings pitch,
// animated humanoid players (players.js), a rotatable camera rig
// (camera.js). Pure dressing: nothing here affects gameplay.
//
// Snapshot interpolation [QUAKE]: render ~4 ticks in the past on the
// SERVER'S tick timeline (not packet-arrival times — WS delivery is
// bursty, and arrival-based brackets caused visible jerk). We estimate
// the offset between local clock and tick timeline as the minimum
// observed (arrival - tick*dt), adapting slowly upward for clock drift.

(function () {
  'use strict';

  const INTERP_DELAY_TICKS = 4;  // ~133 ms behind live at 30 Hz
  const NO_OWNER = 255;

  // Grass: mowing stripes (pitch) or plain (surround) + per-pixel blade
  // noise, so the surface reads as turf rather than flat paint.
  function grassTexture(striped) {
    const W = striped ? 1024 : 256, H = striped ? 512 : 256;
    const c = document.createElement('canvas');
    c.width = W; c.height = H;
    const x = c.getContext('2d');
    const stripes = 12;
    for (let i = 0; i < (striped ? stripes : 1); i++) {
      x.fillStyle = striped ? (i % 2 ? '#2f8a2e' : '#277a27') : '#236b24';
      x.fillRect(striped ? (W / stripes) * i : 0, 0, striped ? W / stripes : W, H);
    }
    const img = x.getImageData(0, 0, W, H);
    for (let p = 0; p < img.data.length; p += 4) {
      const n = (Math.random() - 0.5) * 22;
      img.data[p] += n * 0.6; img.data[p + 1] += n; img.data[p + 2] += n * 0.4;
    }
    x.putImageData(img, 0, 0);
    const t = new THREE.CanvasTexture(c);
    t.wrapS = t.wrapT = THREE.RepeatWrapping;
    return t;
  }

  // Crowd: thousands of tiny shirts/faces on dark terraces.
  function crowdTexture(home) {
    const c = document.createElement('canvas');
    c.width = 512; c.height = 256;
    const x = c.getContext('2d');
    x.fillStyle = '#1a1f2b'; x.fillRect(0, 0, 512, 256);
    const shirts = home
      ? ['#14326e', '#14326e', '#ffcc00', '#f4f6fb', '#14326e', '#2b3a55']
      : ['#c8102e', '#f4f6fb', '#555', '#2b3a55', '#888', '#c8102e'];
    const faces = ['#f1c27d', '#c68642', '#8d5524', '#e0ac69'];
    for (let r = 0; r < 32; r++) {
      for (let k = 0; k < 96; k++) {
        if (Math.random() < 0.12) continue;      // empty seats
        const px = k * 5.33 + Math.random() * 2, py = r * 8 + 2;
        x.fillStyle = shirts[(Math.random() * shirts.length) | 0];
        x.fillRect(px, py + 3, 4, 4);
        x.fillStyle = faces[(Math.random() * faces.length) | 0];
        x.fillRect(px + 1, py, 2.5, 3);
      }
    }
    const t = new THREE.CanvasTexture(c);
    t.wrapS = t.wrapT = THREE.RepeatWrapping;
    return t;
  }

  function boardTexture(text, bg, fg) {
    const c = document.createElement('canvas');
    c.width = 512; c.height = 64;
    const x = c.getContext('2d');
    x.fillStyle = bg; x.fillRect(0, 0, 512, 64);
    x.fillStyle = fg;
    x.font = 'bold 40px system-ui, sans-serif';
    x.textAlign = 'center'; x.textBaseline = 'middle';
    x.fillText(text, 256, 34);
    return new THREE.CanvasTexture(c);
  }

  // Stadium dressing: raked stands with crowds and roofs on all four
  // sides, LED advertising boards round the pitch, floodlight masts.
  function buildStadium(scene, hx, hy) {
    const concrete = new THREE.MeshStandardMaterial({ color: 0x6b7280, roughness: 0.9 });
    const roofMat = new THREE.MeshStandardMaterial({ color: 0x1f2937, roughness: 0.7 });
    const sides = [
      { len: hx * 2 + 16, off: hy + 9, rot: 0, home: true },              // main stand (+z)
      { len: hx * 2 + 16, off: hy + 9, rot: Math.PI, home: false },       // opposite (−z)
      { len: hy * 2 + 16, off: hx + 9, rot: Math.PI / 2, home: true },    // end (+x)
      { len: hy * 2 + 16, off: hx + 9, rot: -Math.PI / 2, home: false },  // end (−x)
    ];
    for (const sd of sides) {
      const g = new THREE.Group();
      g.rotation.y = sd.rot;
      const depth = 18, rise = 11;
      const slope = Math.hypot(depth, rise);
      const tex = crowdTexture(sd.home);
      tex.repeat.set(sd.len / 14, 3);
      const terrace = new THREE.Mesh(
        new THREE.PlaneGeometry(sd.len, slope),
        new THREE.MeshStandardMaterial({ map: tex, roughness: 0.95 }));
      // Face the pitch (normal up and toward it) and rise AWAY from it;
      // the half-turn flips the texture back so the crowd sits upright.
      terrace.rotation.x = Math.atan2(depth, rise) + Math.PI;
      tex.center.set(0.5, 0.5);
      tex.rotation = Math.PI;
      terrace.position.set(0, rise / 2 + 0.6, sd.off + depth / 2);
      terrace.receiveShadow = true;
      g.add(terrace);
      const front = new THREE.Mesh(new THREE.BoxGeometry(sd.len, 1.2, 0.4), concrete);
      front.position.set(0, 0.6, sd.off);
      g.add(front);
      const back = new THREE.Mesh(new THREE.BoxGeometry(sd.len, rise + 6, 0.6), concrete);
      back.position.set(0, (rise + 6) / 2, sd.off + depth + 0.3);
      g.add(back);
      const roof = new THREE.Mesh(new THREE.BoxGeometry(sd.len, 0.4, depth + 4), roofMat);
      roof.position.set(0, rise + 6, sd.off + depth / 2 - 1);
      roof.rotation.x = 0.08;
      g.add(roof);
      scene.add(g);
    }

    // LED boards, 1 m tall, 4 m off the lines (behind the goals too).
    const ads = [
      ['FOOTBALL HOME', '#14326e', '#ffcc00'],
      ['LIGHTHOUSE · EST. 1893', '#ffcc00', '#14326e'],
      ['FOOTBALLHOME.ORG', '#0b1c3d', '#f4f6fb'],
    ];
    let n = 0;
    const board = (w, x0, z0, rotY) => {
      const [t, bg, fg] = ads[n++ % ads.length];
      const m = new THREE.Mesh(new THREE.BoxGeometry(w, 0.9, 0.12),
        [concrete, concrete, concrete, concrete,
         new THREE.MeshBasicMaterial({ map: boardTexture(t, bg, fg) }), concrete]);
      m.position.set(x0, 0.45, z0);
      m.rotation.y = rotY;
      m.castShadow = true;
      scene.add(m);
    };
    for (let x = -hx + 6; x < hx; x += 12) {
      board(11.6, x, hy + 4, Math.PI);   // faces the pitch (−z)
      board(11.6, x, -hy - 4, 0);
    }
    for (const sgn of [-1, 1]) {
      for (const z of [-14, 14]) board(11.6, sgn * (hx + 4), z, -sgn * Math.PI / 2);
    }

    // Floodlight masts at the corners with glowing lamp banks.
    const lamp = new THREE.MeshBasicMaterial({ color: 0xfffbe6 });
    for (const sx of [-1, 1]) {
      for (const sz of [-1, 1]) {
        const mast = new THREE.Mesh(new THREE.CylinderGeometry(0.4, 0.7, 34, 8), concrete);
        mast.position.set(sx * (hx + 16), 17, sz * (hy + 16));
        scene.add(mast);
        const bank = new THREE.Mesh(new THREE.BoxGeometry(6, 3, 0.6), lamp);
        bank.position.set(sx * (hx + 16), 35, sz * (hy + 16));
        bank.lookAt(0, 0, 0);
        scene.add(bank);
      }
    }
  }

  class GameRenderer {
    constructor(canvas) {
      this.canvas = canvas;
      this.figures = [];  // PlayerFigure per slot
      this.players = [];  // their root groups (raycast targets)
      this.shadows = [];
      this.ballMesh = null;
      this.buffer = []; // [{tick, snap}] on the server tick timeline
      this.tickRate = 30;
      this.timeOffset = null; // local ms ↔ tick-time ms estimate
      this.lastSnapshotAt = 0;
      this.lastFrameAt = 0;
      this.mySlots = new Set();
      this.activeSlot = null;
      this.kicks = [];        // [{tick, slot}] pending kick animations
      this.lastOwner = NO_OWNER;
      this.halfN = 11;

      this.scene = new THREE.Scene();
      this.scene.background = new THREE.Color(0x0b1c3d); // club navy sky
      this.scene.fog = new THREE.Fog(0x0b1c3d, 140, 260);

      this.camera = new THREE.PerspectiveCamera(
        45, window.innerWidth / window.innerHeight, 0.1, 500);
      this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
      this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
      this.renderer.shadowMap.enabled = true;
      this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      this.rig = new CameraRig(this.camera, canvas);

      // Low evening sun from the main-stand side: long readable shadows.
      const sun = new THREE.DirectionalLight(0xfff1dc, 1.15);
      sun.position.set(-40, 70, 45);
      sun.castShadow = true;
      const mobile = matchMedia('(pointer: coarse)').matches;
      sun.shadow.mapSize.set(mobile ? 1024 : 2048, mobile ? 1024 : 2048);
      Object.assign(sun.shadow.camera, { left: -75, right: 75, top: 60, bottom: -60, near: 10, far: 200 });
      sun.shadow.bias = -0.0004;
      sun.shadow.normalBias = 0.03;
      this.scene.add(sun);
      this.scene.add(new THREE.HemisphereLight(0xcfe0ff, 0x355e2f, 0.5));

      window.addEventListener('resize', () => this.resize());
      this.resize();
    }

    resize() {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    }

    line(points, mat) {
      this.scene.add(new THREE.Line(
        new THREE.BufferGeometry().setFromPoints(
          points.map(([x, z]) => new THREE.Vector3(x, 0.02, z))), mat));
    }
    arc(cx, cz, r, a0, a1, mat) {
      const pts = [];
      for (let i = 0; i <= 40; i++) {
        const a = a0 + (a1 - a0) * (i / 40);
        pts.push([cx + Math.cos(a) * r, cz + Math.sin(a) * r]);
      }
      this.line(pts, mat);
    }

    // Build pitch + players once HELLO tells us the dimensions.
    buildWorld(hello) {
      this.tickRate = hello.tickRate || 30;
      const hx = hello.pitchHalfX, hy = hello.pitchHalfY;
      this.hx = hx; this.hy = hy;

      // Grass (sim x → three x, sim y → three z): one canvas texture with
      // mowing stripes + blade noise, receiving real shadows.
      const surround = new THREE.Mesh(
        new THREE.PlaneGeometry(hx * 2 + 30, hy * 2 + 30),
        new THREE.MeshStandardMaterial({ map: grassTexture(false), roughness: 1 }));
      surround.material.map.repeat.set(6, 4);
      surround.rotation.x = -Math.PI / 2;
      surround.position.y = -0.01;
      surround.receiveShadow = true;
      this.scene.add(surround);
      const pitch = new THREE.Mesh(
        new THREE.PlaneGeometry(hx * 2 + 4, hy * 2 + 4),
        new THREE.MeshStandardMaterial({ map: grassTexture(true), roughness: 1 }));
      pitch.material.map.anisotropy = this.renderer.capabilities.getMaxAnisotropy();
      pitch.rotation.x = -Math.PI / 2;
      pitch.receiveShadow = true;
      this.scene.add(pitch);
      buildStadium(this.scene, hx, hy);

      // Full markings (Laws of the Game): touch/goal lines, halfway,
      // centre circle + spot, penalty + goal areas, spots, arcs, corners.
      const mark = new THREE.LineBasicMaterial({ color: 0xffffff });
      this.line([[-hx, -hy], [hx, -hy], [hx, hy], [-hx, hy], [-hx, -hy]], mark);
      this.line([[0, -hy], [0, hy]], mark);
      this.arc(0, 0, 9.15, 0, Math.PI * 2, mark);
      this.arc(0, 0, 0.2, 0, Math.PI * 2, mark);
      for (const s of [-1, 1]) {
        const gx = s * hx;
        const pa = gx - s * 16.5, ga = gx - s * 5.5;
        this.line([[gx, -20.16], [pa, -20.16], [pa, 20.16], [gx, 20.16]], mark);
        this.line([[gx, -9.16], [ga, -9.16], [ga, 9.16], [gx, 9.16]], mark);
        const spot = gx - s * 11;
        this.arc(spot, 0, 0.2, 0, Math.PI * 2, mark);
        // Penalty arc: the part of the 9.15 m circle outside the area.
        const a = Math.acos(5.5 / 9.15);
        if (s > 0) this.arc(spot, 0, 9.15, Math.PI - a, Math.PI + a, mark);
        else this.arc(spot, 0, 9.15, -a, a, mark);
        for (const cy of [-1, 1]) {
          const a0 = s > 0 ? (cy > 0 ? Math.PI : Math.PI / 2) : (cy > 0 ? -Math.PI / 2 : 0);
          this.arc(gx, cy * hy, 1, a0, a0 + Math.PI / 2, mark);
        }
      }

      // Goal frames + nets (7.32 x 2.44 m, 2 m deep).
      const postMat = new THREE.MeshLambertMaterial({ color: 0xffffff });
      const netMat = new THREE.MeshBasicMaterial({
        color: 0xffffff, wireframe: true, transparent: true, opacity: 0.35 });
      for (const sign of [-1, 1]) {
        const gx = sign * hx;
        for (const gy of [-3.66, 3.66]) {
          const post = new THREE.Mesh(
            new THREE.CylinderGeometry(0.06, 0.06, 2.44, 8), postMat);
          post.position.set(gx, 1.22, gy);
          post.castShadow = true;
          this.scene.add(post);
        }
        const bar = new THREE.Mesh(
          new THREE.CylinderGeometry(0.06, 0.06, 7.44, 8), postMat);
        bar.rotation.x = Math.PI / 2;
        bar.position.set(gx, 2.44, 0);
        bar.castShadow = true;
        this.scene.add(bar);
        const net = new THREE.Mesh(
          new THREE.BoxGeometry(2, 2.44, 7.32, 4, 6, 14), netMat);
        net.position.set(gx + sign * 1, 1.22, 0);
        this.scene.add(net);
      }

      // Players: slots [0, n/2) = home, rest = away.
      this.halfN = Math.floor(hello.slotCount / 2);
      for (let i = 0; i < hello.slotCount; i++) {
        const f = new PlayerFigure(i, i < this.halfN, false);
        this.figures.push(f);
        this.players.push(f.root);
        this.scene.add(f.root);

      }

      this.ring = new THREE.Mesh(
        new THREE.RingGeometry(0.55, 0.75, 32),
        new THREE.MeshBasicMaterial({ color: 0xffcc00, transparent: true,
                                      opacity: 0.9, depthWrite: false }));
      this.ring.rotation.x = -Math.PI / 2;
      this.ring.position.y = 0.02;
      this.ring.visible = false;
      this.scene.add(this.ring);

      // Ball: classic white with dark panels, a touch over regulation size
      // so it reads at broadcast distance; spins as it rolls.
      const c = document.createElement('canvas');
      c.width = 64; c.height = 32;
      const x = c.getContext('2d');
      x.fillStyle = '#fff'; x.fillRect(0, 0, 64, 32);
      x.fillStyle = '#222';
      for (let i = 0; i < 6; i++)
        x.fillRect(i * 11 + (i % 2) * 3, (i % 2) * 14 + 4, 6, 8);
      this.ballMesh = new THREE.Mesh(
        new THREE.SphereGeometry(0.22, 20, 14),
        new THREE.MeshStandardMaterial({ map: new THREE.CanvasTexture(c), roughness: 0.45 }));
      this.ballMesh.position.set(0, 0.22, 0);
      this.ballMesh.castShadow = true;
      this.scene.add(this.ballMesh);
    }

    pushSnapshot(snap) {
      const now = performance.now();
      this.lastSnapshotAt = now;
      const dt = 1000 / this.tickRate;
      const offset = now - snap.tick * dt;
      if (this.timeOffset === null || offset < this.timeOffset) {
        this.timeOffset = offset;       // fastest observed path wins
      } else {
        this.timeOffset += (offset - this.timeOffset) * 0.002; // drift
      }
      // Keeper flag (players[i].flags bit1, protocol 1.4+): keepers wear
      // their own kit.
      if (snap.players && this.figures.length) {
        snap.players.forEach((p, i) => {
          if (this.figures[i]) this.figures[i].setKeeper(!!(p.flags & 2));
        });
      }
      // A kick: the ball leaves its owner's feet (owner → nobody). Queue
      // the animation on the server timeline so it plays as the ball
      // visibly departs, not ~130 ms early.
      if (snap.ball) {
        const o = snap.ball.owner;
        if (this.lastOwner !== NO_OWNER && o === NO_OWNER)
          this.kicks.push({ tick: snap.tick - 1, slot: this.lastOwner });
        this.lastOwner = o;
      }
      this.buffer.push({ tick: snap.tick, snap });
      if (this.buffer.length > 90) this.buffer.splice(0, 30);
    }

    // Held players glow faint gold; the ACTIVE one glows bright.
    setMySlots(slots, activeSlot) {
      this.mySlots = slots;
      this.activeSlot = activeSlot;
      // Kit colours stay true (any gold glow tinted navy shirts yellow or
      // olive); the controlled player gets a gold ring at his feet,
      // FIFA-style.
      for (const f of this.figures) {
        f.setGlow(0);
      }
      if (this.ring) this.ring.visible = activeSlot !== null && activeSlot !== undefined;
    }

    screenToPitch(v) { return this.rig.screenToPitch(v); }

    // Lerp between the two snapshots bracketing the render TICK.
    frame() {
      const now = performance.now();
      const dt = this.lastFrameAt ? Math.min((now - this.lastFrameAt) / 1000, 0.1) : 0.016;
      this.lastFrameAt = now;
      const n = this.buffer.length;
      let ballPos = null, me = null;
      if (n >= 1 && this.timeOffset !== null) {
        const tdt = 1000 / this.tickRate;
        const renderTick = (now - this.timeOffset) / tdt - INTERP_DELAY_TICKS;
        let a = this.buffer[0], b = this.buffer[n - 1];
        for (let i = n - 1; i > 0; i--) {
          if (this.buffer[i - 1].tick <= renderTick) {
            a = this.buffer[i - 1]; b = this.buffer[i]; break;
          }
        }
        const span = Math.max(b.tick - a.tick, 1);
        const alpha = Math.min(Math.max((renderTick - a.tick) / span, 0), 1);
        while (this.kicks.length && this.kicks[0].tick <= renderTick) {
          const k = this.kicks.shift();
          if (this.figures[k.slot]) this.figures[k.slot].kick();
        }
        // Ball first: every figure looks at it.
        if (this.ballMesh && a.snap.ball && b.snap.ball) {
          const ba = a.snap.ball, bb = b.snap.ball;
          const x = ba.x + (bb.x - ba.x) * alpha;
          const y = ba.y + (bb.y - ba.y) * alpha;
          const z = ba.z + (bb.z - ba.z) * alpha;
          const m = this.ballMesh;
          // Roll: spin about the axis perpendicular to travel.
          const mx = x - m.position.x, mz = y - m.position.z;
          const d = Math.hypot(mx, mz);
          if (d > 1e-4 && d < 3) {
            const axis = new THREE.Vector3(mz / d, 0, -mx / d);
            m.rotateOnWorldAxis(axis, d / 0.22);
          }
          m.position.set(x, 0.22 + z, y);
          ballPos = { x, y, z };
        }
        const owner = b.snap.ball ? b.snap.ball.owner : NO_OWNER;
        const count = Math.min(this.figures.length, b.snap.players.length);
        for (let i = 0; i < count; i++) {
          const pa = a.snap.players[i], pb = b.snap.players[i];
          const x = pa.x + (pb.x - pa.x) * alpha;
          const y = pa.y + (pb.y - pa.y) * alpha;
          const vx = pa.vx + (pb.vx - pa.vx) * alpha;
          const vy = pa.vy + (pb.vy - pa.vy) * alpha;
          const f = this.figures[i];
          f.root.position.set(x, 0, y);
          f.update(dt, { vx, vy, flags: pb.flags, ball: ballPos,
                         hasBall: owner === i, me: { x, y } });
          if (i === this.activeSlot) {
            me = { x, y, team: i < this.halfN ? 0 : 1 };
            this.ring.position.x = x;
            this.ring.position.z = y;
          }
        }
      }
      this.rig.update(dt, { ball: ballPos, me, hx: this.hx, hy: this.hy });
      this.renderer.render(this.scene, this.camera);
    }

    // The scoring side celebrates (EVENT-driven, never inferred).
    celebrate(team) {
      for (const f of this.figures)
        if ((f.slot < this.halfN ? 0 : 1) === team) f.celebrate();
    }

    // GOAL flash: brief white wash + status pulse, triggered by EVENT
    // frames (never inferred client-side — the server is the authority).
    goalFlash() {
      const old = this.scene.background;
      this.scene.background = new THREE.Color(0xffcc00);
      setTimeout(() => { this.scene.background = old; }, 180);
      setTimeout(() => {
        this.scene.background = new THREE.Color(0xffffff);
        setTimeout(() => { this.scene.background = old; }, 120);
      }, 360);
    }

    // Returns the slot index under a click/tap, or null. Used to claim.
    pickSlot(clientX, clientY) {
      const ndc = new THREE.Vector2(
        (clientX / window.innerWidth) * 2 - 1,
        -(clientY / window.innerHeight) * 2 + 1);
      const ray = new THREE.Raycaster();
      ray.setFromCamera(ndc, this.camera);
      const hits = ray.intersectObjects(this.players, true);
      for (const h of hits) {
        let o = h.object;
        while (o && o.userData.slot === undefined) o = o.parent;
        if (o) return o.userData.slot;
      }
      return null;
    }
  }

  window.GameRenderer = GameRenderer;
})();
