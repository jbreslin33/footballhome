// pyramid-path-view.js — #apsl-pyramid "Club pathway", a view over
// PyramidModel: pick a club, see each of its teams' way up the pyramid.
//
// For every table the club has a team in, PyramidModel.upRoutes() walks the
// promoting links to the top; each route is drawn top-down with the same
// table boxes PyramidFlowView draws, the club's own rows marked.  A table
// with two ways up (North Jersey Liga 1 → Delaware River / Metropolitan)
// shows both routes side by side.  The picked club is remembered.
//
// Picking a club (owner 2026-11-24: "needs easy selection of clubs. maybe a
// list by league name then teams under them in a carousel"): two strips on
// top, each one line that slides sideways (‹ › or a swipe) — the leagues
// (each lit conference, then the leagues feeding it), and the clubs of the
// league that is picked.  A tap on a club draws its way up.  ☰ Find a club
// still works and moves the strips to that club's league.
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
      .pt-picker { margin:0 0 14px; }
      .pt-car { display:flex; align-items:center; gap:6px; margin-bottom:6px; }
      .pt-car .strip { flex:1 1 auto; min-width:0; display:flex; gap:6px; overflow-x:auto; scroll-behavior:smooth; scrollbar-width:none; padding:2px 0; }
      .pt-car .strip::-webkit-scrollbar { display:none; }
      .pt-car .strip button { flex:0 0 auto; white-space:nowrap; min-height:0; min-width:0; padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.85rem;
                              border:1px solid var(--border-color, #374151); background:transparent; color:inherit; }
      .pt-car .strip button.on { background:var(--primary-color, #2563eb); border-color:transparent; color:#fff; }
      .pt-car .strip button.conf { border-color:var(--cc, #2563eb); border-width:2px; }
      .pt-car .strip button.conf.on { background:var(--cc, #2563eb); color:var(--cc-fg, #fff); }
      .pt-car.clubs .strip button { font-weight:600; font-size:0.82rem; padding:5px 12px; }
      .pt-car .nav { flex:0 0 auto; min-height:0; min-width:0; width:30px; height:30px; border-radius:50%; cursor:pointer; font-size:1rem; line-height:1;
                     border:1px solid var(--border-color, #374151); background:transparent; color:inherit; }
      .pt-club { text-align:center; margin:0 0 4px; }
      .pt-venue { text-align:center; font-size:0.8rem; opacity:0.7; margin-bottom:12px; }
      .pt-team { margin:0 0 26px; }
      .pt-team h3 { text-align:center; font-size:1rem; margin:0 0 8px; }
      .pt-routes { display:flex; gap:28px; justify-content:center; flex-wrap:wrap; align-items:flex-start; }
      .pt-route { display:flex; flex-direction:column; align-items:center; }
      .pt-up { width:0; height:0; border-left:9px solid transparent; border-right:9px solid transparent; border-bottom:14px solid #64748b; margin:6px 0; }
      .pt-conf { border:2px solid #2563eb; border-radius:14px; padding:8px 10px; background:rgba(37,99,235,0.08); text-align:center; }
      .pt-conf h4 { margin:0 0 6px; }
      .pt-below { display:flex; flex-direction:column; align-items:center; margin-top:14px; padding-top:12px; border-top:1px dashed rgba(148,163,184,0.3); }
      .pt-below h4 { margin:0 0 2px; font-size:0.9rem; opacity:0.85; text-align:center; }
      .pt-level { display:flex; gap:14px; justify-content:center; flex-wrap:wrap; align-items:flex-start; }
      .pt-pro { display:flex; flex-direction:column; align-items:center; gap:8px; margin:6px 0 4px; }
      .pt-pro h4 { margin:0; font-size:0.9rem; opacity:0.85; }
      .pt-pro-tier { display:flex; flex-direction:column; align-items:center; gap:4px; }
      .pt-pro-tier .lbl { font-size:0.68rem; text-transform:uppercase; letter-spacing:0.08em; opacity:0.6; }
      .pt-pro-tier .lgs { display:flex; gap:10px; flex-wrap:wrap; justify-content:center; }
      .pt-pro-lg { border:2px solid #d4a017; border-radius:12px; padding:7px 16px; font-weight:800; background:rgba(212,160,23,0.10); }
      .pt-pro-note { font-size:0.8rem; opacity:0.75; text-align:center; max-width:520px; }
      .pt-pro-doc { max-width:560px; border:2px dashed #94a3b8; border-radius:12px; padding:10px 14px; text-align:center; background:rgba(148,163,184,0.08); }
      .pt-pro-doc .why { font-size:0.85rem; font-style:italic; margin:6px 0; }
      .pt-pro-link { display:block; font-weight:800; color:#fbbf24; }
      .pt-pro-gap { width:0; height:22px; border-left:2px dashed #64748b; }
      .pt-conf .fc-cell { display:flex; gap:10px; justify-content:center; }`;
  }

  // The leagues, in pyramid order: each lit conference, then the leagues
  // feeding it; each with its clubs A–Z (a club once per league).
  _leagues(model, confs) {
    const out = [], seen = new Set();
    const add = (comp, isConf, divIds) => {
      if (!comp) return;
      let lg = out.find((x) => x.id === comp.id);
      if (!lg) { if (seen.has(comp.id)) return; seen.add(comp.id); lg = { id: comp.id, name: model.label(comp), color: isConf ? comp.color : '', conf: isConf, clubs: new Map() }; out.push(lg); }
      for (const id of divIds) {
        const d = model.division(id);
        for (const t of (d && d.teams) || []) if (t.club_id && !lg.clubs.has(t.club_id)) lg.clubs.set(t.club_id, t.club || t.name);
      }
    };
    for (const col of model.layout(confs).columns) {
      add(col.conf, true, col.top.map((d) => d.id));
      for (const ids of col.levels) for (const id of ids) { const d = model.division(id); if (d) add(model.comp(d.competition_id), false, [id]); }
    }
    return out.filter((lg) => lg.clubs.size);
  }

  _pickerHtml(model, confs) {
    const esc = (t) => this._esc(t);
    const leagues = this._leagues(model, confs);
    if (!leagues.length) return '';
    // The strip opens on the picked club's league.
    let cur = leagues.find((l) => l.id === this.leagueId);
    if (!cur || (this.clubId && this._follow)) cur = leagues.find((l) => l.clubs.has(this.clubId)) || cur || leagues[0];
    this._follow = false;
    this.leagueId = cur.id;
    const ink = (c) => (window.PyramidScreenColor ? PyramidScreenColor.ink(c) : '#fff');
    const car = (cls, pills) => `<div class="pt-car ${cls}"><button class="nav" data-pt-nav="-1">‹</button><div class="strip">${pills}</div><button class="nav" data-pt-nav="1">›</button></div>`;
    const lgs = leagues.map((l) => `<button class="${l.conf ? 'conf' : ''} ${l.id === cur.id ? 'on' : ''}" data-pt-league="${l.id}"${l.color ? ` style="--cc:${esc(l.color)}; --cc-fg:${ink(l.color)}"` : ''}>${esc(l.name)}</button>`).join('');
    const clubs = [...cur.clubs].sort((a, b) => a[1].localeCompare(b[1]))
      .map(([id, name]) => `<button class="${id === this.clubId ? 'on' : ''}" data-pt-club="${id}">${esc(name)}</button>`).join('');
    return car('leagues', lgs) + car('clubs', clubs);
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    this._follow = true;
    const club = this.clubId && model.clubs.find((c) => c.id === this.clubId);
    return `
      <div class="pt-picker">${this._pickerHtml(model, confs || [])}</div>
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

  // Show on screen: the pro leagues above the APSL, on unless switched off.
  features() { return [{ key: 'pro', tier: 'feature_pro', def: true }]; }

  // Above the APSL: the professional divisions (mig 1788, owner 11/24
  // "show that above the apsl its pro"), top first — wording rows
  // path_pro_1… = 'label|league;league'.  A dashed step, not an arrow: no
  // club goes up on results, the note says how one does.
  _proHtml() {
    if (!this.screen.feature('pro', true)) return '';
    const esc = (t) => this._esc(t);
    const tiers = [];
    for (let i = 1; i <= 9; i++) {
      const row = this._copy(`path_pro_${i}`);
      if (!row) break;
      const [label, names] = row.split('|');
      tiers.push(`<div class="pt-pro-tier"><span class="lbl">${esc(label)}</span><div class="lgs">${(names || '').split(';').map((n) => `<span class="pt-pro-lg">${esc(n.trim())}</span>`).join('')}</div></div>`);
    }
    if (!tiers.length) return '';
    // The standards themselves (mig 1790): wording row 'label|url' → U.S. Soccer's page.
    const [linkLabel, linkUrl] = (this._copy('path_pro_link') || '').split('|');
    const link = /^https:\/\//.test(linkUrl || '') ? `<a class="pt-pro-link" href="${esc(linkUrl)}" target="_blank" rel="noopener">${esc(linkLabel)}</a>` : '';
    // The document sits ON the line between the pro leagues and the APSL
    // (mig 1794, owner: "it currently acts as a block but should act as a
    // bridge"): dashed line, the PLS box with its caption, dashed line.
    const bridge = this._copy('path_pro_bridge');
    return `<div class="pt-pro"><h4>${esc(this._copy('path_pro_title'))}</h4>${tiers.join('')}
      <div class="pt-pro-gap"></div>
      <div class="pt-pro-doc">${link}${bridge ? `<div class="why">${esc(bridge)}</div>` : ''}
        <div class="pt-pro-note">${esc(this._copy('path_pro_note'))}</div></div>
      <div class="pt-pro-gap"></div></div>`;
  }

  _clubHtml(model, club) {
    const esc = (t) => this._esc(t);
    // Each team plays at its own ground (mig 855) — named with the team.
    const teams = (club.divisions || []).map((id) => model.division(id)).filter(Boolean).map((d) => {
      const team = (d.teams || []).find((t) => t.club === club.name);
      const pl = team && model.place(team.id);
      const venue = pl ? [pl.venue_name, pl.venue].filter(Boolean).join(' · ') : this._copy('map_at_league');
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
      // …and what is below it (mig 1787, owner 11/24 "also show what is
      // below them … in feeders etc"): the tables feeding this one, a row
      // per level, the same arrows pointing up into it.
      const levels = model.below(d.id);
      const n = levels.reduce((k, l) => k + l.length, 0);
      const below = !n ? '' : `
        <div class="pt-below"><h4>${esc(this._copy('path_below', { table, n }))}</h4>
          ${levels.map((l) => `<div class="pt-up"></div><div class="pt-level">${l.map((x) => this._nodeHtml(model, `d${x.id}`, club)).join('')}</div>`).join('')}</div>`;
      return `<div class="pt-team"><h3>${esc(head)}</h3><div class="pt-venue">${esc(venue)}</div>${best != null ? this._proHtml() : ''}<div class="pt-routes">${cols}</div>${below}</div>`;
    }).join('');
    return `
      <h2 class="pt-club">${esc(club.name)}</h2>
      ${teams}`;
  }

  mount(root, model, confs) {
    this.root = root; this.model = model; this.confs = confs || [];
    this._reveal();
    if (root._pt) return;
    root._pt = true;
    root.addEventListener('click', (e) => {
      const nav = e.target.closest('[data-pt-nav]');
      if (nav) { const st = nav.parentElement.querySelector('.strip'); st.scrollLeft += Number(nav.dataset.ptNav) * st.clientWidth * 0.8; return; }
      const lg = e.target.closest('[data-pt-league]');
      if (lg) { this.leagueId = Number(lg.dataset.ptLeague); this._redrawPicker(); return; }
      const cb = e.target.closest('[data-pt-club]');
      if (cb) { const club = this.model.clubs.find((c) => c.id === Number(cb.dataset.ptClub)); if (club) { e.stopPropagation(); this.onClub(club, true); } }
    });
  }

  _redrawPicker() {
    const box = this.root && this.root.querySelector('.pt-picker');
    if (!box) return;
    const left = [...box.querySelectorAll('.strip')].map((s) => s.scrollLeft);
    box.innerHTML = this._pickerHtml(this.model, this.confs);
    // The league strip keeps its place; the lit pills are slid into sight.
    const st = box.querySelector('.leagues .strip');
    if (st) { st.style.scrollBehavior = 'auto'; st.scrollLeft = left[0] || 0; st.style.scrollBehavior = ''; }
    this._reveal();
  }
  _reveal() {
    if (!this.root) return;
    this.root.querySelectorAll('.pt-picker .strip').forEach((st) => {
      const on = st.querySelector('button.on');
      if (!on) return;
      const a = on.offsetLeft - st.offsetLeft, b = a + on.offsetWidth;
      if (a < st.scrollLeft || b > st.scrollLeft + st.clientWidth) st.scrollLeft = Math.max(0, a - 40);
    });
  }

  // A club picked — from the strips here (stay on that league) or from the
  // page's ☰ Find a club (the strips move to its league).
  onClub(club, fromStrip) {
    this.clubId = club.id;
    try { localStorage.setItem('apsl-pyramid-club', String(club.id)); } catch (_) { /* private mode */ }
    const body = this.root && this.root.querySelector('.pt-body');
    if (body) body.innerHTML = this._clubHtml(this.model, club);
    this._follow = !fromStrip;
    this._redrawPicker();
  }

  onResize() {}
  unmount() {}
}
window.PyramidPathView = PyramidPathView;
