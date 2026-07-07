// MyScreen — signed-in player's weekly RSVP + recurring preferences + club chat.
//
// Auth: MyController accepts either the fh_sess cookie OR a JWT bearer.
// We use auth.fetch() here so the JWT path works for the standard SPA
// login flow; requests also carry cookies via credentials: 'include'
// so magic-link sessions transparently work too.
//
// Endpoints:
//   GET  /api/my/week           → { player_id, events: [...] }
//   POST /api/my/rsvp           → body { match_id, rsvp_status_id, note? }
//   GET  /api/my/recurring      → { prefs: [...] }
//   PUT  /api/my/recurring      → body { prefs: [{day_of_week, match_type_id, rsvp_status_id}] }
//   GET  /api/my/chat/messages  → { chat_id, messages: [...] }  (optional ?since_id=)
//   POST /api/my/chat/messages  → body { message }
class MyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.week          = null;          // { player_id, events }
    this.prefs         = null;          // Array<{day_of_week, match_type_id, rsvp_status_id, ...}>
    this.mode          = 'week';        // 'week' | 'recurring' | 'chat'
    this.savingId      = null;          // match_id currently being written
    this.errorMsg      = null;
    // RSVP roster expansion — per-event bucketed lists fetched lazily.
    this.rsvpsByMatch    = {};          // { matchId: {counts, going, maybe, not_going, no_response} }
    this.rsvpsLoadingIds = new Set();   // matchIds currently in flight
    this.expandedMatchIds = new Set();  // matchIds whose "who's going" panel is open
    // Chat state.
    this.chatMessages  = [];            // oldest-first list of {id, user_id, person_id, author_first_name, author_last_name, message, created_at}
    this.chatViewerId  = 0;             // server-echoed users.id of the caller — used to decide "mine" vs "theirs"
    this.chatLoaded    = false;
    this.chatSending   = false;
    this.chatError     = null;
    this.chatSendError = null;
    this.chatPollTimer = null;          // setInterval handle for chat polls
    this.chatUnread    = 0;             // count of messages with id > lastSeenId (excluding chat-tab-active)
    this.chatShowJump  = false;         // "▼ new messages" pill shown when new msgs arrive while scrolled up
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
        <div style="display:flex; gap: var(--space-2); margin-bottom: var(--space-3); flex-wrap:wrap;">
          <button class="btn btn-primary tab-btn" data-tab="week">This week</button>
          <button class="btn btn-outline-secondary tab-btn" data-tab="recurring">Weekly availability</button>
          <button class="btn btn-outline-secondary tab-btn" data-tab="chat">Chat<span id="chat-badge" style="display:none; margin-left:6px; background:#dc2626; color:#fff; border-radius:10px; padding:1px 7px; font-size:0.75rem; font-weight:700;"></span></button>
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
    // Prime the chat feed in the background so the tab-button badge
    // can show unread counts even when the user is on the Week or
    // Recurring tab.  Runs on all screens, throttled to a slow poll
    // until the user actually opens the chat tab.
    this._primeChatBackground();
  }

  onExit() {
    this._stopChatPoll();
  }

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
      // Prefetch per-event RSVP rosters so the count summaries and
      // expandable panels populate shortly after cards render.
      this._prefetchAllEventRsvps();
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
        if (this.mode === 'chat') {
          this._enterChat();
        } else {
          // Downshift to background polling so the badge keeps updating
          // even while the user is on Week/Recurring.
          this._startChatPoll(/*background*/ true);
          this._renderChatBadge();
        }
        return;
      }
      const rsvpBtn = e.target.closest('[data-rsvp-match-id]');
      if (rsvpBtn) {
        const matchId = parseInt(rsvpBtn.getAttribute('data-rsvp-match-id'), 10);
        const statusId = parseInt(rsvpBtn.getAttribute('data-status-id'), 10);
        this._submitRsvp(matchId, statusId);
        return;
      }
      const toggleBtn = e.target.closest('[data-toggle-rsvps]');
      if (toggleBtn) {
        const matchId = parseInt(toggleBtn.getAttribute('data-toggle-rsvps'), 10);
        this._toggleEventRsvps(matchId);
        return;
      }
      const prefBtn = e.target.closest('[data-pref-key]');
      if (prefBtn) {
        const [dowStr, mtypeStr] = prefBtn.getAttribute('data-pref-key').split(':');
        const statusId = parseInt(prefBtn.getAttribute('data-status-id'), 10);
        this._togglePref(parseInt(dowStr, 10), parseInt(mtypeStr, 10), statusId);
        return;
      }
      if (e.target.closest('#chat-send-btn')) {
        this._sendChatMessage();
        return;
      }
      if (e.target.closest('#chat-jump')) {
        this.chatShowJump = false;
        this._renderChat({ scroll: 'bottom' });
        const maxId = this.chatMessages.length ? this.chatMessages[this.chatMessages.length - 1].id : 0;
        if (maxId) this._setLastSeenId(maxId);
        return;
      }
    });
    // Enter to send (Shift+Enter → newline).  Attached via delegation
    // so re-renders don't lose the handler.
    this.element.addEventListener('keydown', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this._sendChatMessage();
      }
    });
    // Auto-grow the chat textarea + toggle send-button enabled state as they type.
    this.element.addEventListener('input', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      ta.style.height = 'auto';
      ta.style.height = Math.min(ta.scrollHeight, 140) + 'px';
      const btn = this.find('#chat-send-btn');
      if (btn) btn.disabled = this.chatSending || !ta.value.trim();
    });
    // If they scroll back to the bottom, clear the jump-to-bottom pill and mark seen.
    this.element.addEventListener('scroll', (e) => {
      const sc = e.target.closest && e.target.closest('#chat-scroll');
      if (!sc) return;
      if (this.chatShowJump && this._isChatScrolledToBottom()) {
        this.chatShowJump = false;
        const pill = this.find('#chat-jump');
        if (pill) pill.style.display = 'none';
        const maxId = this.chatMessages.length ? this.chatMessages[this.chatMessages.length - 1].id : 0;
        if (maxId) this._setLastSeenId(maxId);
      }
    }, true);
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
    if (this.mode === 'chat')      return this._renderChat();
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

    const banner = this._duesOwedBanner();
    const rsvpBanner = this._rsvpMandatoryBanner();
    const pickupCta = this._pickupSignupCta();

    if (!events.length) {
      // No roster row + we have a pickup signup URL → the CTA IS the
      // whole screen (no "check back after Sunday" copy, since the real
      // reason they see nothing is that they're not registered).
      if (pickupCta) {
        box.innerHTML = banner + pickupCta;
        return;
      }
      box.innerHTML = `
        ${banner}
        <div class="empty-state">
          <p>No upcoming events. Check back after Sunday 8pm — the week rolls over then.</p>
        </div>
      `;
      return;
    }

    box.innerHTML = banner + rsvpBanner + events.map(ev => this._eventCard(ev)).join('');
  }

  // "Register for Pickup" card shown when the caller has no mens roster
  // row at all (membership_status === 'none') and the backend told us
  // where to send them on LeagueApps (pickup_signup_url).  Users with an
  // active/dues-owed row already see their events; paused-only users end
  // up here too, which is intentional — they can re-enter the club
  // through the free pickup tier without paying full dues.
  _pickupSignupCta() {
    if (!this.week) return '';
    if (this.week.membership_status !== 'none') return '';
    const url = this.week.pickup_signup_url;
    if (!url || typeof url !== 'string') return '';
    return `
      <div style="background: rgba(59, 130, 246, 0.08);
                  border: 1px solid rgba(59, 130, 246, 0.35);
                  border-radius: 12px;
                  padding: var(--space-4);
                  margin-bottom: var(--space-3);
                  text-align: center;">
        <div style="font-size: 1.15rem; font-weight: 700;
                    color: #1d4ed8; margin-bottom: var(--space-2);">
          You're almost in!
        </div>
        <div style="color: var(--color-text-secondary);
                    margin-bottom: var(--space-3); line-height: 1.5;">
          Register for free Pickup on LeagueApps to see the weekly schedule
          and RSVP. Takes about 60 seconds — no payment required.
        </div>
        <a href="${this.escapeHtml(url)}" target="_blank" rel="noopener"
           style="display: inline-block;
                  background: #2563eb;
                  color: #fff;
                  padding: 10px 18px;
                  border-radius: 8px;
                  font-weight: 600;
                  text-decoration: none;">
          Register for Pickup →
        </a>
      </div>
    `;
  }

  // Amber banner shown when the caller's mens roster_assignments are all
  // soft-deleted (delinquent dues).  Pickup availability still works —
  // practice and games are the ones filtered out on the backend.
  _duesOwedBanner() {
    if (!this.week || this.week.membership_status !== 'dues_owed') return '';
    const days = this.week.dues_days_overdue || 0;
    const daysStr = days > 0 ? ` (${days} day${days === 1 ? '' : 's'} overdue)` : '';
    return `
      <div style="background: rgba(240, 173, 78, 0.15);
                  border: 1px solid rgba(240, 173, 78, 0.5);
                  border-radius: 8px;
                  padding: var(--space-3);
                  margin-bottom: var(--space-3);
                  color: #f0ad4e;">
        <div style="font-weight: 600; margin-bottom: var(--space-1);">
          ⚠ Dues owed${this.escapeHtml(daysStr)}
        </div>
        <div style="opacity: 0.95;">
          Pay to unlock practice and games. You can still set availability for pickup below.
        </div>
      </div>
    `;
  }

  // 2026-07-06 pm — persistent policy banner shown above the weekly
  // event list.  Mirrors the RSVP-mandatory language in the reminder
  // messages (mens-events-reminders.js plain body + EventReminderController
  // magic-link body) so members see the same policy whether they land
  // here via a reminder link or navigate on their own.  Hidden when the
  // schedule is empty (no events = nothing to RSVP to = the banner
  // would just be noise).
  _rsvpMandatoryBanner() {
    return `
      <div style="background: rgba(59, 130, 246, 0.10);
                  border: 1px solid rgba(59, 130, 246, 0.40);
                  border-radius: 8px;
                  padding: var(--space-3);
                  margin-bottom: var(--space-3);
                  color: #93c5fd;">
        <div style="font-weight: 600; margin-bottom: var(--space-1);">
          📋 RSVP to every event on your schedule
        </div>
        <div style="opacity: 0.95;">
          Set <strong>Going</strong>, <strong>Can't go</strong>, or <strong>Maybe</strong> for each row below.
          It's how we plan rosters, subs, and cancellations — please keep it up to date.
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

    // Explicit "your status" line at the top of the button row — the
    // roster summary further down was previously mistaken for the
    // caller's own RSVP because both used the same green.
    const yourStatusLabel = currentId === 1 ? 'Going'
                          : currentId === 2 ? "Can't go"
                          : currentId === 3 ? 'Maybe'
                          : 'Not set';
    const yourStatusColor = currentId === 1 ? '#16a34a'
                          : currentId === 2 ? '#dc2626'
                          : currentId === 3 ? '#f59e0b'
                          : '#9ca3af';

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

    const rsvpBlock = this._renderEventRsvpBlock(ev.match_id);

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
        <div style="margin-top: var(--space-3); font-size:0.8rem; opacity:0.75;">
          <span style="opacity:0.7;">Your availability:</span>
          <strong style="color:${yourStatusColor};">${this.escapeHtml(yourStatusLabel)}</strong>
        </div>
        <div style="display:flex; gap: var(--space-2); margin-top: var(--space-2);">
          ${btn(1, 'Going',     '#16a34a')}
          ${btn(3, 'Maybe',     '#f59e0b')}
          ${btn(2, "Can't go",  '#dc2626')}
        </div>
        ${rsvpBlock}
      </div>
    `;
  }

  // Compact roster preview + optional expanded panel per event card.
  // Counts line + toggle button are always rendered; the expanded
  // panel with names only appears when the user has clicked "Show
  // who's going" for that match.
  _renderEventRsvpBlock(matchId) {
    const data     = this.rsvpsByMatch[matchId];
    const loading  = this.rsvpsLoadingIds.has(matchId);
    const expanded = this.expandedMatchIds.has(matchId);

    // Summary line — INTENTIONALLY neutral.  We do NOT display the
    // "going" count, names, or any RSVP status word on the collapsed
    // card, because users reported reading roster-level text as if it
    // were their own personal RSVP state.  All status details live
    // inside the expanded panel only.
    let summary;
    if (data) {
      const c = data.counts || {};
      const responded = (c.going || 0) + (c.maybe || 0) + (c.not_going || 0);
      const total     = c.total || (responded + (c.no_response || 0));
      summary = `
        <span style="opacity:0.65; font-size:0.8rem;">
          Team roster: <strong>${responded}</strong> of <strong>${total}</strong> responded
        </span>
      `;
    } else if (loading) {
      summary = `<span style="opacity:0.55;">Loading team roster…</span>`;
    } else {
      summary = `<span style="opacity:0.5;">Tap to see the team roster</span>`;
    }

    const arrow = expanded ? '▲' : '▼';
    const toggleLabel = expanded ? 'Hide' : 'See everyone';

    const expandedBody = (expanded && data) ? `
      <div style="margin-top: var(--space-3); padding-top: var(--space-3);
                  border-top: 1px dashed rgba(255,255,255,0.1);
                  display:grid; grid-template-columns: 1fr 1fr; gap: var(--space-3);">
        ${this._renderRsvpBucket('Going',     data.going,       '#16a34a', '✓')}
        ${this._renderRsvpBucket('Maybe',     data.maybe,       '#f59e0b', '?')}
        ${this._renderRsvpBucket("Can't go",  data.not_going,   '#dc2626', '✕')}
        ${this._renderRsvpBucket('No reply',  data.no_response, '#6b7280', '—')}
      </div>
    ` : (expanded && loading) ? `
      <div style="margin-top: var(--space-3); padding: var(--space-3) 0;
                  opacity:0.55; text-align:center; font-size:0.9rem;">
        Loading roster…
      </div>
    ` : '';

    return `
      <div style="margin-top: var(--space-3); padding-top: var(--space-2);
                  border-top: 1px solid rgba(255,255,255,0.06);
                  display:flex; align-items:center; justify-content:space-between;
                  gap: var(--space-2); flex-wrap:wrap; font-size:0.85rem;">
        <div style="flex:1; min-width:0;">${summary}</div>
        <button data-toggle-rsvps="${matchId}"
                style="background: transparent; color: #93c5fd;
                       border: 1px solid rgba(147,197,253,0.3);
                       border-radius: 4px; padding: 3px 10px;
                       cursor: pointer; font-size: 0.8rem; font-weight:500;
                       flex-shrink:0;">
          ${arrow} ${this.escapeHtml(toggleLabel)}
        </button>
      </div>
      ${expandedBody}
    `;
  }

  _renderRsvpBucket(label, people, color, icon) {
    const items = (people || []);
    if (items.length === 0) {
      return `
        <div>
          <div style="color:${color}; font-weight:600; font-size:0.85rem; margin-bottom:4px;">
            ${icon} ${this.escapeHtml(label)} <span style="opacity:0.55;">(0)</span>
          </div>
          <div style="opacity:0.35; font-size:0.85rem; font-style:italic;">nobody</div>
        </div>
      `;
    }
    const rows = items.map(p => {
      const first = (p.first_name || '').trim();
      const last  = (p.last_name  || '').trim();
      const name  = first || last
        ? this.escapeHtml(first + (last ? ' ' + last : ''))
        : `Person #${p.person_id}`;
      return `<div style="font-size:0.85rem; padding:1px 0;">${name}</div>`;
    }).join('');
    return `
      <div>
        <div style="color:${color}; font-weight:600; font-size:0.85rem; margin-bottom:4px;">
          ${icon} ${this.escapeHtml(label)} <span style="opacity:0.55;">(${items.length})</span>
        </div>
        ${rows}
      </div>
    `;
  }

  // Toggle expanded state for an event's roster panel.  Kicks off a
  // fetch if we haven't cached the data yet.
  _toggleEventRsvps(matchId) {
    if (this.expandedMatchIds.has(matchId)) {
      this.expandedMatchIds.delete(matchId);
    } else {
      this.expandedMatchIds.add(matchId);
      if (!this.rsvpsByMatch[matchId] && !this.rsvpsLoadingIds.has(matchId)) {
        this._fetchEventRsvps(matchId);
      }
    }
    this._renderWeek();
  }

  // Prefetch RSVP rosters for every event in the current week so the
  // count summaries populate shortly after cards render.  Never
  // blocks the initial render — failures are silently ignored.
  _prefetchAllEventRsvps() {
    const events = (this.week && this.week.events) || [];
    for (const ev of events) {
      if (!this.rsvpsByMatch[ev.match_id] && !this.rsvpsLoadingIds.has(ev.match_id)) {
        this._fetchEventRsvps(ev.match_id);
      }
    }
  }

  async _fetchEventRsvps(matchId) {
    this.rsvpsLoadingIds.add(matchId);
    try {
      const res = await this._fetch(`/api/my/event-rsvps?match_id=${encodeURIComponent(matchId)}`);
      this.rsvpsByMatch[matchId] = res;
    } catch (err) {
      // Silent — leave summary as fallback text.
      console.warn('event-rsvps fetch failed', matchId, err);
    } finally {
      this.rsvpsLoadingIds.delete(matchId);
      if (this.mode === 'week') this._renderWeek();
    }
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
            ${cell(1, 'Yes',          '#16a34a')}
            ${cell(3, 'Maybe',        '#f59e0b')}
            ${cell(2, 'No',           '#dc2626')}
            ${cell(0, 'Not Selected', '#4b5563')}
          </div>
        </div>
      `;
    }).join('');

    box.innerHTML = `
      <div style="background: var(--bg-secondary, rgba(255,255,255,0.04));
                  border-radius: 8px; padding: var(--space-3);">
        <p style="margin-top:0; font-weight:600; color:#fbbf24;">
          Pick the <strong>2 days</strong> you're committing to each week.
        </p>
        <p style="margin-top:0; opacity:0.85;">
          Tap <strong>Yes</strong> on the two slots you'll show up for every week — those are your committed days.
          Everyone should have two.  If you can't commit to a slot, leave it on <strong>Not Selected</strong> (the rightmost option) instead of picking Yes.
        </p>
        <p style="margin-top:0; opacity:0.85;">
          Your default RSVP is auto-applied every Sunday at 8&nbsp;PM when the week rolls over.
          If something comes up and you can't make one of your committed days that week, just flip it to <strong>No</strong> or <strong>Maybe</strong> on the
          <a href="#" data-tab="week">This week</a> tab — the auto-RSVP only kicks in for future weeks, not the current one after you've overridden it.
        </p>
        <p style="margin-top:0; opacity:0.75; font-size:0.9rem;">
          <strong>Not Selected</strong> means no default — you'll RSVP manually each week for that slot.
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
      // Invalidate the roster cache for this match so counts + names
      // reflect the caller's new RSVP; refetch in background.
      delete this.rsvpsByMatch[matchId];
      this._fetchEventRsvps(matchId);
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

  // ────── Men's chat ──────────────────────────────────────────────────
  //
  // The Chat tab is a thin polling client over /api/my/chat/messages.
  // Design goals:
  //   - never blocks the RSVP UI on network — chat state is separate
  //   - poll only while the chat tab is the active mode (8s interval)
  //   - initial load pulls last 200 messages (server caps)
  //   - subsequent polls use since_id so we only pay the delta cost
  //   - localStorage tracks the highest-seen message id per user so
  //     the unread badge survives page refresh
  //   - autoscroll to bottom when the user is already at bottom OR
  //     just posted; otherwise leave scroll alone so history-reading
  //     isn't interrupted

  _lastSeenKey() {
    const user = this.auth.getUser && this.auth.getUser();
    const key = user && (user.id || user.email) || 'anon';
    return `fh-mens-chat-last-seen:${key}`;
  }

  _getLastSeenId() {
    try {
      const raw = localStorage.getItem(this._lastSeenKey());
      const n = raw ? parseInt(raw, 10) : 0;
      return Number.isFinite(n) ? n : 0;
    } catch (_e) {
      return 0;
    }
  }

  _setLastSeenId(id) {
    try { localStorage.setItem(this._lastSeenKey(), String(id)); } catch (_e) {}
  }

  // Kick off an initial chat fetch + background poll so the tab-button
  // unread badge reflects new activity even while the user is on the
  // Week or Recurring tabs.  Silently swallows failures — chat outage
  // shouldn't nuke the schedule view.
  async _primeChatBackground() {
    try {
      await this._loadChat(/*initial*/ true);
    } catch (_) { /* ignore */ }
    if (this.mode !== 'chat') this._startChatPoll(/*background*/ true);
  }

  async _enterChat() {
    // Switch from background poll to fast poll.
    this._stopChatPoll();
    // Initial fetch on first entry; subsequent entries just resume polling.
    if (!this.chatLoaded) {
      await this._loadChat(/*initial*/ true);
    } else {
      // Force-render since _loadChat may have quietly cached msgs while
      // we were on another tab.
      this._renderChat({ scroll: 'bottom' });
    }
    // Reset the unread counter — user is looking at chat now.
    this.chatUnread = 0;
    this.chatShowJump = false;
    this._renderChatBadge();
    this._startChatPoll(/*background*/ false);
    // Mark newest visible as seen.
    if (this.chatMessages.length > 0) {
      const maxId = this.chatMessages[this.chatMessages.length - 1].id;
      this._setLastSeenId(maxId);
    }
  }

  _startChatPoll(background) {
    this._stopChatPoll();
    // Fast poll (8s) while the chat tab is open; slower poll (25s) in
    // the background so we still detect new messages for the unread
    // badge without hammering the API.
    const interval = background ? 25000 : 8000;
    this.chatPollTimer = setInterval(() => {
      // Skip when tab hidden — avoid battery drain on backgrounded pages.
      if (document.hidden) return;
      this._loadChat(/*initial*/ false).catch(() => {});
    }, interval);
  }

  _stopChatPoll() {
    if (this.chatPollTimer) {
      clearInterval(this.chatPollTimer);
      this.chatPollTimer = null;
    }
  }

  async _loadChat(initial) {
    const sinceId = initial ? 0 : (this.chatMessages.length > 0
      ? this.chatMessages[this.chatMessages.length - 1].id
      : 0);
    const url = sinceId > 0
      ? `/api/my/chat/messages?since_id=${sinceId}`
      : '/api/my/chat/messages';
    let res;
    try {
      res = await this._fetch(url);
    } catch (err) {
      // Silent on poll failure; surface on initial.
      if (initial) {
        this.chatError = err.message || 'Failed to load chat.';
        this.chatLoaded = true;
        if (this.mode === 'chat') this._renderChat();
      }
      return;
    }
    const incoming = (res && res.messages) || [];
    if (initial) {
      this.chatMessages = incoming;
      this.chatViewerId = (res && res.viewer_user_id) || 0;
      this.chatLoaded = true;
      this.chatError = null;
      if (this.mode === 'chat') {
        // Actively viewing — clear unread and scroll to bottom.
        this.chatUnread = 0;
        this._renderChat({ scroll: 'bottom' });
        if (incoming.length > 0) {
          this._setLastSeenId(incoming[incoming.length - 1].id);
        }
      } else {
        // Background prime — compute unread against last-seen so the
        // tab-button badge can light up on first render.
        const lastSeen = this._getLastSeenId();
        this.chatUnread = incoming.filter(m => m.id > lastSeen).length;
      }
      this._renderChatBadge();
    } else if (incoming.length > 0) {
      const wasAtBottom = this._isChatScrolledToBottom();
      this.chatMessages = this.chatMessages.concat(incoming);
      if (res && res.viewer_user_id) this.chatViewerId = res.viewer_user_id;
      // Only track unread when NOT viewing the chat tab.
      if (this.mode !== 'chat') {
        const lastSeen = this._getLastSeenId();
        this.chatUnread = this.chatMessages.filter(m => m.id > lastSeen).length;
        this._renderChatBadge();
      } else {
        // If they were reading history, show the jump pill instead of yanking them down.
        if (!wasAtBottom) this.chatShowJump = true;
        this._renderChat({ scroll: wasAtBottom ? 'bottom' : 'preserve' });
        if (wasAtBottom) {
          const maxId = this.chatMessages[this.chatMessages.length - 1].id;
          this._setLastSeenId(maxId);
        }
      }
    }
  }

  _renderChat(opts = {}) {
    const box = this.find('#my-content');
    if (!box) return;
    const sub = this.find('#my-subtitle');
    if (sub) sub.textContent = "Lighthouse 1893 Men's — practical logistics chat.";

    if (!this.chatLoaded) {
      box.innerHTML = `<div class="loading-state"><div class="spinner"></div><p>Loading chat…</p></div>`;
      return;
    }

    if (this.chatError) {
      box.innerHTML = `<div class="empty-state"><p>Chat unavailable: ${this.escapeHtml(this.chatError)}</p></div>`;
      return;
    }

    // Build an ordered list of items: date-dividers + messages with grouping metadata.
    const items = [];
    let prevDay = null;
    let prevMsg = null;
    for (const m of (this.chatMessages || [])) {
      const t = new Date(m.created_at);
      const dayLabel = this._chatDayLabel(t);
      if (dayLabel !== prevDay) {
        items.push({ type: 'divider', label: dayLabel });
        prevDay = dayLabel;
        prevMsg = null; // new day → new group
      }
      const mine = m.user_id === this.chatViewerId;
      // Group with previous if same sender AND within 5 minutes.
      let firstInRun = true;
      if (prevMsg) {
        const gap = t - new Date(prevMsg.created_at);
        if (prevMsg.user_id === m.user_id && gap < 5 * 60 * 1000) {
          firstInRun = false;
        }
      }
      items.push({ type: 'msg', m, mine, firstInRun });
      prevMsg = m;
    }

    const emptyState = `
      <div style="margin:auto; opacity:0.6; padding:var(--space-4); text-align:center;">
        <div style="font-size:2rem; margin-bottom:8px;">💬</div>
        <div>No messages yet — be the first to say hi.</div>
        <div style="font-size:0.85rem; margin-top:4px;">Or ask if practice is still on.</div>
      </div>`;

    const rows = items.length
      ? items.map(it => it.type === 'divider'
          ? this._renderChatDivider(it.label)
          : this._renderChatRow(it.m, it.mine, it.firstInRun)).join('')
      : emptyState;

    const disabled = this.chatSending;
    box.innerHTML = `
      <div style="position:relative; display:flex; flex-direction:column;
                  height: calc(100vh - 240px); min-height:340px;
                  background: rgba(15,23,42,0.55); border-radius:10px; overflow:hidden;
                  border:1px solid rgba(255,255,255,0.06);">
        <div id="chat-scroll"
             style="flex:1; overflow-y:auto; padding: 12px 10px 8px 10px;
                    display:flex; flex-direction:column;">
          ${rows}
        </div>

        <button id="chat-jump" type="button"
                style="position:absolute; right:14px; bottom:80px; z-index:2;
                       display:${this.chatShowJump ? 'inline-flex' : 'none'};
                       align-items:center; gap:6px;
                       background:#2563eb; color:#fff; border:none; border-radius:999px;
                       padding:8px 14px; font-size:0.85rem; font-weight:600;
                       box-shadow:0 4px 12px rgba(0,0,0,0.35); cursor:pointer;">
          ▼ New messages
        </button>

        <div style="display:flex; gap:8px; align-items:flex-end;
                    padding:8px 10px; border-top:1px solid rgba(255,255,255,0.08);
                    background: rgba(15,23,42,0.75);">
          <textarea id="chat-input"
                    rows="1"
                    maxlength="2000"
                    placeholder="Message the men's chat…"
                    ${disabled ? 'disabled' : ''}
                    style="flex:1; resize:none; min-height:38px; max-height:140px;
                           background:#0f172a; color:#e5e7eb;
                           border:1px solid #334155; border-radius:18px;
                           padding:9px 14px; font-family:inherit; font-size:0.95rem;
                           line-height:1.35; overflow-y:auto;"></textarea>
          <button id="chat-send-btn" type="button"
                  ${disabled ? 'disabled' : ''}
                  aria-label="Send"
                  style="flex:0 0 auto; width:42px; height:42px; border-radius:50%;
                         background:#2563eb; color:#fff; border:none; cursor:pointer;
                         display:inline-flex; align-items:center; justify-content:center;
                         font-size:1.1rem; box-shadow:0 2px 6px rgba(0,0,0,0.35);">
            ${disabled ? '…' : '➤'}
          </button>
        </div>
        ${this.chatSendError ? `<div style="color:#fca5a5; padding:4px 12px 8px; font-size:0.85rem;">${this.escapeHtml(this.chatSendError)}</div>` : ''}
      </div>
    `;

    // Scroll behavior.
    const scrollBox = this.find('#chat-scroll');
    if (scrollBox) {
      if (opts.scroll === 'bottom' || !opts.scroll) {
        scrollBox.scrollTop = scrollBox.scrollHeight;
      }
    }
    // Re-check send button enabled state after re-render.
    const ta = this.find('#chat-input');
    const btn = this.find('#chat-send-btn');
    if (ta && btn) btn.disabled = disabled || !ta.value.trim();
  }

  _renderChatDivider(label) {
    return `
      <div style="display:flex; align-items:center; gap:8px;
                  margin:12px 4px 8px; opacity:0.55;">
        <div style="flex:1; height:1px; background:rgba(255,255,255,0.12);"></div>
        <div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">${this.escapeHtml(label)}</div>
        <div style="flex:1; height:1px; background:rgba(255,255,255,0.12);"></div>
      </div>`;
  }

  _renderChatRow(m, mine, firstInRun) {
    const first = (m.author_first_name || '').trim();
    const last  = (m.author_last_name  || '').trim();
    const author = first || last
      ? this.escapeHtml(first + (last ? ' ' + last.charAt(0) + '.' : ''))
      : 'Someone';
    const when = this._formatChatTime(m.created_at);

    // Escape then linkify.
    const escaped = this.escapeHtml(m.message);
    const linkified = escaped.replace(
      /(https?:\/\/[^\s<]+)/g,
      `<a href="$1" target="_blank" rel="noopener noreferrer" style="color:${mine ? '#dbeafe' : '#93c5fd'}; text-decoration:underline;">$1</a>`
    );

    // Bubble style: mine = right-aligned blue; theirs = left-aligned grey.
    const bubbleBg    = mine ? '#2563eb' : '#334155';
    const bubbleColor = mine ? '#ffffff' : '#e5e7eb';
    const align       = mine ? 'flex-end' : 'flex-start';
    // Tighter top spacing when this message continues a run from the same sender.
    const marginTop   = firstInRun ? '10px' : '2px';
    // Rounded corners get a slight "flat" edge on the inner side to feel like a stack.
    const radius = mine
      ? (firstInRun ? '16px 16px 4px 16px' : '16px 4px 4px 16px')
      : (firstInRun ? '16px 16px 16px 4px' : '4px 16px 16px 4px');

    const header = (firstInRun && !mine)
      ? `<div style="font-size:0.75rem; color:#fbbf24; font-weight:600; margin:0 6px 2px;">${author}</div>`
      : '';

    // Timestamp: show at the start of every run, on either side.
    const timeEl = firstInRun
      ? `<div style="font-size:0.7rem; opacity:0.55; margin:0 6px 4px; text-align:${mine ? 'right' : 'left'};">${when}</div>`
      : '';

    return `
      <div style="display:flex; flex-direction:column; align-items:${align}; margin-top:${marginTop};">
        ${timeEl}
        ${header}
        <div style="max-width:78%; padding:8px 12px; border-radius:${radius};
                    background:${bubbleBg}; color:${bubbleColor};
                    white-space:pre-wrap; word-wrap:break-word; overflow-wrap:anywhere;
                    font-size:0.95rem; line-height:1.35;
                    box-shadow:0 1px 2px rgba(0,0,0,0.25);">${linkified}</div>
      </div>
    `;
  }

  _chatDayLabel(t) {
    if (!t || isNaN(t.getTime())) return '';
    const now = new Date();
    if (t.toDateString() === now.toDateString()) return 'Today';
    const yest = new Date(now); yest.setDate(now.getDate() - 1);
    if (t.toDateString() === yest.toDateString()) return 'Yesterday';
    const sameYear = t.getFullYear() === now.getFullYear();
    return t.toLocaleDateString(undefined, sameYear
      ? { month: 'short', day: 'numeric', weekday: 'short' }
      : { month: 'short', day: 'numeric', year: 'numeric' });
  }

  _formatChatTime(iso) {
    if (!iso) return '';
    const t = new Date(iso);
    if (isNaN(t.getTime())) return '';
    return t.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
  }

  _isChatScrolledToBottom() {
    const box = this.find('#chat-scroll');
    if (!box) return true;
    return (box.scrollHeight - box.scrollTop - box.clientHeight) < 40;
  }

  async _sendChatMessage() {
    if (this.chatSending) return;
    const ta = this.find('#chat-input');
    if (!ta) return;
    const text = (ta.value || '').trim();
    if (!text) return;
    this.chatSending = true;
    this.chatSendError = null;
    this._renderChat({ scroll: 'preserve' });
    try {
      const res = await this._fetch('/api/my/chat/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: text }),
      });
      // Server echoes the new row — append and clear input.
      if (res && res.id) {
        this.chatMessages.push({
          id: res.id,
          user_id: res.user_id,
          person_id: res.person_id,
          author_first_name: res.author_first_name || '',
          author_last_name:  res.author_last_name  || '',
          message: res.message,
          created_at: res.created_at,
        });
        this._setLastSeenId(res.id);
      }
      this.chatSending = false;
      this._renderChat({ scroll: 'bottom' });
      const ta2 = this.find('#chat-input');
      if (ta2) { ta2.value = ''; ta2.focus(); }
    } catch (err) {
      this.chatSending = false;
      this.chatSendError = err.message || 'Failed to send.';
      this._renderChat({ scroll: 'preserve' });
      // Restore text so the user doesn't lose it.
      const ta2 = this.find('#chat-input');
      if (ta2) { ta2.value = text; ta2.focus(); }
    }
  }

  _renderChatBadge() {
    const badge = this.find('#chat-badge');
    if (!badge) return;
    if (this.chatUnread > 0 && this.mode !== 'chat') {
      badge.textContent = this.chatUnread > 99 ? '99+' : String(this.chatUnread);
      badge.style.display = 'inline-block';
    } else {
      badge.style.display = 'none';
    }
  }
}
