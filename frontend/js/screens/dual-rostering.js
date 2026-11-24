// DualRosteringScreen — #dual-rostering (mig 1774; owner 2026-11-23: "we
// need vpn to scrape all apsl, casa … and the upsl … i need you to have a
// page to report dual or even tri rostering").
//
// Every name rostered on two or more teams across the league rosters we can
// read: APSL / CSL / ADASL team pages on TeamPass (through the scraper VPN)
// and CASA's public roster workbooks.  One card per name — its teams, the
// league of each, the date added and (where the league shows one) the birth
// date.  Pills: Different clubs (default) / Same club / 3+ teams / All; a
// search box narrows by name, team or league.  Under them (mig 1778, owner:
// "apsl pill then apsl confs. casa pill then casa confs … or all"): a row
// of league pills, then the chosen league's conferences, then the chosen
// conference's divisions — each row starts with All; a card shows when any
// of its teams is in the pick.  The fold at the bottom says
// where each roster came from and when it was read.
//
// The server re-reads the rosters when they are a day old (a sweep of ~200
// pages, a few minutes): the page shows LoadProgress and re-asks until it
// is done.  A name match is a lead, not proof — the chips say when birth
// dates agree or differ.
//
//   GET  /api/roster-watch            (RosterWatchController)
//   POST /api/roster-watch/refresh    read every roster again
//   POST /api/roster-watch/paste      a roster by paste (mig 1777 — UPSL: the
//                                     server cannot read upsl.com, so open the
//                                     team page, copy all, paste; the page
//                                     picks the names out for fixing first)
//   POST /api/roster-watch/paste/remove
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
    this.group = '';      // league pill ('' = all), then its conference, then its division
    this.sub = '';
    this.div = '';
    this._timer = null;
    this.pasteNote = null;   // the last save's answer, shown in the paste fold
    this.pasteOpen = false;
  }

  _c(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('roster_watch', tier))
      ? MessageCopy.block('roster_watch', tier, tokens || {}) : fb;
  }

  // Names out of a pasted league page.  The layout is the league's, so this
  // only proposes: every line that reads like a person's name (2–5 words of
  // letters, initials allowed), shirt numbers and appearance counts trimmed
  // off, after the page's "Roster" heading when it has one.  The viewer
  // fixes the list before it is saved.
  static namesFrom(text) {
    let lines = String(text || '').split(/\r?\n/).map(l => l.replace(/\s+/g, ' ').trim());
    const at = lines.findIndex(l => /^roster\b/i.test(l));
    if (at >= 0) lines = lines.slice(at + 1);
    const skip = /^(home|news|teams?|standings|schedule|schedules|results|stats|statistics|contact( us)?|about( us)?|privacy policy|terms.*|players?|coach(es)?|staff|goalkeepers?|defenders?|midfielders?|forwards?|strikers?|position|appearances|goals|assists|name|photo|all rights reserved.*|follow us.*|sign in|log ?in|register|search|menu|shop|sponsors?|partners?|match(es)?|fixtures|league table|head coach|assistant coach|team manager)$/i;
    const word = "[\\p{L}][\\p{L}.'’-]*";
    const name = new RegExp(`^${word}(?: ${word}){1,4}$`, 'u');
    const seen = new Set();
    const out = [];
    for (let l of lines) {
      l = l.replace(/^#?\d+[.)]?\s+/, '').replace(/(\s+\d+)+$/, '').trim();
      l = l.replace(/\s+(goalkeeper|defender|midfielder|forward|striker|gk|df|mf|fw)$/i, '').trim();
      if (!l || l.length > 40 || skip.test(l) || !name.test(l)) continue;
      if (l === l.toLowerCase()) continue;
      const key = l.toLowerCase();
      if (seen.has(key)) continue;
      seen.add(key);
      out.push(l);
    }
    return out;
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
      const g = e.target.closest('[data-dr-group]');
      if (g) { this.group = g.dataset.drGroup; this.sub = ''; this.div = ''; this._render(); return; }
      const sb = e.target.closest('[data-dr-sub]');
      if (sb) { this.sub = sb.dataset.drSub; this.div = ''; this._render(); return; }
      const dv = e.target.closest('[data-dr-div]');
      if (dv) { this.div = dv.dataset.drDiv; this._render(); return; }
      if (e.target.closest('[data-dr-refresh]')) { this._refresh(); return; }
      if (e.target.closest('[data-dr-paste-save]')) { this._savePaste(); return; }
      const rm = e.target.closest('[data-dr-paste-remove]');
      if (rm) { this._removePasted(Number(rm.dataset.drPasteRemove)); }
    });
    // The paste fold stays as the viewer left it across re-renders.
    this.element.addEventListener('toggle', (e) => {
      if (e.target.id === 'dr-paste-fold') this.pasteOpen = e.target.open;
    }, true);
    this.element.addEventListener('input', (e) => {
      if (e.target.id === 'dr-q') { this.q = e.target.value.trim().toLowerCase(); this._renderBody(); }
      if (e.target.id === 'dr-paste-raw') {
        const names = this.find('#dr-paste-names');
        if (names) names.value = DualRosteringScreen.namesFrom(e.target.value).join('\n');
        this._pasteCount();
      }
      if (e.target.id === 'dr-paste-names') this._pasteCount();
    });
  }

  _pasteNames() {
    const el = this.find('#dr-paste-names');
    return el ? el.value.split(/\r?\n/).map(l => l.replace(/\s+/g, ' ').trim()).filter(Boolean) : [];
  }
  _pasteCount() {
    const n = this._pasteNames().length;
    const label = this.find('#dr-paste-names-label');
    if (label) label.textContent = this._c('paste_names', { n }, `Names found (${n}) — one per line, fix before saving`);
    const btn = this.find('[data-dr-paste-save]');
    if (btn) { btn.textContent = this._c('paste_save', { n }, `Save ${n} players`); btn.disabled = !n; }
  }
  async _savePaste() {
    const team = ((this.find('#dr-paste-team') || {}).value || '').trim();
    const source = Number((this.find('#dr-paste-source') || {}).value || 0);
    const names = this._pasteNames();
    if (!team) { const t = this.find('#dr-paste-team'); if (t) t.focus(); return; }
    if (!source || !names.length) return;
    try {
      const res = await this.auth.fetch('/api/roster-watch/paste', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ source_id: source, team, names }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.pasteNote = { ok: true, text: this._c('paste_saved', { n: body.saved, team }, `✓ ${body.saved} players saved for ${team}`) };
    } catch (err) {
      console.error('[dual-rostering] paste failed:', err);
      this.pasteNote = { ok: false, text: err.message };
      this._pasteKeep = { team, raw: (this.find('#dr-paste-raw') || {}).value || '', names: names.join('\n') };
    }
    this.pasteOpen = true;
    this._load();
  }
  async _removePasted(teamId) {
    try {
      const res = await this.auth.fetch('/api/roster-watch/paste/remove', {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ team_id: teamId }),
      });
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      this.pasteNote = null;
    } catch (err) {
      console.error('[dual-rostering] remove failed:', err);
      this.pasteNote = { ok: false, text: err.message };
    }
    this.pasteOpen = true;
    this._load();
  }

  _inView(m, view) {
    if (view === 'cross') return m.clubs >= 2;
    if (view === 'same') return m.clubs < 2;
    if (view === 'tri') return m.teams >= 3;
    return true;
  }
  // Is one of the card's teams in the league / conference / division picked?
  _inLeague(m, group = this.group, sub = this.sub, div = this.div) {
    if (!group) return true;
    return (m.rows || []).some(r => r.group === group && (!sub || r.sub === sub) && (!div || r.division === div));
  }
  // The pill rows: every league, the picked league's conferences, the picked
  // conference's divisions (only when it has more than one), in the DB's order.
  _leaguePills(matches) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const inView = matches.filter(m => this._inView(m, this.view));
    const rows = inView.flatMap(m => m.rows || []);
    const uniq = (list, key, ord) => {
      const seen = new Map();
      list.forEach(r => { if (r[key] && !seen.has(r[key])) seen.set(r[key], ord(r)); });
      return [...seen.entries()].sort((a, b) => a[1] - b[1] || String(a[0]).localeCompare(String(b[0]))).map(x => x[0]);
    };
    const row = (attr, picked, allLabel, values, count, label = (v) => v) => `
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin:0 0 8px;">
        <button type="button" class="dr-pill ${picked === '' ? 'on' : ''}" ${attr}="">${esc(allLabel)} (${count('')})</button>
        ${values.map(v => `<button type="button" class="dr-pill ${picked === v ? 'on' : ''}" ${attr}="${esc(v)}">${esc(label(v))} (${count(v)})</button>`).join('')}
      </div>`;
    // "Delaware River Conference (Pennsylvania & New Jersey) - Group A" under Delaware River → "Group A".
    const short = (v) => {
      if (!String(v).startsWith(this.sub)) return v;
      const cut = v.lastIndexOf(' - ');
      const rest = cut >= 0 ? v.slice(cut + 3) : v.slice(this.sub.length).replace(/^\s*Conference\s*/, '').replace(/^[\s–-]+/, '');
      return rest.trim() || v;
    };
    const n = (g, s2, d2) => inView.filter(m => this._inLeague(m, g, s2, d2)).length;
    let html = row('data-dr-group', this.group, this._c('league_all', {}, 'All leagues'), uniq(rows, 'group', r => r.go), g => n(g, '', ''));
    if (this.group) {
      const inGroup = rows.filter(r => r.group === this.group);
      html += row('data-dr-sub', this.sub, this._c('sub_all', { league: this.group }, `All ${this.group}`), uniq(inGroup, 'sub', r => r.so), s2 => n(this.group, s2, ''));
      if (this.sub) {
        const divs = uniq(inGroup.filter(r => r.sub === this.sub), 'division', () => 0);
        if (divs.length > 1) html += row('data-dr-div', this.div, this._c('sub_all', { league: this.sub }, `All ${this.sub}`), divs, d2 => n(this.group, this.sub, d2), short);
      }
    }
    return html;
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
        ${views.map(([code, tier, fb]) => `<button type="button" class="dr-pill ${code === this.view ? 'on' : ''}" data-dr-view="${code}">${esc(this._c(tier, {}, fb))} (${matches.filter(m => this._inView(m, code) && this._inLeague(m)).length})</button>`).join('')}
      </div>
      <div style="${window.LoadProgress ? LoadProgress.dim(!!sweep.running) : ''}">${this._leaguePills(matches)}</div>`;
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
    const shown = (d.matches || []).filter(m => this._inView(m, this.view) && this._inLeague(m) && this._matchesSearch(m));

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

    const paste = d.paste || {};
    const field = 'width:100%; padding:8px 10px; border-radius:var(--radius-md); border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); font:inherit;';
    const pasteFold = (paste.sources || []).length ? `
      <details class="dr-card" id="dr-paste-fold" ${this.pasteOpen ? 'open' : ''}>
        <summary style="cursor:pointer; font-weight:700;">${esc(this._c('paste_fold', {}, '➕ Add a roster by paste'))}</summary>
        <div style="margin-top:6px; display:flex; flex-direction:column; gap:8px;">
          <div style="font-size:0.8rem; opacity:0.8;">${esc(this._c('paste_how', {}, 'Open the team page, copy all, paste below.'))}</div>
          ${this.pasteNote ? `<div style="font-weight:700; color:${this.pasteNote.ok ? '#4ade80' : '#f87171'};">${esc(this.pasteNote.text)}</div>` : ''}
          <div style="display:flex; gap:8px; flex-wrap:wrap;">
            <label style="flex:0 1 200px; font-size:0.78rem;">${esc(this._c('paste_league', {}, 'League'))}
              <select id="dr-paste-source" style="${field}">${paste.sources.map(x => `<option value="${Number(x.id)}">${esc(x.label)}</option>`).join('')}</select></label>
            <label style="flex:1 1 240px; font-size:0.78rem;">${esc(this._c('paste_team', {}, 'Team name'))}
              <input id="dr-paste-team" type="text" autocomplete="off" maxlength="120" style="${field}"></label>
          </div>
          <label style="font-size:0.78rem;">${esc(this._c('paste_raw', {}, 'Paste the team page here'))}
            <textarea id="dr-paste-raw" rows="4" style="${field}"></textarea></label>
          <label style="font-size:0.78rem;"><span id="dr-paste-names-label">${esc(this._c('paste_names', { n: 0 }, 'Names found (0)'))}</span>
            <textarea id="dr-paste-names" rows="10" style="${field}"></textarea></label>
          <div><button type="button" class="btn btn-primary" data-dr-paste-save disabled style="padding:6px 14px;">${esc(this._c('paste_save', { n: 0 }, 'Save 0 players'))}</button></div>
          ${(paste.teams || []).length ? `
            <div style="font-size:0.8rem; font-weight:700; margin-top:4px;">${esc(this._c('paste_teams', { n: paste.teams.length }, `Pasted so far (${paste.teams.length})`))}</div>
            ${paste.teams.map(t => `<div class="dr-src" style="align-items:center;">
                <span style="flex:1 1 240px;">${esc(this._c('paste_team_row', { team: t.team, n: t.n, when: t.when }, `${t.team} · ${t.n} players · ${t.when}`))} <span style="opacity:0.6;">· ${esc(t.league)}</span></span>
                <button type="button" class="btn btn-secondary" data-dr-paste-remove="${Number(t.id)}" style="padding:2px 10px; font-size:0.75rem;">${esc(this._c('paste_remove', {}, 'Remove'))}</button>
              </div>`).join('')}` : ''}
        </div>
      </details>` : '';
    // A re-render (the sweep's polling) must not wipe a paste in progress.
    const keep = this._pasteKeep || {
      team: (this.find('#dr-paste-team') || {}).value || '', raw: (this.find('#dr-paste-raw') || {}).value || '',
      names: (this.find('#dr-paste-names') || {}).value || '', source: (this.find('#dr-paste-source') || {}).value || '',
    };
    this._pasteKeep = null;
    const justSaved = this.pasteNote && this.pasteNote.ok && this._pasteShown !== this.pasteNote;
    if (justSaved) { keep.team = ''; keep.raw = ''; keep.names = ''; this._pasteShown = this.pasteNote; }

    body.innerHTML = pasteFold + (shown.length ? shown.map(card).join('')
        : `<div style="opacity:0.7; padding:var(--space-4); text-align:center;">${esc(this._c('empty', {}, 'No name is on two teams here.'))}</div>`)
      + sources;
    const put = (id, v) => { const el = this.find(id); if (el && v) el.value = v; };
    put('#dr-paste-team', keep.team); put('#dr-paste-raw', keep.raw); put('#dr-paste-names', keep.names); put('#dr-paste-source', keep.source);
    this._pasteCount();
  }
}

window.DualRosteringScreen = DualRosteringScreen;
