// LockupsScreen — #lockups — the nightly "was the gate locked?" board
// (owner 2026-09-24: "so we didn't lock up Lighthouse after practice …
// can we have a system where if we don't tell fh that lighthouse is
// secure that it sends a text and email to me?").
//
// Backed by GET /api/lockups/board, POST /api/lockups/:id/confirm and
// POST /api/lockups/test (backend/src/controllers/LockupController.cpp,
// migration 421).  The backend scheduler does the chasing; this page is
// where staff see tonight's status, press "I locked it" without a link,
// read what was sent to whom, and (admins) fire a test to themselves.
//
// Top-level page, not a panel on #my (owner 2026-09-17: staff tools get
// dedicated pages).  Club admins, active coaches and anyone on the
// facility's lock-up list can open it.
class LockupsScreen extends Screen {
  static STATUS = {
    none:    { label: 'No events tonight',        cls: 'lk-none' },
    pending: { label: 'Not due yet',              cls: 'lk-pending' },
    due:     { label: 'Waiting for confirmation', cls: 'lk-due' },
    overdue: { label: 'NOT CONFIRMED — alerting', cls: 'lk-overdue' },
    locked:  { label: 'Locked',                   cls: 'lk-locked' },
  };
  static CHANNEL = { email: '✉️ email', sms: '💬 text', call: '📞 call' };
  static STAGE   = { prompt: 'asked to confirm', alert: 'alert', confirmed: 'all clear', test: 'test' };

  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.loading = false;
    this.error = null;
    this.busy = false;
    this.flash = '';
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .lk-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary);
                   padding:14px 16px; margin-bottom:var(--space-3); border-left:6px solid var(--border-color); }
        .lk-card.lk-locked  { border-left-color:#4ade80; }
        .lk-card.lk-due     { border-left-color:#facc15; }
        .lk-card.lk-overdue { border-left-color:#f87171; }
        .lk-card.lk-pending { border-left-color:#38bdf8; }
        .lk-title { display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap; }
        .lk-title h2 { margin:0; font-size:1.15rem; }
        .lk-pill { display:inline-block; padding:3px 10px; border-radius:999px; font-size:0.75rem; font-weight:800; }
        .lk-locked  .lk-pill { background:rgba(74,222,128,0.18); color:#4ade80; }
        .lk-due     .lk-pill { background:rgba(250,204,21,0.18); color:#facc15; }
        .lk-overdue .lk-pill { background:rgba(248,113,113,0.2); color:#f87171; }
        .lk-pending .lk-pill { background:rgba(56,189,248,0.18); color:#38bdf8; }
        .lk-none    .lk-pill { opacity:0.5; border:1px solid var(--border-color); }
        .lk-row { display:flex; justify-content:space-between; gap:12px; font-size:0.85rem; padding:3px 0; }
        .lk-row .k { opacity:0.6; white-space:nowrap; }
        .lk-row .v { text-align:right; }
        .lk-btn { padding:10px 18px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:1rem;
                  color:#0b1c3d; background:#4ade80; margin-top:10px; }
        .lk-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .lk-btn.sm { padding:5px 10px; font-size:0.78rem; margin:0; background:var(--primary-color); color:#fff; }
        .lk-log { font-size:0.75rem; margin-top:8px; border-top:1px solid var(--border-color); padding-top:6px; }
        .lk-log div { display:flex; gap:8px; padding:2px 0; }
        .lk-log .ok { color:#4ade80; } .lk-log .bad { color:#f87171; }
        .lk-hist { display:grid; grid-template-columns:repeat(auto-fill, minmax(240px, 1fr)); gap:var(--space-2); }
        .lk-hist .lk-card { margin:0; padding:10px 12px; }
        .lk-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase;
                  letter-spacing:0.05em; opacity:0.6; }
        .lk-people { font-size:0.85rem; }
        .lk-flash { padding:8px 12px; border-radius:8px; background:rgba(74,222,128,0.15); margin-bottom:var(--space-2); font-size:0.85rem; }
        .lk-flash.bad { background:rgba(248,113,113,0.15); }
        .lk-note { width:100%; box-sizing:border-box; margin-top:8px; padding:8px; border-radius:8px;
                   border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🔒 Lock-up</h1>
        <p class="subtitle">Did we lock the gate? Confirm here or from the link in the text/email — otherwise Football Home chases the club after the deadline</p>
      </div>
      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <div style="display:flex; justify-content:flex-end; margin-bottom:var(--space-2);">
          <button id="lk-refresh" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
        </div>
        <div id="lk-body"></div>
      </div>
    `;
    this.element = div;
    this._wireEvents();
    return div;
  }

  onEnter() { this.load(); }

  _wireEvents() {
    this.element.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      if (e.target.closest('#lk-refresh')) { this.load(); return; }
      const confirmBtn = e.target.closest('[data-confirm]');
      if (confirmBtn) { await this.confirm(Number(confirmBtn.dataset.confirm)); return; }
      const testBtn = e.target.closest('[data-test]');
      if (testBtn) { await this.test(testBtn.dataset.test); return; }
    });
  }

  async load() {
    this.loading = true; this.error = null;
    this._renderBody();
    try {
      const res = await this.auth.fetch('/api/lockups/board');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
    } catch (err) {
      this.data = null;
      this.error = err.message || 'Failed to load.';
    }
    this.loading = false;
    this._renderBody();
  }

  async confirm(id) {
    if (this.busy || !id) return;
    this.busy = true;
    const noteEl = this.find(`#lk-note-${id}`);
    try {
      const res = await this.auth.fetch(`/api/lockups/${id}/confirm`, {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ note: noteEl ? noteEl.value.trim() : '' }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.flash = body.already ? 'Already confirmed.' : 'Marked locked. Thanks!';
    } catch (err) {
      this.flash = `✗ ${err.message || 'Could not confirm.'}`;
    }
    this.busy = false;
    await this.load();
  }

  async test(channel) {
    if (this.busy) return;
    this.busy = true;
    this.flash = `Sending a test ${LockupsScreen.CHANNEL[channel] || channel}…`;
    this._renderBody();
    try {
      const res = await this.auth.fetch('/api/lockups/test', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channel }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.flash = body.ok ? `Test ${LockupsScreen.CHANNEL[channel]} sent to ${body.contact}.`
                           : `✗ Test ${LockupsScreen.CHANNEL[channel]} failed: ${body.error || 'unknown error'}`;
    } catch (err) {
      this.flash = `✗ ${err.message || 'Test failed.'}`;
    }
    this.busy = false;
    await this.load();
  }

  _fmtWhen(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (Number.isNaN(d.getTime())) return iso;
    return new Intl.DateTimeFormat('en-US', { timeZone: 'America/New_York', month: 'short', day: 'numeric',
                                              hour: 'numeric', minute: '2-digit' }).format(d);
  }

  _log(alerts) {
    if (!alerts || !alerts.length) return '';
    const rows = alerts.map(a => `
      <div>
        <span style="opacity:0.6; white-space:nowrap;">${this.escapeHtml(this._fmtWhen(a.sent_at))}</span>
        <span>${this.escapeHtml(LockupsScreen.STAGE[a.stage] || a.stage)} · ${this.escapeHtml(LockupsScreen.CHANNEL[a.channel] || a.channel)}
              → ${this.escapeHtml(a.person || a.contact)}</span>
        <span class="${a.ok ? 'ok' : 'bad'}">${a.ok ? '✓' : '✗ ' + this.escapeHtml(a.error || 'failed')}</span>
      </div>`).join('');
    return `<div class="lk-log">${rows}</div>`;
  }

  _card(l, { big }) {
    const st = LockupsScreen.STATUS[l.status] || LockupsScreen.STATUS.none;
    const rows = [];
    if (l.last_event) rows.push(['Last event', l.last_event]);
    if (l.status !== 'none') rows.push(['Confirm by', l.deadline_label]);
    if (l.status === 'locked') {
      rows.push(['Locked by', `${l.confirmed_by || '—'} at ${l.confirmed_label}${l.confirmed_via === 'tap' ? ' (tap link)' : ''}`]);
      if (l.note) rows.push(['Note', l.note]);
    }
    if (l.alert_count > 0) rows.push(['Alerts sent', `${l.alert_count} of ${l.max_alerts}`]);
    const canConfirm = big && l.id > 0 && l.status !== 'none' && l.status !== 'locked';
    return `
      <div class="lk-card ${st.cls}">
        <div class="lk-title">
          <h2>${this.escapeHtml(l.short_name || l.facility)} · ${this.escapeHtml(l.date_label)}</h2>
          <span class="lk-pill">${this.escapeHtml(st.label)}</span>
        </div>
        ${rows.map(([k, v]) => `<div class="lk-row"><span class="k">${this.escapeHtml(k)}</span><span class="v">${this.escapeHtml(v)}</span></div>`).join('')}
        ${canConfirm ? `
          <input id="lk-note-${l.id}" class="lk-note" type="text" maxlength="200" placeholder="Note (optional) — e.g. locked at 8:40, chain + padlock">
          <button class="lk-btn" data-confirm="${l.id}" ${this.busy ? 'disabled' : ''}>🔒 I locked it</button>` : ''}
        ${this._log(l.alerts)}
      </div>`;
  }

  _renderBody() {
    const el = this.find('#lk-body');
    if (!el) return;
    if (this.loading && !this.data) { el.innerHTML = '<p style="opacity:0.6;">Loading…</p>'; return; }
    if (this.error) { el.innerHTML = `<div class="lk-flash bad">${this.escapeHtml(this.error)}</div>`; return; }
    const d = this.data || { today: [], history: [], people: [] };
    const flash = this.flash ? `<div class="lk-flash ${this.flash.startsWith('✗') ? 'bad' : ''}">${this.escapeHtml(this.flash)}</div>` : '';
    const today = d.today.length ? d.today.map(l => this._card(l, { big: true })).join('')
                                 : '<p style="opacity:0.6;">No facility needs a lock-up check-in.</p>';
    const hist = d.history.length
      ? `<div class="lk-hist">${d.history.map(l => this._card(l, { big: false })).join('')}</div>`
      : '<p style="opacity:0.6;">No earlier nights yet.</p>';
    const byFac = {};
    for (const p of d.people) (byFac[p.facility] ||= { rows: [], p }).rows.push(p);
    const people = Object.entries(byFac).map(([fac, { rows, p }]) => `
      <div class="lk-card lk-people" style="border-left-color:var(--border-color);">
        <strong>${this.escapeHtml(fac)}</strong> — deadline ${p.grace_minutes} min after the last event ends;
        then alerts every ${p.repeat_minutes} min, at most ${p.max_alerts}.
        ${p.coaches_too ? 'The coaches of the last event are also asked to confirm.' : ''}
        <div style="margin-top:6px;">
          ${rows.map(r => `<div class="lk-row"><span class="k">${r.role === 'closer' ? 'Asked to confirm' : 'Alerted'}</span>
                            <span class="v">${this.escapeHtml(r.name)} · ${this.escapeHtml(r.channels)}</span></div>`).join('')}
        </div>
      </div>`).join('');
    const tests = d.is_admin ? `
      <div class="lk-sec">Test the pipe (sends tonight's alert wording to you only)</div>
      <div style="display:flex; gap:8px; flex-wrap:wrap;">
        ${['email', 'sms', 'call'].map(c => `<button class="lk-btn sm" data-test="${c}" ${this.busy ? 'disabled' : ''}>Test ${this.escapeHtml(LockupsScreen.CHANNEL[c])} to me</button>`).join('')}
      </div>` : '';
    el.innerHTML = `
      ${flash}
      <div class="lk-sec">Tonight</div>
      ${today}
      ${tests}
      <div class="lk-sec">Who is asked, who is chased</div>
      ${people || '<p style="opacity:0.6;">Nobody is on the lock-up list yet.</p>'}
      <div class="lk-sec">Last 30 nights</div>
      ${hist}
    `;
  }
}
