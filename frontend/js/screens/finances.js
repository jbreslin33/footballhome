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
      const gy = e.target.closest('[data-pg-year]'); if (gy) { this.pgYear = gy.dataset.pgYear; this._renderBody(); return; }
      const gpaid = e.target.closest('[data-pg-paid]'); if (gpaid) { this._pgSave('program-plan', { season: gpaid.dataset.pgPaid, fields: { coach_paid: gpaid.dataset.on !== '1' } }); return; }
      const grm = e.target.closest('[data-pg-entry-rm]'); if (grm) { this._pgSave('program-entry', { season: grm.dataset.season, league_season_id: Number(grm.dataset.pgEntryRm), remove: true }); return; }
      if (e.target.closest('.pg-in, [data-pg-entry-add]')) return;
      // 💵 Men's season pills: Whole year clears; a season toggles (any mix, owner 11/16)
      const pms = e.target.closest('[data-pm-season]'); if (pms) {
        const c = pms.dataset.pmSeason; if (!(this.pmSeasons instanceof Set)) this.pmSeasons = new Set();
        if (c === 'year') this.pmSeasons.clear(); else if (this.pmSeasons.has(c)) this.pmSeasons.delete(c); else this.pmSeasons.add(c);
        this._renderBody(); return;
      }
      const gp = e.target.closest('[data-pg-prog]'); if (gp) { this.pgProg = this.pgProg === gp.dataset.pgProg ? null : gp.dataset.pgProg; this._renderBody(); return; }
      const c = e.target.closest('[data-cat]'); if (c) { const k = c.dataset.cat; if (this.expanded.has(k)) this.expanded.delete(k); else this.expanded.add(k); this._renderBody(); }
    });
    // plan boxes take numbers only (owner 11/17 "make them num boxes only
    // accept numbers"): digits, plus one '.' where the field has decimals
    div.addEventListener('input', (e) => {
      const gf = e.target.closest('.pg-in'); if (!gf) return;
      let v = gf.value.replace(gf.dataset.pgDec ? /[^0-9.]/g : /[^0-9]/g, '');
      const dot = v.indexOf('.'); if (dot >= 0) v = v.slice(0, dot + 1) + v.slice(dot + 1).replace(/\./g, '');
      if (v !== gf.value) gf.value = v;
    });
    div.addEventListener('change', (e) => {
      const gf = e.target.closest('[data-pg-field]');
      if (gf) {
        const raw = String(gf.value).trim(), v = raw === '' ? null : Number(raw);
        if (v !== null && !Number.isFinite(v)) { this._renderBody(); return; }
        this._pgSave('program-plan', { season: gf.dataset.season, fields: { [gf.dataset.pgField]: v } }); return;
      }
      const ga = e.target.closest('[data-pg-entry-add]');
      if (ga) {
        const id = Number(ga.value); if (!id) return;
        const opt = ((((this.programs || {}).league_options || {})[this._pgYearNow()] || {})[ga.dataset.season] || []).find(o => o.id === id) || {};
        this._pgSave('program-entry', { season: ga.dataset.season, league_season_id: id, age_band: this._pgBand(opt.bands || []) }); return;
      }
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
      // fines board (mig 1386): the fines part of LA money, by the same rule as #tuition (FinesCollected)
      const finesP = this.auth.fetch('/api/fines?months=24').then(r => (r.ok ? r.json() : null)).catch(() => null);
      const [s, x, f] = await Promise.all(['summary', 'expenses', 'cash-flow'].map(p => this.auth.fetch(`/api/finances/${p}`)));
      this.finesBoard = await finesP;
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
                   ['plan', this._copy('pill_plan') || 'Operating Budget'], ['variance', this._copy('pill_variance') || 'Budget vs Actual'], ['forecast', this._copy('pill_forecast') || 'Cash Flow Forecast'],
                   ['programs', this._copy('pill_programs') || '🧩 Programs'], ['capacity', this._copy('pill_capacity') || '👥 Full capacity']];
    el.innerHTML = pills.map(([k, l]) => `<button class="fn-pill ${this.view === k ? 'on' : ''}" data-view="${k}">${this.escapeHtml(l)}</button>`).join('');
    const who = this.find('#fn-who'); if (who) who.innerHTML = this.flow && this._byWho() ? this._whoPillsHtml() : '';
  }

  _renderBody() {
    this._renderPills();
    const body = this.find('#fn-body'); if (!body) return;
    if (this.err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.summary || !this.expenses || !this.flow) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    const v = this.view;
    body.innerHTML = v === 'position' ? this._positionHtml() : v === 'activities' ? this._activitiesHtml() : v === 'variance' ? this._varianceHtml() : v === 'forecast' ? this._forecastHtml() : v === 'capacity' ? this._programsHtml('capacity') : v === 'programs' ? this._programsHtml('expected') : this._planHtml();
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
      // reality (mig 1385): past months = what LeagueApps paid out for the
      // section; this month on = the last three months' average
      const a = this._duesActual(sec.code), by = {};
      for (const ym of months) by[ym] = ym < nowYm ? Number(a.by[ym] || 0) : a.rate;
      if (sumBy(by)) receipts.push({ label: this._copy('cf_dues', { section: sec.name }) || `Dues — ${sec.name}`, by, dues: true });
    }
    // fines (mig 1386): as #tuition counts them; none projected
    const finesT = this._finesTotalBy(), finesRow = {}; for (const ym of months) finesRow[ym] = ym < nowYm || ym === nowYm ? Number(finesT[ym] || 0) : 0;
    if (sumBy(finesRow)) receipts.push({ label: this._copy('soa_fines') || 'Fines', by: finesRow });
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
    // LeagueApps fees (mig 1386): past = what it kept; ahead = its rate on the projected dues
    { const fr = this._laFeeRatio(), feeBy = {}, dueAhead = receipts.filter(r => r.dues);
      for (const ym of months) feeBy[ym] = ym < nowYm ? items.filter(i => i.dir === 'in' && i.category === 'dues' && i.ym === ym).reduce((a, i) => a + Number(i.fee || 0), 0) : dueAhead.reduce((a, r) => a + Number(r.by[ym] || 0), 0) * fr;
      pay.set('la_fees', feeBy); catLabel.la_fees = this._copy('soa_la_fees') || 'LeagueApps fees'; }
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
    // a later year is a plan: it adds up from the programs (step 3, mig 1390)
    if (thisYear && year !== thisYear) return this._budgetFromPrograms(year, yearsAll, thisYear);
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
    for (const h of allHeads.filter(h => revCodes.includes(h.code))) {
      const monthly = Number(((this.expenses.plan_dues || []).find(d => d.section_id === h.section_id) || {}).monthly || 0);
      const paying = Number(h.paying || 0), covered = paying === 0 && Number(h.active || 0) > 0;
      // reality (mig 1385): collected so far (after LA fees) + the last three
      // months' average × the months left; next year = that average × 12
      const a = this._duesActual(h.code), left = Math.max(0, 12 - a.closed.length);
      const real = a.closed.length > 0, amount = covered ? 0 : !real ? paying * monthly * 12 : year === thisYear ? a.toDate + a.rate * left : a.rate * 12;
      const detail = covered ? (this._copy('plan_split_club_covers') || 'club covers') : !real ? `${paying} × ${M0(monthly)} × 12`
        : year === thisYear ? (this._copy('plan_dues_real', { so_far: M0(a.toDate), rate: M0(a.rate), left }) || `${M0(a.toDate)} so far + ${M0(a.rate)}/mo × ${left}`)
        : (this._copy('plan_dues_real_next', { rate: M0(a.rate) }) || `${M0(a.rate)}/mo × 12`);
      revenue.push({ kind: 'dues', code: h.code, label: this._copy('plan_rev_dues', { section: secName(h.code) }) || `Dues — ${secName(h.code)}`,
        detail, unit: covered ? '' : (this._copy(real ? 'plan_rev_dues_unit' : 'plan_rev_dues_unit_heads') || ''), amount, assumed: year !== thisYear });
    }
    // LeagueApps fees on the dues (mig 1386): what LA keeps, at its actual rate
    const duesBudget = revenue.filter(r => r.kind === 'dues').reduce((a, r) => a + r.amount, 0), feeRatio = this._laFeeRatio();
    if (duesBudget > 0 && feeRatio > 0) items.push({ category: 'la_fees', category_label: this._copy('soa_la_fees') || 'LeagueApps fees', label: this._copy('soa_la_fees') || 'LeagueApps fees',
      detail: `${M0(duesBudget)} × ${(100 * feeRatio).toFixed(1)}%`, unit: this._copy('plan_la_fees_unit') || '', amount: duesBudget * feeRatio, assumed: false });
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
    // every booking on the calendar in the year, club-wide, shared like grants;
    // a season with nothing booked yet is assumed like fall (mig 1389, owner
    // "casa will rent in sspring"), so later years count both seasons too.
    const ry = ((this.flow || {}).rental_years || []).find(r => r.label === year);
    if (ry && share) {
      const booked = Number(ry.booked || 0), projected = Number(ry.projected || 0), total = booked + projected;
      const bn = Number(ry.booked_n || 0), an = Math.round(Number(ry.projected_n || 0));
      const fy = (this.flow || {}).year || {}, s0 = String(fy.starts_on || '').slice(0, 7), e0 = String(fy.ends_on || '').slice(0, 7);
      const aheadBooked = year === thisYear && ((this.flow || {}).items || []).some(i => i.dir === 'in' && i.category === 'rental' && i.ahead && !i.projected && i.ym >= s0 && (!e0 || i.ym <= e0));
      const detail = pillS ? `${M0(total)} × ${pct}`
        : !an ? `${bn}`
        : bn ? (this._copy('plan_rental_detail', { booked: bn, assumed: an }) || `${bn} booked + ${an} assumed`)
        : (this._copy('plan_rental_assumed', { assumed: an }) || `${an} assumed`);
      if (total) revenue.push({ kind: 'rental', share, label: this._copy('plan_rev_rental') || 'Field rental income',
        detail, unit: an ? (this._copy('plan_rental_unit_assumed') || 'bookings on the calendar; seasons not booked yet assumed like fall') : (this._copy('plan_rev_rental_unit') || 'bookings on the calendar'),
        amount: total * share, assumed: an > 0 || aheadBooked });
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
  // The Operating Budget of a later year from the programs ("expected"):
  // dues per section from each program's dues, CASA and the grant from their
  // support lines, expenses = own + shared lines by category, one line per
  // program. The Who pills pick programs by section; Club-wide = the shared
  // lines alone.
  _budgetFromPrograms(year, yearsAll, thisYear) {
    const M0 = FinancesScreen.money0, coachingLabel = this._copy('coaching_label') || 'Coaching';
    const pg = (this.programsBy || {}).expected;
    if (!pg) { this._loadPrograms('expected'); return { loading: true, year, yearsAll, thisYear }; }
    const b = pg.budgets[year];
    const base = { thisYear, year, yearsAll, revenue: [], cats: [], rank: () => 0, revTotal: 0, expTotal: 0, frac: 0, pct: '', pillS: null, coachingLabel, fromPrograms: true };
    if (!b) return { ...base, empty: true };
    // the pill → programs (by the top of its scope tree)
    const scopes = (this.flow || {}).scopes || [];
    let top = this.scope; for (let i = 0; i < 10; i++) { const sc = scopes.find(x => x.code === top); if (!sc || !sc.parent) break; top = sc.parent; }
    const kindOf = { mens: 'men', womens: 'women', youth: 'youth' }[top];
    const clubOnly = this.scope === 'club';
    const picked = pg.programs.filter(p => this.scope === 'all' || clubOnly || p.kind === kindOf);
    const monthsOf = {}; for (const se of b.seasons) monthsOf[se.code] = (se.months || []).length;
    const secName = (k) => k === 'men' ? (((this.summary || {}).sections || []).find(s => s.code === 'M') || {}).name || "Men's"
      : k === 'women' ? (((this.summary || {}).sections || []).find(s => s.code === 'W') || {}).name || "Women's" : (this._copy('pg_youth_total') || 'Youth');
    const revenue = [], byCat = new Map(), dues = {}, playerMonths = {};
    let casa = 0, grant = 0, awards = 0;
    for (const p of picked) {
      for (const se of b.seasons) {
        const x = (b.programs[p.code] || {})[se.code]; if (!x) continue;
        if (!clubOnly && p.pays_dues) playerMonths[p.kind] = (playerMonths[p.kind] || 0) + Number(x.players || 0) * monthsOf[se.code];
        for (const l of x.lines || []) {
          const amt = Number(l.amount || 0);
          if (clubOnly && l.group !== 'shared') continue;
          if (l.group === 'dues') dues[p.kind] = (dues[p.kind] || 0) + amt;
          else if (l.group === 'support') { if (l.key === 'casa') casa += amt; else if (l.key === 'grant') grant += amt; else awards += amt; }
          else {
            if (!byCat.has(l.category)) byCat.set(l.category, { code: l.category, label: l.category === 'labor' ? coachingLabel : l.category === 'la_fees' ? (this._copy('soa_la_fees') || 'LeagueApps fees') : this._catName(l.category), items: new Map() });
            const key = `${p.code}:${l.group}`, items = byCat.get(l.category).items;
            if (!items.has(key)) items.set(key, { label: l.group === 'shared' ? (this._copy('plan_prog_shared', { program: p.label }) || `${p.label} — share of club-wide`) : p.label, detail: '', unit: '', amount: 0, assumed: true });
            items.get(key).amount += amt;
          }
        }
      }
    }
    const monthly = (pg.settings || {}).monthly || {};
    for (const k of ['men', 'women', 'youth']) {
      if (clubOnly || !picked.some(p => p.kind === k)) continue;
      const covers = !picked.some(p => p.kind === k && p.pays_dues);
      const players = Math.round((playerMonths[k] || 0) / 12);
      revenue.push({ kind: 'dues', code: k, label: this._copy('plan_rev_dues', { section: secName(k) }) || `Dues — ${secName(k)}`,
        detail: covers ? (this._copy('plan_split_club_covers') || 'club covers') : `${players} × ${M0(monthly[k] || 0)} × 12`,
        unit: covers ? '' : (this._copy('plan_prog_dues_unit') || 'players averaged over the seasons, from the programs'), amount: dues[k] || 0, assumed: true });
    }
    if (casa) revenue.push({ kind: 'rental', label: this._copy('plan_rev_rental') || 'Field rental income', detail: '', unit: this._copy('plan_rental_unit_assumed') || '', amount: casa, assumed: true });
    if (grant) {
      const g = (this.expenses.plan_grants || []).find(x => x.budget_year === year && (x.purposes || []).length) || {};
      const purpose = String(g.purpose_label || '').replace(/:\s*$/, '');
      revenue.push({ kind: 'award', label: purpose ? (this._copy('plan_rev_grant', { label: g.label, purpose }) || `Grant — ${g.label}`)
          : g.label ? (this._copy('plan_rev_grant_multi', { label: g.label }) || `Grant (restricted) — ${g.label}`) : (this._copy('pg_line_grant') || 'Grant'),
        detail: b.grant ? (this._copy('plan_grant_used', { used: M0(grant), award: M0(b.grant.award) }) || `${M0(grant)} of ${M0(b.grant.award)}`) : '', unit: '', amount: grant, assumed: true, purposes: g.purposes || [], award: Number(g.amount || 0), share: 1, receipts: [] });
    }
    if (awards) revenue.push({ kind: 'award', label: this._copy('cf_awards') || 'Grants and sponsorships', detail: '', unit: '', amount: awards, assumed: true, purposes: [], share: 1, receipts: [] });
    const order = (this._copy('category_order') || '').split('|').map(t => t.trim()).filter(Boolean);
    const rank = (c) => (order.indexOf(c) < 0 ? 500 : order.indexOf(c));
    const cats = [...byCat.values()].map(c => ({ code: c.code, label: c.label, items: [...c.items.values()].filter(it => Math.abs(it.amount) >= 0.5) }))
      .map(c => ({ ...c, sub: c.items.reduce((a, it) => a + it.amount, 0) })).filter(c => c.items.length).sort((a, b2) => rank(a.code) - rank(b2.code));
    return { ...base, empty: !revenue.length && !cats.length, revenue, cats, rank,
             revTotal: revenue.reduce((a, r) => a + r.amount, 0), expTotal: cats.reduce((a, c) => a + c.sub, 0) };
  }

  _planHtml() {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const m = this._budgetModel(this.planYear), year = m.year, revenue = m.revenue;
    if (m.loading) return `<div class="fn-card"><div class="fn-title">${esc(this._copy('plan_title') || 'Year plan')}</div><div class="loading">Loading…</div></div>`;
    // Year pills (mig 1334, owner: "have a pill for next year budget too").
    const yearBar = m.yearsAll.length > 1 ? `<div class="fn-pills" style="margin:4px 0 6px;">${m.yearsAll.map(y => `<button class="fn-pill ${y === year ? 'on' : ''}" data-plan-year="${esc(y)}">${esc(this._copy('plan_year_pill', { year: y }) || y)}</button>`).join('')}</div>` : '';
    const head = `<div class="fn-title">${esc(this._copy('plan_title') || 'Year plan')}</div><div class="fn-note">${esc(this._copy('plan_note'))}</div>`
      + (m.fromPrograms ? `<div class="fn-note fn-warn" style="font-weight:600;">${esc(this._copy('plan_from_programs', { year }) || `${year} adds up from the programs (🧩 Programs) — change it there.`)}</div>` : '');
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

  // ── 🧩 Programs (mig 1390): each program's own budget, season by season —
  // Men's, Women's, each youth age — rolled up to Youth and the club. The
  // money is worked out on the server (ProgramBudget); this only lays it out.
  // Loads when the pill opens (it reads the whole books, a few seconds).
  // 👥 Full capacity (step 3, replaces mig 1387's own maths) is the same model
  // in the "capacity" scenario: every program fields at least one team in
  // each plan season, players = teams × capacity; the rest of the plan is
  // shared, so the two can't disagree. The Operating Budget for later years
  // reads the "expected" scenario.
  _loadPrograms(scenario = 'expected') {
    this.programsBy = this.programsBy || {}; this._pgLoadingBy = this._pgLoadingBy || {};
    if (this._pgLoadingBy[scenario]) return;
    this._pgLoadingBy[scenario] = true; this.pgErr = '';
    this.auth.fetch(`/api/finances/programs${scenario === 'capacity' ? '?scenario=capacity' : ''}`).then(async r => { const j = await r.json().catch(() => ({})); if (!r.ok) throw new Error(j.error || `HTTP ${r.status}`); this.programsBy[scenario] = j; })
      .catch(e => { this.pgErr = e.message; }).finally(() => { this._pgLoadingBy[scenario] = false; this._renderBody(); });
  }
  _pgYearNow() { const pg = this.programs || {}, years = pg.years || []; return years.includes(this.pgYear) ? this.pgYear : (pg.this_year || years[0]); }
  // the rate-card band for the open program: the smallest band at or above its age
  _pgBand(bands) {
    const p = ((this.programs || {}).programs || []).find(x => x.code === this.pgProg); if (!p || !bands.length) return '';
    const n = (b) => Number(String(b).replace(/\D/g, '')) || 0, sorted = [...bands].sort((a, b) => n(a) - n(b));
    return sorted.find(b => n(b) >= p.age_to) || sorted[sorted.length - 1];
  }
  // one plan change → the server re-adds everything and answers the programs
  async _pgSave(path, body) {
    if (!this.pgProg || this._pgBusy) return;
    this._pgBusy = true; this.pgMsg = this._copy('pg_saving') || 'Saving…'; this._renderBody();
    try {
      const r = await this.auth.fetch(`/api/finances/${path}`, { method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ program: this.pgProg, year: this._pgYearNow(), scenario: this.pgScenario, ...body }) });
      const j = await r.json().catch(() => ({}));
      if (!r.ok) throw new Error(j.error || `HTTP ${r.status}`);
      this.programsBy = { [this.pgScenario]: j }; this.programs = j; this.pgMsg = '';   // the other scenario re-reads when opened
    } catch (e) { this.pgMsg = e.message; }
    this._pgBusy = false; this._renderBody();
  }
  static pgSum(lines, group) { return (lines || []).filter(l => l.group === group).reduce((a, l) => a + Number(l.amount || 0), 0); }
  // one program's year: per season and in total
  _pgRoll(year, code) {
    const b = this.programs.budgets[year], P = b.programs[code], S = FinancesScreen.pgSum;
    const t = { dues: 0, own: 0, shared: 0, support: 0, players: 0, teams: 0, assumed: false };
    const anyPlan = b.seasons.some(se => !se.real);   // players / teams: the plan seasons' when there are any
    for (const se of b.seasons) {
      const x = P[se.code]; if (!x) continue;
      t.dues += S(x.lines, 'dues'); t.own += S(x.lines, 'own'); t.shared += S(x.lines, 'shared'); t.support += S(x.lines, 'support');
      if (!anyPlan || !se.real) { t.players = Math.max(t.players, Number(x.players || 0)); t.teams = Math.max(t.teams, Number(x.teams || 0)); }
      if (!se.real) t.assumed = true;
    }
    t.ownNet = t.dues - t.own; t.net = t.ownNet - t.shared + t.support;
    return t;
  }
  _programsHtml(scenario = 'expected') {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    if (this.pgErr) return `<div class="error-message">${esc(this.pgErr)}</div>`;
    this.pgScenario = scenario; this.programs = (this.programsBy || {})[scenario] || null;
    if (!this.programs) { this._loadPrograms(scenario); return '<div class="loading">Loading…</div>'; }
    const full = scenario === 'capacity';
    const pg = this.programs, years = pg.years || [];
    const year = years.includes(this.pgYear) ? this.pgYear : (pg.this_year || years[0]);
    const b = pg.budgets[year]; if (!b) return '';
    const yearBar = `<div class="fn-pills" style="margin:4px 0 6px;">${years.map(y => `<button class="fn-pill ${y === year ? 'on' : ''}" data-pg-year="${esc(y)}">${esc(y)}</button>`).join('')}</div>`;
    const seasonNote = b.seasons.map(se => `${se.label} ${se.real ? (this._copy('pg_real') || 'real') : (this._copy('pg_plan') || 'plan')}`).join(' · ');
    const signed = (v) => `<td style="font-weight:700; color:${v < -0.5 ? '#fca5a5' : '#86efac'};">${M0(v)}</td>`;
    const verdict = (v) => v >= -0.5 ? `<span class="fn-in">${esc(this._copy('pg_ok') || '✓ pays for itself')}</span>` : `<span class="fn-out">${esc(this._copy('pg_short', { amount: M0(-v) }) || `✗ short ${M0(-v)}`)}</span>`;
    const cols = ['pg_col_program', 'pg_col_players', 'pg_col_teams', 'pg_col_dues', 'pg_col_direct', 'pg_col_own', 'pg_col_shared', 'pg_col_support', 'pg_col_net'].map(k => this._copy(k));
    const row = (code, label, t, cls) => {
      const empty = !t.dues && !t.own && !t.shared && !t.support;
      return `<tr class="${cls}" ${code ? `data-pg-prog="${esc(code)}" style="cursor:pointer;"` : ''}><td>${esc(label)}${t.assumed && !cls ? '*' : ''}${code === this.pgProg ? ' ▾' : ''}</td>
        <td>${t.players || ''}</td><td>${t.teams || ''}</td>
        ${empty && !cls ? `<td colspan="7" class="fn-dim" style="text-align:left;">${esc(this._copy('pg_none') || 'no players expected')}</td>` : `
        <td class="fn-in">${M0(t.dues)}</td><td class="fn-out">${M0(t.own)}</td>${signed(t.ownNet)}
        <td class="fn-out">${M0(t.shared)}</td><td class="fn-in">${M0(t.support)}</td>${signed(t.net)}<td style="text-align:left;">${verdict(t.ownNet)}</td>`}</tr>`;
    };
    const add = (a, t) => { for (const k of ['dues', 'own', 'shared', 'support', 'ownNet', 'net', 'players', 'teams']) a[k] = (a[k] || 0) + t[k]; return a; };
    let rows = '', youth = {}, club = {};
    for (const p of pg.programs) {
      let t = this._pgRoll(year, p.code);
      if (p.kind === 'men' && !full) {   // same numbers as the 💵 table under it
        const m = this._menYear(year), own = m.costs, support = m.grant + m.casa;
        t = { ...t, dues: m.dues, own, shared: m.share, support, players: m.paying || t.players, ownNet: m.dues - own, net: m.dues - own - m.share + support };
      }
      add(club, t);
      if (p.kind === 'youth') add(youth, t);
      rows += row(p.code, p.label, t, '');
      if (p.code === this.pgProg) rows += `<tr><td colspan="10" style="padding:0 0 10px 0; text-align:left; white-space:normal;">${p.kind === 'men' && !full ? this._menMoneyHtml(year) : this._programDetailHtml(year, p)}</td></tr>`;
      const next = pg.programs[pg.programs.indexOf(p) + 1];
      if (p.kind === 'youth' && (!next || next.kind !== 'youth')) rows += row('', this._copy('pg_youth_total') || 'Youth', youth, 'subtotal');
    }
    rows += row('', this._copy('pg_club_total') || 'Club', club, 'sum');
    const g = b.grant ? `<div class="fn-note">${esc(this._copy('plan_grant_used', { used: M0(b.grant.used), award: M0(b.grant.award) }) || `Grant ${M0(b.grant.used)} of ${M0(b.grant.award)}`)}</div>` : '';
    return `<div class="fn-card"><div class="fn-title">${esc(full ? (this._copy('cap_title') || 'Full capacity') : (this._copy('pg_title') || 'Programs'))} · ${esc(year)}</div>
      <div class="fn-note">${esc(full ? this._copy('pg_cap_note') : this._copy('pg_note'))}</div>${yearBar}
      <div class="fn-note">${esc(seasonNote)} — ${esc(this._copy('pg_tap'))}</div>${g}${this.pgMsg ? `<div class="fn-warn">${esc(this.pgMsg)}</div>` : ''}
      <div style="overflow-x:auto;"><table class="fn-table"><thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}<th></th></tr></thead><tbody>${rows}</tbody></table></div></div>${full ? '' : this._coachingTable().html(year)}`;
  }
  // 🧑‍🏫 Coaches for the year (mig 1491): CoachingPlanTable shows what the
  // server's CoachingPlan works out — no coaching maths on this screen.
  _coachingTable() {
    if (!this.coaching && window.CoachingPlanTable) {
      this.coaching = new CoachingPlanTable({ auth: this.auth, copy: (t, tok) => this._copy(t, tok), esc: (t) => this.escapeHtml(t),
        money: FinancesScreen.money0, onLoaded: () => { if (this.view === 'programs') this._renderBody(); } });
    }
    return this.coaching || { html: () => '' };
  }
  // The plan inputs every program shares (owner 11/17 "the now and future
  // years should be consistent in format with options … for diff amount of
  // players and paid or volunteer coach" + "also need hours for coach"):
  // one row per input, seasons across (real seasons blank), the last cell
  // sets every plan season at once.  withTotal: the caller's table has a
  // Total column after the seasons.
  _pgGridRows(year, p, withTotal = true) {
    const esc = (t) => this.escapeHtml(t);
    const b = this.programs.budgets[year], P = b.programs[p.code], ss = b.seasons;
    // plan cells are inputs (empty = the live default, shown greyed); the
    // Total column sets every plan season of the year at once
    const inp = (season, field, value, placeholder, step) => `<input class="pg-in" type="text" inputmode="${step && step < 1 ? 'decimal' : 'numeric'}" autocomplete="off" data-pg-dec="${step && step < 1 ? '1' : ''}" data-pg-field="${field}" data-season="${season}"
        value="${value ?? ''}" placeholder="${esc(String(placeholder ?? ''))}" style="width:4.6em; padding:2px 4px; text-align:right; background:transparent; color:inherit; border:1px solid var(--border-color, #374151); border-radius:4px;">`;
    const plan = ss.filter(se => !se.real);
    const editRow = (label, fn, allFn) => `<tr class="item"><td>${esc(label)}</td>${ss.map(se => `<td>${fn(P[se.code] || {}, se)}</td>`).join('')}${withTotal ? `<td>${plan.length && allFn ? allFn() : ''}</td>` : ''}</tr>`;
    const allTip = this._copy('pg_all_seasons') || 'all';
    const full = this.pgScenario === 'capacity';   // players = teams × capacity there
    let rows = editRow(this._copy('pg_col_players') || 'Players', (x, se) => se.real || full ? String(x.players ?? '') : inp(se.code, 'players', x.players_set ? x.players : '', x.players_default),
                       full ? null : () => inp('all', 'players', '', allTip))
      + editRow(this._copy('pg_col_teams') || 'Teams', (x, se) => se.real ? String(x.teams ?? '') : inp(se.code, 'teams', x.teams_set ? x.teams : '', x.teams), () => inp('all', 'teams', '', allTip))
      + editRow(this._copy('pg_row_practice_h') || 'Practice h/wk', (x, se) => se.real ? '' : inp(se.code, 'practice_hours_week', x.practice_hours_set ? x.practice_hours_week : '', x.calendar_hours, 0.25), () => inp('all', 'practice_hours_week', '', allTip, 0.25))
      + editRow(this._copy('pg_row_practice_w') || 'Practice weeks', (x, se) => se.real ? '' : inp(se.code, 'practice_weeks', x.practice_weeks_set ? x.practice_weeks : '', x.practice_weeks, 0.5), null)
      + editRow(this._copy('pg_row_games_n') || 'Games per team', (x, se) => se.real ? '' : inp(se.code, 'games', x.games, 0), null)
      + editRow(this._copy('pg_row_game_h') || 'Hours a game', (x, se) => se.real ? '' : inp(se.code, 'hours_per_game', x.hours_per_game, 0, 0.25), () => inp('all', 'hours_per_game', '', allTip, 0.25))
      + editRow(this._copy('pg_row_coach') || 'Coach', (x, se) => se.real ? '' : `<button class="fn-pill ${x.coach_paid ? 'on' : ''}" style="padding:2px 8px; font-size:0.75rem;" data-pg-paid="${se.code}" data-on="${x.coach_paid ? '1' : '0'}">${esc(x.coach_paid ? (this._copy('pg_paid') || 'Paid') : (this._copy('pg_volunteer') || 'volunteer'))}</button>`, null)
      + editRow(this._copy('pg_row_rate') || 'Coach $/h', (x, se) => se.real ? '' : inp(se.code, 'coach_rate', x.coach_rate_set ? x.coach_rate : '', x.coach_rate, 0.5), () => inp('all', 'coach_rate', '', allTip, 0.5));
    if (p.kind === 'youth') {
      const opts = ((this.programs.league_options || {})[year]) || {};
      rows += editRow(this._copy('pg_row_leagues') || 'Leagues', (x, se) => {
        if (se.real) return '';
        const have = (x.entries || []).map(e => `<span style="white-space:nowrap; display:block;">${esc(e.league.replace('Philadelphia Parks & Recreation', 'PPR').replace('Inter-County Soccer League', 'ICSL'))} ${esc(e.name)}${e.age_band ? ` (${esc(e.age_band)})` : ''} <button class="fn-pill" style="padding:0 6px; font-size:0.7rem;" data-pg-entry-rm="${e.league_season_id}" data-season="${se.code}" title="${esc(this._copy('pg_remove') || 'Remove')}">✕</button></span>`).join('');
        const free = (opts[se.code] || []).filter(o => !(x.entries || []).some(e => e.league_season_id === o.id));
        const add = free.length ? `<select data-pg-entry-add data-season="${se.code}" style="max-width:9em; font-size:0.75rem; background:transparent; color:inherit;"><option value="">${esc(this._copy('pg_add_league') || '＋ league')}</option>${free.map(o => `<option value="${o.id}">${esc(o.league)} ${esc(o.name)}</option>`).join('')}</select>` : '';
        return `<div style="text-align:left;">${have}${add}</div>`;
      }, null);
    }
    return rows;
  }
  // The weekly practice slots on the calendar behind "Practice h/wk"
  // (owner 11/17 "it should show the schedule in there for that team").
  _pgScheduleHtml(p) {
    const esc = (t) => this.escapeHtml(t);
    const prog = ((this.programs || {}).programs || []).find(x => x.code === p.code) || p;
    const slots = prog.schedule || [];
    const days = (this._copy('pg_days') || 'Mon|Tue|Wed|Thu|Fri|Sat|Sun').split('|');
    const t12 = (hm) => { const [h, m] = String(hm).split(':').map(Number); return `${((h + 11) % 12) + 1}${m ? ':' + String(m).padStart(2, '0') : ''}${h < 12 ? 'am' : 'pm'}`; };
    const total = slots.reduce((a, sl) => a + Number(sl.hours || 0) * Number(sl.weeks || 0), 0) / Math.max(1, Number(prog.weeks_read || 4));
    const head = this._copy('pg_schedule', { hours: (Math.round(Number(prog.calendar_hours || total) * 100) / 100).toString(), weeks: prog.weeks_read || 4 })
      || `Practice schedule — calendar, next ${prog.weeks_read || 4} weeks · ${prog.calendar_hours || 0} h/wk`;
    const list = slots.length
      ? slots.map(sl => `<span style="white-space:nowrap; margin-right:12px;">${esc(days[(Number(sl.dow) + 6) % 7] || '')} ${esc(t12(sl.start))}–${esc(t12(sl.end))}${sl.location ? ` · ${esc(sl.location)}` : ''}${Number(sl.weeks) < Number(prog.weeks_read || 4) ? ` <span class="fn-dim">(${esc(this._copy('pg_schedule_weeks', { n: sl.weeks, of: prog.weeks_read || 4 }) || `${sl.weeks} of ${prog.weeks_read || 4} wks`)})</span>` : ''}</span>`).join('')
      : `<span class="fn-dim">${esc(this._copy('pg_schedule_none') || 'No practices on the calendar')}</span>`;
    return `<div class="fn-note" style="margin:4px 0 6px;"><span style="font-weight:700;">${esc(head)}</span><div style="margin-top:2px;">${list}</div></div>`;
  }
  // One program: seasons across, lines down (dues → own costs → own net →
  // shared → grant / CASA → net with shared).
  _programDetailHtml(year, p) {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const b = this.programs.budgets[year], P = b.programs[p.code], ss = b.seasons;
    const cell = (v, cls) => `<td class="${cls || ''}">${Math.abs(v) >= 0.5 ? M0(v) : '<span class="fn-dim">–</span>'}</td>`;
    const lineLabel = (l) => l.key === 'dues' ? (this._copy('pg_line_dues') || 'Dues') : l.key === 'la_fees' ? (this._copy('pg_line_la_fees') || 'LeagueApps fees')
      : l.key === 'coaching' && l.label === 'practice' ? (this._copy('pg_line_coach_practice') || 'Practice coaching')
      : l.key === 'coaching' && l.label === 'games' ? (this._copy('pg_line_coach_games') || 'Game coaching')
      : l.key === 'coaching' ? (this._copy('pg_line_coaching') || 'Coaching') : l.key === 'grant' ? (this._copy('pg_line_grant') || 'Grant') : l.key === 'casa' ? (this._copy('pg_line_casa') || 'CASA field rental')
      : l.label || this._catName(l.category);
    // rows keyed by group + category (+ label for plan lines), values per season
    // groups in running-balance order (owner 11/16 "show all coaching on
    // separate lines and do pre coaching balance" + "pre club wide total" +
    // "pre grant total" + "do that for all"): money in (dues, CASA) → own
    // costs → coaching (practice / games / paid so far, each a line) → club
    // wide share → grant
    const groups = { dues: new Map(), own: new Map(), coach: new Map(), shared: new Map(), grant: new Map() };
    for (const se of ss) for (const l of (P[se.code] || {}).lines || []) {
      const g = l.group === 'own' && l.category === 'labor' ? 'coach' : l.group === 'support' ? (l.key === 'casa' ? 'dues' : 'grant') : l.group;
      const key = g === 'coach' ? (l.key === 'coaching' ? `coaching:${l.label}` : 'labor') : g === 'own' || g === 'shared' ? `${l.category}` : l.key;
      const m = groups[g]; if (!m) continue;
      if (!m.has(key)) m.set(key, { label: g === 'coach' ? (l.key === 'coaching' ? lineLabel(l) : this._catName('labor')) : g === 'own' || g === 'shared' ? (l.category === 'la_fees' ? lineLabel(l) : this._catName(l.category)) : lineLabel(l), by: {}, details: {}, assumed: false });
      const r = m.get(key); r.by[se.code] = (r.by[se.code] || 0) + Number(l.amount || 0); if (l.assumed) r.assumed = true;
      (r.details[se.code] = r.details[se.code] || []).push(`${l.key === 'coaching' ? lineLabel(l) : (l.label || lineLabel(l))}${l.detail ? ': ' + l.detail : ''} = ${M0(l.amount)}`);
    }
    const tot = (by) => ss.reduce((a, se) => a + Number(by[se.code] || 0), 0);
    const line = (r, cls) => `<tr class="item"><td title="${esc(Object.values(r.details).flat().join('\n'))}">${esc(r.label)}${r.assumed ? '*' : ''}</td>${ss.map(se => cell(r.by[se.code] || 0, cls)).join('')}${cell(tot(r.by), cls)}</tr>`;
    const sumRow = (label, by, cls) => `<tr class="${cls}"><td>${esc(label)}</td>${ss.map(se => cell(by[se.code] || 0)).join('')}${cell(tot(by))}</tr>`;
    const groupBy = (g) => { const by = {}; for (const r of groups[g].values()) for (const [k, v] of Object.entries(r.by)) by[k] = (by[k] || 0) + v; return by; };
    const minus = (a, b2, sign = -1) => { const o = {}; for (const se of ss) o[se.code] = Number(a[se.code] || 0) + sign * Number(b2[se.code] || 0); return o; };
    const dues = groupBy('dues'), own = groupBy('own'), coach = groupBy('coach'), shared = groupBy('shared'), grant = groupBy('grant');
    const preCoach = minus(dues, own), preClub = minus(preCoach, coach), preGrant = minus(preClub, shared), net = minus(preGrant, grant, +1);
    const plan = ss.filter(se => !se.real);
    let rows = this._pgGridRows(year, p, true);
    const lines = (g, cls) => [...groups[g].values()].map(r => line(r, cls)).join('');
    rows += lines('dues', 'fn-in') + lines('own', 'fn-out');
    // A running balance AFTER each pile (owner 11/18 "i like balance after not
    // before … after each section we should just have a running balance").
    rows += sumRow(this._copy('pm_pre_coach') || 'BALANCE AFTER TEAM COSTS', preCoach, 'subtotal');
    if (groups.coach.size) rows += lines('coach', 'fn-out') + sumRow(this._copy('pm_pre_club') || 'BALANCE AFTER COACHING', preClub, 'subtotal');
    if (groups.shared.size) rows += lines('shared', 'fn-out') + sumRow(this._copy('pm_pre_grant') || 'BALANCE AFTER CLUB WIDE', preGrant, 'subtotal');
    if (groups.grant.size) rows += lines('grant', 'fn-in') + sumRow(this._copy('pm_post_grant') || 'BALANCE AFTER GRANT', net, 'sum');
    const head = `<tr><th></th>${ss.map(se => `<th>${esc(se.label)}<span class="fn-tick">${esc(se.real ? (this._copy('pg_real') || 'real') : (this._copy('pg_plan') || 'plan'))}</span></th>`).join('')}<th>${esc(this._copy('col_total') || 'Total')}</th></tr>`;
    return `<div class="fn-card" style="margin:4px 0 0 0;"><div class="fn-title">${esc(p.label)} · ${esc(year)}</div>${this._pgScheduleHtml(p)}${plan.length ? `<div class="fn-note">${esc(this._copy('pg_edit'))}</div>` : ''}<div style="overflow-x:auto;"><table class="fn-table"><thead>${head}</thead><tbody>${rows}</tbody></table></div></div>`;
  }

  // ── 💵 Men's: where the money goes (mig 1407, owner 11/16 "apsl only. liga 1
  // only. u23 only. cups individual only. then we can get a total and a total
  // for dues for men to fund it" + "clear separation … lines … colors" + "where
  // all monies go for a program and what dues coming in" + "a pre grant balance
  // so i know if we are grant proof"). The Year plan's money for the year (rate ×
  // qty per competition from the team fee plans, game coaching per team, Men's
  // general budget lines, LeagueApps fees, the club-wide share), one coloured
  // band per competition, each cup its own block. Balance before the grant, then
  // after it, then the monthly dues per man that fund it. Options (Liga 2,
  // Temple 7s) beside it, never in the total. This year = the Year plan's
  // numbers (same totals); a later year's dues / grant / CASA / club share come
  // from the programs (as its Operating Budget does).
  // The year's seasons (Fall Aug–Nov, Winter Dec–Feb, Spring Mar–May, Summer
  // Jun–Jul): the programs' own when loaded, else built from the year label.
  _pmSeasons(year) {
    const b = ((this.programs || {}).budgets || {})[year];
    if (b && (b.seasons || []).length) return b.seasons.map(se => ({ code: se.code, label: se.label, months: se.months || [] }));
    const y0 = parseInt(year, 10), ym = (y, m) => `${y}-${String(m).padStart(2, '0')}`;
    return [['fall', 'Fall', [[y0, 8], [y0, 9], [y0, 10], [y0, 11]]], ['winter', 'Winter', [[y0, 12], [y0 + 1, 1], [y0 + 1, 2]]],
            ['spring', 'Spring', [[y0 + 1, 3], [y0 + 1, 4], [y0 + 1, 5]]], ['summer', 'Summer', [[y0 + 1, 6], [y0 + 1, 7]]]]
      .map(([code, label, ms]) => ({ code, label: this._copy(`pg_season_${code}`) || label, months: ms.map(([y, m]) => ym(y, m)) }));
  }
  // Season split helpers (owner 11/16 "allow pills to show fall, winter, spring
  // etc or just total for year"): a cost lands in the season it HAPPENS —
  // per-game costs in the months the games are played (the ref policy's
  // games), entry / player fees when the league season starts, weekly and
  // yearly lines spread over their months. When it is PAID = Cash Flow Forecast.
  _pmSplit(year) {
    const SS = this._pmSeasons(year), all = SS.flatMap(se => se.months);
    const seasonOf = (ym) => (SS.find(se => se.months.includes(ym)) || {}).code;
    const fromMonths = (amount, w) => {
      const by = {}; let tot = 0;
      for (const [ym, v] of Object.entries(w || {})) { const c = seasonOf(ym); if (!c || !(v > 0)) continue; by[c] = (by[c] || 0) + v; tot += v; }
      if (!tot) return null; for (const k of Object.keys(by)) by[k] = amount * by[k] / tot; return by;
    };
    const span = (a, b) => { const s0 = String(a || '').slice(0, 7) || all[0], e0 = String(b || '').slice(0, 7) || all[all.length - 1]; const ms = all.filter(m => m >= s0 && m <= e0); return ms.length ? ms : all; };
    const even = (amount, months) => fromMonths(amount, Object.fromEntries((months || all).map(m => [m, 1])));
    const at = (amount, date) => { const m = String(date || '').slice(0, 7); const ym = !m || m < all[0] ? all[0] : m > all[all.length - 1] ? all[all.length - 1] : m; return fromMonths(amount, { [ym]: 1 }); };
    const polW = (p) => { const w = {}; for (const [ym, c] of Object.entries((p || {}).by_month || {})) w[ym] = Number(c.projected || 0) + Number(c.invoiced || 0); return w; };
    // weights by season from the programs (fall real, the rest planned)
    const progW = (amount, pred) => {
      const b = ((this.programs || {}).budgets || {})[year], P = b && b.programs.mens; if (!P) return null;
      const w = {}; let tot = 0; for (const se of b.seasons) for (const l of ((P[se.code] || {}).lines || []).filter(pred)) { const a = Number(l.amount || 0); w[se.code] = (w[se.code] || 0) + a; tot += a; }
      if (!(tot > 0)) return null; for (const k of Object.keys(w)) w[k] = amount * w[k] / tot; return w;
    };
    return { SS, all, fromMonths, span, even, at, polW, progW };
  }
  _menCompetitions(year) {
    const x = this.expenses || {}, scopes = (this.flow || {}).scopes || [], thisYear = ((this.flow || {}).year || {}).label || '';
    const T = this._pmSplit(year);
    const refPolicy = (scope) => year === thisYear ? (x.ref_fees || []).find(p => p.kind === 'referee' && (p.team_scope === scope || p.scope === scope)) : null;
    const planBy = (l) => {
      const amt = Number(l.amount || 0);
      if (l.unit === 'per_game' || l.unit === 'per_home_game') { const p = refPolicy(l.scope); return (p && T.fromMonths(amt, T.polW(p))) || T.even(amt, T.span(l.season_start, l.season_end)); }
      return T.at(amt, l.season_start);
    };
    const mens = FinancesScreen.inScopeOf(scopes, 'mens') || new Set();
    const scopeLabel = (c) => (scopes.find(s => s.code === c) || {}).label || c;
    const M2 = FinancesScreen.money2, qty = (n) => Number(n) % 1 ? Number(n).toFixed(2) : String(Number(n));
    const bands = new Map(), options = new Map();   // scope → { code, label, blocks: Map(key → { label, lines }) }
    const put = (map, scope, blockKey, blockLabel, line) => {
      if (!map.has(scope)) map.set(scope, { code: scope, label: scope === 'mens' ? (this._copy('pm_general') || "Men's club wide") : scope === 'coaching' ? (this._copy('pm_coaching') || 'Coaching') : scopeLabel(scope), blocks: new Map() });
      const b = map.get(scope); if (!b.blocks.has(blockKey)) b.blocks.set(blockKey, { label: blockLabel, lines: [] });
      b.blocks.get(blockKey).lines.push(line);
    };
    // team fee plans: one block per entry's league for Cups, else one per team
    for (const l of (x.plan || []).filter(l => l.budget_year === year && mens.has(l.scope) && l.category !== 'bonds')) {
      const line = { label: l.scope === 'apsl' && l.short_label && l.short_label !== 'APSL' ? `${l.short_label} — ${l.label}` : l.label, detail: `${M2(l.rate)} × ${qty(l.quantity)}${l.team_count == null ? '' : ` × ${l.team_count}`}`, amount: Number(l.amount || 0), assumed: l.is_assumed, note: l.note, by: planBy(l) };
      const block = l.scope === 'cups' ? `cup:${l.league}` : l.scope;
      const label = l.scope === 'cups' ? l.league : scopeLabel(l.scope);
      // a later year's game coaching sits on the plans: into the Coaching band
      if (l.fee_kind === 'game_coaching' && !l.is_option) put(bands, 'coaching', 'coaching', this._copy('pm_coaching') || 'Coaching', { ...line, coach: 'games', label: this._copy('plan_game_coaching', { label: l.scope === 'cups' ? l.league : scopeLabel(l.scope) }) || `Game coaching — ${scopeLabel(l.scope)}` });
      else put(l.is_option ? options : bands, l.scope, block, label, line);
    }
    // budget lines under Men's (kits, practice coaching …): their own scope's band
    // coaching (owner 11/16 "show all coaching on separate lines and do pre
    // coaching balance"): practice + every game-coaching line in ONE band
    const coachLabel = this._copy('pm_coaching') || 'Coaching';
    for (const b of (x.budget || []).filter(b => b.budget_year === year && mens.has(b.scope)))
      put(bands, b.category === 'labor' ? 'coaching' : b.scope, b.category === 'labor' ? 'coaching' : `bl:${b.scope}`, b.category === 'labor' ? coachLabel : scopeLabel(b.scope), { ...(b.category === 'labor' ? { coach: 'practice' } : {}), label: b.label, detail: `${M2(b.amount)} × ${qty(b.year_units)}`, amount: Number(b.year_total || 0), assumed: b.is_assumed, note: b.note, by: T.even(Number(b.year_total || 0), T.span(b.period_start, b.period_end)) });
    // game coaching this year (coaching policies; a later year has it on the plans)
    if (year === thisYear) for (const p of (x.ref_fees || []).filter(p => p.kind === 'coaching' && mens.has(p.scope))) {
      const games = (p.seasons || []).reduce((a, s) => a + Number(s.expected || 0), 0); if (!games) continue;
      const scope = mens.has(p.team_scope) ? p.team_scope : p.scope;
      put(bands, 'coaching', 'coaching', coachLabel,
        { coach: 'games', label: this._copy('plan_game_coaching', { label: p.label }) || `Game coaching — ${p.label}`, detail: `${M2(p.rate)} × ${games}`, amount: Number(p.rate) * games, assumed: (p.seasons || []).some(s => s.is_assumed), note: p.note,
          by: T.fromMonths(Number(p.rate) * games, T.polW(p)) || T.even(Number(p.rate) * games) });
    }
    this._menCoachingFromGrid(year, bands, T);
    const order = ['apsl', 'liga1', 'u23', 'cups', 'liga2', 'temple7s'];
    const rank = (c) => c === 'coaching' ? 950 : c === 'mens' ? 900 : (order.indexOf(c) < 0 ? 500 : order.indexOf(c));
    const list = (map) => [...map.values()].map(b => ({ ...b, blocks: [...b.blocks.values()].map(k => ({ ...k, total: k.lines.reduce((a, l) => a + l.amount, 0) })) }))
      .map(b => ({ ...b, total: b.blocks.reduce((a, k) => a + k.total, 0) })).filter(b => Math.abs(b.total) >= 0.5).sort((a, b2) => rank(a.code) - rank(b2.code));
    // paying men now; full house = roster spots of the dues teams this year
    const heads = (x.plan_heads || []).find(h => h.code === 'M') || {};
    const spots = new Map(); for (const l of (x.plan || []).filter(l => l.budget_year === year && mens.has(l.scope) && !l.is_option && l.dues_rank != null && l.max_roster)) spots.set(l.team_id, Number(l.max_roster));
    const monthly = Number(((x.plan_dues || []).find(d => d.section_id === heads.section_id) || {}).monthly || 0);
    return { bands: list(bands), options: list(options), paying: Number(heads.paying || 0), active: Number(heads.active || 0), fullHouse: [...spots.values()].reduce((a, n) => a + n, 0), monthly };
  }
  // The Men's year in money (the 💵 table's Whole year): dues / CASA / grant /
  // club share from the Year plan's Men's pill (a later year: the programs),
  // costs per competition from _menCompetitions. The Programs summary row
  // shows the same numbers (owner 11/16: one set of numbers, not two).
  // Men's coaching in a plan season comes from the program grid (owner
  // 11/17: the grid drives it, now and later years; fall stays real).
  // 🧑‍🏫 volunteer → no coaching that season.  Paid → the grid's practice
  // coaching (teams × h/wk × weeks × $/h; h/wk defaults to the calendar)
  // replaces the Year plan's practice line for that season, and when games
  // are typed the grid's game coaching replaces the per-game lines too
  // (blank games = the Year plan's per-game coaching stays).
  _menCoachingFromGrid(year, bands, T) {
    const b = ((this.programs || {}).budgets || {})[year], P = b && b.programs.mens;
    if (!P || this.pgScenario === 'capacity') return;
    const coach = bands.get('coaching');
    if (!coach) bands.set('coaching', { code: 'coaching', label: this._copy('pm_coaching') || 'Coaching', blocks: new Map() });
    const band = bands.get('coaching');
    if (!band.blocks.has('coaching')) band.blocks.set('coaching', { label: this._copy('pm_coaching') || 'Coaching', lines: [] });
    const lines = band.blocks.get('coaching').lines;
    for (const l of lines) if (!l.by) l.by = T.even(Number(l.amount || 0)) || {};
    const add = { practice: { by: {}, details: [] }, games: { by: {}, details: [] } };
    let touched = false;
    for (const se of b.seasons) {
      const x = P[se.code];
      if (se.real || !x) continue;
      touched = true;
      const grid = (kind) => (x.lines || []).filter(l => l.key === 'coaching' && l.label === kind);
      const zero = (pred) => { for (const l of lines) if (pred(l)) l.by[se.code] = 0; };
      if (!x.coach_paid) { zero(() => true); continue; }
      zero(l => l.coach === 'practice');
      for (const g of grid('practice')) { add.practice.by[se.code] = (add.practice.by[se.code] || 0) + Number(g.amount || 0); add.practice.details.push(`${se.label} ${g.detail}`); }
      if (Number(x.games || 0) > 0) {
        zero(l => l.coach === 'games');
        for (const g of grid('games')) { add.games.by[se.code] = (add.games.by[se.code] || 0) + Number(g.amount || 0); add.games.details.push(`${se.label} ${g.detail}`); }
      }
    }
    if (!touched) return;
    const label = { practice: this._copy('pm_grid_practice') || 'Practice coaching — plan seasons', games: this._copy('pm_grid_games') || 'Game coaching — plan seasons' };
    for (const k of ['practice', 'games']) {
      const tot = Object.values(add[k].by).reduce((a, v) => a + v, 0);
      if (tot >= 0.5) lines.push({ label: label[k], detail: add[k].details.join(' · '), amount: tot, assumed: true, coach: k, by: add[k].by });
    }
    for (const l of lines) l.amount = Object.values(l.by || {}).reduce((a, v) => a + Number(v || 0), 0);
  }
  _menYear(year) {
    const M0 = FinancesScreen.money0;
    const thisYear = ((this.flow || {}).year || {}).label || '';
    const C = this._menCompetitions(year), feeRatio = this._laFeeRatio();
    // money in + the club-wide share: this year the Year plan's Men's pill; a later year the programs
    let dues = 0, duesDetail = '', casa = 0, grant = 0, award = 0, share = 0, shareDetail = '', paying = C.paying;
    if (year === thisYear) {
      const keep = this.scope; this.scope = 'mens';
      let m; try { m = this._budgetModel(year); } finally { this.scope = keep; }
      for (const r of m.revenue) {
        if (r.kind === 'dues') { dues += r.amount; duesDetail = r.detail; }
        else if (r.kind === 'rental') casa += r.amount;
        else if (r.kind === 'award' && (r.purposes || []).length) { grant += r.amount; award += Number(r.award || 0); }
        else if (r.kind === 'award') grant += r.amount;
      }
      const alloc = m.cats.find(c => c.code === 'allocated'); if (alloc) { share = alloc.sub; shareDetail = `${M0(alloc.sub / (m.frac || 1))} × ${m.pct}`; }
      // More paid spots this year too (owner 11/17 "i should have option to
      // increase paid player numbers even for the current year" + "allowing
      // diff totals fall, spring etc"): a plan season (fall is real) whose
      // paying men were typed adds (typed − default) × that season's dues
      // per man on top of the Year plan's dues.  The standard reports stay
      // as they are — this is the Men's money table only.
      const b = ((this.programs || {}).budgets || {})[year], P = b && b.programs.mens;
      if (P) {
        const bits = [];
        for (const se of b.seasons) {
          const x = P[se.code] || {};
          if (se.real || !x.players_set) continue;
          const pl = Number(x.players || 0), def = Number(x.players_default || 0);
          const lineDues = FinancesScreen.pgSum(x.lines, 'dues');
          const per = pl > 0 && lineDues > 0 ? lineDues / pl : Number(C.monthly || 0) * ((se.months || []).length || 1);
          const add = (pl - def) * per;
          if (Math.abs(add) >= 0.5) { dues += add; bits.push(`${se.label} ${pl}`); }
        }
        if (bits.length) duesDetail = (this._copy('pm_dues_set', { seasons: bits.join(' · ') }) || `with ${bits.join(' · ')} paying`) + (duesDetail ? ` · ${duesDetail}` : '');
      }
    } else {
      const b = ((this.programs || {}).budgets || {})[year], P = b && b.programs.mens;
      if (P) for (const se of b.seasons) for (const l of ((P[se.code] || {}).lines || [])) {
        const a = Number(l.amount || 0);
        if (l.group === 'dues') dues += a; else if (l.group === 'shared') share += a;
        else if (l.group === 'support') { if (l.key === 'casa') casa += a; else grant += a; }
      }
      duesDetail = this._copy('plan_prog_dues_unit') || 'from the programs';
      // a later year's men = the programs' players, averaged over the year's months
      if (P) { let pm = 0, mo = 0; for (const se of b.seasons) { const n = (se.months || []).length || 1; pm += Number((P[se.code] || {}).players || 0) * n; mo += n; } if (mo) paying = Math.round(pm / mo); }
    }
    const laFees = dues * feeRatio, costs = C.bands.reduce((a, b) => a + b.total, 0) + laFees;
    return { C, feeRatio, dues, duesDetail, casa, grant, award, share, shareDetail, laFees, costs, paying };
  }
  _menMoneyHtml(year) {
    const esc = (t) => this.escapeHtml(t), M0 = FinancesScreen.money0;
    const thisYear = ((this.flow || {}).year || {}).label || '';
    const { C, feeRatio, dues, duesDetail, casa, grant, award, share, shareDetail, paying } = this._menYear(year);
    // ── season pills (owner 11/16 "allow all to be clicked fall, spring …
    // click all four to show them all"): Whole year (default) or any mix of
    // seasons, each its own column, a Total column when more than one. Every
    // line carries its split by season (`by`).
    const T = this._pmSplit(year), SS = T.SS;
    const picked = this.pmSeasons instanceof Set ? this.pmSeasons : new Set();
    const cols = SS.filter(se => picked.has(se.code));
    const yearView = !cols.length, multi = cols.length > 1;
    const nMonths = yearView ? 12 : cols.reduce((a, se) => a + (se.months.length || 1), 0);
    // a value = its column amounts + their total
    const V = (amount, by) => {
      if (yearView) return { vals: [amount], tot: amount };
      const b = by || T.even(amount) || {}; const vals = cols.map(se => Number(b[se.code] || 0));
      return { vals, tot: vals.reduce((a, v) => a + v, 0) };
    };
    const Z = () => ({ vals: (yearView ? [0] : cols.map(() => 0)), tot: 0 });
    const plus = (a, b) => ({ vals: a.vals.map((v, i) => v + b.vals[i]), tot: a.tot + b.tot });
    const minus = (a, b) => ({ vals: a.vals.map((v, i) => v - b.vals[i]), tot: a.tot - b.tot });
    const scale = (a, k) => ({ vals: a.vals.map(v => v * k), tot: a.tot * k });
    const sum = (list) => list.reduce((a, v) => plus(a, v), Z());
    const evenBy = (amount) => T.even(amount);
    // money in / grant by season: this year's weights from the programs (fall real, the rest planned)
    const duesBy = T.progW(dues, l => l.group === 'dues') || evenBy(dues);
    const casaBy = T.progW(casa, l => l.group === 'support' && l.key === 'casa') || evenBy(casa);
    const grantBy = T.progW(grant, l => l.group === 'support' && l.key !== 'casa') || evenBy(grant);
    // club-wide lines: the whole club's cost, each split by its own months
    const x = this.expenses || {};
    const clubLines = [
      ...(x.budget || []).filter(b => b.scope === 'club' && b.budget_year === year).map(b => ({ label: b.label, amount: Number(b.year_total || 0), assumed: b.is_assumed, note: b.note, by: T.even(Number(b.year_total || 0), T.span(b.period_start, b.period_end)) })),
      ...(x.plan || []).filter(l => l.scope === 'club' && l.budget_year === year && l.category !== 'bonds').map(l => ({ label: l.label, amount: Number(l.amount || 0), assumed: l.is_assumed, note: l.note, by: T.at(Number(l.amount || 0), l.season_start) }))
    ].filter(l => Math.abs(l.amount) >= 0.5);
    const clubYear = clubLines.reduce((a, l) => a + l.amount, 0), frac = clubYear > 0 ? share / clubYear : 0, pct = `${Math.round(100 * frac)}%`;
    const shareBy = clubYear > 0 ? clubLines.reduce((o, l) => { for (const [k, v] of Object.entries(l.by || {})) o[k] = (o[k] || 0) + v * frac; return o; }, {}) : (T.progW(share, l => l.group === 'shared') || evenBy(share));
    // the selected slice: every line's v, empty lines / blocks / bands dropped
    const cut = (bands) => bands.map(b => ({ ...b, blocks: b.blocks.map(k => {
        const lines = k.lines.map(l => ({ ...l, year: l.amount, v: V(l.amount, l.by) })).filter(l => Math.abs(l.v.tot) >= 0.5);
        return { ...k, lines, v: sum(lines.map(l => l.v)) };
      }).filter(k => k.lines.length) })).map(b => ({ ...b, v: sum(b.blocks.map(k => k.v)) })).filter(b => Math.abs(b.v.tot) >= 0.5);
    const bands = cut(C.bands), options = cut(C.options);
    const duesV = V(dues, duesBy), casaV = V(casa, casaBy), grantV = V(grant, grantBy), laFees = scale(duesV, feeRatio), shareV = V(share, shareBy);
    const general = bands.find(b => b.code === 'mens');
    const coach = bands.find(b => b.code === 'coaching');
    const comps = bands.filter(b => b.code !== 'mens' && b.code !== 'coaching');
    const outTotal = plus(plus(sum(bands.map(b => b.v)), laFees), shareV);
    const coachV = coach ? coach.v : Z();
    const inPre = plus(duesV, casaV), pre = minus(inPre, outTotal), post = plus(pre, grantV);
    const N = paying, F = C.fullHouse, perMan = (v, n) => n > 0 ? v / nMonths / n : 0;
    // dues that fund it: costs less CASA (and the grant), grossed up for LeagueApps' cut
    const gross = (v) => feeRatio < 1 ? Math.max(0, v) / (1 - feeRatio) : v;
    const costsNoFee = outTotal.tot - laFees.tot;
    const needPre = gross(costsNoFee - casaV.tot), needPost = gross(costsNoFee - casaV.tot - grantV.tot);
    const colors = { coaching: '#f97316', apsl: '#3b82f6', liga1: '#22c55e', u23: '#a855f7', cups: '#f59e0b', liga2: '#14b8a6', temple7s: '#ec4899', mens: '#94a3b8', share: '#64748b', in: '#22c55e' };
    const col = (code) => colors[code] || '#94a3b8';
    const pm = (t) => N > 0 && Math.abs(t) >= 0.5 ? `${M0(perMan(t, N))}` : '';
    const nCols = 3 + (yearView ? 1 : cols.length) + (multi ? 1 : 0);
    // the money cells of a row: one per column, then the Total when several
    const cells = (v, cls, style = '') => (yearView ? [v.tot] : v.vals).map(a => `<td class="${cls}" style="${style}">${Math.abs(a) >= 0.5 ? M0(a) : '<span class="fn-dim">–</span>'}</td>`).join('')
      + (multi ? `<td class="${cls}" style="font-weight:800; ${style}">${M0(v.tot)}</td>` : '');
    const signedCells = (v) => (yearView ? [v.tot] : v.vals).map(a => `<td style="font-weight:800; color:${a < -0.5 ? '#fca5a5' : '#86efac'};">${M0(a)}</td>`).join('')
      + (multi ? `<td style="font-weight:800; color:${v.tot < -0.5 ? '#fca5a5' : '#86efac'};">${M0(v.tot)}</td>` : '');
    const gap = `<tr><td colspan="${nCols}" style="height:6px; padding:0; border:0;"></td></tr>`;
    // outside Whole year the second column says what the line costs over the year
    const det = (l) => yearView || l.year == null ? (l.detail || '') : (this._copy('pm_year_amount', { amount: M0(l.year) }) || `${M0(l.year)} a year`);
    const bandHead = (code, label, v, cls) => `${gap}
      <tr style="background:${col(code)}22; border-left:5px solid ${col(code)}; border-top:2px solid ${col(code)};"><td colspan="2" style="font-weight:800; text-align:left;">${esc(label)}</td>${cells(v, cls, 'font-weight:800;')}<td style="font-weight:700;">${pm(v.tot)}</td></tr>`;
    const lineRow = (code, l, cls, indent) => `<tr class="item" style="border-left:5px solid ${col(code)};"><td title="${esc(l.note || '')}" style="white-space:normal; text-align:left; padding-left:${indent || 14}px;">${esc(l.label)}${l.assumed ? '*' : ''}</td><td class="fn-dim">${esc(det(l))}</td>${cells(l.v, cls)}<td class="fn-dim">${pm(l.v.tot)}</td></tr>`;
    const blockHead = (code, k) => `<tr style="border-left:5px solid ${col(code)}; border-top:1px dashed ${col(code)}88;"><td colspan="2" style="text-align:left; padding-left:14px; font-weight:700; color:${col(code)};">${esc(k.label)}</td>${cells(k.v, 'fn-out', 'font-weight:700;')}<td class="fn-dim">${pm(k.v.tot)}</td></tr>`;
    const band = (b, cls = 'fn-out') => bandHead(b.code, b.label, b.v, cls) + b.blocks.map(k => (b.blocks.length > 1 ? blockHead(b.code, k) : '') + k.lines.sort((a, c) => c.v.tot - a.v.tot).map(l => lineRow(b.code, l, cls, b.blocks.length > 1 ? 28 : 14)).join('')).join('');
    const big = (label, v, note) => `${gap}<tr class="sum" style="border-top:3px double currentColor;"><td colspan="2" style="text-align:left; font-weight:800;">${esc(label)}${note ? ` <span style="font-weight:700; margin-left:6px;">${note}</span>` : ''}</td>${signedCells(v)}<td style="font-weight:700; color:${v.tot < -0.5 ? '#fca5a5' : '#86efac'};">${pm(v.tot)}</td></tr>`;
    const head = (label, color) => `<tr><td colspan="${nCols}" style="padding:10px 6px 4px; text-align:left; font-size:0.8rem; letter-spacing:0.08em; font-weight:800; color:${color}; border-bottom:2px solid ${color};">${esc(label)}</td></tr>`;
    const subtotal = (label, v, cls = 'fn-out') => `${gap}<tr class="subtotal" style="border-top:2px solid #fca5a5;"><td colspan="2" style="text-align:left;">${esc(label)}</td>${cells(v, cls, 'font-weight:800;')}<td>${pm(v.tot)}</td></tr>`;

    let rows = head(this._copy('pm_in') || 'MONEY IN', '#22c55e');
    rows += lineRow('in', { label: this._copy('pm_dues', { n: N, monthly: M0(C.monthly) }) || `Dues — ${N} paying men × ${M0(C.monthly)}/mo`, detail: duesDetail, v: duesV, year: yearView ? null : dues }, 'fn-in');
    if (Math.abs(casaV.tot) >= 0.5) rows += lineRow('in', { label: this._copy('pm_casa') || "CASA field rental — Men's share", detail: '', v: casaV, year: yearView ? null : casa, assumed: true }, 'fn-in');
    rows += `<tr class="subtotal"><td colspan="2" style="text-align:left;">${esc(this._copy('pm_in_total') || 'Money in (before any grant)')}</td>${cells(inPre, 'fn-in')}<td>${pm(inPre.tot)}</td></tr>`;
    rows += head(this._copy('pm_out') || 'MONEY OUT — BY COMPETITION', '#fca5a5');
    // Men's club wide (kits, LeagueApps fees) is a competition cost, split half
    // on APSL and half on Liga 1 (owner 11/16 "kits are mens expense with
    // other stuff … its part of competitions" + "put it all on apsl and liga 1")
    const gen = general ? { ...general, blocks: general.blocks.map(k => ({ ...k, lines: [...k.lines] })) } : { code: 'mens', label: this._copy('pm_general') || "Men's club wide", blocks: [{ label: '', lines: [], v: Z() }], v: Z() };
    if (Math.abs(laFees.tot) >= 0.5) { gen.blocks[0].lines.push({ label: this._copy('soa_la_fees') || 'LeagueApps fees', detail: `${M0(dues)} × ${(100 * feeRatio).toFixed(1)}%`, v: laFees, year: yearView ? null : dues * feeRatio }); gen.blocks[0].v = plus(gen.blocks[0].v, laFees); gen.v = plus(gen.v, laFees); }
    const onto = ['apsl', 'liga1'].map(c => comps.find(b => b.code === c)).filter(Boolean);
    if (onto.length && Math.abs(gen.v.tot) >= 0.5) {
      const k = 1 / onto.length, genLines = gen.blocks.flatMap(bk => bk.lines);
      for (const b of onto) {
        const add = genLines.map(l => ({ ...l, label: this._copy('pm_half_line', { label: l.label }) || `${l.label} — half`, detail: `${M0(l.v.tot)} × ${Math.round(100 * k)}%`, v: scale(l.v, k), year: l.year == null ? null : l.year * k }));
        const bk = b.blocks[b.blocks.length - 1]; bk.lines.push(...add);
        for (const l of add) { bk.v = plus(bk.v, l.v); b.v = plus(b.v, l.v); }
      }
    }
    for (const b of comps) rows += band(b);
    if (!onto.length && Math.abs(gen.v.tot) >= 0.5) rows += band(gen);
    // running balance (owner 11/16 "do pre coaching balance" + "pre club wide
    // total" + "pre grant total"; 11/18 say AFTER, not before): competitions →
    // AFTER TEAM COSTS; coaching → AFTER COACHING; club wide share → AFTER
    // CLUB WIDE (the grant-proof line); grant → AFTER GRANT
    const outOwn = minus(minus(outTotal, coachV), shareV), preCoachV = minus(inPre, outOwn);
    rows += subtotal(this._copy('pm_out_pre_coach') || 'Money out — team costs', outOwn);
    rows += big(this._copy('pm_pre_coach') || 'BALANCE AFTER TEAM COSTS', preCoachV, '');
    if (coach) {
      rows += head(this._copy('pm_out_coaching') || 'MONEY OUT — COACHING', col('coaching')); rows += band(coach);
      rows += big(this._copy('pm_pre_club') || 'BALANCE AFTER COACHING', minus(preCoachV, coachV), '');
    }
    // club-wide share (owner 11/16 "the general total like in parens for whole
    // club then the mens share"): the whole club's total in the band, each
    // club-wide line as (whole club) × Men's % = Men's share
    if (Math.abs(shareV.tot) >= 0.5) {
      rows += head(this._copy('pm_out_club') || 'MONEY OUT — CLUB WIDE', col('share'));
      const club = clubLines.map(l => ({ ...l, cv: V(l.amount, l.by) })).filter(l => l.cv.tot >= 0.5);
      const clubV = club.reduce((a, l) => a + l.cv.tot, 0);
      rows += bandHead('share', clubYear > 0 ? (this._copy('pm_share_club', { total: M0(clubV), pct }) || `Share of club-wide costs (whole club ${M0(clubV)}) — Men's ${pct}`) : (this._copy('pm_share') || 'Share of club-wide costs'), shareV, 'fn-out');
      if (clubYear > 0) rows += club.sort((a, c) => c.cv.tot - a.cv.tot)
        .map(l => lineRow('share', { ...l, detail: `(${M0(l.cv.tot)}) × ${pct}`, year: null, v: scale(l.cv, frac) }, 'fn-out')).join('');
      else rows += lineRow('share', { label: this._copy('pm_share_line') || 'Split by paying members', detail: shareDetail, v: shareV }, 'fn-out');
    }
    rows += subtotal(this._copy('pm_out_total') || 'Money out — total', outTotal);
    const proof = pre.tot >= -0.5 ? `<span class="fn-in">${esc(this._copy('pm_proof_ok') || '✓ grant-proof')}</span>` : `<span class="fn-out">${esc(this._copy('pm_proof_short', { amount: M0(-pre.tot) }) || `✗ needs the grant — ${M0(-pre.tot)} short without it`)}</span>`;
    // Named for the last pile added (no club-wide share → after coaching / team costs).
    const preLabel = Math.abs(shareV.tot) >= 0.5 ? (this._copy('pm_pre_grant') || 'BALANCE AFTER CLUB WIDE')
      : coach ? (this._copy('pm_pre_club') || 'BALANCE AFTER COACHING') : (this._copy('pm_pre_coach') || 'BALANCE AFTER TEAM COSTS');
    rows += big(preLabel, pre, proof);
    if (Math.abs(grantV.tot) >= 0.5) {
      rows += lineRow('in', { label: this._copy('pm_grant') || "Grant — Men's share (coaching, refs, equipment)", detail: award ? `${M0(grant)} of ${M0(award)}` : '', v: grantV, year: yearView ? null : grant, assumed: true }, 'fn-in');
      rows += big(this._copy('pm_post_grant') || 'BALANCE AFTER GRANT', post, '');
    }
    // dues that fund it (for the seasons shown, per man a month)
    const shownLabel = cols.map(se => se.label).join(' + ');
    const needWords = (need) => yearView ? (this._copy('pm_fund_need', { need: M0(need) }) || `${M0(need)} a year from dues`)
      : (this._copy('pm_fund_need_season', { need: M0(need), season: shownLabel }) || `${M0(need)} in ${shownLabel} from dues`);
    const fillCols = nCols - 4;   // money columns past the first
    const fund = (label, need) => `<tr class="item"><td colspan="2" style="text-align:left; white-space:normal;">${esc(label)}<span class="fn-tick">${esc(needWords(need))}</span></td>
      <td style="font-weight:800;">${N > 0 ? M0(perMan(need, N)) : '–'}<span class="fn-tick">${esc(this._copy('pm_at', { n: N }) || `${N} paying now`)}</span></td>
      <td style="font-weight:800;" colspan="${fillCols + 1}">${F > 0 ? M0(perMan(need, F)) : '–'}<span class="fn-tick">${esc(this._copy('pm_at_full', { n: F }) || `${F} full house`)}</span></td></tr>`;
    rows += head(this._copy('pm_fund') || 'DUES PER MAN A MONTH THAT FUND IT', '#fbbf24');
    rows += fund(this._copy('pm_fund_pre') || 'Without the grant (grant-proof)', needPre);
    if (Math.abs(grantV.tot) >= 0.5) rows += fund(this._copy('pm_fund_post') || 'With the grant', needPost);
    rows += `<tr class="item"><td colspan="2" style="text-align:left;">${esc(this._copy('pm_now') || 'Dues today')}</td><td>${M0(C.monthly)}</td><td colspan="${fillCols + 1}"></td></tr>`;
    // options: what each would add
    if (options.length) {
      rows += head(this._copy('pm_options') || 'OPTIONS — NOT IN THE TOTAL', '#94a3b8');
      for (const b of options) rows += `<tr class="item" style="border-left:5px dashed ${col(b.code)}; opacity:0.8;"><td colspan="2" style="text-align:left;">${esc(b.label)}<span class="fn-tick">${esc(this._copy('pm_option_adds') || 'would add, per man a month')}</span></td>${cells(b.v, 'fn-out')}<td>+${M0(perMan(gross(b.v.tot), N))}</td></tr>`;
    }
    const base = (this._copy('pm_columns') || 'Line|Rate × qty|Year|Per man / mo').split('|').map(c => c.trim());
    const heads = [base[0], yearView ? base[1] : (this._copy('pm_col_year_cost') || 'Whole year'),
      ...(yearView ? [base[2]] : cols.map(se => se.label)), ...(multi ? [this._copy('pm_col_total') || 'Total'] : []), base[3]];
    // paying men per plan season: type to set, clear to go back to the
    // default (grey).  A later year's dues come from these; this year's add
    // the typed men over the default (see _menYear)
    let playersRow = '';
    const PB = ((this.programs || {}).budgets || {})[year], PM = PB && PB.programs.mens;
    const mensProg = ((this.programs || {}).programs || []).find(x => x.code === 'mens');
    if (mensProg) playersRow = this._pgScheduleHtml(mensProg);
    if (mensProg && PM && PB.seasons.some(se => !se.real)) {
      // the same plan grid as every program (owner 11/17 "the now and future
      // years should be consistent in format with options"): players,
      // teams, practice h/wk, weeks, games, hours a game, Paid/volunteer, $/h
      const gh = `<tr><th></th>${PB.seasons.map(se => `<th>${esc(se.label)}<span class="fn-tick">${esc(se.real ? (this._copy('pg_real') || 'real') : (this._copy('pg_plan') || 'plan'))}</span></th>`).join('')}<th>${esc(this._copy('pg_all_seasons') || 'all')}</th></tr>`;
      playersRow += `<div class="fn-note">${esc(this._copy('pm_grid_note') || 'Plan seasons: blank = the default (grey). Paying men add their dues; coaching follows the grid — volunteer = no coaching that season; blank games keep the per-game coaching.')}</div>
        <div style="overflow-x:auto; margin:4px 0 8px;"><table class="fn-table"><thead>${gh}</thead><tbody>${this._pgGridRows(year, mensProg, true)}</tbody></table></div>`;
    }
    const pills = [{ code: 'year', label: this._copy('pm_year') || 'Whole year', on: yearView }, ...SS.map(se => ({ ...se, on: picked.has(se.code) }))].map(se =>
      `<button class="fn-pill ${se.on ? 'on' : ''}" data-pm-season="${esc(se.code)}">${esc(se.label)}</button>`).join(' ');
    return `<div class="fn-card" style="margin:4px 0 8px 0;"><div class="fn-title">${esc(this._copy('pm_title', { year }) || `💵 Men's money · ${year}`)}${yearView ? '' : ` · ${esc(shownLabel)}`}</div>
      <div style="display:flex; flex-wrap:wrap; gap:6px; margin:6px 0;">${pills}</div>${playersRow}
      <div class="fn-note">${esc(this._copy('pm_note', { n: N }) || '')}${yearView ? '' : ' ' + esc(this._copy('pm_seasons_note') || '')}</div>
      <div style="overflow-x:auto;"><table class="fn-table" style="min-width:${520 + (multi ? cols.length * 80 : 0)}px;"><thead><tr>${heads.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead><tbody>${rows}</tbody></table></div>
      <div class="fn-note" style="margin-top:6px;">${esc(this._copy('assumed_note') || '* assumed')}</div></div>`;
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
        lines = all.filter(i => i.dir === 'in' && i.category === 'dues' && i.section === r.code);   // by the LA program's section (mig 1385)
        lines.forEach(i => usedIn.add(i));
        const fb = this._finesBy(r.code);
        actual = sum(lines) - Object.entries(fb).filter(([ym]) => ym >= startYm && ym < nowYm).reduce((a, [, v]) => a + v, 0);
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
    // fines (mig 1386): not in the budget; the sections' fines through last month
    const finesClosed = m.revenue.filter(r => r.kind === 'dues').reduce((a, r) => a + Object.entries(this._finesBy(r.code)).filter(([ym]) => ym >= startYm && ym < nowYm).reduce((b, [, v]) => b + v, 0), 0);
    if (finesClosed) rev.push({ label: this._copy('var_unbudgeted', { label: this._copy('soa_fines') || 'Fines' }) || 'Fines (not in the budget)', budget: 0, actual: finesClosed, lines: [], given: false });
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
    // LeagueApps fees (mig 1386): what LA kept on this budget's dues, through last month
    const feeE = exp.find(e => e.code === 'la_fees');
    if (feeE) { const codes = m.revenue.filter(r => r.kind === 'dues').map(r => r.code); feeE.actual = all.filter(i => i.dir === 'in' && i.category === 'dues' && codes.includes(i.section)).reduce((a, i) => a + Number(i.fee || 0), 0); }
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

  // Dues as they really came in (owner 11/14 "i thought your were gonna deal
  // with reality?", mig 1385): what LeagueApps paid out (after its fees) per
  // month for one section — by the section of the LA program, never the team
  // tree (youth teams sit under Youth, not Boys/Girls). closed = Aug 1 → the
  // last finished month; rate = the average of the last three finished months.
  // Matches #tuition (owner 11/14 "make finances match tuition", mig 1386):
  // LA money before its fees, approved only (cards at once, bank payments once
  // paid out), the fines part split off by #tuition's rule (FinesCollected).
  _finesBy(code) {
    if (!window.FinesCollected || !this.finesBoard) return {};
    return FinesCollected.byMonth(this.finesBoard, [FinesCollected.CODE_KEY[code]]);
  }
  _finesTotalBy() {
    const out = {}; for (const c of ['M', 'W', 'B', 'G']) for (const [ym, v] of Object.entries(this._finesBy(c))) out[ym] = (out[ym] || 0) + v;
    return out;
  }
  // LA's fee as a share of approved money (what it keeps)
  _laFeeRatio() {
    const d = ((this.flow || {}).items || []).filter(i => i.dir === 'in' && i.category === 'dues');
    const gross = d.reduce((a, i) => a + Number(i.amount || 0), 0), fee = d.reduce((a, i) => a + Number(i.fee || 0), 0);
    return gross > 0 ? fee / gross : 0;
  }
  _duesActual(code) {
    const flow = this.flow || {}, nowYm = String((this.expenses || {}).today || '').slice(0, 7), startYm = String(flow.start || '').slice(0, 7);
    const by = {};
    for (const i of (flow.items || []).filter(i => i.dir === 'in' && i.category === 'dues' && !i.ahead && i.section === code)) by[i.ym] = (by[i.ym] || 0) + Number(i.amount || 0);
    for (const [ym, v] of Object.entries(this._finesBy(code))) if (by[ym] != null) by[ym] -= v;   // dues = LA money less its fines part
    const closed = []; if (startYm && nowYm) { let [y, mo] = startYm.split('-').map(Number); for (;;) { const ym = `${y}-${String(mo).padStart(2, '0')}`; if (ym >= nowYm) break; closed.push(ym); mo++; if (mo > 12) { mo = 1; y++; } } }
    const last = closed.slice(-3);
    return { by, closed, toDate: closed.reduce((a, ym) => a + Number(by[ym] || 0), 0), rate: last.length ? last.reduce((a, ym) => a + Number(by[ym] || 0), 0) / last.length : 0 };
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
    // dues = approved LA money before its fees (as #tuition), less the fines part; LA's fees an expense (mig 1386)
    const duesItems = items.filter(i => i.dir === 'in' && i.category === 'dues');
    const finesBy = this._finesTotalBy();
    L.fines = Object.entries(finesBy).filter(([ym]) => ym >= startYm && ym <= nowYm).reduce((a, [, v]) => a + v, 0);
    L.duesPaid = sum(duesItems) - L.fines;
    L.laFees = duesItems.reduce((a, i) => a + Number(i.fee || 0), 0);
    L.pending = duesItems.reduce((a, i) => a + Number(i.pending || 0), 0);
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
    L.revU = L.duesPaid + L.fines + L.duesOwed + L.rental + L.otherIn + L.grantsU + L.sponsorsU;
    L.changeU = L.revU + L.released - L.expTotal - L.allowance - L.laFees;
    L.changeR = L.restrictedIn - L.released;
    L.beginU = L.bondsBefore;
    L.endU = L.beginU + L.changeU; L.endR = L.beginR + L.changeR;
    L.cash = L.duesPaid + L.fines - L.laFees + L.rental + L.otherIn + L.awardsIn - (L.expTotal - L.payable) - L.bondsNow;
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
    rows += r(this._copy('soa_dues_paid') || 'Dues (paid through LeagueApps)', L.duesPaid, 0, 'item');
    if (L.fines) rows += r(this._copy('soa_fines') || 'Fines', L.fines, 0, 'item');
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
    if (L.laFees) rows += r(this._copy('soa_la_fees') || 'LeagueApps fees', L.laFees, 0, 'item');
    if (L.allowance) rows += r(this._copy('soa_bad_debt') || 'Uncollectible dues (allowance)', L.allowance, 0, 'item');
    rows += r(this._copy('soa_exp_total') || 'Total expenses', L.expTotal + L.allowance + L.laFees, 0, 'sum');
    rows += r(this._copy('soa_change') || 'Change in net assets', L.changeU, L.changeR, 'sum');
    rows += r(this._copy('soa_begin') || 'Net assets, beginning of year', L.beginU, L.beginR, 'item');
    rows += r(this._copy('soa_end') || 'Net assets, end of period', L.endU, L.endR, 'sum');
    const cols = (this._copy('soa_columns') || '|Without donor restrictions|With donor restrictions|Total').split('|');
    const start = String(this.flow.start || '').slice(0, 10), startLbl = start ? new Date(`${start}T12:00:00`).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : '';
    return `
      <div class="fn-card">
        <div class="fn-title">${esc(this._copy('soa_title') || 'Statement of Activities')} · ${esc(this._copy('soa_period', { from: startLbl, to: this._asOf() }) || '')}</div>
        <div class="fn-note">${esc(this._copy('soa_note'))}</div>
        ${L.pending ? `<div class="fn-note">${esc(this._copy('soa_pending', { amount: M0(L.pending) }) || '')}</div>` : ''}
        <div style="overflow-x:auto;"><table class="fn-table" style="min-width:560px;"><thead><tr>${cols.map(t => `<th style="white-space:normal;">${esc(t)}</th>`).join('')}</tr></thead><tbody>${rows}</tbody></table></div>
      </div>`;
  }

}
window.FinancesScreen = FinancesScreen;
