// StatusBanner — 🚦 the band at the very top of every screen, just under the
// admin's 🎭 view-as bar: everything outstanding as boxes, green or red, and
// each box opens its own panel right under the band (migs 1468 → 1473).
//
// Owner 2026-11-18, in order: "this is where all the outstanding items
// should go … green … up to date … red" → "keep the extra view as for me lol
// and show the one i mentioned below it" → "really there prob is no yellow
// just green and red" → "its supposed to be just like the viewing as bar.
// everything in there" → "more actionable and clear" → "Overdue dues pay now
// button? missing x rsvps do so below?" → "amount fined so far?" → "amount
// they will be fined if they don't set availability this week" → "each item
// needs to be in a box and actionable … phone stacked, desktop across" →
// "what is point of details? just let each box do its own expanding".
//
// Each box opens its OWN popup (owner 11/18 "each box needs to expand itself
// and not the others … page them down to first missing one or open pop up"
// → popup: the band is on every screen, the Calendar is not).  A sheet from
// the bottom on a phone, a centred window on a desktop; ✕ / outside / Esc.
//
// Boxes (lib/status-bar.js draws them):
//   ⛔ Missing N RSVPs · $X in fines if not set  [Answer ›] → ✓ / ✗ on every unanswered event
//   ⛔ Overdue dues $X  [Pay now ›] [🙋 Volunteer ›]        → LA pay page / the volunteer card
// Fines: only the NEW ones at stake, on the RSVP box; the totals live in the
// fines section under the Calendar (owner 11/18 "don't show total at all
// except in a fines section").
//   💬 newest message  [N new › | Open ›]                    → the chat (SectionChat)
// Loads once per sign-in; refreshes its events on every screen change
// (≥ 20 s apart), on 'fh:rsvp-changed' from the Calendar, and on focus.
// Under view-as every call carries X-View-As: the viewed person's own band.
//
//   StatusBanner.onScreen(name)   ScreenManager calls it after every show
(function () {
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
    ? MessageCopy.block('event_center', tier, tokens) : fb;
  const money = (n) => `$${(Number(n) || 0).toFixed(2).replace(/\.00$/, '')}`;
  const ymd = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  const HIDDEN_ON = new Set(['login', 'oauth-success']);
  // Which panel a box's button opens (dues pay is a link, not a panel).
  const PANEL = { rsvp_soon: 'rsvp', rsvp_open: 'rsvp', chat_unread: 'chat', volunteer: 'volunteer', fines: 'fines', alerts: 'alerts', menu: 'menu', onboarding: 'onboarding', todo: 'todo', welcome_owed: 'welcome' };

  const CSS = `
    #status-banner #sb-head[hidden], #status-banner #sb-modal[hidden], #status-banner [data-sb-panel][hidden] { display:none !important; }
    #status-banner #sb-modal { position:fixed; inset:0; z-index:10000; background:rgba(0,0,0,0.55); display:flex; align-items:center; justify-content:center; padding:16px; box-sizing:border-box; }
    #status-banner .sb-sheet { width:100%; max-width:640px; max-height:85vh; display:flex; flex-direction:column; border-radius:14px; overflow:hidden;
                               background:var(--bg-secondary, #111827); color:var(--fg, #e5e7eb); border:1px solid var(--border-color, #374151); box-shadow:0 12px 40px rgba(0,0,0,0.5); text-align:left; }
    #status-banner .sb-sheet-head { display:flex; align-items:center; gap:10px; padding:10px 14px; border-bottom:1px solid var(--border-color, #374151); }
    #status-banner .sb-sheet-title { flex:1; font-weight:800; font-size:1rem; }
    #status-banner .sb-sheet-x { min-height:0; padding:4px 10px; border-radius:8px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; font:inherit; font-weight:800; cursor:pointer; }
    #status-banner .sb-sheet-body { padding:10px 14px 14px; overflow-y:auto; }
    #status-banner .sb-band { display:flex; align-items:center; justify-content:center; gap:8px 12px; flex-wrap:wrap; width:100%; box-sizing:border-box;
                              padding:8px 12px; color:#fff; font-weight:600; box-shadow:0 2px 8px rgba(0,0,0,0.25); text-align:center; }
    #status-banner .sb-ok { font-weight:800; }
    /* ☰ at the band's right end, and its menu popup (owner 11/18). */
    #status-banner .sb-burger { flex:none; width:40px; height:38px; min-height:0; padding:0; border-radius:10px; cursor:pointer; font:inherit;
                                font-size:1.25rem; line-height:1; background:#1f2937; border:1px solid #4b5563; color:#fff; }
    #status-banner .sb-menu-item { display:block; width:100%; min-height:0; padding:12px 14px; border-radius:10px; text-align:left; cursor:pointer; font:inherit;
                                   font-weight:700; font-size:0.95rem; border:1px solid var(--border-color, #374151); background:rgba(255,255,255,0.03); color:inherit; }
    #status-banner .sb-menu-item.out { opacity:0.8; margin-top:6px; }
    #status-banner .sb-boxes { display:flex; gap:8px; flex-wrap:wrap; justify-content:center; flex:0 1 auto; }
    #status-banner .sb-box { flex:0 1 auto; min-width:240px; max-width:440px; display:flex; align-items:center; gap:10px; padding:8px 12px;
                             border-radius:10px; text-align:left; cursor:pointer; color:#fff; box-sizing:border-box; }
    #status-banner .sb-box-act  { background:rgba(0,0,0,0.28); border:1px solid rgba(255,255,255,0.75); }
    /* Info (fines so far, chat): nothing to act on — plain dark grey, the same on red or green (owner 11/18). */
    #status-banner .sb-box-info { background:#1f2937; border:1px solid #4b5563; }
    /* 💬 at the band's right end; unread → a red count that pulses until opened (owner 11/18). */
    /* 💬 box: sender · time, then the start of the message (owner 11/18 "show the last message with
       time/date and sender and part of message, otherwise it's confusing"). */
    #status-banner .sb-chat { flex:0 1 auto; min-width:240px; max-width:440px; display:flex; align-items:center; gap:10px; min-height:0; padding:7px 12px;
                              box-sizing:border-box; border-radius:10px; cursor:pointer; font:inherit; text-align:left;
                              background:#1f2937; border:1px solid #4b5563; color:#fff; }
    #status-banner .sb-chat-i { position:relative; flex:none; font-size:1.3rem; }
    #status-banner .sb-chat-dot { position:absolute; top:-8px; right:-10px; min-width:18px; height:18px; padding:0 4px; box-sizing:border-box; border-radius:999px;
                                  background:#ef4444; color:#fff; font-size:0.66rem; font-weight:800; line-height:18px; text-align:center; border:2px solid #fff; }
    #status-banner .sb-chat-t { flex:1; min-width:0; display:flex; flex-direction:column; gap:1px; }
    #status-banner .sb-chat-top { display:flex; gap:8px; align-items:baseline; font-size:0.8rem; }
    #status-banner .sb-chat-who { font-weight:800; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    #status-banner .sb-chat-when { opacity:0.7; white-space:nowrap; font-size:0.72rem; }
    #status-banner .sb-chat-n { margin-left:auto; font-size:0.74rem; font-weight:800; white-space:nowrap; color:#fca5a5; }
    #status-banner .sb-chat-n.zero { color:#9ca3af; }
    #status-banner .sb-chat-msg { font-size:0.8rem; opacity:0.9; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    #status-banner .sb-chat.unread { border-color:#fff; animation: sb-pulse 1.6s ease-in-out infinite; }
    @keyframes sb-pulse { 0%, 100% { box-shadow:0 0 0 0 rgba(255,255,255,0.75); } 50% { box-shadow:0 0 0 8px rgba(255,255,255,0); } }
    @media (prefers-reduced-motion: reduce) { #status-banner .sb-chat.unread { animation:none; } }
    #status-banner .sb-box-open { outline:2px solid #fff; outline-offset:1px; }
    #status-banner .sb-box-label { flex:1; min-width:0; font-weight:800; font-size:0.86rem; line-height:1.25; }
    #status-banner .sb-box[data-sb-code="chat_unread"] .sb-box-label { white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    #status-banner .sb-box-btns { flex:none; display:inline-flex; align-items:center; gap:6px; flex-wrap:wrap; justify-content:flex-end; }
    #status-banner .sb-box-or { font-size:0.76rem; font-weight:700; opacity:0.85; }
    #status-banner .sb-box-go { min-height:0; font:inherit; font-weight:800; font-size:0.8rem; white-space:nowrap; padding:4px 10px; border-radius:999px; cursor:pointer; border:0; }
    #status-banner .sb-box-act .sb-box-go  { background:#fff; color:#b91c1c; }
    #status-banner .sb-box-info .sb-box-go { background:#374151; color:#e5e7eb; }
    #status-banner [data-sb-panel] { display:flex; flex-direction:column; gap:6px; }
    #status-banner .sb-need-title { font-weight:800; color:#fca5a5; font-size:0.85rem; }
    #status-banner .sb-need-row { display:flex; align-items:center; gap:8px; flex-wrap:wrap; width:100%; box-sizing:border-box; padding:7px 10px; border-radius:8px;
                                  border:1px solid #f59e0b; background:rgba(245,158,11,0.10); font-size:0.82rem; text-align:left; }
    #status-banner .sb-need-row.soon { border-color:#ef4444; background:rgba(239,68,68,0.12); }
    #status-banner .sb-need-open { flex:1; min-width:160px; display:flex; gap:8px; align-items:center; cursor:pointer; background:none; border:0; color:inherit; font:inherit; padding:0; text-align:left; min-height:0; }
    #status-banner .sb-ans { min-width:44px; min-height:0; padding:5px 10px; border-radius:8px; cursor:pointer; font:inherit; font-weight:800; }
    #status-banner .sb-ans.yes { border:1px solid #22c55e; background:transparent; color:#22c55e; }
    #status-banner .sb-ans.no  { border:1px solid #ef4444; background:transparent; color:#ef4444; }
    #status-banner .sb-ans:disabled { opacity:0.5; cursor:default; }
    #status-banner .sb-err { width:100%; font-size:0.74rem; color:#fca5a5; }
    @media (max-width: 640px) {
      #status-banner .sb-boxes { flex-direction:column; align-items:stretch; width:100%; }
      #status-banner .sb-box, #status-banner .sb-chat { width:100%; max-width:none; min-width:0; }
      /* The band is never pinned (owner 11/20 "that bar needs to have all page stuff under not
         behind"): #top-banners is in the page flow on every width, it scrolls away. */
      #status-banner #sb-modal { align-items:flex-end; padding:0; }
      #status-banner .sb-sheet { max-width:none; max-height:88vh; border-radius:16px 16px 0 0; }
    }`;

  class StatusBanner {
    constructor(host) {
      this.host = host;
      this.started = false;
      this.events = [];
      this.eventsAt = 0;
      this.loadingEvents = null;
      this.rsvpErr = {};
      this.saving = new Set();
      this.volCard = null;
    }

    get auth() { return window.app && window.app.auth; }
    $(sel) { return this.host.querySelector(sel); }

    // fetch → JSON body, throwing the server's message on a non-2xx.
    async fetchJson(url, options = {}) {
      const res = await this.auth.fetch(url, { ...options, headers: { 'Content-Type': 'application/json', ...(options.headers || {}) } });
      let body = null;
      try { body = await res.json(); } catch (_) { body = null; }
      if (!res.ok) throw new Error((body && (body.error || body.message)) || `HTTP ${res.status}`);
      return body || {};
    }

    ctx(extra) {
      return { fetchJson: (u, o) => this.fetchJson(u, o), escapeHtml: esc, auth: this.auth,
               navigation: window.app && window.app.navigation, ...extra };
    }

    shell() {
      if (!document.getElementById('sb-style')) {
        const st = document.createElement('style');
        st.id = 'sb-style';
        st.textContent = CSS;
        document.head.appendChild(st);
      }
      this.host.innerHTML = `
        <div id="sb-head" hidden></div>
        <div id="sb-modal" hidden>
          <div class="sb-sheet" role="dialog" aria-modal="true" aria-labelledby="sb-sheet-title">
            <div class="sb-sheet-head"><span class="sb-sheet-title" id="sb-sheet-title"></span><button type="button" class="sb-sheet-x" data-sb-close aria-label="Close">✕</button></div>
            <div class="sb-sheet-body">
              <div data-sb-panel="rsvp" id="sb-need" hidden></div>
              <div data-sb-panel="chat" hidden><div id="sb-chat"></div></div>
              <div data-sb-panel="volunteer" hidden><div id="sb-vol"></div></div>
              <div data-sb-panel="fines" hidden><div id="sb-fines" hidden></div></div>
              <div data-sb-panel="alerts" hidden><div id="sb-alerts"></div></div>
              <div data-sb-panel="menu" id="sb-menu" hidden></div>
              <div data-sb-panel="onboarding" hidden><div id="sb-onb"></div></div>
              <div data-sb-panel="todo" hidden><div id="sb-todo"></div></div>
              <div data-sb-panel="welcome" hidden><div id="sb-welcome"></div></div>
            </div>
          </div>
        </div>`;
      this.bar = new StatusBar(this.$('#sb-head'), { escapeHtml: esc, onChip: (code) => this.onChip(code) });
      this.host.addEventListener('click', (e) => {
        // ✕, or a tap on the dimmed backdrop outside the sheet, closes.
        if (e.target.closest('[data-sb-close]') || e.target.id === 'sb-modal') { this.openPanel(null); return; }
        const pg = e.target.closest('[data-sb-page]');
        if (pg) {
          const it = this.currentPageItems()[Number(pg.getAttribute('data-sb-page'))];
          this.openPanel(null);
          if (it && it.run) it.run();
          return;
        }
        const link = e.target.closest('[data-sb-link]');
        if (link) { this.onLink(link.getAttribute('data-sb-link')); return; }
        const ans = e.target.closest('[data-sb-ans]');
        if (ans) { this.answer(Number(ans.getAttribute('data-sb-ev')), Number(ans.getAttribute('data-sb-person')) || 0, ans.getAttribute('data-sb-ans')); return; }
        const open = e.target.closest('[data-sb-event]');
        if (open) { this.openPanel(null); location.hash = `event/${open.getAttribute('data-sb-event')}`; }
      });
    }

    // A box's button: a link (Pay now) or its own panel, one open at a time.
    onChip(code) {
      if (code === 'calendar') {
        this.openPanel(null);
        const nav = window.app && window.app.navigation;
        if (nav) nav.goTo('calendar');
        return;
      }
      if (code === 'dues_owed' || code === 'dues_blocked') {
        const n = ((this.notices && this.notices.notices) || []).find(x => x && x.kind === 'dues' && /^https:\/\//.test(x.pay_url || ''));
        if (n) window.open(n.pay_url, '_blank', 'noopener');
        return;
      }
      if (!PANEL[code]) return;
      this.openPanel(this.bar.openCode === code ? null : code);
    }

    openPanel(code) {
      const panel = code ? PANEL[code] : null;
      this.bar.openCode = panel ? code : null;
      this.$('#sb-modal').hidden = !panel;
      this.host.querySelectorAll('[data-sb-panel]').forEach(p => { p.hidden = p.getAttribute('data-sb-panel') !== panel; });
      const titles = { rsvp: ['sheet_rsvp', '⚠️ Set your availability'], fines: ['sheet_fines', '⚖️ Your fines'], alerts: ['sheet_alerts', '🔔 Alerts'],
                       menu: ['sheet_menu', '☰ Menu'],
                       chat: ['sheet_chat', '💬 Chat'], volunteer: ['sheet_volunteer', '🙋 Volunteer'],
                       onboarding: ['sheet_onboarding', '🎓 Your path at Lighthouse'],
                       todo: ['sheet_todo', '✅ To do'],
                       welcome: ['sheet_welcome', '👋 New registrations — send a welcome'] };
      if (panel) this.$('#sb-sheet-title').textContent = cp(titles[panel][0], {}, titles[panel][1]);
      document.body.style.overflow = panel ? 'hidden' : '';
      if (panel && !this._escWired) {
        this._escWired = true;
        document.addEventListener('keydown', (e) => { if (e.key === 'Escape' && this.bar.openCode) this.openPanel(null); });
      }
      if (panel === 'chat' && this.chat) this.chat.markRead();
      if (panel === 'menu') this.renderMenu();
      if (panel === 'onboarding' && this.onbList) this.onbList.render();
      if (panel === 'welcome' && this.welcome) this.welcome.render();
      if (panel === 'todo' && this.todo) { this.todo.render(); setTimeout(() => this.$('#sb-todo [data-td-body]')?.focus(), 0); }
      if (panel === 'fines' && !this.finesPanel && window.FinesPanel) {
        this.finesPanel = new FinesPanel(this.$('#sb-fines'), this.ctx());
        this.finesPanel.load();
      }
      if (panel === 'alerts' && !this.alertsMounted && window.PushOptIn) {
        this.alertsMounted = true;
        window.PushOptIn.mount(this.$('#sb-alerts'), this.auth, {}).catch(() => {});
      }
      if (panel === 'volunteer' && !this.volCard && window.VolunteerShiftCard)
        this.volCard = VolunteerShiftCard.mount(this.$('#sb-vol'), (u, o) => this.fetchJson(u, o), { folded: false });
      this.bar.render();
    }

    // ☰ the viewer's menu (lib/viewer.js menuItems — PlayerViewer's short list,
    // CoachViewer / AdminViewer extend it).
    // 🎭 Exit view-as first while an admin views as someone — the orange bar
    // can be off-screen on a phone (owner 11/18 "on phone i am still elegbe
    // and there is no exit view as at top").
    menuItems() {
      const base = window.Viewer ? Viewer.account().menuItems() : [];
      return this.auth && this.auth.viewAsPersonId
        ? [{ code: 'exitviewas', tier: 'qlink_exit_view_as', fb: '🎭 Exit view-as' }, ...base] : base;
    }

    // The page's own items on top of ☰ (owner 11/18 "all the stuff under
    // graphic should go inside hamburger for game page"): a screen hands
    // [{ label, run }] tagged with its screen name; they show only while
    // that screen is up.  setPageItems(screen, []) clears.
    setPageItems(screen, items) {
      this.pageItems = { screen, items: items || [] };
      if (this.bar && this.bar.openCode === 'menu') this.renderMenu();
    }
    currentPageItems() {
      const pi = this.pageItems;
      if (!pi || pi.screen !== this.screen) return [];
      // A function = read fresh each time ☰ opens (labels that change with the week).
      return typeof pi.items === 'function' ? (pi.items() || []) : pi.items;
    }

    renderMenu() {
      const box = this.$('#sb-menu');
      if (!box) return;
      const page = this.currentPageItems();
      box.innerHTML = page.map((it, i) => `<button type="button" class="sb-menu-item" data-sb-page="${i}">${esc(it.label)}</button>`).join('')
        + (page.length ? '<div style="height:1px; background:rgba(255,255,255,0.15); margin:8px 0;"></div>' : '')
        + this.menuItems().map(it => `<button type="button" class="sb-menu-item ${it.code === 'signout' ? 'out' : ''}" data-sb-link="${esc(it.code)}">${esc(cp(it.tier, {}, it.fb))}</button>`).join('');
    }

    onLink(code) {
      const it = this.menuItems().find(x => x.code === code);
      if (!it) return;
      const nav = window.app && window.app.navigation;
      if (it.route) { this.openPanel(null); if (nav) nav.goTo(it.route); return; }
      if (code === 'exitviewas') { this.openPanel(null); this.auth.exitViewAs(); return; }
      if (code === 'signout') {
        this.openPanel(null);
        this.auth.logout();
        if (window.MainMenu) MainMenu.reset();
        if (nav) { nav.context = { user: null, role: null, team: null }; nav.updateContextHeader(); nav.goTo('login'); }
        return;
      }
      if (it.panel) this.openPanel(it.panel);
    }

    // The band's right end: 💬 then ☰.
    setChatHtml(html) { this.chatHtml = html; this.paintTail(); }
    // The band's right end: 📅 (PlayerViewer — home from anywhere), 💬, ☰.
    paintTail() {
      // Only away from the Calendar — there it would go nowhere (owner 11/18
      // "since it's only one it just disappears when they are [not] in event").
      const onCal = ['calendar', 'event-center', 'my', 'player-calendar'].includes(this.screen);
      const cal = window.Viewer && Viewer.account().showsCalendarButton && !onCal
        ? `<button type="button" class="sb-burger sb-cal" data-sb-chip="calendar" aria-label="${esc(cp('band_calendar', {}, '📅 Calendar'))}" title="${esc(cp('band_calendar', {}, '📅 Calendar'))}">📅</button>` : '';
      this.bar.setTail(`${cal}${this.chatHtml || ''}${this.burgerHtml()}`);
    }
    burgerHtml() {
      return `<button type="button" class="sb-burger" data-sb-chip="menu" aria-label="${esc(cp('sheet_menu', {}, '☰ Menu'))}">☰</button>`;
    }

    // An item that cleared (all answered …) closes its panel.
    set(code, data) {
      this.bar.set(code, data);
      const open = this.bar.openCode;
      // 🎓 onboarding stays open as its last step is sent — the person sees it go 🟡.
      if (!open || ['volunteer', 'chat_unread', 'fines', 'alerts', 'menu', 'onboarding', 'todo', 'welcome_owed'].includes(open)) return;   // panels that aren't band items
      const stillThere = open === 'rsvp_soon' || open === 'rsvp_open'
        ? (this.bar.has('rsvp_soon') || this.bar.has('rsvp_open')) : this.bar.has(open);
      if (!stillThere) this.openPanel(null);
      else if ((open === 'rsvp_soon' || open === 'rsvp_open') && !this.bar.has(open))   // the box changed code
        this.bar.openCode = this.bar.has('rsvp_soon') ? 'rsvp_soon' : 'rsvp_open';
    }

    // ✓ / ✗ right in the panel (POST /api/calendar/rsvp as the Calendar does).
    async answer(evId, personId, response) {
      const ev = this.events.find(x => x && Number(x.fh_event_id) === evId);
      const key = `${evId}:${personId || 'me'}`;
      if (!ev || this.saving.has(key)) return;
      this.saving.add(key); delete this.rsvpErr[key]; this.renderEvents();
      const payload = { fh_event_id: evId, response };
      if (personId) payload.person_id = personId;
      try {
        const body = await this.fetchJson('/api/calendar/rsvp', { method: 'POST', body: JSON.stringify(payload) });
        const got = (body && body.rsvp && body.rsvp.response) || response;
        if (!personId) ev.my_rsvp = got;
        else {
          const rows = Array.isArray(ev.rsvps) ? ev.rsvps : (ev.rsvps = []);
          const r = rows.find(x => x && Number(x.person_id) === personId);
          if (r) r.response = got; else rows.push({ person_id: personId, response: got });
        }
        if (body && body.sms_opt_in && window.SmsOptInAsk) SmsOptInAsk.show(body.sms_opt_in);
        if (body && body.reg_ask && window.RegAsk) RegAsk.show(body.reg_ask);
        window.dispatchEvent(new CustomEvent('fh:rsvp-changed', { detail: { source: 'banner' } }));
      } catch (err) {
        this.rsvpErr[key] = err.message || 'Could not save';
      } finally {
        this.saving.delete(key);
        this.renderEvents();
      }
    }

    async start() {
      if (this.started) return;
      this.started = true;
      this.shell();
      if (window.MessageCopy) await MessageCopy.load(this.auth).catch(() => {});

      // Dues (+ the volunteer button when he can volunteer) and the rules.
      // Data only: the notices render into an element that is never on the
      // page — the band's red box is the one dues line (owner 11/18 "we have
      // 2 pay now sections we just need the new one in red").
      this.notices = new NoticeStrip(document.createElement('div'), this.ctx());
      const noticesLoaded = this.notices.load().then(() => {
        const list = this.notices.notices || [];
        const dues = list.filter(n => n && n.kind === 'dues');
        const vol = list.find(n => n && n.kind === 'volunteer_shift' && (n.offer || n.pick));
        const extra = vol ? [{ code: 'volunteer', text: vol.pick ? cp('act_volunteer_pick', {}, '🙋 My volunteer slots ›') : cp('act_volunteer', {}, '🙋 Volunteer ›') }] : [];
        const sum = (l) => money(l.reduce((t, n) => t + (Number(n.balance) || 0), 0));
        const blocked = dues.filter(n => n.tier === 'banner'), owed = dues.filter(n => n.tier !== 'banner');
        this.set('dues_blocked', blocked.length ? { amount: sum(blocked), extra } : null);
        this.set('dues_owed', owed.length ? { amount: sum(owed), extra: blocked.length ? [] : extra } : null);
      });

      // 🎓 Onboarding (mig 1526): "⛔ Onboarding — N of M left [Finish ›]"
      // while a step is still to do; the popup is the checklist with its
      // links (owner 11/19 "shows on their calendar as outstanding items
      // like missing rsvps … but has actionable links").
      // The box names each step still to do (owner 11/19 "it should show each
      // one he has to do") — never {total}: the band uses that for RSVPs.
      const onbBox = (o) => {
        if (!o || !(Number(o.left) > 0)) return null;
        const todo = (o.steps || []).filter(s => s.required && (s.state === 'todo' || s.state === 'renew'));
        return { left: o.left, list: todo.map(s => s.short_label || s.label).join(' · ') };
      };
      this.onbList = window.OnboardingChecklist
        ? new OnboardingChecklist(this.$('#sb-onb'), this.ctx({ onChange: (o) => this.set('onboarding', onbBox(o)) })) : null;
      const onbLoaded = this.onbList
        ? this.fetchJson('/api/my/onboarding').then((b) => {
            this.onbList.set(b.onboarding || null);
            this.set('onboarding', onbBox(b.onboarding));
          }).catch(() => {})
        : Promise.resolve();

      // ✅ To do (mig 1570): "✅ To do — <each due item>  Open ›" while any is
      // due (owner 11/19 "a todo all my screens … a reminer every time i oepn
      // app"); stays open as items are ticked.  Re-read on focus / screen
      // change so a "Tomorrow 9 AM" item turns up without a reload.
      const todoBox = (d) => {
        const due = (d && d.todos || []).filter(t => t.due);
        return due.length ? { n: due.length, list: due.map(t => t.body).join(' · ') } : null;
      };
      this.todo = window.TodoPanel
        ? new TodoPanel(this.$('#sb-todo'), this.ctx({ onChange: (d) => this.set('todo', todoBox(d)) })) : null;
      const todoLoaded = this.todo ? this.todo.load() : Promise.resolve();
      this.todoAt = Date.now();

      // 👋 New registrations (mig 1599): "👋 Welcome — N new: names  Welcome ›"
      // for club/super admins until each one is welcomed (owner 11/20 "any
      // new registration show as a todo like missing rsvp … until i send
      // welcome").  A name opens their 📇 Contact with 👋 Welcome preselected.
      const welcomeBox = (list) => list && list.length
        ? { n: list.length, list: list.map(p => `${p.first_name || ''} ${p.last_name || ''}`.trim()).join(' · ') } : null;
      this.welcome = window.WelcomeDuePanel
        ? new WelcomeDuePanel(this.$('#sb-welcome'), this.ctx({ onChange: (l) => this.set('welcome_owed', welcomeBox(l)) })) : null;
      // Not awaited by the band: the read syncs LA first (seconds), the box joins when it lands.
      if (this.welcome) { this.welcomeAt = Date.now(); this.welcome.load(); }

      // 💬 Chat — always a box when the section has one: newest · N new.
      const chatOpen = () => this.bar.openCode === 'chat_unread';
      this.chat = new SectionChat(this.$('#sb-chat'), this.ctx({ isOpen: chatOpen, onSummary: (s) => {
        // 💬 a button at the band's right end, not a box (owner 11/18 "make chat
        // the 💬 button … a blinking button to read unread messages").
        const n = s && s.unread ? (s.capped ? `${s.unread}+` : s.unread) : 0;
        const tip = s && s.text ? `${s.text}${s.when ? ' · ' + s.when : ''}` : cp('sheet_chat', {}, '💬 Chat');
        // "it should say x unread too" → "show a number if unread and say x
        // unread" — 💬 with a count on the bubble + "3 unread", red, pulsing until opened.
        // Always "N unread" — "0 unread" once read, so it never confuses (owner 11/18).
        const words = cp('chat_btn_unread', { n: n || 0 }, `${n || 0} unread`);
        const who = (s && s.who) || cp('sheet_chat', {}, '💬 Chat'), msg = (s && s.msg) || '';
        this.setChatHtml(`<button type="button" class="sb-chat ${n ? 'unread' : ''}" data-sb-chip="chat_unread"
            title="${esc(tip)}" aria-label="${esc(n ? `💬 ${words} — ${who}: ${msg}` : `💬 ${who}: ${msg}`)}">
            <span class="sb-chat-i">💬${n ? `<span class="sb-chat-dot">${esc(n)}</span>` : ''}</span>
            <span class="sb-chat-t">
              <span class="sb-chat-top"><span class="sb-chat-who">${esc(who)}</span>${s && s.when ? `<span class="sb-chat-when">${esc(s.when)}</span>` : ''}<span class="sb-chat-n ${n ? '' : 'zero'}">${esc(words)}</span></span>
              ${msg ? `<span class="sb-chat-msg">${esc(msg)}</span>` : ''}
            </span>
          </button>`);
      } }));
      this.chat.start().catch(() => {});

      // The band draws once the notices AND the week are in — no green flash.
      Promise.all([noticesLoaded, onbLoaded, todoLoaded, this.loadEvents(true)])
        .then(() => this.bar.setRules(this.notices.statusItems || []));
      this.setChatHtml('');   // ☰ from the start; 💬 joins when the chat answers
      if (window.MainMenu) MainMenu.load(this.auth).then(() => this.paintTail()).catch(() => {});
      window.addEventListener('fh:rsvp-changed', (e) => { if (!(e.detail && e.detail.source === 'banner')) this.loadEvents(true); });
      window.addEventListener('focus', () => { this.loadEvents(false); this.loadTodos(); });
    }

    // The next 7 days: what is still unanswered (you + your kids), and any suspension.
    async loadEvents(force) {
      if (!this.started) return;
      if (!force && Date.now() - this.eventsAt < 20000) return;
      if (this.loadingEvents) return this.loadingEvents;
      this.eventsAt = Date.now();
      this.loadingEvents = (async () => {
        try {
          const body = await this.fetchJson(`/api/calendar/upcoming?start=${ymd(new Date())}&days=8`);
          this.events = Array.isArray(body && body.events) ? body.events : [];
        } catch (_) { /* keep what we had */ }
        this.renderEvents();
      })().finally(() => { this.loadingEvents = null; });
      return this.loadingEvents;
    }

    // This week only (Mon–Sun, from now on) and only what can be answered now:
    // RSVPs open (owner 11/18 "showing ones from next week and its saying
    // window not open … should only be this week and not old ones").
    renderEvents() {
      const now = Date.now();
      const sunday = new Date(); sunday.setHours(0, 0, 0, 0);
      sunday.setDate(sunday.getDate() + ((7 - sunday.getDay()) % 7) + 1);   // next Monday 00:00
      const horizon = sunday.getTime();
      const soonMs = this.bar.windowHours('rsvp_soon') * 3600000;
      const rows = [];
      let soon = 0, later = 0, suspended = 0, stake = 0;
      for (const ev of this.events) {
        if (!ev || ev.fh_event_id == null) continue;
        const at = new Date(ev.starts_at).getTime();
        if (!(at >= now && at < horizon) || ev.status === 'cancelled') continue;
        if (ev.my_suspension) suspended++;
        if (ev.rsvps_open_now === false) continue;   // not open yet — nothing to answer
        const who = [];   // [{ id: 0 = me | child person_id, name }]
        if (ev.my_rsvp_eligible === true && !ev.my_suspension && !ev.my_callin && ev.my_rsvp !== 'yes' && ev.my_rsvp !== 'no') who.push({ id: 0, name: '' });
        for (const c of (Array.isArray(ev.guardian_targets) ? ev.guardian_targets : [])) {
          if (!c || !c.person_id || c.suspension) continue;
          const r = (Array.isArray(ev.rsvps) ? ev.rsvps : []).find(x => x && Number(x.person_id) === Number(c.person_id));
          if (!r || (r.response !== 'yes' && r.response !== 'no')) who.push({ id: Number(c.person_id), name: String(c.name || '').split(' ')[0] || 'Your player' });
        }
        if (!who.length) continue;
        const isSoon = at - now <= soonMs;
        if (isSoon) soon += who.length; else later += who.length;
        const fine = ev.my_rsvp_fine_usd > 0 && who.some(w => !w.id) ? Number(ev.my_rsvp_fine_usd) : 0;
        stake += fine;
        // A game shows its arrival first, never a bare start (owner 11/18).
        const firstTime = window.EventLabels && EventLabels.isGame(ev) ? (EventLabels.times(ev)[0] || '') : '';
        const when = firstTime
          ? `${new Date(at).toLocaleDateString('en-US', { weekday: 'short' })} · ${firstTime}`
          : new Date(at).toLocaleString('en-US', { weekday: 'short', hour: 'numeric', minute: '2-digit' });
        const name = (window.EventLabels && EventLabels.title) ? EventLabels.title(ev) : (ev.summary || '');
        for (const w of who) {
          const key = `${ev.fh_event_id}:${w.id || 'me'}`;
          const busy = this.saving.has(key) ? 'disabled' : '';
          const ans = (resp, label) => `<button type="button" class="sb-ans ${resp}" ${busy} data-sb-ans="${resp}" data-sb-ev="${Number(ev.fh_event_id)}" data-sb-person="${w.id}"
              title="${resp === 'yes' ? 'Going' : 'Not going'}">${label}</button>`;
          rows.push(`<div class="sb-need-row ${isSoon ? 'soon' : ''}">
              <button type="button" class="sb-need-open" data-sb-event="${Number(ev.fh_event_id)}">
                <span style="font-weight:800; white-space:nowrap;">${esc(when)}</span>
                <span style="flex:1; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${esc(name)}${w.name ? ` · ${esc(w.name)}` : ''}</span>
                ${!w.id && fine ? `<span style="font-weight:800; color:#fca5a5; white-space:nowrap;">${esc(cp('need_row_fine', { amount: money(fine) }, `${money(fine)} fine`))}</span>` : ''}
              </button>
              ${ans('yes', '✓')}${ans('no', '✗')}
              ${this.rsvpErr[key] ? `<div class="sb-err">${esc(this.rsvpErr[key])}</div>` : ''}
            </div>`);
        }
      }
      const need = this.$('#sb-need');
      if (need) need.innerHTML = rows.length
        ? `<div class="sb-need-title">${esc(cp('need_how_short', {}, 'Tap ✓ going or ✗ not going — tap the event to open it'))}</div>${rows.join('')}` : '';
      const st = stake > 0 ? money(stake) : '';
      this.set('suspended', suspended ? { n: suspended } : null);
      this.set('rsvp_soon', soon ? { n: soon, stake: st } : null);
      this.set('rsvp_open', later ? { n: later, stake: st } : null);
    }

    // ✅ the to-do list again, ≥ 20 s apart (not while its popup is open — typing).
    loadTodos() {
      if (!this.todo || this.bar.openCode === 'todo' || Date.now() - (this.todoAt || 0) < 20000) return;
      this.todoAt = Date.now();
      this.todo.load();
      // 👋 a new LA registration turns up without a reload — ≥ 5 min apart (each read syncs LA).
      if (this.welcome && Date.now() - (this.welcomeAt || 0) > 300000) { this.welcomeAt = Date.now(); this.welcome.load(); }
    }

    show(on) { this.host.style.display = on ? '' : 'none'; }

    static onScreen(name) {
      const host = document.getElementById('status-banner');
      if (!host || !window.StatusBar) return;
      const auth = window.app && window.app.auth;
      const on = !!(auth && auth.isLoggedIn && auth.isLoggedIn()) && !HIDDEN_ON.has(name);
      if (!StatusBanner.instance) StatusBanner.instance = new StatusBanner(host);
      const sb = StatusBanner.instance;
      sb.show(on);
      if (!on) return;
      sb.screen = name;
      if (!sb.started) sb.start().catch((err) => console.warn('status banner failed (non-fatal):', err));
      else { sb.paintTail(); sb.loadEvents(false); sb.loadTodos(); }   // 📅 follows the screen (and the viewer once loaded)
    }
  }

  window.StatusBanner = StatusBanner;
})();
