// frontend/js/game/players.js
//
// Humanoid player figures + procedural animation (pure dressing: the
// server is the authority; nothing here touches gameplay). Built from
// primitives with real joints — hips, knees, shoulders, elbows — so one
// rig animates running, idling, kicking and goalkeeping without assets.
//
// Driven entirely by what the wire already carries: interpolated position
// and velocity per slot (facing + run speed), the keeper flag, and ball
// ownership changes (a kick). Model space faces +z; three y is up.

(function () {
  'use strict';

  const KIT = {
    home:   { shirt: 0x14326e, trim: 0xffcc00, shorts: 0xf4f6fb, socks: 0x14326e },
    away:   { shirt: 0xf4f6fb, trim: 0x14326e, shorts: 0x14326e, socks: 0xf4f6fb },
    homeGk: { shirt: 0x2e9e44, trim: 0x111111, shorts: 0x111111, socks: 0x2e9e44 },
    awayGk: { shirt: 0xff8a1f, trim: 0x111111, shorts: 0x111111, socks: 0xff8a1f },
  };
  const SKIN = [0xf1c27d, 0xe0ac69, 0xc68642, 0x8d5524, 0x5c3a1e, 0xffdbac];
  const HAIR = [0x2b1b10, 0x111111, 0x6b4423, 0xb8860b, 0x3d2817];

  const TAU = Math.PI * 2;
  const geo = {};  // shared geometries (22 figures, one set of buffers)
  function g(name, make) { return geo[name] || (geo[name] = make()); }

  function box(w, h, d, color, y) {
    const m = new THREE.Mesh(g(`b${w},${h},${d}`, () => new THREE.BoxGeometry(w, h, d)),
                             new THREE.MeshLambertMaterial({ color }));
    m.position.y = y;
    return m;
  }

  // Shirt number on the back: one small canvas texture per figure.
  function numberPlate(n, kit) {
    const c = document.createElement('canvas');
    c.width = 64; c.height = 64;
    const x = c.getContext('2d');
    x.fillStyle = '#' + kit.shirt.toString(16).padStart(6, '0');
    x.fillRect(0, 0, 64, 64);
    x.fillStyle = '#' + kit.trim.toString(16).padStart(6, '0');
    x.font = 'bold 40px system-ui, sans-serif';
    x.textAlign = 'center'; x.textBaseline = 'middle';
    x.fillText(String(n), 32, 34);
    const tex = new THREE.CanvasTexture(c);
    const m = new THREE.Mesh(g('plate', () => new THREE.PlaneGeometry(0.3, 0.3)),
                             new THREE.MeshBasicMaterial({ map: tex }));
    m.rotation.y = Math.PI;      // faces -z: the back
    m.position.set(0, 1.3, -0.126);
    return m;
  }

  class PlayerFigure {
    constructor(slot, home, keeper) {
      this.slot = slot;
      this.home = home;
      this.root = new THREE.Group();      // ground position + facing (yaw)
      this.body = new THREE.Group();      // lean + bob
      this.root.add(this.body);
      this.root.userData.slot = slot;
      this.yaw = home ? Math.PI / 2 : -Math.PI / 2;  // face the opponent goal
      this.phase = (slot * 0.37) % 1;      // de-sync the squad's strides
      this.kickT = 0;                      // seconds left in a kick
      this.speed = 0;
      this.mats = [];                      // for highlight emissive
      this.build(home, keeper);
    }

    build(home, keeper) {
      const kit = KIT[(home ? 'home' : 'away') + (keeper ? 'Gk' : '')];
      this.kit = kit;
      this.keeper = keeper;
      const skin = SKIN[(this.slot * 7) % SKIN.length];
      const hair = HAIR[(this.slot * 5) % HAIR.length];
      const B = this.body;
      while (B.children.length) B.remove(B.children[0]);
      this.mats = [];

      // Torso (shirt), shorts, collar trim, head + hair.
      const torso = box(0.42, 0.56, 0.24, kit.shirt, 1.27);
      const collar = box(0.2, 0.05, 0.25, kit.trim, 1.56);
      const shorts = box(0.4, 0.2, 0.25, kit.shorts, 0.93);
      const head = new THREE.Mesh(g('head', () => new THREE.SphereGeometry(0.12, 12, 10)),
                                  new THREE.MeshLambertMaterial({ color: skin }));
      head.position.y = 1.7;
      const hairCap = new THREE.Mesh(
        g('hair', () => new THREE.SphereGeometry(0.125, 12, 6, 0, TAU, 0, Math.PI / 2)),
        new THREE.MeshLambertMaterial({ color: hair }));
      hairCap.position.y = 1.72;
      const neck = box(0.08, 0.08, 0.08, skin, 1.6);
      B.add(torso, collar, shorts, head, hairCap, neck,
            numberPlate(this.slot % 11 + 1, kit));
      this.mats.push(torso.material, collar.material);

      // Legs: hip pivot → thigh (shorts colour) → knee pivot → shin (sock)
      // → boot. Pivots sit at the joint so rotation.x swings the limb.
      this.legs = [-1, 1].map((side) => {
        const hip = new THREE.Group();
        hip.position.set(side * 0.11, 0.9, 0);
        const thigh = box(0.15, 0.42, 0.16, skin, -0.21);
        const knee = new THREE.Group();
        knee.position.y = -0.42;
        const shin = box(0.12, 0.38, 0.13, kit.socks, -0.19);
        const boot = box(0.12, 0.08, 0.24, 0x111111, -0.42);
        boot.position.z = 0.04;
        knee.add(shin, boot);
        hip.add(thigh, knee);
        B.add(hip);
        return { hip, knee };
      });

      // Arms: shoulder pivot → upper arm (sleeve) → elbow → forearm (skin,
      // or keeper gloves).
      this.arms = [-1, 1].map((side) => {
        const sh = new THREE.Group();
        sh.position.set(side * 0.27, 1.5, 0);
        const upper = box(0.1, 0.3, 0.1, kit.shirt, -0.15);
        const elbow = new THREE.Group();
        elbow.position.y = -0.3;
        const fore = box(0.08, 0.27, 0.08, skin, -0.13);
        elbow.add(fore);
        if (keeper) elbow.add(box(0.11, 0.1, 0.11, 0xdddddd, -0.3));
        sh.add(upper, elbow);
        B.add(sh);
        this.mats.push(upper.material);
        return { sh, elbow, side };
      });
    }

    setKeeper(keeper) {
      if (keeper === this.keeper) return;
      this.build(this.home, keeper);
    }

    // Highlight the slot you control: shirt glows gold.
    setGlow(level) {
      for (const m of this.mats) {
        m.emissive = new THREE.Color(level ? 0xffcc00 : 0x000000);
        m.emissiveIntensity = level;
      }
    }

    kick() { this.kickT = 0.38; }

    // dt seconds; vx/vy pitch-space velocity (m/s).
    update(dt, vx, vy) {
      const speed = Math.hypot(vx, vy);
      // Speed is smoothed so a one-tick stop doesn't snap the stride.
      this.speed += (speed - this.speed) * Math.min(1, dt * 10);
      const s = this.speed;
      const run = Math.min(s / 6, 1);         // 0 idle … 1 full sprint

      // Facing: turn toward travel (pitch y → three z), shortest way,
      // ~11 rad/s — a footballer re-plants in a step or two.
      if (speed > 0.4) {
        const want = Math.atan2(vx, vy);
        let d = want - this.yaw;
        d = ((d + Math.PI) % TAU + TAU) % TAU - Math.PI;
        this.yaw += d * Math.min(1, dt * 11);
      }
      this.root.rotation.y = this.yaw;

      // Stride: cadence rises with speed (~2.3 cycles/s at a sprint).
      this.phase = (this.phase + dt * (0.7 + s * 0.27)) % 1;
      const p = this.phase * TAU;
      const swing = 0.15 + 0.75 * run;        // hip amplitude (rad)

      for (let i = 0; i < 2; i++) {
        const leg = this.legs[i];
        const lp = p + i * Math.PI;           // legs in anti-phase
        const hipA = Math.sin(lp) * swing * (s > 0.3 ? 1 : 0);
        // Knee folds on the back-swing (heel kick), more when sprinting.
        const kneeA = s > 0.3
          ? Math.max(0, -Math.cos(lp)) * (0.4 + 1.1 * run)
          : 0.05;
        leg.hip.rotation.x = -hipA;
        leg.knee.rotation.x = kneeA;
      }
      for (const arm of this.arms) {
        const ap = p + (arm.side > 0 ? 0 : Math.PI);
        // Arms counter-swing the legs; elbows bend when running. Keepers
        // carry their hands up and out — the set position.
        if (this.keeper && s < 1.5) {
          arm.sh.rotation.x = -0.5;
          arm.sh.rotation.z = arm.side * 0.45;
          arm.elbow.rotation.x = -0.6;
        } else {
          arm.sh.rotation.x = Math.sin(ap) * swing * 0.85;
          arm.sh.rotation.z = arm.side * 0.08;
          arm.elbow.rotation.x = -(0.25 + 1.1 * run);
        }
      }

      // Lean into the run; bob twice per stride; idle breathing.
      this.body.rotation.x = 0.05 + 0.2 * run;
      this.body.position.y = s > 0.3
        ? Math.abs(Math.sin(p)) * 0.05 * run
        : Math.sin(performance.now() / 600 + this.slot) * 0.008;

      // Kick: the right leg winds back then strikes through, overriding
      // the stride for ~0.4 s; the opposite arm swings for balance.
      if (this.kickT > 0) {
        this.kickT = Math.max(0, this.kickT - dt);
        const k = 1 - this.kickT / 0.38;     // 0 → 1
        const leg = this.legs[1];
        const wind = k < 0.35 ? -0.9 * (k / 0.35) : -0.9 + 2.5 * ((k - 0.35) / 0.65);
        leg.hip.rotation.x = -wind;
        leg.knee.rotation.x = k < 0.35 ? 1.3 * (k / 0.35) : 1.3 * (1 - (k - 0.35) / 0.65);
        this.arms[0].sh.rotation.x = -0.9 * Math.sin(k * Math.PI);
        this.body.rotation.x = -0.12 * Math.sin(k * Math.PI);
      }
    }
  }

  window.PlayerFigure = PlayerFigure;
})();
