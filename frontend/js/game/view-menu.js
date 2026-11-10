// game/view-menu.js — ☰ VIEW menu (James 11/10: "by default shut off everything but the field,
// ball, players and refs … allow for everything to be shut on or off … all options in a menu as
// the gui is too cluttered"). One ViewMenu owns, in GAME mode only:
//   • DRAW  — what the 3D scene draws beyond the essentials (the Lighthouse site's layers, solid
//             leaves, contours, water, the 7v7 chalk, name tags, shadows, sharp resolution);
//   • SHOW  — which on-screen controls float over the pitch (elements tagged data-hud="<key>");
//   • the camera / brain / mode controls themselves, so a hidden button never strands a feature.
// Essentials (pitch + goals, ball, players, officials, scoreboard) are always drawn. Choices are
// remembered on this device (localStorage fh.game.view). DESIGN keeps its own layer pills: the
// menu applies nothing there, and re-applies when GAME comes back. FH original.
(function () {
  'use strict';
  const KEY = 'fh.game.view';

  // Scene items: key → label, field.js layers it switches, default.
  const DRAW = [
    { k: 'ground',    label: 'Site ground, courts & paint', layers: ['ground', 'paint'] },
    { k: 'buildings', label: 'Buildings',                    layers: ['buildings'] },
    { k: 'fences',    label: 'Fences',                       layers: (n) => n === 'fences' || (n.endsWith('_fences') && n !== 'proposed_lane_fences') },
    { k: 'props',     label: 'Bleachers, animals, cars',     layers: ['props'] },
    { k: 'trees',     label: 'Trees',                        layers: ['trees'] },
    { k: 'leaves',    label: '· solid leaves',               layers: [] },
    { k: 'labels',    label: 'Place labels',                 layers: ['labels'] },
    { k: 'contours',  label: 'Ground contours (lidar)',      layers: ['contours'] },
    { k: 'water',     label: 'Water & drainage',             layers: ['water', 'channels'] },
    { k: 'lane',      label: 'Proposed lane',                layers: ['proposed_lane', 'proposed_lane_fences'] },
    { k: 'seven',     label: '7v7 chalk',                    layers: [] },
    { k: 'tags',      label: 'Player name tags',             layers: [] },
  ];
  const QUALITY = [
    { k: 'shadows', label: 'Shadows' },
    { k: 'sharp',   label: 'Sharp (high-res screens)' },
  ];
  // On-screen controls: key → label (elements carry data-hud="<key>").
  const SHOW = [
    { k: 'status',  label: 'Status line' },
    { k: 'play',    label: 'Play buttons (PASS / LOFT / TKL / AUTO)' },
    { k: 'camera',  label: 'Camera buttons (CAM, zoom, follow)' },
    { k: 'brain',   label: 'Brain button + panels' },
    { k: 'replay',  label: 'Replay bar' },
    { k: 'speed',   label: 'Speed bar (admin)' },
    { k: 'match',   label: 'Matchup picker (admin)' },
    { k: 'edit',    label: 'EDIT lineup button (admin)' },
    { k: 'watch',   label: 'Watch-a-player list' },
    { k: 'modes',   label: 'Mode bar (GAME / DESIGN …)' },
  ];
  const ALL = [...DRAW, ...QUALITY, ...SHOW].map((o) => o.k);
  const ESSENTIAL = { sharp: true };   // everything else off: field, ball, players, refs only

  class ViewMenu {
    // hooks: { renderer, isGame(), cam: { label(), cycle(), zoom(f), follow(), toggleFollow() },
    //          brain: { on(), toggle() }, modes: { list: [[key, label]], current(), set(k) },
    //          syncSeven() }
    constructor(hooks) {
      this.h = hooks;
      this.v = ViewMenu.load();
      this.fps = { n: 0, t0: performance.now(), val: 0 };
      this.surround = null;
      this.injectCss();
      this.buildButton();
      this.buildPanel();
      this.applyHud();
      window.addEventListener('keydown', (e) => {
        if (e.target && /INPUT|SELECT|TEXTAREA/.test(e.target.tagName)) return;
        if (e.key.toLowerCase() === 'm' && !e.repeat) this.toggle();
        if (e.key === 'Escape' && this.open) this.toggle(false);
      });
    }

    static load() {
      let saved = null;
      try { saved = JSON.parse(localStorage.getItem(KEY) || 'null'); } catch (_) { /* defaults */ }
      const v = {};
      for (const k of ALL) v[k] = saved && k in saved ? !!saved[k] : !!ESSENTIAL[k];
      return v;
    }
    save() { try { localStorage.setItem(KEY, JSON.stringify(this.v)); } catch (_) { /* this visit only */ } }
    get(k) { return !!this.v[k]; }

    set(k, on) {
      this.v[k] = !!on;
      this.save();
      this.apply();
      this.paint();
    }
    setAll(on) {
      for (const k of ALL) this.v[k] = on ? true : !!ESSENTIAL[k];
      this.save();
      this.apply();
      this.paint();
    }

    injectCss() {
      const hud = SHOW.map((o) => `body.mode-game:not(.hud-${o.k}) [data-hud="${o.k}"]`).join(',\n');
      const st = document.createElement('style');
      st.textContent = `${hud} { display: none !important; }
        #view-btn { position: fixed; top: env(safe-area-inset-top, 8px); left: 78px; z-index: 30;
          margin-top: 4px; border: 1px solid rgba(255,204,0,.55); border-radius: 16px; padding: 5px 12px;
          background: rgba(10,14,20,.72); color: #ffcc00; font: 700 12px system-ui, sans-serif; cursor: pointer; }
        #view-btn[aria-expanded="true"] { background: #ffcc00; color: #0b1c3d; }
        #view-panel { position: fixed; top: calc(env(safe-area-inset-top, 8px) + 44px); left: 8px; z-index: 30;
          width: min(310px, calc(100vw - 16px)); max-height: calc(100vh - 64px); overflow: auto; box-sizing: border-box;
          background: rgba(8,12,18,.92); color: #f4f6fb; border: 1px solid rgba(255,255,255,.18);
          border-radius: 12px; padding: 10px 12px; font: 12px/1.4 system-ui, sans-serif; }
        #view-panel h3 { margin: 10px 0 4px; font: 700 11px system-ui, sans-serif; letter-spacing: 1px;
          color: #ffcc00; text-transform: uppercase; }
        #view-panel label { display: flex; align-items: center; gap: 8px; padding: 3px 0; cursor: pointer; }
        #view-panel input[type=checkbox] { margin: 0; width: 16px; height: 16px; min-width: 0; min-height: 0;
          accent-color: #ffcc00; }
        #view-panel .row { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
        #view-panel button { border: 0; border-radius: 10px; padding: 4px 10px; min-width: 0; min-height: 0;
          font: 700 11px system-ui, sans-serif; cursor: pointer; background: rgba(255,255,255,.15); color: #fff; }
        #view-panel button.on { background: #ffcc00; color: #0b1c3d; }
        #view-panel .fps { margin-left: auto; font: 700 11px ui-monospace, monospace; color: #9fe39f; }
        #view-panel .note { opacity: .7; font-size: 11px; margin-top: 8px; }`;
      document.head.appendChild(st);
    }

    buildButton() {
      const b = document.createElement('button');
      b.id = 'view-btn';
      b.type = 'button';
      b.textContent = '☰ View';
      b.title = 'What to draw and which controls to show (M)';
      b.setAttribute('aria-expanded', 'false');
      b.setAttribute('aria-controls', 'view-panel');
      b.addEventListener('click', (e) => { e.stopPropagation(); this.toggle(); });
      document.body.appendChild(b);
      this.btn = b;
    }

    buildPanel() {
      const p = document.createElement('div');
      p.id = 'view-panel';
      p.hidden = true;
      p.setAttribute('role', 'dialog');
      p.setAttribute('aria-label', 'View');
      const box = (o) => `<label><input type="checkbox" data-k="${o.k}"> ${o.label}</label>`;
      p.innerHTML =
        `<div class="row"><strong style="font-size:13px;">View</strong><span class="fps" data-fps>— fps</span></div>` +
        `<div class="row" style="margin-top:6px;">` +
        `<button type="button" data-act="essential" title="Field, ball, players and referees only">Essentials only</button>` +
        `<button type="button" data-act="all">Everything on</button></div>` +
        `<h3>Camera</h3><div class="row">` +
        `<button type="button" data-act="cam" title="Cycle the camera (C)"></button>` +
        `<button type="button" data-act="zin" aria-label="Zoom in">+</button>` +
        `<button type="button" data-act="zout" aria-label="Zoom out">−</button>` +
        `<button type="button" data-act="follow" title="Camera follows the ball (V)"></button></div>` +
        `<h3>Coach</h3><div class="row"><button type="button" data-act="brain" title="Each player's decision on the pitch"></button></div>` +
        `<h3>Draw on the field</h3>` +
        `<div class="note" style="margin:0 0 2px;">Always drawn: pitch, goals, ball, players, referees.</div>` +
        DRAW.map(box).join('') +
        `<h3>Quality</h3>` + QUALITY.map(box).join('') +
        `<h3>Show on screen</h3>` + SHOW.map(box).join('') +
        `<h3>Mode</h3><div class="row" data-modes></div>` +
        `<div class="note">M opens this menu. Saved on this device.</div>`;
      p.addEventListener('change', (e) => {
        const k = e.target.dataset && e.target.dataset.k;
        if (k) this.set(k, e.target.checked);
      });
      p.addEventListener('click', (e) => {
        const a = e.target.dataset && e.target.dataset.act;
        const m = e.target.dataset && e.target.dataset.mode;
        const { cam, brain } = this.h;
        if (a === 'essential') this.setAll(false);
        else if (a === 'all') this.setAll(true);
        else if (a === 'cam') cam.cycle();
        else if (a === 'zin') cam.zoom(0.85);
        else if (a === 'zout') cam.zoom(1 / 0.85);
        else if (a === 'follow') cam.toggleFollow();
        else if (a === 'brain') brain.toggle();
        else if (m) this.h.modes.set(m);
        else return;
        this.paint();
      });
      // Keys typed while the panel has focus still drive the game (WASD etc.) — only M / Esc are ours.
      document.addEventListener('click', (e) => {
        if (this.open && !p.contains(e.target) && e.target !== this.btn) this.toggle(false);
      });
      document.body.appendChild(p);
      this.panel = p;
      this.paint();
    }

    get open() { return !this.panel.hidden; }
    toggle(on) {
      const want = on === undefined ? this.panel.hidden : !!on;
      this.panel.hidden = !want;
      this.btn.setAttribute('aria-expanded', String(want));
      if (want) this.paint();
    }

    paint() {
      if (!this.panel) return;
      for (const el of this.panel.querySelectorAll('input[data-k]')) el.checked = this.get(el.dataset.k);
      const leaves = this.panel.querySelector('input[data-k="leaves"]');
      if (leaves) leaves.disabled = !this.get('trees');
      const { cam, brain, modes } = this.h;
      const q = (s) => this.panel.querySelector(s);
      q('[data-act="cam"]').textContent = '🎥 ' + cam.label();
      const f = q('[data-act="follow"]');
      f.textContent = cam.follow() ? 'Follow ball: on' : 'Follow ball: off';
      f.classList.toggle('on', cam.follow());
      const b = q('[data-act="brain"]');
      b.textContent = brain.on() ? '🧠 Brain on' : '🧠 Brain off';
      b.classList.toggle('on', brain.on());
      q('[data-modes]').innerHTML = modes.list.map(([k, label]) =>
        `<button type="button" data-mode="${k}" class="${modes.current() === k ? 'on' : ''}">${label}</button>`).join('');
    }

    // Body classes for the on-screen controls (CSS hides untagged ones in GAME only).
    applyHud() {
      for (const o of SHOW) document.body.classList.toggle('hud-' + o.k, this.get(o.k));
      document.body.classList.add('hud-ready');
    }

    // The scene: called by client.js whenever GAME is (re)applied, and on every change here.
    apply() {
      this.applyHud();
      const r = this.h.renderer;
      this.applyQuality(r);
      if (!this.h.isGame()) return;
      const f = r.field;
      if (!f || !f.setLayer) return;   // client.js re-runs applyMode until the site is built
      for (const o of DRAW) {
        const names = typeof o.layers === 'function' ? (f.layers || []).filter(o.layers) : o.layers;
        for (const l of names) f.setLayer(l, this.get(o.k));
      }
      if (f.setContours) f.setContours(this.get('contours') ? 'lidar' : 'off');
      if (f.setWater) f.setWater(this.get('water'));
      if (f.setLeaves) f.setLeaves(this.get('leaves'));
      this.h.syncSeven();
      for (const fig of r.figures || []) if (fig.tag) fig.tag.visible = this.get('tags');
      this.applySurround(r);
    }

    // Without the site's ground, a plain grass apron (one quad) so the pitch isn't floating in sky.
    applySurround(r) {
      const show = !this.get('ground');
      if (!this.surround && show) {
        this.surround = new THREE.Mesh(new THREE.PlaneGeometry(1200, 1200),
          new THREE.MeshLambertMaterial({ color: 0x3f6b35 }));
        this.surround.rotation.x = -Math.PI / 2;
        this.surround.position.y = -0.13;
        this.surround.receiveShadow = true;
        r.scene.add(this.surround);
      }
      if (this.surround) this.surround.visible = show;
    }

    applyQuality(r) {
      const sharp = this.get('sharp');
      const ratio = sharp ? Math.min(window.devicePixelRatio || 1, 2) : 1;
      if (r.renderer.getPixelRatio() !== ratio) {
        r.renderer.setPixelRatio(ratio);
        r.resize();
      }
      const shadows = this.get('shadows');
      if (r.renderer.shadowMap.enabled !== shadows) {
        r.renderer.shadowMap.enabled = shadows;
        if (r.sun) r.sun.castShadow = shadows;
        // Materials compile with or without the shadow code: recompile once.
        r.scene.traverse((o) => {
          const m = o.material;
          if (!m) return;
          for (const mm of Array.isArray(m) ? m : [m]) mm.needsUpdate = true;
        });
      }
    }

    // Once a frame from client.js's loop: the fps readout (only while the panel is open)
    // and name tags the roster attached since the last apply.
    tick() {
      const F = this.fps;
      F.n++;
      const now = performance.now();
      if (now - F.t0 >= 1000) {
        F.val = Math.round(F.n * 1000 / (now - F.t0));
        F.n = 0; F.t0 = now;
        if (this.open) this.panel.querySelector('[data-fps]').textContent = F.val + ' fps';
        const tags = this.get('tags') || !this.h.isGame();
        for (const fig of this.h.renderer.figures || []) if (fig.tag && fig.tag.visible !== tags) fig.tag.visible = tags;
      }
    }
  }
  window.ViewMenu = ViewMenu;
})();
