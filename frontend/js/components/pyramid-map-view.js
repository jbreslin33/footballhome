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
//
// Nothing hides anything (owner 2026-10-29: "use arrows to bubble as its
// covering each other up. so it needs to auto adjust so its all visible"):
// after every zoom / pan, _relayout() works in screen pixels — conference
// bubbles are pushed apart until none overlap and point back to their spot
// with a leader line ending in a ring; dots sharing one point (a shared
// ground, or a league's point) fan out in a small ring around it.
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
    this.dots = [];
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
        this.dots.push({ m, at: L.latLng(p.lat, p.lon), key: `${p.lat.toFixed(4)},${p.lon.toFixed(4)}` });
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
      const anchor = L.latLng(at[0], at[1]);
      const line = L.polyline([anchor, anchor], { color: '#93c5fd', weight: 1.5, opacity: 0.85, interactive: false }).addTo(this.map);
      const ring = L.circleMarker(anchor, { radius: 5, color: '#93c5fd', weight: 2, fill: false, interactive: false }).addTo(this.map);
      const mk = L.marker(anchor, { icon, zIndexOffset: 1000 }).addTo(this.map);
      mk.on('click', () => this.select(col.conf.id, true));
      this.labels.set(col.conf.id, { mk, anchor, line, ring });
    }
    this.map.on('zoomend moveend', () => this._relayout());
    const count = root.querySelector('.mp-count');
    if (count) count.textContent = this._copy('map_located', { located, clubs: seen.size });
    this.all = all;
    if (this.sel && this.columns.some((c) => c.conf.id === this.sel)) this.select(this.sel, false, true);
    else { this.sel = null; this._fitAll(); this._panel(); }
    requestAnimationFrame(() => this._relayout());
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
    const placed = [{ x: 30, y: 50, w: 60, h: 100 }];   // the zoom buttons
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
    if (this.map) { this.map.invalidateSize(); this._relayout(); }
    const col = this.sel && this.columns && this.columns.find((c) => c.conf.id === this.sel);
    const chart = this.root && this.root.querySelector('.mp-panel .fc-chart');
    if (col && chart) this.flow.drawArrows(chart, this.model, [col.conf]);
  }

  unmount() { if (this.map) { this.map.remove(); this.map = null; } }
}
window.PyramidMapView = PyramidMapView;
