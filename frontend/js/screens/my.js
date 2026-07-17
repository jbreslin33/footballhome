// MyScreen — signed-in player's Auto-RSVP standing preferences + club chat.
//
// Post-gcal rip (2026-07-17): the "This week" and "Weekly availability"
// tabs were removed — the canonical player RSVP surface is the
// CalendarScreen (/#calendar) which reads directly from fh_events.
// This screen keeps two responsibilities:
//
//   1. Auto-RSVP preferences (fh_recurring_rsvps, via /api/calendar/my-standing)
//   2. Club chat (users.id-scoped, via /api/my/chat/messages)
//
// Auth: MyController accepts either the fh_sess cookie OR a JWT bearer.
// We use auth.fetch() here so the JWT path works for the standard SPA
// login flow; requests also carry cookies via credentials: 'include'
// so magic-link sessions transparently work too.
//
// Endpoints:
//   GET  /api/calendar/my-standing  → { prefs: [...] }
//   POST /api/calendar/my-standing  → body { kind, category, response, active }
//   GET  /api/my/chat/messages      → { chat_id, messages: [...] }  (optional ?since_id=)
//   POST /api/my/chat/messages      → body { message }
class MyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.standing      = null;          // Array<{kind, category, response, active}>
    this.standingSaving = new Set();    // "kind::category" tokens currently POSTing
    this.mode          = 'standing';    // 'standing' | 'chat'
    this.errorMsg      = null;
    // Chat state.
    this.chatMessages  = [];            // oldest-first list of {id, user_id, person_id, author_first_name, author_last_name, message, created_at}
    this.chatViewerId  = 0;             // server-echoed users.id of the caller — used to decide "mine" vs "theirs"
    this.chatLoaded    = false;
    this.chatSending   = false;
    this.chatError     = null;
    this.chatSendError = null;
    this.chatPollTimer = null;          // setInterval handle for chat polls
    this.chatUnread    = 0;             // count of messages with id > lastSeenId (excluding chat-tab-active)
    this.chatShowJump  = false;         // "▼ new messages" pill shown when new msgs arrive while scrolled up
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
        <div style="display:flex; gap: var(--space-2); margin-bottom: var(--space-3); flex-wrap:wrap;">
          <button class="btn btn-primary tab-btn" data-tab="standing">Auto-RSVP</button>
          <button class="btn btn-outline-secondary tab-btn" data-tab="chat">Chat<span id="chat-badge" style="display:none; margin-left:6px; background:#dc2626; color:#fff; border-radius:10px; padding:1px 7px; font-size:0.75rem; font-weight:700;"></span></button>
        </div>
        <div id="my-content">
          <div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>
        </div>
      </div>
    `;
    this.element = el;
    return el;
  }

  onEnter(_params) {
    this.mode = 'standing';
    this.errorMsg = null;
    this._wire();
    this._bootstrap();
    // Prime the chat feed in the background so the tab-button badge
    // can show unread counts even when the user is on the Week or
    // Recurring tab.  Runs on all screens, throttled to a slow poll
    // until the user actually opens the chat tab.
    this._primeChatBackground();
  }

  onExit() {
    this._stopChatPoll();
  }

  // ---------- data ----------

  async _bootstrap() {
    try {
      const standingRes = await this._fetch('/api/calendar/my-standing').catch(err => {
        console.warn('[my] my-standing load failed:', err.message);
        return { prefs: [] };
      });
      this.standing = standingRes.prefs || [];
      this._renderTabs();
      this._renderCurrent();
    } catch (err) {
      console.error('[my] bootstrap failed:', err);
      this.errorMsg = err.message || 'Failed to load.';
      this._renderError();
    }
  }

  // Thin wrapper that adds credentials: 'include' AND the JWT via
  // auth.fetch — MyController accepts either.
  async _fetch(url, options = {}) {
    const headers = { ...(options.headers || {}) };
    if (this.auth.token) {
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

  // ---------- rendering ----------

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) {
        this.navigation.goBack();
        return;
      }
      const tab = e.target.closest('.tab-btn');
      if (tab) {
        this.mode = tab.getAttribute('data-tab');
        this._renderTabs();
        this._renderCurrent();
        if (this.mode === 'chat') {
          this._enterChat();
        } else {
          // Downshift to background polling so the badge keeps updating
          // even while the user is on the Auto-RSVP tab.
          this._startChatPoll(/*background*/ true);
          this._renderChatBadge();
        }
        return;
      }
      // Slice 6a: standing prefs toggle. data-standing-kind + data-standing-category
      // identify the (kind, category) tuple; the click flips the current
      // active/inactive state and POSTs.
      const standingBtn = e.target.closest('[data-standing-kind]');
      if (standingBtn) {
        const kind     = standingBtn.getAttribute('data-standing-kind');
        const category = standingBtn.getAttribute('data-standing-category') || null;
        this._toggleStanding(kind, category);
        return;
      }
      if (e.target.closest('#chat-send-btn')) {
        this._sendChatMessage();
        return;
      }
      if (e.target.closest('#chat-jump')) {
        this.chatShowJump = false;
        this._renderChat({ scroll: 'bottom' });
        const maxId = this.chatMessages.length ? this.chatMessages[this.chatMessages.length - 1].id : 0;
        if (maxId) this._setLastSeenId(maxId);
        return;
      }
    });
    // Enter to send (Shift+Enter → newline).  Attached via delegation
    // so re-renders don't lose the handler.
    this.element.addEventListener('keydown', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        this._sendChatMessage();
      }
    });
    // Auto-grow the chat textarea + toggle send-button enabled state as they type.
    this.element.addEventListener('input', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      ta.style.height = 'auto';
      ta.style.height = Math.min(ta.scrollHeight, 140) + 'px';
      const btn = this.find('#chat-send-btn');
      if (btn) btn.disabled = this.chatSending || !ta.value.trim();
    });
    // If they scroll back to the bottom, clear the jump-to-bottom pill and mark seen.
    this.element.addEventListener('scroll', (e) => {
      const sc = e.target.closest && e.target.closest('#chat-scroll');
      if (!sc) return;
      if (this.chatShowJump && this._isChatScrolledToBottom()) {
        this.chatShowJump = false;
        const pill = this.find('#chat-jump');
        if (pill) pill.style.display = 'none';
        const maxId = this.chatMessages.length ? this.chatMessages[this.chatMessages.length - 1].id : 0;
        if (maxId) this._setLastSeenId(maxId);
      }
    }, true);
  }

  _renderTabs() {
    const tabs = this.element.querySelectorAll('.tab-btn');
    tabs.forEach(t => {
      const active = t.getAttribute('data-tab') === this.mode;
      t.classList.toggle('btn-primary', active);
      t.classList.toggle('btn-outline-secondary', !active);
    });
  }

  _renderCurrent() {
    if (this.mode === 'chat')      return this._renderChat();
    return this._renderStanding();
  }

  _renderError() {
    const box = this.find('#my-content');
    if (!box) return;
    box.innerHTML = `
      <div class="empty-state">
        <p><strong>Error:</strong> ${this.escapeHtml(this.errorMsg || 'Unknown')}</p>
        <button class="btn btn-primary" onclick="location.reload()">Reload</button>
      </div>
    `;
  }
  // ─── Slice 6a: standing / recurring RSVPs on fh_events ────────────
  //
  // Independent from the legacy _renderRecurring above.  This screen
  // manages `fh_recurring_rsvps` rows keyed on (kind, category), which
  // the gcal-rsvp-apply-standing worker uses to auto-fill fh_event_rsvps
  // when each event's Sunday-20:00 RSVP window opens.
  //
  // For MVP the grid is a flat list of (kind × category) combinations
  // that ops currently tags in Google Calendar (see migrations 121 +
  // 122).  When a new category ships (e.g. Girls Pickup after option-C
  // wiring) add a row here.  The UI intentionally does NOT let a user
  // create arbitrary (kind, category) rows — every row must map to a
  // real fh_events kind/category that ops tags on gcal, otherwise the
  // pref matches nothing.

  _renderStanding() {
    const box = this.find('#my-content');
    if (!box) return;
    const sub = this.find('#my-subtitle');
    if (sub) sub.textContent = 'Auto-say YES when an event window opens.';

    // The set of (kind, category) rows shown here MUST be a subset of
    // what the classifier actually produces.  Adding a row here that
    // has no matching fh_events is harmless (it just never fires) but
    // is confusing UX — remove it once ops confirms they will never
    // tag that combo.
    const slots = [
      { kind: 'pickup',   category: 'mens',   label: 'Mens Pickup'    },
      { kind: 'practice', category: 'mens',   label: 'Mens Practice'  },
      { kind: 'pickup',   category: 'womens', label: 'Womens Pickup'  },
      { kind: 'practice', category: 'womens', label: 'Womens Practice'},
      { kind: 'pickup',   category: 'boys',   label: 'Boys Pickup'    },
      { kind: 'practice', category: 'boys',   label: 'Boys Practice'  },
      { kind: 'pickup',   category: 'girls',  label: 'Girls Pickup'   },
      { kind: 'practice', category: 'girls',  label: 'Girls Practice' },
    ];

    // Index server-side prefs by "kind::category" for O(1) lookup.
    const prefMap = new Map();
    for (const p of (this.standing || [])) {
      const key = `${p.kind}::${p.category || ''}`;
      prefMap.set(key, p);
    }

    const rows = slots.map(s => {
      const key      = `${s.kind}::${s.category}`;
      const pref     = prefMap.get(key);
      const active   = !!(pref && pref.active && pref.response === 'yes');
      const saving   = this.standingSaving.has(key);
      const bg       = active ? '#065f46' : 'transparent';
      const fg       = active ? '#d1fae5' : 'inherit';
      const bd       = active ? '#065f46' : 'rgba(255,255,255,0.2)';
      const label    = active ? 'ON'  : 'OFF';
      const cursor   = saving ? 'wait' : 'pointer';
      const opacity  = saving ? '0.5' : '1';
      return `
        <div style="display:flex; justify-content: space-between; align-items: center;
                    padding: var(--space-2) 0;
                    border-bottom: 1px solid rgba(255,255,255,0.05);">
          <div>
            <div style="font-weight:500;">${this.escapeHtml(s.label)}</div>
            <div style="opacity:0.6; font-size:0.85rem;">
              Auto-YES when this window opens
            </div>
          </div>
          <button data-standing-kind="${s.kind}"
                  data-standing-category="${s.category}"
                  ${saving ? 'disabled' : ''}
                  style="padding: 6px 18px; border-radius: 9999px;
                         background:${bg}; color:${fg};
                         border: 1px solid ${bd};
                         font-size:0.85rem; font-weight:600;
                         cursor:${cursor}; opacity:${opacity};
                         min-width: 70px;">
            ${label}
          </button>
        </div>
      `;
    }).join('');

    box.innerHTML = `
      <div style="background: var(--bg-secondary, rgba(255,255,255,0.04));
                  border-radius: 8px; padding: var(--space-3);">
        <p style="margin-top:0; font-weight:600; color:#fbbf24;">
          Standing RSVPs for the new calendar events.
        </p>
        <p style="margin-top:0; opacity:0.85;">
          Flip a toggle to <strong>ON</strong> and every future event of that kind + category
          will auto-register you as YES the moment its RSVP window opens (Sunday 8 PM ET).
          You can still manually override any individual event from the
          <a href="#" data-tab="week">This week</a> tab or the main Calendar screen — your click always wins.
        </p>
        <p style="margin-top:0; opacity:0.75; font-size:0.9rem;">
          Only shows for events you're roster-eligible for.  Turning a toggle OFF stops
          future auto-registrations but doesn't touch any RSVP that's already been created.
        </p>
        ${rows}
      </div>
    `;
  }

  async _toggleStanding(kind, category) {
    const key = `${kind}::${category || ''}`;
    if (this.standingSaving.has(key)) return;

    // Compute the target state — flip whatever the current row says.
    const existing = (this.standing || []).find(
      p => p.kind === kind && (p.category || '') === (category || '')
    );
    const currentlyOn = !!(existing && existing.active && existing.response === 'yes');
    const newActive   = !currentlyOn;

    this.standingSaving.add(key);
    this._renderStanding();

    try {
      const body = await this._fetch('/api/calendar/my-standing', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          kind,
          category,
          response: 'yes',   // MVP: toggle == YES / OFF.  A future revision
                             // could let users pick "auto-NO" too.
          active:   newActive,
        }),
      });
      const saved = body?.pref;
      if (saved) {
        // Merge into local state — replace or append.
        this.standing = (this.standing || []).filter(
          p => !(p.kind === kind && (p.category || '') === (category || ''))
        );
        this.standing.push(saved);
      }
    } catch (err) {
      console.error('[my] standing toggle failed:', err);
      alert(`Could not save standing preference: ${err.message}`);
    } finally {
      this.standingSaving.delete(key);
      this._renderStanding();
    }
  }

  // ────── Men's chat ──────────────────────────────────────────────────
  //
  // The Chat tab is a thin polling client over /api/my/chat/messages.
  // Design goals:
  //   - never blocks the RSVP UI on network — chat state is separate
  //   - poll only while the chat tab is the active mode (8s interval)
  //   - initial load pulls last 200 messages (server caps)
  //   - subsequent polls use since_id so we only pay the delta cost
  //   - localStorage tracks the highest-seen message id per user so
  //     the unread badge survives page refresh
  //   - autoscroll to bottom when the user is already at bottom OR
  //     just posted; otherwise leave scroll alone so history-reading
  //     isn't interrupted

  _lastSeenKey() {
    const user = this.auth.getUser && this.auth.getUser();
    const key = user && (user.id || user.email) || 'anon';
    return `fh-mens-chat-last-seen:${key}`;
  }

  _getLastSeenId() {
    try {
      const raw = localStorage.getItem(this._lastSeenKey());
      const n = raw ? parseInt(raw, 10) : 0;
      return Number.isFinite(n) ? n : 0;
    } catch (_e) {
      return 0;
    }
  }

  _setLastSeenId(id) {
    try { localStorage.setItem(this._lastSeenKey(), String(id)); } catch (_e) {}
  }

  // Kick off an initial chat fetch + background poll so the tab-button
  // unread badge reflects new activity even while the user is on the
  // Week or Recurring tabs.  Silently swallows failures — chat outage
  // shouldn't nuke the schedule view.
  async _primeChatBackground() {
    try {
      await this._loadChat(/*initial*/ true);
    } catch (_) { /* ignore */ }
    if (this.mode !== 'chat') this._startChatPoll(/*background*/ true);
  }

  async _enterChat() {
    // Switch from background poll to fast poll.
    this._stopChatPoll();
    // Initial fetch on first entry; subsequent entries just resume polling.
    if (!this.chatLoaded) {
      await this._loadChat(/*initial*/ true);
    } else {
      // Force-render since _loadChat may have quietly cached msgs while
      // we were on another tab.
      this._renderChat({ scroll: 'bottom' });
    }
    // Reset the unread counter — user is looking at chat now.
    this.chatUnread = 0;
    this.chatShowJump = false;
    this._renderChatBadge();
    this._startChatPoll(/*background*/ false);
    // Mark newest visible as seen.
    if (this.chatMessages.length > 0) {
      const maxId = this.chatMessages[this.chatMessages.length - 1].id;
      this._setLastSeenId(maxId);
    }
  }

  _startChatPoll(background) {
    this._stopChatPoll();
    // Fast poll (8s) while the chat tab is open; slower poll (25s) in
    // the background so we still detect new messages for the unread
    // badge without hammering the API.
    const interval = background ? 25000 : 8000;
    this.chatPollTimer = setInterval(() => {
      // Skip when tab hidden — avoid battery drain on backgrounded pages.
      if (document.hidden) return;
      this._loadChat(/*initial*/ false).catch(() => {});
    }, interval);
  }

  _stopChatPoll() {
    if (this.chatPollTimer) {
      clearInterval(this.chatPollTimer);
      this.chatPollTimer = null;
    }
  }

  async _loadChat(initial) {
    const sinceId = initial ? 0 : (this.chatMessages.length > 0
      ? this.chatMessages[this.chatMessages.length - 1].id
      : 0);
    const url = sinceId > 0
      ? `/api/my/chat/messages?since_id=${sinceId}`
      : '/api/my/chat/messages';
    let res;
    try {
      res = await this._fetch(url);
    } catch (err) {
      // Silent on poll failure; surface on initial.
      if (initial) {
        this.chatError = err.message || 'Failed to load chat.';
        this.chatLoaded = true;
        if (this.mode === 'chat') this._renderChat();
      }
      return;
    }
    const incoming = (res && res.messages) || [];
    if (initial) {
      this.chatMessages = incoming;
      this.chatViewerId = (res && res.viewer_user_id) || 0;
      this.chatLoaded = true;
      this.chatError = null;
      if (this.mode === 'chat') {
        // Actively viewing — clear unread and scroll to bottom.
        this.chatUnread = 0;
        this._renderChat({ scroll: 'bottom' });
        if (incoming.length > 0) {
          this._setLastSeenId(incoming[incoming.length - 1].id);
        }
      } else {
        // Background prime — compute unread against last-seen so the
        // tab-button badge can light up on first render.
        const lastSeen = this._getLastSeenId();
        this.chatUnread = incoming.filter(m => m.id > lastSeen).length;
      }
      this._renderChatBadge();
    } else if (incoming.length > 0) {
      const wasAtBottom = this._isChatScrolledToBottom();
      this.chatMessages = this.chatMessages.concat(incoming);
      if (res && res.viewer_user_id) this.chatViewerId = res.viewer_user_id;
      // Only track unread when NOT viewing the chat tab.
      if (this.mode !== 'chat') {
        const lastSeen = this._getLastSeenId();
        this.chatUnread = this.chatMessages.filter(m => m.id > lastSeen).length;
        this._renderChatBadge();
      } else {
        // If they were reading history, show the jump pill instead of yanking them down.
        if (!wasAtBottom) this.chatShowJump = true;
        this._renderChat({ scroll: wasAtBottom ? 'bottom' : 'preserve' });
        if (wasAtBottom) {
          const maxId = this.chatMessages[this.chatMessages.length - 1].id;
          this._setLastSeenId(maxId);
        }
      }
    }
  }

  _renderChat(opts = {}) {
    const box = this.find('#my-content');
    if (!box) return;
    const sub = this.find('#my-subtitle');
    if (sub) sub.textContent = "Lighthouse 1893 Men's — practical logistics chat.";

    if (!this.chatLoaded) {
      box.innerHTML = `<div class="loading-state"><div class="spinner"></div><p>Loading chat…</p></div>`;
      return;
    }

    if (this.chatError) {
      box.innerHTML = `<div class="empty-state"><p>Chat unavailable: ${this.escapeHtml(this.chatError)}</p></div>`;
      return;
    }

    // Build an ordered list of items: date-dividers + messages with grouping metadata.
    const items = [];
    let prevDay = null;
    let prevMsg = null;
    for (const m of (this.chatMessages || [])) {
      const t = new Date(m.created_at);
      const dayLabel = this._chatDayLabel(t);
      if (dayLabel !== prevDay) {
        items.push({ type: 'divider', label: dayLabel });
        prevDay = dayLabel;
        prevMsg = null; // new day → new group
      }
      const mine = m.user_id === this.chatViewerId;
      // Group with previous if same sender AND within 5 minutes.
      let firstInRun = true;
      if (prevMsg) {
        const gap = t - new Date(prevMsg.created_at);
        if (prevMsg.user_id === m.user_id && gap < 5 * 60 * 1000) {
          firstInRun = false;
        }
      }
      items.push({ type: 'msg', m, mine, firstInRun });
      prevMsg = m;
    }

    const emptyState = `
      <div style="margin:auto; opacity:0.6; padding:var(--space-4); text-align:center;">
        <div style="font-size:2rem; margin-bottom:8px;">💬</div>
        <div>No messages yet — be the first to say hi.</div>
        <div style="font-size:0.85rem; margin-top:4px;">Or ask if practice is still on.</div>
      </div>`;

    const rows = items.length
      ? items.map(it => it.type === 'divider'
          ? this._renderChatDivider(it.label)
          : this._renderChatRow(it.m, it.mine, it.firstInRun)).join('')
      : emptyState;

    const disabled = this.chatSending;
    box.innerHTML = `
      <div style="position:relative; display:flex; flex-direction:column;
                  height: calc(100vh - 240px); min-height:340px;
                  background: rgba(15,23,42,0.55); border-radius:10px; overflow:hidden;
                  border:1px solid rgba(255,255,255,0.06);">
        <div id="chat-scroll"
             style="flex:1; overflow-y:auto; padding: 12px 10px 8px 10px;
                    display:flex; flex-direction:column;">
          ${rows}
        </div>

        <button id="chat-jump" type="button"
                style="position:absolute; right:14px; bottom:80px; z-index:2;
                       display:${this.chatShowJump ? 'inline-flex' : 'none'};
                       align-items:center; gap:6px;
                       background:#2563eb; color:#fff; border:none; border-radius:999px;
                       padding:8px 14px; font-size:0.85rem; font-weight:600;
                       box-shadow:0 4px 12px rgba(0,0,0,0.35); cursor:pointer;">
          ▼ New messages
        </button>

        <div style="display:flex; gap:8px; align-items:flex-end;
                    padding:8px 10px; border-top:1px solid rgba(255,255,255,0.08);
                    background: rgba(15,23,42,0.75);">
          <textarea id="chat-input"
                    rows="1"
                    maxlength="2000"
                    placeholder="Message the men's chat…"
                    ${disabled ? 'disabled' : ''}
                    style="flex:1; resize:none; min-height:38px; max-height:140px;
                           background:#0f172a; color:#e5e7eb;
                           border:1px solid #334155; border-radius:18px;
                           padding:9px 14px; font-family:inherit; font-size:0.95rem;
                           line-height:1.35; overflow-y:auto;"></textarea>
          <button id="chat-send-btn" type="button"
                  ${disabled ? 'disabled' : ''}
                  aria-label="Send"
                  style="flex:0 0 auto; width:42px; height:42px; border-radius:50%;
                         background:#2563eb; color:#fff; border:none; cursor:pointer;
                         display:inline-flex; align-items:center; justify-content:center;
                         font-size:1.1rem; box-shadow:0 2px 6px rgba(0,0,0,0.35);">
            ${disabled ? '…' : '➤'}
          </button>
        </div>
        ${this.chatSendError ? `<div style="color:#fca5a5; padding:4px 12px 8px; font-size:0.85rem;">${this.escapeHtml(this.chatSendError)}</div>` : ''}
      </div>
    `;

    // Scroll behavior.
    const scrollBox = this.find('#chat-scroll');
    if (scrollBox) {
      if (opts.scroll === 'bottom' || !opts.scroll) {
        scrollBox.scrollTop = scrollBox.scrollHeight;
      }
    }
    // Re-check send button enabled state after re-render.
    const ta = this.find('#chat-input');
    const btn = this.find('#chat-send-btn');
    if (ta && btn) btn.disabled = disabled || !ta.value.trim();
  }

  _renderChatDivider(label) {
    return `
      <div style="display:flex; align-items:center; gap:8px;
                  margin:12px 4px 8px; opacity:0.55;">
        <div style="flex:1; height:1px; background:rgba(255,255,255,0.12);"></div>
        <div style="font-size:0.75rem; text-transform:uppercase; letter-spacing:0.05em;">${this.escapeHtml(label)}</div>
        <div style="flex:1; height:1px; background:rgba(255,255,255,0.12);"></div>
      </div>`;
  }

  _renderChatRow(m, mine, firstInRun) {
    const first = (m.author_first_name || '').trim();
    const last  = (m.author_last_name  || '').trim();
    const author = first || last
      ? this.escapeHtml(first + (last ? ' ' + last.charAt(0) + '.' : ''))
      : 'Someone';
    const when = this._formatChatTime(m.created_at);

    // Escape then linkify.
    const escaped = this.escapeHtml(m.message);
    const linkified = escaped.replace(
      /(https?:\/\/[^\s<]+)/g,
      `<a href="$1" target="_blank" rel="noopener noreferrer" style="color:${mine ? '#dbeafe' : '#93c5fd'}; text-decoration:underline;">$1</a>`
    );

    // Bubble style: mine = right-aligned blue; theirs = left-aligned grey.
    const bubbleBg    = mine ? '#2563eb' : '#334155';
    const bubbleColor = mine ? '#ffffff' : '#e5e7eb';
    const align       = mine ? 'flex-end' : 'flex-start';
    // Tighter top spacing when this message continues a run from the same sender.
    const marginTop   = firstInRun ? '10px' : '2px';
    // Rounded corners get a slight "flat" edge on the inner side to feel like a stack.
    const radius = mine
      ? (firstInRun ? '16px 16px 4px 16px' : '16px 4px 4px 16px')
      : (firstInRun ? '16px 16px 16px 4px' : '4px 16px 16px 4px');

    const header = (firstInRun && !mine)
      ? `<div style="font-size:0.75rem; color:#fbbf24; font-weight:600; margin:0 6px 2px;">${author}</div>`
      : '';

    // Timestamp: show at the start of every run, on either side.
    const timeEl = firstInRun
      ? `<div style="font-size:0.7rem; opacity:0.55; margin:0 6px 4px; text-align:${mine ? 'right' : 'left'};">${when}</div>`
      : '';

    return `
      <div style="display:flex; flex-direction:column; align-items:${align}; margin-top:${marginTop};">
        ${timeEl}
        ${header}
        <div style="max-width:78%; padding:8px 12px; border-radius:${radius};
                    background:${bubbleBg}; color:${bubbleColor};
                    white-space:pre-wrap; word-wrap:break-word; overflow-wrap:anywhere;
                    font-size:0.95rem; line-height:1.35;
                    box-shadow:0 1px 2px rgba(0,0,0,0.25);">${linkified}</div>
      </div>
    `;
  }

  _chatDayLabel(t) {
    if (!t || isNaN(t.getTime())) return '';
    const now = new Date();
    if (t.toDateString() === now.toDateString()) return 'Today';
    const yest = new Date(now); yest.setDate(now.getDate() - 1);
    if (t.toDateString() === yest.toDateString()) return 'Yesterday';
    const sameYear = t.getFullYear() === now.getFullYear();
    return t.toLocaleDateString(undefined, sameYear
      ? { month: 'short', day: 'numeric', weekday: 'short' }
      : { month: 'short', day: 'numeric', year: 'numeric' });
  }

  _formatChatTime(iso) {
    if (!iso) return '';
    const t = new Date(iso);
    if (isNaN(t.getTime())) return '';
    return t.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
  }

  _isChatScrolledToBottom() {
    const box = this.find('#chat-scroll');
    if (!box) return true;
    return (box.scrollHeight - box.scrollTop - box.clientHeight) < 40;
  }

  async _sendChatMessage() {
    if (this.chatSending) return;
    const ta = this.find('#chat-input');
    if (!ta) return;
    const text = (ta.value || '').trim();
    if (!text) return;
    this.chatSending = true;
    this.chatSendError = null;
    this._renderChat({ scroll: 'preserve' });
    try {
      const res = await this._fetch('/api/my/chat/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: text }),
      });
      // Server echoes the new row — append and clear input.
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
        this._setLastSeenId(res.id);
      }
      this.chatSending = false;
      this._renderChat({ scroll: 'bottom' });
      const ta2 = this.find('#chat-input');
      if (ta2) { ta2.value = ''; ta2.focus(); }
    } catch (err) {
      this.chatSending = false;
      this.chatSendError = err.message || 'Failed to send.';
      this._renderChat({ scroll: 'preserve' });
      // Restore text so the user doesn't lose it.
      const ta2 = this.find('#chat-input');
      if (ta2) { ta2.value = text; ta2.focus(); }
    }
  }

  _renderChatBadge() {
    const badge = this.find('#chat-badge');
    if (!badge) return;
    if (this.chatUnread > 0 && this.mode !== 'chat') {
      badge.textContent = this.chatUnread > 99 ? '99+' : String(this.chatUnread);
      badge.style.display = 'inline-block';
    } else {
      badge.style.display = 'none';
    }
  }
}
