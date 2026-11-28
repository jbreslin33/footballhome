// ExercisesScreen — #exercises[/<id>], 🏋️ the exercise catalog (migs 2191/2197).
//
// Owner 2026-11-27: "we need a way to catalog all the exercises from the
// books and any new books etc coming in" · "we may need to modernize the
// section for exercises to the way the other fh stuff is formatted" · "we
// just need a pure exercise pill right?".
//
// Built like #books: category pills (All + one per exercise_categories row
// that has exercises), a source picker and a search box, then one sortable
// table (exercise, category, players, area, source).  Tap a row → the full
// write-up (GET /api/exercises/:id): what it trains, set-up, how it runs,
// rules, progressions, coaching points.  Book exercises cite their app pages;
// the owner (menu_page_people 'books') can tap a page to see the diagram.
// Wording: message_templates kind 'exercises'.
//
// 📚 Sources view (owner 11/27 "can it show all the books it uses as sources
// and how many exercises per book so its sortable by source num of
// exercises?"): every book (read for exercises or not) and any other source,
// sortable by name / pages / exercises; tap one → its exercises.
//
// 🗓 Plans view + ➕ Add to plan (mig 5020, owner 11/27 "for youth … mon,wed,
// fri … for men … -1 game day"): each team's week — youth by weekday, men /
// women by match day (MD+1 … MD-1, MD = game warm-up, no-game week) — from
// /api/session-plans; practices and games on the calendar pick their slot
// (components/session-plan-panel.js on the event page).  #exercises?view=plans&team=<id>.
class ExercisesScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.cat = 'all'; this.source = 'all'; this.q = '';
    this.sort = { key: 'source', dir: 1 };
    this.view = 'exercises'; this.srcSort = { key: 'count', dir: -1 }; this.srcFilter = 'all';
    this.openId = null; this.detail = null; this.detailErr = '';
    this.viewer = null;   // { book, page, count, image, mime, loading }
    this.teams = null; this.planTeam = null; this.plan = null; this.addOpen = false; this.addMsg = ''; this.planBusy = false;
  }

  _c(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('exercises', tier, tokens) : ''; }

  render() {
    const el = document.createElement('div');
    el.className = 'screen';
    el.innerHTML = `
      <style>
        .exc { padding:10px 12px 40px; max-width:1080px; margin:0 auto; }
        .exc h2 { margin:0 0 2px; font-size:1.2rem; }
        .exc .intro { font-size:0.82rem; opacity:0.75; margin-bottom:10px; }
        .exc .pills { display:flex; flex-wrap:wrap; gap:6px; margin:6px 0; }
        .exc .pill { padding:6px 12px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.84rem; min-height:0; min-width:0;
                     border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .exc .pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .exc .pill .n { opacity:0.7; font-weight:600; margin-left:4px; }
        .exc .bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin:8px 0; }
        .exc .bar select, .exc .bar input { padding:6px 10px; border-radius:8px; border:1px solid var(--border-color);
                     background:var(--bg-secondary); color:var(--text-primary); font-size:0.86rem; min-height:0; }
        .exc .bar input { flex:1; min-width:180px; }
        .exc .catd { font-size:0.8rem; opacity:0.75; margin:2px 0 6px; }
        .exc .tot { font-size:0.82rem; opacity:0.75; margin:4px 0 8px; }
        .exc .none { padding:20px 0; opacity:0.7; }
        .exc .tw { overflow-x:auto; }
        .exc table.et { width:100%; border-collapse:collapse; font-size:0.85rem; }
        .exc table.et th { text-align:left; font-size:0.74rem; text-transform:uppercase; letter-spacing:0.05em; opacity:0.75;
                           padding:6px 8px; border-bottom:1px solid var(--border-color); cursor:pointer; white-space:nowrap; user-select:none; }
        .exc table.et th.on { opacity:1; color:var(--primary-color); }
        .exc table.et td { padding:7px 8px; border-bottom:1px solid var(--border-color); vertical-align:top; }
        .exc table.et tr[data-exc-open] { cursor:pointer; }
        .exc table.et tr[data-exc-open]:hover td { background:var(--bg-secondary); }
        .exc table.et .t { font-weight:700; }
        .exc table.et .o { font-size:0.76rem; opacity:0.7; margin-top:2px; }
        .exc table.et .sm { font-size:0.78rem; white-space:nowrap; }
        .exc table.et .num { text-align:right; }
        .exc table.et tr[data-exc-src]:hover td { background:var(--bg-secondary); }
        .exc table.et .src { font-size:0.76rem; opacity:0.75; max-width:220px; }
        .exc .back { margin:4px 0 8px; }
        .exc .card { border:1px solid var(--border-color); border-radius:12px; padding:12px 14px; background:var(--bg-secondary); }
        .exc .card h3 { margin:0 0 4px; font-size:1.1rem; }
        .exc .card .meta { font-size:0.8rem; opacity:0.8; margin-bottom:8px; }
        .exc .card .chips { display:flex; flex-wrap:wrap; gap:6px; margin:6px 0 10px; }
        .exc .card .chip { font-size:0.76rem; padding:3px 9px; border-radius:999px; border:1px solid var(--border-color); }
        .exc .card .sec { margin:10px 0 0; }
        .exc .card .sec .lbl { font-size:0.74rem; text-transform:uppercase; letter-spacing:0.06em; opacity:0.65; margin-bottom:2px; }
        .exc .card .sec p { margin:0; font-size:0.9rem; line-height:1.45; }
        .exc .card .pics { display:flex; flex-wrap:wrap; gap:10px; margin-top:4px; }
        .exc .card .pics img { max-width:min(100%, 520px); background:#fff; border-radius:6px; cursor:zoom-in; }
        .exc .plgrid { display:grid; grid-template-columns:repeat(auto-fill, minmax(230px, 1fr)); gap:10px; margin-top:8px; }
        .exc .plcol { border:1px solid var(--border-color); border-radius:12px; padding:8px 10px; background:var(--bg-secondary); }
        .exc .plhead { display:flex; justify-content:space-between; font-weight:800; margin-bottom:6px; }
        .exc .plhead span { font-weight:600; opacity:0.7; font-size:0.8rem; }
        .exc .pltheme { width:100%; padding:4px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); font-size:0.8rem; margin-bottom:6px; }
        .exc .plempty { font-size:0.78rem; opacity:0.6; }
        .exc .plrow { border-top:1px solid var(--border-color); padding:6px 0; font-size:0.84rem; }
        .exc .plrow .o { font-size:0.74rem; opacity:0.7; }
        .exc .plbtns { display:flex; gap:3px; margin-top:4px; flex-wrap:wrap; }
        .exc .plbtns .pill { padding:2px 8px; font-size:0.74rem; }
        .exc .pg { color:#93c5fd; font-weight:700; cursor:pointer; text-decoration:underline; }
        .exc-view { position:fixed; inset:0; z-index:2000; background:rgba(0,0,0,0.88); display:flex; flex-direction:column; }
        .exc-view .vb { display:flex; gap:8px; align-items:center; justify-content:center; padding:8px; color:#fff; }
        .exc-view .vb button { padding:6px 14px; border-radius:999px; font-weight:700; min-height:0; min-width:0; }
        .exc-view .img { flex:1; overflow:auto; text-align:center; }
        .exc-view img { max-width:min(100%, 820px); background:#fff; }
      </style>
      <div class="exc"><div class="loading" style="padding-top:40px;">Loading…</div></div>`;
    this.element = el;
    el.addEventListener('click', (e) => {
      const v = e.target.closest('[data-exc-view]');
      if (v) { this.view = v.dataset.excView; if (this.view === 'plans') this._ensurePlan(); this._draw(); return; }
      if (this._planClick(e)) return;
      const sf = e.target.closest('[data-exc-sfilter]');
      if (sf) { this.srcFilter = sf.dataset.excSfilter; this._draw(); return; }
      const ss = e.target.closest('[data-exc-ssort]');
      if (ss) { const k = ss.dataset.excSsort; this.srcSort = { key: k, dir: this.srcSort.key === k ? -this.srcSort.dir : (k === 'title' ? 1 : -1) }; this._draw(); return; }
      const so2 = e.target.closest('[data-exc-src]');
      if (so2) { this.source = so2.dataset.excSrc; this.cat = 'all'; this.view = 'exercises'; this._draw(); window.scrollTo(0, 0); return; }
      const c = e.target.closest('[data-exc-cat]');
      if (c) { this.cat = c.dataset.excCat; this._draw(); return; }
      const so = e.target.closest('[data-exc-sort]');
      if (so) { const k = so.dataset.excSort; this.sort = { key: k, dir: this.sort.key === k ? -this.sort.dir : 1 }; this._draw(); return; }
      const row = e.target.closest('[data-exc-open]');
      if (row) { this.navigation.goTo('exercises', { entity: row.dataset.excOpen }); return; }
      if (e.target.closest('[data-exc-back]')) { this.navigation.goTo('exercises', {}); return; }
      const pg = e.target.closest('[data-exc-page]');
      if (pg && this.detail) { this._openPage(this.detail.book_id, Number(pg.dataset.excPage)); return; }
      const nav = e.target.closest('[data-exc-nav]');
      if (nav && this.viewer) {
        const step = nav.dataset.excNav;
        if (step === 'close') { this.viewer = null; this._drawViewer(); return; }
        const next = this.viewer.page + (step === 'next' ? 1 : -1);
        if (next >= 1 && (!this.viewer.count || next <= this.viewer.count)) this._openPage(this.viewer.book, next);
      }
    });
    el.addEventListener('change', (e) => {
      if (e.target.matches('[data-exc-source]')) { this.source = e.target.value; this._draw(); }
      if (e.target.matches('[data-exc-theme]')) {
        const slot = this.plan && this.plan.slots[Number(e.target.dataset.excTheme)];
        if (slot) this._planSend('PUT', `/api/session-plans/team/${this.planTeam}/theme`, { slot: this._slotKey(slot), theme: e.target.value });
      }
    });
    el.addEventListener('input', (e) => {
      if (e.target.matches('[data-exc-q]')) {
        this.q = e.target.value;
        clearTimeout(this._qt);
        this._qt = setTimeout(() => this._draw(true), 200);
      }
    });
    return el;
  }

  onEnter(params = {}) {
    this.openId = params && params.entity ? Number(params.entity) : null;
    this.detail = null; this.detailErr = ''; this.addOpen = false; this.addMsg = '';
    if (params && params.view === 'plans') { this.view = 'plans'; if (params.team) this.planTeam = Number(params.team); }
    this._loadTeams();
    const copy = window.MessageCopy ? Promise.resolve(MessageCopy.load(this.auth)).catch(() => {}) : Promise.resolve();
    const lib = this.data ? Promise.resolve(this.data) : this.auth.fetch('/api/exercises')
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)));
    Promise.all([lib, copy]).then(([d]) => {
      this.data = d; this.err = '';
      if (this.detail && !Object.keys(this.pics || {}).length) this._loadPics(this.detail);   // deep link: detail came first
    })
      .catch((e) => { this.err = e.message || 'error'; })
      .finally(() => { if (this.isMounted !== false) this._draw(); });
    if (this.openId) {
      this.auth.fetch(`/api/exercises/${this.openId}`)
        .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
        .then(d => { this.detail = d.exercise; this._loadPics(d.exercise); })
        .catch(e => { this.detailErr = e.message || 'error'; })
        .finally(() => { if (this.isMounted !== false) this._draw(); });
    }
  }

  onExit() { this.viewer = null; this._drawViewer(); }

  _draw(keepFocus) {
    const box = this.find('.exc');
    if (!box) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    if (this.err) { box.innerHTML = `<div class="none">${esc(this.err)}</div>`; return; }
    if (!this.data) return;
    if (this.openId) { box.innerHTML = this._card(); return; }

    const d = this.data;
    const cats = d.categories || [], all = d.exercises || [];
    const catById = new Map(cats.map(c => [c.id, c]));
    const srcById = new Map((d.sources || []).map(s => [s.id, s]));
    const oppLabel = new Map((d.oppositions || []).map(o => [o.code, o.label]));
    let html = `<h2>${esc(this._c('title'))}</h2><div class="intro">${esc(this._c('intro'))}</div>`;
    html += `<div class="pills">${['exercises', 'sources', 'plans'].map(v =>
      `<button class="pill ${this.view === v ? 'on' : ''}" data-exc-view="${v}">${esc(this._c('view_' + v))}</button>`).join('')}</div>`;
    if (this.view === 'sources') { box.innerHTML = html + this._sources(d.sources || []); return; }
    if (this.view === 'plans') { box.innerHTML = html + this._plans(); return; }
    if (!all.length) { box.innerHTML = html + `<div class="none">${esc(this._c('none'))}</div>`; return; }

    const inSource = all.filter(x => this.source === 'all' || String(x.source_id) === this.source);
    const q = this.q.trim().toLowerCase();
    const matchQ = (x) => !q || [x.title, x.objective, x.coach, x.source_ref, x.players].some(v => v && String(v).toLowerCase().includes(q));
    const base = inSource.filter(matchQ);
    const count = (id) => base.filter(x => x.category_id === id).length;
    html += `<div class="pills"><button class="pill ${this.cat === 'all' ? 'on' : ''}" data-exc-cat="all">${esc(this._c('all'))}<span class="n">${base.length}</span></button>${
      cats.filter(c => all.some(x => x.category_id === c.id)).map(c =>
        `<button class="pill ${this.cat === c.code ? 'on' : ''}" data-exc-cat="${esc(c.code)}" title="${esc(c.description)}">${esc(c.icon || '')} ${esc(c.label)}<span class="n">${count(c.id)}</span></button>`).join('')}</div>`;
    const cat = cats.find(c => c.code === this.cat);
    if (cat) html += `<div class="catd">${esc(cat.description)}</div>`;
    const used = (d.sources || []).filter(s => s.count > 0);
    html += `<div class="bar"><select data-exc-source><option value="all">${esc(this._c('all_sources', { n: used.length }))}</option>${
      used.map(s => `<option value="${s.id}" ${String(s.id) === this.source ? 'selected' : ''}>${esc(s.title)}</option>`).join('')}</select>
      <input type="search" data-exc-q placeholder="${esc(this._c('search'))}" value="${esc(this.q)}"></div>`;

    const rows = base.filter(x => !cat || x.category_id === cat.id).map(x => ({
      x, title: x.title, category: (catById.get(x.category_id) || {}).sort_label || (catById.get(x.category_id) || {}).label || '',
      players: x.min || x.max || 0, source: ((srcById.get(x.source_id) || {}).title || '') + String(x.page_from || 0).padStart(4, '0') }));
    const { key, dir } = this.sort;
    rows.sort((a, b) => {
      const p = a[key], r = b[key];
      const c = typeof p === 'string' ? p.localeCompare(r) : p - r;
      return (c || a.title.localeCompare(b.title)) * (c ? dir : 1);
    });
    html += `<div class="tot">${esc(this._c('totals', { shown: rows.length, total: all.length, sources: used.length }))}</div>`;
    const th = (k, label) => `<th class="${key === k ? 'on' : ''}" data-exc-sort="${k}">${esc(label)}${key === k ? (dir > 0 ? ' ▲' : ' ▼') : ''}</th>`;
    html += `<div class="tw"><table class="et"><thead><tr>${th('title', this._c('col_exercise'))}${th('category', this._c('col_category'))}${
      th('players', this._c('col_players'))}<th>${esc(this._c('col_area'))}</th>${th('source', this._c('col_source'))}</tr></thead><tbody>`;
    for (const r of rows.slice(0, 600)) {
      const x = r.x, c = catById.get(x.category_id) || {}, s = srcById.get(x.source_id) || {};
      html += `<tr data-exc-open="${x.id}">
        <td><div class="t">${esc(x.title)}</div><div class="o">${esc(x.objective)}</div></td>
        <td class="sm">${esc(c.icon || '')} ${esc(c.label || '')}${x.opposition ? `<div class="o">${esc(oppLabel.get(x.opposition) || x.opposition)}</div>` : ''}</td>
        <td class="sm">${esc(x.players || '')}</td>
        <td class="sm">${esc(x.area || '')}</td>
        <td class="src">${esc(s.title || '')}${x.page_from ? ` · ${esc(this._c('page', { p: x.page_from }))}` : ''}${x.coach ? `<div class="o">${esc(x.coach)}</div>` : ''}</td>
      </tr>`;
    }
    html += `</tbody></table></div>`;
    if (rows.length > 600) html += `<div class="tot">${esc(this._c('more', { n: rows.length - 600 }))}</div>`;
    box.innerHTML = html;
    if (keepFocus) {
      const inp = box.querySelector('[data-exc-q]');
      if (inp) { inp.focus(); inp.setSelectionRange(inp.value.length, inp.value.length); }
    }
  }

  // 📚 One row per source: name, pages, exercises catalogued.
  _sources(sources) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const nRead = sources.filter(s => s.count > 0).length;
    const counts = { all: sources.length, read: nRead, unread: sources.length - nRead };
    const shown = sources.filter(s => this.srcFilter === 'all' || (this.srcFilter === 'read' ? s.count > 0 : !s.count))
      .map(s => ({ s, title: s.title || '', pages: s.pages || 0, count: s.count || 0 }));
    const { key, dir } = this.srcSort;
    shown.sort((a, b) => {
      const x = a[key], y = b[key];
      const c = typeof x === 'string' ? x.localeCompare(y) : x - y;
      return (c || a.title.localeCompare(b.title)) * (c ? dir : 1);
    });
    let html = `<div class="pills">${['all', 'read', 'unread'].map(f =>
      `<button class="pill ${this.srcFilter === f ? 'on' : ''}" data-exc-sfilter="${f}">${esc(this._c('sfilter_' + f, { n: counts[f] }))}</button>`).join('')}</div>`;
    html += `<div class="tot">${esc(this._c('src_totals', { sources: sources.length, read: nRead,
      exercises: sources.reduce((t, s) => t + (s.count || 0), 0) }))}</div>`;
    const th = (k, label, cls = '') => `<th class="${cls} ${key === k ? 'on' : ''}" data-exc-ssort="${k}">${esc(label)}${key === k ? (dir > 0 ? ' ▲' : ' ▼') : ''}</th>`;
    html += `<div class="tw"><table class="et"><thead><tr>${th('title', this._c('col_source'))}${th('pages', this._c('col_pages'), 'num')}${
      th('count', this._c('col_exercises'), 'num')}</tr></thead><tbody>`;
    for (const r of shown) {
      const s = r.s;
      html += `<tr ${s.count ? `data-exc-src="${s.id}" data-exc-open-src` : ''} style="${s.count ? 'cursor:pointer' : ''}">
        <td><div class="t">${esc(s.title)}</div>${s.author ? `<div class="o">${esc(s.author)}</div>` : ''}</td>
        <td class="sm num">${s.pages || ''}</td>
        <td class="sm num">${s.count ? s.count : `<span class="o">${esc(this._c('not_read'))}</span>`}</td></tr>`;
    }
    return html + `</tbody></table></div>`;
  }

  _card() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    let html = `<div class="back"><button class="pill" data-exc-back>${esc(this._c('back'))}</button></div>`;
    if (this.detailErr) return html + `<div class="none">${esc(this.detailErr)}</div>`;
    const x = this.detail;
    if (!x) return html + `<div class="loading" style="padding-top:20px;">Loading…</div>`;
    const opp = ((this.data && this.data.oppositions) || []).find(o => o.code === x.opposition);
    const chips = [
      `${x.category_icon || ''} ${x.category}`, opp && opp.label, x.players, x.area,
      x.duration_min ? this._c('minutes', { n: x.duration_min }) : null,
      x.goals ? this._c('chip_goals') : null, x.keepers ? this._c('chip_keepers') : null,
      x.directional ? this._c('chip_directional') : null, x.age ].filter(Boolean);
    let pages = '';
    if (x.page_from) {
      const ps = [];
      for (let i = x.page_from; i <= (x.page_to || x.page_from); i++)
        ps.push(this.data && this.data.book_pages && x.book_id ? `<span class="pg" data-exc-page="${i}">${i}</span>` : String(i));
      pages = ` · ${esc(this._c('pages'))} ${ps.join(' ')}`;
    }
    html += `<div class="card"><h3>${esc(x.title)}</h3>
      <div class="meta">${esc(x.source)}${x.author ? ' · ' + esc(x.author) : ''}${x.source_ref ? ' · ' + esc(x.source_ref) : ''}${pages}${x.coach ? '<br>' + esc(x.coach) : ''}</div>
      <div class="chips">${chips.map(c => `<span class="chip">${esc(c)}</span>`).join('')}</div>`;
    for (const [k, v] of [['objective', x.objective], ['setup', x.setup], ['procedure', x.procedure], ['rules', x.rules],
                          ['progressions', x.progressions], ['coaching_points', x.coaching_points]]) {
      if (v) html += `<div class="sec"><div class="lbl">${esc(this._c('lbl_' + k))}</div><p>${esc(v)}</p></div>`;
    }
    html += this._addToPlanHtml();
    if (this.data && this.data.book_pages && x.book_id && x.page_from) {
      const pics = this.pics || {};
      html += `<div class="sec"><div class="lbl">${esc(this._c('lbl_pictures'))}</div><div class="pics">`;
      for (let i = x.page_from; i <= (x.page_to || x.page_from); i++) {
        const pic = pics[i];
        html += pic ? `<img alt="" data-exc-page="${i}" src="data:${esc(pic.mime)};base64,${pic.image}">`
                    : `<div class="loading" style="padding:20px 0;">Loading…</div>`;
      }
      html += `</div></div>`;
    }
    return html + `</div>`;
  }

  // ── 🗓 Session plans (mig 5020) ─────────────────────────────────────
  _slotKey(s) { return { anchor: s.anchor, weekday: s.weekday, md_offset: s.md_offset }; }
  _slotLabel(s) { return window.SessionPlanPanel ? SessionPlanPanel.slotLabel(s) : ''; }

  _loadTeams() {
    if (this.teams) { this._ensurePlan(); return; }
    this.auth.fetch('/api/session-plans/teams').then(r => r.ok ? r.json() : { teams: [] })
      .then(d => { this.teams = d.teams || []; this._ensurePlan(); if (this.isMounted !== false) this._draw(); })
      .catch(() => { this.teams = []; });
  }

  _ensurePlan() {
    if (!this.teams || !this.teams.length) return;
    if (!this.planTeam || !this.teams.some(t => t.id === this.planTeam)) this.planTeam = this.teams[0].id;
    if (!this.plan || this.plan.team.id !== this.planTeam) this._loadPlan();
  }

  _loadPlan() {
    const id = this.planTeam;
    this.auth.fetch(`/api/session-plans/team/${id}`).then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(d => { if (this.planTeam === id) { this.plan = d; if (this.isMounted !== false) this._draw(); } })
      .catch(() => {});
  }

  async _planSend(method, url, body, msg) {
    this.planBusy = true;
    try {
      const r = await this.auth.fetch(url, { method, headers: { 'Content-Type': 'application/json' }, body: body ? JSON.stringify(body) : undefined });
      if (!r.ok) { const j = await r.json().catch(() => ({})); throw new Error(j.error || `HTTP ${r.status}`); }
      this.addMsg = msg || '';
    } catch (e) { this.addMsg = e.message; }
    this.planBusy = false;
    this._loadPlan();
    this._draw();
  }

  _planClick(e) {
    const t = (sel) => e.target.closest(sel);
    let el;
    if ((el = t('[data-exc-plan-team]'))) { this.planTeam = Number(el.dataset.excPlanTeam); this.plan = null; this._ensurePlan(); this._draw(); return true; }
    if (t('[data-exc-add-open]')) { this.addOpen = !this.addOpen; this.addMsg = ''; this._ensurePlan(); this._draw(); return true; }
    if ((el = t('[data-exc-add-slot]')) && this.plan && this.detail) {
      const slot = this.plan.slots[Number(el.dataset.excAddSlot)];
      this._planSend('POST', `/api/session-plans/team/${this.planTeam}/items`, { slot: this._slotKey(slot), exercise_id: this.detail.id },
        this._c('added', { team: this.plan.team.label, slot: this._slotLabel(slot) }));
      return true;
    }
    if ((el = t('[data-exc-pl-del]'))) { this._planSend('DELETE', `/api/session-plans/items/template/${el.dataset.excPlDel}`); return true; }
    if ((el = t('[data-exc-pl-move]'))) { this._planSend('PUT', `/api/session-plans/items/template/${el.dataset.excPlItem}`, { move: Number(el.dataset.excPlMove) }); return true; }
    if ((el = t('[data-exc-pl-min]'))) {
      const m = Math.max(5, Math.min(180, (Number(el.dataset.excPlCur) || 0) + Number(el.dataset.excPlMin)));
      this._planSend('PUT', `/api/session-plans/items/template/${el.dataset.excPlItem}`, { minutes: m });
      return true;
    }
    if ((el = t('[data-exc-pl-open]'))) { this.navigation.goTo('exercises', { entity: el.dataset.excPlOpen }); return true; }
    return false;
  }

  _teamPills() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    return `<div class="pills">${(this.teams || []).map(t =>
      `<button class="pill ${t.id === this.planTeam ? 'on' : ''}" data-exc-plan-team="${t.id}">${esc(t.label)}</button>`).join('')}</div>`;
  }

  // ➕ on an exercise: pick the team, then the slot.
  _addToPlanHtml() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    if (!this.teams || !this.teams.length) return '';
    let html = `<div class="sec"><button class="pill" data-exc-add-open>${esc(this._c('add_to_plan'))}</button>`;
    if (this.addOpen) {
      html += `<div class="lbl" style="margin-top:8px;">${esc(this._c('add_heading'))}</div>` + this._teamPills();
      if (this.plan && this.plan.team.id === this.planTeam) {
        html += `<div class="pills">${this.plan.slots.map((s, i) =>
          `<button class="pill" data-exc-add-slot="${i}" ${this.planBusy ? 'disabled' : ''}>${esc(this._slotLabel(s))}<span class="n">${s.exercises.length}</span></button>`).join('')}</div>`;
      } else html += `<div class="loading">Loading…</div>`;
    }
    if (this.addMsg) html += `<div class="catd">${esc(this.addMsg)}</div>`;
    return html + `</div>`;
  }

  // 🗓 One team's week: a column per slot with its exercises and minutes.
  _plans() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    let html = `<div class="catd">${esc(this._c('plans_intro'))}</div>`;
    if (this.teams === null) return html + `<div class="loading">Loading…</div>`;
    if (!this.teams.length) return html + `<div class="none">${esc(this._c('no_teams'))}</div>`;
    html += this._teamPills();
    const p = this.plan;
    if (!p || p.team.id !== this.planTeam) return html + `<div class="loading">Loading…</div>`;
    const can = p.can_edit && !this.planBusy;
    html += `<div class="plgrid">`;
    p.slots.forEach((s, si) => {
      const total = s.exercises.reduce((n, x) => n + (x.minutes || 0), 0);
      html += `<div class="plcol"><div class="plhead">${esc(this._slotLabel(s))}<span>${total ? esc(this._c('plans_total', { n: total })) : ''}</span></div>`;
      html += can ? `<input class="pltheme" data-exc-theme="${si}" value="${esc(s.theme || '')}" placeholder="${esc(this._c('theme_ph'))}">`
                  : (s.theme ? `<div class="catd"><i>${esc(s.theme)}</i></div>` : '');
      if (!s.exercises.length) html += `<div class="plempty">${esc(this._c('plans_empty'))}</div>`;
      s.exercises.forEach((x, i) => {
        html += `<div class="plrow"><div><b class="pg" data-exc-pl-open="${x.exercise_id}" style="color:inherit; text-decoration:none;">${esc(x.icon || '')} ${esc(x.title)}</b>
            <div class="o">${esc([x.minutes ? x.minutes + "'" : '', x.players].filter(Boolean).join(' · '))}</div></div>
          ${can ? `<div class="plbtns">
            <button class="pill" data-exc-pl-min="-5" data-exc-pl-item="${x.id}" data-exc-pl-cur="${x.minutes || 0}">−5</button>
            <button class="pill" data-exc-pl-min="5" data-exc-pl-item="${x.id}" data-exc-pl-cur="${x.minutes || 0}">+5</button>
            <button class="pill" data-exc-pl-move="-1" data-exc-pl-item="${x.id}" ${i === 0 ? 'disabled' : ''}>▲</button>
            <button class="pill" data-exc-pl-move="1" data-exc-pl-item="${x.id}" ${i === s.exercises.length - 1 ? 'disabled' : ''}>▼</button>
            <button class="pill" data-exc-pl-del="${x.id}">✕</button></div>` : ''}</div>`;
      });
      html += `</div>`;
    });
    html += `</div>`;
    if (this.addMsg) html += `<div class="catd">${esc(this.addMsg)}</div>`;
    return html;
  }

  // Every page of the exercise inline (owner only — the books gate).
  _loadPics(x) {
    this.pics = {};
    if (!x || !x.book_id || !x.page_from || !(this.data && this.data.book_pages)) return;
    const id = x.id;
    for (let i = x.page_from; i <= (x.page_to || x.page_from); i++) {
      this.auth.fetch(`/api/coaching-books/${x.book_id}/pages/${i}`)
        .then(r => r.ok ? r.json() : null)
        .then(d => {
          if (!d || !this.detail || this.detail.id !== id) return;
          this.pics[i] = { image: d.image, mime: d.mime };
          if (this.isMounted !== false) this._draw();
        }).catch(() => {});
    }
  }

  _openPage(book, page) {
    if (!book) return;
    this.viewer = { ...(this.viewer || {}), book, page, loading: true };
    this._drawViewer();
    this.auth.fetch(`/api/coaching-books/${book}/pages/${page}`)
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)))
      .then(d => {
        if (!this.viewer || this.viewer.page !== page) return;
        this.viewer = { book, page, count: d.page_count, image: d.image, mime: d.mime, loading: false };
        this._drawViewer();
      })
      .catch(() => { if (this.viewer) { this.viewer.loading = false; this.viewer.image = null; this._drawViewer(); } });
  }

  _drawViewer() {
    if (!this.element) return;
    let v = this.element.querySelector('.exc-view');
    if (!this.viewer) { if (v) v.remove(); return; }
    if (!v) { v = document.createElement('div'); v.className = 'exc-view'; this.element.appendChild(v); }
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const w = this.viewer;
    v.innerHTML = `<div class="vb">
        <button data-exc-nav="prev">${esc(this._c('prev'))}</button>
        <span>${w.page}${w.count ? ' / ' + w.count : ''}</span>
        <button data-exc-nav="next">${esc(this._c('next'))}</button>
        <button data-exc-nav="close">${esc(this._c('close'))}</button></div>
      <div class="img">${w.loading ? '<div class="loading" style="color:#fff;padding-top:40px;">Loading…</div>'
        : w.image ? `<img alt="" src="data:${esc(w.mime)};base64,${w.image}">` : ''}</div>`;
  }
}
