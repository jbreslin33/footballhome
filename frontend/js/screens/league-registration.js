// LeagueRegistrationScreen — 📝 #league-registration (mig 1746): entering a
// league as a checklist, with the league's own forms pre-filled.  Owner
// 2026-11-23: "we need to prepare for indoor ppr season … the last 4 docs i
// uploaded to files are needed filled out. should have a league registration
// page for fh? and have these also as check list items but you pre fill them
// for me and get them ready to be sent".
//
//   ✅ CHECKLIST   one row per thing the league wants: 👁 Preview (the
//                  league's Word file, filled here by lib/docx-fill.js and
//                  drawn on the page by lib/docx-view.js), ⬇ Filled form,
//                  Blank, ✓ Done; ✉️ Open Gmail to the league (mig 1816 —
//                  compose opens addressed and worded, the filled forms
//                  land in Downloads to drag in: a Gmail link cannot carry
//                  a file), or send them from Football Home
//   🏢 THE CLUB    who signs (the soccer director) and what is owed
//   ⚽ <team>      the team commitment form's answers — every box saves as
//                  you leave it and the forms refill
//   📋 ROSTER      the team's live players from 👥 Teams (name, DOB, a
//                  parent's phone)
//
//   GET  /api/league-entries
//   POST /api/league-entries/team  {id, fields}
//   POST /api/league-entries/entry {id, fields}
//   POST /api/league-entries/item  {id, done}
//   POST /api/league-entries/send  {id, files:[{filename, file}]}
// Words: message_templates kind league_entry.  Forms: club_files.
class LeagueRegistrationScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.error = '';
    this.note = '';
    this.busy = false;
    this.templates = new Map();   // club_files id → ArrayBuffer
  }

  onEnter() { this.error = ''; this.note = ''; this._load(); }

  _t(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('league_entry', tier)) ? MessageCopy.block('league_entry', tier, tokens || {}) : fb;
  }

  async _json(url, options = {}) {
    const res = await this.auth.fetch(url, { ...options, headers: { 'Content-Type': 'application/json', ...(options.headers || {}) } });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _load() {
    try {
      if (window.MessageCopy) await MessageCopy.load(this.auth);
      this.data = await this._json('/api/league-entries');
    } catch (err) { this.error = err.message; }
    this._renderBody();
  }

  async _post(url, payload) {
    if (this.busy) return null;
    this.busy = true; this.error = '';
    let out = null;
    try { out = this.data = await this._json(url, { method: 'POST', body: JSON.stringify(payload) }); }
    catch (err) { this.error = err.message; }
    this.busy = false;
    this._renderBody();
    return out;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-league-registration';
    div.innerHTML = '<div id="le-body" style="padding: 0 var(--space-4) var(--space-4); max-width: 900px;"></div>';
    this.element = div;
    div.addEventListener('click', (e) => this._onClick(e));
    div.addEventListener('change', (e) => this._onChange(e));
    return div;
  }

  _entry(id) { return ((this.data || {}).entries || []).find(x => x.id === Number(id)); }

  _onChange(e) {
    const el = e.target;
    if (el.matches('[data-le-team-field]')) {
      const k = el.dataset.leTeamField;
      const v = el.type === 'checkbox' ? el.checked : /_person_id$/.test(k) ? Number(el.value) || 0 : el.value.trim();
      this._post('/api/league-entries/team', { id: Number(el.dataset.id), fields: { [k]: v } });
    } else if (el.matches('[data-le-entry-field]')) {
      this._post('/api/league-entries/entry', { id: Number(el.dataset.id), fields: { [el.dataset.leEntryField]: el.value.trim() } });
    }
  }

  async _onClick(e) {
    const t = (sel) => e.target.closest(sel);
    let el;
    if ((el = t('[data-le-done]'))) { this._post('/api/league-entries/item', { id: Number(el.dataset.leDone), done: el.dataset.on === '1' }); return; }
    if ((el = t('[data-le-view]'))) { this._preview(Number(el.dataset.entry), Number(el.dataset.leView)); return; }
    if ((el = t('[data-le-view-close]')) || e.target.matches('[data-le-view-back]')) { this._closePreview(); return; }
    if ((el = t('[data-le-gmail]'))) { this._gmail(Number(el.dataset.leGmail)); return; }
    if ((el = t('[data-le-fill]'))) { this._download(Number(el.dataset.entry), Number(el.dataset.leFill)); return; }
    if ((el = t('[data-le-blank]'))) { this._downloadBlank(Number(el.dataset.entry), Number(el.dataset.leBlank)); return; }
    if ((el = t('[data-le-send]'))) { this._send(Number(el.dataset.leSend)); return; }
  }

  // ── the forms ────────────────────────────────────────────────────────
  static phone(p) {
    const d = String(p || '').replace(/\D/g, '').replace(/^1(?=\d{10}$)/, '');
    return d.length === 10 ? `(${d.slice(0, 3)}) ${d.slice(3, 6)}-${d.slice(6)}` : String(p || '');
  }
  static money(v) { return `$${Number(v || 0).toFixed(2)}`; }

  // The answers a team's forms take: its own boxes, else what FH knows of the coach.
  _teamAnswers(tm) {
    const who = (p, pre) => ({
      name: (p && p.name) || '', phone: LeagueRegistrationScreen.phone(p && p.phone), email: (p && p.email) || '',
      address: tm[`${pre}_address`] || (p && p.address) || '', city: tm[`${pre}_city`] || (p && p.city) || '',
      state: tm[`${pre}_state`] || (p && p.state) || '', zip: tm[`${pre}_zip`] || (p && p.zip) || '',
    });
    return { coach: who(tm.coach, 'coach'), assistant: who(tm.assistant, 'assistant'), roster: (tm.roster || []).slice(0, tm.max_roster || 12) };
  }

  // What a form would still show as a blank line: [label, …].
  _missing(entry, item) {
    const out = [], need = (v, label) => { if (!String(v == null ? '' : v).trim()) out.push(label); };
    const tm = (entry.teams || []).find(x => x.id === item.entry_team_id);
    const d = entry.director || {};
    if (item.kind === 'club_form') { need(d.name, 'director'); need(d.phone, 'director phone'); need(d.email, 'director email'); }
    if (item.kind === 'team_form' && tm) {
      const a = this._teamAnswers(tm);
      need(tm.team_name, 'team name'); need(a.coach.name, 'coach'); need(a.coach.phone, 'coach phone'); need(a.coach.address, 'coach address');
      need(a.coach.city, 'coach city'); need(a.coach.zip, 'coach zip'); need(a.coach.email, 'coach email');
      need(a.assistant.name, 'assistant coach'); need(tm.home_court, 'home court'); need(tm.court_availability, 'court availability');
      need(tm.prev_record, 'last record');
    }
    if (item.kind === 'roster' && tm) {
      const a = this._teamAnswers(tm);
      if (!a.roster.length) out.push('players');
      if (a.roster.some(p => !p.dob)) out.push('a date of birth');
      if (a.roster.some(p => !p.phone)) out.push('a phone');
      need(a.coach.name, 'coach');
    }
    return out;
  }

  async _template(fileId) {
    if (!this.templates.has(fileId)) {
      const res = await this.auth.fetch(`/api/files/dl/${fileId}`);
      if (!res.ok) throw new Error(`The league's form (file ${fileId}) could not be read.`);
      this.templates.set(fileId, await res.arrayBuffer());
    }
    return this.templates.get(fileId).slice(0);
  }

  // The league's Word file with the answers written in → { filename, blob }.
  async _filled(entry, item) {
    const safe = (s) => String(s).replace(/[\\/:*?"<>|]+/g, ' ').replace(/\s+/g, ' ').trim();
    return { filename: `${safe(entry.club)} - ${safe(entry.title)} - ${safe(item.label)}.docx`, blob: (await this._filledDoc(entry, item)).blob() };
  }

  // … as the open document (DocxFill.Doc), for the preview and the file.
  async _filledDoc(entry, item) {
    const doc = await DocxFill.open(await this._template(item.template_file_id));
    const S = LeagueRegistrationScreen, d = entry.director || {};
    const tm = (entry.teams || []).find(x => x.id === item.entry_team_id);
    if (item.kind === 'club_form') {
      doc.blank('CLUB', entry.club).blank('Soccer Director’s Name', d.name).blank('Phone #', S.phone(d.phone)).blank('Email Address', d.email);
      const count = new Map();
      for (const x of entry.teams || []) { const k = `${x.age_group}|${x.gender}`; count.set(k, (count.get(k) || 0) + 1); }
      for (const [k, n] of count) { const [age, g] = k.split('|'); doc.cell(0, age, g === 'F' ? 2 : 1, String(n)); }
      const f = entry.fees || {};
      doc.blank('Current PPR teams', String(f.returning || 0)).blank('Non-PPR Teams', String(f.new || 0))
        .blanks('=', [S.money((f.returning || 0) * entry.fee_returning), S.money((f.new || 0) * entry.fee_new)])
        .blank('TOTAL DUE', S.money(f.total));
    } else if (item.kind === 'team_form' && tm) {
      const a = this._teamAnswers(tm);
      doc.blank('CLUB:', entry.club).blank('AGE GROUP-', tm.age_group).swap(tm.gender === 'F' ? '___FEMALE' : '____MALE', tm.gender === 'F' ? '_X_ FEMALE' : '_X_ MALE')
        .blank('Team Name:', tm.team_name)
        .blanks('Coach’s Name', [a.coach.name, a.assistant.name]).blanks('Phone', [a.coach.phone, a.assistant.phone])
        .blanks('Address', [a.coach.address, a.assistant.address], { not: 'ail ' })
        .blanks('City', [a.coach.city, a.assistant.city]).blanks('State', [a.coach.state, a.assistant.state]).blanks('Zip Code', [a.coach.zip, a.assistant.zip])
        .blanks('ail Address', [a.coach.email, a.assistant.email])
        .blank('Home Court', tm.home_court).lones([tm.court_availability])
        .blank('1-', tm.unavailable_1).blank('2-', tm.unavailable_2).blank('3-', tm.unavailable_3).blank('4-', tm.unavailable_4)
        .blank('PPR Age Group', tm.prev_age_group).blank('Record', tm.prev_record);
    } else if (item.kind === 'roster' && tm) {
      const a = this._teamAnswers(tm);
      doc.blank('TEAM', tm.team_name).blank('AGE', tm.age_group).swap('MALE or FEMALE', tm.gender === 'F' ? 'FEMALE' : 'MALE').blank('Coach', a.coach.name);
      a.roster.forEach((p, i) => doc.cellAt(0, i + 1, 1, p.name).cellAt(0, i + 1, 2, p.dob).cellAt(0, i + 1, 3, S.phone(p.phone)));
    }
    return doc;
  }

  _save(blob, filename) {
    const url = URL.createObjectURL(blob), a = document.createElement('a');
    a.href = url; a.download = filename; document.body.appendChild(a); a.click(); a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 60000);
  }

  async _download(entryId, itemId) {
    const entry = this._entry(entryId), item = entry && entry.items.find(i => i.id === itemId);
    if (!item) return;
    try { const f = await this._filled(entry, item); this._save(f.blob, f.filename); }
    catch (err) { this.error = err.message; this._renderBody(); }
  }

  // 👁 the filled form drawn on the page, over the screen.
  async _preview(entryId, itemId) {
    const entry = this._entry(entryId), item = entry && entry.items.find(i => i.id === itemId);
    if (!item) return;
    try {
      const doc = await this._filledDoc(entry, item);
      this._closePreview();
      const back = document.createElement('div');
      back.dataset.leViewBack = '1';
      back.style.cssText = 'position:fixed; inset:0; z-index:5000; background:rgba(0,0,0,0.78); overflow:auto; padding:0 8px 24px;';
      back.innerHTML = `<div style="position:sticky; top:0; z-index:1; display:flex; gap:8px; align-items:center; max-width:816px; margin:0 auto; padding:8px 0; background:rgba(0,0,0,0.78);">
          <div style="flex:1; min-width:0; font-weight:700; color:#fff; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${this.escapeHtml(item.label)}</div>
          <button type="button" class="btn btn-secondary" data-le-fill="${item.id}" data-entry="${entry.id}" style="min-height:0; padding:5px 11px; font-size:0.8rem;">${this.escapeHtml(this._t('btn_download', {}, '⬇ Filled form'))}</button>
          <button type="button" class="btn btn-primary" data-le-view-close="1" style="min-height:0; padding:5px 11px; font-size:0.8rem;">✕</button>
        </div>`;
      back.appendChild(DocxView.render(doc));
      this.element.appendChild(back);
      this._previewEl = back;
      this._previewKey = (e) => { if (e.key === 'Escape') this._closePreview(); };
      document.addEventListener('keydown', this._previewKey);
    } catch (err) { this.error = err.message; this._renderBody(); }
  }

  _closePreview() {
    if (this._previewEl) this._previewEl.remove();
    if (this._previewKey) document.removeEventListener('keydown', this._previewKey);
    this._previewEl = this._previewKey = null;
  }

  onExit() { this._closePreview(); }

  // ✉️ Gmail, addressed and worded (message_templates league_entry / email —
  // the words the server send uses).  A compose link cannot carry a file, so
  // the filled forms are saved to Downloads in the same click, to drag in.
  // Gmail opens first, inside the click, or the browser blocks the window.
  async _gmail(entryId) {
    const entry = this._entry(entryId);
    if (!entry) return;
    if (!entry.send_to_email) { this.error = this._t('send_nobody', {}, 'Fill in who it goes to first.'); this._renderBody(); return; }
    const forms = entry.items.filter(i => i.template_file_id);
    const u = (this.auth.getUser && this.auth.getUser()) || {};
    const tokens = { club: entry.club, league_title: entry.title, to_name: String(entry.send_to_name || '').trim().split(' ')[0],
      list: forms.map(i => `• ${i.label}`).join('\n') + '\n', sender: u.name || u.display_name || (entry.director || {}).name || '' };
    const mail = (window.MessageCopy && MessageCopy.render('league_entry', 'email', tokens))
      || { subject: `${entry.club} — ${entry.title} registration`, body: '' };
    this.openGmailCompose(this.buildGmailComposeHref({ to: entry.send_to_email, subject: mail.subject, body: mail.body }));
    try { for (const item of forms) { const f = await this._filled(entry, item); this._save(f.blob, f.filename); } }
    catch (err) { this.error = err.message; this._renderBody(); }
  }

  async _downloadBlank(entryId, itemId) {
    const entry = this._entry(entryId), item = entry && entry.items.find(i => i.id === itemId);
    if (!item) return;
    try { this._save(new Blob([await this._template(item.template_file_id)], { type: DocxFill.MIME }), item.template_filename || `${item.label}.docx`); }
    catch (err) { this.error = err.message; this._renderBody(); }
  }

  async _send(entryId) {
    const entry = this._entry(entryId);
    if (!entry || this.busy) return;
    if (!entry.send_to_email) { this.error = this._t('send_nobody', {}, 'Fill in who it goes to first.'); this._renderBody(); return; }
    const forms = entry.items.filter(i => i.template_file_id);
    if (!confirm(this._t('send_confirm', { n: forms.length, name: entry.send_to_name || entry.send_to_email, to: entry.send_to_email },
      `Email ${forms.length} filled form(s) to ${entry.send_to_name} <${entry.send_to_email}>, with a copy to you?`))) return;
    try {
      const files = [];
      for (const item of forms) { const f = await this._filled(entry, item); files.push({ filename: f.filename, file: await DocxFill.dataUrl(f.blob) }); }
      const out = await this._post('/api/league-entries/send', { id: entry.id, files });
      if (out) { this.note = `✓ ${out.sent_files || files.length}`; this._renderBody(); }
    } catch (err) { this.error = err.message; this._renderBody(); }
  }

  // ── the page ─────────────────────────────────────────────────────────
  _renderBody() {
    const body = this.element && this.element.querySelector('#le-body');
    if (!body) return;
    const esc = (s) => this.escapeHtml(s == null ? '' : String(s));
    if (!this.data) { body.innerHTML = this.error ? `<p style="color:#ef4444;">${esc(this.error)}</p>` : '<p style="opacity:0.7;">…</p>'; return; }
    const entries = this.data.entries || [];
    body.innerHTML = `
      <p style="font-size:0.85rem; opacity:0.85; margin:var(--space-2) 0 var(--space-3);">${esc(this._t('intro', {}, "Everything a league wants from us to enter, as a checklist. The forms are the league's own Word files, filled in from what Football Home knows — fix anything below and they refill."))}</p>
      ${this.error ? `<p style="color:#ef4444; margin:0 0 8px;">${esc(this.error)}</p>` : ''}
      ${entries.length ? entries.map(en => this._entryHtml(en, esc)).join('') : '<p style="opacity:0.7;">—</p>'}`;
  }

  _entryHtml(en, esc) {
    const S = LeagueRegistrationScreen;
    const card = 'border:1px solid var(--border-color); border-radius:10px; background:var(--bg-secondary); padding:10px 12px; margin-bottom:10px;';
    const head = (txt) => `<div style="font-weight:800; font-size:0.85rem; letter-spacing:0.03em; margin-bottom:6px;">${esc(txt)}</div>`;
    const inputCss = 'padding:6px 8px; border-radius:6px; border:1px solid var(--border-color); background:transparent; color:inherit; font:inherit; font-size:0.85rem; width:100%; box-sizing:border-box;';
    const field = (label, html, wide) => `<label style="display:flex; flex-direction:column; gap:2px; font-size:0.76rem; flex:1 1 ${wide ? '100%' : '180px'}; min-width:${wide ? '0' : '150px'};"><span style="opacity:0.75;">${esc(label)}</span>${html}</label>`;
    const dis = this.busy ? 'disabled' : '';
    const when = (iso) => new Date(iso).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });

    // ✅ checklist
    const done = en.items.filter(i => i.done_at).length;
    const items = en.items.map(i => {
      const miss = i.template_file_id ? this._missing(en, i) : [];
      return `<div style="display:flex; gap:8px; align-items:flex-start; padding:8px 0; border-top:1px solid var(--border-color);">
          <span style="font-size:1.1rem; line-height:1.2;">${i.done_at ? '✅' : '⬜'}</span>
          <div style="flex:1; min-width:0;">
            <div style="font-weight:700;">${esc(i.label)}</div>
            ${i.how ? `<div style="font-size:0.8rem; opacity:0.8;">${esc(i.how)}</div>` : ''}
            ${miss.length ? `<div style="font-size:0.78rem; color:#fbbf24; margin-top:2px;">${esc(this._t('missing', { list: miss.join(', ') }, `⚠ Still blank on the forms: ${miss.join(', ')}`))}</div>` : ''}
            ${i.kind === 'roster' ? `<div style="font-size:0.78rem; opacity:0.75; margin-top:2px;">${esc(this._t('roster_photos', {}, 'The form also wants a photo of each player in the numbered boxes — add those in Word (or by hand) before it goes in.'))}</div>` : ''}
            <div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:6px;">
              ${i.template_file_id ? `<button type="button" class="btn btn-primary" data-le-view="${i.id}" data-entry="${en.id}" style="min-height:0; padding:5px 11px; font-size:0.8rem;">${esc(this._t('btn_preview', {}, '👁 Preview'))}</button>
                <button type="button" class="btn btn-secondary" data-le-fill="${i.id}" data-entry="${en.id}" style="min-height:0; padding:5px 11px; font-size:0.8rem;">${esc(this._t('btn_download', {}, '⬇ Filled form'))}</button>
                <button type="button" class="btn btn-secondary" data-le-blank="${i.id}" data-entry="${en.id}" style="min-height:0; padding:5px 11px; font-size:0.8rem; opacity:0.8;">${esc(this._t('btn_blank', {}, 'Blank'))}</button>` : ''}
              <button type="button" class="btn btn-secondary" data-le-done="${i.id}" data-on="${i.done_at ? 0 : 1}" ${dis} style="min-height:0; padding:5px 11px; font-size:0.8rem;">${esc(i.done_at ? this._t('btn_undo', {}, '↩ Not done') : this._t('btn_done', {}, '✓ Done'))}</button>
            </div>
          </div>
        </div>`;
    }).join('');
    const sendTo = `<div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:8px; padding-top:8px; border-top:1px solid var(--border-color);">
        ${field('Goes to — name', `<input type="text" data-le-entry-field="send_to_name" data-id="${en.id}" value="${esc(en.send_to_name)}" ${dis} style="${inputCss}">`)}
        ${field('Email', `<input type="email" data-le-entry-field="send_to_email" data-id="${en.id}" value="${esc(en.send_to_email)}" ${dis} style="${inputCss}">`)}
      </div>
      <div style="font-size:0.78rem; opacity:0.75; margin-top:6px;">${esc(this._t('sign_note', {}, 'The forms need a signature — print and sign, or sign in Word, before they count.'))}</div>
      <div style="font-size:0.78rem; opacity:0.75; margin-top:4px;">${esc(this._t('gmail_note', {}, 'Open Gmail starts the email to the league and saves the filled forms to your Downloads — drag them into the email (a Gmail link cannot attach a file).'))}</div>
      <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin-top:8px;">
        <button type="button" class="btn btn-primary" data-le-gmail="${en.id}" style="min-height:0; padding:7px 14px;">${esc(this._t('btn_gmail', { name: en.send_to_name || '…' }, `✉️ Open Gmail to ${en.send_to_name || '…'}`))}</button>
        <button type="button" class="btn btn-secondary" data-le-send="${en.id}" ${dis} style="min-height:0; padding:7px 14px;">${esc(this._t('btn_send', { name: en.send_to_name || '…' }, `✉️ Email the filled forms to ${en.send_to_name || '…'}`))}</button>
        ${en.sent_at ? `<span style="font-size:0.82rem; opacity:0.85;">${esc(this._t('sent_line', { when: when(en.sent_at) }, `✉️ Sent ${when(en.sent_at)}`))}</span>` : ''}
        ${this.note ? `<span style="font-size:0.82rem; color:#22c55e;">${esc(this.note)}</span>` : ''}
      </div>`;

    // 🏢 the club
    const d = en.director || {}, f = en.fees || {};
    const club = `<div style="${card}">${head(this._t('sec_club', {}, '🏢 THE CLUB'))}
        <div style="font-size:0.88rem; line-height:1.5;"><b>${esc(en.club)}</b><br>
          Soccer director: ${esc(d.name || '—')} · ${esc(S.phone(d.phone) || '—')} · ${esc(d.email || '—')}<br>
          ${esc(this._t('fees', { returning: f.returning || 0, new: f.new || 0, fee_returning: S.money(en.fee_returning), fee_new: S.money(en.fee_new), total: S.money(f.total), payable_to: en.payable_to },
            `${f.returning || 0} current team(s) × ${S.money(en.fee_returning)} + ${f.new || 0} new team(s) × ${S.money(en.fee_new)} = ${S.money(f.total)}, payable to ${en.payable_to}`))}</div>
      </div>`;

    // ⚽ each team + 📋 its roster
    const teams = (en.teams || []).map(tm => {
      const a = this._teamAnswers(tm);
      const txt = (label, key, ph, wide) => field(label, `<input type="text" data-le-team-field="${key}" data-id="${tm.id}" value="${esc(tm[key])}" placeholder="${esc(ph || '')}" ${dis} style="${inputCss}">`, wide);
      const pick = (label, key, cur) => field(label, `<select data-le-team-field="${key}" data-id="${tm.id}" ${dis} style="${inputCss}">
          <option value="0">—</option>${(tm.coaches || []).map(c => `<option value="${c.person_id}" ${cur && cur.person_id === c.person_id ? 'selected' : ''}>${esc(c.name)}</option>`).join('')}</select>`);
      const whoLine = (p) => p && p.name ? `<div style="font-size:0.78rem; opacity:0.75; flex:1 1 100%;">${esc(p.name)} · ${esc(p.phone || 'no phone')} · ${esc(p.email || 'no email')}</div>` : '';
      const row = (inner) => `<div style="display:flex; gap:8px; flex-wrap:wrap; margin-bottom:8px;">${inner}</div>`;
      const roster = a.roster;
      return `<div style="${card}">${head(this._t('sec_team', { team: `${tm.age_group} — ${tm.fh_team}` }, `⚽ ${tm.age_group} — ${tm.fh_team}`))}
          ${row(txt('Team name on the forms', 'team_name') + txt('Age group', 'age_group')
            + field('Male / female', `<select data-le-team-field="gender" data-id="${tm.id}" ${dis} style="${inputCss}"><option value="M" ${tm.gender === 'M' ? 'selected' : ''}>Male</option><option value="F" ${tm.gender === 'F' ? 'selected' : ''}>Female</option></select>`)
            + field(`Current team of this league (${S.money(en.fee_returning)} not ${S.money(en.fee_new)})`, `<input type="checkbox" data-le-team-field="is_returning" data-id="${tm.id}" ${tm.is_returning ? 'checked' : ''} ${dis} style="width:20px; height:20px;">`))}
          ${row(pick('Coach', 'coach_person_id', tm.coach) + whoLine(a.coach)
            + txt('Coach address', 'coach_address', (tm.coach && tm.coach.address) || '') + txt('City', 'coach_city', (tm.coach && tm.coach.city) || '') + txt('State', 'coach_state', (tm.coach && tm.coach.state) || '') + txt('Zip', 'coach_zip', (tm.coach && tm.coach.zip) || ''))}
          ${row(pick('Assistant coach', 'assistant_person_id', tm.assistant) + whoLine(a.assistant)
            + txt('Assistant address', 'assistant_address', (tm.assistant && tm.assistant.address) || '') + txt('City', 'assistant_city', (tm.assistant && tm.assistant.city) || '') + txt('State', 'assistant_state', (tm.assistant && tm.assistant.state) || '') + txt('Zip', 'assistant_zip', (tm.assistant && tm.assistant.zip) || ''))}
          ${row(txt('Home court', 'home_court', '', true) + txt('Day and time the court is free', 'court_availability', 'e.g. Saturdays 9 AM – 1 PM', true))}
          ${row(txt('Date unavailable 1', 'unavailable_1') + txt('Date unavailable 2', 'unavailable_2') + txt('Date unavailable 3', 'unavailable_3') + txt('Date unavailable 4', 'unavailable_4'))}
          ${row(txt('Last season: age group', 'prev_age_group') + txt('Last season: record (W-L-T)', 'prev_record', 'e.g. 5-2-1'))}
          <div style="margin-top:4px; padding-top:8px; border-top:1px solid var(--border-color);">
            ${head(this._t('sec_roster', { n: roster.length, max: tm.max_roster }, `📋 OFFICIAL ROSTER — ${roster.length} of ${tm.max_roster}`))}
            <div style="font-size:0.8rem; opacity:0.8; margin-bottom:6px;">${esc(roster.length
              ? this._t('roster_from', { team: tm.fh_team, max: tm.max_roster }, `These are the players on ${tm.fh_team} in 👥 Teams — add or move kids there and this list follows. First ${tm.max_roster} by name go on the form.`)
              : this._t('roster_empty', { team: tm.fh_team }, `Nobody is on ${tm.fh_team} yet. Add the players in 👥 Teams and they appear here and on the form.`))}</div>
            ${roster.length ? `<div style="overflow-x:auto;"><table style="width:100%; border-collapse:collapse; font-size:0.85rem;">
                <thead><tr style="text-align:left; opacity:0.7;"><th style="padding:3px 6px;">#</th><th style="padding:3px 6px;">Name</th><th style="padding:3px 6px;">DOB</th><th style="padding:3px 6px;">Phone</th></tr></thead>
                <tbody>${roster.map((p, i) => `<tr style="border-top:1px solid var(--border-color);"><td style="padding:3px 6px;">${i + 1}</td><td style="padding:3px 6px;">${esc(p.name)}</td>
                  <td style="padding:3px 6px; ${p.dob ? '' : 'color:#fbbf24;'}">${esc(p.dob || 'missing')}</td><td style="padding:3px 6px; ${p.phone ? '' : 'color:#fbbf24;'}">${esc(S.phone(p.phone) || 'missing')}</td></tr>`).join('')}</tbody></table></div>
                ${(tm.roster || []).length > roster.length ? `<div style="font-size:0.78rem; color:#fbbf24; margin-top:4px;">+${tm.roster.length - roster.length} more on the team than the form holds.</div>` : ''}` : ''}
          </div>
        </div>`;
    }).join('');

    return `<h2 style="margin:var(--space-3) 0 var(--space-2); font-size:1.15rem;">${esc(en.title)} <span style="font-size:0.8rem; font-weight:400; opacity:0.7;">${esc(en.league)}</span></h2>
      <div style="${card}">${head(`${this._t('sec_items', {}, '✅ CHECKLIST')} — ${done} / ${en.items.length}`)}${items}${sendTo}</div>
      ${club}${teams}`;
  }
}

window.LeagueRegistrationScreen = LeagueRegistrationScreen;
