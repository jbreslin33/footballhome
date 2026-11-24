// game/view-menu.js — ☰ VIEW menu (James 11/10: "by default shut off everything but the field,
// ball, players and refs … allow for everything to be shut on or off … all options in a menu as
// the gui is too cluttered"). One ViewMenu owns, in GAME mode only:
//   • DRAW  — what the 3D scene draws beyond the essentials (player name tags, shadows, sharp
//             resolution; the Lighthouse site's layers left with the site, lighthouse-site.html);
//   • SHOW  — which on-screen controls float over the pitch (elements tagged data-hud="<key>");
//   • the camera and brain controls themselves, so a hidden button never strands a feature.
//   • CONTROLS (James 11/17: "everything is supposed to be contained in 'menu' in top left that is
//     rolled up by default") — Home, status, EDIT, camera, view switch, Brain, Watch, speed, matchup,
//     kick-off and replay are MOVED into the panel, in the 2D view and the 3D view alike. Over the pitch
//     stay only the scoreboard, the brain's decision panels while Brain is on, and the touch play buttons
//     if switched on here (off by default).
// Essentials (pitch + goals, ball, players, officials, scoreboard) are always drawn. Choices are
// remembered on this device (localStorage fh.game.view). DESIGN keeps its own layer pills: the
// menu applies nothing there, and re-applies when GAME comes back. FH original.
(function () {
  'use strict';
  const KEY = 'fh.game.view';

  // Scene items: key → label, field.js layers it switches, default.
  const DRAW = [
    { k: 'tags',      label: 'Player name tags' },
  ];
  const QUALITY = [
    { k: 'shadows', label: 'Shadows' },
    { k: 'sharp',   label: 'Sharp (high-res screens)' },
  ];
  // On-screen controls that may float over the pitch (elements carry data-hud="<key>"); every other
  // data-hud control lives inside the panel (CONTAIN) and is always shown there.
  const SHOW = [];   // nothing floats over the pitch: the game is a sim to watch (James 11/24), no play buttons
  const CONTAIN = ['status', 'camera', 'brain', 'match', 'speed', 'replay', 'watch'];
  const ALL = [...DRAW, ...QUALITY, ...SHOW].map((o) => o.k);
  const ESSENTIAL = { sharp: true };   // everything else off: field, ball, players, refs only

  class ViewMenu {
    // hooks: { renderer, cam: { label(), cycle(), zoom(f), follow(), toggleFollow() },
    //          brain: { on(), toggle() } }
    constructor(hooks) {
      this.h = hooks;
      this.is3d = !!(hooks.renderer && hooks.renderer.renderer && hooks.renderer.scene);   // 2D: no scene to dress
      this.v = ViewMenu.load();
      this.fps = { n: 0, t0: performance.now(), val: 0 };
      this.surround = null;
      this.injectCss();
      this.buildButton();
      this.buildPanel();
      this.contain();
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
      const st = document.createElement('style');
      st.textContent = `
        #view-controls { display: flex; flex-wrap: wrap; gap: 6px; align-items: center; }
        #view-controls > * { position: static !important; inset: auto !important; left: auto !important; right: auto !important;
          top: auto !important; bottom: auto !important; transform: none !important; margin: 0 !important; z-index: auto !important;
          max-width: 100%; box-sizing: border-box; }
        #view-controls > #status, #view-controls > [data-hud="match"], #view-controls > [data-hud="speed"],
        #view-controls > [data-hud="replay"], #view-controls > [data-hud="watch"] { flex-basis: 100%; width: 100% !important; }
        #view-controls > #back { color: #ffcc00; font: 700 12px system-ui, sans-serif; text-decoration: none; padding: 4px 0; }
        #view-btn { position: fixed; top: env(safe-area-inset-top, 8px); left: 8px; z-index: 30;
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
      b.textContent = '☰ Menu';
      b.title = 'Every control, camera, brain and what to draw (M)';
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
        `<div class="row"><strong style="font-size:13px;">Menu</strong><span class="fps" data-fps>— fps</span></div>` +
        `<h3>Controls</h3><div id="view-controls"></div>` +
        (this.is3d ? `<div class="row" style="margin-top:8px;">` +
        `<button type="button" data-act="essential" title="Field, ball, players and referees only">Essentials only</button>` +
        `<button type="button" data-act="all">Everything on</button></div>` : '') +
        // Camera and Brain: their own buttons are in CONTROLS now (no second copy here).

        (this.is3d ? `<h3>Draw on the field</h3>` +
        `<div class="note" style="margin:0 0 2px;">Always drawn: pitch, goals, ball, players, referees.</div>` +
        DRAW.map(box).join('') +
        `<h3>Quality</h3>` + QUALITY.map(box).join('') : '') +
        `<div class="note">M opens this menu. Saved on this device.</div>`;
      p.addEventListener('change', (e) => {
        const k = e.target.dataset && e.target.dataset.k;
        if (k) this.set(k, e.target.checked);
      });
      p.addEventListener('click', (e) => {
        const a = e.target.dataset && e.target.dataset.act;
        const { cam, brain } = this.h;
        if (a === 'essential') this.setAll(false);
        else if (a === 'all') this.setAll(true);
        else if (a === 'cam') cam.cycle();
        else if (a === 'zin') cam.zoom(0.85);
        else if (a === 'zout') cam.zoom(1 / 0.85);
        else if (a === 'follow') cam.toggleFollow();
        else if (a === 'brain') brain.toggle();
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
    }

    // CONTROLS: move every contained control into the panel — now, and any the client builds later.
    contain() {
      const box = this.panel.querySelector('#view-controls');
      const wanted = (el) => el && el.parentElement === document.body && el !== this.btn && el !== this.panel &&
        (el.id === 'back' || el.id === 'btn-view' ||
         (CONTAIN.includes(el.dataset.hud) && el.getAttribute('role') !== 'region'));   // brain decision panels stay out
      const order = ['back', 'status', 'btn-view'];
      const take = (el) => {
        if (!wanted(el)) return;
        const i = order.indexOf(el.id);
        if (i >= 0) {   // Home, status, view switch first, in that order
          const after = [...box.children].find((c) => order.indexOf(c.id) > i || order.indexOf(c.id) < 0);
          box.insertBefore(el, after || null);
        } else box.appendChild(el);
      };
      [...document.body.children].forEach(take);
      new MutationObserver((ms) => ms.forEach((m) => m.addedNodes.forEach((n) => n.nodeType === 1 && take(n))))
        .observe(document.body, { childList: true });
    }

    // Body classes for the on-screen controls (CSS hides untagged ones in GAME only).
    applyHud() {
      for (const k of CONTAIN) document.body.classList.add('hud-' + k);   // inside the menu: always shown there
      for (const o of SHOW) document.body.classList.toggle('hud-' + o.k, this.get(o.k));
      document.body.classList.add('hud-ready');
    }

    // The scene: called by client.js whenever GAME is (re)applied, and on every change here.
    apply() {
      this.applyHud();
      if (!this.is3d) return;   // the 2D view draws only the match
      const r = this.h.renderer;
      this.applyQuality(r);
      for (const fig of r.figures || []) if (fig.tag) fig.tag.visible = this.get('tags');
      this.applySurround(r);
    }

    // A plain grass apron (one quad) around the pitch, so it isn't floating in sky.
    applySurround(r) {
      if (this.surround) return;
      this.surround = new THREE.Mesh(new THREE.PlaneGeometry(1200, 1200), new THREE.MeshLambertMaterial({ color: 0x3f6b35 }));
      this.surround.rotation.x = -Math.PI / 2;
      this.surround.position.y = -0.13;
      this.surround.receiveShadow = true;
      r.scene.add(this.surround);
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
        if (!this.is3d) return;
        const tags = this.get('tags');
        for (const fig of this.h.renderer.figures || []) if (fig.tag && fig.tag.visible !== tags) fig.tag.visible = tags;
      }
    }
  }
  window.ViewMenu = ViewMenu;
})();
