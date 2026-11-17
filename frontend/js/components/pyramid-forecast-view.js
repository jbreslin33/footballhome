// pyramid-forecast-view.js — #apsl 📈 Forecast (mig 1448), a view of the
// APSL page.  Owner 2026-11-17: "make on apsl page an analysis for league
// and all teams so i can click on any of them" + "make it be able to predict
// scores etc. like a betting app lol. use analysis".
//
// One conference at a time (its pills = the conferences on screen), read
// from GET /api/pyramid/forecast?conference=<id> (models/PyramidForecast.h:
// a goals model + the season played out 10,000 times).
//
//   League   each table: today's place and points, expected points, 1st,
//            🏆 playoff, ⚔️ relegation playoff, ⬇ auto, 💀 relegated in all
//            (incl. losing the group playoff and the feeder game), then
//            every upcoming game as a bet card.
//   A team   tap any name: its odds, its strength, how it would go down,
//            where it finishes (bar per place), its games to come (bet
//            cards: 1 / X / 2 chances + fair odds, xG, most likely scores,
//            over 2.5, both score) and its results.
// Words: message_templates kind 'apsl_pyramid', tiers fc_*.
class PyramidForecastView {
  constructor(screen) {
    this.screen = screen;
    this.data = new Map();   // conference id → forecast | {error}
    this.conf = null; this.team = null;
    try { const c = Number(localStorage.getItem('apsl-forecast-conf')); if (c) this.conf = c; } catch (_) { /* private mode */ }
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens) || ''; }
  static pct(v) { const p = 100 * (v || 0); return p > 0 && p < 0.5 ? '<1%' : p > 99.5 && p < 100 ? '>99%' : `${Math.round(p)}%`; }
  static odds(p) { return p > 0 ? (1 / p >= 100 ? `${Math.round(1 / p)}` : (1 / p).toFixed(2)) : '—'; }

  static css() {
    return `
      .fc-wrap { max-width:980px; margin:0 auto; }
      .fc-wrap h3 { font-size:1rem; margin:16px 0 6px; }
      .fc-confs { display:flex; gap:6px; flex-wrap:wrap; margin:0 0 8px; }
      .fc-note { font-size:0.76rem; opacity:0.72; margin:4px 0 8px; line-height:1.4; }
      .fc-table { width:100%; border-collapse:collapse; font-size:0.82rem; }
      .fc-table th, .fc-table td { padding:5px 6px; text-align:right; border-top:1px solid rgba(255,255,255,0.07); white-space:nowrap; }
      .fc-table th:nth-child(2), .fc-table td:nth-child(2) { text-align:left; }
      .fc-table th { font-size:0.72rem; opacity:0.65; font-weight:700; }
      .fc-table td.tm { font-weight:700; cursor:pointer; text-decoration:underline dotted; text-underline-offset:3px; white-space:normal; }
      .fc-table tr.z-playoff td:first-child { box-shadow:inset 4px 0 #22c55e; }
      .fc-table tr.z-relegation_playoff td:first-child { box-shadow:inset 4px 0 #f97316; }
      .fc-table tr.z-relegation td:first-child { box-shadow:inset 4px 0 #dc2626; }
      .fc-rows td.tm { text-align:left; }
      .fc-heat { display:inline-block; min-width:38px; padding:1px 5px; border-radius:4px; font-weight:800; }
      .fc-bets { display:grid; grid-template-columns:repeat(auto-fill, minmax(290px, 1fr)); gap:10px; }
      .fc-bet { border:1px solid rgba(148,163,184,0.25); border-radius:10px; padding:8px 10px; background:rgba(15,23,42,0.55); }
      .fc-bet .when { font-size:0.7rem; opacity:0.65; margin-bottom:4px; }
      .fc-bet .teams { display:flex; justify-content:space-between; gap:8px; font-weight:800; font-size:0.86rem; }
      .fc-bet .teams span { cursor:pointer; }
      .fc-bet .teams span:last-child { text-align:right; }
      .fc-1x2 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:6px; margin:7px 0 5px; }
      .fc-1x2 div { text-align:center; border-radius:7px; padding:4px 2px; background:rgba(148,163,184,0.12); }
      .fc-1x2 div.fav { background:rgba(34,197,94,0.22); outline:1px solid #22c55e; }
      .fc-1x2 b { display:block; font-size:0.95rem; }
      .fc-1x2 small { font-size:0.68rem; opacity:0.75; }
      .fc-line { display:flex; flex-wrap:wrap; gap:4px 10px; font-size:0.72rem; opacity:0.85; }
      .fc-scores { display:flex; flex-wrap:wrap; gap:4px; margin-top:5px; }
      .fc-scores span { font-size:0.7rem; padding:1px 6px; border-radius:999px; background:rgba(56,189,248,0.14); }
      .fc-result { display:flex; justify-content:space-between; gap:8px; font-size:0.8rem; padding:4px 0; border-top:1px solid rgba(255,255,255,0.06); }
      .fc-result .wl { font-weight:800; min-width:1.4em; text-align:center; border-radius:4px; }
      .fc-bars { display:flex; flex-direction:column; gap:3px; max-width:520px; }
      .fc-bars div { display:grid; grid-template-columns:2.6em 1fr 3.4em; gap:6px; align-items:center; font-size:0.76rem; }
      .fc-bars i { display:block; height:12px; border-radius:3px; background:#3b82f6; min-width:1px; }
      .fc-big { display:flex; flex-wrap:wrap; gap:8px; margin:6px 0; }
      .fc-big div { border-radius:10px; padding:8px 12px; background:rgba(148,163,184,0.12); min-width:110px; }
      .fc-big b { display:block; font-size:1.35rem; }
      .fc-big small { font-size:0.72rem; opacity:0.75; }`;
  }

  // Heat cell: green (good) / red (bad) by chance.
  _heat(v, bad) {
    const p = v || 0;
    if (p < 0.005) return `<span class="fc-dim" style="opacity:0.35;">–</span>`;
    const a = 0.15 + 0.55 * Math.min(1, p);
    const bg = bad ? `rgba(220,38,38,${a})` : `rgba(34,197,94,${a})`;
    return `<span class="fc-heat" style="background:${bg};">${this._esc(PyramidForecastView.pct(p))}</span>`;
  }

  _pickConf(confs) {
    if (this.conf && confs.some((c) => c.id === this.conf)) return this.conf;
    const drc = confs.find((c) => /delaware/i.test(c.name || ''));
    return (drc || confs[0] || {}).id || null;
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    this.confs = confs;
    this.conf = this._pickConf(confs);
    const pills = confs.map((c) => `<button class="ap-pill ${c.id === this.conf ? 'on' : ''}" data-fc-conf="${c.id}">${esc(c.short_name || c.name)}</button>`).join('');
    return `<div class="fc-wrap" data-fc-root>
        <div class="fc-confs">${pills}</div>
        <div data-fc-body>${this._bodyHtml()}</div>
      </div>`;
  }

  _bodyHtml() {
    const d = this.data.get(this.conf);
    if (!d) return `<div class="loading">Loading…</div>`;
    if (d.error) return `<div class="error">${this._esc(d.error)}</div>`;
    if (!d.games || !d.games.length) return `<div class="fc-none">${this._esc(this._copy('fc_none'))}</div>`;
    return this.team ? this._teamHtml(d, this.team) : this._leagueHtml(d);
  }

  _teamsById(d) {
    if (d._byId) return d._byId;
    d._byId = new Map();
    for (const dv of d.divisions) for (const t of dv.teams) d._byId.set(t.id, { ...t, division: dv });
    return d._byId;
  }

  _when(s) {
    if (!s) return '';
    const dt = new Date(s);
    if (isNaN(dt)) return s;
    return dt.toLocaleString([], { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
  }

  _howHtml(d) {
    const m = d.model || {};
    const parts = [this._copy('fc_how', { games: d.played, left: d.left, avg: m.avg_goals, home: m.home_edge })];
    const f = d.format || {};
    if (f.group_rounds) parts.unshift(this._copy('fc_format', { n: f.per_team, rounds: f.group_rounds, cross: f.cross_group_rounds, listed: f.listed, added: f.added }));
    if (d.policy && d.policy.feeder) parts.push(this._copy('fc_feeder_note', { feeder: d.policy.feeder, pct: `${Math.round(d.policy.feeder_stay_up_pct)}%` }));
    if (d.as_of) parts.push(this._copy('fc_asof', { date: this._when(d.as_of) }));
    parts.push(this._copy('fc_fun'));
    return `<div class="fc-note">${parts.filter(Boolean).map((p) => this._esc(p)).join(' ')}</div>`;
  }

  _leagueHtml(d) {
    const esc = (t) => this._esc(t);
    const zoneAt = (dv, pos) => ((dv.zones || []).find((z) => pos >= z.from && pos <= z.to) || {}).kind || '';
    const hasRp = d.divisions.some((dv) => (dv.zones || []).some((z) => z.kind === 'relegation_playoff'));
    const hasDown = d.divisions.some((dv) => (dv.zones || []).some((z) => /relegation/.test(z.kind)));
    const tables = d.divisions.map((dv) => `
      <h3>${esc(dv.name)}</h3>
      <div style="overflow-x:auto;"><table class="fc-table">
        <thead><tr><th>#</th><th>${esc(this._copy('fc_col_team'))}</th><th>P</th><th>Pts</th><th>${esc(this._copy('fc_col_xpts'))}</th>
          <th>${esc(this._copy('fc_col_rating'))}</th><th>${esc(this._copy('fc_col_first'))}</th><th>${esc(this._copy('fc_col_playoff'))}</th>
          ${hasRp ? `<th>${esc(this._copy('fc_col_relplay'))}</th>` : ''}${hasDown ? `<th>${esc(this._copy('fc_col_auto'))}</th><th>${esc(this._copy('fc_col_down'))}</th>` : ''}</tr></thead>
        <tbody>${dv.teams.map((t) => `<tr class="z-${zoneAt(dv, t.pos)}">
          <td>${t.pos}</td><td class="tm" data-fc-team="${t.id}">${esc(t.name)}</td><td>${t.p}</td><td><b>${t.pts}</b></td><td>${t.xpts}</td>
          <td title="${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))}">${t.rating.toFixed(2)}</td>
          <td>${this._heat(t.pos_pct[0], false)}</td><td>${this._heat(t.zones.playoff, false)}</td>
          ${hasRp ? `<td>${this._heat(t.rel_playoff, true)}</td>` : ''}
          ${hasDown ? `<td>${this._heat((t.zones.relegation || 0) + (t.zones.conditional_relegation || 0), true)}</td><td>${this._heat(t.down, true)}</td>` : ''}
        </tr>`).join('')}</tbody>
      </table></div>`).join('');
    const upcoming = this._upcoming(d);
    return `
      <h3 style="margin-top:4px;">${esc(this._copy('fc_title', { conf: d.conference.name, sims: Number(d.sims).toLocaleString() }))}</h3>
      ${this._howHtml(d)}
      <div class="fc-note">${esc(this._copy('fc_tap_team'))}</div>
      ${tables}
      ${upcoming.length ? this._matchupsHtml(d, upcoming) : ''}`;
  }

  _betHtml(d, g, focus) {
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v)), O = PyramidForecastView.odds;
    const by = this._teamsById(d), h = by.get(g.home) || {}, a = by.get(g.away) || {};
    const [ph, pd, pa] = g.p;
    const fav = Math.max(ph, pd, pa);
    const cell = (label, p) => `<div class="${p === fav ? 'fav' : ''}"><small>${esc(label)}</small><b>${P(p)}</b><small>${esc(this._copy('fc_odds'))} ${O(p)}</small></div>`;
    const top = (g.scores || []).slice(0, 5).map((s) => `<span>${s.h}–${s.a} · ${P(s.p)}</span>`).join('');
    const likely = (g.scores || [])[0];
    const name = (t) => focus && t.id === focus ? `<u>${esc(t.name)}</u>` : esc(t.name);
    return `<div class="fc-bet">
        <div class="when">${esc(g.tbs ? this._copy('fc_tbs') : this._when(g.when))}${g.neutral ? ` · ${esc(this._copy('fc_neutral'))}` : ''}</div>
        <div class="teams"><span data-fc-team="${h.id}">${name(h)}</span><span data-fc-team="${a.id}">${name(a)}</span></div>
        <div class="fc-1x2">${cell('1', ph)}${cell(this._copy('fc_draw') || 'X', pd)}${cell('2', pa)}</div>
        <div class="fc-line">
          <span>${esc(this._copy('fc_xg'))} ${g.xg[0].toFixed(1)}–${g.xg[1].toFixed(1)}</span>
          ${likely ? `<span>${esc(this._copy('fc_likely'))} <b>${likely.h}–${likely.a}</b></span>` : ''}
          <span>${esc(this._copy('fc_over'))} ${P(g.over25)}</span>
          <span>${esc(this._copy('fc_btts'))} ${P(g.btts)}</span>
        </div>
        <div class="fc-scores" title="${esc(this._copy('fc_scores'))}">${top}</div>
      </div>`;
  }

  // Remaining games: the league's dated ones first, then the meetings it
  // hasn't scheduled yet (mig 1449).
  _upcoming(d) {
    return d.games.filter((g) => !g.done).sort((a, b) => (!!a.tbs - !!b.tbs) || String(a.when).localeCompare(String(b.when)));
  }

  // Every remaining matchup as one row (owner 11/17 "show all projections
  // for every matchup for rest of year for all teams"); a filter for
  // scheduled / not yet.  Tap a team for its own page.
  _matchupsHtml(d, all) {
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v)), O = PyramidForecastView.odds;
    const by = this._teamsById(d);
    const f = this.filter || 'all';
    const list = all.filter((g) => f === 'all' || (f === 'tbs' ? g.tbs : !g.tbs));
    const pill = (code, tier, n) => `<button class="ap-pill ${f === code ? 'on' : ''}" data-fc-filter="${code}">${esc(this._copy(tier))} · ${n}</button>`;
    const nT = all.filter((g) => g.tbs).length;
    const cell = (p, fav) => `<td><span class="fc-heat" style="${fav ? 'background:rgba(34,197,94,0.3);' : 'background:rgba(148,163,184,0.12);'}">${P(p)}</span><br><small style="opacity:0.7;">${O(p)}</small></td>`;
    const rows = list.map((g) => {
      const h = by.get(g.home) || {}, a = by.get(g.away) || {}, [ph, pd, pa] = g.p, fav = Math.max(ph, pd, pa), top = (g.scores || [])[0];
      return `<tr>
        <td style="text-align:left; white-space:normal; font-size:0.74rem; opacity:0.8;">${esc(g.tbs ? this._copy('fc_tbs') : this._when(g.when))}${g.neutral ? `<br>${esc(this._copy('fc_neutral'))}` : ''}</td>
        <td class="tm" data-fc-team="${h.id}">${esc(h.name)}</td>
        <td class="tm" data-fc-team="${a.id}" style="text-align:left;">${esc(a.name)}</td>
        ${cell(ph, ph === fav)}${cell(pd, pd === fav)}${cell(pa, pa === fav)}
        <td>${g.xg[0].toFixed(1)}–${g.xg[1].toFixed(1)}</td><td><b>${top ? `${top.h}–${top.a}` : ''}</b></td><td>${P(g.over25)}</td><td>${P(g.btts)}</td></tr>`;
    }).join('');
    return `<h3>${esc(this._copy('fc_all_rows', { n: all.length }))}</h3>
      <div class="fc-confs">${pill('all', 'fc_filter_all', all.length)}${pill('sched', 'fc_filter_sched', all.length - nT)}${pill('tbs', 'fc_filter_tbs', nT)}</div>
      <div style="overflow-x:auto;"><table class="fc-table fc-rows">
        <thead><tr><th style="text-align:left;">${esc(this._copy('fc_col_when'))}</th><th>1</th><th style="text-align:left;">2</th>
          <th>1</th><th>${esc(this._copy('fc_draw') || 'X')}</th><th>2</th><th>${esc(this._copy('fc_xg'))}</th><th>${esc(this._copy('fc_likely'))}</th><th>${esc(this._copy('fc_over'))}</th><th>${esc(this._copy('fc_btts'))}</th></tr></thead>
        <tbody>${rows}</tbody></table></div>`;
  }

  _teamHtml(d, id) {
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v)), Pt = PyramidForecastView.pct;
    const t = this._teamsById(d).get(id);
    if (!t) { this.team = null; return this._leagueHtml(d); }
    const auto = (t.zones.relegation || 0) + (t.zones.conditional_relegation || 0);
    const big = (label, v, bad) => `<div style="${bad && v > 0.5 ? 'background:rgba(220,38,38,0.25);' : !bad && v > 0.5 ? 'background:rgba(34,197,94,0.22);' : ''}"><b>${P(v)}</b><small>${esc(label)}</small></div>`;
    const hasDown = (t.division.zones || []).some((z) => /relegation/.test(z.kind));
    const path = hasDown ? (d.policy && d.policy.feeder
      ? this._copy('fc_down_path', { auto: Pt(auto), playoff: Pt(t.lost_playoff), feeder: Pt(t.lost_feeder), feeder_label: d.policy.feeder })
      : this._copy('fc_down_path_nofeed', { auto: Pt(auto), playoff: Pt(t.lost_playoff) })) : '';
    const bars = t.pos_pct.map((p, i) => `<div><span>${i + 1}${['st', 'nd', 'rd'][i] || 'th'}</span><i style="width:${Math.max(0.3, 100 * p)}%; background:${this._barColor(t.division, i + 1)}"></i><span>${P(p)}</span></div>`).join('');
    const mine = d.games.filter((g) => g.home === id || g.away === id);
    const by = this._teamsById(d);
    const results = mine.filter((g) => g.done).map((g) => {
      const home = g.home === id, us = home ? g.hs : g.as, them = home ? g.as : g.hs, o = by.get(home ? g.away : g.home) || {};
      const wl = us > them ? ['W', '#22c55e'] : us < them ? ['L', '#dc2626'] : ['D', '#94a3b8'];
      return `<div class="fc-result"><span>${esc(this._when(g.when))} · ${home ? 'vs' : '@'} <span data-fc-team="${o.id}" style="cursor:pointer; text-decoration:underline dotted;">${esc(o.name)}</span></span>
        <span><b>${us}–${them}</b> <span class="wl" style="background:${wl[1]}; color:#fff; padding:0 5px;">${wl[0]}</span></span></div>`;
    }).join('');
    const upcoming = this._upcoming(d).filter((g) => g.home === id || g.away === id);
    return `
      <button class="btn btn-secondary" data-fc-back style="margin:2px 0 8px;">${esc(this._copy('fc_back'))}</button>
      <h3 style="margin-top:0;">${esc(t.name)} <span style="opacity:0.65; font-weight:600;">· ${esc(t.division.name)} · ${t.pos}${['st', 'nd', 'rd'][t.pos - 1] || 'th'} · ${t.pts} pts</span></h3>
      <div class="fc-big">
        ${big(this._copy('fc_col_playoff'), t.zones.playoff || 0, false)}
        ${big(this._copy('fc_col_first'), t.pos_pct[0], false)}
        ${hasDown ? big(this._copy('fc_col_relplay'), t.rel_playoff, true) + big(this._copy('fc_col_down'), t.down, true) : ''}
        <div><b>${t.xpts}</b><small>${esc(this._copy('fc_col_xpts'))} (${t.left} left)</small></div>
      </div>
      ${path ? `<div class="fc-note" style="opacity:0.9;">${esc(path)}</div>` : ''}
      <div class="fc-note">${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))} · ${t.w}-${t.d}-${t.l}, ${t.gf}:${t.ga}</div>
      <h3>${esc(this._copy('fc_finish'))}</h3>
      <div class="fc-bars">${bars}</div>
      ${upcoming.length ? `<h3>${esc(this._copy('fc_upcoming'))}</h3><div class="fc-bets">${upcoming.map((g) => this._betHtml(d, g, id)).join('')}</div>` : ''}
      ${results ? `<h3>${esc(this._copy('fc_results'))}</h3><div>${results}</div>` : ''}
      ${this._howHtml(d)}`;
  }

  _barColor(dv, pos) {
    const z = ((dv.zones || []).find((x) => pos >= x.from && pos <= x.to) || {}).kind || '';
    return z === 'playoff' || /promotion/.test(z) ? '#22c55e' : z === 'relegation_playoff' ? '#f97316' : /relegation/.test(z) ? '#dc2626' : '#3b82f6';
  }

  _repaint() {
    const body = this.screen.find('[data-fc-body]');
    if (body) body.innerHTML = this._bodyHtml();
    this.screen.findAll('[data-fc-conf]').forEach((b) => b.classList.toggle('on', Number(b.dataset.fcConf) === this.conf));
  }

  async _load(id) {
    if (!id || this.data.has(id)) { this._repaint(); return; }
    this._repaint();
    try {
      const r = await fetch(`/api/pyramid/forecast?conference=${encodeURIComponent(id)}`);
      const j = await r.json().catch(() => ({}));
      this.data.set(id, r.ok ? j : { error: j.error || `HTTP ${r.status}` });
    } catch (e) {
      this.data.set(id, { error: e.message });
    }
    if (id === this.conf) this._repaint();
  }

  mount() {
    const root = this.screen.find('[data-fc-root]');
    if (!root) return;
    this._onClick = (e) => {
      const c = e.target.closest('[data-fc-conf]');
      if (c) {
        this.conf = Number(c.dataset.fcConf); this.team = null;
        try { localStorage.setItem('apsl-forecast-conf', String(this.conf)); } catch (_) { /* private mode */ }
        this._load(this.conf); return;
      }
      const t = e.target.closest('[data-fc-team]');
      if (t) { this.team = Number(t.dataset.fcTeam) || null; this._repaint(); root.scrollIntoView({ block: 'start' }); return; }
      const fl = e.target.closest('[data-fc-filter]');
      if (fl) { this.filter = fl.dataset.fcFilter; this._repaint(); return; }
      if (e.target.closest('[data-fc-back]')) { this.team = null; this._repaint(); }
    };
    root.addEventListener('click', this._onClick);
    this._root = root;
    this._load(this.conf);
  }

  unmount() {
    if (this._root && this._onClick) this._root.removeEventListener('click', this._onClick);
    this._root = null;
  }
}
window.PyramidForecastView = PyramidForecastView;
