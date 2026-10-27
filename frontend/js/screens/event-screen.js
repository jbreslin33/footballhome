// EventScreen — the base class of every opened calendar event (owner
// 2026-10-27: "same behaviour for practice and game except where we have to
// differ … base class is event … then game or practice child").
//
//   EventScreen         #event      any event: header + type pills, the big
//   │                               pill row (lib/event-pills.js), 👥 All
//   │                               Players — RSVP cards, ✓/✗ override,
//   │                               attendance P/A/L/E, reminders (FH Texter
//   │                               or the texting app), 🎟 Invites, 🚗
//   │                               carpool — and the 15 s live refresh
//   ├── PracticeScreen  #practice   + 🎽 Groups / Teams and 📝 Practice Plan
//   │                               (🔶 Cones inside)       screens/practice.js
//   └── GameCenterScreen #game-center  its own four-pill row, lineup,
//                                   posts, opponent contacts — keeps its
//                                   own player cards until they fold in
//                                                      screens/game-center.js
//
// The week calendar that opens them is screens/event-center.js; it routes a
// tap by kind through EventKindSwitch.open.
//
// Doors (params):
//   { event: ev }    an event object from GET /api/calendar/upcoming
//   { fhEventId: n } just the id — read from GET /api/calendar/events/:id
//
// Tools: GET|POST|DELETE /api/calendar/events/:id/attendance,
// GET|POST /api/calendar/events/:id/invites  DELETE …/invites/:personId,
// POST|DELETE /api/calendar/rsvp (admin override), /api/rsvp-board/remind*.
// Who may mark or invite is decided per event by the backend (can_mark —
// CalendarController::isEventCoachOrAdmin); without it the page is
// read-only.  Invite and reminder messages are built server-side from
// message_templates.
class EventScreen extends Screen {
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
    this.ev       = null;      // the open event
    this.pill     = 'players'; // the lit big pill — players (+ invites), and whatever the kind adds
    this.att      = null;      // {canMark, roster: Map(person_id -> {status})}
    this.invites  = null;      // {invites, candidates} | {error}
    this.saving   = new Set(); // "att:<pid>" / "inv:<pid>" in flight
    this.copied   = new Set(); // person_ids whose invite link was copied
    this.error    = null;
    // 🚗 Carpool — the same shared CarpoolPanel component Game Center
    // mounts for games (migs 601/608/609).
    this.carpoolPanel = new CarpoolPanel(this.auth, {
      fhEventId: () => (this.ev ? this.ev.fh_event_id : null),
      rerender: () => this._render(),
      toast: (m) => { this.cpError = m; this._render(); setTimeout(() => { this.cpError = null; this._render(); }, 4000); },
      escapeHtml: (t) => this.escapeHtml(t),
    });
    this.cpError  = null;
    this.rsvpNote = {};        // person_id → last override error, on their card
    this.remindNote = {};      // person_id → last reminder error, on their card
    this.remindOk = {};        // person_id → "📱 Sent from …" after an FH Texter send
    this.relay = null;         // FH Texter {device, today, cap} — admins only
    this.groupNote = '';       // the 📣 bar's result line (html)
    this.folds    = new Map(); // 'noresponse' / 'notgoing' → open?  (kept across refreshes)
  }

  // ── what a kind adds (children override) ──────────────────────────
  // The big pill row: [{ key, icon, title, accent }].  Any event has its
  // players; a child adds its own moments.  Titles are DB copy (mig 751).
  pills(_ev) {
    const cp = (tier, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier)) || fb;
    return [{ key: 'players', icon: '👥', title: cp('pill_players', 'All Players'), accent: '#3b82f6' }];
  }

  // The body under a lit pill.  🎟 Invites ride inside All Players.
  pillHtml(key) {
    const section = (label, html) => `<div class="ec-h" style="margin:var(--space-4) 0 var(--space-2);">${label}</div>${html}`;
    if (key !== 'players') return '';
    return this._comingHtml() + (this._canInvite() ? section('🎟 Invites', this._invitesHtml()) : '')
      + (this.hasCarpool() ? this.carpoolPanel.html() : '');
  }

  // A pill was tapped — fetch what it shows the first time.
  onPill(key) {
    if (key === 'players' && this._canInvite() && !this.invites) this._loadInvites();
  }

  // The event is in hand — the kind's own first loads.
  onEventLoaded() {}

  // A click the base did not handle (the target finder, the event).
  onClick(_t, _e) { return false; }

  // Carpool on practices and pickup (owner 2026-10-19); a game mounts its own.
  hasCarpool() { return !!this.ev && (this.ev.kind === 'practice' || this.ev.kind === 'pickup'); }

  // A player card's middle row, left of attendance (a practice's group
  // swatches), and the strip over the Going cards (its groups in play).
  _cardSideHtml(_r) { return '<span></span>'; }
  _goingTopHtml(_going) { return ''; }

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
    if (document.hidden || !this.ev || this.pill !== 'players' || this._pollBusy) return;
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
      // The phone's report on a reminder still on its way (or a link not
      // opened yet) arrives on the same beat.
      if (this.reminders) {
        const before = JSON.stringify(this.reminders);
        const data = await this._json(`/api/rsvp-board/reminders?fh_event_id=${id}`);
        if (this.ev && this.ev.fh_event_id === id && JSON.stringify(data.reminders || {}) !== before) {
          this.reminders = data.reminders || {};
          this._render();
        }
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
      </style>
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ec-title">📋 Event</h1>
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
    this.ev = params.event || null;
    this.loadingId = (!this.ev && params.fhEventId) ? Number(params.fhEventId) : null;
    this.pill = 'players';
    this.att = null;
    this.invites = null;
    this.reminders = null;    // person_id → {sms, email, total} — who was reminded this week (mig 739)
    this.remindNote = {};     // person_id → last send error, shown on their row
    this.groupNote = '';      // the 📣 bar's result line (html)
    this.error = null;
    this.rsvpNote = {};
    this.remindOk = {};
    this.saving.clear();
    this.copied.clear();
    this.resetKind();
    this._render();
    const loadAll = () => {
      if (!this.ev) return;
      this._loadAttendance();
      if (this.hasCarpool()) this.carpoolPanel.load().then(() => this._render());
      this._loadReminders();
      this._loadRelay();
      this.onEventLoaded();
    };
    if (this.ev) loadAll();
    else if (this.loadingId) this._loadEvent(this.loadingId).then(loadAll);
    this._startLivePoll();
  }

  // Per-visit state a child keeps (cleared on every enter).
  resetKind() {}

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

  // One event by id — the door for { fhEventId }, and the refresh after an
  // invite moves the RSVP list (the picker feed only spans three weeks).
  async _loadEvent(id) {
    try {
      const body = await this._json(`/api/calendar/events/${id}`);
      if (this.ev ? this.ev.fh_event_id === id : this.loadingId === id) this.ev = body.event;
    } catch (err) {
      console.error('[event] event load failed:', err);
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
    let sent = 0;
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
        sent += 1;
        if (this.relay) this.relay.today += 1;
      } catch (err) {
        this.remindNote[personId] = (window.MessageCopy && MessageCopy.block('event_center', 'relay_fell_back', { error: err.message }))
          || `FH Texter could not send (${err.message}) — opened in your texting app`;
      }
      if (!ok) DesktopSms.open(send.sms_href);
    }
    // No compose window opens on this route, so the card says it went —
    // without it a coach taps again and the player gets it twice (owner
    // 2026-10-26: "why is text for reminder not doing pop up").
    if (sent) {
      const device = (this.relay && this.relay.device && this.relay.device.name) || 'FH Texter';
      this.remindOk[personId] = (window.MessageCopy && MessageCopy.block('event_center', 'relay_sent', { device, n: String(sent) }))
        || `📱 Sent from ${device}${sent > 1 ? ` (${sent} texts)` : ''}`;
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
    // One send per card at a time — every button on the card waits.
    const key = `remind:${personId}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    btn.closest('[data-person-row]')?.querySelectorAll('[data-ec-remind]').forEach(b => { b.disabled = true; });
    btn.textContent = '⏳';
    delete this.remindNote[personId];
    delete this.remindOk[personId];
    try {
      const data = await this._json('/api/rsvp-board/remind', {
        method: 'POST',
        body: JSON.stringify({ person_id: personId, channel, fh_event_id: this.ev.fh_event_id, only: btn.dataset.only === '1' }),
      });
      if (channel === 'sms' && this._relayUsable() && window.DesktopSms) await this._sendViaRelay(personId, data.sends || [data]);
      else this.openSends(data, channel);
    } catch (err) {
      this.remindNote[personId] = err.message;
    }
    this.saving.delete(key);
    await this._loadReminders();   // repaints the card: buttons back, note shown
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

  // What the phone reported back for the newest FH Texter reminder (owner
  // 2026-10-26: "can it send back success?"): queued → sent → delivered,
  // or failed with why, then when the link in it was first opened.
  _relayStatusHtml(personId) {
    const t = this.reminders && this.reminders[String(personId)] && this.reminders[String(personId)].relay;
    if (!t) return '';
    const when = (iso) => {
      const x = new Date(iso);
      return isNaN(x) ? '' : x.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
    };
    const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || fb;
    const failed = t.status === 'failed';
    const text = failed ? cp('relay_failed', { error: t.error || '?' }, `📱 FAILED — ${t.error || '?'}`)
      : t.status === 'delivered' ? cp('relay_delivered', { time: when(t.at) }, `📱 delivered ${when(t.at)} ✓`)
      : t.status === 'sent' ? cp('relay_sent_at', { time: when(t.at) }, `📱 sent ${when(t.at)}, waiting for delivery…`)
      : cp('relay_queued', {}, '📱 queued on the phone…');
    const opened = t.opened_at ? ` · ${this.escapeHtml(cp('relay_opened', { time: when(t.opened_at) }, `opened ${when(t.opened_at)} 👀`))}` : '';
    return `<span style="font-weight:700; color:${failed ? '#ef4444' : t.status === 'delivered' ? '#22c55e' : '#fbbf24'};">${this.escapeHtml(text)}</span>${opened}`;
  }

  // The row's buttons: This one 💬 ✉ · All open 💬 ✉, then the sent note.
  _remindRowHtml(r) {
    const name = r.name || [r.first_name, r.last_name].filter(Boolean).join(' ') || '';
    const cp = (tier, tokens) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || '';
    const sentAny = !!this._remindedNote(r.person_id);
    const btn = (channel, only) => `<button type="button" class="ec-send" data-ec-remind="${channel}" data-only="${only ? 1 : 0}"
        data-person-id="${r.person_id}" ${busy ? 'disabled' : ''} title="${this.escapeHtml(cp(only ? 'remind_this_title' : 'remind_all_title', { name }) || '')}"
        style="background:${only ? '#fbbf24' : '#38bdf8'};${sentAny ? ' opacity:0.55;' : ''}">${channel === 'sms' ? '💬' : '✉'}</button>`;
    const label = (tier, fb) => `<span style="font-size:0.7rem; font-weight:800; opacity:0.75;">${this.escapeHtml(cp(tier) || fb)}</span>`;
    const err = this.remindNote[r.person_id];
    const busy = this.saving.has(`remind:${r.person_id}`);
    const relay = this._relayStatusHtml(r.person_id);
    const ok = this.remindOk[r.person_id];
    const reminded = this.escapeHtml(this._remindedNote(r.person_id));
    const note = err ? `<span style="color:#f87171;">${this.escapeHtml(err)}</span>`
      : relay ? [relay, reminded].filter(Boolean).join(' · ')
      : ok ? `<span style="color:#22c55e; font-weight:700;">${this.escapeHtml(ok)}</span>${reminded ? ' · ' + reminded : ''}`
      : reminded;
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
      // 🎟 Invites sit under All Players — load them with it.
      if (this.pill === 'players' && this._canInvite() && !this.invites) this._loadInvites();
    } catch (err) {
      console.error('[event] attendance load failed:', err);
      this.att = { canMark: false, canSetRsvp: false, roster: new Map() };
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
      console.error('[event] invites load failed:', err);
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
      console.error('[event] attendance save failed:', err);
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
      console.error('[event] invite failed:', err);
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
      console.error('[event] revoke failed:', err);
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
    this.element.addEventListener('change', (e) => {
      const cpBehalf = e.target.closest('[data-gc-cp-behalf]');
      if (cpBehalf) this.carpoolPanel.behalf(cpBehalf.value);
    });
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const t = (sel) => e.target.closest(sel);
      let el;
      if ((el = t('[data-event-kind]'))) { EventKindSwitch.go(this.navigation, el.dataset.eventKind); return; }
      if ((el = t('[data-ec-pill]'))) {
        this.pill = el.dataset.ecPill;
        this.onPill(this.pill);
        this._render();
        return;
      }
      if ((el = t('[data-ec-game-center]'))) { EventKindSwitch.open(this.navigation, this.ev); return; }
      if ((el = t('[data-ec-att]'))) {
        this._markAttendance(Number(el.dataset.personId), el.dataset.ecAtt, el.dataset.active === '1');
        return;
      }
      if ((el = t('[data-ec-remind]')))     { this._remind(el); return; }
      if ((el = t('[data-ec-rsvp]')))       { this._setRsvp(Number(el.dataset.personId), el.dataset.ecRsvp, el.dataset.active === '1'); return; }
      if ((el = t('[data-ec-remind-all]'))) { this._remindAll(el); return; }
      if ((el = t('[data-ec-invite]'))) {
        this._sendInvite(Number(el.dataset.personId), el.dataset.ecInvite, (el.dataset.contact || '').trim());
        return;
      }
      if ((el = t('[data-ec-revoke]'))) { this._revokeInvite(Number(el.dataset.ecRevoke)); return; }
      if ((el = t('[data-gc-cp]'))) { this.carpoolPanel.click(el, this.element); return; }
      this.onClick(t, e);
    });
  }

  // ── one player card ─────────────────────────────────────────────────
  // Every EventScreen draws its people the same way (owner 2026-10-27:
  // "same behaviour for practice and game except where we have to
  // differ"): a card with the name and its chips on the left, the quick
  // controls on the right, then the kind's own rows — a game's zone,
  // position and eligibility lines, a practice's groups and attendance —
  // in an auto-fill grid, under a section heading or inside a fold that
  // stays as the coach left it.  The kinds fill the slots; the shape is
  // here.
  static ensureCardStyles() {
    if (document.getElementById('ev-card-styles')) return;
    const st = document.createElement('style');
    st.id = 'ev-card-styles';
    st.textContent = `
      .ev-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(270px, 1fr)); gap:6px; }
      .ev-card { border:1px solid var(--border-color); border-radius:8px; background:var(--bg-secondary); overflow:hidden; min-width:0; font-size:0.9rem; }
      .ev-card-in { padding:7px 10px; }
      .ev-card-head { display:flex; align-items:center; justify-content:space-between; gap:8px; }
      .ev-card-name { display:flex; align-items:center; gap:6px; min-width:0; flex-wrap:wrap; font-weight:700; overflow-wrap:anywhere; }
      .ev-card-right { display:flex; align-items:center; gap:6px; flex-shrink:0; }
      .ev-sec { display:flex; justify-content:space-between; align-items:baseline; gap:8px; margin:var(--space-3) 0 6px;
                font-size:0.78rem; font-weight:800; letter-spacing:0.03em; text-transform:uppercase; }
      .ev-fold { margin:var(--space-3) 0; }
      .ev-fold > summary { cursor:pointer; font-size:0.78rem; font-weight:800; letter-spacing:0.03em; text-transform:uppercase; padding:4px 0; }
      .ev-none { padding:6px 2px; opacity:0.6; font-size:0.85em; }`;
    document.head.appendChild(st);
  }

  // One card.  name / right / body are html; banner sits over the card (a
  // game's registration-gap warning), cls styles the whole card, attrs
  // are extra attributes (data-person-row …).
  cardHtml({ id = '', name = '', right = '', body = '', banner = '', cls = '', attrs = '' } = {}) {
    EventScreen.ensureCardStyles();
    return `<div${id ? ` id="${id}"` : ''} class="ev-card ${cls}" ${attrs}>${banner}<div class="ev-card-in">
        <div class="ev-card-head"><span class="ev-card-name">${name}</span>${right ? `<span class="ev-card-right">${right}</span>` : ''}</div>
        ${body}
      </div></div>`;
  }

  cardGridHtml(cards, empty = 'None yet') {
    EventScreen.ensureCardStyles();
    return cards.length ? `<div class="ev-grid">${cards.join('')}</div>` : `<div class="ev-none">${empty}</div>`;
  }

  // A heading "Label (n)" with an aside on the right (a present count),
  // then whatever sits over the cards, then the cards.
  cardSectionHtml(label, n, grid, { aside = '', top = '' } = {}) {
    EventScreen.ensureCardStyles();
    return `<div class="ev-sec"><span>${label} (${n})</span>${aside ? `<span>${aside}</span>` : ''}</div>${top}${grid}`;
  }

  // The same, folded.  foldAttr/key name the fold so the screen can keep it
  // open across a refresh; open is whether it is open now.
  cardFoldHtml(foldAttr, key, open, label, n, grid, { aside = '', top = '' } = {}) {
    EventScreen.ensureCardStyles();
    return `<details class="ev-fold" ${foldAttr}="${key}" ${open ? 'open' : ''}>
        <summary>${label} (${n})${aside ? ` · ${aside}` : ''}</summary>
        ${n ? top : ''}${grid}
      </details>`;
  }

  // ── render ──────────────────────────────────────────────────────────
  _when(ev) { return EventLabels.when(ev); }
  _kindOf(ev) { return EventLabels.kindOf(ev); }
  _isPast(ev) { return EventLabels.isPast(ev); }

  // Invites are for an event still to come, by whoever may mark it.
  _canInvite() { return !!(this.att && this.att.canMark) && !this._isPast(this.ev); }

  _render() {
    const body = this.find('#ec-body');
    const title = this.find('#ec-title');
    const sub = this.find('#ec-sub');
    if (!body) return;
    const kinds = this.find('#ec-kinds');
    if (kinds) {
      const k = this.ev ? this._kindOf(this.ev) : 'all';
      kinds.innerHTML = EventKindSwitch.html(EventKindSwitch.KINDS.includes(k) ? k : 'all', (t) => this.escapeHtml(t));
    }
    if (this.error) { body.innerHTML = `<div class="empty-state" style="text-align:center; opacity:0.8;">${this.escapeHtml(this.error)}</div>`; return; }
    if (!this.ev) { body.innerHTML = `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`; return; }
    title.textContent = `📋 ${EventLabels.title(this.ev)}`;
    sub.textContent = [this._when(this.ev), this.ev.location].filter(Boolean).join(' · ');
    body.innerHTML = this._eventHtml();
  }

  // The big pill row (lib/event-pills.js — Game Center's row), then the
  // lit pill's body.
  _eventHtml() {
    const ev = this.ev;
    const canMark = !!(this.att && this.att.canMark);
    const pills = this.pills(ev);
    if (!pills.some(p => p.key === this.pill)) this.pill = 'players';
    return `
      ${pills.length > 1 ? EventPills.row(pills, this.pill, { attr: 'data-ec-pill', escapeHtml: (t) => this.escapeHtml(t), label: 'Event' }) : ''}
      ${ev.kind === 'match' && ev.match_id != null
        ? `<div style="text-align:right; margin-bottom:var(--space-2);"><button type="button" class="btn btn-secondary" data-ec-game-center style="padding:4px 12px; font-size:0.85rem;">🏟️ Game Center</button></div>` : ''}
      ${this.att && !canMark ? `<div style="font-size:0.8rem; opacity:0.7; margin-bottom:var(--space-2);">
        Read-only — attendance and invites are for this event's coaches and club admins.</div>` : ''}
      ${this.pillHtml(this.pill)}
      ${this.cpError ? `<div style="font-size:0.75rem; color:#f59e0b; margin-top:6px;">${this.escapeHtml(this.cpError)}</div>` : ''}`;
  }

  _attendanceCell(personId) {
    if (!this.att) return '<span style="opacity:0.35;">…</span>';
    const entry = this.att.roster.get(personId);
    const status = entry && entry.status;
    if (!this.att.canMark) {
      const meta = EventScreen.ATTENDANCE.find(s => s.id === status);
      return meta
        ? `<span class="ec-badge" style="background:${meta.color};" title="${meta.label}">${meta.letter}</span>`
        : `<span style="opacity:0.4;" title="Not marked">—</span>`;
    }
    const saving = this.saving.has(`att:${personId}`);
    return `<span style="display:inline-flex; gap:4px;">${EventScreen.ATTENDANCE.map(s => {
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
    const card = (r, { remind = false, sides = false } = {}) => {
      const err = this.rsvpNote[r.person_id];
      return this.cardHtml({
        attrs: `data-person-row="${r.person_id}"`,
        name: `<span style="min-width:0; overflow:hidden; text-overflow:ellipsis;">${this.escapeHtml(nameOf(r))}</span>${chipHtml(r)}`,
        right: rsvpBtns(r),
        body: `<div style="display:flex; justify-content:space-between; align-items:center; gap:6px; margin-top:6px; flex-wrap:wrap;">
            ${sides ? this._cardSideHtml(r) : '<span></span>'}
            ${this._attendanceCell(r.person_id)}
          </div>
          ${err ? `<div style="font-size:0.72rem; color:#f87171; margin-top:4px;">${this.escapeHtml(err)}</div>` : ''}
          ${remind && canRemind ? this._remindRowHtml(r) : ''}`,
      });
    };
    const grid = (list, opts) => this.cardGridHtml(list.map(r => card(r, opts)));
    const presentAside = (list) => this.att ? `<span style="color:#22c55e;">${present(list)} present</span>` : '';
    const section = (label, list, opts = {}) => list.length
      ? this.cardSectionHtml(label, list.length, grid(list, opts), { aside: presentAside(list), top: opts.top || '' }) : '';
    // Folds keep their open/closed state across the 15s refresh and a
    // reminder's re-render (as Game Center's do).
    const fold = (key, label, list, opts = {}) => {
      if (!list.length) return '';
      const isOpen = this.folds.has(key) ? this.folds.get(key) : !!opts.defaultOpen;
      return this.cardFoldHtml('data-ec-fold', key, isOpen, label, list.length, grid(list, opts), { aside: presentAside(list), top: opts.top || '' });
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

    // Over the Going cards: whatever the kind adds (a practice's groups).
    const groupsTop = this._goingTopHtml(going);
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

window.EventScreen = EventScreen;
