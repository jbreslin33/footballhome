// frontend/js/game/client.js
//
// Orchestrates the G0 walking skeleton: connect → HELLO builds the scene →
// tap/click a player to claim it → drive it with keys or the joystick.
// All state shown is server snapshots; this file owns no game logic.

(function () {
  'use strict';

  const statusEl = document.getElementById('status');
  const boardEl = document.getElementById('scoreboard');
  const autoBtn = document.getElementById('btn-auto');
  const lvlHomeBtn = document.getElementById('btn-level-home');
  const lvlAwayBtn = document.getElementById('btn-level-away');
  const canvas = document.getElementById('game-canvas');
  const renderer = new GameRenderer(canvas);
  const input = new GameInput(
    document.getElementById('joystick'),
    document.getElementById('joystick-knob'),
    document.getElementById('btn-pass'),
    document.getElementById('btn-loft'));

  const mySlots = new Set();
  let activeSlot = null;  // the ONE slot the controls drive right now
  let autoSwitch = false; // AUTO: drive whichever held player is ball-nearest
  let hello = null;
  let intentTimer = null;
  let toastTimer = null;

  // Names for EVENT frames (PROTOCOL.md §7 / MatchEventType).
  const EVENT_NAMES = { 1: 'GOAL!', 2: 'Throw-in', 3: 'Goal kick',
                        4: 'Corner', 5: 'Kickoff', 6: 'Half time',
                        7: 'FULL TIME' };

  function toast(text, ms) {
    statusEl.textContent = text;
    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(updateStatus, ms || 2500);
  }

  // Live levels (from the snapshot 1.3 tail) + admin picker state.
  const levels = { home: 0, away: 0 };

  function sendLevels() {
    net.setLevels(levels.home, levels.away);
  }
  function paintLevelButtons() {
    if (lvlHomeBtn)
      lvlHomeBtn.textContent = 'H: ' + GameWire.LEVELS[levels.home];
    if (lvlAwayBtn)
      lvlAwayBtn.textContent = 'A: ' + GameWire.LEVELS[levels.away];
  }

  let reconnectTimer = null;
  function scheduleReconnect() {
    if (reconnectTimer) return;
    reconnectTimer = setTimeout(() => {
      reconnectTimer = null;
      statusEl.textContent = 'reconnecting…';
      net.connect();
    }, 1500);
  }

  const net = new GameNet({
    onHello(h) {
      hello = h;
      if (!renderer.built) {        // reconnects reuse the scene
        renderer.buildWorld(h);
        renderer.built = true;
      }
      // Admin capability (bit 3) shows the level pickers.
      if ((h.capabilities & 8) && lvlHomeBtn && lvlAwayBtn) {
        lvlHomeBtn.style.display = 'block';
        lvlAwayBtn.style.display = 'block';
        const cycle = (side) => {
          levels[side] = (levels[side] + 1) % GameWire.LEVELS.length;
          paintLevelButtons();
          sendLevels();
        };
        for (const [btn, side] of [[lvlHomeBtn, 'home'], [lvlAwayBtn, 'away']]) {
          btn.addEventListener('click', () => cycle(side));
          btn.addEventListener('touchstart', (e) => {
            e.preventDefault(); e.stopPropagation(); cycle(side);
          });
        }
      }
      statusEl.textContent =
        `match ${h.matchId} — tap a player to take control`;
      // Ship intents at tick rate for every slot we own. The server
      // samples (last write before its tick wins), so this cadence is
      // exactly right. [QUAKE]
      if (intentTimer) clearInterval(intentTimer);
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
      if (s.match && boardEl) {
        const m = s.match;
        if (m.levelHome !== undefined &&
            (m.levelHome !== levels.home || m.levelAway !== levels.away)) {
          levels.home = m.levelHome;
          levels.away = m.levelAway;
          paintLevelButtons();
        }
        const mm = String(Math.floor(m.clockSec / 60)).padStart(2, '0');
        const ss = String(m.clockSec % 60).padStart(2, '0');
        boardEl.textContent =
          `HOME ${m.score0} — ${m.score1} AWAY   ${mm}:${ss} ${m.period === 2 ? '2H' : '1H'}`;
      }
      // AUTO: hand the controls to whichever held player is ball-nearest.
      if (autoSwitch && mySlots.size > 1 && s.players) {
        let best = activeSlot, bestD = Infinity;
        for (const slot of mySlots) {
          const p = s.players[slot];
          if (!p) continue;
          const d = (p.x - s.ball.x) ** 2 + (p.y - s.ball.y) ** 2;
          if (d < bestD) { bestD = d; best = slot; }
        }
        if (best !== activeSlot) {
          activeSlot = best;
          renderer.setMySlots(mySlots, activeSlot);
          updateStatus();
        }
      }
    },
    onEvent(ev) {
      const name = EVENT_NAMES[ev.eventType] || 'event';
      if (ev.eventType === 1) {
        renderer.goalFlash();
        toast(`⚽ ${name}`, 3000);
      } else {
        const side = ev.eventType <= 5
          ? (ev.team === 0 ? ' — home' : ' — away') : '';
        toast(`${name}${side}`, 2000);
      }
    },
    onClose() {
      // Claims died with the socket; drop them and come back by ourselves
      // (phones sleep, wifi blips — a sandbox should just rejoin).
      if (intentTimer) { clearInterval(intentTimer); intentTimer = null; }
      mySlots.clear();
      activeSlot = null;
      renderer.setMySlots(mySlots, activeSlot);
      statusEl.textContent = 'connection lost — reconnecting…';
      scheduleReconnect();
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
  if (autoBtn) {
    const flip = () => {
      autoSwitch = !autoSwitch;
      autoBtn.style.background =
        autoSwitch ? 'rgba(255,204,0,.5)' : 'rgba(255,255,255,.12)';
    };
    autoBtn.addEventListener('click', flip);
    autoBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); flip();
    });
  }

  // Q cycles which held player you're driving (G2.6).
  window.addEventListener('keydown', (e) => {
    if (e.key.toLowerCase() !== 'q' || mySlots.size < 2) return;
    const list = [...mySlots];
    activeSlot = list[(list.indexOf(activeSlot) + 1) % list.length];
    renderer.setMySlots(mySlots, activeSlot);
    updateStatus();
  });

  canvas.addEventListener('click', (e) => pickAt(e.clientX, e.clientY));
  canvas.addEventListener('touchstart', (e) => {
    const t = e.touches[0];
    // Upper part of the screen only — lower part belongs to the joystick.
    if (t && t.clientY < window.innerHeight * 0.4) pickAt(t.clientX, t.clientY);
  });

  function loop() {
    renderer.frame();
    // Stale-socket watchdog: a dead TCP path can go minutes without a
    // close event. No snapshot for 4 s while "open" → force the close
    // path, which reconnects.
    if (renderer.lastSnapshotAt &&
        performance.now() - renderer.lastSnapshotAt > 4000 &&
        net.ws && net.ws.readyState === WebSocket.OPEN) {
      renderer.lastSnapshotAt = 0;
      try { net.ws.close(); } catch (e) {}
    }
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
