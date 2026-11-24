// DualRosteringScreen — #dual-rostering (mig 1774; owner 2026-11-23: "we
// need vpn to scrape all apsl, casa … and the upsl … i need you to have a
// page to report dual or even tri rostering").
//
// Every name rostered on two or more teams across the league rosters we can
// read: APSL / CSL / ADASL team pages on TeamPass (through the scraper VPN)
// and CASA's public roster workbooks.  One card per name — its teams, the
// league of each, the date added and (where the league shows one) the birth
// date.  Pills: Different clubs (default) / Same club / 3+ teams / All; a
// search box narrows by name, team or league.  The fold at the bottom says
// where each roster came from and when it was read.
//
// The server re-reads the rosters when they are a day old (a sweep of ~200
// pages, a few minutes): the page shows LoadProgress and re-asks until it
// is done.  A name match is a lead, not proof — the chips say when birth
// dates agree or differ.
//
//   GET  /api/roster-watch            (RosterWatchController)
//   POST /api/roster-watch/refresh    read every roster again
//
// Words: message_templates kind 'roster_watch' (mig 1774).
class DualRosteringScreen extends Screen {
  static get POLL_MS() { return 4000; }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.error = null;
    this.view = 'cross';   // cross | same | tri | all
    this.q = '';
    this._timer = null;
  }

  _c(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('roster_watch', tier))
      ? MessageCopy.block('roster_watch', tier, tokens || {}) : fb;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .dr-pill { padding:4px 12px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.8rem; min-height:0; min-width:0;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .dr-pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .dr-card { border:1px solid var(--border-color); border-radius:var(--radius-md); background:var(--bg-secondary); padding:8px 12px; margin-bottom:8px; }
        .dr-head { display:flex; flex-wrap:wrap; align-items:center; gap:6px; }
        .dr-chip { font-size:0.72rem; font-weight:700; padding:1px 8px; border-radius:999px; background:rgba(148,163,184,0.18); white-space:nowrap; }
        .dr-row { display:flex; flex-wrap:wrap; gap:4px 10px; align-items:baseline; font-size:0.85rem; padding:4px 0 0 4px; border-top:1px solid var(--border-color); margin-top:4px; }
        .dr-src { font-size:0.8rem; padding:3px 0; display:flex; flex-wrap:wrap; gap:4px 10px; }
      </style>
      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <div id="dr-top"></div>
        <input id="dr-q" type="search" autocomplete="off" style="width:100%; margin:0 0 10px; padding:8px 10px; border-radius:var(--radius-md);
               border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary);">
        <div id="dr-body"></div>
      </div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter() {
    this.error = null;
    this._render();
    if (window.MessageCopy) MessageCopy.load(this.auth).then(() => this._render()).catch(() => {});
    this._load();
  }

  onExit() { this._stopPolling(); super.onExit(); }
  _stopPolling() { if (this._timer) { clearTimeout(this._timer); this._timer = null; } }

  async _load() {
    this._stopPolling();
    try {
      const res = await this.auth.fetch('/api/roster-watch');
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.data = body;
      this.error = null;
    } catch (err) {
      console.error('[dual-rostering] load failed:', err);
      this.error = err.message;
    }
    this._render();
    // A sweep is reading the league sites: ask again until it is done.
    if (this.data && this.data.sweep && this.data.sweep.running && this.element && this.element.isConnected) {
      this._timer = setTimeout(() => this._load(), DualRosteringScreen.POLL_MS);
    }
  }

  async _refresh() {
    try {
      const res = await this.auth.fetch('/api/roster-watch/refresh', { method: 'POST' });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    } catch (err) {
      console.error('[dual-rostering] refresh failed:', err);
      this.error = err.message;
    }
    this._load();
  }

  _wire() {
    this.element.addEventListener('click', (e) => {
      const v = e.target.closest('[data-dr-view]');
      if (v) { this.view = v.dataset.drView; this._render(); return; }
      if (e.target.closest('[data-dr-refresh]')) { this._refresh(); }
    });
    this.element.addEventListener('input', (e) => {
      if (e.target.id === 'dr-q') { this.q = e.target.value.trim().toLowerCase(); this._renderBody(); }
    });
  }

  _inView(m, view) {
    if (view === 'cross') return m.clubs >= 2;
    if (view === 'same') return m.clubs < 2;
    if (view === 'tri') return m.teams >= 3;
    return true;
  }
  _matchesSearch(m) {
    if (!this.q) return true;
    return (m.rows || []).some(r => [r.name, r.team, r.league, r.club, r.division].some(t => t && String(t).toLowerCase().includes(this.q)));
  }

  _render() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const top = this.find('#dr-top');
    if (!top) return;
    const q = this.find('#dr-q');
    if (q) q.placeholder = this._c('search', {}, 'Find a name, team or league');
    const d = this.data;
    if (this.error && !d) { top.innerHTML = `<div style="color:#f87171;">${esc(this.error)}</div>`; this._renderBody(); return; }
    if (!d) { top.innerHTML = ''; this._renderBody(); return; }

    const sweep = d.sweep || {};
    // Running with the count not in yet shows as 0 of 1, so the bar is up from the first poll.
    const progress = sweep.running && window.LoadProgress
      ? LoadProgress.html({ done: sweep.done || 0, total: Math.max(sweep.total || 0, (sweep.done || 0) + 1), what: this._c('reading', {}, 'rosters') }) : '';
    const matches = d.matches || [];
    const views = [['cross', 'pill_cross', 'Different clubs'], ['same', 'pill_same', 'Same club'], ['tri', 'pill_tri', '3+ teams'], ['all', 'pill_all', 'All']];
    top.innerHTML = `
      ${this.error ? `<div style="color:#f87171; margin-bottom:6px;">${esc(this.error)}</div>` : ''}
      <div style="font-size:0.85rem; opacity:0.85; margin-bottom:8px;">${esc(this._c('intro', { players: (d.totals || {}).players || 0, teams: (d.totals || {}).teams || 0 },
        `${(d.totals || {}).players || 0} rostered players on ${(d.totals || {}).teams || 0} teams.`))}</div>
      ${progress}
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin:8px 0 10px; ${window.LoadProgress ? LoadProgress.dim(!!sweep.running) : ''}">
        ${views.map(([code, tier, fb]) => `<button type="button" class="dr-pill ${code === this.view ? 'on' : ''}" data-dr-view="${code}">${esc(this._c(tier, {}, fb))} (${matches.filter(m => this._inView(m, code)).length})</button>`).join('')}
      </div>`;
    this._renderBody();
  }

  _renderBody() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const body = this.find('#dr-body');
    if (!body) return;
    const d = this.data;
    if (!d) { body.innerHTML = this.error ? '' : `<div class="loading-state"><div class="spinner"></div><p>Loading…</p></div>`; return; }

    const chip = (text, style = '') => `<span class="dr-chip" style="${style}">${esc(text)}</span>`;
    // "APSL · Delaware River Conference" + a table named after its conference → the league's first part + the table.
    const where = (r) => {
      if (!r.division || r.division === r.league) return r.league;
      const parts = String(r.league).split(' · ');
      const tail = parts[parts.length - 1];
      return (parts.length > 1 && r.division.startsWith(tail) ? parts.slice(0, -1).join(' · ') : r.league) + ' · ' + r.division;
    };
    const card = (m) => {
      const rows = m.rows || [];
      const name = (rows[0] || {}).name || m.key;
      const chips = [
        chip(this._c('chip_teams', { n: m.teams }, `${m.teams} teams`), m.teams >= 3 ? 'background:rgba(239,68,68,0.2); color:#f87171;' : ''),
        m.clubs >= 2 ? chip(this._c('chip_clubs', { n: m.clubs }, `${m.clubs} clubs`), 'background:rgba(251,191,36,0.2); color:#fbbf24;')
                     : chip(this._c('chip_same', {}, 'same club')),
        m.dob_same ? chip(this._c('chip_dob_ok', {}, '✓ same birth date'), 'background:rgba(34,197,94,0.2); color:#4ade80;') : '',
        m.dobs >= 2 ? chip(this._c('chip_dob_bad', {}, '⚠ different birth dates'), 'background:rgba(148,163,184,0.25);') : '',
      ].join('');
      return `<div class="dr-card">
          <div class="dr-head"><span style="font-weight:800; flex:1 1 180px; min-width:0;">${esc(name)}</span>${chips}</div>
          ${rows.map(r => `
            <div class="dr-row">
              <span style="font-weight:700;">${esc(r.team)}</span>
              <span style="opacity:0.75;">${esc(where(r))}</span>
              ${r.name !== name ? `<span style="opacity:0.75;">“${esc(r.name)}”</span>` : ''}
              ${r.dob ? `<span style="opacity:0.75;">${esc(this._c('row_dob', { dob: r.dob }, `born ${r.dob}`))}</span>` : ''}
              ${r.added ? `<span style="opacity:0.6;">${esc(this._c('row_added', { added: r.added }, `added ${r.added}`))}</span>` : ''}
            </div>`).join('')}
        </div>`;
    };
    const shown = (d.matches || []).filter(m => this._inView(m, this.view) && this._matchesSearch(m));

    const srcLine = (s) => {
      let text;
      if (!s.at) text = this._c('src_never', {}, 'not read yet');
      else if (s.read < s.teams) text = this._c('src_partial', { read: s.read, teams: s.teams, players: s.players, when: s.at }, `${s.read} of ${s.teams} teams read · ${s.players} players · oldest ${s.at}`);
      else text = this._c('src_ok', { teams: s.teams, players: s.players, when: s.at }, `${s.teams} teams · ${s.players} players · read ${s.at}`);
      const failed = s.ok === false ? `<span style="color:#f87171;">${esc(this._c('src_failed', { note: s.note || '' }, `⚠ last read failed: ${s.note || ''}`))}</span>` : '';
      return `<div class="dr-src"><span style="font-weight:700; min-width:220px;">${esc(s.label)}</span><span style="opacity:0.8;">${esc(text)}</span>${failed}</div>`;
    };
    const running = !!(d.sweep && d.sweep.running);
    const sources = `
      <details class="dr-card" style="margin-top:14px;">
        <summary style="cursor:pointer; font-weight:700;">${esc(this._c('sources', {}, 'Where the rosters come from'))}</summary>
        <div style="margin-top:6px;">
          ${(d.sources || []).map(srcLine).join('')}
          <div style="font-size:0.78rem; opacity:0.7; margin-top:6px;">${esc(this._c('not_read', {}, ''))}</div>
          <div style="margin-top:8px;"><button type="button" class="btn btn-secondary" data-dr-refresh ${running ? 'disabled' : ''}
               style="padding:4px 12px; font-size:0.8rem;">${esc(this._c('refresh', {}, '🔄 Read every roster again'))}</button></div>
        </div>
      </details>`;

    body.innerHTML = (shown.length ? shown.map(card).join('')
        : `<div style="opacity:0.7; padding:var(--space-4); text-align:center;">${esc(this._c('empty', {}, 'No name is on two teams here.'))}</div>`)
      + sources;
  }
}

window.DualRosteringScreen = DualRosteringScreen;
