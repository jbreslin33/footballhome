// CASA commissioner section (mig 486) — owner 2026-09-28: "the piece for
// footballhome that is for me being casa commissioner … a whole casa
// commissioner section. that i hit casa and then there is more buttons".
//
//   #casa           the hub: tiles (Clubs & contacts, Schedule & standings,
//                   Sent mail) — add a tile here for each new commissioner tool.
//   #casa-contacts  Liga 1 / Liga 2 clubs with their managers; ✉️/💬 per
//                   contact and one BCC email to a division or the league.
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
      const l = e.target.closest('[data-links]');
      if (l) { const box = this.find('#ch-links'); if (box) box.hidden = !box.hidden; }
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
    const tile = (tier, go, extra = '') => { const t = this._tile(tier); return `
      <button class="btn btn-lg btn-primary" ${go ? `data-go="${go}"` : 'data-links'} style="display:flex; align-items:center; gap:var(--space-3); width:100%; text-align:left; margin-bottom:10px;">
        <span style="font-size:2rem;">${tier === 'tile_contacts' ? '📇' : tier === 'tile_links' ? '📅' : '📤'}</span>
        <div style="flex:1;"><div style="font-weight:bold;">${esc(t.label)}</div><div style="font-size:0.85rem; opacity:0.8;">${esc(t.desc)}${extra}</div></div>
      </button>`; };
    const linkRows = [
      ...(this.data.our_links || []).map(l => `<li><a href="${esc(l.url)}" target="_blank" rel="noopener">${esc(l.team)} — ${esc(l.label)}</a></li>`),
      `<li><a href="https://www.casasoccerleagues.com/page/show/9496155-liga-1" target="_blank" rel="noopener">Liga 1 — league page (schedule, standings)</a></li>`,
      `<li><a href="https://www.casasoccerleagues.com/page/show/9496153-liga-2" target="_blank" rel="noopener">Liga 2 — league page (schedule, standings)</a></li>`,
    ];
    const recent = (this.data.recent || []).slice(0, 8).map(r => `<li style="font-size:0.85rem;">${esc(r.sent_at)} — ${esc(r.tier.replace(/^all_|^one_/, '').replace(/_/g, ' '))} ${r.n > 1 ? `to ${r.n} addresses` : ''} (${esc(r.clubs.length > 90 ? r.clubs.slice(0, 90) + '…' : r.clubs)})</li>`).join('');
    body.innerHTML = `
      ${tile('tile_contacts', 'casa-contacts', ` · ${divisions.map(esc).join(', ')} · ${clubs} clubs`)}
      ${tile('tile_links', null)}
      <div id="ch-links" hidden style="margin:-4px 0 12px 8px;"><ul style="margin:0; padding-left:20px;">${linkRows.join('')}</ul></div>
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
window.CasaHubScreen = CasaHubScreen;
window.CasaContactsScreen = CasaContactsScreen;
