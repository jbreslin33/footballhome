// frontend/js/game/site-client.js — the Lighthouse site page (lighthouse-site.html).
//
// The 3D model of Lighthouse Field and the drag-and-drop pitch planner (pitch-planner.js),
// on their own page. They used to be the 📐 DESIGN mode inside game.html; the game page is
// the pure Premier League sim now (owner 11/24: "game needs to get rid of old lh stuff and
// controls" · "own page"), so the site and the planner live here: no match, no socket, no
// players — the same renderer with nobody on the pitch, the planner on from the start.
(function () {
  'use strict';
  const canvas = document.getElementById('game-canvas');
  const renderer = new GameRenderer(canvas);
  // The renderer's world wants what a match's HELLO carries: the pitch size, nobody on it.
  renderer.buildWorld({ matchId: 0, tickRate: 30, slotCount: 0, capabilities: 0, pitchHalfX: 52.5, pitchHalfY: 34 });
  renderer.built = true;
  renderer.showMatch = false;

  const tap = (el, fn) => {
    if (!el) return;
    el.addEventListener('click', fn);
    el.addEventListener('touchstart', (e) => { e.preventDefault(); e.stopPropagation(); fn(); });
  };

  // Camera: C or the button cycles; drag rotates, wheel / pinch zooms (the rig's own).
  const camBtn = document.getElementById('btn-cam');
  renderer.rig.onModeChange = (label) => { if (camBtn) camBtn.textContent = 'CAM ' + label; };
  if (camBtn) camBtn.textContent = 'CAM ' + renderer.rig.label();
  tap(camBtn, () => renderer.rig.cycle());
  const zoomBy = (f) => renderer.rig.zoom(f);
  for (const [id, f] of [['btn-zoom-in', 0.85], ['btn-zoom-out', 1 / 0.85]]) {
    const el = document.getElementById(id);
    if (!el) continue;
    let rep = null;
    const start = (e) => { e.preventDefault(); e.stopPropagation(); zoomBy(f); rep = setInterval(() => zoomBy(f), 120); };
    const stop = () => { if (rep) clearInterval(rep); rep = null; };
    el.addEventListener('mousedown', start);
    el.addEventListener('touchstart', start);
    for (const ev of ['mouseup', 'mouseleave', 'touchend', 'touchcancel']) el.addEventListener(ev, stop);
  }
  // There is no ball to follow here: the camera is parked and panned.
  if (renderer.rig.follow) renderer.rig.setFollow(false);

  // Trees: see-through wire leaves by default; the button or L shows solid foliage.
  const leavesBtn = document.getElementById('btn-leaves');
  let leavesOn = false;
  const toggleLeaves = () => {
    leavesOn = !leavesOn;
    if (renderer.field && renderer.field.setLeaves) renderer.field.setLeaves(leavesOn);
    if (leavesBtn) leavesBtn.textContent = leavesOn ? 'LEAVES ON' : 'LEAVES OFF';
  };
  tap(leavesBtn, toggleLeaves);
  // Ground contours: lidar 10 cm, city 2 ft, USGS 10 ft, all, off.
  const contoursBtn = document.getElementById('btn-contours');
  const CMODES = ['lidar', 'city', 'topo', 'all', 'off'];
  const CLABEL = { lidar: 'LIDAR 10CM', city: 'CITY 2FT', topo: 'USGS 10FT', all: 'ALL LINES', off: 'CONTOURS OFF' };
  let cmode = 0;
  const toggleContours = () => {
    cmode = (cmode + 1) % CMODES.length;
    if (renderer.field && renderer.field.setContours) renderer.field.setContours(CMODES[cmode]);
    if (contoursBtn) contoursBtn.textContent = CLABEL[CMODES[cmode]];
  };
  tap(contoursBtn, toggleContours);

  // The planner: live legality + water score. Its layer pills decide contours, today's pitch
  // and water once it is on; the site finishes building a moment after the page does.
  const planner = window.PitchPlanner ? window.PitchPlanner.attach(renderer) : null;
  const start = () => {
    if (planner) planner.setOn(true);
    if (!renderer.field || !renderer.field.setContours) { setTimeout(start, 300); return; }
    renderer.field.setContours(CMODES[cmode]);
    if (renderer.field.setOldPitch) renderer.field.setOldPitch(true);   // today's yellow painted pitch
    if (planner) planner.setOn(true);
  };
  start();

  window.addEventListener('keydown', (e) => {
    if (e.target && /INPUT|SELECT|TEXTAREA/.test(e.target.tagName)) return;
    const k = e.key.toLowerCase();
    if (k === 'c' && !e.repeat) renderer.rig.cycle();
    if (k === 'l' && !e.repeat) toggleLeaves();
    if (k === 'k' && !e.repeat) toggleContours();
    if (k === '+' || k === '=') zoomBy(0.85);
    if (k === '-' || k === '_') zoomBy(1 / 0.85);
  });

  (function loop() { renderer.frame(); requestAnimationFrame(loop); })();
  window.__site = { renderer, planner };
})();
