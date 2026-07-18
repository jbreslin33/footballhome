// MyScreen — signed-in player's unified week view + chat.
//
// Post-Slice-7 (2026-07-17): single-screen layout, no tabs.
//   * Section 1: Chat, compressed to the newest message with an
//     expand toggle for older messages.
//   * Section 2: Events for the current week the caller is roster-
//     eligible for.  Rolling one-week window that flips over at
//     Sunday 20:00 local — before the cutover the window ends on the
//     upcoming Sunday, after the cutover it slides to the following
//     Sunday (see _weekWindowEnd).  Each event has four buttons:
//         Going / Not Going          → per-event override (fh_event_rsvps)
//         Recurring Going / Not Going → standing pref     (fh_recurring_rsvps)
//     The effective state is highlighted.  A per-event override always
//     wins over the standing preference for that specific event.
//
// Backend surface (all already exist — no new endpoints needed):
//   GET  /api/calendar/upcoming?days=7   → { events: [{fh_event_id, kind,
//                                                      category, my_rsvp,
//                                                      my_rsvp_eligible,
//                                                      starts_at, ...}] }
//     The backend now enforces the one-week window in America/New_York,
//     so the player screen only sees the current week until Sunday 20:00,
//     then flips to the next week at the cutover.
//   POST /api/calendar/rsvp              → { fh_event_id, response }
//   GET  /api/calendar/my-standing       → { prefs: [{kind, category,
//                                                     response, active}] }
//   POST /api/calendar/my-standing       → { kind, category, response, active }
//   GET  /api/my/chat/messages           → { chat_id, viewer_user_id, messages }
//   POST /api/my/chat/messages           → { message }
//
// Auth: MyController + CalendarController accept fh_sess cookie OR JWT bearer.
// _fetch() sends both so magic-link + SPA-login paths both work.
class MyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    // Event + standing state (this-week section).
    this.events         = null;          // Array<event> from /api/calendar/upcoming
    this.standing       = null;          // Array<{kind, category, response, active}>
    this.eventSaving    = new Set();     // "fh_event_id:response" tokens in-flight
    this.standingSaving = new Set();     // "kind::category::response" tokens in-flight
    this.dataError      = null;

    // Chat state (compressed: latest message on top, expandable).
    this.chatMessages   = [];            // full history, stored oldest-first
    this.chatViewerId   = 0;             // server-echoed users.id — decides "mine"
    this.chatLoaded     = false;
    this.chatSending    = false;
    this.chatError      = null;
    this.chatPollTimer  = null;
    this.chatExpanded   = false;         // true → show full history; false → latest only
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
        <section id="my-chat" style="margin-bottom: var(--space-4);"></section>
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
    this._stopChatPoll();
  }

  // ---------- bootstrap ----------

  async _bootstrap() {
    try {
      const [upRes, standingRes] = await Promise.all([
        this._fetch('/api/calendar/upcoming?days=7'),
        this._fetch('/api/calendar/my-standing').catch((err) => {
          console.warn('[my] my-standing load failed:', err.message);
          return { prefs: [] };
        }),
      ]);
      this.events   = upRes.events    || [];
      this.standing = standingRes.prefs || [];
      this._renderEvents();
      this._renderChatShell();
      await this._loadChat(/*initial*/ true);
      this._startChatPoll();
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
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      // Per-event RSVP button (Going / Not Going).
      const evBtn = e.target.closest('[data-ev-btn]');
      if (evBtn) {
        const response  = evBtn.getAttribute('data-ev-btn');           // 'yes' | 'no'
        const fhEventId = parseInt(evBtn.getAttribute('data-fh-event-id'), 10);
        if (fhEventId && (response === 'yes' || response === 'no')) {
          this._sendEventRsvp(fhEventId, response);
        }
        return;
      }
      // Recurring / standing button (Recurring Going / Recurring Not Going).
      const recBtn = e.target.closest('[data-rec-btn]');
      if (recBtn) {
        const response = recBtn.getAttribute('data-rec-btn');            // 'yes' | 'no'
        const kind     = recBtn.getAttribute('data-rec-kind');
        const category = recBtn.getAttribute('data-rec-category') || '';
        if (kind && (response === 'yes' || response === 'no')) {
          this._setStanding(kind, category, response);
        }
        return;
      }
      if (e.target.closest('#chat-send-btn')) {
        this._sendChatMessage();
        return;
      }
      // Compressed → expanded chat toggle.
      if (e.target.closest('#chat-expand-toggle')) {
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
      const btn = this.find('#chat-send-btn');
      if (btn) btn.disabled = this.chatSending || !ta.value.trim();
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

  _renderEvents() {
    const box = this.find('#my-events');
    if (!box) return;

    // Keep the current-week window trim, but do not drop events purely
    // because the backend has not marked them as eligible for this caller.
    // That lets the player-facing schedule show the upcoming pickup/practice
    // options immediately, while the RSVP write path still enforces the
    // roster eligibility rule server-side.
    const weekEnd = this._weekWindowEnd();
    const list = (this.events || []).filter(e => {
      if (!e.starts_at) return true;                  // undated → keep
      const t = new Date(e.starts_at);
      return !isNaN(t) && t <= weekEnd;
    });

    const sub = this.find('#my-subtitle');
    if (sub) {
      sub.textContent = list.length
        ? `${list.length} event${list.length !== 1 ? 's' : ''} this week`
        : 'Nothing on your calendar this week';
    }

    if (list.length === 0) {
      box.innerHTML = `
        <div class="empty-state" style="padding: var(--space-4); text-align:center; opacity: 0.7;">
          <div style="font-size:2rem; margin-bottom:8px;">📅</div>
          <div>Nothing on your calendar this week.</div>
          <div style="font-size:0.85rem; margin-top:6px; opacity:0.7;">
            Next week's schedule shows up Sunday at 8pm.
          </div>
        </div>`;
      return;
    }

    box.innerHTML = `
      <h2 style="margin: 0 0 var(--space-3); font-size:1.1rem;">This Week</h2>
      ${list.map(e => this._renderEventCard(e)).join('')}
    `;
  }

  _eventTitle(ev) {
    const kind = ev.kind || '';
    const category = ev.category || '';

    const kindLabels = { pickup: 'Pickup', practice: 'Practice', match: 'Match',
                         meeting: 'Meeting', camp: 'Camp' };
    const catLabels  = { mens: 'Mens', womens: 'Womens', boys: 'Boys', girls: 'Girls', staff: 'Staff' };
    const kindLabel  = kindLabels[kind] || (kind ? kind[0].toUpperCase() + kind.slice(1) : '');
    const catLabel   = catLabels[category] || category || '';

    if (kindLabel && catLabel) return `${kindLabel} · ${catLabel}`;
    if (kindLabel) return kindLabel;
    if (catLabel) return catLabel;

    // Fall back to the tagged team names if classification is missing.
    const teams = Array.isArray(ev.teams) ? ev.teams : [];
    const teamNames = teams
      .map(t => (t && (t.name || t.display_name)) || '')
      .filter(Boolean);
    if (teamNames.length) return teamNames.join(' · ');

    return 'Event';
  }

  _renderEventCard(ev) {
    const kind      = ev.kind || '';
    const category  = ev.category || '';
    const standing  = this._findStanding(kind, category);
    // A standing pref only "counts" toward the effective state when
    // active=true.  active=false rows are historical (user turned it off).
    const standingResp = (standing && standing.active) ? standing.response : null;

    const per         = ev.my_rsvp;              // 'yes' | 'no' | 'maybe' | null
    const windowOpen  = ev.rsvps_open_now !== false;
    const openMsg     = !windowOpen ? 'RSVP window not open yet' : '';

    const evYesKey    = `${ev.fh_event_id}:yes`;
    const evNoKey     = `${ev.fh_event_id}:no`;
    const recYesKey   = `${kind}::${category}::yes`;
    const recNoKey    = `${kind}::${category}::no`;

    const evYesSaving  = this.eventSaving.has(evYesKey);
    const evNoSaving   = this.eventSaving.has(evNoKey);
    const recYesSaving = this.standingSaving.has(recYesKey);
    const recNoSaving  = this.standingSaving.has(recNoKey);

    const kindLabels = { pickup: 'Pickup', practice: 'Practice', match: 'Match',
                         meeting: 'Meeting', camp: 'Camp' };
    const catLabels  = { mens: 'Mens', womens: 'Womens', boys: 'Boys', girls: 'Girls' };
    const kindLabel  = kindLabels[kind] || (kind ? kind[0].toUpperCase() + kind.slice(1) : 'Event');
    const catLabel   = catLabels[category] || category || '';

    const dateStr = this._eventDateStr(ev.starts_at);
    const timeStr = this._eventTimeStr(ev.starts_at);
    const title   = this._eventTitle(ev);
    const venue   = ev.location || '';

    // Show a subtle hint on recurring buttons when it would only apply
    // to future events (per-event override is set, so this event is
    // locked by the manual click).
    const recSuffix = per ? ' — future events only' : '';

    return `
      <div style="background: rgba(255,255,255,0.04);
                  border: 1px solid rgba(255,255,255,0.08);
                  border-radius: 10px;
                  padding: var(--space-3);
                  margin-bottom: var(--space-3);">
        <div style="display:flex; justify-content: space-between; align-items: baseline; margin-bottom:6px;">
          <div style="font-weight: 600; font-size: 1rem;">
            ${this.escapeHtml(dateStr)} · ${this.escapeHtml(timeStr)}
          </div>
          <div style="font-size:0.8rem; opacity:0.75;">
            ${this.escapeHtml((catLabel + ' ' + kindLabel).trim())}
          </div>
        </div>
        <div style="font-weight:500; margin-bottom:2px;">${this.escapeHtml(title)}</div>
        ${venue ? `<div style="opacity:0.7; font-size:0.85rem; margin-bottom: var(--space-3);">${this.escapeHtml(venue)}</div>` : `<div style="margin-bottom: var(--space-3);"></div>`}
        <div style="display:flex; gap:8px; flex-wrap:wrap;">
          ${this._btn('Going',      'yes', per === 'yes', 'solid',   evYesSaving,
                     `data-ev-btn="yes" data-fh-event-id="${ev.fh_event_id}"`, openMsg)}
          ${this._btn('Not Going',  'no',  per === 'no',  'solid',   evNoSaving,
                     `data-ev-btn="no"  data-fh-event-id="${ev.fh_event_id}"`, openMsg)}
          ${this._btn('Recurring Going',     'yes', !per && standingResp === 'yes', 'outline', recYesSaving,
                     `data-rec-btn="yes" data-rec-kind="${this.escapeHtml(kind)}" data-rec-category="${this.escapeHtml(category)}"`,
                     '', recSuffix)}
          ${this._btn('Recurring Not Going', 'no',  !per && standingResp === 'no',  'outline', recNoSaving,
                     `data-rec-btn="no"  data-rec-kind="${this.escapeHtml(kind)}" data-rec-category="${this.escapeHtml(category)}"`,
                     '', recSuffix)}
        </div>
      </div>
    `;
  }

  // Button renderer.  `semantic` is 'yes' | 'no' — drives colour.
  // `style` is 'solid' (per-event override active) | 'outline' (recurring active).
  // `disabledMsg` non-empty disables the button and shows a tooltip.
  _btn(label, semantic, active, style, saving, attrs, disabledMsg, hintSuffix) {
    const disabled = !!disabledMsg || saving;
    const isYes = semantic === 'yes';
    let bg, fg, bd;
    if (active && style === 'solid') {
      bg = isYes ? '#065f46' : '#7f1d1d';
      fg = '#ffffff';
      bd = bg;
    } else if (active && style === 'outline') {
      bg = 'transparent';
      fg = isYes ? '#a7f3d0' : '#fecaca';
      bd = isYes ? 'rgba(6,95,70,0.7)' : 'rgba(127,29,29,0.7)';
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
              style="padding: 6px 14px; border-radius: 9999px;
                     background:${bg}; color:${fg};
                     border: 1px solid ${bd};
                     font-size: 0.85rem; font-weight: 600;
                     cursor:${cursor}; opacity:${opacity};">
        ${this.escapeHtml(label)}${saving ? ' …' : ''}
      </button>
    `;
  }

  _findStanding(kind, category) {
    return (this.standing || []).find(p =>
      p.kind === kind && (p.category || '') === (category || ''));
  }

  _eventDateStr(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
  }

  _eventTimeStr(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d.getTime())) return '';
    return d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
  }

  async _sendEventRsvp(fhEventId, response) {
    const key = `${fhEventId}:${response}`;
    if (this.eventSaving.has(key)) return;
    this.eventSaving.add(key);
    this._renderEvents();
    try {
      const body = await this._fetch('/api/calendar/rsvp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ fh_event_id: fhEventId, response }),
      });
      // Optimistic local mutation so the UI updates instantly.
      const ev = (this.events || []).find(e => e.fh_event_id === fhEventId);
      if (ev) {
        ev.my_rsvp = (body && body.rsvp && body.rsvp.response) || response;
        ev.my_rsvp_created_via = 'manual';
      }
    } catch (err) {
      console.error('[my] event RSVP failed:', err);
      alert(`Could not save RSVP: ${err.message}`);
    } finally {
      this.eventSaving.delete(key);
      this._renderEvents();
    }
  }

  async _setStanding(kind, category, response) {
    const key = `${kind}::${category || ''}::${response}`;
    if (this.standingSaving.has(key)) return;
    this.standingSaving.add(key);
    this._renderEvents();
    try {
      const body = await this._fetch('/api/calendar/my-standing', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          kind,
          category: category || null,
          response,
          active: true,
        }),
      });
      const saved = body && body.pref;
      if (saved) {
        this.standing = (this.standing || []).filter(p =>
          !(p.kind === kind && (p.category || '') === (category || '')));
        this.standing.push(saved);
      }
    } catch (err) {
      console.error('[my] standing set failed:', err);
      alert(`Could not save recurring preference: ${err.message}`);
    } finally {
      this.standingSaving.delete(key);
      this._renderEvents();
    }
  }

  // ────── Chat (latest message on top, expandable) ──────────────────

  _renderChatShell() {
    const box = this.find('#my-chat');
    if (!box) return;
    box.innerHTML = `
      <div style="background: rgba(15,23,42,0.55); border-radius:10px;
                  border:1px solid rgba(255,255,255,0.06); overflow:hidden;">
        <div style="display:flex; gap:8px; align-items:flex-end;
                    padding:8px 10px; border-bottom:1px solid rgba(255,255,255,0.08);
                    background: rgba(15,23,42,0.75);">
          <textarea id="chat-input" rows="1" maxlength="2000"
                    placeholder="Message the men's chat…"
                    style="flex:1; resize:none; min-height:38px; max-height:140px;
                           background:#0f172a; color:#e5e7eb;
                           border:1px solid #334155; border-radius:18px;
                           padding:9px 14px; font-family:inherit; font-size:0.95rem;
                           line-height:1.35; overflow-y:auto;"></textarea>
          <button id="chat-send-btn" type="button" aria-label="Send" disabled
                  style="flex:0 0 auto; width:42px; height:42px; border-radius:50%;
                         background:#2563eb; color:#fff; border:none; cursor:pointer;
                         display:inline-flex; align-items:center; justify-content:center;
                         font-size:1.1rem; box-shadow:0 2px 6px rgba(0,0,0,0.35);">
            ➤
          </button>
        </div>
        <div id="chat-list" style="padding: 8px 10px 10px;">
          <div class="loading-state"><div class="spinner"></div><p>Loading chat…</p></div>
        </div>
      </div>
    `;
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
        <div style="opacity:0.6; padding: var(--space-3); text-align:center;">
          <div style="font-size:1.2rem; margin-bottom:4px;">💬</div>
          <div style="font-size:0.9rem;">No messages yet — be the first to say hi.</div>
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
                   style="display:block; width:100%; margin-top:8px;
                          background:transparent; color:#93c5fd;
                          border:1px solid rgba(147,197,253,0.3);
                          border-radius:6px; padding:6px 10px;
                          font-size:0.85rem; font-weight:600; cursor:pointer;">
             ▼ Show ${more} older message${more !== 1 ? 's' : ''}
           </button>`
        : '';
      box.innerHTML = this._renderChatRow(latest) + toggle;
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
      <div style="padding: 10px 4px; border-bottom:1px solid rgba(255,255,255,0.06);">
        <div style="display:flex; justify-content:space-between; gap:8px; margin-bottom:4px;">
          <div style="font-size:0.85rem; color:${nameColor}; font-weight:600;">${author}</div>
          <div style="font-size:0.75rem; opacity:0.55;">${this.escapeHtml(when)}</div>
        </div>
        <div style="white-space:pre-wrap; word-wrap:break-word; overflow-wrap:anywhere;
                    font-size:0.95rem; line-height:1.4;">${linkified}</div>
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

  _startChatPoll() {
    this._stopChatPoll();
    // Single unified poll — this is a one-screen layout, so there's no
    // "background" vs "foreground" distinction any more.
    this.chatPollTimer = setInterval(() => {
      if (document.hidden) return;
      this._loadChat(/*initial*/ false).catch(() => {});
    }, 15000);
  }

  _stopChatPoll() {
    if (this.chatPollTimer) {
      clearInterval(this.chatPollTimer);
      this.chatPollTimer = null;
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
      const btn2 = this.find('#chat-send-btn');
      if (btn2) btn2.disabled = !this.find('#chat-input')?.value.trim();
    }
  }
}

