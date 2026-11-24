// pyramid-shape-view.js — #apsl-pyramid "Spin the pyramid": the whole U.S. game as a
// stepped shape you turn, a view over PyramidModel (mig 1849).
//
// Owner 2026-11-24: "is a flat 2d view the best way to show all of this? i feel like a
// spinning pyramind would be way to go? or multi sided shape. each side is a 'league' …
// then we could spin the shape and zoom in or out and see the standings and the togglles
// to show or hide concacadf or fifa club world cup could change it like if we toggled them
// off mls would move upt to 1st level" · "totally fine with having to get it to face and
// we can also enhnace wiht 2d view of standings for that league off to side with line to
// face when its not facing us" · "we can just have some sides more zoom needed" · (of a
// huge league) "for now just putt hem on face".
//
// THE SHAPE.  One LEVEL per step of the game, top first; a level is a ring of SIDES, one
// per league at that level:
//     the cups and pro divisions above the APSL  (PyramidFlowView._pro — what the pills leave)
//     then the bottom ring: the APSL pyramid itself (its conferences with every league
//     that feeds them underneath, the flow chart) and each national league beside it
//     (its divisions with its regional leagues underneath).
// The shape has as many sides as the bottom ring has leagues, at EVERY level, so a side is
// one whole column (owner: "when we face apsl we should see mls 1, …, apsl 4th level, liga 1s
// 5th, liga 2s 6th all facing us on that side of pyramind · then we can rotate and see upsl
// pyrmaind"): a level with one league repeats it on every side (it wraps), two leagues
// alternate, and under them each bottom league's side carries its own lower levels — its
// first division, then the leagues that feed it, each row tagged with its level number.
// Lower levels are wider, so the block steps out like a pyramid.  A league switched off
// leaves; an emptied level goes and everything below moves up a number.
//
// THE SIDES are the page's own boxes (flow.proLeagueHtml / chartHtml / besideLeagueHtml).
// A level's sides are as wide as its biggest league needs (owner: "just make the faces big
// enough and upsl smalller text or normal text and the apsl whould have bigger text or
// more empty space"): a very wide league (UPSL: 35 conferences) is set a little smaller,
// a narrow one up to 1.6× larger, the rest of its side left empty.  Each level is at
// least a step wider than the one above.  The shape is CSS 3D (rotateY + translateZ on
// real elements), not a canvas: the text stays text.
//
// ONE PYRAMID PER CALENDAR (owner: "if not enoguht sides just never show the 'summer' ones
// with the fifa cal ones · separate pyraminds"): the fall–spring game, the U23 summer leagues
// and the spring-to-fall leagues are three shapes, picked on the row at the top — a league
// is only ever on the shape of its own season_calendars row.
//
// TURNING.  Drag sideways to spin, up/down to slide, wheel or ± to zoom; let go and it
// settles square on the nearest side of the level you held.  Tap a side: it comes round to
// face you and its league opens flat in the panel on the right, a line tying the panel to
// its side wherever the side has turned to (dashed when it faces away).
//
// Layout is measured flat first (natural sizes, and the APSL chart's arrows are drawn
// then), and only after that folded into 3D — getBoundingClientRect is no use under perspective.
class PyramidShapeView {
  constructor(screen, flow) {
    this.screen = screen; this.flow = flow; this.fill = true;
    this.angle = 0; this.zoom = 0; this.panY = 0;   // zoom 0 = fit on mount
    this.picked = null;                              // the side key open in the panel
    this.cal = null;                                 // which calendar's pyramid is up (null = the first)
    try { this.cal = localStorage.getItem('apsl-shape-cal') || null; } catch (_) { /* private mode */ }
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .sh-stage { position:absolute; inset:0; overflow:hidden; perspective:2600px; perspective-origin:50% 30%; cursor:grab; touch-action:none; user-select:none; }
      .sh-stage.dragging { cursor:grabbing; }
      .sh-cam { position:absolute; left:50%; top:0; width:0; height:0; transform-style:preserve-3d; }
      .sh-shape { position:absolute; left:0; top:0; width:0; height:0; transform-style:preserve-3d; }
      .sh-shape.settle { transition:transform 0.55s cubic-bezier(.2,.8,.2,1); }
      .sh-face { position:absolute; left:0; top:0; box-sizing:border-box; overflow:hidden; backface-visibility:hidden;
                 background:var(--bg-color, #0b1220); border:2px solid #334155; border-radius:6px; }
      .sh-face.on { border-color:#fbbf24; }
      .sh-face .sh-hd { position:absolute; left:0; right:0; top:0; z-index:2; height:30px; line-height:30px; padding:0 10px; font-weight:800; font-size:0.9rem; text-align:center; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
                        background:#1e293b; border-bottom:1px solid #334155; }
      .sh-face .sh-hd .lv { opacity:0.65; font-weight:700; margin-right:8px; }
      .sh-face .sh-in { position:absolute; left:0; top:30px; transform-origin:0 0; width:max-content; padding:10px; box-sizing:border-box; }
      .sh-face .sh-in .fc-pro-lg, .sh-face .sh-in .fc-chart { margin:0; }
      /* a cup's clubs across three columns, so its level is a block and not a tall strip */
      .sh-face .sh-in .fc-field ul, .sh-flat .fc-field ul, .sh-panel .fc-field ul { columns:3; column-gap:26px; width:600px; }
      .sh-empty { opacity:0.6; border-style:dashed; min-width:320px; text-align:center; }
      .sh-ledge { position:absolute; left:0; top:0; box-sizing:border-box; backface-visibility:hidden; text-align:center; font-size:0.72rem; font-weight:800; line-height:20px;
                  color:#fbbf24; background:#111827; border:1px dashed #94a3b8; border-radius:4px; white-space:nowrap; overflow:hidden; }
      .sh-flat { position:absolute; left:0; top:0; visibility:hidden; pointer-events:none; }
      .sh-flat > div { width:max-content; padding:10px; }
      .sh-tools { position:absolute; left:12px; bottom:12px; z-index:5; display:flex; gap:6px; align-items:center; }
      .sh-tools button { min-height:0; min-width:0; width:34px; height:34px; border-radius:50%; cursor:pointer; font-size:1rem; font-weight:800;
                         border:1px solid var(--border-color, #374151); background:rgba(15,23,42,0.9); color:inherit; }
      .sh-tools button.wide { width:auto; padding:0 12px; border-radius:999px; font-size:0.8rem; }
      .sh-cals { position:absolute; left:12px; top:10px; z-index:6; display:flex; gap:5px; flex-wrap:wrap; }
      .sh-cals button { min-height:0; min-width:0; padding:3px 10px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.72rem;
                        border:1px solid var(--border-color, #374151); background:rgba(15,23,42,0.9); color:inherit; }
      .sh-cals button.on { background:var(--primary-color, #2563eb); border-color:transparent; color:#fff; }
      .sh-feats { position:absolute; left:12px; top:38px; z-index:6; display:flex; gap:5px; flex-wrap:wrap; }
      .sh-feats button { min-height:0; min-width:0; padding:2px 8px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.66rem; opacity:0.6;
                         border:1px solid var(--border-color, #374151); background:rgba(15,23,42,0.9); color:inherit; }
      .sh-feats button.on { opacity:1; border-color:#fbbf24; }
      .sh-feats button.on::before { content:"✓ "; }
      .sh-hint { position:absolute; left:12px; top:62px; z-index:5; font-size:0.68rem; opacity:0.7; max-width:60%; pointer-events:none; }
      .sh-panel { position:absolute; right:10px; top:10px; bottom:10px; width:min(460px, 46%); z-index:6; display:flex; flex-direction:column;
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
  // The cups over the leagues (levels reached by results): their switches sit on the shape itself,
  // with the pro one (owner 2026-11-24: "we need togllge on screen for pro toggle and concacaf and
  // club world cup toggles").
  _cups(model) { return (model.pro || []).filter((t) => t.standards === false && !t.beside).flatMap((t) => t.leagues.map((l) => `lg-${l.id}`)); }
  _cal(model) {
    const all = this._calendars(model);
    return all.some((c) => c.code === this.cal) ? this.cal : (all[0] ? all[0].code : null);
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
    const flow = this.flow, levels = [], cal = this._cal(model);
    // this calendar's leagues that are switched on (its own pill; the calendar pills of the flat view do not apply)
    const mine = (l) => this._calOf(model, l) === cal && this.screen.feature(`lg-${l.id}`, true);
    const every = (model.pro || []).map((t) => ({ ...t, leagues: t.leagues.filter(mine) }));
    const tiers = every.filter((t) => t.leagues.length);
    if (this.screen.feature('pro', true)) {
      // A pro DIVISION keeps its step even with no league on this calendar, when there is a
      // division above and below it that has one (owner 2026-11-24: "usl champtionsip and usl
      // league one are spring to fall so if that is not selected then level under mls is empty
      // right? and level 3 would only have mls next pro") — MLS NEXT Pro stays a Division III
      // league, it does not slide up under MLS.  A cup (reached by results) with nothing on
      // simply goes, and the rest move up.
      const divisions = every.filter((t) => !t.beside && t.standards !== false);
      const first = divisions.findIndex((t) => t.leagues.length), last = divisions.length - 1 - [...divisions].reverse().findIndex((t) => t.leagues.length);
      const kept = new Set(first < 0 ? [] : divisions.slice(first, last + 1).map((t) => t.tier));
      for (const t of every.filter((x) => !x.beside)) {
        if (t.leagues.length) levels.push({ standards: t.standards !== false, sides: t.leagues.map((l) => ({ key: `lg-${l.id}`, title: l.name, html: flow.proLeagueHtml(l, t) })) });
        else if (kept.has(t.tier)) levels.push({ standards: true, sides: [{ key: `tier-${t.tier}`, title: t.label,
          html: `<div class="fc-pro-lg sh-empty"><h2>${this._esc(t.label)}</h2><div class="fc-meta">${this._esc(this._copy('shape_empty_level'))}</div></div>` }] });
      }
    }
    const bottom = [];
    if (model.data.calendar === cal) {
      const root = model.comp(model.data.root_id);
      bottom.push({ key: 'root', title: root ? model.label(root) : '', html: flow.chartHtml(model, confs), chart: true });
    }
    if (this.screen.feature('open', true))
      for (const t of tiers.filter((x) => x.beside))
        for (const l of t.leagues.filter((x) => x.feeds == null)) bottom.push({ key: `lg-${l.id}`, title: l.name, html: flow.besideLeagueHtml(model, { ...l, label: t.label }) });
    if (bottom.length) levels.push({ standards: false, sides: bottom });
    return levels;
  }

  html(model, confs) {
    this.flow._model = model;
    this._lv = this._levels(model, confs);
    const esc = (t) => this._esc(t);
    return `
      <div class="sh-stage">
        <div class="sh-cals">${this._calendars(model).map((c) => `<button class="${c.code === this._cal(model) ? 'on' : ''}" data-sh-cal="${esc(c.code)}">${esc(c.label)}</button>`).join('')}</div>
        <div class="sh-feats">${this.features().filter((f) => f.key === 'pro' || this._cups(model).includes(f.key)).map((f) => `<button class="${this.screen.feature(f.key, f.def) ? 'on' : ''}" data-sh-feat="${esc(f.key)}">${esc(f.label || this._copy(f.tier))}</button>`).join('')}</div>
        <div class="sh-hint">${esc(this._copy('shape_hint'))}</div>
        <div class="sh-flat">${this._lv.map((lv, i) => lv.sides.map((s, k) => `<div data-flat="${i}-${k}">${s.html}</div>`).join('')).join('')}</div>
        <div class="sh-cam"><div class="sh-shape"></div></div>
        <svg class="sh-line"></svg>
        <div class="sh-panel" hidden><div class="ph"><span></span><button data-sh="close">${esc(this._copy('shape_close'))}</button></div><div class="pb"></div></div>
        <div class="sh-tools">
          <button data-sh="prev" title="${esc(this._copy('shape_prev'))}">‹</button>
          <button data-sh="next" title="${esc(this._copy('shape_next'))}">›</button>
          <button data-sh="out" title="${esc(this._copy('zoom_out'))}">−</button>
          <button data-sh="in" title="${esc(this._copy('zoom_in'))}">+</button>
          <button data-sh="fit" class="wide">${esc(this._copy('zoom_fit'))}</button>
        </div>
      </div>`;
  }

  // ── fold it ──────────────────────────────────────────────────────────
  mount(root, model, confs) {
    this.root = root;
    const stage = root.querySelector('.sh-stage'), shape = root.querySelector('.sh-shape'), flat = root.querySelector('.sh-flat');
    if (!stage || !shape) return;
    const esc = (t) => this._esc(t), L = this._lv, n = L.length;
    this._sides = [];
    if (!n) { this._height = 1; this._wire(stage); return; }
    // 1. flat: the APSL chart's arrows, and every side's natural size
    flat.querySelectorAll('.fc-chart').forEach((c) => this.flow.drawArrows(c, model, confs));
    const HEAD = 30, GAP = 34, LEDGE = 22;
    let y = 0;
    const parts = [];
    this._sides = [];
    // every side's natural size, then each level's width: what its biggest league needs
    // (a very wide one at 0.6), and never less than a step wider than the level above
    const natural = L.map((lv, i) => lv.sides.map((s, k) => {
      const el = flat.querySelector(`[data-flat="${i}-${k}"]`);
      // where each of the league's own levels starts down its side: its first division, then
      // every row of leagues that feed it (the chart's rows; a national league's regional leagues)
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
      return { ...s, html: el.innerHTML, w: el.offsetWidth || 1, h: el.offsetHeight || 1, rows };
    }));
    // as many sides as the bottom ring has leagues — at every level, so each side is a whole column
    const bottomCount = n ? L[n - 1].sides.length : 0, slots = bottomCount < 3 ? 4 : bottomCount;
    const widths = [];
    natural.forEach((sides, i) => {
      const need = Math.max(...sides.map((m) => (m.w > 2400 ? m.w * 0.6 : m.w)));
      widths.push(Math.round(Math.max(360, need, i ? widths[i - 1] * 1.18 : 0)));
    });
    const face = (level, slot, width, height, apothem, step, m, clip) => {
      const id = this._sides.length;
      this._sides.push({ id, key: m.key, title: m.title, html: m.html, level, slot, step });
      // clip = the band of the league's own chart this level shows: the whole box is laid in, slid up, and the side cuts it
      const top = clip ? HEAD - clip.y0 * m.scale : HEAD;
      parts.push(`<div class="sh-face ${this.picked === m.key ? 'on' : ''}" data-side="${id}" style="width:${width}px; height:${height}px; margin-left:${-width / 2}px; transform:translateY(${y}px) rotateY(${slot * step}deg) translateZ(${apothem}px);">
            <div class="sh-in" style="transform:scale(${m.scale}); left:${Math.max(0, (width - m.w * m.scale) / 2)}px; top:${top}px;">${m.html}</div>
            <div class="sh-hd"><span class="lv">${esc(this._copy('shape_level', { n: level + 1 }))}</span>${esc(m.title)}</div></div>`);
    };
    const step = 360 / slots, apo = (width) => width / (2 * Math.tan(Math.PI / slots));
    L.forEach((lv, i) => {
      const count = lv.sides.length;                                          // one league wraps every side, two alternate
      const measured = natural[i].map((m) => { const scale = Math.min(1.6, widths[i] / m.w); return { ...m, scale }; });
      if (i < n - 1) {   // a level above the bottom ring: one block
        const width = widths[i], height = Math.round(HEAD + Math.max(...measured.map((m) => m.h * m.scale)));
        for (let slot = 0; slot < slots; slot++) face(i, slot, width, height, apo(width), step, measured[slot % count], null);
        y += height;
        if (lv.standards) {   // the step down is the standards a league must meet to come up
          const [label, url] = (this._copy('path_pro_link') || '').split('|');
          for (let slot = 0; slot < slots; slot++)
            parts.push(`<div class="sh-ledge" style="width:${width}px; height:${LEDGE}px; margin-left:${-width / 2}px; transform:translateY(${y + 6}px) rotateY(${slot * step}deg) translateZ(${apo(width)}px);">${/^https:\/\//.test(url || '') ? `<a href="${esc(url)}" target="_blank" rel="noopener" style="color:inherit;">${esc(label)}</a>` : esc(label || '')}</div>`);
        }
        y += GAP;
        return;
      }
      // The bottom ring is several levels deep (owner 2026-11-24: "we are also missing the level 7
      // of liga 1 etc. is there a way to pu the on level below apsl and sitll connec twith
      // arrows?"): a league's first division is one level, each row of leagues that feed it the
      // next level down, a step wider.  Every level shows its BAND of the league's one chart,
      // cut half-way through the gap between rows — so the chart's own arrows leave the top of
      // one level and arrive at the foot of the level above, in the same place across the step.
      const bands = measured.map((m) => {
        const tops = m.rows.slice().sort((p, q) => p.step - q.step).map((r) => r.y);
        const cuts = tops.map((t, k) => (k === 0 ? 0 : Math.max(0, t - (m.chart ? 28 : 6))));   // half the chart's 56px row gap
        return cuts.length ? cuts.map((y0, k) => ({ y0, y1: k + 1 < cuts.length ? cuts[k + 1] : m.h })) : [{ y0: 0, y1: m.h }];
      });
      const depth = Math.max(...bands.map((x) => x.length));
      for (let k = 0; k < depth; k++) {
        const width = Math.round(widths[i] * Math.pow(1.1, k));
        const height = Math.round(HEAD + Math.max(...measured.map((m, j) => (bands[j][k] ? (bands[j][k].y1 - bands[j][k].y0) * m.scale : 0))));
        for (let slot = 0; slot < slots; slot++) {
          const j = slot % count;
          if (bands[j][k]) face(i + k, slot, width, height, apo(width), step, measured[j], bands[j][k]);   // a league with no such level leaves its side open
        }
        y += height + (k + 1 < depth ? 8 : GAP);
      }
    });
    this._height = Math.max(1, y - GAP);
    flat.remove();
    shape.innerHTML = parts.join('');
    if (!this.zoom) this._fit(stage);
    this._apply(false);
    this._wire(stage);
    if (this.picked && this._sides.some((s) => s.key === this.picked)) this._openPanel(this.picked); else this.picked = null;
  }

  unmount() { if (this._raf) cancelAnimationFrame(this._raf); this._raf = null; }
  onResize() { this._drawLine(); }

  _fit(stage) {
    // the near sides stand toward the eye and draw larger than their size: leave room for that
    const room = stage.clientHeight - 70;
    this.zoom = Math.min(1, (room * 0.74) / this._height);
    this.panY = 60 + (room - this._height * this.zoom) / 2 - room * 0.06;
  }

  _apply(settle) {
    const cam = this.root.querySelector('.sh-cam'), shape = this.root.querySelector('.sh-shape');
    if (!cam || !shape) return;
    cam.style.transform = `translateY(${this.panY}px) scale3d(${this.zoom}, ${this.zoom}, ${this.zoom})`;   // depth too: scale() leaves z full size, past the eye
    shape.classList.toggle('settle', !!settle);
    shape.style.transform = `rotateX(-4deg) rotateY(${this.angle}deg)`;
    this._follow(settle ? 700 : 0);
  }

  // Keep the panel's line on its side while the shape moves.
  _follow(ms) {
    if (this._raf) cancelAnimationFrame(this._raf);
    const until = performance.now() + ms;
    const tick = () => { this._drawLine(); this._raf = performance.now() < until ? requestAnimationFrame(tick) : null; };
    tick();
  }

  // The side of `key` turned most toward us.
  _nearest(key) {
    let best = null, bestCos = -2;
    for (const s of this._sides) {
      if (s.key !== key) continue;
      const c = Math.cos(((this.angle + s.slot * s.step) * Math.PI) / 180);
      if (c > bestCos) { bestCos = c; best = s; }
    }
    return best ? { side: best, facing: bestCos } : null;
  }

  // Turn the shortest way so `side` faces us.
  _face(side) {
    const want = -side.slot * side.step;
    this.angle += ((((want - this.angle) % 360) + 540) % 360) - 180;
    this._apply(true);
  }

  // Settle square on the nearest side of a level.
  _snap(level) {
    const s = this._sides.find((x) => x.level === level) || this._sides[this._sides.length - 1];
    if (!s) return;
    this.angle = Math.round(this.angle / s.step) * s.step;
    this._apply(true);
  }

  _openPanel(key) {
    const side = this._sides.find((s) => s.key === key), panel = this.root.querySelector('.sh-panel');
    if (!side || !panel) return;
    this.picked = key;
    panel.hidden = false;
    panel.querySelector('.ph span').textContent = side.title;
    panel.querySelector('.pb').innerHTML = side.html;
    this.root.querySelectorAll('.sh-face').forEach((f) => f.classList.toggle('on', this._sides[Number(f.dataset.side)].key === key));
    this._drawLine();
  }

  _closePanel() {
    const panel = this.root.querySelector('.sh-panel');
    this.picked = null;
    if (panel) panel.hidden = true;
    this.root.querySelectorAll('.sh-face.on').forEach((f) => f.classList.remove('on'));
    this._drawLine();
  }

  // Panel → its side: solid while the side faces us, dashed when it has turned away.
  _drawLine() {
    const svg = this.root && this.root.querySelector('.sh-line'), panel = this.root && this.root.querySelector('.sh-panel'), stage = this.root && this.root.querySelector('.sh-stage');
    if (!svg) return;
    const near = this.picked && panel && !panel.hidden ? this._nearest(this.picked) : null;
    if (!near) { svg.innerHTML = ''; return; }
    const el = this.root.querySelector(`.sh-face[data-side="${near.side.id}"]`);
    if (!el) { svg.innerHTML = ''; return; }
    const o = stage.getBoundingClientRect(), f = el.getBoundingClientRect(), p = panel.getBoundingClientRect();
    const x1 = p.left - o.left, y1 = p.top - o.top + 22;
    const x2 = Math.min(x1 - 12, f.left - o.left + f.width / 2), y2 = f.top - o.top + Math.min(f.height / 2, 60);
    const mid = (x1 + x2) / 2;
    svg.innerHTML = `<path d="M${x1},${y1} C${mid},${y1} ${mid},${y2} ${x2},${y2}" fill="none" stroke="#fbbf24" stroke-width="2.5" ${near.facing > 0.2 ? '' : 'stroke-dasharray="7 6"'} />
      <circle cx="${x2}" cy="${y2}" r="5" fill="#fbbf24" />`;
  }

  // ── hands ────────────────────────────────────────────────────────────
  _wire(stage) {
    if (stage._shWired) return;
    stage._shWired = true;
    let drag = null;
    stage.addEventListener('pointerdown', (e) => {
      if (e.target.closest('.sh-panel, .sh-tools, .sh-cals, .sh-feats, a')) return;
      const face = e.target.closest('.sh-face');
      drag = { x: e.clientX, y: e.clientY, angle: this.angle, panY: this.panY, moved: false, side: face ? this._sides[Number(face.dataset.side)] : null };
      stage.setPointerCapture(e.pointerId);
    });
    stage.addEventListener('pointermove', (e) => {
      if (!drag) return;
      const dx = e.clientX - drag.x, dy = e.clientY - drag.y;
      if (!drag.moved && Math.hypot(dx, dy) < 5) return;
      drag.moved = true;
      stage.classList.add('dragging');
      this.angle = drag.angle + dx * 0.35;
      this.panY = drag.panY + dy;
      this._apply(false);
    });
    const end = () => {
      if (!drag) return;
      const d = drag;
      drag = null;
      stage.classList.remove('dragging');
      if (d.moved) this._snap(d.side ? d.side.level : this._sides.length ? this._sides[this._sides.length - 1].level : 0);
      else if (d.side) { this._face(d.side); this._openPanel(d.side.key); }
    };
    stage.addEventListener('pointerup', end);
    stage.addEventListener('pointercancel', end);
    stage.addEventListener('wheel', (e) => {
      if (e.target.closest('.sh-panel')) return;
      e.preventDefault();
      this._zoomBy(e.deltaY < 0 ? 1.12 : 1 / 1.12, e.clientY - stage.getBoundingClientRect().top);
    }, { passive: false });
    stage.addEventListener('click', (e) => {
      const cal = e.target.closest('[data-sh-cal]');
      if (cal) {   // another calendar's pyramid: a fresh shape, squared up and fitted
        this.cal = cal.dataset.shCal;
        try { localStorage.setItem('apsl-shape-cal', this.cal); } catch (_) { /* private mode */ }
        this.angle = 0; this.zoom = 0; this.picked = null;
        this.screen._viewCall('unmount'); this.screen._renderBody();
        return;
      }
      const feat = e.target.closest('[data-sh-feat]');
      if (feat) {   // the same switches as ☰ Show on screen; the shape is rebuilt and refitted
        this.zoom = 0;
        this.screen._setFeature(feat.dataset.shFeat, !this.screen.feature(feat.dataset.shFeat, true));
        this.screen._renderBar();
        return;
      }
      const b = e.target.closest('[data-sh]');
      if (!b) return;
      const k = b.dataset.sh, last = this._sides.length ? this._sides[this._sides.length - 1] : null;
      if (k === 'close') this._closePanel();
      else if (k === 'in' || k === 'out') this._zoomBy(k === 'in' ? 1.25 : 0.8, stage.clientHeight / 2);
      else if (k === 'fit') { this._fit(stage); this._apply(true); }
      else if (last && (k === 'prev' || k === 'next')) {   // one side of the bottom ring
        this.angle = Math.round(this.angle / last.step) * last.step + (k === 'next' ? -last.step : last.step);
        this._apply(true);
      }
    });
  }

  // Zoom about a height on the stage, so what is under the pointer stays there.
  _zoomBy(f, atY) {
    const z = Math.min(6, Math.max(0.08, this.zoom * f));
    this.panY = atY - ((atY - this.panY) * z) / this.zoom;
    this.zoom = z;
    this._apply(false);
  }
}

window.PyramidShapeView = PyramidShapeView;
