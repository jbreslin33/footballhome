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
    // A shared link (mig 1575): /?fc=<conference>&focus=<team>#apsl-pyramid
    // mig 1577: fc=all = every conference; ff=<name> = a feeder team marked
    const q = new URLSearchParams(window.location.search || '');
    this.section = PyramidForecastView.SECTIONS.includes(q.get('s')) ? q.get('s') : 'story';
    this.feederPick = null;
    this.form = null;   // 📅 recent form (mig 1772): null = the conference's own, else { unit, n }
    if (q.get('fc') === 'all') this.conf = 0;
    else if (Number(q.get('fc'))) { this.conf = Number(q.get('fc')); this.team = Number(q.get('focus')) || null; this.feederFocus = q.get('ff') || null; }
  }

  // 🔗 the link to what's on screen — the conference, and the team if one is open
  _shareUrl() {
    const sec = this.section && this.section !== 'story' ? `&s=${this.section}` : '';
    if (this.conf === 0) return `${window.location.origin}/?fc=all${sec}#apsl-pyramid`;
    return `${window.location.origin}/?fc=${this.conf}${this.team ? `&focus=${this.team}` : ''}${!this.team && this.feederFocus ? `&ff=${encodeURIComponent(this.feederFocus)}` : ''}${sec}#apsl-pyramid`;
  }
  _shareHtml() {
    return `<button class="ap-pill" data-fc-share style="float:right; margin-left:8px;">${this._esc(this._copy('fc_share'))}</button>`;
  }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens) || ''; }
  static pct(v) { const p = 100 * (v || 0); return p > 0 && p < 0.5 ? '<1%' : p > 99.5 && p < 100 ? '>99%' : `${Math.round(p)}%`; }
  static odds(p) { return p > 0 ? (1 / p >= 100 ? `${Math.round(1 / p)}` : (1 / p).toFixed(2)) : '—'; }

  static css() {
    return `
      .fc-wrap { max-width:1440px; margin:0 auto; }
      .fc-cols { display:grid; grid-template-columns:repeat(auto-fit, minmax(min(100%, 560px), 1fr)); gap:4px 22px; align-items:start; }
      .fc-mini { display:grid; grid-template-columns:repeat(auto-fit, minmax(min(100%, 300px), 1fr)); gap:12px; }
      .fc-mini .fc-table td, .fc-mini .fc-table th { padding:3px 5px; font-size:0.76rem; }
      .fc-sub { display:flex; gap:6px; flex-wrap:wrap; margin:0 0 8px; }
      .fc-sub .ap-pill { font-size:0.78rem; padding:3px 10px; }
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

  // 0 = every conference; else the one picked; else the first (no home side).
  _pickConf(confs) {
    if (this.conf === 0) return 0;
    if (this.conf && confs.some((c) => c.id === this.conf)) return this.conf;
    return (confs[0] || {}).id || null;
  }

  // 🔎 Every APSL team and every feeder team (a table linked up into a
  // conference; a table feeding two goes by the pyramid's outlier rows).
  _focusList() {
    const m = this.screen.model;
    if (!m) return [];
    const out = [];
    const confName = (id) => { const c = m.comp(id); return c ? (c.short_name || c.name) : ''; };
    for (const d of m.divisions) {
      const c = m.comp(d.competition_id);
      if (c && c.kind === 'conference') for (const t of d.teams || []) out.push({ label: `${t.name} — ${confName(c.id)}`, conf: c.id, team: t.id });
      const ups = (m.links || []).filter((l) => l.lower === d.id && l.promotes && l.upper_competition && (m.comp(l.upper_competition) || {}).kind === 'conference');
      if (!ups.length) continue;
      for (const t of d.teams || []) {
        const l = ups.find((x) => (x.outlier_teams || []).includes(t.id)) || ups.find((x) => !(x.outlier_teams || []).length) || ups[0];
        out.push({ label: `${t.name} — ${confName(d.competition_id)} ${d.name} → ${confName(l.upper_competition)}`, conf: l.upper_competition, feeder: t.name });
      }
    }
    return out.sort((a, b) => a.label.localeCompare(b.label));
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    this.confs = confs;
    this.conf = this._pickConf(confs);
    const pills = `<button class="ap-pill ${this.conf === 0 ? 'on' : ''}" data-fc-conf="0">${esc(this._copy('fc_all'))}</button>`
      + confs.map((c) => `<button class="ap-pill ${c.id === this.conf ? 'on' : ''}" data-fc-conf="${c.id}">${esc(c.short_name || c.name)}</button>`).join('');
    this._focus = this._focusList();
    return `<div class="fc-wrap" data-fc-root>
        <div class="fc-confs" style="align-items:center;"><input class="fc-focus" data-fc-focus list="fc-focus-list" placeholder="${esc(this._copy('fc_focus'))}"
          style="width:min(300px, 100%); padding:5px 12px; border-radius:999px; font-size:0.85rem;">
          <datalist id="fc-focus-list">${this._focus.map((f) => `<option value="${esc(f.label)}">`).join('')}</datalist>${pills}</div>
        <div data-fc-body>${this._bodyHtml()}</div>
      </div>`;
  }

  // ── layout (mig 1578, owner 11/19 "too much right now on one pill … we
  // need more pills. matchup pills for all or 1 team … standings predictions
  // thus relegation spots and percents. feeder focus so feeders should have
  // pills … its really a presentation"): scope on top (🇺🇸 all / a
  // conference / one team), then section pills, then that section only.
  static get SECTIONS() { return ['story', 'table', 'games', 'updown', 'feeders']; }
  _bodyHtml() {
    const esc = (x) => this._esc(x);
    let d = null, t = null, base = null;
    if (this.conf === 0) {
      const confs = this.confs || [];
      const got = confs.map((c) => this.data.get(c.id)).filter((x) => x && !x.error && x.divisions);
      if (got.length < confs.length) return LoadProgress.html({ done: got.length, total: confs.length, what: this._copy('fc_all') });
      this._all = got;
    } else {
      base = this.data.get(this.conf);
      if (!base) return `<div class="loading">Loading…</div>`;
      if (base.error) return `<div class="error">${esc(base.error)}</div>`;
      if (!base.games || !base.games.length) return `<div class="fc-none">${esc(this._copy('fc_none'))}</div>`;
      const w = this.team && this.whatIf && this.whatIf.team === this.team && this.whatIf.conf === this.conf ? this.whatIf : null;
      d = w && w.data ? w.data : base;
      t = this.team ? this._teamsById(d).get(this.team) : null;
      if (this.team && !t) this.team = null;
    }
    const hasFeeders = this.conf === 0 ? this._all.some((x) => ((x.outlook || {}).feeders || []).length) : ((base.outlook || {}).feeders || []).length > 0;
    const secs = PyramidForecastView.SECTIONS.filter((k) => k !== 'feeders' || (hasFeeders && !t));
    if (!secs.includes(this.section)) this.section = 'story';
    const title = this.conf === 0 ? this._copy('story_nat_title')
      : t ? `${t.name} · ${this._groupName(d, t.division)}` : this._copy('fc_title', { conf: d.conference.name, sims: Number(d.sims).toLocaleString() });
    const head = `${this._shareHtml()}${t ? `<button class="ap-pill" data-fc-back style="margin:0 8px 6px 0;">${esc(this._copy('fc_back'))}</button>` : ''}
      <h3 style="margin:4px 0 8px; font-size:1.15rem;">${esc(title)}</h3>
      <div class="fc-confs" style="margin-bottom:12px;">${secs.map((k) => `<button class="ap-pill ${this.section === k ? 'on' : ''}" data-fc-sec="${k}">${esc(this._copy(`fc_sec_${k}`))}</button>`).join('')}</div>
      ${this._formHtml(this.conf === 0 ? this._all[0] : base)}`;
    let body;
    if (this.conf === 0) body = this._allSection(this._all);
    else if (t) body = this._teamSection(d, t, base);
    else body = this._confSection(d);
    return head + body;
  }

  _confSection(d) {
    const esc = (x) => this._esc(x);
    switch (this.section) {
      case 'table': {
        const pts = this.tableView === 'points';
        const sub = `<div class="fc-sub"><button class="ap-pill ${!pts ? 'on' : ''}" data-fc-tview="odds">${esc(this._copy('fc_tview_odds'))}</button><button class="ap-pill ${pts ? 'on' : ''}" data-fc-tview="points">${esc(this._copy('fc_tview_points'))}</button></div>`;
        return `${sub}<div class="fc-cols">${d.divisions.map((dv) => `<div>${pts ? (d.divisions.length > 1 ? `<div class="fc-note" style="font-weight:800; opacity:1;">${esc(this._groupName(d, dv))}</div>` : '') + this._placesHtml(dv) : this._divTableHtml(d, dv)}</div>`).join('')}</div>
          ${pts ? '' : `<div class="fc-note">${esc(this._copy('fc_tap_team'))}</div>`}`;
      }
      case 'games': { const up = this._upcoming(d); return up.length ? this._matchupsHtml(up.map((g) => ({ d, g }))) : `<div class="fc-none">${esc(this._copy('story_no_games'))}</div>`; }
      case 'updown': return `<div class="fc-cols"><div>${this._seasonsHtml(d)}</div><div>${this._dangerHtml(d)}</div></div>`;
      case 'feeders': return this._storyBox(this._feederFocusLines(d)) + this._feedersHtml(d);
      default: return this._storyBox(this._feederFocusLines(d).concat(this._confStory(d)));
    }
  }

  _teamSection(d, t, base) {
    const esc = (x) => this._esc(x), P = (v) => esc(PyramidForecastView.pct(v)), Pt = PyramidForecastView.pct;
    const hasDown = (t.division.zones || []).some((z) => /relegation/.test(z.kind));
    const big = (label, v, bad) => `<div style="${bad && v > 0.5 ? 'background:rgba(220,38,38,0.25);' : !bad && v > 0.5 ? 'background:rgba(34,197,94,0.22);' : ''}"><b>${P(v)}</b><small>${esc(label)}</small></div>`;
    const bigs = `<div class="fc-big">
        ${big(this._copy('fc_col_first'), t.pos_pct[0], false)}${big(this._copy('fc_col_playoff'), t.zones.playoff || 0, false)}
        ${hasDown ? big(this._copy('fc_col_safe'), PyramidForecastView.safe(t), false) + big(this._copy('fc_col_down'), t.down, true) : ''}
        <div><b>${t.xpts}</b><small>${esc(this._copy('fc_col_xpts'))} (${t.left} left)</small></div></div>`;
    switch (this.section) {
      case 'table': {
        const bars = t.pos_pct.map((p, i) => `<div><span>${i + 1}${['st', 'nd', 'rd'][i] || 'th'}</span><i style="width:${Math.max(0.3, 100 * p)}%; background:${this._barColor(t.division, i + 1)}"></i><span>${P(p)}</span></div>`).join('');
        return `<div class="fc-cols"><div><h3 style="margin-top:0;">${esc(this._copy('fc_finish'))}</h3><div class="fc-bars">${bars}</div>${hasDown ? this._targetHtml(t) : ''}</div><div>${this._divTableHtml(d, t.division, t.id)}</div></div>`;
      }
      case 'games': {
        const by = this._teamsById(d), id = t.id;
        const upcoming = this._upcoming(d).filter((g) => g.home === id || g.away === id);
        const results = d.games.filter((g) => g.done && (g.home === id || g.away === id)).map((g) => {
          const home = g.home === id, us = home ? g.hs : g.as, them = home ? g.as : g.hs, o = by.get(home ? g.away : g.home) || {};
          const wl = us > them ? ['W', '#22c55e'] : us < them ? ['L', '#dc2626'] : ['D', '#94a3b8'];
          return `<div class="fc-result"><span>${esc(this._when(g.when))} · ${home ? 'vs' : '@'} <span data-fc-team="${o.id}" style="cursor:pointer; text-decoration:underline dotted;">${esc(o.name)}</span></span>
            <span><b>${us}–${them}</b> <span class="wl" style="background:${wl[1]}; color:#fff; padding:0 5px;">${wl[0]}</span></span></div>`;
        }).join('');
        return `${upcoming.length ? `<h3>${esc(this._copy('fc_upcoming'))}</h3><div class="fc-bets">${upcoming.map((g) => this._betHtml(d, g, id)).join('')}</div>` : ''}
          ${results ? `<h3>${esc(this._copy('fc_results'))}</h3><div>${results}</div>` : ''}`;
      }
      case 'updown': {
        const auto = (t.zones.relegation || 0) + (t.zones.conditional_relegation || 0);
        const path = hasDown ? (d.policy && d.policy.feeder
          ? this._copy('fc_down_path', { auto: Pt(auto), playoff: Pt(t.lost_playoff), feeder: Pt(t.lost_feeder), feeder_label: d.policy.feeder })
          : this._copy('fc_down_path_nofeed', { auto: Pt(auto), playoff: Pt(t.lost_playoff) })) : '';
        return `<div class="fc-cols"><div>${bigs}${path ? `<div class="fc-note" style="opacity:0.9;">${esc(path)}</div>` : ''}${this._roadHtml(base, t)}</div><div>${this._sliderHtml(base, t.id)}${this._seasonsHtml(base)}</div></div>`;
      }
      default: return `<div class="fc-cols"><div>${this._storyBox(this._teamStory(d, t))}</div><div>${bigs}<div class="fc-note">${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))}</div>${this._roadHtml(base, t)}</div></div>`;
    }
  }

  _allSection(all) {
    const esc = (x) => this._esc(x), P = (v) => esc(PyramidForecastView.pct(v)), n = (v) => String(Math.round(v * 10) / 10);
    const confLink = (d) => `<span class="tm" data-fc-conf="${d.conference.id}" style="cursor:pointer; text-decoration:underline dotted; font-weight:800;">${esc(d.conference.name)}</span>`;
    switch (this.section) {
      case 'table':
        return `<div class="fc-mini">${all.flatMap((d) => d.divisions.map((dv) => `<div><div style="font-size:0.85rem; margin:0 0 2px;">${confLink(d)}${d.divisions.length > 1 ? ` <span style="opacity:0.7;">· ${esc(this._groupName(d, dv))}</span>` : ''}</div>${this._miniTableHtml(d, dv)}</div>`)).join('')}</div>`;
      case 'games': {
        const rows = all.flatMap((d) => this._upcoming(d).map((g) => ({ d, g })));
        return rows.length ? this._matchupsHtml(rows, true) : `<div class="fc-none">${esc(this._copy('story_no_games'))}</div>`;
      }
      case 'updown': {
        const rows = all.map((d) => {
          const s1 = ((d.outlook || {}).seasons || [])[0];
          const teams = d.divisions.flatMap((dv) => dv.teams);
          const likely = teams.filter((x) => x.down >= 0.5).sort((a, b) => b.down - a.down);
          return `<tr><td style="text-align:left;">${confLink(d)}</td><td>${teams.length}</td><td>${d.divisions.length}</td>
            <td><b>${s1 ? n(s1.down) : '–'}</b></td><td>${s1 ? P(s1.down / s1.teams) : '–'}</td><td>${s1 ? n(s1.up) : '–'}</td>
            <td style="text-align:left; white-space:normal;">${likely.length ? esc(this._list(likely, 'down')) : '<span style="opacity:0.5;">–</span>'}</td></tr>`;
        }).join('');
        return `<div style="overflow-x:auto;"><table class="fc-table fc-rows"><thead><tr><th style="text-align:left;">${esc(this._copy('story_col_conf'))}</th><th>${esc(this._copy('fc_ol_teams'))}</th><th>${esc(this._copy('fc_ol_groups'))}</th>
          <th>${esc(this._copy('fc_ol_down'))}</th><th>${esc(this._copy('fc_ol_down_pct'))}</th><th>${esc(this._copy('fc_ol_up'))}</th><th style="text-align:left;">${esc(this._copy('story_col_likely_down'))}</th></tr></thead><tbody>${rows}</tbody></table></div>`;
      }
      case 'feeders':
        return all.filter((d) => ((d.outlook || {}).feeders || []).length).map((d) => `<h3>${confLink(d)}</h3>${this._feedersHtml(d)}`).join('');
      default: return this._nationalStoryHtml(all);
    }
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

  // 📅 Recent form (migs 1767, 1772; owner 11/23 "just have slider bar"
  // → "toggle for games or weeks and default to games … so everyones last
  // 3 games e.g."): the ratings from each team's last N games, or from the
  // last N weeks' games; the slider's far right = the whole season.  ⭐
  // marks the conference's own; letting go replays every conference.
  _formMax(f, unit) { return Number((f.max || {})[unit]) || 0; }
  _formLabel(f, unit, v) {
    return v >= this._formMax(f, unit) ? this._copy('fc_form_all') : this._copy(unit === 'weeks' ? 'fc_form_weeks' : 'fc_form_games', { n: v });
  }
  // the fade slider (mig 1773): how much each game / week past the window
  // loses on the one after it — 0% = none ("one that is 0 diminish"), 100% =
  // a clean cut.  The forecast speaks in what is kept (form.fade), so 100 − it.
  _fadeLabel(unit, keep) {
    return keep >= 100 ? this._copy('fc_fade_full') : keep <= 0 ? this._copy('fc_fade_none')
      : this._copy(unit === 'weeks' ? 'fc_fade_weeks' : 'fc_fade_games', { pct: 100 - keep });
  }
  _formHtml(d) {
    const f = d && d.form, esc = (x) => this._esc(x);
    if (!f || !f.max) return '';
    const max = this._formMax(f, f.unit);
    if (max < 2) return '';
    const v = Number(f.current) > 0 ? Number(f.current) : max;
    const whole = !(Number(f.current) > 0);
    const own = f.unit === f.default_unit && Number(f.current) === (Number(f.default) >= this._formMax(f, f.default_unit) ? 0 : Number(f.default))
      && (whole || Number(f.fade) === Number(f.default_fade));
    const star = f.unit === f.default_unit && Number(f.default) > 0 && Number(f.default) < max ? Number(f.default) : null;
    return `<div style="margin:0 0 12px; padding:8px 12px; border-radius:10px; border:1px solid rgba(148,163,184,0.35); background:rgba(148,163,184,0.08); max-width:560px;">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap; font-size:0.82rem; font-weight:800;">
          <span>${esc(this._copy('fc_form_label'))}</span>
          <span class="fc-sub" style="margin:0;">${['games', 'weeks'].map((u) => `<button class="ap-pill ${f.unit === u ? 'on' : ''}" data-fc-form-unit="${u}">${esc(this._copy(`fc_form_unit_${u}`))}</button>`).join('')}
            ${own ? '' : `<button class="ap-pill" data-fc-form-reset>${esc(this._copy('fc_form_reset'))}</button>`}</span>
        </div>
        <input type="range" min="1" max="${max}" step="1" value="${v}" data-fc-form="${esc(f.unit)}" list="fc-form-ticks" style="width:100%; margin:6px 0 2px;">
        <datalist id="fc-form-ticks">${star ? `<option value="${star}" label="⭐"></option>` : ''}</datalist>
        <div data-fc-form-label style="font-size:0.8rem;">${esc(this._formLabel(f, f.unit, v))}${own ? ' ⭐' : ''}</div>
        <input type="range" min="0" max="100" step="10" value="${100 - (Number(f.fade) || 0)}" data-fc-fade ${whole ? 'disabled' : ''} style="width:100%; margin:8px 0 2px;${whole ? ' opacity:0.4;' : ''}">
        <div data-fc-fade-label style="font-size:0.8rem;${whole ? ' opacity:0.5;' : ''}">${esc(this._fadeLabel(f.unit, Number(f.fade) || 0))}</div>
        <div style="font-size:0.72rem; opacity:0.75; margin-top:2px;">${esc(this._copy('fc_form_hint'))}</div>
      </div>`;
  }
  // form = null (the conference's own) | { unit: 'games' | 'weeks', n, fade } — n 0 = the whole season, fade in %
  _setForm(form) {
    this.form = form; this.whatIf = null; this._wiSeq = (this._wiSeq || 0) + 1;
    this.data.clear(); this._load(this.conf);
  }
  _formNow() { const d = this.conf === 0 ? (this._all || [])[0] : this.data.get(this.conf); return d && d.form; }
  _formQuery() { return this.form ? `&form_unit=${encodeURIComponent(this.form.unit)}&form=${encodeURIComponent(this.form.n)}&form_fade=${encodeURIComponent(this.form.fade)}` : ''; }

  _howHtml(d) {
    const m = d.model || {};
    const parts = [this._copy('fc_how', { games: d.played, left: d.left, avg: m.avg_goals, home: m.home_edge })];
    if (d.form && Number(d.form.current) > 0) parts.push(`${this._formLabel(d.form, d.form.unit, Number(d.form.current))}; ${this._fadeLabel(d.form.unit, Number(d.form.fade) || 0)}.`);   // migs 1772, 1773
    const f = d.format || {};
    if (f.group_rounds) parts.unshift(this._copy('fc_format', { n: f.per_team, rounds: f.group_rounds, cross: f.cross_group_rounds, listed: f.listed, added: f.added }));
    if (d.policy && d.policy.feeder) parts.push(this._copy('fc_feeder_note', { feeder: d.policy.feeder, pct: `${Math.round(d.policy.feeder_stay_up_pct)}%` }));
    if (d.zones_assumed) parts.push(this._copy('fc_zones_assumed'));
    if (d.as_of) parts.push(this._copy('fc_asof', { date: this._when(d.as_of) }));
    parts.push(this._copy('fc_fun'));
    return `<div class="fc-note">${parts.filter(Boolean).map((p) => this._esc(p)).join(' ')}</div>`;
  }

  // 🛣 The road ahead for any team (mig 1575 — the page has no home team):
  // this season from the forecast; with more seasons listed, staying up
  // through the next one at an average side's rate, and the drop-and-
  // come-back-up route when a third season's rules differ.
  _roadHtml(base, t) {
    const seasons = ((base.outlook || {}).seasons) || [];
    if (!seasons.length || !(t.division.zones || []).some((z) => /relegation/.test(z.kind))) return '';
    const esc = (x) => this._esc(x), pct = PyramidForecastView.pct, n = (v) => String(Math.round(v * 10) / 10);
    const [s1, s2, s3] = seasons;
    const label = (x) => (x.every ? this._copy('fc_ol_every') : x.season);
    const lines = [this._copy('fc_ol_road_now', { season: label(s1), down: pct(t.down) })];
    if (s2) {
      const b2 = s2.down / s2.teams;
      lines.push(this._copy('fc_ol_stay', { s1: label(s1), s2: label(s2), base: pct(b2), pct: pct((1 - t.down) * (1 - b2)) }));
      if (s3) lines.push(this._copy('fc_ol_bounce', { s2: label(s2), s3: label(s3), up: n(s1.up), others: n(Math.max(0, s1.down - 1)), s3_down: n(s3.down), s3_teams: s3.teams }));
    } else lines.push(this._copy('fc_ol_road_base', { season: label(s1), pct: pct(s1.down / s1.teams) }));
    return `<div style="margin:8px 0; padding:8px 12px; border-radius:10px; border:1px solid #facc15; background:rgba(250,204,21,0.08); font-size:0.84rem; line-height:1.45;">
        <b>${esc(this._copy('fc_ol_road'))}</b>${lines.filter(Boolean).map((l) => `<div>${esc(l)}</div>`).join('')}</div>`;
  }

  // ── 📖 the story (mig 1578, owner 11/19 "focus on all conf. or one conf.
  // or 1 team in conf. it should tell a story and use numbers. it should be
  // understandable to gen pop"): plain sentences from story_* copy rows,
  // every number from the forecast.
  _storyBox(lines) {
    const ls = (lines || []).filter(Boolean);
    if (!ls.length) return '';
    return `<div style="margin:6px 0 10px; padding:10px 14px; border-radius:12px; border:1px solid rgba(56,189,248,0.45); background:rgba(56,189,248,0.07); font-size:0.95rem; line-height:1.55;">
        ${ls.map((l) => `<p style="margin:0 0 6px;">${this._esc(l)}</p>`).join('')}</div>`;
  }
  _list(teams, key) {
    const P = PyramidForecastView.pct;
    return teams.map((t) => `${t.name} (${P(typeof key === 'function' ? key(t) : t[key])})`).join(', ');
  }
  _groupName(d, dv) {
    // "Delaware River Conference (…) - Group A" → "Group A"; one table → the conference
    // "Mid-Atlantic Conference - Chesapeake (Maryland)" → "Chesapeake"
    if (d.divisions.length < 2) return d.conference.short_name || d.conference.name;
    const tail = String(dv.name || '').split(/\s-\s?|-(?=[A-Z])/).pop().replace(/\s*\(.*\)\s*$/, '').trim();
    return tail || dv.name;
  }
  _confStory(d) {
    const P = PyramidForecastView.pct, lines = [];
    const all = d.divisions.flatMap((dv) => dv.teams.map((t) => ({ ...t, dv })));
    const seasons = ((d.outlook || {}).seasons) || [], s1 = seasons[0];
    const n = (v) => String(Math.round(v * 10) / 10);
    lines.push(this._copy('story_conf_size', { conf: d.conference.name, teams: all.length, groups: d.divisions.length, left: d.left, played: d.played }));
    for (const dv of d.divisions) {
      const fav = dv.teams.reduce((m, t) => (!m || t.pos_pct[0] > m.pos_pct[0] ? t : m), null);
      if (fav) lines.push(this._copy(fav.pos_pct[0] >= 0.95 ? 'story_conf_fav_sure' : 'story_conf_fav', { team: fav.name, group: this._groupName(d, dv), pct: P(fav.pos_pct[0]) }));
    }
    const po = all.filter((t) => (t.zones.playoff || 0) >= 0.5).sort((a, b) => b.zones.playoff - a.zones.playoff);
    if (po.length) lines.push(this._copy('story_conf_playoff', { list: this._list(po, (t) => t.zones.playoff) }));
    if (s1) lines.push(this._copy(s1.down > 0 ? 'story_conf_spots' : 'story_conf_nobody', { down: n(s1.down), teams: s1.teams, pct: P(s1.down / s1.teams) }));
    if (!s1 || s1.down > 0) {
      const sure = all.filter((t) => t.down >= 0.75).sort((a, b) => b.down - a.down);
      const risk = all.filter((t) => t.down >= 0.1 && t.down < 0.75).sort((a, b) => b.down - a.down).slice(0, 4);
      if (sure.length) lines.push(this._copy('story_conf_doomed', { list: this._list(sure, 'down') }));
      if (risk.length) lines.push(this._copy('story_conf_risk', { list: this._list(risk, 'down') }));
    }
    const feeders = ((d.outlook || {}).feeders || []).flatMap((f) => f.teams.filter((t) => !t.skip).map((t) => ({ ...t, feeder: f.label })));
    const up = feeders.sort((a, b) => b.up - a.up).slice(0, 3).filter((t) => t.up >= 0.05);
    if (up.length) lines.push(this._copy('story_conf_up', { list: up.map((t) => `${t.name}, ${t.feeder} (${P(t.up)})`).join('; '), spots: s1 ? n(s1.up) : '' }));
    lines.push(this._copy('story_how', { sims: Number(d.sims).toLocaleString() }));
    return lines;
  }
  _teamStory(d, t) {
    const P = PyramidForecastView.pct, th = (k) => `${k}${['st', 'nd', 'rd'][k - 1] || 'th'}`;
    const lines = [this._copy('story_team_now', { team: t.name, pos: th(t.pos), group: this._groupName(d, t.division), pts: t.pts, p: t.p, w: t.w, d: t.d, l: t.l, left: t.left })];
    const hasDown = (t.division.zones || []).some((z) => /relegation/.test(z.kind));
    lines.push(this._copy(hasDown ? 'story_team_odds' : 'story_team_odds_nodown', { sims: Number(d.sims).toLocaleString(), first: P(t.pos_pct[0]), playoff: P(t.zones.playoff || 0), down: P(t.down), safe: P(PyramidForecastView.safe(t)) }));
    const likely = t.pos_pct.reduce((m, v, i) => (v > t.pos_pct[m] ? i : m), 0);
    lines.push(this._copy('story_team_likely', { pos: th(likely + 1), pct: P(t.pos_pct[likely]), xpts: t.xpts }));
    const next = this._upcoming(d).find((g) => g.home === t.id || g.away === t.id);
    if (next) {
      const home = next.home === t.id, o = this._teamsById(d).get(home ? next.away : next.home) || {};
      const [ph, pd, pa] = next.p, top = (next.scores || [])[0];
      lines.push(this._copy('story_team_next', { opp: o.name || '', where: this._copy(home ? 'story_home' : 'story_away'), when: next.tbs ? this._copy('fc_tbs') : this._when(next.when),
        win: P(home ? ph : pa), draw: P(pd), lose: P(home ? pa : ph), score: top ? (home ? `${top.h}–${top.a}` : `${top.a}–${top.h}`) : '' }));
    }
    return lines;
  }
  _feederFocusLines(d) {
    if (!this.feederFocus) return [];
    const P = PyramidForecastView.pct;
    for (const f of ((d.outlook || {}).feeders || [])) {
      const t = f.teams.find((x) => x.name === this.feederFocus);
      if (!t) continue;
      if (t.skip) return [this._copy('story_feeder_skip', { team: t.name, feeder: f.label, why: t.skip === 'reserve' ? this._copy('fc_ol_skip_reserve') : t.skip === 'conf' ? this._copy('fc_ol_skip_conf', { conf: t.skip_arg || '' }) : this._copy('fc_ol_skip_hand', { reason: t.skip_arg || '' }) })];
      return [this._copy('story_feeder', { team: t.name, feeder: f.label, pts: t.pts, p: t.p, champ: P(t.champ), auto: P(t.auto), up: P(t.up), conf: d.conference.name })];
    }
    return [this._copy('fc_focus_feeder', { team: this.feederFocus, feeder: d.conference.name })];
  }

  // one predicted table (a conference group); focusId marks a row; compact
  // = the every-conference list (fewer columns).
  _divTableHtml(d, dv, focusId, compact) {
    const esc = (t) => this._esc(t);
    const zoneAt = (pos) => ((dv.zones || []).find((z) => pos >= z.from && pos <= z.to) || {}).kind || '';
    const hasRp = (dv.zones || []).some((z) => z.kind === 'relegation_playoff');
    const hasDown = (dv.zones || []).some((z) => /relegation/.test(z.kind));
    const name = d.divisions.length > 1 ? this._groupName(d, dv) : (compact ? '' : dv.name);
    const tm = (t) => `<td class="tm" data-fc-team="${t.id}" data-fc-team-conf="${d.conference.id}">${esc(t.name)}</td>`;
    return `${name ? `<div class="fc-note" style="margin-top:10px; font-weight:800; opacity:1;">${esc(name)}</div>` : ''}
      <div style="overflow-x:auto;"><table class="fc-table">
        <thead><tr><th>#</th><th>${esc(this._copy('fc_col_team'))}</th><th>P</th><th>Pts</th><th>${esc(this._copy('fc_col_xpts'))}</th>
          ${compact ? '' : `<th>${esc(this._copy('fc_col_rating'))}</th>`}<th>${esc(this._copy('fc_col_first'))}</th><th>${esc(this._copy('fc_col_playoff'))}</th>
          ${hasDown && !compact ? `<th>${esc(this._copy('fc_col_safe'))}</th>` : ''}${hasRp && !compact ? `<th>${esc(this._copy('fc_col_relplay'))}</th>` : ''}${hasDown ? `<th>${esc(this._copy('fc_col_down'))}</th>` : ''}</tr></thead>
        <tbody>${dv.teams.map((t) => `<tr class="z-${zoneAt(t.pos)}"${t.id === focusId ? ' style="background:rgba(56,189,248,0.16);"' : ''}>
          <td>${t.pos}</td>${tm(t)}<td>${t.p}</td><td><b>${t.pts}</b></td><td>${t.xpts}</td>
          ${compact ? '' : `<td title="${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))}">${t.rating.toFixed(2)}</td>`}
          <td>${this._heat(t.pos_pct[0], false)}</td><td>${this._heat(t.zones.playoff, false)}</td>
          ${hasDown && !compact ? `<td>${this._heat(PyramidForecastView.safe(t), false)}</td>` : ''}
          ${hasRp && !compact ? `<td>${this._heat(t.rel_playoff, true)}</td>` : ''}
          ${hasDown ? `<td>${this._heat(t.down, true)}</td>` : ''}
        </tr>`).join('')}</tbody>
      </table></div>`;
  }

  // ⬇⬆ the seasons: how many go down / come up, share relegated, size next year
  _seasonsHtml(d) {
    const seasons = ((d.outlook || {}).seasons) || [];
    if (!seasons.length) return '';
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v)), n = (v) => String(Math.round(v * 10) / 10);
    const maxShare = Math.max(...seasons.map((x) => x.down / x.teams), 0.01);
    const groups = seasons.some((x) => (x.divisions || 1) > 1);
    // mig 1583: how that season's relegations happen, from its rule columns
    const th = (k) => `${k}${['st', 'nd', 'rd'][k - 1] || 'th'}`;
    const hows = seasons.some((x) => x.auto_down != null || x.playoff_place != null);
    const how = (x) => {
      const g = x.divisions || 1, per = Math.floor(x.teams / g), letters = Array.from({ length: g }, (_, i) => String.fromCharCode(65 + i));
      const auto = x.auto_down ? Array.from({ length: x.auto_down }, (_, i) => per - i).reverse().map((p) => (g > 1 ? letters.map((l) => `${th(p)} ${l}`).join(' + ') : th(p))).join(' + ') : '';
      if (!x.playoff_place) return auto;
      return this._copy(g > 1 ? 'fc_ol_how_paired' : 'fc_ol_how_single', { auto, rp: th(x.playoff_place) });
    };
    return `<h3>${esc(this._copy('fc_ol_title'))}</h3><div style="overflow-x:auto;"><table class="fc-table" style="max-width:720px;">
      <thead><tr><th>${esc(this._copy('fc_ol_season'))}</th><th>${esc(this._copy('fc_ol_rules'))}</th>${groups ? `<th>${esc(this._copy('fc_ol_groups'))}</th>` : ''}<th>${esc(this._copy('fc_ol_teams'))}</th>
        <th>${esc(this._copy('fc_ol_down'))}</th><th style="text-align:left;">${esc(this._copy('fc_ol_down_pct'))}</th><th>${esc(this._copy('fc_ol_up'))}</th><th>${esc(this._copy('fc_ol_next'))}</th>${hows ? `<th style="text-align:left;">${esc(this._copy('fc_ol_how'))}</th>` : ''}</tr></thead>
      <tbody>${seasons.map((x) => {
        const share = x.down / x.teams;
        return `<tr><td style="text-align:left;"><b>${esc(x.every ? this._copy('fc_ol_every') : x.season)}</b></td><td style="text-align:left; white-space:normal;">${esc(x.rules)}</td>${groups ? `<td>${(x.divisions || 1) > 1 ? Array.from({ length: x.divisions }, (_, i) => String.fromCharCode(65 + i)).join(' · ') : '1'}</td>` : ''}<td>${x.teams}</td>
          <td><b>${n(x.down)}</b></td>
          <td style="text-align:left;"><span style="display:inline-block; vertical-align:middle; height:10px; border-radius:3px; background:#dc2626; width:${Math.round(110 * share / maxShare)}px;"></span> <b>${P(share)}</b></td>
          <td>${n(x.up)}</td><td>${n(x.teams - x.down + x.up)}</td>${hows ? `<td style="text-align:left; white-space:normal; font-size:0.78rem; min-width:220px;">${esc(how(x))}</td>` : ''}</tr>`;
      }).join('')}</tbody></table></div>
      <div class="fc-note">${esc(this._copy('fc_ol_note'))}</div>`;
  }

  // 💀 who goes down: every team by its chance, how it would happen
  _dangerHtml(d) {
    const esc = (t) => this._esc(t);
    const all = d.divisions.flatMap((dv) => dv.teams.map((t) => ({ ...t, dv }))).filter((t) => (t.dv.zones || []).some((z) => /relegation/.test(z.kind)) && t.down >= 0.01);
    if (!all.length) return `<div class="fc-none">${esc(this._copy('story_conf_nobody', {}))}</div>`;
    all.sort((a, b) => b.down - a.down);
    const hasRp = all.some((t) => (t.dv.zones || []).some((z) => z.kind === 'relegation_playoff'));
    return `<h3>${esc(this._copy('story_danger_title'))}</h3><div style="overflow-x:auto;"><table class="fc-table fc-rows" style="max-width:760px;">
      <thead><tr><th style="text-align:left;">${esc(this._copy('fc_col_team'))}</th><th>${esc(this._copy('fc_col_now'))}</th><th>${esc(this._copy('fc_col_safe'))}</th>
        ${hasRp ? `<th>${esc(this._copy('fc_col_relplay'))}</th>` : ''}<th>${esc(this._copy('fc_col_auto'))}</th><th>${esc(this._copy('fc_col_down'))}</th></tr></thead>
      <tbody>${all.map((t) => `<tr><td class="tm" data-fc-team="${t.id}">${esc(t.name)}</td><td>${d.divisions.length > 1 ? `${esc(this._groupName(d, t.dv))} · ` : ''}${t.pos} · ${t.pts} pts</td>
        <td>${this._heat(PyramidForecastView.safe(t), false)}</td>${hasRp ? `<td>${this._heat(t.rel_playoff, true)}</td>` : ''}
        <td>${this._heat((t.zones.relegation || 0) + (t.zones.conditional_relegation || 0), true)}</td><td>${this._heat(t.down, true)}</td></tr>`).join('')}</tbody></table></div>`;
  }

  // 🪜 the feeders: the rules in a sentence, the favourites, a pill per
  // feeder (All feeders first), then each feeder's table.
  _feedersHtml(d) {
    const o = d.outlook || {}, feeders = o.feeders || [], ru = o.rules;
    if (!feeders.length || !ru) return '';
    const esc = (t) => this._esc(t);
    const th = (k) => `${k}${['st', 'nd', 'rd'][k - 1] || 'th'}`;
    const meet = ru.meets_survivor ? this._copy('fc_ol_rules_meet', { pct: PyramidForecastView.pct(ru.win_survivor) }) : '';
    const elig = feeders.flatMap((f) => f.teams.filter((t) => !t.skip));
    const best = (k) => elig.reduce((m, t) => (!m || t[k] > m[k] ? t : m), null);
    const ba = best('auto'), bp = best('win_playoff');
    const pick = this.conf === 0 ? null : this.feederPick;
    const shown = pick ? feeders.filter((f) => f.label === pick) : feeders;
    const pills = this.conf === 0 ? '' : `<div class="fc-sub">${[`<button class="ap-pill ${!pick ? 'on' : ''}" data-fc-feeder="">${esc(this._copy('story_all_feeders'))}</button>`]
      .concat(feeders.map((f) => `<button class="ap-pill ${pick === f.label ? 'on' : ''}" data-fc-feeder="${esc(f.label)}">${esc(f.label)}</button>`)).join('')}</div>`;
    const skipWords = (t) => t.skip === 'reserve' ? this._copy('fc_ol_skip_reserve')
      : t.skip === 'conf' ? this._copy('fc_ol_skip_conf', { conf: t.skip_arg || '' })
      : this._copy('fc_ol_skip_hand', { reason: t.skip_arg || '' });
    let html = `${this._storyBox([this._copy('fc_ol_rules_text', { champ: ru.champion_rank === 1 ? 'champion' : th(ru.champion_rank), meet,
        stage: this._copy(ru.feeder_first ? 'fc_ol_stage_feeder' : 'fc_ol_stage_pooled', { from: th(ru.playoff_from), to: th(ru.playoff_to), losers: ru.losers_in ? this._copy('fc_ol_stage_losers') : '' }) }),
      ba && bp ? this._copy('fc_ol_summary', { auto: `${ba.name} ${PyramidForecastView.pct(ba.auto)}`, po: `${bp.name} ${PyramidForecastView.pct(bp.win_playoff)}` }) : ''])}
      ${pills}<div class="fc-note">${esc(this._copy('fc_ol_feeder_note'))}</div>`;
    if (!pick) {
      // All feeders = who comes up: every eligible side by its chance, the top ten
      const top = feeders.flatMap((f) => f.teams.filter((t) => !t.skip).map((t) => ({ ...t, feeder: f.label }))).sort((x, y) => y.up - x.up).slice(0, 10);
      return html + `<div style="overflow-x:auto;"><table class="fc-table fc-rows" style="max-width:900px;">
        <thead><tr><th style="text-align:left;">${esc(this._copy('fc_col_team'))}</th><th style="text-align:left;">${esc(this._copy('story_col_feeder'))}</th><th>Pts</th>
          <th>${esc(this._copy('fc_ol_col_champ'))}</th><th>${esc(this._copy('fc_ol_col_auto'))}</th><th>${esc(this._copy('fc_ol_col_poin'))}</th><th>${esc(this._copy('fc_ol_col_up'))}</th></tr></thead>
        <tbody>${top.map((t) => `<tr${this.feederFocus === t.name ? ' style="background:rgba(56,189,248,0.18);" data-fc-ffrow' : ''}><td style="text-align:left; font-weight:700;">${esc(t.name)}</td><td style="text-align:left;">${esc(t.feeder)}</td><td>${t.pts}</td>
          <td>${this._heat(t.champ, false)}</td><td>${this._heat(t.auto, false)}</td><td>${this._heat(t.in_playoff, false)}</td><td>${this._heat(t.up, false)}</td></tr>`).join('')}</tbody></table></div>`;
    }
    for (const f of shown) {
      html += `<div class="fc-note" style="margin-top:10px; font-weight:800; opacity:1;">${esc(f.label)} <span style="opacity:0.6; font-weight:600;">· ${f.played} played, ${f.left} to go</span></div>
        <div style="overflow-x:auto;"><table class="fc-table">
          <thead><tr><th>${esc(this._copy('fc_ol_col_rank'))}</th><th>${esc(this._copy('fc_col_team'))}</th><th>P</th><th>Pts</th><th>${esc(this._copy('fc_col_xpts'))}</th>
            <th>${esc(this._copy('fc_col_rating'))}</th><th>${esc(this._copy('fc_ol_col_champ'))}</th><th>${esc(this._copy('fc_ol_col_auto'))}</th>${ru.feeder_first ? `<th>${esc(this._copy('fc_ol_col_fwin'))}</th>` : ''}
            <th>${esc(this._copy('fc_ol_col_poin'))}</th><th>${esc(this._copy('fc_ol_col_powin'))}</th><th>${esc(this._copy('fc_ol_col_up'))}</th></tr></thead>
          <tbody>${f.teams.map((t) => {
            const cls = t.skip ? '' : t.elig === ru.champion_rank ? 'z-playoff' : t.elig >= ru.playoff_from && t.elig <= ru.playoff_to ? 'z-relegation_playoff' : '';
            const style = this.feederFocus === t.name ? ' style="background:rgba(56,189,248,0.18); outline:2px solid #38bdf8;" data-fc-ffrow' : t.skip ? ' style="opacity:0.45;"' : '';
            return `<tr class="${cls}"${style}>
              <td>${t.elig || '–'}</td><td style="text-align:left; white-space:normal; font-weight:700;">${esc(t.name)}${t.skip ? ` <small style="font-weight:600;">· ${esc(skipWords(t))}</small>` : ''}</td>
              <td>${t.p}</td><td><b>${t.pts}</b></td><td>${t.xpts}</td>
              <td title="${esc(this._copy('fc_strength', { att: t.att.toFixed(2), def: t.def.toFixed(2) }))}">${t.rating.toFixed(2)}</td>
              ${t.skip ? '<td></td>'.repeat(ru.feeder_first ? 6 : 5) : `<td>${this._heat(t.champ, false)}</td><td>${this._heat(t.auto, false)}</td>${ru.feeder_first ? `<td>${this._heat(t.feeder_po, false)}</td>` : ''}<td>${this._heat(t.in_playoff, false)}</td><td>${this._heat(t.win_playoff, false)}</td><td>${this._heat(t.up, false)}</td>`}</tr>`;
          }).join('')}</tbody>
        </table></div>`;
    }
    return html;
  }

  // 🇺🇸 the national story, then a card per conference (tap → that conference)
  _nationalStoryHtml(got) {
    const esc = (x) => this._esc(x), P = PyramidForecastView.pct;
    const teams = got.reduce((a, d) => a + d.divisions.reduce((b, dv) => b + dv.teams.length, 0), 0);
    const left = got.reduce((a, d) => a + (d.left || 0), 0);
    const down = got.reduce((a, d) => a + d.divisions.reduce((b, dv) => b + dv.teams.reduce((c, t) => c + (t.down || 0), 0), 0), 0);
    const head = [this._copy('story_nat_head', { confs: got.length, teams, left, down: String(Math.round(down * 10) / 10) })];
    const cards = got.map((d) => {
      const all = d.divisions.flatMap((dv) => dv.teams);
      const fav = all.reduce((m, t) => (!m || t.pos_pct[0] > m.pos_pct[0] ? t : m), null);
      const risk = all.slice().sort((a, b) => b.down - a.down)[0];
      const s1 = ((d.outlook || {}).seasons || [])[0];
      const lines = [
        fav ? this._copy('story_card_fav', { team: fav.name, pct: P(fav.pos_pct[0]) }) : '',
        risk && risk.down >= 0.05 ? this._copy('story_card_risk', { team: risk.name, pct: P(risk.down) }) : this._copy('story_card_safe'),
        s1 ? this._copy('story_card_spots', { down: String(Math.round(s1.down * 10) / 10), teams: s1.teams }) : '',
      ].filter(Boolean);
      return `<div class="fc-bet" data-fc-conf="${d.conference.id}" style="cursor:pointer;">
          <div class="teams"><span>${esc(d.conference.name)}</span><span style="opacity:0.6; font-weight:600;">${all.length}</span></div>
          ${lines.map((l) => `<div style="font-size:0.85rem; margin-top:4px;">${esc(l)}</div>`).join('')}</div>`;
    }).join('');
    return `${this._storyBox(head.concat([this._copy('story_how', { sims: Number((got[0] || {}).sims || 10000).toLocaleString() })]))}
      <div class="fc-note">${esc(this._copy('story_nat_tap'))}</div>
      <div class="fc-bets">${cards}</div>`;
  }

  // a conference table in a few columns (the every-conference grid)
  _miniTableHtml(d, dv) {
    const esc = (t) => this._esc(t);
    const zoneAt = (pos) => ((dv.zones || []).find((z) => pos >= z.from && pos <= z.to) || {}).kind || '';
    const hasDown = (dv.zones || []).some((z) => /relegation/.test(z.kind));
    return `<table class="fc-table"><thead><tr><th>#</th><th>${esc(this._copy('fc_col_team'))}</th><th>Pts</th><th>${esc(this._copy('fc_col_first'))}</th>${hasDown ? `<th>${esc(this._copy('fc_col_down'))}</th>` : ''}</tr></thead>
      <tbody>${dv.teams.map((t) => `<tr class="z-${zoneAt(t.pos)}"><td>${t.pos}</td><td class="tm" data-fc-team="${t.id}" data-fc-team-conf="${d.conference.id}">${esc(t.name)}</td><td><b>${t.pts}</b></td>
        <td>${this._heat(t.pos_pct[0], false)}</td>${hasDown ? `<td>${this._heat(t.down, true)}</td>` : ''}</tr>`).join('')}</tbody></table>`;
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
      const r = await fetch(`/api/pyramid/forecast?conference=${encodeURIComponent(conf)}&team=${encodeURIComponent(id)}&rating=${encodeURIComponent(rating.toFixed(3))}${this._formQuery()}`);
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
  // 🎯 matchups by week (owner 11/19 "each pill should do one thing well …
  // scrolling is not really needed"): This week / Next week / Later / Not
  // scheduled yet, one at a time.  rows = [{d, g}] — one conference or many.
  _weekOf(g) {
    if (g.tbs || !g.when) return 'tbs';
    const now = new Date(), mon = new Date(now.getFullYear(), now.getMonth(), now.getDate() - ((now.getDay() + 6) % 7));
    const next = new Date(mon.getTime() + 7 * 864e5), after = new Date(mon.getTime() + 14 * 864e5), w = new Date(g.when);
    return w < next ? 'week' : w < after ? 'next' : 'later';
  }
  _matchupsHtml(rows, multi) {
    const esc = (t) => this._esc(t), P = (v) => esc(PyramidForecastView.pct(v)), O = PyramidForecastView.odds;
    const buckets = ['week', 'next', 'later', 'tbs'], count = {};
    for (const r of rows) { const k = this._weekOf(r.g); count[k] = (count[k] || 0) + 1; }
    let pick = buckets.includes(this.weekPick) && count[this.weekPick] ? this.weekPick : buckets.find((k) => count[k]);
    const list = rows.filter((r) => this._weekOf(r.g) === pick).sort((x, y) => String(x.g.when).localeCompare(String(y.g.when)));
    const cell = (p, fav) => `<td><span class="fc-heat" style="${fav ? 'background:rgba(34,197,94,0.3);' : 'background:rgba(148,163,184,0.12);'}">${P(p)}</span><br><small style="opacity:0.7;">${O(p)}</small></td>`;
    const body = list.map(({ d, g }) => {
      const by = this._teamsById(d), h = by.get(g.home) || {}, a = by.get(g.away) || {}, [ph, pd, pa] = g.p, fav = Math.max(ph, pd, pa), top = (g.scores || [])[0];
      const tm = (t, left) => `<td class="tm" data-fc-team="${t.id}" data-fc-team-conf="${d.conference.id}"${left ? ' style="text-align:left;"' : ''}>${esc(t.name)}</td>`;
      return `<tr>
        <td style="text-align:left; white-space:normal; font-size:0.74rem; opacity:0.8;">${esc(g.tbs ? this._copy('fc_tbs') : this._when(g.when))}${multi ? `<br><b>${esc(d.conference.short_name || d.conference.name)}</b>` : ''}</td>
        ${tm(h)}${tm(a, true)}
        ${cell(ph, ph === fav)}${cell(pd, pd === fav)}${cell(pa, pa === fav)}
        <td>${g.xg[0].toFixed(1)}–${g.xg[1].toFixed(1)}</td><td><b>${top ? `${top.h}–${top.a}` : ''}</b></td><td>${P(g.over25)}</td><td>${P(g.btts)}</td></tr>`;
    }).join('');
    return `<div class="fc-sub">${buckets.filter((k) => count[k]).map((k) => `<button class="ap-pill ${k === pick ? 'on' : ''}" data-fc-week="${k}">${esc(this._copy(`fc_week_${k}`))} · ${count[k]}</button>`).join('')}</div>
      <div style="overflow-x:auto;"><table class="fc-table fc-rows">
        <thead><tr><th style="text-align:left;">${esc(this._copy('fc_col_when'))}</th><th>1</th><th style="text-align:left;">2</th>
          <th>1</th><th>${esc(this._copy('fc_draw') || 'X')}</th><th>2</th><th>${esc(this._copy('fc_xg'))}</th><th>${esc(this._copy('fc_likely'))}</th><th>${esc(this._copy('fc_over'))}</th><th>${esc(this._copy('fc_btts'))}</th></tr></thead>
        <tbody>${body}</tbody></table></div>`;
  }

  _barColor(dv, pos) {
    const z = ((dv.zones || []).find((x) => pos >= x.from && pos <= x.to) || {}).kind || '';
    return z === 'playoff' || /promotion/.test(z) ? '#22c55e' : z === 'relegation_playoff' ? '#f97316' : /relegation/.test(z) ? '#dc2626' : '#3b82f6';
  }

  _repaint() {
    const body = this.screen.find('[data-fc-body]');
    if (body) body.innerHTML = this._bodyHtml();
    this.screen.findAll('button[data-fc-conf]').forEach((b) => b.classList.toggle('on', Number(b.dataset.fcConf) === this.conf));
  }

  async _load(id) {
    if (id === 0) { this._repaint(); await Promise.all((this.confs || []).map((c) => this._load(c.id))); if (this.conf === 0) this._repaint(); return; }
    if (!id || this.data.has(id)) { this._repaint(); return; }
    this._repaint();
    try {
      const form = this.form;
      const r = await fetch(`/api/pyramid/forecast?conference=${encodeURIComponent(id)}${this._formQuery()}`);
      const j = await r.json().catch(() => ({}));
      if (form !== this.form) return;   // another level was picked meanwhile
      this.data.set(id, r.ok ? j : { error: j.error || `HTTP ${r.status}` });
    } catch (e) {
      this.data.set(id, { error: e.message });
    }
    if (id === this.conf || this.conf === 0) this._repaint();
    if (id === this.conf && this.feederFocus) requestAnimationFrame(() => { const r = this.screen.find('[data-fc-ffrow]'); if (r) r.scrollIntoView({ block: 'center' }); });
  }

  mount() {
    const root = this.screen.find('[data-fc-root]');
    if (!root) return;
    this._onClick = (e) => {
      const c = e.target.closest('[data-fc-conf]');
      if (c) {
        this.conf = Number(c.dataset.fcConf); this.team = null; this.feederFocus = null; this.feederPick = null;
        try { localStorage.setItem('apsl-forecast-conf', String(this.conf)); } catch (_) { /* private mode */ }
        this._load(this.conf); return;
      }
      const wk = e.target.closest('[data-fc-week]');
      if (wk) { this.weekPick = wk.dataset.fcWeek; this._repaint(); return; }
      const tv = e.target.closest('[data-fc-tview]');
      if (tv) { this.tableView = tv.dataset.fcTview; this._repaint(); return; }
      const sc = e.target.closest('[data-fc-sec]');
      if (sc) { this.section = sc.dataset.fcSec; this._repaint(); return; }
      if (e.target.closest('[data-fc-form-reset]')) { this._setForm(null); return; }
      const fu = e.target.closest('[data-fc-form-unit]');
      if (fu) {   // the other unit, the slider's number kept when it fits
        const f = this._formNow(), unit = fu.dataset.fcFormUnit;
        if (!f || unit === f.unit) return;
        const n = Number(f.current) > 0 && Number(f.current) < this._formMax(f, unit) ? Number(f.current) : 0;
        this._setForm({ unit, n, fade: Number(f.fade) || 0 }); return;
      }
      const fp = e.target.closest('[data-fc-feeder]');
      if (fp) { this.feederPick = fp.dataset.fcFeeder || null; this._repaint(); return; }
      const t = e.target.closest('[data-fc-team]');
      if (t) {
        const tc = Number(t.dataset.fcTeamConf);
        this.team = Number(t.dataset.fcTeam) || null; this.feederFocus = null;
        if (tc && tc !== this.conf) { this.conf = tc; this._load(tc); } else this._repaint();
        root.scrollIntoView({ block: 'start' }); return;
      }
      const sh = e.target.closest('[data-fc-share]');
      if (sh) {
        const url = this._shareUrl();
        const done = () => { sh.textContent = this._copy('fc_shared'); setTimeout(() => { sh.textContent = this._copy('fc_share'); }, 1800); };
        if (navigator.clipboard && navigator.clipboard.writeText) navigator.clipboard.writeText(url).then(done, () => window.prompt('', url));
        else window.prompt('', url);
        return;
      }
      if (e.target.closest('[data-fc-reset]')) { this.whatIf = null; this._wiSeq = (this._wiSeq || 0) + 1; this._repaint(); return; }
      if (e.target.closest('[data-fc-back]')) { this.team = null; this._repaint(); }
    };
    root.addEventListener('click', this._onClick);
    // the slider: the label follows the thumb; letting go replays the season
    this._onInput = (e) => {
      const fs = e.target.closest('[data-fc-form]');
      if (fs) {
        const lab = root.querySelector('[data-fc-form-label]');
        const f = this._formNow();
        if (lab && f) lab.textContent = this._formLabel(f, f.unit, Number(fs.value));
        return;
      }
      const fd = e.target.closest('[data-fc-fade]');
      if (fd) {
        const lab = root.querySelector('[data-fc-fade-label]');
        const f = this._formNow();
        if (lab && f) lab.textContent = this._fadeLabel(f.unit, 100 - Number(fd.value));
        return;
      }
      const sl = e.target.closest('[data-fc-slider]'); if (!sl) return;
      const base = this.data.get(this.conf); if (!base) return;
      const lab = root.querySelector('[data-fc-slider-label]');
      if (lab) lab.textContent = this._sliderLabel(base, this._fromSlider(base, Number(sl.value)), Number(sl.dataset.fcSlider));
    };
    this._onChange = (e) => {
      const fo = e.target.closest('[data-fc-focus]');
      if (fo) {
        const f = (this._focus || []).find((x) => x.label === fo.value);
        if (!f) return;
        fo.value = ''; this.whatIf = null;
        this.conf = f.conf; this.team = f.team || null; this.feederFocus = f.feeder || null; this.feederPick = null;
        if (f.feeder) this.section = 'feeders';
        this._load(this.conf); root.scrollIntoView({ block: 'start' });
        return;
      }
      const fs = e.target.closest('[data-fc-form]');
      if (fs) { const v = Number(fs.value), f = this._formNow() || {}; this._setForm({ unit: fs.dataset.fcForm, n: v >= Number(fs.max) ? 0 : v, fade: Number(f.fade) || 0 }); return; }
      const fd = e.target.closest('[data-fc-fade]');
      if (fd) { const f = this._formNow(); if (f) this._setForm({ unit: f.unit, n: Number(f.current) || 0, fade: 100 - Number(fd.value) }); return; }
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
