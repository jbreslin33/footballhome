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
// ✓/✗ on a tile: POST|DELETE /api/calendar/rsvp as yourself (my_rsvp) and,
// with person_id, for each of your kids on it (guardian_targets).
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
      <!-- Staff: [👤 Mine] [📅 Club week], one at a time (mig 1296). -->
      <div id="ec-views" style="display:none; gap:6px; flex-wrap:wrap; padding: var(--space-3) var(--space-4) 0; max-width: 1400px; margin: 0 auto;"></div>
      <!-- 👤 Mine: everything #my shows, as its own visible section (owner
           2026-11-11: "bring it all" / "put it in sep section but visible").
           #my redirects here last; until then both work. -->
      <section id="ec-mine" style="padding: var(--space-3) var(--space-4) 0; max-width: 1400px; margin: 0 auto;"></section>
      <div id="ec-body" style="padding: var(--space-4); max-width: 1400px; margin: 0 auto;"></div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter(params = {}) {
    this._mountMine();
    // An old door with one event (saved history) shows that event's week.
    const evAt = params.event && new Date(params.event.starts_at);
    if (evAt && !isNaN(evAt)) { this.weekStart = EventCenterScreen.monday(evAt); this.events = null; }
    // A type pill (EventKindSwitch) lights that kind on the calendar.
    if (params.kind) this.kind = params.kind;
    // An old #my door asks for 👤 Mine (navigation.js) — not saved to the device.
    if (params.view === 'mine' || params.view === 'club') this._viewPick = params.view;
    this.error = null;
    this._render();
    // The DB copy (title, subtitle, not-posted, now line) — cached across screens.
    if (window.MessageCopy) MessageCopy.load(this.auth).then(() => this._render()).catch(() => {});
    this._loadEvents();
    // Pull Google Calendar in the background (GcalRefresh, 11/3) — the week
    // shows from the DB now and reloads once the pull has landed.
    if (window.GcalRefresh) GcalRefresh.ping(this.auth, () => this._loadEvents());
  }

  onExit() { this._unmountMine(); }

  // Club admins, coaches and club staff get the week calendar under Mine;
  // a player or parent (or an admin viewing as one) does not.
  _staffView() {
    if (this.auth && this.auth.viewAsPersonId) return false;
    const role = ((this.navigation.context && this.navigation.context.user) || {}).role;
    if (['club', 'sport_division', 'team', 'super', 'system', 'league', 'marketing'].includes(role)) return true;
    return (this.events || []).some(e => e && (e.my_role === 'coach' || e.my_role === 'staff'));
  }

  // 👤 Mine — the whole #my page (MyScreen: banners, dues, volunteer
  // shifts, GroupMe, your week with Go / No, call-in, kids' pills …)
  // drawn in its own section above the club calendar.  The same MyScreen
  // instance #my uses, mounted here: its own click / change wiring rides
  // on its element.  Words: event_center mine_title.
  _mountMine() {
    const host = this.find('#ec-mine');
    const my = window.app && window.app.screens && window.app.screens.my;
    if (!host || !my || typeof my.render !== 'function') return;
    this._unmountMine();
    let el;
    try { el = my.render(); } catch (err) { console.error('[event-center] mine render failed:', err); return; }
    el.classList.remove('screen');
    // Event Center has its own ← Back; #my's own "My Schedule" title is the
    // section heading's job.
    const back = el.querySelector('.back-btn'); if (back) back.remove();
    const title = (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', 'mine_title'))
      ? MessageCopy.block('event_center', 'mine_title') : '👤 Mine';
    const h = el.querySelector('.screen-header h1'); if (h) h.textContent = title;
    host.innerHTML = '';
    host.appendChild(el);
    this._mine = my;
    my.isMounted = true;
    try { my.onEnter({}); } catch (err) { console.error('[event-center] mine enter failed:', err); }
  }

  _unmountMine() {
    if (!this._mine) return;
    try { this._mine.onExit(); } catch (_) {}
    this._mine.isMounted = false;
    this._mine = null;
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
      if ((el = t('[data-ec-view]'))) { this._setView(el.dataset.ecView); return; }
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
        if (ev) EventKindSwitch.open(this.navigation, ev);
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

  // Staff see ONE of 👤 Mine / 📅 Club week at a time (owner 2026-11-12:
  // "it shows like both views at same time lol player and admin/coach" →
  // two pills).  Club week by default; the last pick is kept per device.
  // Players and parents have no pills — Mine is their page.
  _view() {
    if (!this._viewPick) {
      try { this._viewPick = localStorage.getItem('fh.ec.view'); } catch (_e) { /* private mode */ }
    }
    return this._viewPick === 'mine' ? 'mine' : 'club';
  }

  _setView(v) {
    this._viewPick = v === 'mine' ? 'mine' : 'club';
    try { localStorage.setItem('fh.ec.view', this._viewPick); } catch (_e) { /* private mode */ }
    this._render();
  }

  _paintViews(staff) {
    const host = this.find('#ec-views');
    const mine = this.find('#ec-mine');
    const view = staff ? this._view() : 'mine';
    if (mine) mine.style.display = view === 'mine' ? '' : 'none';
    if (!host) return view;
    host.style.display = staff ? 'flex' : 'none';
    if (!staff) { host.innerHTML = ''; return view; }
    const cp = (tier, fb) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier)) ? MessageCopy.block('event_center', tier) : fb;
    const pill = (v, label) => `<button type="button" class="ec-chip ${view === v ? 'on' : ''}" data-ec-view="${v}">${this.escapeHtml(label)}</button>`;
    host.innerHTML = pill('mine', cp('view_mine', '👤 Mine')) + pill('club', cp('view_club', '📅 Club week'));
    return view;
  }

  _render() {
    const body = this.find('#ec-body');
    const title = this.find('#ec-title');
    const sub = this.find('#ec-sub');
    if (!body) return;
    const kinds = this.find('#ec-kinds');
    // Players and parents: 👤 Mine IS their week (Go / No, call-in, times,
    // kids) — the club calendar under it would list the same events again,
    // so it is for staff only (owner 11/11: #my → Event Center).
    const staff = this._staffView();
    const club = this._paintViews(staff) === 'club';
    body.style.display = club ? '' : 'none';
    if (kinds) kinds.innerHTML = club ? EventKindSwitch.html(EventKindSwitch.KINDS.includes(this.kind) ? this.kind : 'all', (t) => this.escapeHtml(t)) : '';
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
        if (ev.my_rsvp_eligible === true) {
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
        ${mine()}
      </div>`;
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
