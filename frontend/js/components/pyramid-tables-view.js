// pyramid-tables-view.js — #apsl-pyramid "Standings", a view over
// PyramidModel: every table in one list, full columns.
//
// The order is the flow chart's (PyramidModel.layout): per conference on
// the pills, its own tables, then its feeder tables level by level.  Tables
// are PyramidFlowView.tableHtml with opts.full (W D L GF GA too).  Tables
// with no link (reserves, over-40s, women's, a feeder's own copy of APSL
// teams) follow as "other tables" of the leagues under that conference; the
// root league's own tables (the APSL cups) close the list.  A find
// box narrows the list to the tables a team plays in and marks its rows.
class PyramidTablesView {
  constructor(screen, flow) { this.screen = screen; this.flow = flow; this.find = ''; }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .tb-find { display:flex; justify-content:center; margin:4px 0 12px; }
      .tb-find input { width:min(420px, 100%); padding:8px 12px; font-size:1rem; border-radius:999px; }
      .tb-conf { margin:0 0 26px; }
      .tb-conf > h2 { margin:0; font-size:1.15rem; }
      .tb-meta { font-size:0.78rem; opacity:0.7; margin:2px 0 8px; }
      .tb-meta a { color:#93c5fd; }
      .tb-level { font-size:0.72rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6; margin:12px 0 6px; }
      .tb-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(330px, 1fr)); gap:12px; }
      .tb-grid .fc-tbl { width:auto; }
      .tb-grid .fc-tbl table { font-size:0.8rem; }`;
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    const legend = this.flow.legendHtml(model);
    return `
      ${legend ? `<div class="fc-legend">${legend}</div>` : ''}
      <div class="tb-find"><input class="tb-search" placeholder="${esc(this._copy('tables_search'))}" value="${esc(this.find)}"></div>
      <div class="tb-body">${this._bodyHtml(model, confs)}</div>`;
  }

  _bodyHtml(model, confs) {
    const esc = (t) => this._esc(t);
    const find = this.find.trim().toLowerCase();
    const has = (d) => !find || (d.teams || []).some((t) => t.name.toLowerCase().includes(find));
    const opts = { full: true, find: find || null };
    const title = (d) => `<span class="lg">${esc(model.label(model.comp(d.competition_id)))}</span> · ${esc(d.name)}`;
    const out = model.layout(confs).columns.map((col) => {
      const own = col.top.filter(has).map((d) => {
        const part = model.confTableTitle(col, d);
        return this.flow.tableHtml(model, d, part ? esc(part) : '', '', '', opts);
      });
      const levels = col.levels.map((ids, i) => {
        const tables = ids.map((id) => model.division(id)).filter((d) => d && has(d)).map((d) => this.flow.tableHtml(model, d, title(d), 'feeder', '', opts));
        return tables.length ? `<div class="tb-level">${esc(this._copy('present_level', { conference: model.label(col.conf), level: i + 1 }))}</div><div class="tb-grid">${tables.join('')}</div>` : '';
      }).join('');
      // The same leagues' tables that aren't on the chart (no link).
      const charted = new Set([...col.top, ...col.reach].map((d) => d.id));
      const leagues = new Set([...col.reach.map((d) => d.competition_id),
        ...model.competitions.filter((c) => c.parent_id === col.conf.id).map((c) => c.id)]);
      const others = model.divisions.filter((d) => leagues.has(d.competition_id) && !charted.has(d.id) && has(d))
        .map((d) => this.flow.tableHtml(model, d, title(d), 'feeder', '', opts));
      const otherHtml = others.length ? `<div class="tb-level">${esc(this._copy('tables_other', { conference: model.label(col.conf) }))}</div><div class="tb-grid">${others.join('')}</div>` : '';
      if (!own.length && !levels && !otherHtml) return '';
      const { clubs, teams } = model.columnCounts(col);
      const root = model.comp(col.conf.parent_id);
      const src = root && root.source;
      let meta = esc((col.conf.states || []).join(' · '));
      if (teams) meta += ` · ${esc(this._copy('node_counts', { clubs, teams }))}`;
      if (src && src.read_at) meta += ` · ${esc(this._copy('read_at', { when: src.read_at }))}`;
      if (col.conf.standings_url) meta += ` · <a href="${esc(col.conf.standings_url)}" target="_blank" rel="noopener">${esc(this._copy('site_link'))}</a>`;
      return `
        <section class="tb-conf">
          <h2>${esc(col.conf.name)}</h2>
          <div class="tb-meta">${meta}</div>
          ${own.length ? `<div class="tb-grid">${own.join('')}</div>` : ''}
          ${levels}
          ${otherHtml}
        </section>`;
    }).join('');
    // The root league's own tables (the APSL cups).
    const root = model.root();
    const cups = root ? model.divisions.filter((d) => d.competition_id === root.id && has(d)) : [];
    const cupsHtml = cups.length ? `
        <section class="tb-conf">
          <h2>${esc(this._copy('tables_cups', { league: model.label(root) }))}</h2>
          <div class="tb-grid">${cups.map((d) => this.flow.tableHtml(model, d, esc(d.name), '', '', opts)).join('')}</div>
        </section>` : '';
    return (out + cupsHtml) || `<div class="fc-none">${esc(this._copy('tables_none'))}</div>`;
  }

  mount(root, model, confs) {
    const input = root.querySelector('.tb-search');
    if (!input) return;
    input.addEventListener('input', () => {
      this.find = input.value;
      clearTimeout(this._t);
      this._t = setTimeout(() => { root.querySelector('.tb-body').innerHTML = this._bodyHtml(model, confs); }, 150);
    });
  }

  onResize() {}
  unmount() {}
}
window.PyramidTablesView = PyramidTablesView;
