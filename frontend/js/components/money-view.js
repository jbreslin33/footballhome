// money-view.js — #finances "Money in & out" (mig 977; was #cash-flow, mig 882).
//
// Owner 2026-11-03: "apsl pill clicked and expenses pill clicked would be just
// apsl expenses. but if i click 'all' … and just 'apsl' then it gives me all
// coming in from apsl and going out" / "same for all other items and teams
// and leagues".  Two pill rows:
//   Who    All · a section (Men's, Women's, Boys, Girls, Club-wide) · then the
//          section's teams (APSL, Liga 1, Cups · U8, U10, U12, U19 …) —
//          cash_flow_scopes, so a new team is a DB row
//   Money  All · In · Out
// The budget year (Aug 1 – Jul 31, mig 969): actual money up to this month,
// projected after.  Every line of money is a flow.items row tagged with its
// scope; dues count once, for the highest team the member was on when they
// paid (fh_dues_team, migs 973/975), and dues ahead split the same way
// (flow.dues_shares).
//
//   GET /api/finances/cash-flow   CashFlow::build — actuals, rentals, plan
//   GET /api/finances/summary     PaymentsOverview — dues ahead, owed now
//   GET /api/finances/expenses    Expenses::projection — today
//
// Wording: message_templates kind 'cash_flow'.  Used by FinancesScreen and
// the old #cash-flow route.
class MoneyView {
  constructor(screen) {
    this.screen = screen; this.auth = screen.auth;
    this.flow = null; this.summary = null; this.expenses = null;
    this.report = 'likely'; this.scope = 'all'; this.dir = 'all'; this.open = new Set(); this.openKinds = new Set(); this.allLines = false; this.err = '';
  }

  static css() {
    return `
      .cf-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px; }
      .cf-pills.sub { margin-top:-4px; padding-left:12px; border-left:3px solid var(--border-color, #374151); }
      .cf-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
      .cf-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
      .cf-pill.dir.on { background:#475569; border-color:#475569; }
      .cf-wrap { max-width:760px; }
      .cf-strip { display:grid; grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); gap:var(--space-3); margin-bottom:var(--space-3); }
      .cf-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
      .cf-strip .cf-card { margin-bottom:0; }
      .cf-title { font-weight:700; font-size:1rem; }
      .cf-note { opacity:0.7; font-size:0.8rem; margin:2px 0 8px; }
      .cf-big { font-size:1.6rem; font-weight:800; margin-top:4px; }
      .cf-sub { font-size:0.85rem; opacity:0.8; }
      .cf-table { border-collapse:collapse; font-size:0.85rem; width:auto; }
      .cf-table th { padding:4px 10px; text-align:right; opacity:0.7; font-weight:600; white-space:nowrap; }
      .cf-table td { padding:4px 10px; text-align:right; white-space:nowrap; }
      .cf-table th:first-child, .cf-table td:first-child { text-align:left; }
      .cf-table tr.sum td { border-top:2px solid var(--border-color, #374151); font-weight:700; }
      .cf-table tr.now td { background:rgba(14,165,233,0.10); }
      .cf-table tr.ahead td { opacity:0.82; font-style:italic; }
      .cf-tag { font-size:0.72rem; opacity:0.7; font-weight:400; }
      .cf-in { color:#86efac; } .cf-out { color:#fca5a5; } .cf-dim { opacity:0.5; }
      .cf-table tr.cf-month { cursor:pointer; }
      .cf-table tr.cf-month:hover td { background:rgba(148,163,184,0.10); }
      .cf-table td.cf-lines { padding:4px 8px 12px 20px; white-space:normal; }
      .cf-lines .cf-table { font-size:0.8rem; min-width:420px; }
      .cf-lines .cf-table td:last-child { padding-left:24px; }
      .cf-lines td:first-child { white-space:normal; }
      .cf-table tr.cf-kind { cursor:pointer; }
      .cf-table tr.cf-kind td:first-child { font-weight:700; }
      .cf-table tr.cf-kind:hover td { background:rgba(148,163,184,0.10); }
      .cf-table tr.cf-item td { font-size:0.8rem; opacity:0.9; }
      .cf-table tr.cf-item td:first-child { padding-left:24px; white-space:normal; }
      .cf-warn { color:#fbbf24; font-weight:700; font-size:0.85rem; margin-bottom:var(--space-3); }`;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('cash_flow', tier, tokens) : ''; }
  _esc(t) { return this.screen.escapeHtml(t); }

  async load() {
    this.err = '';
    try {
      const res = await Promise.all(['cash-flow', 'summary', 'expenses'].map(p => this.auth.fetch(`/api/finances/${p}`)));
      const [flow, summary, expenses] = await Promise.all(res.map(async (r) => {
        const j = await r.json().catch(() => ({}));
        if (!r.ok) throw new Error(j.error || `HTTP ${r.status}`);
        return j;
      }));
      this.flow = flow; this.summary = summary; this.expenses = expenses;
    } catch (err) { this.err = err.message; }
  }
  ready() { return !!(this.flow && this.summary && this.expenses); }

  // A click inside the view: true when it was ours (the caller re-renders).
  handleClick(e) {
    const p = e.target.closest('[data-report]'); if (p) { this.report = p.dataset.report; return true; }
    const s = e.target.closest('[data-scope]'); if (s) { this.scope = s.dataset.scope; return true; }
    const d = e.target.closest('[data-dir]'); if (d) { this.dir = d.dataset.dir; return true; }
    const k = e.target.closest('[data-kind]');
    if (k) { if (this.openKinds.has(k.dataset.kind)) this.openKinds.delete(k.dataset.kind); else this.openKinds.add(k.dataset.kind); return true; }
    if (e.target.closest('[data-all-lines]')) { this.allLines = !this.allLines; this.open.clear(); return true; }
    const m = e.target.closest('[data-ym]');
    if (m) { if (this.open.has(m.dataset.ym)) this.open.delete(m.dataset.ym); else this.open.add(m.dataset.ym); return true; }
    return false;
  }

  _nowYm() { return String(this.expenses.today || '').slice(0, 7); }
  _lastYm() { let [y, m] = this._nowYm().split('-').map(Number); m--; if (m < 1) { m = 12; y--; } return `${y}-${String(m).padStart(2, '0')}`; }
  _endYm() { return String((this.flow.year || {}).ends_on || '').slice(0, 7); }

  // The months after this one, to the end of the budget year.
  _aheadMonths() {
    const out = [], end = this._endYm(); let [y, m] = this._nowYm().split('-').map(Number);
    if (!y || !end) return out;
    for (;;) { m++; if (m > 12) { m = 1; y++; } const ym = `${y}-${String(m).padStart(2, '0')}`; if (ym > end) break; out.push(ym); }
    return out;
  }

  // Every item in the year, dues ahead added per team, then the pills applied.
  _items() {
    const ratio = Number(this.flow.net_ratio) || 1, end = this._endYm();
    const items = (this.flow.items || []).filter(i => !end || i.ym <= end);
    const scopes = this.flow.scopes || [];
    const sectionScope = new Map(scopes.filter(s => s.section_code).map(s => [s.section_code, s.code]));
    const shares = this.flow.dues_shares || [];
    const ahead = this._aheadMonths();
    if (this.report === 'likely') {
      // Likely: last month's dues in, scope by scope, every month ahead.
      const last = this._lastYm(), byScope = new Map();
      for (const i of items) if (i.dir === 'in' && i.type === 'dues' && i.ym === last) byScope.set(i.scope, (byScope.get(i.scope) || 0) + Number(i.amount));
      for (const ym of ahead) for (const [scope, amount] of byScope) {
        if (!amount) continue;
        const label = (scopes.find(s => s.code === scope) || {}).label || scope;
        items.push({ ym, dir: 'in', scope, type: 'dues_ahead', category: 'dues', detail: '', name: label, amount, ahead: true });
      }
    } else for (const sec of (this.summary.sections || [])) {
      const monthly = Number((sec.projections?.[this.report] || {}).monthly || 0) * ratio;
      if (!monthly) continue;
      let split = shares.filter(x => x.section_code === sec.code);
      if (!split.length && sectionScope.get(sec.code)) split = [{ scope: sectionScope.get(sec.code), share: 1 }];
      for (const ym of ahead) for (const x of split) {
        const label = (scopes.find(s => s.code === x.scope) || {}).label || sec.name;
        items.push({ ym, dir: 'in', scope: x.scope, type: 'dues_ahead', category: 'dues', detail: '', name: label, amount: monthly * Number(x.share), ahead: true });
      }
    }
    const inScope = this._inScope();
    return items.filter(i => (!inScope || inScope.has(i.scope)) && (this.dir === 'all' || i.dir === this.dir));
  }

  // A scope and everything under it; null shows everything.
  static inScopeOf(scopes, code) {
    if (!code || code === 'all') return null;
    const set = new Set([code]);
    let grew = true;
    while (grew) { grew = false; for (const s of (scopes || [])) if (s.parent && set.has(s.parent) && !set.has(s.code)) { set.add(s.code); grew = true; } }
    return set;
  }
  _inScope() { return MoneyView.inScopeOf(this.flow.scopes, this.scope); }

  // Aug 1 → this month from the actuals, then every month left in the year.
  _rows(items) {
    const nowYm = this._nowYm(), startYm = String(this.flow.start || '').slice(0, 7);
    const past = [];
    if (startYm) { let [y, m] = startYm.split('-').map(Number); for (;;) { const ym = `${y}-${String(m).padStart(2, '0')}`; if (ym >= nowYm) break; past.push(ym); m++; if (m > 12) { m = 1; y++; } } }
    const months = [...past.map(ym => [ym, 'past']), [nowYm, 'now'], ...this._aheadMonths().map(ym => [ym, 'ahead'])];
    const total = (ym, dir) => items.filter(i => i.ym === ym && i.dir === dir && !i.prepaid).reduce((a, i) => a + Number(i.amount), 0);
    let run = 0;
    return months.map(([ym, kind]) => {
      const moneyIn = total(ym, 'in'), moneyOut = total(ym, 'out');
      run += moneyIn - moneyOut;
      return { ym, kind, in: moneyIn, out: moneyOut, net: moneyIn - moneyOut, run };
    });
  }

  _lineLabel(i) {
    const tier = { coach: 'line_coach', ref: 'line_ref', dues_ahead: 'line_dues_ahead', rental: 'line_rental' }[i.type];
    return (tier && this._copy(tier, { name: i.name })) || i.name;
  }

  // One month's lines, money in first, biggest first; the same line twice is one row.
  _linesHtml(items, ym) {
    const esc = (t) => this._esc(t), M = MoneyView.money;
    const label = new Map((this.flow.scopes || []).map(s => [s.code, s.label]));
    const merged = new Map();
    for (const i of items.filter(x => x.ym === ym && !x.prepaid)) {
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

  _kindLabel(code) {
    const own = { dues: 'cat_dues', rental: 'cat_rental', labor: 'cat_labor' }[code];
    return (own && this._copy(own)) || ((this.flow.categories || []).find(c => c.code === code) || {}).label || code;
  }

  // Roll-up (mig 985): each kind of money for what the pills show — actual,
  // ahead, year — and, opened, every line that makes it up.
  _rollupHtml(items) {
    const esc = (t) => this._esc(t), M2 = (v) => { const n = Number(v) || 0; return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 }); };
    const order = ['dues', 'rental', ...(this.flow.categories || []).map(c => c.code)];
    const groups = new Map();
    for (const i of items) {
      const key = `${i.dir}|${i.category || 'other'}`;
      if (!groups.has(key)) groups.set(key, { dir: i.dir, code: i.category || 'other', before: 0, actual: 0, ahead: 0, items: [] });
      const g = groups.get(key); g[i.prepaid ? 'before' : i.ahead ? 'ahead' : 'actual'] += Number(i.amount); g.items.push(i);
    }
    const list = [...groups.values()].sort((a, b) => (a.dir === b.dir ? order.indexOf(a.code) - order.indexOf(b.code) : (a.dir === 'in' ? -1 : 1)));
    if (!list.length) return '';
    const cols = (this._copy('rollup_cols') || 'Kind|Before Aug 1|Actual|Ahead|Year').split('|');
    const label = new Map((this.flow.scopes || []).map(s => [s.code, s.label]));
    const row = (g) => {
      const key = `${g.dir}|${g.code}`, isOpen = this.openKinds.has(key), cls = g.dir === 'in' ? 'cf-in' : 'cf-out';
      const lines = isOpen ? [...g.items].sort((a, b) => a.ym.localeCompare(b.ym) || String(a.name).localeCompare(String(b.name))).map(i => `
        <tr class="cf-item"><td>${esc(i.prepaid ? (this._copy('prepaid_tag') || 'Before the year') : this._month(i.ym))} · ${esc(this._lineLabel(i))}${i.detail ? ` <span class="cf-tag">${esc(i.detail)}</span>` : ''}${i.ahead ? ` <span class="cf-tag">${esc(this._copy('ahead_tag') || 'ahead')}</span>` : ''}${this.scope === 'all' || label.get(i.scope) !== (label.get(this.scope)) ? ` <span class="cf-tag">${esc(label.get(i.scope) || '')}</span>` : ''}</td>
          <td class="${cls}">${i.prepaid ? M2(i.amount) : ''}</td><td class="${cls}">${i.ahead || i.prepaid ? '' : M2(i.amount)}</td><td class="${cls}">${i.ahead ? M2(i.amount) : ''}</td><td></td></tr>`).join('') : '';
      return `<tr class="cf-kind" data-kind="${esc(key)}"><td>${isOpen ? '▾' : '▸'} ${esc(this._kindLabel(g.code))} <span class="cf-tag">${g.items.length}</span></td>
        <td class="${cls}">${g.before ? M2(g.before) : '<span class="cf-dim">–</span>'}</td><td class="${cls}">${M2(g.actual)}</td><td class="${cls}">${M2(g.ahead)}</td><td class="${cls}" style="font-weight:700;">${M2(g.before + g.actual + g.ahead)}</td></tr>${lines}`;
    };
    const total = (dir, k) => list.filter(g => g.dir === dir).reduce((a, g) => a + g[k], 0);
    const sumRow = (dir) => list.some(g => g.dir === dir) ? `<tr class="sum"><td>${esc(dir === 'in' ? (this._copy('in') || 'In') : (this._copy('out') || 'Out'))}</td>
        <td class="${dir === 'in' ? 'cf-in' : 'cf-out'}">${M2(total(dir, 'before'))}</td><td class="${dir === 'in' ? 'cf-in' : 'cf-out'}">${M2(total(dir, 'actual'))}</td><td class="${dir === 'in' ? 'cf-in' : 'cf-out'}">${M2(total(dir, 'ahead'))}</td>
        <td class="${dir === 'in' ? 'cf-in' : 'cf-out'}">${M2(total(dir, 'before') + total(dir, 'actual') + total(dir, 'ahead'))}</td></tr>` : '';
    return `
      <div class="cf-card">
        <div class="cf-title">${esc(this._copy('rollup_title') || 'Roll-up')}</div>
        <div class="cf-note">${esc(this._copy('rollup_note') || '')}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${list.filter(g => g.dir === 'in').map(row).join('')}${sumRow('in')}${list.filter(g => g.dir === 'out').map(row).join('')}${sumRow('out')}</tbody>
        </table></div>
      </div>`;
  }

  static money(v) { const n = Math.round(Number(v) || 0); return (n < 0 ? '−' : '') + '$' + Math.abs(n).toLocaleString(); }
  _month(ym) { return new Date(Number(ym.slice(0, 4)), Number(ym.slice(5, 7)) - 1, 1).toLocaleString('en-US', { month: 'short', year: 'numeric' }); }
  _date(d) { return d ? new Date(`${d}T12:00:00`).toLocaleString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }) : ''; }
  _sign(v) { return Number(v) < 0 ? 'cf-out' : 'cf-in'; }

  // The Who rows: top level, then the picked section's teams.
  _whoPills() { return MoneyView.whoPillsHtml(this.flow.scopes || [], this.scope, (t) => this._esc(t), this._copy('pill_all') || 'All'); }
  static whoPillsHtml(scopes, scope, esc, allLabel) {
    const picked = scopes.find(s => s.code === scope);
    const top = picked ? (picked.parent ? picked.parent : picked.code) : null;
    const kids = top ? scopes.filter(s => s.parent === top) : [];
    const pill = (code, label, on) => `<button class="cf-pill ${on ? 'on' : ''}" data-scope="${esc(code)}">${esc(label)}</button>`;
    return `
      <div class="cf-pills">${pill('all', allLabel, scope === 'all')}${scopes.filter(s => !s.parent).map(s => pill(s.code, s.label, s.code === top)).join('')}</div>
      ${kids.length ? `<div class="cf-pills sub">${kids.map(s => pill(s.code, s.label, s.code === scope)).join('')}</div>` : ''}`;
  }

  // opts.who false: the host page draws the Who pills itself (#finances).
  html(opts = {}) {
    const esc = (t) => this._esc(t), M = MoneyView.money;
    if (this.err) return `<div class="error-message">${esc(this.err)}</div>`;
    if (!this.ready()) return '<div class="loading">Loading…</div>';
    const flow = this.flow, year = flow.year || {};
    const items = this._items(), rows = this._rows(items);
    const scoped = this.scope !== 'all';
    const picked = (flow.scopes || []).find(s => s.code === this.scope);
    const startDate = this._date(flow.start);
    const since = rows.filter(r => r.kind !== 'ahead'), ahead = rows.filter(r => r.kind === 'ahead');
    const add = (list, k) => list.reduce((a, r) => a + r[k], 0);
    const showIn = this.dir !== 'out', showOut = this.dir !== 'in';
    const card = (title, moneyIn, moneyOut) => `
      <div class="cf-card">
        <div class="cf-title">${esc(title)}</div>
        <div class="cf-big ${this._sign(showIn && showOut ? moneyIn - moneyOut : showIn ? moneyIn : -moneyOut)}">${M(showIn && showOut ? moneyIn - moneyOut : showIn ? moneyIn : moneyOut)}</div>
        <div class="cf-sub">${showIn ? `<span class="cf-in">${esc(this._copy('in') || 'In')} ${M(moneyIn)}</span>` : ''}${showIn && showOut ? ' · ' : ''}${showOut ? `<span class="cf-out">${esc(this._copy('out') || 'Out')} ${M(moneyOut)}</span>` : ''}</div>
      </div>`;
    const reports = [['current_dues', this._copy('pill_paid_up') || 'Current'], ['likely', this._copy('pill_likely') || 'Likely'], ['all_members', this._copy('pill_paying') || 'Full']];
    const dirs = [['all', this._copy('dir_all') || 'All'], ['in', this._copy('dir_in') || 'In'], ['out', this._copy('dir_out') || 'Out']];
    const rate = ((this.summary.sections || [])[0] || {}).rate || 0;
    const fee = ((1 - (Number(flow.net_ratio) || 1)) * 100).toFixed(1);
    const tag = (r) => r.kind === 'now' ? ` <span class="cf-tag">${esc(this._copy('so_far') || 'so far')}</span>`
      : r.kind === 'ahead' ? ` <span class="cf-tag">${esc(this._copy('projected') || 'projected')}</span>` : '';
    const inv = flow.invoices || [], prog = flow.programs || [];
    const sum = (list, k) => list.reduce((a, r) => a + Number(r[k] || 0), 0);
    const cols = [this._copy('month') || 'Month', ...(showIn ? [this._copy('in') || 'In'] : []), ...(showOut ? [this._copy('out') || 'Out'] : []),
                  ...(showIn && showOut ? [this._copy('net') || 'Net', this._copy('running') || 'Running'] : [])];
    const cell = (v, cls) => `<td class="${cls}">${v ? M(v) : '<span class="cf-dim">–</span>'}</td>`;
    return `<div class="cf-wrap">
      ${(flow.unmapped || []).length ? `<div class="cf-warn">${esc(this._copy('unmapped', { names: flow.unmapped.join(', ') }))}</div>` : ''}
      ${opts.who === false ? '' : this._whoPills()}
      <div class="cf-pills">${dirs.map(([k, l]) => `<button class="cf-pill dir ${this.dir === k ? 'on' : ''}" data-dir="${k}">${esc(l)}</button>`).join('')}</div>
      <div class="cf-note">${esc(this._copy('year_note', { year: year.label || '', from: this._date(year.starts_on), to: this._date(year.ends_on) }))}</div>
      ${picked && picked.team_id ? `<div class="cf-note">${esc(this._copy('shared_in', { league: picked.label }))}</div>` : ''}
      ${showIn ? `<div class="cf-pills">${reports.map(([k, l]) => `<button class="cf-pill ${this.report === k ? 'on' : ''}" data-report="${k}">${esc(l)}</button>`).join('')}</div>` : ''}
      <div class="cf-strip">
        ${card(this._copy('card_since', { date: startDate }) || 'Since', add(since, 'in'), add(since, 'out'))}
        ${card(this._copy('card_ahead', { n: ahead.length }) || 'Projected', add(ahead, 'in'), add(ahead, 'out'))}
        ${card(year.label || '', add(rows, 'in'), add(rows, 'out'))}
      </div>
      ${this._rollupHtml(items)}
      <div class="cf-card">
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <div class="cf-title" style="flex:1;">${esc(this._copy('months_title') || 'Month by month')}${picked ? ` — ${esc(picked.label)}` : ''}</div>
          <button class="cf-pill" data-all-lines="1">${esc(this.allLines ? (this._copy('hide_lines') || 'Hide the lines') : (this._copy('show_lines') || 'Show every line'))}</button>
        </div>
        <div class="cf-note">${esc(this._copy('tap_month') || '')}</div>
        <div class="cf-note">${esc(this._copy('months_note', { date: startDate }))}</div>
        <div class="cf-note">${esc(this.report === 'likely' ? this._copy('likely_note', { month: this._month(this._lastYm()) }) : this._copy('ahead_note', { rate: M(rate), fee, through: this._date(flow.refs_through) }))}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr>${cols.map(c => `<th>${esc(c)}</th>`).join('')}</tr></thead>
          <tbody>${rows.map(r => {
            const isOpen = this.allLines || this.open.has(r.ym);
            return `
            <tr class="cf-month ${r.kind === 'past' ? '' : r.kind}" data-ym="${esc(r.ym)}">
              <td>${isOpen ? '▾' : '▸'} ${esc(this._month(r.ym))}${tag(r)}</td>
              ${showIn ? cell(r.in, 'cf-in') : ''}${showOut ? cell(r.out, 'cf-out') : ''}
              ${showIn && showOut ? `<td class="${this._sign(r.net)}" style="font-weight:700;">${M(r.net)}</td><td class="${this._sign(r.run)}">${M(r.run)}</td>` : ''}
            </tr>${isOpen ? `<tr><td class="cf-lines" colspan="${cols.length}">${this._linesHtml(items, r.ym)}</td></tr>` : ''}`;
          }).join('')}
            <tr class="sum"><td>${esc(this._copy('total') || 'Total')}</td>${showIn ? `<td class="cf-in">${M(add(rows, 'in'))}</td>` : ''}${showOut ? `<td class="cf-out">${M(add(rows, 'out'))}</td>` : ''}${showIn && showOut ? `<td class="${this._sign(add(rows, 'net'))}">${M(add(rows, 'net'))}</td><td></td>` : ''}</tr>
          </tbody>
        </table></div>
      </div>
      ${scoped || this.dir === 'out' ? '' : `<div class="cf-card">
        <div class="cf-title">${esc(this._copy('programs_title') || 'Money in by program')}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr><th>${esc(this._copy('program') || 'Program')}</th><th>${esc(this._copy('since', { date: startDate }))}</th></tr></thead>
          <tbody>${prog.map(p => `<tr><td>${esc(p.label)}</td><td class="cf-in">${M(p.since)}</td></tr>`).join('')}
            <tr class="sum"><td>${esc(this._copy('total') || 'Total')}</td><td class="cf-in">${M(sum(prog, 'since'))}</td></tr></tbody>
        </table></div>
      </div>`}
      ${scoped || this.dir === 'in' ? '' : `<div class="cf-card">
        <div class="cf-title">${esc(this._copy('invoices_title') || 'Invoices by category')}</div>
        <div style="overflow-x:auto;"><table class="cf-table">
          <thead><tr><th>${esc(this._copy('category') || 'Category')}</th><th>${esc(this._copy('final') || 'Final')}</th><th>${esc(this._copy('draft') || 'Draft')}</th><th>${esc(this._copy('total') || 'Total')}</th></tr></thead>
          <tbody>${inv.map(c => `<tr><td>${esc(String(c.label).replace(/:\s*$/, '') || (window.MessageCopy && MessageCopy.block('finances', 'coaching_label')) || c.category)}</td><td class="cf-out">${M(c.final)}</td><td class="cf-out">${M(c.draft)}</td><td class="cf-out">${M(Number(c.final) + Number(c.draft))}</td></tr>`).join('')}
            <tr class="sum"><td>${esc(this._copy('total') || 'Total')}</td><td class="cf-out">${M(sum(inv, 'final'))}</td><td class="cf-out">${M(sum(inv, 'draft'))}</td><td class="cf-out">${M(sum(inv, 'final') + sum(inv, 'draft'))}</td></tr></tbody>
        </table></div>
      </div>`}</div>`;
  }
}
window.MoneyView = MoneyView;
