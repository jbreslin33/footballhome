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

  // ✅ Safe (owner 11/17 "why not have chance of finishing totally safe in
  // the table … which is 6th place"): finishing above every place that
  // moves a team down (relegation playoff included).
  static safe(t) {
    const down = Object.entries(t.zones || {}).filter(([k]) => /relegation/.test(k)).reduce((a, [, v]) => a + v, 0);
    return Math.max(0, 1 - down);
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
    if (!this.team) return this._leagueHtml(d);
    const w = this.whatIf && this.whatIf.team === this.team && this.whatIf.conf === this.conf ? this.whatIf : null;
    return this._teamHtml(w && w.data ? w.data : d, this.team, d);
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
          ${hasDown ? `<th>${esc(this._copy('fc_col_safe'))}</th>` : ''}${hasRp ? `<th>${esc(this._copy('fc_col_relplay'))}</th>` : ''}${hasDown ? `<th>${esc(this._copy('fc_col_auto'))}</th><th>${esc(this._copy('fc_col_down'))}</th>` : ''}</tr></thead>
        <tbody>${dv.teams.map((t) => `<tr class="z-${zoneAt(dv, t.pos)}">
          <td>${t.pos}</td><td class="tm" data-fc-team="${t.id}">${esc(t.name)}</td><td>${t.p}</td><td><b>${t.pts}</b></td><td>${t.xpts}</td>
          <td title="${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))}">${t.rating.toFixed(2)}</td>
          <td>${this._heat(t.pos_pct[0], false)}</td><td>${this._heat(t.zones.playoff, false)}</td>
          ${hasDown ? `<td>${this._heat(PyramidForecastView.safe(t), false)}</td>` : ''}
          ${hasRp ? `<td>${this._heat(t.rel_playoff, true)}</td>` : ''}
          ${hasDown ? `<td>${this._heat((t.zones.relegation || 0) + (t.zones.conditional_relegation || 0), true)}</td><td>${this._heat(t.down, true)}</td>` : ''}
        </tr>`).join('')}</tbody>
      </table></div>
      ${this._placesHtml(dv)}`).join('');
    const upcoming = this._upcoming(d);
    return `
      <h3 style="margin-top:4px;">${esc(this._copy('fc_title', { conf: d.conference.name, sims: Number(d.sims).toLocaleString() }))}</h3>
      ${this._howHtml(d)}
      <div class="fc-note">${esc(this._copy('fc_tap_team'))}</div>
      ${tables}
      ${this._outlookHtml(d)}
      ${upcoming.length ? this._matchupsHtml(d, upcoming) : ''}`;
  }

  // 📉 Up and down (mig 1571, owner 11/19 "3.5 of 16 this year. and 3.5 of
  // 14 next year. then … 1.5 of 12 … show percentage of teams getting
  // relegated each year. show strength of teams from casa" + "chances of
  // getting promoted from feeders"): the seasons table (pyramid_relegation_
  // outlook), our road through them, and each feeder league's table with
  // its strength and promotion chance (server: PyramidForecast outlookJson).
  _outlookHtml(d) {
    const o = d.outlook || {}, seasons = o.seasons || [], feeders = o.feeders || [];
    if (!seasons.length && !feeders.length) return '';
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v));
    const n = (v) => String(Math.round(v * 10) / 10);
    let html = `<h3>${esc(this._copy('fc_ol_title'))}</h3>`;
    if (seasons.length) {
      const maxShare = Math.max(...seasons.map((x) => x.down / x.teams), 0.01);
      html += `<div style="overflow-x:auto;"><table class="fc-table" style="max-width:720px;">
        <thead><tr><th>${esc(this._copy('fc_ol_season'))}</th><th>${esc(this._copy('fc_ol_rules'))}</th><th>${esc(this._copy('fc_ol_teams'))}</th>
          <th>${esc(this._copy('fc_ol_down'))}</th><th style="text-align:left;">${esc(this._copy('fc_ol_down_pct'))}</th><th>${esc(this._copy('fc_ol_up'))}</th><th>${esc(this._copy('fc_ol_next'))}</th></tr></thead>
        <tbody>${seasons.map((x) => {
          const share = x.down / x.teams;
          return `<tr><td style="text-align:left;"><b>${esc(x.season)}</b></td><td style="text-align:left; white-space:normal;">${esc(x.rules)}</td><td>${x.teams}</td>
            <td><b>${n(x.down)}</b></td>
            <td style="text-align:left;"><span style="display:inline-block; vertical-align:middle; height:10px; border-radius:3px; background:#dc2626; width:${Math.round(110 * share / maxShare)}px;"></span> <b>${P(share)}</b></td>
            <td>${n(x.up)}</td><td>${n(x.teams - x.down + x.up)}</td></tr>`;
        }).join('')}</tbody></table></div>
        <div class="fc-note">${esc(this._copy('fc_ol_note'))}</div>`;
    }
    // 🛣 our road: this season's forecast, then the base rates after it
    const us = d.ours ? this._teamsById(d).get(d.ours) : null;
    const feeder = feeders[0];
    if (us && seasons.length >= 2) {
      const [s1, s2, s3] = seasons;
      const base2 = s2.down / s2.teams;
      const lines = [
        this._copy('fc_ol_road_now', { season: s1.season, down: PyramidForecastView.pct(us.down) }),
        this._copy('fc_ol_stay', { s1: s1.season, s2: s2.season, base: PyramidForecastView.pct(base2), pct: PyramidForecastView.pct((1 - us.down) * (1 - base2)) }),
      ];
      if (s3 && feeder) lines.push(this._copy('fc_ol_bounce', { s2: s2.season, s3: s3.season, feeder: feeder.label, up: n(s1.up), others: n(Math.max(0, s1.down - 1)), s3_down: n(s3.down), s3_teams: s3.teams }));
      html += `<div style="margin:8px 0; padding:8px 12px; border-radius:10px; border:1px solid #facc15; background:rgba(250,204,21,0.08); font-size:0.84rem; line-height:1.45;">
          <b>${esc(this._copy('fc_ol_road', { team: us.name }))}</b>${lines.filter(Boolean).map((l) => `<div>${esc(l)}</div>`).join('')}</div>`;
    }
    for (const f of feeders) {
      html += `<h3>${esc(this._copy('fc_ol_feeder', { label: f.label }))}</h3>
        <div class="fc-note">${esc(this._copy('fc_ol_feeder_note', { auto: f.auto, playoff: f.playoff, pct: PyramidForecastView.pct(f.win_playoff), played: f.played, left: f.left }))}</div>
        <div style="overflow-x:auto;"><table class="fc-table">
          <thead><tr><th>#</th><th>${esc(this._copy('fc_col_team'))}</th><th>P</th><th>Pts</th><th>${esc(this._copy('fc_col_xpts'))}</th>
            <th>${esc(this._copy('fc_col_rating'))}</th><th>${esc(this._copy('fc_ol_col_first'))}</th><th>${esc(this._copy('fc_ol_col_po'))}</th><th>${esc(this._copy('fc_ol_col_up'))}</th></tr></thead>
          <tbody>${f.teams.map((t) => `<tr class="${t.pos <= f.auto ? 'z-playoff' : t.pos <= f.auto + f.playoff ? 'z-relegation_playoff' : ''}"${t.ours ? ' style="background:rgba(250,204,21,0.10);"' : ''}>
            <td>${t.pos}</td><td style="text-align:left; white-space:normal; font-weight:700;">${esc(t.name)}</td><td>${t.p}</td><td><b>${t.pts}</b></td><td>${t.xpts}</td>
            <td title="${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))}">${t.rating.toFixed(2)}</td>
            <td>${this._heat(t.first, false)}</td><td>${this._heat(t.playoff, false)}</td><td>${this._heat(t.up, false)}</td></tr>`).join('')}</tbody>
        </table></div>`;
    }
    return html;
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

  // 🎚 What if (owner 11/17 "add a slider to set our strength on the
  // page"): the team's strength (attack ÷ defence, 1.00 = average) on a log
  // scale from the weakest side to the strongest, the other teams marked;
  // let go → the whole season replayed with that strength (server side,
  // ?team=&rating=).  Reset = the strength its results give.
  _sliderRange(base) {
    const r = base.divisions.flatMap((dv) => dv.teams.map((t) => t.rating)).filter((x) => x > 0);
    return { lo: Math.min(...r) * 0.8, hi: Math.max(...r) * 1.1 };
  }
  _toSlider(base, v) { const { lo, hi } = this._sliderRange(base); return Math.round(1000 * Math.log(v / lo) / Math.log(hi / lo)); }
  _fromSlider(base, s) { const { lo, hi } = this._sliderRange(base); return lo * Math.pow(hi / lo, s / 1000); }
  _nearestTeam(base, v, id) {
    let best = null;
    for (const dv of base.divisions) for (const t of dv.teams) if (t.id !== id && (!best || Math.abs(Math.log(t.rating / v)) < Math.abs(Math.log(best.rating / v)))) best = t;
    return best;
  }
  _sliderLabel(base, v, id) {
    const n = this._nearestTeam(base, v, id);
    return this._copy('fc_slider_value', { rating: v.toFixed(2), team: n ? n.name : '', team_rating: n ? n.rating.toFixed(2) : '' });
  }
  _sliderHtml(base, id) {
    const esc = (x) => this._esc(x);
    const t0 = this._teamsById(base).get(id);
    if (!t0) return '';
    const w = this.whatIf && this.whatIf.team === id && this.whatIf.conf === this.conf ? this.whatIf : null;
    const v = w ? w.rating : t0.rating;
    const ticks = base.divisions.flatMap((dv) => dv.teams).filter((t) => t.id !== id)
      .map((t) => `<option value="${this._toSlider(base, t.rating)}" label="${esc(t.name)}"></option>`).join('');
    const status = w && w.loading ? this._copy('fc_slider_busy') : w && w.error ? w.error : w ? this._copy('fc_slider_on', { base: t0.rating.toFixed(2) }) : this._copy('fc_slider_off');
    return `<div style="margin:8px 0; padding:8px 12px; border-radius:10px; border:1px solid #38bdf8; background:rgba(56,189,248,0.08);">
        <div style="display:flex; justify-content:space-between; gap:8px; flex-wrap:wrap; font-size:0.82rem; font-weight:800;">
          <span>🎚 ${esc(this._copy('fc_slider'))}</span>
          ${w ? `<button class="ap-pill" data-fc-reset style="padding:1px 10px; font-size:0.75rem;">${esc(this._copy('fc_slider_reset'))}</button>` : ''}
        </div>
        <input type="range" min="0" max="1000" step="1" value="${this._toSlider(base, v)}" data-fc-slider="${id}" list="fc-ticks" style="width:100%; margin:6px 0 2px;">
        <datalist id="fc-ticks">${ticks}</datalist>
        <div data-fc-slider-label style="font-size:0.8rem;">${esc(this._sliderLabel(base, v, id))}</div>
        <div style="font-size:0.72rem; opacity:0.75; margin-top:2px;">${esc(status)}</div>
      </div>`;
  }
  async _runWhatIf(id, rating) {
    const conf = this.conf;
    this.whatIf = { team: id, conf, rating, loading: true, data: this.whatIf && this.whatIf.team === id ? this.whatIf.data : null };
    this._repaint();
    const seq = (this._wiSeq = (this._wiSeq || 0) + 1);
    try {
      const r = await fetch(`/api/pyramid/forecast?conference=${encodeURIComponent(conf)}&team=${encodeURIComponent(id)}&rating=${encodeURIComponent(rating.toFixed(3))}`);
      const j = await r.json().catch(() => ({}));
      if (seq !== this._wiSeq) return;
      this.whatIf = r.ok ? { team: id, conf, rating, data: j } : { team: id, conf, rating, error: j.error || `HTTP ${r.status}` };
    } catch (e) {
      if (seq !== this._wiSeq) return;
      this.whatIf = { team: id, conf, rating, error: e.message };
    }
    this._repaint();
  }

  // ⭐ Target (owner 11/17: 6th = "totally safe" … "that is our north
  // star"): the last place above every relegation place, the points it
  // usually ends on, and what that asks of this team's games left.
  _targetHtml(t) {
    const dv = t.division, esc = (x) => this._esc(x);
    const down = (pos) => (dv.zones || []).some((z) => /relegation/.test(z.kind) && pos >= z.from && pos <= z.to);
    let place = 0; for (let p = 1; p <= dv.teams.length; p++) if (!down(p)) place = p;
    const pl = (dv.places || [])[place - 1];
    if (!place || !pl) return '';
    const th = (n) => `${n}${['st', 'nd', 'rd'][n - 1] || 'th'}`;
    const need = Math.max(0, pl.p50 - t.pts), wins = Math.ceil(need / 3);
    const words = need <= 0
      ? this._copy('fc_target_done', { place: th(place), pts: pl.p50 })
      : this._copy('fc_target', { place: th(place), pts: pl.p50, lo: pl.p10, hi: pl.p90, need, left: t.left, wins });
    const ok = need <= 3 * t.left;
    return `<div style="margin:6px 0; padding:8px 12px; border-radius:10px; border:1px solid #facc15; background:rgba(250,204,21,0.10); font-size:0.86rem;">
        <b>⭐ ${esc(words)}</b>${ok ? '' : ` <span style="color:#fca5a5;">${esc(this._copy('fc_target_out'))}</span>`}</div>`;
  }

  // ⛳ Points each place finishes on (owner 11/17 "what is probable point
  // total of 6th place in div b" → "give me % spread" → "put that on site
  // too"): per place the likely total, the 80% range, a bar per points
  // total; tap the bars for every total with its chance and the chance of
  // that many or more.
  _placesHtml(dv) {
    if (!dv.places || !dv.places.length) return '';
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v));
    const lo = Math.min(...dv.places.map((p) => (p.spread[0] || [0])[0]));
    const hi = Math.max(...dv.places.map((p) => (p.spread[p.spread.length - 1] || [0])[0]));
    const W = 220, H = 26, span = Math.max(1, hi - lo + 1), bw = W / span;
    const max = Math.max(...dv.places.flatMap((p) => p.spread.map((x) => x[1])), 0.001);
    const rows = dv.places.map((p) => {
      const color = this._barColor(dv, p.pos);
      const bars = p.spread.map(([pts, v]) => `<rect x="${((pts - lo) * bw).toFixed(1)}" y="${(H - H * v / max).toFixed(1)}" width="${Math.max(1, bw - 1).toFixed(1)}" height="${(H * v / max).toFixed(1)}" fill="${color}"><title>${pts} pts · ${esc(PyramidForecastView.pct(v))}</title></rect>`).join('');
      let atLeast = 1;
      const chips = p.spread.map(([pts, v]) => { const c = `<span>${pts}: ${P(v)} <small style="opacity:0.65;">≥${P(atLeast)}</small></span>`; atLeast -= v; return c; }).join('');
      return `<tr><td>${p.pos}</td><td><b>${p.p50}</b></td><td>${p.p10}–${p.p90}</td>
        <td style="text-align:left; white-space:normal;"><details><summary style="list-style:none; cursor:pointer;"><svg width="${W}" height="${H}" viewBox="0 0 ${W} ${H}" style="vertical-align:middle;">${bars}</svg></summary>
          <div class="fc-scores" style="margin:4px 0 6px;">${chips}</div></details></td></tr>`;
    }).join('');
    return `<div class="fc-note" style="margin-top:8px; font-weight:700; opacity:0.9;">${esc(this._copy('fc_places', { from: lo, to: hi }))}</div>
      <div style="overflow-x:auto;"><table class="fc-table" style="max-width:560px;">
        <thead><tr><th>#</th><th>${esc(this._copy('fc_places_likely'))}</th><th>${esc(this._copy('fc_places_range'))}</th><th style="text-align:left;">${esc(this._copy('fc_places_spread'))}</th></tr></thead>
        <tbody>${rows}</tbody></table></div>`;
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

  _teamHtml(d, id, base) {
    base = base || d;
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
        ${hasDown ? big(this._copy('fc_col_safe'), PyramidForecastView.safe(t), false) + big(this._copy('fc_col_relplay'), t.rel_playoff, true) + big(this._copy('fc_col_down'), t.down, true) : ''}
        <div><b>${t.xpts}</b><small>${esc(this._copy('fc_col_xpts'))} (${t.left} left)</small></div>
      </div>
      ${path ? `<div class="fc-note" style="opacity:0.9;">${esc(path)}</div>` : ''}
      ${this._sliderHtml(base, id)}
      ${hasDown ? this._targetHtml(t) : ''}
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
      if (e.target.closest('[data-fc-reset]')) { this.whatIf = null; this._wiSeq = (this._wiSeq || 0) + 1; this._repaint(); return; }
      if (e.target.closest('[data-fc-back]')) { this.team = null; this._repaint(); }
    };
    root.addEventListener('click', this._onClick);
    // the slider: the label follows the thumb; letting go replays the season
    this._onInput = (e) => {
      const sl = e.target.closest('[data-fc-slider]'); if (!sl) return;
      const base = this.data.get(this.conf); if (!base) return;
      const lab = root.querySelector('[data-fc-slider-label]');
      if (lab) lab.textContent = this._sliderLabel(base, this._fromSlider(base, Number(sl.value)), Number(sl.dataset.fcSlider));
    };
    this._onChange = (e) => {
      const sl = e.target.closest('[data-fc-slider]'); if (!sl) return;
      const base = this.data.get(this.conf); if (!base) return;
      this._runWhatIf(Number(sl.dataset.fcSlider), this._fromSlider(base, Number(sl.value)));
    };
    root.addEventListener('input', this._onInput);
    root.addEventListener('change', this._onChange);
    this._root = root;
    this._load(this.conf);
  }

  unmount() {
    if (this._root && this._onClick) this._root.removeEventListener('click', this._onClick);
    if (this._root && this._onInput) { this._root.removeEventListener('input', this._onInput); this._root.removeEventListener('change', this._onChange); }
    this._root = null;
  }
}
window.PyramidForecastView = PyramidForecastView;
