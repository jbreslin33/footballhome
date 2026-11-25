// tickets.js — 🎟 #tickets: the gate and the ticket list (mig 1886).
//
// Gate pill (club admins + ticket_gate_staff): pick today's home game, then
//   • 📷 Scan — the phone camera reads a ticket's QR (BarcodeDetector where
//     the browser has it, jsQR on every frame otherwise, so iPhones work),
//     or type the code; the answer is a big ✅ Let in N / ❌ banner.
//   • +1 / −1 for people let in without a ticket.
//   • Sell at the gate — Cash / Venmo / Cash App / Zelle / Free, people,
//     amount, optional name + phone → a single-game ticket, let in on the
//     spot (the seller checks the payment on the buyer's phone first).
//   • Who is in, and the gate money by who sold it and how.
// Tickets pill (club admins): every ticket — LeagueApps orders pulled by
// TicketOrderSync, gate sales — with its private link /t/?k=<token> to copy.
// Wording = message_templates kind 'tickets'.
class TicketsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.pill = 'gate';
    this.games = []; this.sources = []; this.singlePrice = ''; this.isAdmin = false;
    this.eventId = null; this.summary = null; this.result = null;
    this.source = 'cash'; this.stream = null; this.scanTimer = null; this.busy = false;
  }

  _c(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('tickets', tier, tokens) : ''; }
  _e(t) { return this.escapeHtml(t); }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .tkt { max-width:640px; margin:0 auto; padding:10px 12px 40px; }
        .tkt .pills { display:flex; gap:6px; margin-bottom:10px; }
        .tkt .pill { padding:6px 16px; border-radius:999px; cursor:pointer; font-weight:700; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); min-height:0; min-width:0; }
        .tkt .pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .tkt .card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary); padding:12px; margin-bottom:12px; }
        .tkt h3 { margin:0 0 8px; font-size:1rem; }
        .tkt select, .tkt input { padding:8px 10px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); font-size:1rem; }
        .tkt select { width:100%; }
        .tkt button.big { width:100%; padding:14px; font-size:1.1rem; font-weight:800; border-radius:10px; border:0; background:var(--primary-color); color:#fff; cursor:pointer; }
        .tkt button.small { padding:6px 12px; border-radius:8px; border:1px solid var(--border-color); background:transparent; color:inherit; cursor:pointer; font-weight:700; }
        .tkt .row { display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin-top:8px; }
        .tkt .row input { flex:1; min-width:120px; }
        .tkt video { width:100%; border-radius:10px; margin-top:8px; background:#000; }
        .tkt .res { margin-top:10px; padding:16px; border-radius:12px; font-size:1.3rem; font-weight:900; text-align:center; }
        .tkt .res.ok { background:#14532d; color:#bbf7d0; } .tkt .res.no { background:#7f1d1d; color:#fecaca; }
        .tkt .res small { display:block; font-size:0.9rem; font-weight:600; margin-top:4px; opacity:0.9; }
        .tkt .counts { display:grid; grid-template-columns:repeat(3,1fr); gap:8px; text-align:center; }
        .tkt .counts b { display:block; font-size:1.6rem; }
        .tkt .counts span { font-size:0.75rem; opacity:0.75; }
        .tkt .walk { display:flex; gap:8px; justify-content:center; align-items:center; margin-top:10px; }
        .tkt .walk button { font-size:1.4rem; width:64px; height:48px; border-radius:10px; border:1px solid var(--border-color); background:var(--bg-primary); color:inherit; cursor:pointer; font-weight:900; }
        .tkt .methods { display:flex; gap:6px; flex-wrap:wrap; }
        .tkt .methods .pill { font-size:0.9rem; }
        .tkt .note { font-size:0.82rem; opacity:0.75; margin-top:6px; }
        .tkt table { width:100%; border-collapse:collapse; font-size:0.85rem; }
        .tkt td, .tkt th { padding:5px 6px; text-align:left; border-top:1px solid rgba(148,163,184,0.2); vertical-align:top; }
        .tkt th { border-top:0; opacity:0.65; font-size:0.72rem; text-transform:uppercase; }
        .tkt .err { color:#f87171; margin-top:6px; }
      </style>
      <div class="screen-content"><div class="tkt" id="tkt"></div></div>`;
    this.element = div;
    div.addEventListener('click', (e) => this._click(e));
    div.addEventListener('change', (e) => {
      if (e.target.id === 'tkt-game') { this.eventId = Number(e.target.value) || null; this.result = null; this._loadSummary(); }
    });
    div.addEventListener('keydown', (e) => {
      if (e.target.id === 'tkt-code' && e.key === 'Enter') { e.preventDefault(); this._scan(e.target.value); }
    });
    return div;
  }

  async onEnter() {
    if (window.MessageCopy) await MessageCopy.load(this.auth);
    await this._loadGames();
  }

  onExit() { this._stopCamera(); }

  async _get(url) {
    const res = await this.auth.fetch(url);
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  }

  async _post(url, body) {
    const res = await this.auth.fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  }

  async _loadGames() {
    try {
      const d = await this._get('/api/tickets/gate/games');
      this.games = d.games || []; this.sources = d.sources || [];
      this.singlePrice = d.singlePrice || ''; this.isAdmin = !!d.isAdmin;
      if (!this.games.some(g => g.id === this.eventId)) {
        const today = this.games.find(g => g.today) || this.games.find(g => new Date(g.kickoffAt) > new Date()) || this.games[0];
        this.eventId = today ? today.id : null;
      }
      this.error = '';
    } catch (err) { this.error = err.message; }
    if (this.eventId) await this._loadSummary(); else this._draw();
  }

  async _loadSummary() {
    if (!this.eventId) { this.summary = null; this._draw(); return; }
    try { this.summary = (await this._get(`/api/tickets/gate/summary?e=${this.eventId}`)).summary; this.error = ''; }
    catch (err) { this.error = err.message; }
    this._draw();
  }

  _when(iso) {
    const d = new Date(iso);
    return isNaN(d) ? '' : d.toLocaleString([], { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
  }

  _gameLabel(g) { return `${this._when(g.kickoffAt)} · ${[g.league, g.opponent ? 'v ' + g.opponent : ''].filter(Boolean).join(' ')}`; }

  _draw() {
    const body = this.find('#tkt');
    if (!body) return;
    const pills = this.isAdmin ? `<div class="pills">
        <button class="pill ${this.pill === 'gate' ? 'on' : ''}" data-pill="gate">${this._e(this._c('pill_gate'))}</button>
        <button class="pill ${this.pill === 'list' ? 'on' : ''}" data-pill="list">${this._e(this._c('pill_list'))}</button></div>` : '';
    const err = this.error ? `<div class="err">${this._e(this.error)}</div>` : '';
    body.innerHTML = pills + err + (this.pill === 'list' ? '<div id="tkt-list"></div>' : this._gate());
    if (this.pill === 'list') this._loadList();
  }

  _gate() {
    if (!this.games.length) return `<div class="card">${this._e(this._c('no_games'))}</div>`;
    const s = this.summary || { withTicket: 0, walkups: 0, money: [], scans: [] };
    const res = this.result;
    const resHtml = res ? `<div class="res ${res.ok ? 'ok' : 'no'}">${this._e(res.text)}${res.sub ? `<small>${this._e(res.sub)}</small>` : ''}</div>` : '';
    const methods = this.sources.map(m => `<button class="pill ${this.source === m.code ? 'on' : ''}" data-source="${this._e(m.code)}">${this._e(m.icon)} ${this._e(m.label)}</button>`).join('');
    const money = s.money.length ? `<table><tr><th></th><th></th><th>#</th><th>$</th></tr>${s.money.map(m =>
        `<tr><td>${this._e(m.seller)}</td><td>${this._e(m.icon)} ${this._e(m.method)}</td><td>${m.people}</td><td>$${this._e(m.amount)}</td></tr>`).join('')}</table>`
      : `<div class="note">${this._e(this._c('money_none'))}</div>`;
    const scans = s.scans.length ? `<table>${s.scans.map(x =>
        `<tr><td>${this._e(new Date(x.at).toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' }))}</td><td>${this._e(x.icon)} ${this._e(x.first)}</td><td>${this._e(x.product)}</td><td>+${x.admitted}</td></tr>`).join('')}</table>` : '';
    return `
      <div class="card">
        <h3>${this._e(this._c('pick_game'))}</h3>
        <select id="tkt-game">${this.games.map(g => `<option value="${g.id}" ${g.id === this.eventId ? 'selected' : ''}>${this._e(this._gameLabel(g))}</option>`).join('')}</select>
      </div>
      <div class="card">
        <button class="big" data-act="scan">${this._e(this.stream ? this._c('scan_stop') : this._c('scan'))}</button>
        <video id="tkt-video" playsinline muted ${this.stream ? '' : 'hidden'}></video>
        <div class="row"><input id="tkt-code" placeholder="${this._e(this._c('code_ph'))}" autocomplete="off"><button class="small" data-act="code">${this._e(this._c('code_go'))}</button></div>
        ${resHtml}
      </div>
      <div class="card">
        <h3>${this._e(this._c('count'))}</h3>
        <div class="counts">
          <div><b>${s.withTicket}</b><span>${this._e(this._c('count_tickets'))}</span></div>
          <div><b>${s.walkups}</b><span>${this._e(this._c('count_walkups'))}</span></div>
          <div><b>${s.withTicket + s.walkups}</b><span>${this._e(this._c('count_total'))}</span></div>
        </div>
        <div class="note" style="text-align:center;margin-top:10px;">${this._e(this._c('walkups'))}</div>
        <div class="walk"><button data-count="-1">−1</button><button data-count="1">+1</button></div>
      </div>
      <div class="card">
        <h3>${this._e(this._c('sell'))}</h3>
        <div class="methods">${methods}</div>
        <div class="row">
          <label>${this._e(this._c('sell_people'))} <input id="tkt-people" type="number" min="1" max="50" value="1" style="width:70px;flex:none;"></label>
          <label>${this._e(this._c('sell_amount'))} <input id="tkt-amount" type="number" min="0" step="0.5" placeholder="${this._e(this.singlePrice)}" style="width:90px;flex:none;"></label>
        </div>
        <div class="row"><input id="tkt-name" placeholder="${this._e(this._c('sell_name'))}"><input id="tkt-phone" type="tel" placeholder="${this._e(this._c('sell_phone'))}"></div>
        <div class="note">${this._e(this._c('sell_check'))}</div>
        <div class="row"><button class="big" data-act="sell">${this._e(this._c('sell_go'))}</button></div>
      </div>
      <div class="card"><h3>${this._e(this._c('money'))}</h3>${money}</div>
      ${scans ? `<div class="card">${scans}</div>` : ''}`;
  }

  async _click(e) {
    const pill = e.target.closest('[data-pill]');
    if (pill) { this._stopCamera(); this.pill = pill.dataset.pill; this._draw(); return; }
    const src = e.target.closest('[data-source]');
    if (src) { this.source = src.dataset.source; this.find('.methods').querySelectorAll('.pill').forEach(b => b.classList.toggle('on', b === src)); return; }
    const cnt = e.target.closest('[data-count]');
    if (cnt) {
      try { this.summary = (await this._post('/api/tickets/gate/count', { e: this.eventId, n: Number(cnt.dataset.count) })).summary; }
      catch (err) { this.error = err.message; }
      this._redrawKeepCamera(); return;
    }
    const copy = e.target.closest('[data-copy]');
    if (copy) { navigator.clipboard.writeText(copy.dataset.copy).then(() => { copy.textContent = this._c('copied'); }); return; }
    const act = e.target.closest('[data-act]');
    if (!act) return;
    if (act.dataset.act === 'scan') { if (this.stream) this._stopCamera(); else await this._startCamera(); this._redrawKeepCamera(); return; }
    if (act.dataset.act === 'code') { this._scan(this.find('#tkt-code').value); return; }
    if (act.dataset.act === 'sell') { this._sell(); return; }
    if (act.dataset.act === 'sync') { this._loadList(true); }
  }

  // Redraw the gate without losing the live camera feed.
  _redrawKeepCamera() {
    this._draw();
    const v = this.find('#tkt-video');
    if (v && this.stream) { v.srcObject = this.stream; v.hidden = false; v.play().catch(() => {}); }
  }

  async _scan(code) {
    code = String(code || '').trim();
    if (!code || this.busy || !this.eventId) return;
    this.busy = true;
    try {
      const d = await this._post('/api/tickets/gate/scan', { e: this.eventId, code });
      const s = d.scan || {};
      this.summary = d.summary || this.summary;
      const who = [s.holder, s.product].filter(x => x && x.trim()).join(' · ');
      if (s.result === 'ok') this.result = { ok: true, text: this._c('ok', { n: s.admitted }), sub: who };
      else this.result = { ok: false, text: this._c(s.result) || this._c('invalid'), sub: who };
      if (navigator.vibrate) navigator.vibrate(s.result === 'ok' ? 80 : [60, 60, 60]);
    } catch (err) { this.result = { ok: false, text: err.message }; }
    this.busy = false;
    this._redrawKeepCamera();
  }

  async _sell() {
    if (this.busy || !this.eventId) return;
    const people = Number(this.find('#tkt-people').value) || 1;
    this.busy = true;
    try {
      const d = await this._post('/api/tickets/gate/sell', {
        e: this.eventId, source: this.source, people,
        amount: this.find('#tkt-amount').value, name: this.find('#tkt-name').value.trim(), phone: this.find('#tkt-phone').value.trim(),
      });
      this.summary = d.summary || this.summary;
      this.result = { ok: true, text: this._c('sold', { n: d.sale.admitted }) };
    } catch (err) { this.result = { ok: false, text: err.message }; }
    this.busy = false;
    this._redrawKeepCamera();
  }

  // ── Camera ──────────────────────────────────────────────────────────────
  async _startCamera() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' }, audio: false });
    } catch (err) {
      this.stream = null;
      this.result = { ok: false, text: this._c('camera_none') };
      return;
    }
    const detector = ('BarcodeDetector' in window) ? new window.BarcodeDetector({ formats: ['qr_code'] }) : null;
    if (!detector && !window.jsQR) await this._loadJsQR();
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d', { willReadFrequently: true });
    let last = '', lastAt = 0;
    const tick = async () => {
      if (!this.stream) return;
      const v = this.find('#tkt-video');
      if (v && v.readyState >= 2 && !this.busy) {
        let text = '';
        try {
          if (detector) {
            const codes = await detector.detect(v);
            text = codes[0] ? codes[0].rawValue : '';
          } else if (window.jsQR) {
            canvas.width = v.videoWidth; canvas.height = v.videoHeight;
            ctx.drawImage(v, 0, 0);
            const img = ctx.getImageData(0, 0, canvas.width, canvas.height);
            const hit = window.jsQR(img.data, img.width, img.height, { inversionAttempts: 'dontInvert' });
            text = hit ? hit.data : '';
          }
        } catch (_) { text = ''; }
        // The same code held in front of the camera is read once every 4 s.
        if (text && (text !== last || Date.now() - lastAt > 4000)) { last = text; lastAt = Date.now(); await this._scan(text); }
      }
      this.scanTimer = setTimeout(tick, 250);
    };
    tick();
  }

  _loadJsQR() {
    return new Promise((resolve) => {
      const s = document.createElement('script');
      s.src = 'js/vendor/jsqr-1.4.0.js';
      s.onload = resolve; s.onerror = resolve;
      document.head.appendChild(s);
    });
  }

  _stopCamera() {
    if (this.scanTimer) clearTimeout(this.scanTimer);
    this.scanTimer = null;
    if (this.stream) this.stream.getTracks().forEach(t => t.stop());
    this.stream = null;
  }

  // ── Tickets list (club admins) ──────────────────────────────────────────
  async _loadList(sync = false) {
    const box = this.find('#tkt-list');
    if (!box) return;
    try {
      const d = await this._get(`/api/tickets/list${sync ? '?sync=1' : ''}`);
      const rows = d.tickets || [];
      const link = (t) => `${location.origin}/t/?k=${t.token}`;
      box.innerHTML = `<div class="card"><div class="row" style="margin-top:0;justify-content:space-between;">
          <span class="note" style="margin:0;">${this._e(this._c('list_synced'))}${d.sync && d.sync.error ? ' — ' + this._e(d.sync.error) : ''}</span>
          <button class="small" data-act="sync">↻</button></div></div>`
        + (rows.length ? `<div class="card"><table>${rows.map(t => `
          <tr>
            <td>${this._e(t.icon)}</td>
            <td><b>${this._e([t.first, t.last].join(' ').trim() || '—')}</b><br><span class="note">${this._e(t.product)}${t.opponent ? ' · v ' + this._e(t.opponent) : ''} · ${this._e(this._c('admits', { n: t.admits }))} · $${this._e(t.amount)}</span>
              ${t.email || t.phone ? `<br><span class="note">${this._e([t.phone, t.email].filter(Boolean).join(' · '))}</span>` : ''}</td>
            <td><a href="${this._e(link(t))}" target="_blank" rel="noopener">🎟</a><br><button class="small" data-copy="${this._e(link(t))}">${this._e(this._c('copy_link'))}</button></td>
          </tr>`).join('')}</table></div>` : `<div class="card">${this._e(this._c('list_empty'))}</div>`);
    } catch (err) { box.innerHTML = `<div class="card err">${this._e(err.message)}</div>`; }
  }
}
