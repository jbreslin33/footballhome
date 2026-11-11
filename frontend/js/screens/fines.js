// fines.js — #fines: the fines, their own page under 💰 Money (mig 534),
// laid out like Tuition (owner 2026-11-11: "i want the fines pill to act
// JUST like tuition pill. same format" / "consistency on the tuition and
// fines page" / fines stay separate from tuition).  Same parts as #payments
// via components/money-board.js:
//
//   📊 Stats      players (fineable, owe, nothing owed, disputed, absolved),
//                 fines (owed, this period so far, on LA), by kind
//   Pills         💰 All · 👨 Mens · 👩 Womens · 👦 Boys + Girls · 👧 Girls
//                 (sections with no fine rules say so)
//   Views         👥 Players · 🧾 Fines (every fine) · 🚩 To bill
//   Players       two sections (owner: "2 cats for amount you owe or not"):
//                 🔴 OWES FINES · 🟢 NOTHING OWED.  A card = name, team
//                 pills, ⚖️ dispute banner, the OWES hero by period
//   ⋯             the player sheet on ⚖️ Fines: each fine with 🕊 Absolve,
//                 absolve a whole period, the absolved list with Undo
//                 (mig 1248), dispute Approve / Deny (mig 691)
//
// Nothing is typed in: GET /api/fines works fines out of RSVPs and
// attendance against fine_policies (fh_person_fines), by tuition period
// (first Friday → first Friday, mig 1207).  A finished period is paid once
// it is on LeagueApps and the player's LA balance is back to $0; until then
// it is owed.  The running period is "so far", never owed yet.
//
// Wording: message_templates kind 'fines'.
class FinesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.disputes = []; this.err = ''; this.loading = false;
    this.tab = 'all'; this.view = 'players'; this.search = '';
    this.period = null;   // 'YYYY-MM' of a finished period, null = now (the normal board)
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('fines', tier, tokens) : ''; }
  _w(tier, fb, tokens) { return this._copy(tier, tokens) || fb; }
  static money(n) { const v = Number(n) || 0; return Number.isInteger(v) ? `$${v}` : `$${v.toFixed(2)}`; }
  // "Oct 10/2–11/5" — a period's name with its dates (mig 1207).
  _period(m) {
    if (!m) return '';
    const tokens = { month: m.label, from: this._md(m.from), to: this._md(m.to) };
    return (m.from && this._copy('period_range', tokens)) || (m.from ? `${m.label} ${tokens.from}–${tokens.to}` : m.label);
  }
  _md(iso) { if (!iso) return ''; const d = new Date(iso + (iso.length === 10 ? 'T12:00:00' : '')); return isNaN(d) ? '' : `${d.getMonth() + 1}/${d.getDate()}`; }
  _event(it) {
    return it.eventKind === 'match' ? `Game${it.opponent ? ' vs ' + it.opponent : ''}`
         : it.eventKind === 'practice' ? 'Practice' : (it.eventKind || 'Event');
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .fi-post { display:inline-block; padding:1px 7px; border-radius:999px; font-size:0.68rem; font-weight:800; letter-spacing:0.03em; margin-left:4px; }
        .fi-post.posted { background:#052e16; color:#86efac; border:1px solid #15803d; }
        .fi-post.not_posted, .fi-post.drift { background:#3a2e05; color:#fde68a; border:1px solid #d97706; }
        .fi-post.due, .fi-post.so_far { background:#1e293b; color:#94a3b8; border:1px solid #334155; }
        .fi-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
        .fi-title { font-weight:700; font-size:1rem; }
        .fi-note { opacity:0.7; font-size:0.8rem; margin:2px 0 8px; }
        .fi-table { border-collapse:collapse; font-size:0.8rem; width:100%; font-variant-numeric: tabular-nums; }
        .fi-table th { padding:8px 10px; text-align:left; border-bottom:1px solid var(--border-color, #374151); background:var(--bg-tertiary, #1f2937); position:sticky; top:0; }
        .fi-table td { padding:6px 10px; border-bottom:1px solid var(--border-color, #374151); vertical-align:top; }
        .fi-btn { min-width:0; min-height:0; padding:3px 9px; border-radius:6px; cursor:pointer; font-weight:700; font-size:0.75rem; background:#1e293b; color:#e2e8f0; border:1px solid #475569; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="fi-title">💸 Fines</h1>
        <p class="subtitle" id="fi-sub"></p>
      </div>
      <div style="padding: var(--space-4); max-width: 1400px; margin: 0 auto;">
        <div id="fi-stats" style="${MoneyBoard.STATS_STYLE}"><div style="opacity:0.7;">📊 Stats — loading…</div></div>
        <div id="fi-filters" style="margin-bottom: var(--space-3);"></div>
        <div id="fi-periods" style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom: var(--space-3);"></div>
        <div id="fi-views" style="display:flex; gap:var(--space-2); margin-bottom: var(--space-3);"></div>
        <div style="margin-bottom: var(--space-3);">
          <input id="fi-search" type="text" placeholder="🔎 Filter by name…"
                 style="width:100%; padding: 8px 12px; border-radius: 6px; border: 1px solid var(--border-color, #374151);
                        background: var(--bg-secondary, #111827); color: var(--fg, #e5e7eb); font-size: 0.9rem;">
        </div>
        <div id="fi-body"><div style="text-align:center; padding: var(--space-4); opacity:0.6;">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('.back-btn').addEventListener('click', () => this.navigation.goBack());
    div.querySelector('#fi-search').addEventListener('input', (e) => { this.search = e.target.value.trim().toLowerCase(); this._renderBody(); });
    div.addEventListener('click', (e) => this._onClick(e));
    return div;
  }

  onEnter() {
    const t = this.find('#fi-title'), s = this.find('#fi-sub');
    if (t) t.textContent = this._w('title', '💸 Fines');
    if (s) s.textContent = this._copy('subtitle');
    MoneyBoard.sectionPills(this, this.find('#fi-filters'), this.tab, (id) => { this.tab = id; this._renderAll(); });
    this._renderViews();
    this.load();
  }

  _onClick(e) {
    const dispute = e.target.closest('[data-fi-dispute]');
    if (dispute) { dispute.disabled = true; this._decide(Number(dispute.dataset.fiDispute), dispute.dataset.decision); return; }
    const absolve = e.target.closest('[data-fi-absolve]');
    if (absolve) { e.stopPropagation(); this._absolve(absolve); return; }
    const undo = e.target.closest('[data-fi-undo]');
    if (undo) { e.stopPropagation(); this._undo(Number(undo.dataset.fiUndo), undo); return; }
    const per = e.target.closest('[data-fi-period]');
    if (per) { const k = per.dataset.fiPeriod; this.period = k === 'now' ? null : k; this._renderAll(); return; }
    const view = e.target.closest('.fi-view');
    if (view) { this.view = view.dataset.view; MoneyBoard.paintViewTabs(this.element, 'fi-view', this.view); this._renderBody(); return; }
    const sheetBtn = e.target.closest('[data-player-sheet]');
    if (sheetBtn && !sheetBtn.closest('.player-sheet')) { this._openSheet(Number(sheetBtn.dataset.playerSheet), sheetBtn.dataset.sheetTab || 'fines'); return; }
    const card = e.target.closest('.pay-member-card[data-player-key]');
    if (card && !e.target.closest('a, button, input, select')) this._openSheet(Number(card.dataset.playerKey), 'fines');
  }

  async load() {
    this.loading = true; this.err = ''; this._renderAll();
    try {
      const [res, dres] = await Promise.all([this.auth.fetch('/api/fines?months=6'), this.auth.fetch('/api/fines/disputes')]);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
      const dbody = dres.ok ? await dres.json().catch(() => ({})) : {};
      this.disputes = Array.isArray(dbody.disputes) ? dbody.disputes : [];
    } catch (err) { this.data = null; this.err = err.message || 'Failed to load.'; }
    this.loading = false;
    if (this.isMounted) this._renderAll();
    if (window.PlayerSheet) PlayerSheet.refresh();
  }

  // ── The rows, worked out per player ────────────────────────────────
  // Boys shows Boys + Girls (Screen.sectionIncludes); codes M/W/B/G.
  static TAB_CODES = { mens: ['M'], womens: ['W'], boys: ['B', 'G'], girls: ['G'] };
  _inTab(p) { return this.tab === 'all' || (FinesScreen.TAB_CODES[this.tab] || []).includes(p.section_code); }

  // A finished period is paid once it is on LA and his LA balance is $0.
  static paidOff(p, m) { return !!(m && m.posting && m.posting.status === 'posted' && !(Number(p.la_balance) > 0.005)); }

  _row(p) {
    const months = p.months || [];
    const paidOff = (m) => FinesScreen.paidOff(p, m);
    const owedPeriods = months.filter(m => !m.current && Number(m.total) > 0 && !paidOff(m));
    const current = months.find(m => m.current) || null;
    return {
      ...p,
      owedPeriods,
      owed: owedPeriods.reduce((a, m) => a + Number(m.total), 0),
      current,
      soFar: current ? Number(current.total) || 0 : 0,
      disputes: this.disputes.filter(d => d.person_id === p.person_id),
      absolved: ((this.data && this.data.absolved) || []).filter(a => a.person_id === p.person_id),
    };
  }

  _rows() {
    const people = (this.data && this.data.people) || [];
    return people.filter(p => this._inTab(p)).map(p => this._row(p));
  }

  _byId(pid) {
    const p = ((this.data && this.data.people) || []).find(x => x.person_id === pid);
    return p ? this._row(p) : null;
  }

  // ── Drawing ─────────────────────────────────────────────────────────
  _renderAll() { this._paintPeriods(); this._renderStats(); this._renderBody(); }

  // ── Period pills (owner 2026-11-11: "show what is owed for each month 1st
  // friday to day before first friday for fines just like tuition" / "show
  // each month separate and allow me to absolve each month separate and
  // thus charge each month separate").  One pill per tuition period that
  // had fines; the running one = the normal board.  A finished period
  // shows only that period: who owes it, who paid it, who had none — each
  // card with 🕊 Absolve <period>.
  _periods() {
    const list = ((this.data && this.data.months) || []).filter(m => m.current || Number(m.total) > 0);
    return list.slice().sort((a, b) => String(b.month).localeCompare(String(a.month)));
  }
  _selPeriod() {
    if (!this.period) return null;
    return this._periods().find(m => m.month === this.period && !m.current) || null;
  }
  _paintPeriods() {
    const host = this.find('#fi-periods');
    if (!host) return;
    const list = this._periods();
    if (this.loading || list.length < 2) { host.innerHTML = ''; return; }
    if (this.period && !this._selPeriod()) this.period = null;
    host.innerHTML = list.map(m => {
      const key = m.current ? 'now' : m.month;
      const on = m.current ? !this.period : this.period === m.month;
      const label = m.current
        ? this._w('period_pill_current', `${this._period(m)} so far`, { period: this._period(m) })
        : this._period(m);
      return `<button type="button" data-fi-period="${this.escapeHtml(key)}"
          style="padding:3px 12px; border-radius:999px; font-size:0.8rem; font-weight:700; cursor:pointer;
                 border:1px solid #38bdf8; background:${on ? '#38bdf8' : 'transparent'}; color:${on ? '#0f172a' : '#7dd3fc'};">${this.escapeHtml(label)}</button>`;
    }).join('');
  }
  // One player's standing in one finished period.
  _inPeriod(r, P) {
    const m = (r.months || []).find(x => x.month === P.month) || null;
    const total = m ? Number(m.total) || 0 : 0;
    const state = !(total > 0.005) ? 'none' : (FinesScreen.paidOff(r, m) ? 'paid' : 'owes');
    return { m, total, state };
  }
  _itemsAttr(list) { return (list || []).map(it => `${it.fhEventId}:${it.kind}`).join(','); }

  _renderViews() {
    const el = this.find('#fi-views');
    if (el) el.innerHTML = MoneyBoard.viewTabsHtml([
      { id: 'players', label: this._w('view_players', '👥 Players') },
      { id: 'fines',   label: this._w('view_fines', '🧾 Fines') },
      { id: 'to_bill', label: this._w('view_to_bill', '🚩 To bill') },
    ], this.view, 'fi-view');
  }

  _tabLabel() { return (MoneyBoard.SECTION_PILLS.find(x => x.id === this.tab) || {}).label || ''; }

  _renderStats() {
    const el = this.find('#fi-stats');
    if (!el) return;
    if (this.loading || !this.data) {
      el.innerHTML = MoneyBoard.statsHtml({ title: `📊 Stats · ${this._tabLabel()}`, loading: this.loading ? 'loading…' : '', rows: [] });
      return;
    }
    const rows = this._rows();
    const P = this._selPeriod();
    if (P) { this._renderPeriodStats(el, rows, P); return; }
    const owes = rows.filter(r => r.owed > 0.005);
    const byKind = {};
    for (const r of rows) for (const m of (r.months || [])) for (const it of (m.items || [])) {
      const k = byKind[it.kind] || (byKind[it.kind] = { label: it.label, n: 0, total: 0 });
      k.n++; k.total += Number(it.amount) || 0;
    }
    const finished = rows.flatMap(r => (r.months || []).filter(m => !m.current && Number(m.total) > 0));
    const onLa = finished.filter(m => m.posting && m.posting.status === 'posted').length;
    const cell = (label, value, color, title) => ({ label, value, color, title });
    el.innerHTML = MoneyBoard.statsHtml({
      title: `📊 Stats · ${this._tabLabel()}`,
      rows: [
        { title: this._w('stats_players', 'PLAYERS'), cells: [
          cell(this._w('stat_fineable', 'Fineable'), rows.length),
          cell(this._w('stat_owes', '🔴 Owe'), owes.length, '#fca5a5'),
          cell(this._w('stat_clear', '🟢 Nothing owed'), rows.length - owes.length, '#86efac'),
          cell(this._w('stat_disputed', '⚖️ Disputed'), rows.reduce((a, r) => a + r.disputes.length, 0), '#fde68a'),
          cell(this._w('stat_absolved', '🕊 Absolved'), rows.reduce((a, r) => a + r.absolved.length, 0), '#93c5fd'),
        ] },
        { title: this._w('stats_money', 'FINES'), cells: [
          cell(this._w('stat_owed', '🔴 Owed'), FinesScreen.money(owes.reduce((a, r) => a + r.owed, 0)), '#fca5a5'),
          cell(this._w('stat_so_far', 'This period so far'), FinesScreen.money(rows.reduce((a, r) => a + r.soFar, 0))),
          cell(this._w('stat_on_la', 'On LA'), `${onLa} / ${finished.length}`),
        ] },
        ...(Object.keys(byKind).length ? [{ title: this._w('stats_kinds', 'BY KIND'),
          cells: Object.values(byKind).map(k => cell(this.escapeHtml(k.label), `${FinesScreen.money(k.total)} <span style="opacity:0.5; font-size:0.72rem; font-weight:400;">(${k.n})</span>`)) }] : []),
      ],
    });
  }

  _renderPeriodStats(el, rows, P) {
    const name = this._period(P);
    const per = rows.map(r => ({ r, ...this._inPeriod(r, P) }));
    const sum = (st) => per.filter(x => x.state === st).reduce((a, x) => a + x.total, 0);
    const n = (st) => per.filter(x => x.state === st).length;
    const byKind = {};
    for (const x of per) for (const it of ((x.m && x.m.items) || [])) {
      const k = byKind[it.kind] || (byKind[it.kind] = { label: it.label, n: 0, total: 0 });
      k.n++; k.total += Number(it.amount) || 0;
    }
    const absolved = rows.reduce((a, r) => a + r.absolved.filter(x => x.month === P.month).length, 0);
    const cell = (label, value, color) => ({ label, value, color });
    el.innerHTML = MoneyBoard.statsHtml({
      title: `📊 ${this.escapeHtml(this._w('period_stats_title', `Stats · ${name}`, { period: name }))} · ${this._tabLabel()}`,
      rows: [
        { title: this._w('stats_money', 'FINES'), cells: [
          cell(this._w('period_stat_fined', 'Fined'), FinesScreen.money(sum('owes') + sum('paid'))),
          cell(this._w('period_stat_owed', '🔴 Still owed'), FinesScreen.money(sum('owes')), '#fca5a5'),
          cell(this._w('period_stat_paid', '✅ Paid'), FinesScreen.money(sum('paid')), '#86efac'),
        ] },
        { title: this._w('stats_players', 'PLAYERS'), cells: [
          cell(this._w('stat_owes', '🔴 Owe'), n('owes'), '#fca5a5'),
          cell(this._w('period_stat_paid_n', '✅ Paid'), n('paid'), '#86efac'),
          cell(this._w('period_stat_none', '🟢 No fines'), n('none')),
          cell(this._w('stat_absolved', '🕊 Absolved'), absolved, '#93c5fd'),
        ] },
        ...(Object.keys(byKind).length ? [{ title: this._w('stats_kinds', 'BY KIND'),
          cells: Object.values(byKind).map(k => cell(this.escapeHtml(k.label), `${FinesScreen.money(k.total)} <span style="opacity:0.5; font-size:0.72rem; font-weight:400;">(${k.n})</span>`)) }] : []),
      ],
    });
  }

  _renderBody() {
    const el = this.find('#fi-body');
    if (!el) return;
    if (this.loading) { el.innerHTML = `<div style="text-align:center; padding: var(--space-4); opacity:0.6;">Loading…</div>`; return; }
    if (this.err) { el.innerHTML = `<div style="color:#f87171; padding:var(--space-3); text-align:center;">⚠️ ${this.escapeHtml(this.err)}</div>`; return; }
    const rows = this._rows().filter(r => !this.search || String(r.name || '').toLowerCase().includes(this.search));
    if (!this._rows().length) {
      const section = this._tabLabel().replace(/^\S+\s/, '');
      el.innerHTML = `<div class="fi-card fi-note" style="text-align:center;">${this.escapeHtml(this._w('no_rules', `No fine rules for ${section} — nobody here is fined.`, { section }))}</div>`;
      return;
    }
    if (this.view === 'fines') { el.innerHTML = this._finesTable(rows); return; }
    if (this.view === 'to_bill') { el.innerHTML = this._toBill(rows); return; }
    const P = this._selPeriod();
    if (P) { this._renderPeriodBody(el, rows, P); return; }
    const owes = rows.filter(r => r.owed > 0.005).sort((a, b) => b.owed - a.owed || a.name.localeCompare(b.name));
    const clear = rows.filter(r => !(r.owed > 0.005)).sort((a, b) => b.soFar - a.soFar || a.name.localeCompare(b.name));
    const sec = (meta, list) => list.length ? MoneyBoard.section(meta, list.length, list.map(r => this._card(r)).join('')) : '';
    el.innerHTML =
        sec({ icon: '🔴', label: this._w('sec_owes', 'OWES FINES'), fg: '#7f1d1d', bg: '#fee2e2', border: '#dc2626' }, owes)
      + sec({ icon: '🟢', label: this._w('sec_clear', 'NOTHING OWED'), fg: '#14532d', bg: '#dcfce7', border: '#16a34a' }, clear)
      + this._waivedHtml() + this._rulesHtml();
    if (window.PersonStanding && PersonStanding.fillRosters) PersonStanding.fillRosters(this.auth, el);
  }

  _renderPeriodBody(el, rows, P) {
    const name = this._period(P);
    const per = rows.map(r => ({ r, ...this._inPeriod(r, P) }));
    const pick = (st) => per.filter(x => x.state === st).sort((a, b) => b.total - a.total || a.r.name.localeCompare(b.r.name));
    const sec = (meta, list) => list.length ? MoneyBoard.section(meta, list.length, list.map(x => this._periodCard(x, P)).join('')) : '';
    el.innerHTML =
        sec({ icon: '🔴', label: this._w('period_sec_owes', `OWES FOR ${name}`, { period: name }), fg: '#7f1d1d', bg: '#fee2e2', border: '#dc2626' }, pick('owes'))
      + sec({ icon: '✅', label: this._w('period_sec_paid', `PAID FOR ${name}`, { period: name }), fg: '#14532d', bg: '#dcfce7', border: '#16a34a' }, pick('paid'))
      + sec({ icon: '🟢', label: this._w('period_sec_none', `NO FINES IN ${name}`, { period: name }), fg: '#1e3a8a', bg: '#dbeafe', border: '#2563eb' }, pick('none'));
    if (window.PersonStanding && PersonStanding.fillRosters) PersonStanding.fillRosters(this.auth, el);
  }

  // A card for one period: that period's amount, where it stands on LA,
  // its fines, and 🕊 Absolve <period> (lets off every fine in it).
  _periodCard(x, P) {
    const { r, m, total, state } = x;
    const key = r.person_id;
    const name = this._period(P);
    let hero = `<div style="font-size:0.85rem; font-weight:700; color:#86efac;">🟢 ${this.escapeHtml(this._w('period_none_hero', `No fines in ${name}`, { period: name }))}</div>`;
    if (state !== 'none') {
      const owes = state === 'owes';
      hero = `<div style="background:#0b1220; border:1px solid ${owes ? '#7f1d1d' : '#15803d'}; border-radius:6px; padding:8px 10px;">
           <div style="display:flex; align-items:baseline; gap:6px; flex-wrap:wrap;">
             <span style="font-size:0.65rem; opacity:0.55; text-transform:uppercase; letter-spacing:0.5px;">${this.escapeHtml(owes ? this._w('owes_hero', 'OWES') : this._w('period_paid_hero', 'PAID'))}</span>
             <span style="font-size:1.4rem; font-weight:800; color:${owes ? '#fca5a5' : '#86efac'}; line-height:1;">${FinesScreen.money(total)}</span>
             ${this._postPill(m)}
           </div>
           ${(m.items || []).map(it => `<div style="font-size:0.78rem; margin-top:3px; opacity:0.85;">${this.escapeHtml(this._md(it.startAt))} ${this.escapeHtml(this._event(it))} — ${this.escapeHtml(it.label)} · <b>${FinesScreen.money(it.amount)}</b></div>`).join('')}
           ${owes ? `<div style="margin-top:8px;"><button type="button" class="fi-btn" data-fi-absolve="${key}" data-items="${this._itemsAttr(m.items)}">${this.escapeHtml(this._w('absolve_period', `🕊 Absolve all of ${name}`, { period: name }))}</button></div>` : ''}
         </div>`;
    }
    return `${MoneyBoard.cardOpen(key)}
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
          <div style="font-weight:700; font-size:1rem;">${this.escapeHtml(r.name)}</div>
          <div style="display:flex; align-items:center; gap:6px;">${window.PlayerSheet ? PlayerSheet.button(key, { tab: 'fines', flagged: r.disputes.length > 0 }) : ''}</div>
        </div>
        <div data-roster-standing="${key}"></div>
        ${hero}
      ${MoneyBoard.cardClose}`;
  }

  _postPill(m) {
    if (!m) return '';
    if (m.current) return `<span class="fi-post so_far">${this.escapeHtml(this._w('so_far', 'so far'))}</span>`;
    const p = m.posting; if (!p || !p.status || !(Number(m.total) > 0)) return '';
    const words = {
      posted:     this._w('posted', `on LA ${this._md(p.postedOn)}`, { date: this._md(p.postedOn) }),
      not_posted: this._w('not_posted', 'NOT ON LA'),
      due:        this._w('due', `post ${this._md(p.firstFriday)}`, { date: this._md(p.firstFriday) }),
      drift:      this._w('drift', `LA has ${FinesScreen.money(p.postedAmount)}`, { amount: FinesScreen.money(p.postedAmount) }),
    };
    return words[p.status] ? `<span class="fi-post ${p.status}">${this.escapeHtml(words[p.status])}</span>` : '';
  }

  _card(r) {
    const key = r.person_id;
    const banner = r.disputes.length
      ? `<button type="button" data-player-sheet="${key}" data-sheet-tab="fines"
                 style="text-align:left; padding:6px 10px; border-radius:6px; cursor:pointer; font-weight:800; font-size:0.8rem;
                        background:#3a2e05; color:#fde68a; border:1px solid #d97706;">
           ${this.escapeHtml(this._w('disputes_heading', `Disputes to review (${r.disputes.length})`, { n: r.disputes.length }))} ›</button>`
      : '';
    const hero = r.owed > 0.005
      ? `<div style="background:#0b1220; border:1px solid #7f1d1d; border-radius:6px; padding:8px 10px;">
           <div style="display:flex; align-items:baseline; gap:6px;">
             <span style="font-size:0.65rem; opacity:0.55; text-transform:uppercase; letter-spacing:0.5px;">${this.escapeHtml(this._w('owes_hero', 'OWES'))}</span>
             <span style="font-size:1.4rem; font-weight:800; color:#fca5a5; line-height:1;">${FinesScreen.money(r.owed)}</span>
           </div>
           ${r.owedPeriods.map(m => `<div style="font-size:0.8rem; margin-top:4px;">${this.escapeHtml(this._period(m))} · <b>${FinesScreen.money(m.total)}</b>${this._postPill(m)}</div>`).join('')}
         </div>`
      : `<div style="font-size:0.85rem; font-weight:700; color:#86efac;">🟢 ${this.escapeHtml(this._w('clear_hero', 'Nothing owed'))}</div>`;
    const soFar = r.current && r.soFar > 0
      ? `<div style="font-size:0.8rem; opacity:0.8;">${this.escapeHtml(this._w('so_far_line', `${this._period(r.current)} so far: ${FinesScreen.money(r.soFar)}`, { period: this._period(r.current), amount: FinesScreen.money(r.soFar) }))}</div>`
      : '';
    return `${MoneyBoard.cardOpen(key)}
        <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:8px;">
          <div style="font-weight:700; font-size:1rem;">${this.escapeHtml(r.name)}</div>
          <div style="display:flex; align-items:center; gap:6px;">${window.PlayerSheet ? PlayerSheet.button(key, { tab: 'fines', flagged: r.disputes.length > 0 }) : ''}</div>
        </div>
        <div data-roster-standing="${key}"></div>
        ${banner}
        ${hero}
        ${soFar}
      ${MoneyBoard.cardClose}`;
  }

  // 🧾 Every fine in the window, newest first (like Transactions).
  _finesTable(rows) {
    const lines = [];
    const P = this._selPeriod();
    const inP = (month) => !P || month === P.month;
    for (const r of rows) for (const m of (r.months || [])) if (inP(m.month)) for (const it of (m.items || [])) lines.push({ r, m, it, absolved: null });
    for (const r of rows) for (const a of r.absolved) if (inP(a.month)) lines.push({ r, m: (r.months || []).find(m => m.month === a.month), it: a, absolved: a });
    lines.sort((a, b) => String(b.it.startAt).localeCompare(String(a.it.startAt)));
    if (!lines.length) return `<div class="fi-card fi-note" style="text-align:center;">${this.escapeHtml(this._w('empty', 'No fines.', { month: '' }))}</div>`;
    return `<div style="overflow:auto; border:1px solid var(--border-color, #374151); border-radius:6px;">
      <table class="fi-table">
        <thead><tr><th>When</th><th>Player</th><th>Event</th><th>Fine</th><th style="text-align:right;">Amount</th><th>Period</th></tr></thead>
        <tbody>${lines.map(({ r, m, it, absolved }) => `
          <tr style="${absolved ? 'opacity:0.55;' : ''}">
            <td style="white-space:nowrap;">${this.escapeHtml(this._md(it.startAt))}</td>
            <td>${this.escapeHtml(r.name)}</td>
            <td>${this.escapeHtml(this._event(it))}</td>
            <td>${this.escapeHtml(it.label)}${absolved ? ` · 🕊 ${this.escapeHtml(this._w('absolved_line', `let off — ${absolved.reason || ''}`, { reason: absolved.reason || '' }))}` : ''}</td>
            <td style="text-align:right; font-weight:700;">${absolved ? `<s>${FinesScreen.money(it.amount)}</s>` : FinesScreen.money(it.amount)}</td>
            <td style="white-space:nowrap;">${m ? `${this.escapeHtml(this._period(m))}${absolved ? '' : this._postPill(m)}` : ''}</td>
          </tr>`).join('')}</tbody>
      </table></div>`;
  }

  // 🚩 Finished periods not on LeagueApps yet — what the next bill carries.
  _toBill(rows) {
    const list = [];
    const P = this._selPeriod();
    for (const r of rows) for (const m of r.owedPeriods) if ((!P || m.month === P.month) && (!m.posting || m.posting.status !== 'posted')) list.push({ r, m });
    if (!list.length) return `<div class="fi-card fi-note" style="text-align:center;">${this.escapeHtml(this._w('to_bill_empty', 'Nothing waiting to go on a bill.'))}</div>`;
    list.sort((a, b) => a.r.name.localeCompare(b.r.name) || a.m.month.localeCompare(b.m.month));
    const total = list.reduce((a, x) => a + Number(x.m.total), 0);
    return `<div style="overflow:auto; border:1px solid var(--border-color, #374151); border-radius:6px;">
      <table class="fi-table">
        <thead><tr><th>Player</th><th>Period</th><th style="text-align:right;">Amount</th><th>LeagueApps</th><th>What it is</th></tr></thead>
        <tbody>${list.map(({ r, m }) => `
          <tr>
            <td>${this.escapeHtml(r.name)}</td>
            <td style="white-space:nowrap;">${this.escapeHtml(this._period(m))}</td>
            <td style="text-align:right; font-weight:700;">${FinesScreen.money(m.total)}</td>
            <td>${this._postPill(m)}</td>
            <td style="font-size:0.75rem; opacity:0.85;">${(m.items || []).map(it => `${this.escapeHtml(this._md(it.startAt))} ${this.escapeHtml(this._event(it))} — ${this.escapeHtml(it.label)} ${FinesScreen.money(it.amount)}`).join('<br>')}</td>
          </tr>`).join('')}
          <tr><td colspan="2" style="font-weight:800;">Total</td><td style="text-align:right; font-weight:800;">${FinesScreen.money(total)}</td><td colspan="2"></td></tr>
        </tbody>
      </table></div>`;
  }

  _rulesHtml() {
    const d = this.data || {};
    if (!(d.rules || []).length) return '';
    return `<div class="fi-card">
        <div class="fi-title">${this.escapeHtml(this._w('rules_title', 'The rules'))}</div>
        <div class="fi-note">${this.escapeHtml(this._copy('rules_note', { section: d.rules[0].section, since: d.rules[0].since }))}</div>
        <table class="fi-table" style="width:auto;">${d.rules.map(r => `<tr><td>${this.escapeHtml(r.label)}</td><td><b>${FinesScreen.money(r.amount)}</b></td></tr>`).join('')}</table>
      </div>`;
  }

  // 💤 Waived (mig 997): inactive players' whole stretches.
  _waivedHtml() {
    const waivers = ((this.data && this.data.waivers) || []).filter(w => !this.search || String(w.name || '').toLowerCase().includes(this.search));
    if (!waivers.length) return '';
    return `<div class="fi-card">
        <div class="fi-title">${this.escapeHtml(this._w('waived_title', '💤 Waived'))}</div>
        <div class="fi-note">${this.escapeHtml(this._copy('waived_note'))}</div>
        <table class="fi-table">${waivers.map(w => `<tr>
            <td>${this.escapeHtml(w.name)}</td>
            <td style="opacity:0.75;">${this.escapeHtml(w.until
              ? this._copy('waived_closed', { from: this._md(w.from), until: this._md(w.until) })
              : this._copy('waived_open', { from: this._md(w.from) }))}</td>
            <td style="text-align:right;"><s style="opacity:0.7;">${FinesScreen.money(w.total)}</s> → <b>$0</b></td>
          </tr>`).join('')}</table>
      </div>`;
  }

  // ── The player sheet, opened on ⚖️ Fines ───────────────────────────
  _openSheet(pid, tab) {
    if (!window.PlayerSheet || !pid) return;
    PlayerSheet.open({
      host: this.element,
      auth: this.auth,
      tab: tab || 'fines',
      resolve: () => {
        const r = this._byId(pid);
        return r ? { personId: r.person_id, laUserId: r.la_user_id, firstName: r.name, lastName: '', returnTo: 'fines' } : null;
      },
      extras: () => {
        const r = this._byId(pid);
        return r ? { fines: { html: this._sheetFines(r), flag: r.disputes.length > 0 } } : {};
      },
    });
  }

  _sheetFines(r) {
    const items = (list) => list.map(it => `${it.fhEventId}:${it.kind}`).join(',');
    const disputes = r.disputes.map(d => `
      <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:6px 8px; border:1px solid #d97706; border-radius:6px; background:#3a2e05;">
        <div style="flex:1; min-width:200px; font-size:0.85rem;">${this.escapeHtml(this._copy('dispute_line', { name: d.name, event: d.event, amount: FinesScreen.money(d.amount) }))}
          ${d.note ? `<div style="opacity:0.8; font-style:italic; margin-top:2px;">"${this.escapeHtml(d.note)}"</div>` : ''}</div>
        <button type="button" class="fi-btn" data-fi-dispute="${d.id}" data-decision="approve" style="background:#059669; border-color:#059669; color:#fff;">${this.escapeHtml(this._w('dispute_approve', 'Approve'))}</button>
        <button type="button" class="fi-btn" data-fi-dispute="${d.id}" data-decision="deny" style="background:#7f1d1d; border-color:#7f1d1d; color:#fff;">${this.escapeHtml(this._w('dispute_deny', 'Deny'))}</button>
      </div>`).join('');
    const periods = (r.months || []).filter(m => (m.items || []).length).slice().reverse().map(m => `
      <div style="border:1px solid var(--border-color, #374151); border-radius:6px; padding:8px 10px;">
        <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap;">
          <b>${this.escapeHtml(this._period(m))}</b> · <b>${FinesScreen.money(m.total)}</b>${this._postPill(m)}
          <span style="flex:1;"></span>
          <button type="button" class="fi-btn" data-fi-absolve="${r.person_id}" data-items="${items(m.items)}">${this.escapeHtml(this._w('absolve_period', `🕊 Absolve all of ${this._period(m)}`, { period: this._period(m) }))}</button>
        </div>
        ${m.items.map(it => `
          <div style="display:flex; align-items:center; gap:8px; padding:4px 0; border-top:1px dashed var(--border-color, #374151); margin-top:4px; font-size:0.85rem;">
            <span style="flex:1;">${this.escapeHtml(this._md(it.startAt))} ${this.escapeHtml(this._event(it))} — ${this.escapeHtml(it.label)}${it.dispute ? ` · ⚖️ ${this.escapeHtml(it.dispute)}` : ''}</span>
            <b>${FinesScreen.money(it.amount)}</b>
            <button type="button" class="fi-btn" data-fi-absolve="${r.person_id}" data-items="${items([it])}">${this.escapeHtml(this._w('absolve', '🕊 Absolve'))}</button>
          </div>`).join('')}
      </div>`).join('');
    const absolved = r.absolved.length ? `
      <div style="margin-top:4px;">
        <div style="opacity:0.6; font-size:0.72rem; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:4px;">${this.escapeHtml(this._w('absolved_title', '🕊 Absolved'))}</div>
        ${r.absolved.map(a => `
          <div style="display:flex; align-items:center; gap:8px; padding:4px 0; font-size:0.85rem; opacity:0.85;">
            <span style="flex:1;">${this.escapeHtml(this._md(a.startAt))} ${this.escapeHtml(this._event(a))} — ${this.escapeHtml(a.label)}
              <span style="opacity:0.7;">· ${this.escapeHtml(this._w('absolved_line', `let off — ${a.reason || ''}`, { reason: a.reason || '' }))}</span></span>
            <s>${FinesScreen.money(a.amount)}</s>
            <button type="button" class="fi-btn" data-fi-undo="${a.id}">${this.escapeHtml(this._w('undo', 'Undo'))}</button>
          </div>`).join('')}
      </div>` : '';
    const reason = (periods)
      ? `<input type="text" class="fi-reason" placeholder="${this.escapeHtml(this._w('absolve_prompt', 'Why let this go? (shows in the history)'))}"
               style="width:100%; padding:6px 10px; border-radius:6px; border:1px solid #475569; background:#0f172a; color:#fff; font-size:0.85rem;">`
      : '';
    const owed = r.owed > 0.005
      ? `<div style="font-weight:800; color:#fca5a5;">${this.escapeHtml(this._w('owes_hero', 'OWES'))} ${FinesScreen.money(r.owed)}</div>`
      : `<div style="font-weight:700; color:#86efac;">🟢 ${this.escapeHtml(this._w('clear_hero', 'Nothing owed'))}</div>`;
    return `<div style="display:flex; flex-direction:column; gap:8px;">${owed}${disputes}${reason}${periods}${absolved}</div>`;
  }

  async _absolve(btn) {
    const pid = Number(btn.dataset.fiAbsolve);
    const items = String(btn.dataset.items || '').split(',').filter(Boolean).map(s => {
      const i = s.indexOf(':');
      return { fh_event_id: Number(s.slice(0, i)), kind: s.slice(i + 1) };
    });
    if (!pid || !items.length) return;
    const box = btn.closest('.player-sheet') && btn.closest('.player-sheet').querySelector('.fi-reason');
    const reason = box ? box.value.trim() : '';
    btn.disabled = true;
    try {
      const res = await this.auth.fetch('/api/fines/absolve', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ person_id: pid, items, reason }) });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) { btn.disabled = false; alert(`Could not absolve: ${err.message}`); return; }
    this.load();
  }

  async _undo(id, btn) {
    btn.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/fines/absolve/${id}/undo`, { method: 'POST' });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) { btn.disabled = false; alert(`Could not undo: ${err.message}`); return; }
    this.load();
  }

  async _decide(id, decision) {
    try {
      const res = await this.auth.fetch(`/api/fines/disputes/${id}`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ decision }) });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) { alert(`Could not save: ${err.message}`); }
    this.load();
  }
}
