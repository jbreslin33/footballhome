// frontend/js/game/input.js
//
// Keyboard (WASD / arrows) + virtual touch joystick. Produces a desire
// vector in pitch space; client.js samples it at tick rate and ships
// PLAYER_INTENT frames. The server clamps to unit length regardless —
// input code is untrusted by design. [QUAKE]
//
// Touch scheme (DESIGN.md §7 — controls are a first-class concern):
// touch anywhere on the lower-left half → a joystick anchors at the touch
// point; drag sets direction/magnitude; release = stop.

(function () {
  'use strict';

  class GameInput {
    constructor(joystickEl, knobEl, passBtn, loftBtn, tackleBtn) {
      this.keys = new Set();
      this.joy = { active: false, x: 0, y: 0 };
      this.joystickEl = joystickEl;
      this.knobEl = knobEl;
      this.pendingAction = 0; // one-shot: consumed by the next intent send

      window.addEventListener('keydown', (e) => {
        if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' ']
              .includes(e.key))
          e.preventDefault();
        if (e.key === ' ' && !e.repeat) this.pendingAction = 1;      // pass
        if (e.key.toLowerCase() === 'x' && !e.repeat) this.pendingAction = 2; // loft
        if (e.key.toLowerCase() === 'f' && !e.repeat) this.pendingAction = 5; // tackle
        this.keys.add(e.key.toLowerCase());
      });

      // Touch kick buttons (lower-right). touchstart so they beat the
      // joystick's window-level handler via stopPropagation.
      if (passBtn) passBtn.addEventListener('touchstart', (e) => {
        e.preventDefault(); e.stopPropagation(); this.pendingAction = 1;
      });
      if (loftBtn) loftBtn.addEventListener('touchstart', (e) => {
        e.preventDefault(); e.stopPropagation(); this.pendingAction = 2;
      });
      if (tackleBtn) tackleBtn.addEventListener('touchstart', (e) => {
        e.preventDefault(); e.stopPropagation(); this.pendingAction = 5;
      });
      if (tackleBtn) tackleBtn.addEventListener('click', () => { this.pendingAction = 5; });
      if (passBtn) passBtn.addEventListener('click', () => { this.pendingAction = 1; });
      if (loftBtn) loftBtn.addEventListener('click', () => { this.pendingAction = 2; });
      window.addEventListener('keyup', (e) =>
        this.keys.delete(e.key.toLowerCase()));

      window.addEventListener('touchstart', (e) => this.touch(e), { passive: false });
      window.addEventListener('touchmove', (e) => this.touch(e), { passive: false });
      window.addEventListener('touchend', () => this.touchEnd());
      window.addEventListener('touchcancel', () => this.touchEnd());
    }

    touch(e) {
      const t = e.touches[0];
      if (!t) return;
      if (!this.joy.active) {
        // Anchor only in the lower 60% of the screen so taps on players
        // (claiming) still work up top.
        if (t.clientY < window.innerHeight * 0.4) return;
        this.joy.active = true;
        this.joy.ox = t.clientX;
        this.joy.oy = t.clientY;
        this.joystickEl.style.display = 'block';
        this.joystickEl.style.left = (t.clientX - 60) + 'px';
        this.joystickEl.style.top = (t.clientY - 60) + 'px';
      }
      e.preventDefault();
      const R = 50;
      let dx = t.clientX - this.joy.ox, dy = t.clientY - this.joy.oy;
      const len = Math.hypot(dx, dy);
      if (len > R) { dx = dx / len * R; dy = dy / len * R; }
      this.knobEl.style.transform = `translate(${dx}px, ${dy}px)`;
      this.joy.x = dx / R;
      this.joy.y = dy / R;
    }

    touchEnd() {
      this.joy.active = false;
      this.joy.x = 0;
      this.joy.y = 0;
      this.joystickEl.style.display = 'none';
      this.knobEl.style.transform = 'translate(0px, 0px)';
    }

    // One-shot action for the next intent (0 after the read).
    consumeAction() {
      const a = this.pendingAction;
      this.pendingAction = 0;
      return a;
    }

    // Desire vector in PITCH space. Screen-up = pitch −y because the
    // broadcast camera looks down −z (renderer maps pitch y → three z).
    vector() {
      let x = 0, y = 0;
      if (this.keys.has('w') || this.keys.has('arrowup')) y -= 1;
      if (this.keys.has('s') || this.keys.has('arrowdown')) y += 1;
      if (this.keys.has('a') || this.keys.has('arrowleft')) x -= 1;
      if (this.keys.has('d') || this.keys.has('arrowright')) x += 1;
      x += this.joy.x;
      y += this.joy.y;
      const len = Math.hypot(x, y);
      if (len > 1) { x /= len; y /= len; }
      return { x, y };
    }
  }

  window.GameInput = GameInput;
})();
