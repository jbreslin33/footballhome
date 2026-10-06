// fines.js — #fines: the Men's fines on a page of their own (migration 534).
// Owner 2026-10-06: "we need a fines section. does it get its own or inside
// finances. i think its own."
//
// Nothing is typed in here.  GET /api/fines rolls up the same derived
// fines as the #payments boxes (fh_person_fines, mig 460 — RSVPs and
// attendance against fine_policies) by month and by player, with where
// each finished month's LeagueApps posting stands (posted / not on LA /
// post on the first Friday / LA has a different amount).
//
//   Month pills   All months, then each month newest first; a month pill
//                 narrows the table to that month's fines and shows its
//                 totals by kind
//   Table         one row per player with a fine in the picked months:
//                 total, how many, by kind, posting state per finished
//                 month; tap a row for the events behind it; the name opens
//                 the person (#person, like #payments)
//   Rules         the rates in force, from fine_policies
//
// Wording: message_templates kind 'fines'.
class FinesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.month = 'all'; this.sort = 'total'; this.open = new Set(); this.loading = false;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('fines', tier, tokens) : ''; }
  static money(n) { const v = Number(n) || 0; return Number.isInteger(v) ? `$${v}` : `$${v.toFixed(2)}`; }
  _md(iso) { if (!iso) return ''; const d = new Date(iso + (iso.length === 10 ? 'T12:00:00' : '')); return isNaN(d) ? '' : `${d.getMonth() + 1}/${d.getDate()}`; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fi-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px; align-items:center; }
        .fi-pill { padding:6px 12px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.85rem; }
        .fi-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .fi-pill .n { opacity:0.7; font-weight:400; margin-left:4px; }
        .fi-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
        .fi-title { font-weight:700; font-size:1rem; }
        .fi-note { opacity:0.7; font-size:0.8rem; margin:2px 0 8px; }
        .fi-stats { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:var(--space-3); }
        .fi-stat { border:1px solid var(--border-color); border-radius:6px; padding:6px 12px; min-width:110px; }
        .fi-stat .k { font-size:0.65rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6; }
        .fi-stat .v { font-size:1.2rem; font-weight:800; }
        .fi-stat .s { font-size:0.72rem; opacity:0.7; }
        .fi-table { border-collapse:collapse; font-size:0.85rem; width:100%; }
        .fi-table th { padding:4px 8px; text-align:right; opacity:0.7; font-weight:600; white-space:nowrap; }
        .fi-table td { padding:5px 8px; text-align:right; white-space:nowrap; vertical-align:top; }
        .fi-table th:first-child, .fi-table td:first-child { text-align:left; }
        .fi-table tr.row { cursor:pointer; border-top:1px solid var(--border-color, #374151); }
        .fi-table tr.row:hover td { background:rgba(148,163,184,0.08); }
        .fi-table tr.items td { text-align:left; white-space:normal; font-size:0.8rem; opacity:0.9; padding:2px 8px 8px 24px; }
        .fi-table tr.sum td { border-top:2px solid var(--border-color, #374151); font-weight:800; }
        .fi-post { display:inline-block; padding:1px 7px; border-radius:999px; font-size:0.68rem; font-weight:800; letter-spacing:0.03em; margin-left:4px; }
        .fi-post.posted { background:#052e16; color:#86efac; border:1px solid #15803d; }
        .fi-post.not_posted, .fi-post.drift { background:#3a2e05; color:#fde68a; border:1px solid #d97706; }
        .fi-post.due { background:#1e293b; color:#94a3b8; border:1px solid #334155; }
        .fi-post.so_far { background:#1e293b; color:#94a3b8; border:1px solid #334155; }
        .fi-name { background:none; border:none; color:#bfdbfe; text-decoration:underline; cursor:pointer; font:inherit; padding:0; }
        .fi-kinds { font-size:0.75rem; opacity:0.8; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="fi-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="fi-title">💸 Fines</h1><div id="fi-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
        <button class="btn btn-secondary" id="fi-refresh" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
      </div>
      <div class="screen-content" style="max-width:1300px; margin:0 auto;">
        <div class="fi-pills" id="fi-pills"></div>
        <div id="fi-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#fi-back').addEventListener('click', () => this.navigation.goBack());
    div.querySelector('#fi-refresh').addEventListener('click', () => this.load());
    div.addEventListener('click', (e) => {
      const pill = e.target.closest('[data-fi-month]');
      if (pill) { this.month = pill.dataset.fiMonth; this._renderBody(); return; }
      const sort = e.target.closest('[data-fi-sort]');
      if (sort) { this.sort = sort.dataset.fiSort; this._renderBody(); return; }
      const name = e.target.closest('[data-fi-person]');
      if (name) {
        e.stopPropagation();
        const la = name.dataset.fiPerson;
        if (la) this.navigation.goTo('person', { leagueAppsUserId: la, returnTo: 'fines' });
        return;
      }
      const row = e.target.closest('tr.row[data-fi-row]');
      if (row) { const id = Number(row.dataset.fiRow); if (this.open.has(id)) this.open.delete(id); else this.open.add(id); this._renderBody(); }
    });
    return div;
  }

  onEnter() {
    const t = this.find('#fi-title'), s = this.find('#fi-sub');
    if (t) t.textContent = this._copy('title') || '💸 Fines';
    if (s) s.textContent = this._copy('subtitle');
    this.load();
  }

  async load() {
    this.loading = true; this.err = ''; this._renderBody();
    try {
      const res = await this.auth.fetch('/api/fines?months=6');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
    } catch (err) { this.data = null; this.err = err.message || 'Failed to load.'; }
    this.loading = false;
    if (this.isMounted) { this._renderPills(); this._renderBody(); }
  }

  _months() { return ((this.data && this.data.months) || []).slice().reverse(); }   // newest first

  _renderPills() {
    const el = this.find('#fi-pills');
    if (!el) return;
    const months = this._months();
    if (this.month !== 'all' && !months.some(m => m.month === this.month)) this.month = 'all';
    const pill = (key, label, n) => `<button class="fi-pill${this.month === key ? ' on' : ''}" data-fi-month="${key}">${this.escapeHtml(label)}${n != null ? `<span class="n">${this.escapeHtml(n)}</span>` : ''}</button>`;
    el.innerHTML = pill('all', this._copy('month_all') || 'All months', null)
      + months.map(m => pill(m.month, `${m.label}${m.current ? ` (${this._copy('so_far') || 'so far'})` : ''}`, FinesScreen.money(m.total))).join('')
      + `<span style="flex:1;"></span>
         <span style="font-size:0.8rem; opacity:0.75;">Sort</span>
         <button class="fi-pill${this.sort === 'total' ? ' on' : ''}" data-fi-sort="total">Highest total</button>
         <button class="fi-pill${this.sort === 'name' ? ' on' : ''}" data-fi-sort="name">Name</button>`;
  }

  _postPill(m) {
    if (!m) return '';
    if (m.current) return `<span class="fi-post so_far">${this.escapeHtml(this._copy('so_far') || 'so far')}</span>`;
    const p = m.posting; if (!p || !p.status || !(Number(m.total) > 0)) return '';
    const words = {
      posted:     this._copy('posted', { date: this._md(p.postedOn) }) || `on LA ${this._md(p.postedOn)}`,
      not_posted: this._copy('not_posted') || 'NOT ON LA',
      due:        this._copy('due', { date: this._md(p.firstFriday) }) || `post ${this._md(p.firstFriday)}`,
      drift:      this._copy('drift', { amount: FinesScreen.money(p.postedAmount) }) || `LA has ${FinesScreen.money(p.postedAmount)}`,
    };
    return words[p.status] ? `<span class="fi-post ${p.status}">${this.escapeHtml(words[p.status])}</span>` : '';
  }

  _renderBody() {
    const el = this.find('#fi-body');
    if (!el) return;
    if (this.loading) { el.innerHTML = `<div class="loading">Loading…</div>`; return; }
    if (this.err) { el.innerHTML = `<div style="color:#f87171; padding:var(--space-3);">⚠️ ${this.escapeHtml(this.err)}</div>`; return; }
    const d = this.data || { months: [], people: [], rules: [] };
    const months = this._months();
    const picked = this.month === 'all' ? months : months.filter(m => m.month === this.month);
    const pickedKeys = new Set(picked.map(m => m.month));

    // People with a fine in the picked months, with the total over them.
    const rows = d.people.map(p => {
      const ms = (p.months || []).filter(m => pickedKeys.has(m.month));
      const total = ms.reduce((a, m) => a + (Number(m.total) || 0), 0);
      const count = ms.reduce((a, m) => a + ((m.items || []).length), 0);
      const byKind = {};
      for (const m of ms) for (const it of (m.items || [])) { byKind[it.kind] = byKind[it.kind] || { label: it.label, n: 0 }; byKind[it.kind].n++; }
      return { ...p, pickedMonths: ms, pickedTotal: total, pickedCount: count, byKind };
    }).filter(p => p.pickedCount > 0);
    rows.sort(this.sort === 'name' ? (a, b) => a.name.localeCompare(b.name) : (a, b) => b.pickedTotal - a.pickedTotal || b.pickedCount - a.pickedCount || a.name.localeCompare(b.name));

    const total = rows.reduce((a, p) => a + p.pickedTotal, 0);
    const count = rows.reduce((a, p) => a + p.pickedCount, 0);
    const byKind = {};
    for (const m of picked) for (const [k, v] of Object.entries(m.by_kind || {})) { byKind[k] = byKind[k] || { label: v.label, count: 0, total: 0 }; byKind[k].count += v.count; byKind[k].total += v.total; }
    const posting = { posted: 0, not_posted: 0, due: 0, drift: 0 };
    for (const m of picked) if (!m.current && m.posting) for (const k of Object.keys(posting)) posting[k] += m.posting[k] || 0;
    const monthWord = this.month === 'all' ? `over the last ${d.months_back || 6} months` : `in ${(picked[0] || {}).label || this.month}`;

    const stat = (k, v, s) => `<div class="fi-stat"><div class="k">${this.escapeHtml(k)}</div><div class="v">${v}</div>${s ? `<div class="s">${s}</div>` : ''}</div>`;
    const stats = `<div class="fi-stats">
      ${stat('Total', FinesScreen.money(total), `${count} fine${count === 1 ? '' : 's'} ${this.escapeHtml(monthWord)}`)}
      ${stat('Players fined', rows.length, `of ${d.people.length} fineable`)}
      ${Object.values(byKind).map(v => stat(v.label, FinesScreen.money(v.total), `${v.count}`)).join('')}
      ${(posting.posted + posting.not_posted + posting.due + posting.drift) ? stat('Posted to LA', `${posting.posted}`, `${posting.not_posted ? `<span style="color:#fde68a;">${posting.not_posted} not on LA</span> · ` : ''}${posting.drift ? `${posting.drift} differ · ` : ''}${posting.due} to post`) : ''}
    </div>`;

    const itemsHtml = (p) => p.pickedMonths.map(m => (m.items || []).length ? `
      <div><b>${this.escapeHtml(m.label)}</b> ${FinesScreen.money(m.total)} ${this._postPill(m)}</div>
      ${m.items.map(it => `<div>· ${this.escapeHtml(this._md(it.startAt))} ${this.escapeHtml(it.eventKind === 'match' ? `Game${it.opponent ? ' vs ' + it.opponent : ''}` : it.eventKind === 'practice' ? 'Practice' : it.eventKind || 'Event')} — ${this.escapeHtml(it.label)} <b>${FinesScreen.money(it.amount)}</b></div>`).join('')}` : '').join('');

    const table = rows.length ? `
      <table class="fi-table">
        <thead><tr><th>Player</th><th>Teams</th><th>Fines</th><th>By kind</th><th>Months</th><th>Total</th></tr></thead>
        <tbody>
          ${rows.map(p => `
            <tr class="row" data-fi-row="${p.person_id}">
              <td><button class="fi-name" data-fi-person="${this.escapeHtml(p.la_user_id || '')}" title="Open ${this.escapeHtml(p.name)}">${this.escapeHtml(p.name)}</button></td>
              <td style="text-align:left; opacity:0.75; white-space:normal;">${this.escapeHtml(p.teams || '')}</td>
              <td>${p.pickedCount}</td>
              <td class="fi-kinds" style="text-align:left; white-space:normal;">${Object.values(p.byKind).map(v => `${v.n}× ${this.escapeHtml(v.label)}`).join(' · ')}</td>
              <td style="text-align:left;">${p.pickedMonths.filter(m => (m.items || []).length).map(m => `${this.escapeHtml(m.label)} ${FinesScreen.money(m.total)}${this._postPill(m)}`).join('<br>')}</td>
              <td><b>${FinesScreen.money(p.pickedTotal)}</b></td>
            </tr>
            ${this.open.has(p.person_id) ? `<tr class="items"><td colspan="6">${itemsHtml(p)}</td></tr>` : ''}`).join('')}
          <tr class="sum"><td>Total</td><td></td><td>${count}</td><td></td><td></td><td>${FinesScreen.money(total)}</td></tr>
        </tbody>
      </table>`
      : `<div class="fi-note">${this.escapeHtml(this._copy('empty', { month: monthWord }) || `No fines ${monthWord}.`)}</div>`;

    const rules = (d.rules || []).length ? `
      <div class="fi-card">
        <div class="fi-title">${this.escapeHtml(this._copy('rules_title') || 'The rules')}</div>
        <div class="fi-note">${this.escapeHtml(this._copy('rules_note', { section: d.rules[0].section, since: d.rules[0].since }))}</div>
        <table class="fi-table" style="width:auto;">${d.rules.map(r => `<tr><td>${this.escapeHtml(r.label)}</td><td><b>${FinesScreen.money(r.amount)}</b></td></tr>`).join('')}</table>
        ${!Object.keys(byKind).some(k => k.startsWith('no_show')) ? `<div class="fi-note" style="margin-top:8px;">${this.escapeHtml(this._copy('no_shows_note'))}</div>` : ''}
      </div>` : '';

    el.innerHTML = `${stats}<div class="fi-card">${table}</div>${rules}`;
  }
}
