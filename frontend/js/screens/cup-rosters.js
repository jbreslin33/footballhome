// cup-rosters.js — #cup-rosters: the USASA Region I Player Pool sheet (the
// EPSA / USASA cup roster form) filled from the men's rosters (mig 556).
// Owner 2026-10-09: "for cup rosters we fill out special form … reproduce
// this like we did for invoices. have a blank one and then allow me to
// check off players to fill it from apsl and liga 1 and reserves".
//
//   Sheets      one row per saved sheet (GET /api/cup-rosters/board);
//               + New sheet copies the last sheet's header; 🖨 Blank form
//               prints the empty form.
//   Header      team / cup / association / competition / state, uniform
//               colours, coach-manager / email / phone, verification name
//               and date — typed once, saved on change (POST /:id/update).
//   Players     the pool: everyone on APSL, Reserves and Liga 1, a pill
//               per team to narrow; tick to add (POST /:id/players), 30 max;
//               a player with no date of birth on file is flagged.
//   Sheet       drawn from the header + ticked players, names and DOB from
//               each person's record; Print / Save PDF; 🔗 Copy link gives
//               /cup-roster?k=<slug>, the sheet with no sign-in.
//
// Wording: message_templates kind 'cup_roster'.
class CupRostersScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.board = null; this.sheet = null; this.teamPill = 'all'; this.err = ''; this.loading = false; this.blank = false;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('cup_roster', tier, tokens) : ''; }
  _t(tier, fallback, tokens = {}) { return this._copy(tier, tokens) || (window.MessageCopy && MessageCopy.fill ? MessageCopy.fill(fallback, tokens) : fallback); }
  static get MAX() { return 30; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .cr-wrap { display:grid; grid-template-columns: minmax(280px, 420px) 1fr; gap:16px; align-items:start; }
        @media (max-width: 900px) { .cr-wrap { grid-template-columns: 1fr; } }
        .cr-card { border:1px solid var(--border-color, #374151); border-radius:8px; background:var(--bg-tertiary, #1f2937); padding:12px 14px; margin-bottom:12px; }
        .cr-card h3 { margin:0 0 8px; font-size:0.95rem; }
        .cr-list .row { display:flex; justify-content:space-between; gap:8px; padding:6px 8px; border-radius:6px; cursor:pointer; }
        .cr-list .row:hover, .cr-list .row.on { background:rgba(148,163,184,0.12); }
        .cr-grid { display:grid; grid-template-columns: 1fr 1fr; gap:6px 10px; }
        .cr-grid label { display:flex; flex-direction:column; font-size:0.72rem; opacity:0.8; gap:2px; }
        .cr-grid input { padding:5px 7px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary, #111827); color:inherit; font:inherit; font-size:0.85rem; }
        .cr-pills { display:flex; flex-wrap:wrap; gap:6px; margin:6px 0 8px; }
        .cr-pill { padding:4px 10px; border-radius:999px; border:1px solid var(--border-color); background:transparent; color:inherit; cursor:pointer; font-weight:700; font-size:0.8rem; }
        .cr-pill.on { background:var(--primary-color); color:#fff; border-color:var(--primary-color); }
        .cr-players { max-height:520px; overflow:auto; font-size:0.85rem; }
        .cr-players label { display:flex; align-items:center; gap:8px; padding:4px 6px; border-radius:6px; cursor:pointer; }
        .cr-players label:hover { background:rgba(148,163,184,0.1); }
        .cr-players label.off { opacity:0.45; cursor:not-allowed; }
        .cr-players .t { opacity:0.6; font-size:0.72rem; margin-left:auto; white-space:nowrap; }
        .cr-players .nodob { color:#fde68a; font-size:0.7rem; font-weight:800; }
        .cr-btns { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:10px; }
        .cr-preview-wrap { overflow:hidden; }
        .cr-preview-wrap .cr-scale { transform-origin: top left; }
        /* ── the sheet: 8.5×11 in, drawn to the form ───────────────────── */
        .cr-sheet { position:relative; width:612pt; height:792pt; background:#fff; color:#111; font-family: "Century Gothic", "Trebuchet MS", Arial, sans-serif; box-shadow:0 4px 20px rgba(0,0,0,0.35); box-sizing:border-box; padding:38pt 36pt 0 36pt; font-size:8.5pt; }
        .cr-sheet * { box-sizing:border-box; }
        .cr-sheet .type { text-align:center; font-weight:800; font-size:8.5pt; margin-bottom:3pt; }
        .cr-sheet .cr-bar { background:#1f3864; color:#fff; text-align:center; font-weight:800; font-size:14pt; padding:3pt 0; }
        .cr-sheet table { border-collapse:collapse; width:100%; table-layout:fixed; }
        .cr-sheet td, .cr-sheet th { border:1px solid #333; padding:1.5pt 3pt; height:13pt; vertical-align:middle; font-size:8.5pt; overflow:hidden; white-space:nowrap; }
        .cr-sheet th { background:#dbe5f1; color:#1f3864; text-align:left; font-weight:800; }
        .cr-sheet th.c { text-align:center; }
        .cr-sheet td.lab { background:#dbe5f1; color:#1f3864; font-weight:700; }
        .cr-sheet .gap { height:9pt; }
        .cr-sheet .players { width:400pt; }
        .cr-sheet .players th { text-align:center; height:26pt; white-space:normal; line-height:1.1; }
        .cr-sheet .players td.n { width:14pt; text-align:center; background:#dbe5f1; color:#1f3864; font-weight:700; }
        .cr-sheet .players tr.alt td { background:#dbe5f1; }
        .cr-sheet .players tr.alt td.n { background:#dbe5f1; }
        .cr-sheet .logo { position:absolute; right:40pt; top:262pt; width:110pt; }
        .cr-sheet .count { margin-top:9pt; display:flex; gap:6pt; align-items:flex-start; }
        .cr-sheet .count table { width:130pt; }
        .cr-sheet .count .note { font-weight:800; font-size:9pt; line-height:14pt; }
        .cr-sheet .ver { margin-top:12pt; width:400pt; }
        .cr-sheet .name { margin-top:4pt; width:400pt; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="cr-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="cr-title">🏆 Cup Rosters</h1><div id="cr-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
        <button class="btn btn-primary" id="cr-new" style="padding:6px 12px; font-size:0.9rem;">+ New sheet</button>
        <button class="btn btn-secondary" id="cr-blank" style="padding:6px 12px; font-size:0.9rem;">🖨 Blank form</button>
      </div>
      <div class="screen-content" style="max-width:1400px; margin:0 auto;">
        <div id="cr-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#cr-back').addEventListener('click', () => this.navigation.goBack());
    div.querySelector('#cr-new').addEventListener('click', () => this.newSheet());
    div.querySelector('#cr-blank').addEventListener('click', () => this.printBlank());
    div.addEventListener('click', (e) => {
      const row = e.target.closest('[data-cr-open]'); if (row) { this.open(Number(row.dataset.crOpen)); return; }
      const pill = e.target.closest('[data-cr-team]'); if (pill) { this.teamPill = pill.dataset.crTeam; this._renderPlayers(); return; }
      if (e.target.closest('#cr-print')) { this.print(); return; }
      if (e.target.closest('#cr-link')) { this.copyLink(); return; }
      if (e.target.closest('#cr-email')) { this.emailSheet(); return; }
      if (e.target.closest('#cr-delete')) { this.remove(); return; }
    });
    div.addEventListener('change', (e) => {
      const f = e.target.closest('[data-cr-field]'); if (f) { this.update({ [f.dataset.crField]: f.value }); return; }
      const cb = e.target.closest('[data-cr-person]'); if (cb) { this.toggle(Number(cb.dataset.crPerson), cb.checked); }
    });
    return div;
  }

  async onEnter(params) {
    if (window.MessageCopy && typeof MessageCopy.load === 'function') { try { await MessageCopy.load(this.auth); } catch (_) {} }
    const t = this.find('#cr-title'), s = this.find('#cr-sub'), n = this.find('#cr-new'), b = this.find('#cr-blank');
    if (t) t.textContent = this._t('title', '🏆 Cup Rosters');
    if (s) s.textContent = this._t('subtitle', "The USASA Region I Player Pool form, filled from the men's rosters.");
    if (n) n.textContent = this._t('new', '+ New sheet');
    if (b) b.textContent = this._t('blank', '🖨 Blank form');
    await this.load();
    if (params && params.id) this.open(Number(params.id));
    else if (this.board && this.board.rosters.length && !this.sheet) this.open(this.board.rosters[0].id);
  }

  async _json(path, opts) {
    const res = await this.auth.fetch(path, opts);
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }
  async _post(path, payload) { return this._json(path, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload || {}) }); }

  async load() {
    this.loading = true; this.err = ''; this._renderBody();
    try { this.board = await this._json('/api/cup-rosters/board'); } catch (e) { this.err = e.message; }
    this.loading = false; this._renderBody();
  }
  async open(id) {
    try { this.sheet = await this._json(`/api/cup-rosters/${id}`); this.err = ''; } catch (e) { this.err = e.message; }
    this._renderBody();
  }
  async newSheet() {
    try { const r = await this._post('/api/cup-rosters/new', {}); await this.load(); await this.open(r.id); } catch (e) { this.err = e.message; this._renderBody(); }
  }
  async update(fields) {
    if (!this.sheet) return;
    try { this.sheet = await this._post(`/api/cup-rosters/${this.sheet.id}/update`, fields); this._renderSheetOnly(); this._refreshList(); } catch (e) { this.err = e.message; this._renderBody(); }
  }
  async toggle(personId, on) {
    if (!this.sheet) return;
    const ids = new Set((this.sheet.players || []).map(p => p.person_id));
    if (on) ids.add(personId); else ids.delete(personId);
    if (ids.size > (this.sheet.max || CupRostersScreen.MAX)) { this._renderPlayers(); return; }
    try { this.sheet = await this._post(`/api/cup-rosters/${this.sheet.id}/players`, { person_ids: [...ids] }); this._renderPlayers(); this._renderSheetOnly(); this._refreshList(); }
    catch (e) { this.err = e.message; this._renderBody(); }
  }
  async remove() {
    if (!this.sheet) return;
    const btn = this.find('#cr-delete');
    if (btn && btn.dataset.armed !== '1') { btn.dataset.armed = '1'; btn.textContent = `${this._t('delete', '🗑 Delete')} — tap again`; setTimeout(() => { if (btn.isConnected) { btn.dataset.armed = ''; btn.textContent = this._t('delete', '🗑 Delete'); } }, 4000); return; }
    try { await this._json(`/api/cup-rosters?id=${this.sheet.id}`, { method: 'DELETE' }); this.sheet = null; await this.load(); } catch (e) { this.err = e.message; this._renderBody(); }
  }
  _publicUrl() { return this.sheet && this.sheet.public_slug ? `${location.origin}/cup-roster?k=${this.sheet.public_slug}` : ''; }
  async copyLink() {
    const url = this._publicUrl(); if (!url) return;
    try { await navigator.clipboard.writeText(url); } catch (_) { window.prompt('Copy this link', url); }
    const b = this.find('#cr-link'); if (b) { const was = b.textContent; b.textContent = '✓ Copied'; setTimeout(() => { if (b.isConnected) b.textContent = was; }, 1500); }
  }

  _recipientsLine() {
    const rs = (this.board && this.board.recipients) || [];
    return rs.length ? this._t('email_to', 'Goes to {names}', { names: rs.map(r => `${r.name}${r.role ? ` (${r.role})` : ''}`).join(', ') }) : this._t('email_none', 'No cup roster recipients are loaded yet.');
  }

  // ✉️ Email sheet (mig 557): a Gmail compose to every cup_roster_recipients
  // row with the sheet's public link in the body.  A browser cannot attach
  // a file to a compose window, so the sender attaches the saved PDF.
  emailSheet() {
    const s = this.sheet; if (!s) return;
    const rs = (this.board && this.board.recipients) || [];
    if (!rs.length) { this.err = this._t('email_none', 'No cup roster recipients are loaded yet.'); this._renderBody(); return; }
    const tokens = { team: s.team_name || '', cup: s.cup || '', competition: s.competition || '', count: (s.players || []).length,
                     link: this._publicUrl(), sender: (this.board && this.board.sender) || '' };
    const r = window.MessageCopy && MessageCopy.render ? MessageCopy.render('cup_roster', 'email', tokens) : null;
    const subject = (r && r.subject) || `${tokens.team} — ${tokens.cup} player pool`;
    const body = (r && r.body) || `${tokens.team} player pool: ${tokens.link}`;
    this.openGmailCompose(this.buildGmailComposeHref({ to: rs.map(x => x.email).join(','), subject, body }));
  }

  async _refreshList() { try { this.board = await this._json('/api/cup-rosters/board'); } catch (_) {} const el = this.find('#cr-list'); if (el) el.innerHTML = this._renderList(); }

  _renderBody() {
    const el = this.find('#cr-body'); if (!el) return;
    if (this.loading && !this.board) { el.innerHTML = `<div class="loading">Loading…</div>`; return; }
    const err = this.err ? `<div style="color:#f87171; padding:4px 0 8px;">⚠️ ${this.escapeHtml(this.err)}</div>` : '';
    const s = this.sheet;
    el.innerHTML = `${err}<div class="cr-wrap">
      <div>
        <div class="cr-card"><h3>Sheets</h3><div class="cr-list" id="cr-list">${this._renderList()}</div></div>
        ${s ? `<div class="cr-card"><h3>Sheet</h3>${this._renderHeaderForm(s)}</div>
               <div class="cr-card"><h3 id="cr-players-h"></h3><div class="cr-pills" id="cr-pills"></div><div class="cr-players" id="cr-players"></div></div>` : ''}
      </div>
      <div>
        ${s ? `<div class="cr-btns">
                 <button class="btn btn-primary" id="cr-print">${this.escapeHtml(this._t('print', '🖨 Print / Save PDF'))}</button>
                 <button class="btn btn-secondary" id="cr-link">${this.escapeHtml(this._t('copy_link', '🔗 Copy link'))}</button>
                 <button class="btn btn-secondary" id="cr-email" title="${this.escapeHtml(this._recipientsLine())}">${this.escapeHtml(this._t('email_btn', '✉️ Email sheet'))}</button>
                 <span style="flex:1;"></span>
                 <button class="btn btn-secondary" id="cr-delete">${this.escapeHtml(this._t('delete', '🗑 Delete'))}</button>
               </div>
               <div class="cr-preview-wrap"><div class="cr-scale" id="cr-sheet">${this._renderSheet(s)}</div></div>` : ''}
      </div>
    </div>`;
    if (s) { this._renderPlayers(); this._fitPreview(); }
  }

  _renderList() {
    const rs = (this.board && this.board.rosters) || [];
    if (!rs.length) return `<div style="opacity:0.7; font-size:0.85rem;">${this.escapeHtml(this._t('empty_list', 'No sheets yet.'))}</div>`;
    return rs.map(r => `<div class="row${this.sheet && this.sheet.id === r.id ? ' on' : ''}" data-cr-open="${r.id}">
      <span><b>${this.escapeHtml(r.title || r.cup || r.competition || `Sheet ${r.id}`)}</b> <span style="opacity:0.6; font-size:0.8rem;">${this.escapeHtml(r.sheet_date || '')}</span></span>
      <span style="opacity:0.7; font-size:0.8rem;">${r.players}/${(this.board && this.board.max) || CupRostersScreen.MAX}</span></div>`).join('');
  }

  _renderHeaderForm(s) {
    const esc = (t) => this.escapeHtml(t == null ? '' : t);
    const f = (key, label, extra = '') => `<label>${esc(label)}<input data-cr-field="${key}" value="${esc(s[key])}" ${extra}></label>`;
    return `<div class="cr-grid">
      ${f('title', 'Sheet name (yours)')}${f('team_name', 'Team name')}
      ${f('cup', 'Cup')}${f('competition', 'Competition')}
      ${f('state_association', 'State association')}${f('state', 'State')}
      ${f('shirt_primary', 'Shirt — primary')}${f('shirt_alt', 'Shirt — alternate')}
      ${f('shorts_primary', 'Shorts — primary')}${f('shorts_alt', 'Shorts — alternate')}
      ${f('socks_primary', 'Socks — primary')}${f('socks_alt', 'Socks — alternate')}
      ${f('coach_name', 'Coach / manager')}${f('coach_phone', 'Phone')}
      ${f('coach_email', 'Email')}<label>Date<input data-cr-field="sheet_date" type="date" value="${esc(s.sheet_date)}"></label>
      ${f('verification_name', 'Name (verification line)')}
    </div>`;
  }

  _renderPlayers() {
    const s = this.sheet; if (!s) return;
    const b = this.board || { pool: [], teams: [] };
    const max = s.max || CupRostersScreen.MAX;
    const on = new Set((s.players || []).map(p => p.person_id));
    const h = this.find('#cr-players-h'); if (h) h.textContent = this._t('players_h', 'Players — {n} of {max}', { n: on.size, max });
    const pills = this.find('#cr-pills');
    if (pills) pills.innerHTML = `<button class="cr-pill${this.teamPill === 'all' ? ' on' : ''}" data-cr-team="all">All</button>` +
      (b.teams || []).map(t => `<button class="cr-pill${this.teamPill === String(t.id) ? ' on' : ''}" data-cr-team="${t.id}">${this.escapeHtml(t.label)}</button>`).join('');
    const list = (b.pool || []).filter(p => this.teamPill === 'all' || (p.team_ids || []).includes(Number(this.teamPill)));
    const full = on.size >= max;
    const el = this.find('#cr-players');
    if (el) el.innerHTML = (full ? `<div style="color:#fde68a; font-size:0.8rem; padding:2px 6px 6px;">${this.escapeHtml(this._t('full', 'Pool is set at {max}. No more additions allowed.', { max }))}</div>` : '') +
      list.map(p => { const checked = on.has(p.person_id); const off = full && !checked;
        return `<label class="${off ? 'off' : ''}"><input type="checkbox" data-cr-person="${p.person_id}" ${checked ? 'checked' : ''} ${off ? 'disabled' : ''}>
          <span>${this.escapeHtml(p.last_name)}, ${this.escapeHtml(p.first_name)}${p.dob ? '' : ` <span class="nodob">${this.escapeHtml(this._t('no_dob', 'no DOB on file'))}</span>`}</span>
          <span class="t">${this.escapeHtml(p.teams || '')}${p.dob ? ` · ${this.escapeHtml(p.dob)}` : ''}</span></label>`; }).join('');
  }

  _renderSheetOnly() { const el = this.find('#cr-sheet'); if (el && this.sheet) el.innerHTML = this._renderSheet(this.sheet); }

  // The form, drawn in HTML: title bar, four header blocks, 30 numbered rows
  // with the USASA Region I badge beside them, the player count, the
  // verification and name lines.  Empty `s` fields give the blank form.
  _renderSheet(s) {
    const esc = (t) => this.escapeHtml(t == null ? '' : t);
    const max = (s && s.max) || CupRostersScreen.MAX;
    const players = (s && s.players) || [];
    const rows = [];
    for (let i = 0; i < max; i++) {
      const p = players[i] || {};
      rows.push(`<tr class="${i % 2 ? 'alt' : ''}"><td class="n">${i + 1}</td><td>${esc(p.last_name)}</td><td>${esc(p.first_name)}</td><td style="text-align:center;">${esc(p.dob)}</td></tr>`);
    }
    const v = (k) => esc(s ? s[k] : '');
    return `<div class="cr-sheet">
      <div class="type">${esc(this._t('sheet_type', 'TYPE ALL INFORMATION'))}</div>
      <div class="cr-bar">${esc(this._t('sheet_title', 'USASA Region I Player Pool'))}</div>
      <table><colgroup><col style="width:50%"><col style="width:25%"><col style="width:25%"></colgroup>
        <tr><th>TEAM NAME</th><th>CUP</th><th>STATE ASSOCIATION</th></tr>
        <tr><td rowspan="2" style="font-size:10pt; font-weight:700;">${v('team_name')}</td><td>${v('cup')}</td><td>${v('state_association')}</td></tr>
        <tr><td class="lab">${s && s.competition ? v('competition') : 'SELECT COMPETITION'}</td><td class="lab">${s && s.state ? v('state') : 'SELECT STATE'}</td></tr>
      </table>
      <div class="gap"></div>
      <table><colgroup><col style="width:25%"><col style="width:25%"><col style="width:25%"><col style="width:25%"></colgroup>
        <tr><th>UNIFORM COLORS</th><th class="c">SHIRT</th><th class="c">SHORTS</th><th class="c">SOCKS</th></tr>
        <tr><td class="lab" style="font-weight:400;">PRIMARY</td><td>${v('shirt_primary')}</td><td>${v('shorts_primary')}</td><td>${v('socks_primary')}</td></tr>
        <tr><td class="lab" style="font-weight:400;">ALTERNATE</td><td>${v('shirt_alt')}</td><td>${v('shorts_alt')}</td><td>${v('socks_alt')}</td></tr>
      </table>
      <div class="gap"></div>
      <table><colgroup><col style="width:25%"><col style="width:50%"><col style="width:25%"></colgroup>
        <tr><th>COACH/MANAGER</th><th class="c">EMAIL</th><th>PHONE</th></tr>
        <tr><td>${v('coach_name')}</td><td>${v('coach_email')}</td><td>${v('coach_phone')}</td></tr>
        <tr><td></td><td></td><td></td></tr>
      </table>
      <div class="gap"></div>
      <table class="players"><colgroup><col style="width:14pt"><col style="width:33%"><col style="width:33%"><col></colgroup>
        <tr><th style="background:#fff; border:none;"></th><th class="c">Player's<br>Last Name</th><th class="c">Player's<br>First Name</th><th class="c">DOB<br>m/d/y</th></tr>
        ${rows.join('')}
      </table>
      <img class="logo" src="/images/usasa-region1.png" alt="">
      <div class="count">
        <table><tr><th>PLAYER COUNT</th></tr><tr><td style="font-weight:700;">${players.length}</td></tr></table>
        <div class="note">${esc(this._t('sheet_pool', 'Pool is set at {max}.', { max }))}<br>${esc(this._t('sheet_pool2', 'No more additions allowed after {max} is reached.', { max }))}</div>
      </div>
      <table class="ver"><colgroup><col style="width:66%"><col></colgroup>
        <tr><th>State Association Verification</th><th>Date</th></tr>
        <tr><td style="height:13pt;"></td><td>${v('sheet_date_us')}</td></tr>
      </table>
      <table class="name"><colgroup><col style="width:66%"><col></colgroup>
        <tr><td class="lab" style="height:13pt;">Name: <span style="font-weight:400; color:#111;">${v('verification_name')}</span></td><td></td></tr>
      </table>
    </div>`;
  }

  _fitPreview() {
    const wrap = this.find('.cr-preview-wrap'), inner = wrap && wrap.querySelector('.cr-scale');
    if (!wrap || !inner) return;
    const scale = Math.min(1, (wrap.clientWidth || 816) / 816);
    inner.style.transform = `scale(${scale})`;
    wrap.style.height = `${Math.ceil(1056 * scale) + 16}px`;
  }

  printBlank() { this._printHtml(this._renderSheet(null), 'USASA-Player-Pool-blank'); }
  print() { if (this.sheet) this._printHtml(this._renderSheet(this.sheet), `Player-Pool-${(this.sheet.title || this.sheet.cup || 'sheet').replace(/[^A-Za-z0-9]+/g, '-')}`); }

  // Same print path as #invoices: the sheet alone on a zero-margin letter
  // page, so Chrome adds no header or footer.
  _printHtml(html, title) {
    const was = document.title;
    const root = document.createElement('div'); root.className = 'cr-print-root'; root.innerHTML = html;
    const pageStyle = document.createElement('style'); pageStyle.textContent = '@page { size: letter; margin: 0; }';
    document.head.appendChild(pageStyle);
    const style = document.createElement('style');
    style.textContent = `@media print { html, body { margin:0 !important; padding:0 !important; } body.cr-printing > :not(.cr-print-root) { display:none !important; } body.cr-printing { background:#fff !important; }
      .cr-print-root .cr-sheet { box-shadow:none; } .cr-print-root th, .cr-print-root td, .cr-print-root .cr-bar { -webkit-print-color-adjust:exact; print-color-adjust:exact; } }
      @media screen { .cr-print-root { display:none; } }`;
    root.appendChild(style);
    const sheetCss = this.element && this.element.querySelector('style');
    if (sheetCss) root.appendChild(sheetCss.cloneNode(true));
    document.body.appendChild(root);
    document.body.classList.add('cr-printing');
    document.title = title;
    const done = () => { document.body.classList.remove('cr-printing'); root.remove(); pageStyle.remove(); document.title = was; window.removeEventListener('afterprint', done); };
    window.addEventListener('afterprint', done);
    setTimeout(() => window.print(), 50);
    setTimeout(done, 60000);
  }
}
