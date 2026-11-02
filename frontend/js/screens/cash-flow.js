// cash-flow.js — #cash-flow: soccer money in against invoices out (mig 882).
//
// Behind us: what LeagueApps actually paid (person_payments, the programs
// la_soccer_programs.counts_in names, after fees, less refunds) against every
// invoice by invoice date, from cash_flow_policies.starts_on.
// Ahead: dues × members, the projection #finances prints. Money out is the
// owner's plan from CashFlow::build: coach pay off the calendar, referee fees
// to cash_flow_policies.refs_through, and the cash_flow_planned rows.
//
// flow.items holds every line of money tagged with a scope, a club or a league
// under it (cash_flow_scopes). The pills show one scope; everything adds up
// from the items, and a month opens to its own lines.
//
//   GET /api/finances/cash-flow   CashFlow::build — the actuals
//   GET /api/finances/summary     PaymentsOverview — dues ahead, owed now
//   GET /api/finances/expenses    Expenses::projection — today and the months ahead
//
// Wording: message_templates kind 'cash_flow'.
class CashFlowScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.flow = null; this.summary = null; this.expenses = null; this.report = 'current_dues'; this.scope = 'all'; this.open = new Set(); this.allLines = false; this.err = ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .cf-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px; }
        .cf-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .cf-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .cf-strip { display:grid; grid-template-columns:repeat(auto-fit, minmax(240px, 1fr)); gap:var(--space-3); margin-bottom:var(--space-3); }
        .cf-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
        .cf-strip .cf-card { margin-bottom:0; }
        .cf-title { font-weight:700; font-size:1rem; }
        .cf-note { opacity:0.7; font-size:0.8rem; margin:2px 0 8px; }
        .cf-big { font-size:1.6rem; font-weight:800; margin-top:4px; }
        .cf-sub { font-size:0.85rem; opacity:0.8; }
        .cf-table { border-collapse:collapse; font-size:0.85rem; width:100%; }
        .cf-table th { padding:4px 8px; text-align:right; opacity:0.7; font-weight:600; white-space:nowrap; }
        .cf-table td { padding:4px 8px; text-align:right; white-space:nowrap; }
        .cf-table th:first-child, .cf-table td:first-child { text-align:left; }
        .cf-table tr.sum td { border-top:2px solid var(--border-color, #374151); font-weight:700; }
        .cf-table tr.now td { background:rgba(14,165,233,0.10); }
        .cf-table tr.ahead td { opacity:0.82; font-style:italic; }
        .cf-tag { font-size:0.72rem; opacity:0.7; font-weight:400; }
        .cf-in { color:#86efac; } .cf-out { color:#fca5a5; } .cf-dim { opacity:0.5; }
        .cf-table tr.cf-month { cursor:pointer; }
        .cf-table tr.cf-month:hover td { background:rgba(148,163,184,0.10); }
        .cf-table td.cf-lines { padding:4px 8px 12px 20px; white-space:normal; }
        .cf-lines .cf-table { font-size:0.8rem; }
        .cf-lines td:first-child { white-space:normal; }
        .cf-warn { color:#fbbf24; font-weight:700; font-size:0.85rem; margin-bottom:var(--space-3); }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="cf-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="cf-title">💵 Money In & Out</h1><div id="cf-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" style="max-width:1000px; margin:0 auto;">
        <div id="cf-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#cf-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => {
      const p = e.target.closest('[data-report]');
      if (p) { this.report = p.dataset.report; this._renderBody(); return; }
      const s = e.target.closest('[data-scope]');
      if (s) { this.scope = s.dataset.scope; this._renderBody(); return; }
      if (e.target.closest('[data-all-lines]')) { this.allLines = !this.allLines; this.open.clear(); this._renderBody(); return; }
      const m = e.target.closest('[data-ym]');
      if (m) { if (this.open.has(m.dataset.ym)) this.open.delete(m.dataset.ym); else this.open.add(m.dataset.ym); this._renderBody(); }
    });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('cash_flow', tier, tokens) : ''; }

  async load() {
    this.err = '';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const title = this.find('#cf-title'); if (title) title.textContent = this._copy('title') || '💵 Money In & Out';
      const sub = this.find('#cf-sub'); if (sub) sub.textContent = this._copy('subtitle');
      const res = await Promise.all(['cash-flow', 'summary', 'expenses'].map(p => this.auth.fetch(`/api/finances/${p}`)));
      const [flow, summary, expenses] = await Promise.all(res.map(async (r) => {
        const j = await r.json().catch(() => ({}));
        if (!r.ok) throw new Error(j.error || `HTTP ${r.status}`);
        return j;
      }));
      this.flow = flow; this.summary = summary; this.expenses = expenses;
    } catch (err) { this.err = err.message; }
    this._renderBody();
  }

  // The months ahead, each section's dues as lines beside flow.items.
  _items() {
    const nowYm = String(this.expenses.today || '').slice(0, 7);
    const ratio = Number(this.flow.net_ratio) || 1;
    const items = [...(this.flow.items || [])];
    const scopeOf = new Map((this.flow.scopes || []).filter(s => s.section_code).map(s => [s.section_code, s]));
    for (const sec of (this.summary.sections || [])) {
      const scope = scopeOf.get(sec.code), monthly = Number((sec.projections?.[this.report] || {}).monthly || 0) * ratio;
      if (!scope || !monthly) continue;
      for (const ym of (this.expenses.months || []).filter(m => m > nowYm)) {
        items.push({ ym, dir: 'in', scope: scope.code, type: 'dues_ahead', name: scope.label, amount: monthly, ahead: true });
      }
    }
    const inScope = this._inScope();
    return items.filter(i => !inScope || inScope.has(i.scope));
  }

  // A scope and the leagues under it; null shows everything.
  _inScope() {
    if (this.scope === 'all') return null;
    return new Set([this.scope, ...(this.flow.scopes || []).filter(s => s.parent === this.scope).map(s => s.code)]);
  }

  // Past months and this month from the actuals, then the projection's months.
  _rows(items) {
    const nowYm = String(this.expenses.today || '').slice(0, 7);
    const past = [...new Set((this.flow.items || []).filter(i => !i.ahead).map(i => i.ym))].filter(ym => ym < nowYm).sort();
    const months = [...past.map(ym => [ym, 'past']), [nowYm, 'now'], ...(this.expenses.months || []).filter(m => m > nowYm).map(ym => [ym, 'ahead'])];
    const total = (ym, dir) => items.filter(i => i.ym === ym && i.dir === dir).reduce((a, i) => a + Number(i.amount), 0);
    let run = 0;
    return months.map(([ym, kind]) => {
      const moneyIn = total(ym, 'in'), moneyOut = total(ym, 'out');
      run += moneyIn - moneyOut;
      return { ym, kind, in: moneyIn, out: moneyOut, net: moneyIn - moneyOut, run };
    });
  }

  _lineLabel(i) {
    const tier = { coach: 'line_coach', ref: 'line_ref', dues_ahead: 'line_dues_ahead' }[i.type];
    return (tier && this._copy(tier, { name: i.name })) || i.name;
  }

  // One month's lines, money in first, biggest first; the same line twice is one row.
  _linesHtml(items, ym) {
    const esc = (t) => this.escapeHtml(t), M = CashFlowScreen.money;
    const label = new Map((this.flow.scopes || []).map(s => [s.code, s.label]));
    const merged = new Map();
    for (const i of items.filter(x => x.ym === ym)) {
      const key = [i.dir, i.type, i.name, i.scope].join('|');
      if (merged.has(key)) merged.get(key).amount += Number(i.amount);
      else merged.set(key, { ...i, amount: Number(i.amount) });
    }
    const lines = [...merged.values()].sort((a, b) => (a.dir === b.dir ? b.amount - a.amount : (a.dir === 'in' ? -1 : 1)));
    if (!lines.length) return `<div class="cf-note">${esc(this._copy('no_lines') || 'Nothing this month.')}</div>`;
    return `<table class="cf-table">${lines.map(l => `
      <tr><td>${esc(this._lineLabel(l))} <span class="cf-tag">${esc(label.get(l.scope) || '')}</span></td>
          <td class="${l.dir === 'in' ? 'cf-in' : 'cf-out'}">${M(l.amount)}</td></tr>`).join('')}</table>`;
  }

  static money(v) { const n = Math.round(Number(v) || 0); return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(); }
  _month(ym, withYear = true) {
    return new Date(Number(ym.slice(0, 4)), Number(ym.slice(5, 7)) - 1, 1).toLocaleString('en-US', withYear ? { month: 'short', year: 'numeric' } : { month: 'short' });
  }
  _date(d) { return new Date(`${d}T12:00:00`).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }); }
  _sign(v) { return Number(v) < 0 ? 'cf-out' : 'cf-in'; }

  _renderBody() {
    const body = this.find('#cf-body'); if (!body) return;
    if (this.err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.flow || !this.summary || !this.expenses) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    const esc = (t) => this.escapeHtml(t), M = CashFlowScreen.money, flow = this.flow;
    const items = this._items();
    const rows = this._rows(items);
    const scoped = this.scope !== 'all';
    const scopes = flow.scopes || [], picked = scopes.find(s => s.code === this.scope);
    const parent = picked && scopes.find(s => s.code === picked.parent);
    const startDate = this._date(flow.start);
    const since = rows.filter(r => r.kind !== 'ahead');
    const ahead = rows.filter(r => r.kind === 'ahead');
    const add = (list, k) => list.reduce((a, r) => a + r[k], 0);
    const card = (title, moneyIn, moneyOut) => `
      <div class="cf-card">
        <div class="cf-title">${esc(title)}</div>
        <div class="cf-big ${this._sign(moneyIn - moneyOut)}">${M(moneyIn - moneyOut)}</div>
        <div class="cf-sub"><span class="cf-in">${esc(this._copy('in') || 'In')} ${M(moneyIn)}</span> · <span class="cf-out">${esc(this._copy('out') || 'Out')} ${M(moneyOut)}</span></div>
      </div>`;
    const reports = [['current_dues', this._copy('pill_paid_up') || 'Members current in dues'], ['all_members', this._copy('pill_paying') || 'Every paying member']];
    const rate = ((this.summary.sections || [])[0] || {}).rate || 0;
    const fee = ((1 - (Number(flow.net_ratio) || 1)) * 100).toFixed(1);
    const tag = (r) => r.kind === 'now' ? ` <span class="cf-tag">${esc(this._copy('so_far') || 'so far')}</span>`
      : r.kind === 'ahead' ? ` <span class="cf-tag">${esc(this._copy('projected') || 'projected')}</span>` : '';
    const inv = flow.invoices || [], prog = flow.programs || [];
    const sum = (list, k) => list.reduce((a, r) => a + Number(r[k] || 0), 0);
    body.innerHTML = `
      ${(flow.unmapped || []).length ? `<div class="cf-warn">${esc(this._copy('unmapped', { names: flow.unmapped.join(', ') }))}</div>` : ''}
      <div class="cf-pills">
        <button class="cf-pill ${scoped ? '' : 'on'}" data-scope="all">${esc(this._copy('pill_all') || 'All')}</button>
        ${scopes.map(s => `<button class="cf-pill ${this.scope === s.code ? 'on' : ''}" data-scope="${esc(s.code)}">${esc(s.label)}</button>`).join('')}
      </div>
      ${parent ? `<div class="cf-note">${esc(this._copy('shared_in', { league: picked.label, club: parent.label }))}</div>` : ''}
      <div class="cf-pills">${reports.map(([k, l]) => `<button class="cf-pill ${this.report === k ? 'on' : ''}" data-report="${k}">${esc(l)}</button>`).join('')}</div>
      <div class="cf-strip">
        ${card(this._copy('card_since', { date: startDate }) || 'Since invoices began', add(since, 'in'), add(since, 'out'))}
        ${card(this._copy('card_ahead', { n: ahead.length }) || 'Projected', add(ahead, 'in'), add(ahead, 'out'))}
        ${scoped ? '' : `<div class="cf-card">
          <div class="cf-title">${esc(this._copy('card_owed') || 'Owed to the club now')}</div>
          <div class="cf-big">${M((this.summary.all || {}).owed)}</div>
        </div>`}
      </div>
      <div class="cf-card">
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <div class="cf-title" style="flex:1;">${esc(this._copy('months_title') || 'Month by month')}${picked ? ` — ${esc(picked.label)}` : ''}</div>
          <button class="cf-pill" data-all-lines="1">${esc(this.allLines ? (this._copy('hide_lines') || 'Hide the lines') : (this._copy('show_lines') || 'Show every line'))}</button>
        </div>
        <div class="cf-note">${esc(this._copy('tap_month') || '')}</div>
        <div class="cf-note">${esc(this._copy('months_note', { date: startDate }))}</div>
        <div class="cf-note">${esc(this._copy('ahead_note', { rate: M(rate), fee, through: this._date(flow.refs_through) }))}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr><th>${esc(this._copy('month') || 'Month')}</th><th>${esc(this._copy('in') || 'In')}</th><th>${esc(this._copy('out') || 'Out')}</th><th>${esc(this._copy('net') || 'Net')}</th><th>${esc(this._copy('running') || 'Running')}</th></tr></thead>
          <tbody>${rows.map(r => {
            const isOpen = this.allLines || this.open.has(r.ym);
            return `
            <tr class="cf-month ${r.kind === 'past' ? '' : r.kind}" data-ym="${esc(r.ym)}">
              <td>${isOpen ? '▾' : '▸'} ${esc(this._month(r.ym))}${tag(r)}</td>
              <td class="cf-in">${r.in ? M(r.in) : '<span class="cf-dim">–</span>'}</td>
              <td class="cf-out">${r.out ? M(r.out) : '<span class="cf-dim">–</span>'}</td>
              <td class="${this._sign(r.net)}" style="font-weight:700;">${M(r.net)}</td>
              <td class="${this._sign(r.run)}">${M(r.run)}</td>
            </tr>${isOpen ? `<tr><td class="cf-lines" colspan="5">${this._linesHtml(items, r.ym)}</td></tr>` : ''}`;
          }).join('')}</tbody>
        </table></div>
      </div>
      ${scoped ? '' : `<div class="cf-card">
        <div class="cf-title">${esc(this._copy('programs_title') || 'Money in by program')}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr><th>${esc(this._copy('program') || 'Program')}</th><th>${esc(this._copy('since', { date: startDate }))}</th></tr></thead>
          <tbody>${prog.map(p => `<tr><td>${esc(p.label)}</td><td class="cf-in">${M(p.since)}</td></tr>`).join('')}
            <tr class="sum"><td>${esc(this._copy('total') || 'Total')}</td><td class="cf-in">${M(sum(prog, 'since'))}</td></tr></tbody>
        </table></div>
      </div>
      <div class="cf-card">
        <div class="cf-title">${esc(this._copy('invoices_title') || 'Invoices by category')}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr><th>${esc(this._copy('category') || 'Category')}</th><th>${esc(this._copy('final') || 'Final')}</th><th>${esc(this._copy('draft') || 'Draft')}</th><th>${esc(this._copy('total') || 'Total')}</th></tr></thead>
          <tbody>${inv.map(c => `<tr><td>${esc(String(c.label).replace(/:\s*$/, '') || (window.MessageCopy && MessageCopy.block('finances', 'coaching_label')) || c.category)}</td><td class="cf-out">${M(c.final)}</td><td class="cf-out">${M(c.draft)}</td><td class="cf-out">${M(Number(c.final) + Number(c.draft))}</td></tr>`).join('')}
            <tr class="sum"><td>${esc(this._copy('total') || 'Total')}</td><td class="cf-out">${M(sum(inv, 'final'))}</td><td class="cf-out">${M(sum(inv, 'draft'))}</td><td class="cf-out">${M(sum(inv, 'final') + sum(inv, 'draft'))}</td></tr></tbody>
        </table></div>
      </div>`}`;
  }
}
window.CashFlowScreen = CashFlowScreen;
