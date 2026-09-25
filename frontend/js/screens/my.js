// MyScreen — signed-in player's unified week view + chat.
//
// Post-Slice-7 (2026-07-17): single-screen layout, no tabs.
//   * Section 1: Chat, compressed to the newest message with an
//     expand toggle for older messages.
//   * Section 2: Events for the current week the caller is roster-
//     eligible for.  Rolling one-week window that flips over at
//     Sunday 20:00 local — before the cutover the window ends on the
//     upcoming Sunday, after the cutover it slides to the following
//     Sunday (see _weekWindowEnd).  Each event has Going / Not Going
//     buttons (fh_event_rsvps) — no standing/recurring preference
//     anymore (removed 2026-08-16, see docs/adr — it silently
//     auto-marked people "going" on stale preferences with no way to
//     see or change them from the UI).
//
// Backend surface (all already exist — no new endpoints needed):
//   GET  /api/calendar/upcoming?days=14  → { events: [{fh_event_id, kind,
//                                                      category, my_rsvp,
//                                                      my_rsvp_eligible,
//                                                      starts_at, ...}] }
//     The backend now enforces the one-week window in America/New_York,
//     so the player screen only sees the current week until Sunday 20:00,
//     then flips to the next week at the cutover.
//   POST   /api/calendar/rsvp            → { fh_event_id, response, person_id? }
//   DELETE /api/calendar/rsvp            → { fh_event_id, person_id? } (clears back to no response)
//     person_id is optional and only for a guardian answering on behalf
//     of their own rostered child (see guardian_targets on each event
//     and CalendarController::resolveRsvpTarget) — omit it to RSVP for
//     yourself. The write is always keyed to whoever it's actually for,
//     never the caller when they're proxying for a child.
//   GET  /api/my/chat/messages           → { chat_id, viewer_user_id, messages }
//   POST /api/my/chat/messages           → { message }
//
// Auth: MyController + CalendarController accept fh_sess cookie OR JWT bearer.
// _fetch() sends both so magic-link + SPA-login paths both work.
class MyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    // Event state (this-week section).
    this.events         = null;          // Array<event> from /api/calendar/upcoming
    this.eventSaving    = new Set();     // "fh_event_id:response" tokens in-flight
    this.dataError      = null;
    this.expandedEventId = null;         // toggled by the compact View button
    this.notGoingExpandedEvents = new Set(); // fh_event_ids with "Not Going" list open

    // Old-events range picker. 'current' (default) reuses the existing
    // this-week `this.events` array untouched; any other value swaps the
    // section over to a fetched-on-demand past-events list.
    // My Schedule pills: 'week' (the released week, RSVP-able) or the
    // read-ahead views 'all' | 'games' | 'practices'.  Remembered per device.
    this.scheduleView    = 'week';
    try {
      const v = localStorage.getItem('my.scheduleView');
      if (['week', 'all', 'games', 'practices'].includes(v)) this.scheduleView = v;
    } catch (err) { /* private window */ }
    this.futureEvents    = null;         // 90-day feed, loaded on first use
    this.futureError     = null;
    this.eventsRange     = 'current';    // 'current' | 'yesterday' | 'last7' | 'last30' | 'all'
    this.oldEvents       = null;         // cached results for the active non-current range
    this.oldEventsLoading = false;
    this.oldEventsError  = null;

    // Attendance, read-only: fetched lazily when a card is expanded so the
    // status badges show.  Marking it — and inviting a player — is staff
    // work and lives on #event-center (owner 2026-09-17: staff tools get
    // dedicated pages; #my is each person's own page).
    // Keyed by fh_event_id -> {canMark, roster: Map(person_id -> {status, marked_at})}.
    this.attendanceByEvent = new Map();

    // Chat state (compressed: latest message on top, expandable).
    this.chatMessages   = [];            // full history, stored oldest-first
    this.chatViewerId   = 0;             // server-echoed users.id — decides "mine"
    this.chatLoaded     = false;
    this.chatSending    = false;
    this.chatError      = null;
    this.pollTimer      = null;
    this.chatExpanded   = false;         // true → show full history; false → latest only
    this.chatMessaging  = true;          // chats.messaging_enabled (mig 406); false → links only

    // GroupMe feed (read-only; only sections whose chat has a GroupMe
    // integration get one — chat_integrations, migration 392).
    this.groupmeTitle    = '';
    this.groupmeCanPost  = false;        // chat_integrations.post_messages (mig 407)
    this.groupmeMessages = [];           // newest-first, as the API returns them
    this.groupmeExpanded = false;
    this.pollTick        = 0;
  }

  // ---------- lifecycle ----------

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-my';
    el.innerHTML = `
      <div class="screen-header" style="padding: 4px 8px 3px; gap: 4px; align-items:center; flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn" style="padding: 3px 6px; line-height:1;">←</button>
        <div style="display:flex; align-items:center; gap:4px; flex-wrap:wrap; min-width:0;">
          <h1 style="font-size: 0.95rem; margin: 0; line-height:1; white-space:nowrap;">My Schedule</h1>
          <p class="subtitle" id="my-subtitle" style="margin: 0; font-size: 0.68rem; line-height:1; white-space:nowrap;">Loading…</p>
        </div>
        <div style="margin-left:auto; display:flex; gap:4px; flex-wrap:wrap;">
          <a href="#player-team-rules" data-player-nav-target="player-team-rules" title="View only"
             style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1; text-decoration:none; display:inline-flex; align-items:center;">
            Team Rules
          </a>
          <a href="#my" data-player-nav-target="my" title="View only"
             style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1; text-decoration:none; display:inline-flex; align-items:center;">
            Home
          </a>
          <a href="#player-roster" data-player-nav-target="player-roster" title="View only"
             style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1; text-decoration:none; display:inline-flex; align-items:center;">
            Rosters
          </a>
          <a href="#player-calendar" data-player-nav-target="player-calendar" title="View only"
             style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1; text-decoration:none; display:inline-flex; align-items:center;">
            Players
          </a>
          <a href="#schedules" title="Full-season league schedules for every team (view only)"
             style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1; text-decoration:none; display:inline-flex; align-items:center;">
            Schedules
          </a>
        </div>
      </div>
      <div style="padding: 0 8px;">
        <div id="my-push-banner"></div>
        <section id="my-chat" style="margin-bottom: 6px;"></section>
        <section id="my-groupme" style="margin-bottom: 6px;" hidden></section>
        <div id="my-dues-banner"></div>
        <section id="my-events">
          <div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>
        </section>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter(_params) {
    this._wire();
    this._bootstrap();
  }

  onExit() {
    this._stopPoll();
  }

  // ---------- bootstrap ----------

  async _bootstrap() {
    try {
      // 14 days so a week opened early (migration 334) is in hand; the
      // per-event schedule_window_end from the server decides what shows.
      const upRes = await this._fetch('/api/calendar/upcoming?days=14');
      this.events       = upRes.events    || [];
      this.dues         = upRes.dues      || {};   // per person: eligible, min_payment, pay_url (mig 416)
      // Pill labels are DB copy; the pills appear once it lands.
      MessageCopy.load(this.auth).then(() => this._renderEvents());
      await this._loadNextWeekOpens();
      this._renderEvents();
      this._renderChatShell();
      await this._loadChat(/*initial*/ true);
      this._loadGroupMe().catch(() => {});
      this._startPoll();
      this._initPushUI().catch((err) => console.warn('[my] push UI init failed:', err));
      // Full-width opt-in banner above the week (owner 2026-09-05) —
      // shared PushOptIn component; the pill in the chat header stays as
      // the status readout and refreshes when the banner turns push on.
      if (window.PushOptIn) {
        window.PushOptIn.mount(this.find('#my-push-banner'), this.auth, {
          onChange: () => this._initPushUI().catch(() => {}),
        }).catch((err) => console.warn('[my] push banner failed:', err));
      }
    } catch (err) {
      console.error('[my] bootstrap failed:', err);
      this.dataError = err.message || 'Failed to load.';
      this._renderError();
    }
  }

  // Thin fetch wrapper.  READs go through auth.fetch so the impersonation
  // (`?asPersonId=`) URL rewrite in auth.js flows to /api/calendar/*
  // endpoints — otherwise a "view-as" admin would see their own person's
  // events (usually zero) instead of the impersonated player's roster.
  // WRITES bypass that path and always execute as the actual caller,
  // matching applyImpersonation's write-refusal contract.
  async _fetch(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    // Reads: use auth.fetch so impersonation URL rewrite applies.
    if (method === 'GET' && this.auth && typeof this.auth.fetch === 'function') {
      const res = await this.auth.fetch(url, options);
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
    // Writes: raw fetch + credentials so cookie + JWT both flow, but no
    // impersonation rewrite (see auth.js comment).
    const headers = { ...(options.headers || {}) };
    if (this.auth && this.auth.token) {
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

  // ---------- wiring ----------

  _wire() {
    this.element.addEventListener('click', (e) => {
      const target = e.target instanceof Element ? e.target : (e.target && e.target.parentElement);
      if (!target) return;

      if (target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const playerNavBtn = target.closest('[data-player-nav-target]');
      if (playerNavBtn) {
        e.stopPropagation();
        const targetScreen = playerNavBtn.getAttribute('data-player-nav-target');
        if (targetScreen) this.navigation.goTo(targetScreen);
        return;
      }
      // One link per game (2026-08-28, owner: "i would want just the one
      // link on the game in my page that takes us to game center") —
      // replaces the old ⚽ Lineup + 📸 Post to Instagram pair, which
      // were two doors onto what is now one page. Game Center opens on
      // its Starters & Bench pill; the post pills are on that same page,
      // so marketing no longer needs its own entry point from here.
      const gameCenterBtn = target.closest('[data-game-center-match-id]');
      if (gameCenterBtn) {
        e.stopPropagation();
        const matchId = parseInt(gameCenterBtn.getAttribute('data-game-center-match-id'), 10);
        if (matchId) {
          this.navigation.goTo('game-center', {
            matchId,
            title: gameCenterBtn.getAttribute('data-game-center-title') || '',
            when: gameCenterBtn.getAttribute('data-game-center-when') || '',
            // My is for looking, for everyone — staff set lineups from the
            // top-level Game Center tile (owner 2026-09-17).
            view: 'player',
          });
        }
        return;
      }
      // Bulk "Email N Going" — BCC compose, blank body for a custom message
      // to everyone who's already marked Going.
      const emailGoingBtn = target.closest('[data-email-going]');
      if (emailGoingBtn) {
        e.stopPropagation();
        const fhEventId = parseInt(emailGoingBtn.getAttribute('data-email-going'), 10);
        if (fhEventId) this._emailGoing(fhEventId);
        return;
      }
      // Staff door to #attendance (attendance marking + 🎟 invites).
      const eventCenterBtn = target.closest('[data-event-center]');
      if (eventCenterBtn) {
        e.stopPropagation();
        const fhEventId = parseInt(eventCenterBtn.getAttribute('data-event-center'), 10);
        const ev = (this.events || []).find(x => x.fh_event_id === fhEventId)
                || (this.oldEvents || []).find(x => x.fh_event_id === fhEventId);
        if (ev) this.navigation.goTo('attendance', { event: ev });
        return;
      }
      // "Not Going" list show/hide (collapsed by default — can be a long
      // list, no per-row action needed since they've already responded).
      const notGoingToggle = target.closest('[data-toggle-not-going]');
      if (notGoingToggle) {
        e.stopPropagation();
        const fhEventId = parseInt(notGoingToggle.getAttribute('data-toggle-not-going'), 10);
        if (this.notGoingExpandedEvents.has(fhEventId)) {
          this.notGoingExpandedEvents.delete(fhEventId);
        } else {
          this.notGoingExpandedEvents.add(fhEventId);
        }
        this._renderEvents();
        return;
      }
      // Per-event RSVP button (Going / Not Going). A bare data-ev-btn is
      // the caller's own RSVP; data-ev-person-id present means a
      // guardian answering for that child instead (see guardian rows
      // in _renderEventCard).
      const evBtn = target.closest('[data-ev-btn]');
      if (evBtn) {
        e.stopPropagation();
        const response  = evBtn.getAttribute('data-ev-btn');           // 'yes' | 'no'
        const fhEventId = parseInt(evBtn.getAttribute('data-fh-event-id'), 10);
        const personIdAttr = evBtn.getAttribute('data-ev-person-id');
        const personId = personIdAttr ? parseInt(personIdAttr, 10) : null;
        if (fhEventId && (response === 'yes' || response === 'no')) {
          this._sendEventRsvp(fhEventId, response, personId);
        }
        return;
      }
      // Compact card detail toggle.
      const viewBtn = target.closest('[data-view-event-id]');
      if (viewBtn) {
        e.stopPropagation();
        const fhEventId = parseInt(viewBtn.getAttribute('data-view-event-id'), 10);
        this.expandedEventId = this.expandedEventId === fhEventId ? null : fhEventId;
        if (this.expandedEventId === fhEventId && !this.attendanceByEvent.has(fhEventId)) {
          this._loadAttendance(fhEventId);
        }
        this._renderEvents();
        return;
      }
      if (target.closest('#chat-send-btn')) {
        e.stopPropagation();
        this._sendChatMessage();
        return;
      }
      if (target.closest('#chat-view-btn')) {
        e.stopPropagation();
        this.chatExpanded = !this.chatExpanded;
        this._renderChatMessages();
        return;
      }
      if (target.closest('#push-test-btn')) {
        e.stopPropagation();
        this._onPushTestClick();
        return;
      }
      if (target.closest('#groupme-expand-toggle')) {
        e.preventDefault();
        this.groupmeExpanded = !this.groupmeExpanded;
        this._renderGroupMe();
        return;
      }
      // Compressed → expanded chat toggle.
      if (target.closest('#chat-expand-toggle')) {
        e.stopPropagation();
        this.chatExpanded = !this.chatExpanded;
        this._renderChatMessages();
        return;
      }
    });
    // Enter to send (Shift+Enter → newline).
    this.element.addEventListener('keydown', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this._sendChatMessage();
      }
    });
    // Auto-grow chat textarea + toggle send-button enabled state.
    this.element.addEventListener('input', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      ta.style.height = 'auto';
      ta.style.height = Math.min(ta.scrollHeight, 140) + 'px';
      this._syncChatComposerState();
    });
    this.element.addEventListener('click', (e) => {
      const pill = e.target.closest('[data-schedule-view]');
      if (!pill) return;
      this.scheduleView = pill.dataset.scheduleView;
      try { localStorage.setItem('my.scheduleView', this.scheduleView); } catch (err) { /* private window */ }
      this.expandedEventId = null;
      this._renderEvents();
    });
    this.element.addEventListener('change', (e) => {
      const select = e.target.closest('#events-range-select');
      if (!select) return;
      this._onRangeChange(select.value);
    });
  }

  _renderError() {
    const box = this.find('#my-events');
    if (!box) return;
    box.innerHTML = `
      <div class="empty-state">
        <p><strong>Error:</strong> ${this.escapeHtml(this.dataError || 'Unknown')}</p>
        <button class="btn btn-primary" onclick="location.reload()">Reload</button>
      </div>
    `;
  }

  // ────── Events section ────────────────────────────────────────────

  // Rolling one-week window that flips over at Sunday 8pm local.
  //
  //   * Mon 00:00  → shows Mon..Sun of the same week (7 days).
  //   * Sat        → shows Sat + Sun (still this week).
  //   * Sun before 20:00 → shows only Sun (still this week).
  //   * Sun 20:00 onward → flips to next week (Mon..Sun of next week).
  //
  // Rationale: pickup/practice for next week is scheduled but people
  // shouldn't see it (and can't RSVP to it) until the current week is
  // effectively over — 8pm Sun is the agreed cutover.
  _weekWindowEnd() {
    const now  = new Date();
    const dow  = now.getDay();                        // 0=Sun..6=Sat
    const daysToSunday = (7 - dow) % 7;               // 0 if today is Sun

    // Sunday of THIS week at 20:00 local.
    const sunCutover = new Date(now);
    sunCutover.setDate(now.getDate() + daysToSunday);
    sunCutover.setHours(20, 0, 0, 0);

    // End-of-Sunday (23:59:59.999) for the "shown" week.  If we're
    // before the Sunday-8pm cutover, the shown week ends this Sunday.
    // Otherwise it ends next Sunday.
    const shownSun = new Date(sunCutover);
    if (now >= sunCutover) shownSun.setDate(shownSun.getDate() + 7);
    shownSun.setHours(23, 59, 59, 999);
    return shownSun;
  }

  // "Next week posts <when>" for the empty state — asked of the server so
  // it reflects the club's standing rule and any early release, not a
  // date baked into this file. Silent on failure (keeps the old text).
  async _loadNextWeekOpens() {
    try {
      const now = new Date();
      const dow = now.getDay();                       // 0=Sun
      const daysToNextMon = ((8 - dow) % 7) || 7;     // next Monday, never today
      const mon = new Date(now.getFullYear(), now.getMonth(), now.getDate() + daysToNextMon);
      const ws = `${mon.getFullYear()}-${String(mon.getMonth() + 1).padStart(2, '0')}-${String(mon.getDate()).padStart(2, '0')}`;
      const w = await this._fetch(`/api/schedule/window?week_start=${ws}`);
      if (w && w.open_now) {
        this.nextWeekOpensText = 'Next week is posted.';
      } else if (w && w.opens_at) {
        const d = new Date(w.opens_at);
        // Wording is DB copy (my_schedule / next_week_opens, migration 398).
        await MessageCopy.load(this.auth);
        const when = `${d.toLocaleDateString(undefined, { weekday: 'short', month: 'numeric', day: 'numeric' })} at ${d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' })}`;
        this.nextWeekOpensText = MessageCopy.block('my_schedule', 'next_week_opens', { when });
      }
    } catch (err) {
      console.warn('[my] schedule window lookup failed:', err);
    }
  }

  _isPlayerScheduleEvent(ev) {
    const kind = (ev.kind || '').toLowerCase();
    const category = (ev.category || '').toLowerCase();
    const summary = `${ev.summary || ''} ${ev.title || ''}`.toLowerCase();

    // My is the viewer's OWN week, staff included (owner 2026-09-17: "my
    // page for coaches and admin should be for them and not an admin type
    // view").  The feed hands admins every club event; is_mine is the
    // same test without the admin pass — on the roster, coaching it,
    // invited, or club staff (club_staff, mig 430: full-time staff see
    // every team).  A parent's events arrive as is_guardian.
    if (ev.is_mine === false && !ev.is_guardian) return false;

    if (category === 'staff' || summary.includes('all staff meeting')) return false;
    if (kind === 'meeting') return false;

    return ['pickup', 'practice', 'match', 'barn night', 'intrasquad'].includes(kind);
  }

  _renderEvents() {
    const box = this.find('#my-events');
    if (!box) return;

    const rangeHtml = this._rangeSelectHtml();
    const sub = this.find('#my-subtitle');

    if (this.eventsRange !== 'current') {
      this._renderOldEvents(box, rangeHtml, sub);
      return;
    }

    this._renderDuesBanner();
    const head = rangeHtml + this._schedulePillsHtml();
    if (this.scheduleView !== 'week') {
      this._renderFutureEvents(box, head, sub);
      return;
    }

    // Keep the player-facing schedule focused on the released window.
    // (Until 2026-09-13 this also dropped Mondays — a leftover from when
    // My was men's-only and the men never trained on Monday.  Youth K-2
    // and Grades 3-10 practice on Monday, so every weekday is fair game.)
    const weekEnd = this._weekWindowEnd();
    const now = Date.now();
    const DROP_GRACE_MS = 30 * 60 * 1000;
    // Fallback when ends_at is missing/unparseable — assume a 2hr event so a
    // data gap doesn't drop something that's still in progress.
    const FALLBACK_DURATION_MS = 2 * 60 * 60 * 1000;
    const list = (this.events || [])
      .filter(e => this._isPlayerScheduleEvent(e))
      .filter(e => {
        if (!e.starts_at) return false;
        const t = new Date(e.starts_at);
        // Server-derived window (schedule_release_policies + early
        // releases) wins; the local Sunday-8pm rule is only a fallback
        // for an event that somehow arrived without one.
        const winEnd = e.schedule_window_end ? new Date(e.schedule_window_end) : weekEnd;
        if (isNaN(t) || t > winEnd) return false;

        // Drop the event from the board 30 minutes after it ends, so
        // yesterday's practice doesn't linger on "This Week" all week.
        const endsAt = e.ends_at ? new Date(e.ends_at) : null;
        const cutoff = (endsAt && !isNaN(endsAt) ? endsAt.getTime() : t.getTime() + FALLBACK_DURATION_MS)
          + DROP_GRACE_MS;
        return now < cutoff;
      });

    if (sub) {
      sub.textContent = list.length
        ? `${list.length} event${list.length !== 1 ? 's' : ''} this week`
        : 'Nothing on your calendar this week';
    }

    if (list.length === 0) {
      box.innerHTML = head + `
        <div class="empty-state" style="padding: var(--space-4); text-align:center; opacity: 0.7;">
          <div style="font-size:2rem; margin-bottom:8px;">📅</div>
          <div>Nothing on your calendar this week.</div>
          <div style="font-size:0.85rem; margin-top:6px; opacity:0.7;">
            ${this.escapeHtml(this.nextWeekOpensText || '')}
          </div>
        </div>`;
      return;
    }

    box.innerHTML = head + `
      ${this._schedulePillsHtml() ? '' : '<h2 style="margin: 0 0 4px; font-size:0.8rem;">This Week</h2>'}
      ${list.map(e => this._renderEventCard(e)).join('')}
    `;
  }

  // ────── Schedule pills + the read-ahead list ──────────────────────
  // Owner 2026-09-21: "instead of separate schedule button we can have
  // pills on my page ... this week, all, games only, practice only."
  // The week view is untouched.  The other three read 90 days ahead: an
  // event inside the released week is the normal card; anything later is
  // a read-only row — "they can only rsvp to events up to Sunday night",
  // and the server refuses an RSVP outside the window (migration 396).

  _schedulePillsHtml() {
    const views = [['week', 'pill_week'], ['all', 'pill_all'], ['games', 'pill_games'], ['practices', 'pill_practices']];
    if (!views.every(([, tier]) => MessageCopy.has('my_schedule', tier))) return '';
    return `
      <div style="display:flex; gap:5px; flex-wrap:wrap; margin:0 0 6px;">
        ${views.map(([view, tier]) => {
          const on = this.scheduleView === view;
          return `<button type="button" data-schedule-view="${view}"
                    style="padding:4px 11px; border-radius:999px; cursor:pointer; font-size:0.7rem; font-weight:700;
                           border:1px solid ${on ? '#2563eb' : 'rgba(255,255,255,0.16)'};
                           background:${on ? '#2563eb' : 'transparent'}; color:${on ? '#fff' : '#dbeafe'};">${this.escapeHtml(MessageCopy.block('my_schedule', tier))}</button>`;
        }).join('')}
      </div>`;
  }

  async _loadFutureEvents() {
    if (this._futureLoading) return;
    this._futureLoading = true;
    try {
      const res = await this._fetch('/api/calendar/upcoming?days=90');
      this.futureEvents = res.events || [];
      this.futureError = null;
    } catch (err) {
      console.warn('[my] future schedule failed:', err);
      this.futureEvents = [];
      this.futureError = err.message || 'Could not load';
    }
    this._futureLoading = false;
    this._renderEvents();
  }

  _renderFutureEvents(box, head, sub) {
    if (this.futureEvents === null) {
      box.innerHTML = head + `<div style="padding:12px; opacity:0.7; font-size:0.8rem;">Loading…</div>`;
      this._loadFutureEvents();
      return;
    }
    const kinds = { games: ['match', 'intrasquad'], practices: ['practice', 'pickup'] }[this.scheduleView];
    const now = Date.now();
    // The 14-day feed is the live one (polled, carries RSVP state) — a
    // released event is drawn from it so the card never goes stale.
    const live = new Map((this.events || []).map(e => [e.fh_event_id, e]));
    const list = this.futureEvents
      .map(e => live.get(e.fh_event_id) || e)
      .filter(e => this._isPlayerScheduleEvent(e))
      .filter(e => !kinds || kinds.includes((e.kind || '').toLowerCase()))
      .filter(e => {
        const end = new Date(e.ends_at || e.starts_at).getTime();
        return !isNaN(end) && end + 30 * 60 * 1000 > now;
      })
      .sort((a, b) => new Date(a.starts_at) - new Date(b.starts_at));

    if (sub) sub.textContent = `${list.length} event${list.length !== 1 ? 's' : ''}`;
    if (!list.length) {
      box.innerHTML = head + `<div class="empty-state" style="padding: var(--space-4); text-align:center; opacity:0.7;">
        ${this.escapeHtml(this.futureError || MessageCopy.block('my_schedule', 'future_empty'))}</div>`;
      return;
    }

    const weekEnd = this._weekWindowEnd();
    const released = (e) => new Date(e.starts_at) <= (e.schedule_window_end ? new Date(e.schedule_window_end) : weekEnd);
    // Week dividers: "Sep 28 – Oct 4".
    const weekKey = (iso) => {
      const d = new Date(iso); d.setHours(0, 0, 0, 0);
      d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
      return d.getTime();
    };
    const fmt = (d) => d.toLocaleDateString(undefined, { month: 'short', day: 'numeric' });
    let lastWeek = null;
    const rows = list.map(e => {
      let divider = '';
      const wk = weekKey(e.starts_at);
      if (wk !== lastWeek) {
        lastWeek = wk;
        const mon = new Date(wk), sun = new Date(wk); sun.setDate(sun.getDate() + 6);
        divider = `<div style="margin:10px 0 4px; font-size:0.66rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6;">${fmt(mon)} – ${fmt(sun)}</div>`;
      }
      return divider + (released(e) ? this._renderEventCard(e) : this._renderFutureRow(e));
    }).join('');

    const note = MessageCopy.block('my_schedule', 'future_note');
    box.innerHTML = head
      + (note ? `<div style="font-size:0.68rem; opacity:0.65; margin:0 0 2px;">${this.escapeHtml(note)}</div>` : '')
      + rows;
  }

  // A week that has not opened yet: what, when, where — no RSVP buttons.
  _renderFutureRow(ev) {
    const descTags = this._parseDescTags(ev.description);
    const times = [['Arrival', ev.arrival_label || descTags.arrival], ['Warmup', ev.warmup_label || descTags.warmup],
                   ['Kickoff', ev.kickoff_label || descTags.kickoff]]
      .filter(([, v]) => v).map(([k, v]) => `${k} ${v}`).join(' · ');
    const opens = ev.rsvps_open_at ? new Date(ev.rsvps_open_at) : null;
    const opensText = opens && !isNaN(opens)
      ? MessageCopy.block('my_schedule', 'rsvp_opens', { when: opens.toLocaleString(undefined,
          { weekday: 'short', month: 'numeric', day: 'numeric', hour: 'numeric', minute: '2-digit' }) })
      : '';
    const isGame = ['match', 'intrasquad'].includes((ev.kind || '').toLowerCase());
    return `
      <div style="display:flex; gap:10px; align-items:flex-start; padding:7px 9px; margin-bottom:4px; border-radius:8px;
                  border:1px solid rgba(255,255,255,0.08); border-left:3px solid ${isGame ? '#f59e0b' : '#334155'};
                  background:rgba(15,23,42,0.45);">
        <div style="flex:0 0 74px; font-size:0.7rem; font-weight:700; line-height:1.25;">
          ${this.escapeHtml(EventLabels.dateStr(ev.starts_at))}<br>
          <span style="opacity:0.7; font-weight:600;">${this.escapeHtml(EventLabels.timeStr(ev.starts_at))}</span>
        </div>
        <div style="min-width:0; flex:1; font-size:0.74rem; line-height:1.3;">
          <div style="font-weight:800;">${this.escapeHtml(EventLabels.title(ev))}</div>
          ${ev.location ? `<div style="opacity:0.7; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${this.escapeHtml(ev.location)}</div>` : ''}
          ${times ? `<div style="opacity:0.7;">${this.escapeHtml(times)}</div>` : ''}
          ${opensText ? `<div style="margin-top:2px; font-size:0.64rem; font-weight:700; color:#93c5fd;">${this.escapeHtml(opensText)}</div>` : ''}
        </div>
      </div>`;
  }

  // ────── Old events (range picker) ─────────────────────────────────

  _rangeSelectHtml() {
    const options = [
      ['current', 'This Week'],
      ['yesterday', 'Yesterday'],
      ['last7', 'Last Week'],
      ['last30', 'Last Month'],
      ['all', 'All'],
    ];
    const optsHtml = options.map(([val, label]) =>
      `<option value="${val}" ${this.eventsRange === val ? 'selected' : ''}>${this.escapeHtml(label)}</option>`
    ).join('');
    return `
      <div style="display:flex; justify-content:flex-end; margin-bottom:6px;">
        <select id="events-range-select" style="padding:3px 6px; border-radius:6px;
                border:1px solid rgba(255,255,255,0.16); background:rgba(15,23,42,0.7);
                color:#dbeafe; font-size:0.68rem; font-weight:600;">
          ${optsHtml}
        </select>
      </div>`;
  }

  _onRangeChange(value) {
    if (this.eventsRange === value) return;
    this.eventsRange = value;
    this.expandedEventId = null;
    if (value !== 'current') {
      this.oldEvents = null;
      this.oldEventsError = null;
    }
    this._renderEvents();
    if (value !== 'current' && this.oldEvents === null) {
      this._loadOldEvents(value);
    }
  }

  // 'yesterday'/'last7'/'last30' are rolling day windows (not calendar-
  // day-aligned) ending now; 'all' pages backward in 90-day chunks (the
  // backend's `days` cap) until a chunk comes back empty or a safety cap
  // of 4 chunks (~1 year) is hit, since /api/calendar/upcoming has no
  // true "no limit" mode.
  async _loadOldEvents(rangeKey) {
    this.oldEventsLoading = true;
    this.oldEventsError = null;
    this._renderEvents();

    try {
      let events;
      if (rangeKey === 'all') {
        events = [];
        let chunkEnd = new Date();
        for (let i = 0; i < 4; i++) {
          const chunkStart = new Date(chunkEnd.getTime() - 90 * 24 * 60 * 60 * 1000);
          const res = await this._fetch(
            `/api/calendar/upcoming?start=${encodeURIComponent(chunkStart.toISOString())}&days=90`);
          const chunk = res.events || [];
          if (chunk.length === 0) break;
          events = events.concat(chunk);
          chunkEnd = chunkStart;
        }
      } else {
        const daysBack = { yesterday: 1, last7: 7, last30: 30 }[rangeKey] || 7;
        const start = new Date(Date.now() - daysBack * 24 * 60 * 60 * 1000);
        const res = await this._fetch(
          `/api/calendar/upcoming?start=${encodeURIComponent(start.toISOString())}&days=${daysBack}`);
        events = res.events || [];
      }
      if (this.eventsRange !== rangeKey) return; // user switched ranges while this was in flight
      this.oldEvents = events;
    } catch (err) {
      if (this.eventsRange !== rangeKey) return;
      console.error('[my] old events load failed:', err);
      this.oldEventsError = err.message || 'Failed to load.';
    } finally {
      if (this.eventsRange === rangeKey) this.oldEventsLoading = false;
      this._renderEvents();
    }
  }

  _renderOldEvents(box, rangeHtml, sub) {
    if (this.oldEventsLoading) {
      if (sub) sub.textContent = 'Loading…';
      box.innerHTML = rangeHtml + `<div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>`;
      return;
    }
    if (this.oldEventsError) {
      if (sub) sub.textContent = 'Failed to load';
      box.innerHTML = rangeHtml + `
        <div class="empty-state" style="padding: var(--space-4); text-align:center; opacity: 0.7;">
          <p><strong>Error:</strong> ${this.escapeHtml(this.oldEventsError)}</p>
        </div>`;
      return;
    }

    const list = (this.oldEvents || [])
      .filter(e => this._isPlayerScheduleEvent(e))
      .filter(e => e.starts_at && !isNaN(new Date(e.starts_at)))
      .sort((a, b) => new Date(b.starts_at) - new Date(a.starts_at)); // most recent first

    const rangeLabels = { yesterday: 'yesterday', last7: 'the last week', last30: 'the last month', all: 'your history' };
    const rangeLabel = rangeLabels[this.eventsRange] || 'this range';

    if (sub) {
      sub.textContent = list.length
        ? `${list.length} event${list.length !== 1 ? 's' : ''} in ${rangeLabel}`
        : `Nothing in ${rangeLabel}`;
    }

    if (list.length === 0) {
      box.innerHTML = rangeHtml + `
        <div class="empty-state" style="padding: var(--space-4); text-align:center; opacity: 0.7;">
          <div style="font-size:2rem; margin-bottom:8px;">📅</div>
          <div>No events in ${this.escapeHtml(rangeLabel)}.</div>
        </div>`;
      return;
    }

    box.innerHTML = rangeHtml + list.map(e => this._renderEventCard(e, /*isPast*/ true)).join('');
  }

  // Ops tags the raw Google Calendar description with a small DSL —
  // `Club:`, `Team:`, `Kind:`/`Type:` (inconsistent between event
  // types — practice tends to use `Type:`, match/pickup use `Kind:`,
  // so we check both), `Opponent:`, `Arrival:`, `Warmup:`, `Kickoff:`,
  // `Notes:`. gcal *title* is admin-only and never shown to players —
  // these description tags are the player-facing source of truth
  // instead. Same DSL tags migration 271 stores as fh_events.arrival_at/
  // warmup_at/kickoff_at — parsed here straight off the raw description
  // instead of those columns since no backend controller selects them
  // yet (see my.js's ev.description already being on the wire either
  // way for the other tags).
  _parseDescTags(description) { return EventLabels.parseDescTags(description); }

  // Shared with #event-center — see lib/event-labels.js.
  _eventTitle(ev) { return EventLabels.title(ev); }

  _eventRsvpHtml(ev, isPast = false) {
    const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    // A yes from someone over the dues line (dues_eligible=false,
    // migration 416) is kept but counted apart: it stays out of the
    // Going lists and totals, and staff see it under its own heading
    // (owner 2026-09-23). Other players never see the heading.
    const goingAll       = rsvps.filter(r => r && r.response === 'yes');
    const going          = goingAll.filter(r => r.dues_eligible !== false);
    const goingIneligible= goingAll.filter(r => r.dues_eligible === false);
    const viewerIsStaff  = String(this.navigation?.context?.role || this.auth?.user?.role || '').toLowerCase() !== 'player';
    // The bulk Text All / Text Going / Email Going buttons are for club
    // admins only (owner 2026-09-25: "they should not have option to email
    // and text everyone … for now only i need that").  Coaches nudge from
    // #rsvps and Game Center; players never see them.
    const viewerIsAdmin  = this._viewerIsAdmin();
    const notGoingAll    = rsvps.filter(r => r && r.response === 'no');
    const noResponseAll  = rsvps.filter(r => r && !r.response);
    // Invited players (fh_event_invites, migration 355 — youth call-ups
    // and men's play-downs) are listed apart from the roster when they
    // say yes ("available", the coach still picks), but ride along in
    // Not Going / No Response so reminders reach them too.
    const playersGoing      = going.filter(r => !r.is_coach && !r.is_callup);
    const callupsAvailable  = going.filter(r => r.is_callup);
    const coachesGoing      = going.filter(r => r.is_coach);
    const notGoingPlayers   = notGoingAll.filter(r => !r.is_coach);
    const notGoingCoaches   = notGoingAll.filter(r => r.is_coach);
    const noResponsePlayers = noResponseAll.filter(r => !r.is_coach);
    const noResponseCoaches = noResponseAll.filter(r => r.is_coach);

    const att = this.attendanceByEvent.get(ev.fh_event_id) || null;

    const nameOf = (r) => (r && (r.name || r.first_name || r.last_name || 'Unknown')) || 'Unknown';
    const callupChip = (r) => r && r.is_callup
      ? `<span title="Invited${r.callup_from ? ' from ' + this.escapeHtml(r.callup_from) : ''}"
               style="margin-left:5px; padding:0 5px; border-radius:999px; background:rgba(245,158,11,0.18);
                      border:1px solid rgba(245,158,11,0.55); color:#fcd34d; font-size:0.56rem; font-weight:800;">🎟 INVITED</span>`
      : '';
    const rowsHtml = (list) => list
      .map(r => `<div style="display:flex; align-items:center; justify-content:space-between; gap:6px;">
          <span style="font-size:0.76rem; color:rgba(226,232,240,0.95);">${this.escapeHtml(nameOf(r))}${callupChip(r)}</span>
          ${this._attendanceCellHtml(ev.fh_event_id, r.person_id, att)}
        </div>`)
      .join('');

    // "Present" sits right beside "Players/Coaches <status>" as a matched
    // label+total pair, for every status (not just Going) — late counts
    // toward present (P/L green/amber both mean "showed up"; A/E or a
    // blank dash mean not present); catches the "said no but showed up
    // anyway" case too. Only counted once attendance has actually loaded
    // (`att` set) — no bogus 0 while still loading. No separate
    // present-only list, to avoid showing every name twice.
    const presentCount = (list) => list.filter(r => {
      const entry = att && att.roster.get(r.person_id);
      return entry && (entry.status === 'present' || entry.status === 'late');
    }).length;

    // Same label+count(+Present) shape for every RSVP status and for
    // both players and coaches — Going/Not Going/No Response all get
    // identical treatment instead of coaches only showing up under
    // Going. `rows` is pre-rendered so each status can supply its own
    // rows.
    const groupHtml = (label, list, countWord, rows) => `
      <div style="display:flex; align-items:flex-start; gap:14px; margin-bottom:4px;">
        <div>
          <div style="font-size:0.72rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase;
                      color:rgba(226,232,240,0.75);">${this.escapeHtml(label)}</div>
          <div style="font-size:0.9rem; font-weight:700; color:rgba(226,232,240,0.92);">
            ${list.length ? `${list.length} ${countWord}` : 'None.'}
          </div>
        </div>
        ${list.length && att ? `
        <div>
          <div style="font-size:0.6rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase;
                      color:rgba(226,232,240,0.5);">Present</div>
          <div style="font-size:0.9rem; font-weight:700; color:#22c55e;">${presentCount(list)}</div>
        </div>` : ''}
      </div>
      ${list.length ? `<div style="display:grid; gap:3px; margin-top:6px;">${rows}</div>` : ''}
    `;

    const notGoingExpanded = this.notGoingExpandedEvents.has(ev.fh_event_id);
    const notGoingTotal    = notGoingPlayers.length + notGoingCoaches.length;
    const noResponseTotal  = noResponsePlayers.length + noResponseCoaches.length;

    return `
      <div style="background:rgba(15,23,42,0.45); border:1px solid rgba(148,163,184,0.18);
                  border-radius:8px; padding:8px 10px; margin-bottom: var(--space-3);">
        ${viewerIsAdmin ? this._bulkSmsAllBtnHtml(ev, isPast) : ''}
        ${viewerIsAdmin && going.length ? `
          <div style="margin-bottom:8px;">
            ${this._bulkSmsGoingBtnHtml(ev, going, isPast)}
            ${this._bulkEmailGoingBtnHtml(ev, going, isPast)}
          </div>
        ` : ''}
        <div style="display:grid; gap:10px; grid-template-columns: 1fr 1fr;">
          <div>${groupHtml('Players Going', playersGoing, 'going', rowsHtml(playersGoing))}</div>
          <div>${groupHtml('Coaches Going', coachesGoing, 'going', rowsHtml(coachesGoing))}</div>
        </div>
        ${callupsAvailable.length ? `
          <div style="margin-top:8px;">
            ${groupHtml('Invited · Available', callupsAvailable, 'available', rowsHtml(callupsAvailable))}
          </div>
        ` : ''}
        ${viewerIsStaff && goingIneligible.length ? `
          <div style="margin-top:8px; padding:6px 8px; border-radius:6px; border:1px solid rgba(239,68,68,0.55); background:rgba(239,68,68,0.10);">
            ${groupHtml('⛔ Said Going · Ineligible (dues)', goingIneligible, 'not counted', rowsHtml(goingIneligible))}
          </div>
        ` : ''}
        ${notGoingTotal ? `
          <div style="margin-top:10px; padding-top:8px; border-top:1px solid rgba(148,163,184,0.18);">
            <button type="button" data-toggle-not-going="${ev.fh_event_id}"
                    style="display:flex; align-items:center; justify-content:space-between; width:100%;
                           background:transparent; border:none; padding:0; cursor:pointer; color:inherit;">
              <span style="font-size:0.72rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase;
                          color:rgba(226,232,240,0.75);">
                Not Going (${notGoingTotal})
              </span>
              <span style="font-size:0.62rem; opacity:0.6;">${notGoingExpanded ? '▲ Hide' : '▼ Show'}</span>
            </button>
            ${notGoingExpanded ? `
              <div style="display:grid; gap:10px; grid-template-columns: 1fr 1fr; margin-top:6px;">
                <div>${groupHtml('Players Not Going', notGoingPlayers, 'not going', rowsHtml(notGoingPlayers))}</div>
                <div>${groupHtml('Coaches Not Going', notGoingCoaches, 'not going', rowsHtml(notGoingCoaches))}</div>
              </div>
            ` : ''}
          </div>
        ` : ''}
        ${noResponseTotal ? `
          <div style="margin-top:10px; padding-top:8px; border-top:1px solid rgba(148,163,184,0.18);">
            <div style="font-size:0.72rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase;
                        color:rgba(226,232,240,0.75); margin-bottom:6px;">
              No Response (${noResponseTotal})
            </div>
            <div style="display:grid; gap:10px; grid-template-columns: 1fr 1fr;">
              <div>${groupHtml('Players No Response', noResponsePlayers, 'no response', rowsHtml(noResponsePlayers))}</div>
              <div>${groupHtml('Coaches No Response', noResponseCoaches, 'no response', rowsHtml(noResponseCoaches))}</div>
            </div>
          </div>
        ` : ''}
        ${this._eventCenterLinkHtml(ev, att)}
      </div>`;
  }

  // The one staff control left on a #my event: a door to #attendance,
  // where this event's coaches and club admins mark attendance and send
  // 🎟 invites.  Shown once attendance has loaded and says they may.
  _eventCenterLinkHtml(ev, att) {
    if (!att || !att.canMark) return '';
    return `
      <div style="margin-top:10px; padding-top:8px; border-top:1px solid rgba(148,163,184,0.18);">
        <button type="button" data-event-center="${ev.fh_event_id}"
                style="font-size:0.72rem; font-weight:800; color:#fcd34d; background:transparent;
                       border:1px solid rgba(245,158,11,0.55); padding:4px 10px; border-radius:999px; cursor:pointer;">
          📋 Attendance &amp; invites
        </button>
      </div>`;
  }

  // Club/super admin by the account's DB role — the same list
  // role-selection.js uses to show the Administration tile.
  _viewerIsAdmin() {
    // View-as (auth.viewAsPersonId) means "show me exactly what they
    // see" — an admin viewing as a player gets the player's page.
    if (this.auth?.viewAsPersonId) return false;
    const role = String(this.auth?.user?.role || '').toLowerCase();
    return ['club', 'super', 'system', 'sport_division', 'team', 'league'].includes(role);
  }

  // Event-level "Text All" — everyone who can RSVP to this event (players
  // + coaches, any response status), blank body so the coach writes a
  // custom message live on their phone rather than a canned reminder.
  //
  // Carrier group-MMS limits are commonly ~10 recipients (AT&T/Verizon cap
  // at 10, T-Mobile ~20) — iMessage-only threads can go higher but only
  // work phone-to-phone between iPhones on wifi/data, which a mixed-device
  // roster can't rely on. A single sms: link past that count can silently
  // drop recipients with no warning, so split into multiple group texts of
  // CHUNK_SIZE instead of gambling on one link reaching everyone.
  _bulkSmsAllBtnHtml(ev, isPast) {
    if (isPast) return '';
    const CHUNK_SIZE = 10;
    const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    const phones = [...new Set(rsvps.map(r => (r.phone || '').trim()).filter(Boolean))];
    if (!phones.length) return '';

    const chunks = [];
    for (let i = 0; i < phones.length; i += CHUNK_SIZE) chunks.push(phones.slice(i, i + CHUNK_SIZE));

    const buttonsHtml = chunks.map((chunk, i) => {
      const href = this.buildSmsComposeHref({ to: chunk.join(',') });
      const label = chunks.length > 1
        ? `💬 Text All — Part ${i + 1}/${chunks.length} (${chunk.length})`
        : `💬 Text All (${chunk.length})`;
      return `<a href="${this.escapeHtml(href)}"
                 title="Opens a blank group text to ${chunk.length} ${chunks.length > 1 ? `of ${phones.length} ` : ''}people who can RSVP to this event — write your own message. Everyone in the group will see each other's number."
                 style="padding:3px 8px; border-radius:999px; text-decoration:none; display:inline-block; margin:0 4px 4px 0;
                        background:#6366f1; color:#fff; font-size:0.66rem; font-weight:700;">
                ${label}
              </a>`;
    }).join('');

    return `
      <div style="margin-bottom:8px;">
        ${buttonsHtml}
        ${chunks.length > 1 ? `
          <div style="font-size:0.62rem; opacity:0.6; margin-top:2px;">
            Split into ${chunks.length} group texts of ${CHUNK_SIZE} — carriers commonly cap group MMS around 10 people.
          </div>` : ''}
      </div>`;
  }

  // Bulk "Text N Going" — everyone already marked Going, blank body so the
  // coach writes their own message (field change, time change, etc.)
  // instead of a canned reminder. Same carrier group-MMS chunking as
  // _bulkSmsAllBtnHtml since this is still one shared group thread.
  _bulkSmsGoingBtnHtml(ev, goingList, isPast) {
    if (isPast) return '';
    const CHUNK_SIZE = 10;
    const phones = [...new Set(goingList.map(r => (r.phone || '').trim()).filter(Boolean))];
    if (!phones.length) return '';

    const chunks = [];
    for (let i = 0; i < phones.length; i += CHUNK_SIZE) chunks.push(phones.slice(i, i + CHUNK_SIZE));

    return chunks.map((chunk, i) => {
      const href = this.buildSmsComposeHref({ to: chunk.join(',') });
      const label = chunks.length > 1
        ? `💬 Text Going — Part ${i + 1}/${chunks.length} (${chunk.length})`
        : `💬 Text ${chunk.length} Going`;
      return `<a href="${this.escapeHtml(href)}"
                 title="Opens a blank group text to ${chunk.length} ${chunks.length > 1 ? `of ${phones.length} ` : ''}people going to this event — write your own message. Everyone in the group will see each other's number."
                 style="padding:3px 8px; border-radius:999px; text-decoration:none; display:inline-block; margin:0 4px 4px 0;
                        background:#22c55e; color:#0f172a; font-size:0.66rem; font-weight:700;">
                ${label}
              </a>`;
    }).join('');
  }

  // Bulk "Email N Going" — BCC compose, blank body, same custom-message
  // intent as the Text-All-Going button above.
  _bulkEmailGoingBtnHtml(ev, goingList, isPast) {
    if (isPast) return '';
    const emails = [...new Set(goingList.map(r => (r.email || '').trim()).filter(Boolean))];
    if (!emails.length) return '';
    return `
      <button type="button" data-email-going="${ev.fh_event_id}"
              title="Open Gmail with all ${emails.length} Going player${emails.length !== 1 ? 's' : ''} BCC'd — write your own message"
              style="padding:3px 8px; border-radius:999px; border:none; cursor:pointer;
                     background:#16a34a; color:#fff; font-size:0.66rem; font-weight:700;">
        📧 Email ${emails.length} Going
      </button>`;
  }

  // BCC compose to everyone marked Going for one event — blank body, for a
  // custom message rather than a canned reminder (they've already RSVP'd).
  _emailGoing(fhEventId) {
    const ev = (this.events || []).find(e => e.fh_event_id === fhEventId)
            || (this.oldEvents || []).find(e => e.fh_event_id === fhEventId);
    if (!ev) return;

    const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    const going = rsvps.filter(r => r && r.response === 'yes');
    const emails = [...new Set(going.map(r => (r.email || '').trim()).filter(Boolean))];
    if (!emails.length) {
      alert('No email addresses on file for the Going players.');
      return;
    }

    const eventTitle = this._eventTitle(ev);
    const eventWhen = [this._eventDateStr(ev.starts_at), this._eventTimeStr(ev.starts_at)].filter(Boolean).join(' ');
    const subject = `${eventTitle}${eventWhen ? ' (' + eventWhen + ')' : ''}`;

    // bcc (not to) so the group stays private from each other.
    const href = this.buildGmailComposeHref({ bcc: emails.join(','), subject, body: '' });
    this.openGmailCompose(href);
  }

  // Read-only attendance badge.  `att` is null until the card's first
  // expand triggers `_loadAttendance`.  Marking happens on #event-center.
  _attendanceCellHtml(fhEventId, personId, att) {
    const STATUS_META = [
      { id: 'present', letter: 'P', label: 'Present', color: '#22c55e' },
      { id: 'absent',  letter: 'A', label: 'Absent',  color: '#ef4444' },
      { id: 'late',    letter: 'L', label: 'Late',    color: '#f59e0b' },
      { id: 'excused', letter: 'E', label: 'Excused', color: '#64748b' },
    ];
    if (!att) {
      return '<span style="font-size:0.6rem; opacity:0.35;">…</span>';
    }
    const entry = att.roster.get(personId);
    const meta = STATUS_META.find(s => s.id === (entry && entry.status));
    return meta
      ? `<span style="display:inline-flex; align-items:center; justify-content:center; width:15px; height:15px;
                      border-radius:50%; background:${meta.color}; color:#fff; font-size:0.55rem; font-weight:800;"
               title="${meta.label}">${meta.letter}</span>`
      : `<span style="font-size:0.62rem; opacity:0.4;" title="Not marked">—</span>`;
  }

  async _loadAttendance(fhEventId) {
    try {
      const body = await this._fetch(`/api/calendar/events/${fhEventId}/attendance`);
      const roster = new Map((body.roster || []).map(r => [r.person_id, r]));
      this.attendanceByEvent.set(fhEventId, { canMark: !!body.can_mark, roster });
    } catch (err) {
      console.error('[my] attendance load failed:', err);
      this.attendanceByEvent.set(fhEventId, { canMark: false, roster: new Map() });
    }
    this._renderEvents();
  }

  // ── Dues eligibility (migration 416) ────────────────────────────────
  // The feed's `dues` is keyed by person id: the viewer (is_self) and each
  // child on their page.  At or over the line (eligible=false) the person
  // is not eligible for games and practices: a banner up top, and on each
  // game/practice the Go/No buttons give way to a pay link naming the
  // least payment that gets them back under it.  Copy: message_templates
  // kind my_dues (banner, banner_button, pill); nothing is worded here.
  _duesFor(personId) {
    const d = this.dues || {};
    if (personId == null) return Object.values(d).find(x => x && x.is_self) || null;
    return d[String(personId)] || null;
  }
  _duesMoney(n) { return '$' + (Number(n) || 0).toFixed(2); }
  _duesTokens(d) {
    return { amount: this._duesMoney(d.balance), min_payment: this._duesMoney(d.min_payment), pause_amount: this._duesMoney(d.line) };
  }
  _duesBlocksEvent(kind) { return kind === 'match' || kind === 'practice'; }
  _duesPillHtml(d) {
    if (!d || d.eligible !== false || !d.pay_url) return '';
    const text = MessageCopy.block('my_dues', 'pill', this._duesTokens(d));
    if (!text) return '';
    return `<a href="${this.escapeHtml(d.pay_url)}" target="_blank" rel="noopener"
              style="padding:3px 8px; border-radius:999px; border:1px solid #ef4444; background:rgba(239,68,68,0.18); color:#fca5a5; font-size:0.6rem; font-weight:800; line-height:1.2; text-decoration:none; white-space:normal; text-align:center;">
              ⛔ ${this.escapeHtml(text)}</a>`;
  }
  _renderDuesBanner() {
    const host = this.find('#my-dues-banner');
    if (!host) return;
    const rows = Object.values(this.dues || {}).filter(d => d && d.eligible === false);
    if (!rows.length || !MessageCopy.has('my_dues', 'banner')) { host.innerHTML = ''; return; }
    const button = MessageCopy.block('my_dues', 'banner_button') || 'Pay here';
    host.innerHTML = rows.map(d => {
      const who  = d.is_self ? '' : `${this.escapeHtml(d.first_name || 'Your player')}: `;
      const text = MessageCopy.block('my_dues', 'banner', this._duesTokens(d));
      return `<div style="display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap; margin:0 0 6px; padding:8px 10px; border-radius:8px; border:1px solid #ef4444; background:rgba(239,68,68,0.16); color:#fca5a5; font-size:0.74rem; font-weight:700; line-height:1.3;">
        <span>⛔ ${who}${this.escapeHtml(text)}</span>
        ${d.pay_url ? `<a href="${this.escapeHtml(d.pay_url)}" target="_blank" rel="noopener" style="padding:4px 10px; border-radius:999px; background:#ef4444; color:#fff; font-weight:800; text-decoration:none; white-space:nowrap;">${this.escapeHtml(button)}</a>` : ''}
      </div>`;
    }).join('');
  }

  _renderEventCard(ev, isPast = false) {
    const kind      = ev.kind || '';
    const per       = ev.my_rsvp;              // 'yes' | 'no' | 'maybe' | null
    const windowOpen= ev.rsvps_open_now !== false;
    const eligibilityOk = ev.my_rsvp_eligible !== false;
    const openMsg   = !windowOpen ? 'RSVP window not open yet' : '';
    const eligibilityMsg = eligibilityOk ? '' : (
      ev.my_rsvp_eligibility_reason || 'Not eligible to RSVP for this event'
    );
    const disabledMsg = isPast ? 'Event has passed' : (eligibilityMsg || openMsg);

    // Guardian rows.  A parent of a rostered child sees the child's
    // events (CalendarController's is_guardian) AND can RSVP for them
    // directly — one Go/No row per child in guardian_targets, written
    // server-side under the CHILD's own person_id (never the parent's),
    // so the parent never shows up on the who's-going list as a player.
    const guardianTargets = Array.isArray(ev.guardian_targets) ? ev.guardian_targets : [];
    const rsvpRows = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    const showOwnRsvpRow = eligibilityOk || guardianTargets.length === 0;
    // Pickup side / practice group the coach put this person on
    // (#event-center's Teams / Groups pill) — colour from the feed's my_sides.
    const sides = Array.isArray(ev.my_sides) ? ev.my_sides : [];
    const sideWord = kind === 'pickup' ? 'team' : 'group';
    const sideHtml = (personId, who) => {
      const side = sides.find(x => x.person_id === personId);
      if (!side) return '';
      return `<div style="font-size:0.66rem; font-weight:700; margin-top:2px;">
        <span style="display:inline-block; width:10px; height:10px; border-radius:50%; background:${this.escapeHtml(side.hex)};
                     border:1px solid rgba(255,255,255,0.5); vertical-align:middle;"></span>
        ${this.escapeHtml(who)} on the ${this.escapeHtml(side.label)} ${sideWord}</div>`;
    };
    const guardianRowsHtml = guardianTargets.map(child => {
      const childResponse = (rsvpRows.find(r => r && r.person_id === child.person_id) || {}).response || null;
      const childDisabledMsg = isPast ? 'Event has passed' : openMsg;
      const childClearing = this.eventSaving.has(`${ev.fh_event_id}:${child.person_id}:clear`);
      const childYesSaving = this.eventSaving.has(`${ev.fh_event_id}:${child.person_id}:yes`) || childClearing;
      const childNoSaving  = this.eventSaving.has(`${ev.fh_event_id}:${child.person_id}:no`) || childClearing;
      // Invited (fh_event_invites, migration 355): this kid is NOT on the
      // event's roster — the coach invited them to play up. Say so, and
      // word the ask as "are they available", not "are they going".
      const first = String(child.name || 'Your player').split(' ')[0];
      const callupHtml = child.callup ? `
            <span style="display:inline-block; margin-left:4px; padding:1px 6px; border-radius:999px;
                         background:rgba(245,158,11,0.18); border:1px solid rgba(245,158,11,0.55);
                         color:#fcd34d; font-size:0.56rem; font-weight:800; letter-spacing:0.03em;
                         vertical-align:middle;">🎟 INVITED</span>
            <div style="font-size:0.58rem; line-height:1.25; opacity:0.8; margin-top:2px;">
              The coach invited ${this.escapeHtml(first)} to play up in this game${child.callup_from ? ` (from ${this.escapeHtml(child.callup_from)})` : ''}.
              Please answer so the coach knows if ${this.escapeHtml(first)} is available.
            </div>` : '';
      return `
        <div style="display:flex; align-items:center; justify-content:space-between; gap:6px; margin-top:2px;">
          <div style="font-size:0.62rem; line-height:1.2; opacity:0.85; white-space:normal; overflow-wrap:break-word;">
            👤 ${this.escapeHtml(child.name || 'Your player')}${callupHtml}
            ${sideHtml(child.person_id, `${first} is`)}
          </div>
          <div style="display:flex; gap:3px; flex-shrink:0;">
            ${(!isPast && this._duesBlocksEvent(kind) && this._duesPillHtml(this._duesFor(child.person_id))) || `
              ${this._btn('Go', 'yes', childResponse === 'yes', 'solid', childYesSaving,
                         `data-ev-btn="yes" data-fh-event-id="${ev.fh_event_id}" data-ev-person-id="${child.person_id}"`, childDisabledMsg)}
              ${this._btn('No', 'no', childResponse === 'no', 'solid', childNoSaving,
                         `data-ev-btn="no" data-fh-event-id="${ev.fh_event_id}" data-ev-person-id="${child.person_id}"`, childDisabledMsg)}
            `}
          </div>
        </div>
      `;
    }).join('');

    // The caller's own side: the my_sides entry that is not one of their kids.
    const ownSide = sides.find(x => !guardianTargets.some(c => c.person_id === x.person_id));
    const ownSideHtml = ownSide ? sideHtml(ownSide.person_id, "You're") : '';

    const evYesKey  = `${ev.fh_event_id}:me:yes`;
    const evNoKey   = `${ev.fh_event_id}:me:no`;
    const evYesSaving = this.eventSaving.has(evYesKey) || this.eventSaving.has(`${ev.fh_event_id}:me:clear`);
    const evNoSaving  = this.eventSaving.has(evNoKey) || this.eventSaving.has(`${ev.fh_event_id}:me:clear`);

    const dateStr = this._eventDateStr(ev.starts_at);
    const timeStr = this._eventTimeStr(ev.starts_at);
    const title   = this._eventTitle(ev);
    const venue   = ev.location || '';
    // Which squad this is FOR — "U10 Travel", "APSL", "Liga 1" — as a
    // loud pill at the top of the card (owner, 2026-09-12: parents and
    // players could not tell the main game from the card front; lower
    // teams being RSVP-eligible made it worse). Primary teams come
    // from the backend (is_primary: the team's league is one of the
    // event's leagues), which is what separates the APSL game from the
    // Liga 1 game when both squads are tagged. Practices have no
    // league, so nothing is primary and every tagged team shows.
    const mainTeamLabels = this._mainTeamLabels(ev);
    const mainTeamHtml = mainTeamLabels.length ? `
            <div style="display:flex; flex-wrap:wrap; gap:3px; margin-bottom:2px;">
              ${mainTeamLabels.map(l => `<span style="display:inline-block; padding:1px 7px; border-radius:4px;
                            background:#1d4ed8; color:#fff; font-size:0.66rem; font-weight:800;
                            letter-spacing:0.04em; text-transform:uppercase; line-height:1.4;">${this.escapeHtml(l)}</span>`).join('')}
            </div>` : '';
    const descTags = this._parseDescTags(ev.description);
    // DB first: the tag when typed, else the league's default offsets
    // from kickoff (migration 395).
    const arrival  = ev.arrival_label || descTags.arrival || '';
    const warmup   = ev.warmup_label  || descTags.warmup  || '';
    const kickoff  = ev.kickoff_label || descTags.kickoff || '';
    const notes    = descTags.notes || '';
    const rsvps   = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    const playersGoingCount = rsvps.filter(r => r && r.response === 'yes' && !r.is_coach && !r.is_callup).length;
    const coachesGoingCount = rsvps.filter(r => r && r.response === 'yes' && r.is_coach).length;
    // Invited players who said yes are AVAILABLE, not going (migration 355).
    const callupsAvailCount = rsvps.filter(r => r && r.response === 'yes' && r.is_callup).length;
    const notGoingCount = rsvps.filter(r => r && r.response === 'no').length;
    const isExpanded = this.expandedEventId === ev.fh_event_id;
    const viewLabel = isExpanded ? 'Hide' : 'View';

    // Crest shown on the card front: opponent's (when resolved) for
    // games, falling back to Lighthouse's own crest when the opponent
    // isn't in gcal_opponent_aliases yet — every card gets a crest,
    // never blank. Practice/pickup always show Lighthouse's own.
    const LIGHTHOUSE_CREST = '/images/teams/logos/lighthouse-1893.png';
    // Intra-squad deliberately does NOT consult opponent_logo_url: both
    // sides are Lighthouse, so any "opponent" crest there is either our
    // own or a mis-resolution of our own team name. It gets the club
    // crest like practice and pickup do.
    const crestUrl = kind === 'match'
      ? (ev.opponent_logo_url || LIGHTHOUSE_CREST)
      : ((kind === 'practice' || kind === 'pickup' || kind === 'intrasquad') ? LIGHTHOUSE_CREST : null);
    // League crest, shown whenever the gcal `League:` tag is set (owner,
    // 2026-08-28: "we should always have league logo if league var is
    // set"). It rides on the corner of the main crest rather than
    // replacing it, so a normal away game still leads with the opponent.
    //
    // The case that forced this: two intra-squad games on the same day,
    // "Lighthouse APSL vs Lighthouse Liga 1" and its mirror. Lighthouse
    // is on both sides of both, so opponent_logo_url is identical and
    // the cards were indistinguishable — a player could not tell which
    // RSVP was for which squad. The league badge is the only thing that
    // separates them. Label goes in the meta line below too, since a
    // 16px badge alone is not readable as "APSL" vs "CASA".
    // One event can carry two leagues ("League: APSL, Liga 1"), so this
    // arrives comma-separated and every crest gets a badge — an
    // intra-squad or cross-league fixture then reads as "APSL vs CASA"
    // at a glance. Capped at two so the corner of a 32px crest stays
    // legible; the full list is always in the label below regardless.
    const leagueLogos = String(ev.league_logo_url || '')
      .split(',').map(u => u.trim()).filter(Boolean).slice(0, 2);
    const leagueBadgeHtml = leagueLogos.map((logo, i) => `
      <img src="${this.escapeHtml(logo)}" alt="${this.escapeHtml(ev.league || 'League')}"
           title="${this.escapeHtml(ev.league || '')}"
           style="position:absolute; right:${i * 13 - 3}px; bottom:-3px; width:17px; height:17px;
                  border-radius:50%; object-fit:contain; background:#fff;
                  box-shadow:0 0 0 1.5px rgba(10,20,40,0.9); z-index:${2 - i};"
           onerror="this.onerror=null; this.style.display='none';">
    `).join('');
    const crestHtml = crestUrl ? `
      <span style="position:relative; display:inline-block; flex-shrink:0; line-height:0;">
        <img src="${this.escapeHtml(crestUrl)}" alt=""
             style="width:32px; height:32px; border-radius:50%; object-fit:contain;
                    background:#fff; display:block;"
             onerror="this.onerror=null; this.src='${LIGHTHOUSE_CREST}';">
        ${leagueBadgeHtml}
      </span>
    ` : '';

    const leagueLabel = (ev.league || '').trim();
    const compactMeta = `${leagueLabel ? leagueLabel + ' · ' : ''}${playersGoingCount} players, ${coachesGoingCount} coaches going`
      + (callupsAvailCount ? ` · ${callupsAvailCount} invited available` : '')
      + ` · ${notGoingCount} not going`;
    const arrivalKickoffLine = (arrival || warmup || kickoff)
      ? [arrival ? `Arrival ${arrival}` : '', warmup ? `Warmup ${warmup}` : '', kickoff ? `Kickoff ${kickoff}` : ''].filter(Boolean).join(' · ')
      : '';
    const detailLines = [title, [dateStr, timeStr].filter(Boolean).join(' · ')].filter(Boolean);

    return `
      <div style="background: rgba(255,255,255,0.04);
                  border: 1px solid rgba(255,255,255,0.08);
                  border-radius: 6px;
                  padding: 5px 6px;
                  margin-bottom: 4px;">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:4px; flex-wrap:wrap;">
          ${crestHtml}
          <div style="min-width:160px; flex:1 1 160px;">
            ${mainTeamHtml}
            <div style="font-weight:700; font-size:0.7rem; line-height:1.2;">${this.escapeHtml(dateStr)} · ${this.escapeHtml(timeStr)}</div>
            <div style="font-size:0.66rem; font-weight:600; line-height:1.25; white-space:normal; overflow-wrap:break-word;">${this.escapeHtml(title)}</div>
            ${arrivalKickoffLine ? `<div style="font-size:0.6rem; line-height:1.2; opacity:0.85; white-space:normal; overflow-wrap:break-word;">${this.escapeHtml(arrivalKickoffLine)}</div>` : ''}
            ${venue ? `<div style="font-size:0.6rem; line-height:1.2; opacity:0.7; white-space:normal; overflow-wrap:break-word;">📍 ${this.escapeHtml(venue)}</div>` : ''}
            ${notes ? `<div style="font-size:0.6rem; line-height:1.2; opacity:0.7; white-space:normal; overflow-wrap:break-word;">📝 ${this.escapeHtml(notes)}</div>` : ''}
            ${ownSideHtml}
            ${guardianRowsHtml}
            <div style="font-size:0.6rem; opacity:0.74; line-height:1.2; white-space:normal; overflow-wrap:break-word;">${compactMeta}</div>
          </div>
          <div style="display:flex; align-items:center; gap:3px; flex-wrap:wrap; justify-content:flex-end; flex-shrink:0;">
            ${showOwnRsvpRow ? (
              (!isPast && this._duesBlocksEvent(kind) && this._duesPillHtml(this._duesFor(null))) || `
              ${this._btn('Go', 'yes', per === 'yes', 'solid', evYesSaving,
                         `data-ev-btn="yes" data-fh-event-id="${ev.fh_event_id}"`, disabledMsg)}
              ${this._btn('No', 'no', per === 'no', 'solid', evNoSaving,
                         `data-ev-btn="no" data-fh-event-id="${ev.fh_event_id}"`, disabledMsg)}
            `) : ''}
            <button type="button" data-view-event-id="${ev.fh_event_id}" style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1;">
              ${this.escapeHtml(viewLabel)}
            </button>
            ${kind === 'match' && ev.match_id ? `
              <button type="button" data-game-center-match-id="${ev.match_id}"
                      data-game-center-title="${this.escapeHtml(title)}"
                      data-game-center-when="${this.escapeHtml([dateStr, timeStr].filter(Boolean).join(' · '))}"
                      style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16); background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600; line-height:1;">
                📋 Lineup
              </button>
            ` : ''}
          </div>
        </div>
        ${isExpanded ? `
          <div style="margin-top: 6px; padding: 6px 7px; border-top: 1px solid rgba(255,255,255,0.08); display:grid; gap: 5px;">
            <div style="font-size:0.64rem; line-height:1.3; opacity:0.82;">${this.escapeHtml(detailLines.join(' • '))}</div>
            ${this._eventRsvpHtml(ev, isPast)}
          </div>
        ` : ''}
      </div>
    `;
  }

  // Player-facing names of the squad(s) an event is for. Primary teams
  // (backend is_primary — team's league ∈ event's leagues) win; when
  // none is primary (practice, pickup, untagged league) fall back to
  // every tagged team. Uses teams.label with its leading icon stripped
  // ("⚽ U10 Travel" → "U10 Travel", "🏆 APSL" → "APSL"), never the gcal
  // title, and never the raw teams.name ("Lighthouse Boys Club Liga 1").
  _mainTeamLabels(ev) {
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const stripIcon = (s) => String(s || '').replace(/^[^\p{L}\p{N}]+/u, '').trim();
    const nameOf = (t) => stripIcon(t.label) || stripIcon(t.short_label) || '';
    const primary = teams.filter(t => t && t.is_primary);
    const pool = primary.length ? primary : teams;
    return [...new Set(pool.map(nameOf).filter(Boolean))];
  }

  // Button renderer.  `semantic` is 'yes' | 'no' — drives colour.
  // `disabledMsg` non-empty disables the button and shows a tooltip.
  _btn(label, semantic, active, style, saving, attrs, disabledMsg, hintSuffix) {
    const disabled = !!disabledMsg || saving;
    const isYes = semantic === 'yes';
    let bg, fg, bd;
    if (active) {
      bg = isYes ? '#065f46' : '#7f1d1d';
      fg = '#ffffff';
      bd = bg;
    } else {
      bg = 'transparent';
      fg = 'inherit';
      bd = 'rgba(255,255,255,0.15)';
    }
    const opacity = disabled ? '0.5' : '1';
    const cursor  = disabled ? (saving ? 'wait' : 'not-allowed') : 'pointer';
    const tip     = disabledMsg
      ? disabledMsg
      : (hintSuffix ? label + hintSuffix : label);
    return `
      <button ${attrs}
              ${disabled ? 'disabled' : ''}
              title="${this.escapeHtml(tip)}"
              style="padding: 2px 6px; border-radius: 9999px;
                     background:${bg}; color:${fg};
                     border: 1px solid ${bd};
                     font-size: 0.6rem; font-weight: 600;
                     cursor:${cursor}; opacity:${opacity};">
        ${this.escapeHtml(label)}${saving ? ' …' : ''}
      </button>
    `;
  }

  _eventDateStr(iso) { return EventLabels.dateStr(iso); }

  _eventTimeStr(iso) { return EventLabels.timeStr(iso); }

  // Current response for `personId` (null = the caller's own row) on
  // `ev`, used to decide whether a click is a new answer or a deselect
  // of the button already showing active.
  _currentRsvpFor(ev, personId) {
    if (!personId) return ev.my_rsvp || null;
    const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
    const row = rsvps.find(r => r && r.person_id === personId);
    return (row && row.response) || null;
  }

  // Clicking an already-active Go/No re-clicks it off — same button,
  // second tap clears the RSVP back to no response — rather than being
  // stuck once answered.
  async _sendEventRsvp(fhEventId, response, personId = null) {
    const ev = (this.events || []).find(e => e.fh_event_id === fhEventId);
    if (ev && this._currentRsvpFor(ev, personId) === response) {
      return this._clearEventRsvp(fhEventId, personId);
    }
    const key = `${fhEventId}:${personId || 'me'}:${response}`;
    if (this.eventSaving.has(key)) return;
    this.eventSaving.add(key);
    this._renderEvents();
    try {
      const payload = { fh_event_id: fhEventId, response };
      if (personId) payload.person_id = personId;
      const body = await this._fetch('/api/calendar/rsvp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      // Optimistic local mutation so the UI updates instantly.
      if (ev) {
        const rsvpPersonId  = (body && body.rsvp && body.rsvp.person_id) || personId;
        const finalResponse = (body && body.rsvp && body.rsvp.response) || response;
        if (!personId) {
          ev.my_rsvp = finalResponse;
          ev.my_rsvp_created_via = 'manual';
        }
        if (rsvpPersonId) {
          const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : (ev.rsvps = []);
          const row = rsvps.find(r => r && r.person_id === rsvpPersonId);
          if (row) {
            row.response = finalResponse;
            row.created_via = 'manual';
          } else {
            rsvps.push({ person_id: rsvpPersonId, response: finalResponse, created_via: 'manual', name: personId ? undefined : 'You' });
          }
        }
      }
    } catch (err) {
      console.error('[my] event RSVP failed:', err);
      alert(`Could not save RSVP: ${err.message}`);
    } finally {
      this.eventSaving.delete(key);
      this._renderEvents();
    }
  }

  async _clearEventRsvp(fhEventId, personId = null) {
    const key = `${fhEventId}:${personId || 'me'}:clear`;
    if (this.eventSaving.has(key)) return;
    this.eventSaving.add(key);
    this._renderEvents();
    try {
      const payload = { fh_event_id: fhEventId };
      if (personId) payload.person_id = personId;
      const body = await this._fetch('/api/calendar/rsvp', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const ev = (this.events || []).find(e => e.fh_event_id === fhEventId);
      if (ev) {
        if (!personId) {
          ev.my_rsvp = null;
          ev.my_rsvp_created_via = null;
        }
        const clearedPersonId = (body && body.person_id) || personId;
        if (clearedPersonId) {
          const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
          const row = rsvps.find(r => r && r.person_id === clearedPersonId);
          // Leave the row in place with a cleared response rather than
          // removing it — the roster query includes every rostered
          // person regardless of response, so this person still needs
          // to show up in the "no response" bucket.
          if (row) {
            row.response = null;
            row.created_via = null;
          }
        }
      }
    } catch (err) {
      console.error('[my] event RSVP clear failed:', err);
      alert(`Could not clear RSVP: ${err.message}`);
    } finally {
      this.eventSaving.delete(key);
      this._renderEvents();
    }
  }

  // ────── Chat (latest message on top, expandable) ──────────────────

  _renderChatShell() {
    const box = this.find('#my-chat');
    if (!box) return;
    box.innerHTML = `
      <div id="chat-box" style="background: rgba(15,23,42,0.55); border-radius:7px;
                  border:1px solid rgba(255,255,255,0.06); overflow:hidden;">
        <div style="display:flex; align-items:center; justify-content:space-between;
                    padding:5px 7px; border-bottom:1px solid rgba(255,255,255,0.08);
                    background: rgba(15,23,42,0.75);">
          <div id="chat-title" style="font-size:0.72rem; font-weight:700; opacity:0.9;">Chat</div>
          <div style="display:flex; align-items:center; gap:6px;">
            <button id="push-test-btn" type="button" style="display:none; padding:2px 7px;
                    border-radius:999px; border:1px solid rgba(255,255,255,0.16);
                    background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600;"
                    title="Sends a test push to this device only — /api/my/push-test always targets the caller, never anyone else">
              🔔 Send test
            </button>
            <button id="chat-view-btn" type="button" aria-label="View chat"
                    style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16);
                           background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600;">
              View chat
            </button>
          </div>
        </div>
        <div id="chat-links" style="display:none; flex-wrap:wrap; gap:5px; padding:5px 7px;
                    border-bottom:1px solid rgba(255,255,255,0.08);"></div>
        <div id="chat-list" style="padding: 5px 7px 6px;">
          <div class="loading-state"><div class="spinner"></div><p>Loading chat…</p></div>
        </div>
        <div style="display:flex; align-items:flex-end; gap:6px; padding:6px 7px 7px;
                    border-top:1px solid rgba(255,255,255,0.08); background:rgba(2,6,23,0.35);">
          <textarea id="chat-input" rows="1" placeholder="Write a message…"
                    style="flex:1; resize:none; min-height:32px; max-height:110px; border-radius:6px;
                           border:1px solid rgba(255,255,255,0.12); background:rgba(15,23,42,0.78);
                           color:#f8fafc; padding:7px 8px; font-size:0.72rem; line-height:1.3;"></textarea>
          <button id="chat-send-btn" type="button" disabled
                  style="padding:7px 10px; border-radius:6px; border:1px solid rgba(96,165,250,0.35);
                         background:rgba(59,130,246,0.2); color:#dbeafe; font-size:0.72rem; font-weight:700;">
            Send
          </button>
        </div>
      </div>
    `;
    this._syncChatComposerState();
  }

  _syncChatComposerState() {
    const input = this.find('#chat-input');
    const btn = this.find('#chat-send-btn');
    if (!input || !btn) return;
    btn.disabled = this.chatSending || !input.value.trim();
  }

  // ────── Push notifications (opt-in only — see backend/src/services/
  // WebPushService.h for why this can never be silent/automatic) ─────

  // Sets the enable-notifications button's visibility/label/enabled
  // state to match reality: already subscribed, blocked, unsupported
  // (bare Safari on iOS — Push API only exists there once "installed"
  // via Add to Home Screen), or ready to opt in.
  // The on/off control is the PushOptIn toggle at the top of the page;
  // this only decides whether the "send test" button shows (subscribed
  // on this device).
  async _initPushUI() {
    const testBtn = this.find('#push-test-btn');
    if (!testBtn) return;
    testBtn.style.display = 'none';
    if (!('serviceWorker' in navigator) || !('PushManager' in window)) return;
    try {
      const reg = await navigator.serviceWorker.ready;
      const sub = await reg.pushManager.getSubscription();
      if (sub) testBtn.style.display = '';
    } catch (err) {
      console.warn('[my] push subscription check failed:', err);
    }
  }

  async _onPushTestClick() {
    const btn = this.find('#push-test-btn');
    if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
    try {
      const res = await this._fetch('/api/my/push-test', { method: 'POST' });
      const sent = res && res.sent;
      if (btn) {
        btn.disabled = false;
        btn.textContent = sent ? '🔔 Sent!' : '🔔 No subscription found';
        setTimeout(() => { if (btn) btn.textContent = '🔔 Send test'; }, 3000);
      }
    } catch (err) {
      console.error('[my] push test failed:', err);
      if (btn) { btn.disabled = false; btn.textContent = '🔔 Send test'; }
    }
  }

  // PushManager.subscribe wants applicationServerKey as a Uint8Array,
  // not the base64url string the backend hands back.
  _urlBase64ToUint8Array(base64Url) {
    const padding = '='.repeat((4 - (base64Url.length % 4)) % 4);
    const base64 = (base64Url + padding).replace(/-/g, '+').replace(/_/g, '/');
    const raw = atob(base64);
    const out = new Uint8Array(raw.length);
    for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
    return out;
  }

  // Messaging is off for this section (chats.messaging_enabled = false,
  // mig 406 — the Men's chat lives on GroupMe): the chat box becomes the
  // GroupMe section.  Owner 2026-09-22: "show the last 5 gm messages and
  // have the groupme join button in same section and mark it off with
  // border".  Header (push buttons live there) + join link strip stay;
  // the history slot shows the feed; the composer goes.
  _renderLinksOnly() {
    const box = this.find('#chat-box');
    if (!box) return;
    box.style.border = '1.5px solid rgba(0,175,240,0.6)';   // GroupMe blue
    const view = this.find('#chat-view-btn');
    if (view) view.hidden = true;
    this._syncGroupMeComposer();
    const title = this.find('#chat-title');
    if (title && this.groupmeTitle) title.textContent = this.groupmeTitle;
    const list = this.find('#chat-list');
    if (list) list.innerHTML = this.groupmeMessages.length ? '' : `
      <div style="opacity:0.7; font-size:0.68rem;">Loading GroupMe…</div>`;
    const standalone = this.find('#my-groupme');
    if (standalone) standalone.hidden = true;
    if (this.groupmeMessages.length) this._renderGroupMe();
  }

  // In the merged GroupMe section the composer stays only when the
  // integration allows posting (post_messages, mig 407) — the message is
  // relayed into the group with the sender's name in the text.
  _syncGroupMeComposer() {
    const input = this.find('#chat-input');
    if (!input || !input.parentElement) return;
    input.parentElement.hidden = !this.groupmeCanPost;
  }

  // Section links (chat_links rows for the viewer's own club chat —
  // e.g. the Men's GroupMe join link).  Label + url both come from the DB.
  _renderChatLinks(links) {
    const box = this.find('#chat-links');
    if (!box) return;
    const safe = links.filter(l => /^https:\/\//i.test(l.url || ''));
    box.style.display = safe.length ? 'flex' : 'none';
    box.innerHTML = safe.map(l => `
      <a href="${this.escapeHtml(l.url)}" target="_blank" rel="noopener"
         style="padding:4px 9px; border-radius:999px; border:1px solid rgba(96,165,250,0.35);
                background:rgba(59,130,246,0.2); color:#dbeafe; font-size:0.66rem; font-weight:700;
                line-height:1; text-decoration:none; display:inline-flex; align-items:center;">
        ${this.escapeHtml(l.label)}
      </a>`).join('');
  }

  _renderChatMessages() {
    const box = this.find('#chat-list');
    if (!box) return;

    if (this.chatError) {
      box.innerHTML = `<div class="empty-state"><p>Chat unavailable: ${this.escapeHtml(this.chatError)}</p></div>`;
      return;
    }
    if (!this.chatMessages || !this.chatMessages.length) {
      box.innerHTML = `
        <div style="opacity:0.7; font-size:0.68rem; line-height:1.2; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
          No messages yet — be the first to say hi.
        </div>`;
      return;
    }

    // Chat is stored oldest→newest; newest-first means iterate reversed.
    const reversed = this.chatMessages.slice().reverse();
    const total    = reversed.length;

    // Compressed: latest message only + "Show N more messages" toggle.
    // Expanded: full history newest-first + "Show less" toggle.
    if (!this.chatExpanded) {
      const latest = reversed[0];
      const more   = total > 1 ? total - 1 : 0;
      const toggle = more > 0
        ? `<button id="chat-expand-toggle" type="button"
                   style="display:block; width:100%; margin-top:4px;
                          background:transparent; color:#93c5fd;
                          border:1px solid rgba(147,197,253,0.3);
                          border-radius:5px; padding:3px 6px;
                          font-size:0.62rem; font-weight:600; cursor:pointer;">
             ▼ Show ${more} older message${more !== 1 ? 's' : ''}
           </button>`
        : '';
      box.innerHTML = `<div style="font-size:0.68rem; line-height:1.2; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${this.escapeHtml(latest.message || '')}</div>` + toggle;
      return;
    }

    // Expanded: full list + collapse toggle at the top.
    const rows = reversed.map(m => this._renderChatRow(m)).join('');
    const toggle = `
      <button id="chat-expand-toggle" type="button"
              style="display:block; width:100%; margin: 0 0 8px;
                     background:transparent; color:#93c5fd;
                     border:1px solid rgba(147,197,253,0.3);
                     border-radius:6px; padding:6px 10px;
                     font-size:0.85rem; font-weight:600; cursor:pointer;">
        ▲ Show only latest message
      </button>`;
    box.innerHTML = `
      ${toggle}
      <div style="max-height: 55vh; overflow-y:auto;">${rows}</div>`;
  }

  _renderChatRow(m) {
    const first = (m.author_first_name || '').trim();
    const last  = (m.author_last_name  || '').trim();
    const author = (first || last)
      ? this.escapeHtml(first + (last ? ' ' + last.charAt(0) + '.' : ''))
      : 'Someone';
    const when = this._chatWhen(m.created_at);
    const escaped = this.escapeHtml(m.message);
    const linkified = escaped.replace(
      /(https?:\/\/[^\s<]+)/g,
      `<a href="$1" target="_blank" rel="noopener noreferrer" style="color:#93c5fd; text-decoration:underline;">$1</a>`);
    const mine = m.user_id === this.chatViewerId;
    const nameColor = mine ? '#93c5fd' : '#fbbf24';
    return `
      <div style="padding: 4px 0; border-bottom:1px solid rgba(255,255,255,0.06);">
        <div style="display:flex; justify-content:space-between; gap:6px; margin-bottom:2px;">
          <div style="font-size:0.7rem; color:${nameColor}; font-weight:600;">${author}</div>
          <div style="font-size:0.62rem; opacity:0.55;">${this.escapeHtml(when)}</div>
        </div>
        <div style="white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
                    font-size:0.68rem; line-height:1.2;">${linkified}</div>
      </div>`;
  }

  // ────── GroupMe feed (read-only) ──────────────────────────────────

  async _loadGroupMe() {
    const res = await this._fetch('/api/my/groupme/feed');
    const incoming = (res && res.messages) || [];
    const newestId = m => (m.length ? m[0].id : '');
    const changed = newestId(incoming) !== newestId(this.groupmeMessages)
      || incoming.length !== this.groupmeMessages.length;
    this.groupmeTitle = (res && res.title) || '';
    const couldPost = this.groupmeCanPost;
    this.groupmeCanPost = !!(res && res.can_post);
    this.groupmeMessages = incoming;
    if (changed) this._renderGroupMe();
    if (!this.chatMessaging && couldPost !== this.groupmeCanPost) this._syncGroupMeComposer();
  }

  _renderGroupMe() {
    const msgs = this.groupmeMessages;
    if (!this.chatMessaging) {
      // Merged section (see _renderLinksOnly): last 5 in the history slot,
      // the rest behind a toggle; title from the integration row.
      const title = this.find('#chat-title');
      if (title && this.groupmeTitle) title.textContent = this.groupmeTitle;
      const standalone = this.find('#my-groupme');
      if (standalone) standalone.hidden = true;
      const list = this.find('#chat-list');
      if (!list) return;
      // Oldest at the top, newest at the bottom — the way GroupMe reads
      // (owner 2026-09-22: "flip the messages so they are latest at
      // bottom like in gm").  The API hands them newest-first; the
      // "older" toggle sits above, where the older messages would be.
      const LATEST = 5;
      const shown = (this.groupmeExpanded ? msgs : msgs.slice(0, LATEST)).slice().reverse();
      const older = Math.max(0, msgs.length - LATEST);
      const toggle = older > 0
        ? `<div style="text-align:center; padding-bottom:4px;">
             <button id="groupme-expand-toggle" type="button"
                     style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16);
                            background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600;">
               ${this.groupmeExpanded ? `Latest ${LATEST} only` : `Show ${older} older`}
             </button>
           </div>`
        : '';
      list.innerHTML = msgs.length
        ? toggle + shown.map(m => this._renderGroupMeRow(m)).join('')
        : `<div style="opacity:0.7; font-size:0.68rem;">No GroupMe messages yet.</div>`;
      return;
    }
    const box = this.find('#my-groupme');
    if (!box) return;
    box.hidden = !msgs.length;
    if (!msgs.length) return;
    const shown = this.groupmeExpanded ? msgs : msgs.slice(0, 1);
    const older = msgs.length - 1;
    const toggle = older > 0
      ? `<button id="groupme-expand-toggle" type="button"
                 style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16);
                        background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600;">
           ${this.groupmeExpanded ? 'Latest only' : `Show ${older} older`}
         </button>`
      : '';
    box.innerHTML = `
      <div style="background: rgba(15,23,42,0.55); border-radius:7px;
                  border:1px solid rgba(255,255,255,0.06); overflow:hidden;">
        <div style="display:flex; align-items:center; justify-content:space-between;
                    padding:5px 7px; border-bottom:1px solid rgba(255,255,255,0.08);
                    background: rgba(15,23,42,0.75);">
          <div style="font-size:0.72rem; font-weight:700; opacity:0.9;">${this.escapeHtml(this.groupmeTitle)}</div>
          ${toggle}
        </div>
        <div style="padding: 5px 7px 6px;">${shown.map(m => this._renderGroupMeRow(m)).join('')}</div>
      </div>`;
  }

  _renderGroupMeRow(m) {
    const when = this._chatWhen(m.created_at ? new Date(m.created_at * 1000).toISOString() : '');
    const linkified = this.escapeHtml(m.text || '').replace(
      /(https?:\/\/[^\s<]+)/g,
      `<a href="$1" target="_blank" rel="noopener noreferrer" style="color:#93c5fd; text-decoration:underline;">$1</a>`);
    const image = /^https:\/\/i\.groupme\.com\//.test(m.image_url || '')
      ? `<a href="${this.escapeHtml(m.image_url)}" target="_blank" rel="noopener noreferrer">
           <img src="${this.escapeHtml(m.image_url)}.preview" alt="" loading="lazy"
                style="max-height:90px; border-radius:5px; margin-top:3px; display:block;"></a>`
      : '';
    return `
      <div style="padding: 4px 0; border-bottom:1px solid rgba(255,255,255,0.06);">
        <div style="display:flex; justify-content:space-between; gap:6px; margin-bottom:2px;">
          <div style="font-size:0.7rem; color:#fbbf24; font-weight:600;">${this.escapeHtml(m.name || '')}</div>
          <div style="font-size:0.62rem; opacity:0.55;">${this.escapeHtml(when)}</div>
        </div>
        <div style="font-size:0.68rem; line-height:1.25; white-space:pre-wrap; overflow-wrap:anywhere;">${linkified}</div>
        ${image}
      </div>`;
  }

  _chatWhen(iso) {
    if (!iso) return '';
    const t = new Date(iso);
    if (isNaN(t.getTime())) return '';
    const now = new Date();
    if (t.toDateString() === now.toDateString()) {
      return t.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
    }
    const yest = new Date(now); yest.setDate(now.getDate() - 1);
    if (t.toDateString() === yest.toDateString()) {
      return 'Yesterday ' + t.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
    }
    const sameYear = t.getFullYear() === now.getFullYear();
    return t.toLocaleDateString(undefined, sameYear
      ? { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }
      : { month: 'short', day: 'numeric', year: 'numeric' });
  }

  // Background refetch of events + RSVPs, called from the unified poll so
  // other players' Going/Not Going responses show up without a manual
  // reload. Silent on failure — just keeps showing last-known data. Only
  // re-renders when the "This Week" range is active; browsing an old-range
  // view (_renderOldEvents) is left alone so it doesn't get yanked out from
  // under the player mid-scroll.
  async _refreshEvents() {
    let upRes;
    try {
      // Same 14-day reach as _bootstrap. With 7, the 15-second poll
      // silently dropped an early-released next week (Sunday's games
      // vanished on mobile until a hard refresh — owner 2026-09-05).
      upRes = await this._fetch('/api/calendar/upcoming?days=14');
    } catch (err) {
      return;
    }
    this.events = upRes.events || [];
    this.dues   = upRes.dues   || this.dues || {};
    if (this.eventsRange === 'current') {
      this._renderEvents();
    }
  }

  _startPoll() {
    this._stopPoll();
    // Single unified poll — this is a one-screen layout, so there's no
    // "background" vs "foreground" distinction any more. Refreshes both
    // chat and the events/RSVP data so other players' responses show up
    // without a manual page reload.
    this.pollTimer = setInterval(() => {
      if (document.hidden) return;
      this._loadChat(/*initial*/ false).catch(() => {});
      this._refreshEvents().catch(() => {});
      // The backend caches GroupMe for 60s, so every 4th tick is plenty.
      if (++this.pollTick % 4 === 0) this._loadGroupMe().catch(() => {});
    }, 15000);
  }

  _stopPoll() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
  }

  async _loadChat(initial) {
    const sinceId = initial ? 0 : (this.chatMessages.length
      ? this.chatMessages[this.chatMessages.length - 1].id
      : 0);
    const url = sinceId > 0
      ? `/api/my/chat/messages?since_id=${sinceId}`
      : '/api/my/chat/messages';

    let res;
    try {
      res = await this._fetch(url);
    } catch (err) {
      if (initial) {
        this.chatError = err.message || 'Failed to load chat.';
        this.chatLoaded = true;
        this._renderChatMessages();
      }
      return;
    }

    const incoming = (res && res.messages) || [];
    if (initial) {
      this.chatMessages = incoming;
      this.chatViewerId = (res && res.viewer_user_id) || 0;
      this.chatLoaded = true;
      this.chatError = null;
      this.chatMessaging = !(res && res.messaging === false);
      this._renderChatLinks((res && res.links) || []);
      if (!this.chatMessaging) { this._renderLinksOnly(); return; }
    } else if (!this.chatMessaging) {
      return;  // the section chats on GroupMe — nothing to poll
    } else if (incoming.length > 0) {
      this.chatMessages = this.chatMessages.concat(incoming);
      if (res && res.viewer_user_id) this.chatViewerId = res.viewer_user_id;
    } else {
      return;  // nothing new — skip re-render
    }
    this._renderChatMessages();
  }

  async _sendChatMessage() {
    if (this.chatSending) return;
    const ta = this.find('#chat-input');
    if (!ta) return;
    const text = (ta.value || '').trim();
    if (!text) return;

    this.chatSending = true;
    const btn = this.find('#chat-send-btn');
    if (btn) btn.disabled = true;

    try {
      if (!this.chatMessaging) {
        // No in-app chat here: relay to the section's GroupMe (mig 407).
        await this._fetch('/api/my/groupme/messages', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message: text }),
        });
        ta.value = '';
        ta.style.height = 'auto';
        await this._loadGroupMe();   // server dropped its cache — the post shows now
        return;
      }
      const res = await this._fetch('/api/my/chat/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: text }),
      });
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
      }
      ta.value = '';
      ta.style.height = 'auto';
      this._renderChatMessages();
    } catch (err) {
      console.error('[my] chat send failed:', err);
      alert(`Send failed: ${err.message}`);
    } finally {
      this.chatSending = false;
      this._syncChatComposerState();
    }
  }
}

