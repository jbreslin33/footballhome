// pyramid-shape-view.js — #apsl-pyramid "Spin the pyramid": the whole U.S. game as a 3D pyramid
// you turn, a view over PyramidModel (mig 1849; the page opens on it).
//
// Owner 2026-11-24: "is a flat 2d view the best way to show all of this? i feel like a
// spinning pyramind would be way to go? … each side is a 'league'" · "separate pyraminds" (one
// per calendar) · "2d view of standings for that league off to side with line to face".
//
// WHAT IS ON IT.  One LEVEL per step of the game, top first: the cups and pro divisions above
// the APSL (what the pills leave on), then the APSL itself — its conferences, then each row of
// leagues that feed them, each row a level — and each national league beside it on a side of
// its own.  One league, one side (owner: "no need to draw somethnig on multiple sides. mls side
// shouod be apsl side … that is why we put them on our 'face'"): the APSL's side carries the
// whole column from the Club World Cup down; the other sides of a level are bare.  A league
// switched off leaves; an emptied level goes and the numbers below move up.
//
// HOW IT IS DRAWN.  The page's own boxes (flow.proLeagueHtml / chartHtml / besideLeagueHtml) are
// laid out flat and hidden, measured — where each row of a chart starts, every table, every
// row with its zone colour — and handed as data to PyramidSolid (pyramid-solid-view.js, three.js),
// which draws the solid with the tables on it and the promotion / relegation arrows.  Seven
// builds were tried that day (four CSS-3D, three solid); this is the one kept (owner: "last one
// is winnner as far as resourcess … drop the other versions").  ▦ 2D chart is the flat view.
//
// CALENDARS (season_calendars: the fall–spring game, the U23 summer leagues, spring-to-fall): any
// number at once; a league button on the rail switches on its calendar when it is off (the top row
// of calendar pills went 2026-11-25: "get rid of everyting at top").  The pyramid holds the
// leagues of every calendar on; never none.  On a shared level the APSL's calendar's league comes
// first, so it stands on the APSL's face.
//
// A tap on a level opens its league flat in the panel on the right, scrolled to that level, a
// line tying the panel to the level wherever it has turned to (dashed when it faces away).
class PyramidShapeView {
  constructor(screen, flow) {
    this.screen = screen; this.flow = flow; this.fill = true;
    this.picked = null;                              // the league key open in the panel
    // which calendars are on the pyramid — any number at once (owner 2026-11-24: "the toggles should
    // add allow for multi selectet"); none stored = the first.  The old one-calendar pick carries over.
    this.cals = [];
    try {
      const many = JSON.parse(localStorage.getItem('apsl-shape-cals') || 'null');
      const one = localStorage.getItem('apsl-shape-cal');
      this.cals = Array.isArray(many) ? many : one ? [one] : [];
    } catch (_) { /* private mode */ }
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .sh-stage { position:absolute; inset:0; overflow:hidden; cursor:grab; touch-action:none; user-select:none; }
      .sh-stage.dragging { cursor:grabbing; }
      .sh-empty { opacity:0.6; border-style:dashed; min-width:320px; text-align:center; }
      .sh-flat { position:absolute; left:0; top:0; visibility:hidden; pointer-events:none; }
      .sh-flat > div { width:max-content; padding:10px; }
      .sh-flat .fc-field ul, .sh-panel .fc-field ul { columns:3; column-gap:26px; width:600px; }
      /* THE RAIL (owner 2026-11-25: "we need on right not bottom. the controls"): one button per league,
         the picked one's levels under it, zoom at the foot; nothing across the top any more */
      .sh-rail { position:absolute; right:10px; top:10px; bottom:10px; width:132px; z-index:8; display:flex; flex-direction:column; gap:5px; overflow:auto;
                 padding:8px; box-sizing:border-box; border-radius:12px; background:rgba(15,23,42,0.82); border:1px solid var(--border-color, #374151); }
      .sh-rail button { min-height:0; min-width:0; cursor:pointer; color:inherit; font-weight:800; border:1px solid var(--border-color, #374151); background:rgba(30,41,59,0.9); }
      .sh-rail .lg { width:100%; padding:7px 8px; border-radius:9px; font-size:0.9rem; text-align:left; }
      .sh-rail .lg.on { background:var(--primary-color, #2563eb); border-color:transparent; color:#fff; }
      .sh-rail .lg.off { opacity:0.5; border-style:dashed; }   /* not on the pyramid now: pressing it brings it */
      .sh-rail .lvs { display:flex; flex-wrap:wrap; gap:4px; margin:2px 0 6px; }
      .sh-rail .lvs .h { width:100%; font-size:0.66rem; opacity:0.7; font-weight:700; text-transform:uppercase; letter-spacing:0.04em; }
      .sh-rail .lv { width:32px; height:30px; border-radius:8px; font-size:0.85rem; }
      .sh-rail .lv.cup { width:auto; padding:0 7px; font-size:0.7rem; }
      .sh-rail .lv.on { background:#fbbf24; border-color:transparent; color:#0b1220; }
      .sh-rail .all { width:100%; padding:5px 8px; border-radius:9px; font-size:0.72rem; font-weight:700; margin-top:4px; }
      .sh-rail .zm { margin-top:auto; display:flex; gap:5px; }
      .sh-rail .zm button { flex:1; height:32px; border-radius:9px; font-size:1rem; }
      .sh-rail .hint { font-size:0.62rem; opacity:0.6; line-height:1.3; }
      @media (max-width: 700px) { .sh-panel { right:112px; width:auto; left:10px; } .sh-rail { width:96px; padding:6px; } .sh-rail .lg { font-size:0.8rem; padding:6px; } .sh-rail .hint { display:none; } }
      .sh-panel { position:absolute; right:150px; top:10px; bottom:10px; width:min(460px, 42%); z-index:7; display:flex; flex-direction:column;
                  background:var(--bg-color, #0b1220); border:2px solid #fbbf24; border-radius:12px; box-shadow:0 8px 30px rgba(0,0,0,0.6); }
      .sh-panel[hidden] { display:none; }
      .sh-panel .ph { display:flex; align-items:center; gap:8px; padding:8px 10px; border-bottom:1px solid #334155; font-weight:800; }
      .sh-panel .ph span { flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
      .sh-panel .ph button { min-height:0; min-width:0; padding:3px 10px; border-radius:999px; cursor:pointer; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; }
      .sh-panel .pb { flex:1; overflow:auto; padding:10px; cursor:auto; user-select:text; }
      .sh-panel .pb > * { margin:0; }
      .sh-line { position:absolute; inset:0; z-index:5; pointer-events:none; overflow:visible; }`;
  }

  // The flow view's switches, less its calendar pills: here a calendar is a pyramid of its own.
  features() { return this.flow.features().filter((f) => !f.key.startsWith('cal-')); }

  _calendars(model) { return model.data.calendars || []; }
  // THE RAIL'S LEAGUES (owner 2026-11-24: "not seeing upsl"; 11/25 on the right, by league name):
  // a button for EVERY side the data names (pyramid_side), shown or not.  A side not on the pyramid now (its calendar off, its league switched off) is
  // dimmed; pressing it switches on what it needs and flies there.
  _goList(model) {
    const cals = this._calsOn(model), sides = new Map();
    const add = (side, name, rank, cal, keys) => {
      if (side == null) return;
      const shown = cals.has(cal) && keys.every((k) => this.screen.feature(k, true));
      const g = sides.get(side);
      if (!g || rank < g.rank) sides.set(side, { side, name, rank, cal, keys, shown: shown || (g ? g.shown : false) });
      else if (shown) g.shown = true;
    };
    const root = model.comp(model.data.root_id);
    if (root) add(model.data.side, model.label(root), 0, model.data.calendar, []);
    for (const t of model.pro || []) for (const l of t.leagues)
      if (l.feeds == null) add(l.side, l.name, t.standards === false ? 2 : 1, this._calOf(model, l), [`lg-${l.id}`, t.beside ? 'open' : 'pro']);
    return [...sides.values()].sort((a, b) => a.side - b.side);
  }

  // The calendars switched on: those picked that still exist, else the first.
  _calsOn(model) {
    const all = this._calendars(model).map((c) => c.code);
    const on = this.cals.filter((c) => all.includes(c));
    return new Set(on.length ? on : all.slice(0, 1));
  }
  // A league's calendar: its own, else its upper league's.
  _calOf(model, l) {
    if (l.calendar) return l.calendar;
    const up = l.feeds == null ? null : (model.pro || []).flatMap((t) => t.leagues).find((x) => x.id === l.feeds);
    return up ? this._calOf(model, up) : null;
  }

  // ── what is on the shape ──────────────────────────────────────────────
  // → [{ sides:[{ key, title, html, chart? }], standards }] top first.
  _levels(model, confs) {
    const flow = this.flow, levels = [], cals = this._calsOn(model), home = model.data.calendar;
    // the leagues of the calendars switched on, each also on its own pill (the flat view's calendar pills do not apply);
    // two calendars on one level: the APSL's calendar first, so its league stands on the APSL's face
    const mine = (l) => cals.has(this._calOf(model, l)) && this.screen.feature(`lg-${l.id}`, true);
    const first = (a, b) => (this._calOf(model, a) === home ? 0 : 1) - (this._calOf(model, b) === home ? 0 : 1);
    const every = (model.pro || []).map((t) => ({ ...t, leagues: t.leagues.filter(mine).sort(first) }));
    const tiers = every.filter((t) => t.leagues.length);
    if (this.screen.feature('pro', true)) {
      // A pro DIVISION keeps its step even with no league on this calendar, when there is a
      // division above and below it that has one (owner 2026-11-24: "usl champtionsip and usl
      // league one are spring to fall so if that is not selected then level under mls is empty
      // right? and level 3 would only have mls next pro") — MLS NEXT Pro stays a Division III
      // league, it does not slide up under MLS.  A cup (reached by results) with nothing on
      // simply goes, and the rest move up.
      const divisions = every.filter((t) => !t.beside && t.standards !== false);
      const top = divisions.findIndex((t) => t.leagues.length), last = divisions.length - 1 - [...divisions].reverse().findIndex((t) => t.leagues.length);
      const kept = new Set(top < 0 ? [] : divisions.slice(top, last + 1).map((t) => t.tier));
      // an empty division step stands on the side most pro divisions use (the MLS column)
      const count = new Map();
      for (const t of divisions) for (const l of t.leagues) if (l.side != null) count.set(l.side, (count.get(l.side) || 0) + 1);
      const proSide = [...count].sort((a, b) => b[1] - a[1]).map((x) => x[0])[0] ?? null;
      for (const t of every.filter((x) => !x.beside)) {
        if (t.leagues.length) levels.push({ standards: t.standards !== false, tier: t.tier, sides: t.leagues.map((l) => ({ key: `lg-${l.id}`, title: l.name, side: l.side, html: flow.proLeagueHtml(l, t) })) });
        else if (kept.has(t.tier)) levels.push({ standards: true, tier: t.tier, sides: [{ key: `tier-${t.tier}`, title: t.label, side: proSide,
          html: `<div class="fc-pro-lg sh-empty"><h2>${this._esc(t.label)}</h2><div class="fc-meta">${this._esc(this._copy('shape_empty_level'))}</div></div>` }] });
      }
    }
    const bottom = [];
    if (cals.has(home)) {
      const root = model.comp(model.data.root_id);
      bottom.push({ key: 'root', title: root ? model.label(root) : '', side: model.data.side, html: flow.chartHtml(model, confs), chart: true });
    }
    if (this.screen.feature('open', true))
      for (const t of tiers.filter((x) => x.beside))
        for (const l of t.leagues.filter((x) => x.feeds == null)) bottom.push({ key: `lg-${l.id}`, title: l.name, side: l.side, html: flow.besideLeagueHtml(model, { ...l, label: t.label }) });
    // the APSL and the leagues beside it are one division (Division IV); their feeder rows count on from it
    const beside = (model.pro || []).filter((t) => t.beside).map((t) => t.tier);
    const std = (model.pro || []).filter((t) => !t.beside && t.standards !== false).map((t) => t.tier);
    const base = beside.length ? Math.min(...beside) : std.length ? Math.max(...std) + 1 : 1;
    if (bottom.length) levels.push({ standards: false, tier: base, sides: bottom });
    return levels;
  }

  html(model, confs) {
    this.flow._model = model;
    this._lv = this._levels(model, confs);
    const esc = (t) => this._esc(t);
    return `
      <div class="sh-stage">
        <div class="sh-flat">${this._lv.map((lv, i) => lv.sides.map((s, k) => `<div data-flat="${i}-${k}">${s.html}</div>`).join('')).join('')}</div>
        <svg class="sh-line"></svg>
        <div class="sh-panel" hidden><div class="ph"><span></span><button data-sh="close">${esc(this._copy('shape_close'))}</button></div><div class="pb"></div></div>
        <div class="sh-rail">${this._railHtml(model)}</div>
      </div>`;
  }

  // ── measure it flat, then hand it to the solid ──────────────────────
  mount(root, model, confs) {
    this.root = root;
    const stage = root.querySelector('.sh-stage'), flat = root.querySelector('.sh-flat');
    if (!stage) return;
    const L = this._lv, n = L.length;
    this._sides = [];
    this._wire(stage);
    if (!n) return;
    // every side's box, and where each of a league's own levels starts down it: its first
    // division, then every row of leagues that feed it (the chart's rows; a national league's
    // regional leagues)
    const natural = L.map((lv, i) => lv.sides.map((s, k) => {
      const el = flat.querySelector(`[data-flat="${i}-${k}"]`);
      const top = el.getBoundingClientRect().top, rows = [];
      const at = (node, step) => { if (node) rows.push({ y: node.getBoundingClientRect().top - top, step }); };
      if (s.chart) {
        at(el.querySelector('.fc-conf'), 0);
        const seen = new Set();
        el.querySelectorAll('.fc-cell.lv[data-level]').forEach((c) => { const lvl = Number(c.dataset.level); if (!seen.has(lvl)) { seen.add(lvl); at(c, lvl); } });
      } else if (i === n - 1) {
        at(el.querySelector('.fc-cell'), 0);
        at(el.querySelector('.fc-under') || el.querySelector('.fc-loose-hd'), 1);
      }
      return { ...s, el, html: el.innerHTML, rows };
    }));
    // six sides (owner 2026-11-24: "make six sides and put mls stuff by itself and our pyramind apsl by
    // itself with casa etc"), more if the data asks for a higher side or a level has more leagues
    const slots = Math.max(6, ...L.flatMap((lv) => lv.sides.map((x) => (x.side ?? -1) + 1)), ...L.map((lv) => lv.sides.length));
    this._edges = this._calsOn(model).has(model.data.calendar) ? model.layout(confs).edges : [];   // the APSL chart's links, when its calendar is up
    this._mountSolid(stage, natural, slots);
    flat.remove();
  }

  unmount() { if (this._solid) { this._solid.dispose(); this._solid = null; } }
  onResize() { this._drawLine(); }

  // One row per level, top first; a row's cells are the leagues on it, each on its own side,
  // with every table on it (read from the flat boxes) — the bottom ring's leagues cut into
  // bands: first division, then each row of leagues that feed it.
  _mountSolid(stage, natural, slots) {
    const L = this._lv, n = L.length, rows = [];
    this._sides = [];
    const count = (el, y0, y1) => {   // the tables whose middle is in the band, the clubs in them, the leagues they belong to
      const top = el.getBoundingClientRect().top, names = [], lists = [];
      let tables = 0, clubs = 0;
      const all = [...el.querySelectorAll('.fc-tbl')];
      for (const t of all) {
        if (all.some((o) => o !== t && o.contains(t))) continue;   // counted with the box it sits in
        const r = t.getBoundingClientRect(), mid = (r.top + r.bottom) / 2 - top;
        if (mid < y0 || mid >= y1) continue;
        tables++;
        clubs += t.querySelectorAll('tbody tr, ul li').length;
        const lg = t.querySelector('.lg') || (t.classList.contains('fc-fd') ? t.querySelector('.hd, .fc-meta') : null);
        const name = lg ? lg.textContent.replace(/\s*↗\s*$/, '').trim() : '';
        if (name && !names.includes(name)) names.push(name);
        // every club, table by table (🗻 + teams): the innermost boxes, each under its own name or its holder's
        for (const leaf of [t, ...t.querySelectorAll('.fc-tbl')].filter((x) => !x.querySelector('.fc-tbl'))) {
          const hd = leaf.querySelector('.hd') || t.querySelector('.hd, .fc-meta');
          const teams = [...leaf.querySelectorAll('tbody td.tm, ul li')].map((x) => x.textContent.trim());
          const confBox = leaf.closest('.fc-conf'), confName = confBox ? (confBox.querySelector('h2') || {}).textContent : '';
          let name = hd ? hd.textContent.replace(/\s*↗\s*$/, '').replace(/\s+/g, ' ').trim() : (teams.length ? '' : leaf.textContent.replace(/\s+/g, ' ').trim().slice(0, 60));
          if (confName) name = name ? `${confName.trim()} · ${name}` : confName.trim();   // a conference's table goes by the conference
          // 🗻 + standings: each row in full, with its zone colour (the 2D chart's --zc)
          const rows = [...leaf.querySelectorAll('tbody tr')].map((tr) => {
            const td = [...tr.children], tm = tr.querySelector('td.tm');
            return { pos: (td[0] || {}).textContent, name: tm ? tm.textContent.trim() : '', gp: (td[td.length - 3] || {}).textContent, gd: (td[td.length - 2] || {}).textContent,
                     pts: (td[td.length - 1] || {}).textContent, zc: tr.style.getPropertyValue('--zc').trim() || null };
          }).filter((r) => r.name);
          lists.push({ name, teams, rows, node: leaf.dataset.node || null, conf: confBox ? confBox.dataset.node : null });
        }
      }
      return { tables, clubs, names, lists };
    };
    const sub = (c) => (c.clubs ? this._copy(c.tables > 1 ? 'shape_solid_tables' : 'shape_solid_clubs', { t: c.tables, n: c.clubs }) : '');
    const add = (row, m, slot, level, title, c, y0) => {
      const cell = { slot, key: m.key, title, sub: sub(c), level, num: row.num, y0, tables: c.lists || [] };
      row.cells.push(cell);
      this._sides.push({ id: this._sides.length, key: m.key, title: m.title, html: m.html, level, slot, step: 360 / slots, cell });
    };
    // EACH LEAGUE ON ITS OWN SIDE (pro_leagues.pyramid_side / the root's, mig 1871): the APSL alone on
    // the face, the MLS column, the USL column, the UPSL, the NPSL, the League for Clubs.  A league
    // with no side, or whose side is taken on that level, goes on the next free one.
    const place = (list) => {
      const taken = new Set(), at = new Map();
      for (const m of list) if (m.side != null && m.side < slots && !taken.has(m.side)) { taken.add(m.side); at.set(m, m.side); }
      let free = 0;
      for (const m of list) if (!at.has(m)) { while (taken.has(free)) free++; taken.add(free); at.set(m, free); }
      return at;
    };
    let level = 0;
    L.forEach((lv, i) => {
      if (i < n - 1) {
        const empty = natural[i].every((m) => m.key.startsWith('tier-'));
        const row = { kind: empty ? 'empty' : lv.standards ? 'pro' : 'cup', level, num: lv.standards ? lv.tier : null, cells: [] };
        const at = place(natural[i]);
        natural[i].forEach((m) => add(row, m, at.get(m), level, m.title, empty ? { clubs: 0 } : count(m.el, 0, Infinity), 0));
        rows.push(row); level++;
        return;
      }
      const sides = natural[i].map((m) => {
        const tops = m.rows.slice().sort((p, q) => p.step - q.step).map((r) => r.y);
        const cuts = tops.map((t, k) => (k === 0 ? 0 : Math.max(0, t - (m.chart ? 28 : 6))));
        return { m, bands: cuts.length ? cuts.map((y0, k) => ({ y0, y1: k + 1 < cuts.length ? cuts[k + 1] : Infinity })) : [{ y0: 0, y1: Infinity }] };
      });
      const depth = Math.max(...sides.map((x) => x.bands.length)), at = place(natural[i]);
      for (let k = 0; k < depth; k++) {
        const row = { kind: k ? 'feeder' : 'own', level, num: lv.tier + k, cells: [] };
        sides.forEach((x) => {
          const slot = at.get(x.m);
          const b = x.bands[k];
          if (!b) return;
          const c = count(x.m.el, b.y0, b.y1);
          // a feeder level of several leagues gets no big title — its tables' own yellow headings name
          // them (owner 2026-11-24: "i don't like the size of CASA MA headers. i think if its multi
          // leagus jsut leave it with the yellow conf headers"); one league keeps its name
          const title = !k ? x.m.title : c.names.length === 1 ? c.names[0] : '';
          add(row, x.m, slot, level, title, title ? c : { ...c, clubs: 0 }, b.y0);
        });
        rows.push(row); level++;
      }
    });
    this._banners(rows);
    if (!window.PyramidSolid || !rows.length) return;
    this._solid = new PyramidSolid(stage, rows, slots, {
      level: (num) => (num == null ? this._copy('shape_level_cup') : this._copy('shape_level', { n: num })),
      onMove: () => this._drawLine(),
      onPick: (cell) => { this._solid.face(cell.slot); this._openPanel(cell.key, cell); },
      head: (this._copy('table_head') || '').split(/\s+/).filter(Boolean).slice(-3),
      crown: this._crown || null,
      reserveOf: (node) => {   // 'd23' (Cosmo Division 1 Reserve) → 'd22' — PyramidModel.reserveOf
        const M = this.flow && this.flow._model, id = node && node[0] === 'd' ? M && M.reserveOf(Number(node.slice(1))) : null;
        return id ? `d${id}` : null;
      },
    }, { edges: this._edges || [],
         colors: { promotion: this.flow._model.kindColor('promotion'), relegation: this.flow._model.kindColor('relegation') } });
    this._rows = rows; this._renderRail();
    const was = this.picked && this._sides.find((s) => s.key === this.picked);
    this._solid.start().then(() => {
      if (was && this._solid) this._openPanel(was.key, was.cell); else this.picked = null;
      if (this._goSide != null && this._solid) { this._go(this._goSide, this._goRow); this._goSide = this._goRow = null; }   // a rail button asked for a side that was not built yet
    });
  }

  // ── THE RAIL (owner 2026-11-25) ────────────────────────────────────
  // "get all the controls should be names of leagus to go to their pyramdid. Mls, usl, apsl, npsl,
  // upsl, league for clubs(lfc) … as soon as you hit a button for league or leavel it snaps there".
  // One button per side (shape_side_<n> names it, shape_side_order orders them), the picked one's
  // levels under it by division number, Whole pyramid, zoom.  A drag still spins it (owner: "keep the
  // mouse rotatons for coolmess factor"); a press snaps it back.
  _railSides(model) {
    const go = this._goList(model), order = (this._copy('shape_side_order') || '').split(/\s+/).filter(Boolean).map(Number);
    const rank = (g) => { const i = order.indexOf(g.side); return i < 0 ? 100 + g.side : i; };
    return go.map((g) => ({ ...g, label: this._copy(`shape_side_${g.side}`) || g.name })).sort((a, b) => rank(a) - rank(b));
  }
  _pickedSide(model) {
    const sides = this._railSides(model).map((g) => g.side);
    if (this.side == null) { const kept = Number(localStorage.getItem('apsl-shape-side')); this.side = localStorage.getItem('apsl-shape-side') != null && sides.includes(kept) ? kept : model.data.side; }
    return this.side;
  }
  // a side's levels, top first: { row, num } — the rows that carry a league on that side
  _sideRows(side) { return (this._rows || []).filter((r) => r.cells.some((c) => c.slot === side)).map((r) => ({ row: r.level, num: r.num })); }
  _railHtml(model) {
    const esc = (t) => this._esc(t), on = this._pickedSide(model);
    const lvs = (side) => {
      const list = this._sideRows(side);
      if (!list.length) return '';
      return `<div class="lvs"><span class="h">${esc(this._copy('shape_rail_levels'))}</span>${list.map((x) =>
        `<button class="lv ${x.num == null ? 'cup' : ''} ${this.row === x.row ? 'on' : ''}" data-sh-row="${x.row}">${esc(x.num == null ? this._copy('shape_level_cup') : x.num)}</button>`).join('')}</div>`;
    };
    return this._railSides(model).map((g) => `<button class="lg ${g.side === on ? 'on' : ''} ${g.shown ? '' : 'off'}" data-sh-side="${g.side}">${esc(g.label)}</button>${g.side === on && g.shown ? lvs(g.side) : ''}`).join('')
      + `<button class="all" data-sh="fit">${esc(this._copy('shape_rail_all'))}</button>
      <div class="zm"><button data-sh="out" title="${esc(this._copy('zoom_out'))}">−</button><button data-sh="in" title="${esc(this._copy('zoom_in'))}">+</button></div>
      <div class="hint">${esc(this._copy('shape_hint_solid'))}</div>`;
  }
  _renderRail() { const r = this.root && this.root.querySelector('.sh-rail'); if (r && this.flow._model) r.innerHTML = this._railHtml(this.flow._model); }
  // snap to a side — the whole of its own levels, or one level of it
  _go(side, row) {
    this.side = side; this.row = row == null ? null : row;
    try { localStorage.setItem('apsl-shape-side', String(side)); } catch (_) { /* private mode */ }
    this._renderRail();
    if (!this._solid) return;
    if (row == null) this._solid.focus(side); else this._solid.focus(side, [row]);
  }

  // THE HEADER over each league's pyramid (owner 2026-11-25: "we need to show at top of pyramind the
  // total amount of clubs in the pyrmaid and total levels. for apsl e.g. this header would go right
  // above level 4"): on the top level of every side with a league, "<league> pyramid · N clubs ·
  // M levels" — clubs counted once each across all that side's tables, levels = its numbered steps.
  // CLUBS AND TEAMS (owner 2026-11-25: "we should count 2nd teams as anther team in toal temas but not
  // another club. try to calc that best you can with fuzzy logic"): every table row is a team (the same
  // team twice counts once); its club is, best first —
  //   1. the club the APSL data already ties it to (pyramid teams carry club_id: "Oaklyn United FC II"
  //      → Oaklyn United FC, "PFA APSL" → Patuxent Football Athletics);
  //   2. else its name boiled down: accents, punctuation, FC / SC / Club / Soccer … words dropped, and
  //      a second-team ending (II, 2, B, Reserves, U23, Academy …) cut off — matched against every
  //      club already seen, by name or a known club's own name;
  //   3. else, only when a second-team ending was cut, a known club whose boiled name starts or ends
  //      the same way ("Whitecaps FC 2" → Vancouver Whitecaps FC), so long as it is one club only.
  static NOISE = new Set(['fc', 'sc', 'afc', 'cf', 'ac', 'sfc', 'club', 'soccer', 'futbol', 'football', 'the', 'de', 'cd', 'fk', 'sk']);
  static SECOND = new Set(['ii', 'iii', '2', '3', 'b', 'c', 'reserves', 'reserve', 'res', 'u23', 'u21', 'u20', 'u19', 'academy', 'development', 'dev', '2nd', 'sbu']);
  _boil(name) {
    const words = String(name || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()
      .replace(/\bu-(\d\d)\b/g, 'u$1').replace(/[^a-z0-9]+/g, ' ').trim().split(' ').filter(Boolean);
    let cut = false;
    while (words.length > 1 && PyramidShapeView.SECOND.has(words[words.length - 1])) { words.pop(); cut = true; }
    const core = words.filter((w) => !PyramidShapeView.NOISE.has(w));
    return { club: (core.length ? core : words).join(' '), team: words.join(' ') + (cut ? ' #2' : ''), cut };
  }
  _tally(cells) {
    const M = this.flow && this.flow._model, teams = new Set(), clubs = new Set(), alias = new Map();
    const named = [];
    for (const c of cells) for (const t of c.tables || []) {
      const div = M && t.node && t.node[0] === 'd' ? M.division(Number(t.node.slice(1))) : null;
      if (div && div.teams && div.teams.length) {
        for (const tm of div.teams) {
          const key = tm.club_id ? `c${tm.club_id}` : `n${this._boil(tm.club || tm.name).club}`;
          teams.add(`t${tm.id}`); clubs.add(key);
          for (const n of [tm.club, tm.name]) if (n) { const b = this._boil(n); if (!alias.has(b.club)) alias.set(b.club, key); }
        }
      } else for (const name of (t.rows && t.rows.length ? t.rows.map((x) => x.name) : t.teams || [])) if (name) named.push(name);
    }
    for (const name of named) {
      const b = this._boil(name);
      teams.add(`n${b.team}`);
      let key = alias.get(b.club);
      if (!key && b.cut && b.club.length >= 5) {
        const near = [...new Set([...alias].filter(([k]) => k.startsWith(`${b.club} `) || k.endsWith(` ${b.club}`) || b.club.startsWith(`${k} `) || b.club.endsWith(` ${k}`)).map(([, v]) => v))];
        if (near.length === 1) key = near[0];
      }
      if (!key) { key = `n${b.club}`; alias.set(b.club, key); }
      clubs.add(key);
    }
    return { clubs: clubs.size, teams: teams.size };
  }
  _banners(rows) {
    const slots = [...new Set(rows.flatMap((r) => r.cells.map((c) => c.slot)))];
    for (const slot of slots) {
      // only levels with tables on them: an empty placeholder step above (tier-*) is not this league's
      const cells = rows.map((r) => r.cells.find((c) => c.slot === slot)).filter((c) => c && c.num != null && c.tables && c.tables.length);   // cups' fields (foreign clubs) are not the league's
      if (!cells.length) continue;
      const nums = new Set(cells.map((c) => c.num).filter((x) => x != null)), n = this._tally(cells);
      const league = this._copy(`shape_side_${slot}`) || cells[0].title;
      cells[0].banner = this._copy('shape_side_header', { league, clubs: n.clubs, teams: n.teams, levels: nums.size });
    }
    this._crown = this._crownOf(rows);
  }
  // THE CROWN over the whole pyramid (owner 2026-11-25: "American pyramid at top. number of levels and
  // number of clubs … we can also say the pyramid goes 9 levels deep with the APSL feeder league CASA
  // Massachusetts"): levels = the deepest numbered level, clubs once each across every side (the cups'
  // fields are foreign clubs, left out); the deep line names the deepest table's league and its side
  _crownOf(rows) {
    let deep = null, top = null;
    const all = rows.filter((r) => r.num != null).flatMap((r) => r.cells);   // the cups' fields are foreign clubs, left out
    const n = this._tally(all);
    for (const r of rows) {
      if (r.num == null) continue;
      for (const c of r.cells) {
        if (!(c.tables || []).length) continue;
        if (!deep || r.num > deep.num) deep = { num: r.num, cell: c };
        if (!top || r.num < top.num) top = { num: r.num, cell: c };
      }
    }
    if (!deep) return null;
    const M = this.flow && this.flow._model, t = deep.cell.tables.find((x) => x.node) || deep.cell.tables[0];
    const div = M && t && t.node && t.node[0] === 'd' ? M.division(Number(t.node.slice(1))) : null;
    const comp = div && M.comp(div.competition_id);
    const league = (comp && comp.name) || (t && t.name ? t.name.split(' · ')[0] : '');
    const root = this._copy(`shape_side_${deep.cell.slot}`) || '';
    return [this._copy('shape_crown', { levels: deep.num, clubs: n.clubs, teams: n.teams }),
            league ? this._copy('shape_crown_deep', { levels: deep.num, root, league, top: this._copy(`shape_side_${top.cell.slot}`) || top.cell.title, top_n: top.num }) : ''].filter(Boolean);
  }

  _openPanel(key, cell) {
    const side = this._sides.find((s) => s.key === key), panel = this.root.querySelector('.sh-panel');
    if (!side || !panel || !this._solid) return;
    this.picked = key;
    panel.hidden = false;
    panel.querySelector('.ph span').textContent = side.title;
    panel.querySelector('.pb').innerHTML = side.html;
    // light that level's side, make room for the panel, and show that level's row of tables
    this._cell = cell || side.cell;
    this._solid.setShift(true);
    this._solid.pick(this._cell);
    panel.querySelector('.pb').scrollTop = Math.max(0, (this._cell.y0 || 0) - 6);
    this._drawLine();
  }

  _closePanel() {
    const panel = this.root.querySelector('.sh-panel');
    this.picked = null; this._cell = null;
    if (panel) panel.hidden = true;
    if (this._solid) { this._solid.pick(null); this._solid.setShift(false); }
    this._drawLine();
  }

  // Panel → its level: solid while that side faces us, dashed when it has turned away.
  _drawLine() {
    const svg = this.root && this.root.querySelector('.sh-line'), panel = this.root && this.root.querySelector('.sh-panel'), stage = this.root && this.root.querySelector('.sh-stage');
    if (!svg) return;
    const at = this._solid && this.picked && panel && !panel.hidden && this._cell ? this._solid.anchor(this._cell) : null;
    if (!at) { svg.innerHTML = ''; return; }
    const o = stage.getBoundingClientRect(), p = panel.getBoundingClientRect();
    const x1 = p.left - o.left, y1 = p.top - o.top + 22, mid = (x1 + at.x) / 2;
    svg.innerHTML = `<path d="M${x1},${y1} C${mid},${y1} ${mid},${at.y} ${at.x},${at.y}" fill="none" stroke="#fbbf24" stroke-width="2.5" ${at.facing > 0.2 ? '' : 'stroke-dasharray="7 6"'} />
      <circle cx="${at.x}" cy="${at.y}" r="5" fill="#fbbf24" />`;
  }

  // The buttons on the stage (the pyramid's own hands are in PyramidSolid).
  _wire(stage) {
    if (stage._shWired) return;
    stage._shWired = true;
    stage.addEventListener('click', (e) => {
      const lv = e.target.closest('[data-sh-row]');
      if (lv) { this._go(this.side, Number(lv.dataset.shRow)); return; }
      const side = e.target.closest('[data-sh-side]');
      if (side) {
        const n = Number(side.dataset.shSide), g = this._goList(this.flow._model).find((x) => x.side === n);
        if (g && !g.shown) {   // switch on what that side needs (its calendar, its league), rebuild, then snap there
          const on = this._calsOn(this.flow._model);
          if (g.cal) on.add(g.cal);
          this.cals = [...on];
          try { localStorage.setItem('apsl-shape-cals', JSON.stringify(this.cals)); } catch (_) { /* private mode */ }
          g.keys.forEach((k) => { if (!this.screen.feature(k, true)) try { localStorage.setItem(`apsl-feat-${k}`, '1'); } catch (_) { /* private mode */ } });
          this.side = n; this.row = null; this._goSide = n; this._goRow = null; this.picked = null;
          try { localStorage.setItem('apsl-shape-side', String(n)); } catch (_) { /* private mode */ }
          this.screen._viewCall('unmount'); this.screen._renderBody();
          return;
        }
        this._go(n, null);
        return;
      }
      const b = e.target.closest('[data-sh]');
      if (!b) return;
      const k = b.dataset.sh;
      if (k === 'close') this._closePanel();
      else if (!this._solid) return;
      else if (k === 'in' || k === 'out') this._solid.zoomBy(k === 'in' ? 1.25 : 0.8);
      else if (k === 'fit') { this.row = null; this._renderRail(); this._solid.fit(); }
    });
  }
}

window.PyramidShapeView = PyramidShapeView;
