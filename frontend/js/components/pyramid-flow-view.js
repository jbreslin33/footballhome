// pyramid-flow-view.js — the #apsl-pyramid flow chart (migs 823–836), a
// view over PyramidModel.  Owner 2026-10-29: "apsl conferences are all at
// same level … then under it are the feeder leagues connected by arrows
// like a flow chart."
//
// ONE chart: the conferences side by side on the top row, each with its own
// tables in a container, and each level of feeder tables in the rows below,
// under the conference it feeds.  Every box carries data-node ("c<conf>" /
// "d<table>") so other views (the presentation) can find and fly to it.
// Arrows are an SVG overlay measured from the laid-out boxes; drawArrows()
// works on a zoomed stage too (it divides out the stage's scale).
//
// Panning (owner 2026-11-11: "flowchart view needs to be able to be
// draggable right to left and up to down"): the view fills the stage and
// .fc-scroll is its ONE scroller, both directions — grab with the mouse and
// drag; a finger pans it natively.  A drag never fires the click under it
// (club card, ✏️), a plain click still does.
//
// Outlier links (owner 2026-11-11, mig 1238): a table that feeds two
// conferences sends its MINORITY link (the conference fewer of its teams'
// grounds are nearest) from those teams' rows — one branch per row, merged
// into one line beside the table.  Always drawn — its on/off switch went
// 2026-11-24 (mig 1823; owner: "clutter").
// Not on the map (proposed borders live there).
//
// Zoom (owner 2026-11-24: "the pyramid needs to allow zoom in and out",
// mig 1814): − / % / + / Fit buttons in the bottom-right corner, the mouse
// wheel (and a trackpad or two-finger pinch) about the pointer, and the
// + / − / 0 keys.  The chart
// is scaled by a transform inside .fc-zoomed, which is sized to the scaled
// chart so the scroller pans exactly what is drawn.  The level is kept on
// the view, so a re-render (conference pills, resize) holds it.
class PyramidFlowView {
  constructor(screen) { this.screen = screen; this.fill = true; this.zoom = 1; }


  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .fc-scroll { position:absolute; inset:0; overflow:auto; outline:none; padding:16px 16px 24px; cursor:grab; touch-action:pan-x pan-y; }
      .fc-scroll.dragging { cursor:grabbing; user-select:none; }
      .fc-scroll.dragging * { cursor:grabbing !important; }
      .fc-chart { position:relative; display:grid; column-gap:64px; row-gap:56px; width:max-content; margin:0 auto; align-items:start; justify-items:center; }
      .fc-zoomed { margin:0 auto; }
      .fc-zoomed > .fc-chart { margin:0; transform-origin:0 0; }
      .fc-zoom { position:absolute; right:12px; bottom:12px; z-index:5; display:flex; gap:4px; padding:4px; border-radius:999px; background:rgba(15,23,42,0.85); border:1px solid rgba(148,163,184,0.35); }
      .fc-zoom button { min-height:0; min-width:34px; height:30px; padding:0 10px; border-radius:999px; cursor:pointer; font-weight:800; font-size:0.85rem; border:1px solid rgba(148,163,184,0.35); background:rgba(30,41,59,0.9); color:#e2e8f0; }
      .fc-zoom button:hover { background:#2563eb; border-color:transparent; color:#fff; }
      .fc-arrows { position:absolute; left:0; top:0; pointer-events:none; overflow:visible; z-index:0; }
      .fc-tbl tr.fc-out td.tm { text-decoration:underline dotted #94a3b8; text-underline-offset:3px; }
      .fc-cell { display:flex; gap:44px; justify-content:center; position:relative; z-index:1; }   /* room for the lines (owner: "spread the tables more to see line") */
      .fc-conf { border:2px solid #2563eb; border-radius:14px; padding:10px; background:rgba(37,99,235,0.08); position:relative; z-index:1; }
      .fc-conf h2 { margin:0; font-size:1.1rem; text-align:center; }
      .fc-meta { font-size:0.78rem; opacity:0.7; text-align:center; margin:2px 0 8px; }
      .fc-meta a { color:#93c5fd; }
      .fc-tbl { position:relative; background:var(--card-bg, #111827); border:1px solid var(--border-color, #374151); border-radius:10px; padding:6px 6px 4px; width:230px; }
      .fc-conf .fc-tbl { border-color:#1d4ed8; }
      .fc-tbl.feeder { border-color:#0f766e; }
      .fc-tbl .hd { font-weight:800; font-size:0.82rem; text-align:center; margin-bottom:3px; }
      .fc-tbl .hd .lg { opacity:0.65; font-weight:600; }
      .fc-tbl .note { font-size:0.7rem; opacity:0.65; text-align:center; margin-top:3px; }
      .fc-tbl.empty { opacity:0.6; font-size:0.78rem; text-align:center; padding:10px 6px; }
      .fc-tbl table { width:100%; border-collapse:collapse; font-size:0.76rem; }
      .fc-tbl th { font-size:0.66rem; opacity:0.6; font-weight:700; padding:1px 3px; text-align:center; }
      .fc-tbl td { padding:2px 3px; text-align:center; border-top:1px solid rgba(255,255,255,0.06); white-space:nowrap; }
      .fc-tbl td.tm, .fc-tbl th.tm { text-align:left; white-space:normal; width:100%; }
      .fc-tbl tr.z td:first-child { box-shadow:inset 4px 0 var(--zc); }
      .fc-tbl tr.z td { background:color-mix(in srgb, var(--zc) 20%, transparent); }
      .fc-tbl tr.mine td { font-weight:800; outline:2px solid #e0e7ff; outline-offset:-2px; }
      .fc-legend { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; font-size:0.75rem; opacity:0.85; margin:-4px 0 12px; }
      .fc-legend i { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:4px; vertical-align:-1px; }
      .fc-edit { position:absolute; top:3px; right:4px; background:none; border:0; color:inherit; opacity:0.45; cursor:pointer; font-size:0.75rem; padding:2px; min-height:0; min-width:0; }
      .fc-edit:hover { opacity:1; }`;
  }

  // ── pieces ───────────────────────────────────────────────────────────
  // opts.club: a club name whose rows are marked (the Club pathway view);
  // opts.full: every column — W D L GF GA too (the Standings view);
  // opts.find: lower-case text; rows whose team contains it are marked.
  tableHtml(model, d, title, cls, note, opts = {}) {
    const esc = (t) => this._esc(t);
    const cols = (this._copy(opts.full ? 'table_head_full' : 'table_head') || '').split(/\s+/).filter(Boolean);
    const head = cols.map((c, i) => `<th${i === 1 ? ' class="tm"' : ''}>${esc(c === '-' ? '' : c)}</th>`).join('');
    const rows = (d.teams || []).map((t) => {
      const z = model.zoneOf(d, t.pos);
      const tip = z ? (z.targets ? this._copy('moves_to', { zone: z.label, targets: z.targets }) : z.label) : '';
      return `
      <tr data-team="${t.id}" class="${z ? 'z' : ''}${(opts.club && t.club === opts.club) || (opts.find && t.name.toLowerCase().includes(opts.find)) ? ' mine' : ''}" data-pos="${t.pos == null ? '' : esc(t.pos)}"${z ? ` style="--zc:${esc(z.color)}" title="${esc(tip)}"` : ''}>
        <td>${t.pos == null ? '' : esc(t.pos)}</td><td class="tm"${t.club_id ? ` data-club="${t.club_id}" title="${esc(this._copy('card_hint'))}"` : ''}>${esc(t.name)}</td>
        <td>${t.gp}</td>${opts.full ? `<td>${t.w}</td><td>${t.d}</td><td>${t.l}</td><td>${t.gf}</td><td>${t.ga}</td>` : ''}<td>${t.gd > 0 ? '+' : ''}${t.gd}</td><td><b>${t.pts}</b></td>
      </tr>`;
    }).join('');
    return `
      <div class="fc-tbl ${cls}" data-div="${d.id}" data-node="d${d.id}">
        <button class="fc-edit" data-edit="${d.id}" title="${esc(this._copy('edit_hint'))}">✏️</button>
        ${title ? `<div class="hd">${title}</div>` : ''}
        <table><thead><tr>${head}</tr></thead><tbody>${rows}</tbody></table>
        ${note ? `<div class="note">${esc(note)}</div>` : ''}
      </div>`;
  }

  confHtml(model, col) {
    const esc = (t) => this._esc(t);
    const conf = col.conf;
    const { clubs, teams } = model.columnCounts(col);
    const root = model.comp(conf.parent_id);
    const src = root && root.source;
    let meta = esc((conf.states || []).join(' · '));
    if (teams) meta += ` · ${esc(this._copy('node_counts', { clubs, teams }))}`;
    if (src && src.ok === false) meta += `<br><span class="ap-warn">${esc(this._copy('stale', { when: src.ok_at || '—' }))}</span>`;
    if (conf.standings_url) meta += ` · <a href="${esc(conf.standings_url)}" target="_blank" rel="noopener">${esc(this._copy('site_link'))}</a>`;
    const tables = col.top.map((d) => {
      const part = model.confTableTitle(col, d);
      return this.tableHtml(model, d, part ? esc(part) : '', '', '');
    }).join('');
    return `
      <div class="fc-conf" data-node="c${conf.id}">
        <h2>${esc(model.label(conf))}</h2>
        <div class="fc-meta">${meta}</div>
        <div class="fc-cell">${tables}</div>
      </div>`;
  }

  legendHtml(model) {
    const esc = (t) => this._esc(t);
    return model.zonesInUse().map((z) => `<span><i style="background:${esc(z.color)}"></i>${esc(model.kindLabel(z.kind))}</span>`)
      .concat([`<span><b style="color:${esc(model.kindColor('promotion'))}">▲</b> ${esc(this._copy('arrow_up'))}</span>`,
               `<span><b style="color:${esc(model.kindColor('relegation'))}">▼</b> ${esc(this._copy('arrow_down'))}</span>`]).join('');
  }

  // The colour key, on the screen's caption line (mig 1825).
  legend(model) { return this.legendHtml(model); }

  // The chart itself (grid + arrow layer), no legend / scroller around it.
  chartHtml(model, confs) {
    const esc = (t) => this._esc(t);
    const L = model.layout(confs);
    const cells = [];
    L.columns.forEach((col, ci) => {
      cells.push(`<div style="grid-column:${ci + 1}; grid-row:1;">${this.confHtml(model, col)}</div>`);
      const rows = col.levels.map((ids) => ids.map((id) => {
        const d = model.division(id);
        const also = model.alsoFeeds(id, col.conf.id);
        const note = also.length ? this._copy('also_feeds', { conference: also.map((c) => model.label(c)).join(', ') }) : '';
        const title = `<span class="lg">${esc(model.label(model.comp(d.competition_id)))}</span> · ${esc(d.name)}`;
        return this.tableHtml(model, d, title, 'feeder', note);
      }));
      const empty = col.unmirrored.map((c) => `<div class="fc-tbl feeder empty">${esc(this._copy('not_mirrored', { league: model.label(c) }))}</div>`);
      if (empty.length) { if (rows.length) rows[0].push(...empty); else rows.push(empty); }
      rows.forEach((boxes, li) => cells.push(`<div class="fc-cell lv" data-col="${ci}" data-level="${li + 1}" style="grid-column:${ci + 1}; grid-row:${li + 2};">${boxes.join('')}</div>`));
    });
    return `
      <div class="fc-chart" style="grid-template-columns:repeat(${confs.length}, max-content);">
        <svg class="fc-arrows"></svg>
        ${cells.join('')}
      </div>`;
  }

  // ── the view ─────────────────────────────────────────────────────────
  html(model, confs) {
    return `
      <div class="fc-scroll" tabindex="0"><div class="fc-zoomed">${this.chartHtml(model, confs)}</div></div>
      <div class="fc-zoom">
        <button data-zoom="out" title="${this._esc(this._copy('zoom_out'))}">−</button>
        <button data-zoom="reset" title="${this._esc(this._copy('zoom_reset'))}"></button>
        <button data-zoom="in" title="${this._esc(this._copy('zoom_in'))}">+</button>
        <button data-zoom="fit">${this._esc(this._copy('zoom_fit'))}</button>
      </div>`;
  }

  mount(root, model, confs) {
    const el = root.querySelector('.fc-scroll');
    this._applyZoom(root);
    this.drawArrows(root.querySelector('.fc-chart'), model, confs);
    this.pannable(el);
    this.zoomable(root, el);
  }

  // Scale the chart and size its wrapper to match (a transform alone
  // leaves the layout box, and so the scroll range, at 100%).
  _applyZoom(root) {
    const chart = root.querySelector('.fc-zoomed > .fc-chart');
    if (!chart) return;
    const z = this.zoom, wrap = chart.parentElement;
    chart.style.transform = z === 1 ? '' : `scale(${z})`;
    wrap.style.width = `${chart.offsetWidth * z}px`;
    wrap.style.height = `${chart.offsetHeight * z}px`;
    const pct = root.querySelector('[data-zoom="reset"]');
    if (pct) pct.textContent = `${Math.round(z * 100)}%`;
  }

  // Zoom to z, keeping the chart point under (cx, cy) — client pixels, the
  // middle of the window when not given — where it is.
  _zoomTo(root, z, cx, cy) {
    const el = root.querySelector('.fc-scroll'), chart = root.querySelector('.fc-zoomed > .fc-chart');
    if (!el || !chart) return;
    z = Math.min(2.5, Math.max(0.2, z));
    const view = el.getBoundingClientRect();
    if (cx == null) { cx = view.left + view.width / 2; cy = view.top + view.height / 2; }
    const before = chart.getBoundingClientRect(), old = this.zoom;
    const px = (cx - before.left) / old, py = (cy - before.top) / old;
    this.zoom = z;
    this._applyZoom(root);
    const after = chart.getBoundingClientRect();
    el.scrollLeft += after.left + px * z - cx;
    el.scrollTop += after.top + py * z - cy;
  }

  // The whole chart in the window (never past 100% — text stays its size).
  _zoomFit(root) {
    const el = root.querySelector('.fc-scroll'), chart = root.querySelector('.fc-zoomed > .fc-chart');
    if (!el || !chart || !chart.offsetWidth) return;
    const z = Math.min(1, (el.clientWidth - 32) / chart.offsetWidth, (el.clientHeight - 40) / chart.offsetHeight);
    this._zoomTo(root, z);
    el.scrollLeft = 0; el.scrollTop = 0;
  }

  zoomable(root, el) {
    if (!el || el._zoom) return;
    el._zoom = true;
    const step = (dir, cx, cy) => this._zoomTo(root, this.zoom * (dir > 0 ? 1.2 : 1 / 1.2), cx, cy);
    // The wheel zooms (as on the map and the tour); drag pans.
    el.addEventListener('wheel', (e) => {
      e.preventDefault();
      const dy = e.deltaMode === 1 ? e.deltaY * 33 : e.deltaY;
      this._zoomTo(root, this.zoom * Math.exp(-dy * 0.002), e.clientX, e.clientY);
    }, { passive: false });
    // Two fingers pinch (one finger still pans natively).
    let pinch = null;
    const gap = (t) => Math.hypot(t[0].clientX - t[1].clientX, t[0].clientY - t[1].clientY);
    el.addEventListener('touchstart', (e) => {
      pinch = e.touches.length === 2 ? { d: gap(e.touches) || 1, z: this.zoom } : null;
    }, { passive: true });
    el.addEventListener('touchmove', (e) => {
      if (!pinch || e.touches.length !== 2) return;
      e.preventDefault();
      const t = e.touches;
      this._zoomTo(root, pinch.z * gap(t) / pinch.d, (t[0].clientX + t[1].clientX) / 2, (t[0].clientY + t[1].clientY) / 2);
    }, { passive: false });
    el.addEventListener('touchend', () => { pinch = null; }, { passive: true });
    el.addEventListener('touchcancel', () => { pinch = null; }, { passive: true });
    el.addEventListener('keydown', (e) => {
      if (e.ctrlKey || e.metaKey || e.altKey) return;
      if (e.key === '+' || e.key === '=') step(1);
      else if (e.key === '-' || e.key === '_') step(-1);
      else if (e.key === '0') this._zoomTo(root, 1);
      else return;
      e.preventDefault();
    });
    const bar = root.querySelector('.fc-zoom');
    if (bar) bar.addEventListener('click', (e) => {
      const b = e.target.closest('[data-zoom]');
      if (!b) return;
      if (b.dataset.zoom === 'fit') this._zoomFit(root);
      else if (b.dataset.zoom === 'reset') this._zoomTo(root, 1);
      else step(b.dataset.zoom === 'in' ? 1 : -1);
    });
  }

  // Mouse / pen drag pans the scroller (touch already does).  Past 5 px it
  // is a drag and the click that ends it is swallowed.
  pannable(el) {
    if (!el || el._pan) return;
    el._pan = true;
    let drag = null;
    el.addEventListener('pointerdown', (e) => {
      if (e.pointerType === 'touch' || e.button !== 0) return;
      if (e.target.closest('input, select, textarea, .ap-hud')) return;
      drag = { x: e.clientX, y: e.clientY, left: el.scrollLeft, top: el.scrollTop, moved: false, id: e.pointerId };
    });
    el.addEventListener('pointermove', (e) => {
      if (!drag || e.pointerId !== drag.id) return;
      const dx = e.clientX - drag.x, dy = e.clientY - drag.y;
      if (!drag.moved) {
        if (Math.abs(dx) + Math.abs(dy) < 5) return;
        drag.moved = true;
        el.classList.add('dragging');
        try { el.setPointerCapture(e.pointerId); } catch (_) { /* gone */ }
      }
      el.scrollLeft = drag.left - dx;
      el.scrollTop = drag.top - dy;
      e.preventDefault();
    });
    const end = (e) => {
      if (!drag || (e && e.pointerId !== drag.id)) return;
      const moved = drag.moved;
      drag = null;
      el.classList.remove('dragging');
      if (moved) {
        const eat = (c) => { c.stopPropagation(); c.preventDefault(); };
        el.addEventListener('click', eat, { capture: true, once: true });
        setTimeout(() => el.removeEventListener('click', eat, { capture: true }), 0);
      }
    };
    el.addEventListener('pointerup', end);
    el.addEventListener('pointercancel', end);
  }
  onResize(root, model, confs) { this.mount(root, model, confs); }
  unmount() {}

  // Lower table's top edge → its target's bottom edge, in chart-local
  // coordinates (a zoomed stage's scale divided out).
  // Branches from each outlier row out to the table's edge on the target's
  // side, a trunk up that edge, then the usual curve into the conference.
  // Promotion head at the conference; relegation heads into the rows.
  _outlierPath(rows, a, b, box, k, e, side) {
    const L = (x) => (x - box.left) / k, T = (y) => (y - box.top) / k;
    const right = side ? side === 'right' : (b.left + b.right) / 2 >= (a.left + a.right) / 2;
    const edge = right ? L(a.right) : L(a.left);
    const jx = edge + (right ? 20 : -20);   // mid-gap between tables (.fc-cell gap 44px)
    const ys = rows.map((r) => { const rr = r.getBoundingClientRect(); return T(rr.top + rr.height / 2); });
    const top = T(a.top) - 8;
    const bl = L(b.left), br = L(b.right);
    const x2 = Math.min(Math.max(jx, bl + 24), br - 24), y2 = T(b.bottom) + 3;
    const my = (top + y2) / 2;
    const branch = ys.map((y) => `<path d="M${jx},${y} H${edge + (right ? 1 : -1)}"${e.down ? ' marker-end="url(#fc-down)"' : ''} />`).join('');
    return `<g class="fc-out-link">${branch}<path d="M${jx},${Math.max(...ys)} V${top} C${jx},${my} ${x2},${my} ${x2},${y2}"${e.up ? ' marker-end="url(#fc-up)"' : ''} /></g>`;
  }

  // opts.outliers false: every link from the table edge (the map's
  // conference overlay — outlier lines are for the chart views only).
  drawArrows(chart, model, confs, opts = {}) {
    const svg = chart && chart.querySelector('.fc-arrows');
    if (!svg) return;
    const box = chart.getBoundingClientRect();
    const k = chart.offsetWidth ? box.width / chart.offsetWidth : 1;
    const paths = [];
    const outliers = opts.outliers !== false;
    const edges = model.layout(confs).edges;
    // A split table (mig 1260): each conference's rows leave by the side
    // facing it — the leftmost conference's out of the left edge, the
    // others out of the right (owner: "right side for metro and left side
    // for del").
    const sideOf = new Map();
    if (outliers) {
      const byTable = new Map();
      for (const e of edges) if (e.teams && e.teams.length && e.to[0] === 'c') (byTable.get(e.from) || byTable.set(e.from, []).get(e.from)).push(e);
      for (const list of byTable.values()) {
        if (list.length < 2) continue;
        const cx = (e) => { const el = chart.querySelector(`[data-node="${e.to}"]`); const r = el && el.getBoundingClientRect(); return r ? r.left + r.width / 2 : 0; };
        list.sort((p, q) => cx(p) - cx(q)).forEach((e, i) => sideOf.set(e, i === 0 ? 'left' : 'right'));
      }
    }
    for (const e of edges) {
      const from = chart.querySelector(`.fc-cell.lv [data-node="d${e.from}"]`);
      const to = chart.querySelector(`[data-node="${e.to}"]`);
      if (!from || !to) continue;
      const a = from.getBoundingClientRect(), b = to.getBoundingClientRect();
      const rows = outliers && e.teams && e.teams.length
        ? e.teams.map((id) => from.querySelector(`tr[data-team="${id}"]`)).filter(Boolean) : [];
      if (rows.length) { paths.push(this._outlierPath(rows, a, b, box, k, e, sideOf.get(e))); continue; }
      const x1 = (a.left + a.width / 2 - box.left) / k, y1 = (a.top - box.top) / k;
      // Into a conference: aim above the feeder (clamped into the
      // container) so the arrows fan in instead of meeting mid-box.
      const bl = (b.left - box.left) / k, br = (b.right - box.left) / k;
      const x2 = e.to[0] === 'c' ? Math.min(Math.max(x1, bl + 24), br - 24) : (bl + br) / 2;
      const y2 = (b.bottom - box.top) / k + 3;
      const my = (y1 + y2) / 2;
      paths.push(`<path d="M${x1},${y1 - 2} C${x1},${my} ${x2},${my} ${x2},${y2}"${e.up ? ' marker-end="url(#fc-up)"' : ''}${e.down ? ' marker-start="url(#fc-down)"' : ''} />`);
    }
    chart.querySelectorAll('tr.fc-out').forEach((tr) => tr.classList.remove('fc-out'));
    // dotted underline: the smaller group's rows only
    if (outliers) for (const e of edges.filter((x) => x.majority === false))
      for (const id of e.teams || []) chart.querySelectorAll(`.fc-cell.lv [data-node="d${e.from}"] tr[data-team="${id}"]`).forEach((tr) => tr.classList.add('fc-out'));
    svg.setAttribute('width', chart.offsetWidth);
    svg.setAttribute('height', chart.offsetHeight);
    svg.innerHTML = `
      <defs>
        <marker id="fc-up" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M0,0 L10,5 L0,10 z" fill="${model.kindColor('promotion')}" /></marker>
        <marker id="fc-down" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M0,0 L10,5 L0,10 z" fill="${model.kindColor('relegation')}" /></marker>
      </defs>
      <g fill="none" stroke="#64748b" stroke-width="2">${paths.join('')}</g>`;
  }
}
window.PyramidFlowView = PyramidFlowView;
