// frontend/js/game/camera.js
//
// Camera rig: one spherical camera (target, yaw, pitch, distance) that
// eases toward the current MODE's goal, so switching views never cuts.
//   TV    — broadcast: raised side-on, follows the play tight enough that
//           the pitch fills the screen
//   BALL  — chase cam: low and close, trailing the ball
//   3RD   — third person: behind YOUR player (or the ball carrier when
//           you hold no one), looking up the pitch he attacks
//   1ST   — first person: at his eye line, looking where he faces
//   TOP   — overhead tactical
//   FREE  — drag to orbit anywhere
// ZOOM works in every mode (wheel, pinch, the +/− buttons): it scales the
// mode's distance; in 1ST it narrows/widens the field of view. Any drag
// rotates (dropping into FREE). C or the CAM button cycles.
// screenToPitch() maps screen directions onto the pitch so "up" on the
// keys/joystick is always away from the viewer.

(function () {
  'use strict';

  const MODES = ['broadcast', 'ball', 'third', 'first', 'top', 'orbit'];
  const LABEL = { broadcast: 'TV', ball: 'BALL', third: '3RD', first: '1ST',
                  top: 'TOP', orbit: 'FREE' };
  const wrap = (a) => ((a + Math.PI) % (Math.PI * 2) + Math.PI * 2) % (Math.PI * 2) - Math.PI;

  class CameraRig {
    constructor(camera, canvas) {
      this.camera = camera;
      this.canvas = canvas;
      this.mode = 'broadcast';
      this.target = new THREE.Vector3();
      this.cur = { yaw: 0, pitch: 0.58, dist: 60 };    // eased state
      this.user = { yaw: 0, pitch: 0.55, dist: 45 };   // FREE params
      this.zoomMul = 1;                                 // every other mode
      this.fov = 45;
      this.dragged = false;   // client checks to suppress a claim tap
      this.onModeChange = null;
      this.bindPointer();
    }

    setMode(m) {
      if (m === 'orbit' && this.mode !== 'orbit') {
        this.user.yaw = this.cur.yaw;
        this.user.pitch = Math.max(0.1, this.cur.pitch);
        this.user.dist = Math.min(this.cur.dist, 70);
      }
      this.mode = m;
      if (this.onModeChange) this.onModeChange(LABEL[m]);
    }
    cycle() { this.setMode(MODES[(MODES.indexOf(this.mode) + 1) % MODES.length]); }
    label() { return LABEL[this.mode]; }

    // f > 1 zooms OUT, f < 1 zooms IN.
    zoom(f) {
      if (this.mode === 'orbit') {
        this.user.dist = Math.min(220, Math.max(4, this.user.dist * f));
      } else {
        this.zoomMul = Math.min(3, Math.max(0.3, this.zoomMul * f));
      }
    }

    bindPointer() {
      const c = this.canvas;
      let down = null;
      c.addEventListener('contextmenu', (e) => e.preventDefault());
      c.addEventListener('mousedown', (e) => {
        down = { x: e.clientX, y: e.clientY, moved: false };
        this.dragged = false;
      });
      window.addEventListener('mousemove', (e) => {
        if (!down) return;
        const dx = e.clientX - down.x, dy = e.clientY - down.y;
        if (!down.moved && Math.hypot(dx, dy) < 5) return;
        if (!down.moved) { down.moved = true; this.dragged = true; this.setMode('orbit'); }
        this.rotate(e.movementX, e.movementY);
      });
      window.addEventListener('mouseup', () => { down = null; });
      c.addEventListener('wheel', (e) => {
        e.preventDefault();
        this.zoom(Math.exp(e.deltaY * 0.0012));
      }, { passive: false });

      // Touch: two fingers = pinch zoom (any mode) + midpoint drag rotate.
      // One finger in the upper area drags to rotate; a still tap there is
      // still a claim (client decides on touchend).
      let t2 = null, t1 = null;
      c.addEventListener('touchstart', (e) => {
        if (e.touches.length === 2) {
          const [a, b] = e.touches;
          t2 = { mx: (a.clientX + b.clientX) / 2, my: (a.clientY + b.clientY) / 2,
                 d: Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY) };
          t1 = null;
        } else if (e.touches.length === 1 &&
                   e.touches[0].clientY < window.innerHeight * 0.4) {
          t1 = { x: e.touches[0].clientX, y: e.touches[0].clientY, moved: false };
          this.dragged = false;
        }
      }, { passive: true });
      c.addEventListener('touchmove', (e) => {
        if (t2 && e.touches.length === 2) {
          const [a, b] = e.touches;
          const mx = (a.clientX + b.clientX) / 2, my = (a.clientY + b.clientY) / 2;
          const d = Math.hypot(a.clientX - b.clientX, a.clientY - b.clientY);
          if (t2.d > 0) this.zoom(t2.d / d);
          if (Math.hypot(mx - t2.mx, my - t2.my) > 2) {
            if (this.mode !== 'orbit') this.setMode('orbit');
            this.rotate(mx - t2.mx, my - t2.my);
          }
          t2 = { mx, my, d };
          this.dragged = true;
        } else if (t1 && e.touches.length === 1) {
          const t = e.touches[0];
          const dx = t.clientX - t1.x, dy = t.clientY - t1.y;
          if (!t1.moved && Math.hypot(dx, dy) < 8) return;
          if (!t1.moved) { t1.moved = true; this.dragged = true; this.setMode('orbit'); }
          this.rotate(dx, dy);
          t1.x = t.clientX; t1.y = t.clientY;
        }
      }, { passive: true });
      c.addEventListener('touchend', (e) => {
        if (e.touches.length < 2) t2 = null;
        if (e.touches.length === 0) t1 = null;
      });
    }

    rotate(dx, dy) {
      this.user.yaw -= dx * 0.006;
      this.user.pitch = Math.min(1.5, Math.max(0.04, this.user.pitch + dy * 0.004));
    }

    // ctx: { ball:{x,y,z}, me:{x,y,team,yaw}|null }
    update(dt, ctx) {
      const b = ctx.ball || { x: 0, y: 0, z: 0 };
      const m = ctx.me;
      const Z = this.zoomMul;
      let goal, tx = b.x, tz = b.y, ty = 0;
      // The ball's heading (for the chase cam).
      if (this.prevBall) {
        const vx = (b.x - this.prevBall.x) / Math.max(dt, 1e-3);
        const vz = (b.y - this.prevBall.y) / Math.max(dt, 1e-3);
        if (Math.hypot(vx, vz) > 2) this.ballHeading = Math.atan2(vx, vz);
      }
      this.prevBall = { x: b.x, y: b.y };

      switch (this.mode) {
        case 'broadcast':
          // TV: side-on, following the play — the pitch fills the frame.
          // Aim biased ~8 m toward the near side so BOTH touchlines fit
          // (unbiased, the near touchline fell below the frame).
          tx = b.x * 0.92; tz = b.y * 0.3 + 8;
          goal = { yaw: 0, pitch: 0.56,
                   dist: 58 * Z * Math.max(1, 1.3 / this.camera.aspect) };
          break;
        case 'ball': {
          // Chase: trail the ball's travel, low and close.
          const h = this.ballHeading !== undefined ? this.ballHeading : Math.PI / 2;
          ty = 1;
          goal = { yaw: h + Math.PI, pitch: 0.28, dist: 16 * Z };
          break;
        }
        case 'third':
          if (m) {
            const ax = m.team === 0 ? 1 : -1;     // home attacks +x
            tx = m.x + ax * 6; tz = m.y * 0.9; ty = 1;
            goal = { yaw: ax > 0 ? -Math.PI / 2 : Math.PI / 2, pitch: 0.3, dist: 17 * Z };
          } else {
            goal = { yaw: this.cur.yaw, pitch: 0.4, dist: 30 * Z };
          }
          break;
        case 'first':
          if (m) {
            // Eye line, looking where he faces. Zoom = field of view.
            const yaw = m.yaw !== undefined ? m.yaw : (m.team === 0 ? Math.PI / 2 : -Math.PI / 2);
            this.cur.yaw += wrap(yaw + Math.PI - this.cur.yaw) * Math.min(1, dt * 5);
            const fx = -Math.sin(this.cur.yaw), fz = -Math.cos(this.cur.yaw);
            this.camera.position.set(m.x - fx * 0.15, 1.7, m.y - fz * 0.15);
            this.camera.lookAt(m.x + fx * 20, 1.1, m.y + fz * 20);
            this.applyFov(Math.min(100, Math.max(25, 70 * Z)), dt);
            return;
          }
          goal = { yaw: this.cur.yaw, pitch: 0.4, dist: 30 * Z };
          break;
        case 'top':
          tx = b.x * 0.35; tz = 0;
          goal = { yaw: 0, pitch: 1.5, dist: 96 * Z * Math.max(1, 1.2 / this.camera.aspect) };
          break;
        default:  // FREE
          goal = { ...this.user };
      }
      this.applyFov(45, dt);
      const k = Math.min(1, dt * 4);
      this.target.x += (tx - this.target.x) * k;
      this.target.y += (ty - this.target.y) * k;
      this.target.z += (tz - this.target.z) * k;
      const kk = this.mode === 'orbit' ? Math.min(1, dt * 14) : k;
      this.cur.yaw += wrap(goal.yaw - this.cur.yaw) * kk;
      this.cur.pitch += (goal.pitch - this.cur.pitch) * kk;
      this.cur.dist += (goal.dist - this.cur.dist) * kk;

      const { yaw, pitch, dist } = this.cur;
      this.camera.position.set(
        this.target.x + dist * Math.sin(yaw) * Math.cos(pitch),
        Math.max(0.6, this.target.y + dist * Math.sin(pitch)),
        this.target.z + dist * Math.cos(yaw) * Math.cos(pitch));
      this.camera.lookAt(this.target);
    }

    applyFov(want, dt) {
      if (Math.abs(this.fov - want) < 0.05) return;
      this.fov += (want - this.fov) * Math.min(1, dt * 6);
      this.camera.fov = this.fov;
      this.camera.updateProjectionMatrix();
    }

    // Screen-space desire (x right, y DOWN) → pitch-space vector, relative
    // to where the camera is looking. Yaw 0 = the broadcast mapping
    // exactly (screen-up = pitch −y).
    screenToPitch(v) {
      const yaw = this.cur.yaw;
      const fx = -Math.sin(yaw), fz = -Math.cos(yaw);   // view forward
      const rx = Math.cos(yaw), rz = -Math.sin(yaw);    // view right
      return { x: rx * v.x - fx * v.y, y: rz * v.x - fz * v.y };
    }
  }

  window.CameraRig = CameraRig;
})();
