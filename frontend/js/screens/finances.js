// finances.js — #finances: where the club stands and where it is heading
// (migration 489/490).  Billing stays on #payments.
//
// The standard nonprofit set only (owner 2026-11-14 "just the standard … take
// out everything else root and stem … we will start clean", mig 1367):
//   Budget        the operating budget for a budget year (Aug 1 – Jul 31):
//                 Revenue (dues = paying members × dues × 12; grants awarded
//                 or received = revenue with donor restrictions), Expenses by
//                 category, Net surplus / (deficit) for the year and per month
//   Budget vs Actual (mig 1369) the variance report: this budget year's
//                 Budget beside the money that really moved, through the last
//                 closed month
//   Soccer fund   (mig 1372) statement of financial position, club-wide:
//                 soccer has no bank account of its own — Lighthouse holds its
//                 money — so cash = everything earned since the budget year
//                 began − invoices paid (paid = final), plus what is owed each way
//   Actuals       (mig 977) MoneyView: money that really came in and went out
//   Cash forecast the month-by-month grid of money still to come and go
//                 — GET /api/finances/expenses; ✓ = invoiced
//
// Wording: message_templates kind 'payments_overview' (summary / revenue)
// and 'finances' (page, pills, cash flow).
class FinancesScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.summary = null; this.expenses = null; this.view = 'plan'; this.err = ''; this.expanded = new Set(); this.money = null; this.scope = 'all'; }

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
      const v = e.target.closest('[data-view]'); if (v) { this.view = v.dataset.view; this._renderBody(); return; }
      const yp = e.target.closest('[data-plan-year]'); if (yp) { this.planYear = yp.dataset.planYear; this._renderBody(); return; }
      if (this.view === 'money' && this.money && this.money.handleClick(e)) { this._renderBody(); return; }
      const c = e.target.closest('[data-cat]'); if (c) { const k = c.dataset.cat; if (this.expanded.has(k)) this.expanded.delete(k); else this.expanded.add(k); this._renderBody(); }
    });
    return div;
  }

  onEnter() { this.load(); }
  // The three loads every pill reads (restored 11/14 — 4289d849 took load()
  // out with the budget-line editor, and the page never got its data).
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
      // Actuals (MoneyView, mig 977) shares the three loads.
      if (window.MoneyView) { this.money = this.money || new MoneyView(this); Object.assign(this.money, { flow: fj, summary: sj, expenses: xj, scope: this.scope }); }
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('finances', tier, tokens) : ''; }
  _ov(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('payments_overview', tier, tokens) : ''; }
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
    // The standard nonprofit set only (owner 2026-11-14 "just the standard … take out
    // everything else root and stem … we will start clean"): operating budget,
    // actuals, cash-flow forecast.
    const pills = [['plan', this._copy('pill_plan') || 'Budget'], ['variance', this._copy('pill_variance') || 'Budget vs Actual'], ['fund', this._copy('pill_fund') || 'Soccer fund'], ['money', this._copy('pill_money') || 'Actuals'], ['expenses', this._copy('pill_expenses') || 'Cash forecast']];
    el.innerHTML = pills.map(([k, l]) => `<button class="fn-pill ${this.view === k ? 'on' : ''}" data-view="${k}">${this.escapeHtml(l)}</button>`).join('');
  }

  _renderBody() {
    this._renderPills();
    const body = this.find('#fn-body'); if (!body) return;
    if (this.view === 'money' && !this.err) { body.innerHTML = this.money && this.money.ready() ? this.money.html({ who: false }) : '<div class="loading">Loading…</div>'; return; }
    if (this.err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.summary || !this.expenses) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    body.innerHTML = this.view === 'plan' ? this._planHtml() : this.view === 'variance' ? this._varianceHtml() : this.view === 'fund' ? this._fundHtml() : this._expensesHtml();
  }

  // ── shared bits ──
  static money0(v) { const n = Math.round(Number(v) || 0); return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(); }
  static money2(v) { const n = Number(v) || 0; return (n < 0 ? '−' : '') + '$' + Math.abs(n).toFixed(2); }
  _emoji(code) { return { M: '👨', W: '👩', B: '👦', G: '👧' }[code] || ''; }
  _cols(tier) { return this._ov(tier).split('|').map(c => c.trim()).filter(Boolean); }
  // ── Cash forecast: the month-by-month grid of money still to come and go ──
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

    const seasons = (x.ref_fees || []).flatMap(p => (p.seasons || []).map(s => `${p.kind === 'coaching' ? 'Coaching ' : 'Refs '}${p.label} ${s.label}: ${s.known} on the schedule of ${s.expected}${s.is_assumed ? '*' : ''}`));
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('cash_title') || 'Cash flow')}</div>
        <div class="fn-note">${esc(this._copy('cash_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table"><thead>${head}</thead><tbody>${html}</tbody></table></div>
        <div class="fn-note" style="margin-top:8px;">${esc(this._copy('assumed_note') || '* assumed')} · ${esc(seasons.join(' · '))}</div>
      </div>`;
  }

  // ── Budget (mig 1320 → 1367): the operating budget for a budget year —
  // Revenue, Expenses by category (rate × quantity from each team's fee plan,
  // section + club-wide lines, game coaching), Net surplus / (deficit).
  // The year's budget as data — Budget and Budget vs Actual both read it, so
  // the two can never disagree.
  _budgetModel(pick) {
    const M0 = FinancesScreen.money0, M2 = FinancesScreen.money2;
    // Year pills (mig 1334, owner: "have a pill for next year budget too").
    const thisYear = ((this.flow || {}).year || {}).label || '';
    const years = [...new Set([...(this.expenses.plan || []).map(l => l.budget_year), ...(this.expenses.budget || []).map(b => b.budget_year)].filter(Boolean))].sort();
    const year = pick || (years.includes(thisYear) ? thisYear : years[0]);
    const yearsAll = [...new Set([...years, ...(this.expenses.plan_grants || []).map(g => g.budget_year)])].sort();
    const grants = (this.expenses.plan_grants || []).filter(g => g.budget_year === year);
    // options (is_option entries — Liga 2, Temple 7s) are not in the budget
    const lines = (this.expenses.plan || []).filter(l => this._scopeOk(l.scope) && l.budget_year === year && !l.is_option);
    // Section-wide costs (budget_lines on a section's own pill — kits, coaching):
    // one "general" group per section, amount × units over the whole year (mig 1329).
    const scopes0 = (this.flow || {}).scopes || [];
    // section-wide and club-wide lines (not a team's)
    const general = (this.expenses.budget || []).filter(b => this._scopeOk(b.scope) && b.budget_year === year && scopes0.some(sc => sc.code === b.scope && (sc.section_code || !sc.team_id)));
    // ── Standard budget (owner 2026-11-14 "lets be standard"): Revenue,
    // Expenses by category (natural classification, each category opens to
    // its lines), Net surplus / (deficit) for the year and per month.
    const qty = (n) => Number(n) % 1 ? Number(n).toFixed(2) : String(Number(n));
    const coachingLabel = this._copy('coaching_label') || 'Coaching';
    const items = [];   // { category, category_label, label, detail, unit, amount, assumed, note }
    for (const l of lines) items.push({ category: l.category, category_label: l.category_label, label: `${l.short_label || l.team} — ${l.label}`,
      detail: `${M2(l.rate)} × ${qty(l.quantity)}${l.team_count == null ? '' : ` × ${l.team_count}`}`, unit: `${l.unit_label || ''}${l.team_count == null ? '' : ` × ${this._copy('plan_team_count') || 'teams'}`}`,
      amount: Number(l.amount), assumed: l.is_assumed, note: l.note });
    for (const b of general) items.push({ category: b.category, category_label: b.category_label, label: b.section ? `${b.section} — ${b.label}` : b.label,
      detail: `${M2(b.amount)} × ${qty(b.year_units)}`, unit: b.amount_per === 'member' ? this._copy('plan_unit_member') : b.amount_per === 'new_member' ? (this._copy('plan_unit_new_member') || 'new players') : b.amount_per === 'week' ? this._copy('plan_unit_week') : '',
      amount: Number(b.year_total || 0), assumed: b.is_assumed, note: b.note });
    // Game coaching (mig 1332): each coaching policy under the pill — games × pay per game
    for (const p of (this.expenses.ref_fees || []).filter(p => year === thisYear && p.kind === 'coaching' && this._scopeOk(p.scope) && scopes0.some(sc => sc.code === p.scope && (sc.section_code || !sc.team_id)))) {
      const games = (p.seasons || []).reduce((a, x) => a + Number(x.expected || 0), 0); if (!games) continue;
      items.push({ category: 'labor', category_label: coachingLabel, label: this._copy('plan_game_coaching', { label: p.label }) || `Game coaching — ${p.label}`,
        detail: `${M2(p.rate)} × ${games}`, unit: this._copy('plan_unit_game', { hours: p.hours_per_game, rate: M2(p.rate_per_hour) }),
        amount: Number(p.rate) * games, assumed: (p.seasons || []).some(x => x.is_assumed), note: p.note });
    }
    // A section pill carries its share of the club-wide costs (allocated
    // overhead), split by PAYING members (owner 2026-11-13: "so women don't bear it").
    const scopesS = (this.flow || {}).scopes || [];
    const pillS = scopesS.find(sc => sc.code === this.scope);
    const underS = (code) => { const set = window.MoneyView ? MoneyView.inScopeOf(scopesS, code) : new Set([code]); return scopesS.filter(sc => set.has(sc.code) && sc.section_code).map(sc => sc.section_code); };
    const shareCodes = pillS && !pillS.team_id && this.scope !== 'club' ? underS(pillS.code) : [];
    const allHeads = this.expenses.plan_heads || [];
    const allPaying = allHeads.reduce((a, h) => a + Number(h.paying || 0), 0);
    const myPaying = allHeads.filter(h => shareCodes.includes(h.code)).reduce((a, h) => a + Number(h.paying || 0), 0);
    const frac = shareCodes.length && allPaying > 0 ? myPaying / allPaying : 0, pct = `${Math.round(100 * frac)}%`;
    if (frac > 0) {
      const clubTotal = (this.expenses.budget || []).filter(b => b.scope === 'club' && b.budget_year === year).reduce((a, b) => a + Number(b.year_total || 0), 0)
                      + (this.expenses.plan || []).filter(l => l.scope === 'club' && l.budget_year === year).reduce((a, l) => a + Number(l.amount || 0), 0);
      if (clubTotal > 0) items.push({ category: 'allocated', category_label: this._copy('plan_club_share', { pct, active: myPaying, all: allPaying }) || 'Share of club-wide costs',
        label: this._copy('plan_club_share_line', { total: M0(clubTotal) }), detail: `${M0(clubTotal)} × ${pct}`, unit: '', amount: clubTotal * frac });
    }
    // Revenue: dues = paying members (active, not free / volunteer / injured,
    // never pickup) × monthly dues × 12, per section under the pill; a team
    // pill has none (dues are pooled per section).
    const revCodes = !pillS ? allHeads.map(h => h.code) : shareCodes;
    const secName = (code) => ((this.summary || {}).sections || []).find(s => s.code === code)?.name || code;
    const revenue = [];
    for (const h of allHeads.filter(h => revCodes.includes(h.code))) {
      const monthly = Number(((this.expenses.plan_dues || []).find(d => d.section_id === h.section_id) || {}).monthly || 0);
      const paying = Number(h.paying || 0), covered = paying === 0 && Number(h.active || 0) > 0;
      revenue.push({ kind: 'dues', code: h.code, label: this._copy('plan_rev_dues', { section: secName(h.code) }) || `Dues — ${secName(h.code)}`,
        detail: covered ? (this._copy('plan_split_club_covers') || 'club covers') : `${paying} × ${M0(monthly)} × 12`,
        unit: covered ? '' : (this._copy('plan_rev_dues_unit') || 'paying members × dues a month × 12 months'), amount: covered ? 0 : paying * monthly * 12, assumed: year !== thisYear });
    }
    // Grants awarded or received = revenue with donor restrictions (restricted to
    // their purpose, or to what the label names when it has no single purpose);
    // sponsorships (mig 1372) pay Lighthouse, soccer takes the credit. A section
    // pill carries its paying-member share.
    const share = pillS ? frac : 1;
    for (const g of share ? grants : []) {
      const purpose = String(g.purpose_label || (g.purpose === 'labor' ? coachingLabel : g.purpose || '')).replace(/:\s*$/, '');
      const label = g.kind === 'sponsorship' ? (this._copy('plan_rev_sponsor', { label: g.label }) || `Sponsor — ${g.label}`)
        : purpose ? (this._copy('plan_rev_grant', { label: g.label, purpose }) || `Grant — ${g.label}`)
        : (this._copy('plan_rev_grant_multi', { label: g.label }) || `Grant (restricted) — ${g.label}`);
      // received = the dated receipts, or the whole award once marked received
      const receipts = (g.receipts || []).length ? g.receipts : (g.status === 'received' ? [{ on: '', amount: Number(g.amount) }] : []);
      revenue.push({ kind: 'award', share, receipts, label,
        detail: pillS ? `${M0(g.amount)} × ${pct}` : '', unit: g.note || '', amount: Number(g.amount) * share, assumed: g.status !== 'received' });
    }
    // Field rental income (mig 1372; owner: "CASA Rental that soccer club
    // handles so we count that as money soccer earned", "casa always pays"):
    // every booking on the calendar in the year, club-wide, shared like grants.
    if (year === thisYear && share) {
      const fy = (this.flow || {}).year || {}, s0 = String(fy.starts_on || '').slice(0, 7), e0 = String(fy.ends_on || '').slice(0, 7);
      const bookings = ((this.flow || {}).items || []).filter(i => i.dir === 'in' && i.category === 'rental' && i.ym >= s0 && (!e0 || i.ym <= e0));
      const total = bookings.reduce((a, i) => a + Number(i.amount || 0), 0);
      if (total) revenue.push({ kind: 'rental', share, label: this._copy('plan_rev_rental') || 'Field rental income',
        detail: pillS ? `${M0(total)} × ${pct}` : `${bookings.length}`, unit: this._copy('plan_rev_rental_unit') || 'bookings on the calendar',
        amount: total * share, assumed: bookings.some(i => i.ahead) });
    }
    // expenses by category, in the club's category order
    const order = (this._copy('category_order') || '').split('|').map(t => t.trim()).filter(Boolean);
    const byCat = new Map();
    // refundable bonds are a deposit soccer gets back (an asset on Soccer fund), never an expense
    for (const it of items.filter(it => it.category !== 'bonds')) { if (!byCat.has(it.category)) byCat.set(it.category, { code: it.category, label: it.category === 'labor' ? coachingLabel : String(it.category_label || it.category).replace(/:\s*$/, ''), items: [] }); byCat.get(it.category).items.push(it); }
    const rank = (c) => c === 'allocated' ? 999 : (order.indexOf(c) < 0 ? 500 : order.indexOf(c));
    const cats = [...byCat.values()].sort((a, b) => rank(a.code) - rank(b.code));
    for (const c of cats) c.sub = c.items.reduce((a, it) => a + it.amount, 0);
    return { thisYear, year, yearsAll, empty: !lines.length && !general.length, revenue, cats, rank,
             revTotal: revenue.reduce((a, r) => a + r.amount, 0), expTotal: cats.reduce((a, c) => a + c.sub, 0), frac, pct, pillS, coachingLabel };
  }

  // ── Budget (mig 1320 → 1367): the operating budget for a budget year —
  // Revenue, Expenses by category, Net surplus / (deficit).
  _planHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const m = this._budgetModel(this.planYear), year = m.year, revenue = m.revenue;
    // Year pills (mig 1334, owner: "have a pill for next year budget too").
    const yearBar = m.yearsAll.length > 1 ? `<div class="fn-pills" style="margin:4px 0 6px;">${m.yearsAll.map(y => `<button class="fn-pill ${y === year ? 'on' : ''}" data-plan-year="${esc(y)}">${esc(this._copy('plan_year_pill', { year: y }) || y)}</button>`).join('')}</div>` : '';
    const head = `<div class="fn-title">${esc(this._copy('plan_title') || 'Year plan')}</div><div class="fn-note">${esc(this._copy('plan_note'))}</div>`;
    if (m.empty) return `<div class="fn-card">${head}${yearBar}<div class="fn-dim">${esc(this._copy('plan_empty'))}</div></div>`;
    const cols = (this._copy('plan_columns') || 'Line|Rate × qty|Year').split('|').map(c => c.trim());
    const revTotal = m.revTotal;
    const line = (it, cls) => `<tr class="${cls}"><td title="${esc(it.note || '')}" style="white-space:normal;">${esc(it.label)}${it.assumed ? '*' : ''}${it.note ? `<span class="fn-tick">${esc(it.note)}</span>` : ''}</td>
        <td>${esc(it.detail || '')}<span class="fn-tick">${esc(it.unit || '')}</span></td><td class="${cls.includes('rev') ? 'fn-in' : (it.amount < 0 ? 'fn-in' : 'fn-out')}">${M0(it.amount)}</td></tr>`;
    let rows = `<tr class="group"><td colspan="3">${esc(this._copy('plan_revenue') || 'Revenue')}</td></tr>`;
    rows += revenue.length ? revenue.map(r => line(r, 'item rev')).join('') : `<tr class="item"><td colspan="3" class="fn-dim">${esc(this._copy('plan_rev_none') || 'No dues on this pill — dues are pooled per section')}</td></tr>`;
    rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_rev_total') || 'Total revenue')}</td><td class="fn-in">${M0(revTotal)}</td></tr>`;
    rows += `<tr class="group"><td colspan="3">${esc(this._copy('plan_expenses') || 'Expenses')}</td></tr>`;
    const total = m.expTotal;
    for (const c of m.cats) {
      const sub = c.sub, key = `plan:${c.code}`, open = this.expanded.has(key);
      rows += `<tr class="cat ${open ? 'open' : ''}" data-cat="${esc(key)}"><td colspan="2">${esc(c.label)}</td><td class="fn-out">${M0(sub)}</td></tr>`;
      if (open) rows += c.items.sort((a, b) => b.amount - a.amount).map(it => line(it, 'item')).join('');
    }
    rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_exp_total') || 'Total expenses')}</td><td class="fn-out">${M0(total)}</td></tr>`;
    const net = revTotal - total;
    rows += `<tr class="sum"><td colspan="2">${esc(this._copy(net >= 0 ? 'plan_net_surplus' : 'plan_net_deficit') || 'Net')}</td><td class="${net >= 0 ? 'fn-in' : 'fn-out'}">${M0(net)}</td></tr>
      <tr class="item"><td colspan="2">${esc(this._copy('plan_net_month') || 'Per month')}</td><td class="${net >= 0 ? 'fn-in' : 'fn-out'}">${M0(net / 12)}</td></tr>`;
    return `
      <div class="fn-card">${head}${yearBar}
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:480px;">
          <thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${rows}</tbody>
        </table></div>
        <div class="fn-note" style="margin-top:8px;">${esc(this._copy('assumed_note') || '* assumed')}</div>
      </div>`;
  }

  // ── Budget vs Actual (mig 1369): the variance report. Each Budget line
  // (_budgetModel, this budget year) beside what really came in and went out
  // (/cash-flow items, not ahead) through the last closed month. Budget to
  // date = the year's budget × closed months / 12. Variance is favourable when
  // positive: revenue above budget, expenses below it.
  _varianceHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const flow = this.flow || {}, m = this._budgetModel(((flow.year || {}).label) || undefined);
    const scopes = flow.scopes || [];
    const startYm = String(flow.start || (flow.year || {}).starts_on || '').slice(0, 7), endYm = String((flow.year || {}).ends_on || '').slice(0, 7);
    const nowYm = String(this.expenses.today || '').slice(0, 7);
    let closed = 0;
    if (startYm && nowYm) { let [y, mo] = startYm.split('-').map(Number); for (;;) { const ym = `${y}-${String(mo).padStart(2, '0')}`; if (ym >= nowYm || (endYm && ym > endYm)) break; closed++; mo++; if (mo > 12) { mo = 1; y++; } } }
    const share = Math.min(closed, 12) / 12;
    const lastDay = (() => { if (!closed) return ''; const [y, mo] = nowYm.split('-').map(Number); return new Date(y, mo - 1, 0).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }); })();
    const head = `<div class="fn-title">${esc(this._copy('var_title') || 'Budget vs Actual')} · ${esc(m.year || '')}</div>
      <div class="fn-note">${esc(this._copy('var_note', { through: lastDay, months: closed }))}</div>`;
    if (!closed) return `<div class="fn-card">${head}<div class="fn-dim">${esc(this._copy('var_no_months') || 'No month has closed yet in this budget year.')}</div></div>`;

    // Actual money: past the start, before this month, not a projection.
    const inScope = this._inScope();
    const all = (flow.items || []).filter(i => !i.ahead && i.ym >= startYm && i.ym < nowYm && (!endYm || i.ym <= endYm));
    const mine = all.filter(i => !inScope || inScope.has(i.scope));
    const sum = (list) => list.reduce((a, i) => a + Number(i.amount || 0), 0);
    const catLabel = (code) => code === 'labor' ? m.coachingLabel : ((window.MessageCopy && MessageCopy.block('cash_flow', `cat_${code}`)) || ((flow.categories || []).find(c => c.code === code) || {}).label || code);

    // Revenue: dues per section (pooled per section, as in the Budget); grants
    // count once received; any other money in is shown as not budgeted.
    const rev = [], usedIn = new Set();
    for (const r of m.revenue) {
      let actual = 0, lines = [];
      if (r.kind === 'dues') {
        const sec = (scopes.find(sc => sc.section_code === r.code && !sc.team_id) || scopes.find(sc => sc.section_code === r.code) || {}).code;
        const set = sec && window.MoneyView ? MoneyView.inScopeOf(scopes, sec) : new Set();
        lines = mine.filter(i => i.dir === 'in' && i.category === 'dues' && set.has(i.scope));
        lines.forEach(i => usedIn.add(i)); actual = sum(lines);
      } else if (r.kind === 'award') actual = r.receipts.filter(x => !x.on || x.on.slice(0, 7) < nowYm).reduce((a, x) => a + Number(x.amount || 0), 0) * r.share;
      else if (r.kind === 'rental') {
        lines = all.filter(i => i.dir === 'in' && i.category === 'rental');
        lines.forEach(i => usedIn.add(i)); actual = sum(lines) * r.share;
      }
      rev.push({ label: r.label, budget: r.amount, actual, lines });
    }
    const teamPill = m.pillS && m.pillS.team_id;
    const otherIn = new Map();
    for (const i of mine.filter(i => i.dir === 'in' && !usedIn.has(i) && !(teamPill && i.category === 'dues'))) {
      if (!otherIn.has(i.category)) otherIn.set(i.category, []); otherIn.get(i.category).push(i);
    }
    for (const [code, lines] of otherIn) rev.push({ label: this._copy('var_unbudgeted', { label: catLabel(code) }) || `${catLabel(code)} (not in the budget)`, budget: 0, actual: sum(lines), lines });

    // Expenses: each Budget category beside the money out under the pill; a
    // section pill carries its share of the club-wide money out, as it does
    // its share of the club-wide budget.
    const out = mine.filter(i => i.dir === 'out' && i.category !== 'bonds');   // bonds = deposits, not expenses
    const exp = m.cats.filter(c => c.code !== 'allocated').map(c => ({ code: c.code, label: c.label, budget: c.sub, lines: out.filter(i => i.category === c.code) }));
    for (const code of [...new Set(out.map(i => i.category))].filter(code => !exp.some(e => e.code === code)))
      exp.push({ code, label: catLabel(code), budget: 0, lines: out.filter(i => i.category === code) });
    for (const e of exp) e.actual = sum(e.lines);
    exp.sort((a, b) => m.rank(a.code) - m.rank(b.code));
    const alloc = m.cats.find(c => c.code === 'allocated');
    if (alloc) { const club = all.filter(i => i.dir === 'out' && i.scope === 'club' && i.category !== 'bonds'); exp.push({ code: 'allocated', label: alloc.label, budget: alloc.sub, actual: sum(club) * m.frac, lines: [], scaled: m.frac }); }

    // One row: year budget, budget to date, actual, variance, share of the year used.
    const row = (r, isRev, cls, key) => {
      const toDate = r.budget * share, v = isRev ? r.actual - toDate : toDate - r.actual;
      const used = !r.noUsed && r.budget > 0 ? `${Math.round(100 * r.actual / r.budget)}%` : '–';
      return `<tr class="${cls}" ${key ? `data-cat="${esc(key)}"` : ''}><td style="white-space:normal;">${esc(r.label)}</td><td>${M0(r.budget)}</td><td>${M0(toDate)}</td>
        <td class="${isRev ? 'fn-in' : 'fn-out'}">${M0(r.actual)}</td><td style="font-weight:700; color:${Math.round(v) < 0 ? '#fca5a5' : '#86efac'};">${Math.round(v) > 0 ? '+' : ''}${M0(v)}</td><td>${used}</td></tr>`;
    };
    // Opened, a category lists the money that made its actual (same name = one line).
    const linesHtml = (r) => {
      const merged = new Map(); for (const i of r.lines) merged.set(i.name || i.detail || '', (merged.get(i.name || i.detail || '') || 0) + Number(i.amount || 0));
      const label = new Map(scopes.map(sc => [sc.code, sc.label]));
      const scopeOf = new Map(r.lines.map(i => [i.name || i.detail || '', label.get(i.scope) || '']));
      if (!merged.size) return `<tr class="item"><td colspan="6" class="fn-dim">${esc(this._copy('var_no_actual') || 'Nothing paid yet.')}</td></tr>`;
      return [...merged.entries()].sort((a, b) => b[1] - a[1]).map(([n, a]) => `<tr class="item"><td colspan="3" style="white-space:normal;">${esc(n)} <span class="fn-dim">${esc(scopeOf.get(n) || '')}</span></td><td>${M0(a)}</td><td colspan="2"></td></tr>`).join('');
    };
    const cols = (this._copy('var_columns') || 'Line|Year budget|Budget to date|Actual to date|Variance|Used').split('|').map(c => c.trim());
    let rows = `<tr class="group"><td colspan="6">${esc(this._copy('plan_revenue') || 'Revenue')}</td></tr>`;
    rows += rev.length ? rev.map((r, n) => { const key = `var:in:${n}`, open = this.expanded.has(key); return row(r, true, `cat ${open ? 'open' : ''}`, key) + (open ? linesHtml(r) : ''); }).join('')
      : `<tr class="item"><td colspan="6" class="fn-dim">${esc(this._copy('plan_rev_none') || 'No dues on this pill — dues are pooled per section')}</td></tr>`;
    const revT = { label: this._copy('plan_rev_total') || 'Total revenue', budget: rev.reduce((a, r) => a + r.budget, 0), actual: rev.reduce((a, r) => a + r.actual, 0) };
    rows += row(revT, true, 'sum');
    rows += `<tr class="group"><td colspan="6">${esc(this._copy('plan_expenses') || 'Expenses')}</td></tr>`;
    for (const e of exp) { const key = `var:out:${e.code}`, open = this.expanded.has(key) && !e.scaled; rows += row(e, false, e.scaled ? 'item' : `cat ${open ? 'open' : ''}`, e.scaled ? '' : key) + (open ? linesHtml(e) : ''); }
    const expT = { label: this._copy('plan_exp_total') || 'Total expenses', budget: exp.reduce((a, r) => a + r.budget, 0), actual: exp.reduce((a, r) => a + r.actual, 0) };
    rows += row(expT, false, 'sum');
    rows += row({ label: this._copy('var_net') || 'Net surplus / (deficit)', budget: revT.budget - expT.budget, actual: revT.actual - expT.actual, noUsed: true }, true, 'sum');
    const ratio = Number(flow.net_ratio) || 1;
    return `
      <div class="fn-card">${head}
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:640px;">
          <thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${rows}</tbody>
        </table></div>
        <div class="fn-note" style="margin-top:8px;">${esc(this._copy('var_dues_net', { pct: `${Math.round(100 * (1 - ratio))}%` }))}</div>
      </div>`;
  }

  // ── Soccer fund (mig 1372): the statement of financial position. Owner
  // 2026-11-14: all money in comes via LeagueApps, a grant, CASA rental or a
  // sponsor (sponsors pay Lighthouse, soccer takes the credit); all money out
  // is on invoices, paid when final; CASA always pays. Soccer has no bank
  // account of its own, so its cash is what Lighthouse holds for it: earned
  // since the budget year began − invoices paid. Club-wide (the Who pills do
  // not split a balance sheet).
  _fundHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const flow = this.flow || {}, x = this.expenses || {}, ov = this.summary || {};
    const startYm = String(flow.start || '').slice(0, 7), nowYm = String(x.today || '').slice(0, 7), thisYear = (flow.year || {}).label || '';
    const sum = (list) => list.reduce((a, i) => a + Number(i.amount || 0), 0);
    const items = (flow.items || []).filter(i => !i.ahead && i.ym >= startYm && i.ym <= nowYm);
    const dues = sum(items.filter(i => i.dir === 'in' && i.category === 'dues'));
    const rentals = sum(items.filter(i => i.dir === 'in' && i.category === 'rental'));
    const otherIn = sum(items.filter(i => i.dir === 'in' && i.category !== 'dues' && i.category !== 'rental'));
    // grants + sponsors of this budget year: received = dated receipts to date,
    // or the whole award once marked received; the rest is still owed to soccer
    let awardsIn = 0, awardsOwed = 0;
    for (const g of (x.plan_grants || []).filter(g => g.budget_year === thisYear)) {
      const got = (g.receipts || []).length ? sum(g.receipts.filter(r => !r.on || r.on.slice(0, 7) <= nowYm)) : (g.status === 'received' ? Number(g.amount) : 0);
      awardsIn += got; awardsOwed += Math.max(0, Number(g.amount || 0) - got);
    }
    // invoices to date (cash-flow items, every line) less the ones still draft
    const drafts = (flow.invoices || []).reduce((a, c) => a + Number(c.draft || 0), 0);
    const invoiced = sum(items.filter(i => i.dir === 'out' && !i.prepaid));
    const paid = invoiced - drafts;
    // refundable bonds paid (this year or before it began) are still soccer's
    const deposits = sum((flow.items || []).filter(i => i.dir === 'out' && i.category === 'bonds' && !i.ahead));
    const cash = dues + rentals + otherIn + awardsIn - paid;
    const duesOwed = Number((ov.all || {}).owed || 0);
    const assets = cash + duesOwed + awardsOwed + deposits, liabilities = drafts, net = assets - liabilities;

    const open = this.expanded.has('fund:cash');
    const amt = (v, cls) => `<td class="${cls || (v < 0 ? 'fn-out' : '')}">${M0(v)}</td>`;
    const r = (label, v, cls, rowCls, attrs) => `<tr class="${rowCls || ''}" ${attrs || ''}><td style="white-space:normal;">${esc(label)}</td>${amt(v, cls)}</tr>`;
    let rows = `<tr class="group"><td colspan="2">${esc(this._copy('fund_has') || 'What soccer has')}</td></tr>`;
    rows += r(this._copy('fund_cash') || 'Money Lighthouse holds for soccer', cash, '', `cat ${open ? 'open' : ''}`, 'data-cat="fund:cash"');
    if (open) {
      rows += r(this._copy('fund_cash_dues') || 'Dues in (LeagueApps, after its fees)', dues, 'fn-in', 'item');
      if (rentals) rows += r(this._copy('fund_cash_rental') || 'Field rentals', rentals, 'fn-in', 'item');
      if (otherIn) rows += r(this._copy('fund_cash_other') || 'Other money in', otherIn, 'fn-in', 'item');
      rows += r(this._copy('fund_cash_awards') || 'Grants and sponsors received', awardsIn, 'fn-in', 'item');
      rows += r(this._copy('fund_cash_paid') || 'Invoices paid (final)', -paid, 'fn-out', 'item');
    }
    if (cash < 0) rows += `<tr class="item"><td colspan="2" class="fn-warn" style="white-space:normal;">${esc(this._copy('fund_cash_neg', { amount: M0(-cash) }) || '')}</td></tr>`;
    rows += r(this._copy('fund_dues_owed') || 'Dues members owe', duesOwed);
    rows += r(this._copy('fund_awards_owed') || 'Grants and sponsors awarded, not paid yet', awardsOwed);
    rows += r(this._copy('fund_deposits') || 'Refundable deposits (bonds)', deposits);
    rows += r(this._copy('fund_assets_total') || 'Total', assets, '', 'sum');
    rows += `<tr class="group"><td colspan="2">${esc(this._copy('fund_owes') || 'What soccer owes')}</td></tr>`;
    rows += r(this._copy('fund_drafts') || 'Invoices not final yet', drafts);
    rows += r(this._copy('fund_liab_total') || 'Total', liabilities, '', 'sum');
    rows += `<tr class="sum"><td>${esc(this._copy('fund_net') || 'Net assets')}</td><td class="${net < 0 ? 'fn-out' : 'fn-in'}">${M0(net)}</td></tr>`;
    const asOf = x.today ? new Date(`${String(x.today).slice(0, 10)}T12:00:00`).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '';
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('fund_title') || 'Soccer fund')} · ${esc(this._copy('fund_asof', { date: asOf }) || asOf)}</div>
        <div class="fn-note">${esc(this._copy('fund_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:360px;"><tbody>${rows}</tbody></table></div>
      </div>`;
  }

}
window.FinancesScreen = FinancesScreen;
