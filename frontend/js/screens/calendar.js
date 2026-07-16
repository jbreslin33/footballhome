// CalendarScreen — read-only view over the Google Calendar mirror
// (populated every 5 min by scripts/gcal-sync.js + gcal-classify.js).
//
// Slice 5 of docs/calendar-design.md.  §10.1 lists three views for
// this screen — week grid, month grid, agenda list.  We ship the
// agenda list first because it's the smallest surface that proves
// the pipeline end-to-end and doubles as the mobile fallback per
// §10.1.  Week / month grids are follow-ups.
//
// Data:
//   GET /api/calendar/upcoming?days=14
//     → { days, count, events: [{
//         fh_event_id, gcal_event_id, calendar_role, calendar_time_zone,
//         google_event_id, recurring_event_id,
//         summary, description, location,
//         starts_at (UTC ISO), ends_at (UTC ISO), all_day, status,
//         html_link,
//         kind, category, team_id, is_home, fh_notes,
//         rsvps_open_at (UTC ISO | null), rsvps_open_now (bool)
//       }, ...] }
//
// Auth: endpoint is public; we still route through auth.fetch() to
// pick up the global no-cache headers (per user pref: no browser
// caching outside login).
//
// This screen does NOT write anything.  RSVP writes land in Slice 6
// and add a button to the pickup cards below.
class CalendarScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.events    = [];
    this.count     = 0;
    this.days      = 14;
    this.loading   = false;
    this.error     = null;
    this.fetchedAt = null;   // Date of last successful fetch
  }

  // ---------- lifecycle ----------

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-calendar';
    el.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🗓️ Calendar</h1>
        <p class="subtitle" id="cal-subtitle">Next 14 days — mirrored from Google Calendar</p>
      </div>

      <div style="padding: 0 var(--space-4) var(--space-4);">
        <div id="cal-toolbar" style="display:flex; align-items:center; gap: var(--space-2);
             flex-wrap:wrap; margin-bottom: var(--space-3);">
          <span id="cal-fetched" style="padding:4px 12px; border-radius:9999px;
                font-size:0.85rem; background:transparent; color:#94a3b8;
                border:1px solid #94a3b8; white-space:nowrap;">Loading…</span>
          <button id="cal-refresh" class="btn btn-secondary"
                  style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
          <span style="flex:1"></span>
          <label style="font-size:0.85rem; opacity:0.85;">
            Window:
            <select id="cal-days"
                    style="margin-left:6px; padding:4px 8px; border-radius:6px;
                           background: var(--bg-secondary);
                           color: var(--text-primary);
                           border:1px solid var(--color-border);">
              <option value="7">7 days</option>
              <option value="14" selected>14 days</option>
              <option value="30">30 days</option>
              <option value="60">60 days</option>
              <option value="90">90 days</option>
            </select>
          </label>
        </div>

        <div id="cal-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">
          Loading calendar…
        </div>
        <div id="cal-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="cal-empty" style="display:none; text-align:center;
             padding: var(--space-6); opacity:0.6;">
          No classified events in this window.
        </div>
        <div id="cal-groups" style="display:none;"></div>

        <p style="opacity:0.55; font-size:0.8rem; margin-top: var(--space-4);
                  text-align:center; line-height:1.5;">
          Football Home mirrors <code>soccer@lighthouse1893.org</code> +
          <code>sports@lighthouse1893.org</code>.  To add or change an event,
          edit it in Google Calendar — FH picks it up within ~5&nbsp;minutes.
        </p>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter(_params) {
    this.error = null;
    this._wire();
    this._load();
  }

  onExit() {
    // No timers to clean up (yet).  Slice 6a's countdown may add one.
  }

  // ---------- events ----------

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      if (e.target.closest('#cal-refresh')) {
        this._load();
        return;
      }
    });
    this.find('#cal-days').addEventListener('change', (e) => {
      const n = parseInt(e.target.value, 10);
      if (Number.isFinite(n) && n > 0) {
        this.days = n;
        this._load();
      }
    });
  }

  // ---------- data ----------

  async _load() {
    if (this.loading) return;
    this.loading = true;
    this._renderLoading();
    try {
      const res = await this.auth.fetch(`/api/calendar/upcoming?days=${this.days}`);
      if (!res.ok) {
        let msg = `HTTP ${res.status}`;
        try {
          const body = await res.json();
          if (body && body.error) msg = body.error;
        } catch (_) {}
        throw new Error(msg);
      }
      const body = await res.json();
      this.events    = Array.isArray(body.events) ? body.events : [];
      this.count     = body.count ?? this.events.length;
      this.fetchedAt = new Date();
      this.error     = null;
      this._renderGroups();
    } catch (err) {
      console.error('[calendar] load failed:', err);
      this.error = err.message || 'Failed to load calendar.';
      this._renderError();
    } finally {
      this.loading = false;
      this._renderToolbar();
    }
  }

  // ---------- rendering ----------

  _renderLoading() {
    this.find('#cal-loading').style.display = '';
    this.find('#cal-error').style.display   = 'none';
    this.find('#cal-empty').style.display   = 'none';
    this.find('#cal-groups').style.display  = 'none';
    this._renderToolbar();
  }

  _renderError() {
    this.find('#cal-loading').style.display = 'none';
    this.find('#cal-empty').style.display   = 'none';
    this.find('#cal-groups').style.display  = 'none';
    const errEl = this.find('#cal-error');
    errEl.textContent = this.error || 'Something went wrong.';
    errEl.style.display = '';
  }

  _renderToolbar() {
    const el = this.find('#cal-fetched');
    if (this.error) {
      el.textContent = 'Fetch failed';
      el.style.color = 'var(--color-error)';
      el.style.borderColor = 'var(--color-error)';
    } else if (this.fetchedAt) {
      const t = this.fetchedAt.toLocaleTimeString(undefined,
        { hour: 'numeric', minute: '2-digit' });
      el.textContent = `Fetched at ${t} · ${this.count} event${this.count === 1 ? '' : 's'}`;
      el.style.color = '#94a3b8';
      el.style.borderColor = '#94a3b8';
    } else {
      el.textContent = 'Loading…';
    }
    // Keep the <select> in sync in case a background action ever
    // changes this.days without a DOM click.
    const sel = this.find('#cal-days');
    if (sel) sel.value = String(this.days);
  }

  _renderGroups() {
    this.find('#cal-loading').style.display = 'none';
    this.find('#cal-error').style.display   = 'none';

    if (!this.events.length) {
      this.find('#cal-empty').style.display  = '';
      this.find('#cal-groups').style.display = 'none';
      return;
    }

    // Bucket by calendar date in the user's local zone.
    // Buckets: Today, Tomorrow, This week (rest of), Next week, Later.
    const now = new Date();
    const startOfDay = (d) => new Date(d.getFullYear(), d.getMonth(), d.getDate());
    const today    = startOfDay(now);
    const tomorrow = new Date(today); tomorrow.setDate(tomorrow.getDate() + 1);
    const dayAfter = new Date(today); dayAfter.setDate(dayAfter.getDate() + 2);
    // Days remaining until Sunday 00:00 (exclusive).  In JS: Sun=0.
    const daysToNextSunday = (7 - now.getDay()) % 7 || 7;
    const nextSunday       = new Date(today); nextSunday.setDate(nextSunday.getDate() + daysToNextSunday);
    const twoSundaysOut    = new Date(nextSunday); twoSundaysOut.setDate(twoSundaysOut.getDate() + 7);

    const buckets = [
      { key: 'today',    label: 'Today',      test: (d) => d >= today    && d < tomorrow      },
      { key: 'tomorrow', label: 'Tomorrow',   test: (d) => d >= tomorrow && d < dayAfter      },
      { key: 'thisweek', label: 'This week',  test: (d) => d >= dayAfter && d < nextSunday    },
      { key: 'nextweek', label: 'Next week',  test: (d) => d >= nextSunday && d < twoSundaysOut },
      { key: 'later',    label: 'Later',      test: (d) => d >= twoSundaysOut                  },
    ];
    const groups = buckets.map(b => ({ ...b, events: [] }));
    for (const ev of this.events) {
      const d  = new Date(ev.starts_at);
      const dd = startOfDay(d);
      const g  = groups.find(b => b.test(dd));
      if (g) g.events.push(ev);
    }

    const host = this.find('#cal-groups');
    host.innerHTML = groups
      .filter(g => g.events.length)
      .map(g => this._renderGroup(g))
      .join('');
    this.find('#cal-empty').style.display  = 'none';
    host.style.display = '';
  }

  _renderGroup(group) {
    return `
      <section style="margin-bottom: var(--space-5);">
        <h3 style="margin: 0 0 var(--space-2); opacity:0.9;
                   font-size:1.05rem; letter-spacing:0.02em;">
          ${this._escape(group.label)}
          <span style="opacity:0.55; font-weight:400; font-size:0.85rem;">
            &nbsp;·&nbsp;${group.events.length}
          </span>
        </h3>
        <div style="display:grid; gap: var(--space-2);
                    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));">
          ${group.events.map(ev => this._renderCard(ev)).join('')}
        </div>
      </section>
    `;
  }

  _renderCard(ev) {
    const startD = new Date(ev.starts_at);
    const endD   = new Date(ev.ends_at);
    const dayLbl = startD.toLocaleDateString(undefined,
      { weekday: 'short', month: 'short', day: 'numeric' });
    const timeLbl = ev.all_day
      ? 'All day'
      : `${startD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}` +
        ` – ${endD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;

    // Kind → color.  Matches §10.1 palette.
    const kindColors = {
      pickup:   { bg: '#1e3a8a', fg: '#dbeafe' },  // blue
      practice: { bg: '#064e3b', fg: '#d1fae5' },  // green
      match:    { bg: '#7f1d1d', fg: '#fecaca' },  // red
      meeting:  { bg: '#334155', fg: '#e2e8f0' },  // grey
      camp:     { bg: '#78350f', fg: '#fed7aa' },  // amber
      other:    { bg: '#334155', fg: '#e2e8f0' },
    };
    const kc = kindColors[ev.kind] || kindColors.other;
    const kindLabel = ev.kind + (ev.category ? ` · ${ev.category}` : '');

    // Pickup RSVP hint per §6.5.  Read-only in Slice 5 (button lands in Slice 6).
    let rsvpBlock = '';
    if (ev.kind === 'pickup') {
      if (ev.rsvps_open_now) {
        rsvpBlock = `
          <div style="margin-top: var(--space-2); padding: 6px 10px; border-radius:6px;
                      background:#065f46; color:#d1fae5; font-size:0.85rem;">
            ✅ RSVPs are open
          </div>`;
      } else if (ev.rsvps_open_at) {
        const opens = new Date(ev.rsvps_open_at);
        const opensLbl = opens.toLocaleString(undefined, {
          weekday: 'short', month: 'short', day: 'numeric',
          hour: 'numeric', minute: '2-digit',
        });
        rsvpBlock = `
          <div style="margin-top: var(--space-2); padding: 6px 10px; border-radius:6px;
                      background:#78350f; color:#fed7aa; font-size:0.85rem;">
            ⏱ RSVPs open ${this._escape(opensLbl)}
          </div>`;
      }
    }

    const gcalLink = ev.html_link
      ? `<a href="${this._escape(ev.html_link)}" target="_blank" rel="noopener"
            style="color:#93c5fd; font-size:0.85rem; text-decoration:none;">
           Open in Google Calendar ↗
         </a>`
      : '';

    return `
      <div class="cal-card" style="background: var(--bg-secondary);
           border:1px solid var(--color-border); border-radius: var(--radius-md);
           padding: var(--space-3); display:flex; flex-direction:column; gap:6px;">
        <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
          <span style="background:${kc.bg}; color:${kc.fg};
                       padding:2px 8px; border-radius:9999px;
                       font-size:0.75rem; text-transform:uppercase;
                       letter-spacing:0.05em; font-weight:600;">
            ${this._escape(kindLabel)}
          </span>
          <span style="opacity:0.65; font-size:0.8rem;">
            ${this._escape(dayLbl)}
          </span>
        </div>
        <div style="font-weight:600; font-size:1rem;">
          ${this._escape(ev.summary || '(untitled)')}
        </div>
        <div style="opacity:0.8; font-size:0.9rem;">
          🕒 ${this._escape(timeLbl)}
        </div>
        ${ev.location ? `
          <div style="opacity:0.8; font-size:0.9rem;">
            📍 ${this._escape(ev.location)}
          </div>` : ''}
        ${rsvpBlock}
        ${gcalLink ? `<div style="margin-top:auto; padding-top: var(--space-1);">${gcalLink}</div>` : ''}
      </div>
    `;
  }

  // ---------- utils ----------

  _escape(s) {
    if (s == null) return '';
    return String(s)
      .replaceAll('&',  '&amp;')
      .replaceAll('<',  '&lt;')
      .replaceAll('>',  '&gt;')
      .replaceAll('"',  '&quot;')
      .replaceAll('\'', '&#39;');
  }
}
