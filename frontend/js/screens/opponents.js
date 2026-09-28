// OpponentsScreen — #opponents — who to text or email at the clubs we play.
// (owner 2026-09-28: "a messaging system for opponents. so its easy to text
// or email them same way we do rsvp reminders … a contact page … break it
// down by division and conference so its not a big mess. also youth break
// down u8, u10 etc … same for women").
//
// Backed by /api/opponents (backend/src/controllers/OpponentsController.cpp,
// migration 483).  Two pill rows: the league (APSL, CASA, TCWSL, a youth
// league…) then its division / conference / age band.  One card per club
// with its contacts; ✉️ and 💬 open Gmail or the phone's messages with the
// chosen message filled in, and every tap is logged (club_contact_messages).
// Prospects — clubs we are recruiting, not playing — sit behind their own
// pill.  Club admins only; the same contacts show in Game Center for the
// coaches of a game.  Copy and messages are message_templates kind='opponent'.
class OpponentsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.board = null;
    this.league = '';       // selected league_label, or '__prospects'
    this.division = '';     // selected division_label ('' = all in the league)
    this.search = '';
    this.tier = 'general';
    this.loading = false; this.error = null; this.flash = ''; this.flashBad = false;
    this.editContact = 0;   // contact id with the inline form open
    this.addContactFor = 0; // club id with the add-contact form open
    this.addTo = null;      // {league, division} with the add-club form open
    this.showAddGroup = false;
    this.confirmDelete = 0;
    this.focusClub = 0;     // params.clubId — open that club's group
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .op-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase; letter-spacing:0.05em; opacity:0.6; }
        .op-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:8px; }
        .op-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .op-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .op-pill.sub { font-size:0.82rem; padding:6px 12px; }
        .op-pill .n { opacity:0.6; font-weight:500; margin-left:4px; }
        .op-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary); padding:12px 14px; margin-bottom:var(--space-2); }
        .op-card.focus { outline:2px solid var(--primary-color); }
        .op-head { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .op-head img { width:36px; height:36px; object-fit:contain; border-radius:6px; background:#fff; }
        .op-head .nm { font-weight:800; font-size:1rem; flex:1; min-width:140px; }
        .op-tag { font-size:0.72rem; padding:2px 8px; border-radius:999px; border:1px solid var(--border-color); opacity:0.85; white-space:nowrap; }
        .op-meta { display:grid; grid-template-columns:repeat(auto-fit, minmax(160px, 1fr)); gap:6px; margin-top:8px; }
        .op-lbl { font-size:0.68rem; opacity:0.6; text-transform:uppercase; letter-spacing:0.04em; }
        .op-in { padding:7px 8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); font-size:0.88rem; width:100%; min-width:0; box-sizing:border-box; }
        .op-contact { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:8px 0; border-top:1px solid var(--border-color); font-size:0.9rem; }
        .op-contact:first-of-type { border-top:0; }
        .op-contact .who { flex:1; min-width:160px; }
        .op-contact .who small { opacity:0.65; }
        .op-contact .addr { font-size:0.8rem; opacity:0.75; overflow-wrap:anywhere; }
        .op-btn { padding:7px 12px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.85rem; color:#0b1c3d; background:#4ade80; }
        .op-btn.alt { background:var(--primary-color); color:#fff; }
        .op-btn.sm { padding:5px 9px; font-size:0.78rem; }
        .op-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .op-btn.danger { background:transparent; color:#f87171; border:1px solid #f87171; }
        .op-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .op-form { display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:6px; margin-top:8px; align-items:end; }
        .op-form .wide { grid-column:1 / -1; }
        .op-sent { font-size:0.72rem; opacity:0.6; }
        .op-flash { padding:8px 12px; border-radius:10px; margin:8px 0; background:rgba(74,222,128,0.15); font-size:0.88rem; }
        .op-flash.bad { background:rgba(248,113,113,0.15); }
        .op-hint { font-size:0.8rem; opacity:0.7; margin:4px 0 8px; }
        .op-top { display:flex; gap:8px; align-items:center; flex-wrap:wrap; margin:8px 0; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="op-back">← Back</button>
        <div style="flex:1;">
          <h1 style="margin:0;">📇 Opponents</h1>
          <div id="op-subtitle" style="font-size:0.85rem; opacity:0.75;"></div>
        </div>
      </div>
      <div class="screen-content" id="op-body"></div>`;
    this.element = div;
    div.querySelector('#op-back').addEventListener('click', () => this.navigation.goBack());
    this._wire(div);
    return div;
  }

  onEnter(params = {}) {
    this.focusClub = Number(params.clubId || 0) || 0;
    this.load();
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('opponent', tier, tokens) : ''; }
  _say(text, bad = false) { this.flash = text; this.flashBad = bad; this._renderBody(); }

  async load() {
    this.loading = true; this.error = null; this._renderBody();
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/opponents/board');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.board = body;
      const comps = body.competitions || [];
      if (this.focusClub) {
        const k = comps.find(c => c.club_id === this.focusClub && c.status === 'opponent') || comps.find(c => c.club_id === this.focusClub);
        if (k) { this.league = k.status === 'prospect' ? '__prospects' : k.league_label; this.division = k.division_label; }
      }
      const leagues = this._leagues();
      if (!this.league || (this.league !== '__prospects' && !leagues.includes(this.league))) { this.league = leagues[0] || ''; this.division = ''; }
    } catch (err) { this.board = null; this.error = err.message || 'Failed to load.'; }
    this.loading = false;
    const sub = this.find('#op-subtitle'); if (sub) sub.textContent = this._copy('subtitle');
    this._renderBody();
    if (this.focusClub) { const el = this.find(`[data-club-card="${this.focusClub}"]`); if (el) el.scrollIntoView({ block: 'center' }); }
  }

  async _post(path, payload) {
    const res = await this.auth.fetch(path, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload || {}) });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }
  async _delete(path) {
    const res = await this.auth.fetch(path, { method: 'DELETE' });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  // ── grouping ──────────────────────────────────────────────────────────
  _comps() { return (this.board?.competitions || []); }
  _leagues() {
    const seen = [];
    for (const c of this._comps()) if (c.status === 'opponent' && !seen.includes(c.league_label)) seen.push(c.league_label);
    return seen;
  }
  _divisions(league) {
    const seen = [];
    for (const c of this._comps()) {
      const ok = league === '__prospects' ? c.status === 'prospect' : (c.status === 'opponent' && c.league_label === league);
      if (ok && !seen.includes(c.division_label)) seen.push(c.division_label);
    }
    // U8 before U10 before U12; otherwise as named.
    const ageOf = (d) => { const m = /^U(\d+)/i.exec(d); return m ? Number(m[1]) : null; };
    return seen.sort((a, b) => { const x = ageOf(a), y = ageOf(b); return x != null && y != null ? x - y : (x != null ? -1 : (y != null ? 1 : 0)); });
  }
  _contactsFor(clubId, compId) {
    return (this.board?.contacts || []).filter(c => c.club_id === clubId && (!c.competition_id || c.competition_id === compId));
  }

  // ── events ────────────────────────────────────────────────────────────
  _wire(root) {
    root.addEventListener('click', async (e) => {
      const t = e.target;
      const pill = t.closest('[data-league]');
      if (pill) { this.league = pill.dataset.league; this.division = ''; this.addTo = null; this._renderBody(); return; }
      const dp = t.closest('[data-division]');
      if (dp) { this.division = dp.dataset.division === this.division ? '' : dp.dataset.division; this._renderBody(); return; }
      const send = t.closest('[data-send]');
      if (send) { await this.sendMessage(Number(send.dataset.contact), send.dataset.send, send); return; }
      const ed = t.closest('[data-edit-contact]');
      if (ed) { this.editContact = Number(ed.dataset.editContact) === this.editContact ? 0 : Number(ed.dataset.editContact); this.addContactFor = 0; this._renderBody(); return; }
      const del = t.closest('[data-delete-contact]');
      if (del) {
        const id = Number(del.dataset.deleteContact);
        if (this.confirmDelete !== id) { this.confirmDelete = id; this._renderBody(); return; }
        this.confirmDelete = 0;
        try { await this._delete(`/api/opponents/contact?id=${id}`); await this.load(); } catch (err) { this._say(err.message, true); }
        return;
      }
      const add = t.closest('[data-add-contact]');
      if (add) { this.addContactFor = Number(add.dataset.addContact) === this.addContactFor ? 0 : Number(add.dataset.addContact); this.editContact = 0; this._renderBody(); return; }
      const saveC = t.closest('[data-save-contact]');
      if (saveC) { await this.saveContact(saveC.closest('[data-contact-form]')); return; }
      const cancel = t.closest('[data-cancel-form]');
      if (cancel) { this.editContact = 0; this.addContactFor = 0; this.addTo = null; this.showAddGroup = false; this._renderBody(); return; }
      const addClub = t.closest('[data-add-club]');
      if (addClub) { this.addTo = { league: addClub.dataset.league, division: addClub.dataset.division }; this._renderBody(); return; }
      const saveClub = t.closest('[data-save-club]');
      if (saveClub) { await this.saveClub(saveClub.closest('[data-club-form]')); return; }
      if (t.closest('#op-add-group')) { this.showAddGroup = !this.showAddGroup; this.addTo = null; this._renderBody(); return; }
      const saveAlias = t.closest('[data-save-alias]');
      if (saveAlias) {
        const inp = saveAlias.parentElement.querySelector('input'); const alias = inp ? inp.value.trim() : '';
        if (!alias) return;
        try { await this._post('/api/opponents/alias', { club_id: Number(saveAlias.dataset.saveAlias), alias }); this._say(`"${alias}" now points at this club.`); } catch (err) { this._say(err.message, true); }
        return;
      }
      const link = t.closest('[data-goto-logos]');
      if (link) { this.navigation.goTo('logos'); return; }
    });
    root.addEventListener('change', async (e) => {
      const t = e.target;
      if (t.id === 'op-tier') { this.tier = t.value; return; }
      if (t.id === 'op-search') { this.search = t.value.trim().toLowerCase(); this._renderBody(); return; }
      const f = t.closest('[data-comp-field]');
      if (f) {
        try { await this._post('/api/opponents/competition', { id: Number(f.dataset.compId), [f.dataset.compField]: f.value.trim() }); await this.load(); }
        catch (err) { this._say(err.message, true); }
      }
    });
    root.addEventListener('input', (e) => {
      if (e.target.id === 'op-search') { this.search = e.target.value.trim().toLowerCase(); this._renderCards(); }
    });
  }

  async sendMessage(contactId, channel, btn) {
    const orig = btn.textContent; btn.disabled = true; btn.textContent = '⏳';
    try {
      const data = await this._post('/api/opponents/message', { contact_id: contactId, channel, tier: this.tier });
      const c = (this.board?.contacts || []).find(x => x.id === contactId);
      if (c) { c.last_sent_at = 'just now'; c.last_channel = channel; }
      if (channel === 'email') this.openGmailCompose(data.gmail_href);
      else window.location.href = data.sms_href;
      this._renderBody();
    } catch (err) { this._say(err.message, true); }
    finally { btn.disabled = false; btn.textContent = orig; }
  }

  async saveContact(form) {
    if (!form) return;
    const v = (k) => { const el = form.querySelector(`[data-f="${k}"]`); return el ? el.value.trim() : ''; };
    const payload = { id: Number(form.dataset.contactId || 0) || undefined, club_id: Number(form.dataset.clubId), competition_id: Number(v('scope') || 0) || undefined,
                      name: v('name'), role: v('role'), phone: v('phone'), email: v('email'), note: v('note') };
    try { await this._post('/api/opponents/contact', payload); this.editContact = 0; this.addContactFor = 0; await this.load(); }
    catch (err) { this._say(err.message, true); }
  }

  async saveClub(form) {
    if (!form) return;
    const v = (k) => { const el = form.querySelector(`[data-f="${k}"]`); return el ? el.value.trim() : ''; };
    const payload = { club_name: v('club'), league_label: v('league'), division_label: v('division'), status: v('status') || 'opponent', league_id: Number(v('league_id') || 0) || undefined };
    if (!payload.club_name) { this._say('Type the club name.', true); return; }
    try {
      const r = await this._post('/api/opponents/competition', payload);
      this.addTo = null; this.showAddGroup = false; this.league = payload.status === 'prospect' ? '__prospects' : payload.league_label; this.division = payload.division_label;
      this.focusClub = r.club_id || 0; this.addContactFor = r.club_id || 0;
      await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  // ── render ────────────────────────────────────────────────────────────
  _renderBody() {
    const body = this.find('#op-body'); if (!body) return;
    const esc = (t) => this.escapeHtml(t);
    if (this.loading && !this.board) { body.innerHTML = '<div class="loading">Loading…</div>'; return; }
    if (this.error) { body.innerHTML = `<div class="error-message">${esc(this.error)}</div>`; return; }
    if (!this.board) { body.innerHTML = ''; return; }
    const leagues = this._leagues();
    const prospects = this._comps().some(c => c.status === 'prospect');
    const count = (league) => new Set(this._comps().filter(c => league === '__prospects' ? c.status === 'prospect' : (c.status === 'opponent' && c.league_label === league)).map(c => c.club_id)).size;
    const tiers = this.board.tiers || [];
    body.innerHTML = `
      ${this.flash ? `<div class="op-flash ${this.flashBad ? 'bad' : ''}">${esc(this.flash)}</div>` : ''}
      <div class="op-pills">
        ${leagues.map(l => `<button class="op-pill ${this.league === l ? 'on' : ''}" data-league="${esc(l)}">${esc(l)}<span class="n">${count(l)}</span></button>`).join('')}
        ${prospects ? `<button class="op-pill ${this.league === '__prospects' ? 'on' : ''}" data-league="__prospects">${esc(this._copy('prospect_label') || 'Prospects')}<span class="n">${count('__prospects')}</span></button>` : ''}
        <button class="op-pill" id="op-add-group" title="Add a league, division or age group">＋</button>
      </div>
      <div class="op-pills" id="op-divisions"></div>
      ${this.showAddGroup ? this._addClubForm('', '') : ''}
      <div class="op-top">
        <input class="op-in" id="op-search" placeholder="Search club or contact" value="${esc(this.search)}" style="max-width:260px;">
        <label style="font-size:0.8rem; opacity:0.8;">Message:</label>
        <select class="op-in" id="op-tier" style="max-width:220px;">${tiers.map(t => `<option value="${esc(t.tier)}" ${t.tier === this.tier ? 'selected' : ''}>${esc(t.label)}</option>`).join('')}</select>
      </div>
      <div id="op-cards"></div>`;
    this._renderDivisions();
    this._renderCards();
    this.flash = '';
  }

  _renderDivisions() {
    const el = this.find('#op-divisions'); if (!el) return;
    const esc = (t) => this.escapeHtml(t);
    const divs = this._divisions(this.league);
    const n = (d) => new Set(this._comps().filter(c => c.division_label === d && (this.league === '__prospects' ? c.status === 'prospect' : (c.status === 'opponent' && c.league_label === this.league))).map(c => c.club_id)).size;
    el.innerHTML = divs.length > 1 ? `<button class="op-pill sub ${!this.division ? 'on' : ''}" data-division="">All</button>` + divs.map(d => `<button class="op-pill sub ${this.division === d ? 'on' : ''}" data-division="${esc(d)}">${esc(d)}<span class="n">${n(d)}</span></button>`).join('') : '';
  }

  _renderCards() {
    const el = this.find('#op-cards'); if (!el) return;
    const esc = (t) => this.escapeHtml(t);
    const inLeague = (c) => this.league === '__prospects' ? c.status === 'prospect' : (c.status === 'opponent' && c.league_label === this.league);
    const divs = this._divisions(this.league).filter(d => !this.division || d === this.division);
    const q = this.search;
    const matches = (c) => !q || c.club_name.toLowerCase().includes(q) || this._contactsFor(c.club_id, c.id).some(k => `${k.name || ''} ${k.email || ''} ${k.phone || ''} ${k.role || ''}`.toLowerCase().includes(q));
    let html = '';
    for (const d of divs) {
      const comps = this._comps().filter(c => inLeague(c) && c.division_label === d && matches(c));
      const leagueLabel = this.league === '__prospects' ? (comps[0]?.league_label || 'CASA') : this.league;
      html += `<div class="op-sec" style="display:flex; justify-content:space-between; align-items:center;"><span>${esc(leagueLabel)} · ${esc(d)}</span>
                 <button class="op-btn ghost sm" data-add-club data-league="${esc(leagueLabel)}" data-division="${esc(d)}">＋ club</button></div>`;
      if (this.addTo && this.addTo.division === d && this.addTo.league === leagueLabel) html += this._addClubForm(leagueLabel, d);
      if (!comps.length) html += `<div class="op-hint">Nobody here${q ? ' matches the search' : ' yet'}.</div>`;
      for (const c of comps) html += this._card(c);
    }
    if (!divs.length) html = `<div class="op-hint">No clubs yet. Use ＋ to add a league, division or age group and its first club.</div>`;
    el.innerHTML = html;
  }

  _addClubForm(league, division) {
    const esc = (t) => this.escapeHtml(t);
    const leagues = this.board?.leagues || [];
    return `
      <div class="op-card" data-club-form>
        <div class="op-lbl">Add a club${league ? ` to ${esc(league)} · ${esc(division)}` : ', with its league and division or age group (e.g. EPYSA · U10)'}</div>
        <div class="op-form">
          <div><div class="op-lbl">Club</div><input class="op-in" data-f="club" placeholder="Club name (existing or new)"></div>
          <div><div class="op-lbl">League</div><input class="op-in" data-f="league" value="${esc(league)}" placeholder="APSL, CASA, TCWSL, EPYSA…"></div>
          <div><div class="op-lbl">Division / conference / age</div><input class="op-in" data-f="division" value="${esc(division)}" placeholder="Liga 1, Division II, U10…"></div>
          <div><div class="op-lbl">Status</div><select class="op-in" data-f="status"><option value="opponent">Opponent</option><option value="prospect">Prospect</option></select></div>
          <div><div class="op-lbl">League record (optional)</div><select class="op-in" data-f="league_id"><option value="">—</option>${leagues.map(l => `<option value="${l.id}">${esc(l.name)}</option>`).join('')}</select></div>
          <div style="display:flex; gap:6px;"><button class="op-btn" data-save-club>Add</button><button class="op-btn ghost" data-cancel-form>Cancel</button></div>
        </div>
      </div>`;
  }

  _card(c) {
    const esc = (t) => this.escapeHtml(t);
    const contacts = this._contactsFor(c.club_id, c.id);
    const field = (label, key, val, ph = '') => `<div><div class="op-lbl">${label}</div><input class="op-in" data-comp-field="${key}" data-comp-id="${c.id}" value="${esc(val || '')}" placeholder="${esc(ph)}"></div>`;
    const others = (this.board?.competitions || []).filter(k => k.club_id === c.club_id && k.id !== c.id).map(k => `${k.league_label} ${k.division_label}`);
    const contactRow = (k) => {
      if (this.editContact === k.id) return this._contactForm(c, k);
      const who = k.name ? `<b>${esc(k.name)}</b>${k.role ? ` <small>· ${esc(k.role)}</small>` : ''}` : `<b>${esc(k.role || 'Team mailbox')}</b>`;
      const scope = k.competition_id ? `<small style="opacity:0.6;"> (this team)</small>` : '';
      return `
        <div class="op-contact">
          <div class="who">${who}${scope}
            <div class="addr">${k.phone ? esc(k.phone) : ''}${k.phone && k.email ? ' · ' : ''}${k.email ? esc(k.email) : ''}${k.note ? ` · <i>${esc(k.note)}</i>` : ''}</div>
            ${k.last_sent_at ? `<div class="op-sent">Last ${k.last_channel === 'sms' ? 'text' : 'email'} ${esc(k.last_sent_at)}</div>` : ''}
          </div>
          <button class="op-btn sm" data-send="sms" data-contact="${k.id}" ${k.phone ? '' : 'disabled'} title="${k.phone ? 'Text' : 'No phone'}">💬 Text</button>
          <button class="op-btn sm alt" data-send="email" data-contact="${k.id}" ${k.email ? '' : 'disabled'} title="${k.email ? 'Email' : 'No email'}">✉️ Email</button>
          <button class="op-btn sm ghost" data-edit-contact="${k.id}" title="Edit">✏️</button>
          <button class="op-btn sm ${this.confirmDelete === k.id ? 'danger' : 'ghost'}" data-delete-contact="${k.id}" title="Remove">${this.confirmDelete === k.id ? 'Sure?' : '✕'}</button>
        </div>`;
    };
    return `
      <div class="op-card ${this.focusClub === c.club_id ? 'focus' : ''}" data-club-card="${c.club_id}">
        <div class="op-head">
          ${c.logo_url ? `<img src="${esc(c.logo_url)}" alt="">` : `<span style="width:36px; height:36px; display:inline-flex; align-items:center; justify-content:center; opacity:0.4;">🛡️</span>`}
          <span class="nm">${esc(c.club_name)}</span>
          ${c.status === 'prospect' ? `<span class="op-tag">${esc(c.league_label)} · ${esc(c.division_label)}</span>` : ''}
          ${others.map(o => `<span class="op-tag" title="Also plays in">${esc(o)}</span>`).join('')}
          ${c.external_url ? `<a class="op-tag" href="${esc(c.external_url)}" target="_blank" rel="noopener">league page ↗</a>` : ''}
          ${c.last_sent ? `<span class="op-sent">last message ${esc(c.last_sent)}</span>` : ''}
        </div>
        <div class="op-meta">
          ${field('Our lead', 'lead_name', c.lead_name, 'who talks to them')}
          ${field('Last contacted', 'last_contacted', c.last_contacted, 'e.g. JB called 9/28')}
          ${field('Home field', 'home_field', c.home_field)}
          ${field('Notes', 'notes', c.notes)}
          <div><div class="op-lbl">Status</div><select class="op-in" data-comp-field="status" data-comp-id="${c.id}">
            ${['opponent', 'prospect', 'inactive'].map(s => `<option value="${s}" ${c.status === s ? 'selected' : ''}>${s[0].toUpperCase() + s.slice(1)}</option>`).join('')}</select></div>
        </div>
        <div style="margin-top:8px;">
          ${contacts.length ? contacts.map(contactRow).join('') : `<div class="op-hint">${esc(this._copy('no_contacts') || 'No contact yet.')}</div>`}
          ${this.addContactFor === c.club_id ? this._contactForm(c, null) : `<div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:6px; align-items:center;">
            <button class="op-btn sm ghost" data-add-contact="${c.club_id}">＋ contact</button>
            <span style="display:inline-flex; gap:4px; align-items:center;"><input class="op-in" placeholder="Schedule spelling → alias" style="width:190px; padding:5px 8px; font-size:0.78rem;"><button class="op-btn sm ghost" data-save-alias="${c.club_id}" title="Link the name the schedule uses to this club">link</button></span>
            ${c.logo_url ? '' : `<button class="op-btn sm ghost" data-goto-logos title="Add a crest on the Logos page">crest</button>`}
          </div>`}
        </div>
      </div>`;
  }

  _contactForm(c, k) {
    const esc = (t) => this.escapeHtml(t);
    const v = (key) => esc((k && k[key]) || '');
    return `
      <div class="op-form" data-contact-form data-club-id="${c.club_id}" data-contact-id="${k ? k.id : 0}">
        <div><div class="op-lbl">Name</div><input class="op-in" data-f="name" value="${v('name')}"></div>
        <div><div class="op-lbl">Role</div><input class="op-in" data-f="role" value="${v('role')}" placeholder="Manager, Coach, Captain…"></div>
        <div><div class="op-lbl">Phone</div><input class="op-in" data-f="phone" type="tel" value="${v('phone')}"></div>
        <div><div class="op-lbl">Email</div><input class="op-in" data-f="email" type="email" value="${v('email')}"></div>
        <div><div class="op-lbl">Note</div><input class="op-in" data-f="note" value="${v('note')}"></div>
        <div><div class="op-lbl">For</div><select class="op-in" data-f="scope"><option value="">Whole club</option><option value="${c.id}" ${k && k.competition_id === c.id ? 'selected' : ''}>${esc(c.league_label)} ${esc(c.division_label)} only</option></select></div>
        <div style="display:flex; gap:6px;"><button class="op-btn" data-save-contact>Save</button><button class="op-btn ghost" data-cancel-form>Cancel</button></div>
      </div>`;
  }
}
window.OpponentsScreen = OpponentsScreen;
