// AttendanceCallsScreen — #attendance-calls (mig 1290; owner 2026-11-11:
// "so where on fh can i see attendance calls that went out" → "build a page
// to see all attendance calls").
//
// Every practice that had an attendance-call round (AttendanceCallScheduler,
// mig 1277), newest first, rolled up like every page (one fold per
// practice): the summary carries the day, the practice, live/test, rounds,
// calls answered by Twilio, texts and who is still unmarked; open it for
// each round — when, how many were unmarked, every coach rung or texted
// and whether it went through.  Window pills (7 / 30 / 90 days) and
// section pills; the strip on top says per section whether calls are live.
//
//   GET /api/attendance-calls/log?days=   (AttendanceCallController)
//
// Words: message_templates kind 'attendance_calls_page' (mig 1290).
class AttendanceCallsScreen extends Screen {
  static get WINDOWS() { return [7, 30, 90]; }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.days = 7;
    this.section = 'all';
    this.open = new Set();   // practice ids whose fold is open (kept across reloads)
    this.error = null;
  }

  _c(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('attendance_calls_page', tier))
      ? MessageCopy.block('attendance_calls_page', tier, tokens || {}) : fb;
  }
  _sectionLabel(code) {
    const map = (window.RsvpBoardScreen && RsvpBoardScreen.SECTIONS) || { mens: 'Men', womens: 'Women', boys: 'Boys', girls: 'Girls' };
    return map[code] || code || '';
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ac-pill { padding:4px 12px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.8rem; min-height:0; min-width:0;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .ac-pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .ac-card { border:1px solid var(--border-color); border-radius:var(--radius-md); background:var(--bg-secondary); padding:8px 12px; margin-bottom:8px; }
        .ac-card > summary { cursor:pointer; display:flex; flex-wrap:wrap; align-items:center; gap:6px; }
        .ac-chip { font-size:0.72rem; font-weight:700; padding:1px 8px; border-radius:999px; background:rgba(148,163,184,0.18); white-space:nowrap; }
        .ac-round { border-top:1px solid var(--border-color); padding:6px 0; }
        .ac-person { display:flex; gap:8px; align-items:center; font-size:0.84rem; padding:2px 0 2px 10px; flex-wrap:wrap; }
      </style>
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ac-title">📞 Attendance Calls</h1>
        <p class="subtitle" id="ac-sub"></p>
      </div>
      <div id="ac-body" style="padding: var(--space-4); max-width: 900px; margin: 0 auto;"></div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter() {
    this.error = null;
    this._render();
    if (window.MessageCopy) MessageCopy.load(this.auth).then(() => this._render()).catch(() => {});
    this._load();
  }

  async _load() {
    try {
      const res = await this.auth.fetch(`/api/attendance-calls/log?days=${this.days}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
      this.error = null;
    } catch (err) {
      console.error('[attendance-calls] load failed:', err);
      this.error = err.message;
    }
    this._render();
  }

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const d = e.target.closest('[data-ac-days]');
      if (d) { this.days = Number(d.dataset.acDays); this.data = null; this._render(); this._load(); return; }
      const s = e.target.closest('[data-ac-section]');
      if (s) { this.section = s.dataset.acSection; this._render(); return; }
      const o = e.target.closest('[data-ac-open]');
      if (o && window.EventKindSwitch) { e.preventDefault(); EventKindSwitch.openById(this.navigation, this.auth, Number(o.dataset.acOpen), 'players'); }
    });
    // A practice fold stays as the viewer left it (toggle does not bubble).
    this.element.addEventListener('toggle', (e) => {
      const id = e.target.dataset && e.target.dataset.acFold;
      if (!id) return;
      if (e.target.open) this.open.add(id); else this.open.delete(id);
    }, true);
  }

  _render() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const title = this.find('#ac-title'); if (title) title.textContent = this._c('title', {}, '📞 Attendance Calls');
    const sub = this.find('#ac-sub'); if (sub) sub.textContent = this._c('subtitle', {}, '');
    const body = this.find('#ac-body');
    if (!body) return;
    const pills = `
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:8px;">
        ${AttendanceCallsScreen.WINDOWS.map(n => `<button type="button" class="ac-pill ${n === this.days ? 'on' : ''}" data-ac-days="${n}">${esc(this._c('days_pill', { n }, `Last ${n} days`))}</button>`).join('')}
      </div>`;
    if (this.error) { body.innerHTML = pills + `<div style="color:#f87171;">${esc(this.error)}</div>`; return; }
    if (!this.data) { body.innerHTML = pills + `<div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>`; return; }

    const d = this.data;
    const events = d.events || [];
    const sections = [...new Set([...(d.policies || []).map(p => p.category), ...events.map(e => e.category)])];
    const sectionPills = `
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:10px;">
        ${['all', ...sections].map(code => {
          const n = code === 'all' ? events.length : events.filter(e => e.category === code).length;
          const label = code === 'all' ? this._c('section_all', {}, 'All') : this._sectionLabel(code);
          return `<button type="button" class="ac-pill ${code === this.section ? 'on' : ''}" data-ac-section="${esc(code)}">${esc(label)} (${n})</button>`;
        }).join('')}
      </div>`;
    const policyLine = (p) => {
      const section = this._sectionLabel(p.category);
      if (!p.is_on) return this._c('policy_off', { section }, `${section}: off`);
      if (p.live) return this._c('policy_live', { section }, `${section}: live`);
      return p.test_name ? this._c('policy_test', { section, who: p.test_name }, `${section}: test`)
                         : this._c('policy_nobody', { section }, `${section}: test — nobody is rung`);
    };
    const policies = `<div style="font-size:0.78rem; opacity:0.8; margin-bottom:12px; display:flex; flex-direction:column; gap:2px;">
        ${(d.policies || []).map(p => `<span>${esc(policyLine(p))}</span>`).join('')}
      </div>`;

    const shown = this.section === 'all' ? events : events.filter(e => e.category === this.section);
    const chip = (text, style = '') => `<span class="ac-chip" style="${style}">${esc(text)}</span>`;
    const card = (e) => {
      const unmarked = Number(e.unmarked_now) || 0;
      const head = `
        <span style="font-weight:800;">${esc(e.day)}</span>
        <span style="opacity:0.8;">${esc(e.time)}</span>
        <span style="font-weight:700; flex:1 1 200px; min-width:0;">${esc(e.title || '')} <span style="font-weight:400; opacity:0.65;">· ${esc(this._sectionLabel(e.category))}</span></span>
        ${chip(e.live ? this._c('live', {}, 'LIVE') : this._c('test', {}, '🧪 TEST'), e.live ? 'background:rgba(34,197,94,0.2); color:#4ade80;' : 'background:rgba(251,191,36,0.2); color:#fbbf24;')}
        ${chip(this._c('rounds', { n: e.rounds_n }, `${e.rounds_n} rounds`))}
        ${chip(this._c('calls', { ok: e.calls_ok, tried: e.calls_tried }, `📞 ${e.calls_ok}/${e.calls_tried}`), e.calls_ok < e.calls_tried ? 'color:#f87171;' : '')}
        ${e.texts ? chip(this._c('texts', { n: e.texts }, `💬 ${e.texts}`)) : ''}
        ${unmarked ? chip(this._c('unmarked_now', { n: unmarked }, `${unmarked} still unmarked`), 'background:rgba(239,68,68,0.18); color:#f87171;')
                   : chip(this._c('all_marked', {}, '✅ all marked'), 'background:rgba(34,197,94,0.18); color:#4ade80;')}`;
      const rounds = (e.rounds || []).map(r => `
        <div class="ac-round">
          <div style="font-size:0.8rem; font-weight:700; display:flex; gap:6px; align-items:center; flex-wrap:wrap;">
            ${esc(this._c('round', { round: r.round, at: r.at, n: r.unmarked }, `Round ${r.round} · ${r.at} · ${r.unmarked} unmarked`))}
            ${r.live ? '' : chip(this._c('test', {}, '🧪 TEST'), 'color:#fbbf24;')}
          </div>
          ${(r.people || []).map(p => `
            <div class="ac-person">
              <span style="min-width:150px; font-weight:600;">${esc(p.name)}</span>
              <span style="opacity:0.8;">${esc(p.channel === 'sms' ? this._c('sms', {}, '💬 text') : this._c('call', {}, '📞 call'))}</span>
              ${p.ok ? '<span style="color:#4ade80; font-weight:800;">✓</span>'
                     : `<span style="color:#f87171; font-weight:700;">${esc(this._c('failed', { error: p.error || '' }, `✗ failed ${p.error || ''}`))}</span>`}
            </div>`).join('')}
        </div>`).join('');
      const id = String(e.id);
      return `<details class="ac-card" data-ac-fold="${id}" ${this.open.has(id) ? 'open' : ''}>
          <summary>${head}</summary>
          <div style="margin-top:6px;">${rounds}
            <div style="text-align:right; margin-top:6px;"><button type="button" class="btn btn-secondary" data-ac-open="${id}" style="padding:3px 10px; font-size:0.78rem;">${esc(this._c('open_event', {}, 'Open practice ›'))}</button></div>
          </div>
        </details>`;
    };
    body.innerHTML = pills + sectionPills + policies
      + (shown.length ? shown.map(card).join('') : `<div style="opacity:0.7; padding:var(--space-4); text-align:center;">${esc(this._c('empty', {}, 'No attendance calls in this window.'))}</div>`);
  }
}

window.AttendanceCallsScreen = AttendanceCallsScreen;
