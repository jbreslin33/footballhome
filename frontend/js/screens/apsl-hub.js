// APSL section (mig 833) — owner 2026-10-29: "leagues and opponents section
// should have apsl section. then from there the messaging section and the
// pyramid section etc. we need to be organize".  Same shape as #casa:
//
//   #apsl           the hub: tiles — add a tile here for each new APSL tool.
//   #apsl-messages  the league office's contacts (club_competitions status
//                   'league' under APSL, mig 483) with ✉️/💬, and the
//                   roster-moves email to the commissioner (mig 829,
//                   components/league-moves-mail.js).
//   #apsl-pyramid   the pyramid flow chart (apsl-pyramid.js, migs 819/823).
//   #opponents      opened on the APSL pill.
//
// Wording: message_templates kind 'apsl' (tiles: subject = label, body =
// description).  Club admins only.
class ApslHubScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="ah-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="ah-title">🔺 APSL</h1><div id="ah-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
      </div>
      <div class="screen-content" id="ah-body" style="max-width:720px; margin:0 auto;"><div class="loading">Loading…</div></div>`;
    this.element = div;
    div.querySelector('#ah-back').addEventListener('click', () => this.navigation.goBack());
    div.addEventListener('click', (e) => {
      const t = e.target.closest('[data-go]');
      if (t) this.navigation.goTo(t.dataset.go, t.dataset.league ? { league: t.dataset.league } : {});
    });
    return div;
  }

  onEnter() { this.load(); }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl', tier, tokens) : ''; }
  _tile(tier) { const t = window.MessageCopy && MessageCopy.render('apsl', tier, {}); return t ? { label: t.subject, desc: t.body } : { label: tier, desc: '' }; }

  async load() {
    if (window.MessageCopy) await MessageCopy.load(this.auth);
    const title = this.find('#ah-title'); if (title && this._copy('hub_title')) title.textContent = this._copy('hub_title');
    const sub = this.find('#ah-sub'); if (sub) sub.textContent = this._copy('hub_subtitle');
    this._draw(null);
    // Unasked roster moves on the messaging tile — the DB's view, no
    // league re-pull here (#apsl-messages does that before the email).
    let n = 0;
    try {
      const res = await this.auth.fetch('/api/mens-roster/league-moves');
      const data = await res.json().catch(() => ({}));
      if (res.ok) n = (data.lists || []).reduce((a, l) => a + (l.moves || []).filter(m => !m.askedOn).length, 0);
    } catch (_) { /* tile shows no count */ }
    this._draw(n);
  }

  _draw(moves) {
    const body = this.find('#ah-body'); if (!body) return;
    const esc = (t) => this.escapeHtml(t);
    const tile = (tier, go, extra = '', league = '') => { const t = this._tile(tier); return `
      <button class="btn btn-lg btn-primary" data-go="${go}" ${league ? `data-league="${league}"` : ''} style="display:flex; align-items:center; gap:var(--space-3); width:100%; text-align:left; margin-bottom:10px;">
        <div style="flex:1;"><div style="font-weight:bold;">${esc(t.label)}</div><div style="font-size:0.85rem; opacity:0.8;">${esc(t.desc)}${extra
          ? `<b style="color:#fdba74;">${esc(extra)}</b>` : ''}</div></div>
      </button>`; };
    body.innerHTML = tile('tile_messages', 'apsl-messages', moves ? this._copy('tile_moves_n', { n: moves }) : '')
      + tile('tile_pyramid', 'apsl-pyramid')
      + tile('tile_opponents', 'opponents', '', 'APSL');
  }
}

class ApslMessagesScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="am-back">← Back</button>
        <div style="flex:1;"><h1 style="margin:0;" id="am-title">✉️ APSL</h1></div>
      </div>
      <div class="screen-content" style="max-width:720px; margin:0 auto;">
        <div id="am-moves"></div>
        <div id="am-none" style="display:none; font-size:0.85rem; opacity:0.7; text-align:center; margin-bottom:var(--space-3);"></div>
        <div id="am-contacts"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#am-back').addEventListener('click', () => this.navigation.goBack());
    return div;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl', tier, tokens) : ''; }

  async onEnter() {
    if (window.MessageCopy) await MessageCopy.load(this.auth);
    const t = this.find('#am-title'); if (t && this._copy('messages_title')) t.textContent = this._copy('messages_title');
    if (window.LeagueMovesMail) {
      this._moves = this._moves || new LeagueMovesMail(this, this.find('#am-moves'));
      this._moves.onRender = (shown) => {
        const none = this.find('#am-none'); if (!none) return;
        none.textContent = this._copy('no_moves');
        none.style.display = shown || this._moves.pulling ? 'none' : '';
      };
      this._moves.load();
    }
    this.loadContacts();
  }

  // The APSL league office's contacts — same rows as #opponents (mig 483).
  async loadContacts() {
    const el = this.find('#am-contacts'); if (!el) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    let contacts = [];
    try {
      const res = await this.auth.fetch('/api/opponents/board');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      const office = new Set((body.competitions || []).filter(c => c.league_label === 'APSL' && c.status === 'league').map(c => c.club_id));
      contacts = (body.contacts || []).filter(c => office.has(c.club_id));
    } catch (err) { el.innerHTML = `<div class="error-message">${esc(err.message)}</div>`; return; }
    const row = (c) => {
      const mail = c.email && this.buildGmailComposeHref({ to: c.email });
      const sms = c.phone && this.buildSmsComposeHref({ to: c.phone });
      return `<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:8px 0; border-top:1px solid var(--border-color);">
          <div style="flex:1; min-width:160px;"><b>${esc(c.name)}</b> <small style="opacity:0.65;">${esc(c.role)}</small>
            <div style="font-size:0.8rem; opacity:0.75; overflow-wrap:anywhere;">${esc([c.email, c.phone].filter(Boolean).join(' · '))}</div></div>
          ${mail ? `<a class="btn btn-primary" href="${esc(mail)}" target="_blank" rel="noopener" style="padding:5px 12px;">✉️</a>` : ''}
          ${sms ? `<a class="btn btn-secondary" href="${esc(sms)}" style="padding:5px 12px;">💬</a>` : ''}
        </div>`;
    };
    el.innerHTML = `
      <div style="border:1px solid var(--border-color); border-radius:12px; padding:10px 14px; background:var(--bg-secondary);">
        <div style="font-weight:800;">${esc(this._copy('contacts_h'))}</div>
        ${contacts.length ? contacts.map(row).join('') : `<div style="font-size:0.85rem; opacity:0.7; padding-top:6px;">${esc(this._copy('no_contacts'))}</div>`}
      </div>`;
  }
}

window.ApslHubScreen = ApslHubScreen;
window.ApslMessagesScreen = ApslMessagesScreen;
