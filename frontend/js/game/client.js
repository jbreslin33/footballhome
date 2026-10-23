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
  const editBtn = document.getElementById('btn-edit');
  const editPanel = document.getElementById('edit-panel');
  const presetBar = document.getElementById('preset-bar');
  const presetSelect = document.getElementById('preset-select');
  const canvas = document.getElementById('game-canvas');
  const renderer = new GameRenderer(canvas);
  const input = new GameInput(
    document.getElementById('joystick'),
    document.getElementById('joystick-knob'),
    document.getElementById('btn-pass'),
    document.getElementById('btn-loft'),
    document.getElementById('btn-tackle'));

  const mySlots = new Set();
  let activeSlot = null;  // the ONE slot the controls drive right now
  let autoSwitch = false; // AUTO: drive whichever held player is ball-nearest
  let hello = null;
  let intentTimer = null;
  let toastTimer = null;

  // Names for EVENT frames (PROTOCOL.md §7 / MatchEventType).
  const EVENT_NAMES = { 1: 'GOAL!', 2: 'Throw-in', 3: 'Goal kick',
                        4: 'Corner', 5: 'Kickoff', 6: 'Half time',
                        7: 'FULL TIME', 10: 'Offside' };

  function toast(text, ms) {
    statusEl.textContent = text;
    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(updateStatus, ms || 2500);
  }

  // Live levels (from the snapshot 1.3 tail) + admin picker state.
  const levels = { home: 0, away: 0 };
  let roster = [];        // [{ratings, name}] per slot, server-authoritative
  let presets = [];       // style-preset names (mig 630); id = index
  let editMode = false;   // admin: tap a player to open his knowledge

  // Paint a team identity in one tap (CONCEPTS.md schools; wire 1.4).
  function paintPresetBar() {
    if (!presetBar) return;
    presetBar.style.display =
      editMode && presets.length ? 'flex' : 'none';
  }
  for (const [btnId, team, label] of [['preset-home', 0, 'HOME'],
                                      ['preset-away', 1, 'AWAY']]) {
    const btn = document.getElementById(btnId);
    if (!btn) continue;
    btn.addEventListener('click', () => {
      const id = presetSelect.selectedIndex;
      if (id < 0) return;
      net.applyPreset(team, id);
      toast(presets[id] + ' → ' + label);
    });
  }

  function openEditPanel(slot) {
    const e = roster[slot] || { ratings: [], name: '#' + (slot + 1) };
    let html = `<b>${e.name}</b> <span style="opacity:.6">(slot ${slot + 1})</span>
      <div style="max-height:52vh;overflow-y:auto;margin-top:6px;">`;
    GameWire.CONCEPTS.forEach((c, i) => {
      const v = e.ratings[i] || 0;
      html += `<div style="display:flex;align-items:center;gap:6px;margin:2px 0;">
        <span style="width:92px;font-size:11px;">${c}</span>
        <input type="range" min="0" max="100" value="${v}" data-idx="${i}"
               style="flex:1;" oninput="this.nextElementSibling.textContent=this.value">
        <span style="width:26px;text-align:right;font-size:11px;">${v}</span></div>`;
    });
    html += `</div><div style="margin-top:8px;text-align:right;">
      <button id="ep-close">close</button>
      <button id="ep-apply" style="background:#ffcc00;color:#0b1c3d;
        border:none;padding:4px 14px;border-radius:6px;font-weight:700;">APPLY</button></div>`;
    editPanel.innerHTML = html;
    editPanel.style.display = 'block';
    editPanel.querySelector('#ep-close').onclick = () =>
      (editPanel.style.display = 'none');
    editPanel.querySelector('#ep-apply').onclick = () => {
      const ratings = new Array(GameWire.CONCEPTS.length).fill(0);
      editPanel.querySelectorAll('input[data-idx]').forEach((sl) => {
        ratings[+sl.dataset.idx] = +sl.value;
      });
      net.setConcepts(slot, ratings);
      editPanel.style.display = 'none';
    };
  }

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
      if ((h.capabilities & 8) && editBtn) {
        editBtn.style.display = 'block';
        const flipEdit = () => {
          editMode = !editMode;
          editBtn.style.background =
            editMode ? 'rgba(255,204,0,.5)' : 'rgba(255,255,255,.12)';
          if (!editMode) editPanel.style.display = 'none';
          paintPresetBar();
        };
        editBtn.addEventListener('click', flipEdit);
        editBtn.addEventListener('touchstart', (e) => {
          e.preventDefault(); e.stopPropagation(); flipEdit();
        });
      }
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
        `match ${h.matchId} — tap a player to take control · drag to rotate`;
      // Ship intents at tick rate for every slot we own. The server
      // samples (last write before its tick wins), so this cadence is
      // exactly right. [QUAKE]
      if (intentTimer) clearInterval(intentTimer);
      intentTimer = setInterval(() => {
        if (mySlots.size === 0) return;
        // Controls are CAMERA-relative: "up" means away from the viewer
        // however the camera has been rotated.
        const v = renderer.screenToPitch(input.vector());
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
    onRoster(r) {
      roster = r;
    },
    onPresets(names) {
      presets = names;
      if (presetSelect) {
        presetSelect.innerHTML = '';
        names.forEach((n) => {
          const o = document.createElement('option');
          o.textContent = n;
          presetSelect.appendChild(o);
        });
      }
      paintPresetBar();
    },
    onEvent(ev) {
      // Tackles (8/9) fire dozens of times a match — not toast-worthy.
      if (!EVENT_NAMES[ev.eventType]) return;
      const name = EVENT_NAMES[ev.eventType];
      if (ev.eventType === 1) {
        renderer.goalFlash();
        renderer.celebrate(ev.team);
        toast(`⚽ ${name}`, 3000);
      } else {
        const side = ev.eventType === 10
          ? (ev.team === 0 ? ' — free kick home' : ' — free kick away')
          : ev.eventType <= 5 ? (ev.team === 0 ? ' — home' : ' — away') : '';
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
    if (editMode) {           // admin edit screen: inspect, don't claim
      openEditPanel(slot);
      return;
    }
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
    const myName = roster[activeSlot]
      ? roster[activeSlot].name : '#' + (activeSlot + 1);
    statusEl.textContent =
      `driving ${myName}` +
      (others.length ? ` (also holding ${others.map((s) => '#' + (s + 1)).join(', ')} — tap to switch)` : '') +
      ' — WASD/joystick, Space pass, X loft · C or 1–6 camera, +/− zoom';
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

  // A click/tap claims — unless it turned into a camera drag.
  canvas.addEventListener('click', (e) => {
    if (renderer.rig.dragged) { renderer.rig.dragged = false; return; }
    pickAt(e.clientX, e.clientY);
  });
  let tapStart = null;
  canvas.addEventListener('touchstart', (e) => {
    const t = e.touches[0];
    // Upper part of the screen only — lower part belongs to the joystick.
    tapStart = (e.touches.length === 1 && t && t.clientY < window.innerHeight * 0.4)
      ? { x: t.clientX, y: t.clientY } : null;
  });
  canvas.addEventListener('touchend', (e) => {
    const t = e.changedTouches[0];
    if (tapStart && t && !renderer.rig.dragged &&
        Math.hypot(t.clientX - tapStart.x, t.clientY - tapStart.y) < 8)
      pickAt(t.clientX, t.clientY);
    tapStart = null;
    renderer.rig.dragged = false;
  });

  // Camera: C or the CAM button cycles TV / FREE / BEHIND / TOP; any
  // drag rotates (free orbit), wheel or pinch zooms.
  const camBtn = document.getElementById('btn-cam');
  renderer.rig.onModeChange = (label) => {
    if (camBtn) camBtn.textContent = 'CAM ' + label;
  };
  if (camBtn) {
    camBtn.textContent = 'CAM ' + renderer.rig.label();
    camBtn.addEventListener('click', () => renderer.rig.cycle());
    camBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); renderer.rig.cycle();
    });
  }
  // FOLLOW button or V: stop the camera tracking the ball so it can be
  // parked and panned (drag) anywhere on the site.
  const followBtn = document.getElementById('btn-follow');
  const toggleFollow = () => {
    renderer.rig.setFollow(!renderer.rig.follow);
    if (followBtn) {
      followBtn.textContent = renderer.rig.follow ? 'FOLLOW ON' : 'FOLLOW OFF';
      followBtn.style.background = renderer.rig.follow ? '' : 'rgba(255,204,0,.5)';
    }
  };
  if (followBtn) {
    followBtn.addEventListener('click', toggleFollow);
    followBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); toggleFollow();
    });
  }
  // Zoom: +/− buttons (hold repeats), + / − / = keys; wheel and pinch
  // are handled by the rig itself. 1–6 pick a camera directly.
  const zoomBy = (f) => renderer.rig.zoom(f);
  for (const [id, f] of [['btn-zoom-in', 0.85], ['btn-zoom-out', 1 / 0.85]]) {
    const el = document.getElementById(id);
    if (!el) continue;
    let rep = null;
    const start = (e) => {
      e.preventDefault(); e.stopPropagation();
      zoomBy(f);
      rep = setInterval(() => zoomBy(f), 120);
    };
    const stop = () => { if (rep) clearInterval(rep); rep = null; };
    el.addEventListener('mousedown', start);
    el.addEventListener('touchstart', start);
    for (const ev of ['mouseup', 'mouseleave', 'touchend', 'touchcancel'])
      el.addEventListener(ev, stop);
  }
  // Trees: see-through wire leaves by default; LEAVES button or L shows
  // solid foliage.
  const leavesBtn = document.getElementById('btn-leaves');
  let leavesOn = false;
  const toggleLeaves = () => {
    leavesOn = !leavesOn;
    if (renderer.field && renderer.field.setLeaves) renderer.field.setLeaves(leavesOn);
    if (leavesBtn) leavesBtn.textContent = leavesOn ? 'LEAVES ON' : 'LEAVES OFF';
  };
  if (leavesBtn) {
    leavesBtn.addEventListener('click', toggleLeaves);
    leavesBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); toggleLeaves();
    });
  }
  // Ground contours: button or K cycles lidar 10 cm (USGS 3DEP) → City
  // 2 ft → USGS topo 10 ft → all → off.
  const contoursBtn = document.getElementById('btn-contours');
  const CMODES = ['lidar', 'city', 'topo', 'all', 'off'];
  const CLABEL = { lidar: 'LIDAR 10CM', city: 'CITY 2FT', topo: 'USGS 10FT', all: 'ALL LINES',
                   off: 'CONTOURS OFF' };
  let cmode = 0;
  const toggleContours = () => {
    cmode = (cmode + 1) % CMODES.length;
    if (renderer.field && renderer.field.setContours) renderer.field.setContours(CMODES[cmode]);
    if (contoursBtn) contoursBtn.textContent = CLABEL[CMODES[cmode]];
  };
  if (contoursBtn) {
    contoursBtn.addEventListener('click', toggleContours);
    contoursBtn.addEventListener('touchstart', (e) => {
      e.preventDefault(); e.stopPropagation(); toggleContours();
    });
  }
  // Drag-and-drop pitch planner: live legality + water score.
  const planner = window.PitchPlanner ? window.PitchPlanner.attach(renderer) : null;
  // MODES over the one Lighthouse model (James 10/22: a "game" button and
  // a "design" button, later practice setup / barn night / rodeo — each
  // mode brings only its own controls, so none is cluttered). GAME: the
  // match + its controls, ball-follow, no contours. DESIGN: the pitch
  // planner, contours, camera parked; game-only controls hidden (CSS
  // body.mode-design .game-only). Remembered per device; GAME by default.
  const modeBar = document.getElementById('mode-bar');
  let mode = 'game';
  try {
    mode = localStorage.getItem('fh.game.mode') ||
      (localStorage.getItem('fh.game.planMode') === '1' ? 'design' : 'game');
  } catch (e) { /* default GAME */ }
  // Modes set up but not built yet (James: "setup the others functionally
  // but not implemented"): the model with the game controls cleared and a
  // note of what's coming.
  const COMING = {
    practice: '🦺 <b>Practice setup</b> — coming: place cones, grids and stations on the field so every coach knows where tonight\'s session goes.',
    barn: '🎪 <b>Barn night</b> — coming: simulate a fundraiser night at the barn, people arriving, going in and out.',
    rodeo: '🐂 <b>Rodeo night</b> — coming: the rodeo with the band, the bulls, and cars driving in.',
  };
  const modeNote = document.getElementById('mode-note');
  if (mode !== 'game' && mode !== 'design' && !COMING[mode]) mode = 'game';
  const applyMode = () => {
    const design = mode === 'design';
    const other = !!COMING[mode];
    document.body.classList.toggle('mode-design', design);
    document.body.classList.toggle('mode-other', other);
    // The match (players + ball) only in GAME and DESIGN; the other modes
    // show the complex itself — field, animals, buildings, trees.
    renderer.showMatch = !other;
    if (modeNote) modeNote.innerHTML = other ? COMING[mode] : '';
    if (planner) planner.setOn(design);
    if (modeBar) for (const b of modeBar.querySelectorAll('button')) b.classList.toggle('on', b.dataset.mode === mode);
    if (!renderer.field || !renderer.field.setContours) { setTimeout(applyMode, 300); return; }
    cmode = CMODES.indexOf(design ? 'lidar' : 'off');
    renderer.field.setContours(CMODES[cmode]);
    if (contoursBtn) contoursBtn.textContent = CLABEL[CMODES[cmode]];
    // Ball-follow only in GAME; every other mode parks the camera.
    if (renderer.rig.follow !== (mode === 'game')) toggleFollow();
  };
  const setMode = (m) => {
    if (m === mode) return;
    mode = m;
    try { localStorage.setItem('fh.game.mode', mode); } catch (e) { /* this visit only */ }
    applyMode();
  };
  if (modeBar) {
    for (const b of modeBar.querySelectorAll('button')) {
      b.addEventListener('click', (e) => { e.preventDefault(); e.stopPropagation(); setMode(b.dataset.mode); });
      b.addEventListener('touchstart', (e) => { e.preventDefault(); e.stopPropagation(); setMode(b.dataset.mode); });
    }
  }
  applyMode();
  const CAMS = ['broadcast', 'ball', 'third', 'first', 'top', 'orbit'];
  window.addEventListener('keydown', (e) => {
    const k = e.key.toLowerCase();
    if (k === 'c' && !e.repeat) renderer.rig.cycle();
    if (k === 'l' && !e.repeat) toggleLeaves();
    if (k === 'k' && !e.repeat) toggleContours();
    if (k === 'v' && !e.repeat) toggleFollow();
    if (k === '+' || k === '=') zoomBy(0.85);
    if (k === '-' || k === '_') zoomBy(1 / 0.85);
    if (k >= '1' && k <= '6' && !e.repeat) renderer.rig.setMode(CAMS[+k - 1]);
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
