// PlayerTeamRulesScreen — #player-team-rules, 📋 Rules (mig 4002).
//
// Owner 11/27: "we need a club wide rules, mens wide rule, youth wide rules
// etc right? then team rules?" · "it just has to make sense adn be
// navigatable".  Rules live in club_rules, layered 🏠 Club → section
// (👨 Men / 👩 Women / 👦 Boys / 👧 Girls) → ⚽ team; GET /api/rules hands
// this person exactly their layers (admins: all).  A sticky pill row jumps
// to each layer.  ⚖️ Live fines + fine rules (FinesPanel) stay on top —
// owner 11/18 "even on team rules is where we can show live fines".
// Wording: message_templates kind 'rules'; rule text: club_rules.body
// (blank line = paragraph, "- " bullet, "1. " numbered, **bold**,
// [text](#route) — only in-app #links).
class PlayerTeamRulesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = '';
  }

  _c(tier, fallback) {
    const v = window.MessageCopy ? MessageCopy.block('rules', tier) : '';
    return v || fallback;
  }

  render() {
    const el = document.createElement('div');
    el.className = 'screen screen-player-team-rules';
    el.innerHTML = `
      <style>
        .screen-player-team-rules { overflow:visible; }   /* the window scrolls — let the pill row stick to it */
        .rules { padding:10px 10px 40px; max-width:820px; margin:0 auto; line-height:1.5; }
        .rules h1 { font-size:1.15rem; margin:0 0 2px; }
        .rules .intro { font-size:0.82rem; opacity:0.75; margin-bottom:8px; }
        .rules .pills { position:sticky; top:0; z-index:5; display:flex; flex-wrap:wrap; gap:6px; padding:8px 0; background:var(--bg-primary, #0f172a); }
        .rules .pill { padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.86rem; min-height:0; min-width:0;
                       border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .rules .pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .rules .layer { margin:14px 0 6px; scroll-margin-top:56px; }
        .rules .layer > h2 { font-size:1rem; margin:0 0 8px; padding-bottom:4px; border-bottom:2px solid var(--primary-color); }
        .rules .rule { margin-bottom:10px; padding:10px 12px; border:1px solid rgba(255,255,255,0.12); border-radius:10px; background:rgba(255,255,255,0.03); }
        .rules .rule h3 { font-size:0.92rem; margin:0 0 6px; }
        .rules .rule p { margin:0 0 8px; font-size:0.88rem; }
        .rules .rule ul, .rules .rule ol { margin:0 0 6px 18px; padding:0; font-size:0.88rem; }
        .rules .rule a { color:#93c5fd; }
        .rules .none { opacity:0.65; font-size:0.86rem; padding:4px 2px; }
      </style>
      <div class="rules">
        <div id="ptr-fines" hidden style="margin-bottom:10px;"></div>
        <div class="rules-body"><div class="loading" style="padding-top:30px;">Loading…</div></div>
      </div>`;
    this.element = el;
    el.addEventListener('click', (e) => {
      const p = e.target.closest('[data-rules-jump]');
      if (!p) return;
      const target = el.querySelector(`[data-rules-layer="${p.dataset.rulesJump}"]`);
      if (target) target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      el.querySelectorAll('[data-rules-jump]').forEach(b => b.classList.toggle('on', b === p));
    });
    return el;
  }

  onEnter() {
    const host = this.element.querySelector('#ptr-fines');
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    if (host && window.FinesPanel) {
      const fetchJson = async (url, options = {}) => {
        const res = await this.auth.fetch(url, { ...options, headers: { 'Content-Type': 'application/json', ...(options.headers || {}) } });
        let body = null; try { body = await res.json(); } catch (_) { body = null; }
        if (!res.ok) throw new Error((body && (body.error || body.message)) || `HTTP ${res.status}`);
        return body || {};
      };
      new FinesPanel(host, { fetchJson, escapeHtml: esc, auth: this.auth }).load();
    }
    const copy = window.MessageCopy ? Promise.resolve(MessageCopy.load(this.auth)).catch(() => {}) : Promise.resolve();
    const rules = this.auth.fetch('/api/rules').then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)));
    Promise.all([rules, copy])
      .then(([d]) => { this.data = d; this.err = ''; })
      .catch((e) => { this.err = e.message || 'error'; })
      .finally(() => { if (this.isMounted !== false) this._draw(); });
  }

  _layerLabel(l) {
    if (l.scope === 'club') return this._c('layer_club', '🏠 Club');
    if (l.scope === 'section') return this._c(`section_${l.sectionCode}`, l.label || 'Section');
    return l.label || 'Team';   // teams.label carries its own emoji (🏆 U23)
  }

  // Rule body → safe HTML: escape first, then the tiny format.
  _body(text) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const inline = (s) => esc(s)
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\[([^\]]+)\]\((#[\w\-\/]*)\)/g, '<a href="$2">$1</a>');
    let html = '', list = null;
    const close = () => { if (list) { html += `</${list}>`; list = null; } };
    for (const raw of String(text || '').split('\n')) {
      const line = raw.trim();
      if (!line) { close(); continue; }
      const bullet = /^- (.*)$/.exec(line), num = /^\d+\. (.*)$/.exec(line);
      if (bullet || num) {
        const kind = bullet ? 'ul' : 'ol';
        if (list !== kind) { close(); html += `<${kind}>`; list = kind; }
        html += `<li>${inline((bullet || num)[1])}</li>`;
      } else { close(); html += `<p>${inline(line)}</p>`; }
    }
    close();
    return html;
  }

  _draw() {
    const box = this.element && this.element.querySelector('.rules-body');
    if (!box) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    if (this.err) { box.innerHTML = `<div class="none">${esc(this._c('error', 'Could not load the rules.'))}</div>`; return; }
    const layers = (this.data && this.data.layers) || [];
    let html = `<h1>${esc(this._c('title', '📋 Rules'))}</h1><div class="intro">${esc(this._c('intro', ''))}</div>`;
    html += `<div class="pills">${layers.map((l, i) =>
      `<button class="pill ${i === 0 ? 'on' : ''}" data-rules-jump="${esc(l.key)}">${esc(this._layerLabel(l))}</button>`).join('')}</div>`;
    for (const l of layers) {
      html += `<div class="layer" data-rules-layer="${esc(l.key)}"><h2>${esc(this._layerLabel(l))}</h2>`;
      html += (l.rules || []).length
        ? l.rules.map(r => `<div class="rule"><h3>${esc(r.title)}</h3>${this._body(r.body)}</div>`).join('')
        : `<div class="none">${esc(this._c('empty', 'No rules here yet.'))}</div>`;
      html += `</div>`;
    }
    box.innerHTML = html;
  }
}
