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
class PyramidFlowView {
  constructor(screen) { this.screen = screen; }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .fc-scroll { overflow-x:auto; padding-bottom:var(--space-4); }
      .fc-chart { position:relative; display:grid; column-gap:22px; row-gap:46px; width:max-content; margin:0 auto; align-items:start; justify-items:center; }
      .fc-arrows { position:absolute; left:0; top:0; pointer-events:none; overflow:visible; z-index:0; }
      .fc-cell { display:flex; gap:10px; justify-content:center; position:relative; z-index:1; }
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
      .fc-legend { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; font-size:0.75rem; opacity:0.85; margin:-4px 0 12px; }
      .fc-legend i { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:4px; vertical-align:-1px; }
      .fc-edit { position:absolute; top:3px; right:4px; background:none; border:0; color:inherit; opacity:0.45; cursor:pointer; font-size:0.75rem; padding:2px; min-height:0; min-width:0; }
      .fc-edit:hover { opacity:1; }`;
  }

  // ── pieces ───────────────────────────────────────────────────────────
  tableHtml(model, d, title, cls, note) {
    const esc = (t) => this._esc(t);
    const cols = (this._copy('table_head') || '').split(/\s+/).filter(Boolean);
    const head = cols.map((c, i) => `<th${i === 1 ? ' class="tm"' : ''}>${esc(c === '-' ? '' : c)}</th>`).join('');
    const rows = (d.teams || []).map((t) => {
      const z = model.zoneOf(d, t.pos);
      const tip = z ? (z.targets ? this._copy('moves_to', { zone: z.label, targets: z.targets }) : z.label) : '';
      return `
      <tr class="${z ? 'z' : ''}" data-pos="${t.pos == null ? '' : esc(t.pos)}"${z ? ` style="--zc:${esc(z.color)}" title="${esc(tip)}"` : ''}>
        <td>${t.pos == null ? '' : esc(t.pos)}</td><td class="tm">${esc(t.name)}</td>
        <td>${t.gp}</td><td>${t.gd > 0 ? '+' : ''}${t.gd}</td><td><b>${t.pts}</b></td>
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
    const legend = this.legendHtml(model);
    return `
      ${legend ? `<div class="fc-legend">${legend}</div>` : ''}
      <div class="fc-scroll">${this.chartHtml(model, confs)}</div>`;
  }

  mount(root, model, confs) { this.drawArrows(root.querySelector('.fc-chart'), model, confs); }
  onResize(root, model, confs) { this.mount(root, model, confs); }
  unmount() {}

  // Lower table's top edge → its target's bottom edge, in chart-local
  // coordinates (a zoomed stage's scale divided out).
  drawArrows(chart, model, confs) {
    const svg = chart && chart.querySelector('.fc-arrows');
    if (!svg) return;
    const box = chart.getBoundingClientRect();
    const k = chart.offsetWidth ? box.width / chart.offsetWidth : 1;
    const paths = [];
    for (const e of model.layout(confs).edges) {
      const from = chart.querySelector(`.fc-cell.lv [data-node="d${e.from}"]`);
      const to = chart.querySelector(`[data-node="${e.to}"]`);
      if (!from || !to) continue;
      const a = from.getBoundingClientRect(), b = to.getBoundingClientRect();
      const x1 = (a.left + a.width / 2 - box.left) / k, y1 = (a.top - box.top) / k;
      // Into a conference: aim above the feeder (clamped into the
      // container) so the arrows fan in instead of meeting mid-box.
      const bl = (b.left - box.left) / k, br = (b.right - box.left) / k;
      const x2 = e.to[0] === 'c' ? Math.min(Math.max(x1, bl + 24), br - 24) : (bl + br) / 2;
      const y2 = (b.bottom - box.top) / k + 3;
      const my = (y1 + y2) / 2;
      paths.push(`<path d="M${x1},${y1 - 2} C${x1},${my} ${x2},${my} ${x2},${y2}"${e.up ? ' marker-end="url(#fc-up)"' : ''}${e.down ? ' marker-start="url(#fc-down)"' : ''} />`);
    }
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
