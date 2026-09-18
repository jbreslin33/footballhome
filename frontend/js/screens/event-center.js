// EventCenterScreen — #event-center — the staff page for ONE calendar event
// of any kind (practice, pickup, game, meeting…).
//
// Owner 2026-09-17: "my page for coaches and admin should be for them and
// not an admin type view … its best to have dedicated pages."  Attendance
// marking and the 🎟 Invite panel used to be role-gated panels inside the
// expanded event on #my; they live here now, and #my only shows the
// read-only lists.  Game Center (#game-center) stays the page for a game's
// squad / starters / result — a game opened here links across to it.
//
// Two doors:
//   { pick: true }   the top-level 📋 Event Center tile — pick an event from
//                    the last week or the next two.
//   { event: ev }    an event object from GET /api/calendar/upcoming (what
//                    #my hands over from its "Event Center" link).
//
// No new backend: the feed is GET /api/calendar/upcoming (admins get every
// club event, coaches their teams'), and the tools are the existing
//   GET|POST|DELETE /api/calendar/events/:id/attendance
//   GET|POST        /api/calendar/events/:id/invites   DELETE …/invites/:personId
// Who may mark or invite is decided per event by the backend (can_mark —
// CalendarController::isEventCoachOrAdmin); without it the page is
// read-only.  Invite messages are built server-side from message_templates.
class EventCenterScreen extends Screen {
  static get PAST_DAYS()   { return 7; }
  static get AHEAD_DAYS()  { return 14; }
  static get KIND_PILLS() {
    return [['all', 'All'], ['match', 'Games'], ['practice', 'Practices'], ['pickup', 'Pickup'], ['other', 'Other']];
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
    this.pill     = 'coming';  // coming | invites
    this.att      = null;      // {canMark, roster: Map(person_id -> {status})}
    this.invites  = null;      // {invites, candidates} | {error}
    this.saving   = new Set(); // "att:<pid>" / "inv:<pid>" in flight
    this.copied   = new Set(); // person_ids whose invite link was copied
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
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ec-title">📋 Event Center</h1>
        <p class="subtitle" id="ec-sub"></p>
      </div>
      <div id="ec-body" style="padding: var(--space-4); max-width: 900px; margin: 0 auto;"></div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter(params = {}) {
    this.ev = params.pick ? null : (params.event || null);
    this.pill = 'coming';
    this.att = null;
    this.invites = null;
    this.error = null;
    this.saving.clear();
    this.copied.clear();
    this._render();
    if (this.ev) this._loadAttendance();
    else this._loadEvents();
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

  _feedUrl() {
    const start = new Date();
    start.setHours(0, 0, 0, 0);
    start.setDate(start.getDate() - EventCenterScreen.PAST_DAYS);
    const days = EventCenterScreen.PAST_DAYS + EventCenterScreen.AHEAD_DAYS;
    return `/api/calendar/upcoming?start=${encodeURIComponent(start.toISOString())}&days=${days}`;
  }

  async _loadEvents() {
    try {
      const body = await this._json(this._feedUrl());
      this.events = Array.isArray(body.events) ? body.events : [];
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

  async _loadAttendance() {
    const id = this.ev.fh_event_id;
    try {
      const body = await this._json(`/api/calendar/events/${id}/attendance`);
      if (!this.ev || this.ev.fh_event_id !== id) return;
      this.att = { canMark: !!body.can_mark, roster: new Map((body.roster || []).map(r => [r.person_id, r])) };
    } catch (err) {
      console.error('[event-center] attendance load failed:', err);
      this.att = { canMark: false, roster: new Map() };
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
      if (channel === 'email' && data.gmail_href) {
        this.openGmailCompose(data.gmail_href);
      } else if (channel === 'sms' && data.sms_href) {
        window.location.href = data.sms_href;
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
    await Promise.all([this._loadInvites(), this._loadEvents()]);
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
    await Promise.all([this._loadInvites(), this._loadEvents()]);
  }

  // ── events ──────────────────────────────────────────────────────────
  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const t = (sel) => e.target.closest(sel);
      let el;
      if ((el = t('[data-ec-kind]')))     { this.kind = el.dataset.ecKind; this._render(); return; }
      if ((el = t('[data-ec-category]'))) { this.category = el.dataset.ecCategory; this._render(); return; }
      if ((el = t('[data-ec-open]'))) {
        const ev = (this.events || []).find(x => x.fh_event_id === Number(el.dataset.ecOpen));
        // A goTo, so Back returns to the list.
        if (ev) this.navigation.goTo('event-center', { event: ev });
        return;
      }
      if ((el = t('[data-ec-pill]'))) {
        this.pill = el.dataset.ecPill;
        if (this.pill === 'invites' && !this.invites) this._loadInvites();
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
      if ((el = t('[data-ec-invite]'))) {
        this._sendInvite(Number(el.dataset.personId), el.dataset.ecInvite, (el.dataset.contact || '').trim());
        return;
      }
      if ((el = t('[data-ec-revoke]'))) { this._revokeInvite(Number(el.dataset.ecRevoke)); return; }
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
    if (this.ev) {
      title.textContent = `📋 ${EventLabels.title(this.ev)}`;
      sub.textContent = [this._when(this.ev), this.ev.location].filter(Boolean).join(' · ');
      body.innerHTML = this._eventHtml();
      return;
    }
    title.textContent = '📋 Event Center';
    sub.textContent = 'Pick a practice, pickup or game — take attendance, invite a player';
    if (this.error)   { body.innerHTML = `<div class="empty-state" style="text-align:center; opacity:0.8;">${this.escapeHtml(this.error)}</div>`; return; }
    if (!this.events) { body.innerHTML = `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`; return; }
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
    const upcoming = shown.filter(ev => !this._isPast(ev)).sort(byStart);
    const past     = shown.filter(ev => this._isPast(ev)).sort((a, b) => byStart(b, a));

    const row = (ev) => {
      const rsvps = Array.isArray(ev.rsvps) ? ev.rsvps : [];
      const going = rsvps.filter(r => r && r.response === 'yes' && !r.is_coach).length;
      const teams = (Array.isArray(ev.teams) ? ev.teams : []).map(t => t && t.name).filter(Boolean).join(' + ');
      return `<button type="button" class="btn btn-secondary ec-pick" data-ec-open="${ev.fh_event_id}">
        <span style="font-weight:700;">${this.escapeHtml(EventLabels.title(ev))}</span>
        <span style="font-size:0.8rem; opacity:0.8;">${this.escapeHtml([this._when(ev), ev.location].filter(Boolean).join(' · '))}</span>
        <span style="font-size:0.75rem; opacity:0.65;">${this.escapeHtml([teams, `${going} going`].filter(Boolean).join(' · '))}</span>
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
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap;">
        ${EventCenterScreen.KIND_PILLS.map(([k, label]) => chip('data-ec-kind', k, label, this.kind === k)).join('')}
      </div>
      ${list('Today & coming up', upcoming, `Nothing in the next ${EventCenterScreen.AHEAD_DAYS} days.`)}
      ${list(`Last ${EventCenterScreen.PAST_DAYS} days`, past, 'Nothing.')}`;
  }

  _eventHtml() {
    const ev = this.ev;
    const canMark = !!(this.att && this.att.canMark);
    const pills = [['coming', "Who's Coming & Attendance"]];
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
      ${this.pill === 'invites' ? this._invitesHtml() : this._comingHtml()}`;
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
    const group = (label, list) => {
      if (!list.length) return '';
      return `<div class="ec-box">
        <div style="display:flex; justify-content:space-between; align-items:baseline;">
          <span class="ec-h">${label} (${list.length})</span>
          ${this.att ? `<span style="font-size:0.78rem; color:#22c55e; font-weight:700;">${present(list)} present</span>` : ''}
        </div>
        ${list.map(r => `<div class="ec-row">
            <span>${this.escapeHtml(nameOf(r))}${chipHtml(r)}</span>
            ${this._attendanceCell(r.person_id)}
          </div>`).join('')}
      </div>`;
    };
    if (!rsvps.length) {
      return `<div class="ec-box" style="opacity:0.7;">Nobody is on this event's list — tag a team on the calendar event.</div>`;
    }
    const going = rsvps.filter(r => r && r.response === 'yes');
    return `
      ${group('Going', going.filter(r => !r.is_callup))}
      ${group('Invited · Available', going.filter(r => r.is_callup))}
      ${group('Not going', rsvps.filter(r => r && r.response === 'no'))}
      ${group('No response', rsvps.filter(r => r && r.response !== 'yes' && r.response !== 'no'))}`;
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
