// EventCenterScreen — #event-center: the week calendar, Monday–Sunday
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
// Feed: GET /api/calendar/upcoming?start=<Monday>&days=7 (admins get every
// club event, coaches their teams').
class EventCenterScreen extends Screen {
  static get CATEGORY_LABELS() { return { mens: 'Men', womens: 'Women', boys: 'Boys', girls: 'Girls', staff: 'Staff' }; }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.events   = null;      // the week's feed
    this.kind     = 'all';
    this.category = 'all';
    this.weekStart = EventCenterScreen.monday(new Date());   // the calendar's Monday, kept across visits
    this.error    = null;
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
        .ec-now { display:flex; align-items:center; gap:6px; color:#ef4444; font-size:0.66rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; white-space:nowrap; }
        .ec-now::before, .ec-now::after { content:''; flex:1; height:2px; background:#ef4444; }
        @media (min-width: 900px) { .ec-week { grid-template-columns:repeat(7, minmax(0, 1fr)); } }
      </style>
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ec-title">📋 Event Center</h1>
        <p class="subtitle" id="ec-sub"></p>
        <!-- 🏟️ Games · 🏃 Practices · ⚽ Pickup · 📅 All (lib/event-kind-switch.js) -->
        <div id="ec-kinds" style="display:contents;"></div>
      </div>
      <div id="ec-body" style="padding: var(--space-4); max-width: 1400px; margin: 0 auto;"></div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter(params = {}) {
    // An old door with one event (saved history) shows that event's week.
    const evAt = params.event && new Date(params.event.starts_at);
    if (evAt && !isNaN(evAt)) { this.weekStart = EventCenterScreen.monday(evAt); this.events = null; }
    // A type pill (EventKindSwitch) lights that kind on the calendar.
    if (params.kind) this.kind = params.kind;
    this.error = null;
    this._render();
    // The DB copy (title, subtitle, not-posted, now line) — cached across screens.
    if (window.MessageCopy) MessageCopy.load(this.auth).then(() => this._render()).catch(() => {});
    this._loadEvents();
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

  _weekLabel() {
    const end = new Date(this.weekStart); end.setDate(end.getDate() + 6);
    const fmt = (d) => d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    return `${fmt(this.weekStart)} – ${fmt(end)}`;
  }

  _ymd(d) {
    const p = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
  }

  // Another week (‹ › / This week / the date box): drop the old feed so
  // the calendar shows Loading…, then fetch.
  _setWeek(date) {
    this.weekStart = EventCenterScreen.monday(date);
    this.events = null;
    this.error = null;
    this._render();
    this._loadEvents();
  }

  // The week's events — the whole calendar, released or not (staff see
  // what is coming; a not-yet-posted event says so on its tile).
  async _loadEvents() {
    const start = this.weekStart;
    try {
      const body = await this._json(`/api/calendar/upcoming?start=${encodeURIComponent(start.toISOString())}&days=7`);
      if (start !== this.weekStart) return;   // a newer week was asked for meanwhile
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
      if ((el = t('[data-ec-week]'))) {
        const step = Number(el.dataset.ecWeek);
        const d = step ? new Date(this.weekStart) : new Date();
        if (step) d.setDate(d.getDate() + 7 * step);
        this._setWeek(d);
        return;
      }
      if ((el = t('[data-ec-open]'))) {
        // A goTo, so Back returns to the week.
        const ev = (this.events || []).find(x => x.fh_event_id === Number(el.dataset.ecOpen));
        if (ev) EventKindSwitch.open(this.navigation, ev);
      }
    });
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
    if (!this.events) { body.innerHTML = `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`; return; }
    body.innerHTML = this._pickerHtml();
  }

  // The week calendar: Monday–Sunday, the lit type pill and section chip
  // choosing what fills it.  Each event is a tile — tap to open it.  Days
  // sit side by side on a wide screen and stack Mon→Sun on a phone; the
  // NOW line (mig 748) crosses today where the clock falls, the events
  // already over dimmed above it.
  _pickerHtml() {
    const cats = [...new Set(this.events.map(ev => ev.category).filter(Boolean))];
    const catLabel = (c) => EventCenterScreen.CATEGORY_LABELS[c] || c;
    const chip = (attr, value, label, on) =>
      `<button type="button" class="ec-chip ${on ? 'on' : ''}" ${attr}="${this.escapeHtml(value)}">${this.escapeHtml(label)}</button>`;
    const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || fb;

    const shown = this.events.filter(ev =>
      (this.kind === 'all' || this._kindOf(ev) === this.kind) &&
      (this.category === 'all' || ev.category === this.category))
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

    const tile = (ev) => {
      // Players only — coaches never in a player total (owner 2026-10-06).
      // The feed's roster already honours call-up gates and paper spots;
      // a yes from over the dues line (migration 416) is counted apart.
      const players = (Array.isArray(ev.rsvps) ? ev.rsvps : []).filter(r => r && !r.is_coach);
      const going = players.filter(r => r.response === 'yes' && r.dues_eligible !== false).length;
      const ineligible = players.filter(r => r.response === 'yes' && r.dues_eligible === false).length;
      const notGoing = players.filter(r => r.response === 'no').length;
      const noResp = players.filter(r => r.response !== 'yes' && r.response !== 'no').length;
      const isGame = ev.kind === 'match';
      // A game shows ONE badge — the squad its line names (owner 2026-10-28:
      // "just apsl is fine" on a game tagged APSL + APSL Reserves).
      const badges = (isGame ? primaries(ev).slice(0, 1) : teamsOf(ev)).map(t => badge(t, isGame)).join(' ');
      const count = (tier, n, fb, color) => `<span style="color:${color}; font-weight:700;">${this.escapeHtml(cp(tier, { n }, fb))}</span>`;
      return `<button type="button" class="btn btn-secondary ec-pick ${this._isPast(ev) ? 'ec-past' : ''}" data-ec-open="${ev.fh_event_id}">
        ${badges ? `<span style="display:flex; flex-wrap:wrap; gap:4px;">${badges}</span>` : ''}
        <span style="font-size:0.8rem; font-weight:800;">${this.escapeHtml(time(ev))}</span>
        <span style="font-weight:700;">${this.escapeHtml(line(ev))}</span>
        ${ev.location ? `<span style="font-size:0.72rem; opacity:0.85;">📍 ${this.escapeHtml(ev.location)}</span>` : ''}
        <span style="display:flex; flex-wrap:wrap; gap:2px 8px; font-size:0.75rem;">
          ${count('tile_going', going, `✓ ${going} going`, '#16a34a')}
          ${count('tile_noresp', noResp, `– ${noResp} no response`, '#eab308')}
          ${count('tile_notgoing', notGoing, `✗ ${notGoing} not going`, '#dc2626')}
          ${ineligible ? count('tile_ineligible', ineligible, `⛔ ${ineligible} ineligible`, '#dc2626') : ''}
        </span>
        ${posted(ev) ? '' : `<span style="font-size:0.7rem; color:#f59e0b;">${this.escapeHtml(cp('not_posted', {}, 'not posted yet'))}</span>`}
      </button>`;
    };
    const nowLine = () => {
      const t = new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
      return `<div class="ec-now"><span>${this.escapeHtml(cp('now_line', { time: t }, `Now · ${t}`))}</span></div>`;
    };

    const today = this._ymd(new Date());
    const days = [...Array(7)].map((_, i) => { const d = new Date(this.weekStart); d.setDate(d.getDate() + i); return d; });
    const day = (d) => {
      const ymd = this._ymd(d);
      const evs = shown.filter(ev => { const t = new Date(ev.starts_at); return !isNaN(t) && this._ymd(t) === ymd; });
      // Today's NOW line: above the first event not over yet (one under
      // way sits below it), or under the last when the day is done.
      let cells = evs.map(tile);
      if (ymd === today) {
        const cut = evs.findIndex(ev => !this._isPast(ev));
        cells.splice(cut === -1 ? cells.length : cut, 0, nowLine());
      }
      const head = d.toLocaleDateString('en-US', { weekday: 'short', day: 'numeric' });
      return `<div class="ec-day ${ymd === today ? 'today' : ''}">
        <div class="ec-dayh">${this.escapeHtml(head)}</div>
        ${cells.length ? cells.join('') : '<div class="ec-none">—</div>'}
      </div>`;
    };
    const thisWeek = this.weekStart.getTime() === EventCenterScreen.monday(new Date()).getTime();

    return `
      ${cats.length > 1 ? `<div style="display:flex; gap:var(--space-1); flex-wrap:wrap; margin-bottom:var(--space-2);">
        ${chip('data-ec-category', 'all', 'All', this.category === 'all')}
        ${cats.map(c => chip('data-ec-category', c, catLabel(c), this.category === c)).join('')}
      </div>` : ''}
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2);">
        <button type="button" class="ec-chip" data-ec-week="-1" aria-label="Previous week">‹</button>
        <span style="font-weight:800; min-width:9em; text-align:center;">${this.escapeHtml(this._weekLabel())}</span>
        <button type="button" class="ec-chip" data-ec-week="1" aria-label="Next week">›</button>
        ${thisWeek ? '' : `<button type="button" class="ec-chip" data-ec-week="0">${this.escapeHtml(cp('this_week', {}, 'This week'))}</button>`}
        <input type="date" class="ec-chip" data-ec-date value="${this._ymd(this.weekStart)}"
               aria-label="Go to a week" style="font-family:inherit;">
      </div>
      <div class="ec-week">${days.map(day).join('')}</div>`;
  }
}
