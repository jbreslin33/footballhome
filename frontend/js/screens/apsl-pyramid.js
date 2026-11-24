// apsl-pyramid.js — #apsl-pyramid: the APSL pyramid (migrations 819–836).
// Owner 2026-10-29: "i want the conference shown in a container with
// relegation and playoff spots … feeder leagues connected by arrows like a
// flow chart … use pill format … make sure they all draw from same source
// these are just views."
//
// The screen holds ONE PyramidModel (js/lib/pyramid-model.js), built from
// GET /api/pyramid, plus what every view shares: the conference pills (All
// + each toggles), the view pills, and the ✏️ promotion/relegation editor.
// A view only draws the model: PyramidFlowView (flow chart),
// PyramidPresentView (Prezi-style canvas over the same chart), PyramidMapView
// (clubs on a USA map, a conference's chart under it), PyramidPathView (a
// club's routes up the pyramid), PyramidTablesView (every table, full
// columns), PyramidGrowthView (the league's seasons).  A view pill not built
// yet shows greyed.  Wording: message_templates kind 'apsl_pyramid'.
//
// A normal page with pill rows (owner 2026-11-24: "more like the other pages
// with pills"): the site's top bar stays on top, then the title + totals,
// a row of View pills, a row of Conference pills (All + each toggles), a
// row of the view's on/off switches as pills, and the view under them.  A
// view's panels (screen.hud(): the chart's legend, the slideshow's
// controls, the map's key / conference / club card) sit in .ap-menu — a
// strip above the view, or a column beside the map (under it on a phone).
// The ☰ menu of mig 1234 is gone.
// Black or white text on a conference colour (mig 1249), by its luminance.
const PyramidScreenColor = {
  ink(hex) {
    const m = /^#?([0-9a-f]{6})$/i.exec(hex || '');
    if (!m) return '#fff';
    const n = parseInt(m[1], 16), lum = (0.299 * (n >> 16) + 0.587 * ((n >> 8) & 255) + 0.114 * (n & 255)) / 255;
    return lum > 0.6 ? '#111827' : '#fff';
  },
};
window.PyramidScreenColor = PyramidScreenColor;

class ApslPyramidScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.model = null; this.err = ''; this.loading = false;
    this.clubCard = new PyramidClubCard(this);   // mig 856
    this.on = null;              // Set of conference ids shown; null = all
    // View pills (owner 2026-10-29: "flowchart versions (this one), then one
    // for map of usa, etc. even if they are not implemented just put them
    // greyed out").  `built` = this screen draws it; the rest show greyed.
    const flow = new PyramidFlowView(this);
    this.views = [
      // story order (mig 1580): the pyramid → where → how a club climbs →
      // this season → what happens next → how it grew → the slideshow
      { code: 'flow', tier: 'view_flow', built: true, impl: flow },
      { code: 'map', tier: 'view_map', built: true, impl: new PyramidMapView(this, flow) },
      { code: 'path', tier: 'view_path', built: true, impl: new PyramidPathView(this, flow) },
      { code: 'tables', tier: 'view_tables', built: true, impl: new PyramidTablesView(this, flow) },
      // 📈 Forecast (mig 1448, owner 11/17: "an analysis for league and all teams … predict scores etc. like a betting app")
      { code: 'forecast', tier: 'view_forecast', built: true, impl: new PyramidForecastView(this) },
      { code: 'growth', tier: 'view_growth', built: true, impl: new PyramidGrowthView(this) },
      { code: 'present', tier: 'view_present', built: true, impl: new PyramidPresentView(this, flow) },
    ];
    this.view = 'flow';
    try {
      const saved = JSON.parse(localStorage.getItem('apsl-pyramid-on') || 'null');
      if (Array.isArray(saved)) this.on = new Set(saved);
      const v = localStorage.getItem('apsl-pyramid-view');
      if (this.views.some((x) => x.code === v && x.built)) this.view = v;
    } catch (_) { /* private mode */ }
    // A shared Forecast link (mig 1575: /?fc=<conference>&focus=<team>) opens on it.
    if (new URLSearchParams(window.location.search || '').get('fc')) this.view = 'forecast';
    this._onResize = () => { clearTimeout(this._rt); this._rt = setTimeout(() => this._viewCall('onResize'), 120); };
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl_pyramid', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ap-pill { padding:5px 14px; border-radius:999px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; font-weight:700; font-size:0.85rem; cursor:pointer; min-height:0; min-width:0; }
        .ap-readonly .fc-edit, .ap-readonly [data-cc="edit"], .ap-readonly #ap-refresh { display:none; }
        .ap-pill.on { background:var(--primary-color, #2563eb); border-color:var(--primary-color, #2563eb); color:#fff; }
        /* A conference pill wears its colour (mig 1249): ringed + dot when off, filled when on. */
        .ap-pill.cc { border-color:var(--cc); }
        .ap-pill.cc::before { content:""; display:inline-block; width:8px; height:8px; border-radius:50%; background:var(--cc); margin-right:6px; vertical-align:0; }
        .ap-pill.cc.on { background:var(--cc); border-color:var(--cc); color:var(--cc-fg, #fff); }
        .ap-pill.cc.on::before { background:var(--cc-fg, #fff); }
        .ap-stage { background:var(--bg-color, #0b1220); padding:10px 12px 20px; box-sizing:border-box; }
        .ap-stage:fullscreen { overflow:auto; }
        body.ap-clean #menu-pills { display:none !important; }
        .ap-bar { margin-bottom:10px; }
        .ap-bar .row { display:flex; align-items:center; gap:6px 12px; flex-wrap:wrap; }
        .ap-bar img { height:30px; width:auto; }
        .ap-bar .t { font-weight:900; font-size:1.15rem; white-space:nowrap; }
        .ap-bar .tot { font-size:0.85rem; font-weight:600; opacity:0.8; }
        .ap-bar .acts { margin-left:auto; display:flex; gap:6px; flex-wrap:wrap; }
        .ap-bar .acts .ap-pill { font-weight:600; font-size:0.78rem; padding:4px 11px; }
        /* ☰ (mig 1826): the page is a display — ONE title line, the view takes the rest of the window, and everything you can change drops down over it, in headed sections. */
        .ap-bar { position:relative; }
        .ap-bar .acts .ap-pill.burger { font-size:1.05rem; padding:2px 12px; line-height:1.3; }
        .ap-burger { position:absolute; right:0; top:calc(100% + 2px); z-index:1400; width:min(340px, 94vw); max-height:min(80vh, 760px); overflow:auto; box-sizing:border-box;
                     background:var(--card-bg, #111827); border:1px solid var(--border-color, #374151); border-radius:12px; padding:0 8px 10px; box-shadow:0 8px 28px rgba(0,0,0,0.55); }
        .ap-burger[hidden], .ap-clublist[hidden] { display:none; }
        .ap-burger h4 { margin:10px 6px 4px; font-size:0.68rem; text-transform:uppercase; letter-spacing:0.08em; opacity:0.6; }
        .ap-burger h4:not(:first-child) { border-top:1px solid rgba(148,163,184,0.25); padding-top:10px; }
        .ap-burger .li, .ap-clublist button { display:block; width:100%; text-align:left; min-height:0; padding:6px 8px; border:0; border-radius:8px; background:transparent; color:inherit; font-size:0.88rem; cursor:pointer; }
        .ap-burger .li:hover, .ap-clublist button:hover { background:rgba(148,163,184,0.18); }
        .ap-burger .li.on { font-weight:800; }
        .ap-burger .li.tick::before { content:""; display:inline-block; width:1.3em; }
        .ap-burger .li.tick.on::before { content:"✓"; }
        .ap-burger .li i { display:inline-block; width:9px; height:9px; border-radius:50%; margin-right:7px; background:var(--cc, transparent); }
        .ap-burger .feats { display:flex; flex-wrap:wrap; gap:4px; padding:0 4px; }
        .ap-burger .feats .ap-pill { font-weight:600; font-size:0.78rem; padding:4px 11px; }
        .ap-burger .cap { font-size:0.8rem; opacity:0.8; line-height:1.35; margin:2px 6px 8px; }
        .ap-burger .fc-legend { margin:0 6px; justify-content:flex-start; gap:6px 12px; }
        /* Club search: the clubs of the conferences that are lit. */
        .ap-clubbox { padding:0 4px; }
        .ap-club { width:100%; box-sizing:border-box; min-height:0; padding:6px 12px; font-size:0.85rem; border-radius:999px; }
        .ap-clublist { max-height:220px; overflow:auto; margin-top:4px; border:1px solid rgba(148,163,184,0.25); border-radius:10px; padding:2px; }
        .ap-main { display:flex; gap:12px; align-items:flex-start; }
        .ap-main.top { flex-direction:column; align-items:stretch; gap:8px; }
        #ap-body { position:relative; flex:1 1 auto; min-width:0; isolation:isolate; }
        .ap-main.top #ap-body { flex:none; }
        #ap-body.flush { height:var(--ap-h, 70vh); overflow:hidden; border:1px solid rgba(148,163,184,0.25); border-radius:12px; }
        #ap-body.flush #ap-view { position:absolute; inset:0; }
        @media (max-width: 900px) { .ap-main { flex-direction:column; align-items:stretch; } }
        .ap-dock .mp-layers { margin-bottom:6px; }
        /* The view's panels: a column beside the view (the map), or a strip above it (.ap-main.top). */
        .ap-menu { flex:0 0 340px; max-height:var(--ap-h, 70vh); overflow:auto; box-sizing:border-box; padding:4px 12px 10px;
                   border:1px solid rgba(148,163,184,0.25); border-radius:12px; font-size:0.85rem; }
        .ap-menu[hidden] { display:none; }
        .ap-main.top .ap-menu { order:-1; flex:none; max-height:none; overflow:visible; border:0; padding:0; }
        .ap-main.top .ap-sec { border:0; padding:0; margin:0; }
        .ap-main.top .ap-sec h4 { display:none; }
        @media (max-width: 900px) { .ap-menu { flex:none; max-height:none; } }
        .ap-sec { border-top:1px solid rgba(148,163,184,0.25); padding:9px 0 4px; margin-top:6px; }
        .ap-dock > .ap-sec:first-child { border-top:0; margin-top:0; }
        .ap-sec h4 { margin:0 0 7px; font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; opacity:0.65; }
        .ap-pill:disabled { opacity:0.35; cursor:not-allowed; }
        ${PyramidFlowView.css()}
        ${PyramidPresentView.css()}
        ${PyramidMapView.css()}
        ${PyramidPathView.css()}
        ${PyramidTablesView.css()}
        ${PyramidGrowthView.css()}
        ${PyramidForecastView.css()}
        ${PyramidClubCard.css()}
        .fc-none { text-align:center; font-size:0.8rem; opacity:0.55; margin-top:14px; }
        .ap-warn { color:#fca5a5; }
        .ap-editor-bg { position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:1000; display:flex; align-items:center; justify-content:center; padding:16px; }
        .ap-editor { background:var(--card-bg, #111827); border:1px solid var(--border-color, #374151); border-radius:12px; padding:16px; width:min(460px, 100%); max-height:90vh; overflow:auto; }
        .ap-editor h3 { margin:0 0 10px; font-size:1rem; }
        .ap-editor .sec { border-top:1px solid var(--border-color, #374151); padding:10px 0; }
        .ap-editor .sec b { display:block; margin-bottom:6px; }
        .ap-editor label { margin-right:12px; font-size:0.88rem; }
        .ap-editor .hint { font-size:0.75rem; opacity:0.65; margin:4px 0; }
        .ap-editor .zr { display:flex; gap:6px; align-items:center; margin:6px 0; font-size:0.85rem; }
        .ap-editor .zr select { flex:1; min-width:0; }
        .ap-editor .zr input { width:52px; }
        .ap-editor .btns { display:flex; gap:8px; justify-content:flex-end; margin-top:10px; }
        .ap-editor .err { color:#fca5a5; font-size:0.82rem; }
      </style>
      <div class="ap-stage">
        <div class="ap-bar"></div>
        <div class="ap-main">
          <div id="ap-body"><div class="loading" style="padding-top:60px;">Loading…</div></div>
          <aside class="ap-menu" hidden><div class="ap-dock"></div><div class="ap-menu-extra"></div></aside>
        </div>
      </div>`;
    this.element = div;
    // Full screen is the display case: it starts with the rows folded;
    // leaving it brings back what this browser last chose.
    this._onFullLabel = () => { this._renderBar(); if (this._fit()) this._viewCall('onResize'); };
    document.addEventListener('fullscreenchange', this._onFullLabel);
    div.querySelector('.ap-stage').addEventListener('click', (e) => {
      // The club search (right of the conference pills): a tap in the box
      // opens its list, a club in the list is picked, a tap elsewhere shuts it.
      const cp = e.target.closest('[data-club-pick]');
      if (cp) { this._pickClub(Number(cp.dataset.clubPick)); return; }
      if (e.target.closest('.ap-club')) { this._clubList(true); e.target.select(); return; }
      if (this.clubOpen && !e.target.closest('[data-conf]')) this._clubList(false);
      // ☰: a tap outside its drop-down shuts it.
      if (this.menuOpen && !e.target.closest('.ap-burger, [data-act="menu"]')) this._burger(false);
      // A view's own panel section (the map's proposed conferences).
      if (e.target.closest('.ap-menu') && this._impl().menuClick && this._impl().menuClick(e)) return;
      const act = e.target.closest('[data-act]');
      if (act) { this._menuAction(act.dataset.act); return; }
      // A Show pill: one of the view's on/off switches.
      const feat = e.target.closest('[data-feature]');
      if (feat) {
        const f = (this._impl().features ? this._impl().features() : []).find((x) => x.key === feat.dataset.feature);
        if (f) { this._setFeature(f.key, !this.feature(f.key, f.def)); this._renderBar(); }
        return;
      }
      // A team's name anywhere → its club card (mig 856).
      const club = e.target.closest('[data-club]');
      if (club && !e.target.closest('.pz-vp')) { this.openClub(Number(club.dataset.club)); return; }
      const vp = e.target.closest('[data-view]');
      if (vp) {
        const v = this.views.find((x) => x.code === vp.dataset.view);
        if (v && v.built && v.code !== this.view) {
          this._viewCall('unmount');
          this.view = v.code; this.menuOpen = false;
          try { localStorage.setItem('apsl-pyramid-view', v.code); } catch (_) { /* private mode */ }
          this._renderBody();
        }
        return;
      }
      const pill = e.target.closest('[data-conf]');
      if (pill) { this._toggle(pill.dataset.conf); return; }
      const edit = e.target.closest('[data-edit]');
      if (edit) { this._openEditor(Number(edit.dataset.edit)); return; }
      const ed = e.target.closest('[data-ed]');
      if (ed) this._editorAction(ed);
    });
    // Typing narrows the list; Enter takes the first club left, Esc shuts it.
    div.querySelector('.ap-stage').addEventListener('input', (e) => {
      if (!e.target.closest('.ap-club')) return;
      const q = e.target.value.trim().toLowerCase();
      this._clubList(true);
      this.findAll('.ap-clublist button').forEach((b) => { b.hidden = !!q && !b.textContent.toLowerCase().includes(q); });
    });
    div.querySelector('.ap-stage').addEventListener('keydown', (e) => {
      if (!e.target.closest('.ap-club')) return;
      if (e.key === 'Escape') this._clubList(false);
      else if (e.key === 'Enter') { const b = [...this.findAll('.ap-clublist button')].find((x) => !x.hidden); if (b) this._pickClub(Number(b.dataset.clubPick)); }
    });
    div.querySelector('.ap-stage').addEventListener('change', (e) => {
      if (e.target.closest('.ap-editor')) this._editorRead();
    });
    return div;
  }

  onEnter() {
    // Public page (mig 870): editing and ⟳ are club admin; a visitor has no
    // screen to go back to.
    const user = this.auth.getUser();
    this.element.classList.toggle('ap-readonly', !(user && ['club', 'super'].includes(user.role)));
    window.addEventListener('resize', this._onResize);
    // The page sits in the normal flow under the site's top bars; a canvas
    // view (chart, map, slideshow) takes the window height left under the
    // pill rows, refitted whenever those bars or the rows change height.
    // A display page: the site's top bar is off here (☰ → ← Football Home).
    document.body.classList.add('ap-clean');
    this._fit();
    if (window.ResizeObserver) {
      this._bandObs = new ResizeObserver(() => { if (this._fit()) this._viewCall('onResize'); });
      ['#top-banners', '#menu-pills'].forEach((q) => { const n = document.querySelector(q); if (n) this._bandObs.observe(n); });
      const bar = this.find('.ap-bar'); if (bar) this._bandObs.observe(bar);
    }
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => {
      if (this.data) this._renderBody();
    });
    this.load(false);
  }

  onExit() {
    window.removeEventListener('resize', this._onResize);
    if (this._bandObs) { this._bandObs.disconnect(); this._bandObs = null; }
    document.body.classList.remove('ap-clean');
    this._viewCall('unmount');
    this.clubCard.close();
    if (document.fullscreenElement) document.exitFullscreen();
  }

  // ── the view's panels (.ap-menu) ─────────────────────────────────────
  // Views call _menu(true) to bring their panels up (the map, on a club
  // pick) and _renderMenu() when their own section changed.
  _menu(open = true) { if (open) this._renderMenu(); }

  // 🔗 Copy link (mig 1815; owner 2026-11-24: "what the link is it should
  // be copy link pill"): the page's public address on the clipboard; the
  // pill says so for two seconds.
  _link() { return `${location.origin}/#apsl-pyramid`; }
  _copyLink() {
    const url = this._link();
    const old = () => {
      const t = document.createElement('textarea');
      t.value = url; t.style.cssText = 'position:fixed; opacity:0;';
      document.body.appendChild(t); t.select();
      try { document.execCommand('copy'); } catch (_e) { /* nothing more to try */ }
      t.remove();
    };
    if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(url).catch(old); else old();
    const b = this.find('[data-act="link"]');
    if (!b) return;
    b.textContent = this._copy('link_copied');
    b.classList.add('on');
    setTimeout(() => { if (b.isConnected) { b.textContent = this._copy('link_copy'); b.classList.remove('on'); } }, 2000);
  }

  _menuAction(act) {
    if (act === 'full') {
      const stage = this.find('.ap-stage');
      this.menuOpen = false;
      if (document.fullscreenElement) document.exitFullscreen(); else if (stage && stage.requestFullscreen) stage.requestFullscreen();
    } else if (act === 'refresh') this.load(true);
    else if (act === 'link') this._copyLink();
    else if (act === 'menu') this._burger(!this.menuOpen);
    else if (act === 'site') this.navigation.goTo('apsl');
  }

  // The view's own sections (the map's proposed conferences) go under its
  // dock panels; no panels at all → no column.
  _renderMenu() {
    const side = this.find('.ap-menu'), extra = this.find('.ap-menu-extra'), main = this.find('.ap-main');
    if (!side || !extra) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const impl = this._impl();
    extra.innerHTML = this.model && impl.menuSections
      ? impl.menuSections().map((x) => `<div class="ap-sec"><h4>${esc(this._copy(x.tier))}</h4>${x.html}</div>`).join('') : '';
    const dock = this.find('.ap-dock');
    side.hidden = !((dock && dock.children.length) || extra.children.length);
    if (main) main.classList.toggle('top', !impl.side);
  }

  // Height for a canvas view: the window under the pill rows (never less
  // than 420px — the page scrolls then).  true = it changed.
  _fit() {
    const stage = this.find('.ap-stage'), body = this.find('#ap-body');
    if (!stage || !body) return false;
    const top = document.fullscreenElement === stage
      ? body.getBoundingClientRect().top - stage.getBoundingClientRect().top + stage.scrollTop
      : body.getBoundingClientRect().top + window.scrollY;
    const h = `${Math.max(420, Math.round(window.innerHeight - top - 14))}px`;
    if (stage.style.getPropertyValue('--ap-h') === h) return false;
    stage.style.setProperty('--ap-h', h);
    return true;
  }

  findAll(sel) { return this.element ? this.element.querySelectorAll(sel) : []; }

  // ── the view's switches and panels ────────────────────────────────
  // A view feature switched in ☰ Show on screen; `def` until the viewer
  // picks, remembered per device.
  feature(key, def = true) {
    try { const v = localStorage.getItem(`apsl-feat-${key}`); return v == null ? def : v === '1'; } catch (_) { return def; }
  }
  _setFeature(key, on) {
    try { localStorage.setItem(`apsl-feat-${key}`, on ? '1' : '0'); } catch (_) { /* private mode */ }
    if (this._impl().onFeature) this._impl().onFeature(key, on);
    else { this._viewCall('unmount'); this._renderBody(); }
  }
  // A view's panel: its html() calls this while _renderBody collects the
  // parts, and they are written into .ap-dock (which later re-renders of
  // the view's own sections never touch, so live content — conference
  // stats, the club card — survives).  Views find them with screen.find().
  hud(key, title, body, pos = '', extra = '') {
    (this._dock = this._dock || []).push(`
      <div class="ap-sec ap-dock-sec ${extra}" data-hud="${key}">
        <h4>${this.escapeHtml(title || '')}</h4>
        <div class="ap-hud-body">${body}</div>
      </div>`);
    return '';
  }

  // The club card (mig 856): host = an element to sit in (the map's stage),
  // else it floats over the screen.
  // On the map the map picks it (mig 866): its dots light up and the card
  // is the map's Club HUD — from a dot, a name or the overlay's tables.
  openClub(clubId, host) {
    if (!clubId) return;
    const impl = this._impl();
    if (impl && impl.pickClub && impl.map) { impl.pickClub(clubId, !host); return; }
    this.clubCard.open(clubId, host);
  }

  _impl() { return (this.views.find((v) => v.code === this.view) || this.views[0]).impl; }
  _shown() { return this.model ? this.model.conferences().filter((c) => this._isOn(c.id)) : []; }
  _viewCall(fn) {
    const el = this.find('#ap-view');
    if (!el || !this.model) return;
    const impl = this._impl();
    if (impl && impl[fn]) impl[fn](el, this.model, this._shown());
  }

  async load(refresh) {
    this.loading = true; this.err = ''; this._renderBody();
    try {
      const res = await this.auth.fetch(`/api/pyramid?root=apsl${refresh ? '&refresh=1' : ''}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
      this.model = new PyramidModel(body);
    } catch (err) { this.data = null; this.model = null; this.err = err.message || 'Failed to load.'; }
    this.loading = false;
    if (this.isMounted) this._renderBody();
  }

  // ── pills ────────────────────────────────────────────────────────────
  _conferences() { return this.model.conferences(); }
  _isOn(id) { return !this.on || this.on.has(id); }
  _burger(open) {
    this.menuOpen = !!open;
    const m = this.find('.ap-burger');
    if (m) m.hidden = !this.menuOpen;
  }
  _clubList(open) {
    this.clubOpen = !!open;
    const l = this.find('.ap-clublist');
    if (l) l.hidden = !this.clubOpen;
  }
  // A club from the list → the view's own answer (Club pathway draws its
  // routes), else its club card.
  _pickClub(id) {
    const club = this.model && this.model.clubs.find((c) => c.id === id);
    if (!club) return;
    this.clubName = club.name; this.clubOpen = false; this.menuOpen = false;
    this._renderBar();
    if (this._impl().onClub) this._impl().onClub(club); else this.openClub(club.id);
  }
  // Clubs with a team under a lit conference — its own tables or a feeder's
  // (All = every club), A–Z.  The club search's list.
  _clubsShown() {
    if (!this.model) return [];
    let clubs = this.model.clubs;
    if (this.on) {
      const ids = new Set();
      for (const col of this.model.layout(this._shown()).columns)
        for (const x of this.model.columnTeams(col)) if (x.team.club_id) ids.add(x.team.club_id);
      clubs = clubs.filter((c) => ids.has(c.id));
    }
    return [...clubs].sort((a, b) => a.name.localeCompare(b.name));
  }
  _toggle(key) {
    const all = this._conferences().map((c) => c.id);
    if (key === 'all') this.on = null;
    else if (key === 'none') this.on = new Set();
    else {
      // Each pill switches on/off on its own (owner 11/24 "have a select
      // all and deselect all"): All lights every one, None clears them.
      const id = Number(key);
      const set = this.on ? new Set(this.on) : new Set(all);
      if (set.has(id)) set.delete(id); else set.add(id);
      this.on = set.size === all.length ? null : set;
    }
    try { localStorage.setItem('apsl-pyramid-on', JSON.stringify(this.on ? [...this.on] : null)); } catch (_) { /* private mode */ }
    // The club search lists the clubs of whatever is lit (All = every
    // club); it opens on a tap in its box.
    this.clubOpen = false;
    this._renderBody();
  }

  _renderBody() {
    const el = this.find('#ap-body');
    if (!el) return;
    if (this.loading && !this.data) { el.innerHTML = '<div class="loading">Loading…</div>'; return; }
    if (this.err) { el.innerHTML = `<div class="error">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.model) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const shown = this._shown();
    // A view that is a canvas (map, presentation) fills the stage edge to edge.
    el.classList.toggle('flush', !!this._impl().fill);
    this._dock = [];
    this._renderBar();
    el.innerHTML = `
      <div id="ap-view">${shown.length ? this._impl().html(this.model, shown) : `<div class="fc-none">${esc(this._copy('none_on'))}</div>`}</div>
      ${this.edit ? this._editorHtml() : ''}`;
    const dock = this.find('.ap-dock');
    if (dock) dock.innerHTML = this._dock.join('');
    this._renderMenu();
    this._fit();
    if (shown.length) requestAnimationFrame(() => this._viewCall('mount'));
  }


  // ── the header: title + totals, then the pill rows ───────────────────
  // Views in story order (mig 1580), conferences (All + each toggles), the
  // view's on/off switches, and one plain sentence on what the view shows.
  _renderBar() {
    const bar = this.find('.ap-bar');
    if (!bar || !this.model) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const root = this.model.root();
    const views = this.views.filter((v) => v.built)
      .map((v) => `<button class="li tick ${this.view === v.code ? 'on' : ''}" data-view="${v.code}">${esc(this._copy(v.tier))}</button>`).join('');
    const confs = `<button class="li tick ${!this.on ? 'on' : ''}" data-conf="all">${esc(this._copy('pill_all'))}</button>
      <button class="li tick ${this.on && !this.on.size ? 'on' : ''}" data-conf="none">${esc(this._copy('pill_none'))}</button>`
      + this._conferences().map((c) => `<button class="li tick ${this._isOn(c.id) ? 'on' : ''}" data-conf="${c.id}"><i${c.color ? ` style="--cc:${esc(c.color)}"` : ''}></i>${esc(c.short_name || c.name)}</button>`).join('');
    const feats = (this._impl().features ? this._impl().features() : [])
      .map((f) => `<button class="ap-pill ${this.feature(f.key, f.def) ? 'on' : ''}" data-feature="${esc(f.key)}">${esc(this._copy(f.tier))}</button>`).join('');
    const cap = this._copy(`story_view_${this.view}`, { ...this.model.totals, confs: this._conferences().length });
    // The view's colour key rides the caption line (owner 11/24 "can go on same line as legend?").
    const legend = this._impl().legend ? this._impl().legend(this.model) : '';
    const li = (act, text, extra = '') => `<button class="li" data-act="${act}"${extra}>${esc(text)}</button>`;
    const was = bar.querySelector('.ap-burger'), scroll = was ? was.scrollTop : 0;
    // ONE line (owner 11/24: "its really a view thing and not a work thing"
    // · "we want full screens always"): title, counts, ☰.  The drop-down:
    // views, conferences, club search, the view's switches, then the page's
    // own actions and what the view shows + its colour key.
    bar.innerHTML = `
      <div class="row">${root && root.logo_url ? `<img src="${esc(root.logo_url)}" alt="">` : ''}<span class="t">${esc(this._copy('title'))}</span>
        <span class="tot">${esc(this._copy('totals', this.model.totals))}${this.loading ? ' · ⟳' : ''}</span>
        <div class="acts"><button class="ap-pill burger" data-act="menu">${esc(this._copy('menu_open'))}</button></div></div>
      <div class="ap-burger"${this.menuOpen ? '' : ' hidden'}>
        <h4>${esc(this._copy('menu_view'))}</h4>${views}
        <h4>${esc(this._copy('menu_conf'))}</h4>${confs}
        <h4>${esc(this._copy('menu_club'))}</h4>
        <div class="ap-clubbox"><input class="ap-club" autocomplete="off" placeholder="${esc(this._copy('path_search'))}" value="${esc(this.clubName || '')}">
          <div class="ap-clublist"${this.clubOpen ? '' : ' hidden'}>${this._clubsShown().map((c) => `<button type="button" data-club-pick="${c.id}">${esc(c.name)}</button>`).join('')}</div></div>
        ${feats ? `<h4>${esc(this._copy('menu_show'))}</h4><div class="feats">${feats}</div>` : ''}
        <h4>${esc(this._copy('menu_page'))}</h4>
        ${li('link', this._copy('link_copy'), ` title="${esc(this._link())}"`)}
        ${li('full', this._copy(document.fullscreenElement ? 'map_exit_full' : 'map_full') || '⛶')}
        ${li('refresh', this._copy('menu_refresh'), ' id="ap-refresh"')}
        ${this.auth.isLoggedIn() ? li('site', this._copy('menu_site')) : ''}
        ${cap || legend ? `<h4>${esc(this._copy('menu_about'))}</h4>${cap ? `<div class="cap">${esc(cap)}</div>` : ''}${legend ? `<div class="fc-legend">${legend}</div>` : ''}` : ''}
      </div>`;
    const now = bar.querySelector('.ap-burger');
    if (now && scroll) now.scrollTop = scroll;
  }

  // ── ✏️ override editor (mig 828) ─────────────────────────────────────
  // Per direction: Default rules (pyramid_zone_rules defaults), None, or
  // this table's own zones.  Save = POST /api/pyramid/zone-rules per side.
  _openEditor(divId) {
    const d = this.model.division(divId);
    if (!d) return;
    const side = (dir) => {
      const o = d.overrides ? d.overrides[dir] : null;
      if (o == null) return { mode: 'default', zones: [] };
      if (!o.length) return { mode: 'none', zones: [] };
      return { mode: 'custom', zones: o.map((z) => ({ ...z })), until: (o.find((z) => z.until) || {}).until || '' };
    };
    this.edit = { divId, up: side('up'), stay: side('stay'), down: side('down'), err: '', saving: false };
    this._renderBody();
  }

  _editorRead() {
    const box = this.find('.ap-editor');
    if (!box || !this.edit) return;
    for (const dir of ['up', 'stay', 'down']) {
      const m = box.querySelector(`input[name="m-${dir}"]:checked`);
      if (m) this.edit[dir].mode = m.value;
      this.edit[dir].zones = [...box.querySelectorAll(`.zr[data-dir="${dir}"]`)].map((r) => ({
        kind: r.querySelector('select').value,
        from: Number(r.querySelector('[data-f]').value),
        to: Number(r.querySelector('[data-t]').value),
      }));
    }
  }

  async _editorAction(el) {
    if (!this.edit) return;
    this._editorRead();
    const act = el.dataset.ed, dir = el.dataset.dir;
    if (act === 'cancel') { this.edit = null; this._renderBody(); return; }
    if (act === 'mode') { this._renderBody(); return; }
    if (act === 'add') {
      const kinds = this.model.kinds.filter((k) => (k.moves || 'stay') === dir);
      this.edit[dir].mode = 'custom';
      this.edit[dir].zones.push({ kind: kinds[0] ? kinds[0].code : '', from: 1, to: 1 });
      this._renderBody(); return;
    }
    if (act === 'del') { this.edit[dir].zones.splice(Number(el.dataset.i), 1); this._renderBody(); return; }
    if (act === 'save') {
      this.edit.saving = true; this.edit.err = ''; this._renderBody();
      try {
        for (const side of ['up', 'stay', 'down']) {
          const e = this.edit[side];
          const res = await this.auth.fetch('/api/pyramid/zone-rules', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ division_id: this.edit.divId, direction: side, mode: e.mode, zones: e.mode === 'custom' ? e.zones : [] }),
          });
          const body = await res.json().catch(() => ({}));
          if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
        }
        this.edit = null;
        await this.load(false);
      } catch (err) {
        if (this.edit) { this.edit.saving = false; this.edit.err = err.message || 'Save failed.'; this._renderBody(); }
      }
    }
  }

  _editorHtml() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const d = this.model.division(this.edit.divId);
    if (!d) return '';
    const comp = this.model.comp(d.competition_id);
    const kinds = this.model.kinds;
    const kindLabel = (code) => this.model.kindLabel(code);
    const sec = (dir) => {
      const e = this.edit[dir];
      // What the defaults give this table today (origin 'default' zones).
      const defs = (d.zones || []).filter((z) => z.origin === 'default' && (z.moves || 'stay') === dir)
        .map((z) => `${kindLabel(z.kind)} ${z.from === z.to ? z.from : `${z.from}–${z.to}`}`).join(', ');
      const radio = (mode, tier) => `<label><input type="radio" name="m-${dir}" value="${mode}" data-ed="mode" ${e.mode === mode ? 'checked' : ''}> ${esc(this._copy(tier))}</label>`;
      const rows = e.mode === 'custom' ? e.zones.map((z, i) => `
        <div class="zr" data-dir="${dir}">
          <select>${kinds.filter((k) => (k.moves || 'stay') === dir).map((k) => `<option value="${esc(k.code)}" ${k.code === z.kind ? 'selected' : ''}>${esc(k.label)}</option>`).join('')}</select>
          ${esc(this._copy('place_from'))} <input type="number" min="1" data-f value="${esc(z.from)}">
          ${esc(this._copy('place_to'))} <input type="number" min="1" data-t value="${esc(z.to)}">
          <button class="btn btn-secondary" data-ed="del" data-dir="${dir}" data-i="${i}" style="padding:2px 8px; min-height:0;">✕</button>
        </div>`).join('') : '';
      return `
        <div class="sec">
          <b>${esc(this._copy(dir === 'up' ? 'edit_up' : dir === 'stay' ? 'edit_stay' : 'edit_down'))}</b>
          ${radio('default', 'mode_default')}${radio('none', 'mode_none')}${radio('custom', 'mode_custom')}
          <div class="hint">${esc(defs ? this._copy('defaults_are', { zones: defs }) : this._copy('defaults_none'))}</div>
          ${e.until && e.mode === 'custom' ? `<div class="hint">${esc(this._copy('until', { date: e.until }))}</div>` : ''}
          ${rows}
          ${e.mode === 'custom' ? `<button class="btn btn-secondary" data-ed="add" data-dir="${dir}" style="padding:2px 10px; min-height:0; font-size:0.8rem;">${esc(this._copy('add_zone'))}</button>` : ''}
        </div>`;
    };
    const table = `${comp ? this.model.label(comp) + ' · ' : ''}${d.name}`;
    return `
      <div class="ap-editor-bg">
        <div class="ap-editor">
          <h3>${esc(this._copy('edit_title', { table }))}</h3>
          ${sec('up')}${sec('stay')}${sec('down')}
          ${this.edit.err ? `<div class="err">${esc(this.edit.err)}</div>` : ''}
          <div class="btns">
            <button class="btn btn-secondary" data-ed="cancel">${esc(this._copy('cancel'))}</button>
            <button class="btn btn-primary" data-ed="save" ${this.edit.saving ? 'disabled' : ''}>${esc(this._copy('save'))}</button>
          </div>
        </div>
      </div>`;
  }
}
window.ApslPyramidScreen = ApslPyramidScreen;
