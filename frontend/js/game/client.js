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
    document.getElementById('joystick-knob'));

  const mySlots = new Set();
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
        for (const slot of mySlots) net.intent(slot, v.x, v.y);
      }, 1000 / (h.tickRate || 30));
    },
    onSnapshot(s) {
      renderer.pushSnapshot(s);
    },
    onClose() {
      statusEl.textContent = 'disconnected — reload to rejoin';
      if (intentTimer) clearInterval(intentTimer);
    },
  });

  // Claim on tap/click. A second tap on an owned player releases it.
  function pickAt(x, y) {
    if (!hello) return;
    const slot = renderer.pickSlot(x, y);
    if (slot === null) return;
    if (mySlots.has(slot)) {
      mySlots.delete(slot);
      net.release(slot);
    } else {
      mySlots.add(slot);
      net.claim(slot);
    }
    renderer.setMySlots(mySlots);
    statusEl.textContent = mySlots.size
      ? `controlling ${[...mySlots].map((s) => '#' + (s + 1)).join(', ')} — move with WASD / joystick`
      : 'tap a player to take control';
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
