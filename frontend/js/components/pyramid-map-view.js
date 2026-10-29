// pyramid-map-view.js — #apsl-pyramid "USA map" (mig 844), a view over
// PyramidModel.  Owner 2026-10-29: "ok next view usa map"; first ask: "map
// form — you jump round the usa and it shows you the pyramid."
//
// A dark US map (Leaflet, vendored in frontend/vendor/leaflet, loaded only
// when this view opens; OpenStreetMap tiles, darkened in CSS — CARTO's dark
// tiles now want an API key) with a dot per club at its home
// ground — blue for a club with an APSL team, teal for a feeder-only club;
// a club whose league publishes no address sits at its league's point,
// dimmed and dashed.  Each conference has a label at its clubs' middle; tap
// it (or a dot) and the camera flies there and THAT conference's pyramid —
// the same chart PyramidFlowView draws — appears under the map.  The
// conference pills choose which conferences' clubs are on the map.
class PyramidMapView {
  constructor(screen, flow) {
    this.screen = screen; this.flow = flow;
    this.map = null; this.sel = null;
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .mp-map .leaflet-tile-pane { filter:invert(1) hue-rotate(180deg) brightness(0.9) contrast(0.9) saturate(0.6); }
      .mp-map { height:58vh; min-height:380px; border-radius:12px; border:1px solid var(--border-color, #374151); background:#0b1220; }
      .mp-sub { text-align:center; font-size:0.78rem; opacity:0.7; margin:6px 0; }
      .mp-label { background:#1d4ed8; color:#fff; font-weight:800; font-size:12px; padding:3px 9px; border-radius:999px;
                  border:2px solid #93c5fd; white-space:nowrap; box-shadow:0 2px 8px rgba(0,0,0,0.5); cursor:pointer; transform:translate(-50%, -50%); display:inline-block; }
      .mp-label.on { background:#facc15; color:#111827; border-color:#fff; }
      .mp-panel { margin-top:14px; }
      .mp-panel h3 { text-align:center; margin:0 0 8px; }
      .leaflet-popup-content { font-size:0.82rem; line-height:1.35; }
      .leaflet-popup-content b { font-size:0.9rem; }`;
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
    return `
      <div class="mp-sub">${esc(this._copy('map_hint'))}</div>
      <div class="mp-map"></div>
      <div class="mp-sub mp-count"></div>
      <div class="mp-panel"></div>`;
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
    this.map = L.map(root.querySelector('.mp-map'), { zoomSnap: 0.25, attributionControl: true });
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 18, attribution: this._esc(this._copy('map_attribution')),
    }).addTo(this.map);

    const L2 = model.layout(confs);
    this.columns = L2.columns;
    const seen = new Set();
    const all = [];
    let located = 0;
    for (const col of this.columns) {
      for (const club of model.columnClubs(col)) {
        if (seen.has(club.id)) continue;
        seen.add(club.id);
        const p = model.clubPoint(club);
        if (!p) continue;
        if (!p.approx) located++;
        all.push([p.lat, p.lon]);
        const apsl = model.clubTier(club) === 'apsl';
        const color = apsl ? '#3b82f6' : '#14b8a6';
        const m = L.circleMarker([p.lat, p.lon], {
          radius: apsl ? 7 : 5, color: p.approx ? '#64748b' : '#0b1220', weight: 1.5, dashArray: p.approx ? '3 3' : null,
          fillColor: color, fillOpacity: p.approx ? 0.35 : 0.9,
        }).addTo(this.map);
        const where = p.approx ? `<i>${this._esc(this._copy('map_at_league'))}</i>` : this._esc([club.venue_name, club.venue].filter(Boolean).join(' · '));
        m.bindTooltip(this._esc(club.name));
        m.bindPopup(`<b>${this._esc(this._copy('map_club', { club: club.name }))}</b><br>${where}<br>${model.clubTables(club).map((t) => this._esc(t)).join('<br>')}`);
        m.on('click', () => { const col = this.columns.find((c) => model.columnClubs(c).some((x) => x.id === club.id)); if (col) this.select(col.conf.id, false); });
      }
    }
    // A label per conference at its clubs' middle (else its own point).
    this.labels = new Map();
    for (const col of this.columns) {
      const pts = model.columnClubs(col).map((c) => model.clubPoint(c)).filter((p) => p && !p.approx);
      const at = pts.length ? [pts.reduce((a, p) => a + p.lat, 0) / pts.length, pts.reduce((a, p) => a + p.lon, 0) / pts.length]
        : (col.conf.lat != null ? [col.conf.lat, col.conf.lon] : null);
      if (!at) continue;
      const icon = L.divIcon({ className: '', html: `<span class="mp-label" data-conf-label="${col.conf.id}">${this._esc(model.label(col.conf))}</span>`, iconSize: null });
      const mk = L.marker(at, { icon, zIndexOffset: 1000 }).addTo(this.map);
      mk.on('click', () => this.select(col.conf.id, true));
      this.labels.set(col.conf.id, mk);
    }
    const count = root.querySelector('.mp-count');
    if (count) count.textContent = this._copy('map_located', { located, clubs: seen.size });
    this.all = all;
    if (this.sel && this.columns.some((c) => c.conf.id === this.sel)) this.select(this.sel, false, true);
    else { this.sel = null; this._fitAll(); this._panel(); }
  }

  _fitAll() { if (this.all && this.all.length) this.map.fitBounds(this.all, { padding: [30, 30] }); else this.map.setView([39.5, -86], 5); }

  // Fly to a conference's clubs and draw its pyramid under the map.
  select(confId, fly = true, instant = false) {
    const col = this.columns.find((c) => c.conf.id === confId);
    if (!col) return;
    this.sel = confId;
    this.root.querySelectorAll('[data-conf-label]').forEach((el) => el.classList.toggle('on', Number(el.dataset.confLabel) === confId));
    const pts = this.model.columnClubs(col).map((c) => this.model.clubPoint(c)).filter(Boolean).map((p) => [p.lat, p.lon]);
    if (pts.length && (fly || instant)) {
      if (instant) this.map.fitBounds(pts, { padding: [40, 40], maxZoom: 10 });
      else this.map.flyToBounds(pts, { padding: [40, 40], maxZoom: 10, duration: 1.4 });
    }
    this._panel();
  }

  _panel() {
    const el = this.root.querySelector('.mp-panel');
    if (!el) return;
    const col = this.sel && this.columns.find((c) => c.conf.id === this.sel);
    if (!col) { el.innerHTML = `<div class="fc-none">${this._esc(this._copy('map_pick'))}</div>`; return; }
    el.innerHTML = `<h3>${this._esc(col.conf.name)}</h3><div class="fc-scroll">${this.flow.chartHtml(this.model, [col.conf])}</div>`;
    requestAnimationFrame(() => this.flow.drawArrows(el.querySelector('.fc-chart'), this.model, [col.conf]));
  }

  onResize() {
    if (this.map) this.map.invalidateSize();
    const col = this.sel && this.columns && this.columns.find((c) => c.conf.id === this.sel);
    const chart = this.root && this.root.querySelector('.mp-panel .fc-chart');
    if (col && chart) this.flow.drawArrows(chart, this.model, [col.conf]);
  }

  unmount() { if (this.map) { this.map.remove(); this.map = null; } }
}
window.PyramidMapView = PyramidMapView;
