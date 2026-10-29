// pyramid-growth-view.js — #apsl-pyramid "Growth by season" (mig 847), a
// view over PyramidModel: how the APSL has grown, season by season, from
// the leagues' own past seasons (TeamPass feeds, read once each).
//
//   Teams by season  stacked bars, one segment per conference.  Colours are
//                    the validated eight-slot categorical set (dataviz
//                    validator, dark surface #111827: all checks pass),
//                    assigned in the conferences' FIXED order — a conference
//                    keeps its colour when pills hide others; conferences
//                    that no longer exist (Northeast) fold into one grey
//                    "Former conferences" series.  2px gaps
//                    between segments, the total labelled on each bar, a
//                    tooltip per segment, a legend.
//   The numbers      the table view (clubs, games too); then other leagues
//                    with past seasons.  (No clubs chart: an APSL club
//                    enters one side, so it would repeat the totals.)
class PyramidGrowthView {
  constructor(screen) { this.screen = screen; }

  // Dark-mode categorical slots 1–8 (dataviz reference palette, validated).
  static SLOTS = ['#3987e5', '#d95926', '#199e70', '#c98500', '#d55181', '#008300', '#9085e9', '#e66767'];
  static OTHER = '#6b7280';   // the folded "Former conferences" series

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .gr-wrap { max-width:900px; margin:0 auto; }
      .gr-wrap h3 { font-size:1rem; margin:18px 0 6px; }
      .gr-legend { display:flex; gap:12px; flex-wrap:wrap; font-size:0.78rem; margin:0 0 6px; }
      .gr-legend i { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:4px; vertical-align:-1px; }
      .gr-svg { width:100%; height:auto; display:block; }
      .gr-svg .grid { stroke:rgba(255,255,255,0.08); stroke-width:1; }
      .gr-svg .axis { fill:var(--text-secondary, #9ca3af); font-size:12px; }
      .gr-svg .total { fill:var(--text-primary, #e5e7eb); font-size:12px; font-weight:700; }
      .gr-svg .seg:hover, .gr-svg .dot:hover { opacity:0.8; }
      .gr-tip { position:fixed; pointer-events:none; background:#0b1220; border:1px solid #374151; border-radius:6px; padding:4px 8px; font-size:0.78rem; z-index:1001; display:none; }
      .gr-table { width:100%; border-collapse:collapse; font-size:0.82rem; }
      .gr-table th, .gr-table td { padding:4px 6px; text-align:right; border-top:1px solid rgba(255,255,255,0.06); }
      .gr-table th:first-child, .gr-table td:first-child { text-align:left; }
      .gr-table th { opacity:0.65; font-weight:700; font-size:0.74rem; }
      .gr-table tr.now td { font-weight:800; }`;
  }

  html(model, confs) {
    const esc = (t) => this._esc(t);
    const root = model.root();
    const seasons = root ? model.leagueSeasons(root.id) : [];
    if (!seasons.length) return `<div class="fc-none">${esc(this._copy('growth_none'))}</div>`;
    const all = model.conferences();
    const slot = new Map(all.map((c, i) => [c.id, PyramidGrowthView.SLOTS[i % PyramidGrowthView.SLOTS.length]]));
    const shown = all.filter((c) => confs.some((x) => x.id === c.id));
    // Former conferences ride along only when every conference is on.
    this.former = !this.screen.on && seasons.some((s) => model.seasonFormer(s) > 0);
    const legend = shown.map((c) => `<span><i style="background:${slot.get(c.id)}"></i>${esc(model.label(c))}</span>`)
      .concat(this.former ? [`<span><i style="background:${PyramidGrowthView.OTHER}"></i>${esc(this._copy('growth_former'))}</span>`] : []).join('');
    const league = model.label(root);
    return `
      <div class="gr-wrap">
        <h3>${esc(this._copy('growth_teams', { league }))}</h3>
        <div class="gr-legend">${legend}</div>
        ${this._stackSvg(model, seasons, shown, slot)}
        <h3>${esc(this._copy('growth_table'))}</h3>
        ${this._table(model, seasons, shown)}
        ${this._others(model)}
        <div class="gr-tip"></div>
      </div>`;
  }

  // Bars share one geometry: W×H viewBox, left gutter for the axis.
  _frame(n, max) {
    const W = 720, H = 300, L = 40, R = 10, T = 22, B = 28;
    const step = (W - L - R) / n, bw = Math.min(70, step * 0.55);
    const top = Math.max(1, Math.ceil(max / 20) * 20);
    const y = (v) => T + (H - T - B) * (1 - v / top);
    const ticks = [0, 0.25, 0.5, 0.75, 1].map((f) => Math.round(top * f));
    const grid = ticks.map((t) => `<line class="grid" x1="${L}" x2="${W - R}" y1="${y(t)}" y2="${y(t)}"/><text class="axis" x="${L - 6}" y="${y(t) + 4}" text-anchor="end">${t}</text>`).join('');
    return { W, H, L, B, step, bw, y, grid, cx: (i) => L + step * i + step / 2 };
  }

  _stackSvg(model, seasons, shown, slot) {
    const esc = (t) => this._esc(t);
    // Series, bottom up: the former conferences (grey), then today's in
    // their fixed order.
    const series = (this.former ? [{ label: this._copy('growth_former'), color: PyramidGrowthView.OTHER, value: (s) => model.seasonFormer(s),
      tipName: (s) => model.seasonFormerNames(s).join(', ') }] : [])
      .concat(shown.map((c) => ({ label: model.label(c), color: slot.get(c.id), value: (s) => model.seasonTeams(s, c.id), tipName: () => model.label(c) })));
    const totals = seasons.map((s) => series.reduce((a, x) => a + x.value(s), 0));
    const f = this._frame(seasons.length, Math.max(...totals));
    const bars = seasons.map((s, i) => {
      let acc = 0;
      const segs = series.map((x) => {
        const v = x.value(s);
        if (!v) return '';
        const y0 = f.y(acc), y1 = f.y(acc + v);
        acc += v;
        const h = Math.max(0, y0 - y1 - 2);   // 2px surface gap between segments
        const tip = this._copy('growth_tip', { conference: x.tipName(s), season: s.name, teams: v });
        return `<rect class="seg" data-tip="${esc(tip)}" x="${f.cx(i) - f.bw / 2}" y="${y1}" width="${f.bw}" height="${h}" rx="2" fill="${x.color}"/>`;
      }).join('');
      return `${segs}<text class="total" x="${f.cx(i)}" y="${f.y(totals[i]) - 6}" text-anchor="middle">${totals[i]}</text>
        <text class="axis" x="${f.cx(i)}" y="${f.H - 8}" text-anchor="middle">${esc(s.name)}</text>`;
    }).join('');
    return `<svg class="gr-svg" viewBox="0 0 ${f.W} ${f.H}" role="img">${f.grid}${bars}</svg>`;
  }

  _table(model, seasons, shown) {
    const esc = (t) => this._esc(t);
    const head = `<tr><th>${esc(this._copy('growth_season'))}</th>${this.former ? `<th>${esc(this._copy('growth_former'))}</th>` : ''}${shown.map((c) => `<th>${esc(model.label(c))}</th>`).join('')}
      <th>${esc(this._copy('growth_total'))}</th><th>${esc(this._copy('growth_clubs_h'))}</th><th>${esc(this._copy('growth_games'))}</th></tr>`;
    const rows = seasons.map((s) => {
      const per = (this.former ? [model.seasonFormer(s)] : []).concat(shown.map((c) => model.seasonTeams(s, c.id)));
      return `<tr class="${s.current ? 'now' : ''}"><td>${esc(s.name)}</td>${per.map((v) => `<td>${v || '—'}</td>`).join('')}
        <td>${per.reduce((a, v) => a + v, 0)}</td><td>${s.clubs}</td><td>${s.games}</td></tr>`;
    }).join('');
    return `<table class="gr-table"><thead>${head}</thead><tbody>${rows}</tbody></table>`;
  }

  // Other leagues with stored seasons (Cosmo): totals per season.
  _others(model) {
    const esc = (t) => this._esc(t);
    const leagues = model.leaguesWithSeasons();
    if (!leagues.length) return '';
    const tables = leagues.map((lg) => {
      const rows = model.leagueSeasons(lg.id).map((s) => `<tr class="${s.current ? 'now' : ''}"><td>${esc(s.name)}</td>
        <td>${s.teams}</td><td>${s.clubs}</td><td>${s.games}</td></tr>`).join('');
      return `<h3>${esc(lg.name)}</h3><table class="gr-table"><thead><tr><th>${esc(this._copy('growth_season'))}</th>
        <th>${esc(this._copy('growth_total'))}</th><th>${esc(this._copy('growth_clubs_h'))}</th><th>${esc(this._copy('growth_games'))}</th></tr></thead><tbody>${rows}</tbody></table>`;
    }).join('');
    return `<h3 style="margin-top:26px;">${esc(this._copy('growth_other'))}</h3>${tables}`;
  }

  mount(root) {
    const tip = root.querySelector('.gr-tip');
    if (!tip) return;
    root.querySelectorAll('[data-tip]').forEach((el) => {
      el.addEventListener('mousemove', (e) => { tip.textContent = el.dataset.tip; tip.style.display = 'block'; tip.style.left = `${e.clientX + 12}px`; tip.style.top = `${e.clientY + 12}px`; });
      el.addEventListener('mouseleave', () => { tip.style.display = 'none'; });
    });
  }

  onResize() {}
  unmount() {}
}
window.PyramidGrowthView = PyramidGrowthView;
