// apsl-pyramid.js — #apsl: the APSL pyramid (migration 819).  Owner
// 2026-10-29: "i want to build an apsl pyramid. with multiple views with
// its feeder leagues and standings live … we want to show how big the apsl
// and feeder system is. show keep club/team totals too."
//
// GET /api/pyramid: APSL (root) → conferences (tier 1) → the Tier 2
// affiliate leagues that feed each one, every node with its mirrored
// tables and club/team counts.  Three views of the same tree:
//   Org chart  — APSL on top, a column per conference, its feeders below
//   Pyramid    — a band per tier, each league's width = its team count
//   Standings  — every table, conference first then its feeders
// Tapping a box in either picture opens that league in Standings.  The map
// view is phase 2.  Wording: message_templates kind 'apsl_pyramid'.
class ApslPyramidScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.loading = false;
    this.view = 'org'; this.focusId = null;
    try { this.view = localStorage.getItem('apsl-pyramid-view') || 'org'; } catch (_) { /* private mode */ }
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl_pyramid', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ap-totals { text-align:center; font-size:1.25rem; font-weight:800; margin:var(--space-2) 0 var(--space-3); letter-spacing:0.01em; }
        .ap-pills { display:flex; gap:8px; justify-content:center; flex-wrap:wrap; margin-bottom:var(--space-3); }
        .ap-pill { padding:6px 16px; border-radius:999px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; font-weight:700; font-size:0.9rem; cursor:pointer; }
        .ap-pill.on { background:var(--primary-color, #2563eb); border-color:var(--primary-color, #2563eb); color:#fff; }
        .ap-box { border-radius:10px; padding:8px 10px; cursor:pointer; text-align:center; line-height:1.25; }
        .ap-box .nm { font-weight:800; font-size:0.92rem; }
        .ap-box .sub { font-size:0.74rem; opacity:0.75; }
        .ap-box .ct { font-size:0.78rem; font-weight:700; margin-top:3px; }
        .ap-t0 { background:#1e3a8a; color:#fff; }
        .ap-t1 { background:#1d4ed8; color:#fff; }
        .ap-t2 { background:#0f766e; color:#fff; }
        .ap-box.dim { opacity:0.7; }
        .ap-root { max-width:340px; margin:0 auto; }
        .ap-org { display:grid; grid-template-columns:repeat(auto-fit, minmax(150px, 1fr)); gap:12px; margin-top:22px; position:relative; }
        .ap-col { display:flex; flex-direction:column; gap:8px; position:relative; }
        .ap-col::before { content:''; position:absolute; top:-14px; left:50%; height:14px; border-left:2px solid var(--border-color, #4b5563); }
        .ap-feed { position:relative; margin-top:6px; }
        .ap-feed::before { content:''; position:absolute; top:-14px; left:50%; height:14px; border-left:2px dashed var(--border-color, #4b5563); }
        .ap-none { font-size:0.75rem; opacity:0.5; text-align:center; padding:4px; }
        .ap-tier-lbl { text-align:center; font-size:0.72rem; font-weight:800; letter-spacing:0.08em; text-transform:uppercase; opacity:0.6; margin:12px 0 4px; }
        .ap-band { display:flex; gap:3px; margin:0 auto; }
        .ap-band .ap-box { min-width:0; padding:8px 4px; overflow:hidden; }
        .ap-band .nm { white-space:nowrap; overflow:hidden; text-overflow:ellipsis; font-size:0.8rem; }
        .ap-apex { width:0; height:0; margin:0 auto; border-left:70px solid transparent; border-right:70px solid transparent; border-bottom:56px solid #1e3a8a; }
        .ap-apex-lbl { text-align:center; font-weight:800; margin-top:-30px; color:#fff; position:relative; font-size:0.9rem; }
        .ap-sec { margin-top:var(--space-4); }
        .ap-sec h2 { margin:0; font-size:1.05rem; }
        .ap-sec .meta { font-size:0.8rem; opacity:0.7; margin:2px 0 6px; }
        .ap-sec .meta a { color:#93c5fd; }
        .ap-sec.focus h2 { color:#93c5fd; }
        .ap-div { font-weight:700; font-size:0.85rem; margin:10px 0 4px; }
        .ap-div .x { font-weight:400; opacity:0.6; font-size:0.78rem; }
        .ap-wrap { overflow-x:auto; }
        .ap-tbl { width:100%; border-collapse:collapse; font-size:0.84rem; }
        .ap-tbl th, .ap-tbl td { padding:4px 6px; text-align:center; border-top:1px solid var(--border-color, #374151); white-space:nowrap; }
        .ap-tbl th { font-size:0.72rem; opacity:0.65; font-weight:700; }
        .ap-tbl td.tm, .ap-tbl th.tm { text-align:left; white-space:normal; min-width:140px; }
        .ap-tbl tr.ours td { font-weight:800; color:#fde68a; }
        .ap-warn { color:#fca5a5; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="ap-back">← Back</button>
        <div style="flex:1; min-width:0;"><h1 style="margin:0;" id="ap-title">🔺 APSL Pyramid</h1><div id="ap-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
        <button class="btn btn-secondary" id="ap-refresh" style="padding:4px 12px; font-size:0.85rem;">🔄</button>
      </div>
      <div class="screen-content" style="max-width:1100px; margin:0 auto;">
        <div id="ap-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#ap-back').addEventListener('click', () => this.navigation.goBack());
    div.querySelector('#ap-refresh').addEventListener('click', () => this.load(true));
    div.querySelector('#ap-body').addEventListener('click', (e) => {
      const pill = e.target.closest('[data-view]');
      if (pill) { this._setView(pill.dataset.view, null); return; }
      const box = e.target.closest('[data-node]');
      if (box) this._setView('tables', Number(box.dataset.node));
    });
    return div;
  }

  onEnter() {
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => {
      const t = this.find('#ap-title'); if (t && this._copy('title')) t.textContent = this._copy('title');
      const s = this.find('#ap-sub'); if (s) s.textContent = this._copy('subtitle');
      if (this.data) this._renderBody();
    });
    this.load(false);
  }

  async load(refresh) {
    this.loading = true; this.err = ''; this._renderBody();
    try {
      const res = await this.auth.fetch(`/api/pyramid?root=apsl${refresh ? '&refresh=1' : ''}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
    } catch (err) { this.data = null; this.err = err.message || 'Failed to load.'; }
    this.loading = false;
    if (this.isMounted) this._renderBody();
  }

  _setView(view, focusId) {
    this.view = view; this.focusId = focusId;
    try { localStorage.setItem('apsl-pyramid-view', view); } catch (_) { /* private mode */ }
    this._renderBody();
    if (focusId) {
      const el = this.find(`#ap-sec-${focusId}`);
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
    } else window.scrollTo({ top: 0 });
  }

  // ── tree helpers ─────────────────────────────────────────────────────
  _nodes() { return (this.data && this.data.nodes) || []; }
  _root() { return this._nodes().find((n) => n.id === this.data.root_id); }
  _children(id) { return this._nodes().filter((n) => n.parent_id === id); }
  _label(n) { return n.short_name || n.name; }
  _counts(n) {
    return n.teams ? this._copy('node_counts', { clubs: n.clubs, teams: n.teams }) : '';
  }
  // A conference's tables come in on APSL's feed — its read time is the root's.
  _sourceOf(n) {
    if (n.source) return n.source;
    if (n.kind === 'conference') { const p = this._nodes().find((x) => x.id === n.parent_id); return p ? p.source : null; }
    return null;
  }

  _box(n, extraClass = '', style = '') {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const cls = n.tier === 2 ? 'ap-t2' : 'ap-t1';
    const counts = this._counts(n);
    return `
      <div class="ap-box ${cls} ${counts ? '' : 'dim'} ${extraClass}" data-node="${n.id}" style="${style}" title="${esc(n.name)}">
        <div class="nm">${esc(this._label(n))}</div>
        <div class="sub">${esc((n.states || []).join(' · ') || n.region || '')}</div>
        ${counts ? `<div class="ct">${esc(counts)}</div>` : ''}
      </div>`;
  }

  _renderBody() {
    const el = this.find('#ap-body');
    if (!el) return;
    if (this.loading && !this.data) { el.innerHTML = '<div class="loading">Loading…</div>'; return; }
    if (this.err) { el.innerHTML = `<div class="error">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.data || !this._root()) { el.innerHTML = `<div style="opacity:0.7;">${this.escapeHtml(this._copy('empty'))}</div>`; return; }
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const tot = this.data.totals || {};
    const pills = [['org', 'view_org'], ['pyramid', 'view_pyramid'], ['tables', 'view_tables']]
      .map(([v, tier]) => `<button class="ap-pill ${this.view === v ? 'on' : ''}" data-view="${v}">${esc(this._copy(tier) || v)}</button>`).join('');
    const body = this.view === 'pyramid' ? this._pyramidHtml() : this.view === 'tables' ? this._tablesHtml() : this._orgHtml();
    el.innerHTML = `
      <div class="ap-totals">${esc(this._copy('totals', tot))}</div>
      <div class="ap-pills">${pills}</div>
      ${this.loading ? '<div class="loading" style="text-align:center;">Refreshing…</div>' : ''}
      ${body}`;
  }

  // ── Org chart ────────────────────────────────────────────────────────
  _orgHtml() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const root = this._root();
    const confs = this._children(root.id).filter((n) => n.kind === 'conference');
    const tot = this.data.totals || {};
    const cols = confs.map((c) => {
      const feeds = this._children(c.id);
      return `
        <div class="ap-col">
          ${this._box(c)}
          ${feeds.length
            ? feeds.map((f) => `<div class="ap-feed">${this._box(f)}</div>`).join('')
            : ''}
        </div>`;
    }).join('');
    return `
      <div class="ap-root">
        <div class="ap-box ap-t0" data-node="${root.id}">
          <div class="nm">${esc(root.name)}</div>
          <div class="ct">${esc(this._copy('node_counts', { clubs: tot.clubs, teams: tot.teams }))}</div>
        </div>
      </div>
      <div class="ap-org">${cols}</div>`;
  }

  // ── Pyramid ──────────────────────────────────────────────────────────
  // A band per tier; band width ∝ the tier's team count against the
  // widest tier, each league's share ∝ its own teams (a league with no
  // mirrored tables keeps a sliver so it still shows).
  _pyramidHtml() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const root = this._root();
    const tiers = [1, 2].map((t) => this._nodes().filter((n) => n.tier === t && n.id !== root.id));
    // Feeders in their conference's order, so each sits under what it feeds.
    const confAt = new Map(tiers[0].map((n, i) => [n.id, i]));
    tiers[1].sort((a, b) => (confAt.get(a.parent_id) ?? 99) - (confAt.get(b.parent_id) ?? 99));
    const sums = tiers.map((list) => list.reduce((a, n) => a + (n.teams || 0), 0));
    const widest = Math.max(1, ...sums);
    const band = (list, sum, tierKey) => {
      if (!list.length) return '';
      const share = Math.max(40, Math.round((sum / widest) * 100));
      const sliver = Math.max(1, Math.round(sum * 0.04));
      return `
        <div class="ap-tier-lbl">${esc(this._copy(tierKey))} · ${esc(this._copy('node_counts', { clubs: list.reduce((a, n) => a + (n.clubs || 0), 0), teams: sum }))}</div>
        <div class="ap-band" style="width:${share}%;">
          ${list.map((n) => this._box(n, '', `flex:${n.teams || sliver} 1 0;`)).join('')}
        </div>`;
    };
    return `
      <div class="ap-apex" data-node="${root.id}"></div>
      <div class="ap-apex-lbl">${esc(this._label(root))}</div>
      ${band(tiers[0], sums[0], 'tier_1')}
      ${band(tiers[1], sums[1], 'tier_2')}`;
  }

  // ── Standings ────────────────────────────────────────────────────────
  _tablesHtml() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const root = this._root();
    const order = [];
    for (const c of this._children(root.id)) { order.push(c); for (const f of this._children(c.id)) order.push(f); }
    order.push(root);    // the root's own tables are the cups
    return order.map((n) => {
      if (n.id === root.id && !(n.divisions || []).length) return '';
      const src = this._sourceOf(n);
      let meta = esc((n.states || []).join(' · ') || n.region || '');
      if (n.kind === 'affiliate') {
        const parent = this._nodes().find((x) => x.id === n.parent_id);
        if (parent) meta += ` · ${esc(this._copy('feeds', { parent: this._label(parent) }))}`;
      }
      if (src && src.ok === false) meta += ` · <span class="ap-warn">${esc(this._copy('stale', { when: src.ok_at || '—' }))}</span>`;
      else if (src && src.read_at) meta += ` · ${esc(this._copy('read_at', { when: src.read_at }))}`;
      const site = n.standings_url || n.website_url;
      if (site) meta += ` · <a href="${esc(site)}" target="_blank" rel="noopener">${esc(this._copy('site_link'))}</a>`;
      const divs = n.divisions || [];
      const tables = divs.length
        ? divs.map((d) => this._tableHtml(d)).join('')
        : `<div style="opacity:0.6; font-size:0.85rem;">${esc(this._copy('no_source'))}</div>`;
      const title = n.id === root.id ? this._copy('cups') : n.name;
      return `
        <div class="ap-sec ${this.focusId === n.id ? 'focus' : ''}" id="ap-sec-${n.id}">
          <h2>${esc(title)}</h2>
          <div class="meta">${meta}${n.teams ? ` · ${esc(this._counts(n))}` : ''}</div>
          ${tables}
        </div>`;
    }).join('');
  }

  _tableHtml(d) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    // Column heads: one copy row, space-separated, in table order.
    const cols = (this._copy('table_head') || '').split(/\s+/).filter(Boolean);
    const head = cols.map((c, i) => `<th${i === 1 ? ' class="tm"' : ''}>${esc(c === '-' ? '' : c)}</th>`).join('');
    const rows = (d.teams || []).map((t) => `
      <tr class="${t.ours ? 'ours' : ''}">
        <td>${t.pos == null ? '' : esc(t.pos)}</td><td class="tm">${esc(t.name)}</td>
        <td>${t.gp}</td><td>${t.w}</td><td>${t.d}</td><td>${t.l}</td>
        <td>${t.gf}</td><td>${t.ga}</td><td>${t.gd > 0 ? '+' : ''}${t.gd}</td><td><b>${t.pts}</b></td>
      </tr>`).join('');
    return `
      <div class="ap-div">${esc(d.name)}</div>
      <div class="ap-wrap"><table class="ap-tbl">
        <thead><tr>${head}</tr></thead>
        <tbody>${rows}</tbody>
      </table></div>`;
  }
}
window.ApslPyramidScreen = ApslPyramidScreen;
