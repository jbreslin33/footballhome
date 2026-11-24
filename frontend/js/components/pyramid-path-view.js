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
// list by league name then teams under them in a carousel" · "all the
// conferences are back as pills lol. we need like a drop down"): ONE line
// on top — a league drop-down (each lit conference, then ↳ the leagues
// feeding it) and, beside it, the picked league's clubs on a strip that
// slides sideways (‹ › or a swipe).  A tap on a club draws its way up.
// ☰ Find a club still works and moves the line to that club's league.
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
      .pt-car .strip button { font-weight:600; font-size:0.82rem; padding:5px 12px; }
      .pt-car select { flex:0 0 auto; max-width:46vw; min-height:0; padding:6px 10px; border-radius:999px; font-weight:700; font-size:0.85rem; }
      .pt-car .nav { flex:0 0 auto; min-height:0; min-width:0; width:30px; height:30px; border-radius:50%; cursor:pointer; font-size:1rem; line-height:1;
                     border:1px solid var(--border-color, #374151); background:transparent; color:inherit; }
      .pt-team { margin:0 0 26px; }
      /* The team's own table carries its bubble: club, where it stands, its ground — linked to the table by the pointer (owner 11/24 "this all should be nearer to the team in question … a linked bubble or box"). */
      .pt-own { position:relative; }
      .pt-bubble { position:absolute; left:calc(100% + 16px); top:6px; width:250px; box-sizing:border-box; text-align:left;
                   border:3px solid #0b1220; border-radius:22px; padding:10px 14px; background:#fff; color:#0b1220; box-shadow:4px 4px 0 rgba(0,0,0,0.55); }
      /* a comic-book speech bubble (owner: "like a comic book"): white, inked, its tail on the table */
      .pt-bubble::before { content:""; position:absolute; left:-18px; top:14px; border-top:4px solid transparent; border-bottom:16px solid transparent; border-right:18px solid #fff; }
      .pt-bubble b { display:block; font-size:1rem; }
      .pt-bubble .st { font-size:0.85rem; font-weight:700; margin-top:2px; }
      .pt-bubble .vn { font-size:0.78rem; opacity:0.75; margin-top:4px; }
      .pt-bubble.alone { position:static; margin:0 auto 12px; }
      .pt-bubble.alone::before { display:none; }
      @media (max-width: 900px) {
        .pt-own { display:flex; flex-direction:column-reverse; align-items:center; gap:18px; }
        .pt-bubble { position:relative; left:auto; top:auto; width:min(250px, 100%); }
        .pt-bubble::before { left:calc(50% - 9px); top:auto; bottom:-16px; border:0; border-left:4px solid transparent; border-right:16px solid transparent; border-top:16px solid #fff; }
      }
      .pt-routes { display:flex; gap:28px; justify-content:center; flex-wrap:wrap; align-items:flex-start; }
      .pt-route { display:flex; flex-direction:column; align-items:center; }
      .pt-up { width:0; height:0; border-left:9px solid transparent; border-right:9px solid transparent; border-bottom:14px solid #64748b; margin:6px 0; }
      .pt-conf { border:2px solid #2563eb; border-radius:14px; padding:8px 10px; background:rgba(37,99,235,0.08); text-align:center; }
      .pt-conf h4 { margin:0 0 6px; }
      .pt-below { display:flex; flex-direction:column; align-items:center; margin-top:14px; padding-top:12px; border-top:1px dashed rgba(148,163,184,0.3); }
      .pt-below h4 { margin:0 0 2px; font-size:0.9rem; opacity:0.85; text-align:center; }
      .pt-level { display:flex; gap:14px; justify-content:center; flex-wrap:wrap; align-items:flex-start; }
      .pt-team { position:relative; }
      .pt-team > .fc-pro { margin-bottom:70px; }
      /* The APSL level: every lit conference on one sliding line, the team's own in full, the rest dimmed (owner 11/24 "show the other apsl confs but the focus should be on the team in question"). */
      .pt-confs { display:flex; gap:28px; align-items:flex-start; overflow-x:auto; max-width:calc(100vw - 48px); padding:4px 2px 10px; scrollbar-width:thin; }
      .pt-confs .pt-conf { flex:0 0 auto; opacity:0.45; }
      .pt-confs .pt-conf.me { opacity:1; }
      .pt-route, .pt-below { position:relative; z-index:1; }
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
    const lgs = leagues.map((l) => `<option value="${l.id}"${l.id === cur.id ? ' selected' : ''}>${l.conf ? '' : '↳ '}${esc(l.name)}</option>`).join('');
    const clubs = [...cur.clubs].sort((a, b) => a[1].localeCompare(b[1]))
      .map(([id, name]) => `<button class="${id === this.clubId ? 'on' : ''}" data-pt-club="${id}">${esc(name)}</button>`).join('');
    return `<div class="pt-car"><select data-pt-league>${lgs}</select>
      <button class="nav" data-pt-nav="-1">‹</button><div class="strip">${clubs}</div><button class="nav" data-pt-nav="1">›</button></div>`;
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    this._follow = true; this._m = model; this.confs = confs || [];
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
      const one = (c, me) => {
        if (me) return `<div class="pt-conf me"><h4>${esc(conf.name)}</h4><div class="fc-cell">${tables}</div></div>`;
        const oc = model.layout([c]).columns[0];
        if (!oc) return '';
        return `<div class="pt-conf"><h4>${esc(c.name)}</h4><div class="fc-cell">${oc.top.map((d) => {
          const part = model.confTableTitle(oc, d);
          return this.flow.tableHtml(model, d, part ? esc(part) : '', '', '', { club: club.name });
        }).join('')}</div></div>`;
      };
      const all = (this.confs || []).some((c) => c.id === conf.id) ? this.confs : [conf];
      return `<div class="pt-confs">${all.map((c) => one(c, c.id === conf.id)).join('')}</div>`;
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

  // Above the APSL: the professional divisions with their tables and the
  // standards box (PyramidFlowView.proHtml, mig 1833) — on unless switched
  // off in ☰ Show on screen.
  _proHtml() {
    return this.screen.feature('pro', true) ? `<svg class="fc-links"></svg>${this.flow.proHtml(this.model || this._m)}` : '';
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
      const bubble = (cls) => `<div class="pt-bubble ${cls}"><b>${esc(club.name)}</b><div class="st">${esc(head)}</div><div class="vn">${esc(venue)}</div></div>`;
      // Top of the pyramid first: each route reversed, arrows pointing up.
      // The team's own table is the foot of every route; the rightmost
      // one carries the bubble (free space beside it).
      const cols = routes.map((r, ri) => `
        <div class="pt-route">${[...r].reverse().map((n, i, a) => {
          const box = this._nodeHtml(model, n, club);
          return i === a.length - 1 ? `<div class="pt-own">${box}${ri === routes.length - 1 ? bubble('') : ''}</div>` : box;
        }).join('<div class="pt-up"></div>')}</div>`).join('');
      // …and what is below it (mig 1787, owner 11/24 "also show what is
      // below them … in feeders etc"): the tables feeding this one, a row
      // per level, the same arrows pointing up into it.
      const levels = model.below(d.id);
      const n = levels.reduce((k, l) => k + l.length, 0);
      const below = !n ? '' : `
        <div class="pt-below"><h4>${esc(this._copy('path_below', { table, n }))}</h4>
          ${levels.map((l) => `<div class="pt-up"></div><div class="pt-level">${l.map((x) => this._nodeHtml(model, `d${x.id}`, club)).join('')}</div>`).join('')}</div>`;
      return `<div class="pt-team">${routes.length ? '' : bubble('alone')}${best != null ? this._proHtml() : ''}<div class="pt-routes">${cols}</div>${below}</div>`;
    }).join('');
    return teams;
  }

  mount(root, model, confs) {
    this.root = root; this.model = model; this.confs = confs || [];
    this._reveal();
    this._links();
    if (root._pt) return;
    root._pt = true;
    root.addEventListener('change', (e) => this._onLeague(e));
    root.addEventListener('click', (e) => {
      const nav = e.target.closest('[data-pt-nav]');
      if (nav) { const st = nav.parentElement.querySelector('.strip'); st.scrollLeft += Number(nav.dataset.ptNav) * st.clientWidth * 0.8; return; }
      const cb = e.target.closest('[data-pt-club]');
      if (cb) { const club = this.model.clubs.find((c) => c.id === Number(cb.dataset.ptClub)); if (club) { e.stopPropagation(); this.onClub(club, true); } }
    });
  }

  _onLeague(e) {
    const lg = e.target.closest('select[data-pt-league]');
    if (lg) { this.leagueId = Number(lg.value); this._redrawPicker(); }
  }

  // The team's conference slid to the middle of its line, then the dashed
  // lines: that conference → the standards box → Division III.
  _links(focus) {
    if (!this.root) return;
    this.root.querySelectorAll('.pt-confs').forEach((st) => {
      const me = st.querySelector('.pt-conf.me');
      if (me && !st._set) st.scrollLeft = me.offsetLeft - st.offsetLeft - (st.clientWidth - me.offsetWidth) / 2;
      if (!st._set) { st._set = true; st.addEventListener('scroll', () => this._links(), { passive: true }); }
    });
    this.root.querySelectorAll('.pt-team').forEach((t) => this.flow.drawProLinks(t, '.pt-conf.me'));
    // Focus: the picked team's own table (and its bubble) into the middle of the window.
    const own = focus && this.root.querySelector('.pt-own');
    if (own) own.scrollIntoView({ block: 'center', behavior: 'smooth' });
  }

  _redrawPicker() {
    const box = this.root && this.root.querySelector('.pt-picker');
    if (!box) return;
    box.innerHTML = this._pickerHtml(this.model, this.confs);
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
    this._links(true);
  }

  onResize() { this._links(); }
  unmount() {}
}
window.PyramidPathView = PyramidPathView;
