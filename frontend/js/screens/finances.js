// finances.js — #finances: the standard nonprofit financial reports, and only
// those (owner 2026-11-14 "it needs to be standard and standard only … we can
// always add custom later", mig 1379). Billing stays on #payments.
//
// Soccer is a Lighthouse program: Lighthouse receives all the money
// (LeagueApps dues, CASA rental, grants, sponsors) and pays soccer's invoices
// (paid once final). Soccer's books start at zero on Aug 1 of the budget year.
//
//   Statement of Financial Position  as of today, club-wide: assets (cash held
//       by Lighthouse, dues + grants receivable, deposits), liabilities
//       (accounts payable = invoices not final), net assets without / with
//       donor restrictions
//   Statement of Activities  Aug 1 → today, club-wide: revenue and support,
//       net assets released from restrictions, expenses by category, change
//       in net assets, beginning / ending net assets — the same ledger
//       (_ledger) as the Financial Position, so the two always tie
//   Operating Budget  the year (Aug 1 – Jul 31): revenue (earned, contributed),
//       expenses by category, net surplus / (deficit) — Who pills apply
//   Budget vs Actual  (mig 1369) the Budget beside actuals through the last
//       closed month — Who pills apply
//   Cash Flow Forecast  month by month, club-wide: beginning cash, receipts,
//       payments, net cash flow, ending cash
//
// Wording: message_templates kind 'finances'.
class FinancesScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.summary = null; this.expenses = null; this.flow = null; this.view = 'plan'; this.err = ''; this.expanded = new Set(); this.scope = 'all'; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fn-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px; }
        .fn-pills.sub { margin-top:-4px; padding-left:12px; border-left:3px solid var(--border-color, #374151); }
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
        .fn-table tr.subtotal td { font-weight:700; font-size:0.82rem; border-top:1px solid var(--border-color, #374151); }
        .fn-table tr.subtotal td:first-child { padding-left:26px; }
        .fn-table td.now { background:rgba(14,165,233,0.10); }
        .fn-in { color:#86efac; } .fn-out { color:#fca5a5; } .fn-dim { opacity:0.5; }
        .fn-tick { font-size:0.7rem; opacity:0.75; display:block; }
        .fn-warn { color:#fbbf24; font-weight:700; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="fn-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="fn-title">📈 Finances</h1><div id="fn-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" style="max-width:1400px; margin:0 auto;">
        <div class="fn-pills" id="fn-pills"></div>
        <div id="fn-who"></div>
        <div id="fn-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#fn-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => {
      const w = e.target.closest('[data-scope]'); if (w) { this.scope = w.dataset.scope; this._renderBody(); return; }
      const v = e.target.closest('[data-view]'); if (v) { this.view = v.dataset.view; this._renderBody(); return; }
      const yp = e.target.closest('[data-plan-year]'); if (yp) { this.planYear = yp.dataset.planYear; this._renderBody(); return; }
      const c = e.target.closest('[data-cat]'); if (c) { const k = c.dataset.cat; if (this.expanded.has(k)) this.expanded.delete(k); else this.expanded.add(k); this._renderBody(); }
    });
    return div;
  }

  onEnter() { this.load(); }
  // The three loads every report reads.
  async load() {
    this.err = '';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const title = this.find('#fn-title'); if (title) title.textContent = this._copy('title') || '📈 Finances';
      const sub = this.find('#fn-sub'); if (sub) sub.textContent = this._copy('subtitle');
      this._renderPills();
      const [s, x, f] = await Promise.all(['summary', 'expenses', 'cash-flow'].map(p => this.auth.fetch(`/api/finances/${p}`)));
      const sj = await s.json().catch(() => ({})), xj = await x.json().catch(() => ({})), fj = await f.json().catch(() => ({}));
      if (!s.ok) throw new Error(sj.error || `HTTP ${s.status}`);
      if (!x.ok) throw new Error(xj.error || `HTTP ${x.status}`);
      if (!f.ok) throw new Error(fj.error || `HTTP ${f.status}`);
      this.summary = sj; this.expenses = xj; this.flow = fj;
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('finances', tier, tokens) : ''; }

  // A scope and everything under it (cash_flow_scopes parents); null = all.
  static inScopeOf(scopes, code) {
    if (!code || code === 'all') return null;
    const set = new Set([code]);
    let grew = true;
    while (grew) { grew = false; for (const sc of (scopes || [])) if (sc.parent && set.has(sc.parent) && !set.has(sc.code)) { set.add(sc.code); grew = true; } }
    return set;
  }
  // The Who pills (mig 986) split the Budget and Budget vs Actual by section
  // and team (program budgets); the statements and the cash forecast are
  // club-wide, as a statement is.
  _byWho() { return this.view === 'plan' || this.view === 'variance'; }
  _inScope() { return this.flow && this._byWho() ? FinancesScreen.inScopeOf(this.flow.scopes, this.scope) : null; }
  _scopeOk(code) { const set = this._inScope(); return !set || set.has(code || 'club'); }
  _whoPillsHtml() {
    const esc = (t) => this.escapeHtml(t), scopes = (this.flow || {}).scopes || [], scope = this.scope;
    const picked = scopes.find(sc => sc.code === scope), top = picked ? (picked.parent || picked.code) : null;
    const kids = top ? scopes.filter(sc => sc.parent === top) : [];
    const pill = (code, label, on) => `<button class="fn-pill ${on ? 'on' : ''}" data-scope="${esc(code)}">${esc(label)}</button>`;
    return `<div class="fn-pills">${pill('all', this._copy('pill_all') || 'All', scope === 'all')}${scopes.filter(sc => !sc.parent).map(sc => pill(sc.code, sc.label, sc.code === top)).join('')}</div>
      ${kids.length ? `<div class="fn-pills sub">${kids.map(sc => pill(sc.code, sc.label, sc.code === scope)).join('')}</div>` : ''}`;
  }

  _renderPills() {
    const el = this.find('#fn-pills'); if (!el) return;
    const pills = [['position', this._copy('pill_position') || 'Statement of Financial Position'], ['activities', this._copy('pill_activities') || 'Statement of Activities'],
                   ['plan', this._copy('pill_plan') || 'Operating Budget'], ['variance', this._copy('pill_variance') || 'Budget vs Actual'], ['forecast', this._copy('pill_forecast') || 'Cash Flow Forecast']];
    el.innerHTML = pills.map(([k, l]) => `<button class="fn-pill ${this.view === k ? 'on' : ''}" data-view="${k}">${this.escapeHtml(l)}</button>`).join('');
    const who = this.find('#fn-who'); if (who) who.innerHTML = this.flow && this._byWho() ? this._whoPillsHtml() : '';
  }

  _renderBody() {
    this._renderPills();
    const body = this.find('#fn-body'); if (!body) return;
    if (this.err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.summary || !this.expenses || !this.flow) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    const v = this.view;
    body.innerHTML = v === 'position' ? this._positionHtml() : v === 'activities' ? this._activitiesHtml() : v === 'variance' ? this._varianceHtml() : v === 'forecast' ? this._forecastHtml() : this._planHtml();
  }

  // ── shared bits ──
  static money0(v) { const n = Math.round(Number(v) || 0); return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(); }
  static money2(v) { const n = Number(v) || 0; return (n < 0 ? '−' : '') + '$' + Math.abs(n).toFixed(2); }
  // ── Cash Flow Forecast: beginning cash, receipts, payments, net cash flow,
  // ending cash, month by month through the budget year, club-wide. Past
  // months = what really moved; this month on = the projection (dues from
  // members current in dues, CASA bookings on the calendar, grant/sponsor
  // receipts on their date, and the cost model: coaches' usual hours, game
  // coaching and referees, team fee plans, budget lines). Cash starts at zero
  // on Aug 1, when soccer's books begin.
  _forecastHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, x = this.expenses, flow = this.flow;
    const months = x.months || [];
    const nowYm = (x.today || '').slice(0, 7);
    const mLabel = (ym) => new Date(Number(ym.slice(0, 4)), Number(ym.slice(5, 7)) - 1, 1).toLocaleString('en-US', { month: 'short', year: '2-digit' }).replace(' ', ' ’');
    const sumBy = (by) => months.reduce((a, ym) => a + Number(by[ym] || 0), 0);
    const items = flow.items || [];

    // Receipts. Dues per section: past months = what LeagueApps paid; this
    // month on = members current in dues × dues.
    const scopes = flow.scopes || [];
    const receipts = [];
    for (const sec of (this.summary.sections || [])) {
      const monthly = Number(((sec.projections || {}).current_dues || {}).monthly || 0);
      const scode = (scopes.find(sc => sc.section_code === sec.code && !sc.team_id) || {}).code;
      const set = (scode && FinancesScreen.inScopeOf(scopes, scode)) || new Set();
      const by = {};
      for (const ym of months) by[ym] = ym < nowYm ? items.filter(i => i.dir === 'in' && i.category === 'dues' && !i.ahead && i.ym === ym && set.has(i.scope)).reduce((a, i) => a + Number(i.amount), 0) : monthly;
      if (sumBy(by)) receipts.push({ label: this._copy('cf_dues', { section: sec.name }) || `Dues — ${sec.name}`, by, dues: true });
    }
    const rentBy = {}; for (const ym of months) rentBy[ym] = items.filter(i => i.dir === 'in' && i.category === 'rental' && i.ym === ym).reduce((a, i) => a + Number(i.amount), 0);
    if (sumBy(rentBy)) receipts.push({ label: this._copy('cf_rental') || 'CASA field rental', by: rentBy });

    // Payments by expense category: past months = invoiced; this month on = projected.
    const catLabel = {}; for (const c of (flow.categories || [])) catLabel[c.code] = c.label;
    catLabel.labor = this._copy('coaching_label') || 'Coaching'; catLabel.referees = catLabel.referees || 'Referees';
    const pay = new Map();
    const add = (cat, byMonth) => {
      if (!pay.has(cat)) pay.set(cat, {});
      const into = pay.get(cat);
      for (const [ym, c] of Object.entries(byMonth || {})) into[ym] = (into[ym] || 0) + Number(c.projected || 0) + (ym < nowYm ? Number(c.invoiced || 0) : 0);
    };
    for (const u of (x.coaching_usual || [])) add('labor', u.by_month);
    for (const p of (x.ref_fees || [])) add(p.kind === 'coaching' ? 'labor' : 'referees', p.by_month);
    for (const p of (x.plan_cash || [])) add(p.category, p.by_month);
    for (const b of (x.budget || []).filter(b => b.category !== 'labor' && b.this_year !== false)) add(b.category, b.by_month);
    const order = (this._copy('category_order') || '').split('|').map(t => t.trim()).filter(Boolean);
    const payRows = [...pay.entries()].filter(([, by]) => sumBy(by)).sort((p1, p2) => (order.indexOf(p1[0]) + 1 || 99) - (order.indexOf(p2[0]) + 1 || 99))
      .map(([cat, by]) => ({ label: catLabel[cat] || cat, by }));
    const outBy = {}; for (const ym of months) outBy[ym] = payRows.reduce((a, r) => a + Number(r.by[ym] || 0), 0);

    // Grants (mig 1382, standard): this year's restricted grant is drawn as it
    // is spent on what it may pay for (released from restriction), month by
    // month up to the award; other awards count when their money arrives.
    const thisYear = ((flow.year || {}).label) || '';
    const usedBy = {}, awardBy = {};
    for (const g of (x.plan_grants || [])) {
      if (g.budget_year === thisYear && (g.purposes || []).length) {
        let left = Number(g.amount || 0);
        for (const ym of months) {
          const spent = (g.purposes || []).reduce((a, c) => a + Number((pay.get(c) || {})[ym] || 0), 0), take = Math.max(0, Math.min(left, spent));
          usedBy[ym] = (usedBy[ym] || 0) + take; left -= take;
        }
      } else if (!(g.purposes || []).length) for (const r of (g.receipts || [])) { const ym = String(r.on || '').slice(0, 7); if (months.includes(ym)) awardBy[ym] = (awardBy[ym] || 0) + Number(r.amount || 0); }
    }
    if (sumBy(usedBy)) receipts.push({ label: this._copy('cf_grant_used') || 'Grant — drawn as it is spent on its purposes', by: usedBy });
    if (sumBy(awardBy)) receipts.push({ label: this._copy('cf_awards') || 'Grants and sponsorships', by: awardBy });
    const inBy = {}; for (const ym of months) inBy[ym] = receipts.reduce((a, r) => a + Number(r.by[ym] || 0), 0);

    // Beginning → ending cash.
    const begin = {}, end = {}; let run = 0;
    for (const ym of months) { begin[ym] = run; run += inBy[ym] - outBy[ym]; end[ym] = run; }
    const td = (ym, v, cls) => `<td class="${ym === nowYm ? 'now' : ''} ${cls || ''}">${v ? M0(v) : '<span class="fn-dim">–</span>'}</td>`;
    const signedTd = (ym, v) => `<td class="${ym === nowYm ? 'now' : ''}" style="font-weight:700; color:${v < 0 ? '#fca5a5' : '#86efac'};">${M0(v)}</td>`;
    const line = (label, by, cls, rowCls) => `<tr class="${rowCls || ''}"><td style="white-space:normal;">${esc(label)}</td>${months.map(ym => td(ym, by[ym], cls)).join('')}<td class="${cls || ''}">${M0(sumBy(by))}</td></tr>`;
    const n = months.length + 2;
    let rows = `<tr class="sum"><td>${esc(this._copy('cf_begin') || 'Beginning cash')}</td>${months.map(ym => signedTd(ym, begin[ym])).join('')}<td>${M0(0)}</td></tr>`;
    rows += `<tr class="group"><td colspan="${n}">${esc(this._copy('cf_receipts') || 'Cash receipts')}</td></tr>`;
    // dues per section, then their subtotal (owner 11/14 "show total dues … under the clubs")
    const duesRows = receipts.filter(r => r.dues), duesBy = {}; for (const ym of months) duesBy[ym] = duesRows.reduce((a, r) => a + Number(r.by[ym] || 0), 0);
    rows += duesRows.map(r => line(r.label, r.by, 'fn-in', 'item')).join('');
    if (duesRows.length > 1) rows += line(this._copy('cf_dues_total') || 'Total dues', duesBy, 'fn-in', 'subtotal');
    rows += receipts.filter(r => !r.dues).map(r => line(r.label, r.by, 'fn-in', 'item')).join('');
    rows += line(this._copy('cf_receipts_total') || 'Total cash receipts', inBy, 'fn-in', 'sum');
    rows += `<tr class="group"><td colspan="${n}">${esc(this._copy('cf_payments') || 'Cash payments')}</td></tr>`;
    rows += payRows.map(r => line(r.label, r.by, 'fn-out', 'item')).join('');
    rows += line(this._copy('cf_payments_total') || 'Total cash payments', outBy, 'fn-out', 'sum');
    const netBy = {}; for (const ym of months) netBy[ym] = inBy[ym] - outBy[ym];
    rows += `<tr class="sum"><td>${esc(this._copy('cf_net') || 'Net cash flow')}</td>${months.map(ym => signedTd(ym, netBy[ym])).join('')}<td>${M0(sumBy(netBy))}</td></tr>`;
    rows += `<tr class="sum"><td>${esc(this._copy('cf_end') || 'Ending cash')}</td>${months.map(ym => signedTd(ym, end[ym])).join('')}<td>${M0(run)}</td></tr>`;
    const head = `<tr><th></th>${months.map(ym => `<th class="${ym === nowYm ? 'now' : ''}">${esc(mLabel(ym))}</th>`).join('')}<th>${esc(this._copy('col_total') || 'Total')}</th></tr>`;
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('cf_title') || 'Cash Flow Forecast')}</div>
        <div class="fn-note">${esc(this._copy('cf_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table"><thead>${head}</thead><tbody>${rows}</tbody></table></div>
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
    const underS = (code) => { const set = FinancesScreen.inScopeOf(scopesS, code) || new Set(scopesS.map(sc => sc.code)); return scopesS.filter(sc => set.has(sc.code) && sc.section_code).map(sc => sc.section_code); };
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
    // expected collection rate (mig 1381) = 1 − allowance ÷ dues billed since Aug 1 (collected, before LA fees, + still owed)
    const collect = this._collectionRate(), collectPct = `${Math.round(100 * collect)}%`;
    for (const h of allHeads.filter(h => revCodes.includes(h.code))) {
      const monthly = Number(((this.expenses.plan_dues || []).find(d => d.section_id === h.section_id) || {}).monthly || 0);
      const paying = Number(h.paying || 0), covered = paying === 0 && Number(h.active || 0) > 0;
      revenue.push({ kind: 'dues', code: h.code, label: this._copy('plan_rev_dues', { section: secName(h.code) }) || `Dues — ${secName(h.code)}`,
        detail: covered ? (this._copy('plan_split_club_covers') || 'club covers') : `${paying} × ${M0(monthly)} × 12${collect < 1 ? ` × ${collectPct}` : ''}`,
        unit: covered ? '' : (this._copy('plan_rev_dues_unit') || 'paying members × dues a month × 12 months'), amount: covered ? 0 : paying * monthly * 12 * collect, assumed: year !== thisYear });
    }
    // Grants awarded or received = revenue with donor restrictions (restricted to
    // their purpose, or to what the label names when it has no single purpose);
    // sponsorships (mig 1372) pay Lighthouse, soccer takes the credit. A section
    // pill carries its paying-member share.
    const share = pillS ? frac : 1;
    // this year's budgeted costs in the given categories under the pill (a
    // section pill adds its share of the club-wide ones)
    const purposeSpend = (codes) => items.filter(it => codes.includes(it.category)).reduce((a, it) => a + it.amount, 0)
      + (frac > 0 ? ((this.expenses.budget || []).filter(b => b.scope === 'club' && b.budget_year === year && codes.includes(b.category)).reduce((a, b) => a + Number(b.year_total || 0), 0)
                    + (this.expenses.plan || []).filter(l => l.scope === 'club' && l.budget_year === year && codes.includes(l.category)).reduce((a, l) => a + Number(l.amount || 0), 0)) * frac : 0);
    const claimed = new Map();
    for (const g of share ? grants : []) {
      const purpose = String(g.purpose_label || (g.purpose === 'labor' ? coachingLabel : g.purpose || '')).replace(/:\s*$/, '');
      const label = g.kind === 'sponsorship' ? (this._copy('plan_rev_sponsor', { label: g.label }) || `Sponsor — ${g.label}`)
        : purpose ? (this._copy('plan_rev_grant', { label: g.label, purpose }) || `Grant — ${g.label}`)
        : (this._copy('plan_rev_grant_multi', { label: g.label }) || `Grant (restricted) — ${g.label}`);
      // received = the dated receipts, or the whole award once marked received
      const receipts = (g.receipts || []).length ? g.receipts : (g.status === 'received' ? [{ on: '', amount: Number(g.amount) }] : []);
      // Restricted (owner 11/14 "just use grant money for all refs, coach pay and
      // equipment … any excess grant money don't use it at all", mig 1384):
      // budgeted = this year's costs it may pay for, up to the award; the rest unused.
      const purposes = g.purposes || [], award = Number(g.amount) * share;
      let amount = award, detail = pillS ? `${M0(g.amount)} × ${pct}` : '', unit = g.note || '';
      if (purposes.length) {
        const spend = Math.max(0, purposeSpend(purposes) - (claimed.get(purposes.join()) || 0));
        amount = Math.min(award, spend); claimed.set(purposes.join(), (claimed.get(purposes.join()) || 0) + amount);
        detail = this._copy('plan_grant_used', { used: M0(amount), award: M0(award) }) || `${M0(amount)} of ${M0(award)}`;
        unit = award - amount > 0.5 ? (this._copy('plan_grant_left', { left: M0(award - amount) }) || `${M0(award - amount)} not used`) : '';
      }
      revenue.push({ kind: 'award', share, receipts, purposes, award, label, detail, unit, amount, assumed: g.status !== 'received' });
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
    // Standard nonprofit order (owner 2026-11-14 "is that normal" → standard):
    // Revenue first — earned (dues, CASA rental) then contributed (grants,
    // sponsors) — then Expenses, then one Net surplus / (deficit). Lighthouse
    // holds all the money; soccer gets the credit (page note).
    const earned = revenue.filter(r => r.kind === 'dues' || r.kind === 'rental'), given = revenue.filter(r => r.kind === 'award');
    const signed = (v) => `<td class="${v >= 0 ? 'fn-in' : 'fn-out'}">${M0(v)}</td>`;
    const sub = (label) => `<tr class="item"><td colspan="3" style="font-weight:700; opacity:0.8; padding-left:14px;">${esc(label)}</td></tr>`;
    let rows = `<tr class="group"><td colspan="3">${esc(this._copy('plan_revenue') || 'Revenue')}</td></tr>`;
    if (!revenue.length) rows += `<tr class="item"><td colspan="3" class="fn-dim">${esc(this._copy('plan_rev_none') || 'No dues on this pill — dues are pooled per section')}</td></tr>`;
    if (earned.length) rows += sub(this._copy('plan_rev_earned') || 'Earned') + earned.map(r => line(r, 'item rev')).join('');
    if (given.length) rows += sub(this._copy('plan_rev_contributed') || 'Contributed') + given.map(r => line(r, 'item rev')).join('');
    rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_rev_total') || 'Total revenue')}</td><td class="fn-in">${M0(revTotal)}</td></tr>`;
    rows += `<tr class="group"><td colspan="3">${esc(this._copy('plan_expenses') || 'Expenses')}</td></tr>`;
    const total = m.expTotal;
    for (const c of m.cats) {
      const cs = c.sub, key = `plan:${c.code}`, open = this.expanded.has(key);
      rows += `<tr class="cat ${open ? 'open' : ''}" data-cat="${esc(key)}"><td colspan="2">${esc(c.label)}</td><td class="fn-out">${M0(cs)}</td></tr>`;
      if (open) rows += c.items.sort((a, b) => b.amount - a.amount).map(it => line(it, 'item')).join('');
    }
    rows += `<tr class="sum"><td colspan="2">${esc(this._copy('plan_exp_total') || 'Total expenses')}</td><td class="fn-out">${M0(total)}</td></tr>`;
    const net = revTotal - total;
    rows += `<tr class="sum"><td colspan="2">${esc(this._copy(net >= 0 ? 'plan_net_surplus' : 'plan_net_deficit') || 'Net')}</td>${signed(net)}</tr>
      <tr class="item"><td colspan="2">${esc(this._copy('plan_net_month') || 'Per month')}</td>${signed(net / 12)}</tr>`;
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
    const catLabel = (code) => code === 'labor' ? m.coachingLabel : code === 'rental' ? (this._copy('cf_rental') || 'CASA field rental') : code === 'dues' ? (this._copy('soa_dues_paid') || 'Dues') : (((flow.categories || []).find(c => c.code === code) || {}).label || code);

    // Revenue: dues per section (pooled per section, as in the Budget); grants
    // count once received; any other money in is shown as not budgeted.
    const rev = [], usedIn = new Set();
    for (const r of m.revenue) {
      let actual = 0, lines = [];
      if (r.kind === 'dues') {
        const sec = (scopes.find(sc => sc.section_code === r.code && !sc.team_id) || scopes.find(sc => sc.section_code === r.code) || {}).code;
        const set = sec ? FinancesScreen.inScopeOf(scopes, sec) : new Set();
        lines = mine.filter(i => i.dir === 'in' && i.category === 'dues' && set.has(i.scope));
        lines.forEach(i => usedIn.add(i)); actual = sum(lines);
      } else if (r.kind === 'award' && (r.purposes || []).length) {
        // restricted (mig 1382, standard): counts as it is spent on what it may pay for — released from restriction
        const spent = all.filter(i => i.dir === 'out' && r.purposes.includes(i.category)).reduce((a, i) => a + Number(i.amount || 0), 0);
        actual = Math.min(r.award, spent * r.share);
      } else if (r.kind === 'award') actual = r.receipts.filter(x => !x.on || x.on.slice(0, 7) < nowYm).reduce((a, x) => a + Number(x.amount || 0), 0) * r.share;
      else if (r.kind === 'rental') {
        lines = all.filter(i => i.dir === 'in' && i.category === 'rental');
        lines.forEach(i => usedIn.add(i)); actual = sum(lines) * r.share;
      }
      rev.push({ label: r.label, budget: r.amount, actual, lines, given: r.kind === 'award' });
    }
    const teamPill = m.pillS && m.pillS.team_id;
    const otherIn = new Map();
    for (const i of mine.filter(i => i.dir === 'in' && !usedIn.has(i) && !(teamPill && i.category === 'dues'))) {
      if (!otherIn.has(i.category)) otherIn.set(i.category, []); otherIn.get(i.category).push(i);
    }
    for (const [code, lines] of otherIn) rev.push({ label: this._copy('var_unbudgeted', { label: catLabel(code) }) || `${catLabel(code)} (not in the budget)`, budget: 0, actual: sum(lines), lines, given: false });

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
    // Standard order, as on the Budget: Revenue (earned, contributed) → Expenses → Net.
    const tot = (list, label) => ({ label, budget: list.reduce((a, r) => a + r.budget, 0), actual: list.reduce((a, r) => a + r.actual, 0) });
    const revRows = (list) => list.map(r => { const key = `var:in:${rev.indexOf(r)}`, open = this.expanded.has(key); return row(r, true, `cat ${open ? 'open' : ''}`, key) + (open ? linesHtml(r) : ''); }).join('');
    const sub = (label) => `<tr class="item"><td colspan="6" style="font-weight:700; opacity:0.8; padding-left:14px;">${esc(label)}</td></tr>`;
    const earnedRows = rev.filter(r => !r.given), givenRows = rev.filter(r => r.given);
    let rows = `<tr class="group"><td colspan="6">${esc(this._copy('plan_revenue') || 'Revenue')}</td></tr>`;
    if (!rev.length) rows += `<tr class="item"><td colspan="6" class="fn-dim">${esc(this._copy('plan_rev_none') || 'No dues on this pill — dues are pooled per section')}</td></tr>`;
    if (earnedRows.length) rows += sub(this._copy('plan_rev_earned') || 'Earned') + revRows(earnedRows);
    if (givenRows.length) rows += sub(this._copy('plan_rev_contributed') || 'Contributed') + revRows(givenRows);
    const revT = tot(rev, this._copy('plan_rev_total') || 'Total revenue');
    rows += row(revT, true, 'sum');
    rows += `<tr class="group"><td colspan="6">${esc(this._copy('plan_expenses') || 'Expenses')}</td></tr>`;
    for (const e of exp) { const key = `var:out:${e.code}`, open = this.expanded.has(key) && !e.scaled; rows += row(e, false, e.scaled ? 'item' : `cat ${open ? 'open' : ''}`, e.scaled ? '' : key) + (open ? linesHtml(e) : ''); }
    const expT = tot(exp, this._copy('plan_exp_total') || 'Total expenses');
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
        <div class="fn-note">${esc(this._copy('var_grant_used'))}</div>
      </div>`;
  }

  // Share of dues expected to be collected (mig 1381): 1 − the allowance for
  // uncollectible dues ÷ dues billed since Aug 1 (paid through LeagueApps,
  // grossed up for its fees, plus what members owe now).
  _collectionRate() {
    if (!this.flow || !this.expenses || !this.summary) return 1;
    const L = this._ledger(), ratio = Number(this.flow.net_ratio) || 1;
    const billed = L.duesPaid / ratio + L.duesOwed;
    return billed > 0 ? Math.max(0, 1 - L.allowance / billed) : 1;
  }

  // ── The ledger both statements read (mig 1379): this budget year, Aug 1 →
  // today, club-wide, starting from zero on Aug 1 (only deposits paid before
  // then are carried in). Accrual basis: an expense is recorded when invoiced
  // (a draft invoice is a payable; paid once final); a grant or sponsorship is
  // revenue when awarded (with donor restrictions when it names what it may
  // pay for); dues are revenue when paid through LeagueApps (after its fees)
  // plus what members owe now (dues receivable).
  _ledger() {
    const flow = this.flow, x = this.expenses, ov = this.summary;
    const startYm = String(flow.start || '').slice(0, 7), nowYm = String(x.today || '').slice(0, 7), thisYear = (flow.year || {}).label || '';
    const sum = (list) => list.reduce((a, i) => a + Number(i.amount || 0), 0);
    const items = (flow.items || []).filter(i => !i.ahead && i.ym >= startYm && i.ym <= nowYm);
    const L = { thisYear };
    L.duesPaid = sum(items.filter(i => i.dir === 'in' && i.category === 'dues'));
    L.duesOwed = Number((ov.all || {}).owed || 0);
    // allowance for uncollectible dues (mig 1381): aging tiers on what is owed now
    L.allowance = Math.min(L.duesOwed, Number((ov.all || {}).allowance || 0));
    L.rental = sum(items.filter(i => i.dir === 'in' && i.category === 'rental'));
    L.otherIn = sum(items.filter(i => i.dir === 'in' && i.category !== 'dues' && i.category !== 'rental'));
    // expenses by category (this year's invoices, every line; bonds are deposits)
    const out = items.filter(i => i.dir === 'out' && !i.prepaid);
    L.expenses = new Map();
    for (const i of out.filter(i => i.category !== 'bonds')) L.expenses.set(i.category, (L.expenses.get(i.category) || 0) + Number(i.amount || 0));
    L.expTotal = [...L.expenses.values()].reduce((a, v) => a + v, 0);
    L.payable = (flow.invoices || []).reduce((a, c) => a + Number(c.draft || 0), 0);
    L.bondsNow = sum(out.filter(i => i.category === 'bonds'));
    L.bondsBefore = sum((flow.items || []).filter(i => i.dir === 'out' && i.category === 'bonds' && i.prepaid));
    // grants and sponsorships (mig 1380): a guaranteed promise is revenue in
    // full in the year it was promised — every year of a multi-year promise.
    // Restricted when it names purposes or is for a later year (time); its own
    // year's spending on its purposes releases it (a purpose-free one is
    // released when its year begins). Unpaid installments are receivable.
    const yStart = String((flow.year || {}).starts_on || flow.start || '').slice(0, 10), today = String(x.today || '').slice(0, 10);
    const yearAhead = today ? new Date(new Date(`${today}T12:00:00`).getTime() + 365 * 864e5).toISOString().slice(0, 10) : '';
    L.grantsR = 0; L.grantsU = 0; L.sponsorsR = 0; L.sponsorsU = 0; L.awardsIn = 0; L.awardsOwed = 0; L.awardsOwedLater = 0; L.released = 0; L.beginR = 0;
    for (const g of (x.plan_grants || [])) {
      const amount = Number(g.amount || 0), purposes = g.purposes || [], due = String(g.year_starts || '').slice(0, 10);
      const promised = String(g.promised_on || g.year_starts || '').slice(0, 10);
      const current = g.budget_year === thisYear, later = !!due && due > yStart && !current;
      if (!current && !later) continue;            // an earlier year's award
      if (!promised || promised > today) continue; // not promised yet
      const receipts = (g.receipts || []).length ? g.receipts : (g.status === 'received' ? [{ on: '', amount }] : []);
      const gotAll = sum(receipts.filter(r => !r.on || r.on.slice(0, 10) <= today));
      L.awardsIn += sum(receipts.filter(r => !r.on || (r.on.slice(0, 10) >= yStart && r.on.slice(0, 10) <= today)));
      const owed = Math.max(0, amount - gotAll);
      if (later && due > yearAhead) L.awardsOwedLater += owed; else L.awardsOwed += owed;
      const restricted = purposes.length > 0 || later;
      if (promised >= yStart) {                     // promised this year → revenue now
        if (g.kind === 'sponsorship') { if (restricted) L.sponsorsR += amount; else L.sponsorsU += amount; }
        else if (restricted) L.grantsR += amount; else L.grantsU += amount;
      } else L.beginR += amount;                    // promised earlier for this or a later year: restricted at the start
      if (current) {
        if (purposes.length) L.released += Math.min(amount, purposes.reduce((a, c) => a + Number(L.expenses.get(c) || 0), 0));
        else if (promised < yStart) L.released += amount;
      }
    }
    L.restrictedIn = L.grantsR + L.sponsorsR;
    // the two statements
    L.revU = L.duesPaid + L.duesOwed + L.rental + L.otherIn + L.grantsU + L.sponsorsU;
    L.changeU = L.revU + L.released - L.expTotal - L.allowance;
    L.changeR = L.restrictedIn - L.released;
    L.beginU = L.bondsBefore;
    L.endU = L.beginU + L.changeU; L.endR = L.beginR + L.changeR;
    L.cash = L.duesPaid + L.rental + L.otherIn + L.awardsIn - (L.expTotal - L.payable) - L.bondsNow;
    L.deposits = L.bondsNow + L.bondsBefore;
    L.assets = L.cash + L.duesOwed - L.allowance + L.awardsOwed + L.awardsOwedLater + L.deposits;
    L.liabilities = L.payable;
    return L;
  }
  _asOf() { const t = String(this.expenses.today || '').slice(0, 10); return t ? new Date(`${t}T12:00:00`).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' }) : ''; }
  _catName(code) { return code === 'labor' ? (this._copy('coaching_label') || 'Coaching') : (((this.flow.categories || []).find(c => c.code === code) || {}).label || code); }

  // ── Statement of Financial Position (mig 1379), as of today, club-wide.
  _positionHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, L = this._ledger();
    const r = (label, v, rowCls) => `<tr class="${rowCls || ''}"><td style="white-space:normal;">${esc(label)}</td><td class="${v < 0 ? 'fn-out' : ''}">${M0(v)}</td></tr>`;
    const g = (label) => `<tr class="group"><td colspan="2">${esc(label)}</td></tr>`;
    let rows = g(this._copy('sfp_assets') || 'Assets');
    rows += r(this._copy('sfp_cash') || 'Cash held by Lighthouse for soccer', L.cash, 'item');
    rows += r(this._copy('sfp_dues_recv') || 'Dues receivable', L.duesOwed, 'item');
    if (L.allowance) rows += r(this._copy('sfp_dues_allowance') || 'Less allowance for uncollectible dues', -L.allowance, 'item');
    rows += r(this._copy('sfp_grants_recv') || 'Grants and sponsorships receivable, due within one year', L.awardsOwed, 'item');
    if (L.awardsOwedLater) rows += r(this._copy('sfp_grants_recv_later') || 'Grants and sponsorships receivable, due in later years', L.awardsOwedLater, 'item');
    rows += r(this._copy('sfp_deposits') || 'Deposits (refundable bonds)', L.deposits, 'item');
    rows += r(this._copy('sfp_assets_total') || 'Total assets', L.assets, 'sum');
    rows += g(this._copy('sfp_liabilities') || 'Liabilities');
    rows += r(this._copy('sfp_payable') || 'Accounts payable (invoices not final)', L.payable, 'item');
    rows += r(this._copy('sfp_liab_total') || 'Total liabilities', L.liabilities, 'sum');
    rows += g(this._copy('sfp_net_assets') || 'Net assets');
    rows += r(this._copy('sfp_net_u') || 'Without donor restrictions', L.endU, 'item');
    rows += r(this._copy('sfp_net_r') || 'With donor restrictions', L.endR, 'item');
    rows += r(this._copy('sfp_net_total') || 'Total net assets', L.endU + L.endR, 'sum');
    rows += r(this._copy('sfp_total') || 'Total liabilities and net assets', L.liabilities + L.endU + L.endR, 'sum');
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('sfp_title') || 'Statement of Financial Position')} · ${esc(this._copy('sfp_asof', { date: this._asOf() }) || this._asOf())}</div>
        <div class="fn-note">${esc(this._copy('sfp_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:360px;"><tbody>${rows}</tbody></table></div>
      </div>`;
  }

  // ── Statement of Activities (mig 1379), Aug 1 → today, club-wide; columns
  // without / with donor restrictions / total.
  _activitiesHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0, L = this._ledger();
    const c = (v) => `<td class="${v < 0 ? 'fn-out' : ''}">${v ? M0(v) : '<span class="fn-dim">–</span>'}</td>`;
    const r = (label, u, rr, rowCls) => `<tr class="${rowCls || ''}"><td style="white-space:normal;">${esc(label)}</td>${c(u)}${c(rr)}${c(u + rr)}</tr>`;
    const g = (label) => `<tr class="group"><td colspan="4">${esc(label)}</td></tr>`;
    let rows = g(this._copy('soa_revenue') || 'Revenue and support');
    rows += r(this._copy('soa_dues_paid') || 'Dues (paid through LeagueApps, after its fees)', L.duesPaid, 0, 'item');
    if (L.duesOwed) rows += r(this._copy('soa_dues_owed') || 'Dues billed, not yet paid', L.duesOwed, 0, 'item');
    if (L.rental) rows += r(this._copy('soa_rental') || 'CASA field rental', L.rental, 0, 'item');
    if (L.otherIn) rows += r(this._copy('soa_other') || 'Other revenue', L.otherIn, 0, 'item');
    if (L.grantsU || L.grantsR) rows += r(this._copy('soa_grants') || 'Grants', L.grantsU, L.grantsR, 'item');
    if (L.sponsorsU || L.sponsorsR) rows += r(this._copy('soa_sponsors') || 'Sponsorships', L.sponsorsU, L.sponsorsR, 'item');
    if (L.released) rows += r(this._copy('soa_released') || 'Net assets released from restrictions', L.released, -L.released, 'item');
    rows += r(this._copy('soa_rev_total') || 'Total revenue and support', L.revU + L.released, L.restrictedIn - L.released, 'sum');
    rows += g(this._copy('soa_expenses') || 'Expenses');
    const order = (this._copy('category_order') || '').split('|').map(t => t.trim()).filter(Boolean);
    for (const [code, v] of [...L.expenses.entries()].sort((a, b) => (order.indexOf(a[0]) + 1 || 99) - (order.indexOf(b[0]) + 1 || 99))) rows += r(this._catName(code), v, 0, 'item');
    if (L.allowance) rows += r(this._copy('soa_bad_debt') || 'Uncollectible dues (allowance)', L.allowance, 0, 'item');
    rows += r(this._copy('soa_exp_total') || 'Total expenses', L.expTotal + L.allowance, 0, 'sum');
    rows += r(this._copy('soa_change') || 'Change in net assets', L.changeU, L.changeR, 'sum');
    rows += r(this._copy('soa_begin') || 'Net assets, beginning of year', L.beginU, L.beginR, 'item');
    rows += r(this._copy('soa_end') || 'Net assets, end of period', L.endU, L.endR, 'sum');
    const cols = (this._copy('soa_columns') || '|Without donor restrictions|With donor restrictions|Total').split('|');
    const start = String(this.flow.start || '').slice(0, 10), startLbl = start ? new Date(`${start}T12:00:00`).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '';
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('soa_title') || 'Statement of Activities')} · ${esc(this._copy('soa_period', { from: startLbl, to: this._asOf() }) || '')}</div>
        <div class="fn-note">${esc(this._copy('soa_note'))}</div>
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:560px;"><thead><tr>${cols.map(t => `<th style="white-space:normal;">${esc(t)}</th>`).join('')}</tr></thead><tbody>${rows}</tbody></table></div>
      </div>`;
  }

}
window.FinancesScreen = FinancesScreen;
