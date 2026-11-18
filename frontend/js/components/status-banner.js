// StatusBanner — 🚦 the band at the very top of every screen, just under the
// admin's 🎭 view-as bar: everything outstanding in one line, green or red,
// and everything behind it one tap away (mig 1468/1469).
//
// Owner 2026-11-18: "this is where all the outstanding items should go.
// including unread messages, warning they have unset rsvp, dues, fines etc.
// then if all set on all it should show in green and say up to date" →
// "keep the extra view as for me lol and show the one i mentioned below it"
// → "really there prob is no yellow just green and red" → "its supposed to
// be just like the viewing as bar. everything in there".
//
// The band is StatusBar (lib/status-bar.js): headline + a chip per item;
// 'action' items (status_items) turn it red, 'info' items are grey chips.
// Details drop down from it:
//   ⚠️ unanswered events (next 7 days, with the fine riding on each) → tap opens the event
//   NoticeStrip   dues / volunteer (lib/notices.js)
//   💬 Chat bar   SectionChat folded (newest · N new · time)
//   ⚖️ Fines bar  FinesPanel folded (total · N fines)
// Loads once per sign-in, refreshes its events on every screen change
// (≥ 20 s apart), on 'fh:rsvp-changed', and on focus.  Under view-as every
// call carries X-View-As, so it is the viewed person's own bar.
//
//   StatusBanner.onScreen(name)   ScreenManager calls it after every show
(function () {
  const esc = (s) => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const cp = (tier, tokens, fb) => (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
    ? MessageCopy.block('event_center', tier, tokens) : fb;
  const money = (n) => `$${(Number(n) || 0).toFixed(2).replace(/\.00$/, '')}`;
  const ymd = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  const HIDDEN_ON = new Set(['login', 'oauth-success']);

  class StatusBanner {
    constructor(host) {
      this.host = host;
      this.started = false;
      this.events = [];
      this.eventsAt = 0;
      this.loadingEvents = null;
    }

    get auth() { return window.app && window.app.auth; }

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
        st.textContent = `
          #status-banner #sb-head[hidden], #status-banner #sb-body[hidden] { display:none !important; }
          #status-banner #sb-body { display:flex; flex-direction:column; gap:6px; padding:8px 12px 10px; max-height:70vh; overflow-y:auto;
                                    background:var(--bg-secondary, #111827); border-bottom:1px solid var(--border-color, #374151); text-align:left; }
          #status-banner .sb-need-title { font-weight:800; color:#fca5a5; font-size:0.85rem; }
          #status-banner .sb-need-row { display:flex; align-items:center; gap:8px; flex-wrap:wrap; width:100%; box-sizing:border-box; padding:7px 10px; border-radius:8px;
                                        border:1px solid #f59e0b; background:rgba(245,158,11,0.10); font-size:0.82rem; text-align:left; }
          #status-banner .sb-need-open { flex:1; min-width:160px; display:flex; gap:8px; align-items:center; cursor:pointer; background:none; border:0; color:inherit; font:inherit; padding:0; text-align:left; min-height:0; }
          #status-banner .sb-ans { min-width:44px; min-height:0; padding:5px 10px; border-radius:8px; font-weight:800; cursor:pointer; font:inherit; font-weight:800; }
          #status-banner .sb-ans.yes { border:1px solid #22c55e; background:transparent; color:#22c55e; }
          #status-banner .sb-ans.no  { border:1px solid #ef4444; background:transparent; color:#ef4444; }
          #status-banner .sb-ans:disabled { opacity:0.5; cursor:default; }
          #status-banner .sb-err { width:100%; font-size:0.74rem; color:#fca5a5; }
          #status-banner .sb-need-row.soon { border-color:#ef4444; background:rgba(239,68,68,0.12); }
          #status-banner .sb-fold-bar { display:flex; align-items:center; gap:8px; width:100%; min-height:0; padding:6px 10px; border-radius:8px; cursor:pointer;
                                        border:1px solid var(--border-color, #374151); background:rgba(15,23,42,0.55); color:inherit; font:inherit; font-size:0.8rem; text-align:left; }
          #status-banner .sb-fold-bar.hot { border-color:#ef4444; background:rgba(239,68,68,0.10); }
          #status-banner .sb-l { font-weight:800; white-space:nowrap; }
          #status-banner .sb-s { flex:1; min-width:0; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; opacity:0.85; }
          #status-banner .sb-fold-bar.hot .sb-s { color:#fca5a5; font-weight:800; opacity:1; }
          #status-banner .sb-m { display:inline-flex; align-items:center; gap:6px; }
          #status-banner .sb-c { opacity:0.7; }
          #status-banner .sb-when { font-size:0.7rem; opacity:0.7; white-space:nowrap; }
          #status-banner .sb-badge { font-size:0.68rem; font-weight:800; color:#fff; background:#ef4444; border-radius:999px; padding:1px 7px; white-space:nowrap; }
          #status-banner .sb-fold-body { margin-top:6px; }`;
        document.head.appendChild(st);
      }
      this.host.innerHTML = `
        <div id="sb-head" hidden></div>
        <div id="sb-body" hidden>
          <div id="sb-need"></div>
          <div id="sb-notices" style="display:none;"></div>
          <div id="sb-fold-chat" class="sb-fold" hidden>
            <button type="button" class="sb-fold-bar" data-sb-fold="chat"><span class="sb-l" id="sb-chat-l"></span><span class="sb-s" id="sb-chat-s"></span><span id="sb-chat-m" class="sb-m"></span><span class="sb-c">▾</span></button>
            <div class="sb-fold-body" hidden><div id="sb-chat"></div></div>
          </div>
          <div id="sb-fold-fines" class="sb-fold" hidden>
            <button type="button" class="sb-fold-bar" data-sb-fold="fines"><span class="sb-l" id="sb-fines-l"></span><span class="sb-s" id="sb-fines-s"></span><span id="sb-fines-m" class="sb-m"></span><span class="sb-c">▾</span></button>
            <div class="sb-fold-body" hidden><div id="sb-fines" hidden></div></div>
          </div>
        </div>`;
      const $ = (s) => this.host.querySelector(s);
      this.bar = new StatusBar($('#sb-head'), $('#sb-body'), { escapeHtml: esc, onChip: (code) => this.onChip(code) });
      this.rsvpErr = {};
      this.saving = new Set();
      this.host.addEventListener('click', (e) => {
        const bar = e.target.closest('[data-sb-fold]');
        if (bar) {
          const body = bar.parentElement.querySelector('.sb-fold-body');
          body.hidden = !body.hidden;
          bar.querySelector('.sb-c').textContent = body.hidden ? '▾' : '▴';
          if (!body.hidden && bar.getAttribute('data-sb-fold') === 'chat' && this.chat) this.chat.markRead();
          return;
        }
        const ans = e.target.closest('[data-sb-ans]');
        if (ans) { this.answer(Number(ans.getAttribute('data-sb-ev')), Number(ans.getAttribute('data-sb-person')) || 0, ans.getAttribute('data-sb-ans')); return; }
        const open = e.target.closest('[data-sb-event]');
        if (open) {
          this.bar.toggle(false);
          location.hash = `event/${open.getAttribute('data-sb-event')}`;
        }
      });
    }

    // A band button: do the thing (owner 11/18 "Overdue dues pay now button?
    // missing x rsvps do so below?").
    onChip(code) {
      const $ = (s) => this.host.querySelector(s);
      const openFold = (name) => {
        const body = $(`#sb-fold-${name} .sb-fold-body`);
        if (body && body.hidden) $(`#sb-fold-${name} .sb-fold-bar`).click();
        return $(`#sb-fold-${name}`);
      };
      if (code === 'dues_owed' || code === 'dues_blocked') {
        const n = ((this.notices && this.notices.notices) || []).find(x => x && x.kind === 'dues' && /^https:\/\//.test(x.pay_url || ''));
        if (n) { window.open(n.pay_url, '_blank', 'noopener'); return; }
        this.bar.toggle(true); $('#sb-notices').scrollIntoView({ block: 'nearest' }); return;
      }
      this.bar.toggle(true);
      const target = code === 'chat_unread' ? openFold('chat') : code === 'fines_owed' ? openFold('fines') : $('#sb-need');
      if (target) target.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }

    // ✓ / ✗ right in the list (POST /api/calendar/rsvp as the Calendar does).
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

    fold(name, label, sum, hot, meta = '') {
      const $ = (s) => this.host.querySelector(s);
      const box = $(`#sb-fold-${name}`);
      if (!box) return;
      box.hidden = false;
      $(`#sb-${name}-l`).textContent = label;
      $(`#sb-${name}-s`).textContent = sum || '';
      $(`#sb-${name}-m`).innerHTML = meta;
      box.querySelector('.sb-fold-bar').classList.toggle('hot', !!hot);
      this.bar.render();
    }

    async start() {
      if (this.started) return;
      this.started = true;
      this.shell();
      if (window.MessageCopy) await MessageCopy.load(this.auth).catch(() => {});
      const $ = (s) => this.host.querySelector(s);

      // Dues + volunteer notices, and the rules.
      this.notices = new NoticeStrip($('#sb-notices'), this.ctx());
      // The band draws once the notices AND the week are in — never a
      // green "All set" flash before the RSVPs land.
      const noticesLoaded = this.notices.load().then(() => {
        const dues = (this.notices.notices || []).filter(n => n && n.kind === 'dues');
        const sum = (list) => money(list.reduce((t, n) => t + (Number(n.balance) || 0), 0));
        const blocked = dues.filter(n => n.tier === 'banner'), owed = dues.filter(n => n.tier !== 'banner');
        this.bar.set('dues_blocked', blocked.length ? { amount: sum(blocked) } : null);
        this.bar.set('dues_owed', owed.length ? { amount: sum(owed) } : null);
      });

      // 💬 Chat — newest · N new · time.
      const chatOpen = () => { const b = $('#sb-fold-chat .sb-fold-body'); return !!(b && !b.hidden); };
      this.chat = new SectionChat($('#sb-chat'), this.ctx({ isOpen: chatOpen, onSummary: (s) => {
        const n = s && s.unread ? (s.capped ? `${s.unread}+` : String(s.unread)) : '';
        const meta = (n ? `<span class="sb-badge">${esc(cp('top_chat_unread', { n }, `${n} new`))}</span>` : '')
          + (s && s.when ? `<span class="sb-when">${esc(s.when)}</span>` : '');
        this.fold('chat', cp('top_chat', {}, '💬 Chat'), s ? s.text : '', false, meta);
        this.bar.set('chat_unread', n ? { n } : null);
      } }));
      this.chat.start().catch(() => {});

      // ⚖️ Fines — total · N fines (no bar without rates).
      new FinesPanel($('#sb-fines'), this.ctx({ onSummary: (s) => {
        this.bar.set('fines_owed', s && s.total > 0 ? { amount: s.amount } : null);
        if (!s) { $('#sb-fold-fines').hidden = true; this.bar.render(); return; }
        this.fold('fines', cp('top_fines', {}, '⚖️ Fines'),
          s.total > 0 ? (s.count === 1 ? cp('top_fines_one', { amount: s.amount }, `${s.amount} · 1 fine`)
                                       : cp('top_fines_many', { amount: s.amount, n: s.count }, `${s.amount} · ${s.count} fines`))
                      : cp('top_fines_none', {}, 'None — keep it that way'), s.total > 0);
      } })).load();

      Promise.all([noticesLoaded, this.loadEvents(true)])
        .then(() => this.bar.setRules(this.notices.statusItems || []));
      window.addEventListener('fh:rsvp-changed', (e) => { if (!(e.detail && e.detail.source === 'banner')) this.loadEvents(true); });
      window.addEventListener('focus', () => this.loadEvents(false));
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
          this.events = Array.isArray(body && body.events) ? body.events : (Array.isArray(body) ? body : []);
        } catch (_) { /* keep what we had */ }
        this.renderEvents();
      })().finally(() => { this.loadingEvents = null; });
      return this.loadingEvents;
    }

    renderEvents() {
      const now = Date.now(), horizon = now + 7 * 86400000;
      const soonMs = this.bar.windowHours('rsvp_soon') * 3600000;
      const rows = [];
      let soon = 0, later = 0, suspended = 0, stake = 0;
      for (const ev of this.events) {
        if (!ev || ev.fh_event_id == null) continue;
        const at = new Date(ev.starts_at).getTime();
        if (!(at >= now && at < horizon) || ev.status === 'cancelled') continue;
        if (ev.my_suspension) suspended++;
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
        const when = new Date(at).toLocaleString('en-US', { weekday: 'short', hour: 'numeric', minute: '2-digit' });
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
      const need = this.host.querySelector('#sb-need');
      if (need) need.innerHTML = rows.length
        ? `<div class="sb-need-title">${esc(cp('need_title', {}, '⚠️ Set your availability — tap ✓ going or ✗ not going'))}</div>${rows.join('')}` : '';
      const st = stake > 0 ? money(stake) : '';
      this.bar.set('suspended', suspended ? { n: suspended } : null);
      this.bar.set('rsvp_soon', soon ? { n: soon, stake: st } : null);
      this.bar.set('rsvp_open', later ? { n: later, stake: st } : null);
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
      if (!sb.started) sb.start().catch((err) => console.warn('status banner failed (non-fatal):', err));
      else sb.loadEvents(false);
    }
  }

  window.StatusBanner = StatusBanner;
})();
