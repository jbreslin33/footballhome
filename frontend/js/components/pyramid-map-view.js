// pyramid-map-view.js — #apsl-pyramid "USA map" (mig 844), a view over
// PyramidModel.  Owner 2026-10-29: "ok next view usa map"; first ask: "map
// form — you jump round the usa and it shows you the pyramid."
//
// A US map (Leaflet, vendored in frontend/vendor/leaflet, loaded only when
// this view opens) with a dot per club at its home
// ground — blue for a club with an APSL team, teal for a feeder-only club;
// a club whose league publishes no address sits at its league's point,
// dimmed and dashed.  Each conference has a label at its clubs' middle; tap
// it (or a dot) and the camera flies there and THAT conference's pyramid —
// the same chart PyramidFlowView draws — opens as an overlay ON the map.
//
// Mig 850 (owner: "i want map full screen and the data as hud … overlay
// over map … transparency … slider"): the map fills the page (⛶ = the
// browser's full screen); totals, the dot legend and the located count float
// on it as a HUD; the overlay has a see-through slider (remembered) and
// closes with ✕ / Esc.  All of it lives inside the full-screen element.
//
// Owner 2026-10-29: "we need team names on the dots. we need a line drawn
// around the conference when picked and the conference highlighted. base it
// off teams in other conferences around it to infer map borders."
//   names      each club's name beside its dot when zoomed in (and always
//              for the picked conference) — placed like the bubbles: a free
//              side of the dot or not at all; picked conference first,
//              then APSL clubs, then feeders.
//   territory  counties (mig 852, owner: "its really based on metro size …
//              pretend your making the conferences from scratch based off
//              population and distance"): a county is the conference's whose
//              nearest APSL club is closest, within ~an hour's drive — GET
//              /api/pyramid/territory draws the picked one's counties, tinted,
//              with only its OUTER border outlined; the HUD gives the
//              population inside, and Sunday (no traffic) drive times: the
//              two furthest clubs, the shortest trip — the derby (mig
//              857) — the average if all play all, and the median (mig 854); and
//              the main city (mig 860) — its city limits outlined, its collar
//              counties dashed, the APSL teams counted in the city / the
//              collar / further out.
// The conference pills choose which conferences' clubs are on the map.
// Mig 871 (owner: "the map is pretty bare can we have option of satelite
// etc"): the map underneath is a pill in the key HUD — pyramid_map_layers
// rows (Dark = OpenStreetMap darkened in CSS; CARTO's dark tiles now want an
// API key), the viewer's pick remembered.
//
// Nothing hides anything (owner 2026-10-29: "use arrows to bubble as its
// covering each other up. so it needs to auto adjust so its all visible"):
// after every zoom / pan, _relayout() works in screen pixels — conference
// bubbles are pushed apart until none overlap and point back to their spot
// with a leader line ending in a ring; dots sharing one point (a shared
// ground, or a league's point) fan out in a small ring around it.
//
// Picking a club (mig 866; owner: "we need to be able to select a club on
// the map! … and it should show data in hud on that club"): a dot, a club's
// name beside it, or a team in the conference overlay's tables.  The club's
// dots ring yellow and its names show (yellow) at any zoom; its card (mig
// 856) is the Club HUD on the left, under the Conference HUD.  ✕ or Esc
// lets it go (Esc again closes the conference).
//
// Proposal layer (mig 1241, owner 2026-11-11: "draw a line where you
// propose borders for all conferences and judge proposed new ones with names
// in the rest of country … fill the map" / "maps only" / "toggle"): GET
// /api/pyramid/proposal — every lower-48 county goes to its nearest APSL
// ground or proposed city; dashed lines where regions meet, a label per
// proposed conference (tier from its people within 100 km vs the smallest
// live conference), dashed rings for the watch list, and the verdicts in
// the "Proposed conferences" panel.  ☰ Show on screen switches it (on by
// default for club admins; a visitor ticks it — it is our proposal, not
// APSL's).
class PyramidMapView {
  features() {
    const u = this.screen.auth && this.screen.auth.getUser && this.screen.auth.getUser();
    return [{ key: 'proposal', tier: 'feature_proposal', def: !!(u && ['club', 'super'].includes(u.role)) },
            { key: 'states', tier: 'feature_states', def: true }];
  }
  onFeature(key, on) {
    if (key === 'proposal') this._showProposal(on);
    if (key === 'states') this._showStates(on);
  }

  // State lines (mig 1257, owner: "show state borders clearer"): their own
  // layer over the tiles, under the conference borders.  Fetched once.
  async _showStates(on) {
    const L = window.L;
    if (!this.map || !this.stateLayer) return;
    this.stateLayer.clearLayers();
    if (!on) return;
    if (!PyramidMapView._states) {
      try {
        const res = await this.screen.auth.fetch('/api/pyramid/state-borders');
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        PyramidMapView._states = (await res.json()).lines || [];
      } catch (e) { console.warn('state borders', e); return; }
    }
    if (!this.map || !this.screen.feature('states', true)) return;
    for (const line of PyramidMapView._states)
      L.polyline(line, { renderer: this.stateRenderer, interactive: false, color: '#e2e8f0', weight: 2, opacity: 0.85 }).addTo(this.stateLayer);
  }

  // The conference list lives in the ☰ menu (owner: "proposed confs gui
  // should be in main gui" / "get rid of clutter!"; mig 1269: "put the
  // existing in the list and mark off existing and proposed" / "list by pop
  // desc"): the count (existing + proposed = total), then one row per
  // conference, biggest metro first — colour dot, name, Existing / Proposed
  // tag (a proposal's tag carries its tier colour), cities · metro people.
  // A proposal's judgement is the row's tooltip.  Tap → fly there.
  menuSections() {
    const P = this.proposal;
    if (!P || !(this.screen.feature && this.screen.feature('proposal', this.features()[0].def))) return [];
    const esc = (t) => this._esc(t);
    const M = (n) => (n == null ? '—' : `${(n / 1e6).toFixed(1)} M`);
    const tierLabel = (t) => this._copy(`tier_${t}`) || t;
    // Two plans (mig 1274, owner: "pill toggle to show proposed and current
    // because it gives you freedom to move borders or delete or re imagine
    // current to fit new"): Current = today's conferences; Proposed = the
    // re-imagined map (today's ones as proposals of their own, free to change).
    const plan = this._plan();
    const regs = (P.regions || []).filter((r) => r.plan === plan);
    const live = regs.filter((r) => r.conference_id || r.from_conference_id);
    const proposed = regs.filter((r) => r.proposed_id && !r.from_conference_id).concat(plan === 'proposed' ? (P.watch || []) : []);
    const count = plan === 'current' ? this._copy('proposal_count_current', { live: live.length })
      : this._copy('proposal_count', { live: live.length, proposed: proposed.length, total: live.length + proposed.length });
    const planPills = ['current', 'proposed'].map((k) => `<button class="ap-pill${k === plan ? ' on' : ''}" data-pzplan="${k}">${esc(this._copy(`plan_${k}`))}</button>`).join('');
    // The table (mig 1272, owner: "show me data in the menu that i can sort
    // by longest trip asc,desc … longest dist … pop … land area"): one row a
    // conference; a column header / sort pill sorts by it, tapped again flips.
    const cols = [
      { key: 'name', label: this._copy('col_name'), val: (r) => r.name.replace(/ Conference$/, ''), txt: true },
      { key: 'pop', label: this._copy('col_pop'), val: (r) => r.population, fmt: (v) => M(v).replace(' ', '') },
      { key: 'area', label: this._copy('col_area'), val: (r) => r.area_km2, fmt: (v) => (v == null ? '—' : `${Math.round(v / 1000)}k`) },
      { key: 'dist', label: this._copy('col_dist'), val: (r) => r.span_km, fmt: (v) => (v == null ? '—' : Math.round(v)) },
      { key: 'drive', label: this._copy('col_drive'), val: (r) => r.drive_min, fmt: (v) => (v == null ? '—' : `${Math.floor(Math.round(v) / 60)}:${String(Math.round(v) % 60).padStart(2, '0')}`) },
      { key: 'counties', label: this._copy('col_counties'), val: (r) => r.counties, fmt: (v) => (v == null ? '—' : v) },
    ];
    const sort = this.pzSort || (this.pzSort = { key: 'pop', dir: -1 });
    const col = cols.find((c) => c.key === sort.key) || cols[1];
    const all = live.concat(proposed).sort((a, b) => {
      const x = col.val(a), y = col.val(b);
      if (col.txt) return sort.dir * String(x).localeCompare(String(y));
      return sort.dir * ((x == null ? -Infinity : x) - (y == null ? -Infinity : y));
    });
    const arrow = (c) => (c.key === sort.key ? (sort.dir > 0 ? ' ↑' : ' ↓') : '');
    const head = cols.map((c) => `<th data-pzsort="${c.key}" class="${c.key === sort.key ? 'on' : ''}">${esc(c.label)}${arrow(c)}</th>`).join('');
    const body = all.map((r) => {
      const isLive = !!(r.conference_id || r.from_conference_id);
      const tip = isLive ? (r.anchors || '') : `${tierLabel(r.tier)} — ${r.note || ''}`;
      const far = r.far_a ? ` · ${this._copy('pill_far', { a: r.far_a, b: r.far_b })}` : '';
      return `<tr data-pzrow="${r.lat},${r.lon}" title="${esc(tip + far)}">
        <td class="nm"><i class="dot" style="background:${esc(r.color || '#64748b')}"></i>${esc(cols[0].val(r))}
          <span class="tag ${isLive ? 'live' : esc(r.tier)}">${esc(this._copy(isLive ? 'mark_live' : 'mark_proposed'))}</span></td>
        ${cols.slice(1).map((c) => `<td>${esc(c.fmt(c.val(r)))}</td>`).join('')}</tr>`;
    }).join('');
    return [{ tier: 'proposal_hud',
      html: `<div class="mp-pz"><div class="mp-sorts">${planPills}</div><div class="count">${esc(count)}</div>
        <div class="intro">${esc(this._copy('sort_label'))}</div>
        <div class="mp-sorts">${cols.map((c) => `<button class="ap-pill${c.key === sort.key ? ' on' : ''}" data-pzsort="${c.key}">${esc(c.label)}${arrow(c)}</button>`).join('')}</div>
        <div class="mp-tbl"><table><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>
        <div class="intro">${esc(this._copy('proposal_lines'))}</div><div class="intro">${esc(plan === 'current' ? this._copy('plan_current_intro') : this._copy('proposal_intro', { bar: M(P.bar) }))}</div></div>` }];
  }
  _plan() {
    if (!this.pzPlan) {
      let v = null;
      try { v = localStorage.getItem('fh.pyramid.plan'); } catch (_) { /* private mode */ }
      this.pzPlan = v === 'current' ? 'current' : 'proposed';
    }
    return this.pzPlan;
  }
  _hm(min) {
    if (min == null) return '—';
    const m = Math.round(min);
    return `${Math.floor(m / 60)} h ${String(m % 60).padStart(2, '0')}`;
  }
  menuClick(e) {
    const pl = e.target.closest('[data-pzplan]');
    if (pl) {   // switch plan (mig 1274): redraw borders, pills and the table
      this.pzPlan = pl.dataset.pzplan;
      try { localStorage.setItem('fh.pyramid.plan', this.pzPlan); } catch (_) { /* private mode */ }
      this._showProposal(true);
      return true;
    }
    const srt = e.target.closest('[data-pzsort]');
    if (srt) {   // sort the table (mig 1272): a new column starts biggest-first (names A→Z), the same one flips
      const k = srt.dataset.pzsort, cur = this.pzSort || { key: 'pop', dir: -1 };
      this.pzSort = cur.key === k ? { key: k, dir: -cur.dir } : { key: k, dir: k === 'name' ? 1 : -1 };
      this.screen._renderMenu();
      return true;
    }
    const r = e.target.closest('[data-pzrow]');
    if (!r || !this.map) return false;
    const [lat, lon] = r.dataset.pzrow.split(',').map(Number);
    this.map.flyTo([lat, lon], Math.max(this.map.getZoom(), 6), { duration: 0.6 });
    return true;
  }

  constructor(screen, flow) {
    this.screen = screen; this.flow = flow;
    this.fill = true;   // a canvas: fills the stage, writing in HUDs
    this.map = null; this.sel = null;
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }
  // "8.1 M · ↔ 520 km · 5 h 10" — people, furthest-apart county centres (mig 1270).
  _pillStats(r) {
    const pop = r.population == null ? '—' : `${(r.population / 1e6).toFixed(1)} M`;
    const drive = this._hm(r.drive_min);
    return this._copy('pill_stats', { pop, km: r.span_km == null ? '—' : Math.round(r.span_km), drive });
  }

  static css() {
    return `
      .mp-map.mp-dark .leaflet-tile-pane { filter:invert(1) hue-rotate(180deg) brightness(0.9) contrast(0.9) saturate(0.6); }
      .mp-stage { position:absolute; inset:0; overflow:hidden; }
      .mp-map { position:absolute; inset:0; background:#0b1220; }
      .mp-hud-stats { max-width:360px; line-height:1.45; }
      .mp-layers { display:flex; flex-wrap:wrap; gap:4px; margin-bottom:6px; }
      .mp-hud-stats b { font-size:0.9rem; }
      .mp-key span { display:block; }
      .mp-key i { display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:6px; vertical-align:-1px; }
      .mp-ov { position:absolute; z-index:1200; top:56px; right:12px; bottom:12px; width:min(820px, calc(100% - 24px)); display:flex; flex-direction:column;
               background:rgba(11,18,32,0.92); border:1px solid rgba(148,163,184,0.35); border-radius:12px; box-shadow:0 8px 30px rgba(0,0,0,0.5); }
      .mp-ov[hidden] { display:none; }
      .mp-name { color:#f8fafc; font-size:11px; font-weight:600; white-space:nowrap; text-shadow:0 0 3px #0b1220, 0 0 3px #0b1220, 0 0 2px #0b1220;
                 transform:translate(0, -50%); display:inline-block; pointer-events:none; }
      .mp-name.shown { pointer-events:auto; cursor:pointer; }
      .mp-name.shown:hover { text-decoration:underline; }
      .mp-name.on { color:#facc15; font-size:12px; font-weight:800; }
      .hud-club:not(.has-club) { display:none; }
      .mp-ov-head { display:flex; align-items:center; gap:10px; padding:8px 12px; border-bottom:1px solid rgba(148,163,184,0.2); }
      .mp-ov-head h3 { margin:0; flex:1; font-size:1rem; }
      .mp-ov-head label { font-size:0.75rem; opacity:0.85; display:flex; align-items:center; gap:6px; }
      .mp-ov-head input[type=range] { width:120px; }
      .mp-ov-head button { min-height:0; min-width:0; padding:2px 10px; }
      .mp-ov-body { overflow:auto; padding:10px; flex:1; }
      .mp-pin { pointer-events:none !important; overflow:visible; }
      .mp-pin .mp-label { pointer-events:auto; }
      .mp-label { background:var(--cc, #1d4ed8); color:var(--cc-fg, #fff); font-weight:800; font-size:12px; padding:3px 9px; border-radius:999px;
                  border:2px solid rgba(255,255,255,0.75); white-space:nowrap; box-shadow:0 2px 8px rgba(0,0,0,0.5); cursor:pointer; transform:translate(-50%, -50%); display:inline-block; }
      .mp-label.on { background:#facc15; color:#111827; border-color:#fff; }
      .mp-prop { transform:translate(-50%, -50%); display:inline-flex; flex-direction:column; align-items:center; white-space:nowrap; pointer-events:auto;
                 background:rgba(11,18,32,0.88); border:2px solid var(--pc, #94a3b8); border-radius:10px; padding:2px 8px; line-height:1.2;
                 color:#e2e8f0; font-size:10px; box-shadow:0 2px 6px rgba(0,0,0,0.45); }
      .mp-prop b { color:var(--pc, #e2e8f0); font-size:11px; font-weight:800; }
      .mp-prop.live { transform:translate(-50%, 16px); border-style:solid; }
      .mp-pz .row { display:flex; align-items:baseline; gap:6px; padding:4px 0; border-top:1px solid rgba(148,163,184,0.12); cursor:pointer; font-size:0.82rem; }
      .mp-pz .row:hover .nm { text-decoration:underline; }
      .mp-pz .nm { font-weight:800; white-space:nowrap; }
      .mp-pz .sub { flex:1; opacity:0.7; font-size:0.74rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
      .mp-pz .tier { width:8px; height:8px; border-radius:50%; flex:0 0 auto; align-self:center; }
      .mp-pz .tier.ready { background:#22c55e; } .mp-pz .tier.borderline { background:#eab308; } .mp-pz .tier.developing { background:#64748b; }
      .mp-pz .dot { width:9px; height:9px; border-radius:50%; flex:0 0 auto; align-self:center; }
      .mp-pz .tag { flex:0 0 auto; font-size:0.62rem; font-weight:800; text-transform:uppercase; letter-spacing:0.03em; padding:1px 5px; border-radius:6px; border:1px solid currentColor; }
      .mp-pz .tag.live { color:#e2e8f0; background:rgba(226,232,240,0.14); }
      .mp-pz .tag.ready { color:#22c55e; } .mp-pz .tag.borderline { color:#eab308; } .mp-pz .tag.developing { color:#94a3b8; }
      .mp-sorts { display:flex; flex-wrap:wrap; gap:4px; margin:2px 0 6px; }
      .mp-sorts .ap-pill { font-size:0.7rem; padding:2px 8px; }
      .mp-tbl { overflow-x:auto; margin-bottom:6px; }
      .mp-tbl table { border-collapse:collapse; width:100%; font-size:0.7rem; }
      .mp-tbl th { position:sticky; top:0; background:rgba(15,23,42,0.96); text-align:right; font-weight:800; padding:3px 4px; cursor:pointer; white-space:nowrap; opacity:0.8; }
      .mp-tbl th:first-child, .mp-tbl td:first-child { text-align:left; }
      .mp-tbl th.on { color:#facc15; opacity:1; }
      .mp-tbl td { text-align:right; padding:3px 4px; border-top:1px solid rgba(148,163,184,0.12); white-space:nowrap; font-variant-numeric:tabular-nums; }
      .mp-tbl tr { cursor:pointer; } .mp-tbl tr:hover td { background:rgba(148,163,184,0.1); }
      .mp-tbl .nm { font-weight:800; } .mp-tbl .nm .dot { display:inline-block; margin-right:4px; vertical-align:middle; }
      .mp-tbl .nm .tag { display:table; margin:1px 0 0 13px; font-size:0.5rem; padding:0 3px; }
      .mp-tbl td, .mp-tbl th { padding:3px 3px; }
      .mp-pz .count { font-weight:800; font-size:0.85rem; margin-bottom:4px; }
      .mp-pz .intro { font-size:0.72rem; opacity:0.65; margin-bottom:4px; white-space:normal; }
`;
  }

  // Leaflet once per page, on first use.
  static load() {
    if (window.L) return Promise.resolve();
    if (PyramidMapView._loading) return PyramidMapView._loading;
    PyramidMapView._loading = new Promise((resolve, reject) => {
      const css = document.createElement('link');
      css.rel = 'stylesheet'; css.href = 'vendor/leaflet/leaflet.css';
      document.head.appendChild(css);
      const js = document.createElement('script');
      js.src = 'vendor/leaflet/leaflet.js';
      js.onload = () => resolve();
      js.onerror = () => { PyramidMapView._loading = null; reject(new Error('map library failed to load')); };
      document.head.appendChild(js);
    });
    return PyramidMapView._loading;
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    let alpha = 0.92;
    try { alpha = Number(localStorage.getItem('apsl-pyramid-map-ov')) || 0.92; } catch (_) { /* private mode */ }
    this.alpha = alpha;
    return `
      <div class="mp-stage">
        <div class="mp-map"></div>
        ${this.screen.hud('map-key', this._copy('hud_map'), `
          <div class="mp-layers">${(model.data.map_layers || []).map((l) => `<button class="ap-pill" data-mp="layer" data-code="${esc(l.code)}">${esc(l.label)}</button>`).join('')}</div>
          <div class="mp-key">
            <span><i style="background:#3b82f6"></i>${esc(this._copy('map_dot_apsl'))}</span>
            <span><i style="background:#14b8a6"></i>${esc(this._copy('map_dot_feeder'))}</span>
            <span><i style="background:rgba(20,184,166,0.35); outline:1px dashed #64748b"></i>${esc(this._copy('map_dot_approx'))}</span>
          </div>
          <div class="mp-hud-count" style="margin-top:4px; opacity:0.85;"></div>
          <div style="margin-top:2px; opacity:0.7;">${esc(this._copy('map_hint'))}</div>`, 'hud-bl')}
        ${this.screen.hud('map-stats', this._copy('hud_stats'), `<div class="mp-hud-stats">${esc(this._copy('map_pick'))}</div>`, 'hud-tl')}
        ${this.screen.hud('map-club', this._copy('hud_club'), '<div data-cc-host="hud"></div>', '', 'hud-club')}
        <div class="mp-ov" hidden style="opacity:${alpha}">
          <div class="mp-ov-head">
            <h3></h3>
            <label>${esc(this._copy('map_opacity'))}<input type="range" min="0.25" max="1" step="0.05" value="${alpha}" data-mp="alpha"></label>
            <button class="btn btn-secondary" data-mp="close" title="Esc">${esc(this._copy('map_close'))}</button>
          </div>
          <div class="mp-ov-body"></div>
        </div>
      </div>`;
  }

  async mount(root, model, confs) {
    this.root = root; this.model = model; this.confs = confs;
    try { await PyramidMapView.load(); } catch (e) {
      root.querySelector('.mp-map').innerHTML = `<div class="error">${this._esc(e.message)}</div>`;
      return;
    }
    if (!root.isConnected) return;
    if (this.map) { this.map.remove(); this.map = null; }
    const L = window.L;
    this.map = L.map(root.querySelector('.mp-map'), { zoomSnap: 0.25, attributionControl: true, zoomControl: false });
    L.control.zoom({ position: 'bottomright' }).addTo(this.map);
    let picked = null;
    try { picked = localStorage.getItem('apsl-pyramid-map-layer'); } catch (_) { /* private mode */ }
    this._setLayer(picked);

    const L2 = model.layout(confs);
    this.columns = L2.columns;
    const seen = new Set();
    const all = [];
    this.dots = [];
    let located = 0;
    // A dot per TEAM at its own ground (mig 855: Oaklyn's APSL side and its
    // Liga 1 side play at different fields).
    for (const col of this.columns) {
      for (const { team, division } of model.columnTeams(col)) {
        if (seen.has(team.id)) continue;
        seen.add(team.id);
        const p = model.teamPoint(team.id, division.id);
        if (!p) continue;
        if (!p.approx) located++;
        all.push([p.lat, p.lon]);
        const apsl = model.divisionTier(division.id) === 'apsl';
        const color = apsl ? '#3b82f6' : '#14b8a6';
        const m = L.circleMarker([p.lat, p.lon], {
          interactive: false,
          radius: apsl ? 7 : 5, color: p.approx ? '#64748b' : '#0b1220', weight: 1.5, dashArray: p.approx ? '3 3' : null,
          fillColor: color, fillOpacity: p.approx ? 0.35 : 0.9,
        }).addTo(this.map);
        const name = L.marker([p.lat, p.lon], {
          icon: L.divIcon({ className: '', html: `<span class="mp-name" data-map-club="${team.club_id}">${this._esc(team.name)}</span>`, iconSize: null }),
          interactive: false, keyboard: false, opacity: 0,
        }).addTo(this.map);
        this.dots.push({ m, name, label: team.name, clubId: team.club_id, conf: col.conf.id, apsl, approx: p.approx, r: apsl ? 7 : 5,
                         at: L.latLng(p.lat, p.lon), key: `${p.lat.toFixed(4)},${p.lon.toFixed(4)}` });
      }
    }
    // A label per conference at its clubs' middle (else its own point).
    this.labels = new Map();
    for (const col of this.columns) {
      const pts = model.columnTeams(col).map(({ team, division }) => model.teamPoint(team.id, division.id)).filter((p) => p && !p.approx);
      const at = pts.length ? [pts.reduce((a, p) => a + p.lat, 0) / pts.length, pts.reduce((a, p) => a + p.lon, 0) / pts.length]
        : (col.conf.lat != null ? [col.conf.lat, col.conf.lon] : null);
      if (!at) continue;
      // A zero-size marker box: only the visible bubble takes clicks (a
      // content-sized box hung down-right of it and swallowed dots' clicks).
      // The bubble wears the conference's colour (mig 1249).
      const cc = col.conf.color || '#1d4ed8';
      const ink = window.PyramidScreenColor ? PyramidScreenColor.ink(cc) : '#fff';
      const icon = L.divIcon({ className: 'mp-pin', html: `<span class="mp-label" data-conf-label="${col.conf.id}" style="--cc:${this._esc(cc)}; --cc-fg:${ink}">${this._esc(model.label(col.conf))}</span>`, iconSize: [0, 0] });
      const anchor = L.latLng(at[0], at[1]);
      const line = L.polyline([anchor, anchor], { color: cc, weight: 1.5, opacity: 0.9, interactive: false }).addTo(this.map);
      const ring = L.circleMarker(anchor, { radius: 5, color: cc, weight: 2, fill: false, interactive: false }).addTo(this.map);
      const mk = L.marker(anchor, { icon, zIndexOffset: 1000 }).addTo(this.map);
      mk.on('click', () => this.select(col.conf.id, true));
      this.labels.set(col.conf.id, { mk, anchor, line, ring });
    }
    // The territory layer: its own pane, under the dots and bubbles.
    const pane = this.map.createPane('mp-territory');
    pane.style.zIndex = 350;
    pane.style.pointerEvents = 'none';
    this.terrRenderer = L.svg({ pane: 'mp-territory' });
    this.terrLayer = L.layerGroup().addTo(this.map);
    this.terrCache = this.terrCache || new Map();
    const spane = this.map.createPane('mp-states');
    spane.style.zIndex = 330;
    spane.style.pointerEvents = 'none';
    this.stateRenderer = L.svg({ pane: 'mp-states' });
    this.stateLayer = L.layerGroup().addTo(this.map);
    if (this.screen.feature && this.screen.feature('states', true)) this._showStates(true);
    const ppane = this.map.createPane('mp-proposal');
    ppane.style.zIndex = 340;
    ppane.style.pointerEvents = 'none';
    this.propRenderer = L.svg({ pane: 'mp-proposal' });
    this.propLayer = L.layerGroup().addTo(this.map);
    this.propLines = L.layerGroup().addTo(this.map);
    this.map.on('zoomend', () => this._drawBorders());
    if (this.screen.feature && this.screen.feature('proposal', this.features()[0].def)) this._showProposal(true);   // features()[0] = proposal
    this.map.on('zoomend moveend', () => this._relayout());
    // Picking a team: the dots don't take clicks themselves (5–7px circles,
    // fanned rings overlap); the map finds the NEAREST dot within 16px of
    // the pointer — its name shows on hover and the cursor turns to a
    // pointer.  A club's shown name is a target too (mig 866).
    const tip = L.tooltip({ direction: 'top', offset: [0, -8] });
    this.map.on('mousemove', (e) => {
      const d = this._nearestDot(e.containerPoint);
      this.map.getContainer().style.cursor = d ? 'pointer' : '';
      if (d) tip.setLatLng(d.m.getLatLng()).setContent(this._esc(d.label)).addTo(this.map); else tip.remove();
    });
    this.map.on('mouseout', () => { tip.remove(); this.map.getContainer().style.cursor = ''; });
    this.map.on('click', (e) => {
      const nm = e.originalEvent && e.originalEvent.target.closest && e.originalEvent.target.closest('[data-map-club]');
      if (nm) { this.pickClub(Number(nm.dataset.mapClub), false); return; }
      const d = this._nearestDot(e.containerPoint);
      if (d) this.pickClub(d.clubId, false);
    });
    this._bindHud(root);
    const count = this.screen.find('.mp-hud-count');
    if (count) count.textContent = this._copy('map_located', { located, clubs: seen.size });
    this.all = all;
    if (this.sel && this.columns.some((c) => c.conf.id === this.sel)) this.select(this.sel, false, true);
    else { this.sel = null; this._fitAll(); this._panel(); }
    if (this.club) { const c = this.club; this.club = null; this.pickClub(c, false); }
    requestAnimationFrame(() => this._relayout());
  }

  _nearestDot(pt, within = 16) {
    let best = null, bd = within;
    for (const d of this.dots || []) {
      const q = this.map.latLngToContainerPoint(d.m.getLatLng());
      const dist = Math.hypot(q.x - pt.x, q.y - pt.y);
      if (dist <= bd) { bd = dist; best = d; }
    }
    return best;
  }

  // ── keep everything visible ───────────────────────────────────────────
  _relayout() {
    if (!this.map) return;
    const map = this.map;
    // Dots sharing a point fan out in a ring (golden-angle spiral when many).
    const groups = new Map();
    for (const d of this.dots || []) { if (!groups.has(d.key)) groups.set(d.key, []); groups.get(d.key).push(d); }
    for (const list of groups.values()) {
      if (list.length === 1) { list[0].m.setLatLng(list[0].at); continue; }
      const c = map.latLngToContainerPoint(list[0].at);
      list.forEach((d, i) => {
        const r = list.length <= 8 ? 11 : 6 * Math.sqrt(i + 1);
        const a = list.length <= 8 ? (2 * Math.PI * i) / list.length : i * 2.39996;
        d.m.setLatLng(map.containerPointToLatLng([c.x + r * Math.cos(a), c.y + r * Math.sin(a)]));
      });
    }
    // Conference bubbles: each takes the first free slot on a ring of
    // candidate spots around its point (above, below, diagonals, further
    // out) — never over another bubble or the zoom buttons, always inside
    // the map.  A conference off-screen starts from the nearest edge point
    // in its direction.  A leader line runs from the bubble to the spot.
    const size = map.getSize();
    const pad = 4;
    const placed = [];
    // The zoom buttons, every HUD (the screen's too), the open overlay and a
    // club card: bubbles and names keep clear of them all.
    const box = map.getContainer().getBoundingClientRect();
    const scope = this.screen.element || this.root;
    (scope ? [...scope.querySelectorAll('.leaflet-control-zoom, .ap-hud, .mp-ov:not([hidden]), .cc-card')] : []).forEach((el) => {
      const r = el.getBoundingClientRect();
      if (r.width) placed.push({ x: r.left - box.left + r.width / 2, y: r.top - box.top + r.height / 2, w: r.width + 8, h: r.height + 8 });
    });
    const hit = (p) => placed.some((q) => Math.abs(p.x - q.x) < (p.w + q.w) / 2 && Math.abs(p.y - q.y) < (p.h + q.h) / 2);
    const inside = (p) => p.x - p.w / 2 >= pad && p.x + p.w / 2 <= size.x - pad && p.y - p.h / 2 >= pad && p.y + p.h / 2 <= size.y - pad;
    const ring = [[0, -1], [0, 1], [1, -1], [-1, -1], [1, 1], [-1, 1], [1, 0], [-1, 0]];
    const items = [...(this.labels || new Map()).values()].map((l) => {
      const el = l.mk.getElement() && l.mk.getElement().querySelector('.mp-label');
      const a = map.latLngToContainerPoint(l.anchor);
      return { l, a, w: (el ? el.offsetWidth : 90) + 8, h: (el ? el.offsetHeight : 22) + 6 };
    }).sort((p, q) => p.a.y - q.a.y || p.a.x - q.a.x);
    for (const p of items) {
      const cx = Math.min(Math.max(p.a.x, p.w / 2 + pad), size.x - p.w / 2 - pad);
      const cy = Math.min(Math.max(p.a.y, p.h / 2 + pad), size.y - p.h / 2 - pad);
      let best = null;
      for (let k = 1; k <= 12 && !best; k++) {
        for (const [dx, dy] of ring) {
          const c = { x: cx + dx * (p.w / 2 + 14) * k * 0.8, y: cy + dy * (p.h + 10) * k * 0.9, w: p.w, h: p.h };
          if (inside(c) && !hit(c)) { best = c; break; }
        }
      }
      best = best || { x: cx, y: cy, w: p.w, h: p.h };
      placed.push(best);
      p.x = best.x; p.y = best.y;
    }
    for (const p of items) {
      const at = map.containerPointToLatLng([p.x, p.y]);
      p.l.mk.setLatLng(at);
      p.l.line.setLatLngs([p.l.anchor, at]);
    }
    this._placeNames(placed, inside);
  }

  // Club names: from zoom 7 (or the picked conference), each on the first
  // free side of its dot, never over a bubble, the HUD or another name.
  _placeNames(placed, inside) {
    const map = this.map;
    const zoom = map.getZoom();
    const mine = (d) => this.club != null && d.clubId === this.club;
    const order = [...(this.dots || [])].sort((a, b) =>
      (mine(b) - mine(a)) || ((b.conf === this.sel) - (a.conf === this.sel)) || (b.apsl - a.apsl) || a.label.localeCompare(b.label));
    const nameEl = (d) => d.name.getElement() && d.name.getElement().querySelector('.mp-name');
    const hit = (p) => placed.some((q) => Math.abs(p.x - q.x) < (p.w + q.w) / 2 && Math.abs(p.y - q.y) < (p.h + q.h) / 2);
    for (const d of this.dots || []) {
      d.name.setOpacity(0);
      const el = nameEl(d);
      if (el) { el.classList.remove('shown'); el.classList.toggle('on', mine(d)); }
    }
    for (const d of order) {
      if (zoom < 7 && d.conf !== this.sel && !mine(d)) continue;
      const at = d.m.getLatLng();
      const c = map.latLngToContainerPoint(at);
      const el = d.name.getElement() && d.name.getElement().querySelector('.mp-name');
      // The rendered box, plus a 3px margin all round.
      const w = (el ? el.offsetWidth : d.label.length * 6) + 6, h = (el ? el.offsetHeight : 14) + 6;
      const gap = d.r + 3;
      // right, left, above, below the dot (the box's centre → the marker's
      // anchor is its left edge, vertically centred).
      for (const [bx, by] of [[c.x + gap + w / 2, c.y], [c.x - gap - w / 2, c.y], [c.x, c.y - gap - h / 2], [c.x, c.y + gap + h / 2]]) {
        const box = { x: bx, y: by, w, h };
        if (!inside(box) || hit(box)) continue;
        placed.push(box);
        d.name.setLatLng(map.containerPointToLatLng([bx - w / 2 + 2, by]));
        d.name.setOpacity(1);
        if (el) el.classList.add('shown');
        break;
      }
    }
  }

  // The picked conference's ground: its counties (fetched once per
  // conference), tinted, with only the OUTER border outlined — an edge two
  // of its counties share is inside; one drawn once is the border.  The HUD
  // chip gives population and Sunday drive times.
  async _showTerritory() {
    const L = window.L;
    if (!this.map || !this.terrLayer) return;
    this.terrLayer.clearLayers();
    const stats = this.screen.find('.mp-hud-stats');
    const conf = this.sel;
    if (!conf) { if (stats) stats.textContent = this._copy('map_pick'); return; }
    let t = this.terrCache.get(conf);
    if (!t) {
      try {
        const res = await this.screen.auth.fetch(`/api/pyramid/territory?conf=${conf}`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        t = await res.json();
        this.terrCache.set(conf, t);
      } catch (e) { console.warn('territory', e); return; }
    }
    if (this.sel !== conf || !this.map) return;
    L.geoJSON(t.geojson, { renderer: this.terrRenderer, interactive: false,
      style: { stroke: false, fillColor: '#facc15', fillOpacity: 0.13 } }).addTo(this.terrLayer);
    const seen = new Map();
    const k = (p) => `${p[0].toFixed(5)},${p[1].toFixed(5)}`;
    for (const f of t.geojson.features || []) {
      const g = f.geometry || {};
      const polys = g.type === 'MultiPolygon' ? g.coordinates : g.type === 'Polygon' ? [g.coordinates] : [];
      for (const poly of polys) for (const ring of poly)
        for (let i = 0; i + 1 < ring.length; i++) {
          const a = ring[i], b = ring[i + 1];
          const key = k(a) < k(b) ? `${k(a)}|${k(b)}` : `${k(b)}|${k(a)}`;
          const e = seen.get(key);
          if (e) e.n++; else seen.set(key, { n: 1, a, b });
        }
    }
    const edges = [...seen.values()].filter((e) => e.n === 1).map((e) => [[e.a[1], e.a[0]], [e.b[1], e.b[0]]]);
    L.polyline(edges, { renderer: this.terrRenderer, interactive: false, color: '#facc15', weight: 2, opacity: 0.95 }).addTo(this.terrLayer);
    // The main city (mig 860): its city-limits outline, and its collar
    // counties dashed.
    if (t.city) {
      const collar = new Set(t.city.collar_fips || []);
      const collarFeatures = (t.geojson.features || []).filter((f) => collar.has(f.properties.fips));
      if (collarFeatures.length)
        L.geoJSON({ type: 'FeatureCollection', features: collarFeatures }, { renderer: this.terrRenderer, interactive: false,
          style: { color: '#7dd3fc', weight: 1.5, dashArray: '5 5', fill: false, opacity: 0.8 } }).addTo(this.terrLayer);
      if (t.city.geometry)
        L.geoJSON(t.city.geometry, { renderer: this.terrRenderer, interactive: false,
          style: { color: '#22d3ee', weight: 2.5, fillColor: '#22d3ee', fillOpacity: 0.1 } }).addTo(this.terrLayer);
    }
    if (stats) {
      const esc = (x) => this._esc(x);
      const time = (m) => { const h = Math.floor(m / 60), r = Math.round(m % 60); return h ? `${h}h ${String(r).padStart(2, '0')}m` : `${r}m`; };
      const conference = this.columns.find((c) => c.conf.id === conf);
      let html = `<b>${esc(conference ? this.model.label(conference.conf) : '')}</b> · ${esc(this._copy('map_counties', { counties: t.counties }))}<br>`
        + esc(this._copy('map_pop', { pop: Number(t.population).toLocaleString() }));
      if (t.travel) {
        html += `<br>${esc(this._copy('map_far', { a: t.travel.from, b: t.travel.to, time: time(t.travel.max_minutes) }))}`
          + (t.travel.min_minutes != null ? `<br>${esc(this._copy('map_short', { a: t.travel.min_from, b: t.travel.min_to, time: time(t.travel.min_minutes) }))}` : '')
          + `<br>${esc(this._copy('map_avg', { time: time(t.travel.avg_minutes), pairs: t.travel.pairs }))}`
          + (t.travel.median_minutes != null ? `<br>${esc(this._copy('map_median', { time: time(t.travel.median_minutes) }))}` : '');
      } else html += `<br>${esc(this._copy('map_no_travel'))}`;
      if (t.city && t.city.rings) {
        const r = t.city.rings;
        const tip = [`${t.city.name}: ${r.city.join(', ')}`, `collar: ${r.collar.join(', ')}`, `further: ${r.further.join(', ')}`].join('\n');
        html += `<br><span title="${esc(tip)}" style="color:#67e8f9;">${esc(this._copy('map_rings', { city: t.city.name, city_n: r.city.length, collar_n: r.collar.length, far_n: r.further.length }))}</span>`;
      }
      stats.innerHTML = html;
      this._relayout();
    }
  }

  _fitAll() { if (this.all && this.all.length) this.map.fitBounds(this.all, { padding: [30, 30] }); else this.map.setView([39.5, -86], 5); }

  // Fly to a conference's clubs and draw its pyramid under the map.
  select(confId, fly = true, instant = false) {
    const col = this.columns.find((c) => c.conf.id === confId);
    if (!col) return;
    this.sel = confId;
    this.root.querySelectorAll('[data-conf-label]').forEach((el) => el.classList.toggle('on', Number(el.dataset.confLabel) === confId));
    const pts = this.model.columnTeams(col).map(({ team, division }) => this.model.teamPoint(team.id, division.id)).filter(Boolean).map((p) => [p.lat, p.lon]);
    if (pts.length && (fly || instant)) {
      // Frame the clubs in the part of the map the overlay leaves uncovered
      // (unless the overlay takes nearly the whole width — a phone).
      const w = this.map.getSize().x, ovW = Math.min(820, w - 24) + 24;
      const opts = w - ovW > 260
        ? { paddingTopLeft: [40, 70], paddingBottomRight: [ovW + 20, 60], maxZoom: 10 }
        : { padding: [40, 40], maxZoom: 10 };
      if (instant) this.map.fitBounds(pts, opts);
      else this.map.flyToBounds(pts, { ...opts, duration: 1.4 });
    }
    this._panel();
    this._relayout();
    this._showTerritory();
  }

  // The picked conference's pyramid, as an overlay on the map.
  _panel() {
    const ov = this.root.querySelector('.mp-ov');
    if (!ov) return;
    const col = this.sel && this.columns.find((c) => c.conf.id === this.sel);
    if (!col) { ov.hidden = true; return; }
    ov.querySelector('h3').textContent = col.conf.name;
    const body = ov.querySelector('.mp-ov-body');
    body.innerHTML = this.flow.chartHtml(this.model, [col.conf]);
    ov.hidden = false;
    this._fitOverlay();
    requestAnimationFrame(() => this.flow.drawArrows(body.querySelector('.fc-chart'), this.model, [col.conf], { outliers: false }));
  }

  // The overlay starts just under the screen's ☰ button (mig 1234).
  _fitOverlay() {
    const ov = this.root && this.root.querySelector('.mp-ov');
    const main = this.screen.element && this.screen.element.querySelector('.ap-menu-btn');
    if (!ov || !main) return;
    const top = main.getBoundingClientRect().bottom - this.root.querySelector('.mp-stage').getBoundingClientRect().top + 8;
    ov.style.top = `${Math.max(12, Math.round(top))}px`;
  }

  _close() {
    this.sel = null;
    this.root.querySelectorAll('[data-conf-label]').forEach((el) => el.classList.remove('on'));
    this._panel();
    this._relayout();
    this._showTerritory();
  }

  // Pick a club: its dots ring yellow, its names show, its card fills the
  // Club HUD.  fly: from the overlay's tables — bring its grounds into view.
  pickClub(clubId, fly = false) {
    if (!this.map || !clubId) return;
    this.club = clubId;
    const hud = this.screen.find('.hud-club');
    hud.classList.add('has-club');
    // The club card is a ☰ section now — open the menu on it.
    this.screen._menu(true);
    requestAnimationFrame(() => hud.scrollIntoView({ block: 'nearest' }));
    this.screen.clubCard.open(clubId, hud.querySelector('[data-cc-host]'), () => this._dropClub());
    this._styleDots();
    const pts = (this.dots || []).filter((d) => d.clubId === clubId).map((d) => d.at);
    if (fly && pts.length) {
      const w = this.map.getSize().x, ovW = this.sel ? Math.min(820, w - 24) + 24 : 0;
      const opts = w - ovW > 260 ? { paddingTopLeft: [420, 80], paddingBottomRight: [ovW + 40, 60], maxZoom: 11 } : { padding: [40, 40], maxZoom: 11 };
      this.map.flyToBounds(pts, { ...opts, duration: 1.0 });
    }
    this._relayout();
  }

  _dropClub() {
    this.club = null;
    const hud = this.screen.find('.hud-club');
    if (hud) hud.classList.remove('has-club');
    this._styleDots();
    this._relayout();
  }

  _styleDots() {
    for (const d of this.dots || []) {
      const on = this.club != null && d.clubId === this.club;
      d.m.setStyle(on
        ? { color: '#facc15', weight: 3, dashArray: null }
        : { color: d.approx ? '#64748b' : '#0b1220', weight: 1.5, dashArray: d.approx ? '3 3' : null });
      d.m.setRadius(on ? d.r + 2 : d.r);
      if (on) d.m.bringToFront();
    }
  }

  // The Club HUD: under the Conference HUD, down to the map key (or the
  // bottom when the key is collapsed out of the way).
  _fitClubHud() {
    return;   // the club card lives in the ☰ menu since 2026-11-11
    const hud = this.root && this.root.querySelector('.hud-club');
    const stage = this.root && this.root.querySelector('.mp-stage');
    if (!hud || !stage) return;
    const s = stage.getBoundingClientRect();
    const stats = this.root.querySelector('[data-hud="map-stats"]');
    const key = this.root.querySelector('[data-hud="map-key"]');
    // A panel switched off in ☰ (mig 1234) takes no room.
    const top = stats && stats.offsetWidth ? stats.getBoundingClientRect().bottom - s.top + 8 : 62;
    const bottom = key && key.offsetWidth ? s.bottom - key.getBoundingClientRect().top + 8 : 10;
    hud.style.top = `${Math.round(top)}px`;
    hud.style.maxHeight = `${Math.max(160, Math.round(s.height - top - bottom))}px`;
  }

  // The map underneath: this code's pyramid_map_layers row, else the default.
  _setLayer(code) {
    const layers = this.model.data.map_layers || [];
    const row = layers.find((l) => l.code === code) || layers.find((l) => l.is_default);
    if (!row) return;
    (this.tiles || []).forEach((t) => t.remove());
    const L = window.L;
    this.tiles = [L.tileLayer(row.tile_url, { maxZoom: row.max_zoom, attribution: this._esc(row.attribution) })];
    if (row.overlay_url) this.tiles.push(L.tileLayer(row.overlay_url, { maxZoom: row.max_zoom }));
    this.tiles.forEach((t) => t.addTo(this.map));
    this.root.querySelector('.mp-map').classList.toggle('mp-dark', row.darken);
    this.root.querySelectorAll('[data-mp="layer"]').forEach((b) => b.classList.toggle('on', b.dataset.code === row.code));
  }

  _bindHud(root) {
    const stage = root.querySelector('.mp-stage');
    // Layer pills sit in the ☰ dock (Map key); the overlay's slider / ✕ in root.
    [...root.querySelectorAll('[data-mp]'), ...this.screen.element.querySelectorAll('.ap-dock [data-mp]')].forEach((el) => {
      const a = el.dataset.mp;
      if (a === 'alpha') {
        el.addEventListener('input', () => {
          this.alpha = Number(el.value);
          root.querySelector('.mp-ov').style.opacity = this.alpha;
          try { localStorage.setItem('apsl-pyramid-map-ov', String(this.alpha)); } catch (_) { /* private mode */ }
        });
      } else if (a === 'layer') {
        el.addEventListener('click', () => {
          this._setLayer(el.dataset.code);
          try { localStorage.setItem('apsl-pyramid-map-layer', el.dataset.code); } catch (_) { /* private mode */ }
        });
      } else if (a === 'close') el.addEventListener('click', () => this._close());
    });
    // Keep Leaflet's own drag / wheel off the HUD and overlay.
    root.querySelectorAll('.ap-hud, .mp-ov').forEach((el) => { window.L.DomEvent.disableClickPropagation(el); window.L.DomEvent.disableScrollPropagation(el); });
    this._onKey = (e) => {
      if (e.key !== 'Escape' || document.fullscreenElement) return;
      if (this.club != null) this.screen.clubCard.close(); else if (this.sel) this._close();
    };
    this._onFull = () => setTimeout(() => { if (this.map) { this.map.invalidateSize(); this._relayout(); this._panel(); this._fitClubHud(); } }, 150);
    document.addEventListener('keydown', this._onKey);
    document.addEventListener('fullscreenchange', this._onFull);
  }

  // ── proposal layer (mig 1241) ────────────────────────────────────────
  async _showProposal(on) {
    const L = window.L;
    if (!this.map || !this.propLayer) return;
    this.propLayer.clearLayers();
    if (this.propLines) this.propLines.clearLayers();
    if (!on) { this.screen._renderMenu(); return; }
    if (!this.proposal) {
      try {
        const res = await this.screen.auth.fetch('/api/pyramid/proposal');
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        this.proposal = await res.json();
      } catch (e) { console.warn('proposal', e); return; }
    }
    if (!this.map || !(this.screen.feature && this.screen.feature('proposal', this.features()[0].def))) return;
    // On the map: the border lines and each proposed conference's name —
    // nothing else (the watch list and the numbers are in ☰).
    // The neutral zone (mig 1255): counties the two borders disagree on.
    const plan = this._plan();
    const neutral = { type: 'FeatureCollection', features: ((this.proposal.neutral || {}).features || []).filter((f) => (f.properties.plan || 'proposed') === plan) };
    if (neutral.features.length)
      L.geoJSON(neutral, { renderer: this.propRenderer, interactive: false,
        style: { stroke: false, fillColor: '#f8fafc', fillOpacity: 0.22 } }).addTo(this.propLayer);
    this._drawBorders();
    // A pill on every conference, live or proposed (mig 1270, owner: "pill on
    // each conf proposed or not proposed on map with distance from furthest
    // points and pop" / "dist and drive time"): name, people, the two county
    // centres furthest apart — straight km and the road drive.  A live
    // conference's pill hangs under its club bubble.
    for (const r of (this.proposal.regions || []).filter((x) => x.plan === plan)) {
      const live = !!r.conference_id;
      const tip = r.far_a ? this._copy('pill_far', { a: r.far_a, b: r.far_b }) : '';
      L.marker([r.lat, r.lon], { interactive: false, keyboard: false, icon: L.divIcon({ className: 'mp-pin',
        html: `<span class="mp-prop${live ? ' live' : ''}" style="--pc:${this._esc(r.color || '#94a3b8')}" title="${this._esc(tip)}">`
          + `<b>${this._esc(r.name.replace(/ Conference$/, ''))}</b><span>${this._esc(this._pillStats(r))}</span></span>`, iconSize: [0, 0] }) }).addTo(this.propLayer);
    }
    this.screen._renderMenu();
  }

  // Two-tone borders (mig 1249, owner: "color of one conference on dividing
  // line and other on the divide line so line is 2 tone"): each border is
  // two lines side by side, each pushed HALF px to its own region's side
  // (a_left says which side region a is on) in that region's colour.
  // Offsets are in screen pixels, so it redraws on every zoom.
  _drawBorders() {
    const L = window.L;
    if (!this.map || !this.propLines) return;
    this.propLines.clearLayers();
    const P = this.proposal;
    if (!P || !(this.screen.feature && this.screen.feature('proposal', this.features()[0].def))) return;
    const color = new Map((P.regions || []).map((r) => [r.key, r.color || '#94a3b8']));
    const HALF = 2, W = 4;
    const shift = (pts, d) => pts.map((p, i) => {
      const a = pts[Math.max(0, i - 1)], b = pts[Math.min(pts.length - 1, i + 1)];
      const dx = b.x - a.x, dy = b.y - a.y, len = Math.hypot(dx, dy) || 1;
      // screen y points down: (dy, -dx) is the left of travel as seen on the map
      return this.map.layerPointToLatLng(L.point(p.x + (dy / len) * d, p.y + (-dx / len) * d));
    });
    const pre = this._plan() === 'current' ? 'c' : 'p';   // a region key sorts before 'x', so b.a names the plan
    for (const b of (P.borders || []).filter((x) => x.a[0] === pre)) {
      // The straight-distance border (mig 1255) is drawn exactly like the
      // traffic one — two-tone in the same conferences' colours (owner: "i
      // need them same colors" / "same colors as each other"); the traffic
      // line is always the one nearer New York ("it will be obvious the one
      // closer is the traffic one").
      const dash = null;
      const pts = b.line.map((ll) => this.map.latLngToLayerPoint(L.latLng(ll[0], ll[1])));
      if (pts.length < 2) continue;
      const aSide = b.a_left ? HALF : -HALF;
      L.polyline(shift(pts, aSide), { renderer: this.propRenderer, interactive: false, color: color.get(b.a), weight: W, opacity: 0.95, lineCap: 'butt', dashArray: dash }).addTo(this.propLines);
      L.polyline(shift(pts, -aSide), { renderer: this.propRenderer, interactive: false, color: color.get(b.b), weight: W, opacity: 0.95, lineCap: 'butt', dashArray: dash }).addTo(this.propLines);
    }
  }

  onResize() {
    if (this.map) { this.map.invalidateSize(); this._relayout(); }
    this._fitOverlay();
    this._fitClubHud();
    const col = this.sel && this.columns && this.columns.find((c) => c.conf.id === this.sel);
    const chart = this.root && this.root.querySelector('.mp-ov .fc-chart');
    if (col && chart) this.flow.drawArrows(chart, this.model, [col.conf], { outliers: false });
  }

  unmount() {
    if (this._onKey) document.removeEventListener('keydown', this._onKey);
    if (this._onFull) document.removeEventListener('fullscreenchange', this._onFull);
    if (this.club != null) this.screen.clubCard.close();
    if (this.map) { this.map.remove(); this.map = null; }
  }
}
window.PyramidMapView = PyramidMapView;
