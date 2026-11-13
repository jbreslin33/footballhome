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

  // Graphics tier 1 (James 11/11 "how realistic can we get the mesh/graphics" → lighting first):
  // colour managed (sRGB in, linear light, sRGB out), filmic tone mapping, image-based light from
  // a generated sky, the sun's shadow box following the play. ?gfx=classic = the old flat look.
  const GFX_CLASSIC = /[?&]gfx=classic\b/.test(location.search);
  // three 0.160 (boot.js): hex colours are sRGB and get linearised by default; every
  // canvas-drawn texture in the game (grass, ball, numbers, labels, overlays) is sRGB too —
  // one place, all files. Classic turns colour management off, as r149 had it.
  if (GFX_CLASSIC) {
    THREE.ColorManagement.enabled = false;
  } else {
    const BaseCanvasTexture = THREE.CanvasTexture;
    THREE.CanvasTexture = class extends BaseCanvasTexture {
      constructor(...a) { super(...a); this.colorSpace = THREE.SRGBColorSpace; }
    };
  }
  // Lights: physically based since 0.155 — a legacy intensity × π gives the same light.
  const LEGACY = Math.PI;

  // The sky as a light source: a gradient dome (zenith, horizon haze, a dark grass-coloured
  // ground) with a bright disc where the sun is, prefiltered (PMREM) for every material's
  // ambient and reflections — what the flat hemisphere light can't give (rim light, glossy
  // ball and boots, shaded undersides). Built once, a few ms.
  function skyEnvironment(renderer, sunDir) {
    const sc = new THREE.Scene();
    const dome = new THREE.Mesh(new THREE.SphereGeometry(100, 48, 24), new THREE.ShaderMaterial({
      side: THREE.BackSide, depthWrite: false,
      uniforms: { sun: { value: sunDir.clone().normalize() } },
      vertexShader: 'varying vec3 vD; void main(){ vD = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); }',
      fragmentShader: [
        'uniform vec3 sun; varying vec3 vD;',
        'void main(){',
        '  float h = vD.y;',
        '  vec3 zen = vec3(0.16, 0.34, 0.70), hor = vec3(0.70, 0.80, 0.92), gnd = vec3(0.10, 0.16, 0.08);',
        '  vec3 c = h > 0.0 ? mix(hor, zen, pow(h, 0.5)) : mix(hor * 0.6, gnd, pow(-h, 0.35));',
        '  float d = max(dot(vD, sun), 0.0);',
        '  c += vec3(1.0, 0.92, 0.80) * (pow(d, 600.0) * 40.0 + pow(d, 12.0) * 0.6);',
        '  gl_FragColor = vec4(c, 1.0);',
        '}'].join('\n'),
    }));
    sc.add(dome);
    const pm = new THREE.PMREMGenerator(renderer);
    const env = pm.fromScene(sc, 0.02).texture;
    pm.dispose(); dome.geometry.dispose(); dome.material.dispose();
    return env;
  }

  const INTERP_DELAY_TICKS = 4;  // ~133 ms behind live at 30 Hz
  const NO_OWNER = 255;
  const BALL_R = 0.109;          // the engine's kBallRadius (core/Ball.hpp), a size 5

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
      const sun = new THREE.DirectionalLight(0xfff1dc, 1.15 * LEGACY);
      sun.position.set(-40, 70, 45);
      sun.castShadow = true;
      const mobile = matchMedia('(pointer: coarse)').matches;
      sun.shadow.mapSize.set(mobile ? 1024 : 2048, mobile ? 1024 : 2048);
      Object.assign(sun.shadow.camera, { left: -75, right: 75, top: 60, bottom: -60, near: 10, far: 200 });
      sun.shadow.bias = -0.0004;
      sun.shadow.normalBias = 0.03;
      this.scene.add(sun);
      this.sun = sun;   // view-menu.js switches its shadow
      this.sunOffset = sun.position.clone();
      this.scene.add(sun.target);
      if (GFX_CLASSIC) {
        this.renderer.outputColorSpace = THREE.LinearSRGBColorSpace;   // r149's default
        this.scene.add(new THREE.HemisphereLight(0xcfe0ff, 0x355e2f, 0.5 * LEGACY));
      } else {
        this.renderer.outputColorSpace = THREE.SRGBColorSpace;
        this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
        this.renderer.toneMappingExposure = 0.55;   // tuned by eye against ?gfx=classic, 11/11
        sun.intensity = 2.4 * LEGACY;   // ACES compresses: the sun carries the picture, the sky fills
        this.scene.environment = skyEnvironment(this.renderer, this.sunOffset);
        this.scene.add(new THREE.HemisphereLight(0xcfe0ff, 0x355e2f, 0.15 * LEGACY));
      }

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
      // At y 0, where the players' feet and the ball's underside are: at 0.05
      // everything stood 5 cm into the turf (James 11/7: "the ball is like in
      // ground"). The polygon offset keeps it over the site's grass (-0.05).
      pitch.position.y = 0;
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
      // The officials (G4.93, snapshot 1.16 tail): the referee and two
      // assistants with flags. Hidden until a snapshot carries them (an
      // older server sends none). Not in this.figures — not player slots.
      this.officials = [0, 1, 2].map((i) => {
        const f = new PlayerFigure(100 + i, true, false, { official: true, flag: i > 0 });
        f.root.visible = false;
        this.scene.add(f.root);
        return f;
      });

      this.ring = new THREE.Mesh(
        new THREE.RingGeometry(0.55, 0.75, 32),
        new THREE.MeshBasicMaterial({ color: 0xffcc00, transparent: true,
                                      opacity: 0.9, depthWrite: false }));
      this.ring.rotation.x = -Math.PI / 2;
      this.ring.position.y = 0.02;
      this.ring.visible = false;
      this.scene.add(this.ring);
      this.watchRing = this.ring.clone();
      this.watchRing.material = this.ring.material.clone();
      this.watchRing.material.color.set(0x00e5ff);
      this.watchRing.visible = false;
      this.scene.add(this.watchRing);
      this.watchSlot = null;

      // Ball: classic white with dark panels at the real size (radius
      // BALL_R = the engine's kBallRadius 0.109 m, a size 5); spins as it
      // rolls. It was drawn at 0.22, twice regulation (James 11/7: "too big").
      const c = document.createElement('canvas');
      c.width = 64; c.height = 32;
      const x = c.getContext('2d');
      x.fillStyle = '#fff'; x.fillRect(0, 0, 64, 32);
      x.fillStyle = '#222';
      for (let i = 0; i < 6; i++)
        x.fillRect(i * 11 + (i % 2) * 3, (i % 2) * 14 + 4, 6, 8);
      this.ballMesh = new THREE.Mesh(
        new THREE.SphereGeometry(BALL_R, 20, 14),
        new THREE.MeshStandardMaterial({ map: new THREE.CanvasTexture(c), roughness: 0.45 }));
      this.ballMesh.position.set(0, BALL_R, 0);
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
        // A first touch: nobody → a player (the same queue; armed the same way).
        if (this.lastOwner === NO_OWNER && o !== NO_OWNER && this.lastOwner !== undefined)
          this.kicks.push({ tick: snap.tick, slot: o, rx: true, z: snap.ball.z });
        // A dribble touch (G5.78: the carried ball rolls): his ball's velocity jumps while he keeps it.
        if (o !== NO_OWNER && o === this.lastOwner && this.lastBall) {
          const dt = Math.max(1, snap.tick - this.lastBall.tick);
          const vx = (snap.ball.x - this.lastBall.x) / dt, vy = (snap.ball.y - this.lastBall.y) / dt;
          if (this.lastBallV && Math.hypot(vx - this.lastBallV.x, vy - this.lastBallV.y) * (this.tickRate || 30) > 0.6)
            this.kicks.push({ tick: snap.tick - 1, slot: o, touch: true });
          this.lastBallV = { x: vx, y: vy };
        } else this.lastBallV = null;
        this.lastBall = { x: snap.ball.x, y: snap.ball.y, tick: snap.tick };
        this.lastOwner = o;
      }
      this.buffer.push({ tick: snap.tick, snap });
      if (this.buffer.length > 90) this.buffer.splice(0, 30);
      this.history.push({ tick: snap.tick, snap });
      if (this.history.length > 3600 + 300) this.history.splice(0, 300);
    }

    // Held players glow faint gold; the ACTIVE one glows bright.
    // The one player the camera watches (null = none). Watching claims
    // nothing: the AI keeps playing him.
    setWatchSlot(slot) {
      this.watchSlot = slot;
      if (this.rig) this.rig.watchYaw = undefined;
    }

    // How far behind live the picture runs, ticks. Watching (no player of ours under control) it runs
    // 11 ticks (~370 ms) behind, so a kick is known early enough for a real back-swing (~0.3 s); with a
    // man under control, the short delay (input feel first). 11/12.
    leadTicks() { return this.activeSlot === null || this.activeSlot === undefined ? 11 : INTERP_DELAY_TICKS; }

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
      if (!GFX_CLASSIC && this.sun) {
        // The shadow box follows the play and tightens with the camera: the same map over
        // ~60 m instead of the whole complex = shadows 2-3× sharper up close.
        const t = this.rig.target, half = Math.min(80, Math.max(30, cd * 0.9));
        this.sun.position.set(t.x + this.sunOffset.x, this.sunOffset.y, t.z + this.sunOffset.z);
        this.sun.target.position.set(t.x, 0, t.z);
        const sc = this.sun.shadow.camera;
        if (sc.right !== half) {
          Object.assign(sc, { left: -half, right: half, top: half, bottom: -half });
          sc.updateProjectionMatrix();
        }
      }
      const now = performance.now();
      const dt = this.lastFrameAt ? Math.min((now - this.lastFrameAt) / 1000, 0.1) : 0.016;
      let simDt = dt * this.speed;   // figures move in sim time
      this.lastFrameAt = now;
      const rp = this.replay;
      const buf = rp ? this.history : this.buffer;
      const n = buf.length;
      let ballPos = null, me = null, watch = null;
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
          const delay = Math.max(1.5, this.leadTicks() * this.speed);
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
        // Kicks are armed as soon as they are known (up to the interpolation
        // delay ahead), so the back-swing plays BEFORE the ball leaves and
        // the contact lands on it. Power = the ball's speed off the foot.
        while (!rp && this.kicks.length && this.kicks[0].tick <= renderTick + this.leadTicks()) {
          const k = this.kicks.shift();
          const f = this.figures[k.slot];
          if (!f) continue;
          const lead = Math.max(0, k.tick - renderTick) / (this.tickRate || 30);
          if (k.rx) { if (f.receive) f.receive(lead, k.z); continue; }
          if (k.touch) { if (!f.kk) f.kick(lead, 0, 0.3); continue; }   // a dribble touch: a small push
          let power = 0.5;
          const at = buf.find((e) => e.tick >= k.tick);
          const after = buf.filter((e) => e.tick > k.tick && e.tick <= k.tick + 3).pop();
          if (at && after && at.snap.ball && after.snap.ball) {
            const sp = Math.hypot(after.snap.ball.x - at.snap.ball.x, after.snap.ball.y - at.snap.ball.y,
                                  after.snap.ball.z - at.snap.ball.z) * (this.tickRate || 30) / (after.tick - at.tick);
            power = Math.min(1, Math.max(0, (sp - 6) / 22));   // 6 m/s tap … 28 m/s shot
          }
          // G5.79: the engine's kicking foot (players[i].flags bit5 = foot 1, his left) on the first
          // snapshot after the strike.
          const post = buf.find((e) => e.tick > k.tick);
          const pf = post && post.snap.players && post.snap.players[k.slot];
          f.kick(lead, power, undefined, pf ? ((pf.flags & 32) ? 1 : 0) : undefined);
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
            m.rotateOnWorldAxis(axis, d / BALL_R);
          }
          // The wire's z is the height of the ball's underside (the engine
          // floors it at 0), so its centre is BALL_R above that.
          m.position.set(x, BALL_R + Math.max(0, z), y);
          ballPos = { x, y, z };
        }
        // Officials: interpolated like the players; their velocity is the
        // snapshot-to-snapshot move (the wire carries no officials' velocity).
        if (this.officials && a.snap.officials && b.snap.officials) {
          const oc = Math.min(this.officials.length, a.snap.officials.length, b.snap.officials.length);
          const per = (this.tickRate || 30) / span;
          for (let i = 0; i < oc; i++) {
            const oa = a.snap.officials[i], ob = b.snap.officials[i];
            const x = oa.x + (ob.x - oa.x) * alpha;
            const y = oa.y + (ob.y - oa.y) * alpha;
            const f = this.officials[i];
            f.root.visible = true;
            f.root.position.set(x, 0, y);
            f.setFlag(ob.flags & 1);
            f.setSignal((ob.flags >> 1) & 7);   // G5.2: the call on a ball out
            f.update(simDt, { vx: (ob.x - oa.x) * per, vy: (ob.y - oa.y) * per, fx: ob.fx, fy: ob.fy,
                              flags: 0, ball: ballPos, hasBall: false, me: { x, y } });
          }
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
          // 2.3 feet: the later snapshot's plants, progress interpolated while the foot holds its state.
          let feet = null;
          if (pb.feet) {
            feet = pb.feet.map((fb, k) => {
              const fa = pa.feet && pa.feet[k];
              const prog = fa && fa.down === fb.down && fb.prog >= fa.prog ? fa.prog + (fb.prog - fa.prog) * alpha : fb.prog;
              return { down: fb.down, x: fb.x, y: fb.y, prog };
            });
          }
          f.update(simDt, { vx, vy, fx: pb.fx, fy: pb.fy, flags: pb.flags, ball: ballPos,
                         hasBall: owner === i, me: { x, y }, feet });
          if (owner === i) {
            this.carrierSlot = i;
            this.lastOwnerPos = { x, y, team: i < this.halfN ? 0 : 1, yaw: f.yaw };
          }
          if (i === this.watchSlot) {
            watch = { x, y, team: i < this.halfN ? 0 : 1, yaw: f.yaw };
            if (this.watchRing) {
              this.watchRing.position.x = x;
              this.watchRing.position.z = y;
            }
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
      this.rig.update(dt, { ball: ballPos, me, watch, hx: this.hx, hy: this.hy });
      if (this.field) this.field.update(this.camera, now / 1000);
      // First person: hide your own body (the camera is in his head).
      const firstSlot = this.watchSlot !== null && this.watchSlot !== undefined ? this.watchSlot
        : this.activeSlot !== null && this.activeSlot !== undefined ? this.activeSlot : this.carrierSlot;
      // showMatch false (non-GAME modes, client.js): the complex without
      // the match — no players, no ball.
      const showMatch = this.showMatch !== false;
      for (const f of this.figures)
        f.root.visible = showMatch && !(this.rig.mode === 'first' && f.slot === firstSlot);
      if (this.ballMesh) this.ballMesh.visible = showMatch;
      if (this.ring && !showMatch) this.ring.visible = false;
      if (this.watchRing) this.watchRing.visible = showMatch && this.watchSlot !== null && this.watchSlot !== undefined;
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

    setBrain(view) { this.brain = view; }   // { entries, legend, concepts?, show: Set }
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
          // G4.70: a call — a white line from the talker to who it's for.
          const talk = new THREE.Line(new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(), new THREE.Vector3()]),
                                      new THREE.LineDashedMaterial({ color: 0xffffff, dashSize: 0.3, gapSize: 0.3, depthTest: false, transparent: true }));
          go.renderOrder = act.renderOrder = dot.renderOrder = talk.renderOrder = 60;
          group.add(go, act, dot, talk);
          this.scene.add(group);
          part = this.brainParts[i] = { group, go, act, dot, talk, text: null, sprite: null };
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
        part.talk.visible = false;   // G5.23: no call system
        // Trainer step 3: out of possession his concept, in the board's words (blue);
        // otherwise the engine's decision (yellow).
        const concept = e.concept !== undefined && e.concept !== 255 && v.concepts ? v.concepts[e.concept] : null;
        const text = concept ? concept.title : (v.legend && v.legend[e.why]) || '?';
        if (text !== part.text) {
          if (part.sprite) { this.figures[i].root.remove(part.sprite); part.sprite.material.map.dispose(); part.sprite.material.dispose(); }
          const c = document.createElement('canvas');
          c.width = 256; c.height = 56;
          const x = c.getContext('2d');
          x.font = 'bold 28px system-ui, sans-serif';
          x.textAlign = 'center'; x.textBaseline = 'middle';
          const w = Math.min(250, x.measureText(text).width + 18);
          x.fillStyle = concept ? 'rgba(127,215,255,0.94)' : 'rgba(255,204,0,0.92)';
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
