// SectionChat — your section's chat in Event Center's 👤 Mine: the in-app chat
// (Boys & Girls, Women) or, where the section chats on GroupMe
// (chats.messaging_enabled = false, mig 406 — the Men), the GroupMe feed in
// the same box (mig 392) with the composer only when posting is on
// (post_messages, mig 407) and the section's links (chat_links: the GroupMe
// join link, #film …).  What a section HAS comes from those DB rows, never
// from code — a parents' GroupMe is one chat_integrations row.
//
// Moved out of MyScreen (docs/event-center-design.md, slice 3) — same look.
//
//   GET  /api/my/chat/messages[?since_id]  → {messages, viewer_user_id, messaging, links}
//   POST /api/my/chat/messages             → the new message
//   GET  /api/my/groupme/feed              → {title, messages, can_post}
//   POST /api/my/groupme/messages          → relay into the group
//   POST /api/my/push-test                 → 🔔 a test push to this device only
//
//   const chat = new SectionChat(host, { fetchJson, escapeHtml, navigation });
//   chat.start();  …  chat.stop();
class SectionChat {
  constructor(host, ctx) {
    this.host = host;
    this.ctx = ctx;
    this.messages = [];
    this.viewerId = 0;
    this.messaging = true;
    this.expanded = false;
    this.error = null;
    this.sending = false;
    this.gm = { title: '', canPost: false, messages: [], expanded: false };
    this.timer = null;
    this.tick = 0;
    this._wire();
  }

  esc(t) { return this.ctx.escapeHtml(t == null ? '' : String(t)); }
  find(sel) { return this.host.querySelector(sel); }

  async start() {
    this.renderShell();
    await this.loadChat(true);
    this.loadGroupMe().catch(() => {});
    this.initPushTest().catch(() => {});
    this.stop();
    this.timer = setInterval(() => {
      if (!this.host.isConnected) { this.stop(); return; }
      if (document.hidden) return;
      this.loadChat(false).catch(() => {});
      // The backend caches GroupMe for 60 s, so every 4th tick is plenty.
      if (++this.tick % 4 === 0) this.loadGroupMe().catch(() => {});
    }, 15000);
  }

  stop() { if (this.timer) { clearInterval(this.timer); this.timer = null; } }

  _wire() {
    this.host.addEventListener('click', (e) => {
      const t = (sel) => e.target.closest(sel);
      let el;
      if ((el = t('[data-player-nav-target]'))) {
        e.preventDefault();
        const to = el.getAttribute('data-player-nav-target');
        if (to && this.ctx.navigation) this.ctx.navigation.goTo(to);
        return;
      }
      if (t('#chat-send-btn')) { this.send(); return; }
      if (t('#chat-view-btn') || t('#chat-expand-toggle')) { this.expanded = !this.expanded; this.renderMessages(); return; }
      if (t('#push-test-btn')) { this.pushTest(); return; }
      if (t('#groupme-expand-toggle')) { this.gm.expanded = !this.gm.expanded; this.renderGroupMe(); }
    });
    this.host.addEventListener('keydown', (e) => {
      if (!e.target.closest('#chat-input')) return;
      if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); this.send(); }
    });
    this.host.addEventListener('input', (e) => {
      const ta = e.target.closest('#chat-input');
      if (!ta) return;
      ta.style.height = 'auto';
      ta.style.height = Math.min(ta.scrollHeight, 140) + 'px';
      this.syncComposer();
    });
  }

  renderShell() {
    const pill = `padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16);
                  background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600;`;
    this.host.innerHTML = `
      <div id="chat-box" style="background: rgba(15,23,42,0.55); border-radius:7px; border:1px solid rgba(255,255,255,0.06); overflow:hidden;">
        <div style="display:flex; align-items:center; justify-content:space-between; padding:5px 7px;
                    border-bottom:1px solid rgba(255,255,255,0.08); background: rgba(15,23,42,0.75);">
          <div id="chat-title" style="font-size:0.72rem; font-weight:700; opacity:0.9;">Chat</div>
          <div style="display:flex; align-items:center; gap:6px;">
            <button id="push-test-btn" type="button" style="display:none; ${pill}"
                    title="Sends a test push to this device only — /api/my/push-test always targets the caller, never anyone else">🔔 Send test</button>
            <button id="chat-view-btn" type="button" aria-label="View chat" style="${pill}">View chat</button>
          </div>
        </div>
        <div id="chat-links" style="display:none; flex-wrap:wrap; gap:5px; padding:5px 7px; border-bottom:1px solid rgba(255,255,255,0.08);"></div>
        <div id="chat-list" style="padding: 5px 7px 6px;">
          <div class="loading-state"><div class="spinner"></div><p>Loading chat…</p></div>
        </div>
        <div id="chat-composer" style="display:flex; align-items:flex-end; gap:6px; padding:6px 7px 7px;
                    border-top:1px solid rgba(255,255,255,0.08); background:rgba(2,6,23,0.35);">
          <textarea id="chat-input" rows="1" placeholder="Write a message…"
                    style="flex:1; resize:none; min-height:32px; max-height:110px; border-radius:6px; border:1px solid rgba(255,255,255,0.12);
                           background:rgba(15,23,42,0.78); color:#f8fafc; padding:7px 8px; font-size:0.72rem; line-height:1.3;"></textarea>
          <button id="chat-send-btn" type="button" disabled
                  style="padding:7px 10px; border-radius:6px; border:1px solid rgba(96,165,250,0.35); background:rgba(59,130,246,0.2);
                         color:#dbeafe; font-size:0.72rem; font-weight:700;">Send</button>
        </div>
        <div id="chat-send-error" style="display:none; padding:0 7px 6px; font-size:0.68rem; color:#f87171;"></div>
      </div>`;
    this.syncComposer();
  }

  syncComposer() {
    const input = this.find('#chat-input'), btn = this.find('#chat-send-btn');
    if (input && btn) btn.disabled = this.sending || !input.value.trim();
  }

  // ── in-app chat ──────────────────────────────────────────────────────
  async loadChat(initial) {
    const sinceId = initial ? 0 : (this.messages.length ? this.messages[this.messages.length - 1].id : 0);
    let res;
    try {
      res = await this.ctx.fetchJson(sinceId > 0 ? `/api/my/chat/messages?since_id=${sinceId}` : '/api/my/chat/messages');
    } catch (err) {
      if (initial) { this.error = err.message || 'Failed to load chat.'; this.renderMessages(); }
      return;
    }
    const incoming = (res && res.messages) || [];
    if (initial) {
      this.messages = incoming;
      this.viewerId = (res && res.viewer_user_id) || 0;
      this.error = null;
      this.messaging = !(res && res.messaging === false);
      this.renderLinks((res && res.links) || []);
      if (!this.messaging) { this.renderGroupMeShell(); return; }
    } else if (!this.messaging || !incoming.length) {
      return;   // GroupMe section, or nothing new
    } else {
      this.messages = this.messages.concat(incoming);
      if (res && res.viewer_user_id) this.viewerId = res.viewer_user_id;
    }
    this.renderMessages();
  }

  renderMessages() {
    if (!this.messaging) return;
    const box = this.find('#chat-list');
    if (!box) return;
    if (this.error) { box.innerHTML = `<div class="empty-state"><p>Chat unavailable: ${this.esc(this.error)}</p></div>`; return; }
    if (!this.messages.length) {
      if (this.ctx.onSummary && this.messaging) this.ctx.onSummary({ text: '', when: '', unread: 0 });
      box.innerHTML = `<div style="opacity:0.7; font-size:0.68rem;">No messages yet — be the first to say hi.</div>`;
      return;
    }
    const reversed = this.messages.slice().reverse();   // stored oldest→newest; show newest first
    this._emitSummary();
    const toggleCss = `display:block; width:100%; background:transparent; color:#93c5fd; border:1px solid rgba(147,197,253,0.3);
                       border-radius:5px; padding:3px 6px; font-size:0.62rem; font-weight:600; cursor:pointer;`;
    if (!this.expanded) {
      const more = reversed.length - 1;
      box.innerHTML = `<div style="font-size:0.68rem; line-height:1.2; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${this.esc(reversed[0].message || '')}</div>`
        + (more > 0 ? `<button id="chat-expand-toggle" type="button" style="margin-top:4px; ${toggleCss}">▼ Show ${more} older message${more !== 1 ? 's' : ''}</button>` : '');
      return;
    }
    box.innerHTML = `<button id="chat-expand-toggle" type="button" style="margin:0 0 8px; ${toggleCss}">▲ Show only latest message</button>
      <div style="max-height:55vh; overflow-y:auto;">${reversed.map(m => this.chatRow(m)).join('')}</div>`;
  }

  chatRow(m) {
    const first = (m.author_first_name || '').trim(), last = (m.author_last_name || '').trim();
    const author = (first || last) ? this.esc(first + (last ? ' ' + last.charAt(0) + '.' : '')) : 'Someone';
    const color = m.user_id === this.viewerId ? '#93c5fd' : '#fbbf24';
    return this.row(author, color, SectionChat.when(m.created_at), this.linkify(m.message), '');
  }

  // ── GroupMe ──────────────────────────────────────────────────────────
  // The chat box becomes the GroupMe section (owner 2026-09-22: "show the
  // last 5 gm messages and have the groupme join button in same section and
  // mark it off with border").
  renderGroupMeShell() {
    const box = this.find('#chat-box');
    if (box) box.style.border = '1.5px solid rgba(0,175,240,0.6)';   // GroupMe blue
    const view = this.find('#chat-view-btn');
    if (view) view.hidden = true;
    this.syncGroupMeComposer();
    const list = this.find('#chat-list');
    if (list && !this.gm.messages.length) list.innerHTML = `<div style="opacity:0.7; font-size:0.68rem;">Loading GroupMe…</div>`;
    this.renderGroupMe();
  }

  syncGroupMeComposer() {
    const c = this.find('#chat-composer');
    if (c && !this.messaging) c.style.display = this.gm.canPost ? 'flex' : 'none';
  }

  async loadGroupMe() {
    const res = await this.ctx.fetchJson('/api/my/groupme/feed');
    const incoming = (res && res.messages) || [];
    const newest = (m) => (m.length ? m[0].id : '');
    const changed = newest(incoming) !== newest(this.gm.messages) || incoming.length !== this.gm.messages.length;
    this.gm.title = (res && res.title) || '';
    this.gm.canPost = !!(res && res.can_post);
    this.gm.messages = incoming;
    this.syncGroupMeComposer();
    if (changed) this.renderGroupMe();
  }

  renderGroupMe() {
    if (this.messaging) return;   // in-app chat sections have no GroupMe here
    const title = this.find('#chat-title');
    if (title && this.gm.title) title.textContent = this.gm.title;
    const list = this.find('#chat-list');
    if (!list) return;
    const msgs = this.gm.messages;
    if (!msgs.length) return;
    this._emitSummary();
    // Oldest at the top, newest at the bottom — the way GroupMe reads (owner
    // 2026-09-22); the API hands them newest-first.
    const LATEST = 5;
    const shown = (this.gm.expanded ? msgs : msgs.slice(0, LATEST)).slice().reverse();
    const older = Math.max(0, msgs.length - LATEST);
    const toggle = older > 0 ? `<div style="text-align:center; padding-bottom:4px;">
        <button id="groupme-expand-toggle" type="button" style="padding:2px 7px; border-radius:999px; border:1px solid rgba(255,255,255,0.16);
                background:transparent; color:#dbeafe; font-size:0.58rem; font-weight:600;">${this.gm.expanded ? `Latest ${LATEST} only` : `Show ${older} older`}</button>
      </div>` : '';
    list.innerHTML = toggle + shown.map(m => {
      const image = /^https:\/\/i\.groupme\.com\//.test(m.image_url || '')
        ? `<a href="${this.esc(m.image_url)}" target="_blank" rel="noopener noreferrer"><img src="${this.esc(m.image_url)}.preview" alt="" loading="lazy"
             style="max-height:90px; border-radius:5px; margin-top:3px; display:block;"></a>` : '';
      return this.row(this.esc(m.name || ''), '#fbbf24',
        SectionChat.when(m.created_at ? new Date(m.created_at * 1000).toISOString() : ''), this.linkify(m.text), image, true);
    }).join('');
  }

  // Section links (chat_links): an https:// url opens a new tab, a #route
  // goes through the router.
  renderLinks(links) {
    const box = this.find('#chat-links');
    if (!box) return;
    const pill = `padding:4px 9px; border-radius:999px; border:1px solid rgba(96,165,250,0.35); background:rgba(59,130,246,0.2);
                  color:#dbeafe; font-size:0.66rem; font-weight:700; line-height:1; text-decoration:none; display:inline-flex; align-items:center; cursor:pointer;`;
    const safe = links.filter(l => /^(https:\/\/|#[a-z0-9-]+$)/i.test(l.url || ''));
    box.style.display = safe.length ? 'flex' : 'none';
    box.innerHTML = safe.map(l => l.url.startsWith('#')
      ? `<a data-player-nav-target="${this.esc(l.url.slice(1))}" style="${pill}">${this.esc(l.label)}</a>`
      : `<a href="${this.esc(l.url)}" target="_blank" rel="noopener" style="${pill}">${this.esc(l.label)}</a>`).join('');
  }

  // ── send ─────────────────────────────────────────────────────────────
  async send() {
    if (this.sending) return;
    const ta = this.find('#chat-input');
    const text = ta ? (ta.value || '').trim() : '';
    if (!text) return;
    this.sending = true;
    this.syncComposer();
    const err = this.find('#chat-send-error');
    if (err) err.style.display = 'none';
    try {
      const opts = { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ message: text }) };
      if (!this.messaging) {
        await this.ctx.fetchJson('/api/my/groupme/messages', opts);   // relay to the section's GroupMe (mig 407)
        ta.value = ''; ta.style.height = 'auto';
        await this.loadGroupMe();
        return;
      }
      const res = await this.ctx.fetchJson('/api/my/chat/messages', opts);
      if (res && res.id) {
        this.messages.push({ id: res.id, user_id: res.user_id, person_id: res.person_id,
          author_first_name: res.author_first_name || '', author_last_name: res.author_last_name || '',
          message: res.message, created_at: res.created_at });
      }
      ta.value = ''; ta.style.height = 'auto';
      this.renderMessages();
    } catch (e) {
      if (err) { err.textContent = `Send failed: ${e.message}`; err.style.display = ''; }
    } finally {
      this.sending = false;
      this.syncComposer();
    }
  }

  // ── 🔔 test push (shows only when this device is subscribed) ─────────
  async initPushTest() {
    const btn = this.find('#push-test-btn');
    if (!btn || !('serviceWorker' in navigator) || !('PushManager' in window)) return;
    try {
      const reg = await navigator.serviceWorker.ready;
      if (await reg.pushManager.getSubscription()) btn.style.display = '';
    } catch (_) { /* no service worker */ }
  }

  async pushTest() {
    const btn = this.find('#push-test-btn');
    if (btn) { btn.disabled = true; btn.textContent = 'Sending…'; }
    let label = '🔔 Send test';
    try {
      const res = await this.ctx.fetchJson('/api/my/push-test', { method: 'POST' });
      label = res && res.sent ? '🔔 Sent!' : '🔔 No subscription found';
    } catch (_) { /* label stays */ }
    if (btn) {
      btn.disabled = false; btn.textContent = label;
      setTimeout(() => { btn.textContent = '🔔 Send test'; }, 3000);
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────
  linkify(text) {
    return this.esc(text || '').replace(/(https?:\/\/[^\s<]+)/g,
      `<a href="$1" target="_blank" rel="noopener noreferrer" style="color:#93c5fd; text-decoration:underline;">$1</a>`);
  }

  row(author, color, when, body, extra, wrap = false) {
    return `<div style="padding:4px 0; border-bottom:1px solid rgba(255,255,255,0.06);">
        <div style="display:flex; justify-content:space-between; gap:6px; margin-bottom:2px;">
          <div style="font-size:0.7rem; color:${color}; font-weight:600;">${author}</div>
          <div style="font-size:0.62rem; opacity:0.55;">${this.esc(when)}</div>
        </div>
        <div style="font-size:0.68rem; line-height:1.25; ${wrap ? 'white-space:pre-wrap; overflow-wrap:anywhere;' : 'white-space:nowrap; overflow:hidden; text-overflow:ellipsis;'}">${body}</div>
        ${extra}
      </div>`;
  }

  // ── The folded bar up top (Event Center, owner 11/18: "part of last
  // message and then number of unread messages and timestamp of last one").
  // Unread = newer than the newest one seen on this device (a per-device
  // convenience in localStorage, per person — view-as keeps its own).
  _feed() {
    if (this.messaging) {
      return this.messages.slice().reverse().map(m => ({
        at: new Date(m.created_at).getTime() || 0, iso: m.created_at,
        who: (m.author_first_name || '').trim(), text: m.message || '', mine: m.user_id === this.viewerId }));
    }
    return this.gm.messages.map(m => ({
      at: (Number(m.created_at) || 0) * 1000, iso: m.created_at ? new Date(m.created_at * 1000).toISOString() : '',
      who: m.name || '', text: m.text || (m.image_url ? '📷' : ''), mine: false }));
  }

  _readKey() {
    let who = '';
    try { who = localStorage.getItem('viewAsPersonId') || ''; } catch (_) { who = ''; }
    const u = this.ctx.auth && this.ctx.auth.user;
    return `fh.chat.read.${who ? 'p' + who : 'u' + ((u && u.id) || '0')}.${this.messaging ? 'app' : 'gm'}`;
  }

  _emitSummary() {
    if (!this.ctx.onSummary) return;
    const feed = this._feed();
    if (!feed.length) { this.ctx.onSummary({ text: '', when: '', unread: 0 }); return; }
    const newest = feed[0];
    let seen = NaN;
    try { seen = Number(localStorage.getItem(this._readKey())); } catch (_) { seen = NaN; }
    // First look on this device: nothing counts as new.
    if (!Number.isFinite(seen) || seen <= 0 || (this.ctx.isOpen && this.ctx.isOpen())) { this._markSeen(newest.at); seen = newest.at; }
    const unread = feed.filter(m => m.at > seen && !m.mine).length;
    this.ctx.onSummary({ text: `${newest.who ? newest.who + ': ' : ''}${newest.text}`, when: SectionChat.when(newest.iso),
                         unread, capped: unread >= feed.length && feed.length > 1 });
  }

  _markSeen(at) { try { localStorage.setItem(this._readKey(), String(at || Date.now())); } catch (_) { /* fine */ } }

  // Opened: everything shown counts as read.
  markRead() {
    const feed = this._feed();
    if (feed.length) this._markSeen(feed[0].at);
    this._emitSummary();
  }

  static when(iso) {
    if (!iso) return '';
    const t = new Date(iso);
    if (isNaN(t.getTime())) return '';
    const now = new Date();
    const hm = (d) => d.toLocaleTimeString(undefined, { hour: 'numeric', minute: '2-digit' });
    if (t.toDateString() === now.toDateString()) return hm(t);
    const yest = new Date(now); yest.setDate(now.getDate() - 1);
    if (t.toDateString() === yest.toDateString()) return 'Yesterday ' + hm(t);
    return t.toLocaleDateString(undefined, t.getFullYear() === now.getFullYear()
      ? { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }
      : { month: 'short', day: 'numeric', year: 'numeric' });
  }
}

window.SectionChat = SectionChat;
