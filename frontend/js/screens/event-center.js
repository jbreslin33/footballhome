// EventCenterScreen — #attendance (alias #event-center) — the staff page for
// ONE calendar event of any kind (practice, pickup, game, meeting…).
// Renamed from "Event Center" 2026-09-24 (owner: "it should be called
// attendance"); the class and file keep their names.
//
// Owner 2026-09-17: "my page for coaches and admin should be for them and
// not an admin type view … its best to have dedicated pages."  Attendance
// marking and the 🎟 Invite panel used to be role-gated panels inside the
// expanded event on #my; they live here now, and #my only shows the
// read-only lists.  Game Center (#game-center) stays the page for a game's
// squad / starters / result — a game opened here links across to it.
//
// Three doors:
//   { pick: true }   the top-level 📋 Attendance tile — pick a day (Today,
//                    Yesterday, This week, Last week, or any date) then an event.
//                    "This week" is the released window — Monday of this week
//                    through fh_schedule_window_end (migration 334), so a week
//                    opened early (owner 2026-09-27: "this week should show all
//                    'live' items to rsvp to") is listed with it.
//   { event: ev }    an event object from GET /api/calendar/upcoming (what
//                    #my hands over from its "Event Center" link).
//   { fhEventId: n } just the id — the event is read from
//                    GET /api/calendar/events/:id, any date.
//
// The feed is GET /api/calendar/upcoming (admins get every club event,
// coaches their teams'); one open event is re-read from
// GET /api/calendar/events/:id (same shape).  The tools are the existing
//   GET|POST|DELETE /api/calendar/events/:id/attendance
//   GET|POST        /api/calendar/events/:id/invites   DELETE …/invites/:personId
//   GET             /api/calendar/events/:id/session-plan   the practice plan
//                   attached to the event (edited on #practice-plan)
//   GET|POST        /api/calendar/events/:id/sides     pickup sides / practice
//                   groups by bib colour (match_lineups.squad_color; the
//                   colours are squad_colors rows, migration 372)
// Who may mark or invite is decided per event by the backend (can_mark —
// CalendarController::isEventCoachOrAdmin); without it the page is
// read-only.  Invite messages are built server-side from message_templates.
class EventCenterScreen extends Screen {
  // Which days the picker lists; 'date' = the day in the date input.
  static get WHEN_PILLS() {
    return [['today', 'Today'], ['yesterday', 'Yesterday'], ['this-week', 'This week'], ['last-week', 'Last week']];
  }
  static get CATEGORY_LABELS() { return { mens: 'Men', womens: 'Women', boys: 'Boys', girls: 'Girls', staff: 'Staff' }; }
  static get ATTENDANCE() {
    return [
      { id: 'present', letter: 'P', label: 'Present', color: '#22c55e' },
      { id: 'absent',  letter: 'A', label: 'Absent',  color: '#ef4444' },
      { id: 'late',    letter: 'L', label: 'Late',    color: '#f59e0b' },
      { id: 'excused', letter: 'E', label: 'Excused', color: '#64748b' },
    ];
  }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.events   = null;      // the picker's feed
    this.ev       = null;      // the open event
    this.kind     = 'all';
    this.category = 'all';
    this.when     = 'today';   // today | yesterday | this-week | last-week | date
    this.date     = null;      // 'YYYY-MM-DD' when `when` is 'date'
    this.windowEnd = null;     // Date: end of the released window (GET /api/schedule/window)
    this.pill     = 'coming';  // coming | sides | plan | cones | invites
    this.att      = null;      // {canMark, roster: Map(person_id -> {status})}
    this.invites  = null;      // {invites, candidates} | {error}
    this.saving   = new Set(); // "att:<pid>" / "inv:<pid>" in flight
    this.copied   = new Set(); // person_ids whose invite link was copied
    this.error    = null;
    // 🚗 Carpool on practices and pickup too (owner 2026-10-19: "this
    // should be for practices too!") — the same shared CarpoolPanel
    // component Game Center mounts for games (migs 601/608/609).
    this.carpoolPanel = new CarpoolPanel(this.auth, {
      fhEventId: () => (this.ev ? this.ev.fh_event_id : null),
      rerender: () => this._render(),
      toast: (m) => { this.cpError = m; this._render(); setTimeout(() => { this.cpError = null; this._render(); }, 4000); },
      escapeHtml: (t) => this.escapeHtml(t),
    });
    this.cpError  = null;
    this.rsvpNote = {};        // person_id → last override error, on their card
    this.remindNote = {};      // person_id → last reminder error, on their card
    this.relay = null;         // FH Texter {device, today, cap} — admins only
    this.groupNote = '';       // the 📣 bar's result line (html)
    this.folds    = new Map(); // 'noresponse' / 'notgoing' → open?  (kept across refreshes)
  }

  // Leaving the page stops the live refresh.
  onExit() { this._stopLivePoll(); }

  // ── Live refresh ────────────────────────────────────────────────────
  // Answers land from phones while a coach has the page open (as Game
  // Center's 15s poll): refetch the open event, repaint only when the
  // RSVPs actually changed, so nothing jumps under a thumb.
  _startLivePoll() {
    this._stopLivePoll();
    this._pollTimer = setInterval(() => this._pollLive(), 15000);
    this._pollOnShow = () => { if (!document.hidden) this._pollLive(); };
    document.addEventListener('visibilitychange', this._pollOnShow);
  }

  _stopLivePoll() {
    if (this._pollTimer) { clearInterval(this._pollTimer); this._pollTimer = null; }
    if (this._pollOnShow) { document.removeEventListener('visibilitychange', this._pollOnShow); this._pollOnShow = null; }
  }

  async _pollLive() {
    if (document.hidden || !this.ev || this.pill !== 'coming' || this._pollBusy) return;
    const id = this.ev.fh_event_id;
    this._pollBusy = true;
    try {
      const body = await this._json(`/api/calendar/events/${id}`);
      if (!this.ev || this.ev.fh_event_id !== id || !body.event) return;
      const key = (ev) => JSON.stringify((ev.rsvps || []).map(r => [r.person_id, r.response]));
      if (key(body.event) !== key(this.ev)) {
        this.ev = body.event;
        this._render();
      }
    } catch (_err) {
      // A missed beat is fine; the next one tries again.
    } finally {
      this._pollBusy = false;
    }
  }

  // Club admins answer for a player (owner: Game Center's coach override,
  // now on practices) — the same POST/DELETE /api/calendar/rsvp a player
  // uses, with person_id; the row records who answered.  Tapping the lit
  // answer clears it.
  async _setRsvp(personId, response, active) {
    const key = `rsvp:${personId}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    delete this.rsvpNote[personId];
    this._render();
    const id = this.ev.fh_event_id;
    try {
      if (active) {
        await this._json('/api/calendar/rsvp', { method: 'DELETE', body: JSON.stringify({ fh_event_id: id, person_id: personId }) });
      } else {
        await this._json('/api/calendar/rsvp', { method: 'POST', body: JSON.stringify({ fh_event_id: id, person_id: personId, response }) });
      }
      const row = (this.ev.rsvps || []).find(r => r.person_id === personId);
      if (row) row.response = active ? null : response;
    } catch (err) {
      this.rsvpNote[personId] = err.message;
    } finally {
      this.saving.delete(key);
    }
    this._render();
    if (this.ev && this.ev.fh_event_id === id) this._loadEvent(id);
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ec-chip { padding:5px 12px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.8rem;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .ec-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .ec-pick { display:flex; flex-direction:column; align-items:flex-start; gap:2px; text-align:left; padding:10px 12px; }
        .ec-h { font-size:0.72rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; opacity:0.75; }
        .ec-row { display:flex; align-items:center; justify-content:space-between; gap:8px; padding:4px 0;
                  border-bottom:1px solid var(--border-color); font-size:0.9rem; }
        .ec-att { width:26px; height:26px; padding:0; border-radius:50%; line-height:1; font-size:0.75rem; font-weight:800; cursor:pointer; }
        .ec-att[disabled] { opacity:0.5; cursor:wait; }
        .ec-badge { display:inline-flex; align-items:center; justify-content:center; width:22px; height:22px;
                    border-radius:50%; color:#fff; font-size:0.7rem; font-weight:800; }
        .ec-send { font-size:0.8rem; font-weight:700; color:#0f172a; padding:4px 9px; border-radius:999px; border:none; cursor:pointer; }
        .ec-send[disabled] { opacity:0.5; }
        .ec-box { border:1px solid var(--border-color); border-radius:10px; background:var(--bg-secondary); padding:12px; margin-bottom:var(--space-3); }
        .ec-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(260px, 1fr)); gap:6px; }
        .ec-card { border:1px solid var(--border-color); border-radius:10px; background:var(--bg-secondary); padding:8px 10px; font-size:0.9rem; min-width:0; }
      </style>
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ec-title">📋 Event Center</h1>
        <p class="subtitle" id="ec-sub"></p>
        <!-- 🏟️ Games · 🏃 Practices · ⚽ Pickup · 📅 All (lib/event-kind-switch.js) -->
        <div id="ec-kinds" style="display:contents;"></div>
      </div>
      <div id="ec-body" style="padding: var(--space-4); max-width: 900px; margin: 0 auto;"></div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter(params = {}) {
    // A type pill (EventKindSwitch) lands on that kind's list for the week,
    // the way Game Center shows the week's games.
    if (params.kind) { this.kind = params.kind; this.when = 'this-week'; this.date = null; }
    this.ev = params.pick ? null : (params.event || null);
    this.loadingId = (!this.ev && !params.pick && params.fhEventId) ? Number(params.fhEventId) : null;
    this.pill = 'coming';
    this.att = null;
    this.invites = null;
    this.sides = null;        // { canEdit, colors, players }
    this.plan = undefined;
    this.cones = undefined;    // undefined = not loaded; null = no plan
    this.sideColors = null;   // Set of colour codes in play on this event
    this.reminders = null;    // person_id → {sms, email, total} — who was reminded this week (mig 739)
    this.remindNote = {};     // person_id → last send error, shown on their row
    this.groupNote = '';      // the 📣 bar's result line (html)
    this.error = null;
    this.rsvpNote = {};
    this.groupNote = '';
    this.saving.clear();
    this.copied.clear();
    this._render();
    const loadCarpool = () => {
      if (this.ev && (this.ev.kind === 'practice' || this.ev.kind === 'pickup'))
        this.carpoolPanel.load().then(() => this._render());
    };
    // Groups / teams ride on the Who's Coming cards, so they load with it.
    const loadSides = () => {
      if (this.ev && (this.ev.kind === 'practice' || this.ev.kind === 'pickup')) this._loadSides();
    };
    if (this.ev) { this._loadAttendance(); loadCarpool(); this._loadReminders(); loadSides(); this._loadRelay(); }
    else if (this.loadingId) this._loadEvent(this.loadingId).then(() => { if (this.ev) { this._loadAttendance(); loadCarpool(); this._loadReminders(); loadSides(); this._loadRelay(); } });
    else this._loadEvents();
    if (this.ev || this.loadingId) this._startLivePoll(); else this._stopLivePoll();
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

  // The picker's window as { start: local midnight, days }.  Weeks run
  // Monday–Sunday (the schedule is released Sunday night for the week ahead).
  // "This week" runs from this Monday to the end of the released window —
  // seven days normally, fourteen (or more) when next week was opened early.
  _range() {
    const day = (ymd) => {
      const [y, m, d] = ymd.split('-').map(Number);
      return new Date(y, m - 1, d);
    };
    const today = new Date(); today.setHours(0, 0, 0, 0);
    const monday = (d) => { const m = new Date(d); m.setDate(m.getDate() - ((m.getDay() + 6) % 7)); return m; };
    const shift = (d, n) => { const s = new Date(d); s.setDate(s.getDate() + n); return s; };
    const releasedDays = (from) => {
      if (!(this.windowEnd instanceof Date) || isNaN(this.windowEnd)) return 7;
      const end = new Date(this.windowEnd); end.setHours(0, 0, 0, 0);
      const days = Math.round((end - from) / 86400000) + 1;
      return Math.min(90, Math.max(7, days));
    };
    switch (this.when) {
      case 'yesterday': return { start: shift(today, -1), days: 1 };
      case 'this-week': return { start: monday(today), days: releasedDays(monday(today)) };
      case 'last-week': return { start: shift(monday(today), -7), days: 7 };
      case 'date':      return { start: this.date ? day(this.date) : today, days: 1 };
      default:          return { start: today, days: 1 };
    }
  }

  _rangeLabel() {
    const { start, days } = this._range();
    const fmt = (d) => d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
    if (days === 1) return fmt(start);
    const end = new Date(start); end.setDate(end.getDate() + days - 1);
    return `${fmt(start)} – ${fmt(end)}`;
  }

  _ymd(d) {
    const p = (n) => String(n).padStart(2, '0');
    return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
  }

  _feedUrl() {
    const { start, days } = this._range();
    return `/api/calendar/upcoming?start=${encodeURIComponent(start.toISOString())}&days=${days}`;
  }

  // A new window: drop the old feed so the list shows Loading…, then fetch.
  _setWhen(when, date) {
    this.when = when;
    if (date) this.date = date;
    this.events = null;
    this._render();
    this._loadEvents();
  }

  // The released window's end for the club (policy + early releases),
  // asked once per visit.  Silent on failure: "This week" then falls back
  // to the plain Monday–Sunday.
  async _loadWindowEnd() {
    if (this.windowEnd) return;
    try {
      const { start } = this._range();
      const body = await this._json(`/api/schedule/window?week_start=${this._ymd(start)}`);
      const end = body && body.window_end ? new Date(body.window_end) : null;
      if (end && !isNaN(end)) this.windowEnd = end;
    } catch (err) {
      console.warn('[event-center] schedule window unavailable:', err);
    }
  }

  async _loadEvents() {
    try {
      if (this.when === 'this-week') await this._loadWindowEnd();
      const body = await this._json(this._feedUrl());
      let events = Array.isArray(body.events) ? body.events : [];
      // Each event carries its own section's window end; when a section
      // is not open as far as the club is, its later events stay hidden.
      if (this.when === 'this-week') {
        events = events.filter(ev => {
          if (!ev.schedule_window_end || !ev.starts_at) return true;
          const end = new Date(ev.schedule_window_end), t = new Date(ev.starts_at);
          return isNaN(end) || isNaN(t) || t <= end;
        });
      }
      this.events = events;
      // An open event is re-read from the fresh feed (its RSVP list moves
      // when an invite is sent or withdrawn).
      if (this.ev) {
        const fresh = this.events.find(e => e.fh_event_id === this.ev.fh_event_id);
        if (fresh) this.ev = fresh;
      }
    } catch (err) {
      console.error('[event-center] events load failed:', err);
      if (!this.ev) this.error = 'Could not load the calendar.';
    }
    this._render();
  }

  // One event by id — the door for { fhEventId }, and the refresh after an
  // invite moves the RSVP list (the picker feed only spans three weeks).
  async _loadEvent(id) {
    try {
      const body = await this._json(`/api/calendar/events/${id}`);
      if (this.ev ? this.ev.fh_event_id === id : this.loadingId === id) this.ev = body.event;
    } catch (err) {
      console.error('[event-center] event load failed:', err);
      if (!this.ev) this.error = 'Could not load that event.';
    }
    this.loadingId = null;
    this._render();
  }

  // Who was already reminded this week, per channel (GET /api/rsvp-board/
  // reminders, admins only — anyone else just gets no sent notes).
  async _loadReminders() {
    if (!this.ev) return;
    try {
      const data = await this._json(`/api/rsvp-board/reminders?fh_event_id=${this.ev.fh_event_id}`);
      this.reminders = data.reminders || {};
    } catch (_err) {
      this.reminders = null;
    }
    this._render();
  }

  // FH Texter (mig 667/673) — admins only; anyone else (403) just opens
  // their own texting app.
  async _loadRelay() {
    try {
      const st = await this._json('/api/phone-relay/status');
      this.relay = { device: (st.devices || [])[0] || null, today: st.today || 0, cap: st.cap || 0 };
    } catch (_err) {
      this.relay = null;
    }
    this._render();
  }

  // A 💬 reminder goes from the owner's phone when FH Texter can take it
  // (paired, online, under the day's cap) — Game Center's rule for an RSVP
  // reminder (_textRoute; never the club number, which is for opted-in game
  // links).  Otherwise the texting app opens with the message.
  _relayUsable() {
    const r = this.relay;
    return !!(r && r.device && r.device.online && r.today < r.cap);
  }

  // One text per parent through FH Texter; a refusal (offline, cap, STOP)
  // opens that text in the texting app instead, so nothing is lost.
  async _sendViaRelay(personId, sends) {
    for (const send of sends) {
      if (!send.sms_href) continue;
      const { to, body } = DesktopSms.parse(send.sms_href);
      let ok = false;
      try {
        await this._json('/api/phone-relay/texts', {
          method: 'POST',
          body: JSON.stringify({ to: to[0] || '', body, for_person_id: personId,
                                 purpose: `remind:event:${this.ev.fh_event_id}`, magic_link_token_id: send.token_id || 0 }),
        });
        ok = true;
        if (this.relay) this.relay.today += 1;
      } catch (err) {
        this.remindNote[personId] = (window.MessageCopy && MessageCopy.block('event_center', 'relay_fell_back', { error: err.message }))
          || `FH Texter could not send (${err.message}) — opened in your texting app`;
      }
      if (!ok) DesktopSms.open(send.sms_href);
    }
  }

  // ── No Response reminders (mig 739) ─────────────────────────────────
  // Owner 2026-10-26: "whenever a player shows as no response we need easy
  // buttons to remind for that specific event and others. but that event
  // should be highlite".  The row's two pairs are the personal reminder
  // #rsvps and Game Center send — "This one" for this event alone, "All
  // open" for the player's whole week with this event named first; either
  // way the link opens the roll call on this event, highlighted.  One
  // message per parent (openSends), wording from message_templates.
  async _remind(btn) {
    const personId = Number(btn.dataset.personId);
    const channel = btn.dataset.ecRemind === 'email' ? 'email' : 'sms';
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    delete this.remindNote[personId];
    try {
      const data = await this._json('/api/rsvp-board/remind', {
        method: 'POST',
        body: JSON.stringify({ person_id: personId, channel, fh_event_id: this.ev.fh_event_id, only: btn.dataset.only === '1' }),
      });
      if (channel === 'sms' && this._relayUsable() && window.DesktopSms) await this._sendViaRelay(personId, data.sends || [data]);
      else this.openSends(data, channel);
      await this._loadReminders();
    } catch (err) {
      this.remindNote[personId] = err.message;
      btn.textContent = original;
      btn.disabled = false;
      this._render();
    }
  }

  // 📣 One group message to every player still unanswered on this event —
  // the group reminder Game Center's bar sends, named for this event.
  // Carriers cap a group text around 10, so a bigger group is split into
  // parts (parents of one kid never share a part, mig 682).
  async _remindAll(btn) {
    const channel = btn.dataset.ecRemindAll === 'email' ? 'email' : 'sms';
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const data = await this._json('/api/rsvp-board/remind-event', {
        method: 'POST',
        body: JSON.stringify({ fh_event_id: this.ev.fh_event_id, scope: 'event', channel, role: 'player' }),
      });
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        this.groupNote = this.escapeHtml(`✉ Email drafted to ${contacts.length} (BCC)${skipped}`);
      } else {
        const CHUNK_SIZE = 10;
        const chunks = Screen.chunkContacts(contacts, data.kids, CHUNK_SIZE);
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        if (chunks.length === 1) {
          (window.DesktopSms ? DesktopSms.open(hrefs[0]) : (window.location.href = hrefs[0]));
          this.groupNote = this.escapeHtml(`💬 Group text drafted to ${contacts.length}${skipped}`);
        } else {
          this.groupNote = `Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a href="${this.escapeHtml(h)}" class="ec-send" style="background:#38bdf8; text-decoration:none;">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ')
            + this.escapeHtml(skipped);
        }
      }
      await this._loadReminders();
    } catch (err) {
      this.groupNote = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
      btn.textContent = original;
      btn.disabled = false;
      this._render();
    }
  }

  // "reminded Mon 6:40 PM ×2" — the newest send on either channel this week.
  _remindedNote(personId) {
    const r = this.reminders && this.reminders[String(personId)];
    if (!r) return '';
    const sends = [r.sms, r.email].filter(Boolean);
    if (!sends.length) return '';
    const latest = sends.reduce((a, b) => (String(a.sent_at) > String(b.sent_at) ? a : b));
    const count = sends.reduce((n, x) => n + (x.count || 0), 0);
    const d = new Date(latest.sent_at);
    const time = isNaN(d) ? '' : `${d.toLocaleDateString('en-US', { weekday: 'short' })} ${d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' })}`;
    const fill = (window.MessageCopy && MessageCopy.block('event_center', 'reminded', { time, count: count > 1 ? String(count) : '' }));
    return fill || `reminded ${time}${count > 1 ? ` ×${count}` : ''}`;
  }

  // The row's buttons: This one 💬 ✉ · All open 💬 ✉, then the sent note.
  _remindRowHtml(r) {
    const name = r.name || [r.first_name, r.last_name].filter(Boolean).join(' ') || '';
    const cp = (tier, tokens) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || '';
    const sentAny = !!this._remindedNote(r.person_id);
    const btn = (channel, only) => `<button type="button" class="ec-send" data-ec-remind="${channel}" data-only="${only ? 1 : 0}"
        data-person-id="${r.person_id}" title="${this.escapeHtml(cp(only ? 'remind_this_title' : 'remind_all_title', { name }) || '')}"
        style="background:${only ? '#fbbf24' : '#38bdf8'};${sentAny ? ' opacity:0.55;' : ''}">${channel === 'sms' ? '💬' : '✉'}</button>`;
    const label = (tier, fb) => `<span style="font-size:0.7rem; font-weight:800; opacity:0.75;">${this.escapeHtml(cp(tier) || fb)}</span>`;
    const err = this.remindNote[r.person_id];
    const note = err ? `<span style="color:#f87171;">${this.escapeHtml(err)}</span>` : this.escapeHtml(this._remindedNote(r.person_id));
    return `<div style="flex-basis:100%; display:flex; gap:6px; align-items:center; flex-wrap:wrap; padding:2px 0 4px;">
      ${label('remind_this', 'This one')} ${btn('sms', true)} ${btn('email', true)}
      <span style="width:6px;"></span>
      ${label('remind_all', 'All open')} ${btn('sms', false)} ${btn('email', false)}
      <span style="font-size:0.72rem; opacity:0.8;">${note}</span>
    </div>`;
  }

  async _loadAttendance() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/attendance`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.att = { canMark: !!body.can_mark, canSetRsvp: !!body.can_set_rsvp,
                   roster: new Map((body.roster || []).map(r => [r.person_id, r])) };
    } catch (err) {
      console.error('[event-center] attendance load failed:', err);
      this.att = { canMark: false, canSetRsvp: false, roster: new Map() };
    }
    this._render();
  }

  async _loadPlan() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/session-plan`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.plan = body.practice || null;
    } catch (err) {
      console.error('[event-center] session plan load failed:', err);
      this.plan = null;
    }
    this._render();
  }

  // Cone setups (mig 559, owner 2026-10-09): the layout this session uses,
  // the default unless a coach picks another for it.
  async _loadCones() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/cone-setup`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.cones = body;
    } catch (err) { console.error('[event-center] cone setup load failed:', err); this.cones = null; }
    this._render();
  }
  async _pickCones(value) {
    const id = this.ev.fh_event_id;
    try {
      this.cones = await this._json(`/api/calendar/events/${id}/cone-setup`, { method: 'POST', body: JSON.stringify({ cone_setup_id: value ? Number(value) : null }) });
    } catch (err) { alert(`Could not save: ${err.message}`); }
    this._render();
  }
  // The cones of a setup: every cone_spacing_yd along each rectangle's
  // edges, corners once.  Pure geometry from the rows — nothing stored per cone.
  static coneDots(setup) {
    const sp = Number(setup.cone_spacing_yd) || 5, seen = new Set(), dots = [];
    const add = (x, y) => { const k = `${x.toFixed(2)},${y.toFixed(2)}`; if (!seen.has(k)) { seen.add(k); dots.push([x, y]); } };
    for (const a of (setup.areas || [])) {
      const x0 = Number(a.x), y0 = Number(a.y), w = Number(a.w), h = Number(a.h);
      for (let d = 0; d <= w + 1e-9; d += sp) { add(x0 + d, y0); add(x0 + d, y0 + h); }
      for (let d = 0; d <= h + 1e-9; d += sp) { add(x0, y0 + d); add(x0 + w, y0 + d); }
    }
    return dots;
  }
  // The drawing: the part of the pitch in use (goal line at the bottom),
  // its boxes, and a dot per cone.  1 yard = 6 px.
  static coneSvg(setup) {
    const W = Number(setup.area_width_yd), L = Number(setup.area_length_yd), k = 6, pad = 18;
    const esc = (t) => String(t == null ? '' : t).replace(/[&<>"]/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]));
    const dots = EventCenterScreen.coneDots(setup);
    const goalAtBottom = setup.area_anchor !== 'top';
    const half = setup.area_anchor !== 'full';
    const gw = 8 * k, gx = (W * k - gw) / 2, pa = 18 * k, pw = 44 * k, px = (W * k - pw) / 2, ga = 6 * k, gaw = 20 * k, gax = (W * k - gaw) / 2;
    const box = (w, d) => `<rect x="${(W * k - w) / 2}" y="${goalAtBottom ? L * k - d : 0}" width="${w}" height="${d}" fill="none" stroke="#9ca3af" stroke-width="1" stroke-dasharray="3 3"/>`;
    return `<svg viewBox="${-pad} ${-pad} ${W * k + 2 * pad} ${L * k + 2 * pad}" style="width:100%; max-width:560px; display:block; background:#14532d; border-radius:8px;" xmlns="http://www.w3.org/2000/svg">
      <rect x="0" y="0" width="${W * k}" height="${L * k}" fill="#166534" stroke="#e5e7eb" stroke-width="1.5"/>
      ${box(pw, pa)}${box(gaw, ga)}
      <rect x="${gx}" y="${goalAtBottom ? L * k : -3}" width="${gw}" height="3" fill="#e5e7eb"/>
      ${half ? `<line x1="0" y1="${goalAtBottom ? 0 : L * k}" x2="${W * k}" y2="${goalAtBottom ? 0 : L * k}" stroke="#e5e7eb" stroke-width="1" stroke-dasharray="6 4"/><circle cx="${W * k / 2}" cy="${goalAtBottom ? 0 : L * k}" r="${10 * k}" fill="none" stroke="#9ca3af" stroke-width="1" stroke-dasharray="3 3"/>` : ''}
      ${(setup.areas || []).map(a => `<rect x="${Number(a.x) * k}" y="${Number(a.y) * k}" width="${Number(a.w) * k}" height="${Number(a.h) * k}" fill="rgba(251,191,36,0.10)" stroke="#fbbf24" stroke-width="1"/>
        <text x="${(Number(a.x) + Number(a.w) / 2) * k}" y="${(Number(a.y) + Number(a.h) / 2) * k}" fill="#fde68a" font-size="11" text-anchor="middle" dominant-baseline="middle" opacity="0.9">${esc(a.label)} · ${esc(Number(a.w))}×${esc(Number(a.h))}</text>`).join('')}
      ${dots.map(([x, y]) => `<circle cx="${x * k}" cy="${y * k}" r="3.2" fill="#f97316" stroke="#7c2d12" stroke-width="0.8"/>`).join('')}
      <text x="${W * k / 2}" y="${goalAtBottom ? L * k + 13 : -6}" fill="#e5e7eb" font-size="9" text-anchor="middle" opacity="0.7">${esc(W)} yd</text>
      <text x="${-6}" y="${L * k / 2}" fill="#e5e7eb" font-size="9" text-anchor="middle" transform="rotate(-90 -6 ${L * k / 2})" opacity="0.7">${esc(L)} yd</text>
    </svg>`;
  }
  _conesHtml() {
    if (this.cones === undefined) return `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    const c = this.cones;
    const copy = (tier, tokens) => window.MessageCopy ? MessageCopy.block('cone_setup', tier, tokens) : '';
    if (!c || !c.setup) return `<div class="ec-box" style="opacity:0.7;">No cone setups are defined yet.</div>`;
    const s = c.setup, dots = EventCenterScreen.coneDots(s);
    const areaWord = copy(`area_${s.area_anchor}`, { length: s.area_length_yd, width: s.area_width_yd }) || `${s.area_anchor} ${s.area_length_yd} × ${s.area_width_yd} yd`;
    const picker = c.can_edit ? `
      <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px;">
        <span style="font-size:0.8rem; opacity:0.8;">${this.escapeHtml(copy('choose') || 'Cone setup for this practice')}</span>
        <select data-ec-cones style="font-size:0.85rem; padding:4px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary);">
          ${(c.setups || []).map(x => `<option value="${x.id}" ${x.id === s.id ? 'selected' : ''}>${this.escapeHtml(x.name)}${x.is_default ? ` (${this.escapeHtml(copy('default_tag') || 'default')})` : ''}</option>`).join('')}
        </select>
      </div>` : '';
    return `<div class="ec-box">
      ${picker}
      <div style="font-weight:700;">${this.escapeHtml(s.name)}${s.is_default ? ` <span style="font-size:0.7rem; opacity:0.6; font-weight:400;">· ${this.escapeHtml(copy('default_tag') || 'default')}</span>` : ''}</div>
      ${s.description ? `<div style="font-size:0.82rem; opacity:0.8; margin:2px 0 8px;">${this.escapeHtml(s.description)}</div>` : ''}
      ${c.chosen_id == null ? `<div style="font-size:0.76rem; opacity:0.65; margin-bottom:6px;">${this.escapeHtml(copy('using_default') || 'Using the default setup.')}</div>` : ''}
      ${EventCenterScreen.coneSvg(s)}
      <div style="font-size:0.8rem; opacity:0.8; margin-top:6px;">${this.escapeHtml(copy('summary', { cones: dots.length, boxes: (s.areas || []).length, spacing: s.cone_spacing_yd, area: areaWord }) || `${dots.length} cones · ${(s.areas || []).length} boxes · every ${s.cone_spacing_yd} yd · ${areaWord}`)}</div>
    </div>`;
  }

  async _loadSides() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/sides`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.sides = { canEdit: !!body.can_edit, colors: body.colors || [], players: body.players || [] };
      // In play: whatever is already used; a fresh event starts with the
      // first two colours.
      const used = new Set(this.sides.players.map(p => p.squad_color).filter(Boolean));
      if (!this.sideColors) {
        this.sideColors = used.size ? used : new Set(this.sides.colors.slice(0, 2).map(c => c.code));
      } else {
        used.forEach(c => this.sideColors.add(c));
      }
    } catch (err) {
      console.error('[event-center] sides load failed:', err);
      this.sides = { canEdit: false, colors: [], players: [], failed: true };
    }
    this._render();
  }

  // Tap a colour to put the player on it; tap their current colour to take
  // them off.
  async _setSide(personId, color) {
    const key = `side:${personId}`;
    if (this.saving.has(key)) return;
    const player = this.sides.players.find(p => p.person_id === personId);
    if (!player) return;
    const next = player.squad_color === color ? null : color;
    this.saving.add(key);
    this._render();
    try {
      await this._json(`/api/calendar/events/${this.ev.fh_event_id}/sides`, {
        method: 'POST',
        body: JSON.stringify({ person_id: personId, squad_color: next }),
      });
      player.squad_color = next;
    } catch (err) {
      console.error('[event-center] side save failed:', err);
      alert(`Could not save: ${err.message}`);
    } finally {
      this.saving.delete(key);
    }
    this._render();
  }

  async _loadInvites() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/invites`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.invites = { invites: body.invites || [], candidates: body.candidates || [] };
    } catch (err) {
      console.error('[event-center] invites load failed:', err);
      this.invites = { error: err.message || 'Could not load invites' };
    }
    this._render();
  }

  // Tap a status to set it; tap the active one to clear it.
  async _markAttendance(personId, status, active) {
    const key = `att:${personId}`;
    if (!this.att || this.saving.has(key)) return;
    const id = this.ev.fh_event_id;
    const prev = this.att.roster.get(personId) || null;
    this.saving.add(key);
    if (active) this.att.roster.delete(personId);
    else this.att.roster.set(personId, { person_id: personId, status });
    this._render();
    try {
      await this._json(`/api/calendar/events/${id}/attendance`, {
        method: active ? 'DELETE' : 'POST',
        body: JSON.stringify(active ? { person_id: personId } : { person_id: personId, status }),
      });
    } catch (err) {
      console.error('[event-center] attendance save failed:', err);
      if (prev) this.att.roster.set(personId, prev); else this.att.roster.delete(personId);
      alert(`Could not save attendance: ${err.message}`);
    } finally {
      this.saving.delete(key);
      this._render();
    }
  }

  // POST the invite, then hand the coach the compose (sms: / Gmail) or put
  // the message on the clipboard.  The wording is the server's.
  async _sendInvite(personId, channel, contact) {
    const key = `inv:${personId}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    this._render();
    try {
      const data = await this._json(`/api/calendar/events/${this.ev.fh_event_id}/invites`, {
        method: 'POST',
        body: JSON.stringify({ person_id: personId, channel, contact }),
      });
      if ((channel === 'email' && data.gmail_href) || (channel === 'sms' && data.sms_href)) {
        this.openSends(data, channel);   // one per parent (mig 682)
      } else if (data.url) {
        try {
          await navigator.clipboard.writeText(data.sms_body || data.url);
          this.copied.add(personId);
        } catch {
          window.prompt('Copy this invite message:', data.sms_body || data.url);
        }
      }
    } catch (err) {
      console.error('[event-center] invite failed:', err);
      alert(`Invite failed: ${err.message}`);
    } finally {
      this.saving.delete(key);
    }
    await Promise.all([this._loadInvites(), this._loadEvent(this.ev.fh_event_id)]);
  }

  async _revokeInvite(personId) {
    const key = `inv:${personId}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    this._render();
    try {
      await this._json(`/api/calendar/events/${this.ev.fh_event_id}/invites/${personId}`, { method: 'DELETE' });
    } catch (err) {
      console.error('[event-center] revoke failed:', err);
      alert(`Could not withdraw invite: ${err.message}`);
    } finally {
      this.saving.delete(key);
    }
    await Promise.all([this._loadInvites(), this._loadEvent(this.ev.fh_event_id)]);
  }

  // ── events ──────────────────────────────────────────────────────────
  _wire() {
    // A fold opened or closed by the coach stays that way (toggle does not
    // bubble — listen in the capture phase).
    this.element.addEventListener('toggle', (e) => {
      const d = e.target.closest && e.target.closest('[data-ec-fold]');
      if (d) this.folds.set(d.dataset.ecFold, d.open);
    }, true);
    // The date input: pick any day directly.
    this.element.addEventListener('change', (e) => { const sel = e.target.closest('[data-ec-cones]'); if (sel) this._pickCones(sel.value); });
    this.element.addEventListener('change', (e) => {
      const el = e.target.closest('[data-ec-date]');
      if (el && el.value) this._setWhen('date', el.value);
    });
    this.element.addEventListener('change', (e) => {
      const cpBehalf = e.target.closest('[data-gc-cp-behalf]');
      if (cpBehalf) this.carpoolPanel.behalf(cpBehalf.value);
    });
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const t = (sel) => e.target.closest(sel);
      let el;
      if ((el = t('[data-event-kind]'))) {
        const kind = el.dataset.eventKind;
        // Games are Game Center's; the other kinds just refilter this list.
        if (kind === 'match' || this.ev) EventKindSwitch.go(this.navigation, kind);
        else { this.kind = kind; this._render(); }
        return;
      }
      if ((el = t('[data-ec-category]'))) { this.category = el.dataset.ecCategory; this._render(); return; }
      if ((el = t('[data-ec-when]')))     { this._setWhen(el.dataset.ecWhen); return; }
      if ((el = t('[data-ec-open]'))) {
        const ev = (this.events || []).find(x => x.fh_event_id === Number(el.dataset.ecOpen));
        // A goTo, so Back returns to the list.  A linked game opens in
        // Game Center — Event Center's page for games.
        if (ev && ev.kind === 'match' && ev.match_id != null) {
          this.navigation.goTo('game-center', { matchId: ev.match_id, title: EventLabels.title(ev), when: this._when(ev) });
        } else if (ev) this.navigation.goTo('event-center', { event: ev });
        return;
      }
      if ((el = t('[data-ec-pill]'))) {
        this.pill = el.dataset.ecPill;
        if (this.pill === 'invites' && !this.invites) this._loadInvites();
        if (this.pill === 'sides' && !this.sides) this._loadSides();
        if (this.pill === 'plan' && this.plan === undefined) this._loadPlan();
        if (this.pill === 'cones' && this.cones === undefined) this._loadCones();
        this._render();
        return;
      }
      if ((el = t('[data-ec-game-center]'))) {
        this.navigation.goTo('game-center', {
          matchId: this.ev.match_id,
          title: EventLabels.title(this.ev),
          when: this._when(this.ev),
        });
        return;
      }
      if ((el = t('[data-ec-att]'))) {
        this._markAttendance(Number(el.dataset.personId), el.dataset.ecAtt, el.dataset.active === '1');
        return;
      }
      if ((el = t('[data-ec-practice-plan]'))) { this.navigation.goTo('practice-plan', {}); return; }
      if ((el = t('[data-ec-remind]')))     { this._remind(el); return; }
      if ((el = t('[data-ec-rsvp]')))       { this._setRsvp(Number(el.dataset.personId), el.dataset.ecRsvp, el.dataset.active === '1'); return; }
      if ((el = t('[data-ec-remind-all]'))) { this._remindAll(el); return; }
      if ((el = t('[data-ec-side]'))) { this._setSide(Number(el.dataset.personId), el.dataset.ecSide); return; }
      if ((el = t('[data-ec-side-color]'))) {
        const code = el.dataset.ecSideColor;
        if (this.sideColors.has(code)) this.sideColors.delete(code); else this.sideColors.add(code);
        this._render();
        return;
      }
      if ((el = t('[data-ec-invite]'))) {
        this._sendInvite(Number(el.dataset.personId), el.dataset.ecInvite, (el.dataset.contact || '').trim());
        return;
      }
      if ((el = t('[data-ec-revoke]'))) { this._revokeInvite(Number(el.dataset.ecRevoke)); return; }
      if ((el = t('[data-gc-cp]'))) { this.carpoolPanel.click(el, this.element); return; }
    });
  }

  // ── render ──────────────────────────────────────────────────────────
  _when(ev) {
    return [EventLabels.dateStr(ev.starts_at), EventLabels.timeStr(ev.starts_at)].filter(Boolean).join(' · ');
  }

  _isPast(ev) {
    const end = new Date(ev.ends_at || ev.starts_at);
    return !isNaN(end.getTime()) && end.getTime() < Date.now();
  }

  _render() {
    const body = this.find('#ec-body');
    const title = this.find('#ec-title');
    const sub = this.find('#ec-sub');
    if (!body) return;
    const kinds = this.find('#ec-kinds');
    if (kinds) {
      const k = this.ev ? (['match', 'practice', 'pickup'].includes(this.ev.kind) ? this.ev.kind : 'all') : this.kind;
      kinds.innerHTML = EventKindSwitch.html(EventKindSwitch.KINDS.includes(k) ? k : 'all', (t) => this.escapeHtml(t));
    }
    if (this.ev) {
      title.textContent = `📋 ${EventLabels.title(this.ev)}`;
      sub.textContent = [this._when(this.ev), this.ev.location].filter(Boolean).join(' · ');
      body.innerHTML = this._eventHtml();
      return;
    }
    title.textContent = EventKindSwitch.title();
    sub.textContent = (window.MessageCopy && MessageCopy.block('event_center', 'list_sub'))
      || 'Pick a day, then the practice or pickup — who\'s coming, attendance, groups, invites';
    if (this.error)   { body.innerHTML = `<div class="empty-state" style="text-align:center; opacity:0.8;">${this.escapeHtml(this.error)}</div>`; return; }
    if (!this.events || this.loadingId) { body.innerHTML = `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`; return; }
    body.innerHTML = this._pickerHtml();
  }

  _pickerHtml() {
    const kindOf = (ev) => (['match', 'practice', 'pickup'].includes(ev.kind) ? ev.kind : 'other');
    const cats = [...new Set(this.events.map(ev => ev.category).filter(Boolean))];
    const catLabel = (c) => EventCenterScreen.CATEGORY_LABELS[c] || c;
    const chip = (attr, value, label, on) =>
      `<button type="button" class="ec-chip ${on ? 'on' : ''}" ${attr}="${this.escapeHtml(value)}">${this.escapeHtml(label)}</button>`;

    const shown = this.events.filter(ev =>
      (this.kind === 'all' || kindOf(ev) === this.kind) &&
      (this.category === 'all' || ev.category === this.category));
    const byStart = (a, b) => String(a.starts_at).localeCompare(String(b.starts_at));
    const listed = shown.sort(byStart);
    const dateValue = this.when === 'date' && this.date ? this.date : this._ymd(this._range().start);

    const row = (ev) => {
      const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
      // Eligible yeses only — a yes from over the dues line is counted apart (migration 416).
      const going = rsvps.filter(r => r && r.response === 'yes' && !r.is_coach && r.dues_eligible !== false).length;
      const ineligible = rsvps.filter(r => r && r.response === 'yes' && !r.is_coach && r.dues_eligible === false).length;
      const teams = (Array.isArray(ev.teams) ? ev.teams : []).map(t => t && t.name).filter(Boolean).join(' + ');
      return `<button type="button" class="btn btn-secondary ec-pick" data-ec-open="${ev.fh_event_id}">
        <span style="font-weight:700;">${this.escapeHtml(EventLabels.title(ev))}</span>
        <span style="font-size:0.8rem; opacity:0.8;">${this.escapeHtml([this._when(ev), ev.location].filter(Boolean).join(' · '))}</span>
        <span style="font-size:0.75rem; opacity:0.65;">${this.escapeHtml([teams, `${going} going`, ineligible ? `⛔ ${ineligible} ineligible` : ''].filter(Boolean).join(' · '))}</span>
      </button>`;
    };
    const list = (label, evs, empty) => `
      <div class="ec-h" style="margin:var(--space-3) 0 var(--space-1);">${label} (${evs.length})</div>
      ${evs.length
        ? `<div style="display:flex; flex-direction:column; gap:8px;">${evs.map(row).join('')}</div>`
        : `<div style="font-size:0.85rem; opacity:0.6;">${empty}</div>`}`;

    return `
      ${cats.length > 1 ? `<div style="display:flex; gap:var(--space-1); flex-wrap:wrap; margin-bottom:var(--space-2);">
        ${chip('data-ec-category', 'all', 'All', this.category === 'all')}
        ${cats.map(c => chip('data-ec-category', c, catLabel(c), this.category === c)).join('')}
      </div>` : ''}
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2);">
        ${EventCenterScreen.WHEN_PILLS.map(([k, label]) => chip('data-ec-when', k, label, this.when === k)).join('')}
        <input type="date" class="ec-chip ${this.when === 'date' ? 'on' : ''}" data-ec-date value="${dateValue}"
               aria-label="Go to a day" style="font-family:inherit;">
      </div>
      ${list(this._rangeLabel(), listed, 'Nothing on the calendar for these days.')}`;
  }

  _eventHtml() {
    const ev = this.ev;
    const canMark = !!(this.att && this.att.canMark);
    const pills = [['coming', "Who's Coming & Attendance"]];
    // Sides for a pickup, groups for a practice — a game's squad and
    // starters are Game Center's.
    if (ev.kind === 'pickup')   pills.push(['sides', '🎽 Teams']);
    if (ev.kind === 'practice') pills.push(['sides', '🎽 Groups']);
    if (ev.kind === 'practice' || ev.kind === 'pickup') pills.push(['plan', '📝 Session Plan']);
    // Cone setups (mig 559): the field layout for this session.
    if (ev.kind === 'practice' || ev.kind === 'pickup') pills.push(['cones', (window.MessageCopy && MessageCopy.block('cone_setup', 'pill')) || '🔶 Cones']);
    // Invites are for an event still to come, by whoever may mark it.
    if (canMark && !this._isPast(ev)) pills.push(['invites', '🎟 Invites']);
    if (!pills.some(([k]) => k === this.pill)) this.pill = 'coming';

    return `
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-3);">
        ${pills.map(([k, label]) =>
          `<button type="button" class="ec-chip ${this.pill === k ? 'on' : ''}" data-ec-pill="${k}">${label}</button>`).join('')}
        <span style="flex:1;"></span>
        ${ev.kind === 'match' && ev.match_id != null
          ? `<button type="button" class="btn btn-secondary" data-ec-game-center style="padding:4px 12px; font-size:0.85rem;">🏟️ Game Center</button>` : ''}
      </div>
      ${this.att && !canMark ? `<div style="font-size:0.8rem; opacity:0.7; margin-bottom:var(--space-2);">
        Read-only — attendance and invites are for this event's coaches and club admins.</div>` : ''}
      ${this.pill === 'invites' ? this._invitesHtml()
        : this.pill === 'sides' ? this._sidesHtml()
        : this.pill === 'plan' ? this._planHtml()
        : this.pill === 'cones' ? this._conesHtml() : this._comingHtml()}
      ${this.cpError ? `<div style="font-size:0.75rem; color:#f59e0b; margin-top:6px;">${this.escapeHtml(this.cpError)}</div>` : ''}
      ${this.pill === 'coming' && (ev.kind === 'practice' || ev.kind === 'pickup') ? this.carpoolPanel.html() : ''}`;
  }

  // The practice plan attached to this event, read-only — sessions in order,
  // each with its exercises.  Editing stays on #practice-plan.
  _planHtml() {
    if (this.plan === undefined) return `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    const canMark = !!(this.att && this.att.canMark);
    const editBtn = canMark
      ? `<button type="button" class="btn btn-secondary" data-ec-practice-plan style="padding:4px 12px; font-size:0.85rem;">📋 Practice Plans</button>` : '';
    if (!this.plan) {
      return `<div class="ec-box" style="display:flex; justify-content:space-between; align-items:center; gap:8px; flex-wrap:wrap;">
        <span style="opacity:0.7;">No session plan is attached to this event.</span>${editBtn}</div>`;
    }
    const para = (label, text) => text
      ? `<div style="font-size:0.82rem; margin-top:4px; white-space:pre-wrap;"><b>${label}:</b> ${this.escapeHtml(text)}</div>` : '';
    const sessions = this.plan.sessions || [];
    return `
      ${this.plan.notes ? `<div class="ec-box" style="white-space:pre-wrap;">${this.escapeHtml(this.plan.notes)}</div>` : ''}
      ${sessions.map(s => `<div class="ec-box">
        <div style="display:flex; justify-content:space-between; align-items:baseline; gap:8px;">
          <span class="ec-h">${this.escapeHtml(s.title || 'Session')}</span>
          <span style="font-size:0.78rem; opacity:0.7;">${this.escapeHtml(s.start_time)} – ${this.escapeHtml(s.end_time)}</span>
        </div>
        ${s.notes ? `<div style="font-size:0.85rem; opacity:0.85; white-space:pre-wrap;">${this.escapeHtml(s.notes)}</div>` : ''}
        ${(s.exercises || []).map(x => `<div style="padding:6px 0; border-top:1px solid var(--border-color); margin-top:6px;">
            <div style="font-weight:700; font-size:0.92rem;">${this.escapeHtml(x.title)}${x.player_count ? ` <span style="font-weight:400; opacity:0.6; font-size:0.78rem;">· ${x.player_count} players</span>` : ''}</div>
            ${x.description ? `<div style="font-size:0.82rem; opacity:0.85; white-space:pre-wrap;">${this.escapeHtml(x.description)}</div>` : ''}
            ${para('Setup', x.setup)}${para('Coaching points', x.coaching_points)}${para('Notes', x.notes)}
          </div>`).join('') || `<div style="font-size:0.82rem; opacity:0.55;">No exercises yet.</div>`}
      </div>`).join('')}
      ${editBtn ? `<div style="text-align:right;">${editBtn}</div>` : ''}`;
  }

  // Pickup sides / practice groups by bib colour.  Top: each colour and who
  // is on it.  Below, for whoever may edit: the roster, people who are
  // coming first, with one swatch per colour in play.
  _sidesHtml() {
    if (!this.sides) return `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`;
    if (this.sides.failed) return `<div class="ec-box" style="opacity:0.7;">Could not load.</div>`;
    const { canEdit, colors, players } = this.sides;
    const word = this.ev.kind === 'pickup' ? 'team' : 'group';
    const nameOf = (p) => [p.first_name, p.last_name].filter(Boolean).join(' ') || 'Unknown';
    const swatch = (c, size = 14) => `<span style="display:inline-block; width:${size}px; height:${size}px; border-radius:50%;
      background:${c.hex}; border:1px solid var(--border-color); vertical-align:middle;"></span>`;

    const onSide = colors
      .map(c => [c, players.filter(p => p.squad_color === c.code)])
      .filter(([, list]) => list.length);
    const summary = onSide.length
      ? onSide.map(([c, list]) => `<div class="ec-box">
          <div class="ec-h">${swatch(c)} ${this.escapeHtml(c.label)} (${list.length})</div>
          <div style="font-size:0.9rem; margin-top:4px;">${list.map(p => this.escapeHtml(nameOf(p))).join(' · ')}</div>
        </div>`).join('')
      : `<div class="ec-box" style="opacity:0.7;">Nobody is on a ${word} yet.</div>`;
    if (!canEdit) return summary;

    const inPlay = colors.filter(c => this.sideColors.has(c.code));
    const row = (p) => {
      const saving = this.saving.has(`side:${p.person_id}`);
      return `<div class="ec-row">
        <span>${this.escapeHtml(nameOf(p))}</span>
        <span style="display:inline-flex; gap:6px;">${inPlay.map(c => {
          const active = p.squad_color === c.code;
          return `<button type="button" class="ec-att" data-ec-side="${c.code}" data-person-id="${p.person_id}"
                    ${saving ? 'disabled' : ''} title="${this.escapeHtml(c.label)}${active ? ' — tap to clear' : ''}"
                    style="background:${c.hex}; border:${active ? '3px solid var(--primary-color)' : '1px solid var(--border-color)'};
                           opacity:${active || !p.squad_color ? 1 : 0.35};"></button>`;
        }).join('')}</span>
      </div>`;
    };
    const group = (label, list) => list.length
      ? `<div class="ec-box"><div class="ec-h">${label} (${list.length})</div>${list.map(row).join('')}</div>` : '';
    return `
      ${summary}
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin:var(--space-3) 0 var(--space-2);">
        <span class="ec-h">Colours in play</span>
        ${colors.map(c => `<button type="button" class="ec-chip ${this.sideColors.has(c.code) ? 'on' : ''}"
            data-ec-side-color="${c.code}">${swatch(c, 10)} ${this.escapeHtml(c.label)}</button>`).join('')}
      </div>
      ${group('Going', players.filter(p => !p.is_coach && p.rsvp === 'yes'))}
      ${group('No response', players.filter(p => !p.is_coach && p.rsvp !== 'yes' && p.rsvp !== 'no'))}
      ${group('Not going', players.filter(p => !p.is_coach && p.rsvp === 'no'))}
      ${players.some(p => p.is_coach) ? `<div class="ec-box" style="border-style:dashed; opacity:0.85;"><span class="ec-h">Coaches — not on a side</span>
        <div class="ec-row"><span>${players.filter(p => p.is_coach).map(p => this.escapeHtml([p.first_name, p.last_name].filter(Boolean).join(' '))).join(', ')}</span></div></div>` : ''}`;
  }

  _attendanceCell(personId) {
    if (!this.att) return '<span style="opacity:0.35;">…</span>';
    const entry = this.att.roster.get(personId);
    const status = entry && entry.status;
    if (!this.att.canMark) {
      const meta = EventCenterScreen.ATTENDANCE.find(s => s.id === status);
      return meta
        ? `<span class="ec-badge" style="background:${meta.color};" title="${meta.label}">${meta.letter}</span>`
        : `<span style="opacity:0.4;" title="Not marked">—</span>`;
    }
    const saving = this.saving.has(`att:${personId}`);
    return `<span style="display:inline-flex; gap:4px;">${EventCenterScreen.ATTENDANCE.map(s => {
      const active = status === s.id;
      return `<button type="button" class="ec-att" data-ec-att="${s.id}" data-person-id="${personId}"
                data-active="${active ? '1' : '0'}" ${saving ? 'disabled' : ''}
                title="${active ? `${s.label} — tap to clear` : s.label}"
                style="border:1px solid ${s.color}; background:${active ? s.color : 'transparent'};
                       color:${active ? '#fff' : s.color};">${s.letter}</button>`;
    }).join('')}</span>`;
  }

  // Who's Coming, laid out like Game Center's RSVP sections (owner
  // 2026-10-26: "i like the rsvp situaiton in game center and want that for
  // practice"): one card per player, Going first, then Not going and No
  // response as folds that stay as the coach left them.  A card carries
  // everything a coach does to that player here — the RSVP override (club
  // admins, can_set_rsvp), the group swatches (practice groups / pickup
  // teams take the place of a game's starters and bench), attendance
  // P/A/L/E, and on No response the reminder buttons.  Coaches sit in
  // their own box, never in a player count (owner 2026-10-06).
  _comingHtml() {
    const rsvps = Array.isArray(this.ev.rsvps) ? this.ev.rsvps : [];
    const nameOf = (r) => r.name || [r.first_name, r.last_name].filter(Boolean).join(' ') || 'Unknown';
    const present = (list) => list.filter(r => {
      const e = this.att && this.att.roster.get(r.person_id);
      return e && (e.status === 'present' || e.status === 'late');
    }).length;
    const chipHtml = (r) => r.is_callup
      ? `<span title="Invited${r.callup_from ? ' from ' + this.escapeHtml(r.callup_from) : ''}"
               style="margin-left:6px; padding:0 6px; border-radius:999px; background:rgba(245,158,11,0.18);
                      border:1px solid rgba(245,158,11,0.55); color:#fcd34d; font-size:0.62rem; font-weight:800;">🎟 INVITED</span>`
      : (r.is_coach ? `<span style="margin-left:6px; font-size:0.68rem; opacity:0.6;">coach</span>` : '');
    if (!rsvps.length) {
      return `<div class="ec-box" style="opacity:0.7;">Nobody is on this event's list — tag a team on the calendar event.</div>`;
    }
    const open = !this._isPast(this.ev);
    // remind: No Response cards carry the reminder buttons for whoever may
    // mark the event (the send itself is club admins only, server-side),
    // and only while it can still be answered.
    const canRemind = !!(this.att && this.att.canMark) && open;
    const canSet = !!(this.att && this.att.canSetRsvp) && open;
    const hasSides = this.ev.kind === 'practice' || this.ev.kind === 'pickup';
    const sideOf = (pid) => {
      const p = this.sides && !this.sides.failed && this.sides.players.find(x => x.person_id === pid);
      return p ? p.squad_color : null;
    };
    const colorOf = (code) => (this.sides && this.sides.colors.find(c => c.code === code)) || null;
    const swatch = (c, size = 14) => `<span style="display:inline-block; width:${size}px; height:${size}px; border-radius:50%;
      background:${c.hex}; border:1px solid var(--border-color); vertical-align:middle;"></span>`;

    // ✓ / ✗ — tap the lit one to clear the answer (DELETE /rsvp).
    const rsvpBtns = (r) => {
      if (!canSet) return '';
      const busy = this.saving.has(`rsvp:${r.person_id}`);
      const b = (resp, label, color) => {
        const on = r.response === resp;
        return `<button type="button" class="ec-att" data-ec-rsvp="${resp}" data-person-id="${r.person_id}" data-active="${on ? 1 : 0}"
                  ${busy ? 'disabled' : ''} title="${on ? 'Tap to clear their answer' : (resp === 'yes' ? 'Set Going' : 'Set Not going')}"
                  style="border:1px solid ${color}; background:${on ? color : 'transparent'}; color:${on ? '#fff' : color};">${label}</button>`;
      };
      return `<span style="display:inline-flex; gap:4px;">${b('yes', '✓', '#22c55e')}${b('no', '✗', '#ef4444')}</span>`;
    };
    // Group swatches: the colours in play, for whoever may edit sides.
    const sideBtns = (r) => {
      if (!hasSides || !this.sides || this.sides.failed) return '';
      const mine = sideOf(r.person_id);
      if (!this.sides.canEdit) {
        const c = mine && colorOf(mine);
        return c ? `<span title="${this.escapeHtml(c.label)}">${swatch(c)}</span>` : '';
      }
      const saving = this.saving.has(`side:${r.person_id}`);
      return `<span style="display:inline-flex; gap:5px;">${this.sides.colors.filter(c => this.sideColors && this.sideColors.has(c.code)).map(c => {
        const active = mine === c.code;
        return `<button type="button" class="ec-att" data-ec-side="${c.code}" data-person-id="${r.person_id}"
                  ${saving ? 'disabled' : ''} title="${this.escapeHtml(c.label)}${active ? ' — tap to clear' : ''}"
                  style="background:${c.hex}; border:${active ? '3px solid var(--primary-color)' : '1px solid var(--border-color)'};
                         opacity:${active || !mine ? 1 : 0.35};"></button>`;
      }).join('')}</span>`;
    };
    const card = (r, { remind = false, sides = false } = {}) => {
      const err = this.rsvpNote[r.person_id];
      return `<div class="ec-card" data-person-row="${r.person_id}">
        <div style="display:flex; justify-content:space-between; align-items:center; gap:6px;">
          <span style="font-weight:700; min-width:0; overflow:hidden; text-overflow:ellipsis;">${this.escapeHtml(nameOf(r))}${chipHtml(r)}</span>
          ${rsvpBtns(r)}
        </div>
        <div style="display:flex; justify-content:space-between; align-items:center; gap:6px; margin-top:6px; flex-wrap:wrap;">
          ${sides ? sideBtns(r) : '<span></span>'}
          ${this._attendanceCell(r.person_id)}
        </div>
        ${err ? `<div style="font-size:0.72rem; color:#f87171; margin-top:4px;">${this.escapeHtml(err)}</div>` : ''}
        ${remind && canRemind ? this._remindRowHtml(r) : ''}
      </div>`;
    };
    const grid = (list, opts) => `<div class="ec-grid">${list.map(r => card(r, opts)).join('')}</div>`;
    const head = (label, list) => `<div style="display:flex; justify-content:space-between; align-items:baseline; margin:var(--space-3) 0 6px;">
        <span class="ec-h">${label} (${list.length})</span>
        ${this.att ? `<span style="font-size:0.78rem; color:#22c55e; font-weight:700;">${present(list)} present</span>` : ''}
      </div>`;
    const section = (label, list, opts = {}) => list.length ? head(label, list) + (opts.top || '') + grid(list, opts) : '';
    // Folds keep their open/closed state across the 15s refresh and a
    // reminder's re-render (as Game Center's do).
    const fold = (key, label, list, opts = {}) => {
      if (!list.length) return '';
      const isOpen = this.folds.has(key) ? this.folds.get(key) : !!opts.defaultOpen;
      return `<details data-ec-fold="${key}" ${isOpen ? 'open' : ''} style="margin:var(--space-3) 0;">
        <summary style="cursor:pointer;" class="ec-h">${label} (${list.length})${this.att ? ` · <span style="color:#22c55e;">${present(list)} present</span>` : ''}</summary>
        ${opts.top || ''}${grid(list, opts)}
      </details>`;
    };

    // A yes from someone over the dues line (dues_eligible=false,
    // migration 416) is kept but counted apart from Going.
    const coaches  = rsvps.filter(r => r && r.is_coach);
    const players  = rsvps.filter(r => r && !r.is_coach);
    const goingAll = players.filter(r => r.response === 'yes');
    const going    = goingAll.filter(r => r.dues_eligible !== false);
    const noResp   = players.filter(r => r.response !== 'yes' && r.response !== 'no');
    const cp = (tier, tokens) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || '';
    const L = (tier, fb) => this.escapeHtml(cp(tier) || fb);

    // Groups in play + who is on each, over the Going cards (the 🎽 pill
    // keeps the full editor).
    let groupsTop = '';
    if (hasSides && this.sides && !this.sides.failed) {
      const onSide = this.sides.colors.map(c => [c, going.filter(r => sideOf(r.person_id) === c.code)]).filter(([, l]) => l.length);
      const chooser = this.sides.canEdit ? `<div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:6px;">
          <span style="font-size:0.72rem; font-weight:800; opacity:0.75;">${this.escapeHtml(cp(this.ev.kind === 'pickup' ? 'teams_in_play' : 'groups_in_play') || (this.ev.kind === 'pickup' ? 'Teams' : 'Groups'))}</span>
          ${this.sides.colors.map(c => `<button type="button" class="ec-chip ${this.sideColors && this.sideColors.has(c.code) ? 'on' : ''}"
              data-ec-side-color="${c.code}">${swatch(c, 10)} ${this.escapeHtml(c.label)}</button>`).join('')}
        </div>` : '';
      const summary = onSide.length ? `<div style="display:flex; gap:10px; flex-wrap:wrap; font-size:0.78rem; margin-bottom:6px;">
          ${onSide.map(([c, l]) => `<span>${swatch(c, 10)} <b>${this.escapeHtml(c.label)}</b> ${l.length}</span>`).join('')}
          <span style="opacity:0.6;">${going.length - onSide.reduce((n, [, l]) => n + l.length, 0)} unassigned</span>
        </div>` : '';
      groupsTop = chooser + summary;
    }
    const remindBar = canRemind && noResp.length ? `<div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin:0 0 6px;">
        <span style="font-size:0.78rem; font-weight:700;">${this.escapeHtml(cp('remind_group', { n: noResp.length }) || `📣 Remind all ${noResp.length} who haven't answered`)}</span>
        <button type="button" class="ec-send" data-ec-remind-all="sms" style="background:#38bdf8;">💬</button>
        <button type="button" class="ec-send" data-ec-remind-all="email" style="background:#38bdf8;">✉</button>
        ${this.groupNote ? `<span style="font-size:0.72rem; flex-basis:100%;">${this.groupNote}</span>` : ''}
        <span style="font-size:0.7rem; opacity:0.7; flex-basis:100%;">${this.escapeHtml(this._relayUsable()
          ? (cp('text_via_relay', { device: this.relay.device.name || 'FH Texter', today: this.relay.today, cap: this.relay.cap })
             || `💬 on a card texts from ${this.relay.device.name || 'FH Texter'} (${this.relay.today}/${this.relay.cap} today)`)
          : (cp('text_via_app') || '💬 on a card opens your texting app'))}</span>
      </div>` : '';

    const coachBox = () => {
      if (!coaches.length) return '';
      const part = (label, list) => list.length
        ? `<div class="ec-row"><span><b>${label}</b> ${list.map(r => this.escapeHtml(nameOf(r))).join(', ')}</span><span style="opacity:0.7;">${list.length}</span></div>` : '';
      return `<div class="ec-box" style="border-style:dashed; margin-top:var(--space-3);">
        <div style="display:flex; justify-content:space-between; align-items:baseline;">
          <span class="ec-h">Coaches (${coaches.length}) — not in the player counts</span>
          ${this.att ? `<span style="font-size:0.78rem; color:#22c55e; font-weight:700;">${present(coaches)} present</span>` : ''}
        </div>
        ${part('✓ Going', coaches.filter(r => r.response === 'yes'))}
        ${part('✗ Not going', coaches.filter(r => r.response === 'no'))}
        ${part('? No response', coaches.filter(r => r.response !== 'yes' && r.response !== 'no'))}
        ${this.att ? coaches.map(r => `<div class="ec-row"><span>${this.escapeHtml(nameOf(r))}</span>${this._attendanceCell(r.person_id)}</div>`).join('') : ''}
      </div>`;
    };
    return `
      ${going.length ? section(L('sec_going', '✓ Going'), going.filter(r => !r.is_callup), { sides: true, top: groupsTop }) : ''}
      ${section(L('sec_invited', '🎟 Invited · Available'), going.filter(r => r.is_callup), { sides: true })}
      ${section(L('sec_ineligible', '⛔ Said going · Ineligible (dues)'), goingAll.filter(r => r.dues_eligible === false))}
      ${fold('noresponse', L('sec_noresp', '– No response'), noResp, { remind: true, top: remindBar, defaultOpen: true })}
      ${fold('notgoing', L('sec_notgoing', '✗ Not going'), players.filter(r => r.response === 'no'))}
      ${coachBox()}`;
  }

  // Open invites with their answer and a withdraw, then everyone who COULD
  // be invited — youth club-pass call-ups, or the section's other squads —
  // grouped by the squad they come from (fh_event_invites, migration 355).
  _invitesHtml() {
    const data = this.invites;
    if (!data) return `<div class="ec-box" style="opacity:0.6;">Loading…</div>`;
    if (data.error) return `<div class="ec-box" style="color:#fca5a5;">${this.escapeHtml(data.error)}</div>`;
    const nm = (r) => `${r.first_name || ''} ${r.last_name || ''}`.trim() || 'Unknown';
    const answers = { yes: ['Available', '#22c55e'], no: ['Not available', '#f87171'], maybe: ['Maybe', '#fbbf24'] };
    const answerChip = (resp) => {
      const [label, color] = answers[resp] || ['No response', 'inherit'];
      return `<span style="font-size:0.72rem; font-weight:700; color:${color}; ${answers[resp] ? '' : 'opacity:0.5;'}">${label}</span>`;
    };
    const sendBtns = (r, resend) => {
      const busy = this.saving.has(`inv:${r.person_id}`);
      const verb = resend ? 'Re-send' : 'Invite by';
      const btn = (channel, contact, icon, bg, title) =>
        `<button type="button" class="ec-send" data-ec-invite="${channel}" data-person-id="${r.person_id}"
                 data-contact="${this.escapeHtml(contact || '')}" ${busy ? 'disabled' : ''}
                 title="${this.escapeHtml(title)}" style="background:${bg};">${icon}</button>`;
      const dim = (icon, why) => `<span style="opacity:0.35;" title="${why}">${icon}</span>`;
      return `<span style="display:inline-flex; align-items:center; gap:5px;">
        ${r.phone ? btn('sms', r.phone, '💬', '#38bdf8', `${verb} text (${r.phone})`) : dim('💬', 'No SMS on file')}
        ${r.email ? btn('email', r.email, '📧', '#a78bfa', `${verb} email (${r.email})`) : dim('📧', 'No email on file')}
        ${btn('copy', '', '🔗', '#fcd34d', resend ? 'Copy a fresh sign-in link' : 'Invite and copy the sign-in link')}
        ${this.copied.has(r.person_id) ? `<span style="font-size:0.7rem; color:#fcd34d;">✓ copied</span>` : ''}
      </span>`;
    };

    const invited = data.invites.map(r => `<div class="ec-row">
        <span>${this.escapeHtml(nm(r))}${r.from_team ? `<span style="font-size:0.72rem; opacity:0.6;"> · ${this.escapeHtml(r.from_team)}</span>` : ''}</span>
        <span style="display:inline-flex; align-items:center; gap:8px;">
          ${answerChip(r.response)}
          ${sendBtns(r, true)}
          <button type="button" data-ec-revoke="${r.person_id}" ${this.saving.has(`inv:${r.person_id}`) ? 'disabled' : ''}
                  title="Withdraw this invite — the event disappears for them again"
                  style="font-size:0.72rem; font-weight:700; color:#fca5a5; background:transparent;
                         border:1px solid rgba(248,113,113,0.5); padding:2px 8px; border-radius:999px; cursor:pointer;">✕</button>
        </span>
      </div>`).join('');

    const byTeam = new Map();
    for (const c of data.candidates) {
      const k = c.from_team || 'Other';
      if (!byTeam.has(k)) byTeam.set(k, []);
      byTeam.get(k).push(c);
    }
    const candidates = [...byTeam.entries()].map(([team, list]) => `
      <div class="ec-h" style="margin-top:var(--space-2); opacity:0.55;">${this.escapeHtml(team)} (${list.length})</div>
      ${list.map(c => `<div class="ec-row">
          <span>${this.escapeHtml(nm(c))}${c.single_age ? `<span style="font-size:0.72rem; opacity:0.6;"> · U${this.escapeHtml(String(c.single_age))}</span>` : ''}</span>
          ${sendBtns(c, false)}
        </div>`).join('')}`).join('');

    return `
      <div style="font-size:0.8rem; opacity:0.75; margin-bottom:var(--space-2);">
        An invited player (or their parent) sees this event on their page, gets a Go/No, and shows up under
        Who's Coming. Nobody else outside the squad can see it.
      </div>
      <div class="ec-box">
        <div class="ec-h">Invited (${data.invites.length})</div>
        ${data.invites.length ? invited : `<div style="font-size:0.85rem; opacity:0.55;">Nobody yet.</div>`}
      </div>
      <div class="ec-box">
        <div class="ec-h">Can be invited (${data.candidates.length})</div>
        ${data.candidates.length ? candidates
          : `<div style="font-size:0.85rem; opacity:0.55;">Nobody eligible — everyone age-eligible in the program is rostered or already invited.</div>`}
      </div>`;
  }
}

window.EventCenterScreen = EventCenterScreen;
