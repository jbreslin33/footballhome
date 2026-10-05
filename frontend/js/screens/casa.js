// CASA commissioner section (mig 486) — owner 2026-09-28: "the piece for
// footballhome that is for me being casa commissioner … a whole casa
// commissioner section. that i hit casa and then there is more buttons".
//
//   #casa           the hub: tiles (Clubs & contacts, Schedule & standings,
//                   Scores to chase, Sent mail) — add a tile here for each new commissioner tool.
//   #casa-contacts  Liga 1 / Liga 2 clubs with their managers; ✉️/💬 per
//                   contact and one BCC email to a division or the league.
//   #casa-schedule  every game of the season (mig 488): division + Upcoming /
//                   Results / All / Table pills; GET /api/opponents/league-fixtures
//                   pulls the league's SportsEngine feed into league_fixtures on
//                   every open, so it is current and survives the feed being down.
//   #casa-scores    games already played with no score on the league site
//                   (mig 520): Text / Email per manager, logged per game.
//
// Everything mails from the league's address (leagues.correspondence_email,
// jbreslin@casasoccerleagues.com) — Gmail opens on that account (authuser),
// not the club's.  Data = club_competitions / club_contacts (mig 483) through
// GET /api/opponents/league?label=CASA; wording = message_templates kind 'casa'.
// Club admins only.

class CasaHubScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.data = null; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="ch-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="ch-title">⚽ CASA</h1><div id="ch-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" id="ch-body"><div class="loading">Loading…</div></div>`;
    this.element = div;
    div.querySelector('#ch-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => {
      const t = e.target.closest('[data-go]');
      if (t) { this.navigation.goTo(t.dataset.go, { league: 'CASA' }); return; }
    });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('casa', tier, tokens) : ''; }
  _tile(tier) { const t = window.MessageCopy && MessageCopy.render('casa', tier, {}); return t ? { label: t.subject, desc: t.body } : { label: tier, desc: '' }; }

  async load() {
    const body = this.find('#ch-body'); if (!body) return;
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/opponents/league?label=CASA');
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      this.data = data;
    } catch (err) { body.innerHTML = `<div class="error-message">${this.escapeHtml(err.message)}</div>`; return; }
    const esc = (t) => this.escapeHtml(t);
    const from = this.data.league?.correspondence_email || '';
    const title = this.find('#ch-title'); if (title) title.textContent = '⚽ ' + (this._copy('hub_title') || 'CASA');
    const sub = this.find('#ch-sub'); if (sub) sub.textContent = this._copy('hub_subtitle', { from_email: from });
    const divisions = [...new Set((this.data.competitions || []).map(c => c.division_label))];
    const clubs = new Set((this.data.competitions || []).map(c => c.club_id)).size;
    const fx = this.data.fixtures || {};
    const tile = (tier, go, extra = '') => { const t = this._tile(tier); return `
      <button class="btn btn-lg btn-primary" ${go ? `data-go="${go}"` : 'data-links'} style="display:flex; align-items:center; gap:var(--space-3); width:100%; text-align:left; margin-bottom:10px;">
        <span style="font-size:2rem;">${tier === 'tile_contacts' ? '📇' : tier === 'tile_links' ? '📅' : tier === 'tile_scores' ? '🥅' : '📤'}</span>
        <div style="flex:1;"><div style="font-weight:bold;">${esc(t.label)}</div><div style="font-size:0.85rem; opacity:0.8;">${esc(t.desc)}${extra}</div></div>
      </button>`; };
    const recent = (this.data.recent || []).slice(0, 8).map(r => `<li style="font-size:0.85rem;">${esc(r.sent_at)} — ${esc(r.tier.replace(/^all_|^one_/, '').replace(/_/g, ' '))} ${r.n > 1 ? `to ${r.n} addresses` : ''} (${esc(r.clubs.length > 90 ? r.clubs.slice(0, 90) + '…' : r.clubs)})</li>`).join('');
    body.innerHTML = `
      ${tile('tile_contacts', 'casa-contacts', ` · ${divisions.map(esc).join(', ')} · ${clubs} clubs`)}
      ${tile('tile_links', 'casa-schedule', fx.n ? ` · ${fx.n} games${fx.last_fetched_at ? ` · ${fx.fresh ? 'refreshed just now' : `from ${esc(fx.last_fetched_at)}`}` : ''}` : '')}
      ${tile('tile_scores', 'casa-scores', fx.waiting ? ` · ${fx.waiting} waiting` : '')}
      ${tile('tile_log', null)}
      <div style="margin:-4px 0 12px 8px;">${recent ? `<ul style="margin:0; padding-left:20px;">${recent}</ul>` : `<div style="font-size:0.85rem; opacity:0.7;">Nothing sent from ${esc(from)} yet.</div>`}</div>`;
  }
}

class CasaContactsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.division = ''; this.tier = ''; this.search = '';
    this.editContact = 0; this.addContactFor = 0; this.confirmDelete = 0; this.flash = ''; this.flashBad = false;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .cs-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:8px; align-items:center; }
        .cs-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .cs-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .cs-pill .n { opacity:0.6; font-weight:500; margin-left:4px; }
        .cs-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary); padding:12px 14px; margin-bottom:var(--space-2); }
        .cs-head { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .cs-head img { width:36px; height:36px; object-fit:contain; border-radius:6px; background:#fff; }
        .cs-head .nm { font-weight:800; font-size:1rem; flex:1; min-width:140px; }
        .cs-tag { font-size:0.72rem; padding:2px 8px; border-radius:999px; border:1px solid var(--border-color); opacity:0.85; white-space:nowrap; }
        .cs-contact { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:8px 0; border-top:1px solid var(--border-color); font-size:0.9rem; }
        .cs-contact:first-of-type { border-top:0; }
        .cs-contact .who { flex:1; min-width:160px; }
        .cs-contact .who small { opacity:0.65; }
        .cs-contact .addr { font-size:0.8rem; opacity:0.75; overflow-wrap:anywhere; }
        .cs-btn { padding:7px 12px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.85rem; color:#0b1c3d; background:#4ade80; }
        .cs-btn.alt { background:var(--primary-color); color:#fff; }
        .cs-btn.big { padding:10px 16px; font-size:0.95rem; }
        .cs-btn.sm { padding:5px 9px; font-size:0.78rem; }
        .cs-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .cs-btn.danger { background:transparent; color:#f87171; border:1px solid #f87171; }
        .cs-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .cs-in { padding:7px 8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); font-size:0.88rem; width:100%; min-width:0; box-sizing:border-box; }
        .cs-lbl { font-size:0.68rem; opacity:0.6; text-transform:uppercase; letter-spacing:0.04em; }
        .cs-form { display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:6px; margin-top:8px; align-items:end; }
        .cs-sent { font-size:0.72rem; opacity:0.6; }
        .cs-flash { padding:8px 12px; border-radius:10px; margin:8px 0; background:rgba(74,222,128,0.15); font-size:0.88rem; }
        .cs-flash.bad { background:rgba(248,113,113,0.15); }
        .cs-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase; letter-spacing:0.05em; opacity:0.6; }
        .cs-hint { font-size:0.8rem; opacity:0.7; margin:4px 0 8px; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="cs-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;">📇 CASA clubs & contacts</h1><div id="cs-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" id="cs-body"></div>`;
    this.element = div;
    div.querySelector('#cs-back').addEventListener('click', () => this.navigation.goBack());
    this._wire(div);
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('casa', tier, tokens) : ''; }
  _say(text, bad = false) { this.flash = text; this.flashBad = bad; this._renderBody(); }
  _from() { return this.data?.league?.correspondence_email || ''; }

  async load() {
    const body = this.find('#cs-body'); if (body && !this.data) body.innerHTML = '<div class="loading">Loading…</div>';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/opponents/league?label=CASA');
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      this.data = data;
      const tiers = data.tiers || [];
      if (!this.tier || !tiers.some(t => t.tier === this.tier)) this.tier = (tiers.find(t => t.tier.startsWith('all_')) || tiers[0] || {}).tier || '';
    } catch (err) { if (body) body.innerHTML = `<div class="error-message">${this.escapeHtml(err.message)}</div>`; return; }
    const sub = this.find('#cs-sub'); if (sub) sub.textContent = this._copy('contacts_subtitle', { from_email: this._from() });
    this._renderBody();
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

  _divisions() { return [...new Set((this.data?.competitions || []).map(c => c.division_label))]; }
  _contactsFor(clubId, compId) { return (this.data?.contacts || []).filter(c => c.club_id === clubId && (!c.competition_id || c.competition_id === compId)); }

  _wire(root) {
    root.addEventListener('click', async (e) => {
      const t = e.target;
      const dp = t.closest('[data-division]');
      if (dp) { this.division = dp.dataset.division; this._renderBody(); return; }
      const bcc = t.closest('[data-bcc]');
      if (bcc) { await this.emailAll(bcc); return; }
      const send = t.closest('[data-send]');
      if (send) { await this.sendOne(Number(send.dataset.contact), send.dataset.send, send); return; }
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
      if (t.closest('[data-cancel-form]')) { this.editContact = 0; this.addContactFor = 0; this._renderBody(); return; }
    });
    root.addEventListener('change', async (e) => {
      const t = e.target;
      if (t.id === 'cs-tier') { this.tier = t.value; this._renderBody(); return; }
      const f = t.closest('[data-comp-field]');
      if (f) { try { await this._post('/api/opponents/competition', { id: Number(f.dataset.compId), [f.dataset.compField]: t.value.trim() }); await this.load(); } catch (err) { this._say(err.message, true); } }
    });
    root.addEventListener('input', (e) => { if (e.target.id === 'cs-search') { this.search = e.target.value.trim().toLowerCase(); this._renderCards(); } });
  }

  // One Gmail draft, every club in scope BCC'd, from the league address.
  async emailAll(btn) {
    const tier = this.tier && this.tier.startsWith('all_') ? this.tier : ((this.data.tiers || []).find(t => t.tier.startsWith('all_')) || {}).tier;
    const orig = btn.textContent; btn.disabled = true; btn.textContent = '⏳';
    try {
      const data = await this._post('/api/opponents/group-message', { league_label: 'CASA', division_label: this.division, tier });
      const contacts = data.contacts || [];
      if (!contacts.length) throw new Error('No club in this scope has an email on file.');
      this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body, authuser: data.from_email || this._from() }));
      await this.load();
      this._say(this._copy('bcc_drafted', { n: contacts.length, clubs: data.clubs, skipped: data.skipped }) || `Draft open to ${contacts.length} addresses.`);
    } catch (err) { this._say(err.message, true); }
    finally { btn.disabled = false; btn.textContent = orig; }
  }

  async sendOne(contactId, channel, btn) {
    const tier = this.tier && this.tier.startsWith('one_') ? this.tier : ((this.data.tiers || []).find(t => t.tier.startsWith('one_')) || {}).tier;
    const orig = btn.textContent; btn.disabled = true; btn.textContent = '⏳';
    try {
      const data = await this._post('/api/opponents/message', { contact_id: contactId, channel, tier, kind: 'casa', league_label: 'CASA' });
      const c = (this.data?.contacts || []).find(x => x.id === contactId);
      if (c) { c.last_sent_at = 'just now'; c.last_channel = channel; }
      if (channel === 'email') this.openGmailCompose(this.buildGmailComposeHref({ to: data.contact, subject: data.subject, body: data.body, authuser: data.from_email || this._from() }));
      else window.location.href = data.sms_href;
      this._renderBody();
    } catch (err) { this._say(err.message, true); }
    finally { btn.disabled = false; btn.textContent = orig; }
  }

  async saveContact(form) {
    if (!form) return;
    const v = (k) => { const el = form.querySelector(`[data-f="${k}"]`); return el ? el.value.trim() : ''; };
    try {
      await this._post('/api/opponents/contact', { id: Number(form.dataset.contactId || 0) || undefined, club_id: Number(form.dataset.clubId), competition_id: Number(v('scope') || 0) || undefined,
                                                   name: v('name'), role: v('role'), phone: v('phone'), email: v('email'), note: v('note') });
      this.editContact = 0; this.addContactFor = 0; await this.load();
    } catch (err) { this._say(err.message, true); }
  }

  _renderBody() {
    const body = this.find('#cs-body'); if (!body || !this.data) return;
    const esc = (t) => this.escapeHtml(t);
    const divs = this._divisions();
    const n = (d) => new Set((this.data.competitions || []).filter(c => !d || c.division_label === d).map(c => c.club_id)).size;
    const tiers = this.data.tiers || [];
    const scope = this.division || 'Liga 1 & Liga 2';
    body.innerHTML = `
      ${this.flash ? `<div class="cs-flash ${this.flashBad ? 'bad' : ''}">${esc(this.flash)}</div>` : ''}
      <div class="cs-pills">
        <button class="cs-pill ${!this.division ? 'on' : ''}" data-division="">All<span class="n">${n('')}</span></button>
        ${divs.map(d => `<button class="cs-pill ${this.division === d ? 'on' : ''}" data-division="${esc(d)}">${esc(d)}<span class="n">${n(d)}</span></button>`).join('')}
      </div>
      <div class="cs-pills">
        <label style="font-size:0.8rem; opacity:0.8;">Message:</label>
        <select class="cs-in" id="cs-tier" style="max-width:260px;">
          <optgroup label="To all clubs (BCC)">${tiers.filter(t => t.tier.startsWith('all_')).map(t => `<option value="${esc(t.tier)}" ${t.tier === this.tier ? 'selected' : ''}>${esc(t.label)}</option>`).join('')}</optgroup>
          <optgroup label="To one contact">${tiers.filter(t => t.tier.startsWith('one_')).map(t => `<option value="${esc(t.tier)}" ${t.tier === this.tier ? 'selected' : ''}>${esc(t.label)}</option>`).join('')}</optgroup>
        </select>
        <button class="cs-btn alt big" data-bcc ${this.tier.startsWith('all_') ? '' : 'disabled'} title="${this.tier.startsWith('all_') ? '' : 'Pick an all-clubs message first'}">${esc(this._copy('bcc_button', { scope }) || `✉️ Email all ${scope} clubs (BCC)`)}</button>
        <input class="cs-in" id="cs-search" placeholder="Search club or contact" value="${esc(this.search)}" style="max-width:220px;">
      </div>
      <div class="cs-hint">From ${esc(this._from() || 'the club address')}. The per-contact ✉️ and 💬 buttons use the "one contact" messages.</div>
      <div id="cs-cards"></div>`;
    this._renderCards();
    this.flash = '';
  }

  _renderCards() {
    const el = this.find('#cs-cards'); if (!el) return;
    const esc = (t) => this.escapeHtml(t);
    const q = this.search;
    const divs = this._divisions().filter(d => !this.division || d === this.division);
    let html = '';
    for (const d of divs) {
      const comps = (this.data.competitions || []).filter(c => c.division_label === d && (!q || c.club_name.toLowerCase().includes(q) || this._contactsFor(c.club_id, c.id).some(k => `${k.name || ''} ${k.email || ''} ${k.phone || ''} ${k.role || ''}`.toLowerCase().includes(q))));
      html += `<div class="cs-sec">${esc(d)} · ${comps.length} clubs</div>`;
      for (const c of comps) html += this._card(c);
    }
    el.innerHTML = html || '<div class="cs-hint">No clubs match.</div>';
  }

  _card(c) {
    const esc = (t) => this.escapeHtml(t);
    const contacts = this._contactsFor(c.club_id, c.id);
    const field = (label, key, val, ph = '') => `<div><div class="cs-lbl">${label}</div><input class="cs-in" data-comp-field="${key}" data-comp-id="${c.id}" value="${esc(val || '')}" placeholder="${esc(ph)}"></div>`;
    const row = (k) => this.editContact === k.id ? this._contactForm(c, k) : `
      <div class="cs-contact">
        <div class="who">${k.name ? `<b>${esc(k.name)}</b>${k.role ? ` <small>· ${esc(k.role)}</small>` : ''}` : `<b>${esc(k.role || 'Team mailbox')}</b>`}
          <div class="addr">${[k.phone, k.email].filter(Boolean).map(esc).join(' · ')}${k.note ? ` · <i>${esc(k.note)}</i>` : ''}</div>
          ${k.last_sent_at ? `<div class="cs-sent">Last ${k.last_channel === 'sms' ? 'text' : 'email'} ${esc(k.last_sent_at)}</div>` : ''}
        </div>
        <button class="cs-btn sm" data-send="sms" data-contact="${k.id}" ${k.phone ? '' : 'disabled'}>💬 Text</button>
        <button class="cs-btn sm alt" data-send="email" data-contact="${k.id}" ${k.email ? '' : 'disabled'}>✉️ Email</button>
        <button class="cs-btn sm ghost" data-edit-contact="${k.id}" title="Edit">✏️</button>
        <button class="cs-btn sm ${this.confirmDelete === k.id ? 'danger' : 'ghost'}" data-delete-contact="${k.id}">${this.confirmDelete === k.id ? 'Sure?' : '✕'}</button>
      </div>`;
    return `
      <div class="cs-card">
        <div class="cs-head">
          ${c.logo_url ? `<img src="${esc(c.logo_url)}" alt="">` : '<span style="width:36px; display:inline-block;"></span>'}
          <span class="nm">${esc(c.club_name)}</span>
          ${c.external_url ? `<a class="cs-tag" href="${esc(c.external_url)}" target="_blank" rel="noopener">league page ↗</a>` : ''}
          ${c.last_sent ? `<span class="cs-sent">last mail ${esc(c.last_sent)}</span>` : ''}
        </div>
        <div class="cs-form" style="margin-top:6px;">${field('Last contacted', 'last_contacted', c.last_contacted, 'e.g. emailed 9/28')}${field('Home field', 'home_field', c.home_field)}${field('Notes', 'notes', c.notes)}</div>
        <div style="margin-top:8px;">
          ${contacts.length ? contacts.map(row).join('') : `<div class="cs-hint">No contact yet — add a name, phone or email.</div>`}
          ${this.addContactFor === c.club_id ? this._contactForm(c, null) : `<button class="cs-btn sm ghost" data-add-contact="${c.club_id}" style="margin-top:6px;">＋ contact</button>`}
        </div>
      </div>`;
  }

  _contactForm(c, k) {
    const esc = (t) => this.escapeHtml(t); const v = (key) => esc((k && k[key]) || '');
    return `
      <div class="cs-form" data-contact-form data-club-id="${c.club_id}" data-contact-id="${k ? k.id : 0}">
        <div><div class="cs-lbl">Name</div><input class="cs-in" data-f="name" value="${v('name')}"></div>
        <div><div class="cs-lbl">Role</div><input class="cs-in" data-f="role" value="${v('role')}" placeholder="Manager, Captain…"></div>
        <div><div class="cs-lbl">Phone</div><input class="cs-in" data-f="phone" type="tel" value="${v('phone')}"></div>
        <div><div class="cs-lbl">Email</div><input class="cs-in" data-f="email" type="email" value="${v('email')}"></div>
        <div><div class="cs-lbl">Note</div><input class="cs-in" data-f="note" value="${v('note')}"></div>
        <div><div class="cs-lbl">For</div><select class="cs-in" data-f="scope"><option value="">Whole club</option><option value="${c.id}" ${k && k.competition_id === c.id ? 'selected' : ''}>${esc(c.division_label)} team only</option></select></div>
        <div style="display:flex; gap:6px;"><button class="cs-btn" data-save-contact>Save</button><button class="cs-btn ghost" data-cancel-form>Cancel</button></div>
      </div>`;
  }
}

// ─── #casa-schedule — every game of the season, from the DB (mig 488) ───────
class CasaScheduleScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.data = null; this.division = ''; this.view = 'upcoming'; this.search = ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .cx-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:8px; align-items:center; }
        .cx-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .cx-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .cx-pill .n { opacity:0.6; font-weight:500; margin-left:4px; }
        .cx-in { padding:8px 10px; border-radius:10px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); font-size:0.9rem; }
        .cx-hint { font-size:0.8rem; opacity:0.7; margin:4px 0 8px; }
        .cx-stale { background:#fde68a; color:#3b2f00; border-radius:10px; padding:8px 12px; margin-bottom:10px; font-size:0.85rem; }
        .cx-day { font-weight:800; margin:14px 0 6px; font-size:0.95rem; opacity:0.85; }
        .cx-game { display:grid; grid-template-columns:64px 1fr auto; gap:6px 10px; align-items:center; border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary); padding:8px 12px; margin-bottom:6px; }
        .cx-game.ours { border-left:5px solid var(--primary-color); }
        .cx-time { font-weight:700; font-size:0.85rem; }
        .cx-teams { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
        .cx-teams img { width:22px; height:22px; object-fit:contain; border-radius:4px; }
        .cx-teams b { font-size:0.95rem; }
        .cx-teams a { color:inherit; text-decoration:none; }
        .cx-score { font-weight:900; font-size:1rem; padding:2px 8px; border-radius:8px; background:var(--bg-primary); border:1px solid var(--border-color); white-space:nowrap; }
        .cx-badge { font-size:0.72rem; font-weight:800; padding:2px 7px; border-radius:6px; background:#ef4444; color:#fff; text-transform:uppercase; }
        .cx-venue { grid-column:1 / -1; font-size:0.8rem; opacity:0.75; }
        .cx-div { font-size:0.72rem; opacity:0.6; margin-left:auto; }
        .cx-table { width:100%; border-collapse:collapse; font-size:0.88rem; margin-bottom:14px; }
        .cx-table th, .cx-table td { padding:6px 6px; border-bottom:1px solid var(--border-color); text-align:right; white-space:nowrap; }
        .cx-table th:nth-child(2), .cx-table td:nth-child(2) { text-align:left; width:100%; }
        .cx-table tr.ours td { font-weight:800; }
        .cx-table img { width:18px; height:18px; object-fit:contain; vertical-align:middle; margin-right:6px; }
        @media (max-width:520px) { .cx-game { grid-template-columns:56px 1fr auto; } }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="cx-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="cx-title">📅 CASA schedule</h1><div id="cx-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" id="cx-body"><div class="loading">Loading…</div></div>`;
    this.element = div;
    div.querySelector('#cx-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => {
      const d = e.target.closest('[data-division]'); if (d) { this.division = d.dataset.division; this._renderBody(); return; }
      const v = e.target.closest('[data-view]'); if (v) { this.view = v.dataset.view; this._renderBody(); return; }
    });
    div.addEventListener('input', (e) => { if (e.target.id === 'cx-search') { this.search = e.target.value.trim().toLowerCase(); this._renderList(); } });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('casa', tier, tokens) : ''; }

  async load() {
    const body = this.find('#cx-body'); if (body && !this.data) body.innerHTML = '<div class="loading">Loading…</div>';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/opponents/league-fixtures?label=CASA');
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      this.data = data;
    } catch (err) { if (body) body.innerHTML = `<div class="error-message">${this.escapeHtml(err.message)}</div>`; return; }
    const sm = this.data.summary || {};
    const title = this.find('#cx-title'); if (title) title.textContent = '📅 ' + (this._copy('schedule_title') || 'CASA schedule & results');
    const sub = this.find('#cx-sub'); if (sub) sub.textContent = this._copy('schedule_subtitle', { when: sm.fresh ? 'just now' : (sm.last_fetched_at || 'never'), n: sm.n || 0 });
    this._renderBody();
  }

  _ours(f) { const me = this.data.our_club_id; return f.home_club_id === me || f.away_club_id === me; }
  // A score is in once both numbers are there, even while SportsEngine still
  // calls the game scheduled (nobody marked it final yet).
  _scored(f) { return f.home_score !== null && f.away_score !== null && f.status !== 'postponed'; }
  _inScope(f) { return !this.division || f.division_label === this.division; }
  _matches(f) { const q = this.search; return !q || `${f.home_name} ${f.away_name} ${f.venue_name || ''}`.toLowerCase().includes(q); }

  _renderBody() {
    const body = this.find('#cx-body'); if (!body || !this.data) return;
    const esc = (t) => this.escapeHtml(t);
    const all = this.data.fixtures || [];
    const divs = this.data.divisions || [];
    const sm = this.data.summary || {};
    const n = (d) => all.filter(f => !d || f.division_label === d).length;
    const inScope = all.filter(f => this._inScope(f));
    const counts = { upcoming: inScope.filter(f => !f.past || f.status === 'postponed').length, results: inScope.filter(f => this._scored(f)).length, all: inScope.length };
    const views = [['upcoming', 'Upcoming'], ['results', 'Results'], ['all', 'All'], ['table', 'Table']];
    body.innerHTML = `
      ${sm.fresh === false && sm.last_fetched_at ? `<div class="cx-stale">${esc(this._copy('schedule_stale', { when: sm.last_fetched_at }) || `Showing the list from ${sm.last_fetched_at}.`)}${sm.note ? ` (${esc(sm.note)})` : ''}</div>` : ''}
      <div class="cx-pills">
        <button class="cx-pill ${!this.division ? 'on' : ''}" data-division="">All<span class="n">${n('')}</span></button>
        ${divs.map(d => `<button class="cx-pill ${this.division === d ? 'on' : ''}" data-division="${esc(d)}">${esc(d)}<span class="n">${n(d)}</span></button>`).join('')}
      </div>
      <div class="cx-pills">
        ${views.map(([k, l]) => `<button class="cx-pill ${this.view === k ? 'on' : ''}" data-view="${k}">${l}${k in counts ? `<span class="n">${counts[k]}</span>` : ''}</button>`).join('')}
        <input class="cx-in" id="cx-search" placeholder="Club or venue" value="${esc(this.search)}" style="max-width:200px;">
      </div>
      <div id="cx-list"></div>
      <div style="margin-top:18px;"><div class="cx-day">${esc(this._copy('schedule_links') || 'League pages')}</div>
        <ul style="margin:0; padding-left:20px; font-size:0.9rem;">
          ${(this.data.our_links || []).map(l => `<li><a href="${esc(l.url)}" target="_blank" rel="noopener">${esc(l.team)} — ${esc(l.label)}</a></li>`).join('')}
          ${this.data.league?.website_url ? `<li><a href="${esc(this.data.league.website_url)}" target="_blank" rel="noopener">${esc(this.data.league.name || 'League site')} ↗</a></li>` : ''}
        </ul></div>`;
    this._renderList();
  }

  _renderList() {
    const el = this.find('#cx-list'); if (!el) return;
    if (this.view === 'table') { el.innerHTML = this._tables(); return; }
    const esc = (t) => this.escapeHtml(t);
    let rows = (this.data.fixtures || []).filter(f => this._inScope(f) && this._matches(f));
    if (this.view === 'upcoming') rows = rows.filter(f => !f.past || f.status === 'postponed');
    else if (this.view === 'results') rows = rows.filter(f => this._scored(f)).reverse();
    if (!rows.length) { el.innerHTML = `<div class="cx-hint">${esc(this._copy('schedule_empty') || 'No games match.')}</div>`; return; }
    const team = (name, logo, url, cid) => `<span style="display:inline-flex; align-items:center; gap:6px;">${logo ? `<img src="${esc(logo)}" alt="">` : ''}<b>${url ? `<a href="${esc(url)}" target="_blank" rel="noopener">${esc(name)}</a>` : esc(name)}</b></span>`;
    let html = '', day = '';
    for (const f of rows) {
      if (f.date_key !== day) { day = f.date_key; html += `<div class="cx-day">${esc(f.date_label)}</div>`; }
      const done = this._scored(f);
      html += `
        <div class="cx-game ${this._ours(f) ? 'ours' : ''}">
          <div class="cx-time">${esc(f.time_label)}</div>
          <div class="cx-teams">${team(f.home_name, f.home_logo, f.home_url)}<span style="opacity:0.6;">v</span>${team(f.away_name, f.away_logo, f.away_url)}${!this.division ? `<span class="cx-div">${esc(f.division_label || '')}</span>` : ''}</div>
          <div>${done ? `<span class="cx-score">${f.home_score} – ${f.away_score}</span>${f.status !== 'completed' ? ` <span class="cx-badge" style="background:#f59e0b; color:#3b2f00;">${esc(this._copy('scores_not_final') || 'not final')}</span>` : ''}` : f.status !== 'scheduled' ? `<span class="cx-badge">${esc(f.status)}</span>` : ''}</div>
          ${f.venue_name ? `<div class="cx-venue">📍 ${esc(f.venue_name)}${f.venue_detail ? ` · ${esc(f.venue_detail)}` : ''}${f.venue_address ? ` · <a href="https://maps.google.com/?q=${encodeURIComponent(f.venue_address)}" target="_blank" rel="noopener" style="color:inherit; text-decoration:underline;">map</a>` : ''}</div>` : ''}
        </div>`;
    }
    el.innerHTML = html;
  }

  // Standings from completed games: 3/1/0, then goal difference, then goals
  // for (the league also applies head-to-head before GD; not modelled here).
  _tables() {
    const esc = (t) => this.escapeHtml(t);
    const divs = (this.data.divisions || []).filter(d => !this.division || d === this.division);
    let html = '';
    for (const d of divs) {
      const rows = new Map();
      const get = (name, cid, logo, url) => { if (!rows.has(name)) rows.set(name, { name, cid, logo, url, p: 0, w: 0, dr: 0, l: 0, gf: 0, ga: 0 }); return rows.get(name); };
      for (const f of (this.data.fixtures || []).filter(f => f.division_label === d)) {
        const h = get(f.home_name, f.home_club_id, f.home_logo, f.home_url), a = get(f.away_name, f.away_club_id, f.away_logo, f.away_url);
        if (!this._scored(f)) continue;
        h.p++; a.p++; h.gf += f.home_score; h.ga += f.away_score; a.gf += f.away_score; a.ga += f.home_score;
        if (f.home_score > f.away_score) { h.w++; a.l++; } else if (f.home_score < f.away_score) { a.w++; h.l++; } else { h.dr++; a.dr++; }
      }
      const list = [...rows.values()].map(r => ({ ...r, gd: r.gf - r.ga, pts: r.w * 3 + r.dr }))
        .sort((x, y) => y.pts - x.pts || y.gd - x.gd || y.gf - x.gf || x.name.localeCompare(y.name));
      html += `<div class="cx-day">${esc(d)}</div>
        <table class="cx-table"><thead><tr><th>#</th><th>Club</th><th>P</th><th>W</th><th>D</th><th>L</th><th>GF</th><th>GA</th><th>GD</th><th>Pts</th></tr></thead><tbody>
        ${list.map((r, i) => `<tr class="${r.cid === this.data.our_club_id ? 'ours' : ''}"><td>${i + 1}</td><td>${r.logo ? `<img src="${esc(r.logo)}" alt="">` : ''}${r.url ? `<a href="${esc(r.url)}" target="_blank" rel="noopener" style="color:inherit; text-decoration:none;">${esc(r.name)}</a>` : esc(r.name)}</td><td>${r.p}</td><td>${r.w}</td><td>${r.dr}</td><td>${r.l}</td><td>${r.gf}</td><td>${r.ga}</td><td>${r.gd > 0 ? '+' : ''}${r.gd}</td><td><b>${r.pts}</b></td></tr>`).join('')}
        </tbody></table>`;
    }
    return html || `<div class="cx-hint">${esc(this._copy('schedule_empty') || 'No games match.')}</div>`;
  }
}
// ─── #casa-scores — played games with no score yet, and who to ask (mig 520) ─
// Owner 2026-10-05: "treat it like the not rsvp yet function … every time i
// open results page it should check casa website for scores as source of
// truth on what is in. then for each game a text and email button to request
// the score from the manager … each manager or person should have its own
// button on the game card and option to tag the person as main one to ask
// for score or message all too or just one".
//
// GET /api/opponents/league-scores pulls SportsEngine first, so a score that
// has landed drops its game off the list.  People on a game card are the
// team's club_contacts with a score_role (★ main, others "manager"); the
// rest of the club's contacts sit behind "more" and can be put on the card.
// The Message pills pick what the buttons send: ask for the score (reply to
// me) or get the SportsEngine app and enter it yourself (mig 522).
class CasaScoresScreen extends Screen {
  constructor(navigation, auth) { super(navigation, auth); this.data = null; this.division = ''; this.tier = 'score_request'; this.more = new Set(); this.flash = ''; this.flashBad = false; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .cz-pills { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:8px; align-items:center; }
        .cz-pill { padding:8px 14px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:var(--text-primary); cursor:pointer; font-weight:700; font-size:0.9rem; }
        .cz-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .cz-pill .n { opacity:0.6; font-weight:500; margin-left:4px; }
        .cz-hint { font-size:0.8rem; opacity:0.7; margin:4px 0 8px; }
        .cz-stale { background:#fde68a; color:#3b2f00; border-radius:10px; padding:8px 12px; margin-bottom:10px; font-size:0.85rem; }
        .cz-flash { padding:8px 12px; border-radius:10px; margin:8px 0; background:rgba(74,222,128,0.15); font-size:0.88rem; }
        .cz-flash.bad { background:rgba(248,113,113,0.15); }
        .cz-sec { margin:var(--space-4) 0 var(--space-2); font-size:0.8rem; font-weight:700; text-transform:uppercase; letter-spacing:0.05em; opacity:0.6; }
        .cz-day { font-weight:800; margin:14px 0 6px; font-size:0.95rem; opacity:0.85; }
        .cz-game { border:1px solid var(--border-color); border-left:5px solid #f59e0b; border-radius:12px; background:var(--bg-secondary); padding:10px 14px; margin-bottom:var(--space-2); }
        .cz-game.asked { border-left-color:#4ade80; }
        .cz-top { display:flex; align-items:center; gap:8px; flex-wrap:wrap; }
        .cz-top img { width:22px; height:22px; object-fit:contain; border-radius:4px; }
        .cz-top b { font-size:1rem; }
        .cz-meta { font-size:0.78rem; opacity:0.7; margin-left:auto; white-space:nowrap; }
        .cz-asked { font-size:0.78rem; opacity:0.75; margin-top:2px; }
        .cz-team { margin-top:10px; padding-top:8px; border-top:1px solid var(--border-color); }
        .cz-team-h { display:flex; align-items:center; gap:8px; flex-wrap:wrap; font-size:0.82rem; font-weight:800; }
        .cz-team-h .side { font-size:0.68rem; font-weight:700; text-transform:uppercase; letter-spacing:0.04em; opacity:0.6; }
        .cz-person { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:6px 0; font-size:0.9rem; }
        .cz-person .who { flex:1; min-width:150px; }
        .cz-person .who small { opacity:0.65; }
        .cz-person .addr { font-size:0.78rem; opacity:0.7; overflow-wrap:anywhere; }
        .cz-person .sent { font-size:0.72rem; opacity:0.65; }
        .cz-btn { padding:7px 12px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.85rem; color:#0b1c3d; background:#4ade80; }
        .cz-btn.alt { background:var(--primary-color); color:#fff; }
        .cz-btn.sm { padding:5px 9px; font-size:0.78rem; }
        .cz-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .cz-btn[disabled] { opacity:0.4; cursor:not-allowed; }
        .cz-star { background:transparent; border:none; cursor:pointer; font-size:1.15rem; padding:0 2px; color:#f59e0b; }
        .cz-star.off { color:var(--text-primary); opacity:0.35; }
        .cz-in { display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:6px 10px; border:1px solid var(--border-color); border-radius:10px; margin-bottom:4px; font-size:0.88rem; }
        .cz-notfinal { font-size:0.7rem; font-weight:800; padding:2px 7px; border-radius:6px; background:#f59e0b; color:#3b2f00; text-transform:uppercase; }
        .cz-score { font-weight:900; padding:1px 8px; border-radius:8px; background:var(--bg-primary); border:1px solid var(--border-color); white-space:nowrap; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="cz-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="cz-title">🥅 CASA scores</h1><div id="cz-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" id="cz-body"><div class="loading">Loading…</div></div>`;
    this.element = div;
    div.querySelector('#cz-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', async (e) => {
      const t = e.target;
      const d = t.closest('[data-division]'); if (d) { this.division = d.dataset.division; this._renderBody(); return; }
      const pick = t.closest('[data-tier]'); if (pick) { this.tier = pick.dataset.tier; this._renderBody(); return; }
      const ask = t.closest('[data-ask]'); if (ask) { await this.ask(Number(ask.dataset.fixture), ask.dataset.contacts.split(',').map(Number), ask.dataset.ask, ask); return; }
      const role = t.closest('[data-score-role]'); if (role) { await this.setRole(Number(role.dataset.contact), role.dataset.scoreRole); return; }
      const more = t.closest('[data-more]'); if (more) { const k = more.dataset.more; if (this.more.has(k)) this.more.delete(k); else this.more.add(k); this._renderBody(); return; }
      if (t.closest('[data-go]')) { this.navigation.goTo(t.closest('[data-go]').dataset.go, { league: 'CASA' }); return; }
      if (t.closest('[data-refresh]')) { await this.load(); return; }
    });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('casa', tier, tokens) : ''; }
  _say(text, bad = false) { this.flash = text; this.flashBad = bad; this._renderBody(); }

  async load() {
    const body = this.find('#cz-body'); if (body && !this.data) body.innerHTML = '<div class="loading">Loading…</div>';
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      const res = await this.auth.fetch('/api/opponents/league-scores?label=CASA');
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
      this.data = data;
    } catch (err) { if (body) body.innerHTML = `<div class="error-message">${this.escapeHtml(err.message)}</div>`; return; }
    const sm = this.data.summary || {};
    const title = this.find('#cz-title'); if (title) title.textContent = '🥅 ' + (this._copy('scores_title') || 'CASA scores to chase');
    const sub = this.find('#cz-sub'); if (sub) sub.textContent = this._copy('scores_subtitle', { when: sm.fresh ? 'just now' : (sm.last_fetched_at || 'never'), n: (this.data.waiting || []).length });
    this._renderBody();
  }

  async _post(path, payload) {
    const res = await this.auth.fetch(path, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload || {}) });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  // The contacts of one side of a game: the club's, narrowed to that
  // division's team where a contact is pinned to one (two-team clubs).
  _side(f, clubId) {
    const comp = (this.data.competitions || []).find(k => k.club_id === clubId && k.division_label === f.division_label);
    const all = (this.data.contacts || []).filter(c => c.club_id === clubId && (!c.competition_id || (comp && c.competition_id === comp.id)));
    return { tagged: all.filter(c => c.score_role), others: all.filter(c => !c.score_role) };
  }
  _asks(fixtureId, contactId) { return (this.data.asks || []).filter(a => a.fixture_id === fixtureId && (contactId === undefined || a.contact_id === contactId)); }

  // One ask to one person or several: the server words and logs it, the
  // phone's messages or Gmail (as the league address) opens with it filled in.
  async ask(fixtureId, contactIds, channel, btn) {
    const orig = btn.textContent; btn.disabled = true; btn.textContent = '⏳';
    try {
      const data = await this._post('/api/opponents/score-request', { fixture_id: fixtureId, contact_ids: contactIds, channel, tier: this.tier });
      const to = (data.recipients || []).map(r => r.contact);
      if (channel === 'email') this.openGmailCompose(this.buildGmailComposeHref({ to: to.join(','), subject: data.subject, body: data.body, authuser: data.from_email || this.data.league?.correspondence_email }));
      else {
        const nums = to.map(p => p.replace(/[^\d+]/g, '')).join(',');
        const apple = /iPhone|iPad|Macintosh/.test(navigator.userAgent);
        window.location.href = to.length > 1 && apple ? `sms://open?addresses=${nums}&body=${encodeURIComponent(data.body)}` : `sms:${nums}?body=${encodeURIComponent(data.body)}`;
      }
      await this.load();
    } catch (err) { this._say(err.message, true); }
    finally { btn.disabled = false; btn.textContent = orig; }
  }

  async setRole(contactId, role) {
    try { await this._post('/api/opponents/score-contact', { contact_id: contactId, score_role: role }); await this.load(); }
    catch (err) { this._say(err.message, true); }
  }

  _renderBody() {
    const body = this.find('#cz-body'); if (!body || !this.data) return;
    const esc = (t) => this.escapeHtml(t);
    const sm = this.data.summary || {};
    const waiting = this.data.waiting || [], recent = this.data.recent || [];
    const divs = [...new Set([...waiting, ...recent].map(f => f.division_label).filter(Boolean))].sort();
    const n = (d) => waiting.filter(f => !d || f.division_label === d).length;
    const inScope = (f) => !this.division || f.division_label === this.division;
    const w = waiting.filter(inScope), r = recent.filter(inScope);
    let html = '', day = '';
    for (const f of w) {
      if (f.date_key !== day) { day = f.date_key; html += `<div class="cz-day">${esc(f.date_label)}</div>`; }
      html += this._game(f);
    }
    let inHtml = ''; day = '';
    for (const f of r) {
      if (f.date_key !== day) { day = f.date_key; inHtml += `<div class="cz-day">${esc(f.date_label)}</div>`; }
      inHtml += `<div class="cz-in">${f.home_logo ? `<img src="${esc(f.home_logo)}" alt="" style="width:18px;height:18px;object-fit:contain;">` : ''}<b>${esc(f.home_name)}</b><span class="cz-score">${f.home_score} – ${f.away_score}</span><b>${esc(f.away_name)}</b>${f.away_logo ? `<img src="${esc(f.away_logo)}" alt="" style="width:18px;height:18px;object-fit:contain;">` : ''}${f.status !== 'completed' ? `<span class="cz-notfinal">${esc(this._copy('scores_not_final') || 'not final')}</span>` : ''}<span class="cz-meta">${esc(f.division_label || '')}</span></div>`;
    }
    body.innerHTML = `
      ${this.flash ? `<div class="cz-flash ${this.flashBad ? 'bad' : ''}">${esc(this.flash)}</div>` : ''}
      ${sm.fresh === false && sm.last_fetched_at ? `<div class="cz-stale">${esc(this._copy('schedule_stale', { when: sm.last_fetched_at }) || `Showing the list from ${sm.last_fetched_at}.`)}</div>` : ''}
      <div class="cz-pills">
        <button class="cz-pill ${!this.division ? 'on' : ''}" data-division="">All<span class="n">${n('')}</span></button>
        ${divs.map(d => `<button class="cz-pill ${this.division === d ? 'on' : ''}" data-division="${esc(d)}">${esc(d)}<span class="n">${n(d)}</span></button>`).join('')}
        <button class="cz-btn sm ghost" data-refresh>↻ Check again</button>
        <button class="cz-btn sm ghost" data-go="casa-contacts">📇 Edit contacts</button>
      </div>
      <div class="cz-pills">
        <span style="font-size:0.8rem; opacity:0.8;">Message:</span>
        ${[['score_request', 'scores_pick_request', '🙋 Ask for the score'], ['score_app', 'scores_pick_app', '📲 Get the app & enter it']].map(([k, c, d]) => `<button class="cz-pill ${this.tier === k ? 'on' : ''}" data-tier="${k}">${k === 'score_app' ? '📲' : '🙋'} ${esc(this._copy(c) || d.slice(3))}</button>`).join('')}
      </div>
      <div class="cz-hint">${esc(this._copy('scores_hint'))}</div>
      <div class="cz-sec">${esc(this._copy('scores_waiting') || 'Waiting on a score')} · ${w.length}</div>
      ${html || `<div class="cz-hint">${esc(this._copy('scores_none') || 'Nothing missing.')}</div>`}
      ${inHtml ? `<div class="cz-sec">${esc(this._copy('scores_in') || 'Scores in')} · ${r.length}</div>${inHtml}` : ''}`;
    this.flash = '';
  }

  _game(f) {
    const esc = (t) => this.escapeHtml(t);
    const asks = this._asks(f.id);
    const total = asks.reduce((a, x) => a + x.n, 0);
    const last = asks.slice().sort((a, b) => b.last_epoch - a.last_epoch)[0];
    const logo = (u) => u ? `<img src="${esc(u)}" alt="">` : '';
    return `
      <div class="cz-game ${total ? 'asked' : ''}">
        <div class="cz-top">${logo(f.home_logo)}<b>${esc(f.home_name)}</b><span style="opacity:0.6;">v</span><b>${esc(f.away_name)}</b>${logo(f.away_logo)}
          <span class="cz-meta">${esc(f.time_label)} · ${esc(f.division_label || '')}${f.status !== 'scheduled' ? ` · ${esc(f.status)}` : ''}</span></div>
        ${total ? `<div class="cz-asked">${esc(this._copy('scores_asked', { n: total, when: last.last }) || `Asked ${total}× · last ${last.last}`)}</div>` : ''}
        ${this._team(f, 'Home', f.home_name, f.home_club_id)}
        ${this._team(f, 'Away', f.away_name, f.away_club_id)}
      </div>`;
  }

  _team(f, side, name, clubId) {
    const esc = (t) => this.escapeHtml(t);
    const head = (extra = '') => `<div class="cz-team-h"><span class="side">${side}</span><span>${esc(name)}</span>${extra}</div>`;
    if (clubId === this.data.our_club_id) return `<div class="cz-team">${head()}<div class="cz-hint">${esc(this._copy('scores_ours') || 'Our team.')}</div></div>`;
    const { tagged, others } = clubId ? this._side(f, clubId) : { tagged: [], others: [] };
    const key = `${f.id}:${clubId}`;
    const open = this.more.has(key);
    const withPhone = tagged.filter(c => c.phone).map(c => c.id), withEmail = tagged.filter(c => c.email).map(c => c.id);
    const allBtns = tagged.length > 1 ? `<span style="margin-left:auto; display:flex; gap:6px;">
        <button class="cz-btn sm" data-ask="sms" data-fixture="${f.id}" data-contacts="${withPhone.join(',')}" ${withPhone.length ? '' : 'disabled'}>💬 Text all ${withPhone.length}</button>
        <button class="cz-btn sm alt" data-ask="email" data-fixture="${f.id}" data-contacts="${withEmail.join(',')}" ${withEmail.length ? '' : 'disabled'}>✉️ Email all ${withEmail.length}</button></span>` : '';
    const person = (c, onCard) => {
      const mine = this._asks(f.id, c.id);
      const appWord = this._copy('scores_tag_app') || 'app';
      const sent = mine.map(a => `${a.app ? appWord + ' ' : ''}${a.channel === 'sms' ? 'text' : 'email'} ${a.last}${a.n > 1 ? ` (${a.n}×)` : ''}`).join(' · ');
      const main = c.score_role === 'main';
      return `
        <div class="cz-person">
          <button class="cz-star ${main ? '' : 'off'}" data-score-role="${main ? 'manager' : 'main'}" data-contact="${c.id}" title="${main ? 'The one to ask first — tap to unstar' : 'Make this the one to ask first'}">${main ? '★' : '☆'}</button>
          <div class="who"><b>${esc(c.name || c.role || 'Team mailbox')}</b>${c.name && c.role ? ` <small>· ${esc(c.role)}</small>` : ''}
            <div class="addr">${[c.phone, c.email].filter(Boolean).map(esc).join(' · ')}</div>
            ${sent ? `<div class="sent">Asked: ${esc(sent)}</div>` : ''}</div>
          <button class="cz-btn sm" data-ask="sms" data-fixture="${f.id}" data-contacts="${c.id}" ${c.phone ? '' : 'disabled'}>💬 Text</button>
          <button class="cz-btn sm alt" data-ask="email" data-fixture="${f.id}" data-contacts="${c.id}" ${c.email ? '' : 'disabled'}>✉️ Email</button>
          ${onCard ? `<button class="cz-btn sm ghost" data-score-role="" data-contact="${c.id}" title="Take off the game cards">✕</button>`
                   : `<button class="cz-btn sm ghost" data-score-role="manager" data-contact="${c.id}" title="Show on the game cards">＋ card</button>`}
        </div>`;
    };
    return `
      <div class="cz-team">${head(allBtns)}
        ${tagged.length ? tagged.map(c => person(c, true)).join('') : `<div class="cz-hint">${esc(this._copy('scores_no_contact') || 'Nobody tagged for scores yet.')}</div>`}
        ${others.length ? `<button class="cz-btn sm ghost" data-more="${key}" style="margin-top:2px;">${open ? '▾ Hide' : `▸ ${others.length} more at this club`}</button>` : ''}
        ${open ? others.map(c => person(c, false)).join('') : ''}
      </div>`;
  }
}
window.CasaHubScreen = CasaHubScreen;
window.CasaContactsScreen = CasaContactsScreen;
window.CasaScheduleScreen = CasaScheduleScreen;
window.CasaScoresScreen = CasaScoresScreen;
