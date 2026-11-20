// proposals.js — 📑 #proposals: every club proposal on one page (mig 1572).
//
// #proposals lists them (GET /api/proposals); #proposals/<code> draws one
// from its proposal_sections rows (GET /api/proposals/<code>).  A proposal
// with its own hand-built page (`screen`, e.g. In-House) opens that page.
// Page wording = message_templates kind 'proposals'.
//
// Section body: a line starting "- " is a bullet; lines starting "|" are a
// table (first = header, cells split by |); anything else is a paragraph.
// Inside a line, **bold** and [text](https://…) work.
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
      </style>
      <div class="screen-content"><div class="prp-wrap" id="prp-body"></div></div>`;
    this.element = div;
    div.querySelector('#prp-body').addEventListener('click', (e) => {
      const item = e.target.closest('[data-proposal]');
      if (!item) return;
      if (item.dataset.screen) this.navigation.goTo(item.dataset.screen);
      else this.navigation.goTo('proposals', { entity: item.dataset.proposal });
    });
    return div;
  }

  onEnter(params = {}) { this.code = params.entity || null; this.load(); }
  _copy(tier) { return window.MessageCopy ? MessageCopy.block('proposals', tier) : ''; }
  _esc(text) { const d = document.createElement('div'); d.textContent = text == null ? '' : String(text); return d.innerHTML; }

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
          <div class="prp-meta"><span class="prp-pill">${this._esc(p.status.icon)} ${this._esc(p.status.label)}</span><span>${this._esc(this._copy('as_of'))} ${this._esc(this._date(p.asOf))}</span></div>
        </div>
      </div>`).join('');
  }

  async _one(body) {
    let p;
    try { ({ proposal: p } = await this._get(`/api/proposals/${encodeURIComponent(this.code)}`)); }
    catch (err) {
      body.innerHTML = `<div class="prp-card prp-note">${this._esc(this._copy('missing'))}</div>`;
      return;
    }
    if (p.screen) { this.navigation.goTo(p.screen); return; }
    // The proposal's own title + status head its page (the list has none —
    // the lit menu pill names #proposals).
    body.innerHTML = `
      <h1 style="margin:0;">${this._esc(p.icon)} ${this._esc(p.title)}</h1>
      <div class="prp-meta" style="margin:4px 0 var(--space-3);"><span class="prp-pill">${this._esc(p.status.icon)} ${this._esc(p.status.label)}</span><span>${this._esc(this._copy('as_of'))} ${this._esc(this._date(p.asOf))}</span></div>`
      + p.sections.map(s =>
      `<div class="prp-card"><div class="prp-head">${this._esc(s.heading)}</div>${this._body(s.body)}</div>`).join('');
  }

  _date(iso) {
    const d = new Date(`${iso}T12:00:00`);
    return isNaN(d) ? iso : d.toLocaleDateString(undefined, { month: 'long', day: 'numeric', year: 'numeric' });
  }

  // **bold** and [text](https://…) inside one escaped line.
  _inline(text) {
    return this._esc(text)
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\[([^\]]+)\]\((https?:\/\/[^)\s]+)\)/g, '<a href="$2" target="_blank" rel="noopener">$1</a>');
  }

  // Consecutive lines of one kind group into a list or a table.
  _body(text) {
    const out = [];
    let run = null;
    const flush = () => {
      if (!run) return;
      if (run.kind === 'ul') out.push(`<ul>${run.lines.map(l => `<li>${this._inline(l.slice(2))}</li>`).join('')}</ul>`);
      else {
        const cells = (l, tag) => l.replace(/^\|/, '').split('|').map(c => `<${tag}>${this._inline(c.trim())}</${tag}>`).join('');
        const [head, ...rows] = run.lines;
        out.push(`<div class="prp-scroll"><table class="prp-table"><thead><tr>${cells(head, 'th')}</tr></thead><tbody>${rows.map(r => `<tr>${cells(r, 'td')}</tr>`).join('')}</tbody></table></div>`);
      }
      run = null;
    };
    for (const line of String(text || '').split('\n')) {
      if (!line.trim()) { flush(); continue; }
      const kind = line.startsWith('- ') ? 'ul' : line.startsWith('|') ? 'table' : 'p';
      if (kind === 'p') { flush(); out.push(`<p>${this._inline(line)}</p>`); continue; }
      if (!run || run.kind !== kind) { flush(); run = { kind, lines: [] }; }
      run.lines.push(line);
    }
    flush();
    return out.join('');
  }
}
