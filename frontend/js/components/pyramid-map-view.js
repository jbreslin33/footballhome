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
//              two furthest clubs, and the average if all play all.  The
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
      .mp-stage { position:relative; height:calc(100vh - 210px); min-height:480px; border-radius:12px; overflow:hidden; border:1px solid var(--border-color, #374151); }
      .mp-stage:fullscreen { height:100vh; border-radius:0; border:0; }
      .mp-map { position:absolute; inset:0; background:#0b1220; }
      .mp-hud { position:absolute; z-index:1100; background:rgba(11,18,32,0.78); backdrop-filter:blur(6px); border:1px solid rgba(148,163,184,0.25);
                border-radius:10px; padding:6px 10px; font-size:0.8rem; color:#e5e7eb; }
      .mp-hud-top { top:10px; left:50%; transform:translateX(-50%); display:flex; gap:12px; align-items:center; white-space:nowrap; max-width:calc(100% - 140px); }
      .mp-hud-top .tot { font-weight:800; font-size:0.95rem; overflow:hidden; text-overflow:ellipsis; }
      .mp-hud-top button { min-height:0; padding:3px 10px; font-size:0.78rem; }
      .mp-hud-legend { left:10px; bottom:30px; display:flex; flex-direction:column; gap:3px; }
      .mp-hud-legend i { display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:6px; vertical-align:-1px; }
      .mp-hud-count { right:10px; bottom:30px; opacity:0.9; }
      .mp-hud-stats { left:56px; top:10px; max-width:360px; line-height:1.45; }
      .mp-hud-stats[hidden] { display:none; }
      .mp-hud-stats b { font-size:0.9rem; }
      .mp-hud-hint { left:50%; bottom:30px; transform:translateX(-50%); opacity:0.75; font-size:0.74rem; }
      .mp-ov { position:absolute; z-index:1200; top:56px; right:12px; bottom:12px; width:min(820px, calc(100% - 24px)); display:flex; flex-direction:column;
               background:rgba(11,18,32,0.92); border:1px solid rgba(148,163,184,0.35); border-radius:12px; box-shadow:0 8px 30px rgba(0,0,0,0.5); }
      .mp-ov[hidden] { display:none; }
      .mp-name { color:#f8fafc; font-size:11px; font-weight:600; white-space:nowrap; text-shadow:0 0 3px #0b1220, 0 0 3px #0b1220, 0 0 2px #0b1220;
                 transform:translate(0, -50%); display:inline-block; pointer-events:none; }
      .mp-ov-head { display:flex; align-items:center; gap:10px; padding:8px 12px; border-bottom:1px solid rgba(148,163,184,0.2); }
      .mp-ov-head h3 { margin:0; flex:1; font-size:1rem; }
      .mp-ov-head label { font-size:0.75rem; opacity:0.85; display:flex; align-items:center; gap:6px; }
      .mp-ov-head input[type=range] { width:120px; }
      .mp-ov-head button { min-height:0; min-width:0; padding:2px 10px; }
      .mp-ov-body { overflow:auto; padding:10px; flex:1; }
      .mp-label { background:#1d4ed8; color:#fff; font-weight:800; font-size:12px; padding:3px 9px; border-radius:999px;
                  border:2px solid #93c5fd; white-space:nowrap; box-shadow:0 2px 8px rgba(0,0,0,0.5); cursor:pointer; transform:translate(-50%, -50%); display:inline-block; }
      .mp-label.on { background:#facc15; color:#111827; border-color:#fff; }
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
    let alpha = 0.92;
    try { alpha = Number(localStorage.getItem('apsl-pyramid-map-ov')) || 0.92; } catch (_) { /* private mode */ }
    this.alpha = alpha;
    return `
      <div class="mp-stage">
        <div class="mp-map"></div>
        <div class="mp-hud mp-hud-top">
          <span class="tot">${esc(this._copy('totals', model.totals))}</span>
          <button class="btn btn-secondary" data-mp="full">${esc(this._copy('map_full'))}</button>
        </div>
        <div class="mp-hud mp-hud-legend">
          <span><i style="background:#3b82f6"></i>${esc(this._copy('map_dot_apsl'))}</span>
          <span><i style="background:#14b8a6"></i>${esc(this._copy('map_dot_feeder'))}</span>
          <span><i style="background:rgba(20,184,166,0.35); outline:1px dashed #64748b"></i>${esc(this._copy('map_dot_approx'))}</span>
        </div>
        <div class="mp-hud mp-hud-hint">${esc(this._copy('map_hint'))}</div>
        <div class="mp-hud mp-hud-count"></div>
        <div class="mp-hud mp-hud-stats" hidden></div>
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
        const name = L.marker([p.lat, p.lon], {
          icon: L.divIcon({ className: '', html: `<span class="mp-name">${this._esc(club.name)}</span>`, iconSize: null }),
          interactive: false, keyboard: false, opacity: 0,
        }).addTo(this.map);
        this.dots.push({ m, name, club, conf: col.conf.id, apsl, approx: p.approx, r: apsl ? 7 : 5,
                         at: L.latLng(p.lat, p.lon), key: `${p.lat.toFixed(4)},${p.lon.toFixed(4)}` });
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
    // The territory layer: its own pane, under the dots and bubbles.
    const pane = this.map.createPane('mp-territory');
    pane.style.zIndex = 350;
    pane.style.pointerEvents = 'none';
    this.terrRenderer = L.svg({ pane: 'mp-territory' });
    this.terrLayer = L.layerGroup().addTo(this.map);
    this.terrCache = this.terrCache || new Map();
    this.map.on('zoomend moveend', () => this._relayout());
    this._bindHud(root);
    const count = root.querySelector('.mp-hud-count');
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
    // …and the HUD pieces / open overlay floating on the map.
    const box = map.getContainer().getBoundingClientRect();
    (this.root ? [...this.root.querySelectorAll('.mp-hud, .mp-ov:not([hidden])')] : []).forEach((el) => {
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
    const order = [...(this.dots || [])].sort((a, b) =>
      ((b.conf === this.sel) - (a.conf === this.sel)) || (b.apsl - a.apsl) || a.club.name.localeCompare(b.club.name));
    const hit = (p) => placed.some((q) => Math.abs(p.x - q.x) < (p.w + q.w) / 2 && Math.abs(p.y - q.y) < (p.h + q.h) / 2);
    for (const d of this.dots || []) d.name.setOpacity(0);
    for (const d of order) {
      if (zoom < 7 && d.conf !== this.sel) continue;
      const at = d.m.getLatLng();
      const c = map.latLngToContainerPoint(at);
      const el = d.name.getElement() && d.name.getElement().querySelector('.mp-name');
      // The rendered box, plus a 3px margin all round.
      const w = (el ? el.offsetWidth : d.club.name.length * 6) + 6, h = (el ? el.offsetHeight : 14) + 6;
      const gap = d.r + 3;
      // right, left, above, below the dot (the box's centre → the marker's
      // anchor is its left edge, vertically centred).
      for (const [bx, by] of [[c.x + gap + w / 2, c.y], [c.x - gap - w / 2, c.y], [c.x, c.y - gap - h / 2], [c.x, c.y + gap + h / 2]]) {
        const box = { x: bx, y: by, w, h };
        if (!inside(box) || hit(box)) continue;
        placed.push(box);
        d.name.setLatLng(map.containerPointToLatLng([bx - w / 2 + 2, by]));
        d.name.setOpacity(1);
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
    const stats = this.root.querySelector('.mp-hud-stats');
    const conf = this.sel;
    if (!conf) { if (stats) stats.hidden = true; return; }
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
    if (stats) {
      const esc = (x) => this._esc(x);
      const time = (m) => { const h = Math.floor(m / 60), r = Math.round(m % 60); return h ? `${h}h ${String(r).padStart(2, '0')}m` : `${r}m`; };
      const conference = this.columns.find((c) => c.conf.id === conf);
      let html = `<b>${esc(conference ? this.model.label(conference.conf) : '')}</b> · ${esc(this._copy('map_counties', { counties: t.counties }))}<br>`
        + esc(this._copy('map_pop', { pop: Number(t.population).toLocaleString() }));
      if (t.travel) {
        html += `<br>${esc(this._copy('map_far', { a: t.travel.from, b: t.travel.to, time: time(t.travel.max_minutes) }))}`
          + `<br>${esc(this._copy('map_avg', { time: time(t.travel.avg_minutes), pairs: t.travel.pairs }))}`;
      } else html += `<br>${esc(this._copy('map_no_travel'))}`;
      stats.innerHTML = html;
      stats.hidden = false;
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
    const pts = this.model.columnClubs(col).map((c) => this.model.clubPoint(c)).filter(Boolean).map((p) => [p.lat, p.lon]);
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
    requestAnimationFrame(() => this.flow.drawArrows(body.querySelector('.fc-chart'), this.model, [col.conf]));
  }

  _close() {
    this.sel = null;
    this.root.querySelectorAll('[data-conf-label]').forEach((el) => el.classList.remove('on'));
    this._panel();
    this._relayout();
    this._showTerritory();
  }

  _bindHud(root) {
    const stage = root.querySelector('.mp-stage');
    root.querySelectorAll('[data-mp]').forEach((el) => {
      const a = el.dataset.mp;
      if (a === 'alpha') {
        el.addEventListener('input', () => {
          this.alpha = Number(el.value);
          root.querySelector('.mp-ov').style.opacity = this.alpha;
          try { localStorage.setItem('apsl-pyramid-map-ov', String(this.alpha)); } catch (_) { /* private mode */ }
        });
      } else if (a === 'close') el.addEventListener('click', () => this._close());
      else if (a === 'full') el.addEventListener('click', () => {
        if (document.fullscreenElement) document.exitFullscreen(); else if (stage.requestFullscreen) stage.requestFullscreen();
      });
    });
    // Keep Leaflet's own drag / wheel off the HUD and overlay.
    root.querySelectorAll('.mp-hud, .mp-ov').forEach((el) => { window.L.DomEvent.disableClickPropagation(el); window.L.DomEvent.disableScrollPropagation(el); });
    this._onKey = (e) => { if (e.key === 'Escape' && this.sel && !document.fullscreenElement) this._close(); };
    this._onFull = () => {
      const b = root.querySelector('[data-mp="full"]');
      if (b) b.textContent = this._copy(document.fullscreenElement ? 'map_exit_full' : 'map_full');
      setTimeout(() => { if (this.map) { this.map.invalidateSize(); this._relayout(); this._panel(); } }, 150);
    };
    document.addEventListener('keydown', this._onKey);
    document.addEventListener('fullscreenchange', this._onFull);
  }

  onResize() {
    if (this.map) { this.map.invalidateSize(); this._relayout(); }
    const col = this.sel && this.columns && this.columns.find((c) => c.conf.id === this.sel);
    const chart = this.root && this.root.querySelector('.mp-ov .fc-chart');
    if (col && chart) this.flow.drawArrows(chart, this.model, [col.conf]);
  }

  unmount() {
    if (this._onKey) document.removeEventListener('keydown', this._onKey);
    if (this._onFull) document.removeEventListener('fullscreenchange', this._onFull);
    if (this.map) { this.map.remove(); this.map = null; }
  }
}
window.PyramidMapView = PyramidMapView;
