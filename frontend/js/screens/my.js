// MyScreen — signed-in player's weekly RSVP + recurring preferences.
//
// Auth: MyController accepts either the fh_sess cookie OR a JWT bearer.
// We use auth.fetch() here so the JWT path works for the standard SPA
// login flow; requests also carry cookies via credentials: 'include'
// so magic-link sessions transparently work too.
//
// Endpoints:
//   GET  /api/my/week      → { player_id, events: [...] }
//   POST /api/my/rsvp      → body { match_id, rsvp_status_id, note? }
//   GET  /api/my/recurring → { prefs: [...] }
//   PUT  /api/my/recurring → body { prefs: [{day_of_week, match_type_id, rsvp_status_id}] }
class MyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.week      = null;          // { player_id, events }
    this.prefs     = null;          // Array<{day_of_week, match_type_id, rsvp_status_id, ...}>
    this.mode      = 'week';        // 'week' | 'recurring'
    this.savingId  = null;          // match_id currently being written
    this.errorMsg  = null;
  }

  // ---------- lifecycle ----------

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-my';
    el.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>My Schedule</h1>
        <p class="subtitle" id="my-subtitle">Loading…</p>
      </div>
      <div style="padding: 0 var(--space-4);">
        <div style="display:flex; gap: var(--space-2); margin-bottom: var(--space-3);">
          <button class="btn btn-primary tab-btn" data-tab="week">This week</button>
          <button class="btn btn-outline-secondary tab-btn" data-tab="recurring">Preferences</button>
        </div>
        <div id="my-content">
          <div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>
        </div>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter(_params) {
    this.mode = 'week';
    this.errorMsg = null;
    this._wire();
    this._bootstrap();
  }

  onExit() {}

  // ---------- data ----------

  async _bootstrap() {
    try {
      const [weekRes, prefsRes] = await Promise.all([
        this._fetch('/api/my/week'),
        this._fetch('/api/my/recurring'),
      ]);
      this.week  = weekRes;
      this.prefs = prefsRes.prefs || [];
      this._renderTabs();
      this._renderCurrent();
    } catch (err) {
      console.error('[my] bootstrap failed:', err);
      this.errorMsg = err.message || 'Failed to load schedule.';
      this._renderError();
    }
  }

  // Thin wrapper that adds credentials: 'include' AND the JWT via
  // auth.fetch — MyController accepts either.
  async _fetch(url, options = {}) {
    const headers = { ...(options.headers || {}) };
    if (this.auth.token) {
      headers['Authorization'] = `Bearer ${this.auth.token}`;
    }
    const res = await fetch(url, {
      ...options,
      headers,
      credentials: 'include',
    });
    if (!res.ok) {
      let msg = `HTTP ${res.status}`;
      try {
        const body = await res.json();
        if (body && body.error)   msg = body.error;
        if (body && body.message) msg = body.message;
      } catch {}
      throw new Error(msg);
    }
    return res.json();
  }

  // ---------- rendering ----------

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const tab = e.target.closest('.tab-btn');
      if (tab) {
        this.mode = tab.getAttribute('data-tab');
        this._renderTabs();
        this._renderCurrent();
        return;
      }
      const rsvpBtn = e.target.closest('[data-rsvp-match-id]');
      if (rsvpBtn) {
        const matchId = parseInt(rsvpBtn.getAttribute('data-rsvp-match-id'), 10);
        const statusId = parseInt(rsvpBtn.getAttribute('data-status-id'), 10);
        this._submitRsvp(matchId, statusId);
        return;
      }
      const prefBtn = e.target.closest('[data-pref-key]');
      if (prefBtn) {
        const [dowStr, mtypeStr] = prefBtn.getAttribute('data-pref-key').split(':');
        const statusId = parseInt(prefBtn.getAttribute('data-status-id'), 10);
        this._togglePref(parseInt(dowStr, 10), parseInt(mtypeStr, 10), statusId);
        return;
      }
    });
  }

  _renderTabs() {
    const tabs = this.element.querySelectorAll('.tab-btn');
    tabs.forEach(t => {
      const active = t.getAttribute('data-tab') === this.mode;
      t.classList.toggle('btn-primary', active);
      t.classList.toggle('btn-outline-secondary', !active);
    });
  }

  _renderCurrent() {
    if (this.mode === 'week')      return this._renderWeek();
    if (this.mode === 'recurring') return this._renderRecurring();
  }

  _renderError() {
    const box = this.find('#my-content');
    if (!box) return;
    box.innerHTML = `
      <div class="empty-state">
        <p><strong>Error:</strong> ${this.escapeHtml(this.errorMsg || 'Unknown')}</p>
        <button class="btn btn-primary" onclick="location.reload()">Reload</button>
      </div>
    `;
  }

  _renderWeek() {
    const box = this.find('#my-content');
    if (!box) return;
    const events = (this.week && this.week.events) || [];
    const sub    = this.find('#my-subtitle');
    if (sub) sub.textContent = events.length
      ? `${events.length} event${events.length === 1 ? '' : 's'} this week`
      : 'Nothing on the schedule right now.';

    const banner = this._purgatoryBanner();

    if (!events.length) {
      box.innerHTML = `
        ${banner}
        <div class="empty-state">
          <p>No upcoming events. Check back after Sunday 8pm — the week rolls over then.</p>
        </div>
      `;
      return;
    }

    box.innerHTML = banner + events.map(ev => this._eventCard(ev)).join('');
  }

  // Amber banner shown when the caller's mens roster_assignments are all
  // soft-deleted (delinquent dues).  Pickup RSVPs still work — practice
  // and games are the ones filtered out on the backend.
  _purgatoryBanner() {
    if (!this.week || this.week.membership_status !== 'purgatory') return '';
    const days = this.week.purgatory_days_overdue || 0;
    const daysStr = days > 0 ? ` (${days} day${days === 1 ? '' : 's'} overdue)` : '';
    return `
      <div style="background: rgba(240, 173, 78, 0.15);
                  border: 1px solid rgba(240, 173, 78, 0.5);
                  border-radius: 8px;
                  padding: var(--space-3);
                  margin-bottom: var(--space-3);
                  color: #f0ad4e;">
        <div style="font-weight: 600; margin-bottom: var(--space-1);">
          ⚠ Unpaid dues${this.escapeHtml(daysStr)}
        </div>
        <div style="opacity: 0.95;">
          Pay to unlock practice and games. You can still RSVP to pickup below.
        </div>
      </div>
    `;
  }

  _eventCard(ev) {
    const day       = this._formatDay(ev.match_date);
    const time      = this._formatRange(ev.match_time, ev.end_time);
    const title     = ev.title || this._titleCase(ev.match_type || 'Event');
    const currentId = ev.my_rsvp ? ev.my_rsvp.rsvp_status_id : null;
    const saving    = this.savingId === ev.match_id;

    const btn = (statusId, label, activeBg) => {
      const active = currentId === statusId;
      const style = [
        'flex:1',
        'padding: var(--space-2) var(--space-3)',
        'border-radius: 6px',
        `background: ${active ? activeBg : 'transparent'}`,
        `color: ${active ? '#fff' : 'inherit'}`,
        `border: 1px solid ${active ? activeBg : 'rgba(255,255,255,0.2)'}`,
        'cursor: pointer',
        'font-weight: 500',
      ].join(';');
      return `
        <button data-rsvp-match-id="${ev.match_id}" data-status-id="${statusId}"
                ${saving ? 'disabled' : ''}
                style="${style}">
          ${saving && active ? '…' : this.escapeHtml(label)}
        </button>
      `;
    };

    const desc = ev.description
      ? `<div style="opacity:0.75; font-size:0.9rem; margin-top: var(--space-1);">${this.escapeHtml(ev.description)}</div>`
      : '';

    return `
      <div style="background: var(--bg-secondary, rgba(255,255,255,0.04));
                  border: 1px solid var(--border-color, rgba(255,255,255,0.08));
                  border-radius: 8px; padding: var(--space-3);
                  margin-bottom: var(--space-3);">
        <div style="display:flex; justify-content: space-between; gap: var(--space-2); align-items: baseline;">
          <div style="font-weight: 600;">${this.escapeHtml(title)}</div>
          <div style="opacity:0.7; font-size: 0.9rem;">${this.escapeHtml(day)} · ${this.escapeHtml(time)}</div>
        </div>
        ${desc}
        <div style="display:flex; gap: var(--space-2); margin-top: var(--space-3);">
          ${btn(1, 'Going',     '#16a34a')}
          ${btn(3, 'Maybe',     '#f59e0b')}
          ${btn(2, "Can't go",  '#dc2626')}
        </div>
      </div>
    `;
  }

  _renderRecurring() {
    const box = this.find('#my-content');
    if (!box) return;
    const sub = this.find('#my-subtitle');
    if (sub) sub.textContent = 'Set defaults for each weekly slot.';

    // Slot list matches the current match_series schedule.  Keep in sync
    // with the DB rows in `match_series` — this is display order only.
    const slots = [
      { dow: 2, match_type_id: 7, label: 'Tuesday Pickup',     time: '7:00 PM' },
      { dow: 3, match_type_id: 3, label: 'Wednesday Practice', time: '7:00 PM' },
      { dow: 4, match_type_id: 7, label: 'Thursday Pickup',    time: '7:00 PM' },
      { dow: 5, match_type_id: 3, label: 'Friday Practice',    time: '7:00 PM' },
      { dow: 6, match_type_id: 7, label: 'Saturday Pickup',    time: '11:00 AM' },
    ];

    const prefMap = new Map();
    for (const p of (this.prefs || [])) {
      prefMap.set(`${p.day_of_week}:${p.match_type_id}`, p.rsvp_status_id);
    }

    const rows = slots.map(s => {
      const key = `${s.dow}:${s.match_type_id}`;
      const current = prefMap.get(key) || 0;
      const cell = (statusId, label, bg) => {
        const active = current === statusId;
        const style = [
          'padding: 6px 12px',
          'border-radius: 4px',
          `background: ${active ? bg : 'transparent'}`,
          `color: ${active ? '#fff' : 'inherit'}`,
          `border: 1px solid ${active ? bg : 'rgba(255,255,255,0.2)'}`,
          'cursor: pointer',
          'font-size: 0.85rem',
        ].join(';');
        return `<button data-pref-key="${key}" data-status-id="${statusId}"
                        style="${style}">${label}</button>`;
      };
      return `
        <div style="display:flex; justify-content: space-between; align-items: center;
                    padding: var(--space-2) 0;
                    border-bottom: 1px solid rgba(255,255,255,0.05);">
          <div>
            <div style="font-weight: 500;">${this.escapeHtml(s.label)}</div>
            <div style="opacity: 0.6; font-size: 0.85rem;">${this.escapeHtml(s.time)}</div>
          </div>
          <div style="display:flex; gap: 6px;">
            ${cell(1, 'Yes',   '#16a34a')}
            ${cell(3, 'Maybe', '#f59e0b')}
            ${cell(2, 'No',    '#dc2626')}
            ${cell(0, '—',     '#4b5563')}
          </div>
        </div>
      `;
    }).join('');

    box.innerHTML = `
      <div style="background: var(--bg-secondary, rgba(255,255,255,0.04));
                  border-radius: 8px; padding: var(--space-3);">
        <p style="margin-top:0; opacity:0.8;">
          Your default RSVP is auto-applied every Sunday at 8&nbsp;PM when the week rolls over.
          You can always change your mind on the <a href="#" data-tab="week">This week</a> tab.
        </p>
        ${rows}
      </div>
    `;
  }

  // ---------- writes ----------

  async _submitRsvp(matchId, statusId) {
    if (this.savingId) return;
    this.savingId = matchId;
    this._renderWeek();  // show "…" state
    try {
      const res = await this._fetch('/api/my/rsvp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ match_id: matchId, rsvp_status_id: statusId }),
      });
      // Update local state without a full refetch.
      const ev = (this.week?.events || []).find(e => e.match_id === matchId);
      if (ev) {
        ev.my_rsvp = {
          rsvp_status_id: statusId,
          status: this._statusName(statusId),
          notes: null,
        };
      }
    } catch (err) {
      console.error('[my] RSVP failed:', err);
      alert(`Could not save RSVP: ${err.message}`);
    } finally {
      this.savingId = null;
      this._renderWeek();
    }
  }

  async _togglePref(dow, mtypeId, statusId) {
    // statusId=0 means "clear".  We rebuild the prefs array
    // and PUT the whole set — the backend does delete-then-insert.
    const filtered = (this.prefs || []).filter(
      p => !(p.day_of_week === dow && p.match_type_id === mtypeId)
    );
    if (statusId > 0) {
      filtered.push({
        day_of_week: dow,
        match_type_id: mtypeId,
        rsvp_status_id: statusId,
      });
    }
    // Optimistic UI.
    const previous = this.prefs;
    this.prefs = filtered;
    this._renderRecurring();
    try {
      await this._fetch('/api/my/recurring', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prefs: filtered.map(p => ({
          day_of_week:    p.day_of_week,
          match_type_id:  p.match_type_id,
          rsvp_status_id: p.rsvp_status_id,
        })) }),
      });
    } catch (err) {
      console.error('[my] preference save failed:', err);
      alert(`Could not save preference: ${err.message}`);
      this.prefs = previous;
      this._renderRecurring();
    }
  }

  // ---------- helpers ----------

  _statusName(id) {
    switch (id) {
      case 1: return 'yes';
      case 2: return 'no';
      case 3: return 'maybe';
      default: return '';
    }
  }

  _titleCase(s) {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  _formatDay(isoDate) {
    if (!isoDate) return '';
    // Interpret YYYY-MM-DD in local time.  Avoids the "off by one day"
    // UTC bug that new Date('2026-07-05') would trigger.
    const [y, m, d] = isoDate.split('-').map(n => parseInt(n, 10));
    const dt = new Date(y, (m || 1) - 1, d || 1);
    return dt.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
  }

  _formatRange(startHHMMSS, endHHMMSS) {
    const fmt = (hhmm) => {
      if (!hhmm) return '';
      const [hRaw, mRaw] = hhmm.split(':');
      let h = parseInt(hRaw, 10);
      const m = parseInt(mRaw, 10) || 0;
      const suffix = h >= 12 ? 'PM' : 'AM';
      h = h % 12; if (h === 0) h = 12;
      return m === 0 ? `${h} ${suffix}` : `${h}:${String(m).padStart(2,'0')} ${suffix}`;
    };
    const a = fmt(startHHMMSS);
    const b = fmt(endHHMMSS);
    if (!a) return '';
    if (!b) return a;
    return `${a}–${b}`;
  }
}
