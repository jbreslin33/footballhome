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
// conference's divisions — each row starts with All.  Pills toggle, several
// can be on: the pick centres the query — every name with a team in a
// picked league shows with all its teams (UPSL included), several pills =
// any of them; the picked league's lines are highlighted on each card.
// 👤 By player / 🏟 By club (mig 1784, owner: "order by clubs with most guys
// from other clubs"): By club folds the same cards under each club, the club
// with the most names first.  The fold at the bottom says
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
    this.groups = [];     // league pills on (none = all); per league its conferences; per conference its divisions
    this.subs = {};       // league → [conference, …]
    this.divs = {};       // 'league|conference' → [division, …]
    this._timer = null;
    this.pasteNote = null;   // the last save's answer, shown in the paste fold
    this.pasteOpen = false;
    this.by = 'player';   // 'player' = one card per name; 'club' = folded under each club, most shared players first
    this.clubOpen = new Set();
  }

  _c(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('roster_watch', tier))
      ? MessageCopy.block('roster_watch', tier, tokens || {}) : fb;
  }

  // A saved UPSL team page (mig 1780) → {team, division, players: [{name, apps}]}.
  // The league's markup: .single-team__roster-player blocks under the
  // "Roster N" heading (staff sit under "Staff" with the title Coach / Admin),
  // each with first<br>last, a position and data-appearences; the header has
  // the team (h1) and its conference (.page__header--conference).
  static fromSavedPage(html) {
    const doc = new DOMParser().parseFromString(String(html || ''), 'text/html');
    const text = (el) => (el ? el.textContent : '').replace(/\s+/g, ' ').trim();
    const heading = [...doc.querySelectorAll('.single-team__heading')].find(h => /^\s*roster/i.test(h.textContent));
    let blocks = heading && heading.nextElementSibling ? [...heading.nextElementSibling.querySelectorAll('.single-team__roster-player')] : [];
    if (!blocks.length) blocks = [...doc.querySelectorAll('.single-team__roster-player')];
    const players = [];
    blocks.forEach(b => {
      const nameEl = b.querySelector('.single-team__roster-player-name');
      if (!nameEl) return;
      if (/^(coach|admin|manager|staff)$/i.test(text(b.querySelector('.single-team__roster-player-title')))) return;
      const copy = nameEl.cloneNode(true);
      copy.querySelectorAll('br').forEach(br => br.replaceWith(' '));
      const name = text(copy);
      const apps = parseInt(b.getAttribute('data-appearences') || b.getAttribute('data-appearances') || '', 10);
      if (name) players.push(Number.isFinite(apps) ? { name, apps } : { name });
    });
    const team = text(doc.querySelector('.page__header--team-name-wrapper h1') || doc.querySelector('h1'))
      || text(doc.querySelector('title')).replace(/-\d+\s*-.*$/, '').trim();
    return { team, division: text(doc.querySelector('.page__header--conference')), players };
  }

  // Names out of a team page copied as text (Ctrl+A, Ctrl+C).  A UPSL page
  // reads, after its "Roster N" heading, one player over several lines:
  // first name / last name / position / "Appearances: N" (the last two not
  // always there).  Any other page: every line that reads like a full name.
  // Either way this only proposes — the viewer fixes the list before saving.
  static namesFrom(text) {
    let lines = String(text || '').split(/\r?\n/).map(l => l.replace(/\s+/g, ' ').trim()).filter(Boolean);
    const at = lines.findIndex(l => /^roster\b/i.test(l));
    if (at >= 0) lines = lines.slice(at + 1);
    const position = /^(forward|midfield(er)?|defen[sc]e|defender|goalkeeper|striker)$/i;
    const stop = /^(top scorers|staff|schedule|results|standings|news|menu|home|about|socials|teams)$/i;   // what follows the roster: other sections, the footer menu
    const word = /^[\p{L}][\p{L}.'’ -]*$/u;
    const out = [];
    const seen = new Set();
    const add = (n) => { const k = n.toLowerCase(); if (n && !seen.has(k)) { seen.add(k); out.push(n); } };
    if (at >= 0 && lines.some(l => position.test(l) || /^appearances:/i.test(l))) {
      let buf = [];
      const flush = () => { if (buf.length) add(buf.join(' ')); buf = []; };
      for (const l of lines) {
        if (stop.test(l)) break;
        if (/^appearances:/i.test(l) || position.test(l)) { flush(); continue; }
        if (!word.test(l) || l.length > 40) { flush(); continue; }
        if (buf.length >= 2) flush();   // a player with no position shown
        buf.push(l);
      }
      flush();
      return out;
    }
    const full = /^[\p{L}][\p{L}.'’-]*(?: [\p{L}][\p{L}.'’-]*){1,4}$/u;
    const skip = /^(home|news|teams?|standings|schedule|schedules|results|stats|statistics|contact( us)?|about( us)?|privacy policy|terms.*|players?|coach(es)?|staff|position|appearances|goals|assists|name|photo|all rights reserved.*|follow us.*|sign in|log ?in|register|search|menu|shop|sponsors?|partners?|match(es)?|fixtures|league table|head coach|assistant coach|team manager|top scorers|player registration|new team membership)$/i;
    for (let l of lines) {
      l = l.replace(/^#?\d+[.)]?\s+/, '').replace(/(\s+\d+)+$/, '').trim();
      if (!l || l.length > 40 || skip.test(l) || position.test(l) || !full.test(l) || l === l.toLowerCase()) continue;
      add(l);
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
        .dr-row.picked { background:rgba(59,130,246,0.16); box-shadow:inset 3px 0 0 var(--primary-color); border-radius:4px; padding-left:8px; }
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
      const by = e.target.closest('[data-dr-by]');
      if (by) { this.by = by.dataset.drBy; this._render(); return; }
      const pick = e.target.closest('[data-dr-pick]');
      if (pick) {
        const v = pick.dataset.drV, g = pick.dataset.drG, kind = pick.dataset.drPick;
        if (kind === 'group') {
          if (!v) { this.groups = []; this.subs = {}; this.divs = {}; }
          else {
            this._toggle(this.groups, v);
            if (!this.groups.includes(v)) { delete this.subs[v]; Object.keys(this.divs).filter(k => k.startsWith(v + '|')).forEach(k => delete this.divs[k]); }
          }
        } else if (kind === 'sub') {
          if (!v) this.subs[g] = []; else this._toggle(this.subs[g] = this.subs[g] || [], v);
          Object.keys(this.divs).filter(k => k.startsWith(g + '|')).forEach(k => delete this.divs[k]);
        } else {
          const key = g + '|' + pick.dataset.drS;
          if (!v) this.divs[key] = []; else this._toggle(this.divs[key] = this.divs[key] || [], v);
        }
        this._render();
        return;
      }
      if (e.target.closest('[data-dr-refresh]')) { this._refresh(); return; }
      if (e.target.closest('[data-dr-paste-save]')) { this._savePaste(); return; }
      const rm = e.target.closest('[data-dr-paste-remove]');
      if (rm) { this._removePasted(Number(rm.dataset.drPasteRemove)); }
    });
    this.element.addEventListener('change', (e) => {
      if (e.target.id === 'dr-paste-files' && e.target.files && e.target.files.length) this._saveFiles([...e.target.files]);
    });
    // The paste fold stays as the viewer left it across re-renders.
    this.element.addEventListener('toggle', (e) => {
      if (e.target.id === 'dr-paste-fold') this.pasteOpen = e.target.open;
      if (e.target.id === 'dr-paste-hand') this.handOpen = e.target.open;
      const club = e.target.dataset && e.target.dataset.drClub;
      if (club != null) { if (e.target.open) this.clubOpen.add(club); else this.clubOpen.delete(club); }
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
  // Saved team pages, many at once: each is read here and saved as its team.
  async _saveFiles(files) {
    const source = Number((this.find('#dr-paste-source') || {}).value || 0);
    if (!source) return;
    let teams = 0, players = 0;
    const bad = [];
    for (const f of files) {
      try {
        const page = DualRosteringScreen.fromSavedPage(await f.text());
        if (!page.team || !page.players.length) { bad.push(f.name); continue; }
        const res = await this.auth.fetch('/api/roster-watch/paste', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ source_id: source, team: page.team, division: page.division, names: page.players }),
        });
        const body = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
        teams++; players += Number(body.saved) || 0;
      } catch (err) {
        console.error('[dual-rostering] file failed:', f.name, err);
        bad.push(f.name);
      }
    }
    const done = this._c('files_done', { teams, players }, `✓ ${teams} teams saved · ${players} players`);
    const missed = bad.length ? ' ' + this._c('files_bad', { names: bad.join(', ') }, `⚠ no roster found in: ${bad.join(', ')}`) : '';
    this.pasteNote = { ok: !bad.length, text: done + missed };
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
  // The league pills are the pick (owner 11/23: "the pills should be the one
  // to highlight and find matches with that one. but allow for clicking more
  // than one. but if we click apsl but not upsl it should show if apsl guy is
  // upsl" · "its just a way to center the query").  A pill toggles; none on
  // = everything.  The pick is the centre of the query: every name with a
  // team in a picked league (or its picked conferences / divisions) shows,
  // with ALL its teams — so APSL alone still shows the APSL man who is also
  // UPSL.  Several pills = any of them.  The picked teams are the
  // highlighted lines on each card; the search box narrows further ("UPSL").
  _rowIn(r, g) {
    if (r.group !== g) return false;
    const subs = this.subs[g] || [];
    if (subs.length && !subs.includes(r.sub)) return false;
    const divs = this.divs[g + '|' + r.sub] || [];
    return !divs.length || divs.includes(r.division);
  }
  _rowPicked(r) { return this.groups.some(g => this._rowIn(r, g)); }
  _inLeague(m) { return !this.groups.length || (m.rows || []).some(r => this._rowPicked(r)); }
  _toggle(list, v) { const i = list.indexOf(v); if (i >= 0) list.splice(i, 1); else list.push(v); }

  // The pill rows: every league; under it, per league picked, its
  // conferences; under a league with exactly one conference picked, that
  // conference's divisions (when it has more than one) — in the DB's order.
  _leaguePills(matches) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const inView = matches.filter(m => this._inView(m, this.view));
    const rows = inView.flatMap(m => m.rows || []);
    const uniq = (list, key, ord) => {
      const seen = new Map();
      list.forEach(r => { if (r[key] && !seen.has(r[key])) seen.set(r[key], ord(r)); });
      return [...seen.entries()].sort((a, b) => a[1] - b[1] || String(a[0]).localeCompare(String(b[0]))).map(x => x[0]);
    };
    const count = (test) => inView.filter(m => (m.rows || []).some(test)).length;
    const row = (attrs, picked, allLabel, values, n, label = (v) => v) => `
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin:0 0 8px;">
        <button type="button" class="dr-pill ${picked.length ? '' : 'on'}" ${attrs} data-dr-v="">${esc(allLabel)}</button>
        ${values.map(v => `<button type="button" class="dr-pill ${picked.includes(v) ? 'on' : ''}" ${attrs} data-dr-v="${esc(v)}">${esc(label(v))} (${n(v)})</button>`).join('')}
      </div>`;
    const groups = uniq(rows, 'group', r => r.go);
    let html = row('data-dr-pick="group"', this.groups, this._c('league_all', {}, 'All leagues'), groups, g => count(r => r.group === g));
    groups.filter(g => this.groups.includes(g)).forEach(g => {
      const inGroup = rows.filter(r => r.group === g);
      const subs = this.subs[g] || [];
      html += row(`data-dr-pick="sub" data-dr-g="${esc(g)}"`, subs, this._c('sub_all', { league: g }, `All ${g}`),
                  uniq(inGroup, 'sub', r => r.so), s => count(r => r.group === g && r.sub === s));
      if (subs.length !== 1) return;
      const sub = subs[0];
      const divs = uniq(inGroup.filter(r => r.sub === sub), 'division', () => 0);
      if (divs.length < 2) return;
      // "Delaware River Conference (Pennsylvania & New Jersey) - Group A" under Delaware River → "Group A".
      const short = (v) => {
        if (!String(v).startsWith(sub)) return v;
        const cut = v.lastIndexOf(' - ');
        const rest = cut >= 0 ? v.slice(cut + 3) : v.slice(sub.length).replace(/^\s*Conference\s*/, '').replace(/^[\s–-]+/, '');
        return rest.trim() || v;
      };
      html += row(`data-dr-pick="div" data-dr-g="${esc(g)}" data-dr-s="${esc(sub)}"`, this.divs[g + '|' + sub] || [],
                  this._c('sub_all', { league: sub }, `All ${sub}`), divs, d => count(r => r.group === g && r.sub === sub && r.division === d), short);
    });
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
      <div style="${window.LoadProgress ? LoadProgress.dim(!!sweep.running) : ''}">${this._leaguePills(matches)}</div>
      <div style="display:flex; gap:6px; flex-wrap:wrap; margin:0 0 8px;">
        ${[['player', 'by_player', '👤 By player'], ['club', 'by_club', '🏟 By club']].map(([code, tier, fb]) =>
          `<button type="button" class="dr-pill ${code === this.by ? 'on' : ''}" data-dr-by="${code}">${esc(this._c(tier, {}, fb))}</button>`).join('')}
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
            <div class="dr-row ${this._rowPicked(r) ? 'picked' : ''}">
              <span style="font-weight:700;">${esc(r.team)}</span>
              <span style="opacity:0.75;">${esc(where(r))}</span>
              ${r.name !== name ? `<span style="opacity:0.75;">“${esc(r.name)}”</span>` : ''}
              ${r.dob ? `<span style="opacity:0.75;">${esc(this._c('row_dob', { dob: r.dob }, `born ${r.dob}`))}</span>` : ''}
              ${r.apps != null ? `<span style="opacity:0.75;">${esc(this._c('row_apps', { n: r.apps }, `${r.apps} appearances`))}</span>` : ''}
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
          <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:flex-end;">
            <label style="flex:0 1 200px; font-size:0.78rem;">${esc(this._c('paste_league', {}, 'League'))}
              <select id="dr-paste-source" style="${field}">${paste.sources.map(x => `<option value="${Number(x.id)}">${esc(x.label)}</option>`).join('')}</select></label>
            <label style="flex:1 1 300px; font-size:0.78rem;">${esc(this._c('files_label', {}, 'Saved team pages'))}
              <input id="dr-paste-files" type="file" accept=".html,.htm,text/html" multiple style="${field}"></label>
          </div>
          <details ${this.handOpen ? 'open' : ''} id="dr-paste-hand">
            <summary style="cursor:pointer; font-size:0.8rem; opacity:0.85;">${esc(this._c('files_or', {}, 'Or one team by hand:'))}</summary>
            <div style="display:flex; flex-direction:column; gap:8px; margin-top:6px;">
          <div style="display:flex; gap:8px; flex-wrap:wrap;">
            <label style="flex:1 1 240px; font-size:0.78rem;">${esc(this._c('paste_team', {}, 'Team name'))}
              <input id="dr-paste-team" type="text" autocomplete="off" maxlength="120" style="${field}"></label>
          </div>
          <label style="font-size:0.78rem;">${esc(this._c('paste_raw', {}, 'Paste the team page here'))}
            <textarea id="dr-paste-raw" rows="4" style="${field}"></textarea></label>
          <label style="font-size:0.78rem;"><span id="dr-paste-names-label">${esc(this._c('paste_names', { n: 0 }, 'Names found (0)'))}</span>
            <textarea id="dr-paste-names" rows="10" style="${field}"></textarea></label>
          <div><button type="button" class="btn btn-primary" data-dr-paste-save disabled style="padding:6px 14px;">${esc(this._c('paste_save', { n: 0 }, 'Save 0 players'))}</button></div>
            </div>
          </details>
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

    // By club (mig 1784): the same cards folded under each club, the club
    // with the most names first.  With league pills on, only the clubs of
    // the picked teams get a fold; a name sits under each of its clubs.
    const byClub = () => {
      const clubs = new Map();
      shown.forEach(m => {
        const mine = (m.rows || []).filter(r => !this.groups.length || this._rowPicked(r));
        [...new Set(mine.map(r => r.club || r.team))].forEach(c => {
          if (!clubs.has(c)) clubs.set(c, { cards: [], teams: new Set() });
          clubs.get(c).cards.push(m);
          mine.filter(r => (r.club || r.team) === c).forEach(r => clubs.get(c).teams.add(r.team));
        });
      });
      const tier = this.view === 'cross' ? 'club_count' : 'club_count_all';
      return [...clubs.entries()].sort((a, b) => b[1].cards.length - a[1].cards.length || a[0].localeCompare(b[0])).map(([c, x]) => `
        <details class="dr-card" data-dr-club="${esc(c)}" ${this.clubOpen.has(c) ? 'open' : ''}>
          <summary style="cursor:pointer; display:flex; flex-wrap:wrap; gap:6px; align-items:center;">
            <span style="font-weight:800; font-size:1.05rem; min-width:2ch;">${x.cards.length}</span>
            <span style="font-weight:800; flex:1 1 200px; min-width:0;">${esc(c)}</span>
            <span style="font-size:0.78rem; opacity:0.7;">${esc([...x.teams].filter(t => t !== c).join(' · '))}</span>
            ${chip(this._c(tier, { n: x.cards.length }, `${x.cards.length} also at another club`), 'background:rgba(251,191,36,0.2); color:#fbbf24;')}
          </summary>
          <div style="margin-top:8px;">${x.cards.map(card).join('')}</div>
        </details>`).join('');
    };
    body.innerHTML = pasteFold + (shown.length ? (this.by === 'club' ? byClub() : shown.map(card).join(''))
        : `<div style="opacity:0.7; padding:var(--space-4); text-align:center;">${esc(this._c('empty', {}, 'No name is on two teams here.'))}</div>`)
      + sources;
    const put = (id, v) => { const el = this.find(id); if (el && v) el.value = v; };
    put('#dr-paste-team', keep.team); put('#dr-paste-raw', keep.raw); put('#dr-paste-names', keep.names); put('#dr-paste-source', keep.source);
    this._pasteCount();
  }
}

window.DualRosteringScreen = DualRosteringScreen;
