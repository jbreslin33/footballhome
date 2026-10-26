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
// Sim speed (G4.61): at s× the server ticks s times as often, so a tick
// lasts 1000/(30·s) ms here, the timeline re-anchors on each change, the
// delay stays ~133 ms of wall clock (4·s ticks, never under 1.5), and the
// figures animate at s× — slow motion, the same football. Paused, the
// picture holds and only the camera moves.
// Replay (G4.62): every snapshot also goes into a 2-minute history; in
// replay the picture renders from it at the viewer's own tick — rewind,
// scrub, step, slow motion — while the live match carries on unseen.
// Viewer-side only: nothing is sent, so it can't disturb the match.

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

  // The pitch surface WITH its markings painted in (Laws of the Game, 12 cm
  // lines): real pitches are paint on grass, and separate line geometry
  // lost depth fights with the turf at range. Canvas spans the pitch plus
  // a 2 m apron; ~19 px per metre.
  function pitchTexture(hx, hy) {
    const PW = hx * 2 + 4, PH = hy * 2 + 4;
    const W = 2048, H = Math.round(2048 * PH / PW);
    const k = W / PW;
    const X = (x) => (x + hx + 2) * k, Y = (z) => (z + hy + 2) * k;
    const c = document.createElement('canvas');
    c.width = W; c.height = H;
    const g = c.getContext('2d');
    const stripes = 12;
    for (let i = 0; i < stripes; i++) {
      g.fillStyle = i % 2 ? '#2f8a2e' : '#277a27';
      g.fillRect(X(-hx + (2 * hx / stripes) * i), 0, (2 * hx / stripes) * k + 1, H);
    }
    g.fillStyle = '#277a27';
    g.fillRect(0, 0, X(-hx), H); g.fillRect(X(hx), 0, W - X(hx), H);
    const img = g.getImageData(0, 0, W, H);
    for (let p = 0; p < img.data.length; p += 4) {
      const n = (Math.random() - 0.5) * 22;
      img.data[p] += n * 0.6; img.data[p + 1] += n; img.data[p + 2] += n * 0.4;
    }
    g.putImageData(img, 0, 0);
    g.strokeStyle = 'rgba(250,250,245,0.95)';
    g.fillStyle = 'rgba(250,250,245,0.95)';
    g.lineWidth = 0.12 * k;
    const rect = (x0, z0, x1, z1) => g.strokeRect(X(x0), Y(z0), (x1 - x0) * k, (z1 - z0) * k);
    const arc = (x, z, r, a0, a1) => { g.beginPath(); g.arc(X(x), Y(z), r * k, a0, a1); g.stroke(); };
    const spot = (x, z) => { g.beginPath(); g.arc(X(x), Y(z), 0.15 * k, 0, Math.PI * 2); g.fill(); };
    rect(-hx, -hy, hx, hy);
    g.beginPath(); g.moveTo(X(0), Y(-hy)); g.lineTo(X(0), Y(hy)); g.stroke();
    arc(0, 0, 9.15, 0, Math.PI * 2);
    spot(0, 0);
    const a = Math.acos(5.5 / 9.15);
    for (const s of [-1, 1]) {
      const gx = s * hx;
      rect(Math.min(gx, gx - s * 16.5), -20.16, Math.max(gx, gx - s * 16.5), 20.16);
      rect(Math.min(gx, gx - s * 5.5), -9.16, Math.max(gx, gx - s * 5.5), 9.16);
      const sp = gx - s * 11;
      spot(sp, 0);
      if (s > 0) arc(sp, 0, 9.15, Math.PI - a, Math.PI + a);
      else arc(sp, 0, 9.15, -a, a);
      for (const cz of [-1, 1]) {
        const a0 = s > 0 ? (cz > 0 ? Math.PI : Math.PI / 2) : (cz > 0 ? -Math.PI / 2 : 0);
        arc(gx, cz * hy, 1, a0, a0 + Math.PI / 2);
      }
    }
    return new THREE.CanvasTexture(c);
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
      this.speed = 1;            // G4.61: sim speed (1 = live, 0 = paused)
      this.history = [];         // G4.62: [{tick, snap}], 2 min of sim time
      this.replay = null;        // G4.62: {tick, rate, playing} while replaying
      this.heldTick = null;
      this.timeOffset = null; // local ms ↔ tick-time ms estimate
      this.lastSnapshotAt = 0;
      this.lastFrameAt = 0;
      this.mySlots = new Set();
      this.activeSlot = null;
      this.kicks = [];        // [{tick, slot}] pending kick animations
      this.lastOwner = NO_OWNER;
      this.halfN = 11;

      this.scene = new THREE.Scene();
      this.scene.background = new THREE.Color(0x9cc3e6); // open daytime sky
      this.scene.fog = new THREE.Fog(0x9cc3e6, 220, 520);

      this.camera = new THREE.PerspectiveCamera(
        45, window.innerWidth / window.innerHeight, 0.5, 1400);
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
          points.map(([x, z]) => new THREE.Vector3(x, 0.09, z))), mat));
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
      const pitch = new THREE.Mesh(
        new THREE.PlaneGeometry(hx * 2 + 4, hy * 2 + 4),
        new THREE.MeshStandardMaterial({ map: pitchTexture(hx, hy), roughness: 1 }));
      pitch.material.map.anisotropy = this.renderer.capabilities.getMaxAnisotropy();
      pitch.rotation.x = -Math.PI / 2;
      pitch.position.y = 0.05;
      pitch.material.polygonOffset = true;
      pitch.material.polygonOffsetFactor = -4;
      pitch.material.polygonOffsetUnits = -16;
      pitch.renderOrder = 20;
      pitch.receiveShadow = true;
      this.scene.add(pitch);
      // The game pitch IS plan A's spot; the plan-A pill hides it whole.
      this.pitchParts = [pitch];
      this.field = LighthouseField.build(this.scene, hx, hy);

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
          this.pitchParts.push(post);
        }
        const bar = new THREE.Mesh(
          new THREE.CylinderGeometry(0.06, 0.06, 7.44, 8), postMat);
        bar.rotation.x = Math.PI / 2;
        bar.position.set(gx, 2.44, 0);
        bar.castShadow = true;
        this.scene.add(bar);
        this.pitchParts.push(bar);
        const net = new THREE.Mesh(
          new THREE.BoxGeometry(2, 2.44, 7.32, 4, 6, 14), netMat);
        net.position.set(gx + sign * 1, 1.22, 0);
        this.scene.add(net);
        this.pitchParts.push(net);
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

    // G4.61: the server's sim speed, % of real time (0 = paused).
    setSpeed(pct) {
      const s = pct / 100;
      if (s === this.speed) return;
      this.speed = s;
      this.timeOffset = null;   // re-anchor the tick timeline at the new rate
    }

    pushSnapshot(snap) {
      const now = performance.now();
      this.lastSnapshotAt = now;
      // Paused heartbeats repeat the frozen tick: keep the watchdog fed,
      // the timeline untouched.
      const last = this.buffer.length ? this.buffer[this.buffer.length - 1].tick : -1;
      if (snap.tick === last) return;
      const dt = 1000 / (this.tickRate * (this.speed || 1));
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
      this.history.push({ tick: snap.tick, snap });
      if (this.history.length > 3600 + 300) this.history.splice(0, 300);
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
      // Fog and the far plane follow a far-out camera, so zooming out shows
      // the complex instead of sky (defaults unchanged up close).
      const cd = this.rig.cur.dist;
      const fogNear = Math.max(220, cd * 1.3), fogFar = Math.max(520, cd * 3), far = Math.max(1400, cd * 3.5);
      if (this.scene.fog.near !== fogNear) { this.scene.fog.near = fogNear; this.scene.fog.far = fogFar; }
      if (this.camera.far !== far) { this.camera.far = far; this.camera.updateProjectionMatrix(); }
      const now = performance.now();
      const dt = this.lastFrameAt ? Math.min((now - this.lastFrameAt) / 1000, 0.1) : 0.016;
      let simDt = dt * this.speed;   // figures move in sim time
      this.lastFrameAt = now;
      const rp = this.replay;
      const buf = rp ? this.history : this.buffer;
      const n = buf.length;
      let ballPos = null, me = null;
      if (n >= 1 && (rp || this.timeOffset !== null)) {
        let renderTick;
        if (rp) {
          // Replay: the viewer's own clock over the history.
          if (rp.playing) rp.tick += dt * this.tickRate * rp.rate;
          const first = buf[0].tick, last = buf[n - 1].tick;
          if (rp.tick < first) rp.tick = first;
          if (rp.tick >= last) { rp.tick = last; rp.playing = false; }
          renderTick = rp.tick;
          simDt = rp.playing ? dt * rp.rate : 0;
        } else {
          const tdt = 1000 / (this.tickRate * (this.speed || 1));
          const delay = Math.max(1.5, INTERP_DELAY_TICKS * this.speed);
          renderTick = (now - this.timeOffset) / tdt - delay;
          // Paused: hold the last rendered tick (it would otherwise run on).
          if (this.speed === 0 && this.heldTick !== null) renderTick = this.heldTick;
          else if (this.speed === 0) this.heldTick = renderTick;
          else this.heldTick = null;
        }
        this.renderTick = renderTick;
        // The bracketing pair (binary search: the history is 3,600 long).
        let lo = 0, hi = n - 1;
        while (hi - lo > 1) {
          const mid = (lo + hi) >> 1;
          if (buf[mid].tick <= renderTick) lo = mid; else hi = mid;
        }
        let a = buf[lo], b = buf[hi];
        if (renderTick <= a.tick) b = a;
        const span = Math.max(b.tick - a.tick, 1);
        const alpha = Math.min(Math.max((renderTick - a.tick) / span, 0), 1);
        while (!rp && this.kicks.length && this.kicks[0].tick <= renderTick) {
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
          f.update(simDt, { vx, vy, fx: pb.fx, fy: pb.fy, flags: pb.flags, ball: ballPos,
                         hasBall: owner === i, me: { x, y } });
          if (owner === i) {
            this.carrierSlot = i;
            this.lastOwnerPos = { x, y, team: i < this.halfN ? 0 : 1, yaw: f.yaw };
          }
          if (i === this.activeSlot) {
            me = { x, y, team: i < this.halfN ? 0 : 1, yaw: f.yaw };
            this.ring.position.x = x;
            this.ring.position.z = y;
          }
        }
      }
      // No controlled player: "the man" is whoever has the ball.
      if (!me && this.lastOwnerPos) me = this.lastOwnerPos;
      this.rig.update(dt, { ball: ballPos, me, hx: this.hx, hy: this.hy });
      if (this.field) this.field.update(this.camera, now / 1000);
      // First person: hide your own body (the camera is in his head).
      const firstSlot = this.activeSlot !== null && this.activeSlot !== undefined
        ? this.activeSlot : this.carrierSlot;
      // showMatch false (non-GAME modes, client.js): the complex without
      // the match — no players, no ball.
      const showMatch = this.showMatch !== false;
      for (const f of this.figures)
        f.root.visible = showMatch && !(this.rig.mode === 'first' && f.slot === firstSlot);
      if (this.ballMesh) this.ballMesh.visible = showMatch;
      if (this.ring && !showMatch) this.ring.visible = false;
      this.drawBrain();
      this.renderer.render(this.scene, this.camera);
    }

    // ── Brain overlay (G4.41, after [Buckland]'s Simple Soccer debug view):
    // for each shown player a label of what he decided, a line to where
    // he's going and a dashed line to the man he's acting on. ──
    // G4.62 replay: start `ticksBack` before the newest snapshot, paused;
    // stopReplay() goes back to live.
    startReplay(ticksBack) {
      const h = this.history;
      if (!h.length) return;
      const last = h[h.length - 1].tick;
      this.replay = { tick: Math.max(h[0].tick, last - ticksBack), rate: 0.5, playing: false };
    }
    stopReplay() {
      this.replay = null;
      this.kicks = this.kicks.filter((k) => k.tick > (this.renderTick || 0));
    }
    historySpan() {
      const h = this.history;
      return h.length ? { first: h[0].tick, last: h[h.length - 1].tick } : null;
    }

    setBrain(view) { this.brain = view; }   // { entries, legend, show: Set }
    drawBrain() {
      const v = this.brain;
      this.brainParts = this.brainParts || [];
      const n = this.figures.length;
      for (let i = 0; i < n; i++) {
        const show = v && v.show && v.show.has(i) && v.entries && v.entries[i] && this.showMatch !== false;
        let part = this.brainParts[i];
        if (!show) { if (part) part.group.visible = false; continue; }
        if (!part) {
          const group = new THREE.Group();
          const home = i < this.halfN;
          const col = home ? 0x2b7bff : 0xff3355;
          const go = new THREE.Line(new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(), new THREE.Vector3()]),
                                    new THREE.LineBasicMaterial({ color: col, depthTest: false, transparent: true, opacity: 0.9 }));
          const act = new THREE.Line(new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(), new THREE.Vector3()]),
                                     new THREE.LineDashedMaterial({ color: 0xffcc00, dashSize: 0.6, gapSize: 0.4, depthTest: false, transparent: true }));
          const dot = new THREE.Mesh(new THREE.RingGeometry(0.25, 0.4, 20), new THREE.MeshBasicMaterial({ color: col, depthTest: false, side: THREE.DoubleSide }));
          dot.rotation.x = -Math.PI / 2;
          go.renderOrder = act.renderOrder = dot.renderOrder = 60;
          group.add(go, act, dot);
          this.scene.add(group);
          part = this.brainParts[i] = { group, go, act, dot, text: null, sprite: null };
        }
        part.group.visible = true;
        const e = v.entries[i];
        const p = this.figures[i].root.position;
        const set = (line, a, b) => {
          const pos = line.geometry.attributes.position;
          pos.setXYZ(0, a.x, 0.08, a.z); pos.setXYZ(1, b.x, 0.08, b.z); pos.needsUpdate = true;
          line.geometry.computeBoundingSphere();
        };
        set(part.go, p, { x: e.tx, z: e.ty });
        part.dot.position.set(e.tx, 0.09, e.ty);
        const other = e.other !== 255 && this.figures[e.other] ? this.figures[e.other].root.position : null;
        part.act.visible = !!other;
        if (other) { set(part.act, p, other); part.act.computeLineDistances(); }
        let text = (v.legend && v.legend[e.why]) || '?';
        if (e.rung) text += ' · rung ' + e.rung;
        if (text !== part.text) {
          if (part.sprite) { this.figures[i].root.remove(part.sprite); part.sprite.material.map.dispose(); part.sprite.material.dispose(); }
          const c = document.createElement('canvas');
          c.width = 256; c.height = 56;
          const x = c.getContext('2d');
          x.font = 'bold 28px system-ui, sans-serif';
          x.textAlign = 'center'; x.textBaseline = 'middle';
          const w = Math.min(250, x.measureText(text).width + 18);
          x.fillStyle = 'rgba(255,204,0,0.92)';
          x.fillRect(128 - w / 2, 8, w, 40);
          x.fillStyle = '#10161f';
          x.fillText(text, 128, 29);
          const sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(c), depthTest: false, transparent: true }));
          sp.scale.set(1.9, 0.42, 1);
          sp.position.y = 2.85;
          sp.renderOrder = 71;
          this.figures[i].root.add(sp);
          part.sprite = sp; part.text = text;
        }
        if (part.sprite) part.sprite.visible = true;
      }
      if (!v || !v.show) for (const part of this.brainParts) if (part && part.sprite) part.sprite.visible = false;
      for (let i = 0; i < this.brainParts.length; i++) {
        const part = this.brainParts[i];
        if (part && part.sprite && !(v && v.show && v.show.has(i))) part.sprite.visible = false;
      }
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
