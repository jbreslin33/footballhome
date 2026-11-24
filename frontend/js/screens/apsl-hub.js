// APSL section (mig 833) — owner 2026-10-29: "leagues and opponents section
// should have apsl section. then from there the messaging section and the
// pyramid section etc. we need to be organize".  Same shape as #casa:
//
//   #apsl           the hub: a row of pills — add a pill here for each new APSL tool.
//   #apsl-messages  the league office's contacts (club_competitions status
//                   'league' under APSL, mig 483) with ✉️/💬, and the
//                   roster-moves email to the commissioner (mig 829,
//                   components/league-moves-mail.js).
//   #apsl-pyramid   the pyramid flow chart (apsl-pyramid.js, migs 819/823).
//   #opponents      opened on the APSL pill.
//   Below the tiles: GroupMe feeds, read-only (mig 1295,
//   components/groupme-feeds.js, chats slug 'apsl-hub').
//
// Wording: message_templates kind 'apsl' (tiles: subject = label, body =
// description).  Club admins only.
class ApslHubScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-content" style="max-width:720px; margin:0 auto;"><div id="ah-body"><div class="loading">Loading…</div></div><div id="ah-gm"></div></div>`;
    this.element = div;
    div.addEventListener('click', (e) => {
      const t = e.target.closest('[data-go]');
      if (t) this.navigation.goTo(t.dataset.go, t.dataset.league ? { league: t.dataset.league } : {});
    });
    return div;
  }

  onEnter() {
    this.load();
    // GroupMe feeds under the tiles (mig 1295): chats slug 'apsl-hub'.
    if (window.GroupMeFeeds) { this._gm = this._gm || new GroupMeFeeds(this, this.find('#ah-gm'), 'apsl-hub'); this._gm.load(); }
  }
  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl', tier, tokens) : ''; }
  _tile(tier) { const t = window.MessageCopy && MessageCopy.render('apsl', tier, {}); return t ? { label: t.subject, desc: t.body } : { label: tier, desc: '' }; }

  async load() {
    if (window.MessageCopy) await MessageCopy.load(this.auth);
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
    // The hub's tools are a row of pills, like every other page (owner
    // 11/24 "the leagues menu needs to have its buttons turned into
    // pills"): label on the pill, the tile's description in its tooltip,
    // the unasked-moves count on the messaging pill.
    const pillCss = 'padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.9rem; min-height:0; min-width:0; border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);';
    const tile = (tier, go, extra = '', league = '') => { const t = this._tile(tier); return `
      <button data-go="${go}" ${league ? `data-league="${league}"` : ''} title="${esc(t.desc)}" style="${pillCss}">${esc(t.label)}${extra
        ? ` <b style="color:#fdba74;">${esc(extra)}</b>` : ''}</button>`; };
    body.innerHTML = `<div style="display:flex; flex-wrap:wrap; gap:8px; margin-bottom:14px;">${
      tile('tile_messages', 'apsl-messages', moves ? this._copy('tile_moves_n', { n: moves }) : '')
      + tile('tile_pyramid', 'apsl-pyramid')
      + tile('tile_opponents', 'opponents', '', 'APSL')}</div>`;
  }
}

class ApslMessagesScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-content" style="max-width:720px; margin:0 auto;">
        <div id="am-moves"></div>
        <div id="am-none" style="display:none; font-size:0.85rem; opacity:0.7; text-align:center; margin-bottom:var(--space-3);"></div>
        <div id="am-contacts"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    return div;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl', tier, tokens) : ''; }

  async onEnter() {
    if (window.MessageCopy) await MessageCopy.load(this.auth);
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
      const contact = (c.email || c.phone) ? ContactPopup.button({
        key: `apsl-office:${c.id}`, screen: this, big: true,
        recipients: [{ personId: null, name: c.name || '', phone: c.phone || '', email: c.email || '' }],
        messages: [ContactPopup.blankMessage()],
      }) : '';
      return `<div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; padding:8px 0; border-top:1px solid var(--border-color);">
          <div style="flex:1; min-width:160px;"><b>${esc(c.name)}</b> <small style="opacity:0.65;">${esc(c.role)}</small>
            <div style="font-size:0.8rem; opacity:0.75; overflow-wrap:anywhere;">${esc([c.email, c.phone].filter(Boolean).join(' · '))}</div></div>
          <div style="flex:none;">${contact}</div>
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
