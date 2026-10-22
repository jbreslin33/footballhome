// frontend/js/game/camera.js
//
// Camera rig: one spherical camera (target, yaw, pitch, distance) that
// eases toward the current MODE's goal, so switching views never cuts.
//   broadcast — raised side-on TV angle, pans with the ball (default)
//   orbit     — free: drag to rotate, wheel / pinch to zoom, follows ball
//   follow    — behind YOUR player, looking up the pitch he attacks
//   top       — tactical overhead, the whole shape at once
// Any drag rotates (and drops into orbit); C or the CAM button cycles.
// basis() lets input map screen directions onto the pitch, so "up" on
// the keys or joystick always means away from the viewer.

(function () {
  'use strict';

  const MODES = ['broadcast', 'orbit', 'follow', 'top'];
  const LABEL = { broadcast: 'TV', orbit: 'FREE', follow: 'BEHIND', top: 'TOP' };

  class CameraRig {
    constructor(camera, canvas) {
      this.camera = camera;
      this.canvas = canvas;
      this.mode = 'broadcast';
      this.target = new THREE.Vector3();
      this.cur = { yaw: 0, pitch: 0.6, dist: 52 };     // eased state
      this.user = { yaw: 0, pitch: 0.55, dist: 45 };   // orbit params
      this.dragged = false;   // client checks to suppress a claim tap
      this.onModeChange = null;
      this.bindPointer();
    }

    setMode(m) {
      if (m === 'orbit' && this.mode !== 'orbit') {
        // Enter free orbit from wherever the camera is now.
        this.user.yaw = this.cur.yaw;
        this.user.pitch = this.cur.pitch;
        this.user.dist = Math.min(this.cur.dist, 70);
      }
      this.mode = m;
      if (this.onModeChange) this.onModeChange(LABEL[m]);
    }
    cycle() {
      this.setMode(MODES[(MODES.indexOf(this.mode) + 1) % MODES.length]);
    }
    label() { return LABEL[this.mode]; }

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
        if (this.mode !== 'orbit') this.setMode('orbit');
        this.zoom(Math.exp(e.deltaY * 0.0012));
      }, { passive: false });

      // Touch: two fingers = rotate (midpoint drag) + pinch zoom. One
      // finger in the upper area (above the joystick zone) drags to rotate;
      // a still tap there is still a claim (client decides on touchend).
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
          if (this.mode !== 'orbit') this.setMode('orbit');
          this.rotate(mx - t2.mx, my - t2.my);
          if (t2.d > 0) this.zoom(t2.d / d);
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
      this.user.pitch = Math.min(1.45, Math.max(0.08, this.user.pitch + dy * 0.004));
    }
    zoom(f) {
      this.user.dist = Math.min(170, Math.max(6, this.user.dist * f));
    }

    // ctx: { ball:{x,y}, me:{x,y,team}|null, hx, hy }
    update(dt, ctx) {
      const b = ctx.ball || { x: 0, y: 0 };
      let goal, tx = b.x, tz = b.y;
      switch (this.mode) {
        case 'broadcast':
          // TV gantry: side-on from the home touchline, panning with play.
          tx = b.x * 0.75; tz = b.y * 0.25;
          // Gantry at the FRONT of the main stand's roof line, not inside
          // it (the roof filled the lower frame from 68 m out).
          goal = { yaw: 0, pitch: 0.6, dist: 52 };
          break;
        case 'top':
          tx = b.x * 0.3; tz = 0;
          goal = { yaw: 0, pitch: 1.45, dist: 92 };
          break;
        case 'follow': {
          const m = ctx.me;
          if (m) {
            // Behind the player, looking up the pitch he attacks (home
            // attacks +x): camera offset −x for home, +x for away.
            const ax = m.team === 0 ? 1 : -1;
            tx = m.x + ax * 7; tz = m.y * 0.85;
            goal = { yaw: ax > 0 ? -Math.PI / 2 : Math.PI / 2, pitch: 0.32, dist: 19 };
          } else {
            goal = { yaw: this.cur.yaw, pitch: 0.4, dist: 30 };
          }
          break;
        }
        default:  // orbit
          goal = { ...this.user };
      }
      const k = Math.min(1, dt * 4);
      this.target.x += (tx - this.target.x) * k;
      this.target.z += (tz - this.target.z) * k;
      let dy = goal.yaw - this.cur.yaw;
      dy = ((dy + Math.PI) % (Math.PI * 2) + Math.PI * 2) % (Math.PI * 2) - Math.PI;
      const kk = this.mode === 'orbit' ? Math.min(1, dt * 14) : k;
      this.cur.yaw += dy * kk;
      this.cur.pitch += (goal.pitch - this.cur.pitch) * kk;
      this.cur.dist += (goal.dist - this.cur.dist) * kk;

      const { yaw, pitch, dist } = this.cur;
      this.camera.position.set(
        this.target.x + dist * Math.sin(yaw) * Math.cos(pitch),
        this.target.y + dist * Math.sin(pitch),
        this.target.z + dist * Math.cos(yaw) * Math.cos(pitch));
      this.camera.lookAt(this.target);
    }

    // Screen-space desire (x right, y DOWN) → pitch-space vector, relative
    // to where the camera is looking. Yaw 0 = the old fixed broadcast
    // mapping exactly (screen-up = pitch −y).
    screenToPitch(v) {
      const yaw = this.cur.yaw;
      const fx = -Math.sin(yaw), fz = -Math.cos(yaw);   // view forward
      const rx = Math.cos(yaw), rz = -Math.sin(yaw);    // view right
      return { x: rx * v.x - fx * v.y, y: rz * v.x - fz * v.y };
    }
  }

  window.CameraRig = CameraRig;
})();
