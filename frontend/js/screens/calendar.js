// CalendarScreen — FH soccer view over the Google Calendar mirror
// (populated every 5 min by scripts/gcal-sync.js + gcal-classify.js).
//
// Slice 5 of docs/calendar-design.md.  §10.1 lists three views for
// this screen — week grid, month grid, agenda list.  The screen now
// exposes all three over the same Google soccer event feed.  FH
// classification enriches rows when it exists.
//
// Data:
//   GET /api/calendar/upcoming?start=<iso>&days=<range>&include_unclassified=1
//     → { days, count, events: [{
//         fh_event_id, gcal_event_id, calendar_role, calendar_time_zone,
//         google_event_id, recurring_event_id,
//         summary, description, location,
//         starts_at (UTC ISO), ends_at (UTC ISO), all_day, status,
//         html_link, hangout_link,
//         kind, category, is_home, opponent, fh_notes,
//         teams:            [{ id, name, gender_category }, ...]   // §6.1.5 junction
//         rsvps_open_at:    UTC ISO | null,
//         rsvps_open_now:   bool,
//         my_rsvp:          'yes'|'no'|'maybe'|null,
//         my_rsvp_eligible: bool | null   // null when anonymous; §6.1.5
//       }, ...] }
//
// This is an admin/ops read-only calendar.  Player RSVP workflows live
// on My Schedule; this screen deliberately shows soccer events beyond
// the Sunday 8pm RSVP window.
class CalendarScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.events    = [];
    this.count     = 0;
    this.days      = 90;
    this.anchorDate = this._startOfDay(new Date());
    this.view      = localStorage.getItem('cal-view') || 'week';
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
        <h1>⚽ Soccer Calendar</h1>
        <p class="subtitle" id="cal-subtitle">Google Calendar timing, translated into Football Home soccer events</p>
      </div>

      <div style="padding: 0 var(--space-4) var(--space-4);">
        <div id="cal-toolbar" style="display:flex; align-items:center; gap: var(--space-2);
             flex-wrap:wrap; margin-bottom: var(--space-3);">
          <span id="cal-fetched" style="padding:4px 12px; border-radius:9999px;
                font-size:0.85rem; background:transparent; color:#94a3b8;
                border:1px solid #94a3b8; white-space:nowrap;">Loading…</span>
          <button id="cal-refresh" class="btn btn-secondary"
                  style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
          <div id="cal-nav" style="display:flex;gap:4px;align-items:center;">
            <button type="button" class="btn btn-secondary" data-cal-nav="prev" aria-label="Previous" style="padding:4px 10px;font-size:0.95rem;">‹</button>
            <button type="button" class="btn btn-secondary" data-cal-nav="today" style="padding:4px 12px;font-size:0.85rem;">Today</button>
            <button type="button" class="btn btn-secondary" data-cal-nav="next" aria-label="Next" style="padding:4px 10px;font-size:0.95rem;">›</button>
          </div>
          <span id="cal-range-label" style="padding:4px 10px;font-size:0.85rem;opacity:0.82;white-space:nowrap;"></span>
          <div id="cal-view-tabs" style="display:flex;gap:4px;align-items:center;">
            <button type="button" class="btn btn-secondary" data-cal-view="week" style="padding:4px 12px;font-size:0.85rem;">Week</button>
            <button type="button" class="btn btn-secondary" data-cal-view="month" style="padding:4px 12px;font-size:0.85rem;">Month</button>
            <button type="button" class="btn btn-secondary" data-cal-view="agenda" style="padding:4px 12px;font-size:0.85rem;">Agenda</button>
          </div>
        </div>

        <div id="cal-loading" style="text-align:center; padding: var(--space-6); opacity:0.7;">
          Loading calendar…
        </div>
        <div id="cal-error" style="display:none; color: var(--color-error);
             padding: var(--space-4); text-align:center;"></div>
        <div id="cal-empty" style="display:none;text-align:center;
             padding: var(--space-6); opacity:0.6;">
          No soccer events from Google Calendar in this window.
        </div>
        <div id="cal-groups" style="display:none;"></div>

        <p style="opacity:0.55; font-size:0.8rem; margin-top: var(--space-4);
                  text-align:center; line-height:1.5;">
          Football Home mirrors soccer events from <code>soccer@lighthouse1893.org</code> +
          <code>sports@lighthouse1893.org</code>. Google Calendar owns timing and tags;
          FH translates classified events into kind, team, opponent, and roster state.
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
      const navBtn = e.target.closest('[data-cal-nav]');
      if (navBtn) {
        this._moveAnchor(navBtn.getAttribute('data-cal-nav'));
        return;
      }
      const viewBtn = e.target.closest('[data-cal-view]');
      if (viewBtn) {
        const nextView = viewBtn.getAttribute('data-cal-view');
        if (['week', 'month', 'agenda'].includes(nextView)) {
          this.view = nextView;
          try { localStorage.setItem('cal-view', this.view); } catch (_) {}
          this._load();
        }
        return;
      }
    });
  }

  // ---------- data ----------

  async _load() {
    if (this.loading) return;
    this.loading = true;
    this._renderLoading();
    try {
      const range = this._queryRange();
      this.days = range.days;
      const start = encodeURIComponent(range.start.toISOString());
      const res = await this.auth.fetch(`/api/calendar/upcoming?start=${start}&days=${range.days}&include_unclassified=1`);
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
    const viewTabs = this.element.querySelectorAll('[data-cal-view]');
    viewTabs.forEach(btn => {
      const active = btn.getAttribute('data-cal-view') === this.view;
      btn.style.background = active ? '#1e3a8a' : '';
      btn.style.color = active ? '#dbeafe' : '';
      btn.style.borderColor = active ? '#3b82f6' : '';
      btn.setAttribute('aria-pressed', active ? 'true' : 'false');
    });
    const rangeLabel = this.find('#cal-range-label');
    if (rangeLabel) rangeLabel.textContent = this._rangeLabel();
  }

  _renderGroups() {
    this.find('#cal-loading').style.display = 'none';
    this.find('#cal-error').style.display   = 'none';

    if (!this.events.length && this.view === 'agenda') {
      this.find('#cal-empty').style.display  = '';
      this.find('#cal-groups').style.display = 'none';
      return;
    }

    const host = this.find('#cal-groups');
    host.innerHTML = this.view === 'month'
      ? this._renderMonthGrid()
      : this.view === 'agenda'
        ? this._renderAgenda()
        : this._renderWeekGrid();
    this.find('#cal-empty').style.display  = 'none';
    host.style.display = '';
  }

  _renderMonthGrid() {
    const anchor = this.anchorDate;
    const first = new Date(anchor.getFullYear(), anchor.getMonth(), 1);
    const gridStart = new Date(first);
    gridStart.setDate(first.getDate() - first.getDay());
    const todayKey = this._dateKey(new Date());
    const monthLabel = first.toLocaleDateString(undefined, { month: 'long', year: 'numeric' });
    const days = Array.from({ length: 42 }, (_, i) => {
      const day = new Date(gridStart);
      day.setDate(gridStart.getDate() + i);
      return day;
    });
    return `
      <section style="margin-bottom: var(--space-5);">
        <div style="display:flex;align-items:flex-end;justify-content:space-between;
                    gap:var(--space-3);margin-bottom:var(--space-2);">
          <div>
            <h3 style="margin:0; font-size:1.05rem; letter-spacing:0.02em;">${this._escape(monthLabel)}</h3>
            <div style="opacity:0.65;font-size:0.85rem;">Google soccer events; FH details when classified</div>
          </div>
          <div style="opacity:0.65;font-size:0.85rem;">${this.count} event${this.count === 1 ? '' : 's'}</div>
        </div>
        <div style="display:grid;grid-template-columns:repeat(7, minmax(118px, 1fr));
                    gap:1px;background:var(--color-border);border:1px solid var(--color-border);
                    border-radius:var(--radius-md);overflow:auto;">
          ${['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(label => `
            <div style="min-width:118px;background:#111827;color:#cbd5e1;padding:7px 8px;
                        font-size:0.76rem;font-weight:700;text-transform:uppercase;letter-spacing:0.05em;">
              ${label}
            </div>`).join('')}
          ${days.map(day => this._renderMonthCell(day, first.getMonth(), todayKey)).join('')}
        </div>
      </section>
    `;
  }

  _renderMonthCell(day, visibleMonth, todayKey) {
    const key = this._dateKey(day);
    const events = this.events.filter(ev => this._dateKey(new Date(ev.starts_at)) === key);
    const muted = day.getMonth() !== visibleMonth;
    const isToday = key === todayKey;
    return `
      <div style="min-width:118px;min-height:116px;background:var(--bg-secondary);
                  padding:7px;display:flex;flex-direction:column;gap:5px;
                  opacity:${muted ? '0.45' : '1'};">
        <div style="display:flex;align-items:center;justify-content:space-between;gap:6px;">
          <span style="display:inline-flex;align-items:center;justify-content:center;
                       min-width:24px;height:24px;border-radius:999px;
                       background:${isToday ? '#1e3a8a' : 'transparent'};
                       color:${isToday ? '#dbeafe' : 'var(--text-primary)'};
                       font-size:0.82rem;font-weight:700;">
            ${day.getDate()}
          </span>
          ${events.length ? `<span style="opacity:0.55;font-size:0.72rem;">${events.length}</span>` : ''}
        </div>
        <div style="display:flex;flex-direction:column;gap:4px;">
          ${events.slice(0, 4).map(ev => this._renderMonthEvent(ev)).join('')}
          ${events.length > 4 ? `<div style="opacity:0.65;font-size:0.72rem;">+${events.length - 4} more</div>` : ''}
        </div>
      </div>
    `;
  }

  _renderMonthEvent(ev) {
    const meta = this._eventMeta(ev);
    const startD = new Date(ev.starts_at);
    const timeLbl = ev.all_day
      ? 'All day'
      : startD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
    return `
      <div class="cal-month-event" data-gcal-event-id="${ev.gcal_event_id}"
           style="border-left:3px solid ${meta.color.bg};background:${meta.color.bg}1f;
                  border-radius:4px;padding:4px 5px;line-height:1.2;">
        <div style="font-size:0.67rem;color:${meta.color.fg};font-weight:700;">${this._escape(timeLbl)} · ${this._escape(meta.kindText)}</div>
        <div style="font-size:0.72rem;font-weight:650;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${this._escape(meta.title)}</div>
      </div>
    `;
  }

  _renderWeekGrid() {
    const days = this._visibleWeekDays();
    const todayKey = this._dateKey(new Date());
    return `
      <section style="margin-bottom: var(--space-5);">
        <div style="display:flex;align-items:flex-end;justify-content:space-between;
                    gap:var(--space-3);margin-bottom:var(--space-2);">
          <div>
            <h3 style="margin:0; font-size:1.05rem; letter-spacing:0.02em;">Week</h3>
            <div style="opacity:0.65;font-size:0.85rem;">Google soccer events; FH details when classified</div>
          </div>
          <div style="opacity:0.65;font-size:0.85rem;">${this.count} event${this.count === 1 ? '' : 's'}</div>
        </div>
        <div style="display:grid;grid-template-columns:repeat(7, minmax(150px, 1fr));
                    gap:1px;background:var(--color-border);border:1px solid var(--color-border);
                    border-radius:var(--radius-md);overflow:auto;">
          ${days.map(day => this._renderDayColumn(day, todayKey)).join('')}
        </div>
      </section>
    `;
  }

  _renderDayColumn(day, todayKey) {
    const key = this._dateKey(day);
    const events = this.events.filter(ev => this._dateKey(new Date(ev.starts_at)) === key);
    const isToday = key === todayKey;
    const label = day.toLocaleDateString(undefined, { weekday: 'short' });
    const num = day.toLocaleDateString(undefined, { month: 'numeric', day: 'numeric' });
    return `
      <div style="min-width:150px;background:var(--bg-secondary);display:flex;flex-direction:column;min-height:360px;">
        <div style="position:sticky;top:0;z-index:1;padding:8px 10px;border-bottom:1px solid var(--color-border);
                    background:${isToday ? '#1e3a8a' : 'var(--bg-secondary)'};
                    color:${isToday ? '#dbeafe' : 'var(--text-primary)'};">
          <div style="font-weight:700;font-size:0.85rem;">${this._escape(label)}</div>
          <div style="opacity:0.75;font-size:0.78rem;">${this._escape(num)}</div>
        </div>
        <div style="padding:8px;display:flex;flex-direction:column;gap:8px;">
          ${events.length ? events.map(ev => this._renderWeekBlock(ev)).join('') : '<div style="opacity:0.35;font-size:0.8rem;padding:8px;">No events</div>'}
        </div>
      </div>
    `;
  }

  _renderAgenda() {
    // Bucket by calendar date in the user's local zone.
    // Buckets: Today, Tomorrow, This week (rest of), Next week, Later.
    const now = this.anchorDate;
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

    const html = groups
      .filter(g => g.events.length)
      .map(g => this._renderGroup(g))
      .join('');
    if (!html) return '';
    return `
      <section>
        <h3 style="margin: 0 0 var(--space-2); opacity:0.9;
                   font-size:1.05rem; letter-spacing:0.02em;">Agenda</h3>
        ${html}
      </section>
    `;
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
    const meta = this._eventMeta(ev);
    const startD = new Date(ev.starts_at);
    const endD   = new Date(ev.ends_at);
    const dayLbl = startD.toLocaleDateString(undefined,
      { weekday: 'short', month: 'short', day: 'numeric' });
    const timeLbl = ev.all_day
      ? 'All day'
      : `${startD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}` +
        ` – ${endD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;

    const kc = meta.color;
    const teams = meta.teams;
    const kindLabel = meta.kindLabel;

    // Compact team chip strip below the kind pill — shows which
    // rosters this event is attached to.  Only rendered when there
    // are teams; keeps single-team events visually quiet by putting
    // the team name inline with the kind pill instead.
    let teamStrip = '';
    if (teams.length === 1) {
      teamStrip = `
        <div style="opacity:0.7; font-size:0.8rem;">
          👥 ${this._escape(teams[0].name)}
        </div>`;
    } else if (teams.length > 1) {
      teamStrip = `
        <div style="display:flex; gap:4px; flex-wrap:wrap;">
          ${teams.map(t => `
            <span style="padding:1px 8px; border-radius:9999px;
                         background:#1f2937; color:#cbd5e1;
                         font-size:0.75rem; border:1px solid var(--color-border);">
              ${this._escape(t.name)}
            </span>`).join('')}
        </div>`;
    }

    // fh_notes (from `Notes:` DSL tag) rendered as a plain-text block.
    // Preserves user newlines via CSS white-space so multi-line notes
    // like "Bring water\nNo cleats" render on separate visual lines.
    const notesBlock = ev.fh_notes ? `
      <div style="opacity:0.85; font-size:0.9rem; padding: 6px 10px;
                  border-left: 3px solid #64748b; background:#0f172a;
                  border-radius:4px; white-space:pre-wrap;">
        📝 ${this._escape(ev.fh_notes)}
      </div>` : '';

    // Google Meet button when the underlying gcal event has a Meet
    // attached.
    const meetBlock = ev.hangout_link ? `
      <a href="${this._escape(ev.hangout_link)}" target="_blank" rel="noopener"
         style="display:inline-block; padding:6px 12px; border-radius:6px;
                background:#065f46; color:#d1fae5; font-size:0.85rem;
                font-weight:600; text-decoration:none;">
        📹 Join Meet
      </a>` : '';

    const gcalLink = ev.html_link
      ? `<a href="${this._escape(ev.html_link)}" target="_blank" rel="noopener"
            style="color:#93c5fd; font-size:0.85rem; text-decoration:none;">
           Open in Google Calendar ↗
         </a>`
      : '';

    return `
      <div class="cal-card" data-gcal-event-id="${ev.gcal_event_id}"
           style="background: var(--bg-secondary);
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
          ${this._escape(meta.title)}
        </div>
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:6px;font-size:0.82rem;">
          <div style="opacity:0.82;">FH kind: <strong>${this._escape(meta.kindText)}</strong></div>
          <div style="opacity:0.82;">Scope: <strong>${this._escape(meta.scopeText)}</strong></div>
          ${meta.homeAway ? `<div style="opacity:0.82;">Home/Away: <strong>${this._escape(meta.homeAway)}</strong></div>` : ''}
          ${meta.opponent ? `<div style="opacity:0.82;">Opponent: <strong>${this._escape(meta.opponent)}</strong></div>` : ''}
        </div>
        ${teamStrip}
        <div style="opacity:0.8; font-size:0.9rem;">
          🕒 ${this._escape(timeLbl)}
        </div>
        ${ev.location ? `
          <div style="opacity:0.8; font-size:0.9rem;">
            📍 ${this._escape(ev.location)}
          </div>` : ''}
        ${notesBlock}
        ${meetBlock}
        ${ev.description ? `
          <details style="margin-top:2px;opacity:0.82;font-size:0.82rem;">
            <summary style="cursor:pointer;color:#93c5fd;">Raw Google description</summary>
            <div style="white-space:pre-wrap;margin-top:4px;color:var(--text-muted);">${this._escape(ev.description)}</div>
          </details>` : ''}
        ${gcalLink ? `<div style="margin-top:auto; padding-top: var(--space-1);">${gcalLink}</div>` : ''}
      </div>
    `;
  }

  _renderWeekBlock(ev) {
    const meta = this._eventMeta(ev);
    const startD = new Date(ev.starts_at);
    const endD = new Date(ev.ends_at);
    const timeLbl = ev.all_day
      ? 'All day'
      : `${startD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}–${endD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;
    return `
      <div class="cal-week-event" data-gcal-event-id="${ev.gcal_event_id}"
           style="border-left:4px solid ${meta.color.bg};background:${meta.color.bg}18;
                  border-radius:6px;padding:7px 8px;display:flex;flex-direction:column;gap:3px;">
        <div style="font-size:0.72rem;font-weight:700;color:${meta.color.fg};text-transform:uppercase;letter-spacing:0.04em;">
          ${this._escape(timeLbl)} · ${this._escape(meta.kindText)}
        </div>
        <div style="font-weight:700;font-size:0.86rem;line-height:1.25;">${this._escape(meta.title)}</div>
        <div style="font-size:0.75rem;opacity:0.75;line-height:1.25;">${this._escape(meta.scopeText)}</div>
        ${meta.opponent ? `<div style="font-size:0.75rem;opacity:0.75;line-height:1.25;">vs ${this._escape(meta.opponent)}</div>` : ''}
      </div>
    `;
  }

  _eventMeta(ev) {
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const kindColors = {
      pickup:   { bg: '#1e3a8a', fg: '#dbeafe' },
      practice: { bg: '#064e3b', fg: '#d1fae5' },
      match:    { bg: '#7f1d1d', fg: '#fecaca' },
      meeting:  { bg: '#334155', fg: '#e2e8f0' },
      camp:     { bg: '#78350f', fg: '#fed7aa' },
      other:    { bg: '#334155', fg: '#e2e8f0' },
    };
    const kind = ev.kind || 'other';
    const kindText = this._titleCase(kind);
    let scopeText = ev.category || '';
    if (!scopeText && teams.length) {
      const cats = [...new Set(teams.map(t => t.gender_category).filter(Boolean))];
      scopeText = cats.join(' + ');
    }
    if (!scopeText) scopeText = 'Club';
    const kindLabel = `${kind}${scopeText ? ` · ${scopeText}` : ''}`;
    const homeAway = ev.is_home === true ? 'Home' : ev.is_home === false ? 'Away' : '';
    return {
      teams,
      kindText,
      kindLabel,
      scopeText: this._titleCase(scopeText.replaceAll('_', ' ')),
      color: kindColors[kind] || kindColors.other,
      title: this._soccerTitle(ev),
      opponent: ev.opponent || this._inferOpponent(ev),
      homeAway,
    };
  }

  _soccerTitle(ev) {
    const raw = (ev.summary || '').trim();
    if (!raw) return '(untitled soccer event)';
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    if (ev.kind === 'match' && teams.length === 1) {
      const opponent = ev.opponent || this._inferOpponent(ev);
      if (opponent) return `${teams[0].name} vs ${opponent}`;
    }
    return raw;
  }

  _inferOpponent(ev) {
    if (ev.kind !== 'match') return '';
    const raw = (ev.summary || '').trim();
    if (!raw) return '';
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const homeTeam = teams.length === 1 ? teams[0].name : '';
    const parts = raw.split(/\s+(?:vs\.?|v\.?|@|at)\s+/i).map(p => p.trim()).filter(Boolean);
    if (parts.length < 2) return '';
    if (homeTeam) {
      const normalizedHome = homeTeam.toLowerCase();
      const other = parts.find(p => !normalizedHome.includes(p.toLowerCase()) && !p.toLowerCase().includes(normalizedHome));
      if (other) return other;
    }
    return parts[parts.length - 1];
  }

  _visibleWeekDays() {
    const anchor = this.anchorDate;
    const start = new Date(anchor.getFullYear(), anchor.getMonth(), anchor.getDate());
    start.setDate(start.getDate() - start.getDay());
    return Array.from({ length: 7 }, (_, i) => {
      const day = new Date(start);
      day.setDate(start.getDate() + i);
      return day;
    });
  }

  _dateKey(d) {
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }

  _moveAnchor(direction) {
    const next = new Date(this.anchorDate);
    if (direction === 'today') {
      this.anchorDate = this._startOfDay(new Date());
      this._load();
      return;
    }
    const delta = direction === 'next' ? 1 : direction === 'prev' ? -1 : 0;
    if (!delta) return;
    if (this.view === 'month') {
      next.setMonth(next.getMonth() + delta);
    } else if (this.view === 'week') {
      next.setDate(next.getDate() + (delta * 7));
    } else {
      next.setDate(next.getDate() + (delta * 30));
    }
    this.anchorDate = this._startOfDay(next);
    this._load();
  }

  _queryRange() {
    if (this.view === 'month') {
      const first = new Date(this.anchorDate.getFullYear(), this.anchorDate.getMonth(), 1);
      const start = new Date(first);
      start.setDate(first.getDate() - first.getDay());
      return { start, days: 42 };
    }
    if (this.view === 'week') {
      const days = this._visibleWeekDays();
      return { start: days[0], days: 7 };
    }
    return { start: this._startOfDay(this.anchorDate), days: 90 };
  }

  _rangeLabel() {
    if (this.view === 'month') {
      return this.anchorDate.toLocaleDateString(undefined, { month: 'long', year: 'numeric' });
    }
    const range = this._queryRange();
    const end = new Date(range.start);
    end.setDate(range.start.getDate() + range.days - 1);
    const startText = range.start.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
    const endText = end.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
    return `${startText} – ${endText}`;
  }

  _startOfDay(d) {
    return new Date(d.getFullYear(), d.getMonth(), d.getDate());
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

  _titleCase(s) {
    return String(s || '')
      .split(/\s+/)
      .filter(Boolean)
      .map(part => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' ');
  }
}
