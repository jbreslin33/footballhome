// SecurityScreen — #security — the nightly "was the gate locked?" board
// (owner 2026-09-24: "it needs to call phone if no upload of picture of
// locked gate is uploaded to footballhome within 45 minutes of end time
// of event at a lighthouse site … a security button at top level of
// admin … and an upload button to accept a pic").
//
// Backed by GET /api/security/board, POST /api/security/photo and
// POST /api/security/test (backend/src/controllers/LockupController.cpp,
// migrations 421 + 424).  The backend scheduler does the chasing: 45 min
// after the night's last event at a facility, the phone rings every 5
// minutes until a photo of the locked gate is up.  This page is where
// staff see tonight's status, upload the photo, see the photos and what
// was sent to whom, and (admins) fire a test to themselves.
//
// Top-level page, not a panel on #my (owner 2026-09-17: staff tools get
// dedicated pages).  Club admins, active coaches and anyone on the
// facility's lock-up list can open it.
class SecurityScreen extends Screen {
  static STATUS = {
    none:    { label: 'No events tonight',          cls: 'lk-none' },
    pending: { label: 'Not due yet',                cls: 'lk-pending' },
    due:     { label: 'Waiting for the photo',      cls: 'lk-due' },
    overdue: { label: 'NO PHOTO — calling',         cls: 'lk-overdue' },
    locked:  { label: 'Locked — photo up',          cls: 'lk-locked' },
  };
  static VIA = { photo: 'photo', tap: 'tap link', board: 'button' };
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
        .lk-btn[disabled], .lk-btn.busy { opacity:0.4; cursor:not-allowed; pointer-events:none; }
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
        <h1>🔐 Security</h1>
        <p class="subtitle">After the last event at a Lighthouse site, upload a photo of the locked gate — otherwise Football Home starts calling 45 minutes after it ends</p>
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
    this.element.addEventListener('change', async (e) => {
      const input = e.target.closest('input[data-upload]');
      if (input && input.files && input.files[0]) await this.upload(Number(input.dataset.upload), input.files[0]);
    });
    this.element.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      if (e.target.closest('#lk-refresh')) { this.load(); return; }
      const testBtn = e.target.closest('[data-test]');
      if (testBtn) { await this.test(testBtn.dataset.test); return; }
    });
  }

  async load() {
    this.loading = true; this.error = null;
    this._renderBody();
    try {
      const res = await this.auth.fetch('/api/security/board');
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

  async upload(id, file) {
    if (this.busy || !id) return;
    this.busy = true;
    this.flash = 'Uploading the photo…';
    this._renderBody();
    try {
      const image = await window.shrinkPhoto(file, 1600, 0.82);
      const res = await this.auth.fetch('/api/security/photo', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lockup_id: id, image }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.flash = 'Photo up. Marked locked.';
    } catch (err) {
      this.flash = `✗ ${err.message || 'Upload failed.'}`;
    }
    this.busy = false;
    await this.load();
  }

  async test(channel) {
    if (this.busy) return;
    this.busy = true;
    this.flash = `Sending a test ${SecurityScreen.CHANNEL[channel] || channel}…`;
    this._renderBody();
    try {
      const res = await this.auth.fetch('/api/security/test', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ channel }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.flash = body.ok ? `Test ${SecurityScreen.CHANNEL[channel]} sent to ${body.contact}.`
                           : `✗ Test ${SecurityScreen.CHANNEL[channel]} failed: ${body.error || 'unknown error'}`;
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
        <span>${this.escapeHtml(SecurityScreen.STAGE[a.stage] || a.stage)} · ${this.escapeHtml(SecurityScreen.CHANNEL[a.channel] || a.channel)}
              → ${this.escapeHtml(a.person || a.contact)}</span>
        <span class="${a.ok ? 'ok' : 'bad'}">${a.ok ? '✓' : '✗ ' + this.escapeHtml(a.error || 'failed')}</span>
      </div>`).join('');
    return `<div class="lk-log">${rows}</div>`;
  }

  _card(l, { big }) {
    const st = SecurityScreen.STATUS[l.status] || SecurityScreen.STATUS.none;
    const rows = [];
    if (l.last_event) rows.push(['Last event', l.last_event]);
    if (l.status !== 'none') rows.push(['Confirm by', l.deadline_label]);
    if (l.status === 'locked') {
      rows.push(['Locked by', `${l.confirmed_by || '—'} at ${l.confirmed_label} (${SecurityScreen.VIA[l.confirmed_via] || l.confirmed_via})`]);
    }
    if (l.alert_count > 0) rows.push(['Alerts sent', `${l.alert_count} of ${l.max_alerts}`]);
    const canUpload = l.id > 0 && l.status !== 'none';
    const photos = (l.photos || []).map(p => `
      <a href="${this.escapeHtml(p.url)}" target="_blank" rel="noopener" title="${this.escapeHtml(p.person)} · ${this.escapeHtml(this._fmtWhen(p.created_at))}">
        <img src="${this.escapeHtml(p.url)}" alt="" style="width:96px; height:96px; object-fit:cover; border-radius:8px; border:1px solid var(--border-color);">
      </a>`).join('');
    return `
      <div class="lk-card ${st.cls}">
        <div class="lk-title">
          <h2>${this.escapeHtml(l.short_name || l.facility)} · ${this.escapeHtml(l.date_label)}</h2>
          <span class="lk-pill">${this.escapeHtml(st.label)}</span>
        </div>
        ${rows.map(([k, v]) => `<div class="lk-row"><span class="k">${this.escapeHtml(k)}</span><span class="v">${this.escapeHtml(v)}</span></div>`).join('')}
        ${photos ? `<div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:8px;">${photos}</div>` : ''}
        ${canUpload ? `
          <label class="lk-btn ${this.busy ? 'busy' : ''}" style="display:inline-block; text-align:center; ${big ? '' : 'font-size:0.8rem; padding:6px 12px;'}">
            📷 ${l.status === 'locked' ? 'Add another photo' : 'Take / upload photo of the locked gate'}
            <input type="file" accept="image/*" data-upload="${l.id}" hidden ${this.busy ? 'disabled' : ''}>
          </label>` : ''}
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
                                 : '<p style="opacity:0.6;">No facility needs a gate photo.</p>';
    const hist = d.history.length
      ? `<div class="lk-hist">${d.history.map(l => this._card(l, { big: false })).join('')}</div>`
      : '<p style="opacity:0.6;">No earlier nights yet.</p>';
    const byFac = {};
    for (const p of d.people) (byFac[p.facility] ||= { rows: [], p }).rows.push(p);
    const people = Object.entries(byFac).map(([fac, { rows, p }]) => `
      <div class="lk-card lk-people" style="border-left-color:var(--border-color);">
        <strong>${this.escapeHtml(fac)}</strong> — photo due ${p.grace_minutes} min after the last event ends;
        then the phone rings every ${p.repeat_minutes} min, at most ${p.max_alerts} times (email/text once, with the link).
        ${p.coaches_too ? 'The coaches of the last event are also asked to confirm.' : ''}
        <div style="margin-top:6px;">
          ${rows.map(r => `<div class="lk-row"><span class="k">${r.role === 'closer' ? 'Asked to confirm' : 'Alerted'}</span>
                            <span class="v">${this.escapeHtml(r.name)} · ${this.escapeHtml(r.channels)}</span></div>`).join('')}
        </div>
      </div>`).join('');
    const tests = d.is_admin ? `
      <div class="lk-sec">Test the pipe (sends tonight's alert wording to you only)</div>
      <div style="display:flex; gap:8px; flex-wrap:wrap;">
        ${['email', 'sms', 'call'].map(c => `<button class="lk-btn sm" data-test="${c}" ${this.busy ? 'disabled' : ''}>Test ${this.escapeHtml(SecurityScreen.CHANNEL[c])} to me</button>`).join('')}
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
