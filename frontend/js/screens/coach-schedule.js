// CoachScheduleScreen — #coach-schedule (mig 955 → mig 1634).
// The standing week of practice SESSIONS (weekday + local start, read off
// the calendar's repeating practices — a cancelled week is still the same
// session), who covers each, weekend duty (= the coach's teams' games), and
// cover asks.  Three pills:
//   📅 Week        — one real week (◀ ▶): every practice and game, who is on
//                    it, cancellations, cover asks.  🙋 asks for cover:
//                    pick coaches, then one 💬 text per coach — their own
//                    sign-in link landing on the event (mig 1640), opens
//                    Messages on iPhone and Android.
//   🕒 By session  — the standing week, coaches on each session.
//   👤 By coach    — each coach's sessions + weekend duty.
// Coaches and club admins open it; only admins change assignments (tap).
//
//   GET  /api/coach-schedule?week=YYYY-MM-DD | ?cover=<id>
//   POST /api/coach-schedule/session   { coach_id, isodow, starts_at, on }
//   POST /api/coach-schedule/plan      { coach_id, mode: every | call_in }
//   POST /api/coach-schedule/cover     { fh_event_id, coach_id, ask, note }
//   POST /api/coach-schedule/cover/<id>/take | withdraw | text (→ sms_href)
//
// Words: message_templates kind coach_schedule (migs 956, 1634).
class CoachScheduleScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.error = '';
    this.pill = 'week';
    this.week = null;          // 'YYYY-MM-DD' Monday, null = this week
    this.coverId = null;       // a cover link's id — opens that week once
    this.busy = new Set();
    this.ask = null;           // { fhEventId, coachId, picked:Set, coverId }
  }

  onEnter(params = {}) {
    this.error = '';
    this.coverId = params.coverId ? Number(params.coverId) : null;
    if (this.coverId) { this.pill = 'week'; this.week = null; }
    this.ask = null;
    this._load();
  }

  _t(tier, tokens, fallback) {
    return (window.MessageCopy && MessageCopy.block('coach_schedule', tier, tokens)) || fallback;
  }

  async _json(url, options = {}) {
    const res = await this.auth.fetch(url, options);
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  _post(url, body = {}) {
    return this._json(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  }

  async _load() {
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const q = this.coverId ? `?cover=${this.coverId}` : (this.week ? `?week=${this.week}` : '');
      this.data = await this._json(`/api/coach-schedule${q}`);
      this.week = this.data.week.start;
      this.coverId = null;
    } catch (err) {
      this.error = err.message;
    }
    this._renderBody();
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-coach-schedule';
    div.innerHTML = `<div id="cs-body" style="padding: var(--space-4); max-width: 820px;"></div>`;
    this.element = div;
    div.addEventListener('click', (e) => this._onClick(e));
    return div;
  }

  // ── helpers ────────────────────────────────────────────────────────────
  get _me() { return (this.data && this.data.me) || {}; }
  _coach(id) { return (this.data.coaches || []).find(c => c.coach_id === id); }
  _first(id) { const c = this._coach(id); return c ? (c.first || c.name) : '?'; }
  _key(isodow, start) { return `${isodow}|${start}`; }
  _day(d) { return this._t(`day_${d}`, {}, String(d)); }
  _time(hhmm) {
    const [h, m] = String(hhmm || '').split(':').map(Number);
    if (Number.isNaN(h)) return hhmm || '';
    return `${((h + 11) % 12) + 1}:${String(m).padStart(2, '0')}${h < 12 ? 'a' : 'p'}`;
  }
  // Is this coach expected at this standing session?
  _onSession(c, s) {
    if (!(s.team_ids || []).some(t => (c.team_ids || []).includes(t))) return null;   // not their teams
    if (!c.has_plan) return 'every';
    return c.sessions.some(x => x.isodow === s.isodow && x.starts_at === s.starts_at) ? 'on' : 'off';
  }
  _planText(c) {
    if (!c.has_plan) return this._t('every', {}, 'Every session');
    if (!c.sessions.length) return this._t('call_in', {}, 'Call in if needed');
    return c.sessions.map(x => `${this._day(x.isodow)} ${this._time(x.starts_at)}`).join(' · ');
  }
  _addDays(ymd, n) {
    const d = new Date(`${ymd}T12:00:00`);
    d.setDate(d.getDate() + n);
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }
  _dateLabel(ymd) {
    const d = new Date(`${ymd}T12:00:00`);
    return d.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
  }

  // ── clicks ─────────────────────────────────────────────────────────────
  _onClick(e) {
    const b = e.target.closest('[data-cs]');
    if (!b || !this.data) return;
    const a = b.dataset.cs;
    if (a === 'pill') { this.pill = b.dataset.v; this.ask = null; this._renderBody(); return; }
    if (a === 'week') { this.week = this._addDays(this.week, Number(b.dataset.v) * 7); this.ask = null; this._load(); return; }
    if (a === 'session') { this._toggleSession(Number(b.dataset.coach), Number(b.dataset.dow), b.dataset.start, b.dataset.on === '1'); return; }
    if (a === 'plan') { this._plan(Number(b.dataset.coach), b.dataset.v); return; }
    if (a === 'ask') {
      const ev = Number(b.dataset.ev), coach = Number(b.dataset.coach);
      this.ask = (this.ask && this.ask.fhEventId === ev && this.ask.coachId === coach) ? null
        : { fhEventId: ev, coachId: coach, picked: new Set(), coverId: null };
      this._renderBody();
      return;
    }
    if (a === 'pick' && this.ask) {
      const id = Number(b.dataset.coach);
      if (this.ask.picked.has(id)) this.ask.picked.delete(id); else this.ask.picked.add(id);
      this._renderBody();
      return;
    }
    if (a === 'ask-send') { this._sendAsk(); return; }
    if (a === 'take') { this._cover(Number(b.dataset.id), 'take'); return; }
    if (a === 'withdraw') { this._cover(Number(b.dataset.id), 'withdraw'); return; }
    if (a === 'text') { this._text(Number(b.dataset.id), Number(b.dataset.coach)); }
  }

  async _run(key, fn) {
    if (this.busy.has(key)) return;
    this.busy.add(key);
    this.error = '';
    this._renderBody();
    try { await fn(); } catch (err) { this.error = err.message; }
    this.busy.delete(key);
    this._renderBody();
  }

  _toggleSession(coachId, isodow, start, on) {
    return this._run(`s:${coachId}`, async () => {
      const r = await this._post('/api/coach-schedule/session', { coach_id: coachId, isodow, starts_at: start, on });
      Object.assign(this._coach(coachId), r);
    });
  }

  _plan(coachId, mode) {
    return this._run(`s:${coachId}`, async () => {
      const r = await this._post('/api/coach-schedule/plan', { coach_id: coachId, mode });
      Object.assign(this._coach(coachId), r);
    });
  }

  _sendAsk() {
    const ask = this.ask;
    if (!ask || !ask.picked.size) return;
    return this._run('ask', async () => {
      const r = await this._post('/api/coach-schedule/cover', { fh_event_id: ask.fhEventId, coach_id: ask.coachId, ask: [...ask.picked] });
      ask.coverId = r.id;
      await this._load();   // the ask now shows on the event with a 💬 per coach
      this.ask = null;
    });
  }

  _cover(id, action) {
    return this._run(`c:${id}`, async () => {
      await this._post(`/api/coach-schedule/cover/${id}/${action}`);
      await this._load();
    });
  }

  // One 💬 per asked coach.  The text is built server-side with THEIR own
  // sign-in link (minted like every player / parent reminder, mig 1640),
  // landing on the event; the sms: href opens Messages on iPhone + Android.
  _textLink(cover, ev, coachId) {
    const c = this._coach(coachId);
    if (!c) return '';
    if (!c.phone) return `<span style="font-size:0.72rem; opacity:0.7;">${this.escapeHtml(this._t('ask_no_phone', { first: c.first || c.name }, `${c.first}: no phone`))}</span>`;
    return `<button type="button" data-cs="text" data-id="${cover.id}" data-coach="${c.coach_id}"
      style="padding:6px 10px; border-radius:8px; border:none; background:#1d4ed8; color:#fff; font-size:0.74rem; font-weight:800; cursor:pointer;">${this.escapeHtml(this._t('ask_text', { first: c.first || c.name }, `💬 Text ${c.first}`))}${this.busy.has(`t:${cover.id}:${c.coach_id}`) ? ' …' : ''}</button>`;
  }

  async _text(coverId, coachId) {
    const key = `t:${coverId}:${coachId}`;
    if (this.busy.has(key)) return;
    this.busy.add(key);
    this.error = '';
    this._renderBody();
    try {
      const r = await this._post(`/api/coach-schedule/cover/${coverId}/text`, { coach_id: coachId });
      if (!r.sms_href) throw new Error('No text came back');
      if (window.DesktopSms && DesktopSms.isDesktop && DesktopSms.isDesktop()) DesktopSms.open(r.sms_href);
      else window.location.href = r.sms_href;
    } catch (err) {
      this.error = err.message;
    }
    this.busy.delete(key);
    this._renderBody();
  }

  // ── render ─────────────────────────────────────────────────────────────
  _renderBody() {
    const body = this.find('#cs-body');
    if (!body) return;
    if (!this.data) { body.innerHTML = this.error ? `<p style="color:#f87171;">${this.escapeHtml(this.error)}</p>` : '<p>Loading…</p>'; return; }
    const pill = (v, tier, fb) => `<button type="button" data-cs="pill" data-v="${v}" style="padding:8px 14px; border-radius:999px; font-weight:800; font-size:0.8rem; cursor:pointer;
      border:1px solid ${this.pill === v ? '#fbbf24' : 'rgba(255,255,255,0.2)'}; background:${this.pill === v ? '#fbbf24' : 'transparent'}; color:${this.pill === v ? '#111827' : '#e5e7eb'};">${this.escapeHtml(this._t(tier, {}, fb))}</button>`;
    const view = this.pill === 'session' ? this._sessionView() : this.pill === 'coach' ? this._coachView() : this._weekView();
    body.innerHTML = `
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:12px;">
        ${pill('week', 'pill_week', '📅 Week')}${pill('session', 'pill_session', '🕒 By session')}${pill('coach', 'pill_coach', '👤 By coach')}
      </div>
      ${this.error ? `<p style="color:#f87171;">${this.escapeHtml(this.error)}</p>` : ''}
      ${view}`;
  }

  _chip(text, { on = true, mine = false, dim = false, attrs = '' } = {}) {
    const bg = on ? (dim ? 'rgba(34,197,94,0.25)' : '#15803d') : 'transparent';
    const tag = attrs ? 'button type="button"' : 'span';
    return `<${tag} ${attrs} style="display:inline-block; padding:5px 9px; border-radius:8px; font-size:0.74rem; font-weight:700; ${attrs ? 'cursor:pointer;' : ''}
      border:1px solid ${mine ? '#fbbf24' : on ? '#22c55e' : 'rgba(255,255,255,0.2)'}; background:${bg}; color:${on ? '#fff' : '#94a3b8'};">${this.escapeHtml(text)}</${tag.split(' ')[0]}>`;
  }

  _card(inner, extra = '') {
    return `<div style="padding:10px 12px; margin-bottom:8px; border:1px solid rgba(255,255,255,0.1); border-radius:10px; background:rgba(15,23,42,0.45); ${extra}">${inner}</div>`;
  }

  // 📅 one real week
  _weekView() {
    const me = this._me;
    const ws = this.week;
    const nav = `<div style="display:flex; align-items:center; gap:8px; margin-bottom:6px;">
      <button type="button" data-cs="week" data-v="-1" style="padding:6px 12px; border-radius:8px; border:1px solid rgba(255,255,255,0.2); background:transparent; color:#e5e7eb; font-weight:800; cursor:pointer;">◀</button>
      <b style="flex:1; text-align:center;">${this.escapeHtml(this._t('week_of', { date: this._dateLabel(ws) }, `Week of ${this._dateLabel(ws)}`))}</b>
      <button type="button" data-cs="week" data-v="1" style="padding:6px 12px; border-radius:8px; border:1px solid rgba(255,255,255,0.2); background:transparent; color:#e5e7eb; font-weight:800; cursor:pointer;">▶</button></div>
      <p style="font-size:0.8rem; opacity:0.8; margin:0 0 10px;">${this.escapeHtml(this._t('week_hint', {}, 'Who is on each practice and game this week.'))}</p>`;
    const events = this.data.week.events || [];
    let out = nav, day = '';
    for (const ev of events) {
      if (ev.day !== day) { day = ev.day; out += `<h2 style="font-size:1rem; margin:14px 0 6px;">${this.escapeHtml(this._dateLabel(day))}</h2>`; }
      out += this._eventCard(ev, me);
    }
    if (!events.length) out += '<p style="opacity:0.7;">—</p>';
    return out;
  }

  _eventCard(ev, me) {
    const live = !ev.cancelled && !ev.past;
    const covers = ev.covers || [];
    const liveCover = (cid) => covers.find(c => c.coach_id === cid);
    const chips = (ev.coach_ids || []).map(cid => {
      const mine = cid === me.coach_id;
      const canAsk = live && (mine || me.is_admin) && !liveCover(cid);
      const covering = covers.find(c => c.status === 'covered' && c.cover_coach_id === cid);
      const label = `${this._first(cid)}${covering ? ' 🔁' : ''}${canAsk ? ` · ${this._t('ask_cover', {}, '🙋 Cover')}` : ''}`;
      return this._chip(label, { mine, attrs: canAsk ? `data-cs="ask" data-ev="${ev.fh_event_id}" data-coach="${cid}"` : '' });
    }).join(' ');
    const none = !ev.cancelled && !(ev.coach_ids || []).length
      ? `<span style="color:#f87171; font-weight:800; font-size:0.78rem;">⚠ ${this.escapeHtml(this._t('no_coach', {}, 'No coach'))}</span>` : '';
    const coverRows = covers.map(cv => this._coverRow(cv, ev, me, live)).join('');
    const ask = this.ask && this.ask.fhEventId === ev.fh_event_id ? this._askSheet(ev) : '';
    const kind = ev.kind === 'match' ? '⚽' : '🏃';
    return this._card(`
      <div style="display:flex; justify-content:space-between; gap:8px; flex-wrap:wrap; ${ev.cancelled ? 'text-decoration:line-through; opacity:0.55;' : ''}">
        <b>${kind} ${this.escapeHtml(this._time(ev.starts_at))}–${this.escapeHtml(this._time(ev.ends_at))} ${this.escapeHtml(ev.label || '')}</b>
        ${ev.cancelled ? `<span style="color:#f87171; font-weight:800; font-size:0.78rem;">${this.escapeHtml(this._t('cancelled', {}, 'Cancelled'))}</span>` : ''}
      </div>
      <div style="font-size:0.74rem; opacity:0.7; margin:2px 0 6px;">${this.escapeHtml(ev.teams || '')}</div>
      ${ev.cancelled ? '' : `<div style="display:flex; gap:4px; flex-wrap:wrap; align-items:center;">${chips} ${none}</div>`}
      ${coverRows}${ask}`, ev.past ? 'opacity:0.7;' : '');
  }

  _coverRow(cv, ev, me, live) {
    const asker = this._first(cv.coach_id);
    const mineAsk = cv.coach_id === me.coach_id || me.is_admin;
    const btn = (a, tier, fb, bg) => `<button type="button" data-cs="${a}" data-id="${cv.id}" style="padding:6px 10px; border-radius:8px; border:none; background:${bg}; color:#fff; font-size:0.74rem; font-weight:800; cursor:pointer;">${this.escapeHtml(this._t(tier, {}, fb))}</button>`;
    let line, actions = '';
    if (cv.status === 'covered') {
      line = this._t('covered_by', { cover: this._first(cv.cover_coach_id), coach: asker }, `🔁 ${this._first(cv.cover_coach_id)} for ${asker}`);
      if (live && mineAsk) actions = btn('withdraw', 'withdraw', 'Cancel ask', '#475569');
    } else {
      line = this._t('needs_cover', { coach: asker }, `🆘 ${asker} needs cover`);
      if (live && me.coach_id && me.coach_id !== cv.coach_id) actions += btn('take', 'take_cover', "✋ I'll cover", '#15803d');
      if (live && mineAsk) {
        actions += (cv.asked || []).map(cid => this._textLink(cv, ev, cid)).join(' ');
        actions += ' ' + btn('withdraw', 'withdraw', 'Cancel ask', '#475569');
      }
    }
    return `<div style="margin-top:8px; padding:8px; border-radius:8px; background:${cv.status === 'covered' ? 'rgba(34,197,94,0.12)' : 'rgba(248,113,113,0.12)'};">
      <div style="font-size:0.8rem; font-weight:800; margin-bottom:${actions ? '6px' : '0'};">${this.escapeHtml(line)}</div>
      <div style="display:flex; gap:6px; flex-wrap:wrap; align-items:center;">${actions}</div></div>`;
  }

  _askSheet(ev) {
    const ask = this.ask;
    const others = (this.data.coaches || []).filter(c => c.coach_id !== ask.coachId);
    const picks = others.map(c => this._chip(c.name, { on: ask.picked.has(c.coach_id), attrs: `data-cs="pick" data-coach="${c.coach_id}"` })).join(' ');
    const title = this._t('ask_title', { coach: this._first(ask.coachId), event: `${ev.label || ''} ${this._time(ev.starts_at)}` }, `Who could cover ${this._first(ask.coachId)}?`);
    return `<div style="margin-top:8px; padding:10px; border-radius:8px; border:1px solid #fbbf24;">
      <div style="font-size:0.8rem; font-weight:800; margin-bottom:6px;">${this.escapeHtml(title)}</div>
      <div style="display:flex; gap:4px; flex-wrap:wrap; margin-bottom:8px;">${picks}</div>
      <button type="button" data-cs="ask-send" ${ask.picked.size ? '' : 'disabled'} style="padding:8px 14px; border-radius:8px; border:none; background:${ask.picked.size ? '#fbbf24' : '#475569'}; color:#111827; font-weight:800; cursor:pointer;">${this.escapeHtml(this._t('ask_send', {}, 'Ask them'))}${this.busy.has('ask') ? ' …' : ''}</button></div>`;
  }

  // 🕒 the standing week
  _sessionView() {
    const me = this._me;
    let out = `<p style="font-size:0.8rem; opacity:0.8; margin:0 0 10px;">${this.escapeHtml(this._t('session_hint', {}, 'The standing week, off the calendar.'))}</p>`;
    let dow = 0;
    for (const s of this.data.sessions || []) {
      if (s.isodow !== dow) { dow = s.isodow; out += `<h2 style="font-size:1rem; margin:14px 0 6px;">${this.escapeHtml(this._day(dow))}</h2>`; }
      const chips = (this.data.coaches || []).map(c => {
        const st = this._onSession(c, s);
        if (!st || (st === 'off' && !me.is_admin)) return '';
        const attrs = me.is_admin ? `data-cs="session" data-coach="${c.coach_id}" data-dow="${s.isodow}" data-start="${s.starts_at}" data-on="${st === 'off' ? 1 : 0}"` : '';
        return this._chip(`${c.first || c.name}${st === 'every' ? ' ∞' : ''}`, { on: st !== 'off', dim: st === 'every', mine: c.coach_id === me.coach_id, attrs });
      }).join(' ');
      out += this._card(`
        <b>${this.escapeHtml(this._time(s.starts_at))}–${this.escapeHtml(this._time(s.ends_at))} ${this.escapeHtml(s.label || '')}</b>
        <div style="font-size:0.74rem; opacity:0.7; margin:2px 0 6px;">${this.escapeHtml(s.teams || '')}</div>
        <div style="display:flex; gap:4px; flex-wrap:wrap;">${chips || `<span style="color:#f87171; font-weight:800; font-size:0.78rem;">⚠ ${this.escapeHtml(this._t('no_coach', {}, 'No coach'))}</span>`}</div>`);
    }
    return out;
  }

  // 👤 each coach — me first
  _coachView() {
    const me = this._me;
    const sessions = this.data.sessions || [];
    const coaches = [...(this.data.coaches || [])].sort((a, b) => (b.coach_id === me.coach_id) - (a.coach_id === me.coach_id));
    const quick = 'padding:6px 10px; border-radius:8px; border:1px solid rgba(255,255,255,0.2); background:transparent; color:#dbeafe; font-size:0.72rem; font-weight:700; cursor:pointer;';
    let out = `<p style="font-size:0.8rem; opacity:0.8; margin:0 0 10px;">${this.escapeHtml(this._t('coach_hint', {}, 'Tap a session to add or drop it.'))}</p>
      <p style="font-size:0.74rem; opacity:0.7; margin:0 0 10px;">${this.escapeHtml(this._t('call_in_hint', {}, ''))}</p>`;
    for (const c of coaches) {
      const mine = sessions.filter(s => this._onSession(c, s));
      const pills = mine.map(s => {
        const st = this._onSession(c, s);
        const attrs = me.is_admin ? `data-cs="session" data-coach="${c.coach_id}" data-dow="${s.isodow}" data-start="${s.starts_at}" data-on="${st === 'off' ? 1 : 0}"` : '';
        if (!me.is_admin && st === 'off') return '';
        return this._chip(`${this._day(s.isodow)} ${this._time(s.starts_at)}`, { on: st !== 'off', dim: st === 'every', attrs });
      }).join(' ');
      // plan sessions the calendar no longer has
      const gone = c.has_plan ? c.sessions.filter(x => !sessions.some(s => s.isodow === x.isodow && s.starts_at === x.starts_at)) : [];
      const goneTxt = gone.length ? `<div style="font-size:0.72rem; color:#fca5a5; margin-top:4px;">${this.escapeHtml(gone.map(x => `${this._day(x.isodow)} ${this._time(x.starts_at)}`).join(', '))} — ${this.escapeHtml(this._t('session_gone', {}, 'not on the calendar now'))}</div>` : '';
      const duty = c.game_teams ? `<div style="font-size:0.76rem; color:#93c5fd; margin-top:6px;">⚽ ${this.escapeHtml(this._t('weekend_duty', { teams: c.game_teams }, `Weekend: ${c.game_teams} games`))}</div>` : '';
      const admin = me.is_admin ? `<div style="display:flex; gap:4px; margin-top:8px;">
          <button type="button" data-cs="plan" data-coach="${c.coach_id}" data-v="every" style="${quick}">${this.escapeHtml(this._t('every', {}, 'Every session'))}</button>
          <button type="button" data-cs="plan" data-coach="${c.coach_id}" data-v="call_in" style="${quick}">${this.escapeHtml(this._t('call_in', {}, 'Call in if needed'))}</button></div>` : '';
      out += this._card(`
        <div style="display:flex; justify-content:space-between; gap:8px; flex-wrap:wrap; margin-bottom:6px;">
          <b>${this.escapeHtml(c.name)}${c.coach_id === me.coach_id ? ' ⭐' : ''}</b>
          <span style="font-size:0.78rem; color:#fcd34d; font-weight:700;">${this.escapeHtml(this._planText(c))}${this.busy.has(`s:${c.coach_id}`) ? ' …' : ''}</span>
        </div>
        <div style="display:flex; gap:4px; flex-wrap:wrap;">${pills}</div>${goneTxt}${duty}${admin}`,
        c.coach_id === me.coach_id ? 'border-color:#fbbf24;' : '');
    }
    return out;
  }
}

window.CoachScheduleScreen = CoachScheduleScreen;
