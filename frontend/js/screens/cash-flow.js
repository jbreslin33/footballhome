// cash-flow.js — #cash-flow: soccer money in against invoices out (mig 882).
//
// Behind us: what LeagueApps actually paid (person_payments, the programs
// la_soccer_programs.counts_in names, after fees, less refunds) against every
// invoice by invoice date, from cash_flow_policies.starts_on.
// Ahead: dues × members, the projection #finances prints. Money out is the
// owner's plan from CashFlow::build: coach pay off the calendar, referee fees
// to cash_flow_policies.refs_through, and the cash_flow_planned rows.
//
//   GET /api/finances/cash-flow   CashFlow::build — the actuals
//   GET /api/finances/summary     PaymentsOverview — dues ahead, owed now
//   GET /api/finances/expenses    Expenses::projection — today and the months ahead
//
// Wording: message_templates kind 'cash_flow'.
class CashFlowScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.flow = null; this.summary = null; this.expenses = null; this.report = 'current_dues'; this.err = ''; }

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
      if (p) { this.report = p.dataset.report; this._renderBody(); }
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

  // Past months and this month from the actuals, then the projection's months.
  _rows() {
    const byYm = new Map((this.flow.months || []).map(m => [m.ym, m]));
    const nowYm = String(this.expenses.today || '').slice(0, 7);
    const ratio = Number(this.flow.net_ratio) || 1;
    const monthlyIn = Number((((this.summary.all || {}).projections || {})[this.report] || {}).monthly || 0) * ratio;
    const invoiced = (m) => Number(m?.final || 0) + Number(m?.draft || 0);
    const past = [...byYm.keys()].filter(ym => ym < nowYm);
    let run = 0;
    const row = (ym, kind, moneyIn, moneyOut, onInvoices) => { run += moneyIn - moneyOut; return { ym, kind, in: moneyIn, out: moneyOut, onInvoices, net: moneyIn - moneyOut, run }; };
    const rows = past.map(ym => row(ym, 'past', Number(byYm.get(ym).net || 0), invoiced(byYm.get(ym)), invoiced(byYm.get(ym))));
    rows.push(row(nowYm, 'now', Number(byYm.get(nowYm)?.net || 0), invoiced(byYm.get(nowYm)), invoiced(byYm.get(nowYm))));
    for (const ym of (this.expenses.months || []).filter(m => m > nowYm)) {
      rows.push(row(ym, 'ahead', monthlyIn, Number((this.flow.ahead_out || {})[ym] || 0), 0));
    }
    return rows;
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
    const rows = this._rows();
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
      <div class="cf-pills">${reports.map(([k, l]) => `<button class="cf-pill ${this.report === k ? 'on' : ''}" data-report="${k}">${esc(l)}</button>`).join('')}</div>
      <div class="cf-strip">
        ${card(this._copy('card_since', { date: startDate }) || 'Since invoices began', add(since, 'in'), add(since, 'onInvoices'))}
        ${card(this._copy('card_ahead', { n: ahead.length }) || 'Projected', add(ahead, 'in'), add(ahead, 'out'))}
        <div class="cf-card">
          <div class="cf-title">${esc(this._copy('card_owed') || 'Owed to the club now')}</div>
          <div class="cf-big">${M((this.summary.all || {}).owed)}</div>
        </div>
      </div>
      <div class="cf-card">
        <div class="cf-title">${esc(this._copy('months_title') || 'Month by month')}</div>
        <div class="cf-note">${esc(this._copy('months_note', { date: startDate }))}</div>
        <div class="cf-note">${esc(this._copy('ahead_note', { rate: M(rate), fee, through: this._date(flow.refs_through) }))}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr><th>${esc(this._copy('month') || 'Month')}</th><th>${esc(this._copy('in') || 'In')}</th><th>${esc(this._copy('out') || 'Out')}</th><th>${esc(this._copy('net') || 'Net')}</th><th>${esc(this._copy('running') || 'Running')}</th></tr></thead>
          <tbody>${rows.map(r => `
            <tr class="${r.kind === 'past' ? '' : r.kind}">
              <td>${esc(this._month(r.ym))}${tag(r)}</td>
              <td class="cf-in">${r.in ? M(r.in) : '<span class="cf-dim">–</span>'}</td>
              <td class="cf-out">${r.out ? M(r.out) : '<span class="cf-dim">–</span>'}</td>
              <td class="${this._sign(r.net)}" style="font-weight:700;">${M(r.net)}</td>
              <td class="${this._sign(r.run)}">${M(r.run)}</td>
            </tr>`).join('')}</tbody>
        </table></div>
      </div>
      <div class="cf-card">
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
      </div>`;
  }
}
window.CashFlowScreen = CashFlowScreen;
