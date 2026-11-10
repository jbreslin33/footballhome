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
//     kick · slide tackle · stumble · keeper dive · header jump · celebrate
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
      this.w = { slide: 0, stumble: 0, dive: 0, jump: 0, dribble: 0, cele: 0 };
      this.diveSide = 1;
      this.look = { yaw: 0, pitch: 0 };
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
      while (this.root.children.length) this.root.remove(this.root.children[0]);

      // pelvis: the rig's hub (lean, bob, slide drop all act here)
      const pelvis = new THREE.Group();
      pelvis.position.y = 0.95;
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
        hip.rotation.order = 'ZYX';   // Rz·Rx: tilt the leg's plane, then flex in it (the IK)
        hip.position.set(side * 0.1, -0.06, 0);
        pelvis.add(hip);
        const thigh = cap(0.074, 0.28, skin, -0.21);
        const leg = mesh(g('shortleg', () => new THREE.CylinderGeometry(0.09, 0.085, 0.14, 10)),
                         mat(kit.shorts), -0.06);
        const knee = new THREE.Group();
        knee.position.y = -0.42;
        const shin = cap(0.06, 0.28, kit.socks, -0.2);
        const band = mesh(g('band', () => new THREE.CylinderGeometry(0.066, 0.066, 0.04, 10)),
                          mat(kit.trim), -0.06);
        const ankle = new THREE.Group();
        ankle.position.y = -0.4;
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
      const T = Tw + (Tr - Tw) * r, duty = dw + (dr - dw) * r;
      this.phase = (this.phase + dt / T) % 1;
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
      const lift = (0.07 + r * clamp(0.1 + 0.075 * (s - 2.5), 0, 0.5)) * m;
      // Pelvis: COM high at mid-stance walking, low running; ±2 / ±3.5 cm.
      const stepPh = (this.phase * 2) % 1;
      const osc = Math.cos(TAU * (stepPh - duty / 2));
      const ready = this.readyAmt || 0;
      let py = 0.95 - 0.02 * m - 0.025 * r + m * (0.018 * (1 - r) * osc - 0.035 * r * osc) - 0.05 * ready * (1 - m);
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
        const base = side * (0.11 - 0.04 * r + 0.06 * Math.abs(dx) * m);
        L[i].along = along - centre;
        return { x: base + dx * along, z: dz * along, y: h + 0.085, pitchF };
      });
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
        this.solveLeg(leg, v, f.pitchF, pitch);
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
    solveLeg(leg, t, pitchF, pelvisPitch) {
      const a = 0.42, b = 0.40;
      const phi = Math.atan2(t.x, -t.y);
      const dy = -Math.hypot(t.x, t.y), dz = t.z;
      const D = clamp(Math.hypot(dy, dz), 0.25, a + b - 0.002);
      const beta = Math.atan2(dz, -dy);
      const alpha = Math.acos(clamp((a * a + D * D - b * b) / (2 * a * D), -1, 1));
      const knee = Math.PI - Math.acos(clamp((a * a + b * b - D * D) / (2 * a * b), -1, 1));
      const hipX = -(beta + alpha);
      leg.hip.rotation.set(hipX, 0, phi);
      leg.knee.rotation.x = knee;
      leg.ankle.rotation.x = clamp(pitchF - (pelvisPitch + hipX + knee), -0.6, 1.0);
    }

    setKeeper(keeper) {
      if (keeper !== this.keeper) this.build(this.home, keeper);
    }
    setGlow() {}

    // A kick (renderer.js arms it up to INTERP_DELAY ticks before the ball
    // leaves): lead = sim seconds to contact, power 0..1 from the ball's
    // speed off the foot. The foot is the one on the ball's side (right by
    // default); the other leg plants.
    kick(lead, power) {
      const L = lead === undefined ? 0.04 : clamp(lead, 0, 0.2);
      this.kk = { t: 0, contact: L + 0.03, power: power === undefined ? 0.5 : clamp(power, 0, 1),
                  leg: (this.ballLocalX || 0) > 0.12 ? 1 : 0 };
      this.kk.end = this.kk.contact + 0.3 + 0.2 * this.kk.power;
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
      W.slide = ease(W.slide, flags & 4 ? 1 : 0, flags & 4 ? 14 : 5, dt);
      W.stumble = ease(W.stumble, flags & 8 ? 1 : 0, 10, dt);
      W.dribble = ease(W.dribble, ctx.hasBall ? 1 : 0, 6, dt);
      this.readyAmt = ease(this.readyAmt || 0, !this.official && bd < 25 ? 1 : 0, 2, dt);   // knees bent, on his toes near play
      // Keeper dive: moving fast while a ball is close and on its way.
      let diveWant = 0;
      if (this.keeper && s > 3.2 && bd < 11 && !ctx.hasBall) {
        const side = Math.sign(Math.sin(wrap(Math.atan2(vx, vy) - this.yaw + Math.PI / 2))) || 1;
        this.diveSide = side;
        diveWant = 1;
      }
      W.dive = ease(W.dive, diveWant, diveWant ? 12 : 4, dt);
      // Header: a ball at head height arriving at this player.
      W.jump = ease(W.jump, bz > 1.3 && bz < 2.6 && bd < 1.4 ? 1 : 0, 12, dt);
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
          const P = K.power, t = K.t, tc = K.contact;
          const back = 0.45 + 0.45 * P, through = -(0.75 + 0.65 * P);
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
          const w = Math.min(1, t / 0.035) * Math.min(1, (K.end - t) / 0.12);
          const kl = L[K.leg], pl = L[1 - K.leg], ka = A[1 - K.leg], sd = K.leg === 0 ? 1 : -1;
          kl.hip.rotation.x += (hipX - kl.hip.rotation.x) * w;
          kl.hip.rotation.z += (sd * 0.08 - kl.hip.rotation.z) * w;
          kl.knee.rotation.x += (kneeX - kl.knee.rotation.x) * w;
          kl.ankle.rotation.x += (0.5 - kl.ankle.rotation.x) * w;   // toe down, laces through
          this.pelvis.position.y -= 0.05 * w;
          this.pelvis.rotation.x += (0.08 + 0.1 * P) * w;          // over the ball
          // The standing foot planted beside the ball (IK against the moved pelvis).
          this.plantLeg(1 - K.leg, sd * 0.13, 0.02, w);
          this.chest.rotation.y += sd * twist * w;
          ka.sh.rotation.z += (sd * (0.9 + 0.3 * P) - ka.sh.rotation.z) * w;   // out to the side
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
      // Keeper dive: launch sideways — body rolls flat, arms stretch past
      // the head toward the ball, legs trail.
      if (W.dive > 0.01) {
        const w = W.dive, sd = this.diveSide;
        this.pelvis.position.y += (0.75 - this.pelvis.position.y) * w;
        this.pelvis.rotation.z += (-sd * 1.25 - this.pelvis.rotation.z) * w;
        for (const a of A) {
          a.sh.rotation.x += (-3.0 - a.sh.rotation.x) * w;
          a.sh.rotation.z += (-sd * 0.25 - a.sh.rotation.z) * w;
          a.elbow.rotation.x *= 1 - w;
        }
        for (const l of L) {
          l.hip.rotation.x *= 1 - w * 0.8;
          l.knee.rotation.x += (0.3 - l.knee.rotation.x) * w;
        }
      }
      // Header: spring up, arms up for leverage, head snaps forward.
      if (W.jump > 0.01) {
        const w = W.jump;
        this.pelvis.position.y += 0.35 * w;
        for (const l of L) l.knee.rotation.x += (0.9 - l.knee.rotation.x) * w;
        for (const a of A) {
          a.sh.rotation.x += (-1.6 - a.sh.rotation.x) * w;
          a.sh.rotation.z += (a.side * 0.5 - a.sh.rotation.z) * w;
        }
        this.neck.rotation.x += 0.4 * w;
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
