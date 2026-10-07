// ContactsScreen — #contacts: the club's people into your phone, one tap
// (migration 541).  Owner 2026-10-07: "a contacts page where i can click
// a button and get an import of all contacts into my phone that are
// members or leads etc." / "if someone was imported already it would
// ignore them?"
//
// Top-level 📇 Contacts tile (club admins).  Group pills (Members,
// Parents, Coaches, Staff, Leads, Opponents — multi-select) and a scope
// (New since my last export / Changed since / Everything), then one
// button that downloads a single .vcf; the phone opens it and offers Add
// All Contacts.  Phones do not de-duplicate an import, so the server logs
// what this login exported (contact_exports) and "new" is the default.
//
//   GET  /api/contacts/summary
//   POST /api/contacts/export   { groups, scope }   → text/vcard
//
// Wording: message_templates kind 'contacts'.
class ContactsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.summary = null;
    this.groups = new Set(['members', 'parents', 'coaches', 'staff', 'leads', 'opponents']);
    this.scope = 'new';
    this.busy = false;
    this.message = '';
    this.error = null;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('contacts', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-contacts';
    div.innerHTML = `
      <style>
        .ct-chip { padding:6px 12px; border-radius:999px; cursor:pointer; font-size:0.85rem; font-weight:700;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .ct-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .ct-chip .n { opacity:0.75; font-weight:400; margin-left:4px; }
        .ct-row { display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2); }
        .ct-line { font-size:0.85rem; opacity:0.75; margin:var(--space-2) 0; }
        .ct-go { font-size:1.1rem; padding:14px 22px; }
        .ct-msg { margin-top:var(--space-3); font-weight:600; }
        .ct-msg.bad { color:#ef4444; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="ct-title">📇 Contacts</h1>
        <p class="subtitle" id="ct-sub"></p>
      </div>
      <div style="padding: var(--space-4); max-width: 760px; margin: 0 auto;">
        <div id="ct-body"></div>
      </div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter() {
    this.error = null; this.message = '';
    this._render();
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => this._render());
    this._load();
  }

  async _json(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    const headers = { ...(options.headers || {}) };
    if (method !== 'GET') headers['Content-Type'] = 'application/json';
    const res = await this.auth.fetch(url, { ...options, headers });
    let body = null;
    try { body = await res.json(); } catch {}
    if (!res.ok) throw new Error((body && (body.message || body.error)) || `HTTP ${res.status}`);
    return body || {};
  }

  async _load() {
    try {
      this.summary = await this._json('/api/contacts/summary');
      this.error = null;
    } catch (err) {
      console.error('[contacts] summary failed:', err);
      this.error = err.message;
    }
    this._render();
  }

  // What the button would export: a contact counted once per group, so
  // this over-counts someone in two picked groups; the server's reply
  // carries the true count.
  _count(scope = this.scope) {
    if (!this.summary) return 0;
    let n = 0;
    for (const g of this.groups) {
      const c = this.summary.groups[g] || {};
      n += scope === 'all' ? (c.all || 0) : scope === 'changed' ? (c.new || 0) + (c.changed || 0) : (c.new || 0);
    }
    return n;
  }

  // Download the .vcf: fetch with the session, then hand the phone a file
  // it opens as contacts.
  async _export() {
    if (this.busy) return;
    this.busy = true; this.message = ''; this._render();
    try {
      const res = await this.auth.fetch('/api/contacts/export', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ groups: [...this.groups], scope: this.scope }),
      });
      if (!res.ok) {
        let body = null; try { body = await res.json(); } catch {}
        throw new Error((body && body.error) || `HTTP ${res.status}`);
      }
      const n = Number(res.headers.get('X-Contact-Count') || 0);
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = this._copy('filename') || 'contacts.vcf';
      document.body.appendChild(a);
      a.click();
      setTimeout(() => { URL.revokeObjectURL(url); a.remove(); }, 4000);
      this.message = this._copy('done', { n }) || `Downloaded ${n} contacts.`;
      await this._load();
    } catch (err) {
      this.message = `✗ ${err.message}`;
    } finally {
      this.busy = false;
      this._render();
    }
  }

  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      let el;
      if ((el = e.target.closest('[data-ct-group]'))) {
        const g = el.dataset.ctGroup;
        if (this.groups.has(g)) this.groups.delete(g); else this.groups.add(g);
        this._render(); return;
      }
      if ((el = e.target.closest('[data-ct-scope]'))) { this.scope = el.dataset.ctScope; this._render(); return; }
      if (e.target.closest('#ct-go')) this._export();
    });
  }

  _render() {
    const title = this.find('#ct-title'); if (title) title.textContent = this._copy('title') || '📇 Contacts';
    const sub = this.find('#ct-sub'); if (sub) sub.textContent = this._copy('subtitle');
    const body = this.find('#ct-body');
    if (!body) return;
    const msg = (text) => `<div class="empty-state" style="text-align:center; opacity:0.75; padding:var(--space-6);">${this.escapeHtml(text)}</div>`;
    if (this.error) { body.innerHTML = msg(this.error); return; }
    if (!this.summary) { body.innerHTML = msg('Loading…'); return; }

    const groups = ['members', 'parents', 'coaches', 'staff', 'leads', 'opponents'];
    const gc = (g) => this.summary.groups[g] || { new: 0, changed: 0, all: 0 };
    const scopeN = (g, s) => s === 'all' ? gc(g).all : s === 'changed' ? gc(g).new + gc(g).changed : gc(g).new;
    const scopes = [['new', this._copy('scope_new') || 'New since my last export'],
                    ['changed', this._copy('scope_changed') || 'Changed since'],
                    ['all', this._copy('scope_all') || 'Everything']];
    const n = this._count();
    const totals = { new: 0, changed: 0, all: 0 };
    for (const g of this.groups) { totals.new += gc(g).new; totals.changed += gc(g).changed; totals.all += gc(g).all; }
    const le = this.summary.last_export;
    const lastLine = le ? (this._copy('last_export', { when: le.when, n: le.n }) || `Last export ${le.when}, ${le.n} contacts.`)
                        : (this._copy('never') || 'Nothing exported from this login yet.');
    const label = n ? (this._copy('button', { n }) || `📲 Add ${n} to my phone`) : (this._copy('button_none') || 'Nothing to add');

    body.innerHTML = `
      <div class="ct-row">
        ${groups.map(g => `<button type="button" class="ct-chip ${this.groups.has(g) ? 'on' : ''}" data-ct-group="${g}">
            ${this.escapeHtml(this._copy('group_' + g) || g)}<span class="n">${scopeN(g, this.scope)}</span></button>`).join('')}
      </div>
      <div class="ct-row">
        ${scopes.map(([k, l]) => `<button type="button" class="ct-chip ${this.scope === k ? 'on' : ''}" data-ct-scope="${k}">${this.escapeHtml(l)}</button>`).join('')}
      </div>
      <div class="ct-line">${this.escapeHtml(this._copy('count_line', totals) || `${totals.new} new · ${totals.changed} changed · ${totals.all} in all`)}</div>
      <button type="button" class="btn btn-primary ct-go" id="ct-go" ${(!n || this.busy) ? 'disabled' : ''}>${this.busy ? '⏳' : this.escapeHtml(label)}</button>
      <div class="ct-line">${this.escapeHtml(lastLine)}</div>
      ${this.message ? `<div class="ct-msg ${this.message.startsWith('✗') ? 'bad' : ''}">${this.escapeHtml(this.message)}</div>` : ''}
    `;
  }
}
