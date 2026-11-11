// frontend/js/game/players.js
//
// Humanoid player figures + procedural animation (pure dressing: the
// server is the authority; nothing here touches gameplay). A jointed rig
// built from capsules — pelvis, torso, neck/head, hips/knees/ankles,
// shoulders/elbows — animated in LAYERS over the gait:
//   locomotion (James 11/10 "more realistic player animations"): a GAIT
//     model, not a sine on the joints. Each foot follows a stance/swing
//     path in the body frame and a two-bone IK solves hip + knee, so a
//     planted foot moves back at exactly the body's speed (no skating) and
//     the knee bend comes out of where the foot is. Timing from running /
//     walking biomechanics: contact length ~constant and swing time ~0.5 →
//     0.34 s as speed rises [Weyand 2000]; duty factor walk 0.62, jog ~0.39,
//     sprint ~0.22, the COM low at mid-stance running and high walking,
//     heel recovery under the buttock at speed [Novacheck 1998]. The body
//     leans along its real horizontal acceleration (atan a/g: into turns,
//     forward speeding up, back braking) — FH original.
//   → look (head + chest track the ball)
//   → overlays, each with an eased weight so nothing snaps:
//     kick · first touch · slide tackle · stumble · keeper dive · header
//     jump · celebrate (kick / touch / dive / header are timelines)
// Inputs are all on the wire: interpolated velocity, snapshot flags
// (keeper, down-in-a-tackle, dispossessed), ball position and owner.
// Model space faces +z; three y is up.

(function () {
  'use strict';

  const KIT = {
    home:   { shirt: 0x14326e, trim: 0xffcc00, shorts: 0xf4f6fb, socks: 0x14326e, boots: 0x111111 },
    away:   { shirt: 0xeef1f6, trim: 0x14326e, shorts: 0x14326e, socks: 0xeef1f6, boots: 0xc8102e },
    homeGk: { shirt: 0x2e9e44, trim: 0x111111, shorts: 0x111111, socks: 0x2e9e44, boots: 0x111111 },
    awayGk: { shirt: 0xff8a1f, trim: 0x111111, shorts: 0x111111, socks: 0xff8a1f, boots: 0x111111 },
    // G4.93: the match officials — black with yellow trim, no number.
    official: { shirt: 0x111111, trim: 0xffd400, shorts: 0x111111, socks: 0x111111, boots: 0x111111 },
  };
  const SKIN = [0xf1c27d, 0xe0ac69, 0xc68642, 0x8d5524, 0x5c3a1e, 0xffdbac, 0xa1665e];
  const HAIR = [0x2b1b10, 0x111111, 0x6b4423, 0xb8860b, 0x3d2817, 0x8a8a8a];
  const TAU = Math.PI * 2;

  const geo = {};  // shared geometries — 22 figures, one set of buffers
  function g(name, make) { return geo[name] || (geo[name] = make()); }
  const matCache = {};
  function mat(color, rough) {
    const k = color + ':' + (rough || 0.8);
    return matCache[k] || (matCache[k] = new THREE.MeshStandardMaterial({
      color, roughness: rough || 0.8, metalness: 0 }));
  }
  function mesh(geometry, material, y) {
    const m = new THREE.Mesh(geometry, material);
    m.castShadow = true;
    if (y !== undefined) m.position.y = y;
    return m;
  }
  // Capsule along y, centred at its middle.
  function cap(r, len, color, y) {
    return mesh(g(`c${r},${len}`, () => new THREE.CapsuleGeometry(r, len, 4, 10)),
                mat(color), y);
  }
  const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
  const ease = (cur, want, rate, dt) => cur + (want - cur) * Math.min(1, dt * rate);
  const smooth = (u) => { u = clamp(u, 0, 1); return u * u * (3 - 2 * u); };
  function wrap(a) { return ((a + Math.PI) % TAU + TAU) % TAU - Math.PI; }

  function numberDecal(n, kit) {
    const c = document.createElement('canvas');
    c.width = 64; c.height = 64;
    const x = c.getContext('2d');
    x.fillStyle = '#' + kit.trim.toString(16).padStart(6, '0');
    x.font = 'bold 44px system-ui, sans-serif';
    x.textAlign = 'center'; x.textBaseline = 'middle';
    x.fillText(String(n), 32, 35);
    const m = new THREE.Mesh(g('plate', () => new THREE.PlaneGeometry(0.26, 0.26)),
      new THREE.MeshBasicMaterial({ map: new THREE.CanvasTexture(c), transparent: true }));
    m.rotation.y = Math.PI;      // faces −z: the back
    m.position.set(0, 0.04, -0.125);
    return m;
  }

  class PlayerFigure {
    // opts.official (G4.93): a referee / assistant — his own kit, no number;
    // opts.flag: an assistant, carrying the flag he raises (setFlag).
    constructor(slot, home, keeper, opts) {
      this.slot = slot;
      this.home = home;
      this.official = !!(opts && opts.official);
      this.carriesFlag = !!(opts && opts.flag);
      this.flagUp = false;
      this.root = new THREE.Group();      // ground position + facing (yaw)
      this.root.userData.slot = slot;
      this.yaw = home ? Math.PI / 2 : -Math.PI / 2;  // face the opponent goal
      this.yawRate = 0;
      this.phase = (slot * 0.37) % 1;      // de-sync the squad's strides
      this.speed = 0;
      this.kickT = 0;
      this.celebrateT = 0;
      this.w = { slide: 0, stumble: 0, dribble: 0, cele: 0 };
      this.diveSide = 1;
      this.look = { yaw: 0, pitch: 0 };
      // Proportions (bodies.js gives a skinned body its own): thigh, shin, standing pelvis height.
      this.legA = 0.42; this.legB = 0.40; this.pelvisH = 0.95;
      this.build(home, keeper);
    }

    build(home, keeper) {
      this.buildBody(home, keeper);
      if (this.tagName) this.attachTag();   // build clears root; keep the name tag
    }

    buildBody(home, keeper) {
      const kit = this.official ? KIT.official : KIT[(home ? 'home' : 'away') + (keeper ? 'Gk' : '')];
      this.kit = kit;
      this.keeper = keeper;
      const skin = SKIN[(this.slot * 7) % SKIN.length];
      const hair = HAIR[(this.slot * 5) % HAIR.length];
      this.skinHex = skin; this.hairHex = hair;   // bodies.js tints the skinned body with them
      while (this.root.children.length) this.root.remove(this.root.children[0]);

      // pelvis: the rig's hub (lean, bob, slide drop all act here)
      const pelvis = new THREE.Group();
      pelvis.position.y = this.pelvisH;
      this.root.add(pelvis);
      this.pelvis = pelvis;
      const shorts = mesh(g('shorts', () => new THREE.CylinderGeometry(0.17, 0.19, 0.22, 12)),
                          mat(kit.shorts), -0.02);
      shorts.scale.z = 0.8;
      pelvis.add(shorts);

      // chest: twists toward the ball, carries arms/neck/head
      const chest = new THREE.Group();
      chest.position.y = 0.08;
      pelvis.add(chest);
      this.chest = chest;
      const torso = cap(0.16, 0.3, kit.shirt, 0.27);
      torso.scale.set(1.2, 1, 0.72);
      const collar = mesh(g('collar', () => new THREE.TorusGeometry(0.07, 0.022, 6, 14)),
                          mat(kit.trim), 0.52);
      collar.rotation.x = Math.PI / 2;
      chest.add(torso, collar);
      if (!this.official) {
        const plate = numberDecal(this.number || this.slot % 11 + 1, kit);
        plate.position.y = 0.3;
        chest.add(plate);
      }

      const neck = new THREE.Group();
      neck.position.y = 0.55;
      chest.add(neck);
      this.neck = neck;
      neck.add(cap(0.045, 0.06, skin, 0.04));
      const head = mesh(g('head', () => new THREE.SphereGeometry(0.115, 16, 12)),
                        mat(skin), 0.17);
      head.scale.set(0.92, 1.05, 1);
      neck.add(head);
      // Hair: three cuts by slot — cropped, full, buzz-with-top.
      const cut = this.slot % 3;
      const hairM = mat(hair, 0.95);
      const hairCap = mesh(g('hair' + cut, () =>
        new THREE.SphereGeometry(0.122, 14, 8, 0, TAU, 0, cut === 1 ? Math.PI * 0.62 : Math.PI * 0.45)),
        hairM, 0.18);
      hairCap.scale.set(0.95, cut === 2 ? 1.15 : 1.05, 1.02);
      neck.add(hairCap);

      // Arms: shoulder → upper (sleeve over skin) → elbow → forearm → hand.
      this.arms = [-1, 1].map((side) => {
        const sh = new THREE.Group();
        sh.position.set(side * 0.235, 0.46, 0);
        chest.add(sh);
        const sleeve = mesh(g('sleeve', () => new THREE.CylinderGeometry(0.062, 0.055, 0.16, 10)),
                            mat(kit.shirt), -0.07);
        const upper = cap(0.047, 0.18, skin, -0.15);
        const elbow = new THREE.Group();
        elbow.position.y = -0.27;
        const fore = cap(0.042, 0.18, skin, -0.12);
        const hand = mesh(g('hand', () => new THREE.SphereGeometry(0.048, 8, 6)),
                          mat(keeper ? 0xf2f2f2 : skin), -0.26);
        if (keeper) hand.scale.set(1.4, 1.4, 1.2);
        elbow.add(fore, hand);
        // The assistant's flag in his right hand (G4.93): a stick and a
        // yellow cloth with a red band, held down until he raises it.
        if (this.carriesFlag && side === 1) {
          const stick = mesh(g('flagstick', () => new THREE.CylinderGeometry(0.012, 0.012, 0.5, 6)),
                             mat(0x222222), -0.3);
          const cloth = new THREE.Mesh(g('flagcloth', () => new THREE.PlaneGeometry(0.3, 0.22)),
            new THREE.MeshBasicMaterial({ color: 0xffd400, side: THREE.DoubleSide }));
          cloth.position.set(0, -0.45, 0.15);
          cloth.rotation.y = Math.PI / 2;
          const band = new THREE.Mesh(g('flagband', () => new THREE.PlaneGeometry(0.3, 0.07)),
            new THREE.MeshBasicMaterial({ color: 0xd2232a, side: THREE.DoubleSide }));
          band.position.set(0.001, -0.42, 0.15);
          band.rotation.y = Math.PI / 2;
          elbow.add(stick, cloth, band);
        }
        sh.add(upper, sleeve, elbow);
        return { sh, elbow, side };
      });

      // Legs: hip → thigh (shorts leg over skin) → knee → shin (sock with
      // a trim band) → ankle → boot.
      this.legs = [-1, 1].map((side) => {
        const hip = new THREE.Group();
        hip.rotation.order = 'YZX';   // Ry·Rz·Rx: turn the leg, tilt its plane, flex in it (the IK)
        hip.position.set(side * 0.1, -0.06, 0);
        pelvis.add(hip);
        const thigh = cap(0.074, 0.28, skin, -0.21);
        const leg = mesh(g('shortleg', () => new THREE.CylinderGeometry(0.09, 0.085, 0.14, 10)),
                         mat(kit.shorts), -0.06);
        const knee = new THREE.Group();
        knee.position.y = -this.legA;
        const shin = cap(0.06, 0.28, kit.socks, -0.2);
        const band = mesh(g('band', () => new THREE.CylinderGeometry(0.066, 0.066, 0.04, 10)),
                          mat(kit.trim), -0.06);
        const ankle = new THREE.Group();
        ankle.position.y = -this.legB;
        const boot = mesh(g('boot', () => new THREE.CapsuleGeometry(0.05, 0.14, 3, 8)),
                          mat(kit.boots, 0.5), -0.03);
        boot.rotation.x = Math.PI / 2;
        boot.position.z = 0.05;
        ankle.add(boot);
        knee.add(shin, band, ankle);
        hip.add(thigh, leg, knee);
        return { hip, knee, ankle };
      });
    }

    // ── the gait (see the header): sets pelvis height/lean/yaw and solves
    // both legs by IK. Leaves this.moveAmt, runAmt, halfStride, leg.along.
    gait(dt, vx, vy, speed, W) {
      const s = this.speed;
      const m = smooth((s - 0.15) / 0.6);            // standing → moving
      const r = smooth((s - 1.9) / 0.7);             // walk → run, ~2.0-2.6 m/s
      const dribble = W.dribble;
      // Stride period and duty factor. Walk: stride 0.75 + 0.55 v m.
      // Run: contact length ~0.95 m (leg 0.9 m), swing 0.50 s at 3 m/s →
      // 0.34 s at 13 m/s [Weyand 2000]. 5 m/s: 1.5 strides/s, duty 0.29.
      const vs = Math.max(s, 0.3);
      const Tw = Math.min(1.4, (0.75 + 0.55 * vs) / vs), dw = 0.62;
      const tc = 0.95 * (1 - 0.15 * dribble) / Math.max(s, 1.6);
      const tsw = clamp(0.5 - 0.016 * (s - 3), 0.34, 0.5) * (1 - 0.12 * dribble);
      const Tr = tc + tsw, dr = tc / Tr;
      // Turning on the spot: little steps round (a planted foot keeps its
      // place and its toes' direction in the world while the body turns).
      const dyaw = wrap(this.yaw - (this.gYaw ?? this.yaw));
      this.gYaw = this.yaw;
      const turn = smooth((Math.abs(this.yawRate) - 0.7) / 1.5) * (1 - m);
      this.turnAmt = ease(this.turnAmt || 0, turn, 8, dt);
      const ta = this.turnAmt;
      const T0 = Tw + (Tr - Tw) * r, duty = dw + (dr - dw) * r;
      const T = T0 + (0.62 - T0) * ta;
      const ph0 = this.phase;
      this.phase = (this.phase + dt / T) % 1;
      if (this.phase < ph0) this.strides = (this.strides || 0) + 1;
      // Ankle travel in stance = contact length less the heel-to-toe roll.
      const contact = s * duty * T;
      const Ls = Math.max(0, contact - (0.25 - 0.13 * r)) * m;
      const centre = (0.02 - 0.1 * r) * m;           // running lands ahead, leaves well behind
      this.halfStride = Ls / 2;
      // Travel direction in the body frame (backpedal / side-step step that way).
      const rel = speed > 0.3 ? wrap(Math.atan2(vx, vy) - this.yaw) : 0;
      this.fwd = ease(this.fwd ?? 1, Math.cos(rel), 10, dt);   // eased as
      this.lat = ease(this.lat ?? 0, Math.sin(rel), 10, dt);   // components: no wrap
      const dz = this.fwd, dx = this.lat;
      // Swing height: walking toe clearance; running the heel comes up
      // behind toward the buttock, more the faster [Novacheck 1998].
      const lift = Math.max((0.07 + r * clamp(0.1 + 0.075 * (s - 2.5), 0, 0.5)) * m, 0.07 * ta);
      // Pelvis: COM high at mid-stance walking, low running; ±2 / ±3.5 cm.
      const stepPh = (this.phase * 2) % 1;
      const osc = Math.cos(TAU * (stepPh - duty / 2));
      const ready = this.readyAmt || 0;
      let py = this.pelvisH - 0.02 * m - 0.025 * r + m * (0.018 * (1 - r) * osc - 0.035 * r * osc) - 0.05 * ready * (1 - m);
      // Lean along the horizontal acceleration (body frame), so the ground
      // force goes through the body: into turns, forward accelerating.
      const ax0 = (vx - (this.pvx ?? vx)) / Math.max(dt, 1e-3), ay0 = (vy - (this.pvy ?? vy)) / Math.max(dt, 1e-3);
      this.pvx = vx; this.pvy = vy;
      this.awx = ease(this.awx || 0, clamp(ax0, -15, 15), 5, dt);
      this.awy = ease(this.awy || 0, clamp(ay0, -15, 15), 5, dt);
      const cy = Math.cos(this.yaw), sy = Math.sin(this.yaw);
      const aLat = this.awx * cy - this.awy * sy, aFwd = this.awx * sy + this.awy * cy;
      const pitch = 0.04 * m + 0.08 * r + clamp(Math.atan(aFwd / 9.81) * 0.8, -0.3, 0.35);
      const roll = -clamp(Math.atan(aLat / 9.81) * 0.7, -0.3, 0.3);
      // Braking hard: shorter, flexed steps — the hips sit down into it.
      py -= 0.06 * smooth((-aFwd - 2) / 4) * m;
      // Hips turn with the forward leg (±~6°); the chest counters (update()).
      const L = this.legs;
      const feet = [0, 1].map((i) => {
        const side = i === 0 ? -1 : 1;
        const ps = (this.phase + i * 0.5) % 1;
        let along, h, pitchF;
        if (ps < duty) {                             // stance: moves back at body speed
          const u = ps / duty;
          along = centre + Ls / 2 - u * Ls; h = 0;
          // walk: heel strike toe-up, flat, heel rise; run: flat, toe-off push
          pitchF = m * (u < 0.15 ? -0.25 * (1 - r) * (1 - u / 0.15)
                      : u > 0.6 ? (0.45 + 0.2 * r) * smooth((u - 0.6) / 0.4) : 0);
          h = 0.12 * Math.sin(Math.max(0, pitchF));
        } else {                                     // swing: up and through
          const u = (ps - duty) / (1 - duty);
          const late = 0.12 * r;                     // running: the foot stays back while the heel rises
          along = centre - Ls / 2 + Ls * smooth((u - late) / (1 - late));
          // Walking: a low arc. Running: the heel peaks early (recovery under
          // the buttock) and the foot drops under the knee as the shin swings
          // through — never a straight leg reaching out in the air.
          const hw = Math.sin(Math.PI * u);
          const hr = smooth(u / 0.35) * (1 - smooth((u - 0.35) / 0.6));
          h = lift * (hw + (hr - hw) * r);
          pitchF = m * ((0.55 + 0.2 * r) * (1 - smooth(u / 0.45)) - 0.12 * Math.sin(Math.PI * u) - 0.25 * (1 - r) * smooth((u - 0.8) / 0.2));
        }
        // Dribbling: every other stride the ball-side foot pushes the ball on
        // with the laces — a longer, toe-down reach at the end of its swing.
        if (dribble > 0.05 && ps >= duty && i === (this.dribbleLeg || 0) && (this.strides || 0) % 2 === 0) {
          const u = (ps - duty) / (1 - duty);
          if (u > 0.5) {
            const k = Math.sin(Math.PI * (u - 0.5) / 0.5) * dribble * m;
            along += 0.14 * k; h += 0.05 * k; pitchF += 0.45 * k;
          }
        }
        // The foot's twist off the body: planted, it holds still in the world
        // as the body turns (−dyaw); in the air it swings back square.
        const leg = L[i];
        if (ps < duty) leg.tw = (leg.tw || 0) - dyaw;
        else {
          const left = (1 - (ps - duty) / (1 - duty)) * (1 - duty) * T;
          leg.tw = (leg.tw || 0) * (1 - Math.min(1, dt / Math.max(left, dt)));
        }
        leg.tw = clamp(leg.tw, -0.9, 0.9);
        const base = side * (0.11 - 0.04 * r + 0.06 * Math.abs(dx) * m);
        leg.along = along - centre;
        const fx = base + dx * along, fz = dz * along, ct = Math.cos(leg.tw), st = Math.sin(leg.tw);
        return { x: fx * ct + fz * st, z: -fx * st + fz * ct, y: h + 0.085, pitchF };
      });
      // The engine's feet (2.3 wire, G5.77): when the snapshot carries them, each leg goes where
      // the engine put that foot — a planted foot stays on its spot in the world, a foot in the
      // air travels from where it left the ground to where the engine says it lands. The
      // procedural gait above stays as the fallback (officials, older servers).
      const WF = this.wireFeet;
      if (WF && this.me) {
        const cy = Math.cos(this.yaw), sy = Math.sin(this.yaw);
        const toLocal = (wx, wy) => { const ex = wx - this.me.x, ez = wy - this.me.y; return { x: ex * cy - ez * sy, z: ex * sy + ez * cy }; };
        this.liftFrom = this.liftFrom || [null, null];
        let downU = -1;
        for (let i = 0; i < 2; i++) {
          const ft = WF[i], leg = L[i];
          let wx, wy, h, pitchF;
          if (ft.down) {
            this.liftFrom[i] = { x: ft.x, y: ft.y };
            wx = ft.x; wy = ft.y;
            const u = ft.prog;
            pitchF = m * (u < 0.15 ? -0.25 * (1 - r) * (1 - u / 0.15) : u > 0.6 ? (0.45 + 0.2 * r) * smooth((u - 0.6) / 0.4) : 0);
            h = 0.12 * Math.sin(Math.max(0, pitchF));
            downU = Math.max(downU, 1 - Math.abs(u - 0.5) * 2);
          } else {
            const u = ft.prog, from = this.liftFrom[i] || { x: ft.x, y: ft.y };
            const late = 0.12 * r, k = smooth((u - late) / (1 - late));
            wx = from.x + (ft.x - from.x) * k; wy = from.y + (ft.y - from.y) * k;
            const hw = Math.sin(Math.PI * u), hr = smooth(u / 0.35) * (1 - smooth((u - 0.35) / 0.6));
            const run = Math.hypot(ft.x - from.x, ft.y - from.y);   // a step in place barely lifts
            h = Math.min(lift + 0.03, 0.04 + run * 0.4) * (hw + (hr - hw) * r);
            pitchF = m * ((0.55 + 0.2 * r) * (1 - smooth(u / 0.45)) - 0.12 * Math.sin(Math.PI * u) - 0.25 * (1 - r) * smooth((u - 0.8) / 0.2));
          }
          const lp = toLocal(wx, wy);
          feet[i] = { x: lp.x, z: lp.z, y: h + 0.085, pitchF };
          leg.along = lp.z * dz + lp.x * dx;
          leg.tw = 0;
        }
        // COM low at mid-stance running / high walking; in flight (no foot down) it rides high.
        const oscW = downU >= 0 ? downU * 2 - 1 : -0.8;
        py = this.pelvisH - 0.02 * m - 0.025 * r + m * (0.018 * (1 - r) * oscW - 0.035 * r * oscW) - 0.05 * ready * (1 - m);
      }
      // Pelvis yaw follows the forward foot of the right leg (side -1).
      const yawP = 0.1 * m * clamp(L[0].along / Math.max(0.12, Ls / 2 + 1e-3), -1, 1) * Math.abs(dz);
      this.pelvis.position.set(0, py, 0);
      this.pelvis.rotation.set(pitch, yawP, roll);
      this.pelvis.updateMatrix();
      const qi = this._qi || (this._qi = new THREE.Quaternion());
      const v = this._v || (this._v = new THREE.Vector3());
      qi.copy(this.pelvis.quaternion).invert();
      for (let i = 0; i < 2; i++) {
        const f = feet[i], leg = L[i];
        v.set(f.x, f.y, f.z).sub(this.pelvis.position).applyQuaternion(qi).sub(leg.hip.position);
        this.solveLeg(leg, v, f.pitchF, pitch, leg.tw);
      }
      this.moveAmt = m; this.runAmt = r;
    }

    // Re-solve leg i to a planted foot at (x, z) in the root frame, blended
    // by w over its current pose — for overlays that move the pelvis.
    plantLeg(i, x, z, w) {
      const leg = this.legs[i];
      const h0 = leg.hip.rotation.x, hz = leg.hip.rotation.z, k0 = leg.knee.rotation.x, a0 = leg.ankle.rotation.x;
      const q = (this._qi || (this._qi = new THREE.Quaternion())).copy(this.pelvis.quaternion).invert();
      const v = (this._v || (this._v = new THREE.Vector3())).set(x, 0.085, z).sub(this.pelvis.position).applyQuaternion(q).sub(leg.hip.position);
      this.solveLeg(leg, v, 0, this.pelvis.rotation.x);
      leg.hip.rotation.x = h0 + (leg.hip.rotation.x - h0) * w;
      leg.hip.rotation.z = hz + (leg.hip.rotation.z - hz) * w;
      leg.knee.rotation.x = k0 + (leg.knee.rotation.x - k0) * w;
      leg.ankle.rotation.x = a0 + (leg.ankle.rotation.x - a0) * w;
    }

    // Two-bone IK, hip at the origin, target t (pelvis frame, from the hip):
    // tilt the leg plane (hip z), flex in it (hip x), knee forward; the boot
    // set to pitchF (+ = toe down) against the chain above it.
    solveLeg(leg, t, pitchF, pelvisPitch, yaw) {
      const a = this.legA, b = this.legB;
      const yw = yaw || 0;
      if (yw) {   // solve in the leg's own turned frame
        const c = Math.cos(yw), sn = Math.sin(yw), x = t.x, z = t.z;
        t.x = x * c - z * sn; t.z = x * sn + z * c;
      }
      const phi = Math.atan2(t.x, -t.y);
      const dy = -Math.hypot(t.x, t.y), dz = t.z;
      const D = clamp(Math.hypot(dy, dz), 0.25, a + b - 0.002);
      const beta = Math.atan2(dz, -dy);
      const alpha = Math.acos(clamp((a * a + D * D - b * b) / (2 * a * D), -1, 1));
      const knee = Math.PI - Math.acos(clamp((a * a + b * b - D * D) / (2 * a * b), -1, 1));
      const hipX = -(beta + alpha);
      leg.hip.rotation.set(hipX, yw, phi);
      leg.knee.rotation.x = knee;
      leg.ankle.rotation.x = clamp(pitchF - (pelvisPitch + hipX + knee), -0.6, 1.0);
    }

    // A body with its own leg (bodies.js): thigh a, shin b, standing pelvis height h.
    setProportions(a, b, h) {
      this.legA = a; this.legB = b; this.pelvisH = h;
      for (const l of this.legs) { l.knee.position.y = -a; l.ankle.position.y = -b; }
      if (this.pelvis) this.pelvis.position.y = h;
    }
    setKeeper(keeper) {
      if (keeper !== this.keeper) this.build(this.home, keeper);
    }
    setGlow() {}

    // A kick (renderer.js arms it up to INTERP_DELAY ticks before the ball
    // leaves): lead = sim seconds to contact, power 0..1 from the ball's
    // speed off the foot. The foot is the one on the ball's side (right by
    // default); the other leg plants.
    // amp < 1: a dribble touch (G5.78) — the same strike, small and quick.
    // foot (G5.79): the engine's kicking foot, 0 right / 1 left; else the ball's side.
    kick(lead, power, amp, foot) {
      const L = lead === undefined ? 0.04 : clamp(lead, 0, 0.2);
      const A = amp === undefined ? 1 : clamp(amp, 0.1, 1);
      this.kk = { t: 0, contact: L + 0.03, power: power === undefined ? 0.5 : clamp(power, 0, 1), amp: A,
                  leg: foot === 0 || foot === 1 ? foot : (this.ballLocalX || 0) > 0.12 ? 1 : 0 };
      this.kk.end = this.kk.contact + (0.3 + 0.2 * this.kk.power) * (A < 1 ? 0.5 : 1);
    }
    // A first touch (renderer.js arms it as the ball reaches him): lead =
    // sim seconds to the touch, z = the ball's height then. Foot (inside of
    // the foot, opened), thigh, or chest by height; the touch cushions back.
    receive(lead, z) {
      const zz = z || 0;
      this.rc = { t: 0, contact: clamp(lead || 0, 0.05, 0.2), leg: (this.ballLocalX || 0) > 0.1 ? 1 : 0,
                  kind: zz > 1.05 ? 2 : zz > 0.35 ? 1 : 0 };
      this.rc.end = this.rc.contact + 0.32;
    }
    setFlag(up) { this.flagUp = !!up; }   // G4.93: an assistant's flag
    // G5.2: an official's signal for a ball out (OfficialSnap bits 1-3):
    // 1/2 throw, up toward the attack (+x / -x); 3/4 goal kick, level at the
    // goal area; 5/6 corner, down at the corner arc.
    setSignal(code) {
      if (!code) { this.signal = null; return; }
      const dir = code % 2 === 1 ? 1 : -1;
      const up = code <= 2 ? 0.8 : code <= 4 ? 0.1 : -0.5;
      this.signal = new THREE.Vector3(dir, up, 0).normalize();
    }
    celebrate() { this.celebrateT = 3.5; }

    // ctx: { vx, vy, flags, ball:{x,y,z}|null, hasBall, me:{x,y} }
    update(dt, ctx) {
      this.wireFeet = ctx.feet || null;   // 2.3: the engine's feet
      this.me = ctx.me;
      const { vx, vy } = ctx;
      const speed = Math.hypot(vx, vy);
      this.speed = ease(this.speed, speed, 10, dt);
      const s = this.speed;
      const flags = ctx.flags || 0;
      const W = this.w;

      // ── facing + turn rate (for leaning into turns) ─────────────────
      const prevYaw = this.yaw;
      if (ctx.fx !== undefined && !(flags & 4)) {
        // The server's facing (1.8): he can face the ball while moving away.
        this.yaw += wrap(Math.atan2(ctx.fx, ctx.fy) - this.yaw) * Math.min(1, dt * 11);
      } else if (speed > 0.4 && !(flags & 4)) {
        this.yaw += wrap(Math.atan2(vx, vy) - this.yaw) * Math.min(1, dt * 11);
      }
      this.yawRate = ease(this.yawRate, wrap(this.yaw - prevYaw) / Math.max(dt, 1e-3), 8, dt);
      this.root.rotation.y = this.yaw;

      // ── overlay weights (eased) ──────────────────────────────────────
      const b = ctx.ball;
      let bdx = 0, bdz = 0, bd = 99, bz = 0;
      if (b) { bdx = b.x - ctx.me.x; bdz = b.y - ctx.me.y; bd = Math.hypot(bdx, bdz); bz = b.z; }
      this.ballLocalX = bdx * Math.cos(this.yaw) - bdz * Math.sin(this.yaw);
      // The ball's velocity, from frame to frame (for headers and dives).
      const BV = this.bv || (this.bv = { x: 0, y: 0, z: 0, px: null });
      if (b && dt > 1e-4) {
        if (BV.px !== null) {
          const k = Math.min(1, dt * 12);
          BV.x += ((b.x - BV.px) / dt - BV.x) * k; BV.y += ((b.y - BV.py) / dt - BV.y) * k; BV.z += ((b.z - BV.pz) / dt - BV.z) * k;
        }
        BV.px = b.x; BV.py = b.y; BV.pz = b.z;
      }
      const closing = bd > 0.05 ? -(bdx * BV.x + bdz * BV.y) / bd : 0;   // m/s toward him
      if (ctx.hasBall && !this.hadBall) this.dribbleLeg = this.ballLocalX > 0.1 ? 1 : 0;
      this.hadBall = !!ctx.hasBall;
      // Header: a ball he will meet at head height within ~0.4 s → a timed
      // jump, its peak on the ball's arrival (crouch 0.12 s, up 0.22 s).
      if (b && !this.hd && !this.dv && !ctx.hasBall && closing > 3) {
        const tA = Math.max(0, bd - 0.35) / closing;
        const zA = bz + BV.z * tA - 4.9 * tA * tA;
        if (tA < 0.36 && zA > 1.45 && zA < 2.75) this.hd = { t: Math.max(0, 0.34 - tA), up: clamp((zA - 1.6) * 0.5 + 0.18, 0.08, 0.5) };
      }
      // Keeper dive: a shot coming at him, wide of his body → a timed dive
      // to that side (launch, flight, land, lie, up).
      if (this.keeper && b && !this.dv && !ctx.hasBall && closing > 9 && bd < 16) {
        const tA = Math.max(0.05, bd / closing);
        const lx = (b.x + BV.x * tA - ctx.me.x) * Math.cos(this.yaw) - (b.y + BV.y * tA - ctx.me.y) * Math.sin(this.yaw);
        const zA = bz + BV.z * tA - 4.9 * tA * tA;
        if (Math.abs(lx) > 0.9 && Math.abs(lx) < 4.5 && tA < 0.6) this.dv = { t: 0, sd: lx > 0 ? 1 : -1, high: clamp(zA / 2.2, 0, 1) };
      }
      W.slide = ease(W.slide, flags & 4 ? 1 : 0, flags & 4 ? 14 : 5, dt);
      W.stumble = ease(W.stumble, flags & 8 ? 1 : 0, 10, dt);
      W.dribble = ease(W.dribble, ctx.hasBall ? 1 : 0, 6, dt);
      this.readyAmt = ease(this.readyAmt || 0, !this.official && bd < 25 ? 1 : 0, 2, dt);   // knees bent, on his toes near play
      if (this.celebrateT > 0) this.celebrateT -= dt;
      W.cele = ease(W.cele, this.celebrateT > 0 ? 1 : 0, 5, dt);
      W.flag = ease(W.flag || 0, this.carriesFlag && this.flagUp ? 1 : 0, 9, dt);
      W.signal = ease(W.signal || 0, this.signal ? 1 : 0, 9, dt);       // G5.2
      W.throwIn = ease(W.throwIn || 0, flags & 16 ? 1 : 0, 10, dt);     // G5.2

      // ── locomotion: the gait ─────────────────────────────────────────
      this.chest.rotation.set(0, 0, 0);
      this.gait(dt, vx, vy, speed, W);
      const m = this.moveAmt, r = this.runAmt;
      for (const arm of this.arms) {
        if (this.keeper && s < 1.5) {           // keeper set position
          arm.sh.rotation.set(-0.55, 0, arm.side * 0.5);
          arm.elbow.rotation.x = -0.7;
          continue;
        }
        // The arm swings against its own side's leg: that foot forward,
        // this hand back. Elbow ~20° walking, ~85° running [Novacheck 1998].
        const leg = this.legs[arm.side < 0 ? 0 : 1];
        const amp = (0.32 + r * (0.28 + 0.05 * clamp(s - 3, 0, 6))) * m;
        const sw = clamp(leg.along / Math.max(0.12, this.halfStride), -1, 1) * amp;
        arm.sh.rotation.set(sw + 0.22 * r * m, 0, arm.side * (0.07 + 0.06 * r + 0.18 * W.dribble));   // running: the upper arm swings about a point behind vertical
        arm.elbow.rotation.x = -(0.3 + 1.2 * r) - Math.max(0, -sw) * 0.35;
      }
      // ── look: head (and a little chest) track the ball ──────────────
      let lookYaw = 0, lookPitch = 0.1;
      if (b && bd < 45) {
        lookYaw = clamp(wrap(Math.atan2(bdx, bdz) - this.yaw), -1.2, 1.2);
        lookPitch = clamp(Math.atan2(1.6 - bz, Math.max(bd, 0.5)) * 0.8, -0.6, 0.7);
      }
      this.look.yaw = ease(this.look.yaw, lookYaw, 6, dt);
      this.look.pitch = ease(this.look.pitch, lookPitch, 6, dt);
      this.neck.rotation.set(this.look.pitch, this.look.yaw * 0.75, 0);
      this.chest.rotation.y = this.look.yaw * 0.25 - this.pelvis.rotation.y * 0.8;   // shoulders counter the hips

      // ── overlays ─────────────────────────────────────────────────────
      const L = this.legs, A = this.arms;
      // Kick: back-swing, strike, follow-through on the ball-side leg; the
      // other leg planted and flexed, the opposite arm out for balance, the
      // shoulders wound open then turned through. Contact as the ball leaves.
      if (this.kk) {
        const K = this.kk;
        K.t += dt;
        if (K.t >= K.end) this.kk = null;
        else {
          const P = K.power, t = K.t, tc = K.contact, AM = K.amp || 1;
          const back = (0.45 + 0.45 * P) * AM, through = -(0.75 + 0.65 * P) * AM;
          const ws = Math.max(0.06, Math.min(0.1, tc * 0.6));   // the strike itself
          let hipX, kneeX, twist;
          if (t < tc - ws) {                       // back-swing
            const u = smooth(t / Math.max(1e-3, tc - ws));
            hipX = back * u; kneeX = 0.3 + (1.3 + 0.5 * P) * u; twist = 0.3 * u;
          } else if (t < tc) {                     // strike: thigh drives, knee snaps straight
            const u = (t - (tc - ws)) / ws;
            hipX = back + (-0.3 - back) * smooth(u); kneeX = (1.6 + 0.5 * P) * (1 - u * u) + 0.25 * u * u;
            twist = 0.3 - 0.6 * u;
          } else {                                 // follow-through, then back to the gait
            const u = smooth((t - tc) / (K.end - tc));
            hipX = -0.3 + (through + 0.3) * Math.min(1, u * 2.2); kneeX = 0.25 + 0.4 * u; twist = -0.3 * (1 - u);
          }
          if (AM < 1) { kneeX = 0.3 + (kneeX - 0.3) * AM; twist *= AM; }
          const w = Math.min(1, t / 0.035) * Math.min(1, (K.end - t) / 0.12) * (AM < 1 ? 0.8 : 1);
          const kl = L[K.leg], pl = L[1 - K.leg], ka = A[1 - K.leg], sd = K.leg === 0 ? 1 : -1;
          kl.hip.rotation.x += (hipX - kl.hip.rotation.x) * w;
          kl.hip.rotation.z += (sd * 0.08 - kl.hip.rotation.z) * w;
          kl.knee.rotation.x += (kneeX - kl.knee.rotation.x) * w;
          kl.ankle.rotation.x += (0.5 - kl.ankle.rotation.x) * w;   // toe down, laces through
          this.pelvis.position.y -= 0.05 * w * AM;
          this.pelvis.rotation.x += (0.08 + 0.1 * P) * w * AM;     // over the ball
          // The standing foot planted beside the ball (IK against the moved pelvis).
          this.plantLeg(1 - K.leg, sd * 0.13, 0.02, w);
          this.chest.rotation.y += sd * twist * w;
          ka.sh.rotation.z += (sd * (0.9 + 0.3 * P) * AM - ka.sh.rotation.z) * w;   // out to the side
          ka.sh.rotation.x += (-0.35 - ka.sh.rotation.x) * w;
          ka.elbow.rotation.x += (-0.4 - ka.elbow.rotation.x) * w;
        }
      }
      // Slide tackle: drop to the turf, lead leg out straight, trail leg
      // tucked, lean back, arms behind for balance.
      if (W.slide > 0.01) {
        const w = W.slide;
        this.pelvis.position.y += (0.32 - this.pelvis.position.y) * w;
        this.pelvis.rotation.x += (-1.05 - this.pelvis.rotation.x) * w;
        this.pelvis.rotation.z += (-0.4 - this.pelvis.rotation.z) * w;   // onto the trail-leg side
        L[1].ankle.rotation.x += (-0.4 - L[1].ankle.rotation.x) * w;     // lead toe up, studs at the ball
        L[1].hip.rotation.x += (-1.45 - L[1].hip.rotation.x) * w;
        L[1].knee.rotation.x *= 1 - w;
        L[0].hip.rotation.x += (-0.5 - L[0].hip.rotation.x) * w;
        L[0].knee.rotation.x += (1.9 - L[0].knee.rotation.x) * w;
        for (const a of A) {
          a.sh.rotation.x += (0.9 - a.sh.rotation.x) * w;
          a.sh.rotation.z += (a.side * 0.6 - a.sh.rotation.z) * w;
          a.elbow.rotation.x *= 1 - w;
        }
      }
      // Stumble: pitched forward, arms flung out, a wobble.
      if (W.stumble > 0.01) {
        const w = W.stumble;
        const t = performance.now() / 90;
        this.pelvis.rotation.x += 0.45 * w;
        this.pelvis.rotation.z += Math.sin(t) * 0.2 * w;
        for (const a of A) {
          a.sh.rotation.z += (a.side * 1.3 - a.sh.rotation.z) * w;
          a.sh.rotation.x += (-0.6 - a.sh.rotation.x) * w;
        }
      }
      // First touch: the receiving part goes to meet the ball and gives
      // with it (cushion), the other leg planted.
      if (this.rc) {
        const R = this.rc;
        R.t += dt;
        if (R.t >= R.end) this.rc = null;
        else {
          const t = R.t, tc = R.contact;
          const reach = t < tc ? smooth(t / tc) : 1 - smooth((t - tc) / (R.end - tc));   // out, then gives
          const w = Math.min(1, t / 0.04) * Math.min(1, (R.end - t) / 0.1);
          const kl = L[R.leg], sd = R.leg === 0 ? 1 : -1, side = -sd;
          if (R.kind === 0) {           // inside of the foot, toes turned out
            kl.hip.rotation.x += (-0.45 * reach - kl.hip.rotation.x) * w;
            kl.hip.rotation.y += (side * 0.75 * reach - kl.hip.rotation.y) * w;
            kl.knee.rotation.x += (0.15 + 0.35 * reach - kl.knee.rotation.x) * w;
            kl.ankle.rotation.x += (-0.1 - kl.ankle.rotation.x) * w;
            this.plantLeg(1 - R.leg, sd * 0.12, -0.02, w);
          } else if (R.kind === 1) {    // thigh up to it
            kl.hip.rotation.x += (-1.15 * reach - kl.hip.rotation.x) * w;
            kl.knee.rotation.x += (0.2 + 1.2 * reach - kl.knee.rotation.x) * w;
            this.plantLeg(1 - R.leg, sd * 0.1, 0, w);
            for (const a of A) a.sh.rotation.z += (a.side * 0.45 - a.sh.rotation.z) * w * reach;
          } else {                      // chest: lean back, arms out, knees soft
            this.pelvis.rotation.x += (-0.3 * reach) * w;
            this.chest.rotation.x = -0.15 * reach * w;
            this.pelvis.position.y -= 0.04 * w;
            this.plantLeg(0, -0.13, 0.05, w);
            this.plantLeg(1, 0.13, -0.05, w);
            for (const a of A) {
              a.sh.rotation.z += (a.side * 0.85 - a.sh.rotation.z) * w * reach;
              a.sh.rotation.x += (-0.3 - a.sh.rotation.x) * w * reach;
            }
          }
        }
      }
      // Keeper dive: crouch and push off (0.1 s), fly sideways near level
      // with arms past the head (to 0.45 s), land on the side, lie, get up.
      if (this.dv) {
        const D = this.dv, sd = D.sd;
        D.t += dt;
        const t = D.t, END = 1.5;
        if (t >= END) this.dv = null;
        else {
          let rollT, py, armUp, w = Math.min(1, (END - t) / 0.35);
          if (t < 0.1) { const u = t / 0.1; rollT = 0.25 * u; py = this.pelvisH - 0.15 * u; armUp = 0.5 * u; }
          else if (t < 0.45) { const u = (t - 0.1) / 0.35; rollT = 0.25 + 1.2 * smooth(u); py = this.pelvisH - 0.15 + (0.25 + 0.35 * D.high) * Math.sin(Math.PI * u * 0.8) - 0.3 * smooth((u - 0.6) / 0.4); armUp = 1; }
          else { rollT = 1.45; py = 0.32; armUp = 1 - 0.6 * smooth((t - 0.45) / 0.5); }
          w = Math.min(1, t / 0.05) * w;
          this.pelvis.position.y += (py - this.pelvis.position.y) * w;
          this.pelvis.rotation.z += (sd * -rollT - this.pelvis.rotation.z) * w;
          this.pelvis.rotation.x += (0.05 - this.pelvis.rotation.x) * w;
          for (const a of A) {
            a.sh.rotation.x += (-3.0 * armUp - 0.3 - a.sh.rotation.x) * w;
            a.sh.rotation.z += (-sd * 0.2 - a.sh.rotation.z) * w;
            a.elbow.rotation.x *= 1 - w * armUp;
          }
          for (const l of L) {
            l.hip.rotation.x += (-0.15 - l.hip.rotation.x) * w;
            l.hip.rotation.y *= 1 - w;
            l.hip.rotation.z += (0 - l.hip.rotation.z) * w;
            l.knee.rotation.x += (0.25 - l.knee.rotation.x) * w;
          }
          L[sd > 0 ? 0 : 1].knee.rotation.x += 0.5 * w * (t < 0.12 ? 1 : 0.3);   // the push leg
        }
      }
      // Header: crouch, spring off one leg (the other knee driven up), back
      // arched with the arms up for leverage, snap forward through the ball
      // at the top, land.
      if (this.hd) {
        const H = this.hd;
        H.t += dt;
        const t = H.t;
        if (t >= 0.75) this.hd = null;
        else {
          const w = Math.min(1, t / 0.04) * Math.min(1, (0.75 - t) / 0.08);
          let lift = 0, crouch = 0, arch = 0, tuck = 0;
          if (t < 0.12) crouch = smooth(t / 0.12);
          else if (t < 0.56) { const u = (t - 0.12) / 0.44; lift = Math.sin(Math.PI * u); crouch = Math.max(0, 1 - u * 6); tuck = Math.sin(Math.PI * u);
                               arch = u < 0.5 ? -smooth(u / 0.5) : -1 + 1.8 * smooth((u - 0.5) / 0.15); }
          else crouch = 0.6 * (1 - smooth((t - 0.56) / 0.19));
          this.pelvis.position.y += (-0.13 * crouch + H.up * lift);
          this.pelvis.rotation.x += 0.16 * arch * w;
          this.chest.rotation.x += 0.12 * arch * w;
          this.neck.rotation.x += (arch > 0 ? 0.35 * arch : -0.25 * -arch) * w;
          if (lift === 0) { this.plantLeg(0, -0.12, 0, w); this.plantLeg(1, 0.12, 0, w); }
          else {
            L[0].hip.rotation.x += (-0.9 * tuck - L[0].hip.rotation.x) * w;   // drive knee
            L[0].knee.rotation.x += (1.3 * tuck - L[0].knee.rotation.x) * w;
            L[1].hip.rotation.x += (0.1 - L[1].hip.rotation.x) * w;           // take-off leg trails
            L[1].knee.rotation.x += (0.5 * tuck + 0.1 - L[1].knee.rotation.x) * w;
            L[1].ankle.rotation.x += (0.6 - L[1].ankle.rotation.x) * w;
          }
          for (const a of A) {
            a.sh.rotation.x += (-1.7 * Math.max(lift, crouch * 0.4) - a.sh.rotation.x) * w;
            a.sh.rotation.z += (a.side * 0.6 - a.sh.rotation.z) * w;
            a.elbow.rotation.x += (-0.9 - a.elbow.rotation.x) * w;
          }
        }
      }
      // Celebrate: arms up and pumping, little jumps.
      if (W.cele > 0.01) {
        const w = W.cele;
        const t = performance.now() / 160 + this.slot;
        this.pelvis.position.y += Math.abs(Math.sin(t)) * 0.18 * w;
        for (const a of A) {
          a.sh.rotation.x += (-2.7 + Math.sin(t * 1.3) * 0.25 - a.sh.rotation.x) * w;
          a.sh.rotation.z += (a.side * 0.35 - a.sh.rotation.z) * w;
          a.elbow.rotation.x += (-0.3 - a.elbow.rotation.x) * w;
        }
        this.neck.rotation.x += (-0.35 - this.neck.rotation.x) * w;
      }
      // Flag up (G4.93): the assistant's right arm straight up, still.
      if (W.flag > 0.01) {
        const w = W.flag, a = A[1];
        a.sh.rotation.x += (-3.0 - a.sh.rotation.x) * w;
        a.sh.rotation.z += (0.1 - a.sh.rotation.z) * w;
        a.elbow.rotation.x *= 1 - w;
      }
      // Taking a throw (G5.2): both hands on the ball, over his head.
      if (W.throwIn > 0.01) {
        const w = W.throwIn;
        for (const a of A) {
          a.sh.rotation.x += (-3.0 - a.sh.rotation.x) * w;
          a.sh.rotation.z += (a.side * -0.12 - a.sh.rotation.z) * w;
          a.elbow.rotation.x += (-0.5 - a.elbow.rotation.x) * w;
        }
      }
      // An official's signal (G5.2): his right arm points along the world
      // direction, whichever way he's facing.
      if (W.signal > 0.01 && this.signal) {
        const a = A[1];
        const q = a.sh.parent.getWorldQuaternion(new THREE.Quaternion()).invert();
        const local = this.signal.clone().applyQuaternion(q);
        const aim = new THREE.Quaternion().setFromUnitVectors(new THREE.Vector3(0, -1, 0), local);
        a.sh.quaternion.slerp(aim, W.signal);
        a.elbow.rotation.x *= 1 - W.signal;
      }
    }
  }

  // Team kits from the DB (mig 639, TEAMS frame): { shirt, shorts, socks,
  // trim } per side, outfield only (keepers keep their contrasting kit).
  // Callers rebuild existing figures afterwards.
  PlayerFigure.setKits = (home, away) => {
    if (home) Object.assign(KIT.home, home);
    if (away) Object.assign(KIT.away, away);
  };
  // Video-game identity (James: "names video game style last name over
  // player and their position number like 9 for striker"): the slot's
  // position number on the shirt + a last-name tag over the head. A new
  // number rebuilds the figure; the tag survives rebuilds.
  PlayerFigure.prototype.setIdentity = function (number, name) {
    const last = String(name || '').trim().split(/\s+/).pop().toUpperCase();
    const numChanged = number && number !== this.number;
    this.number = number || this.number;
    if (numChanged) this.build(this.home, this.keeper);
    if (last !== this.tagName || numChanged) {
      this.tagName = last;
      this.attachTag();
    }
  };
  PlayerFigure.prototype.attachTag = function () {
    if (this.tag) { this.root.remove(this.tag); this.tag.material.map.dispose(); this.tag.material.dispose(); }
    this.tag = null;
    if (!this.tagName) return;
    const c = document.createElement('canvas');
    c.width = 256; c.height = 64;
    const x = c.getContext('2d');
    const text = (this.number ? this.number + ' ' : '') + this.tagName;
    x.font = 'bold 34px system-ui, sans-serif';
    x.textAlign = 'center'; x.textBaseline = 'middle';
    const w = Math.min(248, x.measureText(text).width + 22);
    x.fillStyle = 'rgba(10,14,20,0.62)';
    x.fillRect(128 - w / 2, 10, w, 44);
    x.fillStyle = '#ffffff';
    x.fillText(text, 128, 33);
    const sp = new THREE.Sprite(new THREE.SpriteMaterial({ map: new THREE.CanvasTexture(c), depthTest: false, transparent: true }));
    sp.scale.set(1.9, 0.475, 1);
    sp.position.y = 2.35;
    sp.renderOrder = 70;
    this.root.add(sp);
    this.tag = sp;
  };
  window.PlayerFigure = PlayerFigure;
})();
