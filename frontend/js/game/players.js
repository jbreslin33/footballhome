// frontend/js/game/players.js
//
// Humanoid player figures + procedural animation (pure dressing: the
// server is the authority; nothing here touches gameplay). A jointed rig
// built from capsules — pelvis, torso, neck/head, hips/knees/ankles,
// shoulders/elbows — animated in LAYERS over the run cycle:
//   locomotion (stride/cadence by speed, dribble touch, turn lean)
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
    constructor(slot, home, keeper) {
      this.slot = slot;
      this.home = home;
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
      const kit = KIT[(home ? 'home' : 'away') + (keeper ? 'Gk' : '')];
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
      const plate = numberDecal(this.number || this.slot % 11 + 1, kit);
      plate.position.y = 0.3;
      chest.add(torso, collar, plate);

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
        sh.add(upper, sleeve, elbow);
        return { sh, elbow, side };
      });

      // Legs: hip → thigh (shorts leg over skin) → knee → shin (sock with
      // a trim band) → ankle → boot.
      this.legs = [-1, 1].map((side) => {
        const hip = new THREE.Group();
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

    setKeeper(keeper) {
      if (keeper !== this.keeper) this.build(this.home, keeper);
    }
    setGlow() {}

    kick() { this.kickT = 0.38; }
    celebrate() { this.celebrateT = 3.5; }

    // ctx: { vx, vy, flags, ball:{x,y,z}|null, hasBall, me:{x,y} }
    update(dt, ctx) {
      const { vx, vy } = ctx;
      const speed = Math.hypot(vx, vy);
      this.speed = ease(this.speed, speed, 10, dt);
      const s = this.speed;
      const run = Math.min(s / 6, 1);
      const flags = ctx.flags || 0;
      const W = this.w;

      // ── facing + turn rate (for leaning into turns) ─────────────────
      const prevYaw = this.yaw;
      if (speed > 0.4 && !(flags & 4)) {
        this.yaw += wrap(Math.atan2(vx, vy) - this.yaw) * Math.min(1, dt * 11);
      }
      this.yawRate = ease(this.yawRate, wrap(this.yaw - prevYaw) / Math.max(dt, 1e-3), 8, dt);
      this.root.rotation.y = this.yaw;

      // ── overlay weights (eased) ──────────────────────────────────────
      const b = ctx.ball;
      let bdx = 0, bdz = 0, bd = 99, bz = 0;
      if (b) { bdx = b.x - ctx.me.x; bdz = b.y - ctx.me.y; bd = Math.hypot(bdx, bdz); bz = b.z; }
      W.slide = ease(W.slide, flags & 4 ? 1 : 0, flags & 4 ? 14 : 5, dt);
      W.stumble = ease(W.stumble, flags & 8 ? 1 : 0, 10, dt);
      W.dribble = ease(W.dribble, ctx.hasBall ? 1 : 0, 6, dt);
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

      // ── locomotion: the stride ───────────────────────────────────────
      // Dribbling: quicker, shorter steps — the ball is in the stride.
      const cadence = 0.7 + s * (0.27 + 0.06 * W.dribble);
      this.phase = (this.phase + dt * cadence) % 1;
      const p = this.phase * TAU;
      const swing = (0.15 + 0.75 * run) * (1 - 0.3 * W.dribble);
      const moving = s > 0.3 ? 1 : 0;
      for (let i = 0; i < 2; i++) {
        const leg = this.legs[i];
        const lp = p + i * Math.PI;
        leg.hip.rotation.set(-Math.sin(lp) * swing * moving, 0, 0);
        leg.knee.rotation.x = moving
          ? Math.max(0, -Math.cos(lp)) * (0.4 + 1.1 * run) + 0.08
          : 0.05;
        leg.ankle.rotation.x = moving ? Math.sin(lp) * 0.3 * run : 0;
      }
      for (const arm of this.arms) {
        const ap = p + (arm.side > 0 ? 0 : Math.PI);
        if (this.keeper && s < 1.5) {           // keeper set position
          arm.sh.rotation.set(-0.55, 0, arm.side * 0.5);
          arm.elbow.rotation.x = -0.7;
        } else {
          arm.sh.rotation.set(Math.sin(ap) * swing * 0.85,
                              0, arm.side * (0.08 + 0.18 * W.dribble));
          arm.elbow.rotation.x = -(0.25 + 1.1 * run);
        }
      }
      // Lean into the run, bank into turns, bob twice per stride.
      this.pelvis.rotation.set(0.05 + 0.2 * run,
                               0,
                               clamp(-this.yawRate * 0.05 * run, -0.35, 0.35));
      this.pelvis.position.y = 0.95 + (moving
        ? Math.abs(Math.sin(p)) * 0.05 * run
        : Math.sin(performance.now() / 600 + this.slot) * 0.006);
      this.chest.rotation.set(0, 0, 0);

      // ── look: head (and a little chest) track the ball ──────────────
      let lookYaw = 0, lookPitch = 0.1;
      if (b && bd < 45) {
        lookYaw = clamp(wrap(Math.atan2(bdx, bdz) - this.yaw), -1.2, 1.2);
        lookPitch = clamp(Math.atan2(1.6 - bz, Math.max(bd, 0.5)) * 0.8, -0.6, 0.7);
      }
      this.look.yaw = ease(this.look.yaw, lookYaw, 6, dt);
      this.look.pitch = ease(this.look.pitch, lookPitch, 6, dt);
      this.neck.rotation.set(this.look.pitch, this.look.yaw * 0.75, 0);
      this.chest.rotation.y = this.look.yaw * 0.25;

      // ── overlays ─────────────────────────────────────────────────────
      const L = this.legs, A = this.arms;
      // Kick: right leg winds back then strikes through (~0.4 s).
      if (this.kickT > 0) {
        this.kickT = Math.max(0, this.kickT - dt);
        const k = 1 - this.kickT / 0.38;
        const wind = k < 0.35 ? -0.9 * (k / 0.35) : -0.9 + 2.5 * ((k - 0.35) / 0.65);
        L[1].hip.rotation.x = -wind;
        L[1].knee.rotation.x = k < 0.35 ? 1.3 * (k / 0.35) : 1.3 * (1 - (k - 0.35) / 0.65);
        A[0].sh.rotation.x = -0.9 * Math.sin(k * Math.PI);
        A[0].sh.rotation.z = -0.5 * Math.sin(k * Math.PI);
        this.pelvis.rotation.x -= 0.15 * Math.sin(k * Math.PI);
        this.chest.rotation.y -= 0.35 * Math.sin(k * Math.PI);
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
