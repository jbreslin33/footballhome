// GroupMeFeeds (mig 1295) — read-only GroupMe feeds on the league hubs,
// the same look as the Men's GroupMe section on #my (my.js
// _renderGroupMe): GroupMe-blue border, last 5 messages oldest at the top /
// newest at the bottom, "Show N older" toggle, images as previews.
//
//   const feeds = new GroupMeFeeds(screen, el, 'casa-hub');   // or 'apsl-hub'
//   feeds.load();     // fetches now, then every 60 s while el is on the page
//
// Data: GET /api/opponents/groupme?chat=<slug> → {feeds:[{title, messages,
// error}], links:[{label,url}]}; headings and the link pill are DB rows
// (chat_integrations.external_name, chat_links).
class GroupMeFeeds {
  constructor(screen, el, slug) {
    this.screen = screen; this.el = el; this.slug = slug;
    this.data = null; this.expanded = new Set(); this.timer = null;
    el.addEventListener('click', (e) => {
      const t = e.target.closest('[data-gm-toggle]'); if (!t) return;
      const k = t.dataset.gmToggle;
      if (this.expanded.has(k)) this.expanded.delete(k); else this.expanded.add(k);
      this.render();
    });
  }

  async load() {
    clearTimeout(this.timer);
    if (!this.el.isConnected && this.data) return;           // screen left — stop polling
    try {
      const res = await this.screen.auth.fetch(`/api/opponents/groupme?chat=${encodeURIComponent(this.slug)}`);
      const body = await res.json().catch(() => ({}));
      if (res.ok) { this.data = body; this.render(); }
    } catch (_) { /* keep the last copy */ }
    this.timer = setTimeout(() => this.load(), 60000);
  }

  render() {
    const esc = (t) => this.screen.escapeHtml(t == null ? '' : String(t));
    const feeds = (this.data && this.data.feeds) || [];
    if (!feeds.length) { this.el.innerHTML = ''; return; }
    const links = ((this.data && this.data.links) || []).filter(l => /^https:\/\//.test(l.url || ''));
    const LATEST = 5;
    const card = (f, i) => {
      const msgs = f.messages || [];
      const open = this.expanded.has(String(i));
      const shown = (open ? msgs : msgs.slice(0, LATEST)).slice().reverse();
      const older = Math.max(0, msgs.length - LATEST);
      const toggle = older > 0
        ? `<div style="text-align:center; padding-bottom:4px;"><button type="button" data-gm-toggle="${i}"
             style="padding:3px 9px; border-radius:999px; border:1px solid var(--border-color); background:transparent;
                    color:var(--text-primary); font-size:0.75rem; font-weight:600; cursor:pointer;">
             ${open ? `Latest ${LATEST} only` : `Show ${older} older`}</button></div>` : '';
      const rows = f.error ? `<div style="font-size:0.85rem; opacity:0.7;">${esc(f.error)}</div>`
        : msgs.length ? toggle + shown.map(m => this._row(m, esc)).join('')
        : `<div style="font-size:0.85rem; opacity:0.7;">—</div>`;
      return `
        <div style="border:1.5px solid rgba(0,175,240,0.6); border-radius:12px; background:var(--bg-secondary); margin-bottom:10px; overflow:hidden;">
          <div style="padding:8px 12px; font-weight:800; border-bottom:1px solid var(--border-color);">💬 ${esc(f.title)}</div>
          <div style="padding:6px 12px 8px; ${open ? 'max-height:60vh; overflow-y:auto;' : ''}">${rows}</div>
        </div>`;
    };
    this.el.innerHTML = feeds.map(card).join('') + (links.length
      ? `<div style="display:flex; gap:8px; flex-wrap:wrap; margin-bottom:12px;">${links.map(l =>
          `<a href="${esc(l.url)}" target="_blank" rel="noopener" style="padding:6px 12px; border-radius:999px;
             border:1px solid rgba(0,175,240,0.6); color:var(--text-primary); font-size:0.85rem; font-weight:700; text-decoration:none;">${esc(l.label)}</a>`).join('')}</div>`
      : '');
  }

  _row(m, esc) {
    const when = this._when(m.created_at);
    const text = esc(m.text || '').replace(/(https?:\/\/[^\s<]+)/g,
      '<a href="$1" target="_blank" rel="noopener noreferrer" style="color:#60a5fa; text-decoration:underline;">$1</a>');
    const image = /^https:\/\/i\.groupme\.com\//.test(m.image_url || '')
      ? `<a href="${esc(m.image_url)}" target="_blank" rel="noopener noreferrer"><img src="${esc(m.image_url)}.preview" alt="" loading="lazy"
           style="max-height:120px; border-radius:6px; margin-top:4px; display:block;"></a>` : '';
    return `
      <div style="padding:6px 0; border-bottom:1px solid var(--border-color);">
        <div style="display:flex; justify-content:space-between; gap:8px; margin-bottom:2px;">
          <div style="font-size:0.85rem; color:#f59e0b; font-weight:700;">${esc(m.name || '')}</div>
          <div style="font-size:0.75rem; opacity:0.6; white-space:nowrap;">${esc(when)}</div>
        </div>
        <div style="font-size:0.9rem; line-height:1.3; white-space:pre-wrap; overflow-wrap:anywhere;">${text}</div>
        ${image}
      </div>`;
  }

  _when(secs) {
    if (!secs) return '';
    const t = new Date(secs * 1000), now = new Date();
    const hm = { hour: 'numeric', minute: '2-digit' };
    if (t.toDateString() === now.toDateString()) return t.toLocaleTimeString(undefined, hm);
    const y = new Date(now); y.setDate(now.getDate() - 1);
    if (t.toDateString() === y.toDateString()) return 'Yesterday ' + t.toLocaleTimeString(undefined, hm);
    return t.toLocaleDateString(undefined, t.getFullYear() === now.getFullYear()
      ? { month: 'short', day: 'numeric', ...hm } : { month: 'short', day: 'numeric', year: 'numeric' });
  }
}

window.GroupMeFeeds = GroupMeFeeds;
