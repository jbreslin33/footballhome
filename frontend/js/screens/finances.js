// finances.js — #finances: where the club stands and where it is heading
// (migration 489/490).  Billing stays on #payments (owner 2026-09-29:
// "should this all be on separate page(s) including the summary to keep the
// billing part cleaner?").
//
//   Summary    per section + All: members, free, paid up, behind, blocked,
//              owed — GET /api/finances/summary (LeagueApps synced first)
//   Money in & out  (mig 977) MoneyView: Who pills (All › section › team)
//              × Money pills (All / In / Out) over the budget year
//   Revenue    dues × members per month and year, two reports: every paying
//              member, and only members current in dues
//   At capacity (mig 1360) members now vs the members each team wants (men /
//              women roster spots, youth per age), × dues, vs the Year plan ÷ 12
//   Playground (mig 1361) 🧪 a what-if copy of a budget year: teams, players,
//              coaches — never the real plan; ↺ rebuilds it from the real plan
//   Expenses   the cash-flow grid from this month forward: money in (dues
//              from members current in dues), money out (referee fees per
//              home game, league dues, kits), net — GET /api/finances/expenses
//              pulls the league feeds first; ✓ marks what is on an invoice
//
// Wording: message_templates kind 'payments_overview' (summary / revenue)
// and 'finances' (page, pills, cash flow).
class FinancesScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.summary = null; this.expenses = null; this.view = 'plan'; this.err = ''; this.options = new Set(); try { this.options = new Set(JSON.parse(localStorage.getItem('fn-plan-options') || '[]')); } catch (_) {} this.expanded = new Set(); this.money = null; this.scope = 'all'; }

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
        .fn-table tr.cat td { font-weight:700; cursor:pointer; }
        .fn-table tr.cat td:first-child::before { content:'▸ '; opacity:0.6; }
        .fn-table tr.cat.open td:first-child::before { content:'▾ '; }
        .fn-table tr.item td { opacity:0.85; font-size:0.82rem; }
        .fn-table tr.item td:first-child { padding-left:26px; }
        .fn-table td.now { background:rgba(14,165,233,0.10); }
        .fn-in { color:#86efac; } .fn-out { color:#fca5a5; } .fn-dim { opacity:0.5; }
        .fn-tick { font-size:0.7rem; opacity:0.75; display:block; }
        .fn-games { font-size:0.85rem; }
        .fn-game { display:flex; gap:10px; align-items:center; padding:3px 0; border-bottom:1px solid var(--border-color, #374151); }
        .fn-game .d { width:90px; font-weight:700; } .fn-game .o { flex:1; }
        .fn-warn { color:#fbbf24; font-weight:700; }
        ${window.MoneyView ? MoneyView.css() : ''}
        .fn-amt { width:90px; text-align:right; padding:3px 6px; border:1px solid var(--border-color, #374151); border-radius:4px; background:transparent; color:var(--text-primary); font:inherit; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="fn-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="fn-title">📈 Budget</h1><div id="fn-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" style="max-width:1400px; margin:0 auto;">
        <div id="fn-who"></div>
        <div class="fn-pills" id="fn-pills"></div>
        <div id="fn-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#fn-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => {
      const w = e.target.closest('[data-scope]'); if (w) { this.scope = w.dataset.scope; if (this.money) this.money.scope = this.scope; this._renderBody(); return; }
      if (this.view === 'playground' && this._pgClick(e)) return;
      const v = e.target.closest('[data-view]'); if (v) { this.view = v.dataset.view; this._renderBody(); return; }
      if (e.target.closest('[data-plan-grants]')) { this.showGrants = !this.showGrants; this._renderBody(); return; }
      const yp = e.target.closest('[data-plan-year]'); if (yp) { this.planYear = yp.dataset.planYear; this._renderBody(); return; }
      const o = e.target.closest('[data-plan-option]'); if (o) { const id = Number(o.dataset.planOption); if (this.options.has(id)) this.options.delete(id); else this.options.add(id); try { localStorage.setItem('fn-plan-options', JSON.stringify([...this.options])); } catch (_) {} this._renderBody(); return; }
      if (this.view === 'money' && this.money && this.money.handleClick(e)) { this._renderBody(); return; }
      const c = e.target.closest('[data-cat]'); if (c) { const k = c.dataset.cat; if (this.expanded.has(k)) this.expanded.delete(k); else this.expanded.add(k); this._renderBody(); }
    });
    div.addEventListener('change', (e) => {
      if (e.target.matches('[data-pg-field]')) { this._pgChange(e.target); return; }
      if (e.target.matches('[data-plan-teams]')) { const n = Number(e.target.value); if (Number.isInteger(n) && n >= 0 && n <= 20) this._savePlanTeams(Number(e.target.dataset.planTeams), n); else this._renderBody(); return; }
      if (e.target.matches('[data-plan-roster]')) { const n = Number(e.target.value); if (Number.isInteger(n) && n >= 0) this._savePlanRoster(Number(e.target.dataset.planRoster), n); else this._renderBody(); return; }
      const row = e.target.closest('[data-budget-line]'); if (!row) return;
      if (e.target.matches('[data-budget-settled]')) this._saveBudgetLine(row.dataset.budgetLine, { settled: e.target.checked });
      if (e.target.matches('[data-budget-amount]')) {
        const amount = Number(e.target.value);
        if (e.target.value.trim() !== '' && amount >= 0) this._saveBudgetLine(row.dataset.budgetLine, { amount });
        else this._renderBody();
      }
    });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('finances', tier, tokens) : ''; }
  _ov(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('payments_overview', tier, tokens) : ''; }

  async load() {
    this.err = '';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const title = this.find('#fn-title'); if (title) title.textContent = this._copy('title') || '📈 Budget';
      const sub = this.find('#fn-sub'); if (sub) sub.textContent = this._copy('subtitle');
      this._renderPills();
      const [s, x, f] = await Promise.all(['summary', 'expenses', 'cash-flow'].map(p => this.auth.fetch(`/api/finances/${p}`)));
      const sj = await s.json().catch(() => ({})), xj = await x.json().catch(() => ({})), fj = await f.json().catch(() => ({}));
      if (!s.ok) throw new Error(sj.error || `HTTP ${s.status}`);
      if (!x.ok) throw new Error(xj.error || `HTTP ${x.status}`);
      if (!f.ok) throw new Error(fj.error || `HTTP ${f.status}`);
      this.summary = sj; this.expenses = xj; this.flow = fj;
      // Money in & out (mig 977) shares the three loads.
      if (window.MoneyView) { this.money = this.money || new MoneyView(this); Object.assign(this.money, { flow: fj, summary: sj, expenses: xj, scope: this.scope }); }
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }

  // A budget line's estimate or ✓ Settled (mig 921), then the grid again.
  async _saveBudgetLine(id, change) {
    try {
      const res = await this.auth.fetch(`/api/finances/budget-lines/${id}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(change) });
      const j = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(j.error || `HTTP ${res.status}`);
      const x = await this.auth.fetch('/api/finances/expenses');
      const xj = await x.json().catch(() => ({}));
      if (!x.ok) throw new Error(xj.error || `HTTP ${x.status}`);
      this.expenses = xj; if (this.money) this.money.expenses = xj;
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }

  // Year plan team count (mig 1348): save, then the plan again.
  async _savePlanTeams(entryId, teams) {
    try {
      const res = await this.auth.fetch('/api/finances/plan-teams', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ entry_id: entryId, teams }) });
      const j = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(j.error || `HTTP ${res.status}`);
      const x = await this.auth.fetch('/api/finances/expenses');
      const xj = await x.json().catch(() => ({}));
      if (!x.ok) throw new Error(xj.error || `HTTP ${x.status}`);
      this.expenses = xj; if (this.money) this.money.expenses = xj;
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }

  // Year plan "Full rosters" (mig 1345): save, then the plan again.
  async _savePlanRoster(entryId, players) {
    try {
      const res = await this.auth.fetch('/api/finances/plan-roster', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ entry_id: entryId, players }) });
      const j = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(j.error || `HTTP ${res.status}`);
      const x = await this.auth.fetch('/api/finances/expenses');
      const xj = await x.json().catch(() => ({}));
      if (!x.ok) throw new Error(xj.error || `HTTP ${x.status}`);
      this.expenses = xj; if (this.money) this.money.expenses = xj;
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }

  // The Who pills (mig 986): every view below follows them — owner: "could we
  // just do pills and not diff pages … more control with pills".
  _inScope() { return window.MoneyView && this.flow ? MoneyView.inScopeOf(this.flow.scopes, this.scope) : null; }
  _scopeOk(code) { const set = this._inScope(); return !set || set.has(code || 'club'); }
  // Summary / Revenue rows: the sections when All, else the teams under the pill and their total.
  _units() {
    const ov = this.summary || {};
    if (!this._inScope()) return { rows: (ov.sections || []).map(s => ({ ...s, title: `${this._emoji(s.code)} ${s.name}` })), total: ov.all || {} };
    const rows = (ov.teams || []).filter(t => this._scopeOk(t.scope)).map(t => ({ ...t, title: `${this._emoji(t.code)} ${t.label}` }));
    const keys = ['members', 'free', 'volunteers', 'injured', 'paying', 'paid_up', 'behind', 'blocked', 'owed'];
    const total = {}; for (const k of keys) total[k] = rows.reduce((a, r) => a + Number(r[k] || 0), 0);
    total.projections = {};
    for (const p of ['all_members', 'current_dues']) total.projections[p] = ['count', 'monthly', 'yearly'].reduce((o, k) => (o[k] = rows.reduce((a, r) => a + Number(((r.projections || {})[p] || {})[k] || 0), 0), o), {});
    return { rows, total };
  }

  _renderPills() {
    const who = this.find('#fn-who');
    if (who) who.innerHTML = window.MoneyView && this.flow ? MoneyView.whoPillsHtml(this.flow.scopes || [], this.scope, (t) => this.escapeHtml(t), (window.MessageCopy && MessageCopy.block('cash_flow', 'pill_all')) || 'All') : '';
    const el = this.find('#fn-pills'); if (!el) return;
    const pills = [['plan', this._copy('pill_plan') || 'Year plan'], ['summary', this._copy('pill_summary') || 'Summary'], ['money', this._copy('pill_money') || 'Money in & out'], ['revenue', this._copy('pill_revenue') || 'Revenue'], ['capacity', this._copy('pill_capacity') || 'At capacity'], ['playground', this._copy('pill_playground') || 'Playground'], ['expenses', this._copy('pill_expenses') || 'Expenses']];
    el.innerHTML = pills.map(([k, l]) => `<button class="fn-pill ${this.view === k ? 'on' : ''}" data-view="${k}">${this.escapeHtml(l)}</button>`).join('');
  }

  _renderBody() {
    this._renderPills();
    const body = this.find('#fn-body'); if (!body) return;
    if (this.view === 'money' && !this.err) { body.innerHTML = this.money && this.money.ready() ? this.money.html({ who: false }) : '<div class="loading">Loading…</div>'; return; }
    if (this.err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.summary || !this.expenses) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    body.innerHTML = this.view === 'playground' ? this._pgHtml() : this.view === 'plan' ? this._planHtml() : this.view === 'summary' ? this._summaryHtml() : this.view === 'revenue' ? this._revenueHtml() : this.view === 'capacity' ? this._capacityHtml() : this._expensesHtml();
  }

  // ── shared bits ──
  static money0(v) { const n = Math.round(Number(v) || 0); return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(); }
  static money2(v) { const n = Number(v) || 0; return (n < 0 ? '−' : '') + '$' + Math.abs(n).toFixed(2); }
  _emoji(code) { return { M: '👨', W: '👩', B: '👦', G: '👧' }[code] || ''; }
  _cols(tier) { return this._ov(tier).split('|').map(c => c.trim()).filter(Boolean); }

  // ── Summary: raw totals per section then All ──
  _summaryHtml() {
    const esc = (t) => this.escapeHtml(t), M = FinancesScreen.money2, ov = this.summary;
    const sections = ov.sections || [], { rows: units, total: all } = this._units();
    const line = sections.length ? FinancesScreen.money0(sections[0].line) : '';
    const tone = (n, color) => n ? `color:${color}; font-weight:700;` : 'opacity:0.5;';
    const row = (s, isAll) => `
      <tr class="${isAll ? 'sum' : ''}">
        <td style="font-weight:700;">${isAll ? esc(this._ov('all_label') || 'All') : esc(s.title)}</td>
        <td>${s.members}</td><td style="${s.free ? '' : 'opacity:0.5;'}">${s.free}</td><td style="${s.volunteers ? '' : 'opacity:0.5;'}">${s.volunteers || 0}</td><td style="${s.injured ? '' : 'opacity:0.5;'}">${s.injured || 0}</td>
        <td style="${tone(s.paid_up, '#86efac')}">${s.paid_up}</td><td style="${tone(s.behind, '#fbbf24')}">${s.behind}</td>
        <td style="${tone(s.blocked, '#fca5a5')}">${s.blocked}</td><td style="${tone(s.owed, '#fca5a5')}">${M(s.owed)}</td>
      </tr>`;
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._ov('summary_title') || 'Summary')}</div>
        <div class="fn-note">${esc(this._ov('summary_note', { line }))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:520px;">
          <thead><tr><th></th>${this._cols('summary_columns').map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${units.map(s => row(s, false)).join('')}${row(all, true)}</tbody>
        </table></div>
      </div>`;
  }

  // ── Revenue: dues × members, two reports, per month and per year ──
  _revenueHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, M2 = FinancesScreen.money2, ov = this.summary;
    const { rows: units, total: all } = this._units();
    const pCols = this._cols('projections_columns');
    const reports = [['all_members', this._ov('row_all_members') || 'All current members'], ['current_dues', this._ov('row_current_dues') || 'Members current in dues']];
    const row = (s, isAll) => `
      <tr class="${isAll ? 'sum' : ''}">
        <td style="font-weight:700;">${isAll ? esc(this._ov('all_label') || 'All') : esc(s.title)}</td>
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
          <tbody>${units.map(s => row(s, false)).join('')}${row(all, true)}</tbody>
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
    // Money in: past months = the dues LeagueApps actually paid for the row
    // (flow items, mig 977); this month on = members current in dues × rate.
    const scopes = (this.flow || {}).scopes || [];
    const actualDues = (set, ym) => ((this.flow || {}).items || []).filter(i => i.dir === 'in' && i.category === 'dues' && !i.ahead && i.ym === ym && set.has(i.scope)).reduce((a, i) => a + Number(i.amount), 0);
    const inRows = this._units().rows.map(s => {
      const m = Number(((s.projections || {}).current_dues || {}).monthly || 0), name = s.label || s.name;
      const sec = s.scope ? null : (scopes.find(x => x.section_code === s.code) || {}).code;
      const set = s.scope ? new Set([s.scope]) : (window.MoneyView && sec ? MoneyView.inScopeOf(scopes, sec) : new Set());
      const by = {}; for (const ym of months) by[ym] = ym < nowYm ? actualDues(set, ym) : m;
      return { label: this._copy('row_dues', { section: name }) || `Dues — ${name}`, emoji: this._emoji(s.code), by };
    }).filter(r => Object.values(r.by).some(v => v));
    const inBy = {}; for (const ym of months) inBy[ym] = inRows.reduce((a, r) => a + r.by[ym], 0);
    const inTotal = months.reduce((a, ym) => a + inBy[ym], 0);
    let html = `<tr class="group"><td colspan="${months.length + 2}">${esc(this._copy('row_in') || 'Money in')}</td></tr>`;
    for (const r of inRows) html += `<tr><td>${r.emoji} ${esc(r.label)}</td>${months.map(ym => cell(ym, r.by[ym], 0, 'fn-in')).join('')}<td class="fn-in">${M0(months.reduce((a, ym) => a + r.by[ym], 0))}</td></tr>`;
    html += `<tr class="sum"><td>${esc(this._copy('row_in') || 'Money in')}</td>${months.map(ym => cell(ym, inBy[ym], 0, 'fn-in')).join('')}<td class="fn-in">${M0(inTotal)}</td></tr>`;

    // Money out, rolled up by major category (invoice_line_categories, mig
    // 493): one row per category with monthly totals; tap to expand into
    // its items, where rows sharing a group_label are one line ("u8 fall
    // winter spring all one line").
    const addBy = (into, by) => { for (const [ym, c] of Object.entries(by || {})) { into[ym] = into[ym] || { projected: 0, invoiced: 0 }; into[ym].projected += Number(c.projected || 0); into[ym].invoiced += Number(c.invoiced || 0); } };
    const catLabel = {}; for (const b of [...(x.budget || []), ...(x.plan_cash || [])]) catLabel[b.category] = (b.category_label || b.category).replace(/:\s*$/, '');
    catLabel.referees = catLabel.referees || 'Referees';
    catLabel.labor = this._copy('coaching_label') || 'Coaching';
    const raw = [
      // Coaching (mig 494): each coach's usual week, then hours per game by league.
      // A per-game coach (pay_basis games, mig 497) projects under Game hours; their row is what they invoiced.
      ...(x.coaching_usual || []).filter(u => this._scopeOk(u.scope || 'club')).map(u => u.pay_basis === 'games'
        ? ({ cat: 'labor', key: `usual:${u.issuer_id}`, keyLabel: this._copy('games_invoiced', { name: u.name }) || `Games invoiced — ${u.name}`, assumed: false, by: u.by_month || {},
             hints: [`paid per game at ${FinancesScreen.money2(u.rate)}/h — projected under Game hours`] })
        : ({ cat: 'labor', key: `usual:${u.issuer_id}`, keyLabel: this._copy('usual_hours', { name: u.name }) || `Usual hours — ${u.name}`, assumed: false, by: u.by_month || {},
             hints: [`${u.weekly_hours} h a week × ${FinancesScreen.money2(u.rate)}/h`] })),
      ...(x.ref_fees || []).filter(p => p.kind === 'coaching' && this._scopeOk(p.scope)).map(p => ({ cat: 'labor', key: `game:${p.label}`, keyLabel: `Game hours — ${p.label}${p.coach ? ` · ${p.coach}` : ''}`, assumed: !!p.seasons?.some(s => s.is_assumed), by: p.by_month || {},
        hints: [`${p.hours_per_game} h × ${FinancesScreen.money2(p.rate_per_hour)}/h = ${FinancesScreen.money2(p.rate)} per game, home and away${p.coach ? `, paid to ${p.coach}` : ''}`] })),
      ...(x.ref_fees || []).filter(p => p.kind !== 'coaching' && this._scopeOk(p.scope)).map(p => ({ cat: 'referees', key: p.group_label || p.label, assumed: !!p.seasons?.some(s => s.is_assumed), by: p.by_month || {}, hints: [`${p.label}: ${FinancesScreen.money2(p.rate)} per home game`] })),
      // Teams on their fee plan (mig 1320): league payments + per-game costs still ahead.
      ...(x.plan_cash || []).filter(p => this._scopeOk(p.scope)).map(p => ({ cat: p.category, key: p.label, assumed: !!p.assumed, by: p.by_month || {}, hints: [p.hint || ''] })),
      ...(x.budget || []).filter(b => this._scopeOk(b.scope) && b.category !== 'labor' && b.this_year !== false).map(b => ({ cat: b.category, key: b.group_label || b.label, assumed: !!b.is_assumed, by: b.by_month || {},
        hints: [`${b.label}: ${b.amount_per === 'member' ? `${FinancesScreen.money2(b.amount)} × ${b.units} members = ` : b.amount_per === 'week' ? `${FinancesScreen.money2(b.amount)} × ${b.units} weeks ahead = ` : ''}${FinancesScreen.money2(b.total)}${b.paid_before ? ` − ${FinancesScreen.money2(b.paid_before)} paid before` : ''}${b.invoiced ? ` − ${FinancesScreen.money2(b.invoiced)} invoiced` : ''}${b.settled ? ` · ${this._copy('budget_settled_hint', { amount: FinancesScreen.money2(b.invoiced + b.paid_before) })}` : ''}`] })),
    ];
    const cats = new Map();
    for (const r of raw) {
      if (!cats.has(r.cat)) cats.set(r.cat, { code: r.cat, label: catLabel[r.cat] || r.cat, by: {}, items: new Map() });
      const c = cats.get(r.cat); addBy(c.by, r.by);
      if (!c.items.has(r.key)) c.items.set(r.key, { label: r.keyLabel || r.key, assumed: false, by: {}, hints: [] });
      const it = c.items.get(r.key); it.assumed = it.assumed || r.assumed; it.hints.push(...r.hints); addBy(it.by, r.by);
    }
    const order = (this._copy('category_order') || '').split('|').map(t => t.trim()).filter(Boolean);
    const catRows = [...cats.values()].filter(c => sum(c.by, 'projected') > 0 || sum(c.by, 'invoiced') > 0)
      .sort((a, b) => (order.indexOf(a.code) + 1 || 99) - (order.indexOf(b.code) + 1 || 99));
    const emoji = { labor: '🧢', league_dues: '🏆', registrations: '📝', referees: '🧑‍⚖️', field_rentals: '🏟️', facilities: '🎨', equipment: '⚽', uniforms: '👕', other: '📦', media: '🎥', medical: '🩺', advertising: '📣' };
    const outRows = [];   // what the grid prints, in order
    for (const c of catRows) {
      const open = this.expanded.has(c.code);
      const items = [...c.items.values()].filter(i => sum(i.by, 'projected') > 0 || sum(i.by, 'invoiced') > 0);
      outRows.push({ kind: 'cat', code: c.code, open, label: `${c.label}${items.some(i => i.assumed) ? '*' : ''}`, emoji: emoji[c.code] || '', by: c.by, hint: `${items.length} item${items.length === 1 ? '' : 's'}` });
      if (open) for (const i of items) outRows.push({ kind: 'item', label: `${i.label}${i.assumed ? '*' : ''}`, emoji: '', by: i.by, hint: i.hints.join('\n') });
    }
    const outBy = {}; for (const c of catRows) addBy(outBy, c.by);
    html += `<tr class="group"><td colspan="${months.length + 2}">${esc(this._copy('row_out') || 'Money out')} <span style="font-weight:400; opacity:0.6; font-size:0.78rem;">${esc(this._copy('expand_hint'))}</span></td></tr>`;
    for (const r of outRows) html += `<tr class="${r.kind} ${r.open ? 'open' : ''}" ${r.kind === 'cat' ? `data-cat="${esc(r.code)}"` : ''}><td title="${esc(r.hint)}">${r.emoji ? r.emoji + ' ' : ''}${esc(r.label)}</td>${months.map(ym => cell(ym, (r.by[ym] || {}).projected, (r.by[ym] || {}).invoiced, 'fn-out')).join('')}<td class="fn-out">${M0(sum(r.by, 'projected'))}</td></tr>`;
    const outTotal = sum(outBy, 'projected');
    html += `<tr class="sum"><td>${esc(this._copy('row_out') || 'Money out')}</td>${months.map(ym => cell(ym, outBy[ym]?.projected, outBy[ym]?.invoiced, 'fn-out')).join('')}<td class="fn-out">${M0(outTotal)}</td></tr>`;
    const net = (ym) => inBy[ym] - Number(outBy[ym]?.projected || 0) - (ym < nowYm ? Number(outBy[ym]?.invoiced || 0) : 0);
    html += `<tr class="sum"><td>${esc(this._copy('row_net') || 'Net')}</td>${months.map(ym => `<td class="${ym === nowYm ? 'now' : ''}" style="font-weight:800; color:${net(ym) < 0 ? '#fca5a5' : '#86efac'};">${M0(net(ym))}</td>`).join('')}<td style="font-weight:800; color:${months.reduce((a, ym) => a + net(ym), 0) < 0 ? '#fca5a5' : '#86efac'};">${M0(months.reduce((a, ym) => a + net(ym), 0))}</td></tr>`;

    // Referee games: what the projection is made of, and what is ticked.
    const games = (x.games || []).filter(g => g.kind !== 'coaching' && this._scopeOk(g.scope));
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
    const seasons = (x.ref_fees || []).flatMap(p => (p.seasons || []).map(s => `${p.kind === 'coaching' ? 'Coaching ' : 'Refs '}${p.label} ${s.label}: ${s.known} on the schedule of ${s.expected}${s.is_assumed ? '*' : ''}`));
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
      </div>
      ${this._budgetHtml()}`;
  }

  // ── Year plan (mig 1320): each team's fee plan, rate × quantity for the
  // budget year — what the year really costs, and per player against dues.
  _planHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, M2 = FinancesScreen.money2;
    // Options (mig 1333, owner: "an option on finance page to add liga 2 in
    // spring"): an is_option entry counts only while its switch is on.
    // Year pills (mig 1334, owner: "have a pill for next year budget too").
    const thisYear = ((this.flow || {}).year || {}).label || '';
    const years = [...new Set([...(this.expenses.plan || []).map(l => l.budget_year), ...(this.expenses.budget || []).map(b => b.budget_year)].filter(Boolean))].sort();
    const year = this.planYear || (years.includes(thisYear) ? thisYear : years[0]);
    const yearsAll = [...new Set([...years, ...(this.expenses.plan_grants || []).map(g => g.budget_year)])].sort();
    const yearBar = yearsAll.length > 1 ? `<div class="fn-pills" style="margin:4px 0 6px;">${yearsAll.map(y => `<button class="fn-pill ${y === year ? 'on' : ''}" data-plan-year="${esc(y)}">${esc(this._copy('plan_year_pill', { year: y }) || y)}</button>`).join('')}</div>` : '';
    const grants = (this.expenses.plan_grants || []).filter(g => g.budget_year === year);
    const grantsBtn = grants.length ? `<button class="fn-pill ${this.showGrants ? 'on' : ''}" data-plan-grants>${esc(this._copy(this.showGrants ? 'plan_grants_on' : 'plan_grants_add'))}</button>` : '';
    const grantsCard = this.showGrants && grants.length ? `<div style="margin-top:12px;"><div style="font-weight:800;">${esc(this._copy('plan_grants_title'))}</div><div class="fn-note">${esc(this._copy('plan_grants_note'))}</div>
      <table class="fn-table" style="min-width:420px;"><tbody>${grants.map(g => `<tr><td title="${esc(g.note || '')}">${esc(g.label)}<span class="fn-tick">${esc(g.note || '')}</span></td><td>${esc((g.purpose_label || (g.purpose === 'labor' ? this._copy('coaching_label') : '') || '').replace(/:\s*$/, ''))}</td><td class="fn-in">${M0(g.amount)}</td></tr>`).join('')}
      <tr class="sum"><td colspan="2">${esc(this._copy('plan_total') || 'Total')}</td><td class="fn-in">${M0(grants.reduce((a, g) => a + Number(g.amount), 0))}</td></tr></tbody></table></div>` : '';
    const allLines = (this.expenses.plan || []).filter(l => this._scopeOk(l.scope) && l.budget_year === year);
    const optionEntries = [...new Map(allLines.filter(l => l.is_option).map(l => [l.entry_id, l])).values()];
    const lines = allLines.filter(l => !l.is_option || this.options.has(l.entry_id));
    const optionBar = (optionEntries.length || grantsBtn) ? `<div class="fn-pills" style="margin:4px 0 10px;">${grantsBtn}${optionEntries.map(l => { const on = this.options.has(l.entry_id); return `<button class="fn-pill ${on ? 'on' : ''}" data-plan-option="${l.entry_id}">${esc(this._copy(on ? 'plan_option_on' : 'plan_option_add', { team: l.short_label || l.team, when: l.entry_note || l.season }))}</button>`; }).join('')}</div>` : '';
    // Section-wide costs (budget_lines on a section's own pill — kits, coaching):
    // one "general" group per section, amount × units over the whole year (mig 1329).
    const scopes0 = (this.flow || {}).scopes || [];
    // section-wide and club-wide lines (not a team's)
    const general = (this.expenses.budget || []).filter(b => this._scopeOk(b.scope) && b.budget_year === year && scopes0.some(sc => sc.code === b.scope && (sc.section_code || !sc.team_id)));
    const head = `<div class="fn-title">${esc(this._copy('plan_title') || 'Year plan')}</div><div class="fn-note">${esc(this._copy('plan_note'))}</div>`;
    if (!lines.length && !general.length) return `<div class="fn-card">${head}${yearBar}${optionBar}<div class="fn-dim">${esc(this._copy('plan_empty'))}</div>${grantsCard}</div>`;
    const cols = (this._copy('plan_columns') || 'Line|Rate × qty|Year').split('|').map(c => c.trim());
    const qty = (n) => Number(n) % 1 ? Number(n).toFixed(2) : String(Number(n));
    const entries = new Map();
    for (const l of lines) { if (!entries.has(l.entry_id)) entries.set(l.entry_id, { id: l.entry_id, teams: l.team_count, title: `${l.team} · ${l.league} ${l.season}${l.is_option ? ` · ${l.entry_note || ''} (${this._copy('plan_option_tag') || 'option'})` : ''}`, lines: [] }); entries.get(l.entry_id).lines.push(l); }
    let rows = '', total = 0;
    for (const e of entries.values()) {
      const sub = e.lines.reduce((a, l) => a + Number(l.amount), 0); total += sub;
      // Team count (mig 1348): an entry that carries one gets a box; lines are per team × it.
      const teamsBox = e.teams == null ? '' : ` <label style="font-weight:400; white-space:nowrap;"><input class="fn-amt" style="width:52px;" type="number" min="0" max="20" step="1" data-plan-teams="${e.id}" value="${e.teams}"> ${esc(this._copy('plan_team_count') || 'teams')}</label>`;
      rows += `<tr class="group"><td colspan="2">${esc(e.title)}${teamsBox}</td><td>${M0(sub)}</td></tr>`;
      for (const l of e.lines) rows += `
        <tr class="item"><td title="${esc(l.note || '')}" style="white-space:normal;">${esc(l.label)}${l.is_assumed ? '*' : ''}${l.note ? `<span class="fn-tick">${esc(l.note)}</span>` : ''}</td>
          <td>${M2(l.rate)} × ${qty(l.quantity)}${l.team_count == null ? '' : ` × ${l.team_count}`}<span class="fn-tick">${esc(l.unit_label || '')}${l.team_count == null ? '' : ` × ${esc(this._copy('plan_team_count') || 'teams')}`}</span></td>
          <td class="${Number(l.amount) < 0 ? 'fn-in' : 'fn-out'}">${M0(l.amount)}</td></tr>`;
    }
    const bySection = new Map();
    for (const b of general) { const k = b.section || (scopes0.find(sc => sc.code === b.scope) || {}).label || ''; if (!bySection.has(k)) bySection.set(k, []); bySection.get(k).push(b); }
    // Game coaching (mig 1332): each coaching policy under the pill — its
    // season game counts × pay per game (hours × rate).
    // a coaching policy on a section pill or a section-level group (Men's, Youth) — not a team's
    for (const p of (this.expenses.ref_fees || []).filter(p => year === thisYear && p.kind === 'coaching' && this._scopeOk(p.scope) && scopes0.some(sc => sc.code === p.scope && (sc.section_code || !sc.team_id)))) {
      const games = (p.seasons || []).reduce((a, x) => a + Number(x.expected || 0), 0); if (!games) continue;
      const k = p.section || ''; if (!bySection.has(k)) bySection.set(k, []);
      bySection.get(k).push({ label: this._copy('plan_game_coaching', { label: p.label }) || `Game coaching — ${p.label}`, amount: p.rate, year_units: games, year_total: p.rate * games,
        is_assumed: (p.seasons || []).some(x => x.is_assumed), note: p.note, unitText: this._copy('plan_unit_game', { hours: p.hours_per_game, rate: M2(p.rate_per_hour) }) });
    }
    for (const [sec, bs] of bySection) {
      const sub = bs.reduce((a, b) => a + Number(b.year_total || 0), 0); total += sub;
      rows += `<tr class="group"><td colspan="2">${esc(this._copy('plan_general', { section: sec }) || sec)}</td><td>${M0(sub)}</td></tr>`;
      for (const b of bs) {
        const unit = b.unitText || (b.amount_per === 'member' ? this._copy('plan_unit_member') : b.amount_per === 'week' ? this._copy('plan_unit_week') : '');
        rows += `
        <tr class="item"><td title="${esc(b.note || '')}" style="white-space:normal;">${esc(b.label)}${b.is_assumed ? '*' : ''}${b.note ? `<span class="fn-tick">${esc(b.note)}</span>` : ''}</td>
          <td>${M2(b.amount)} × ${qty(b.year_units)}<span class="fn-tick">${esc(unit || '')}</span></td>
          <td class="fn-out">${M0(b.year_total)}</td></tr>`;
      }
    }
    // Split by paying members (owner 2026-11-13: "yes go ahead with that split" → "just split by paying members"):
    // a section pill (Men's, Women's, Youth) carries its share of the club-wide
    // lines, and — with the grants switch on — its share of the grants.
    const scopesS = (this.flow || {}).scopes || [];
    const pillS = scopesS.find(sc => sc.code === this.scope);
    const underS = (code) => { const set = window.MoneyView ? MoneyView.inScopeOf(scopesS, code) : new Set([code]); return scopesS.filter(sc => set.has(sc.code) && sc.section_code).map(sc => sc.section_code); };
    const shareCodes = pillS && !pillS.team_id && this.scope !== 'club' ? underS(pillS.code) : [];
    const allHeads = this.expenses.plan_heads || [];
    // by PAYING members (owner: "just split by paying members. so women don't bear it")
    const allActive = allHeads.reduce((a, h) => a + Number(h.paying || 0), 0);
    const myActive = allHeads.filter(h => shareCodes.includes(h.code)).reduce((a, h) => a + Number(h.paying || 0), 0);
    if (shareCodes.length && allActive > 0 && myActive > 0) {
      const frac = myActive / allActive, pct = `${Math.round(100 * frac)}%`;
      const clubTotal = (this.expenses.budget || []).filter(b => b.scope === 'club' && b.budget_year === year).reduce((a, b) => a + Number(b.year_total || 0), 0)
                      + (this.expenses.plan || []).filter(l => l.scope === 'club' && l.budget_year === year).reduce((a, l) => a + Number(l.amount || 0), 0);
      if (clubTotal > 0) {
        const share = clubTotal * frac; total += share;
        rows += `<tr class="group"><td colspan="2">${esc(this._copy('plan_club_share', { pct, active: myActive, all: allActive }))}</td><td>${M0(share)}</td></tr>
          <tr class="item"><td style="white-space:normal;">${esc(this._copy('plan_club_share_line', { total: M0(clubTotal) }))}</td><td>${M0(clubTotal)} × ${pct}</td><td class="fn-out">${M0(share)}</td></tr>`;
      }
      if (this.showGrants && grants.length) {
        const gTotal = grants.reduce((a, g) => a + Number(g.amount), 0), gShare = gTotal * frac;
        rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_total') || 'Total')}</td><td class="fn-out">${M0(total)}</td></tr>
          <tr class="item"><td style="white-space:normal;">${esc(this._copy('plan_grants_share', { pct }))}</td><td>${M0(gTotal)} × ${pct}</td><td class="fn-in">−${M0(gShare)}</td></tr>`;
        total -= gShare;
        rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_total_after_grants') || 'After grants')}</td><td class="fn-out">${M0(total)}</td></tr>`;
      } else rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_total') || 'Total')}</td><td class="fn-out">${M0(total)}</td></tr>`;
    } else rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_total') || 'Total')}</td><td class="fn-out">${M0(total)}</td></tr>`;
    // Who shares it (owner 2026-11-13: "dont ever use pickup … use 70 as the
    // maxed out perfect scenario then use active but also a cat for current
    // dues payers"): the pill's total ÷ each count, against a year of dues.
    let per = '';
    const scopes = (this.flow || {}).scopes || [];
    // the sections under a pill (Youth = Boys + Girls, mig 1341); a team pill climbs to its parent
    const sectionsUnder = (code) => { const set = window.MoneyView ? MoneyView.inScopeOf(scopes, code) : new Set([code]); return scopes.filter(sc => set.has(sc.code) && sc.section_code).map(sc => sc.section_code); };
    let pill = scopes.find(sc => sc.code === this.scope);
    while (pill && !sectionsUnder(pill.code).length && pill.parent) pill = scopes.find(sc => sc.code === pill.parent);
    const codes = pill ? sectionsUnder(pill.code) : [];
    const hs = (this.expenses.plan_heads || []).filter(h => codes.includes(h.code));
    const heads = hs.length ? { code: codes.join('+'), codes, section_id: hs[0].section_id, active: hs.reduce((a, h) => a + Number(h.active), 0),
                                current: hs.reduce((a, h) => a + Number(h.current), 0), full_house: hs.reduce((a, h) => a + Number(h.full_house), 0) } : null;
    const duesM = heads ? Number(((this.expenses.plan_dues || []).find(d => d.section_id === heads.section_id) || {}).monthly || 0) : 0;
    if (heads && duesM > 0) {
      // a section nobody pays dues in (Women's, owner: "we are eating the cost while we build it")
      const noDues = Number(heads.active) > 0 && Number(heads.current) === 0 && !((this.summary || {}).sections || []).some(x => heads.codes.includes(x.code) && Number(x.paying) > 0);
      const dues = 12 * duesM, sCols = (this._copy('plan_split_columns') || 'Shared by|Players|Each|Of a year of dues').split('|').map(c => c.trim());
      // full house = roster spots of the year's dues-carrying teams (an option only while on)
      // per dues-carrying team: its planned players, else its roster size (youth: no per-player fees)
      const byTeam = new Map();
      for (const l of lines.filter(l => l.dues_rank != null)) {
        const t = byTeam.get(l.team_id) || { players: 0, roster: Number(l.max_roster || 0), entry: l.entry_id, label: l.short_label || l.team };
        t.players += (l.category === 'registrations' && l.unit === 'per_player' ? Number(l.quantity) : 0) + Number(l.players_included || 0);
        byTeam.set(l.team_id, t);
      }
      const spots = [...byTeam.values()].reduce((a, t) => a + (t.players || t.roster), 0);
      const splits = [['plan_split_full', spots || Number(heads.full_house)], ['plan_split_active', heads.active], ['plan_split_current', heads.current]].filter(([, n]) => Number(n) > 0);
      per = `<table class="fn-table" style="margin-top:10px; min-width:420px;">
        <thead><tr>${sCols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
        <tbody>${splits.map(([k, n]) => `<tr><td>${esc(this._copy(k))}</td><td>${n}</td><td class="fn-out">${M0(total / n)}</td><td>${noDues ? esc(this._copy('plan_split_club_covers')) : `${Math.round(100 * total / n / dues)}% of ${M0(dues)}`}</td></tr>`).join('')}</tbody>
      </table>`;
      // Full rosters (mig 1345, owner: "allow for on budget page to put in full rosters")
      if (byTeam.size) per += `<div style="margin-top:12px;"><div style="font-weight:800;">${esc(this._copy('plan_rosters_title') || 'Full rosters')}</div>
        <div class="fn-note">${esc(this._copy('plan_rosters_note'))}</div>
        <div style="display:flex; flex-wrap:wrap; gap:10px;">${[...byTeam.values()].map(t => `<label style="display:flex; align-items:center; gap:6px;">${esc(t.label)}
          <input class="fn-amt" style="width:64px;" type="number" min="0" max="200" step="1" data-plan-roster="${t.entry}" value="${t.players || t.roster}"></label>`).join('')}</div></div>`;
    }
    return `
      <div class="fn-card">${head}${yearBar}${optionBar}
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:480px;">
          <thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${rows}</tbody>
        </table></div>${per}${grantsCard}
      </div>`;
  }

  // What the Year plan costs for a budget year, whole club (the Year plan
  // pill's total on All): team plans (options only while switched on),
  // section + club-wide lines, and this year's game coaching.
  _yearCost(year) {
    const thisYear = ((this.flow || {}).year || {}).label || '';
    const scopes = (this.flow || {}).scopes || [];
    const notTeam = (code) => scopes.some(sc => sc.code === code && (sc.section_code || !sc.team_id));
    const plan = (this.expenses.plan || []).filter(l => l.budget_year === year && (!l.is_option || this.options.has(l.entry_id))).reduce((a, l) => a + Number(l.amount || 0), 0);
    const general = (this.expenses.budget || []).filter(b => b.budget_year === year && notTeam(b.scope)).reduce((a, b) => a + Number(b.year_total || 0), 0);
    const coaching = year !== thisYear ? 0 : (this.expenses.ref_fees || []).filter(p => p.kind === 'coaching' && notTeam(p.scope))
      .reduce((a, p) => a + Number(p.rate || 0) * (p.seasons || []).reduce((g, x) => g + Number(x.expected || 0), 0), 0);
    return plan + general + coaching;
  }

  // ── 🎯 At capacity (mig 1360, owner: "we need to hit capicity for all
  // teams … how much per month and show each cat of age team") ──
  _capacityHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const rows = this.expenses.capacity || [];
    const heads = this.expenses.plan_heads || [];
    const duesOf = (code) => { const h = heads.find(x => x.code === code); return h ? Number(((this.expenses.plan_dues || []).find(d => d.section_id === h.section_id) || {}).monthly || 0) : 0; };
    // a section nobody pays dues in (Women's: "we are eating the cost while we build it")
    const covered = (code) => !((this.summary || {}).sections || []).some(x => x.code === code && Number(x.paying) > 0);
    const cols = (this._copy('capacity_columns') || 'Team|Members|Capacity|Open|$/mo now|$/mo at capacity').split('|').map(c => c.trim());
    const tot = { members: 0, capacity: 0, now: 0, full: 0 };
    const line = (label, r, code, cls = '') => {
      const dues = duesOf(code), free = covered(code), open = Math.max(0, r.capacity - r.members);
      const now = free ? 0 : r.paying * dues, full = free ? 0 : r.capacity * dues;
      if (cls !== 'group') { tot.members += r.members; tot.capacity += r.capacity; tot.now += now; tot.full += full; }
      const money = (v) => free ? `<span class="fn-dim">${esc(this._copy('capacity_club_covers'))}</span>` : M0(v);
      return `<tr class="${cls}"><td>${esc(label)}</td><td>${r.members}</td><td>${r.capacity}</td><td class="${open ? 'fn-warn' : 'fn-dim'}">${open || '✓'}</td><td>${money(now)}</td><td class="fn-in">${money(full)}</td></tr>`;
    };
    const name = (code) => `${this._emoji(code)} ${(((this.summary || {}).sections || []).find(x => x.code === code) || {}).name || code}`;
    let body = rows.filter(r => r.kind === 'section').map(r => line(name(r.code), r, r.code)).join('');
    // youth: consecutive ages with the same capacity make one group
    const ages = rows.filter(r => r.kind === 'age');
    const groups = [];
    for (const r of ages) { const g = groups[groups.length - 1]; if (g && g.cap === r.capacity && g.to === r.us_age - 1) { g.to = r.us_age; g.rows.push(r); } else groups.push({ cap: r.capacity, from: r.us_age, to: r.us_age, rows: [r] }); }
    const yt = { members: 0, capacity: 0, paying: 0 };
    for (const g of groups) {
      const sub = g.rows.reduce((a, r) => ({ members: a.members + r.members, capacity: a.capacity + r.capacity, paying: a.paying + r.paying }), { members: 0, capacity: 0, paying: 0 });
      yt.members += sub.members; yt.capacity += sub.capacity; yt.paying += sub.paying;
      body += line('👦👧 ' + this._copy('capacity_youth_group', { from: g.from, to: g.to, cap: g.cap }), sub, 'B', 'group');
      body += g.rows.map(r => line(this._copy('capacity_age', { age: r.us_age }) || `U${r.us_age}`, r, 'B', 'item')).join('');
    }
    if (groups.length) body += line(this._copy('capacity_youth_total') || 'Youth total', yt, 'B', 'group');
    // against the Year plan (same year pills)
    const thisYear = ((this.flow || {}).year || {}).label || '';
    const years = [...new Set([...(this.expenses.plan || []).map(l => l.budget_year), ...(this.expenses.budget || []).map(b => b.budget_year)].filter(Boolean))].sort();
    const year = this.planYear || (years.includes(thisYear) ? thisYear : years[0]);
    const yearBar = years.length > 1 ? `<div class="fn-pills" style="margin:4px 0 6px;">${years.map(y => `<button class="fn-pill ${y === year ? 'on' : ''}" data-plan-year="${esc(y)}">${esc(this._copy('plan_year_pill', { year: y }) || y)}</button>`).join('')}</div>` : '';
    const cost = this._yearCost(year), need = cost / 12;
    const spare = tot.full - need;
    body += `<tr class="sum"><td>${esc(this._copy('capacity_total') || 'Whole club')}</td><td>${tot.members}</td><td>${tot.capacity}</td><td class="fn-warn">${Math.max(0, tot.capacity - tot.members)}</td><td>${M0(tot.now)}</td><td class="fn-in">${M0(tot.full)}</td></tr>
      <tr><td colspan="4">${esc(this._copy('capacity_need', { year, total: M0(cost) }))}</td><td class="fn-out">${M0(need)}</td><td class="fn-out">${M0(need)}</td></tr>
      <tr class="sum"><td colspan="4">${esc(this._copy('capacity_gap_now') || 'Short now')} · ${esc(this._copy(spare >= 0 ? 'capacity_spare' : 'capacity_short'))}</td>
        <td class="${tot.now >= need ? 'fn-in' : 'fn-out'}">${M0(tot.now - need)}</td><td class="${spare >= 0 ? 'fn-in' : 'fn-out'}">${M0(spare)}</td></tr>`;
    return `<div class="fn-card"><div class="fn-title">${esc(this._copy('capacity_title'))}</div><div class="fn-note">${esc(this._copy('capacity_note'))}</div>${yearBar}
      <div style="overflow-x:auto;"><table class="fn-table" style="min-width:560px;"><thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead><tbody>${body}</tbody></table></div></div>`;
  }

  // ── Budget lines: edit the estimate, ✓ when the bill is finished (mig 921) ──
  _budgetHtml() {
    const esc = (t) => this.escapeHtml(t), M2 = FinancesScreen.money2;
    const lines = (this.expenses.budget || []).filter(b => this._scopeOk(b.scope) && b.this_year !== false);
    if (!lines.length) return '';
    const cols = (this._copy('budget_columns') || '').split('|').map(c => c.trim());
    const per = (b) => b.amount_per === 'member' ? this._copy('budget_per_member', { units: b.units }) : b.amount_per === 'week' ? this._copy('budget_per_week', { units: b.units }) : '';
    const rows = lines.map(b => `
      <tr data-budget-line="${b.id}" class="${b.settled ? 'fn-dim' : ''}">
        <td style="white-space:normal;">${esc(b.label)}${b.is_assumed ? '*' : ''}${b.section ? ` <span class="fn-dim">· ${esc(b.section)}</span>` : ''}</td>
        <td><input class="fn-amt" data-budget-amount type="number" min="0" step="0.01" value="${Number(b.amount).toFixed(2)}" aria-label="${esc(cols[1] || '')}"><span class="fn-tick">${esc(per(b))}</span></td>
        <td>${b.invoiced ? M2(b.invoiced) : '<span class="fn-dim">–</span>'}</td>
        <td class="fn-out">${b.remaining ? M2(b.remaining) : '<span class="fn-dim">–</span>'}</td>
        <td><input type="checkbox" data-budget-settled ${b.settled ? 'checked' : ''} aria-label="${esc(cols[4] || '')}"></td>
      </tr>`).join('');
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('budget_title'))}</div>
        <div class="fn-note">${esc(this._copy('budget_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:560px;">
          <thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${rows}</tbody>
        </table></div>
      </div>`;
  }

  // ── 🧪 Playground (mig 1361, owner 2026-11-14: "a playground where i can do
  // this and not touch current live ones and real projected"): a what-if copy
  // of a budget year in its own tables. Teams × players × dues in, teams ×
  // (cost + kits + their coaches) out; ↺ rebuilds the year from the real plan.
  async _pgLoad(year) {
    if (this.pgLoading) return; this.pgLoading = true;
    try {
      const res = await this.auth.fetch(`/api/finances/playground${year ? `?year=${encodeURIComponent(year)}` : ''}`);
      const j = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(j.error || `HTTP ${res.status}`);
      this.pg = j; this.pgErr = '';
    } catch (err) { this.pgErr = err.message; this.pg = this.pg || { failed: true }; }
    this.pgLoading = false; this._renderBody();
  }

  async _pgPost(change) {
    try {
      const res = await this.auth.fetch('/api/finances/playground', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ year: this.pg.year.label, ...change }) });
      const j = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(j.error || `HTTP ${res.status}`);
      this.pg = j; this.pgErr = '';
    } catch (err) { this.pgErr = err.message; }
    this._renderBody();
  }

  _pgClick(e) {
    const y = e.target.closest('[data-pg-year]'); if (y) { this.pgResetArm = false; this._pgLoad(y.dataset.pgYear); return true; }
    if (e.target.closest('[data-pg-reset]')) {
      if (!this.pgResetArm) { this.pgResetArm = true; this._renderBody(); return true; }
      this.pgResetArm = false; this._pgPost({ action: 'reset' }); return true;
    }
    const a = e.target.closest('[data-pg-act]'); if (!a) return false;
    const id = a.dataset.id ? Number(a.dataset.id) : undefined, group = a.dataset.group;
    switch (a.dataset.pgAct) {
      case 'add-team': this._pgPost({ action: 'add', kind: 'team', group, label: this._copy(group === 'C' ? 'pg_new_line' : 'pg_new_team') || 'New team' }); break;
      case 'copy-team': this._pgPost({ action: 'add', kind: 'team', group, copy_of: id, label: this._copy('pg_b_suffix') || ' B' }); break;
      case 'add-coach': this._pgPost({ action: 'add', kind: 'coach', group, ...(id ? { team_id: id } : {}), label: this._copy('pg_new_coach') || 'New coach' }); break;
      case 'del-team': this._pgPost({ action: 'delete', kind: 'team', id }); break;
      case 'del-coach': this._pgPost({ action: 'delete', kind: 'coach', id }); break;
      default: return false;
    }
    return true;
  }

  _pgChange(el) {
    const kind = el.dataset.pgKind, field = el.dataset.pgField;
    const text = field === 'label' || field === 'per';
    const raw = el.value.trim();
    let value = text ? raw : Number(raw);
    if (!text && (field === 'roster' || field === 'us_age') && raw === '') value = null;
    if ((text && !raw) || (!text && value !== null && (raw === '' || !Number.isFinite(value)))) { this._renderBody(); return; }
    const change = { action: 'save', kind, fields: { [field]: value } };
    if (kind === 'group') change.group = el.dataset.group; else change.id = Number(el.dataset.id);
    this._pgPost(change);
  }

  // The sums, per group: { teams, players, income, cost, rows }.
  _pgSums() {
    const pg = this.pg, coachCost = (c) => Number(c.rate_per_hour) * Number(c.hours) * Number(c.times);
    const out = {};
    for (const g of pg.groups) {
      const teams = pg.teams.filter(t => t.group === g.code);
      const rows = teams.map(t => {
        const n = Number(t.team_count), coaches = pg.coaches.filter(c => c.team_id === t.id);
        const coaching = n * coaches.reduce((a, c) => a + coachCost(c), 0);
        const kits = n * Number(t.players) * Number(g.kit_per_player);
        const cost = n * Number(t.cost_per_team) + coaching + kits;
        const income = n * Number(t.players) * Number(g.dues_monthly) * 12;
        return { t, coaches, coaching, kits, cost, income };
      });
      const sectionCoaches = pg.coaches.filter(c => c.group === g.code && c.team_id == null);
      const sectionCoaching = sectionCoaches.reduce((a, c) => a + coachCost(c), 0);
      out[g.code] = { g, rows, sectionCoaches, sectionCoaching,
        teams: g.code === 'C' ? 0 : rows.reduce((a, r) => a + Number(r.t.team_count), 0),
        players: g.code === 'C' ? 0 : rows.reduce((a, r) => a + Number(r.t.team_count) * Number(r.t.players), 0),
        income: rows.reduce((a, r) => a + r.income, 0),
        cost: rows.reduce((a, r) => a + r.cost, 0) + sectionCoaching };
    }
    return { out, coachCost };
  }

  _pgHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, M2 = FinancesScreen.money2;
    if (!this.pg) { this._pgLoad(); return '<div class="loading">Loading…</div>'; }
    const pg = this.pg;
    const err = this.pgErr ? `<div class="error-message">${esc(this.pgErr)}</div>` : '';
    if (pg.failed || !pg.year) return `<div class="fn-card">${err}</div>`;
    const cols = (tier, d) => (this._copy(tier) || d).split('|').map(c => `<th>${esc(c.trim())}</th>`).join('');
    const year = pg.year.label;
    const yearBar = `<div class="fn-pills" style="margin:4px 0 6px;">${pg.years.map(y => `<button class="fn-pill ${y.label === year ? 'on' : ''}" data-pg-year="${esc(y.label)}">${esc(y.label)}</button>`).join('')}
      <button class="fn-pill" style="margin-left:auto; ${this.pgResetArm ? 'background:#b91c1c; color:#fff; border-color:#b91c1c;' : ''}" data-pg-reset>${esc(this.pgResetArm ? this._copy('pg_reset_confirm', { year }) : this._copy('pg_reset') || '↺ Reset')}</button></div>`;
    const copied = pg.year.copied_from ? `<div class="fn-note fn-warn">${esc(this._copy('pg_copied', { from: pg.year.copied_from }))}</div>` : '';
    const { out, coachCost } = this._pgSums();
    const inp = (kind, id, field, value, w = 64, extra = '') => `<input class="fn-amt" style="width:${w}px;${field === 'label' ? ' text-align:left;' : ''}" data-pg-kind="${kind}" data-id="${id}" data-pg-field="${field}" value="${esc(value == null ? '' : String(value))}"${extra}>`;
    const num = (kind, id, field, value, w = 64, step = 'any') => inp(kind, id, field, value, w, ` type="number" min="0" step="${step}"`);
    const txt = (kind, id, field, value, w = 170) => inp(kind, id, field, value, w, ' type="text" maxlength="80"');
    const btn = (act, label, attrs) => `<button class="fn-pill" style="padding:3px 9px; font-size:0.78rem;" data-pg-act="${act}" ${attrs}>${esc(label)}</button>`;
    const coachRow = (c, perTeam) => `<tr class="item"><td>${txt('coach', c.id, 'label', c.label, 220)}</td>
        <td>${num('coach', c.id, 'rate_per_hour', c.rate_per_hour, 64)}</td><td>${num('coach', c.id, 'hours', c.hours, 60)}</td>
        <td>${num('coach', c.id, 'times', c.times, 60)} <select class="fn-amt" style="width:auto;" data-pg-kind="coach" data-id="${c.id}" data-pg-field="per">
          <option value="week" ${c.per === 'week' ? 'selected' : ''}>${esc(this._copy('pg_per_week') || 'weeks')}</option>
          <option value="game" ${c.per === 'game' ? 'selected' : ''}>${esc(this._copy('pg_per_game') || 'games')}</option></select></td>
        <td class="fn-out">${M0(coachCost(c))}${perTeam ? ` <span class="fn-dim">× ${perTeam}</span>` : ''}</td><td>${btn('del-coach', '✕', `data-id="${c.id}"`)}</td></tr>`;
    const coachTable = (list, perTeam) => list.length ? `<table class="fn-table" style="margin:2px 0 8px 18px;"><thead><tr>${cols('pg_coach_columns', 'Coach|$ / hour|Hours|Times a year|Cost / yr')}<th></th></tr></thead><tbody>${list.map(c => coachRow(c, perTeam)).join('')}</tbody></table>` : '';

    // summary
    let sum = '', tIn = 0, tCost = 0, payers = 0;
    for (const code of Object.keys(out)) {
      const s = out[code], net = s.income - s.cost; tIn += s.income; tCost += s.cost;
      if (Number(s.g.dues_monthly) > 0) payers += s.players;
      sum += `<tr><td>${esc(`${s.g.emoji || ''} ${s.g.label}`)}</td><td>${code === 'C' ? '' : s.teams}</td><td>${code === 'C' ? '' : s.players}</td>
        <td class="fn-in">${s.income ? M0(s.income) : '<span class="fn-dim">—</span>'}</td><td class="fn-out">${M0(s.cost)}</td>
        <td class="${net >= 0 ? 'fn-in' : 'fn-out'}">${M0(net)}</td><td class="${net >= 0 ? 'fn-in' : 'fn-out'}">${M0(net / 12)}</td></tr>`;
    }
    const tNet = tIn - tCost;
    sum += `<tr class="sum"><td>${esc(this._copy('pg_total') || 'Whole club')}</td><td></td><td>${payers}</td><td class="fn-in">${M0(tIn)}</td><td class="fn-out">${M0(tCost)}</td>
      <td class="${tNet >= 0 ? 'fn-in' : 'fn-out'}">${M0(tNet)}</td><td class="${tNet >= 0 ? 'fn-in' : 'fn-out'}">${M0(tNet / 12)}</td></tr>`;
    const breakEven = payers > 0 ? `<div class="fn-note" style="margin-top:6px; font-weight:700; opacity:0.9;">${esc(this._copy('pg_break_even', { dues: M2(tCost / payers / 12), players: payers }))}</div>` : '';

    // one card per group
    let cards = '';
    for (const code of Object.keys(out)) {
      const s = out[code], g = s.g;
      if (code === 'C') {
        cards += `<div class="fn-card"><div class="fn-title">${esc(`${g.emoji || ''} ${g.label}`)} · <span class="fn-out">${M0(s.cost)}</span></div>
          <table class="fn-table" style="margin-top:6px;"><thead><tr>${cols('pg_club_columns', 'Line|Cost / yr')}<th></th></tr></thead><tbody>
          ${s.rows.map(r => `<tr><td title="${esc(r.t.note || '')}">${txt('team', r.t.id, 'label', r.t.label, 240)}${r.t.is_assumed ? '*' : ''}</td><td>${num('team', r.t.id, 'cost_per_team', r.t.cost_per_team, 90)}</td><td>${btn('del-team', '✕', `data-id="${r.t.id}"`)}</td></tr>`).join('')}
          </tbody></table><div style="margin-top:6px;">${btn('add-team', this._copy('pg_add_line') || '＋ Line', `data-group="C"`)}</div></div>`;
        continue;
      }
      const net = s.income - s.cost;
      let rows = '';
      for (const r of s.rows) {
        const t = r.t, over = t.roster != null && Number(t.players) > Number(t.roster);
        rows += `<tr class="${Number(t.team_count) ? '' : 'fn-dim'}"><td title="${esc(t.note || '')}">${txt('team', t.id, 'label', t.label, 150)}${t.is_assumed ? '*' : ''}${t.note ? `<span class="fn-tick">${esc(t.note)}</span>` : ''}</td>
          <td>${num('team', t.id, 'team_count', t.team_count, 52, '1')}</td>
          <td class="${over ? 'fn-warn' : ''}" title="${over ? esc(this._copy('pg_over_roster')) : ''}">${num('team', t.id, 'players', t.players, 56, '1')}${over ? ' ⚠' : ''}</td>
          <td>${num('team', t.id, 'roster', t.roster, 56, '1')}</td>
          <td>${num('team', t.id, 'cost_per_team', t.cost_per_team, 84)}</td>
          <td class="fn-out">${M0(r.coaching)}</td><td class="fn-out">${M0(r.kits)}</td><td class="fn-out">${M0(r.cost)}</td><td class="fn-in">${r.income ? M0(r.income) : '<span class="fn-dim">—</span>'}</td>
          <td style="white-space:nowrap;">${btn('copy-team', this._copy('pg_copy_team') || '⧉ B team', `data-id="${t.id}" data-group="${code}"`)} ${btn('add-coach', this._copy('pg_add_coach') || '＋ Coach', `data-id="${t.id}" data-group="${code}"`)} ${btn('del-team', '✕', `data-id="${t.id}"`)}</td></tr>`;
        if (r.coaches.length) rows += `<tr><td colspan="10" style="padding:0;">${coachTable(r.coaches, Number(t.team_count) !== 1 ? t.team_count : 0)}</td></tr>`;
      }
      cards += `<div class="fn-card">
        <div class="fn-title">${esc(`${g.emoji || ''} ${g.label}`)} · <span class="${net >= 0 ? 'fn-in' : 'fn-out'}">${M0(net)} / yr</span></div>
        <div style="display:flex; flex-wrap:wrap; gap:14px; margin:6px 0 8px;">
          <label>${esc(this._copy('pg_dues') || 'Dues / month')} ${inp('group', '', 'dues_monthly', g.dues_monthly, 70, ` type="number" min="0" step="any" data-group="${code}"`)}</label>
          <label>${esc(this._copy('pg_kit') || 'Kit per player')} ${inp('group', '', 'kit_per_player', g.kit_per_player, 70, ` type="number" min="0" step="any" data-group="${code}"`)}</label>
          ${g.note ? `<span class="fn-note">${esc(g.note)}</span>` : ''}</div>
        <div style="overflow-x:auto;"><table class="fn-table"><thead><tr>${cols('pg_team_columns', 'Team|Teams|Players per team|Roster|Cost per team|Coaching|Kits|Cost / yr|Income / yr')}<th></th></tr></thead><tbody>${rows}</tbody></table></div>
        <div style="margin:6px 0;">${btn('add-team', this._copy('pg_add_team') || '＋ Team', `data-group="${code}"`)}</div>
        <div style="font-weight:800; margin-top:8px;">${esc(this._copy('pg_section_coaches') || 'Coaches for the whole section')} · <span class="fn-out">${M0(s.sectionCoaching)}</span></div>
        ${coachTable(s.sectionCoaches, 0)}
        <div>${btn('add-coach', this._copy('pg_add_coach') || '＋ Coach', `data-group="${code}"`)}</div>
      </div>`;
    }
    return `<div class="fn-card"><div class="fn-title">${esc(this._copy('pg_title') || 'Playground')}</div><div class="fn-note">${esc(this._copy('pg_note'))}</div>
      ${yearBar}${copied}${err}
      <div style="overflow-x:auto;"><table class="fn-table" style="min-width:520px;"><thead><tr>${cols('pg_summary_columns', 'Section|Teams|Players|Income / yr|Cost / yr|Net / yr|Net / mo')}</tr></thead><tbody>${sum}</tbody></table></div>
      ${breakEven}<div class="fn-note">${esc(this._copy('assumed_note') || '* assumed')}</div></div>${cards}`;
  }
}
window.FinancesScreen = FinancesScreen;
