// LeagueSchedulesScreen — #league-schedules (migration 566): the leagues'
// own schedule pages (the owner's "schedules" bookmarks) saved as DB rows
// and opened from one page.  Owner 2026-10-12: "i have short cuts to all
// schedules in schedules bookmark on soccer chrome … please save them and
// display links on a page on fh. maybe we need a schedule maker page."
//
// A card per link (label, host, note) opening in a new tab; club admins
// add, edit and retire links right here — no migration for a new season's
// team id.  (#schedules was already the public team-schedule directory,
// hence #league-schedules.)
//
//   GET    /api/schedule-links
//   POST   /api/schedule-links          { id?, label, url, note?, sort_order? }
//   DELETE /api/schedule-links?id=…
//
// Wording: message_templates kind 'league_schedules'.
class LeagueSchedulesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.links = [];
    this.loading = false;
    this.error = null;
    this.flash = '';
    this.editId = 0;       // 0 = none, -1 = new-link form open
    this.confirmDelete = 0;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('league_schedules', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ls-card { border:1px solid var(--border-color); border-radius:12px; background:var(--bg-secondary);
                   padding:12px 14px; margin-bottom:var(--space-2); }
        .ls-row { display:flex; gap:12px; align-items:center; }
        .ls-row .grow { flex:1; min-width:0; }
        .ls-label { font-weight:800; }
        .ls-host { font-size:0.8rem; opacity:0.65; }
        .ls-note { font-size:0.85rem; opacity:0.8; margin-top:2px; }
        .ls-btn { padding:8px 14px; border-radius:10px; border:none; cursor:pointer; font-weight:800; font-size:0.9rem;
                  color:#0b1c3d; background:#4ade80; }
        .ls-btn.ghost { background:transparent; color:var(--text-primary); border:1px solid var(--border-color); }
        .ls-btn.danger { background:transparent; color:#f87171; border:1px solid #f87171; }
        .ls-btn.sm { padding:5px 10px; font-size:0.78rem; }
        .ls-open { text-decoration:none; font-weight:800; padding:8px 14px; border-radius:10px;
                   background:var(--primary-color); color:#fff; white-space:nowrap; }
        .ls-in { padding:8px; border-radius:8px; border:1px solid var(--border-color); background:var(--bg-primary);
                 color:var(--text-primary); font-size:0.9rem; width:100%; }
        .ls-grid { display:grid; grid-template-columns:1fr 2fr; gap:8px; margin-top:6px; }
        .ls-grid .wide { grid-column:1 / -1; }
        .ls-lbl { font-size:0.72rem; opacity:0.65; text-transform:uppercase; letter-spacing:0.04em; margin-bottom:2px; }
        .ls-flash { padding:8px 12px; border-radius:8px; background:rgba(74,222,128,0.15); margin-bottom:var(--space-2); font-size:0.85rem; }
        .ls-flash.bad { background:rgba(248,113,113,0.15); }
        .ls-hint { font-size:0.8rem; opacity:0.7; margin:4px 0 10px; }
        @media (max-width: 600px) { .ls-row { flex-wrap:wrap; } .ls-grid { grid-template-columns:1fr; } }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ls-title">🗓 League Schedules</h1>
        <p class="subtitle" id="ls-sub"></p>
      </div>
      <div style="padding: var(--space-4); max-width: 760px; margin: 0 auto;">
        <div id="ls-body"></div>
      </div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter() {
    this.flash = ''; this.error = null; this.editId = 0; this.confirmDelete = 0;
    this._renderBody();
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => {
      const t = this.find('#ls-title'); if (t && this._copy('title')) t.textContent = this._copy('title');
      const s = this.find('#ls-sub'); if (s) s.textContent = this._copy('subtitle');
      this._renderBody();
    });
    this._load();
  }

  async _json(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    const headers = { ...(options.headers || {}) };
    if (method !== 'GET') headers['Content-Type'] = 'application/json';
    const res = await this.auth.fetch(url, { ...options, headers });
    let body = null;
    try { body = await res.json(); } catch {}
    if (!res.ok) throw new Error((body && body.error) || `HTTP ${res.status}`);
    return body || {};
  }

  async _load() {
    this.loading = true; this._renderBody();
    try {
      const body = await this._json('/api/schedule-links');
      this.links = body.links || [];
      this.error = null;
    } catch (err) { this.error = err.message || 'Failed to load.'; }
    this.loading = false;
    this._renderBody();
  }

  async _save(id) {
    const v = (sel) => (this.find(sel)?.value || '').trim();
    const payload = { label: v('#ls-f-label'), url: v('#ls-f-url'), note: v('#ls-f-note') };
    if (id > 0) payload.id = id;
    try {
      const body = await this._json('/api/schedule-links', { method: 'POST', body: JSON.stringify(payload) });
      this.links = body.links || [];
      this.editId = 0;
      this.flash = this._copy('saved') || 'Saved.'; this.flashBad = false;
    } catch (err) { this.flash = err.message; this.flashBad = true; }
    this._renderBody();
  }

  async _remove(id) {
    if (this.confirmDelete !== id) { this.confirmDelete = id; this._renderBody(); return; }
    this.confirmDelete = 0;
    try {
      const body = await this._json(`/api/schedule-links?id=${id}`, { method: 'DELETE' });
      this.links = body.links || [];
      this.flash = this._copy('removed') || 'Link removed.'; this.flashBad = false;
    } catch (err) { this.flash = err.message; this.flashBad = true; }
    this._renderBody();
  }

  _wire() {
    const el = this.element;
    el.addEventListener('click', async (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      const edit = e.target.closest('[data-edit]');
      if (edit) { this.editId = Number(edit.dataset.edit); this.confirmDelete = 0; this._renderBody(); return; }
      if (e.target.closest('#ls-add')) { this.editId = -1; this.confirmDelete = 0; this._renderBody(); return; }
      if (e.target.closest('#ls-cancel')) { this.editId = 0; this._renderBody(); return; }
      const save = e.target.closest('[data-save]');
      if (save) { await this._save(Number(save.dataset.save)); return; }
      const del = e.target.closest('[data-remove]');
      if (del) { await this._remove(Number(del.dataset.remove)); return; }
    });
    el.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && e.target.closest('#ls-f-label, #ls-f-url, #ls-f-note')) {
        e.preventDefault();
        const save = this.find('[data-save]');
        if (save) save.click();
      }
    });
  }

  _host(url) { try { return new URL(url).host.replace(/^www\./, ''); } catch { return ''; } }

  _form(link) {
    const esc = (t) => this.escapeHtml(t);
    const l = link || { id: 0, label: '', url: '', note: '' };
    return `
      <div class="ls-grid">
        <div><div class="ls-lbl">Label</div><input class="ls-in" id="ls-f-label" value="${esc(l.label)}" placeholder="U8 — PPR"></div>
        <div><div class="ls-lbl">Link</div><input class="ls-in" id="ls-f-url" type="url" value="${esc(l.url)}" placeholder="https://…"></div>
        <div class="wide"><div class="ls-lbl">Note</div><input class="ls-in" id="ls-f-note" value="${esc(l.note || '')}" placeholder="where it lives, what changes each season"></div>
      </div>
      <div style="display:flex; gap:8px; margin-top:8px;">
        <button class="ls-btn" data-save="${l.id}">Save</button>
        <button class="ls-btn ghost" id="ls-cancel">Cancel</button>
      </div>`;
  }

  _renderBody() {
    const body = this.find('#ls-body');
    if (!body) return;
    const esc = (t) => this.escapeHtml(t);
    const parts = [];
    if (this.flash) parts.push(`<div class="ls-flash ${this.flashBad ? 'bad' : ''}">${esc(this.flash)}</div>`);
    if (this.error) parts.push(`<div class="ls-flash bad">${esc(this.error)}</div>`);
    parts.push(`<div class="ls-hint">${esc(this._copy('hint') || 'These open the league’s site in a new tab. Keep them current here when a league moves or a new season gets a new team id.')}</div>`);
    if (this.loading && !this.links.length) parts.push('<div class="ls-card">Loading…</div>');
    else if (!this.links.length) parts.push(`<div class="ls-card">${esc(this._copy('empty') || 'No schedule links yet — add the first one below.')}</div>`);
    for (const l of this.links) {
      if (this.editId === l.id) { parts.push(`<div class="ls-card">${this._form(l)}</div>`); continue; }
      parts.push(`
        <div class="ls-card ls-row">
          <div class="grow">
            <div class="ls-label">${esc(l.label)} <span class="ls-host">· ${esc(this._host(l.url))}</span></div>
            ${l.note ? `<div class="ls-note">${esc(l.note)}</div>` : ''}
          </div>
          <a class="ls-open" href="${esc(l.url)}" target="_blank" rel="noopener">Open ↗</a>
          <button class="ls-btn ghost sm" data-edit="${l.id}" title="Edit">✏️</button>
          <button class="ls-btn danger sm" data-remove="${l.id}" title="Remove">${this.confirmDelete === l.id ? 'Sure?' : '✕'}</button>
        </div>`);
    }
    if (this.editId === -1) parts.push(`<div class="ls-card">${this._form(null)}</div>`);
    else parts.push(`<div style="margin-top:var(--space-2);"><button class="ls-btn" id="ls-add">${esc(this._copy('add_button') || '➕ Add link')}</button></div>`);
    body.innerHTML = parts.join('');
  }
}
