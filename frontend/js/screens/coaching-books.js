// CoachingBooksScreen — #books, 📚 Coaching books (mig 1928). Owner only.
//
// Owner 2026-11-26: "i have lots of coaching books but they are in the coach
// viewer from soccer tutor" · "i would like to incorporate into footballhome
// for my personal use" · "yes add the owner-only page".
//
// One book at a time (pills).  For the book: author / team / season and how
// the author built it, then the team patterns written up from it in OUR
// words, grouped by game moment (pills: All / In possession / Out of
// possession / transitions / set pieces).  Each pattern: situation, trigger,
// aim, who does what, and its pages — tap a page number to open the page
// image (base64 from GET /api/coaching-books/:book/pages/:n). Only people
// listed in menu_page_people for 'books' (the owner) get the menu pill or data.
// Wording: message_templates kind 'books'.
//
// 📋 Table view (mig 1961, owner 11/27 "can we fix up the books page with a
// "table" view. title, read, anaylysis etc?"): every book in one sortable
// table — pages, read (pattern count), patterns per moment, analysis
// (method write-up) — with All / Read / Not read pills; tap a row → 📖 Book.
class CoachingBooksScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.bookId = null; this.moment = 'all';
    this.viewer = null;   // { book, page, count, image, mime, loading }
    this.view = 'table'; this.filter = 'all'; this.sort = { key: 'title', dir: 1 };
  }

  _c(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('books', tier, tokens) : ''; }

  render() {
    const el = document.createElement('div');
    el.className = 'screen';
    el.innerHTML = `
      <style>
        .cbk { padding:10px 12px 40px; max-width:980px; margin:0 auto; }
        .cbk h2 { margin:0 0 2px; font-size:1.2rem; }
        .cbk .intro { font-size:0.82rem; opacity:0.75; margin-bottom:10px; }
        .cbk .pills { display:flex; flex-wrap:wrap; gap:6px; margin:6px 0; }
        .cbk .pill { padding:6px 14px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.86rem; min-height:0; min-width:0;
                     border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .cbk .pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .cbk .book { border:1px solid var(--border-color); border-radius:12px; padding:10px 12px; margin:8px 0 12px; background:var(--bg-secondary); }
        .cbk .book b { font-size:1rem; }
        .cbk .book .meta { font-size:0.82rem; opacity:0.8; margin-top:2px; }
        .cbk .book .method { font-size:0.82rem; margin-top:6px; line-height:1.4; }
        .cbk .mo { margin:16px 0 6px; font-size:0.78rem; text-transform:uppercase; letter-spacing:0.07em; opacity:0.65; }
        .cbk .pat { border:1px solid var(--border-color); border-radius:10px; padding:9px 11px; margin-bottom:8px; }
        .cbk .pat .t { font-weight:800; }
        .cbk .pat .ch { font-size:0.74rem; opacity:0.6; }
        .cbk .pat p { margin:4px 0; font-size:0.86rem; line-height:1.4; }
        .cbk .pat .lbl { font-weight:700; opacity:0.75; }
        .cbk .pat ul { margin:4px 0 2px 0; padding-left:18px; font-size:0.85rem; line-height:1.4; }
        .cbk .pg { color:#93c5fd; font-weight:700; cursor:pointer; text-decoration:underline; }
        .cbk .none { padding:20px 0; opacity:0.7; }
        .cbk .tot { font-size:0.82rem; opacity:0.75; margin:4px 0 8px; }
        .cbk .tw { overflow-x:auto; }
        .cbk table.bt { width:100%; border-collapse:collapse; font-size:0.85rem; }
        .cbk table.bt th { text-align:left; font-size:0.74rem; text-transform:uppercase; letter-spacing:0.05em; opacity:0.75;
                           padding:6px 8px; border-bottom:1px solid var(--border-color); cursor:pointer; white-space:nowrap; user-select:none; }
        .cbk table.bt th.on { opacity:1; color:var(--primary-color); }
        .cbk table.bt td { padding:7px 8px; border-bottom:1px solid var(--border-color); vertical-align:top; }
        .cbk table.bt tr[data-cbk-open] { cursor:pointer; }
        .cbk table.bt tr[data-cbk-open]:hover td { background:var(--bg-secondary); }
        .cbk table.bt .bk { font-weight:700; }
        .cbk table.bt .au { font-size:0.75rem; opacity:0.65; }
        .cbk table.bt .num { text-align:right; white-space:nowrap; }
        .cbk table.bt .mom { white-space:nowrap; font-size:0.76rem; }
        .cbk table.bt .mom span { display:inline-block; margin-right:6px; opacity:0.85; }
        .cbk table.bt .no { opacity:0.55; white-space:nowrap; }
        .cbk table.bt .rd { white-space:nowrap; }
        .cbk-view { position:fixed; inset:0; z-index:2000; background:rgba(0,0,0,0.88); display:flex; flex-direction:column; }
        .cbk-view .bar { display:flex; gap:8px; align-items:center; justify-content:center; padding:8px; color:#fff; }
        .cbk-view .bar button { padding:6px 14px; border-radius:999px; font-weight:700; min-height:0; min-width:0; }
        .cbk-view .img { flex:1; overflow:auto; text-align:center; }
        .cbk-view img { max-width:min(100%, 820px); background:#fff; }
      </style>
      <div class="cbk"><div class="loading" style="padding-top:40px;">Loading…</div></div>`;
    this.element = el;
    el.addEventListener('click', (e) => {
      const v = e.target.closest('[data-cbk-view]');
      if (v) { this.view = v.dataset.cbkView; this._draw(); return; }
      const f = e.target.closest('[data-cbk-filter]');
      if (f) { this.filter = f.dataset.cbkFilter; this._draw(); return; }
      const so = e.target.closest('[data-cbk-sort]');
      if (so) { const k = so.dataset.cbkSort; this.sort = { key: k, dir: this.sort.key === k ? -this.sort.dir : (k === 'title' ? 1 : -1) }; this._draw(); return; }
      const row = e.target.closest('[data-cbk-open]');
      if (row) { this.bookId = Number(row.dataset.cbkOpen); this.moment = 'all'; this.view = 'book'; this._draw(); window.scrollTo(0, 0); return; }
      const b = e.target.closest('[data-cbk-book]');
      if (b) { this.bookId = Number(b.dataset.cbkBook); this.moment = 'all'; this._draw(); return; }
      const m = e.target.closest('[data-cbk-moment]');
      if (m) { this.moment = m.dataset.cbkMoment; this._draw(); return; }
      const pg = e.target.closest('[data-cbk-page]');
      if (pg) { this._open(this.bookId, Number(pg.dataset.cbkPage)); return; }
      const nav = e.target.closest('[data-cbk-nav]');
      if (nav && this.viewer) {
        const step = nav.dataset.cbkNav;
        if (step === 'close') { this.viewer = null; this._drawViewer(); return; }
        const next = this.viewer.page + (step === 'next' ? 1 : -1);
        if (next >= 1 && next <= this.viewer.count) this._open(this.viewer.book, next);
      }
    });
    return el;
  }

  onEnter() {
    const copy = window.MessageCopy ? Promise.resolve(MessageCopy.load(this.auth)).catch(() => {}) : Promise.resolve();
    const lib = this.auth.fetch('/api/coaching-books')
      .then(r => r.ok ? r.json() : Promise.reject(new Error(`HTTP ${r.status}`)));
    Promise.all([lib, copy]).then(([d]) => {
      this.data = d; this.err = '';
      if (!this.bookId && d.books && d.books.length) this.bookId = d.books[0].id;
    }).catch((e) => { this.err = e.message || 'error'; })
      .finally(() => { if (this.isMounted !== false) this._draw(); });
  }

  onExit() { this.viewer = null; this._drawViewer(); }

  _draw() {
    const box = this.find('.cbk');
    if (!box) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    if (this.err) { box.innerHTML = `<div class="none">${esc(this.err)}</div>`; return; }
    const d = this.data || { books: [], moments: [] };
    const books = d.books || [];
    let html = `<h2>${esc(this._c('title'))}</h2><div class="intro">${esc(this._c('intro'))}</div>`;
    if (!books.length) { box.innerHTML = html + `<div class="none">${esc(this._c('none'))}</div>`; return; }

    html += `<div class="pills">${['table', 'book'].map(v =>
      `<button class="pill ${this.view === v ? 'on' : ''}" data-cbk-view="${v}">${esc(this._c('view_' + v))}</button>`).join('')}</div>`;
    if (this.view === 'table') { box.innerHTML = html + this._table(books, d.moments || []); return; }

    html += `<div class="pills">${books.map(b =>
      `<button class="pill ${b.id === this.bookId ? 'on' : ''}" data-cbk-book="${b.id}">${esc(b.team || b.title)}${b.season ? ' ' + esc(b.season) : ''}</button>`).join('')}</div>`;
    const book = books.find(b => b.id === this.bookId) || books[0];
    const pats = book.patterns || [];
    html += `<div class="book"><b>${esc(book.title)}</b>${book.subtitle ? ` — ${esc(book.subtitle)}` : ''}
      <div class="meta">${esc(book.author)}${book.team ? ' · ' + esc(book.team) : ''}${book.season ? ' · ' + esc(book.season) : ''}
        · ${esc(this._c('counts', { pages: book.page_count, patterns: pats.length }))}
        ${book.page_count ? ` · <span class="pg" data-cbk-page="1">${esc(this._c('browse'))}</span>` : ''}</div>
      ${book.method_note ? `<div class="method">${esc(book.method_note)}</div>` : ''}</div>`;

    if (!pats.length) { box.innerHTML = html + `<div class="none">${esc(this._c('no_patterns'))}</div>`; return; }

    const moments = (d.moments || []).filter(m => pats.some(p => p.moment === m.code));
    html += `<div class="pills"><button class="pill ${this.moment === 'all' ? 'on' : ''}" data-cbk-moment="all">${esc(this._c('all'))}</button>${
      moments.map(m => `<button class="pill ${this.moment === m.code ? 'on' : ''}" data-cbk-moment="${esc(m.code)}">${esc(m.title)}</button>`).join('')}</div>`;

    for (const m of moments) {
      if (this.moment !== 'all' && this.moment !== m.code) continue;
      html += `<div class="mo">${esc(m.title)}</div>`;
      for (const p of pats.filter(x => x.moment === m.code)) {
        const pages = [];
        for (let i = p.page_from; i <= p.page_to; i++) pages.push(`<span class="pg" data-cbk-page="${i}">${i}</span>`);
        html += `<div class="pat">
          ${p.chapter ? `<div class="ch">${esc(p.chapter)}</div>` : ''}
          <div class="t">${esc(p.title)}${p.vs_formation ? ` <span class="ch">${esc(this._c('vs'))} ${esc(p.vs_formation)}</span>` : ''}</div>
          <p>${esc(p.situation)}</p>
          ${p.trigger ? `<p><span class="lbl">${esc(this._c('trigger'))}:</span> ${esc(p.trigger)}</p>` : ''}
          ${p.outcome ? `<p><span class="lbl">${esc(this._c('outcome'))}:</span> ${esc(p.outcome)}</p>` : ''}
          ${(p.roles || []).length ? `<ul>${p.roles.map(r => `<li><b>${esc(r.role)}</b> — ${esc(r.job)}</li>`).join('')}</ul>` : ''}
          <p class="ch">${esc(this._c('pages'))} ${pages.join(' ')}</p>
        </div>`;
      }
    }
    box.innerHTML = html;
  }

  // 📋 One row per book: pages, read, patterns per moment, analysis.
  _table(books, moments) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const abbr = String(this._c('moment_abbr') || '').split('|');
    const rows = books.map(b => {
      const pats = b.patterns || [];
      const per = moments.map(m => pats.filter(p => p.moment === m.code).length);
      return { b, title: b.title || '', pages: b.page_count || 0, read: pats.length, per, analysis: b.method_note ? 1 : 0 };
    });
    const nRead = rows.filter(r => r.read).length;
    const shown = rows.filter(r => this.filter === 'all' || (this.filter === 'read' ? r.read : !r.read));
    const { key, dir } = this.sort;
    shown.sort((a, b) => {
      const x = a[key], y = b[key];
      const c = typeof x === 'string' ? x.localeCompare(y) : x - y;
      return (c || a.title.localeCompare(b.title)) * (c ? dir : 1);
    });
    const counts = { all: rows.length, read: nRead, unread: rows.length - nRead };
    let html = `<div class="pills">${['all', 'read', 'unread'].map(f =>
      `<button class="pill ${this.filter === f ? 'on' : ''}" data-cbk-filter="${f}">${esc(this._c('filter_' + f, { n: counts[f] }))}</button>`).join('')}</div>`;
    html += `<div class="tot">${esc(this._c('totals', {
      books: rows.length, read: nRead,
      patterns: rows.reduce((s, r) => s + r.read, 0), pages: rows.reduce((s, r) => s + r.pages, 0) }))}</div>`;
    const th = (k, label, cls = '') =>
      `<th class="${cls} ${key === k ? 'on' : ''}" data-cbk-sort="${k}">${esc(label)}${key === k ? (dir > 0 ? ' ▲' : ' ▼') : ''}</th>`;
    html += `<div class="tw"><table class="bt"><thead><tr>
      ${th('title', this._c('col_book'))}${th('pages', this._c('col_pages'), 'num')}${th('read', this._c('col_read'))}
      <th>${esc(this._c('col_moments'))}</th>${th('analysis', this._c('col_analysis'))}</tr></thead><tbody>`;
    for (const r of shown) {
      const b = r.b;
      html += `<tr data-cbk-open="${b.id}">
        <td><div class="bk">${esc(b.title)}${b.subtitle ? ` — ${esc(b.subtitle)}` : ''}</div><div class="au">${esc([b.author, b.team, b.season].filter(Boolean).join(' · '))}</div></td>
        <td class="num">${r.pages}</td>
        <td class="${r.read ? 'rd' : 'no'}">${esc(r.read ? this._c('read_yes', { patterns: r.read }) : this._c('read_no'))}</td>
        <td class="mom">${r.read ? r.per.map((n, i) => n ? `<span>${esc(abbr[i] || moments[i].title)} ${n}</span>` : '').join('') : ''}</td>
        <td class="${r.analysis ? '' : 'no'}">${esc(this._c(r.analysis ? 'analysis_yes' : 'analysis_no'))}</td>
      </tr>`;
    }
    return html + `</tbody></table></div>`;
  }

  _open(book, page) {
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
    let v = this.element.querySelector('.cbk-view');
    if (!this.viewer) { if (v) v.remove(); return; }
    if (!v) { v = document.createElement('div'); v.className = 'cbk-view'; this.element.appendChild(v); }
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const w = this.viewer;
    v.innerHTML = `<div class="bar">
        <button data-cbk-nav="prev">${esc(this._c('prev'))}</button>
        <span>${w.page}${w.count ? ' / ' + w.count : ''}</span>
        <button data-cbk-nav="next">${esc(this._c('next'))}</button>
        <button data-cbk-nav="close">${esc(this._c('close'))}</button></div>
      <div class="img">${w.loading ? '<div class="loading" style="color:#fff;padding-top:40px;">Loading…</div>'
        : w.image ? `<img alt="" src="data:${esc(w.mime)};base64,${w.image}">` : ''}</div>`;
  }
}
