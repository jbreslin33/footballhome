// proposals.js — 📑 #proposals: every club proposal on one page (mig 1572).
//
// #proposals lists them (GET /api/proposals); #proposals/<code> draws one
// from its proposal_sections rows (GET /api/proposals/<code>).  A proposal
// with its own hand-built page (`screen`, e.g. In-House) opens that page.
// Page wording = message_templates kind 'proposals'.
//
// A proposal flagged public (proposals.is_public, mig 1713) shows its public
// link up top with a copy button: the standalone page /proposals/#<code>
// that anyone can open, drawn by proposals/index.html.  The text → HTML
// rules live in lib/proposal-body.js, shared with that page.
class ProposalsScreen extends Screen {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .prp-wrap { max-width:820px; margin:0 auto; }
        .prp-card { border:1px solid var(--border-color, #374151); border-radius:6px; background:var(--bg-tertiary, #1f2937); padding:var(--space-3); margin-bottom:var(--space-3); }
        .prp-item { cursor:pointer; display:flex; gap:var(--space-3); align-items:flex-start; }
        .prp-item:hover { border-color:var(--primary-color, #3b82f6); }
        .prp-icon { font-size:1.8rem; line-height:1; }
        .prp-title { font-weight:700; font-size:1.05rem; }
        .prp-sum { margin-top:4px; line-height:1.45; opacity:0.9; }
        .prp-meta { margin-top:6px; font-size:0.8rem; opacity:0.7; display:flex; gap:10px; flex-wrap:wrap; }
        .prp-pill { border:1px solid var(--border-color, #374151); border-radius:999px; padding:1px 8px; }
        .prp-head { font-weight:700; font-size:1.05rem; margin-bottom:8px; }
        .prp-card p { margin:0 0 8px; line-height:1.5; }
        .prp-card ul { margin:0 0 8px; padding-left:20px; line-height:1.5; }
        .prp-card li { margin-bottom:6px; }
        .prp-card a { color:var(--primary-color, #60a5fa); }
        .prp-scroll { overflow-x:auto; margin-bottom:8px; }
        .prp-table { border-collapse:collapse; font-size:0.85rem; width:100%; }
        .prp-table th { padding:4px 8px; text-align:left; opacity:0.7; font-weight:600; }
        .prp-table td { padding:6px 8px; text-align:left; border-top:1px solid var(--border-color, #374151); vertical-align:top; }
        .prp-note { opacity:0.7; }
        .prp-share { display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
        .prp-share a { word-break:break-all; }
        .prp-mail { display:flex; flex-direction:column; gap:8px; }
        .prp-mail label { display:flex; gap:8px; align-items:center; flex-wrap:wrap; }
        .prp-mail input[type=email] { padding:4px 8px; border-radius:6px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; min-width:220px; }
        .prp-mail button, .prp-mail .prp-send { padding:6px 14px; border-radius:6px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; cursor:pointer; align-self:flex-start; font-weight:700; }
        .prp-role { opacity:0.7; }
        .prp-share button { padding:4px 12px; border-radius:6px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; cursor:pointer; }
      </style>
      <div class="screen-content"><div class="prp-wrap" id="prp-body"></div></div>`;
    this.element = div;
    div.querySelector('#prp-body').addEventListener('click', (e) => {
      const copy = e.target.closest('[data-copy-link]');
      if (copy) {
        navigator.clipboard.writeText(copy.dataset.copyLink).then(() => { copy.textContent = this._copy('copied'); });
        return;
      }
      const save = e.target.closest('[data-save-recipient]');
      if (save) { this._saveEmail(save.dataset.saveRecipient); return; }
      if (e.target.closest('[data-send]')) { this._send(); return; }
      const item = e.target.closest('[data-proposal]');
      if (!item) return;
      if (item.dataset.screen) this.navigation.goTo(item.dataset.screen);
      else this.navigation.goTo('proposals', { entity: item.dataset.proposal });
    });
    return div;
  }

  onEnter(params = {}) { this.code = params.entity || null; this.load(); }
  _copy(tier) { return window.MessageCopy ? MessageCopy.block('proposals', tier) : ''; }
  _esc(text) { return ProposalBody.esc(text); }

  async load() {
    const user = this.navigation.context.user;
    if (!['club', 'sport_division', 'team', 'super', 'system', 'league'].includes(user?.role)) { this.navigation.goBack(); return; }
    if (window.MessageCopy) await MessageCopy.load(this.auth);
    const body = this.find('#prp-body');
    body.innerHTML = '';
    try {
      if (this.code) await this._one(body);
      else await this._list(body);
    } catch (err) {
      console.warn('[proposals] load failed:', err);
      body.innerHTML = `<div class="prp-card prp-note">${this._esc(err.message || String(err))}</div>`;
    }
  }

  async _get(url) {
    const res = await this.auth.fetch(url);
    const data = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
    return data;
  }

  async _list(body) {
    const { proposals = [] } = await this._get('/api/proposals');
    if (!proposals.length) { body.innerHTML = `<div class="prp-card prp-note">${this._esc(this._copy('empty'))}</div>`; return; }
    body.innerHTML = proposals.map(p => `
      <div class="prp-card prp-item" data-proposal="${this._esc(p.code)}" data-screen="${this._esc(p.screen)}">
        <div class="prp-icon">${this._esc(p.icon)}</div>
        <div style="flex:1;">
          <div class="prp-title">${this._esc(p.title)}</div>
          <div class="prp-sum">${this._esc(p.summary)}</div>
          <div class="prp-meta"><span class="prp-pill">${this._esc(p.status.icon)} ${this._esc(p.status.label)}</span><span>${this._esc(this._copy('as_of'))} ${this._esc(ProposalBody.date(p.asOf))}</span></div>
        </div>
      </div>`).join('');
  }

  async _one(body) {
    let p;
    try { ({ proposal: p, recipients: this.recipients = [] } = await this._get(`/api/proposals/${encodeURIComponent(this.code)}`)); }
    catch (err) {
      body.innerHTML = `<div class="prp-card prp-note">${this._esc(this._copy('missing'))}</div>`;
      return;
    }
    if (p.screen) { this.navigation.goTo(p.screen); return; }
    this.proposal = p;
    // The proposal's own title + status head its page (the list has none —
    // the lit menu pill names #proposals).
    body.innerHTML = `
      <h1 style="margin:0;">${this._esc(p.icon)} ${this._esc(p.title)}</h1>
      <div class="prp-meta" style="margin:4px 0 var(--space-3);"><span class="prp-pill">${this._esc(p.status.icon)} ${this._esc(p.status.label)}</span><span>${this._esc(this._copy('as_of'))} ${this._esc(ProposalBody.date(p.asOf))}</span></div>`
      + (p.isPublic ? this._share(p.code) + `<div class="prp-card prp-mail" id="prp-mail">${this._mail()}</div>` : '')
      + p.sections.map(s =>
      `<div class="prp-card"><div class="prp-head">${this._esc(s.heading)}</div>${ProposalBody.html(s.body)}</div>`).join('');
  }

  // The public link, to copy and send.
  _share(code) {
    const url = ProposalBody.publicUrl(code);
    return `<div class="prp-card prp-share"><strong>${this._esc(this._copy('public_link'))}</strong>
      <a href="${this._esc(url)}" target="_blank" rel="noopener">${this._esc(url)}</a>
      <button type="button" data-copy-link="${this._esc(url)}">${this._esc(this._copy('copy_link'))}</button></div>`;
  }

  // Who to email: a tick-box each (ticked when they have an address), an
  // address box for anyone without one, and the button that opens the email.
  _mail() {
    return `<strong>${this._esc(this._copy('email_to'))}</strong>`
      + this.recipients.map(r => `
        <label><input type="checkbox" data-recipient="${r.id}" ${r.email ? 'checked' : 'disabled'}>
          <span>${this._esc(r.name)}${r.role ? ` <span class="prp-role">${this._esc(r.role)}</span>` : ''}</span>
          ${r.email ? `<span class="prp-role">${this._esc(r.email)}</span>`
            : `<input type="email" data-email-for="${r.id}" placeholder="${this._esc(this._copy('email_add'))}"><button type="button" data-save-recipient="${r.id}">${this._esc(this._copy('email_save'))}</button>`}
        </label>`).join('')
      + `<button type="button" class="prp-send" data-send="1">${this._esc(this._copy('email_button'))}</button><div class="prp-note" id="prp-mail-note"></div>`;
  }

  async _saveEmail(id) {
    const email = (this.find(`[data-email-for="${id}"]`)?.value || '').trim();
    if (!email) return;
    const res = await this.auth.fetch(`/api/proposals/recipients/${encodeURIComponent(id)}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ email }) });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) { this.find('#prp-mail-note').textContent = data.error || `HTTP ${res.status}`; return; }
    this.recipients = data.recipients || [];
    this.find('#prp-mail').innerHTML = this._mail();
  }

  // Opens an email to the ticked people, carrying the public link.
  _send() {
    const ticked = [...this.element.querySelectorAll('[data-recipient]:checked')].map(b => Number(b.dataset.recipient));
    const to = this.recipients.filter(r => r.email && ticked.includes(r.id)).map(r => r.email).join(',');
    if (!to) { this.find('#prp-mail-note').textContent = this._copy('email_none'); return; }
    const fill = (text) => text.replaceAll('{title}', this.proposal.title).replaceAll('{url}', ProposalBody.publicUrl(this.proposal.code));
    const href = this.buildGmailComposeHref({ to, subject: fill(this._copy('email_subject')), body: fill(this._copy('email_body')) });
    if (href) window.open(href, '_blank', 'noopener');
  }
}
