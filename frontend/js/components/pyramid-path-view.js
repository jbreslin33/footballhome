// pyramid-path-view.js — #apsl-pyramid "Club pathway", a view over
// PyramidModel: pick a club, see each of its teams' way up the pyramid.
//
// For every table the club has a team in, PyramidModel.upRoutes() walks the
// promoting links to the top; each route is drawn top-down with the same
// table boxes PyramidFlowView draws, the club's own rows marked.  A table
// with two ways up (North Jersey Liga 1 → Delaware River / Metropolitan)
// shows both routes side by side.  The picked club is remembered.
class PyramidPathView {
  constructor(screen, flow) {
    this.screen = screen; this.flow = flow;
    this.clubId = null;
    try { this.clubId = Number(localStorage.getItem('apsl-pyramid-club')) || null; } catch (_) { /* private mode */ }
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .pt-pick { display:flex; justify-content:center; margin:4px 0 14px; }
      .pt-pick input { width:min(420px, 100%); padding:8px 12px; font-size:1rem; border-radius:999px; }
      .pt-club { text-align:center; margin:0 0 4px; }
      .pt-venue { text-align:center; font-size:0.8rem; opacity:0.7; margin-bottom:12px; }
      .pt-team { margin:0 0 26px; }
      .pt-team h3 { text-align:center; font-size:1rem; margin:0 0 8px; }
      .pt-routes { display:flex; gap:28px; justify-content:center; flex-wrap:wrap; align-items:flex-start; }
      .pt-route { display:flex; flex-direction:column; align-items:center; }
      .pt-up { width:0; height:0; border-left:9px solid transparent; border-right:9px solid transparent; border-bottom:14px solid #64748b; margin:6px 0; }
      .pt-conf { border:2px solid #2563eb; border-radius:14px; padding:8px 10px; background:rgba(37,99,235,0.08); text-align:center; }
      .pt-conf h4 { margin:0 0 6px; }
      .pt-conf .fc-cell { display:flex; gap:10px; justify-content:center; }`;
  }

  html(model) {
    const esc = (t) => this._esc(t);
    const names = model.clubs.map((c) => c.name).sort((a, b) => a.localeCompare(b));
    const club = this.clubId && model.clubs.find((c) => c.id === this.clubId);
    return `
      <div class="pt-pick">
        <input class="pt-search" list="pt-clubs" placeholder="${esc(this._copy('path_search'))}" value="${esc(club ? club.name : '')}">
        <datalist id="pt-clubs">${names.map((n) => `<option value="${esc(n)}">`).join('')}</datalist>
      </div>
      <div class="pt-body">${club ? this._clubHtml(model, club) : `<div class="fc-none">${esc(this._copy('path_pick'))}</div>`}</div>`;
  }

  _nodeHtml(model, node, club) {
    const esc = (t) => this._esc(t);
    if (node[0] === 'c') {
      // A conference: its own tables in its container.
      const conf = model.comp(Number(node.slice(1)));
      const col = conf && model.layout([conf]).columns[0];
      if (!col) return '';
      const tables = col.top.map((d) => {
        const part = model.confTableTitle(col, d);
        return this.flow.tableHtml(model, d, part ? esc(part) : '', '', '', { club: club.name });
      }).join('');
      return `<div class="pt-conf"><h4>${esc(conf.name)}</h4><div class="fc-cell">${tables}</div></div>`;
    }
    const d = model.division(Number(node.slice(1)));
    if (!d) return '';
    const lg = model.comp(d.competition_id);
    const apsl = lg && lg.kind === 'conference';
    const title = `<span class="lg">${esc(model.label(lg))}</span> · ${esc(d.name)}`;
    return this.flow.tableHtml(model, d, title, apsl ? '' : 'feeder', '', { club: club.name });
  }

  _clubHtml(model, club) {
    const esc = (t) => this._esc(t);
    const p = model.clubPoint(club);
    const venue = [club.venue_name, club.venue].filter(Boolean).join(' · ');
    const teams = (club.divisions || []).map((id) => model.division(id)).filter(Boolean).map((d) => {
      const routes = model.upRoutes(d.id);
      const steps = routes.map((r) => model.routeSteps(r)).filter((n) => n != null);
      const best = steps.length ? Math.min(...steps) : null;
      const lg = model.comp(d.competition_id);
      const table = `${model.label(lg)} · ${d.name}`;
      const head = best === 0 ? this._copy('path_apsl', { table })
        : best != null ? this._copy('path_team', { table, steps: best })
          : this._copy('path_none', { table });
      // Top of the pyramid first: each route reversed, arrows pointing up.
      const cols = routes.map((r) => `
        <div class="pt-route">${[...r].reverse().map((n) => this._nodeHtml(model, n, club)).join('<div class="pt-up"></div>')}</div>`).join('');
      return `<div class="pt-team"><h3>${esc(head)}</h3><div class="pt-routes">${cols}</div></div>`;
    }).join('');
    return `
      <h2 class="pt-club">${esc(club.name)}</h2>
      <div class="pt-venue">${esc(venue || (p && p.approx ? this._copy('map_at_league') : ''))}</div>
      ${teams}`;
  }

  mount(root, model) {
    this.root = root; this.model = model;
    const input = root.querySelector('.pt-search');
    if (!input) return;
    input.addEventListener('change', () => {
      const club = model.clubByName(input.value);
      if (!club) return;
      this.clubId = club.id;
      try { localStorage.setItem('apsl-pyramid-club', String(club.id)); } catch (_) { /* private mode */ }
      root.querySelector('.pt-body').innerHTML = this._clubHtml(model, club);
    });
  }

  onResize() {}
  unmount() {}
}
window.PyramidPathView = PyramidPathView;
