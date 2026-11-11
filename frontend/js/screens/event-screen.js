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
    this.coachGroupNote = '';  // the same, for the Coaches section's bar
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
    return this._comingHtml() + this._jobsHtml() + (this._canInvite() ? section('🎟 Invites', this._invitesHtml()) : '')
      + (this.hasCarpool() ? this.carpoolPanel.html() : '');
  }

  // A pill was tapped — fetch what it shows the first time.
  onPill(key) {
    if (key === 'players' && this._canInvite() && !this.invites) this._loadInvites();
  }

  // The event is in hand — the kind's own first loads.  A game opened here
  // (the #my staff door) still gets its ✉️ draft buttons.
  onEventLoaded() {
    if (this.ev.kind === 'match' && this.ev.match_id != null) this._loadGameDrafts();
  }

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
        // A late yes / no re-runs the job fill — show the new holders.
        if (this.jobs) this._loadJobs();
        this._loadStanding();
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
  // answer clears it.  Your own card answers as you (no person_id — the
  // same self write #my makes, so its eligibility rules apply).
  async _setRsvp(personId, response, active) {
    const key = `rsvp:${personId}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    delete this.rsvpNote[personId];
    this._render();
    const id = this.ev.fh_event_id;
    const self = !!(this.att && this.att.me && this.att.me === personId);   // a child goes with person_id (guardian write)
    const target = self ? {} : { person_id: personId };
    try {
      if (active) {
        await this._json('/api/calendar/rsvp', { method: 'DELETE', body: JSON.stringify({ fh_event_id: id, ...target }) });
      } else {
        const body = await this._json('/api/calendar/rsvp', { method: 'POST', body: JSON.stringify({ fh_event_id: id, ...target, response }) });
        if (self && body && body.sms_opt_in && window.SmsOptInAsk) SmsOptInAsk.show(body.sms_opt_in);   // 📲 mig 647
        if (self && body && body.reg_ask && window.RegAsk) RegAsk.show(body.reg_ask);                   // 📝 mig 725
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
    this.pill = params.pill || 'players';   // render() falls back when the kind has no such pill
    this.att = null;
    this.invites = null;
    this.callins = null;      // 🙋 call-in requests (mig 1265) — staff, games only
    this.reminders = null;    // person_id → {sms, email, total} — who was reminded this week (mig 739)
    this.remindNote = {};     // person_id → last send error, shown on their row
    this.groupNote = '';      // the 📣 bar's result line (html)
    this.coachGroupNote = '';
    this.oppContacts = null;  // this game's 📇 people, for its ✉️ drafts
    this.jobs = null;         // 🧹 /api/jobs/event body (staff only; mig 978) — null until loaded / when refused
    this._panelDrafts = [];
    this.error = null;
    this.rsvpNote = {};
    this.remindOk = {};
    this.saving.clear();
    this.resetKind();
    this._render();
    // The DB copy (pill titles, the contact sheet's wording) — cached
    // across screens; repaint once it lands.
    if (window.MessageCopy) MessageCopy.load(this.auth).then(() => this._render()).catch(() => {});
    // The section's registration / docs forms for the 📇 Contact popup.
    if (window.SectionContact) SectionContact.load(this.auth).then(() => this._render()).catch(() => {});
    const loadAll = () => {
      if (!this.ev) return;
      this._loadAttendance();
      if (this.hasCarpool()) this.carpoolPanel.load().then(() => this._render());
      this._loadReminders();
      this._loadRelay();
      this._loadTextMarks().then(() => this._render());
      this._loadJobs();
      this._loadStanding();
      this.onEventLoaded();
    };
    if (this.ev) { loadAll(); this.syncHash(); }
    else if (this.loadingId) this._loadEvent(this.loadingId).then(loadAll);
    this._startLivePoll();
    // Pull Google Calendar in the background (GcalRefresh, 11/3): the event
    // shows from the DB now and repaints only if the pull moved or renamed it.
    if (window.GcalRefresh) GcalRefresh.ping(this.auth, () => this._refreshFromGcal());
  }

  async _refreshFromGcal() {
    if (!this.ev || !this.ev.fh_event_id) return;
    const id = this.ev.fh_event_id;
    const body = await this._json(`/api/calendar/events/${id}`);
    if (!body.event || !this.ev || this.ev.fh_event_id !== id) return;
    const key = (e) => JSON.stringify([e.title, e.starts_at, e.ends_at, e.location, e.description, e.kind]);
    if (key(body.event) === key(this.ev)) return;
    this.ev = body.event;
    this._render();
  }

  // Per-visit state a child keeps (cleared on every enter).
  resetKind() {}

  // #event/<fh_event_id>/<pill> — one URL shape for every kind
  // (EventKindSwitch.hash).  Game Center lights its own pill set.
  syncHash() { EventKindSwitch.syncHash(this.navigation, this.ev, this.pill); }

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
      if (this.ev ? this.ev.fh_event_id === id : this.loadingId === id) { this.ev = body.event; this.syncHash(); }
    } catch (err) {
      console.error('[event] event load failed:', err);
      if (!this.ev) this.error = 'Could not load that event.';
    }
    this.loadingId = null;
    this._render();
  }

  // 👻 Last RSVP + dues standing on every card (PersonStanding, 11/3).
  _loadStanding() {
    if (!window.PersonStanding || !this.ev) return;
    const ids = (this.ev.rsvps || []).map(r => r.person_id);
    PersonStanding.load(this.auth, ids).then(() => this._render()).catch(() => {});
  }

  // 🧹 This event's jobs and who holds them — the #jobs board's own call,
  // which runs the auto-fill first.  Club admins and coaches only (the API
  // answers 403 otherwise); a refusal just leaves the section out.
  async _loadJobs() {
    if (!this.ev) return;
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/jobs/event/${id}`);
      if (this.ev && this.ev.fh_event_id === id) { this.jobs = body; this._render(); }
    } catch (_err) {
      if (this.ev && this.ev.fh_event_id === id) this.jobs = null;
    }
  }

  // One card per job: holders by name, open spots, a switched-off job
  // dimmed.  Editing (assign, flag, toggle) stays on #jobs.
  _jobsHtml() {
    const jobs = this.jobs && Array.isArray(this.jobs.jobs) ? this.jobs.jobs : [];
    if (!jobs.length) return '';
    const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || fb;
    const esc = (t) => this.escapeHtml(t);
    const live = jobs.filter(j => !j.off);
    const needed = live.reduce((n, j) => n + (j.needed || 0), 0);
    const filled = live.reduce((n, j) => n + Math.min((j.assignments || []).length, j.needed || 0), 0);
    const cards = jobs.map(j => {
      const held = j.assignments || [];
      const open = j.off ? 0 : Math.max(0, (j.needed || 0) - held.length);
      const rows = held.map(a => `<div style="font-size:0.85rem;">${esc(a.name)}${a.not_done
          ? ` <span style="color:#f87171; font-size:0.72rem;">⚠ ${esc(cp('jobs_not_done', {}, 'not done'))}</span>` : ''}</div>`)
        .concat(Array.from({ length: open }, () =>
          `<div style="font-size:0.85rem; opacity:0.5; font-style:italic;">${esc(cp('jobs_open_slot', {}, 'Open'))}</div>`))
        .join('');
      return this.cardHtml({
        name: esc(j.title),
        right: j.off ? '' : `<span style="font-size:0.75rem; opacity:0.75;">${held.length}/${j.needed}</span>`,
        body: `<div style="font-size:0.72rem; opacity:0.7; margin:2px 0 4px;">${esc(j.description || '')}</div>`
            + (j.off ? `<div style="font-size:0.8rem; opacity:0.7;">${esc(cp('jobs_off', {}, 'Off for this event'))}</div>` : rows),
        attrs: j.off ? 'style="opacity:0.55;"' : '',
      });
    });
    const aside = `<span style="font-size:0.78rem;">${esc(cp('jobs_filled', { filled: String(filled), needed: String(needed) }, `${filled} of ${needed} filled`))}</span>`;
    const top = `<div style="text-align:right; margin:0 0 6px;"><button type="button" class="btn btn-secondary" data-ec-jobs
        style="padding:4px 12px; font-size:0.8rem;">${esc(cp('jobs_edit', {}, '✏️ Edit on Jobs board'))}</button></div>`;
    return this.cardSectionHtml(esc(cp('sec_jobs', {}, '🧹 Jobs')), jobs.length, this.cardGridHtml(cards), { aside, top });
  }

  // The people on this game's 📇 panel, then the drafts going to them.
  async _loadGameDrafts() {
    try {
      const res = await this.auth.fetch(`/api/opponents/for-match/${this.ev.match_id}`);
      this.oppContacts = res.ok ? await res.json() : null;
    } catch (err) {
      this.oppContacts = null;
    }
    await this._loadPanelDrafts();
    this._render();
  }

  // This game's drafts going to anyone in this panel (mig 728) — each is one
  // big ✉️ button: one click = Gmail with message + everyone.  A draft saved
  // without a game shows on any game of its people.
  async _loadPanelDrafts() {
    const o = this.oppContacts || {};
    const ids = [...(((o.club || {}).contacts) || []), ...(((o.league || {}).contacts) || [])].map(c => c.id);
    this._panelDrafts = [];
    if (!ids.length) return;
    try {
      const res = await this.auth.fetch(`/api/contact-drafts?contact_ids=${ids.join(',')}`);
      const data = await res.json().catch(() => ({}));
      const game = Number(this.matchId || (this.ev && this.ev.match_id));
      this._panelDrafts = (res.ok ? (data.drafts || []) : []).filter(d => !d.match_id || d.match_id === game);
    } catch (err) { this._panelDrafts = []; }
  }

  // attr: the click attribute of the screen drawing them.
  _panelDraftButtons(attr) {
    const esc = (t) => this.escapeHtml(t);
    return (this._panelDrafts || []).map(d => {
      const to = (d.recipients || []).map(r => r.name || r.email).join(', ');
      const note = window.MessageCopy ? MessageCopy.block('contact_draft', d.subject ? 'big_button_note' : 'big_button_note_text', { to }) : to;
      return `
        <div style="margin:4px 0 10px;">
          <button class="btn btn-primary" ${attr}="${d.id}" style="width:100%; padding:10px 14px; font-size:0.95rem; font-weight:700;">${d.subject ? '✉️' : '💬'} ${esc(d.label || d.subject || 'Email')}</button>
          <div style="font-size:0.66rem; opacity:0.7; margin-top:3px; line-height:1.35;">${esc(note)}</div>
        </div>`;
    }).join('');
  }

  // Gmail opens inside the click (no popup block).  The button stays: a click
  // can't tell whether it was sent (owner 2026-10-30).
  _panelDraftOpen(id) {
    const d = (this._panelDrafts || []).find(x => x.id === id);
    if (!d) return;
    if (!d.subject) { this._panelDraftText(d); return; }
    const to = (d.recipients || []).map(r => r.email).filter(Boolean).join(',');
    this.openGmailCompose(this.buildGmailComposeHref({ to, subject: d.subject, body: d.body }));
  }

  // A draft with no subject is a text (mig 916): the phones come from the
  // panel's contacts.
  _panelDraftText(d) {
    const o = this.oppContacts || {};
    const people = [...(((o.club || {}).contacts) || []), ...(((o.league || {}).contacts) || [])];
    const to = (d.recipients || []).map(r => (people.find(p => p.id === r.id) || {}).phone).filter(Boolean).join(',');
    const href = this.buildSmsComposeHref({ to, body: d.body });
    if (!href) return;
    if (window.DesktopSms) DesktopSms.open(href); else window.location.href = href;
  }

  // 📇 The other club's people through the one ContactPopup (owner
  // 2026-11-07: "event center contact to work same as players. open the
  // contact dialog with the standard messages").  MESSAGE = the opponent
  // templates (message_templates kind opponent, the tiers for-match sends),
  // filled with this game; the words stay editable.  A send still logs a
  // club_contact_messages row (POST /api/opponents/message) so "Last text /
  // email" keeps working.  Game Center's 📇 panel draws the same button.
  _oppContactButton(k, opts = {}) {
    if (!window.ContactPopup || !(k.phone || k.email)) return '';
    const o = this.oppContacts || {};
    const club = (o.club && o.club.name) || o.opponent_text || '';
    const me = (this.auth && this.auth.getUser && this.auth.getUser()) || {};
    const tokens = {
      club, contact_first: String(k.name || '').split(/\s+/)[0] || 'there',
      our_team: o.our_team || '', date: o.date || 'our next game', time: o.time || 'kick-off',
      venue: o.venue || 'the field', home_away: o.is_home === false ? 'at' : 'vs',
      sender: me.name || [me.first_name, me.last_name].filter(Boolean).join(' ') || '',
      message: '',
    };
    const matchId = Number(o.match_id || (this.ev && this.ev.match_id) || this.matchId || 0);
    const messages = (o.tiers || []).map(t => {
      const r = window.MessageCopy && MessageCopy.render('opponent', t.tier, tokens);
      if (!r) return null;
      return {
        key: t.tier, label: t.label, subject: r.subject || '', body: r.body || '', noClub: true,
        onSent: (_res, via, words) => {
          if (via === 'copy') return;
          this.auth.fetch('/api/opponents/message', { method: 'POST', body: JSON.stringify({
            contact_id: k.id, channel: via === 'email' ? 'email' : 'sms', tier: t.tier,
            match_id: matchId || undefined, message: t.tier === 'custom' ? (words || ' ') : '' }) }).catch(() => {});
          k.last_sent_at = 'just now'; k.last_channel = via === 'email' ? 'email' : 'sms';
        },
      };
    }).filter(Boolean);
    if (!messages.length) return '';
    return ContactPopup.button({
      key: `opp:${matchId}:${k.id}`, screen: this,
      recipients: [{ personId: null, name: k.name || k.role || club, phone: k.phone || null, email: k.email || null }],
      messages, defaultKey: messages.some(m => m.key === 'confirm') ? 'confirm' : messages[0].key,
      title: `Contact ${k.name || club}`, big: !!opts.big,
    });
  }

  // Event Center's 📇 block for a game: the other club's contacts, then the
  // league directors for this age group — one popup button each.  Only the
  // game's coaches get for-match (403 otherwise → nothing drawn).
  _oppContactsHtml() {
    const o = this.oppContacts;
    if (!o || !window.ContactPopup) return '';
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens) => (window.MessageCopy && MessageCopy.block('opponent', tier, tokens)) || '';
    const row = (k) => `
      <div style="display:flex; align-items:center; gap:8px; padding:5px 0; border-top:1px solid var(--border-color); font-size:0.8rem;">
        <div style="flex:1; min-width:0;">
          <b>${esc(k.name || k.role || '')}</b>${k.name && k.role ? ` <span style="opacity:0.65;">· ${esc(k.role)}</span>` : ''}
          ${k.last_sent_at ? `<div style="font-size:0.66rem; opacity:0.6;">Last ${k.last_channel === 'sms' ? 'text' : 'email'} ${esc(k.last_sent_at)}</div>` : ''}
        </div>
        ${this._oppContactButton(k)}
      </div>`;
    const club = o.club, lg = o.league;
    const clubRows = ((club && club.contacts) || []).filter(k => k.phone || k.email);
    const lgRows = ((lg && lg.contacts) || []).filter(k => k.phone || k.email);
    if (!club && !lgRows.length) return '';
    const clubName = (club && club.name) || o.opponent_text || '';
    return `
      <div style="margin:0 0 var(--space-2); border:1px solid var(--border-color); border-radius:12px; padding:8px 12px;">
        <div style="font-size:0.75rem; font-weight:700; opacity:0.85; margin-bottom:2px;">${esc(copy('game_center_title', { club: clubName }) || `📇 Contact ${clubName}`)}</div>
        ${clubRows.map(row).join('') || `<div style="font-size:0.72rem; opacity:0.7;">${esc(club ? (copy('no_contacts') || 'No contact yet.') : (copy('game_center_none', { opponent: o.opponent_text || '?' }) || ''))}</div>`}
        ${lgRows.length ? `<div style="font-size:0.72rem; font-weight:700; opacity:0.8; margin-top:8px;">${esc(copy('game_center_league', { league: lg.name || lg.label }) || `🏛 ${lg.name || lg.label}`)}</div>${lgRows.map(row).join('')}` : ''}
      </div>`;
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

  // 📣 One group message to every player still unanswered on this event —
  // the group reminder Game Center's bar sends, named for this event.
  // The Coaches section has its own bar: same send, role 'coach'.
  // Carriers cap a group text around 10, so a bigger group is split into
  // parts (parents of one kid never share a part, mig 682).
  async _remindAll(btn) {
    const channel = btn.dataset.ecRemindAll === 'email' ? 'email' : 'sms';
    const role = btn.dataset.ecRemindRole === 'coach' ? 'coach' : 'player';
    const setNote = (html) => { if (role === 'coach') this.coachGroupNote = html; else this.groupNote = html; };
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const data = await this._json('/api/rsvp-board/remind-event', {
        method: 'POST',
        body: JSON.stringify({ fh_event_id: this.ev.fh_event_id, scope: 'event', channel, role }),
      });
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        setNote(this.escapeHtml(`✉ Email drafted to ${contacts.length} (BCC)${skipped}`));
      } else {
        const CHUNK_SIZE = 10;
        const chunks = Screen.chunkContacts(contacts, data.kids, CHUNK_SIZE);
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        if (chunks.length === 1) {
          (window.DesktopSms ? DesktopSms.open(hrefs[0]) : (window.location.href = hrefs[0]));
          setNote(this.escapeHtml(`💬 Group text drafted to ${contacts.length}${skipped}`));
        } else {
          setNote(`Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a href="${this.escapeHtml(h)}" class="ec-send" style="background:#38bdf8; text-decoration:none;">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ')
            + this.escapeHtml(skipped));
        }
      }
      await this._loadReminders();
    } catch (err) {
      setNote(`<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`);
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
  // One ✉ CONTACT button per card (Game Center's, mig 654): the
  // primary-channel badge, the button that opens the sheet (WHAT / HOW /
  // whether each way works), and one status line — what was sent and how
  // it went.  noResp: they have not answered an event still open, so the
  // sheet leads with the RSVP reminder.
  // The one 📇 Contact popup (owner 2026-11-03: "contact popup is all
  // inclusive"): this event's RSVP reminder first when they owe an answer,
  // then the section's list (components/section-contact.js) — the same
  // list #teams offers for Men's / Women's / Boys / Girls.  Recipients are
  // the card's own contact rows (every parent of a kid, mig 682).
  // inactive: a 💤 Inactive card (mig 1217, owner 2026-11-10: "it should
  // have that as option just like active players") — he owes no answer, so
  // no reminder; his RSVP link is the 🎟 invite, preselected, for a game or
  // a practice.
  _contactButtonHtml(r, st, noResp, inactive = false) {
    if (!window.ContactPopup || !window.SectionContact || !st) return '';
    const pid = r.person_id;
    const rows = Array.isArray(st.recipients) && st.recipients.length ? st.recipients : [st];
    const recipients = rows
      .map(x => ({ personId: x.recipient_person_id || pid, name: x.recipient_name || r.name || '',
                   phone: x.phone || null, email: x.email || null, forPersonId: pid }))
      .filter(x => x.phone || x.email);
    if (!recipients.length) return '';
    const first = r.first_name || String(r.name || '').split(' ')[0] || '';
    const parentRow = recipients.find(x => x.personId !== pid);
    const remind = noResp ? [{
      key: 'remind', label: this._cm('what_remind') || '📣 RSVP reminder', noClub: true,
      resolve: async (rc, channel) => {
        const data = await this._postReminder('/api/rsvp-board/remind', {
          person_id: pid, channel, fh_event_id: this.eventId() || 0, recipient_person_ids: [rc.personId] });
        const x = (data.sends && data.sends[0]) || data;
        const href = channel === 'email' ? x.gmail_href : x.sms_href;
        if (!href) throw new Error('No message came back');
        return { ...x, href };
      },
      onSent: () => this._loadReminders().then(() => this._render()),
    }] : [];
    const cand = inactive && this.invites && Array.isArray(this.invites.candidates)
      ? this.invites.candidates.find(c => Number(c.person_id) === Number(pid)) : null;
    const invite = cand && this.ev && this.ev.fh_event_id ? [SectionContact.callupMessage(this, this.ev.fh_event_id, pid, {
      practice: this.ev.kind !== 'match',
      onSent: () => Promise.all([this._loadInvites(), this._loadEvent(this.ev.fh_event_id)]),
    })] : [];
    return ContactPopup.button({
      key: `ec:${this.eventId()}:${pid}`, screen: this, recipients,
      messages: SectionContact.messages(this.ev && this.ev.category, {
        screen: this, playerId: pid, first,
        parentFirst: parentRow ? String(parentRow.name || '').split(' ')[0] : '',
        context: [...invite, ...remind],
      }),
      ...(invite.length ? { defaultKey: 'callup' } : {}),
      flagged: noResp,
      title: `Contact ${r.name || first}`,
    });
  }

  _contactLineHtml(r, noResp, inactive = false) {
    const pid = r.person_id;
    const st = (this.textMarks && this.textMarks.people && this.textMarks.people[String(pid)]) || null;
    const cb = (tier, tokens) => (window.MessageCopy && MessageCopy.block('contact_box', tier, tokens)) || '';
    const hasPhone = st ? !!st.phone : true;
    const consent = st ? st.consent : 'none';
    const badge = !hasPhone ? cb('badge_nophone') : consent === 'in' ? cb('badge_in')
                : consent === 'stopped' ? cb('badge_stopped') : cb('badge_none');
    this._contactCtx = this._contactCtx || {};
    this._contactCtx[pid] = { name: r.name || [r.first_name, r.last_name].filter(Boolean).join(' ') || '', noResp, gap: null, st };
    const err = this.remindNote[pid];
    const relay = this._relayStatusHtml(pid);
    const ok = this.remindOk[pid];
    const reminded = this.escapeHtml(this._remindedNote(pid));
    const reply = st && st.reply_body ? this.escapeHtml(cb('reply', { time: this._sentWhen(st.reply_at), body: st.reply_body })) : '';
    const status = [
      err ? `<span style="color:#f87171;">${this.escapeHtml(err)}</span>`
        : relay || (ok ? `<span style="color:#22c55e; font-weight:700;">${this.escapeHtml(ok)}</span>` : ''),
      reminded,
      reply ? `<span style="color:#38bdf8; font-weight:700;">${reply}</span>` : '',
    ].filter(Boolean).join(' · ');
    return `
      <div data-gc-contact style="margin-top:6px;">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:6px;">
          <span style="font-size:0.68rem; font-weight:800;">${this.escapeHtml(badge)}</span>
          ${this._contactButtonHtml(r, st, noResp, inactive)}
        </div>
        <div data-gc-squad-note style="font-size:0.66rem; opacity:0.85; min-height:1.3em; margin-top:3px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${status || '&nbsp;'}</div>
      </div>`;
  }

  async _loadAttendance() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/attendance`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.att = { canMark: !!body.can_mark, canSetRsvp: !!body.can_set_rsvp,
                   me: Number(body.me_person_id) || 0,
                   roster: new Map((body.roster || []).map(r => [r.person_id, r])) };
      // 🎟 Invites sit under All Players — load them with it.
      if (this.pill === 'players' && this._canInvite() && !this.invites) this._loadInvites();
      if (this.att.canMark && this.ev.kind === 'match') this._loadCallins();
    } catch (err) {
      console.error('[event] attendance load failed:', err);
      this.att = { canMark: false, canSetRsvp: false, roster: new Map() };
    }
    this._render();
  }

  // 🙋 Call-in requests (mig 1265): Liga 1 players asking in to this game.
  async _loadCallins() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/callins`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.callins = body && body.can_decide ? (body.requests || []) : null;
    } catch (err) {
      console.error('[event] call-in load failed:', err);
      this.callins = null;
    }
    this._render();
  }

  // Accept = invited (he gets Go / No, lands in No Response; nothing sent);
  // decline = not this week; undo = back to waiting.
  async _decideCallin(requestId, decision) {
    const key = `callin:${requestId}`;
    if (this.saving.has(key)) return;
    this.saving.add(key);
    this._render();
    const id = this.ev.fh_event_id;
    try {
      await this._json(`/api/calendar/events/${id}/callins`, {
        method: 'POST', body: JSON.stringify({ request_id: requestId, decision }),
      });
      await Promise.all([this._loadCallins(), decision === 'accept' ? this._loadEvent(id) : null]);
    } catch (err) {
      alert(`Could not save: ${err.message}`);
    } finally {
      this.saving.delete(key);
      this._render();
    }
  }

  _callinsHtml() {
    const list = Array.isArray(this.callins) ? this.callins : [];
    if (!list.length) return '';
    const c = (tier, fb, tokens = {}) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('callin', tier))
      ? MessageCopy.block('callin', tier, tokens) : fb;
    const open = list.filter(r => !r.decision);
    const declined = list.filter(r => r.decision === 'declined');
    const row = (r, actions) => {
      const name = `${r.first_name || ''} ${r.last_name || ''}`.trim() || 'Unknown';
      const busy = this.saving.has(`callin:${r.request_id}`) ? 'disabled' : '';
      return `<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:6px 0; border-top:1px solid var(--border-color, #374151);">
          <span style="flex:1; min-width:150px; font-weight:700;">${this.escapeHtml(name)}
            ${r.from_team ? `<span style="font-size:0.7rem; opacity:0.7; font-weight:600;"> · ${this.escapeHtml(r.from_team)}</span>` : ''}
            ${r.on_list ? '' : `<span style="font-size:0.68rem; color:#fbbf24; font-weight:800; margin-left:4px;">${this.escapeHtml(c('off_list', '⚠ not on the APSL list'))}</span>`}</span>
          ${actions(busy)}
        </div>`;
    };
    const openHtml = open.map(r => row(r, (busy) => `
        <button type="button" class="ec-send" data-ec-callin="${r.request_id}" data-decision="accept" ${busy} style="background:#22c55e;">${this.escapeHtml(c('accept', '✓ Accept'))}</button>
        <button type="button" class="ec-send" data-ec-callin="${r.request_id}" data-decision="decline" ${busy} style="background:#475569; color:#e2e8f0;">${this.escapeHtml(c('decline', 'Not this week'))}</button>`)).join('');
    const declinedHtml = declined.length ? `
        <div style="font-size:0.72rem; opacity:0.7; margin-top:8px; font-weight:700;">${this.escapeHtml(c('declined_title', `Not this week (${declined.length})`, { n: declined.length }))}</div>
        ${declined.map(r => row(r, (busy) => `<button type="button" class="ec-send" data-ec-callin="${r.request_id}" data-decision="undo" ${busy} style="background:#334155; color:#e2e8f0;">${this.escapeHtml(c('undo_decline', 'Undo'))}</button>`)).join('')}` : '';
    return `<div class="ec-box" style="border-color:#38bdf8;">
        <div style="font-weight:800; color:#7dd3fc;">${this.escapeHtml(c('staff_title', `🙋 CALL-IN REQUESTS (${open.length})`, { n: open.length }))}</div>
        <div style="font-size:0.72rem; opacity:0.75; margin:2px 0 6px;">${this.escapeHtml(c('staff_note', 'Accept = invited: Go / No shows for him and he sits in No Response until he answers. No text is sent.'))}</div>
        ${openHtml}${declinedHtml}
      </div>`;
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

  // From the event's calendar day on (mark-all is for taking the roll, not
  // pre-filling next week).
  _eventDayReached() {
    const d = new Date(this.ev && this.ev.starts_at);
    if (isNaN(d)) return true;
    d.setHours(0, 0, 0, 0);
    return Date.now() >= d.getTime();
  }

  // ✓ Mark all present: the same POST per person as a P tap, four at a
  // time; a failed one goes back to unmarked and is named in the alert.
  async _markAllPresent(personIds) {
    if (!this.att || !personIds.length || this.saving.has('att:all')) return;
    const id = this.ev.fh_event_id;
    this.saving.add('att:all');
    personIds.forEach(p => { this.saving.add(`att:${p}`); this.att.roster.set(p, { person_id: p, status: 'present' }); });
    this._render();
    const failed = [];
    const queue = personIds.slice();
    const worker = async () => {
      while (queue.length) {
        const p = queue.shift();
        try {
          await this._json(`/api/calendar/events/${id}/attendance`, {
            method: 'POST', body: JSON.stringify({ person_id: p, status: 'present' }),
          });
        } catch (err) {
          console.error('[event] mark-all save failed for', p, err);
          this.att.roster.delete(p);
          failed.push(p);
        } finally {
          this.saving.delete(`att:${p}`);
        }
      }
    };
    await Promise.all([worker(), worker(), worker(), worker()]);
    this.saving.delete('att:all');
    this._render();
    if (failed.length) alert(`Could not mark ${failed.length} present — tap P on them again.`);
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

  // ---- Contact sheet hooks (children override) ----
  // WHAT a card can send: the RSVP reminder when they have not answered,
  // and a blank text.  A game adds its game link, registration form and
  // dues note.
  contactWhats(c) {
    const whats = [];
    if (c.noResp) whats.push({ key: 'remind', label: this._cm('what_remind') });
    whats.push({ key: 'blank', label: this._cm('what_blank') });
    return whats;
  }

  contactRecommended(_c, whats) { return whats[0].key; }
  contactHasProblem(c) { return !!c.noResp; }

  // Which WHATs the club number may carry (Twilio 10DLC: the tracked
  // links) — none for a plain event; a game sends its game link and
  // registration form.
  clubTextWhats() { return []; }

  // The fh_events id every send is about.
  eventId() { return this.ev ? this.ev.fh_event_id : null; }

  // After a send: refresh what the cards say was sent.
  async afterContactSend() { await this._loadReminders(); }

  // The tracked RSVP reminder for some of a player's parents (mig 682),
  // one entry per parent with their own sign-in link.
  async _composeSends(what, channel, ids) {
    if (what !== 'remind') throw new Error(this._cm('why_club_what') || 'Not available here');
    const pid = Number(this._contactSheet.personId);
    const body = { person_id: pid, channel, fh_event_id: this.eventId() || 0, ...(ids.length ? { recipient_person_ids: ids } : {}) };
    const data = await this._postReminder('/api/rsvp-board/remind', body);
    await this._loadReminders();
    return data.sends || [data];
  }

  // The FH Texter message for one parent: the RSVP reminder (tracked,
  // with its sign-in link) or the coach's own words.
  async _relayMessage(what, c, t, personId, only) {
    if (what === 'blank') {
      const words = ((this._contactSheet && this._contactSheet.body) || '').trim();
      if (!words) throw new Error(this._cm('blank_empty'));
      return { href: this.buildSmsComposeHref({ to: (t && t.phone) || (c.st && c.st.phone) || '', body: words }), tokenId: 0, purpose: 'blank' };
    }
    if (what === 'remind') {
      const data = await this._postReminder('/api/rsvp-board/remind', { person_id: personId, channel: 'sms', fh_event_id: this.eventId() || 0, ...only });
      await this._loadReminders();
      return { href: data.sms_href, tokenId: data.token_id || 0, purpose: `remind:event:${this.eventId()}` };
    }
    throw new Error(this._cm('why_club_what') || 'Not available here');
  }

  // Not offered off a game (clubTextWhats is empty) — a game sends its
  // links from the club number.
  async _sendClubText() { return false; }

  // Each card's contact state (mig 649/683): who a text reaches (every
  // parent of a kid), opted in / STOPped / neither, mobile and email, the
  // latest reply.  Admins only — anyone else gets no sheet state.
  async _loadTextMarks() {
    const id = this.eventId();
    if (!id) { this.textMarks = null; return; }
    try {
      const body = await this._json(`/api/rsvp-board/text-marks?fh_event_id=${encodeURIComponent(id)}`);
      this.textMarks = { marks: body.marks || {}, optedIn: new Set(body.opted_in || []), people: body.people || {} };
    } catch (_err) {
      this.textMarks = null;
    }
  }

  // ---- Contact menu (mig 654) — every EventScreen's ✉ CONTACT sheet ----
  //
  // Moved up from Game Center 2026-10-27 so a practice card texts the way a
  // game card does.
  //
  // Owner 2026-10-23: "its confusing in game center what does what as far
  // as communication … and what works — needs to be more clear".  One
  // sheet per player: WHAT to send, HOW to send it, and beside every HOW
  // whether it works for this person or why not.  The sends are the same
  // tracked paths the old buttons used (squad notice, remind, club text,
  // registration form); the sheet only chooses between them.

  _cm(tier, tokens) { return (window.MessageCopy && MessageCopy.block('contact_menu', tier, tokens)) || ''; }

  // The choices for one person: WHAT (only what applies to them) and, for
  // the chosen WHAT, every HOW with ok / why-not.
  _contactChoices(personId, what, toIds) {
    const c = (this._contactCtx || {})[personId] || {};
    const st = c.st;
    const cb = (tier, tokens) => (window.MessageCopy && MessageCopy.block('contact_box', tier, tokens)) || '';
    // WHAT — the kind decides (contactWhats); the one for this card's
    // problem is starred (owner 2026-10-24: "they recommend message to send").
    const whats = this.contactWhats(c);
    const rec = this.contactRecommended(c, whats);
    whats.forEach(x => { if (x.key === rec && this.contactHasProblem(c)) x.label += ` ${this._cm('recommended') || '⭐'}`; });
    const w = whats.some(x => x.key === what) ? what : rec;
    // TO (mig 682/683): every parent of a kid, each sent their own
    // message — owner 2026-10-24: "they are divorced so we want option to
    // send to both but sep".  One recipient = the card's own state.
    const recips = st && Array.isArray(st.recipients) && st.recipients.length
      ? st.recipients.map(r => ({ id: r.recipient_person_id, name: r.recipient_name || '', consent: r.consent || 'none',
                                  phone: r.phone || null, email: r.email || null }))
      : [{ id: null, name: c.name || '', consent: st ? st.consent : 'none', phone: st ? st.phone : true, email: st ? st.email : true }];
    const ticked = toIds ? recips.filter(r => toIds.includes(r.id)) : recips;
    const multi = ticked.length > 1;
    const one = ticked[0] || recips[0];
    const hasPhone = ticked.some(r => !!r.phone);
    const hasEmail = ticked.some(r => !!r.email);
    const anyStopped = ticked.some(r => r.consent === 'stopped');
    const allIn = ticked.length > 0 && ticked.every(r => r.consent === 'in');
    const regPhoneWhy = w === 'reg' && !(c.gap && c.gap.phone) ? cb('why_nophone') : '';
    const regEmailWhy = w === 'reg' && !(c.gap && c.gap.email) ? cb('why_noemail') : '';
    const noneWhy = ticked.length ? '' : this._cm('none_ticked');
    const hows = [
      { key: 'text',  label: this._cm('how_text'), why: noneWhy || (!hasPhone ? cb('why_nophone') : regPhoneWhy) },
      { key: 'email', label: this._cm('how_email'), why: noneWhy || (!hasEmail ? cb('why_noemail') : regEmailWhy) },
      { key: 'call',  label: this._cm('how_call'),  why: noneWhy || (hasPhone ? '' : cb('why_nophone')) },
    ];
    // 📲 Text's sub-options (mig 675; owner 2026-10-24: "inside each
    // option it has sub option and defaults to default but allows radio
    // button to change it for that message").  The default is the rule in
    // _textRoute — per parent when two are ticked ("Best for each").
    const r = this.relay;
    const clubWhy = this.clubTextWhats().includes(w) ? '' : this._cm('why_club_what');
    const relayWhy = !r ? '' : anyStopped ? this._cm('manual_why_stopped')
                   : !r.device ? this._cm('manual_why_unpaired') : !r.device.online ? this._cm('manual_why_offline')
                   : r.today + ticked.length > r.cap ? this._cm('manual_why_cap') : '';
    const device = r && r.device ? r.device.name : '';
    let vias;
    if (!multi) {
      vias = [
        { key: 'club',  label: this._cm('via_club'),
          why: one.consent === 'stopped' ? cb('why_stopped') : one.consent !== 'in' ? cb('why_none') : clubWhy },
        ...(r ? [{ key: 'relay', label: this._cm('via_relay', { device }), why: relayWhy }] : []),
        { key: 'paste', label: this._cm('via_paste'), why: '' },
      ];
    } else {
      const word = { club: this._cm('route_club_short'), relay: this._cm('route_relay_short'), manual: this._cm('route_paste_short') };
      const routes = ticked.map(t => `${t.name}: ${word[this._textRoute(w, t.consent).route]}`).join(' · ');
      vias = [
        { key: 'best',  label: this._cm('via_best', { routes }), why: '' },
        { key: 'club',  label: this._cm('via_club_all'), why: !allIn ? this._cm('why_not_all_in') : clubWhy },
        ...(r ? [{ key: 'relay', label: this._cm('via_relay_all', { device }), why: relayWhy }] : []),
        { key: 'paste', label: this._cm('via_paste_all'), why: '' },
      ];
    }
    const defVia = multi ? 'best' : { club: 'club', relay: 'relay', manual: 'paste' }[this._textRoute(w, one.consent).route];
    return { c, whats, what: w, hows, vias, defVia, recips, ticked };
  }

  // Which number a 📲 Text goes from (mig 673; owner 2026-10-24: "default
  // to using twilio phone for text. then fall back to my phone app if not
  // opted in"): the club number for an opted-in player's game link or
  // registration form, else FH Texter on the owner's phone, else copy &
  // paste.  Coaches without FH Texter (admins only) just paste.
  _textRoute(what, consent) {
    if (consent === 'in' && this.clubTextWhats().includes(what)) return { route: 'club' };
    const r = this.relay;
    if (!r) return { route: 'manual', why: '' };
    const why = consent === 'stopped' ? 'manual_why_stopped'
              : !r.device ? 'manual_why_unpaired'
              : !r.device.online ? 'manual_why_offline'
              : r.today >= r.cap ? 'manual_why_cap' : '';
    return why ? { route: 'manual', why: this._cm(why) } : { route: 'relay' };
  }

  _openContactSheet(personId, what = null) {
    const prev = this._contactSheet;
    this._contactSheet = { personId, what: what || (prev && prev.personId === personId ? prev.what : null), how: null, error: '', to: null };
    this._renderContactSheet();
  }

  _closeContactSheet() {
    this._contactSheet = null;
    document.getElementById('gc-contact-sheet')?.remove();
  }

  // The sheet lives on <body>, outside the screen's re-render, so the 15s
  // live poll never closes it under the coach's thumb.
  _renderContactSheet() {
    const sh = this._contactSheet;
    if (!sh) return this._closeContactSheet();
    const { c, whats, what, hows, vias, defVia, recips } = this._contactChoices(sh.personId, sh.what, sh.to);
    sh.what = what;
    if (!sh.to) sh.to = recips.map(r => r.id);
    if (!sh.via || (vias.find(v => v.key === sh.via) || {}).why) sh.via = defVia;
    const firstOk = hows.find(h => !h.why && h.key !== 'call');
    if (!sh.how || (hows.find(h => h.key === sh.how) || {}).why) sh.how = firstOk ? firstOk.key : 'call';
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const radio = (group, key, label, on, why) => `
      <label style="display:flex; align-items:flex-start; gap:8px; padding:7px 8px; border-radius:8px; cursor:${why ? 'not-allowed' : 'pointer'};
                    background:${on ? 'rgba(2,132,199,0.18)' : 'transparent'}; opacity:${why ? 0.55 : 1};">
        <input type="radio" name="gc-cs-${group}" data-gc-cs-${group}="${key}" ${on ? 'checked' : ''} ${why ? 'disabled' : ''} style="margin-top:2px;">
        <span style="flex:1;">${esc(label)}${group !== 'what'
          ? `<br><span style="font-size:0.75rem; font-weight:700; color:${why ? '#fbbf24' : '#34d399'};">${esc(why ? '⚠ ' + why : this._cm('works'))}</span>` : ''}</span>
      </label>`;
    const title = this._cm('title', { name: c.name || '' });
    let el = document.getElementById('gc-contact-sheet');
    if (!el) {
      el = document.createElement('div');
      el.id = 'gc-contact-sheet';
      el.setAttribute('role', 'dialog');
      el.addEventListener('click', (e) => this._onContactSheetClick(e));
      el.addEventListener('input', (e) => {
        if (e.target.matches('[data-gc-cs-body]') && this._contactSheet) this._contactSheet.body = e.target.value;
      });
      document.body.appendChild(el);
    }
    el.style.cssText = 'position:fixed; inset:0; z-index:10001; background:rgba(0,0,0,0.55); display:flex; align-items:flex-end; justify-content:center;';
    el.innerHTML = `
      <div data-gc-contact style="width:100%; max-width:480px; max-height:90vh; overflow:auto; margin:0 12px 12px; padding:14px 16px;
                                   border-radius:14px; background:#0f172a; color:#f8fafc; border:1px solid #334155; font-size:0.9rem;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
          <b style="font-size:1.02rem;">${esc(title)}</b>
          <button type="button" data-gc-cs-close style="border:none; background:none; color:#94a3b8; font-size:1.3rem; cursor:pointer;" aria-label="${esc(this._cm('cancel'))}">×</button>
        </div>
        ${recips.length > 1 ? `<div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.6; margin:4px 0 2px;">${esc(this._cm('to').toUpperCase())}
            <span style="font-weight:600; letter-spacing:0; text-transform:none;">— ${esc(this._cm('to_hint'))}</span></div>
          <div style="display:flex; gap:6px; flex-wrap:wrap; margin-bottom:6px;">${recips.map(r => `
            <label style="display:flex; align-items:center; gap:6px; padding:6px 10px; border-radius:999px; cursor:pointer;
                          border:1px solid ${sh.to.includes(r.id) ? '#0284c7' : '#334155'}; background:${sh.to.includes(r.id) ? 'rgba(2,132,199,0.18)' : 'transparent'};">
              <input type="checkbox" data-gc-cs-to="${r.id}" ${sh.to.includes(r.id) ? 'checked' : ''}>
              <span>${esc(r.name)}</span></label>`).join('')}</div>` : ''}
        ${sh.how === 'call' ? '' : `<div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.6; margin:4px 0 2px;">${esc(this._cm('what').toUpperCase())}</div>
        ${whats.map(x => radio('what', x.key, x.label, x.key === what, '')).join('')}`}
        <div style="font-size:0.7rem; font-weight:800; letter-spacing:0.05em; opacity:0.6; margin:10px 0 2px;">${esc(this._cm('how').toUpperCase())}</div>
        ${hows.map(h => radio('how', h.key, h.label, h.key === sh.how, h.why)
          + (h.key === 'text' && sh.how === 'text' && !h.why
             ? `<div style="margin-left:26px; border-left:2px solid #334155; padding-left:6px;">${vias.map(v => radio('via', v.key, v.label, v.key === sh.via, v.why)).join('')}
                ${what === 'blank' && (sh.via === 'relay' || sh.via === 'best') ? `<textarea data-gc-cs-body rows="4" maxlength="1600" placeholder="${esc(this._cm('blank_placeholder'))}"
                  style="width:100%; box-sizing:border-box; margin:6px 0 4px; padding:8px; border-radius:8px; border:1px solid #334155; background:#1e293b; color:#f8fafc; font:inherit; font-size:0.9rem;">${esc(sh.body || '')}</textarea>` : ''}</div>` : '')).join('')}
        <div style="display:flex; gap:8px; align-items:center; margin-top:12px;">
          <button type="button" data-gc-cs-send style="flex:1; padding:11px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.95rem; color:#fff; background:#0284c7;">${esc(sh.how === 'call' ? this._cm('call_go') : this._cm('send'))}</button>
          <span data-gc-remind-note data-gc-squad-note style="flex:1; font-size:0.75rem;">${sh.error ? `<span style="color:#f87171;">${esc(sh.error)}</span>` : ''}</span>
        </div>
      </div>`;
  }

  _onContactSheetClick(e) {
    const sh = this._contactSheet;
    if (!sh) return;
    if (e.target.id === 'gc-contact-sheet' || e.target.closest('[data-gc-cs-close]')) { this._closeContactSheet(); return; }
    const w = e.target.closest('[data-gc-cs-what]');
    if (w && !w.disabled) { sh.what = w.dataset.gcCsWhat; sh.how = null; sh.via = null; this._renderContactSheet(); return; }
    const to = e.target.closest('[data-gc-cs-to]');
    if (to) {
      const id = Number(to.dataset.gcCsTo);
      sh.to = to.checked ? [...new Set([...(sh.to || []), id])] : (sh.to || []).filter(x => x !== id);
      sh.how = null; sh.via = null;
      this._renderContactSheet();
      return;
    }
    const v = e.target.closest('[data-gc-cs-via]');
    if (v && !v.disabled) { sh.via = v.dataset.gcCsVia; this._renderContactSheet(); return; }
    const h = e.target.closest('[data-gc-cs-how]');
    if (h && !h.disabled) { sh.how = h.dataset.gcCsHow; this._renderContactSheet(); return; }
    const send = e.target.closest('[data-gc-cs-send]');
    if (send && !send.disabled) this._contactSend(send);
  }

  // Hand the choice to the sends it always was — once per ticked parent
  // (mig 682: each gets their own message, never one thread).  Text
  // routes are per parent under "Best for each".
  async _contactSend(btn) {
    const sh = this._contactSheet;
    const { c, what, hows, ticked } = this._contactChoices(sh.personId, sh.what, sh.to);
    const how = hows.find(x => x.key === sh.how);
    if (!how || how.why || !ticked.length) return;
    btn.dataset.personId = String(sh.personId);
    const ids = ticked.map(t => t.id).filter(id => id != null);
    const done = async () => { this._closeContactSheet(); await this.afterContactSend(); this._render(); };
    const fail = (msg) => {
      const note = btn.closest('[data-gc-contact]')?.querySelector('[data-gc-squad-note]');
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(msg)}</span>`;
      this._renderContactSheetError(btn);
    };
    const words = ((sh.body || '')).trim();
    const items = [];   // separate compose links, one per parent → DesktopSms.openMany
    try {
      if (how.key === 'call') {
        ticked.filter(t => t.phone).forEach(t => items.push({ name: t.name, label: `📞 ${t.name}`, href: `tel:${t.phone}` }));
        if (items.length === 1) window.location.href = items[0].href;
        else DesktopSms.openMany(items, { openEmail: (h) => { window.location.href = h; } });
        return this._closeContactSheet();
      }
      if (how.key === 'email') {
        if (what === 'blank') ticked.filter(t => t.email).forEach(t => items.push({ name: t.name, label: `✉ ${t.name}`, href: `mailto:${t.email}` }));
        else if (what === 'reg') items.push({ name: c.name, label: `✉ ${c.name}`, href: this.buildGmailComposeHref({ to: c.gap.email, subject: c.gap.subject || '', body: c.gap.body || '' }) });
        else (await this._composeSends(what, 'email', ids)).forEach(x => items.push({ name: x.recipient_name, label: `✉ ${x.recipient_name}`, href: x.gmail_href }));
        DesktopSms.openMany(items, { openEmail: (h) => /^mailto:/.test(h) ? (window.location.href = h) : this.openGmailCompose(h) });
        return done();
      }
      // 📲 Text: each ticked parent's route.
      const routeOf = (t) => sh.via === 'best'
        ? { club: 'club', relay: 'relay', manual: 'paste' }[this._textRoute(what, t.consent).route]
        : sh.via;
      const by = { club: [], relay: [], paste: [] };
      ticked.forEach(t => by[routeOf(t) || 'paste'].push(t));
      if (by.club.length) {
        btn.dataset.gcClubText = what === 'reg' ? 'reg_link' : 'game_link';
        if (!(await this._sendClubText(btn, by.club.map(t => t.id)))) return this._renderContactSheetError(btn);
      }
      for (const t of by.relay) {
        if (!(await this._sendViaPhone(btn, what, c, t))) return this._renderContactSheetError(btn);
      }
      if (by.paste.length) {
        if (what === 'blank') by.paste.filter(t => t.phone).forEach(t => items.push({ name: t.name, label: `💬 ${t.name}`, href: this.buildSmsComposeHref({ to: t.phone, body: words }) }));
        else if (what === 'reg') items.push({ name: c.name, label: `💬 ${c.name}`, href: this.buildSmsComposeHref({ to: c.gap.phone, body: c.gap.body || '' }) });
        else (await this._composeSends(what, 'sms', by.paste.map(t => t.id))).forEach(x => items.push({ name: x.recipient_name, label: `💬 ${x.recipient_name}`, href: x.sms_href }));
        DesktopSms.openMany(items);
      }
      return done();
    } catch (err) {
      return fail(err.message);
    }
  }

  _renderContactSheetError(btn) {
    const note = btn.closest('[data-gc-contact]')?.querySelector('[data-gc-squad-note]');
    if (this._contactSheet) this._contactSheet.error = note ? note.textContent : '';
    this._renderContactSheet();
  }


  // 📲 Text for a player not opted in (mig 673): the same tracked message
  // the copy-and-paste path builds — game link, RSVP reminder or the
  // registration form — queued to FH Texter instead, one text, one click.
  // If the phone refuses it (offline, cap, STOP) the paste panel opens
  // with that same text, so nothing is lost.
  async _sendViaPhone(btn, what, c, t) {
    const personId = Number(btn.dataset.personId);
    const note = btn.closest('[data-gc-contact]')?.querySelector('[data-gc-squad-note]');
    btn.disabled = true;
    btn.textContent = '⏳';
    let href = '', tokenId = 0, purpose = '';
    const only = t && t.id != null ? { recipient_person_ids: [t.id] } : {};
    try {
      ({ href, tokenId, purpose } = await this._relayMessage(what, c, t, personId, only));
    } catch (err) {
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
      btn.disabled = false;
      return false;
    }
    const { to, body } = DesktopSms.parse(href);
    let res = null, data = {};
    try {
      res = await this.auth.fetch('/api/phone-relay/texts', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ to: to[0] || '', body, for_person_id: personId, purpose, magic_link_token_id: tokenId }) });
      data = await res.json().catch(() => ({}));
    } catch (err) { data = { error: err.message }; }
    if (!res || !res.ok) {
      this._closeContactSheet();
      DesktopSms.open(href);
      const why = this._cm('relay_fell_back', { error: data.error || (res ? `HTTP ${res.status}` : '?') });
      setTimeout(() => {
        const slot = document.querySelector('#fh-desktop-sms [data-ds-relay]');
        if (slot) slot.insertAdjacentHTML('beforebegin', `<div style="color:#fbbf24; font-size:0.82rem; margin:6px 0;">⚠ ${this.escapeHtml(why)}</div>`);
      }, 50);
    }
    btn.disabled = false;
    return true;
  }


  async _postReminder(path, payload) {
    const headers = { 'Content-Type': 'application/json' };
    if (this.auth && this.auth.token) headers['Authorization'] = `Bearer ${this.auth.token}`;
    const res = await fetch(path, { method: 'POST', headers, credentials: 'same-origin', body: JSON.stringify(payload) });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  }

  _sentWhen(iso) {
    return new Date(iso).toLocaleString('en-US', { weekday: 'short', hour: 'numeric', minute: '2-digit' });
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
      const cpDep = e.target.closest('[data-gc-cp-dep-add]');
      if (cpDep) this.carpoolPanel.departureAdd(cpDep.dataset.gcCpDepAdd, cpDep.value);
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
        this.syncHash();
        return;
      }
      if ((el = t('[data-ec-game-center]'))) { EventKindSwitch.open(this.navigation, this.ev); return; }
      if ((el = t('[data-ec-jobs]'))) { this.navigation.goTo('jobs', { eventId: this.ev.fh_event_id }); return; }
      if ((el = t('[data-ec-draft-open]'))) { this._panelDraftOpen(Number(el.dataset.ecDraftOpen)); return; }
      if ((el = t('[data-ec-callin]'))) { this._decideCallin(Number(el.dataset.ecCallin), el.dataset.decision); return; }
      if ((el = t('[data-ec-mark-all]'))) {
        this._markAllPresent(el.dataset.ecMarkAll.split(',').map(Number).filter(Boolean));
        return;
      }
      if ((el = t('[data-ec-att]'))) {
        this._markAttendance(Number(el.dataset.personId), el.dataset.ecAtt, el.dataset.active === '1');
        return;
      }
      if ((el = t('[data-ec-contact-open]'))) { this._openContactSheet(Number(el.dataset.ecContactOpen)); return; }
      if ((el = t('[data-ec-rsvp]')))       { this._setRsvp(Number(el.dataset.personId), el.dataset.ecRsvp, el.dataset.active === '1'); return; }
      if ((el = t('[data-ec-remind-all]'))) { this._remindAll(el); return; }
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
    // Arrival · Warmup · Kickoff after the date (owner 11/5: every event).
    sub.textContent = [this._when(this.ev), EventLabels.timesLine(this.ev), EventLabels.homeSetup(this.ev) || this.ev.location].filter(Boolean).join(' · ');
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
      ${this._panelDraftButtons('data-ec-draft-open')}
      ${ev.kind === 'match' ? this._oppContactsHtml() : ''}
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
  // P/A/L/E, and on No response the reminder buttons.  Coaches get their
  // own section with the same cards and reminders, never in a player count
  // (owner 2026-10-06, 2026-11-02).
  _comingHtml() {
    // 💤 Inactive (mig 945; owner 2026-11-03: "show in sep section on all
    // screens including event center so i don't bother with them"): their
    // own closed fold, never No response / Not going / a reminder.  The
    // server keeps them out of rsvps except a practice answer of theirs.
    const inactive = Array.isArray(this.ev.inactive) ? this.ev.inactive : [];
    const inactiveIds = new Set(inactive.map(r => r.person_id));
    const rsvps = (Array.isArray(this.ev.rsvps) ? this.ev.rsvps : [])
      .filter(r => r && (r.is_coach || r.response === 'yes' || !inactiveIds.has(r.person_id)));
    const nameOf = (r) => r.name || [r.first_name, r.last_name].filter(Boolean).join(' ') || 'Unknown';
    const present = (list) => list.filter(r => {
      const e = this.att && this.att.roster.get(r.person_id);
      return e && (e.status === 'present' || e.status === 'late');
    }).length;
    // An invited player stays in No response with the team (owner
    // 2026-11-04: "if he is not with the others i will forget about him");
    // the chip says which way he came, as the #teams Team pill does (mig
    // 1024): ⭐ CALL-UP · Liga 1 / ⭐ CALL-DOWN · APSL / 🎟 INVITED.
    const chipHtml = (r) => {
      if (!r.is_callup) return r.is_coach ? `<span style="margin-left:6px; font-size:0.68rem; opacity:0.6;">coach</span>` : '';
      const b = r.callup_badge || {};
      const tier = b.dir === 'up' ? 'chip_callup_up' : b.dir === 'down' ? 'chip_callup_down' : 'chip_invited';
      const from = b.from || r.callup_from || '';
      const text = (window.MessageCopy && MessageCopy.block('event_center', tier, { from }))
        || `🎟 INVITED${from ? ' · ' + from : ''}`;
      return `<span title="Invited${r.callup_from ? ' from ' + this.escapeHtml(r.callup_from) : ''}"
               style="margin-left:6px; padding:0 6px; border-radius:999px; background:rgba(245,158,11,0.18);
                      border:1px solid rgba(245,158,11,0.55); color:#fcd34d; font-size:0.62rem; font-weight:800; white-space:nowrap;">${this.escapeHtml(text)}</span>`;
    };
    if (!rsvps.length && !inactive.length) {
      return `<div class="ec-box" style="opacity:0.7;">Nobody is on this event's list — tag a team on the calendar event.</div>`;
    }
    const open = !this._isPast(this.ev);
    // remind: No Response cards carry the reminder buttons for whoever may
    // mark the event (the send itself is club admins only, server-side),
    // and only while it can still be answered.
    const canRemind = !!(this.att && this.att.canMark) && open;
    // ✉ CONTACT on every card for whoever may mark the event (Game Center's).
    const canContact = !!(this.att && this.att.canMark);
    const canSet = !!(this.att && this.att.canSetRsvp) && open;
    // Your own card (owner 2026-11-06: "you should be able to set going or
    // not going for yourself from event center … on the card … and it
    // should show your status"): ✓/✗ for anyone while it's open, a YOU
    // chip and your answer in words.
    const me = (this.att && this.att.me) || 0;
    const isMe = (r) => !!me && Number(r.person_id) === me;
    // …and your kids' cards (guardian_targets, mig 1148: "same with grace").
    const kidIds = new Set((Array.isArray(this.ev.guardian_targets) ? this.ev.guardian_targets : [])
      .filter(c => c && c.person_id && !c.suspension).map(c => Number(c.person_id)));
    const isKid = (r) => !isMe(r) && kidIds.has(Number(r.person_id));
    const cpy = (tier, fb, tokens) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || fb;
    const chipSpan = (text) => `<span style="margin-left:6px; padding:0 6px; border-radius:999px; background:rgba(56,189,248,0.18); border:1px solid rgba(56,189,248,0.6);
               color:#7dd3fc; font-size:0.62rem; font-weight:800; white-space:nowrap;">${this.escapeHtml(text)}</span>`;
    const meChip = (r) => isMe(r) ? chipSpan(cpy('me_chip', 'YOU')) : isKid(r) ? chipSpan(cpy('kid_chip', 'YOUR PLAYER')) : '';
    const meStatus = (r) => {
      if (!isMe(r) && !isKid(r)) return '';
      const name = String(nameOf(r)).split(' ')[0];
      const [tier, fb, color] = isMe(r)
        ? (r.response === 'yes' ? ['me_status_yes', "✓ You're going", '#22c55e']
          : r.response === 'no' ? ['me_status_no', "✗ You're not going", '#ef4444']
          : ['me_status_none', "You haven't answered yet", '#fbbf24'])
        : (r.response === 'yes' ? ['kid_status_yes', `✓ ${name} is going`, '#22c55e']
          : r.response === 'no' ? ['kid_status_no', `✗ ${name} is not going`, '#ef4444']
          : ['kid_status_none', `${name} hasn't answered yet`, '#fbbf24']);
      return `<div style="font-size:0.78rem; font-weight:800; color:${color}; margin-top:6px;">${this.escapeHtml(cpy(tier, fb, { name }))}</div>`;
    };
    // ✓ / ✗ — tap the lit one to clear the answer (DELETE /rsvp).
    const rsvpBtns = (r) => {
      if (!canSet && !(open && (isMe(r) || isKid(r)))) return '';
      const busy = this.saving.has(`rsvp:${r.person_id}`);
      const b = (resp, label, color) => {
        const on = r.response === resp;
        return `<button type="button" class="ec-att" data-ec-rsvp="${resp}" data-person-id="${r.person_id}" data-active="${on ? 1 : 0}"
                  ${busy ? 'disabled' : ''} title="${on ? 'Tap to clear their answer' : (resp === 'yes' ? 'Set Going' : 'Set Not going')}"
                  style="border:1px solid ${color}; background:${on ? color : 'transparent'}; color:${on ? '#fff' : color};">${label}</button>`;
      };
      return `<span style="display:inline-flex; gap:4px;">${b('yes', '✓', '#22c55e')}${b('no', '✗', '#ef4444')}</span>`;
    };
    // 🎟 CALL IN on a 💤 Inactive card of a game (mig 1076): the 📇 popup
    // with the call-up preselected; sending it invites him into No Response.
    const callInBtn = (r) => {
      if (!canContact || !open || this.ev.kind !== 'match' || !window.SectionContact || !this.invites || !this.invites.candidates) return '';
      const cand = this.invites.candidates.find(c => Number(c.person_id) === Number(r.person_id));
      if (!cand) return '';
      return `<div style="margin-top:6px;">${SectionContact.callupButton(this, this.ev.fh_event_id, cand, {
        section: this.ev && this.ev.category,
        label: (window.MessageCopy && MessageCopy.block('contact_popup', 'callin_button')) || '🎟 CALL IN',
        onSent: () => Promise.all([this._loadInvites(), this._loadEvent(this.ev.fh_event_id)]),
      })}</div>`;
    };
    const card = (r, { remind = false, sides = false, callIn = false } = {}) => {
      const err = this.rsvpNote[r.person_id];
      return this.cardHtml({
        attrs: `data-person-row="${r.person_id}"`,
        name: `<span style="min-width:0; overflow:hidden; text-overflow:ellipsis;">${this.escapeHtml(nameOf(r))}</span>${meChip(r)}${chipHtml(r)}`,
        right: r.suspension ? '' : rsvpBtns(r),   // ⛔ mig 1077: no answer to set
        body: `<div style="display:flex; justify-content:space-between; align-items:center; gap:6px; margin-top:6px; flex-wrap:wrap;">
            ${sides ? this._cardSideHtml(r) : '<span></span>'}
            ${this._attendanceCell(r.person_id)}
          </div>
          ${meStatus(r)}
          ${err ? `<div style="font-size:0.72rem; color:#f87171; margin-top:4px;">${this.escapeHtml(err)}</div>` : ''}
          ${window.PersonStanding ? PersonStanding.html(r.person_id) : ''}
          ${canContact ? this._contactLineHtml(r, remind && canRemind, callIn) : ''}
          ${callIn ? callInBtn(r) : ''}`,
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
    // ⛔ Suspended for this game (mig 1077): own section, out of Going /
    // No response / Remind all.
    const suspended = rsvps.filter(r => r && !r.is_coach && r.suspension);
    const players  = rsvps.filter(r => r && !r.is_coach && !r.suspension);
    const goingAll = players.filter(r => r.response === 'yes');
    const going    = goingAll.filter(r => r.dues_eligible !== false);
    // 🩹 An open injury answers for them (mig 510, as on #my): no answer of
    // their own → the Injured group, never No response, so Remind all
    // skips them (mig 984).  An explicit answer still wins the grouping.
    const unanswered = players.filter(r => r.response !== 'yes' && r.response !== 'no');
    const injured  = unanswered.filter(r => r.injury);
    const noResp   = unanswered.filter(r => !r.injury);
    const cp = (tier, tokens) => (window.MessageCopy && MessageCopy.block('event_center', tier, tokens)) || '';
    const L = (tier, fb) => this.escapeHtml(cp(tier) || fb);

    // ✓ Mark all present (mig 1239; owner 11/11: "then i can deselect the
    // absent"): from the event's day on, every Going player with no mark
    // yet → Present in one tap; the coach then taps A on whoever didn't show.
    const unmarked = going.filter(r => !(this.att && this.att.roster.get(r.person_id) || {}).status);
    const markAllBar = this.att && this.att.canMark && this._eventDayReached() && unmarked.length
      ? `<div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin:0 0 6px;">
          <button type="button" class="ec-send" data-ec-mark-all="${unmarked.map(r => r.person_id).join(',')}"
                  ${this.saving.has('att:all') ? 'disabled' : ''} style="background:#22c55e;">${this.escapeHtml(cp('mark_all_present', { n: unmarked.length }) || `✓ Mark all ${unmarked.length} present`)}</button>
          <span style="font-size:0.72rem; opacity:0.75;">${this.escapeHtml(cp('mark_all_present_note') || "then tap A on whoever didn't show")}</span>
        </div>` : '';
    // Over the Going cards: whatever the kind adds (a practice's groups).
    const groupsTop = markAllBar + this._goingTopHtml(going);
    const remindBarHtml = (label, note, role) => `<div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin:0 0 6px;">
        <span style="font-size:0.78rem; font-weight:700;">${this.escapeHtml(label)}</span>
        <button type="button" class="ec-send" data-ec-remind-all="sms" data-ec-remind-role="${role}" style="background:#38bdf8;">💬</button>
        <button type="button" class="ec-send" data-ec-remind-all="email" data-ec-remind-role="${role}" style="background:#38bdf8;">✉</button>
        ${note ? `<span style="font-size:0.72rem; flex-basis:100%;">${note}</span>` : ''}
        <span style="font-size:0.7rem; opacity:0.7; flex-basis:100%;">${this.escapeHtml(this._relayUsable()
          ? (cp('text_via_relay', { device: this.relay.device.name || 'FH Texter', today: this.relay.today, cap: this.relay.cap })
             || `💬 on a card texts from ${this.relay.device.name || 'FH Texter'} (${this.relay.today}/${this.relay.cap} today)`)
          : (cp('text_via_app') || '💬 on a card opens your texting app'))}</span>
      </div>`;
    const remindBar = canRemind && noResp.length
      ? remindBarHtml(cp('remind_group', { n: noResp.length }) || `📣 Remind all ${noResp.length} who haven't answered`, this.groupNote, 'player') : '';

    // Coaches: their own section, unanswered first, each answer under its
    // own small heading.  Open until the coach folds it.
    const coachSection = () => {
      if (!coaches.length) return '';
      const noAnswer = coaches.filter(r => r.response !== 'yes' && r.response !== 'no');
      const part = (label, list, opts = {}) => list.length
        ? `<div style="font-size:0.74rem; font-weight:800; opacity:0.8; margin:8px 0 4px;">${label} (${list.length})</div>${grid(list, opts)}` : '';
      const key = 'coaches';
      const isOpen = this.folds.has(key) ? this.folds.get(key) : true;
      const bar = canRemind && noAnswer.length
        ? remindBarHtml(cp('remind_group_coaches', { n: noAnswer.length }) || `📣 Remind all ${noAnswer.length} coaches who haven't answered`, this.coachGroupNote, 'coach') : '';
      const body = part(L('sec_noresp', '– No response'), noAnswer, { remind: true })
                 + part(L('sec_going', '✓ Going'), coaches.filter(r => r.response === 'yes'))
                 + part(L('sec_notgoing', '✗ Not going'), coaches.filter(r => r.response === 'no'));
      return this.cardFoldHtml('data-ec-fold', key, isOpen, L('sec_coaches', '🧑‍🏫 Coaches'), coaches.length, body,
                               { aside: presentAside(coaches), top: bar });
    };
    return `
      ${this._callinsHtml()}
      ${going.length ? section(L('sec_going', '✓ Going'), going.filter(r => !r.is_callup), { sides: true, top: groupsTop }) : ''}
      ${section(L('sec_invited', '🎟 Invited · Available'), going.filter(r => r.is_callup), { sides: true })}
      ${section(L('sec_ineligible', '⛔ Said going · Ineligible (dues)'), goingAll.filter(r => r.dues_eligible === false))}
      ${fold('noresponse', L('sec_noresp', '– No response'), noResp, { remind: true, top: remindBar, defaultOpen: true })}
      ${fold('notgoing', L('sec_notgoing', '✗ Not going'), players.filter(r => r.response === 'no'))}
      ${fold('injured', L('sec_injured', '🩹 Injured'), injured)}
      ${fold('inactive', L('sec_inactive', '💤 Inactive'), inactive, { callIn: true })}
      ${fold('suspended', this.escapeHtml((window.MessageCopy && MessageCopy.block('suspended', 'section')) || '⛔ Suspended'), suspended)}
      ${coachSection()}`;
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
    // One 📇 Contact per row (mig 1068): the call-up preselected; sending
    // it creates the invite.  No other send buttons here.
    const contactBtn = (r, resend) => SectionContact.callupButton(this, this.ev.fh_event_id, r, {
      section: this.ev && this.ev.category, resend,
      onSent: () => Promise.all([this._loadInvites(), this._loadEvent(this.ev.fh_event_id)]),
    });

    const invited = data.invites.map(r => `<div class="ec-row">
        <span>${this.escapeHtml(nm(r))}${r.from_team ? `<span style="font-size:0.72rem; opacity:0.6;"> · ${this.escapeHtml(r.from_team)}</span>` : ''}</span>
        <span style="display:inline-flex; align-items:center; gap:8px;">
          ${answerChip(r.response)}
          ${contactBtn(r, true)}
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
          ${contactBtn(c, false)}
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
