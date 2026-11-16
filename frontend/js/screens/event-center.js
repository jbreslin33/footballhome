// EventCenterScreen — THE 📅 Calendar (URL #calendar; screen key still
// 'event-center').  Owner 2026-11-16: "rsvp, calendar and event center should
// be one page. when you click an event it should take you to the event" — the
// old #calendar screen (calendar.js) and the RSVP menu door folded in here:
// 🗓 Week · Month · Agenda views, and for admins the schedule-release and
// field-clash strips (lib/calendar-ops.js), ⚠ tag audit on tiles and Google
// soccer events not classified yet (a tap opens Google).  Post / flyer moved
// onto the event itself (lib/event-posts.js).
//
// Was: #event-center: the week calendar, Monday–Sunday
// (owner 2026-10-27: "a calendar is best … one source of data … cal with
// pills to populate cal"; "clicking a card opens that event to view and
// edit").  The type pills (lib/event-kind-switch.js) and section chips
// choose what fills it, ‹ › / This week / the date box step weeks, and a
// tap opens the event on its own screen by kind (EventKindSwitch.open):
// a game in Game Center, a practice or pickup in #practice, anything else
// in #event — the EventScreen family (screens/event-screen.js).
//
// Doors: { pick: true, kind } — the 📋 Event Center tile and the type
// pills.  An old door that hands over one event ({ event }, saved history)
// shows that event's week.
//
// ✓/✗ on a tile: POST|DELETE /api/calendar/rsvp as yourself (my_rsvp) and,
// with person_id, for each of your kids on it (guardian_targets).
//
// Feed: GET /api/calendar/upcoming?start=<Monday>&days=7 — already scoped
// per viewer: admins every club event, coaches their teams', players and
// parents their own + their kids' (docs/event-center-design.md, slice 2).
//
// ONE page for every tier (owner 2026-11-14: "for me cal grid should be
// standard with the red line"): the calendar for everyone, person chips
// (Everyone · Me · each kid) when the week holds more than your own events,
// earlier days greyed, and on a phone the first open of this week scrolls to
// the red NOW line.
//
// Slice 3 (MyScreen no longer mounted here): the page is three pieces, the
// same for every tier —
//   NoticeStrip  (lib/notices.js)          dues, volunteer shift — above the calendar
//   the week calendar                       this screen
//   👤 Mine                                 page links, PushOptIn, SectionChat
//                                           (components/section-chat.js), FinesPanel
//                                           (components/fines-panel.js) — below it
class EventCenterScreen extends Screen {
  static get VIEWS() { return ['week', 'month', 'agenda']; }
  static get AGENDA_DAYS() { return 28; }
  static get CATEGORY_LABELS() { return { mens: 'Men', womens: 'Women', boys: 'Boys', girls: 'Girls', staff: 'Staff' }; }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.events   = null;      // the week's feed
    this.kind     = 'all';
    this.category = 'all';
    this.person   = 'all';       // person chip: 'all' | 'me' | a kid's person_id
    this.weekStart = EventCenterScreen.monday(new Date());   // the calendar's Monday, kept across visits
    this.anchor   = new Date();    // the day the page is on (month view: its month)
    // 🗓 Week · Month · Agenda (the old #calendar's three views, owner 11/16:
    // "rsvp, calendar and event center should be one page") — remembered per
    // browser, a convenience only.
    // 📅 By event (the calendar) · 👥 By person (the RSVP Reminders board,
    // folded in 11/16 — owner: "3. fold it").  Admins only; the board is
    // the RsvpBoardScreen class (screens/rsvps.js) hosted in #ec-people.
    this.mode = 'event';
    this.board = null;
    this.view = 'week';
    try { const v = localStorage.getItem('fh.cal.view'); if (EventCenterScreen.VIEWS.includes(v)) this.view = v; } catch {}
    this.error    = null;
    this.saving   = new Set();   // fh_event_id of a self-RSVP in flight
    this.rsvpNote = {};          // fh_event_id → last self-RSVP error, on its tile
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ec-chip { padding:5px 12px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.8rem;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .ec-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .ec-pick { display:flex; flex-direction:column; align-items:flex-start; gap:2px; text-align:left; padding:8px 10px; width:100%; min-width:0; white-space:normal; }
        .ec-past { opacity:0.55; }
        .ec-week { display:grid; grid-template-columns:1fr; gap:10px; }
        .ec-day { display:flex; flex-direction:column; gap:6px; min-width:0; }
        .ec-dayh { font-size:0.72rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; opacity:0.75;
                   border-bottom:1px solid var(--border-color); padding-bottom:3px; }
        .ec-day.today .ec-dayh { color:var(--primary-color); opacity:1; border-bottom-color:var(--primary-color); }
        .ec-none { font-size:0.8rem; opacity:0.35; }
        .ec-day.past { opacity:0.5; }
        .ec-day.past .ec-past { opacity:1; }
        #ec-stack { display:flex; flex-direction:column; gap:8px; padding: var(--space-3) var(--space-4) var(--space-4); max-width:1400px; margin:0 auto; }
        #ec-notices { display:flex; flex-direction:column; gap:6px; }
        #ec-mine { display:flex; flex-direction:column; gap:8px; margin-top:var(--space-4); }
        .ec-mine-head { display:flex; align-items:center; justify-content:space-between; gap:8px; flex-wrap:wrap;
                        border-bottom:1px solid var(--border-color); padding-bottom:4px; }
        .ec-mine-head h2 { margin:0; font-size:1rem; }
        .ec-link { padding:3px 9px; border-radius:999px; border:1px solid var(--border-color); background:transparent;
                   color:var(--text-primary); font-size:0.7rem; font-weight:600; cursor:pointer; }
        .ec-now { display:flex; align-items:center; gap:6px; color:#ef4444; font-size:0.66rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; white-space:nowrap; }
        .ec-now::before, .ec-now::after { content:''; flex:1; height:2px; background:#ef4444; }
        @media (min-width: 900px) { .ec-week { grid-template-columns:repeat(7, minmax(0, 1fr)); } }
        .ec-views { display:inline-flex; gap:4px; margin-left:auto; }
        .ec-agenda { display:grid; grid-template-columns:repeat(auto-fill, minmax(260px, 1fr)); gap:8px; }
        .ec-month-wrap { overflow-x:auto; }
        .ec-month { display:grid; grid-template-columns:repeat(7, minmax(84px, 1fr)); gap:1px; min-width:600px;
                    background:var(--border-color); border:1px solid var(--border-color); border-radius:8px; overflow:hidden; }
        .ec-mhead { background:var(--bg-secondary); font-size:0.68rem; font-weight:800; text-transform:uppercase; letter-spacing:0.05em; padding:5px 6px; opacity:0.75; }
        .ec-mcell { background:var(--bg-primary, var(--bg-secondary)); min-height:92px; padding:4px; display:flex; flex-direction:column; gap:3px; min-width:0; }
        .ec-mcell.out { opacity:0.4; }
        .ec-mcell.today .ec-mday { background:var(--primary-color); color:#fff; }
        .ec-mday { align-self:flex-start; min-width:22px; text-align:center; border-radius:999px; font-size:0.75rem; font-weight:800; padding:1px 5px;
                   border:none; background:transparent; color:var(--text-primary); cursor:pointer; }
        .ec-mchip { font-size:0.68rem; font-weight:700; line-height:1.25; padding:2px 4px; border-radius:4px; cursor:pointer;
                    border-left:3px solid var(--primary-color); background:var(--bg-secondary);
                    white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .ec-mchip.ec-past { opacity:0.55; }
        .ec-mmore { font-size:0.66rem; opacity:0.7; border:none; background:transparent; color:var(--text-primary); text-align:left; padding:0 4px; cursor:pointer; }
      </style>
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ec-title">📋 Event Center</h1>
        <p class="subtitle" id="ec-sub"></p>
        <!-- 🏟️ Games · 🏃 Practices · ⚽ Pickup · 📅 All (lib/event-kind-switch.js) -->
        <div id="ec-kinds" style="display:contents;"></div>
      </div>
      <div id="ec-stack">
        <div id="ec-mode" style="display:none; gap:var(--space-1); flex-wrap:wrap;"></div>
        <div id="ec-notices" style="display:none;"></div>
        <!-- admin: schedule release + field clashes (lib/calendar-ops.js) -->
        <div id="ec-ops" style="display:none; flex-direction:column; gap:6px;">
          <div id="ec-release"></div>
          <div id="ec-clash"></div>
        </div>
        <!-- 🎞 Weekend slideshows (mig 1179) — club-wide, so here, not on
             each game (moved off Game Center 11/16).  Who may post. -->
        <div id="ec-weekend"></div>
        <div id="ec-body"></div>
        <div id="ec-people" style="display:none;"></div>
        <section id="ec-mine">
          <div class="ec-mine-head"><h2 id="ec-mine-title">👤 Mine</h2><span id="ec-mine-links" style="display:flex; gap:4px; flex-wrap:wrap;"></span></div>
          <div id="ec-push"></div>
          <div id="ec-chat"></div>
          <div id="ec-fines" hidden></div>
        </section>
      </div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter(params = {}) {
    // An old #rsvps door (menu, dashboard, saved return) or a phone reload
    // mid-reminders (resumeState) lands on 👥 By person.
    const r = params.resume || {};
    // Each history entry remembers its half (_keepMode), so Back returns to it.
    this.mode = (params.mode === 'people' || r.mode === 'people') ? 'people' : 'event';
    this._boardParams = params.board || (r.board ? { resume: r.board } : null);
    this._mountMine();
    this._mountOps();
    this._mountWeekend();
    this._paintMode();
    // An old door with one event (saved history) shows that event's week.
    const evAt = params.event && new Date(params.event.starts_at);
    if (evAt && !isNaN(evAt)) { this.anchor = evAt; this.weekStart = EventCenterScreen.monday(evAt); this.events = null; }
    // A type pill (EventKindSwitch) lights that kind on the calendar.
    if (params.kind) this.kind = params.kind;
    // Back from an event this screen opened → where you were; otherwise the
    // first paint of this week scrolls to the NOW line (phone only).
    this._restoreScroll = this._openedEvent ? this._savedScroll : null;
    this._openedEvent = false;
    this._autoScroll = this._restoreScroll == null;
    this.error = null;
    this._render();
    // The DB copy (title, subtitle, not-posted, now line) — cached across screens.
    if (window.MessageCopy) MessageCopy.load(this.auth).then(() => this._render()).catch(() => {});
    this._loadEvents();
    // Pull Google Calendar in the background (GcalRefresh, 11/3) — the week
    // shows from the DB now and reloads once the pull has landed.
    if (window.GcalRefresh) GcalRefresh.ping(this.auth, () => this._loadEvents());
  }

  onExit() {
    if (this.chat) this.chat.stop();
    if (this.board) this.board.isMounted = false;
  }

  // For Navigation.rememberForReturn: a phone reload after a REMIND text
  // comes back to the board as it was.
  resumeState() {
    return { mode: this.mode, board: this.board && this.mode === 'people' ? this.board.resumeState() : null };
  }

  // The half in this history entry's params (replaceState), so Back from an
  // event opened here — or from a page opened off the board — lands on it.
  _keepMode() {
    const nav = this.navigation;
    if (!nav || nav.currentState !== 'event-center') return;
    nav.currentParams = { ...(nav.currentParams || {}), mode: this.mode };
    delete nav.currentParams.board;
    try { window.history.replaceState(nav._historyState('event-center', nav.currentParams), '', window.location.hash); } catch (_) {}
  }

  // The switch, and which half of the page shows.
  _paintMode() {
    const admin = this._isAdmin() && typeof RsvpBoardScreen !== 'undefined';
    if (!admin) this.mode = 'event';
    const bar = this.find('#ec-mode');
    const people = this.mode === 'people';
    if (bar) {
      bar.style.display = admin ? 'flex' : 'none';
      const cp = (tier, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb;
      const chip = (m, label) => `<button type="button" class="ec-chip ${this.mode === m ? 'on' : ''}" data-ec-mode="${m}">${this.escapeHtml(label)}</button>`;
      bar.innerHTML = admin ? chip('event', cp('mode_event', '📅 By event')) + chip('people', cp('mode_people', '👥 By person')) : '';
    }
    for (const [sel, showInPeople] of [['#ec-body', false], ['#ec-ops', false], ['#ec-weekend', false], ['#ec-mine', false], ['#ec-people', true]]) {
      const el = this.find(sel);
      if (!el) continue;
      if (sel === '#ec-ops' && !this._isAdmin()) continue;   // _mountOps decides for non-admins
      el.style.display = (people === showInPeople) ? (sel === '#ec-ops' ? 'flex' : '') : 'none';
    }
    const kinds = this.find('#ec-kinds');
    if (kinds) kinds.style.display = people ? 'none' : 'contents';
    if (people) this._mountBoard();
  }

  // The RSVP Reminders board inside this page: its own element (filters,
  // cards, REMIND), minus its old screen header.  Built once per visit.
  _mountBoard() {
    const host = this.find('#ec-people');
    if (!host) return;
    if (this.board && this.board.element && host.contains(this.board.element)) return;
    const prev = this.board ? this.board.resumeState() : null;
    this.board = this.board || new RsvpBoardScreen(this.navigation, this.auth);
    const el = this.board.render();
    const head = el.querySelector('.screen-header');
    if (head) head.remove();
    el.classList.remove('screen');
    host.replaceChildren(el);
    this.board.isMounted = true;
    const params = this._boardParams || (prev ? { resume: prev } : {});
    this._boardParams = null;
    this.board.onEnter(params);
  }

  // Reads follow view-as (auth.fetch adds ?asPersonId); writes go as the
  // real caller and the server refuses them under view-as — the contract
  // every #my component was built on (MyScreen._fetch).
  async _memberFetch(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    let res;
    if (method === 'GET') res = await this.auth.fetch(url, options);
    else {
      const headers = { ...(options.headers || {}) };
      if (this.auth && this.auth.token) headers.Authorization = `Bearer ${this.auth.token}`;
      res = await fetch(url, { ...options, headers, credentials: 'include' });
    }
    let body = null;
    try { body = await res.json(); } catch {}
    if (!res.ok) throw new Error((body && (body.message || body.error)) || `HTTP ${res.status}`);
    return body || {};
  }

  // The notices strip above the calendar and 👤 Mine below it — every tier
  // gets the same pieces; what shows is what the DB has for you (a dues
  // balance, a volunteer offer, a section chat, fine rates).
  _mountMine() {
    const ctx = { fetchJson: (u, o) => this._memberFetch(u, o), escapeHtml: (t) => this.escapeHtml(t),
                  auth: this.auth, navigation: this.navigation };
    const cp = (tier, fb) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier)) ? MessageCopy.block('event_center', tier) : fb;
    this.notices = new NoticeStrip(this.find('#ec-notices'), ctx);
    this.notices.load().then(() => { if (this._autoScrollWaiting) this._placeScroll(); });
    const title = this.find('#ec-mine-title');
    if (title) title.textContent = cp('mine_title', '👤 Mine');
    // Read-only club pages (were #my's header links).  Words: event_center
    // link_* (mig 1366).
    const links = this.find('#ec-mine-links');
    if (links) links.innerHTML = [['player-team-rules', 'link_team_rules', 'Team Rules'], ['player-roster', 'link_rosters', 'Rosters'],
      ['player-calendar', 'link_players', 'Players'], ['schedules', 'link_schedules', 'Schedules']]
      .map(([to, tier, fb]) => `<button type="button" class="ec-link" data-ec-nav="${to}">${this.escapeHtml(cp(tier, fb))}</button>`).join('');
    if (window.PushOptIn) window.PushOptIn.mount(this.find('#ec-push'), this.auth, {}).catch(() => {});
    if (this.chat) this.chat.stop();
    this.chat = new SectionChat(this.find('#ec-chat'), ctx);
    this.chat.start().catch((err) => console.error('[event-center] chat failed:', err));
    new FinesPanel(this.find('#ec-fines'), ctx).load();
  }

  // ── data ────────────────────────────────────────────────────────────
  async _json(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    const headers = { ...(options.headers || {}) };
    if (method !== 'GET') headers['Content-Type'] = 'application/json';
    const res = await this.auth.fetch(url, { ...options, headers });
    let body = null;
    try { body = await res.json(); } catch {}
    if (!res.ok) throw new Error((body && (body.message || body.error)) || `HTTP ${res.status}`);
    return body || {};
  }

  // Monday 00:00 of the week holding this date — weeks run Monday–Sunday,
  // as the schedule release (mig 334) and My Schedule.
  static monday(date) {
    const d = new Date(date); d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() - ((d.getDay() + 6) % 7));
    return d;
  }

  _ymd(d) {
    const p = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
  }

  // Another week (‹ › / This week / the date box): drop the old feed so
  // the calendar shows Loading…, then fetch.
  _setWeek(date) {
    this._autoScroll = false;     // stepping weeks starts at Monday
    this._restoreScroll = null;
    this.anchor = new Date(date);
    this.weekStart = EventCenterScreen.monday(date);
    this.events = null;
    this.error = null;
    this._render();
    this._loadEvents();
  }

  // ‹ › — a week, a month or four weeks, by view.
  _step(n) {
    const d = new Date(this.view === 'week' ? this.weekStart : this.anchor);
    if (this.view === 'month') { d.setDate(1); d.setMonth(d.getMonth() + n); }
    else d.setDate(d.getDate() + n * (this.view === 'agenda' ? EventCenterScreen.AGENDA_DAYS : 7));
    this._setWeek(d);
  }

  _setView(view) {
    if (!EventCenterScreen.VIEWS.includes(view) || view === this.view) return;
    this.view = view;
    try { localStorage.setItem('fh.cal.view', view); } catch {}
    this._setWeek(this.anchor);
  }

  // What the view shows: { start, days }.  Month = whole Mon–Sun weeks
  // covering the month; agenda = four weeks from the anchor's Monday.
  _range() {
    if (this.view === 'month') {
      const first = new Date(this.anchor.getFullYear(), this.anchor.getMonth(), 1);
      const start = EventCenterScreen.monday(first);
      const last = new Date(this.anchor.getFullYear(), this.anchor.getMonth() + 1, 0);
      const days = Math.round((EventCenterScreen.monday(last) - start) / 86400000) + 7;
      return { start, days };
    }
    return { start: this.weekStart, days: this.view === 'agenda' ? EventCenterScreen.AGENDA_DAYS : 7 };
  }

  _isAdmin() { return window.CalendarOps ? CalendarOps.isAdmin(this.auth) : false; }

  // Admin strips above the calendar — the week's schedule release (week
  // view only: it is about one Monday) and field clashes.
  _mountOps() {
    const box = this.find('#ec-ops');
    if (!box || !window.ReleaseStrip || !this._isAdmin()) { if (box) box.style.display = 'none'; return; }
    box.style.display = 'flex';
    const ctx = { auth: this.auth, escapeHtml: (t) => this.escapeHtml(t) };
    this.release = new ReleaseStrip(this.find('#ec-release'), ctx);
    this.release.onChange = () => this._loadEvents();
    new ClashStrip(this.find('#ec-clash'), ctx).load();
  }

  // 🎞 One Instagram carousel of the weekend's games (WeekendSlides loads
  // its own games).  The roles that may post: club, super, marketing —
  // never under view-as.
  _mountWeekend() {
    const host = this.find('#ec-weekend');
    if (!host) return;
    const role = String((this.auth && this.auth.user && this.auth.user.role) || '').toLowerCase();
    if (typeof WeekendSlides === 'undefined' || (this.auth && this.auth.viewAsPersonId) || !['club', 'super', 'marketing'].includes(role)) { host.innerHTML = ''; return; }
    this.weekendSlides = this.weekendSlides || new WeekendSlides(this.auth, {
      navigation: this.navigation, escapeHtml: (t) => this.escapeHtml(t),
    });
    this.weekendSlides.el = null;   // a fresh element every visit
    this.weekendSlides.mount(host);
  }

  _loadOps() {
    if (this.release) this.release.load(this.view === 'week' ? this._ymd(this.weekStart) : null);
  }

  // The week's events — the whole calendar, released or not (staff see
  // what is coming; a not-yet-posted event says so on its tile).
  async _loadEvents() {
    const { start, days } = this._range();
    const key = `${this.view}:${start.getTime()}`;
    this._loadKey = key;
    this._loadOps();
    // Admins also see Google soccer events not classified yet (the old
    // #calendar's include_unclassified) — the server shows them to admins only.
    const extra = this._isAdmin() ? '&include_unclassified=1' : '';
    try {
      const body = await this._json(`/api/calendar/upcoming?start=${encodeURIComponent(this._ymd(start))}&days=${days}${extra}`);
      if (this._loadKey !== key) return;   // a newer range was asked for meanwhile
      this.events = Array.isArray(body.events) ? body.events : [];
      this.error = null;
    } catch (err) {
      console.error('[event-center] events load failed:', err);
      this.error = 'Could not load the calendar.';
    }
    this._render();
  }

  // ── events ──────────────────────────────────────────────────────────
  _wire() {
    // The date input: jump to that day's week.
    this.element.addEventListener('change', (e) => {
      const el = e.target.closest('[data-ec-date]');
      if (el && el.value) { const [y, m, d] = el.value.split('-').map(Number); this._setWeek(new Date(y, m - 1, d)); }
    });
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const t = (sel) => e.target.closest(sel);
      let el;
      if ((el = t('[data-event-kind]'))) {
        this.kind = el.dataset.eventKind;
        if (this.error) this._setWeek(this.weekStart);   // a failed load tries again
        else this._render();
        return;
      }
      if ((el = t('[data-ec-category]'))) { this.category = el.dataset.ecCategory; this._render(); return; }
      if ((el = t('[data-ec-person]'))) { this.person = el.dataset.ecPerson; this._render(); return; }
      if ((el = t('[data-ec-nav]'))) { this.navigation.goTo(el.dataset.ecNav); return; }
      if ((el = t('[data-ec-week]'))) {
        const step = Number(el.dataset.ecWeek);
        if (step) this._step(step); else this._setWeek(new Date());
        return;
      }
      if ((el = t('[data-ec-view]'))) { this._setView(el.dataset.ecView); return; }
      if ((el = t('[data-ec-mode]'))) {
        this.mode = el.dataset.ecMode === 'people' ? 'people' : 'event';
        this._keepMode();
        this._paintMode();
        if (this.mode === 'event') this._render();
        return;
      }
      // Month: a day's number (or +N) opens that week.
      if ((el = t('[data-ec-goday]'))) {
        const [y, m, d] = el.dataset.ecGoday.split('-').map(Number);
        this.anchor = new Date(y, m - 1, d);
        this._setView('week');
        return;
      }
      // Not in Football Home yet (admins): no event to open — Google's own page.
      if ((el = t('[data-ec-gcal]'))) {
        const ev = (this.events || []).find(x => String(x.gcal_event_id) === el.dataset.ecGcal);
        if (ev && ev.html_link) window.open(ev.html_link, '_blank', 'noopener');
        return;
      }
      // ✓ / ✗ on a tile answers for YOU without opening it (owner
      // 2026-11-06) — checked before the tile's own open.
      if ((el = t('[data-ec-my-rsvp]'))) {
        e.stopPropagation();
        const ev = (this.events || []).find(x => x.fh_event_id === Number(el.dataset.eventId));
        if (ev) this._setMyRsvp(ev, el.dataset.ecMyRsvp, Number(el.dataset.personId) || 0);
        return;
      }
      if ((el = t('[data-ec-open]'))) {
        // A goTo, so Back returns to the week.
        const ev = (this.events || []).find(x => x.fh_event_id === Number(el.dataset.ecOpen));
        if (ev) {
          this._openedEvent = true;
          this._savedScroll = window.scrollY || 0;
          EventKindSwitch.open(this.navigation, ev);
        }
      }
    });
  }

  // Your own answer from a tile — the self write #my makes (POST/DELETE
  // /api/calendar/rsvp, no person_id unless viewing as someone), so the
  // same eligibility rules apply — or, with childId, a guardian's answer
  // for one of their kids (person_id, as #my's guardian rows; mig 1148).
  // Tapping the lit answer clears it.
  _childResponse(ev, childId) {
    const row = (Array.isArray(ev.rsvps) ? ev.rsvps : []).find(r => r && Number(r.person_id) === childId);
    return (row && row.response) || null;
  }

  async _setMyRsvp(ev, response, childId = 0) {
    const id = ev.fh_event_id;
    const key = `${id}:${childId || 'me'}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    delete this.rsvpNote[key];
    this._render();
    const current = childId ? this._childResponse(ev, childId) : ev.my_rsvp;
    const clear = current === response;
    const payload = { fh_event_id: id };
    if (childId) payload.person_id = childId;
    else if (this.auth && this.auth.viewAsPersonId) payload.person_id = Number(this.auth.viewAsPersonId);
    try {
      let answer = null;
      if (clear) {
        await this._json('/api/calendar/rsvp', { method: 'DELETE', body: JSON.stringify(payload) });
      } else {
        const body = await this._json('/api/calendar/rsvp', { method: 'POST', body: JSON.stringify({ ...payload, response }) });
        answer = (body && body.rsvp && body.rsvp.response) || response;
        if (body && body.sms_opt_in && window.SmsOptInAsk) SmsOptInAsk.show(body.sms_opt_in);   // 📲 mig 647
        if (body && body.reg_ask && window.RegAsk) RegAsk.show(body.reg_ask);                   // 📝 mig 725
      }
      if (!childId) ev.my_rsvp = answer;
      else {
        const rows = Array.isArray(ev.rsvps) ? ev.rsvps : (ev.rsvps = []);
        const row = rows.find(r => r && Number(r.person_id) === childId);
        if (row) row.response = answer; else rows.push({ person_id: childId, response: answer });
      }
    } catch (err) {
      this.rsvpNote[key] = err.message;
    } finally {
      this.saving.delete(key);
    }
    this._render();
    this._loadEvents();   // the tile's counts follow
  }

  // ── render ──────────────────────────────────────────────────────────
  _kindOf(ev) { return EventLabels.kindOf(ev); }
  _isPast(ev) { return EventLabels.isPast(ev); }

  _render() {
    const body = this.find('#ec-body');
    const title = this.find('#ec-title');
    const sub = this.find('#ec-sub');
    if (!body) return;
    const kinds = this.find('#ec-kinds');
    if (kinds) kinds.innerHTML = EventKindSwitch.html(EventKindSwitch.KINDS.includes(this.kind) ? this.kind : 'all', (t) => this.escapeHtml(t));
    title.textContent = EventKindSwitch.title();
    sub.textContent = (window.MessageCopy && MessageCopy.block('event_center', 'list_sub'))
      || 'The week — pick a type, then tap an event to open it';
    if (this.error)   { body.innerHTML = `<div class="empty-state" style="text-align:center; opacity:0.8;">${this.escapeHtml(this.error)}</div>`; return; }
    body.innerHTML = this._pickerHtml();
    this._placeScroll();
  }

  // Phone, first paint of THIS week: the NOW line near the top with the
  // event before it still in sight (owner 11/14: "default the view to the red
  // line like screll down if phone to that spot").  A banner above the
  // calendar (dues, shifts …) wins — the page stops at it instead, so it is
  // never scrolled out of sight.  Back from an event: where you were.
  _placeScroll() {
    if (this._restoreScroll != null) {
      const y = this._restoreScroll;
      this._restoreScroll = null;
      this._autoScroll = false;
      // Mine fills in after the first paint, so the page may still be too
      // short to reach y: set it again as it grows, until reached or the
      // reader scrolls themselves.
      let last = null;
      const put = (tries) => {
        if (last !== null && Math.abs(window.scrollY - last) > 2) return;   // they scrolled
        window.scrollTo(0, y);
        last = window.scrollY;
        if (Math.abs(last - y) > 2 && tries > 0) setTimeout(() => put(tries - 1), 250);
      };
      requestAnimationFrame(() => put(12));
      return;
    }
    if (!this._autoScroll) return;
    if (!window.matchMedia || !window.matchMedia('(max-width: 899px)').matches) { this._autoScroll = false; return; }
    const now = this.find('.ec-now');
    if (!now) { this._autoScroll = false; return; }   // not this week, or nothing to place
    // The notices decide where the page stops — wait for them.
    if (this.notices && !this.notices.loaded) { this._autoScrollWaiting = true; return; }
    this._autoScrollWaiting = false;
    this._autoScroll = false;
    const strip = this.find('#ec-notices');
    const banner = this.notices && this.notices.hasNotices && strip && strip.offsetHeight > 0 ? strip : null;
    const prev = now.previousElementSibling;
    // The event just before the line, else the top of today's column.
    const target = banner || (prev && prev.classList.contains('ec-pick') ? prev : now.closest('.ec-day'));
    requestAnimationFrame(() => target.scrollIntoView({ block: 'start' }));
  }

  // The week calendar: Monday–Sunday, the lit type pill and section chip
  // choosing what fills it.  Each event is a tile — tap to open it.  Days
  // sit side by side on a wide screen and stack Mon→Sun on a phone; the
  // NOW line (mig 748) crosses today where the clock falls, the events
  // already over dimmed above it.
  _pickerHtml() {
    // Still loading: the filters, ‹ › and view chips stay, the grid says so.
    const loading = !this.events;
    const evAll = this.events || [];
    const cats = [...new Set(evAll.map(ev => ev.category).filter(Boolean))];
    const catLabel = (c) => EventCenterScreen.CATEGORY_LABELS[c] || c;
    const chip = (attr, value, label, on) =>
      `<button type="button" class="ec-chip ${on ? 'on' : ''}" ${attr}="${this.escapeHtml(value)}">${this.escapeHtml(label)}</button>`;
    const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || fb;

    // Person chips: Everyone · Me · each kid — only when the week holds more
    // than your own events (a parent's kids, a coach's or admin's whole
    // scope).  Words: event_center person_all / person_me (mig 1363).
    const kids = new Map();
    for (const ev of evAll)
      for (const c of (Array.isArray(ev.guardian_targets) ? ev.guardian_targets : []))
        if (c && c.person_id && !kids.has(Number(c.person_id))) kids.set(Number(c.person_id), String(c.name || '').split(' ')[0] || 'Your player');
    const hasMine = evAll.some(ev => ev.is_mine === true);
    const hasOthers = evAll.some(ev => ev.is_mine !== true && !(Array.isArray(ev.guardian_targets) && ev.guardian_targets.length));
    const personChips = kids.size || (hasMine && hasOthers);
    if (!loading && (!personChips || (this.person !== 'all' && this.person !== 'me' && !kids.has(Number(this.person))))) this.person = 'all';
    const forPerson = (ev) => this.person === 'all' ? true
      : this.person === 'me' ? ev.is_mine === true
      : (Array.isArray(ev.guardian_targets) ? ev.guardian_targets : []).some(c => c && Number(c.person_id) === Number(this.person));

    const shown = evAll.filter(ev =>
      (this.kind === 'all' || this._kindOf(ev) === this.kind) &&
      (this.category === 'all' || ev.category === this.category) && forPerson(ev))
      .sort((a, b) => String(a.starts_at).localeCompare(String(b.starts_at)));
    // "4:30 – 6:00 PM" (both halves' AM/PM when they differ); start alone
    // when the calendar gives no end.
    const time = (ev) => {
      const a = new Date(ev.starts_at), b = new Date(ev.ends_at);
      if (isNaN(a)) return '';
      const hm = (d) => d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
      if (isNaN(b) || b <= a) return hm(a);
      const [ta, pa] = hm(a).split(' '), [tb, pb] = hm(b).split(' ');
      return pa === pb ? `${ta} – ${tb} ${pb}` : `${hm(a)} – ${hm(b)}`;
    };
    const posted = (ev) => {
      if (!ev.schedule_window_end || !ev.starts_at) return true;
      const end = new Date(ev.schedule_window_end), t = new Date(ev.starts_at);
      return isNaN(end) || isNaN(t) || t <= end;
    };

    // WHO is playing, up top (mig 778): a game's own team(s) — the
    // primary squads the fixture is for — as big badges in the team's
    // label + colour; a practice's tagged teams as small chips.
    const teamsOf = (ev) => (Array.isArray(ev.teams) ? ev.teams : []).filter(t => t && (t.label || t.name));
    const primaries = (ev) => { const ts = teamsOf(ev), p = ts.filter(t => t.is_primary); return p.length ? p : ts; };
    const plain = (label) => String(label || '').replace(/^[^\p{L}\p{N}]+/u, '').trim();   // "⚽ U8 Travel" → "U8 Travel"
    const badge = (t, big) => {
      const c = t.color || 'var(--primary-color)';
      return `<span style="display:inline-block; background:${this.escapeHtml(c)}; color:#fff; border-radius:6px; font-weight:800;
                ${big ? 'font-size:0.95rem; padding:3px 8px;' : 'font-size:0.68rem; padding:1px 6px;'}">${this.escapeHtml(big ? (t.label || t.name) : (t.short_label || t.label || t.name))}</span>`;
    };
    const line = (ev) => {
      const team = primaries(ev)[0];
      if (ev.kind === 'match' && team) {
        const opponent = ev.opponent || EventLabels.parseDescTags(ev.description).opponent || 'TBD';
        return cp('tile_vs', { team: plain(team.label || team.name), opponent }, `${plain(team.label || team.name)} vs ${opponent}`);
      }
      return EventLabels.title(ev);
    };

    const admin = this._isAdmin();
    // ⚠ What the Google description is missing (admins; the old #calendar's
    // tag audit — each line names the tag to add).
    const tagIssues = (ev) => admin && Array.isArray(ev.tag_issues) && ev.tag_issues.length
      ? `<span style="font-size:0.7rem; font-weight:700; color:#fbbf24; white-space:normal; text-align:left;">⚠ ${this.escapeHtml(ev.tag_issues.join(' · '))}</span>` : '';
    // A Google soccer event Football Home has not classified (admins only —
    // include_unclassified): nothing to open, so the tap goes to Google.
    const rawTile = (ev) => `<div role="button" tabindex="0" class="btn btn-secondary ec-pick ${this._isPast(ev) ? 'ec-past' : ''}"
          data-ec-gcal="${this.escapeHtml(ev.gcal_event_id)}" style="border-style:dashed;">
        <span style="font-size:0.8rem; font-weight:800;">${this.escapeHtml(time(ev))}</span>
        <span style="font-weight:700;">${this.escapeHtml(ev.summary || '(untitled)')}</span>
        <span style="font-size:0.72rem; font-weight:700; color:#f59e0b; white-space:normal; text-align:left;">${this.escapeHtml(cp('unclassified', {}, '⚠ Not in Football Home yet — tag it in Google Calendar'))}</span>
        ${tagIssues(ev)}
      </div>`;

    const tile = (ev) => {
      if (ev.fh_event_id == null) return rawTile(ev);
      // Players only — coaches never in a player total (owner 2026-10-06).
      // The feed's roster already honours call-up gates and paper spots;
      // a yes from over the dues line (migration 416) is counted apart.
      // 💤 Inactive (mig 945): their own count, never in the others.
      const inactive = Array.isArray(ev.inactive) ? ev.inactive.length : 0;
      const inactiveIds = new Set((ev.inactive || []).map(r => r.person_id));
      const players = (Array.isArray(ev.rsvps) ? ev.rsvps : [])
        .filter(r => r && !r.is_coach && (r.response === 'yes' || !inactiveIds.has(r.person_id)));
      const going = players.filter(r => r.response === 'yes' && r.dues_eligible !== false).length;
      const ineligible = players.filter(r => r.response === 'yes' && r.dues_eligible === false).length;
      const notGoing = players.filter(r => r.response === 'no').length;
      const noResp = players.filter(r => r.response !== 'yes' && r.response !== 'no').length;
      const isGame = ev.kind === 'match';
      // A game shows ONE badge — the squad its line names (owner 2026-10-28:
      // "just apsl is fine" on a game tagged APSL + APSL Reserves).
      const badges = (isGame ? primaries(ev).slice(0, 1) : teamsOf(ev)).map(t => badge(t, isGame)).join(' ');
      const count = (tier, n, fb, color) => `<span style="color:${color}; font-weight:700;">${this.escapeHtml(cp(tier, { n }, fb))}</span>`;
      // YOUR answer + ✓/✗, right on the tile (owner 2026-11-06: "set
      // availability for me … from each card w/o opening card") — only on
      // events you may answer (my_rsvp_eligible) while they're open.
      // …and one row per child of yours on the event (guardian_targets —
      // every guardian of the child gets it; mig 1148: "same with grace").
      const answerRow = (personId, r, [tier, fb, color], tokens) => {
        const key = `${ev.fh_event_id}:${personId || 'me'}`;
        const busy = this.saving.has(key);
        const b = (resp, label, c) => {
          const on = r === resp;
          return `<button type="button" data-ec-my-rsvp="${resp}" data-event-id="${ev.fh_event_id}" data-person-id="${personId || 0}" ${busy ? 'disabled' : ''}
                    title="${on ? 'Tap to clear the answer' : (resp === 'yes' ? 'Going' : 'Not going')}"
                    style="min-width:40px; padding:4px 10px; border-radius:8px; font-weight:800; cursor:pointer;
                           border:1px solid ${c}; background:${on ? c : 'transparent'}; color:${on ? '#fff' : c};">${label}</button>`;
        };
        const err = this.rsvpNote[key];
        return `<span style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; width:100%; margin-top:2px; padding-top:6px; border-top:1px solid var(--border-color);">
            <span style="font-size:0.78rem; font-weight:800; color:${color}; flex:1; min-width:0;">${this.escapeHtml(cp(tier, tokens, fb))}</span>
            ${b('yes', '✓', '#22c55e')}${b('no', '✗', '#ef4444')}
          </span>
          ${err ? `<span style="font-size:0.72rem; color:#f87171;">${this.escapeHtml(err)}</span>` : ''}`;
      };
      const mine = () => {
        if (this._isPast(ev)) return '';
        let out = '';
        if (ev.my_suspension) {
          out += `<span style="font-size:0.72rem; font-weight:800; color:#fca5a5;">${this.escapeHtml(
            (window.MessageCopy && MessageCopy.block('suspended', 'chip')) || '⛔ SUSPENDED')}</span>`;
        } else if (ev.my_callin && window.CallIn) {
          // 🙋 Call-in (mig 1265): no Go / No — the chip and where it stands;
          // the request itself is on the event page.
          const c = ev.my_callin;
          const say = c.state === 'requested' ? CallIn.copy('requested', '🙋 Call-in requested — the coach will let you know.', { from: c.from || '' })
            : c.state === 'declined' ? CallIn.copy('declined', 'Not this week — thanks for putting your hand up.', { from: c.from || '' })
            : CallIn.copy('note', 'Want in for this one? Put your hand up and the coach will let you know.', { from: c.from || '' });
          out += `<span style="font-size:0.72rem; font-weight:700; white-space:normal; text-align:left;">${CallIn.chipHtml(c)}${this.escapeHtml(say)}</span>`;
        } else if (ev.my_rsvp_eligible === true) {
          const r = ev.my_rsvp;
          out += answerRow(0, r, r === 'yes' ? ['me_status_yes', "✓ You're going", '#22c55e']
            : r === 'no' ? ['me_status_no', "✗ You're not going", '#ef4444']
            : ['me_status_none', "You haven't answered yet", '#fbbf24'], {});
        }
        for (const c of (Array.isArray(ev.guardian_targets) ? ev.guardian_targets : [])) {
          if (!c || !c.person_id || c.suspension) continue;   // ⛔ mig 1077: no answer to set
          const id = Number(c.person_id);
          const name = String(c.name || '').split(' ')[0] || 'Your player';
          const r = this._childResponse(ev, id);
          out += answerRow(id, r, r === 'yes' ? ['kid_status_yes', `✓ ${name} is going`, '#22c55e']
            : r === 'no' ? ['kid_status_no', `✗ ${name} is not going`, '#ef4444']
            : ['kid_status_none', `${name} hasn't answered yet`, '#fbbf24'], { name });
        }
        return out;
      };
      return `<div role="button" tabindex="0" class="btn btn-secondary ec-pick ${this._isPast(ev) ? 'ec-past' : ''}" data-ec-open="${ev.fh_event_id}">
        ${badges ? `<span style="display:flex; flex-wrap:wrap; gap:4px;">${badges}</span>` : ''}
        <span style="font-size:0.8rem; font-weight:800;">${this.escapeHtml(time(ev))}</span>
        <span style="font-weight:700;">${this.escapeHtml(line(ev))}</span>
        ${EventLabels.timesLine(ev) ? `<span style="font-size:0.72rem; font-weight:700; color:#93c5fd;">${this.escapeHtml(EventLabels.timesLine(ev))}</span>` : ''}
        ${EventLabels.carpoolLines(ev).map(l => `<span style="font-size:0.7rem; font-weight:700; color:#fbbf24; white-space:normal; overflow-wrap:anywhere; text-align:left;">${this.escapeHtml(l)}</span>`).join('')}
        ${EventLabels.homeSetup(ev) ? `<span>${EventLabels.homeSetupBadge(ev, (t) => this.escapeHtml(t))}</span>`
          : ev.location ? `<span style="font-size:0.72rem; opacity:0.85;">📍 ${this.escapeHtml(ev.location)}</span>` : ''}
        <span style="display:flex; flex-wrap:wrap; gap:2px 8px; font-size:0.75rem;">
          ${count('tile_going', going, `✓ ${going} going`, '#16a34a')}
          ${count('tile_noresp', noResp, `– ${noResp} no response`, '#eab308')}
          ${count('tile_notgoing', notGoing, `✗ ${notGoing} not going`, '#dc2626')}
          ${ineligible ? count('tile_ineligible', ineligible, `⛔ ${ineligible} ineligible`, '#dc2626') : ''}
          ${inactive ? count('tile_inactive', inactive, `💤 ${inactive} inactive`, '#94a3b8') : ''}
        </span>
        ${posted(ev) ? '' : `<span style="font-size:0.7rem; color:#f59e0b;">${this.escapeHtml(cp('not_posted', {}, 'not posted yet'))}</span>`}
        ${tagIssues(ev)}
        ${mine()}
      </div>`;
    };
    const nowLine = () => {
      const t = new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
      return `<div class="ec-now"><span>${this.escapeHtml(cp('now_line', { time: t }, `Now · ${t}`))}</span></div>`;
    };

    const today = this._ymd(new Date());
    const { start, days: span } = this._range();
    const dates = [...Array(span)].map((_, i) => { const d = new Date(start); d.setDate(d.getDate() + i); return d; });
    const onDay = (ymd) => shown.filter(ev => { const t = new Date(ev.starts_at); return !isNaN(t) && this._ymd(t) === ymd; });
    // Today's NOW line: above the first event not over yet (one under way
    // sits below it), or under the last when the day is done.
    const cellsFor = (ymd, evs) => {
      const cells = evs.map(tile);
      if (ymd === today) {
        const cut = evs.findIndex(ev => !this._isPast(ev));
        cells.splice(cut === -1 ? cells.length : cut, 0, nowLine());
      }
      return cells;
    };
    const dayHead = (d, long) => d.toLocaleDateString('en-US', long ? { weekday: 'short', month: 'short', day: 'numeric' } : { weekday: 'short', day: 'numeric' });

    let grid;
    if (loading) {
      grid = `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    } else if (this.view === 'month') {
      // Mon–Sun weeks over the month; a chip per event (tap opens it), a
      // day's number opens that week.
      const month = this.anchor.getMonth();
      const chipEv = (ev) => {
        const team = primaries(ev)[0];
        const color = (team && team.color) || 'var(--primary-color)';
        const a = new Date(ev.starts_at);
        const hm = isNaN(a) ? '' : a.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }).replace(':00', '').replace(' ', '').toLowerCase();
        const me = ev.my_rsvp === 'yes' ? '✓ ' : ev.my_rsvp === 'no' ? '✗ ' : '';
        const door = ev.fh_event_id == null ? `data-ec-gcal="${this.escapeHtml(ev.gcal_event_id)}"` : `data-ec-open="${ev.fh_event_id}"`;
        const label = ev.fh_event_id == null ? (ev.summary || '') : line(ev);
        const warn = (admin && Array.isArray(ev.tag_issues) && ev.tag_issues.length) || ev.fh_event_id == null ? '⚠ ' : '';
        return `<div role="button" tabindex="0" class="ec-mchip ${this._isPast(ev) ? 'ec-past' : ''}" ${door}
                     style="border-left-color:${this.escapeHtml(color)};" title="${this.escapeHtml(`${time(ev)} ${label}`)}">${this.escapeHtml(`${warn}${me}${hm} ${label}`)}</div>`;
      };
      const heads = dates.slice(0, 7).map(d => `<div class="ec-mhead">${this.escapeHtml(d.toLocaleDateString('en-US', { weekday: 'short' }))}</div>`).join('');
      const cells = dates.map(d => {
        const ymd = this._ymd(d);
        const evs = onDay(ymd);
        const more = evs.length > 4 ? `<button type="button" class="ec-mmore" data-ec-goday="${ymd}">+${evs.length - 4}</button>` : '';
        return `<div class="ec-mcell ${d.getMonth() !== month ? 'out' : ''} ${ymd === today ? 'today' : ''}">
          <button type="button" class="ec-mday" data-ec-goday="${ymd}" aria-label="Open the week of ${this.escapeHtml(dayHead(d, true))}">${d.getDate()}</button>
          ${evs.slice(0, 4).map(chipEv).join('')}${more}
        </div>`;
      }).join('');
      grid = `<div class="ec-month-wrap"><div class="ec-month">${heads}${cells}</div></div>`;
    } else if (this.view === 'agenda') {
      // Four weeks as a list — only days with something on, past days dimmed.
      const blocks = dates.map(d => {
        const ymd = this._ymd(d);
        const evs = onDay(ymd);
        if (!evs.length) return '';
        return `<div class="ec-day ${ymd === today ? 'today' : ymd < today ? 'past' : ''}">
          <div class="ec-dayh">${this.escapeHtml(dayHead(d, true))}</div>
          <div class="ec-agenda">${cellsFor(ymd, evs).join('')}</div>
        </div>`;
      }).filter(Boolean);
      grid = blocks.length ? `<div style="display:flex; flex-direction:column; gap:12px;">${blocks.join('')}</div>`
        : `<div class="ec-none" style="padding:var(--space-4); text-align:center;">${this.escapeHtml(cp('agenda_empty', {}, 'Nothing on in these four weeks'))}</div>`;
    } else {
      grid = `<div class="ec-week">${dates.map(d => {
        const ymd = this._ymd(d);
        const cells = cellsFor(ymd, onDay(ymd));
        return `<div class="ec-day ${ymd === today ? 'today' : ymd < today ? 'past' : ''}">
          <div class="ec-dayh">${this.escapeHtml(dayHead(d))}</div>
          ${cells.length ? cells.join('') : '<div class="ec-none">—</div>'}
        </div>`;
      }).join('')}</div>`;
    }

    // The range label, and the jump back to now when it is out of sight.
    const end = new Date(start); end.setDate(end.getDate() + span - 1);
    const fmt = (d) => d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const label = this.view === 'month' ? this.anchor.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }) : `${fmt(start)} – ${fmt(end)}`;
    const now = new Date();
    const hasNow = this.view === 'month'
      ? now.getMonth() === this.anchor.getMonth() && now.getFullYear() === this.anchor.getFullYear()
      : now >= start && now < new Date(end.getTime() + 86400000);
    const nowWord = this.view === 'month' ? cp('this_month', {}, 'This month') : cp('this_week', {}, 'This week');
    const viewChip = (v, fb) => chip('data-ec-view', v, cp(`view_${v}`, {}, fb), this.view === v);

    return `
      ${personChips ? `<div style="display:flex; gap:var(--space-1); flex-wrap:wrap; margin-bottom:var(--space-2);">
        ${chip('data-ec-person', 'all', cp('person_all', {}, 'Everyone'), this.person === 'all')}
        ${hasMine ? chip('data-ec-person', 'me', cp('person_me', {}, 'Me'), this.person === 'me') : ''}
        ${[...kids].map(([id, name]) => chip('data-ec-person', String(id), name, String(this.person) === String(id))).join('')}
      </div>` : ''}
      ${cats.length > 1 ? `<div style="display:flex; gap:var(--space-1); flex-wrap:wrap; margin-bottom:var(--space-2);">
        ${chip('data-ec-category', 'all', 'All', this.category === 'all')}
        ${cats.map(c => chip('data-ec-category', c, catLabel(c), this.category === c)).join('')}
      </div>` : ''}
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2);">
        <button type="button" class="ec-chip" data-ec-week="-1" aria-label="Previous">‹</button>
        <span style="font-weight:800; min-width:9em; text-align:center;">${this.escapeHtml(label)}</span>
        <button type="button" class="ec-chip" data-ec-week="1" aria-label="Next">›</button>
        ${hasNow ? '' : `<button type="button" class="ec-chip" data-ec-week="0">${this.escapeHtml(nowWord)}</button>`}
        <input type="date" class="ec-chip" data-ec-date value="${this._ymd(this.view === 'week' ? this.weekStart : this.anchor)}"
               aria-label="Go to a date" style="font-family:inherit;">
        <span class="ec-views" role="tablist" aria-label="Calendar view">
          ${viewChip('week', 'Week')}${viewChip('month', 'Month')}${viewChip('agenda', 'Agenda')}
        </span>
      </div>
      ${grid}`;
  }
}
