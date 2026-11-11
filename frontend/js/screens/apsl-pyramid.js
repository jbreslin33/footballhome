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
// One ☰ button (mig 1234, owner 2026-11-11: "like game … one button to open
// interface so screen on load is not cluttered … organized sections"): the
// page opens on the view alone.  ☰ (or M) opens one panel — View,
// Conferences, Show on screen (the view's floating panels, off by default,
// remembered per device), Actions.  Same idea as game/view-menu.js.
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
      { code: 'flow', tier: 'view_flow', built: true, impl: flow },
      { code: 'present', tier: 'view_present', built: true, impl: new PyramidPresentView(this, flow) },
      { code: 'map', tier: 'view_map', built: true, impl: new PyramidMapView(this, flow) },
      { code: 'path', tier: 'view_path', built: true, impl: new PyramidPathView(this, flow) },
      { code: 'tables', tier: 'view_tables', built: true, impl: new PyramidTablesView(this, flow) },
      { code: 'growth', tier: 'view_growth', built: true, impl: new PyramidGrowthView(this) },
    ];
    this.view = 'flow';
    try {
      const saved = JSON.parse(localStorage.getItem('apsl-pyramid-on') || 'null');
      if (Array.isArray(saved)) this.on = new Set(saved);
      const v = localStorage.getItem('apsl-pyramid-view');
      if (this.views.some((x) => x.code === v && x.built)) this.view = v;
    } catch (_) { /* private mode */ }
    this._onResize = () => { clearTimeout(this._rt); this._rt = setTimeout(() => this._viewCall('onResize'), 120); };
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl_pyramid', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ap-totals { text-align:center; font-size:1.2rem; font-weight:800; margin:var(--space-2) 0 var(--space-3); }
        .ap-pills { display:flex; gap:6px; justify-content:center; flex-wrap:wrap; margin-bottom:var(--space-3); }
        .ap-pill { padding:5px 14px; border-radius:999px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; font-weight:700; font-size:0.85rem; cursor:pointer; min-height:0; min-width:0; }
        .ap-readonly .fc-edit, .ap-readonly [data-cc="edit"], .ap-readonly #ap-refresh { display:none; }
        .ap-pill.on { background:var(--primary-color, #2563eb); border-color:var(--primary-color, #2563eb); color:#fff; }
        .ap-stage { position:fixed; inset:0; z-index:1000; background:var(--bg-color, #0b1220); overflow:hidden; }
        .ap-stage #ap-body { position:absolute; inset:0; overflow:auto; padding:62px 16px 24px; }
        .ap-stage #ap-body.flush { padding:0; overflow:hidden; }
        .ap-stage #ap-body.flush #ap-view { position:absolute; inset:0; }
        .ap-hud { position:absolute; z-index:1100; background:rgba(11,18,32,0.84); backdrop-filter:blur(6px); border:1px solid rgba(148,163,184,0.3);
                  border-radius:12px; color:#e5e7eb; font-size:0.8rem; box-shadow:0 4px 18px rgba(0,0,0,0.4); max-width:calc(100% - 20px); }
        .ap-hud-head { display:flex; align-items:center; gap:8px; padding:4px 6px 4px 10px; font-weight:800; white-space:nowrap; }
        .ap-hud-head .t { flex:1; overflow:hidden; text-overflow:ellipsis; }
        .ap-hud-head button { min-height:0; min-width:0; padding:1px 8px; font-size:0.78rem; }
        .ap-hud-body { padding:2px 10px 8px; }
        .ap-hud.collapsed .ap-hud-body { display:none; }
        .ap-hud.off { display:none !important; }
        .ap-menu-btn { position:absolute; top:10px; left:10px; z-index:1300; width:44px; height:44px; min-width:0; min-height:0; padding:0;
                       border-radius:12px; border:1px solid rgba(148,163,184,0.35); background:rgba(11,18,32,0.84); color:#e5e7eb;
                       font-size:1.35rem; line-height:1; cursor:pointer; box-shadow:0 4px 18px rgba(0,0,0,0.4); }
        .ap-menu-btn.open { background:var(--primary-color, #2563eb); border-color:var(--primary-color, #2563eb); color:#fff; }
        .ap-menu { position:absolute; top:62px; left:10px; z-index:1300; width:min(380px, calc(100% - 20px)); max-height:calc(100% - 72px); overflow:auto;
                   background:rgba(11,18,32,0.94); backdrop-filter:blur(6px); border:1px solid rgba(148,163,184,0.3); border-radius:12px;
                   color:#e5e7eb; font-size:0.85rem; box-shadow:0 6px 24px rgba(0,0,0,0.5); padding:10px 12px; box-sizing:border-box; }
        .ap-menu[hidden] { display:none; }
        .ap-menu-head { display:flex; align-items:center; gap:8px; font-weight:800; font-size:1rem; }
        .ap-menu-head img { height:28px; width:auto; }
        .ap-menu-head .t { flex:1; }
        .ap-menu .ap-totals { text-align:left; font-size:0.85rem; font-weight:600; opacity:0.85; margin:4px 0 2px; }
        .ap-sec { border-top:1px solid rgba(148,163,184,0.25); padding:9px 0 4px; margin-top:6px; }
        .ap-sec h4 { margin:0 0 7px; font-size:0.7rem; text-transform:uppercase; letter-spacing:0.08em; opacity:0.65; }
        .ap-menu .ap-pills { justify-content:flex-start; margin-bottom:4px; }
        .ap-show label { display:flex; align-items:center; gap:8px; padding:4px 0; cursor:pointer; }
        .ap-show .none { opacity:0.6; font-size:0.8rem; }
        .ap-acts { display:flex; flex-direction:column; gap:6px; }
        .ap-acts button { width:100%; text-align:left; min-height:0; padding:7px 10px; }
        .hud-tl { top:10px; left:10px; }
        .hud-bl { bottom:10px; left:10px; }
        .hud-br { bottom:10px; right:10px; }
        .hud-bc { bottom:10px; left:50%; transform:translateX(-50%); }
        .ap-views { margin-bottom:8px; }
        .ap-views .ap-pill { font-size:0.9rem; padding:6px 16px; }
        .ap-pill:disabled { opacity:0.35; cursor:not-allowed; }
        ${PyramidFlowView.css()}
        ${PyramidPresentView.css()}
        ${PyramidMapView.css()}
        ${PyramidPathView.css()}
        ${PyramidTablesView.css()}
        ${PyramidGrowthView.css()}
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
        <div id="ap-body"><div class="loading" style="padding-top:60px;">Loading…</div></div>
        <button class="ap-menu-btn" data-menu aria-label="☰">☰</button>
        <div class="ap-menu" hidden></div>
      </div>`;
    this.element = div;
    this._onFullLabel = () => this._renderMenu();
    document.addEventListener('fullscreenchange', this._onFullLabel);
    this._onKey = (e) => {
      if (e.target && /INPUT|SELECT|TEXTAREA/.test(e.target.tagName)) return;
      if (e.key && e.key.toLowerCase() === 'm' && !e.repeat && !e.ctrlKey && !e.metaKey && !e.altKey) this._menu();
      else if (e.key === 'Escape' && this.menuOpen) this._menu(false);
    };
    div.querySelector('.ap-stage').addEventListener('click', (e) => {
      // ☰ (✕ while open) opens and closes the one menu.
      if (e.target.closest('[data-menu]')) { this._menu(); return; }
      const act = e.target.closest('[data-act]');
      if (act) { this._menuAction(act.dataset.act); return; }
      if (e.target.closest('[data-show], [data-feature]')) return;   // checkbox: handled on change
      // ▾ / ▸ on any HUD: collapse to its title, remembered (owner: "the
      // huds should be collapsable").
      const tg = e.target.closest('[data-hud-toggle]');
      if (tg) { this._toggleHud(tg.closest('[data-hud]')); return; }
      // A team's name anywhere → its club card (mig 856).
      const club = e.target.closest('[data-club]');
      if (club && !e.target.closest('.pz-vp')) { this.openClub(Number(club.dataset.club)); return; }
      const vp = e.target.closest('[data-view]');
      if (vp) {
        const v = this.views.find((x) => x.code === vp.dataset.view);
        if (v && v.built && v.code !== this.view) {
          this._viewCall('unmount');
          this.view = v.code;
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
    div.querySelector('.ap-stage').addEventListener('change', (e) => {
      const show = e.target.closest('[data-show]');
      if (show) { this._setShown(show.dataset.show, show.checked); return; }
      const feat = e.target.closest('[data-feature]');
      if (feat) { this._setFeature(feat.dataset.feature, feat.checked); return; }
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
    window.addEventListener('keydown', this._onKey);
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => {
      const b = this.find('.ap-menu-btn'); if (b && this._copy('menu_button')) b.title = this._copy('menu_button');
      if (this.data) this._renderBody(); else this._renderMenu();
    });
    this.load(false);
  }

  onExit() {
    window.removeEventListener('resize', this._onResize);
    window.removeEventListener('keydown', this._onKey);
    this._menu(false);
    this._viewCall('unmount');
    this.clubCard.close();
    if (document.fullscreenElement) document.exitFullscreen();
  }

  // ── the ☰ menu (mig 1234) ────────────────────────────────────────────
  _menu(open = !this.menuOpen) {
    this.menuOpen = !!open;
    const m = this.find('.ap-menu'), b = this.find('.ap-menu-btn');
    if (m) m.hidden = !this.menuOpen;
    if (b) { b.classList.toggle('open', this.menuOpen); b.textContent = this.menuOpen ? '✕' : '☰'; }
    if (this.menuOpen) this._renderMenu();
  }

  _menuAction(act) {
    if (act === 'full') {
      const stage = this.find('.ap-stage');
      if (document.fullscreenElement) document.exitFullscreen(); else if (stage && stage.requestFullscreen) stage.requestFullscreen();
    } else if (act === 'refresh') this.load(true);
    else if (act === 'back') this.navigation.goBack();
  }

  // Sections: title + totals, View, Conferences, Show on screen, Actions.
  _renderMenu() {
    const m = this.find('.ap-menu');
    if (!m || !this.menuOpen) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const root = this.model && this.model.root();
    const sec = (tier, inner) => `<div class="ap-sec"><h4>${esc(this._copy(tier))}</h4>${inner}</div>`;
    let body = '';
    if (this.model) {
      const views = this.views.map((v) => `<button class="ap-pill ${this.view === v.code ? 'on' : ''}" data-view="${v.code}"${v.built ? '' : ` disabled title="${esc(this._copy('view_soon'))}"`}>${esc(this._copy(v.tier))}</button>`).join('');
      const confs = [`<button class="ap-pill ${!this.on ? 'on' : ''}" data-conf="all">${esc(this._copy('pill_all'))}</button>`]
        .concat(this._conferences().map((c) => `<button class="ap-pill ${this.on && this.on.has(c.id) ? 'on' : ''}" data-conf="${c.id}">${esc(c.short_name || c.name)}</button>`))
        .join('');
      // The view's floating panels; the map's Club HUD comes and goes with a pick.
      const huds = [...this.findAll('#ap-view [data-hud]')].filter((h) => !['map-club', 'map-proposal'].includes(h.dataset.hud));
      // …and the view's on/off features (impl.features(): outlier lines on
      // the chart, proposed borders on the map — mig 1238/1239).
      const feats = (this._impl().features ? this._impl().features() : [])
        .map((f) => `<label><input type="checkbox" data-feature="${esc(f.key)}" ${this.feature(f.key, f.def) ? 'checked' : ''}> ${esc(this._copy(f.tier))}</label>`);
      const rows = huds.map((h) => `<label><input type="checkbox" data-show="${esc(h.dataset.hud)}" ${this._hudShown(h.dataset.hud) ? 'checked' : ''}> ${esc(h.querySelector('.ap-hud-head .t').textContent)}</label>`)
        .concat(feats);
      const show = rows.length ? rows.join('') : `<div class="none">${esc(this._copy('menu_show_none'))}</div>`;
      body = `
        <div class="ap-totals">${esc(this._copy('totals', this.model.totals))}${this.loading ? ' · ⟳' : ''}</div>
        ${sec('menu_view', `<div class="ap-pills">${views}</div>`)}
        ${sec('menu_conf', `<div class="ap-pills">${confs}</div>`)}
        ${sec('menu_show', `<div class="ap-show">${show}</div>`)}`;
    }
    const acts = [
      `<button class="btn btn-secondary" data-act="full">${esc(this._copy(document.fullscreenElement ? 'map_exit_full' : 'map_full') || '⛶')}</button>`,
      `<button class="btn btn-secondary" data-act="refresh" id="ap-refresh">${esc(this._copy('menu_refresh'))}</button>`,
      this.auth.isLoggedIn() ? `<button class="btn btn-secondary" data-act="back">${esc(this._copy('menu_back'))}</button>` : '',
    ].join('');
    m.innerHTML = `
      <div class="ap-menu-head">
        ${root && root.logo_url ? `<img src="${esc(root.logo_url)}" alt="">` : ''}
        <span class="t">${esc(this._copy('title'))}</span>
      </div>
      ${body}
      ${sec('menu_actions', `<div class="ap-acts">${acts}</div>`)}`;
  }

  findAll(sel) { return this.element ? this.element.querySelectorAll(sel) : []; }

  // ── floating HUDs: shown only when ticked in ☰ Show on screen ────────
  _hudShown(key) { try { return localStorage.getItem(`apsl-show-${key}`) === '1'; } catch (_) { return false; } }
  _setShown(key, on) {
    try { localStorage.setItem(`apsl-show-${key}`, on ? '1' : '0'); } catch (_) { /* private mode */ }
    this.findAll(`#ap-view [data-hud="${key}"]`).forEach((el) => el.classList.toggle('off', !on));
    this._viewCall('onResize');
  }
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
  _hudCollapsed(key) { try { return localStorage.getItem(`apsl-hud-${key}`) === '1'; } catch (_) { return false; } }
  _toggleHud(el) {
    if (!el) return;
    const key = el.dataset.hud;
    const now = !el.classList.contains('collapsed');
    el.classList.toggle('collapsed', now);
    const b = el.querySelector('[data-hud-toggle]');
    if (b) b.textContent = now ? '▸' : '▾';
    try { localStorage.setItem(`apsl-hud-${key}`, now ? '1' : '0'); } catch (_) { /* private mode */ }
    this._viewCall('onResize');
  }
  // A view's HUD panel: title + ▾/▸ + body; pos = hud-tl / hud-bl / hud-br / hud-bc.
  // Off until ticked in ☰ (the map's Club HUD always rides its pick).
  hud(key, title, body, pos = 'hud-bl', extra = '') {
    const c = this._hudCollapsed(key);
    // The Club HUD rides a pick and the proposal HUD its ☰ feature switch.
    const off = !['map-club', 'map-proposal'].includes(key) && !this._hudShown(key);
    return `
      <div class="ap-hud ${pos}${c ? ' collapsed' : ''}${off ? ' off' : ''} ${extra}" data-hud="${key}">
        <div class="ap-hud-head"><span class="t">${this.escapeHtml(title || '')}</span><button class="btn btn-secondary" data-hud-toggle>${c ? '▸' : '▾'}</button></div>
        <div class="ap-hud-body">${body}</div>
      </div>`;
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
  _toggle(key) {
    const all = this._conferences().map((c) => c.id);
    if (key === 'all') this.on = null;
    else {
      const id = Number(key);
      const set = this.on ? new Set(this.on) : new Set(all);
      if (set.has(id)) set.delete(id); else set.add(id);
      this.on = set.size === all.length ? null : set;
    }
    try { localStorage.setItem('apsl-pyramid-on', JSON.stringify(this.on ? [...this.on] : null)); } catch (_) { /* private mode */ }
    this._renderBody();
  }

  _renderBody() {
    const el = this.find('#ap-body');
    if (!el) return;
    if (this.loading && !this.data) { el.innerHTML = '<div class="loading">Loading…</div>'; return; }
    if (this.err) { el.innerHTML = `<div class="error">${this.escapeHtml(this.err)}</div>`; this._renderMenu(); return; }
    if (!this.model) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const shown = this._shown();
    // A view that is a canvas (map, presentation) fills the stage edge to edge.
    el.classList.toggle('flush', !!this._impl().fill);
    el.innerHTML = `
      <div id="ap-view">${shown.length ? this._impl().html(this.model, shown) : `<div class="fc-none">${esc(this._copy('none_on'))}</div>`}</div>
      ${this.edit ? this._editorHtml() : ''}`;
    this._renderMenu();
    if (shown.length) requestAnimationFrame(() => this._viewCall('mount'));
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
