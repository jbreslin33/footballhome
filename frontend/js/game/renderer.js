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
      this.rig = new CameraRig(this.camera, canvas);

      const sun = new THREE.DirectionalLight(0xffffff, 0.85);
      sun.position.set(30, 80, 20);
      this.scene.add(sun);
      this.scene.add(new THREE.HemisphereLight(0xdfe8ff, 0x2e5d2e, 0.55));

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

      // Grass with mowing stripes (sim x → three x, sim y → three z).
      const surround = new THREE.Mesh(
        new THREE.PlaneGeometry(hx * 2 + 24, hy * 2 + 24),
        new THREE.MeshLambertMaterial({ color: 0x2a6f2d }));
      surround.rotation.x = -Math.PI / 2;
      surround.position.y = -0.01;
      this.scene.add(surround);
      const stripes = 12, sw = (hx * 2) / stripes;
      for (let i = 0; i < stripes; i++) {
        const s = new THREE.Mesh(
          new THREE.PlaneGeometry(sw, hy * 2),
          new THREE.MeshLambertMaterial({ color: i % 2 ? 0x2f8a34 : 0x2a7a2f }));
        s.rotation.x = -Math.PI / 2;
        s.position.set(-hx + sw * (i + 0.5), 0, 0);
        this.scene.add(s);
      }

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
          this.scene.add(post);
        }
        const bar = new THREE.Mesh(
          new THREE.CylinderGeometry(0.06, 0.06, 7.44, 8), postMat);
        bar.rotation.x = Math.PI / 2;
        bar.position.set(gx, 2.44, 0);
        this.scene.add(bar);
        const net = new THREE.Mesh(
          new THREE.BoxGeometry(2, 2.44, 7.32, 4, 6, 14), netMat);
        net.position.set(gx + sign * 1, 1.22, 0);
        this.scene.add(net);
      }

      // Players: slots [0, n/2) = home, rest = away.
      this.halfN = Math.floor(hello.slotCount / 2);
      const shadowGeo = new THREE.CircleGeometry(0.45, 16);
      const shadowMat = new THREE.MeshBasicMaterial({
        color: 0x000000, transparent: true, opacity: 0.28, depthWrite: false });
      for (let i = 0; i < hello.slotCount; i++) {
        const f = new PlayerFigure(i, i < this.halfN, false);
        this.figures.push(f);
        this.players.push(f.root);
        this.scene.add(f.root);
        const sh = new THREE.Mesh(shadowGeo, shadowMat);
        sh.rotation.x = -Math.PI / 2;
        sh.position.y = 0.015;
        this.shadows.push(sh);
        this.scene.add(sh);
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
        new THREE.SphereGeometry(0.22, 16, 12),
        new THREE.MeshLambertMaterial({ map: new THREE.CanvasTexture(c) }));
      this.ballMesh.position.set(0, 0.22, 0);
      this.scene.add(this.ballMesh);
      this.ballShadow = new THREE.Mesh(
        new THREE.CircleGeometry(0.25, 16), shadowMat.clone());
      this.ballShadow.rotation.x = -Math.PI / 2;
      this.ballShadow.position.y = 0.016;
      this.scene.add(this.ballShadow);
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
        const count = Math.min(this.figures.length, b.snap.players.length);
        for (let i = 0; i < count; i++) {
          const pa = a.snap.players[i], pb = b.snap.players[i];
          const x = pa.x + (pb.x - pa.x) * alpha;
          const y = pa.y + (pb.y - pa.y) * alpha;
          const vx = pa.vx + (pb.vx - pa.vx) * alpha;
          const vy = pa.vy + (pb.vy - pa.vy) * alpha;
          const f = this.figures[i];
          f.root.position.set(x, 0, y);
          f.update(dt, vx, vy);
          this.shadows[i].position.x = x;
          this.shadows[i].position.z = y;
          if (i === this.activeSlot) {
            me = { x, y, team: i < this.halfN ? 0 : 1 };
            this.ring.position.x = x;
            this.ring.position.z = y;
          }
        }
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
          this.ballShadow.position.x = x;
          this.ballShadow.position.z = y;
          const s = 1 / (1 + z * 0.35);
          this.ballShadow.scale.set(s, s, s);
          this.ballShadow.material.opacity = 0.3 * s;
          ballPos = { x, y };
        }
      }
      this.rig.update(dt, { ball: ballPos, me, hx: this.hx, hy: this.hy });
      this.renderer.render(this.scene, this.camera);
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
