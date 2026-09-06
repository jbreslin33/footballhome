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
//         tag_issues:       [string, ...] // [] when fully tagged
//       }, ...] }
//
// tag_issues is the tag audit: gcal-classify.js accepts an under-tagged
// description (missing `Type:` → kind is inferred from the team names;
// a misspelled (Club, Team) pair → attaches no roster) without any
// visible complaint, so this screen is where ops finds out.  Each
// string names the variable to add.  Agenda cards render the full list;
// the week/month grids show a ⚠ with the text in a tooltip.
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

        <div id="cal-push-banner"></div>
        <div id="cal-release-strip"></div>

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
    this._wireReleaseStrip();
    this._load();
    // Push opt-in banner (owner 2026-09-05). Magic-link verify lands
    // people here, so this is the first screen a new parent sees; the
    // shared PushOptIn component shows the banner only when this
    // browser can subscribe and hasn't yet.
    if (window.PushOptIn) {
      window.PushOptIn.mount(this.find('#cal-push-banner'), this.auth)
        .catch((err) => console.warn('[calendar] push banner failed:', err));
    }
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
      // Clicking a link/summary inside a card (Meet, gcal link, raw
      // description toggle) should do that, not open the action menu.
      if (e.target.closest('a, summary')) return;

      const eventEl = e.target.closest('[data-gcal-event-id]');
      if (eventEl) {
        this._openEventActions(eventEl.dataset.gcalEventId);
        return;
      }
    });
  }

  // Small "what do you want to do with this event" menu — same options
  // regardless of which view (week/month/agenda) the event was clicked in.
  _openEventActions(gcalEventId) {
    // Admin-only menu (Game Day posts, flyers, results). The screen is
    // reachable by every role now; players/parents RSVP on #my.
    if (!this._isAdmin()) return;
    const ev = this.events.find(e => String(e.gcal_event_id) === String(gcalEventId));
    if (!ev) return;
    const s = this._publicEventSummary(ev);
    const isMatch = ev.kind === 'match';

    // Matches get three specific post types instead of one generic
    // button. Lineup is shown but not wired yet — setting a lineup for
    // a gcal-sourced match needs its own rework first. Game Result
    // always prompts for the score/scorers: there's no scrape/result
    // lookup wired to gcal-sourced matches today (the league scraper
    // only knows about the separate, mostly-unused `matches` table).
    const buttonsHtml = isMatch ? `
        <button type="button" class="btn btn-primary ea-announce-btn" style="text-align:left;">📣 Game Announcement</button>
        <button type="button" class="btn btn-primary ea-lineup-btn" style="text-align:left;">📋 Lineup Post</button>
        <button type="button" class="btn btn-primary ea-result-btn" style="text-align:left;">🏆 Game Result</button>
      ` : `
        <button type="button" class="btn btn-primary ea-post-btn" style="text-align:left;">📷 Make Instagram Post</button>
      `;

    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.innerHTML = `
      <div class="modal-content" style="max-width: 380px;">
        <div class="modal-header">
          <h2>${this._escape(s.title)}${s.subtitle ? ' — ' + this._escape(s.subtitle) : ''}</h2>
          <button class="modal-close" data-action="close">&times;</button>
        </div>
        <p style="opacity:0.7; font-size:0.9rem; margin-top:-8px;">${this._escape(s.dateStr)}${s.timeStr ? ' · ' + this._escape(s.timeStr) : ''}</p>
        <div style="display:flex; flex-direction:column; gap:8px;">
          ${buttonsHtml}
          <button type="button" class="btn btn-secondary ea-flyer-btn" style="text-align:left;">🖨️ Make Flyer</button>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.closest('[data-action="close"]')) close();
    });
    overlay.querySelector('.ea-flyer-btn').addEventListener('click', () => {
      close();
      this._startFlyerFromEvent(gcalEventId);
    });

    if (isMatch) {
      overlay.querySelector('.ea-announce-btn').addEventListener('click', () => {
        close();
        this._startPostFromEvent(gcalEventId);
      });
      overlay.querySelector('.ea-lineup-btn').addEventListener('click', () => {
        close();
        if (!ev.match_id) {
          alert('This match hasn\'t been linked to a lineup yet — it may be missing a team tag in the calendar sync.');
          return;
        }
        this.navigation.goTo('game-center', {
          matchId: ev.match_id,
          title: s.title,
          when: [s.dateStr, s.timeStr].filter(Boolean).join(' · '),
        });
      });
      overlay.querySelector('.ea-result-btn').addEventListener('click', () => {
        close();
        this._openResultForm(gcalEventId);
      });
    } else {
      overlay.querySelector('.ea-post-btn').addEventListener('click', () => {
        close();
        this._startPostFromEvent(gcalEventId);
      });
    }
  }

  // ---------- Post / Flyer prefill ----------

  // Public-safe summary of an event — never touches ev.summary (raw
  // gcal title is admin-only), only kind/category/opponent/date/time/
  // location, same fields already shown on the card itself.
  _publicEventSummary(ev) {
    const meta = this._eventMeta(ev);
    const startD = new Date(ev.starts_at);
    const dateStr = startD.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
    const timeStr = ev.all_day ? '' : startD.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
    // Matches often carry several squad-level teams for the same game
    // (e.g. APSL + APSL Reserves + Liga 1 Trialists all on one event) —
    // exact team name only makes sense for the single-team case;
    // otherwise fall back to the club-wide "Lighthouse" branding
    // already used everywhere else (#Lighthouse1893). Logo still picks
    // the first linked team that actually has one, regardless of count.
    const teamName = meta.teams.length === 1 ? meta.teams[0].name : (meta.teams.length ? 'Lighthouse' : '');
    const teamWithLogo = meta.teams.find(t => t.logo_url);

    let title, subtitle;
    if (ev.kind === 'match') {
      title = meta.homeAway === 'Away' ? 'AWAY MATCH' : 'GAME DAY';
      subtitle = meta.opponent ? `vs ${meta.opponent}` : teamName;
    } else {
      title = meta.kindText.toUpperCase();
      subtitle = teamName;
    }

    return {
      kind: ev.kind,
      title,
      subtitle,
      badge: teamName || meta.scopeText,
      dateStr,
      timeStr,
      location: ev.location || '',
      teamName,
      teamLogo: teamWithLogo ? (teamWithLogo.logo_url || '') : '',
      opponent: meta.opponent || '',
      opponentLogo: ev.opponent_logo_url || '',
    };
  }

  _startPostFromEvent(gcalEventId) {
    const ev = this.events.find(e => String(e.gcal_event_id) === String(gcalEventId));
    if (!ev) return;
    const s = this._publicEventSummary(ev);
    const lines = [`⚽ ${s.title}!`, ''];
    if (s.subtitle) lines.push(s.subtitle);
    lines.push(`📅 ${s.dateStr}`);
    if (s.timeStr) lines.push(`⏰ ${s.timeStr}`);
    if (s.location) lines.push(`📍 ${s.location}`);
    lines.push('', '#Lighthouse1893 #PhillySoccer');

    this.navigation.context.contentPrefill = {
      title: `${s.title}${s.subtitle ? ' - ' + s.subtitle : ''}`,
      caption: lines.join('\n'),
      matchGraphic: s.kind === 'match' ? {
        eyebrow: s.title,
        ourName: s.teamName || 'Lighthouse',
        ourLogo: s.teamLogo,
        opponent: s.opponent || 'Opponent',
        opponentLogo: s.opponentLogo,
        dateStr: s.dateStr,
        timeStr: s.timeStr,
        location: s.location,
      } : null,
    };
    this.navigation.goTo('content-posts', {});
  }

  _startFlyerFromEvent(gcalEventId) {
    const ev = this.events.find(e => String(e.gcal_event_id) === String(gcalEventId));
    if (!ev) return;
    const s = this._publicEventSummary(ev);
    const pills = [
      { icon: '📅', label: 'Date', value: s.dateStr },
    ];
    if (s.timeStr) pills.push({ icon: '🕒', label: 'Time', value: s.timeStr });
    if (s.location) pills.push({ icon: '📍', label: 'Location', value: s.location });

    this.navigation.context.flyerPrefill = {
      badge: s.badge,
      eyebrow: s.kind === 'match' ? (s.title === 'AWAY MATCH' ? 'Away Match' : 'Game Day') : this._titleCase(s.kind),
      title: s.title,
      subtitle: s.subtitle,
      pills,
    };
    this.navigation.goTo('flyers', {});
  }

  // No result-lookup exists for gcal-sourced matches yet (the league
  // scraper only writes to the separate `matches` table — see
  // EventController::handleSyncLeague), so this always prompts rather
  // than trying to auto-fill a score.
  _openResultForm(gcalEventId) {
    const ev = this.events.find(e => String(e.gcal_event_id) === String(gcalEventId));
    if (!ev) return;
    const s = this._publicEventSummary(ev);

    const overlay = document.createElement('div');
    overlay.className = 'modal-overlay';
    overlay.innerHTML = `
      <div class="modal-content" style="max-width: 420px;">
        <div class="modal-header">
          <h2>🏆 Game Result</h2>
          <button class="modal-close" data-action="close">&times;</button>
        </div>
        <p style="opacity:0.7; font-size:0.9rem; margin-top:-8px;">${this._escape(s.subtitle || s.title)} · ${this._escape(s.dateStr)}</p>
        <div style="display:flex; flex-direction:column; gap:12px;">
          <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
            <div>
              <label style="display:block; font-weight:600; margin-bottom:4px; font-size:0.9rem;">Our score</label>
              <input type="number" id="rf-our-score" class="form-input" min="0" style="width:100%; box-sizing:border-box;">
            </div>
            <div>
              <label style="display:block; font-weight:600; margin-bottom:4px; font-size:0.9rem;">Their score</label>
              <input type="number" id="rf-their-score" class="form-input" min="0" style="width:100%; box-sizing:border-box;">
            </div>
          </div>
          <div>
            <label style="display:block; font-weight:600; margin-bottom:4px; font-size:0.9rem;">Scorers <span style="font-weight:400; opacity:0.6;">— optional, one per line</span></label>
            <textarea id="rf-scorers" class="form-input" rows="3" style="width:100%; box-sizing:border-box; resize:vertical;" placeholder="e.g. J. Smith\nOG"></textarea>
          </div>
          <button type="button" id="rf-generate-btn" class="btn btn-primary">Generate Post</button>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => {
      if (e.target === overlay || e.target.closest('[data-action="close"]')) close();
    });

    overlay.querySelector('#rf-generate-btn').addEventListener('click', () => {
      const ourScore = parseInt(overlay.querySelector('#rf-our-score').value, 10);
      const theirScore = parseInt(overlay.querySelector('#rf-their-score').value, 10);
      if (Number.isNaN(ourScore) || Number.isNaN(theirScore)) {
        alert('Enter both scores.');
        return;
      }
      const scorers = (overlay.querySelector('#rf-scorers').value || '')
        .split('\n').map(l => l.trim()).filter(Boolean);

      const resultLabel = ourScore > theirScore ? 'WIN' : ourScore < theirScore ? 'LOSS' : 'DRAW';
      const result = { WIN: '🟢 WIN', LOSS: '🔴 LOSS', DRAW: '🟡 DRAW' }[resultLabel];
      const opponent = s.subtitle ? s.subtitle.replace(/^vs\s*/i, '') : 'Opponent';
      const lines = [
        result,
        '',
        `${s.badge || 'Lighthouse'} ${ourScore} - ${theirScore} ${opponent}`,
        `📅 ${s.dateStr}`,
      ];
      if (s.location) lines.push(`📍 ${s.location}`);
      if (scorers.length) {
        lines.push('');
        scorers.forEach(sc => lines.push(`⚽ ${sc}`));
      }
      lines.push('', '#Lighthouse1893 #PhillySoccer');

      close();
      this.navigation.context.contentPrefill = {
        title: `Result - ${s.badge || 'Lighthouse'} ${ourScore}-${theirScore} ${opponent}`,
        caption: lines.join('\n'),
        resultGraphic: {
          result: resultLabel,
          ourName: s.teamName || s.badge || 'Lighthouse',
          ourLogo: s.teamLogo,
          ourScore,
          opponent,
          opponentLogo: s.opponentLogo,
          theirScore,
          dateStr: s.dateStr,
          location: s.location,
          scorers,
        },
      };
      this.navigation.goTo('content-posts', {});
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
      this._loadReleaseStrip().catch((err) => console.warn('[calendar] release strip failed:', err));
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
                  border-radius:4px;padding:4px 5px;line-height:1.2;cursor:pointer;">
        <div style="font-size:0.67rem;color:${meta.color.fg};font-weight:700;">${this._escape(timeLbl)} · ${this._escape(meta.kindText)}</div>
        <div style="font-size:0.72rem;font-weight:650;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${this._tagIssuesMark(ev)}${this._escape(meta.title)}</div>
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
    // (see _tagIssuesBlock below for the tag-audit panel)
    // Preserves user newlines via CSS white-space so multi-line notes
    // like "Bring water\nNo cleats" render on separate visual lines.
    const notesBlock = ev.fh_notes ? `
      <div style="opacity:0.85; font-size:0.9rem; padding: 6px 10px;
                  border-left: 3px solid #64748b; background:#0f172a;
                  border-radius:4px; white-space:pre-wrap;">
        📝 ${this._escape(ev.fh_notes)}
      </div>` : '';

    // Tag audit (tag_issues from /api/calendar/upcoming).  The
    // classifier is forgiving — a description missing `Type:` still
    // classifies, because kind gets inferred from the team names, and
    // a misspelled (Club, Team) pair attaches no roster rather than
    // erroring.  Both failures are silent in Google Calendar, so this
    // panel is the only place ops finds out.  Each line names the
    // variable to add, so the fix is a copy-paste back into the gcal
    // description.
    const tagBlock = this._tagIssuesBlock(ev);

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
           padding: var(--space-3); display:flex; flex-direction:column; gap:6px; cursor:pointer;">
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
        ${tagBlock}
        <div style="opacity:0.8; font-size:0.9rem;">
          🕒 ${this._escape(timeLbl)}
        </div>
        ${ev.location ? `
          <div style="opacity:0.8; font-size:0.9rem;">
            📍 ${this._escape(ev.location)}
          </div>` : ''}
        ${notesBlock}
        ${meetBlock}
        ${(ev.description && this._isAdmin()) ? `
          <details style="margin-top:2px;opacity:0.82;font-size:0.82rem;">
            <summary style="cursor:pointer;color:#93c5fd;">Raw Google description</summary>
            <div style="white-space:pre-wrap;margin-top:4px;color:var(--text-muted);">${this._escape(ev.description)}</div>
          </details>` : ''}
        ${gcalLink ? `<div style="margin-top:auto; padding-top: var(--space-1);">${gcalLink}</div>` : ''}
        <div style="opacity:0.5; font-size:0.75rem; padding-top:2px;">Tap card for post / flyer actions →</div>
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
                  border-radius:6px;padding:7px 8px;display:flex;flex-direction:column;gap:3px;cursor:pointer;">
        <div style="font-size:0.72rem;font-weight:700;color:${meta.color.fg};text-transform:uppercase;letter-spacing:0.04em;">
          ${this._escape(timeLbl)} · ${this._escape(meta.kindText)}
        </div>
        <div style="font-weight:700;font-size:0.86rem;line-height:1.25;">${this._tagIssuesMark(ev)}${this._escape(meta.title)}</div>
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

  // Card title. The raw Google title is admin-only text (it is whatever
  // ops typed — "Soccer Games APSL"); now that every role can open this
  // screen, a classified event is titled from its tags: team + opponent
  // for a match, "<Category> <Kind>" otherwise. The raw title survives
  // only for unclassified events, which only admins can see anyway.
  _soccerTitle(ev) {
    const raw   = (ev.summary || '').trim();
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const kind  = ev.kind || 'other';
    const cat   = this._titleCase((ev.category || '').replaceAll('_', ' '));
    if (kind === 'match') {
      const opponent = ev.opponent || this._inferOpponent(ev);
      if (opponent) {
        if (teams.length === 1) return `${teams[0].name} vs ${opponent}`;
        // Several squads share the game (APSL + Liga 1). Lead with the
        // league only when one of the tagged teams is named for it
        // ("APSL vs Feels Good FC"); otherwise the category ("Mens vs
        // Sierra Stars") — a league name alone reads as the opponent's.
        const lg = (ev.league || '').trim();
        const leagueIsTeam = lg && teams.some(t => (t.name || '').toLowerCase().includes(lg.toLowerCase()));
        const lead = (leagueIsTeam ? lg : '') || cat || lg || (teams[0] && teams[0].name) || 'Match';
        return `${lead} vs ${opponent}`;
      }
      if (teams.length) return `${teams.map(t => t.name).join(' + ')} match`;
    }
    if (kind !== 'other' && (teams.length || cat)) {
      const label = `${cat ? cat + ' ' : ''}${this._titleCase(kind)}`;
      return teams.length === 1 ? `${label} · ${teams[0].name}` : label;
    }
    if (!raw) return '(untitled soccer event)';
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
    // Monday-based week (owner 2026-09-05): matches My Schedule and the
    // release model, so Sunday's games sit in the week that posts them.
    start.setDate(start.getDate() - ((start.getDay() + 6) % 7));
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

  // ---------- schedule release strip (migration 334) ----------

  _isAdmin() {
    const role = this.auth && this.auth.user && this.auth.user.role;
    return role === 'club' || role === 'super' || role === 'system';
  }

  // First day of the displayed Mon..Sun week — the release model keys
  // weeks on Monday, same as My Schedule.
  _displayedWeekStartKey() {
    const days = this._visibleWeekDays();
    return this._dateKey(days[0]);
  }

  async _loadReleaseStrip() {
    const el = this.find('#cal-release-strip');
    if (!el) return;
    if (this.view !== 'week') { el.innerHTML = ''; return; }
    const ws = this._displayedWeekStartKey();
    const res = await this.auth.fetch(`/api/schedule/window?week_start=${ws}`);
    if (!res.ok) { el.innerHTML = ''; return; }
    const w = await res.json();
    this._releaseWindow = w;
    el.innerHTML = this._renderReleaseStrip(w);
  }

  _fmtWhen(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d)) return '';
    return `${d.toLocaleDateString(undefined, { weekday: 'short', month: 'numeric', day: 'numeric' })} ${d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;
  }

  _renderReleaseStrip(w) {
    const admin = this._isAdmin();
    const mon = new Date(w.week_start + 'T00:00:00');
    const weekLabel = `Week of ${mon.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })}`;
    const now = Date.now();
    const policyOpens = w.policy_opens_at ? new Date(w.policy_opens_at).getTime() : null;
    const earlyOpen = !!(w.release && !w.release.revoked_at && policyOpens && policyOpens > now);
    const postedNormally = w.open_now && !earlyOpen;

    const base = 'display:flex; align-items:center; gap:10px; flex-wrap:wrap; padding:8px 12px; margin-bottom: var(--space-3); border-radius:8px; font-size:0.85rem;';
    const btn  = 'padding:5px 12px; border-radius:999px; border:1px solid rgba(255,255,255,0.25); background:#2563eb; color:#fff; font-weight:700; font-size:0.8rem; cursor:pointer;';
    const link = 'background:none; border:none; color:#bfdbfe; text-decoration:underline; cursor:pointer; font-size:0.78rem; padding:2px 4px;';

    let body;
    if (postedNormally) {
      body = `
        <span>✅ <strong>${this._escape(weekLabel)}</strong> is posted. It opened
          ${this._escape(this._fmtWhen(w.opens_at))}${w.policy ? ` (rule: ${this._escape(w.policy.label)})` : ''}.
          Use › to reach a week that hasn't posted yet.</span>`;
    } else if (earlyOpen) {
      body = `
        <span>✅ <strong>${this._escape(weekLabel)}</strong> is posted early
          ${w.release.released_by ? `by ${this._escape(w.release.released_by)}` : ''}, ${this._escape(this._fmtWhen(w.release.released_at))}.
          Normal post time was ${this._escape(this._fmtWhen(w.policy_opens_at))}.</span>
        ${admin ? `<button type="button" data-release-close="${w.release.id}" style="${btn} background:#7f1d1d;">Close it again</button>` : ''}`;
    } else {
      body = `
        <span>🕗 <strong>${this._escape(weekLabel)}</strong> posts to players and parents
          <strong>${this._escape(this._fmtWhen(w.opens_at))}</strong>${w.policy ? ` (rule: ${this._escape(w.policy.label)})` : ''}.</span>
        ${admin ? `<button type="button" data-release-open="${this._escape(w.week_start)}" style="${btn}">Open now</button>` : ''}`;
    }

    let policyHtml = '';
    if (admin) {
      if (this._policyEditing) {
        const wd = w.policy ? w.policy.weekday : 0;
        const tm = w.policy ? w.policy.time : '20:00';
        const names = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
        policyHtml = `
          <span style="display:inline-flex; align-items:center; gap:6px; margin-left:auto;">
            <span style="opacity:0.8;">Standing rule:</span>
            <select data-policy-weekday style="font-size:0.8rem; padding:3px 6px;">
              ${names.map((n, i) => `<option value="${i}" ${i === wd ? 'selected' : ''}>${n}</option>`).join('')}
            </select>
            <input type="time" data-policy-time value="${this._escape(tm)}" style="font-size:0.8rem; padding:3px 6px;">
            <button type="button" data-policy-save style="${btn}">Save</button>
            <button type="button" data-policy-cancel style="${link}">Cancel</button>
          </span>`;
      } else {
        policyHtml = `<button type="button" data-policy-edit style="${link} margin-left:auto;">Change the rule</button>`;
      }
    }

    return `
      <div style="${base} background:${(earlyOpen || postedNormally) ? 'rgba(22,101,52,0.25)' : 'rgba(37,99,235,0.18)'}; border:1px solid ${(earlyOpen || postedNormally) ? 'rgba(74,222,128,0.45)' : 'rgba(96,165,250,0.45)'};">
        ${body}${policyHtml}
      </div>`;
  }

  _wireReleaseStrip() {
    if (this._releaseWired) return;
    this._releaseWired = true;
    this.element.addEventListener('click', async (e) => {
      const openBtn  = e.target.closest('[data-release-open]');
      const closeBtn = e.target.closest('[data-release-close]');
      const editBtn  = e.target.closest('[data-policy-edit]');
      const saveBtn  = e.target.closest('[data-policy-save]');
      const cancelBtn= e.target.closest('[data-policy-cancel]');
      if (!openBtn && !closeBtn && !editBtn && !saveBtn && !cancelBtn) return;
      e.preventDefault(); e.stopPropagation();
      try {
        if (openBtn) {
          const ws = openBtn.dataset.releaseOpen;
          const mon = new Date(ws + 'T00:00:00');
          if (!confirm(`Post the week of ${mon.toLocaleDateString(undefined, { month: 'short', day: 'numeric' })} to players and parents now?`)) return;
          openBtn.disabled = true; openBtn.textContent = 'Opening…';
          const res = await this.auth.fetch('/api/schedule/releases', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ week_start: ws }),
          });
          if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error || `HTTP ${res.status}`);
        } else if (closeBtn) {
          if (!confirm('Close this week again? Players and parents will stop seeing it until the normal post time.')) return;
          closeBtn.disabled = true; closeBtn.textContent = 'Closing…';
          const res = await this.auth.fetch(`/api/schedule/releases/${closeBtn.dataset.releaseClose}/revoke`, { method: 'POST' });
          if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error || `HTTP ${res.status}`);
        } else if (editBtn) {
          this._policyEditing = true;
        } else if (cancelBtn) {
          this._policyEditing = false;
        } else if (saveBtn) {
          const wd = this.find('[data-policy-weekday]').value;
          const tm = this.find('[data-policy-time]').value;
          saveBtn.disabled = true; saveBtn.textContent = 'Saving…';
          const res = await this.auth.fetch('/api/schedule/policy', {
            method: 'PUT', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cutover_weekday: String(wd), cutover_time: tm }),
          });
          if (!res.ok) throw new Error((await res.json().catch(() => ({}))).error || `HTTP ${res.status}`);
          this._policyEditing = false;
        }
        await this._loadReleaseStrip();
      } catch (err) {
        console.error('[calendar] release action failed:', err);
        alert(`Could not update the schedule window: ${err.message}`);
        await this._loadReleaseStrip().catch(() => {});
      }
    });
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

  // ---------- tag audit ----------

  // True when the backend flagged this event's Google description as
  // under-tagged.  Drives both the ⚠ marker on the compact week/month
  // chips and the full panel on the agenda card.
  _hasTagIssues(ev) {
    return Array.isArray(ev.tag_issues) && ev.tag_issues.length > 0;
  }

  // Amber panel listing exactly which variables the description is
  // missing.  Rendered only on the agenda card, where there is room for
  // the wording — the grid views get the ⚠ marker and a tooltip.
  _tagIssuesBlock(ev) {
    if (!this._hasTagIssues(ev)) return '';
    return `
      <div style="font-size:0.82rem; padding:6px 10px; border-radius:4px;
                  border-left:3px solid #f59e0b; background:#1c1917;
                  color:#fde68a;">
        <div style="font-weight:600; margin-bottom:2px;">
          ⚠ Google description is missing tags
        </div>
        <ul style="margin:0; padding-left:18px; display:flex;
                   flex-direction:column; gap:2px;">
          ${ev.tag_issues.map(i => `<li>${this._escape(i)}</li>`).join('')}
        </ul>
      </div>`;
  }

  // Compact marker for the week/month grids, where a full panel would
  // not fit.  title= carries the same text so hovering explains it
  // without opening the event.
  _tagIssuesMark(ev) {
    if (!this._hasTagIssues(ev)) return '';
    return `<span title="${this._escape(ev.tag_issues.join(' | '))}"
                  style="color:#fbbf24; font-weight:700;">⚠</span> `;
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
