// pyramid-present-view.js — #apsl-pyramid "Presentation": the pyramid as a
// zoomable canvas you fly around, Prezi-style (owner 2026-10-29: "next view
// is like a prezi type view … make sure they all draw from same source these
// are just views").
//
// The stage holds the SAME chart PyramidFlowView draws from PyramidModel —
// nothing here re-derives the pyramid.  On top of it:
//   click a box        → the camera flies to it; empty space → whole pyramid
//   click a zone row   → follows the model's links to where those teams go
//                        (up to the conference / table above, down to every
//                        feeder) and lights them up
//   wheel / pinch      → zoom about the pointer; drag → pan
//   ◀ ▶ / Play / keys  → tour: overview, then each conference and its
//                        feeder levels, in the model's tree order
//   far out            → text fades, the zone bands stay (the map look)
class PyramidPresentView {
  constructor(screen, flow) {
    this.screen = screen; this.flow = flow;
    this.cam = { x: 0, y: 0, s: 1 };
    this.steps = []; this.step = 0; this.timer = null;
    this.free = false;   // true once the viewer clicks / drags / zooms off the tour
    this._onKey = (e) => this._key(e);
    this._onFull = () => setTimeout(() => { if (this.free) this.fit(false); else this.go(this.step, false); }, 120);
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .pz-bar { display:flex; gap:6px; align-items:center; justify-content:center; flex-wrap:wrap; margin-bottom:8px; }
      .pz-bar button { min-height:0; padding:5px 12px; font-size:0.85rem; }
      .pz-cap { flex-basis:100%; text-align:center; font-weight:800; font-size:1rem; min-height:1.3em; }
      .pz-vp { position:relative; height:calc(100vh - 290px); min-height:420px; overflow:hidden; border:1px solid var(--border-color, #374151);
               border-radius:12px; background:radial-gradient(circle at 50% 30%, #172554 0%, #0b1220 70%); touch-action:none; cursor:grab; user-select:none; }
      .pz-vp:fullscreen { height:100vh; border-radius:0; }
      .pz-vp.dragging { cursor:grabbing; }
      .pz-stage { position:absolute; left:0; top:0; transform-origin:0 0; will-change:transform; }
      .pz-stage .fc-chart { margin:0; padding:24px; }
      .pz-vp .fc-edit { display:none; }
      .pz-vp .fc-tbl, .pz-vp .fc-conf { cursor:zoom-in; }
      .pz-vp tr.z { cursor:pointer; }
      .pz-vp.pz-far .fc-tbl td, .pz-vp.pz-far .fc-tbl th, .pz-vp.pz-far .fc-meta, .pz-vp.pz-far .fc-tbl .note { color:transparent; }
      .pz-vp.pz-far .fc-tbl td:first-child { box-shadow:none; }
      .pz-hl { outline:4px solid #facc15; outline-offset:3px; transition:outline-color 0.4s; }
      .pz-hint { text-align:center; font-size:0.75rem; opacity:0.6; margin-top:6px; }`;
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    const legend = this.flow.legendHtml(model);
    return `
      <div class="pz-bar">
        <button class="btn btn-secondary" data-pz="prev">◀</button>
        <button class="btn btn-primary" data-pz="play">${esc(this._copy('present_play'))}</button>
        <button class="btn btn-secondary" data-pz="next">▶</button>
        <button class="btn btn-secondary" data-pz="fit">${esc(this._copy('present_fit'))}</button>
        <button class="btn btn-secondary" data-pz="full">${esc(this._copy('present_full'))}</button>
        <div class="pz-cap"></div>
      </div>
      ${legend ? `<div class="fc-legend">${legend}</div>` : ''}
      <div class="pz-vp"><div class="pz-stage">${this.flow.chartHtml(model, confs)}</div></div>
      <div class="pz-hint">${esc(this._copy('present_hint'))}</div>`;
  }

  mount(root, model, confs) {
    this.root = root; this.model = model; this.confs = confs;
    this.vp = root.querySelector('.pz-vp');
    this.stage = root.querySelector('.pz-stage');
    this.chart = root.querySelector('.fc-chart');
    if (!this.vp || !this.chart) return;
    this.stage.style.transform = 'none';
    this.flow.drawArrows(this.chart, model, confs);
    this._buildSteps();
    this.step = Math.min(this.step, this.steps.length - 1);
    this.go(this.step, false);
    this._bind();
    document.addEventListener('keydown', this._onKey);
    document.addEventListener('fullscreenchange', this._onFull);
  }

  unmount() {
    this._stop();
    document.removeEventListener('keydown', this._onKey);
    document.removeEventListener('fullscreenchange', this._onFull);
  }

  // A resize re-frames the tour step being shown; a camera the viewer moved
  // stays where they put it.
  onResize() { if (this.vp && !this.free) this.go(this.step, false); }

  // ── the tour: overview, then per conference its box and feeder levels ─
  _buildSteps() {
    const L = this.model.layout(this.confs);
    this.steps = [{ el: this.chart, cap: this._copy('totals', this.model.totals) }];
    L.columns.forEach((col, ci) => {
      const conf = this.chart.querySelector(`[data-node="c${col.conf.id}"]`);
      if (conf) this.steps.push({ el: conf, cap: col.conf.name });
      this.chart.querySelectorAll(`.fc-cell.lv[data-col="${ci}"]`).forEach((cell) => {
        this.steps.push({ el: cell, cap: this._copy('present_level', { conference: this.model.label(col.conf), level: cell.dataset.level }) });
      });
    });
  }

  go(i, animate = true) {
    if (!this.steps.length) return;
    this.free = false;
    this.step = Math.max(0, Math.min(i, this.steps.length - 1));
    const st = this.steps[this.step];
    const cap = this.root.querySelector('.pz-cap');
    if (cap) cap.textContent = `${this.step + 1} / ${this.steps.length} · ${st.cap || ''}`;
    if (st.el === this.chart) this.fit(animate); else this.flyTo([st.el], animate);
  }

  _stop() { if (this.timer) { clearInterval(this.timer); this.timer = null; } this._playLabel(); }
  _playLabel() {
    const b = this.root && this.root.querySelector('[data-pz="play"]');
    if (b) b.textContent = this._copy(this.timer ? 'present_pause' : 'present_play');
  }
  _toggle() {
    if (this.timer) { this._stop(); return; }
    if (this.step >= this.steps.length - 1) this.go(0);
    this.timer = setInterval(() => {
      if (this.step >= this.steps.length - 1) { this._stop(); return; }
      this.go(this.step + 1);
    }, 4500);
    this._playLabel();
  }

  // ── camera ───────────────────────────────────────────────────────────
  _apply(animate) {
    this.stage.style.transition = animate ? 'transform 0.9s cubic-bezier(0.4, 0, 0.2, 1)' : 'none';
    this.stage.style.transform = `translate(${this.cam.x}px, ${this.cam.y}px) scale(${this.cam.s})`;
    this.vp.classList.toggle('pz-far', this.cam.s < 0.5);
  }

  _fitScale() {
    const w = this.chart.offsetWidth, h = this.chart.offsetHeight;
    return Math.min(this.vp.clientWidth / w, this.vp.clientHeight / h) * 0.96;
  }

  fit(animate = true) {
    const s = this._fitScale();
    this.cam = { s, x: (this.vp.clientWidth - this.chart.offsetWidth * s) / 2, y: (this.vp.clientHeight - this.chart.offsetHeight * s) / 2 };
    this._apply(animate);
  }

  // Fly so the elements' joint box fills the viewport.
  flyTo(els, animate = true) {
    const st = this.stage.getBoundingClientRect();
    let l = Infinity, t = Infinity, r = -Infinity, b = -Infinity;
    for (const el of els) {
      const q = el.getBoundingClientRect();
      l = Math.min(l, q.left); t = Math.min(t, q.top); r = Math.max(r, q.right); b = Math.max(b, q.bottom);
    }
    if (!isFinite(l)) return;
    const k = this.cam.s;
    const lx = (l - st.left) / k, ly = (t - st.top) / k, w = (r - l) / k, h = (b - t) / k;
    const vw = this.vp.clientWidth, vh = this.vp.clientHeight;
    const s = Math.max(this._fitScale(), Math.min(Math.min(vw / w, vh / h) * 0.88, 2.6));
    this.cam = { s, x: vw / 2 - (lx + w / 2) * s, y: vh / 2 - (ly + h / 2) * s };
    this._apply(animate);
  }

  _zoomAt(px, py, factor) {
    this.free = true;
    const s = Math.max(this._fitScale() * 0.6, Math.min(this.cam.s * factor, 4));
    const f = s / this.cam.s;
    this.cam = { s, x: px - (px - this.cam.x) * f, y: py - (py - this.cam.y) * f };
    this._apply(false);
  }

  // ── input ────────────────────────────────────────────────────────────
  _bind() {
    const vp = this.vp;
    this.root.querySelectorAll('[data-pz]').forEach((b) => b.addEventListener('click', () => {
      const a = b.dataset.pz;
      if (a === 'prev') { this._stop(); this.go(this.step - 1); }
      else if (a === 'next') { this._stop(); this.go(this.step + 1); }
      else if (a === 'play') this._toggle();
      else if (a === 'fit') { this._stop(); this.go(0); }
      else if (a === 'full') { if (document.fullscreenElement) document.exitFullscreen(); else if (vp.requestFullscreen) vp.requestFullscreen(); }
    }));
    vp.addEventListener('wheel', (e) => {
      e.preventDefault();
      const r = vp.getBoundingClientRect();
      this._zoomAt(e.clientX - r.left, e.clientY - r.top, Math.exp(-e.deltaY * 0.0015));
    }, { passive: false });

    const pts = new Map();
    let start = null, pinch = null;
    vp.addEventListener('pointerdown', (e) => {
      if (e.target.closest('a')) return;
      vp.setPointerCapture(e.pointerId);
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (pts.size === 1) start = { x: e.clientX, y: e.clientY, cx: this.cam.x, cy: this.cam.y, target: e.target, moved: false };
      if (pts.size === 2) {
        const [a, b] = [...pts.values()];
        pinch = { d: Math.hypot(a.x - b.x, a.y - b.y), s: this.cam.s };
        start = null;
      }
      this._stop();
    });
    vp.addEventListener('pointermove', (e) => {
      if (!pts.has(e.pointerId)) return;
      pts.set(e.pointerId, { x: e.clientX, y: e.clientY });
      if (pinch && pts.size === 2) {
        const [a, b] = [...pts.values()];
        const r = vp.getBoundingClientRect();
        this._zoomAt((a.x + b.x) / 2 - r.left, (a.y + b.y) / 2 - r.top, (pinch.s * Math.hypot(a.x - b.x, a.y - b.y) / pinch.d) / this.cam.s);
        return;
      }
      if (!start) return;
      const dx = e.clientX - start.x, dy = e.clientY - start.y;
      if (!start.moved && Math.hypot(dx, dy) < 5) return;
      start.moved = true;
      this.free = true;
      vp.classList.add('dragging');
      this.cam.x = start.cx + dx; this.cam.y = start.cy + dy;
      this._apply(false);
    });
    const end = (e) => {
      pts.delete(e.pointerId);
      if (pts.size < 2) pinch = null;
      vp.classList.remove('dragging');
      if (start && !start.moved && e.type === 'pointerup') this._click(start.target);
      if (!pts.size) start = null;
    };
    vp.addEventListener('pointerup', end);
    vp.addEventListener('pointercancel', end);
  }

  _click(target) {
    this.free = true;
    const row = target.closest('tr.z');
    const tbl = target.closest('[data-div]');
    if (row && tbl) {
      // Follow the zone: where this place's teams go, from the model.
      const d = this.model.division(Number(tbl.dataset.div));
      const z = d && this.model.zoneOf(d, Number(row.dataset.pos));
      const els = this.model.moveTargets(d, z).map((n) => this.chart.querySelector(`[data-node="${n}"]`)).filter(Boolean);
      if (els.length) {
        this.flyTo([tbl, ...els]);
        els.forEach((el) => el.classList.add('pz-hl'));
        setTimeout(() => els.forEach((el) => el.classList.remove('pz-hl')), 2600);
        return;
      }
    }
    const node = target.closest('[data-node]');
    if (node) { this.flyTo([node]); return; }
    this.fit();
  }

  _key(e) {
    if (!this.vp || !this.vp.isConnected || e.target.closest('input, select, textarea')) return;
    if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') { e.preventDefault(); this._stop(); this.go(this.step + 1); }
    else if (e.key === 'ArrowLeft' || e.key === 'PageUp') { e.preventDefault(); this._stop(); this.go(this.step - 1); }
    else if (e.key === 'Escape' && !document.fullscreenElement) { this._stop(); this.go(0); }
  }
}
window.PyramidPresentView = PyramidPresentView;
