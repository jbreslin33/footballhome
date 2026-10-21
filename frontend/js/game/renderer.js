// frontend/js/game/renderer.js
//
// Three.js view of the authoritative world: a pitch plane, one capsule per
// slot, broadcast-angle camera (DESIGN.md §7 — readable on a 6" phone).
// Pure dressing: nothing here affects gameplay.
//
// Snapshot interpolation [QUAKE]: render ~100 ms in the past, lerping
// between the two snapshots that bracket the render time. Jitter in frame
// arrival disappears; the cost is imperceptible latency.

(function () {
  'use strict';

  const INTERP_DELAY_MS = 100;

  class GameRenderer {
    constructor(canvas) {
      this.canvas = canvas;
      this.players = []; // THREE.Mesh per slot
      this.buffer = []; // [{at, snap}] arrival-stamped snapshots
      this.tickRate = 30;
      this.mySlots = new Set();

      this.scene = new THREE.Scene();
      this.scene.background = new THREE.Color(0x0b1c3d); // club navy sky

      this.camera = new THREE.PerspectiveCamera(
        45, window.innerWidth / window.innerHeight, 0.1, 500);
      this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
      this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

      const sun = new THREE.DirectionalLight(0xffffff, 0.9);
      sun.position.set(30, 80, 20);
      this.scene.add(sun);
      this.scene.add(new THREE.AmbientLight(0xffffff, 0.45));

      window.addEventListener('resize', () => this.resize());
      this.resize();
    }

    resize() {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    }

    // Build pitch + players once HELLO tells us the dimensions.
    buildWorld(hello) {
      this.tickRate = hello.tickRate || 30;
      const hx = hello.pitchHalfX, hy = hello.pitchHalfY;

      // Grass. Sim x → three x, sim y → three z (three y is up).
      const grass = new THREE.Mesh(
        new THREE.PlaneGeometry(hx * 2 + 10, hy * 2 + 10),
        new THREE.MeshLambertMaterial({ color: 0x2e7d32 }));
      grass.rotation.x = -Math.PI / 2;
      this.scene.add(grass);

      // Markings: touchlines, halfway line, centre circle — thin white
      // lines drawn as LineLoops slightly above the grass.
      const mark = new THREE.LineBasicMaterial({ color: 0xffffff });
      const rect = new THREE.BufferGeometry().setFromPoints([
        new THREE.Vector3(-hx, 0.02, -hy), new THREE.Vector3(hx, 0.02, -hy),
        new THREE.Vector3(hx, 0.02, hy), new THREE.Vector3(-hx, 0.02, hy),
      ]);
      this.scene.add(new THREE.LineLoop(rect, mark));
      const half = new THREE.BufferGeometry().setFromPoints([
        new THREE.Vector3(0, 0.02, -hy), new THREE.Vector3(0, 0.02, hy)]);
      this.scene.add(new THREE.Line(half, mark));
      const circlePts = [];
      for (let i = 0; i <= 48; i++) {
        const a = (i / 48) * Math.PI * 2;
        circlePts.push(new THREE.Vector3(
          Math.cos(a) * 9.15, 0.02, Math.sin(a) * 9.15));
      }
      this.scene.add(new THREE.LineLoop(
        new THREE.BufferGeometry().setFromPoints(circlePts), mark));

      // Players: slots [0, n/2) = home (club navy/gold), rest = away (white).
      const half_n = Math.floor(hello.slotCount / 2);
      for (let i = 0; i < hello.slotCount; i++) {
        const home = i < half_n;
        const body = new THREE.Mesh(
          new THREE.CylinderGeometry(0.45, 0.45, 1.8, 12),
          new THREE.MeshLambertMaterial({ color: home ? 0x14326e : 0xf4f6fb }));
        body.position.y = 0.9;
        const group = new THREE.Group();
        group.add(body);
        group.userData.slot = i;
        group.userData.body = body;
        this.scene.add(group);
        this.players.push(group);
      }

      // Broadcast camera: raised, behind the home touchline, whole pitch
      // in frame on a phone held landscape or portrait.
      this.camera.position.set(0, Math.max(hx, 60) * 0.9, hy * 2.4);
      this.camera.lookAt(0, 0, 0);
    }

    pushSnapshot(snap) {
      this.buffer.push({ at: performance.now(), snap });
      if (this.buffer.length > 90) this.buffer.splice(0, 30);
    }

    setMySlots(slots) {
      this.mySlots = slots;
      for (const g of this.players) {
        const mine = slots.has(g.userData.slot);
        g.userData.body.material.emissive =
          new THREE.Color(mine ? 0xffcc00 : 0x000000);
        g.userData.body.material.emissiveIntensity = mine ? 0.5 : 0;
      }
    }

    // Lerp between the two snapshots bracketing (now − delay).
    frame() {
      const n = this.buffer.length;
      if (n >= 1) {
        const t = performance.now() - INTERP_DELAY_MS;
        let a = this.buffer[0], b = this.buffer[n - 1];
        for (let i = n - 1; i > 0; i--) {
          if (this.buffer[i - 1].at <= t) { a = this.buffer[i - 1]; b = this.buffer[i]; break; }
        }
        const span = Math.max(b.at - a.at, 1);
        const alpha = Math.min(Math.max((t - a.at) / span, 0), 1);
        const count = Math.min(this.players.length, b.snap.players.length);
        for (let i = 0; i < count; i++) {
          const pa = a.snap.players[i], pb = b.snap.players[i];
          this.players[i].position.x = pa.x + (pb.x - pa.x) * alpha;
          this.players[i].position.z = pa.y + (pb.y - pa.y) * alpha;
        }
      }
      this.renderer.render(this.scene, this.camera);
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
