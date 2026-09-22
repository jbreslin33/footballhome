// RsvpBoardScreen — #rsvps — the RSVP follow-up board (owner 2026-09-17).
//
// "pills for men, boys etc … send text or email reminder for rsvp … the
// message crafted by db query to see what events they didn't rsvp to and
// list them and give magic link … sort by worst rsvp percent for this week
// or all time or last 2 weeks or month … their card should show last rsvp
// they set … and dues … and last payment date … and how much."
//
// Backed by GET /api/rsvp-board and POST /api/rsvp-board/remind
// (backend/src/controllers/RsvpBoardController.cpp).  #reports is the
// analysis table (attendance, reliability, streaks); this is the work
// queue: who owes an answer right now, and one tap to chase them.  It is
// meant to take over from the per-event Remind buttons on #my, which only
// remember "reminded ✓" until the page reloads — sends here are logged
// (rsvp_reminders, mig 363) and shown on the card for every coach.
//
// Club admins only for now (owner 2026-09-17); the backend's coach scoping
// (own teams, no payment amounts) is written but switched off.
//
// A card shows the released week as a table — every expected event with
// the player's answer (owner 2026-09-22: "so i can see if missing all or
// some and which ones"): going / not going / unanswered (still answerable)
// / missed (already happened, never answered).
// REMIND only lists the still-answerable ones — a past event in the
// message would just confuse the player (owner 2026-09-19).  The day pills
// (owner 2026-09-22) narrow the cards to one day's stragglers, but REMIND
// still sends the whole week: "for the reminder on rsvp for today etc it
// still should send message for all days".
//
// With one event picked ("Unanswered for:" or a next-game tile) a bar
// offers ONE group text / BCC email to everybody who still owes that event
// an answer — POST /api/rsvp-board/remind-event.  No magic link in a group
// message; the DB copy (mig 380) points at footballhome.org.
class RsvpBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.section = 'mens';     // mens | womens | boys | girls
    this.window  = 'week';     // week | 2w | month | all
    this.kind    = 'all';      // all | games | practices
    this.sort    = 'worst';    // worst | open | quiet | name
    this.teamId  = null;
    this.eventId = null;       // "unanswered for this event" filter
    this.openOnly = false;
    this.search  = '';
    this.data    = null;
    this.loading = false;
    this.error   = null;
    this._loadSeq = 0;
    this.bulk    = null;       // last group reminder: { key, channel, html }
    this.day     = 'week';     // 'week' or a club-local YYYY-MM-DD — owner 2026-09-22: pills for the
                               // days left in the week, today as "Today", tomorrow as "Tomorrow"
  }

  // Club-local YYYY-MM-DD for the day pill, or '' for the whole week.
  _dayIso() { return /^\d{4}-\d{2}-\d{2}$/.test(this.day) ? this.day : ''; }

  // Pills for the rest of the released week: today through Sunday (the
  // board's week runs Monday–Sunday, club time).  Days already gone are
  // not shown; today reads "Today", tomorrow "Tomorrow", the rest by name.
  _dayPills() {
    const tz = 'America/New_York';
    const iso = (d) => new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' }).format(d);
    const dow = (d) => new Intl.DateTimeFormat('en-US', { timeZone: tz, weekday: 'long' }).format(d);
    const pills = [{ key: 'week', label: RsvpBoardScreen.DAYS.week }];
    const d = new Date();
    for (let i = 0; i < 7; i++) {
      const name = dow(d);
      pills.push({ key: iso(d), label: i === 0 ? RsvpBoardScreen.DAYS.today : i === 1 ? RsvpBoardScreen.DAYS.tomorrow : name });
      if (name === 'Sunday') break;
      d.setDate(d.getDate() + 1);
    }
    return pills;
  }

  _dayLabel() { const pl = this._dayPills().find(x => x.key === this.day); return pl ? pl.label : RsvpBoardScreen.DAYS.week; }

  // The card's events for the current day pill (open + missed both carry
  // `day` from the server).
  _openFor(p)   { const d = this._dayIso(); return (p.open_events   || []).filter(ev => !d || ev.day === d); }
  _missedFor(p) { const d = this._dayIso(); return (p.missed_events || []).filter(ev => !d || ev.day === d); }

  static get SECTIONS() { return { all: 'All', mens: 'Men', womens: 'Women', boys: 'Boys', girls: 'Girls' }; }
  static get DAYS()     { return { week: 'Whole week', today: 'Today', tomorrow: 'Tomorrow' }; }
  static get WINDOWS()  { return { week: 'This week', '2w': 'Last 2 weeks', month: 'Last month', all: 'All time' }; }
  static get KINDS()    { return { all: 'All events', games: 'Games only', practices: 'Practices only' }; }
  static get SORTS() {
    return { worst: 'Worst RSVP %', open: 'Most unanswered now', quiet: 'Longest since last RSVP', nagged: 'Most reminders needed', name: 'Name' };
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .rb-chip { padding:5px 12px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.8rem;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .rb-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .rb-group { display:flex; align-items:center; gap:var(--space-2); flex-wrap:wrap; margin-bottom:var(--space-2); }
        .rb-lbl { font-size:0.7rem; font-weight:700; text-transform:uppercase; letter-spacing:0.05em; opacity:0.55; min-width:88px; }
        .rb-chips { display:flex; gap:var(--space-1); flex-wrap:wrap; }
        .rb-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(290px, 1fr)); gap:var(--space-2); }
        .rb-card { border:1px solid var(--border-color); border-radius:10px; background:var(--bg-secondary);
                   padding:10px 12px; display:flex; flex-direction:column; gap:6px; }
        .rb-pct { font-size:1.5rem; font-weight:800; line-height:1; }
        .rb-good { color:#4ade80; } .rb-mid { color:#facc15; } .rb-bad { color:#f87171; } .rb-none { opacity:0.4; }
        .rb-row { display:flex; justify-content:space-between; gap:8px; font-size:0.78rem; }
        .rb-row .k { opacity:0.6; white-space:nowrap; }
        .rb-row .v { text-align:right; }
        .rb-open { font-size:0.78rem; margin:0; padding-left:16px; }
        .rb-week { width:100%; border-collapse:collapse; font-size:0.75rem; }
        .rb-week td { padding:2px 4px 2px 0; vertical-align:top; border-top:1px solid var(--border-color); }
        .rb-week tr:first-child td { border-top:none; }
        .rb-week td:last-child { text-align:right; white-space:nowrap; padding-right:0; font-weight:700; }
        .rb-week tr.past { opacity:0.65; }
        .rb-week tr.pick td { background:rgba(245,212,66,0.12); }
        .rb-btn { padding:4px 10px; border-radius:6px; border:none; cursor:pointer; font-weight:800; font-size:0.72rem; color:#fff; }
        .rb-btn[disabled] { opacity:0.35; cursor:not-allowed; }
        .rb-game { flex:1 1 230px; max-width:340px; text-align:left; cursor:pointer; padding:10px 12px; border-radius:10px;
                   border:1px solid var(--border-color); border-left:4px solid #f5d442;
                   background:var(--bg-secondary); color:var(--text-primary); }
        .rb-game.on { outline:2px solid #f5d442; }
        .rb-bulk { display:flex; gap:8px; flex-wrap:wrap; align-items:center; padding:8px 12px; margin-bottom:var(--space-2);
                   border:1px solid var(--border-color); border-left:4px solid #f5d442; border-radius:10px;
                   background:var(--bg-secondary); font-size:0.8rem; }
        .rb-bulk a.rb-btn { text-decoration:none; display:inline-block; }
        .rb-pill { display:inline-block; padding:1px 8px; border-radius:999px; font-size:0.7rem; font-weight:700; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>✅ RSVPs</h1>
        <p class="subtitle">Who owes an answer — remind them with their unanswered events and a sign-in link</p>
      </div>
      <div style="padding: var(--space-4); max-width: 1500px; margin: 0 auto;">
        <!-- One labelled row per pill group (owner 2026-09-22: "all time
             frames in own section and clubs Men, boys etc in own section
             and types game, practice all in own section"). -->
        <div class="rb-group"><span class="rb-lbl">Day</span><div id="rb-days" class="rb-chips"></div></div>
        <div class="rb-group"><span class="rb-lbl">Section</span><div id="rb-sections" class="rb-chips"></div></div>
        <div class="rb-group"><span class="rb-lbl">RSVP % over</span><div id="rb-windows" class="rb-chips"></div></div>
        <div class="rb-group"><span class="rb-lbl">Events</span><div id="rb-kinds" class="rb-chips"></div></div>
        <div class="rb-group" id="rb-teams-group"><span class="rb-lbl">Team</span><div id="rb-teams" class="rb-chips"></div></div>
        <div id="rb-next" style="margin-bottom:var(--space-3);"></div>
        <div style="display:flex; gap:var(--space-2); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-3);">
          <label style="font-size:0.8rem; opacity:0.75;">Sort
            <select id="rb-sort" style="margin-left:4px; padding:5px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);"></select>
          </label>
          <select id="rb-event" title="Show only players who have not answered this event"
                  style="padding:5px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); max-width:100%;"></select>
          <label style="font-size:0.8rem; display:inline-flex; align-items:center; gap:4px; cursor:pointer;">
            <input type="checkbox" id="rb-open-only"> Unanswered now only
          </label>
          <input id="rb-search" type="search" placeholder="Search player…"
                 style="padding:6px 10px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); min-width:160px;">
          <span style="flex:1;"></span>
          <button id="rb-refresh" class="btn btn-secondary" style="padding:4px 12px; font-size:0.85rem;">🔄 Refresh</button>
        </div>
        <div id="rb-summary" style="font-size:0.8rem; opacity:0.75; margin-bottom:var(--space-2);"></div>
        <div id="rb-bulk"></div>
        <div id="rb-body"></div>
      </div>
    `;
    this.element = div;
    this._wireEvents();
    return div;
  }

  onEnter(params) {
    if (params && params.section && RsvpBoardScreen.SECTIONS[params.section]) this.section = params.section;
    this._renderChips();
    this.load();
  }

  _wireEvents() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const sec = e.target.closest('[data-section]');
      if (sec) { this.section = sec.dataset.section; this.teamId = null; this.eventId = null; this._renderChips(); this.load(); return; }
      const dayChip = e.target.closest('[data-day]');
      if (dayChip) {
        this.day = dayChip.dataset.day; this.eventId = null;
        if (this.day !== 'week') { this.sort = 'open'; this.openOnly = true; }
        this._renderChips(); this._renderBody(); return;
      }
      const win = e.target.closest('[data-window]');
      if (win) { this.window = win.dataset.window; this._renderChips(); this.load(); return; }
      const kind = e.target.closest('[data-kind]');
      if (kind) { this.kind = kind.dataset.kind; this.eventId = null; this._renderChips(); this.load(); return; }
      // Next-game tile: focus the cards on that team's players who have
      // not answered that game; tap again to clear.
      const game = e.target.closest('[data-game]');
      if (game) {
        const id = Number(game.dataset.game), team = Number(game.dataset.gameTeam);
        const on = this.eventId === id && this.teamId === team;
        this.eventId = on ? null : id;
        this.teamId  = on ? null : team;
        if (!on) this.sort = 'open';
        this._renderChips();
        this._renderBody();
        return;
      }
      const team = e.target.closest('[data-team]');
      if (team) { this.teamId = team.dataset.team ? Number(team.dataset.team) : null; this._renderBody(); return; }
      if (e.target.closest('#rb-refresh')) { this.load(); return; }
      const remind = e.target.closest('[data-remind]');
      if (remind && !remind.disabled) { this._remind(remind); return; }
      const bulk = e.target.closest('[data-bulk]');
      if (bulk && !bulk.disabled) { this._remindEvent(bulk); return; }
    });
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'rb-sort')      { this.sort = e.target.value; this._renderBody(); }
      if (e.target.id === 'rb-event')     { this.eventId = e.target.value ? Number(e.target.value) : null; this._renderBody(); }
      if (e.target.id === 'rb-open-only') { this.openOnly = e.target.checked; this._renderBody(); }
    });
    this.element.addEventListener('input', (e) => {
      if (e.target.id === 'rb-search') { this.search = e.target.value.trim().toLowerCase(); this._renderBody(); }
    });
  }

  _renderChips() {
    const chip = (attr, key, label, on) =>
      `<button class="rb-chip${on ? ' on' : ''}" data-${attr}="${key}">${this.escapeHtml(label)}</button>`;
    // Day pills carry how many players still owe an answer that day, and
    // dim at zero; a stale pick (yesterday's date after midnight) resets.
    const pills = this._dayPills();
    if (!pills.some(pl => pl.key === this.day)) this.day = 'week';
    const people = (this.data && this.data.people) || [];
    this.find('#rb-days').innerHTML = pills.map(pl => {
      if (pl.key === 'week') return chip('day', pl.key, pl.label, pl.key === this.day);
      const n = people.filter(p => (p.open_events || []).some(ev => ev.day === pl.key)).length;
      return `<button class="rb-chip${pl.key === this.day ? ' on' : ''}" data-day="${pl.key}"
                      style="${n || pl.key === this.day ? '' : 'opacity:0.45;'}"
                      title="${n} player${n === 1 ? '' : 's'} with something unanswered">${this.escapeHtml(pl.label)}${people.length ? ` <span style="opacity:0.7; font-weight:400;">${n}</span>` : ''}</button>`;
    }).join('');
    this.find('#rb-sections').innerHTML = Object.entries(RsvpBoardScreen.SECTIONS)
      .map(([k, l]) => chip('section', k, l, k === this.section)).join('');
    this.find('#rb-windows').innerHTML = Object.entries(RsvpBoardScreen.WINDOWS)
      .map(([k, l]) => chip('window', k, l, k === this.window)).join('');
    this.find('#rb-kinds').innerHTML = Object.entries(RsvpBoardScreen.KINDS)
      .map(([k, l]) => chip('kind', k, l, k === this.kind)).join('');
    this.find('#rb-sort').innerHTML = Object.entries(RsvpBoardScreen.SORTS)
      .map(([k, l]) => `<option value="${k}"${k === this.sort ? ' selected' : ''}>${this.escapeHtml(l)}</option>`).join('');
    const openOnly = this.find('#rb-open-only');
    if (openOnly) openOnly.checked = this.openOnly;
  }

  async load() {
    const seq = ++this._loadSeq;
    this.loading = true; this.error = null;
    this._renderBody();
    try {
      // "All" (owner 2026-09-22) is the four sections fetched together and
      // merged; every row remembers its section so reminders route right.
      const keys = this.section === 'all'
        ? Object.keys(RsvpBoardScreen.SECTIONS).filter(k => k !== 'all') : [this.section];
      const bodies = await Promise.all(keys.map(async (key) => {
        const res = await this.auth.fetch(`/api/rsvp-board?section=${encodeURIComponent(key)}&window=${encodeURIComponent(this.window)}&kind=${encodeURIComponent(this.kind)}`);
        const body = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
        for (const p of (body.people || [])) p.section = key;
        for (const g of (body.next_games || [])) g.section = key;
        return body;
      }));
      if (seq !== this._loadSeq) return;           // a newer load superseded this one
      this.data = bodies.length === 1 ? bodies[0] : {
        ...bodies[0],
        section: 'all',
        next_games: bodies.flatMap(b => b.next_games || []),
        people: bodies.flatMap(b => b.people || []),
      };
    } catch (err) {
      if (seq !== this._loadSeq) return;
      this.data = null;
      this.error = err.message || 'Failed to load.';
    }
    this.loading = false;
    if (this.isMounted) { this._renderChips(); this._renderBody(); }
  }

  // ── Body ────────────────────────────────────────────────────────
  _renderBody() {
    const bodyEl = this.find('#rb-body');
    if (!bodyEl) return;
    if (this.loading) {
      // Don't leave the previous section's games above a loading list.
      const next = this.find('#rb-next');
      if (next) next.innerHTML = '';
      const bulkEl = this.find('#rb-bulk');
      if (bulkEl) bulkEl.innerHTML = '';
      // The list waits on a LeagueApps sync so dues are fresh.
      bodyEl.innerHTML = `<div style="opacity:0.7; padding:var(--space-4);">Loading — syncing LeagueApps so dues are current…</div>`;
      return;
    }
    if (this.error) {
      bodyEl.innerHTML = `<div style="color:#f87171; padding:var(--space-4);">⚠️ ${this.escapeHtml(this.error)}</div>`;
      return;
    }
    const people = (this.data && this.data.people) || [];

    this._renderNextGames();

    // Team chips + event filter come from the loaded rows.
    const teams = new Map();
    const events = new Map();
    for (const p of people) {
      for (const t of (p.teams || [])) teams.set(t.id, t.label);
      for (const ev of this._openFor(p)) events.set(ev.fh_event_id, ev.line);
    }
    this.find('#rb-teams-group').style.display = teams.size > 1 ? '' : 'none';
    this.find('#rb-teams').innerHTML = teams.size > 1
      ? [`<button class="rb-chip${this.teamId == null ? ' on' : ''}" data-team="">All teams</button>`]
          .concat([...teams].map(([id, label]) =>
            `<button class="rb-chip${this.teamId === id ? ' on' : ''}" data-team="${id}">${this.escapeHtml(label)}</button>`))
          .join('')
      : '';
    if (this.eventId != null && !events.has(this.eventId)) this.eventId = null;
    this.find('#rb-event').innerHTML = `<option value="">Unanswered for: any event</option>` +
      [...events].map(([id, line]) =>
        `<option value="${id}"${id === this.eventId ? ' selected' : ''}>Unanswered for: ${this.escapeHtml(line)}</option>`).join('');

    const dayOn = this.day !== 'week';
    const list = people.filter(p =>
      (this.teamId == null || (p.teams || []).some(t => t.id === this.teamId)) &&
      (this.eventId == null || this._openFor(p).some(ev => ev.fh_event_id === this.eventId)) &&
      // A day pill is a straggler list: only players with something still
      // unanswered that day.
      (!(this.openOnly || dayOn) || this._openFor(p).length > 0) &&
      (!this.search || `${p.first_name} ${p.last_name}`.toLowerCase().includes(this.search)));

    this._renderBulk(people, events);

    const ts = (iso) => iso ? new Date(iso).getTime() : 0;
    const byName = (a, b) => `${a.last_name} ${a.first_name}`.localeCompare(`${b.last_name} ${b.first_name}`);
    const sorters = {
      // Nobody-expected players (null %) sink to the bottom of the % sort.
      worst: (a, b) => (a.rsvp_pct == null) - (b.rsvp_pct == null) || (a.rsvp_pct - b.rsvp_pct)
                       || (b.open_events.length - a.open_events.length) || byName(a, b),
      open:  (a, b) => (this._openFor(b).length - this._openFor(a).length) || (a.rsvp_pct ?? 101) - (b.rsvp_pct ?? 101) || byName(a, b),
      quiet: (a, b) => ts(a.last_rsvp_at) - ts(b.last_rsvp_at) || byName(a, b),
      nagged: (a, b) => ((b.reminders_total || 0) - (a.reminders_total || 0)) || byName(a, b),
      name:  byName,
    };
    list.sort(sorters[this.sort] || sorters.worst);

    const owing  = list.filter(p => this._openFor(p).length > 0).length;
    const behind = list.filter(p => this._openFor(p).length + this._missedFor(p).length > 0).length;
    const dayLabel = dayOn ? `${this._dayLabel().toLowerCase()} (${this._dayIso()})` : 'this week';
    this.find('#rb-summary').textContent =
      `${list.length} player${list.length === 1 ? '' : 's'} · ${owing} with unanswered events ${dayOn ? dayLabel : 'right now'} · ${behind} below 100% ${dayLabel} · ` +
      `RSVP % covers ${RsvpBoardScreen.WINDOWS[this.window].toLowerCase()}, ` +
      `${{ all: 'practices & games', games: 'games only', practices: 'practices only' }[this.kind]} (from the day they joined the team)`;

    bodyEl.innerHTML = list.length
      ? `<div class="rb-grid">${list.map(p => this._renderCard(p)).join('')}</div>`
      : `<div style="opacity:0.7; padding:var(--space-4);">Nobody matches these filters.</div>`;
  }

  // Group reminder bar — only with one event picked.  It goes to everyone
  // in the section (and team, when one is picked) who has not answered
  // that event; search / "unanswered now only" narrow the cards, not this.
  _renderBulk(people, events) {
    const slot = this.find('#rb-bulk');
    if (!slot) return;
    if (this.eventId == null) { slot.innerHTML = ''; this.bulk = null; return; }
    const key = `${this.section}:${this.eventId}:${this.teamId ?? ''}`;
    if (this.bulk && this.bulk.key !== key) this.bulk = null;

    const owing = people.filter(p =>
      (this.teamId == null || (p.teams || []).some(t => t.id === this.teamId)) &&
      this._openFor(p).some(ev => ev.fh_event_id === this.eventId));
    const phones = owing.filter(p => p.has_phone).length;
    const emails = owing.filter(p => p.has_email).length;
    const btn = (channel, icon, n, bg, what) =>
      `<button class="rb-btn" data-bulk="${channel}" style="background:${bg};"${n ? '' : ' disabled'}
               title="${this.escapeHtml(n ? what : 'Nobody unanswered has one on file')}">${icon} ${channel === 'sms' ? 'GROUP TEXT' : 'EMAIL'} ${n}</button>`;
    slot.innerHTML = `
      <div class="rb-bulk">
        <span><b>${owing.length}</b> ${owing.length === 1 ? 'has' : 'have'} not answered
              <b>${this.escapeHtml(events.get(this.eventId) || '')}</b> — remind them all at once:</span>
        ${btn('sms', '💬', phones, '#0284c7', 'One group text (split into groups of 10) — no sign-in link, everyone sees each other\'s number')}
        ${btn('email', '✉', emails, '#7c3aed', 'One email, everyone BCC\'d — no sign-in link')}
        <span data-bulk-result style="flex-basis:100%;${this.bulk ? '' : ' display:none;'}">${this.bulk ? this.bulk.html : ''}</span>
      </div>`;
  }

  // POST renders the DB copy, logs every player as reminded, and hands
  // back the contacts; the compose href is built here because
  // screen-base.js carries the per-device quirks (Android BCC, sms hint).
  // Carriers cap group MMS around 10 people (see my.js Text All), so a
  // bigger group becomes several links — a tap can only open one thread.
  async _remindEvent(btn) {
    const channel = btn.dataset.bulk === 'email' ? 'email' : 'sms';
    const key = `${this.section}:${this.eventId}:${this.teamId ?? ''}`;
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const headers = { 'Content-Type': 'application/json' };
      if (this.auth && this.auth.token) headers['Authorization'] = `Bearer ${this.auth.token}`;
      // Under "All" the event's section comes from a row that owes it.
      const section = this.section !== 'all' ? this.section
        : ((((this.data && this.data.people) || []).find(p => (p.open_events || []).some(ev => ev.fh_event_id === this.eventId)) || {}).section || 'mens');
      const res = await fetch('/api/rsvp-board/remind-event', {
        method: 'POST', headers, credentials: 'same-origin',
        body: JSON.stringify({ section, fh_event_id: this.eventId, team_id: this.teamId, channel }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);

      for (const p of ((this.data && this.data.people) || [])) {
        const rem = data.reminded && data.reminded[p.person_id];
        if (rem) this._applyTally(p, rem);
      }
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      let html;
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        html = `✉ Email drafted to ${contacts.length} (BCC)${skipped}`;
      } else {
        const CHUNK_SIZE = 10;
        const chunks = [];
        for (let i = 0; i < contacts.length; i += CHUNK_SIZE) chunks.push(contacts.slice(i, i + CHUNK_SIZE));
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        html = chunks.length === 1
          ? `💬 Group text drafted to ${contacts.length}${skipped}`
          : `Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a class="rb-btn" style="background:#0284c7;" href="${this.escapeHtml(h)}">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ') + skipped;
        if (chunks.length === 1) window.location.href = hrefs[0];
      }
      this.bulk = { key, channel, html };
      this._renderBody();
    } catch (err) {
      btn.textContent = original;
      btn.disabled = false;
      console.warn('[rsvps] group remind failed:', err);
      const slot = this.find('[data-bulk-result]');
      if (slot) { slot.style.display = ''; slot.innerHTML = `<span class="rb-bad">${this.escapeHtml(err.message)}</span>`; }
    }
  }

  // One tile per team: its next game and how the roster has answered.
  // Games matter most (owner 2026-09-17), so this sits above the cards.
  _renderNextGames() {
    const slot = this.find('#rb-next');
    if (!slot) return;
    const games = (this.data && this.data.next_games) || [];
    if (!games.length || this.kind === 'practices') { slot.innerHTML = ''; return; }
    slot.innerHTML = `
      <div style="font-size:0.72rem; letter-spacing:0.06em; text-transform:uppercase; opacity:0.6; margin-bottom:6px;">
        Next game — tap to see who hasn't answered
      </div>
      <div style="display:flex; gap:var(--space-2); flex-wrap:wrap;">
        ${games.map(g => {
          const on = this.eventId === g.fh_event_id && this.teamId === g.team_id;
          const ha = g.is_home == null ? 'vs' : (g.is_home ? 'vs' : '@');
          const counts = g.released
            ? `<span class="rb-good">${g.yes} going</span> · <span>${g.no} not</span> ·
               <span class="${g.unanswered ? 'rb-bad' : 'rb-good'}" style="font-weight:800;">${g.unanswered} unanswered</span>
               <span style="opacity:0.6;"> of ${g.expected}</span>`
            : `<span style="opacity:0.7;">Not released to players yet — nobody can answer</span>`;
          return `
            <button type="button" class="rb-game${on ? ' on' : ''}" data-game="${g.fh_event_id}" data-game-team="${g.team_id}">
              <div style="font-size:0.72rem; opacity:0.7;">${this.escapeHtml(g.team_label)}</div>
              <div style="font-weight:800;">${ha} ${this.escapeHtml(g.opponent)}</div>
              <div style="font-size:0.78rem; opacity:0.8;">${this.escapeHtml(g.when_text)}</div>
              <div style="font-size:0.78rem; margin-top:4px;">${counts}</div>
            </button>`;
        }).join('')}
      </div>`;
  }

  _fmtDate(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d)) return '';
    const days = Math.floor((Date.now() - d.getTime()) / 86400000);
    const when = d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    return days <= 0 ? `${when} (today)` : `${when} (${days}d ago)`;
  }

  _renderCard(p) {
    const pct = p.rsvp_pct;
    const pctCls = pct == null ? 'rb-none' : pct >= 80 ? 'rb-good' : pct >= 50 ? 'rb-mid' : 'rb-bad';
    const teams = (p.teams || []).map(t => this.escapeHtml(t.label)).join(' · ');

    const lastRsvp = p.last_rsvp_at
      ? `${this._fmtDate(p.last_rsvp_at)}${p.last_rsvp_via === 'standing' ? ' · standing default' : ''}`
      : '<span class="rb-bad">never</span>';
    // A standing default can be newer than anything the player did
    // themselves — show their last own tap when it differs.
    const lastManual = (p.last_manual_rsvp_at && p.last_manual_rsvp_at !== p.last_rsvp_at)
      ? `<div class="rb-row"><span class="k">Last own tap</span><span class="v">${this._fmtDate(p.last_manual_rsvp_at)}</span></div>` : '';

    let dues;
    if (p.months_overdue == null) dues = `<span class="rb-pill" style="background:rgba(148,163,184,0.2);">No membership</span>`;
    else if (p.months_overdue === 0) dues = `<span class="rb-pill" style="background:rgba(34,197,94,0.18); color:#4ade80;">Dues current</span>`;
    else dues = `<span class="rb-pill" style="background:rgba(239,68,68,0.18); color:#f87171;">Dues ${p.months_overdue} mo behind</span>`;
    if (p.dues_variant === 'inactive') dues += ` <span class="rb-pill" style="background:rgba(148,163,184,0.2);">Inactive tier</span>`;

    // Payment rows are admin-only; the backend omits the fields for coaches.
    const payment = ('last_payment_at' in p)
      ? `<div class="rb-row"><span class="k">Last payment</span><span class="v">${p.last_payment_at
          ? `$${Number(p.last_payment_amount).toFixed(2)} · ${this._fmtDate(p.last_payment_at)}`
          : '<span class="rb-bad">none on record</span>'}</span></div>` : '';

    const rem = p.last_reminder;
    const reminded = rem
      ? `${rem.channel === 'sms' ? '💬' : '✉'}${rem.group ? ' 👥 group' : ''} ${this._fmtDate(rem.sent_at)}${rem.by ? ` · ${this.escapeHtml(rem.by)}` : ''}`
      : '—';

    const to = p.youth ? ` (to parent${p.parent_first_name ? ' ' + this.escapeHtml(p.parent_first_name) : ''})` : '';
    // REMIND only lists what can still be answered — an event that
    // already went by would just confuse the player (owner 2026-09-19).
    // Missed ones stay on the card for the admin.
    // Each button tallies ITS channel (owner 2026-09-22: "I sent 2 emails
    // and no response yet, let me try a text"); one reminder on either
    // channel still greys both, because it covered the whole week.
    // A day pill narrows the card, not the message: REMIND always lists
    // every unanswered event of the week (owner 2026-09-22).
    const weekOpen = (p.open_events || []).length;
    const btn = (channel, icon, has, bg) => {
      const mine = channel === 'sms' ? (p.reminders_week_sms || 0) : (p.reminders_week_email || 0);
      const why = !weekOpen ? 'Nothing left to answer this week' : !has
        ? (channel === 'sms' ? 'No mobile number on file' : 'No email on file')
        : `${channel === 'sms' ? 'Text' : 'Email'} the ${weekOpen} unanswered event${weekOpen === 1 ? '' : 's'} this week + sign-in link${to}`;
      const already = p.reminders_week
        ? ` — this week: ${p.reminders_week_sms || 0} text${(p.reminders_week_sms || 0) === 1 ? '' : 's'}, ${p.reminders_week_email || 0} email${(p.reminders_week_email || 0) === 1 ? '' : 's'}`
        : '';
      return `<button class="rb-btn" data-remind="${channel}" data-person-id="${p.person_id}"
                      style="background:${bg};${p.reminders_week ? ' opacity:0.45;' : ''}" title="${this.escapeHtml(why + already)}"${(!weekOpen || !has) ? ' disabled' : ''}>${icon} REMIND${mine ? ` ✓ ×${mine}` : (p.reminders_week ? ' ✓' : '')}</button>`;
    };

    return `
      <div class="rb-card" data-card="${p.person_id}">
        <div style="display:flex; justify-content:space-between; gap:8px; align-items:flex-start;">
          <div style="min-width:0;">
            <div style="font-weight:800;">${this.escapeHtml(p.first_name)} ${this.escapeHtml(p.last_name)}</div>
            <div style="font-size:0.72rem; opacity:0.65;">${this.section === 'all' && p.section ? this.escapeHtml(RsvpBoardScreen.SECTIONS[p.section] || p.section) + ' · ' : ''}${teams}${p.youth ? ' · youth' : ''}</div>
          </div>
          <div style="text-align:right;">
            <div class="rb-pct ${pctCls}">${pct == null ? '—' : pct + '%'}</div>
            <div style="font-size:0.68rem; opacity:0.6;">${p.expected ? `answered ${p.answered} of ${p.expected}` : 'no events in window'}</div>
          </div>
        </div>
        ${this._weekTable(p)}
        <div class="rb-row"><span class="k">Last RSVP</span><span class="v">${lastRsvp}</span></div>
        ${lastManual}
        <div class="rb-row"><span class="k">Dues</span><span class="v">${dues}</span></div>
        ${payment}
        <div class="rb-row"><span class="k">Last reminded</span><span class="v" data-reminded>${reminded}</span></div>
        <div class="rb-row"><span class="k">Reminders</span><span class="v" data-reminder-tally>${this._tallyText(p)}</span></div>
        <div style="display:flex; gap:6px; margin-top:2px;">
          ${btn('sms', '💬', p.has_phone, '#0284c7')}
          ${btn('email', '✉', p.has_email, '#7c3aed')}
        </div>
      </div>`;
  }

  // The player's released week as a table — every expected event with
  // their answer (owner 2026-09-22: "so i can see if missing all or some
  // and which ones").  Whole week always, whatever day pill is on; the
  // pill's day is highlighted.  Past events dim; a past unanswered one is
  // "missed" (never answered), a future one "unanswered" (still owed —
  // these are what REMIND lists).
  _weekTable(p) {
    const week = p.week_events || [];
    if (!week.length) return `<div style="font-size:0.78rem;" class="rb-none">No events this week</div>`;
    const answered = week.filter(ev => ev.response).length;
    const open     = week.filter(ev => !ev.response && ev.still_open).length;
    const missed   = week.length - answered - open;
    const cls = answered === week.length ? 'rb-good' : answered === 0 ? 'rb-bad' : 'rb-mid';
    const head = `${answered === week.length ? '✓ ' : ''}Answered ${answered} of ${week.length} this week` +
      (open ? ` · <span class="rb-bad">${open} unanswered</span>` : '') +
      (missed ? ` · <span class="rb-mid">${missed} missed</span>` : '');
    const day = this._dayIso();
    const rows = week.map(ev => {
      const status = ev.response === 'yes'   ? `<span class="rb-good">✓ Going${ev.via === 'standing' ? ' <span style="font-weight:400; opacity:0.7;">(standing)</span>' : ''}</span>`
                   : ev.response === 'no'    ? `<span style="opacity:0.75;">✗ Not going${ev.via === 'standing' ? ' <span style="font-weight:400; opacity:0.7;">(standing)</span>' : ''}</span>`
                   : ev.response === 'maybe' ? `<span class="rb-mid">? Maybe</span>`
                   : ev.still_open           ? `<span class="rb-bad">— unanswered</span>`
                                             : `<span class="rb-mid">missed</span>`;
      const trCls = [ev.still_open ? '' : 'past', day && ev.day === day ? 'pick' : ''].filter(Boolean).join(' ');
      return `<tr${trCls ? ` class="${trCls}"` : ''}>
                <td style="white-space:nowrap;">${this.escapeHtml(ev.when)}</td>
                <td>${this.escapeHtml(ev.what)}</td>
                <td>${status}</td>
              </tr>`;
    }).join('');
    return `<div style="font-size:0.78rem; font-weight:700;" class="${cls}">${head}</div>
            <table class="rb-week">${rows}</table>`;
  }

  // "this week 💬 1 · ✉ 2 — all-time 💬 3 · ✉ 4", per channel.
  _tallyText(p) {
    if (!p || !p.reminders_total) return '—';
    const pair = (sms, email) => `💬 ${sms || 0} · ✉ ${email || 0}`;
    return `this week ${pair(p.reminders_week_sms, p.reminders_week_email)} — all-time ${pair(p.reminders_total_sms, p.reminders_total_email)}`;
  }

  // Copy the fresh server tally onto a person row (both single and group
  // reminders hand back the same shape).
  _applyTally(person, rem) {
    if (!person || !rem) return;
    person.last_reminder = rem;
    person.reminders_total = rem.total;  person.reminders_week = rem.week;
    person.reminders_total_sms = rem.total_sms;     person.reminders_total_email = rem.total_email;
    person.reminders_week_sms  = rem.week_sms;      person.reminders_week_email  = rem.week_email;
  }

  // POST builds the message server-side (unanswered events + the
  // recipient's magic link), logs it, and hands back the compose href for
  // THIS device's Messages / Gmail.  Nothing is sent until the operator
  // presses send there.  Opening after an await works in practice for
  // sms: and Gmail compose — same as the LINK / WELCOME buttons.
  async _remind(btn) {
    const channel  = btn.dataset.remind === 'email' ? 'email' : 'sms';
    const personId = Number(btn.dataset.personId);
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const headers = { 'Content-Type': 'application/json' };
      if (this.auth && this.auth.token) headers['Authorization'] = `Bearer ${this.auth.token}`;
      // The day pill only narrows the board; the message always lists
      // every unanswered event of the week (owner 2026-09-22).
      const res = await fetch('/api/rsvp-board/remind', {
        method: 'POST', headers, credentials: 'same-origin',
        body: JSON.stringify({ person_id: personId, channel }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);

      const person = ((this.data && this.data.people) || []).find(p => p.person_id === personId);
      if (person && data.last_reminder) this._applyTally(person, data.last_reminder);
      if (channel === 'email') this.openGmailCompose(data.gmail_href);
      else window.location.href = data.sms_href;

      btn.disabled = false;
      const card = btn.closest('[data-card]');
      // One reminder covers the whole week, so both channels dim — but
      // each button tallies only its own channel.
      const lr = data.last_reminder || {};
      (card ? card.querySelectorAll('[data-remind]') : [btn]).forEach(b => {
        const isSms = b.dataset.remind === 'sms';
        const mine  = isSms ? (lr.week_sms || 0) : (lr.week_email || 0);
        b.textContent = `${isSms ? '💬' : '✉'} REMIND ✓${mine ? ` ×${mine}` : ''}`;
        b.style.opacity = '0.45';
      });
      const tally = card && card.querySelector('[data-reminder-tally]');
      if (tally && person) tally.textContent = this._tallyText(person);
      const slot = card && card.querySelector('[data-reminded]');
      if (slot && data.last_reminder) {
        slot.textContent = `${channel === 'sms' ? '💬' : '✉'} ${this._fmtDate(data.last_reminder.sent_at)}` +
          (data.last_reminder.by ? ` · ${data.last_reminder.by}` : '');
      }
    } catch (err) {
      btn.textContent = original;
      btn.disabled = false;
      btn.title = err.message;
      console.warn('[rsvps] remind failed:', err);
      const card = btn.closest('[data-card]');
      const slot = card && card.querySelector('[data-reminded]');
      if (slot) slot.innerHTML = `<span class="rb-bad">${this.escapeHtml(err.message)}</span>`;
    }
  }
}
