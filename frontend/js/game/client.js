// frontend/js/game/client.js
//
// Orchestrates the G0 walking skeleton: connect → HELLO builds the scene →
// tap/click a player to claim it → drive it with keys or the joystick.
// All state shown is server snapshots; this file owns no game logic.

(function () {
  'use strict';

  const statusEl = document.getElementById('status');
  const canvas = document.getElementById('game-canvas');
  const renderer = new GameRenderer(canvas);
  const input = new GameInput(
    document.getElementById('joystick'),
    document.getElementById('joystick-knob'),
    document.getElementById('btn-pass'),
    document.getElementById('btn-loft'));

  const mySlots = new Set();
  let activeSlot = null;  // the ONE slot the controls drive right now
  const score = [0, 0];
  let hello = null;
  let intentTimer = null;

  const net = new GameNet({
    onHello(h) {
      hello = h;
      renderer.buildWorld(h);
      statusEl.textContent =
        `match ${h.matchId} — tap a player to take control`;
      // Ship intents at tick rate for every slot we own. The server
      // samples (last write before its tick wins), so this cadence is
      // exactly right. [QUAKE]
      intentTimer = setInterval(() => {
        if (mySlots.size === 0) return;
        const v = input.vector();
        const action = input.consumeAction();
        // One input device drives ONE player. Other claimed slots get an
        // explicit zero vector each tick — the server samples intents and
        // would otherwise keep running their last one forever.
        for (const slot of mySlots) {
          if (slot === activeSlot) net.intent(slot, v.x, v.y, action);
          else net.intent(slot, 0, 0, 0);
        }
      }, 1000 / (h.tickRate || 30));
    },
    onSnapshot(s) {
      renderer.pushSnapshot(s);
    },
    onEvent(ev) {
      if (ev.eventType === 1) {
        score[ev.team]++;
        renderer.goalFlash();
        statusEl.textContent =
          `GOAL! ${score[0]} — ${score[1]}  (tap a player / WASD + Space to pass, X to loft)`;
      }
    },
    onClose() {
      statusEl.textContent = 'disconnected — reload to rejoin';
      if (intentTimer) clearInterval(intentTimer);
    },
  });

  // Tap rules: unclaimed → claim it AND make it the active one;
  // claimed-but-inactive → switch control to it; the active one → release
  // it (control falls to another claimed player if you still hold one).
  function pickAt(x, y) {
    if (!hello) return;
    const slot = renderer.pickSlot(x, y);
    if (slot === null) return;
    if (!mySlots.has(slot)) {
      mySlots.add(slot);
      net.claim(slot);
      activeSlot = slot;
    } else if (slot !== activeSlot) {
      activeSlot = slot;
    } else {
      mySlots.delete(slot);
      net.release(slot);
      activeSlot = mySlots.size ? [...mySlots][0] : null;
    }
    renderer.setMySlots(mySlots, activeSlot);
    updateStatus();
  }

  function updateStatus() {
    if (!mySlots.size) {
      statusEl.textContent = 'tap a player to take control';
      return;
    }
    const others = [...mySlots].filter((s) => s !== activeSlot);
    statusEl.textContent =
      `driving #${activeSlot + 1}` +
      (others.length ? ` (also holding ${others.map((s) => '#' + (s + 1)).join(', ')} — tap to switch)` : '') +
      ' — WASD/joystick, Space/PASS, X/LOFT';
  }
  canvas.addEventListener('click', (e) => pickAt(e.clientX, e.clientY));
  canvas.addEventListener('touchstart', (e) => {
    const t = e.touches[0];
    // Upper part of the screen only — lower part belongs to the joystick.
    if (t && t.clientY < window.innerHeight * 0.4) pickAt(t.clientX, t.clientY);
  });

  function loop() {
    renderer.frame();
    requestAnimationFrame(loop);
  }

  statusEl.textContent = 'connecting…';
  net.connect();
  loop();

  // Debug handle for automated testing and console poking — reads state,
  // never owns it (the server stays authoritative regardless).
  window.__game = { renderer, net, mySlots, pickAt, input,
                    get hello() { return hello; } };
})();
