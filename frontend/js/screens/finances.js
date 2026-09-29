// finances.js — #finances: where the club stands and where it is heading
// (migration 489/490).  Billing stays on #payments (owner 2026-09-29:
// "should this all be on separate page(s) including the summary to keep the
// billing part cleaner?").
//
//   Summary    per section + All: members, free, paid up, behind, blocked,
//              owed — GET /api/finances/summary (LeagueApps synced first)
//   Revenue    dues × members per month and year, two reports: every paying
//              member, and only members current in dues
//   Expenses   the cash-flow grid from this month forward: money in (dues
//              from members current in dues), money out (referee fees per
//              home game, league dues, kits), net — GET /api/finances/expenses
//              pulls the league feeds first; ✓ marks what is on an invoice
//
// Wording: message_templates kind 'payments_overview' (summary / revenue)
// and 'finances' (page, pills, cash flow).
class FinancesScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.summary = null; this.expenses = null; this.view = 'summary'; this.err = ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fn-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px; }
        .fn-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .fn-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .fn-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
        .fn-title { font-weight:700; font-size:1rem; }
        .fn-note { opacity:0.7; font-size:0.8rem; margin:2px 0 8px; }
        .fn-table { border-collapse:collapse; font-size:0.85rem; }
        .fn-table th { padding:4px 8px; text-align:right; opacity:0.7; font-weight:600; white-space:nowrap; }
        .fn-table td { padding:4px 8px; text-align:right; white-space:nowrap; }
        .fn-table th:first-child, .fn-table td:first-child { text-align:left; }
        .fn-table tr.sum td { border-top:2px solid var(--border-color, #374151); font-weight:700; }
        .fn-table tr.group td { padding-top:10px; font-weight:800; opacity:0.85; }
        .fn-table td.now { background:rgba(14,165,233,0.10); }
        .fn-in { color:#86efac; } .fn-out { color:#fca5a5; } .fn-dim { opacity:0.5; }
        .fn-tick { font-size:0.7rem; opacity:0.75; display:block; }
        .fn-games { font-size:0.85rem; }
        .fn-game { display:flex; gap:10px; align-items:center; padding:3px 0; border-bottom:1px solid var(--border-color, #374151); }
        .fn-game .d { width:90px; font-weight:700; } .fn-game .o { flex:1; }
        .fn-warn { color:#fbbf24; font-weight:700; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="fn-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="fn-title">📈 Finances</h1><div id="fn-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" style="max-width:1400px; margin:0 auto;">
        <div class="fn-pills" id="fn-pills"></div>
        <div id="fn-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#fn-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => { const v = e.target.closest('[data-view]'); if (v) { this.view = v.dataset.view; this._renderBody(); } });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('finances', tier, tokens) : ''; }
  _ov(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('payments_overview', tier, tokens) : ''; }

  async load() {
    this.err = '';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const title = this.find('#fn-title'); if (title) title.textContent = this._copy('title') || '📈 Finances';
      const sub = this.find('#fn-sub'); if (sub) sub.textContent = this._copy('subtitle');
      this._renderPills();
      const [s, x] = await Promise.all([this.auth.fetch('/api/finances/summary'), this.auth.fetch('/api/finances/expenses')]);
      const sj = await s.json().catch(() => ({})), xj = await x.json().catch(() => ({}));
      if (!s.ok) throw new Error(sj.error || `HTTP ${s.status}`);
      if (!x.ok) throw new Error(xj.error || `HTTP ${x.status}`);
      this.summary = sj; this.expenses = xj;
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }

  _renderPills() {
    const el = this.find('#fn-pills'); if (!el) return;
    const pills = [['summary', this._copy('pill_summary') || 'Summary'], ['revenue', this._copy('pill_revenue') || 'Revenue'], ['expenses', this._copy('pill_expenses') || 'Expenses']];
    el.innerHTML = pills.map(([k, l]) => `<button class="fn-pill ${this.view === k ? 'on' : ''}" data-view="${k}">${this.escapeHtml(l)}</button>`).join('');
  }

  _renderBody() {
    this._renderPills();
    const body = this.find('#fn-body'); if (!body) return;
    if (this.err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.summary || !this.expenses) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    body.innerHTML = this.view === 'summary' ? this._summaryHtml() : this.view === 'revenue' ? this._revenueHtml() : this._expensesHtml();
  }

  // ── shared bits ──
  static money0(v) { const n = Math.round(Number(v) || 0); return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(); }
  static money2(v) { const n = Number(v) || 0; return (n < 0 ? '−' : '') + '$' + Math.abs(n).toFixed(2); }
  _emoji(code) { return { M: '👨', W: '👩', B: '👦', G: '👧' }[code] || ''; }
  _cols(tier) { return this._ov(tier).split('|').map(c => c.trim()).filter(Boolean); }

  // ── Summary: raw totals per section then All ──
  _summaryHtml() {
    const esc = (t) => this.escapeHtml(t), M = FinancesScreen.money2, ov = this.summary;
    const sections = ov.sections || [], all = ov.all || {};
    const line = sections.length ? FinancesScreen.money0(sections[0].line) : '';
    const tone = (n, color) => n ? `color:${color}; font-weight:700;` : 'opacity:0.5;';
    const row = (s, isAll) => `
      <tr class="${isAll ? 'sum' : ''}">
        <td style="font-weight:700;">${isAll ? esc(this._ov('all_label') || 'All') : `${this._emoji(s.code)} ${esc(s.name)}`}</td>
        <td>${s.members}</td><td style="${s.free ? '' : 'opacity:0.5;'}">${s.free}</td>
        <td style="${tone(s.paid_up, '#86efac')}">${s.paid_up}</td><td style="${tone(s.behind, '#fbbf24')}">${s.behind}</td>
        <td style="${tone(s.blocked, '#fca5a5')}">${s.blocked}</td><td style="${tone(s.owed, '#fca5a5')}">${M(s.owed)}</td>
      </tr>`;
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._ov('summary_title') || 'Summary')}</div>
        <div class="fn-note">${esc(this._ov('summary_note', { line }))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:520px;">
          <thead><tr><th></th>${this._cols('summary_columns').map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${sections.map(s => row(s, false)).join('')}${row(all, true)}</tbody>
        </table></div>
      </div>`;
  }

  // ── Revenue: dues × members, two reports, per month and per year ──
  _revenueHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, M2 = FinancesScreen.money2, ov = this.summary;
    const sections = ov.sections || [], all = ov.all || {};
    const pCols = this._cols('projections_columns');
    const reports = [['all_members', this._ov('row_all_members') || 'All current members'], ['current_dues', this._ov('row_current_dues') || 'Members current in dues']];
    const row = (s, isAll) => `
      <tr class="${isAll ? 'sum' : ''}">
        <td style="font-weight:700;">${isAll ? esc(this._ov('all_label') || 'All') : `${this._emoji(s.code)} ${esc(s.name)}`}</td>
        <td style="opacity:0.7;">${isAll ? '' : M2(s.rate)}</td>
        ${reports.map(([k]) => { const p = (s.projections || {})[k] || {}; return `<td class="fn-dim">${p.count ?? 0}</td><td class="fn-in" style="font-weight:700;">${M0(p.monthly)}</td><td class="fn-in">${M0(p.yearly)}</td>`; }).join('')}
      </tr>`;
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._ov('projections_title') || 'Projections')}</div>
        <div class="fn-note">${esc(this._ov('projections_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:640px;">
          <thead>
            <tr><th></th><th></th>${reports.map(([, l]) => `<th colspan="3" style="text-align:center; border-bottom:1px solid var(--border-color, #374151);">${esc(l)}</th>`).join('')}</tr>
            <tr><th></th><th>${esc(pCols[0] || 'Rate')}</th>${reports.map(() => `<th>#</th><th>${esc(pCols[1] || 'Per month')}</th><th>${esc(pCols[2] || 'Per year')}</th>`).join('')}</tr>
          </thead>
          <tbody>${sections.map(s => row(s, false)).join('')}${row(all, true)}</tbody>
        </table></div>
      </div>`;
  }

  // ── Expenses: the cash-flow grid, then the referee game list ──
  _expensesHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, x = this.expenses, ov = this.summary;
    const months = x.months || [];
    const nowYm = (x.today || '').slice(0, 7);
    const mLabel = (ym) => new Date(Number(ym.slice(0, 4)), Number(ym.slice(5, 7)) - 1, 1).toLocaleString('en-US', { month: 'short', year: '2-digit' }).replace(' ', ' ’');
    const cell = (ym, proj, inv, cls) => `<td class="${ym === nowYm ? 'now' : ''}">${proj ? `<span class="${cls}">${M0(proj)}</span>` : '<span class="fn-dim">–</span>'}${inv ? `<span class="fn-tick">✓ ${M0(inv)}</span>` : ''}</td>`;
    const head = `<tr><th></th>${months.map(ym => `<th class="${ym === nowYm ? 'now' : ''}">${esc(mLabel(ym))}</th>`).join('')}<th>${esc(this._copy('col_total') || 'Total')}</th></tr>`;
    const sum = (byMonth, key) => months.reduce((a, ym) => a + Number((byMonth[ym] || {})[key] || 0), 0);

    // Money in: dues from members current in dues, flat per month, per section.
    const inRows = (ov.sections || []).map(s => {
      const m = Number(((s.projections || {}).current_dues || {}).monthly || 0);
      return { label: this._copy('row_dues', { section: s.name }) || `Dues — ${s.name}`, emoji: this._emoji(s.code), monthly: m };
    }).filter(r => r.monthly > 0);
    const inTotal = inRows.reduce((a, r) => a + r.monthly, 0);
    let html = `<tr class="group"><td colspan="${months.length + 2}">${esc(this._copy('row_in') || 'Money in')}</td></tr>`;
    for (const r of inRows) html += `<tr><td>${r.emoji} ${esc(r.label)}</td>${months.map(ym => cell(ym, r.monthly, 0, 'fn-in')).join('')}<td class="fn-in">${M0(r.monthly * months.length)}</td></tr>`;
    html += `<tr class="sum"><td>${esc(this._copy('row_in') || 'Money in')}</td>${months.map(ym => cell(ym, inTotal, 0, 'fn-in')).join('')}<td class="fn-in">${M0(inTotal * months.length)}</td></tr>`;

    // Money out: referee policies, then budget lines.
    const outRows = [
      ...(x.ref_fees || []).map(p => ({ label: `Refs — ${p.label}${p.seasons?.some(s => s.is_assumed) ? '*' : ''}`, emoji: '🧑‍⚖️', by: p.by_month || {}, hint: `${FinancesScreen.money2(p.rate)} per home game` })),
      ...(x.budget || []).map(b => ({ label: `${b.label}${b.is_assumed ? '*' : ''}`, emoji: b.category === 'uniforms' ? '👕' : '🏆', by: b.by_month || {},
        hint: `${b.amount_per === 'member' ? `${FinancesScreen.money2(b.amount)} × ${b.units} members = ` : ''}${FinancesScreen.money2(b.total)}${b.paid_before ? ` − ${FinancesScreen.money2(b.paid_before)} paid before` : ''}${b.invoiced ? ` − ${FinancesScreen.money2(b.invoiced)} invoiced` : ''}` })),
    ].filter(r => sum(r.by, 'projected') > 0 || sum(r.by, 'invoiced') > 0);
    const outBy = {}; for (const r of outRows) for (const ym of months) { const c = r.by[ym] || {}; outBy[ym] = outBy[ym] || { projected: 0, invoiced: 0 }; outBy[ym].projected += Number(c.projected || 0); outBy[ym].invoiced += Number(c.invoiced || 0); }
    html += `<tr class="group"><td colspan="${months.length + 2}">${esc(this._copy('row_out') || 'Money out')}</td></tr>`;
    for (const r of outRows) html += `<tr><td title="${esc(r.hint)}">${r.emoji} ${esc(r.label)}</td>${months.map(ym => cell(ym, (r.by[ym] || {}).projected, (r.by[ym] || {}).invoiced, 'fn-out')).join('')}<td class="fn-out">${M0(sum(r.by, 'projected'))}</td></tr>`;
    const outTotal = sum(outBy, 'projected');
    html += `<tr class="sum"><td>${esc(this._copy('row_out') || 'Money out')}</td>${months.map(ym => cell(ym, outBy[ym]?.projected, outBy[ym]?.invoiced, 'fn-out')).join('')}<td class="fn-out">${M0(outTotal)}</td></tr>`;
    const net = (ym) => inTotal - Number(outBy[ym]?.projected || 0);
    html += `<tr class="sum"><td>${esc(this._copy('row_net') || 'Net')}</td>${months.map(ym => `<td class="${ym === nowYm ? 'now' : ''}" style="font-weight:800; color:${net(ym) < 0 ? '#fca5a5' : '#86efac'};">${M0(net(ym))}</td>`).join('')}<td style="font-weight:800; color:${inTotal * months.length - outTotal < 0 ? '#fca5a5' : '#86efac'};">${M0(inTotal * months.length - outTotal)}</td></tr>`;

    // Referee games: what the projection is made of, and what is ticked.
    const games = x.games || [];
    const byPolicy = new Map();
    for (const g of games) { if (!byPolicy.has(g.policy_label)) byPolicy.set(g.policy_label, []); byPolicy.get(g.policy_label).push(g); }
    let list = '';
    for (const [label, gs] of byPolicy) {
      if (!gs.some(g => g.amount > 0)) continue;
      list += `<div style="font-weight:800; margin:10px 0 4px;">${esc(label)} <span class="fn-dim">· ${gs.length} home game${gs.length === 1 ? '' : 's'} on the schedule</span></div>`;
      for (const g of gs) list += `
        <div class="fn-game ${g.invoiced ? 'fn-dim' : ''}">
          <span class="d">${esc(g.date_label)}</span><span class="o">${esc(g.opponent)}${g.status && g.status !== 'scheduled' && g.status !== 'completed' ? ` <span class="fn-warn">${esc(g.status)}</span>` : ''}</span>
          <span>${FinancesScreen.money2(g.amount)}</span>
          <span style="width:190px; text-align:right;">${g.invoiced ? `✓ invoice ${esc(g.invoiced.invoice_label || '')}` : g.played ? `<span class="fn-warn">${esc(this._copy('games_played') || 'played — not invoiced yet')}</span>` : ''}</span>
        </div>`;
    }
    const seasons = (x.ref_fees || []).flatMap(p => (p.seasons || []).map(s => `${p.label} ${s.label}: ${s.known} on the schedule of ${s.expected}${s.is_assumed ? '*' : ''}`));
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('cash_title') || 'Cash flow')}</div>
        <div class="fn-note">${esc(this._copy('cash_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table"><thead>${head}</thead><tbody>${html}</tbody></table></div>
        <div class="fn-note" style="margin-top:8px;">${esc(this._copy('assumed_note') || '* assumed')} · ${esc(seasons.join(' · '))}</div>
      </div>
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('refs_title') || 'Home games')}</div>
        <div class="fn-note">${esc(this._copy('refs_note'))}</div>
        <div class="fn-games">${list || '<div class="fn-dim">No games on the schedules yet.</div>'}</div>
      </div>`;
  }
}
window.FinancesScreen = FinancesScreen;
