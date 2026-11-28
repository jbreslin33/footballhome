// FootballTaxonomyScreen — #football-taxonomy — ⚽ Football → 🧬 Taxonomy (mig 1810).
//
// Owner 2026-11-24: "show me first the entire taxonomy of football we currently have in db
// and c++ … this should be on a page in footballhome … under football menu".  And why: "we
// need the engine to be aware of all of 'football' and its concepts right? it doesn't mean
// u use it all?"  So this is a reference page with one question per concept — how far does
// it reach?
//
//   📚 named        a game_concepts row
//   🏷 a board job   a tactic_job_kinds row placed by rule 'home' (he keeps his spot)
//   📐 placed       a job with geometry (shared/tactics/TacticGeometry.hpp)
//   ⚙️ played       the game engine runs it by itself (game_engine_acts)
//
// Tabs: 🧠 Concepts (moment → principle → concept) · 🦶 Techniques (the tree) ·
// 📏 Roles, measures, Laws, placement rules · ⚙️ Engine.  Read-only.
//
// ONE system (owner 11/24: "we need them synced taxonomy and engine. also the taxonomy page
// should show the db entry and the c++ class should be viewable with hyperlink to parent
// classes" · "this is a holistic system that feeds off each other"; mig 1812):
//   • tap a concept → its whole database row, what it refines / requires, its board jobs
//     (with the placement class), and every engine behaviour that plays it;
//   • ⚙️ Engine lists every behaviour the engine has (game_engine_behaviours): linked to a
//     concept, real football with no name yet, or a fudge — and what the engine READS;
//   • tap a class name anywhere → the C++ class: its parents (each a link), its children,
//     its comment, the behaviours in it, and the source itself
//     (game_engine_classes / game_engine_sources, refreshed by the backend TaxonomySync on load).
//
// WHERE it lives, on every concept card (owner 11/24: "i need on each concept card wherther
// icons for if used in game, db, engine" · "clicking each one takes you to pertiientn info.
// c++ icon for code right? should take me to code with links to parent and childs"; mig 1827)
// — three chips, lit or dim, the three layers of docs/taxonomy-one-system.md:
//   🗄 DB     the catalogue row                       → the database sheet (owner: "db icon
//             should show me talbe and relationships and normalzation"): the game_concepts
//             table with its key and foreign keys, this row, the rows it points to, and
//             every table that points at it with its rows — GET /taxonomy/db?concept=,
//             read from the Postgres catalogue, so a new table shows by itself
//   🎮 Game   the engine plays it in a match          → the game sheet (owner: "engine
//             ashould talk about and demo how its used … show the players moving and
//             demonstrating the concept in a popup game on a loop" · "the popup game shold
//             run the engine full"): what the engine does with it, and ▶ a popup window on
//             the concept clip viewer (/concept.html?concept=<id>, js/teach/concept.js)
//             that replays each moment a player does it.  The popup asks this page for its
//             words (loop_* rows) by postMessage.
//   ⚙️ C++    there is code for it — a behaviour's class or its board placement class
//                                                     → the class sheet: parents, children, source
// GET /api/tactic-plans/taxonomy (one fetch) + /taxonomy/source for the code.
// Every word is message_templates kind 'taxonomy'; the content is the tables' own.
class FootballTaxonomyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.error = false;
    this.tab = 'principles';
    this.moment = '';       // '' = every moment
    this.reach = 'all';     // all | played | placed | job | named
    this.kind = '';         // '' | behaviour | style | call (game_concepts.kind, mig 5026/5029)
    this.view = 'sections'; // sections | machines (game_machines, mig 5038)
    this.search = '';
    this.plevel = 'all';    // 📜 Principles: all | general | operational | fundamental | sub | federations
    this.engine = 'all';    // ⚙️ Engine list: all | concept | unnamed | fudge | read | classes
    this.detail = null;     // { type: 'concept' | 'behaviour' | 'class', key } — the open sheet
    this.trail = [];        // sheets behind it (‹ Back)
    this.sourceCache = new Map();
  }

  _t(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('taxonomy', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .tx-wrap { padding: var(--space-4); max-width: 1100px; margin: 0 auto; }
        .tx-pills { display:flex; flex-wrap:wrap; gap:6px; margin: 8px 0; }
        .tx-pill { padding:5px 12px; border-radius:999px; cursor:pointer; font-weight:700; font-size:0.8rem; min-height:0; min-width:0;
                   border:1px solid var(--border-color); background:transparent; color:var(--text-primary); }
        .tx-pill.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .tx-pill .n { opacity:0.7; font-weight:600; margin-left:4px; }
        .tx-search { width:100%; max-width:340px; padding:6px 10px; border-radius:8px; border:1px solid var(--border-color);
                     background:var(--bg-secondary); color:var(--text-primary); font-size:0.85rem; }
        .tx-moment { margin: 18px 0 4px; font-size:1.05rem; font-weight:800; }
        .tx-principle { margin: 12px 0 4px; font-size:0.78rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.75; }
        .tx-grid { display:grid; gap:6px; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); }
        .tx-card { border:1px solid var(--border-color); border-left-width:4px; border-radius:var(--radius-md); background:var(--bg-secondary); padding:8px 10px; }
        .tx-card[data-reach="played"] { border-left-color:#22c55e; }
        .tx-card[data-reach="placed"] { border-left-color:#0ea5e9; }
        .tx-card[data-reach="job"]    { border-left-color:#f59e0b; }
        .tx-card[data-reach="named"]  { border-left-color:var(--border-color); }
        /* The legend: the same colours as dots on the reach pills. */
        .tx-dot { display:inline-block; width:10px; height:10px; border-radius:50%; margin-right:6px; vertical-align:baseline; border:1px solid var(--border-color); }
        .tx-dot[data-reach="played"] { background:#22c55e; border-color:#22c55e; }
        .tx-dot[data-reach="placed"] { background:#0ea5e9; border-color:#0ea5e9; }
        .tx-dot[data-reach="job"]    { background:#f59e0b; border-color:#f59e0b; }
        .tx-legend { font-size:0.78rem; opacity:0.75; margin: 10px 0 -2px; }
        .tx-title { font-weight:700; font-size:0.9rem; }
        .tx-meta { font-size:0.72rem; opacity:0.75; margin-top:2px; }
        .tx-cue { font-size:0.8rem; margin-top:4px; opacity:0.9; }
        .tx-line { font-size:0.74rem; margin-top:4px; }
        .tx-h { margin: 18px 0 6px; font-size:0.95rem; font-weight:800; }
        .tx-list { margin:0; padding-left: 18px; font-size:0.85rem; line-height:1.55; }
        .tx-list ul { padding-left: 18px; }
        .tx-dim { opacity:0.7; }
        .tx-card { cursor:pointer; }
        .tx-link { color:#38bdf8; cursor:pointer; text-decoration:underline; text-underline-offset:2px; background:none; border:0; padding:0; font:inherit; min-height:0; min-width:0; }
        .tx-code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size:0.78rem; }
        .tx-row { border:1px solid var(--border-color); border-left-width:4px; border-radius:var(--radius-md); background:var(--bg-secondary); padding:7px 10px; margin:5px 0; cursor:pointer; }
        .tx-row[data-status="concept"] { border-left-color:#22c55e; }
        .tx-row[data-status="unnamed"] { border-left-color:#f43f5e; }
        .tx-row[data-status="fudge"]   { border-left-color:#a855f7; }
        .tx-dot[data-reach="unnamed"] { background:#f43f5e; border-color:#f43f5e; }
        .tx-dot[data-reach="fudge"]   { background:#a855f7; border-color:#a855f7; }
        .tx-dot[data-reach="concept"] { background:#22c55e; border-color:#22c55e; }
        .tx-sheet-back { position:fixed; inset:0; background:rgba(0,0,0,0.55); z-index:900; }
        .tx-sheet { position:fixed; top:0; right:0; bottom:0; width:min(760px, 100vw); z-index:901; overflow:auto;
                    background:var(--bg-primary, #0f172a); border-left:1px solid var(--border-color); padding:14px 16px 40px; }
        .tx-sheet h3 { margin:0 0 2px; font-size:1.1rem; }
        .tx-sheet h4 { margin:16px 0 4px; font-size:0.74rem; letter-spacing:0.07em; text-transform:uppercase; opacity:0.75; }
        .tx-kv { display:grid; grid-template-columns: 130px 1fr; gap:3px 10px; font-size:0.84rem; }
        .tx-kv dt { opacity:0.7; } .tx-kv dd { margin:0; }
        .tx-src { margin:6px 0 0; padding:10px; border-radius:8px; background:#0b1220; color:#e2e8f0; overflow:auto; max-height:60vh;
                  font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size:0.74rem; line-height:1.45; white-space:pre; }
        .tx-src .ln { display:inline-block; width:3.2em; margin-right:10px; text-align:right; opacity:0.45; user-select:none; }
        .tx-src .hit { background:rgba(250,204,21,0.18); display:inline-block; min-width:100%; }
        .tx-crumb { font-size:0.9rem; margin:6px 0; }
        .tx-tbl { border-collapse:collapse; font-size:0.78rem; width:100%; margin:4px 0 2px; }
        .tx-tbl th { text-align:left; opacity:0.65; font-weight:600; padding:2px 8px 2px 0; white-space:nowrap; }
        .tx-tbl td { padding:3px 8px 3px 0; border-top:1px solid var(--border-color); vertical-align:top; overflow-wrap:anywhere; }
        .tx-tbl td.tx-code { white-space:nowrap; overflow-wrap:normal; }
        .tx-tname { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-weight:700; font-size:0.86rem; margin-top:10px; }
        .tx-scroll { overflow-x:auto; }
        .tx-where { display:flex; gap:5px; margin-top:6px; }
        .tx-chip { padding:2px 8px; border-radius:6px; font-size:0.7rem; font-weight:700; line-height:1.5; min-height:0; min-width:0;
                   border:1px solid var(--border-color); background:transparent; color:var(--text-primary); }
        .tx-chip.on { cursor:pointer; border-color:#38bdf8; background:rgba(56,189,248,0.12); }
        .tx-chip.off { opacity:0.3; filter:grayscale(1); }
        .tx-chip.half { cursor:pointer; border:1px dashed #f59e0b; background:rgba(245,158,11,0.10); opacity:0.85; }
        .tx-card[data-reach="engine"] { border-left-color:#f43f5e; }
        .tx-card[data-reach="fudge"]  { border-left-color:#a855f7; }
        .tx-dot[data-reach="engine"] { background:#f43f5e; border-color:#f43f5e; }
        .tx-sync { margin:10px 0 2px; padding:8px 10px; border:1px solid var(--border-color); border-radius:var(--radius-md); font-size:0.8rem; display:flex; flex-wrap:wrap; gap:6px 12px; align-items:center; }
        .tx-sync.bad { border-color:#f43f5e; background:rgba(244,63,94,0.08); }
        .tx-sync .d { flex-basis:100%; }
      </style>
      <div class="tx-wrap" id="tx-body"></div>
      <div id="tx-detail"></div>`;
    this.element = div;
    div.addEventListener('click', (e) => {
      const open = e.target.closest('[data-tx-open]');
      if (open) { e.stopPropagation(); this._open(open.dataset.txOpen, open.dataset.k, open.dataset.sec); return; }
      const b = e.target.closest('[data-tx]');
      if (!b) return;
      const [k, v] = [b.dataset.tx, b.dataset.v];
      if (k === 'sync') { this._syncNow(); return; }
      if (k === 'close') { this.detail = null; this.trail = []; this._renderDetail(); return; }
      if (k === 'watch') { this._watch(Number(v)); return; }
      if (k === 'back') { this.detail = this.trail.pop() || null; this._renderDetail(); return; }
      if (k === 'verdict') { this._verdict(b.dataset.code, v); return; }
      if (k === 'tab') this.tab = v;
      else if (k === 'plevel') this.plevel = v;
      else if (k === 'moment') this.moment = v;
      else if (k === 'reach') this.reach = v;
      else if (k === 'kind') this.kind = v;
      else if (k === 'view') this.view = v;
      else if (k === 'engine') this.engine = v;
      this._render();
    });
    div.addEventListener('input', (e) => {
      if (!e.target.matches('[data-tx-search]')) return;
      this.search = e.target.value;
      this._renderConceptList();
    });
    return div;
  }

  onEnter() {
    this._render();
    const copy = window.MessageCopy ? MessageCopy.load(this.auth).catch(() => {}) : Promise.resolve();
    // Every visit reads it again, and every read checks the engine's C++ against the database
    // first (backend TaxonomySync) — the sync line says when.
    Promise.all([copy, this._load()]).then(() => this._render());
  }

  async _load() {
    this.error = false;
    try {
      const res = await this.auth.fetch('/api/tactic-plans/taxonomy');
      if (!res.ok) throw new Error('HTTP ' + res.status);
      this.data = await res.json();
    } catch (_) { this.error = true; }
  }

  // ── lookups over the one payload ───────────────────────────────────────
  _index() {
    if (this._ix && this._ix.d === this.data) return this._ix;
    const d = this.data, ix = { d, concept: new Map(), byName: new Map(), cls: new Map(), kids: new Map(), behOf: new Map(), behIn: new Map(), beh: new Map() };
    for (const c of d.concepts || []) { ix.concept.set(c.id, c); ix.byName.set(c.name, c); }
    for (const k of d.classes || []) {
      if (!ix.cls.has(k.name)) ix.cls.set(k.name, k);
      if (k.parent) { if (!ix.kids.has(k.parent)) ix.kids.set(k.parent, []); ix.kids.get(k.parent).push(k.name); }
    }
    for (const b of d.behaviours || []) {
      ix.beh.set(b.code, b);
      if (b.concept_id != null) { if (!ix.behOf.has(b.concept_id)) ix.behOf.set(b.concept_id, []); ix.behOf.get(b.concept_id).push(b); }
      if (b.class) { if (!ix.behIn.has(b.class)) ix.behIn.set(b.class, []); ix.behIn.get(b.class).push(b); }
    }
    this._ix = ix;
    return ix;
  }
  // The placement class behind a board rule: cover_shadow → CoverShadowRule (shared/tactics/TacticGeometry.hpp).
  _ruleClass(rule) { return String(rule || '').split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join('') + 'Rule'; }

  // sec = the sheet section to land on ('behaviours' | 'classes').
  _open(type, key, sec) {
    if (this.detail) this.trail.push({ type: this.detail.type, key: this.detail.key });
    this.detail = { type, key, sec };
    this._renderDetail();
  }

  // Where a concept lives → { game: [behaviours that play it], classes: [C++ class names] }.
  // The classes are its behaviours' own and the placement class of its board jobs.
  _where(c) {
    const ix = this._index(), game = ix.behOf.get(c.id) || [], classes = [];
    const add = (n) => { if (n && ix.cls.has(n) && !classes.includes(n)) classes.push(n); };
    for (const b of game) add(b.class);
    for (const j of this.data.jobs || []) if (j.concept_id === c.id && j.rule && j.rule !== 'home') add(this._ruleClass(j.rule));
    // played = the sim itself runs it; built = there is engine code no side uses yet.
    const inSim = game.some(b => b.in_sim !== false) || !!c.act;
    return { game, classes, played: inSim, built: !inSim && game.length > 0 };
  }

  // The three chips: 🗄 DB · 🎮 Game · ⚙️ C++ — lit ones go to their own place.
  _whereHtml(c, esc) {
    const w = this._where(c);
    const chip = (tier, on, attrs) => on
      ? `<button type="button" class="tx-chip on" title="${esc(this._t(tier + '_tip'))}" ${attrs}>${esc(this._t(tier))}</button>`
      : `<span class="tx-chip off" title="${esc(this._t(tier + '_no'))}">${esc(this._t(tier))}</span>`;
    const game = `data-tx-open="game" data-k="${c.id}"`;
    // code with no class of its own (a free function) → the behaviour, which shows its source
    const code = w.classes.length === 1 ? `data-tx-open="class" data-k="${esc(w.classes[0])}"`
      : w.classes.length ? `data-tx-open="concept" data-k="${c.id}" data-sec="classes"`
      : w.game.length === 1 ? `data-tx-open="behaviour" data-k="${esc(w.game[0].code)}"` : `data-tx-open="concept" data-k="${c.id}" data-sec="behaviours"`;
    const gameChip = w.built
      ? `<button type="button" class="tx-chip half" title="${esc(this._t('where_game_built'))}" ${game}>${esc(this._t('where_game'))}</button>`
      : chip('where_game', w.played, game);
    return `<div class="tx-where">${chip('where_db', true, `data-tx-open="db" data-k="${c.id}"`)}${gameChip}${chip('where_code', w.classes.length > 0 || w.game.length > 0, code)}</div>`;
  }

  // How far a concept reaches.
  _reach(c) {
    if (c.act || (this._index().behOf.get(c.id) || []).length) return 'played';
    if (c.rule && c.rule !== 'home') return 'placed';
    if (c.job) return 'job';
    return 'named';
  }

  _render() {
    const el = this.find('#tx-body');
    if (!el) return;
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const head = `<h2 style="margin:0;">${esc(this._t('title'))}</h2>
      <div class="tx-dim" style="font-size:0.85rem; margin-top:4px; max-width:75ch;">${esc(this._t('intro'))}</div>`;
    if (this.error && !this.data) { el.innerHTML = head + `<p>${esc(this._t('failed'))}</p>`; return; }
    if (!this.data) { el.innerHTML = head + `<p class="tx-dim">${esc(this._t('loading'))}</p>`; return; }
    const d = this.data;
    const tabs = [['principles', this._t('tab_principles'), (d.play_principles || []).length],
                  ['formations', this._t('tab_formations'), (d.formation_families || []).length],
                  ['styles', this._t('tab_styles'), (d.styles || []).length],
                  ['models', this._t('tab_models'), (d.game_models || []).length],
                  ['concepts', this._t('tab_concepts'), (d.concepts || []).length], ['techniques', this._t('tab_techniques'), (d.techniques || []).length],
                  ['learning', this._t('tab_learning'), null], ['more', this._t('tab_more'), null], ['engine', this._t('tab_engine'), null]]
      .map(([k, label, n]) => `<button type="button" class="tx-pill ${this.tab === k ? 'on' : ''}" data-tx="tab" data-v="${k}">${esc(label)}${n != null ? `<span class="n">${n}</span>` : ''}</button>`).join('');
    let body = '';
    if (this.tab === 'principles') body = this._principlesHtml(esc);
    else if (this.tab === 'formations') body = this._formationsHtml(esc);
    else if (this.tab === 'styles') body = this._stylesHtml(esc);
    else if (this.tab === 'models') body = this._modelsHtml(esc);
    else if (this.tab === 'concepts') body = this._conceptsHtml(esc);
    else if (this.tab === 'techniques') body = this._techniquesHtml(esc);
    else if (this.tab === 'more') body = this._moreHtml(esc);
    else if (this.tab === 'learning') body = this._learningHtml(esc);
    else body = this._engineHtml(esc);
    el.innerHTML = head + this._syncHtml(esc) + `<div class="tx-pills">${tabs}</div>` + body;
    if (this.tab === 'concepts') this._renderConceptList();
    this._renderDetail();
  }

  // ── 🔀 By machine: every state machine the game has and the designed ones (game_machines /
  // _states / _transitions, mig 5038). A machine's states are exclusive; top-level machines run side by
  // side; a state can hold sub-machines (parent_state_id); arrows carry the card a player needs to take them.
  _machinesHtml(esc) {
    const d = this.data, ix = this._index();
    const M = d.machines || [], S = d.machine_states || [], T = d.machine_transitions || [];
    const statesOf = new Map(), subsOf = new Map(), arrowsOf = new Map(), stateById = new Map(S.map(x => [x.id, x]));
    for (const x of S) { if (!statesOf.has(x.machine_id)) statesOf.set(x.machine_id, []); statesOf.get(x.machine_id).push(x); }
    for (const m of M) if (m.parent_state_id != null) { if (!subsOf.has(m.parent_state_id)) subsOf.set(m.parent_state_id, []); subsOf.get(m.parent_state_id).push(m); }
    for (const t of T) { if (!arrowsOf.has(t.machine_id)) arrowsOf.set(t.machine_id, []); arrowsOf.get(t.machine_id).push(t); }
    const chip = (st) => `<span class="tx-chip ${st === 'engine' ? 'on' : 'off'}" style="font-size:0.72rem;">${esc(this._t(st === 'engine' ? 'm_engine' : 'm_design'))}</span>`;
    const card = (id) => { const c = id != null && ix.concept.get(id); return c ? ' · ' + this._conceptLink(c, esc) : ''; };
    const name = (id) => { const x = id != null && stateById.get(id); return x ? esc(x.title) : null; };
    const machine = (m, depth) => {
      const states = statesOf.get(m.id) || [], arrows = arrowsOf.get(m.id) || [];
      let h = `<div style="margin:${depth ? '6px 0 4px' : '0 0 14px'}; padding-left:10px; border-left:3px solid ${m.status === 'engine' ? '#22c55e' : '#94a3b8'};">
        <div><strong>${esc(m.title)}</strong> ${chip(m.status)}${card(m.concept_id)}${m.engine ? ` <span class="tx-dim tx-code">${esc(m.engine)}</span>` : ''}</div>
        ${m.note ? `<div class="tx-dim" style="font-size:0.78rem; max-width:80ch;">${esc(m.note)}</div>` : ''}<ul class="tx-list" style="margin:4px 0;">`;
      for (const x of states) {
        const xc = x.concept_id != null && ix.concept.get(x.concept_id);
        h += `<li>${xc && xc.title === x.title ? this._conceptLink(xc, esc) : esc(x.title) + card(x.concept_id)}${x.status !== m.status ? ' ' + chip(x.status) : ''}`;
        for (const sub of subsOf.get(x.id) || []) h += machine(sub, depth + 1);
        h += `</li>`;
      }
      h += `</ul>`;
      if (arrows.length) h += `<div class="tx-dim" style="font-size:0.8rem;">${esc(this._t('m_arrows'))}</div><ul class="tx-list" style="margin:2px 0 4px;">` + arrows.map(t =>
        `<li>${name(t.from) || `<em>${esc(this._t('m_any'))}</em>`} → ${name(t.to) || `<em>${esc(this._t('m_leaves'))}</em>`} <span class="tx-dim">· ${esc(t.label)}</span>${card(t.concept_id)}</li>`).join('') + `</ul>`;
      return h + `</div>`;
    };
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0 12px; max-width:80ch;">${esc(this._t('m_intro'))}</div>`;
    for (const scope of ['team', 'player']) {
      const top = M.filter(m => m.parent_state_id == null && m.scope === scope);
      if (!top.length) continue;
      html += `<div class="tx-moment">${esc(this._t('m_scope_' + scope))}</div>` + top.map(m => machine(m, 0)).join('');
    }
    const used = new Set([...M.map(m => m.concept_id), ...S.map(x => x.concept_id), ...T.map(t => t.concept_id)].filter(v => v != null));
    const loose = (d.concepts || []).filter(c => !used.has(c.id));
    html += `<details style="margin-top:12px;"><summary class="tx-principle" style="cursor:pointer;">${esc(this._t('m_not_placed', { n: loose.length }))}</summary>
      <div style="font-size:0.85rem; line-height:1.8;">${loose.map(c => this._conceptLink(c, esc)).join(' · ')}</div></details>`;
    return html;
  }

  // ── 🧭 How players learn — the design model (owner 11/27), every word message_templates
  // kind 'taxonomy' tiers lm_intro, lm_s<n>_h / lm_s<n>_b (sections run until a heading is missing).
  _learningHtml(esc) {
    let html = `<div class="tx-dim" style="font-size:0.85rem; margin:8px 0 12px; max-width:80ch; white-space:pre-line;">${esc(this._t('lm_intro'))}</div>`;
    for (let n = 1; n < 40; n++) {
      const h = this._t(`lm_s${n}_h`);
      if (!h) break;
      html += `<div class="tx-principle">${esc(h)}</div><div style="font-size:0.88rem; max-width:80ch; white-space:pre-line; margin:0 0 14px;">${esc(this._t(`lm_s${n}_b`))}</div>`;
    }
    return html;
  }

  // ── 🧠 Concepts ────────────────────────────────────────────────────────
  _conceptsHtml(esc) {
    const d = this.data, all = d.concepts || [];
    const inMoment = all.filter(c => !this.moment || c.moment === this.moment);
    const count = (r) => inMoment.filter(c => r === 'all' || this._reach(c) === r).length;
    const moments = [['', this._t('moment_all'), all.length]].concat((d.moments || []).map(m => [m.code, m.title, all.filter(c => c.moment === m.code).length]))
      .map(([k, label, n]) => `<button type="button" class="tx-pill ${this.moment === k ? 'on' : ''}" data-tx="moment" data-v="${esc(k)}">${esc(label)}<span class="n">${n}</span></button>`).join('');
    const eo = this._engineOnly(), dups = this._dups();
    const reaches = ['all', 'played', 'placed', 'job', 'named']
      .map(r => `<button type="button" class="tx-pill ${this.reach === r ? 'on' : ''}" data-tx="reach" data-v="${r}">${r === 'all' ? '' : `<span class="tx-dot" data-reach="${r}"></span>`}${esc(this._t('reach_' + r))}<span class="n">${count(r) + (r === 'all' && !this.moment ? eo.length : 0)}</span></button>`).join('')
      + `<button type="button" class="tx-pill ${this.reach === 'engine' ? 'on' : ''}" data-tx="reach" data-v="engine"><span class="tx-dot" data-reach="engine"></span>${esc(this._t('reach_engine'))}<span class="n">${eo.length}</span></button>`
      + `<button type="button" class="tx-pill ${this.reach === 'dups' ? 'on' : ''}" data-tx="reach" data-v="dups">${esc(this._t('reach_dups'))}<span class="n">${dups.engine.length + dups.pairs.length}</span></button>`;
    const kinds = ['', 'behaviour', 'style', 'call']
      .map(k => `<button type="button" class="tx-pill ${this.kind === k ? 'on' : ''}" data-tx="kind" data-v="${k}">${esc(this._t(k ? 'kind_' + k : 'kind_all'))}<span class="n">${inMoment.filter(c => !k || c.kind === k).length}</span></button>`).join('');
    const legend = this._t('legend'), where = this._t('where_legend');
    const views = ['sections', 'machines'].map(v => `<button type="button" class="tx-pill ${this.view === v ? 'on' : ''}" data-tx="view" data-v="${v}">${esc(this._t('view_' + v))}</button>`).join('');
    if (this.view === 'machines') return `<div class="tx-pills">${views}</div><div id="tx-concepts"></div>`;
    return `<div class="tx-pills">${views}</div><div class="tx-pills">${moments}</div><div class="tx-pills">${kinds}</div>${legend ? `<div class="tx-legend">${esc(legend)}</div>` : ''}<div class="tx-pills">${reaches}</div>
      ${where ? `<div class="tx-legend" style="margin:0 0 8px;">${esc(where)}</div>` : ''}
      <input type="search" class="tx-search" data-tx-search placeholder="${esc(this._t('search'))}" value="${esc(this.search)}">
      <div id="tx-concepts"></div>`;
  }

  // The list alone, so typing in the search box keeps its focus.
  _renderConceptList() {
    const el = this.find('#tx-concepts');
    if (!el || !this.data) return;
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const d = this.data, q = this.search.trim().toLowerCase();
    const rules = {};
    for (const r of d.rules || []) rules[r.code] = r.label;
    if (this.view === 'machines') { el.innerHTML = this._machinesHtml(esc); return; }
    if (this.reach === 'dups') { el.innerHTML = this._dupsHtml(esc); return; }
    const shown = (d.concepts || []).filter(c => (!this.moment || c.moment === this.moment) && (!this.kind || c.kind === this.kind)
      && this.reach !== 'engine' && (this.reach === 'all' || this._reach(c) === this.reach)
      && (!q || (c.title + ' ' + c.name + ' ' + (c.cue || '')).toLowerCase().includes(q)));
    const card = (c) => {
      const reach = this._reach(c);
      const fam = this._t('family_' + c.family) || c.family;
      const nb = (this._index().behOf.get(c.id) || []).length;
      return `<div class="tx-card" data-reach="${reach}" data-tx-open="concept" data-k="${c.id}">
        <div class="tx-title">${esc(c.title)}</div>
        <div class="tx-meta">${esc(this._t('reach_' + reach))} · ${esc(fam)}${c.kind && c.kind !== 'behaviour' ? ' · ' + esc(this._t('kind_' + c.kind)) : ''}${c.sources ? ' · ' + esc(this._t('sources', { n: c.sources })) : ''}</div>
        ${c.cue ? `<div class="tx-cue">${esc(c.cue)}</div>` : ''}
        ${c.books_any ? `<div class="tx-line">${esc(this._t('books_n', { n: c.books, a: c.books_any - c.books }))}</div>` : ''}
        ${reach === 'placed' ? `<div class="tx-line">${esc(this._t('placed_by', { rule: rules[c.rule] || c.rule }))}</div>` : ''}
        ${nb ? `<div class="tx-line">${esc(this._t('n_behaviours', { n: nb }))}</div>` : ''}
        ${this._whereHtml(c, esc)}
      </div>`;
    };
    // What the engine does under no catalogue name is part of the taxonomy too (owner 11/24).
    const eo = (this.reach === 'all' || this.reach === 'engine') && !this.moment
      ? this._engineOnly().filter(g => !q || (g.title + ' ' + g.what + ' ' + g.near.join(' ')).toLowerCase().includes(q)) : [];
    let html = `<div class="tx-dim" style="font-size:0.78rem; margin-top:8px;">${esc(this._t('count_all', { n: shown.length + eo.length, total: (d.concepts || []).length, e: this._engineOnly().length }))}</div>`;
    for (const m of d.moments || []) {
      const mine = shown.filter(c => c.moment === m.code);
      if (!mine.length) continue;
      html += `<div class="tx-moment">${esc(m.title)}</div>`;
      // A principle's own description sits under its heading. A sub-principle (game_principles.parent_id)
      // prints its parent's heading + description once, then its own heading indented under it.
      const groups = (d.principles || []).filter(p => p.moment === m.code).map(p => [p, mine.filter(c => c.principle_id === p.id)]);
      const known = new Set((d.principles || []).filter(p => p.moment === m.code).map(p => p.id));
      groups.push([{ title: this._t('no_principle') }, mine.filter(c => !known.has(c.principle_id))]);
      const shownParents = new Set();
      const desc = (p) => p.description ? `<div class="tx-dim" style="font-size:0.8rem; margin:-2px 0 6px; max-width:80ch;">${esc(p.description)}</div>` : '';
      for (const [p, list] of groups) {
        if (!list.length) continue;
        const par = p.parent_id != null && (d.principles || []).find(x => x.id === p.parent_id);
        if (par && !shownParents.has(par.id)) { shownParents.add(par.id); html += `<div class="tx-principle">${esc(par.title)}</div>${desc(par)}`; }
        html += `<div class="tx-principle"${par ? ' style="margin-left:14px; font-size:0.92em;"' : ''}>${esc(p.title)}</div>${desc(p)}<div class="tx-grid">${list.map(card).join('')}</div>`;
      }
    }
    if (eo.length) {
      const ix = this._index();
      html += `<div class="tx-moment">${esc(this._t('h_engine_only'))}</div><div class="tx-grid">` + eo.map(g => {
        const near = g.near.map(n => ix.byName.get(n)).filter(Boolean);
        return `<div class="tx-card" data-reach="${g.fudge ? 'fudge' : 'engine'}" data-tx-open="behaviour" data-k="${esc(g.behaviours[0].code)}">
          <div class="tx-title">${esc(g.title)}</div>
          <div class="tx-meta">${esc(g.fudge ? this._t('eo_fudge') : this._t('eo_unnamed', { n: g.behaviours.length }))}${g.behaviours[0].symbol ? ` · <span class="tx-code">${esc(g.behaviours[0].symbol)}</span>` : ''}</div>
          <div class="tx-cue">${esc(g.what)}</div>
          ${g.fudge ? '' : `<div class="tx-line">${near.length ? esc(this._t('eo_near')) + ' ' + near.map(c => this._conceptLink(c, esc)).join(', ') : esc(this._t('eo_none'))}</div>`}
          <div class="tx-where"><span class="tx-chip off">${esc(this._t('where_db'))}</span><span class="tx-chip on">${esc(this._t('where_game'))}</span><span class="tx-chip on">${esc(this._t('where_code'))}</span></div>
        </div>`;
      }).join('') + `</div>`;
    }
    el.innerHTML = html;
  }

  // The engine's behaviours no catalogue concept names, one entry per suggested name (two
  // behaviours given the same name are the same idea), fudges each their own.
  _engineOnly() {
    if (this._eo && this._eo.d === this.data) return this._eo.list;
    const groups = new Map(), list = [];
    const pretty = (n) => { const t = String(n || '').replace(/-/g, ' '); return t.charAt(0).toUpperCase() + t.slice(1); };
    for (const b of this.data.behaviours || []) {
      if (b.status === 'concept') continue;
      const near = (b.other || '').split(/,\s*/).filter(Boolean);
      if (b.status === 'fudge') { list.push({ title: pretty(b.code.replace(/_/g, '-')), what: b.what, behaviours: [b], near: [], fudge: true }); continue; }
      const key = b.suggested || b.code;
      if (!groups.has(key)) { groups.set(key, { title: pretty(key), what: b.what, behaviours: [], near: [], fudge: false }); list.push(groups.get(key)); }
      const g = groups.get(key);
      g.behaviours.push(b);
      for (const n of near) if (!g.near.includes(n)) g.near.push(n);
    }
    list.sort((a, b) => (a.fudge - b.fudge) || a.title.localeCompare(b.title));
    this._eo = { d: this.data, list };
    return list;
  }

  // Duplicate candidates, from evidence: an engine-only entry and the concepts it may already
  // be; and two concepts that one behaviour was judged to fit both of.
  _dups() {
    if (this._dp && this._dp.d === this.data) return this._dp.v;
    const ix = this._index(), pairs = new Map();
    for (const b of this.data.behaviours || []) {
      const a = b.concept_id != null ? ix.concept.get(b.concept_id) : null;
      if (!a) continue;
      for (const n of (b.other || '').split(/,\s*/).filter(Boolean)) {
        const o = ix.byName.get(n);
        if (!o || o.id === a.id) continue;
        const key = [Math.min(a.id, o.id), Math.max(a.id, o.id)].join('|');
        if (!pairs.has(key)) pairs.set(key, { a: a.id < o.id ? a : o, b: a.id < o.id ? o : a, n: 0 });
        pairs.get(key).n++;
      }
    }
    const v = { engine: this._engineOnly().filter(g => !g.fudge && g.near.some(n => ix.byName.has(n))),
                pairs: [...pairs.values()].sort((x, y) => y.n - x.n || x.a.title.localeCompare(y.a.title)) };
    this._dp = { d: this.data, v };
    return v;
  }

  _dupsHtml(esc) {
    const ix = this._index(), v = this._dups();
    if (!v.engine.length && !v.pairs.length) return `<p class="tx-dim">${esc(this._t('dup_none'))}</p>`;
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0; max-width:75ch;">${esc(this._t('dup_intro'))}</div>`;
    if (v.engine.length) html += `<div class="tx-h">${esc(this._t('dup_h_engine'))} <span class="tx-dim">${v.engine.length}</span></div>` + v.engine.map(g =>
      `<div class="tx-row" data-status="unnamed" data-tx-open="behaviour" data-k="${esc(g.behaviours[0].code)}">
        <div style="font-size:0.88rem;"><strong>${esc(g.title)}</strong> <span class="tx-dim">— ${esc(g.what)}</span></div>
        <div class="tx-meta">${esc(this._t('eo_near'))} ${g.near.map(n => ix.byName.get(n)).filter(Boolean).map(c => this._conceptLink(c, esc)).join(', ')}</div>
      </div>`).join('');
    if (v.pairs.length) html += `<div class="tx-h">${esc(this._t('dup_h_pairs'))} <span class="tx-dim">${v.pairs.length}</span></div>` + v.pairs.map(p =>
      `<div class="tx-row" data-status="concept" style="cursor:default;">
        <div style="font-size:0.88rem;">${this._conceptLink(p.a, esc)} <span class="tx-dim">↔</span> ${this._conceptLink(p.b, esc)}</div>
        <div class="tx-meta">${esc(this._t('dup_pair_why', { n: p.n }))}</div>
      </div>`).join('');
    return html;
  }

  // ── Always in step, with a timestamp (scripts/taxonomy/sync.py → taxonomy_sync) ──
  _ago(epoch, now) {
    const s = Math.max(0, Math.round(now - epoch));
    if (s < 90) return this._t('ago_s', { n: s });
    if (s < 5400) return this._t('ago_m', { n: Math.round(s / 60) });
    if (s < 86400) return this._t('ago_h', { n: Math.round(s / 3600) });
    return this._t('ago_at', { t: new Date(epoch * 1000).toLocaleString() });
  }
  _syncHtml(esc) {
    const y = this.data && this.data.sync;
    const btn = `<button type="button" class="tx-pill" data-tx="sync" ${this._syncing ? 'disabled' : ''}>${esc(this._t(this._syncing ? 'sync_wait' : 'sync_now'))}</button>`;
    if (!y || !y.checked_at) return `<div class="tx-sync"><span>${esc(this._t('sync_never'))}</span>${btn}</div>`;
    const when = this._ago(y.checked_at, y.now) + ' (' + new Date(y.checked_at * 1000).toLocaleTimeString() + ')';
    const main = y.in_sync ? this._t('sync_ok', { when, n: y.db_rows }) : this._t('sync_bad', { when });
    const diffs = Object.entries(y.diff || {}).filter(([, list]) => list && list.length)
      .map(([k, list]) => `<div class="d">${esc(this._t('sync_d_' + k, { list: list.join(', ') }))}</div>`).join('');
    const game = y.game_built_at ? `<div class="d">${esc(this._t(y.game_stale ? 'sync_game_stale' : 'sync_game_ok', { when: this._ago(y.game_built_at, y.now) }))}</div>` : '';
    return `<div class="tx-sync ${y.in_sync ? '' : 'bad'}"><span>${esc(main)}</span>${btn}${diffs}${game}</div>`;
  }
  // 🔄 Sync now: read it all again — every read checks the C++ against the database first.
  async _syncNow() {
    if (this._syncing) return;
    this._syncing = true;
    this._render();
    await this._load();
    this._syncing = false;
    this._render();
  }

  // ── 📜 Principles of play (migs 1929–1935) ──────────────────────────────
  // Owner 11/26: "find the ones that are same and put them linked in db … one offs we can have them" ·
  // "list the most popular principles sorted by pop" · "decide based on popularity or we can over ride".
  // Every source's principle in its own words → the common ground it is (same / part of / overlaps) →
  // popularity = sources that name it, schools = lineage roots. Sorted by popularity (the server's order).
  _principlesHtml(esc) {
    const d = this.data, all = d.play_principles || [];
    const levels = ['all', 'general', 'operational', 'fundamental', 'sub'];
    const n = (l) => l === 'all' ? all.length : all.filter(p => p.level === l).length;
    const pills = levels.map(l => `<button type="button" class="tx-pill ${this.plevel === l ? 'on' : ''}" data-tx="plevel" data-v="${l}">${esc(this._t('pl_' + l))}<span class="n">${n(l)}</span></button>`).join('')
      + `<button type="button" class="tx-pill ${this.plevel === 'federations' ? 'on' : ''}" data-tx="plevel" data-v="federations">${esc(this._t('pl_federations'))}<span class="n">${(d.federations || []).length}</span></button>`;
    const nsrc = (d.sources || []).length, nent = (d.principle_entries || []).length;
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0; max-width:75ch;">${esc(this._t('pr_intro', { s: nsrc, e: nent }))}</div><div class="tx-pills">${pills}</div>`;
    if (this.plevel === 'federations') return html + this._federationsHtml(esc);
    const rows = this.plevel === 'all' ? all : all.filter(p => p.level === this.plevel);
    html += `<div class="tx-grid">` + rows.map((p, i) => {
      const verdict = p.verdict ? `<span class="tx-chip on">${esc(this._t('pr_v_' + p.verdict))}</span>` : '';
      const built = p.concepts ? esc(this._t('pr_built', { c: p.concepts, e: p.engine, s: p.in_sim })) : esc(this._t('pr_not_built'));
      return `<div class="tx-card" data-reach="${p.verdict === 'reject' ? 'named' : p.concepts ? 'played' : p.sources >= 3 ? 'job' : 'named'}" data-tx-open="principle" data-k="${esc(p.code)}">
        <div class="tx-title">${i + 1}. ${esc(p.title)} ${verdict}</div>
        <div class="tx-meta">${esc(this._t('pr_meta', { s: p.sources, o: p.overlaps, k: p.schools, l: this._t('pl_' + p.level), side: this._t('side_' + p.side) }))}</div>
        ${p.aka ? `<div class="tx-cue tx-dim">${esc(p.aka)}</div>` : ''}
        <div class="tx-line">${built}</div></div>`;
    }).join('') + `</div>`;
    return html;
  }

  _federationsHtml(esc) {
    const feds = this.data.federations || [], srcs = new Map((this.data.sources || []).map(s => [s.id, s]));
    const confs = [...new Set(feds.map(f => f.confederation))];
    const statuses = ['found', 'known', 'not_published', 'not_searched'];
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0; max-width:75ch;">${esc(this._t('fed_intro'))}</div>`;
    for (const c of confs) {
      const mine = feds.filter(f => f.confederation === c);
      html += `<div class="tx-moment">${esc(c)} <span class="tx-dim" style="font-size:0.8rem;">${statuses.map(st => esc(this._t('fed_' + st)) + ' ' + mine.filter(f => f.status === st).length).join(' · ')}</span></div>`;
      for (const st of statuses) {
        const list = mine.filter(f => f.status === st);
        if (!list.length) continue;
        html += `<div class="tx-principle">${esc(this._t('fed_' + st))}</div><ul class="tx-list">` + list.map(f => {
          const s = f.source_id != null ? srcs.get(f.source_id) : null;
          const name = f.url ? `<a class="tx-link" href="${esc(f.url)}" target="_blank" rel="noopener">${esc(f.name)}</a>` : esc(f.name);
          return `<li>${name}${s ? ` <span class="tx-dim">— ${esc(s.title)}</span>` : ''}${f.note ? ` <span class="tx-dim">· ${esc(f.note)}</span>` : ''}</li>`;
        }).join('') + `</ul>`;
      }
    }
    return html;
  }

  _principleSheet(code, esc) {
    const d = this.data, p = (d.play_principles || []).find(x => x.code === code);
    if (!p) return '';
    const srcs = new Map((d.sources || []).map(s => [s.id, s]));
    const kids = (d.play_principles || []).filter(x => x.parent_id === p.id);
    const parent = p.parent_id != null ? (d.play_principles || []).find(x => x.id === p.parent_id) : null;
    const entries = (d.principle_entries || []).filter(e => e.principle_id === p.id || kids.some(k => k.id === e.principle_id));
    const rel = ['same', 'part_of', 'overlaps'];
    let html = `<h3 style="margin:6px 0 2px;">${esc(p.title)}</h3>
      <div class="tx-meta">${esc(this._t('pr_meta', { s: p.sources, o: p.overlaps, k: p.schools, l: this._t('pl_' + p.level), side: this._t('side_' + p.side) }))} · ${esc(p.decided_by)}</div>`
      + this._kv([[this._t('pr_aka'), p.aka], [this._t('pr_def'), p.definition], [this._t('pr_not'), p.is_not],
                  [this._t('pr_parent'), parent ? `<button type="button" class="tx-link" data-tx-open="principle" data-k="${esc(parent.code)}">${esc(parent.title)}</button>` : '', true],
                  [this._t('pr_kids'), kids.map(k => `<button type="button" class="tx-link" data-tx-open="principle" data-k="${esc(k.code)}">${esc(k.title)}</button>`).join(', '), true],
                  [this._t('pr_chain'), this._t('pr_chain_v', { m: p.model_principles, c: p.concepts, e: p.engine, s: p.in_sim })],
                  [this._t('tab_models'), (d.game_models || []).filter(m => (m.principles || []).some(x => x.principle_id === p.id))
                     .map(m => `<button type="button" class="tx-link" data-tx-open="model" data-k="${m.id}">${esc(m.name)}</button>`).join(', '), true],
                  [this._t('pr_note'), p.note]], esc);
    if (window.MainMenu && MainMenu._access && MainMenu._access.admin) {   // the server checks too (admins only)
      html += `<div class="tx-pills">${['adopt', 'reject', ''].map(v => `<button type="button" class="tx-pill ${(p.verdict || '') === v ? 'on' : ''}" data-tx="verdict" data-code="${esc(p.code)}" data-v="${v}">${esc(this._t('pr_set_' + (v || 'pop')))}</button>`).join('')}</div>`;
    }
    for (const r of rel) {
      const list = entries.filter(e => e.relation === r);
      if (!list.length) continue;
      html += `<div class="tx-h">${esc(this._t('pr_rel_' + r))} <span class="tx-dim">${new Set(list.map(e => e.source_id)).size}</span></div><ul class="tx-list">` + list.map(e => {
        const s = srcs.get(e.source_id) || {};
        const t = s.url ? `<a class="tx-link" href="${esc(s.url)}" target="_blank" rel="noopener">${esc(s.title || s.code)}</a>` : esc(s.title || s.code);
        return `<li><strong>${esc(e.term)}</strong> <span class="tx-dim">(${esc(e.lang)})</span> — ${t}${s.school ? ` <span class="tx-dim">· ${esc(this._t('pr_school', { s: s.school }))}</span>` : ''}${e.verified ? '' : ` <span class="tx-dim">· ${esc(this._t('pr_unverified'))}</span>`}</li>`;
      }).join('') + `</ul>`;
    }
    return html;
  }

  // ── shared: a source's name for something, with its link and school ──────────────────────────────────────
  _srcLine(sourceId, words, extra, esc) {
    const s = (this.data.sources || []).find(x => x.id === sourceId) || {};
    const t = s.url ? `<a class="tx-link" href="${esc(s.url)}" target="_blank" rel="noopener">${esc(s.title || s.code)}</a>` : esc(s.title || s.code || '');
    return `<li><strong>${esc(words)}</strong>${extra ? ` <span class="tx-dim">${esc(extra)}</span>` : ''} — ${t}${s.school ? ` <span class="tx-dim">· ${esc(this._t('pr_school', { s: s.school }))}</span>` : ''}</li>`;
  }
  _byRelation(entries, line, esc) {
    let html = '';
    for (const r of ['same', 'part_of', 'overlaps']) {
      const list = entries.filter(e => (e.relation || 'same') === r);
      if (!list.length) continue;
      html += `<div class="tx-h">${esc(this._t('pr_rel_' + r))} <span class="tx-dim">${new Set(list.map(e => e.source_id)).size}</span></div><ul class="tx-list">${list.map(line).join('')}</ul>`;
    }
    return html;
  }

  // ── 🧩 Formations (mig 1938): named systems, by sources then real starts ──────────────────────────────────
  _formationsHtml(esc) {
    const fams = this.data.formation_families || [];
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0; max-width:75ch;">${esc(this._t('fm_intro'))}</div>`;
    for (const ph of ['base', 'in_possession', 'historic']) {
      const list = fams.filter(f => f.phase === ph);
      if (!list.length) continue;
      html += `<div class="tx-moment">${esc(this._t('fm_ph_' + ph))}</div><div class="tx-grid">` + list.map(f => {
        const par = f.parent_id != null ? fams.find(x => x.id === f.parent_id) : null;
        return `<div class="tx-card" data-reach="${f.boards ? 'played' : f.sources >= 2 ? 'job' : 'named'}" data-tx-open="family" data-k="${f.id}">
          <div class="tx-title">${esc(f.title)}${f.title !== f.code ? ` <span class="tx-dim">${esc(f.code)}</span>` : ''}</div>
          <div class="tx-meta">${esc(this._t('fm_meta', { s: f.sources, u: f.uses, b: f.boards, t: f.sim_teams }))}</div>
          ${par ? `<div class="tx-line tx-dim">${esc(this._t('fm_variant', { p: par.title }))}</div>` : ''}</div>`;
      }).join('') + `</div>`;
    }
    return html;
  }
  _familySheet(id, esc) {
    const d = this.data, f = (d.formation_families || []).find(x => x.id === id);
    if (!f) return '';
    const kids = (d.formation_families || []).filter(x => x.parent_id === id), par = (d.formation_families || []).find(x => x.id === f.parent_id);
    const boards = (d.boards || []).filter(b => b.family_id === id);
    const models = (d.game_models || []).filter(m => m.family_id === id);
    const link = (x) => `<button type="button" class="tx-link" data-tx-open="family" data-k="${x.id}">${esc(x.title)}</button>`;
    let html = `<h3 style="margin:6px 0 2px;">${esc(f.title)}</h3><div class="tx-meta">${esc(this._t('fm_meta', { s: f.sources, u: f.uses, b: f.boards, t: f.sim_teams }))} · ${esc(f.decided_by)}</div>`
      + this._kv([[this._t('pr_aka'), f.aka], [this._t('pr_def'), f.definition], [this._t('pr_parent'), par ? link(par) : '', true],
                  [this._t('pr_kids'), kids.map(link).join(', '), true], [this._t('fm_boards'), boards.map(b => esc(b.name)).join(' · '), true],
                  [this._t('tab_models'), models.map(m => `<button type="button" class="tx-link" data-tx-open="model" data-k="${m.id}">${esc(m.name)}</button>`).join(', '), true]], esc);
    return html + this._byRelation((d.formation_entries || []).filter(e => e.family_id === id),
      e => this._srcLine(e.source_id, e.name, [e.context, e.uses != null ? this._t('fm_uses', { n: e.uses }) : ''].filter(Boolean).join(' · '), esc), esc);
  }

  // ── 🎨 Playing styles (mig 1939): the axes, then the named styles with their profile ──────────────────────
  _profileHtml(profile, esc) {
    const dims = new Map((this.data.style_dimensions || []).map(x => [x.id, x]));
    return (profile || []).filter(p => p.value).map(p => { const x = dims.get(p.dimension_id); return x ? `<span class="tx-chip on" title="${esc(x.title)}">${esc(p.value > 0 ? x.high : x.low)}${Math.abs(p.value) > 1 ? ' ●●' : ' ●'}</span>` : ''; }).join(' ');
  }
  _stylesHtml(esc) {
    const d = this.data, ms = new Map((d.moments || []).map(m => [m.code, m.title]));
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0; max-width:75ch;">${esc(this._t('st_intro'))}</div>`;
    html += `<div class="tx-moment">${esc(this._t('st_named'))}</div><div class="tx-grid">` + (d.styles || []).map(st => `
      <div class="tx-card" data-reach="${st.sources >= 2 ? 'played' : 'named'}" data-tx-open="style" data-k="${st.id}">
        <div class="tx-title">${esc(st.title)} ${st.era ? `<span class="tx-dim">${esc(st.era)}</span>` : ''}</div>
        <div class="tx-meta">${esc(this._t('st_meta', { s: st.sources }))}${st.aka ? ' · ' + esc(st.aka) : ''}</div>
        <div class="tx-line">${this._profileHtml(st.profile, esc)}</div></div>`).join('') + `</div>`;
    html += `<div class="tx-moment">${esc(this._t('st_axes'))}</div><ul class="tx-list">` + (d.style_dimensions || []).map(x =>
      `<li><strong>${esc(x.title)}</strong> <span class="tx-dim">(${esc(ms.get(x.moment) || x.moment)})</span>: ${esc(x.low)} ↔ ${esc(x.high)} — ${esc(x.definition)} <span class="tx-dim">· ${esc(this._t('st_axis_meta', { s: x.sources, n: x.named, m: x.measure }))}</span></li>`).join('') + `</ul>`;
    return html;
  }
  _styleSheet(id, esc) {
    const d = this.data, st = (d.styles || []).find(x => x.id === id);
    if (!st) return '';
    const par = (d.styles || []).find(x => x.id === st.parent_id), kids = (d.styles || []).filter(x => x.parent_id === id);
    const link = (x) => `<button type="button" class="tx-link" data-tx-open="style" data-k="${x.id}">${esc(x.title)}</button>`;
    const models = (d.game_models || []).filter(m => m.style_id === id);
    let html = `<h3 style="margin:6px 0 2px;">${esc(st.title)}</h3><div class="tx-meta">${esc(this._t('st_meta', { s: st.sources }))}${st.era ? ' · ' + esc(st.era) : ''}</div>`
      + this._kv([[this._t('pr_aka'), st.aka], [this._t('pr_def'), st.definition], [this._t('st_profile'), this._profileHtml(st.profile, esc), true],
                  [this._t('pr_parent'), par ? link(par) : '', true], [this._t('pr_kids'), kids.map(link).join(', '), true],
                  [this._t('tab_models'), models.map(m => `<button type="button" class="tx-link" data-tx-open="model" data-k="${m.id}">${esc(m.name)}</button>`).join(', '), true]], esc);
    return html + this._byRelation((d.style_entries || []).filter(e => e.style_id === id), e => this._srcLine(e.source_id, e.name, e.context, esc), esc);
  }

  // ── 🗺 Game models (mig 1940): ours with everyone else's ───────────────────────────────────────────────────
  _modelsHtml(esc) {
    const d = this.data, sty = new Map((d.styles || []).map(x => [x.id, x])), fam = new Map((d.formation_families || []).map(x => [x.id, x]));
    let html = `<div class="tx-dim" style="font-size:0.82rem; margin:8px 0; max-width:75ch;">${esc(this._t('gm_intro'))}</div>`;
    for (const k of ['club', 'team', 'federation', 'school']) {
      const list = (d.game_models || []).filter(m => m.kind === k);
      if (!list.length) continue;
      html += `<div class="tx-moment">${esc(this._t('gm_kind_' + k))}</div><div class="tx-grid">` + list.map(m => `
        <div class="tx-card" data-reach="${(m.moments || []).length ? 'played' : 'named'}" data-tx-open="model" data-k="${m.id}">
          <div class="tx-title">${esc(m.name)} ${m.era ? `<span class="tx-dim">${esc(m.era)}</span>` : ''}</div>
          <div class="tx-meta">${[m.style_id ? sty.get(m.style_id)?.title : '', m.family_id ? fam.get(m.family_id)?.title : ''].filter(Boolean).map(esc).join(' · ') || esc(this._t('gm_no_style'))}</div>
          <div class="tx-cue tx-dim">${esc(m.note)}</div></div>`).join('') + `</div>`;
    }
    return html;
  }
  _modelSheet(id, esc) {
    const d = this.data, m = (d.game_models || []).find(x => x.id === id);
    if (!m) return '';
    const sty = (d.styles || []).find(x => x.id === m.style_id), fam = (d.formation_families || []).find(x => x.id === m.family_id);
    const src = (d.sources || []).find(x => x.id === m.source_id), pp = new Map((d.play_principles || []).map(x => [x.id, x]));
    let html = `<h3 style="margin:6px 0 2px;">${esc(m.name)}</h3><div class="tx-meta">${esc(this._t('gm_kind_' + m.kind))}${m.era ? ' · ' + esc(m.era) : ''}${m.verified ? '' : ' · ' + esc(this._t('pr_unverified'))}</div>`
      + this._kv([[this._t('gm_whose'), src ? (src.url ? `<a class="tx-link" href="${esc(src.url)}" target="_blank" rel="noopener">${esc(src.title)}</a>` : esc(src.title)) : '', true],
                  [this._t('pr_def'), m.note],
                  [this._t('tab_styles'), sty ? `<button type="button" class="tx-link" data-tx-open="style" data-k="${sty.id}">${esc(sty.title)}</button>` : '', true],
                  [this._t('tab_formations'), fam ? `<button type="button" class="tx-link" data-tx-open="family" data-k="${fam.id}">${esc(fam.title)}</button>` : '', true],
                  [this._t('st_profile'), this._profileHtml(m.settings, esc), true],
                  [this._t('gm_concepts'), m.concepts ? String(m.concepts) : '']], esc);
    for (const mo of d.moments || []) {
      const plan = (m.moments || []).find(x => x.moment === mo.code), prs = (m.principles || []).filter(x => x.moment === mo.code);
      if (!plan && !prs.length) continue;
      html += `<div class="tx-h">${esc(mo.title)}</div>${plan ? `<div class="tx-cue">${esc(plan.plan)}</div>` : ''}`
        + (prs.length ? `<ul class="tx-list">${prs.map(x => { const p = pp.get(x.principle_id); return `<li>${p ? `<button type="button" class="tx-link" data-tx-open="principle" data-k="${esc(p.code)}">${esc(p.title)}</button>` : ''}${x.words ? ` <span class="tx-dim">— “${esc(x.words)}”</span>` : ''}</li>`; }).join('')}</ul>` : '');
    }
    return html;
  }

  async _verdict(code, verdict) {
    try {
      const res = await this.auth.fetch(`/api/tactic-plans/taxonomy/principles/${encodeURIComponent(code)}/verdict`,
        { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ verdict, note: '' }) });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      await this._load();
      this._render();
      this._renderDetail();
    } catch (_) { /* the sheet stays as it was */ }
  }

  // ── 🦶 Techniques: the tree as nested lists ────────────────────────────
  _techniquesHtml(esc) {
    const kids = new Map();
    for (const t of this.data.techniques || []) {
      const k = t.parent_id == null ? 0 : t.parent_id;
      if (!kids.has(k)) kids.set(k, []);
      kids.get(k).push(t);
    }
    const tree = (parent, depth) => {
      const list = kids.get(parent) || [];
      if (!list.length) return '';
      return `<ul class="tx-list">${list.map(t => `<li>${depth === 0 ? `<strong>${esc(t.title)}</strong>` : esc(t.title)}${t.how ? ` <span class="tx-dim">— ${esc(t.how)}</span>` : ''}${tree(t.id, depth + 1)}</li>`).join('')}</ul>`;
    };
    return tree(0, 0);
  }

  // ── 📏 Roles · measures · Laws · placement rules ──────────────────────
  _moreHtml(esc) {
    const d = this.data;
    const list = (rows, f) => `<ul class="tx-list">${(rows || []).map(r => `<li>${f(r)}</li>`).join('')}</ul>`;
    return `<div class="tx-h">${esc(this._t('h_roles'))}</div>${list(d.roles, r => esc(r.title))}
      <div class="tx-h">${esc(this._t('h_measures'))}</div>${list(d.measures, r => esc(r.title))}
      <div class="tx-h">${esc(this._t('h_rules'))}</div>${list(d.rules, r => esc(r.label))}
      <div class="tx-h">${esc(this._t('h_laws'))}</div>${list(d.laws, r => `<strong>${esc(r.number)}</strong> ${esc(r.title)}${r.summary ? ` <span class="tx-dim">— ${esc(r.summary)}</span>` : ''}`)}`;
  }

  // ── ⚙️ Engine: every behaviour it has, its classes, its vocabulary ──────
  _engineHtml(esc) {
    const d = this.data, ix = this._index(), all = d.behaviours || [];
    const sets = { all, concept: all.filter(b => b.status === 'concept'), unnamed: all.filter(b => b.status === 'unnamed'),
                   fudge: all.filter(b => b.status === 'fudge'), read: all.filter(b => b.read) };
    const pills = ['all', 'concept', 'unnamed', 'fudge', 'read']
      .map(k => `<button type="button" class="tx-pill ${this.engine === k ? 'on' : ''}" data-tx="engine" data-v="${k}">${['concept', 'unnamed', 'fudge'].includes(k) ? `<span class="tx-dot" data-reach="${k}"></span>` : ''}${esc(this._t('beh_' + k))}<span class="n">${sets[k].length}</span></button>`).join('')
      + `<button type="button" class="tx-pill ${this.engine === 'classes' ? 'on' : ''}" data-tx="engine" data-v="classes">${esc(this._t('beh_classes'))}<span class="n">${(d.classes || []).length}</span></button>`
      + `<button type="button" class="tx-pill ${this.engine === 'terms' ? 'on' : ''}" data-tx="engine" data-v="terms">${esc(this._t('beh_terms'))}</button>`;
    const used = new Set(sets.concept.map(b => b.concept_id)).size;
    let body = '';
    if (this.engine === 'classes') body = this._classTreeHtml(esc);
    else if (this.engine === 'terms') {
      const terms = d.engine || [];
      const sec = (kind) => {
        const rows = terms.filter(t => t.kind === kind);
        return rows.length ? `<div class="tx-h">${esc(this._t('h_' + kind))} <span class="tx-dim">${rows.length}</span></div>
          <ul class="tx-list">${rows.map(t => `<li>${esc(t.title)}${t.note ? ` <span class="tx-dim">— ${esc(t.note)}</span>` : ''}</li>`).join('')}</ul>` : '';
      };
      body = sec('phase') + sec('state') + sec('decision') + sec('role');
    } else {
      body = (sets[this.engine] || all).map(b => this._behaviourRow(b, esc)).join('');
    }
    return `<div class="tx-dim" style="font-size:0.85rem; max-width:75ch;">${esc(this._t('engine_intro2', { n: all.length, used, total: (d.concepts || []).length }))}</div>
      <div class="tx-pills">${pills}</div>${body}`;
  }

  _behaviourRow(b, esc) {
    const ix = this._index(), c = b.concept_id != null ? ix.concept.get(b.concept_id) : null;
    const name = c ? `<button type="button" class="tx-link" data-tx-open="concept" data-k="${c.id}">${esc(c.title)}</button>`
      : b.status === 'unnamed' ? `<span>${esc(this._t('beh_suggested', { name: b.suggested || '' }))}</span>` : `<span>${esc(this._t('beh_fudge'))}</span>`;
    return `<div class="tx-row" data-status="${esc(b.status)}" data-tx-open="behaviour" data-k="${esc(b.code)}">
      <div style="font-size:0.86rem;">${esc(b.what)}</div>
      <div class="tx-meta">${b.read ? esc(this._t('beh_is_read')) + ' · ' : ''}${name}${b.symbol ? ` · <span class="tx-code">${esc(b.symbol)}</span>` : ''}${b.tag ? ` · ${esc(b.tag)}` : ''}</div>
    </div>`;
  }

  _classTreeHtml(esc) {
    const ix = this._index();
    const link = (n) => `<button type="button" class="tx-link tx-code" data-tx-open="class" data-k="${esc(n)}">${esc(n)}</button>`;
    const node = (n) => {
      const kids = (ix.kids.get(n) || []).slice().sort(), nb = (ix.behIn.get(n) || []).length;
      return `<li>${link(n)}${nb ? ` <span class="tx-dim">· ${esc(this._t('n_behaviours', { n: nb }))}</span>` : ''}${kids.length ? `<ul class="tx-list">${kids.map(node).join('')}</ul>` : ''}</li>`;
    };
    const roots = [...ix.cls.values()].filter(k => !k.parent || !ix.cls.has(k.parent)).map(k => k.name).sort();
    const families = roots.filter(n => (ix.kids.get(n) || []).length), loners = roots.filter(n => !(ix.kids.get(n) || []).length);
    return `<div class="tx-h">${esc(this._t('h_families'))}</div><ul class="tx-list">${families.map(node).join('')}</ul>
      <div class="tx-h">${esc(this._t('h_loners'))}</div><ul class="tx-list" style="columns: 2 260px;">${loners.map(node).join('')}</ul>`;
  }

  // ── The sheet: a concept's database row, a behaviour, or a C++ class ───
  _renderDetail() {
    const host = this.find('#tx-detail');
    if (!host) return;
    if (!this.detail || !this.data) { host.innerHTML = ''; return; }
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    const { type, key } = this.detail;
    const inner = type === 'principle' ? this._principleSheet(key, esc) : type === 'family' ? this._familySheet(Number(key), esc)
      : type === 'style' ? this._styleSheet(Number(key), esc) : type === 'model' ? this._modelSheet(Number(key), esc) : type === 'concept' ? this._conceptSheet(Number(key), esc) : type === 'db' ? this._dbSheet(Number(key), esc)
      : type === 'game' ? this._gameSheet(Number(key), esc)
      : type === 'behaviour' ? this._behaviourSheet(key, esc) : this._classSheet(key, esc);
    host.innerHTML = `<div class="tx-sheet-back" data-tx="close"></div><div class="tx-sheet" role="dialog">
      <div class="tx-pills" style="margin-top:0;">${this.trail.length ? `<button type="button" class="tx-pill" data-tx="back">${esc(this._t('back'))}</button>` : ''}
        <button type="button" class="tx-pill" data-tx="close">${esc(this._t('close'))}</button></div>${inner}</div>`;
    if (type === 'db') this._loadDb(Number(key));
    else if (type === 'concept') this._loadBooks(Number(key));
    else if (!['concept', 'game', 'principle', 'family', 'style', 'model'].includes(type)) this._loadSource();
    const at = this.detail.sec && host.querySelector(`[data-tx-sec="${this.detail.sec}"]`);
    if (at) at.scrollIntoView({ block: 'start' });
  }

  _kv(rows, esc) {
    return `<dl class="tx-kv">${rows.filter(r => r[1] != null && r[1] !== '').map(([k, v, raw]) => `<dt>${esc(k)}</dt><dd>${raw ? v : esc(v)}</dd>`).join('')}</dl>`;
  }
  _classLink(n, esc) {
    return this._index().cls.has(n) ? `<button type="button" class="tx-link tx-code" data-tx-open="class" data-k="${esc(n)}">${esc(n)}</button>` : `<span class="tx-code">${esc(n)}</span>`;
  }
  _conceptLink(c, esc) { return `<button type="button" class="tx-link" data-tx-open="concept" data-k="${c.id}">${esc(c.title)}</button>`; }

  _conceptSheet(id, esc) {
    const d = this.data, ix = this._index(), c = ix.concept.get(id);
    if (!c) return '';
    const moment = ((d.moments || []).find(m => m.code === c.moment) || {}).title || c.moment;
    const principle = ((d.principles || []).find(p => p.id === c.principle_id) || {}).title;
    const reach = this._reach(c);
    let html = `<h3>${esc(c.title)}</h3><div class="tx-dim tx-code">game_concepts · id ${c.id} · ${esc(c.name)}</div>
      ${this._whereHtml(c, esc)}
      <h4>${esc(this._t('s_row'))}</h4>` + this._kv([
        [this._t('f_reach'), this._t('reach_' + reach)], [this._t('f_moment'), moment], [this._t('f_principle'), principle],
        [this._t('f_family'), this._t('family_' + c.family) || c.family], [this._t('f_kind'), this._t('kind_' + c.kind) || c.kind], [this._t('f_status'), c.status],
        [this._t('f_taught'), c.taught_from], [this._t('f_definition'), c.definition], [this._t('f_cue'), c.cue], [this._t('f_lacking'), c.lacking],
        [this._t('f_sources'), c.sources || null]], esc);
    const out = (d.links || []).filter(l => l.from === id), inn = (d.links || []).filter(l => l.to === id);
    if (out.length || inn.length) {
      html += `<h4>${esc(this._t('s_links'))}</h4><ul class="tx-list">`
        + out.map(l => ix.concept.get(l.to) ? `<li>${esc(this._t('link_' + l.kind.replace('-', '_')) || l.kind)} ${this._conceptLink(ix.concept.get(l.to), esc)}</li>` : '').join('')
        + inn.map(l => ix.concept.get(l.from) ? `<li>${esc(this._t('link_' + l.kind.replace('-', '_') + '_by') || l.kind)} ${this._conceptLink(ix.concept.get(l.from), esc)}</li>` : '').join('') + `</ul>`;
    }
    const jobs = (d.jobs || []).filter(j => j.concept_id === id);
    html += `<h4>${esc(this._t('s_jobs'))}</h4>` + (jobs.length ? `<ul class="tx-list">${jobs.map(j => {
      const rule = (d.rules || []).find(r => r.code === j.rule);
      const nums = [j.dist_m != null ? `${j.dist_m} m` : '', j.press_m != null ? `press ${j.press_m} m` : '', j.lane_t != null ? `lane ${j.lane_t}` : ''].filter(Boolean).join(' · ');
      return `<li><strong>${esc(j.label)}</strong> <span class="tx-dim tx-code">${esc(j.code)}</span><br>${esc(rule ? rule.label : j.rule)}${nums ? ` <span class="tx-dim">(${esc(nums)})</span>` : ''} — ${this._classLink(this._ruleClass(j.rule), esc)}</li>`;
    }).join('')}</ul>` : `<div class="tx-dim">${esc(this._t('none_jobs'))}</div>`);
    const behs = ix.behOf.get(id) || [];
    const classes = this._where(c).classes;
    if (classes.length) html += `<h4 data-tx-sec="classes">${esc(this._t('s_classes'))}</h4><ul class="tx-list">${classes.map(n => `<li>${this._classLink(n, esc)} <span class="tx-dim tx-code">${esc(ix.cls.get(n).file)}</span></li>`).join('')}</ul>`;
    html += `<h4 data-tx-sec="behaviours">${esc(this._t('s_behaviours'))}</h4>` + (behs.length ? behs.map(b => this._behaviourRow(b, esc)).join('') : `<div class="tx-dim">${esc(this._t('none_behaviours'))}</div>`);
    const also = (d.behaviours || []).filter(b => b.concept_id !== id && (b.other || '').split(/,\s*/).includes(c.name));
    if (also.length) html += `<h4>${esc(this._t('s_near'))}</h4>` + also.map(b => this._behaviourRow(b, esc)).join('');
    // 📚 The coaching-book patterns tagged with it (coaching_book_pattern_concepts) — loaded on open.
    html += `<h4 data-tx-sec="books">${esc(this._t('s_books', { n: c.books_any || 0 }))}</h4>`
      + (c.books_any ? `<div data-tx-books="${c.id}"><p class="tx-dim">${esc(this._t('loading'))}</p></div>` : `<div class="tx-dim">${esc(this._t('none_books'))}</div>`);
    return html;
  }

  // ── 🎮 the concept in the game: what the engine does with it, and a live demo ──
  _gameSheet(id, esc) {
    const c = this._index().concept.get(id);
    if (!c) return '';
    const w = this._where(c);
    let html = `<h3>${esc(this._t('game_title', { title: c.title }))}</h3>
      <div class="tx-dim tx-code">game_concepts · id ${c.id} · ${this._conceptLink({ id: c.id, title: this._t('db_to_concept') }, esc)}</div>
      ${c.cue ? `<div style="font-size:0.9rem; margin-top:8px;">${esc(c.cue)}</div>` : ''}`;
    if (!w.played) return html + `<p class="tx-dim">${esc(this._t('where_game_no'))}</p>`;
    html += `<h4>${esc(this._t('game_s_watch'))}</h4>
      <button type="button" class="tx-pill on" data-tx="watch" data-v="${c.id}" style="font-size:0.9rem; padding:8px 16px;">${esc(this._t('game_watch'))}</button>
      <div class="tx-dim" style="font-size:0.8rem; margin-top:6px; max-width:70ch;">${esc(this._t(c.act ? 'game_watch_note' : 'game_watch_unreported'))}</div>
      <h4>${esc(this._t('game_s_how'))}</h4>`;
    if (c.act_note) html += `<div style="font-size:0.86rem; margin-bottom:6px;">${esc(c.act_note)}</div>`;
    html += w.game.map(b => this._behaviourRow(b, esc)).join('');
    return html;
  }

  // The popup on the live match.  It needs its opener (the words), so no 'noopener'.
  _watch(id) {
    window.open(`/concept.html?concept=${id}`, 'fh-concept-clips', 'popup=yes,width=1280,height=800');
  }

  // ── 🗄 the concept as the database holds it ────────────────────────────
  _dbSheet(id, esc) {
    const c = this._index().concept.get(id);
    if (!c) return '';
    return `<h3>${esc(this._t('db_title', { title: c.title }))}</h3>
      <div class="tx-dim tx-code">game_concepts · id ${c.id} · ${this._conceptLink({ id: c.id, title: this._t('db_to_concept') }, esc)}</div>
      <div data-tx-db="${c.id}"><p class="tx-dim">${esc(this._t('loading'))}</p></div>`;
  }

  async _loadBooks(id) {
    const c = this._index().concept.get(id);
    if (!c || !c.books_any) return;
    if (!this.booksCache) this.booksCache = new Map();
    let list = this.booksCache.get(id);
    if (!list) {
      try {
        const res = await this.auth.fetch('/api/tactic-plans/taxonomy/books?concept=' + id);
        list = res.ok ? await res.json() : null;
      } catch (_) { list = null; }
      if (list) this.booksCache.set(id, list);
    }
    const host = this.find(`[data-tx-books="${id}"]`);
    if (!host) return;
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    if (!list) { host.innerHTML = `<p>${esc(this._t('failed'))}</p>`; return; }
    const byBook = new Map();
    for (const p of list) { if (!byBook.has(p.book)) byBook.set(p.book, []); byBook.get(p.book).push(p); }
    host.innerHTML = [...byBook].map(([book, ps]) => `<div class="tx-principle">${esc(book)} <span class="tx-dim">${ps.length}</span></div><ul class="tx-list">`
      + ps.map(p => `<li><strong>${esc(p.title)}</strong>${p.main ? '' : ` <span class="tx-chip off">${esc(this._t('book_also'))}</span>`}${p.fit === 'loose' ? ` <span class="tx-chip off">${esc(this._t('book_loose'))}</span>` : ''}
          <span class="tx-dim">${esc(this._t('book_pages', { from: p.from, to: p.to }))}${p.vs ? ' · vs ' + esc(p.vs) : ''}</span><br>${esc(p.situation)}${p.outcome ? ` <span class="tx-dim">→ ${esc(p.outcome)}</span>` : ''}</li>`).join('') + `</ul>`).join('');
  }

  async _loadDb(id) {
    if (!this.dbCache) this.dbCache = new Map();
    let db = this.dbCache.get(id);
    if (!db) {
      try {
        const res = await this.auth.fetch('/api/tactic-plans/taxonomy/db?concept=' + id);
        db = res.ok ? await res.json() : null;
      } catch (_) { db = null; }
      if (db) this.dbCache.set(id, db);
    }
    const host = this.find(`[data-tx-db="${id}"]`);
    if (!host) return;
    const esc = (v) => this.escapeHtml(String(v == null ? '' : v));
    host.innerHTML = db ? this._dbHtml(id, db, esc) : `<p>${esc(this._t('failed'))}</p>`;
  }

  // A cell: a key into game_concepts / the behaviour index / a class becomes a link.
  _dbCell(table, col, v, selfId, esc) {
    if (v == null) return '<span class="tx-dim">—</span>';
    const ix = this._index(), text = typeof v === 'object' ? JSON.stringify(v) : String(v);
    if (col.ref === 'game_concepts.id' && Number(v) !== selfId && ix.concept.has(Number(v))) return this._conceptLink(ix.concept.get(Number(v)), esc);
    if (table === 'game_engine_behaviours' && col.name === 'code' && ix.beh.has(text)) return `<button type="button" class="tx-link tx-code" data-tx-open="behaviour" data-k="${esc(text)}">${esc(text)}</button>`;
    if (col.name === 'class_name' && ix.cls.has(text)) return this._classLink(text, esc);
    return esc(text.length > 220 ? text.slice(0, 220) + '…' : text);
  }
  _dbKey(col) { return col.pk ? '🔑' : col.ref ? '🔗' : col.unique ? '◇' : ''; }

  // One row as the table's columns down the side: key · column · type · value · points to.
  _dbRowHtml(info, row, selfId, esc) {
    return `<div class="tx-scroll"><table class="tx-tbl"><thead><tr><th></th><th>${esc(this._t('db_col'))}</th><th>${esc(this._t('db_type'))}</th><th>${esc(this._t('db_value'))}</th><th>${esc(this._t('db_ref'))}</th></tr></thead><tbody>`
      + info.columns.map(col => `<tr><td>${this._dbKey(col)}</td><td class="tx-code">${esc(col.name)}</td><td class="tx-dim tx-code">${esc(col.type)}${col.notnull ? '' : ' ?'}</td>
          <td>${row ? this._dbCell(info.name, col, row[col.name], selfId, esc) : ''}</td><td class="tx-code">${col.ref ? '→ ' + esc(col.ref) : ''}</td></tr>`).join('')
      + `</tbody></table></div>`;
  }

  _dbHtml(id, db, esc) {
    const used = db.pointed_at_by.filter(t => t.count > 0), empty = db.pointed_at_by.filter(t => !t.count);
    let html = `<div style="font-size:0.84rem; margin-top:8px; max-width:75ch;">${esc(this._t('db_norm', { cols: db.table.columns.length, out: db.points_to.length, tables: db.pointed_at_by.length, used: used.length }))}</div>
      <div class="tx-dim" style="font-size:0.74rem; margin-top:4px;">${esc(this._t('db_key_legend'))}</div>
      <h4>${esc(this._t('db_s_table'))}</h4><div class="tx-tname">game_concepts</div>` + this._dbRowHtml(db.table, db.row, id, esc);
    if (db.points_to.length) {
      html += `<h4>${esc(this._t('db_s_out'))}</h4>`;
      for (const p of db.points_to) html += `<div class="tx-tname">${esc(p.column)} → ${esc(p.table.name)}.${esc(p.ref_column)}</div>` + this._dbRowHtml(p.table, p.row, id, esc);
    }
    html += `<h4>${esc(this._t('db_s_in'))}</h4>`;
    for (const t of used) {
      // the rows across; the column that points here is dropped (it is this concept on every row)
      const cols = t.table.columns.filter(col => col.name !== t.column);
      html += `<div class="tx-tname">${esc(t.table.name)}.${esc(t.column)} → game_concepts <span class="tx-dim" style="font-weight:400;">· ${esc(this._t('db_rows', { n: t.count }))}</span></div>
        <div class="tx-scroll"><table class="tx-tbl"><thead><tr>${cols.map(col => `<th class="tx-code">${this._dbKey(col)} ${esc(col.name)}</th>`).join('')}</tr></thead>
        <tbody>${t.rows.map(r => `<tr>${cols.map(col => `<td>${this._dbCell(t.table.name, col, r[col.name], id, esc)}</td>`).join('')}</tr>`).join('')}</tbody></table></div>
        ${t.count > t.rows.length ? `<div class="tx-dim" style="font-size:0.74rem;">${esc(this._t('db_more', { n: t.count - t.rows.length }))}</div>` : ''}`;
    }
    if (empty.length) html += `<h4>${esc(this._t('db_s_empty'))}</h4><div class="tx-code" style="font-size:0.78rem; line-height:1.7;">${empty.map(t => `${esc(t.table.name)}.${esc(t.column)}`).join('<br>')}</div>`;
    return html;
  }

  _behaviourSheet(code, esc) {
    const ix = this._index(), b = ix.beh.get(code);
    if (!b) return '';
    const c = b.concept_id != null ? ix.concept.get(b.concept_id) : null;
    const others = (b.other || '').split(/,\s*/).filter(Boolean).map(n => ix.byName.get(n) ? this._conceptLink(ix.byName.get(n), esc) : esc(n)).join(', ');
    this._want = { file: b.file, from: Math.max(1, b.line - 6), to: b.line + 44, hit: b.line };
    return `<h3>${esc(b.what)}</h3><div class="tx-dim tx-code">game_engine_behaviours · ${esc(b.code)}</div>
      <h4>${esc(this._t('s_row'))}</h4>` + this._kv([
        [this._t('f_standing'), this._t('beh_' + b.status)], [this._t('f_concept'), c ? this._conceptLink(c, esc) : null, true],
        [this._t('f_suggested'), b.suggested], [this._t(c ? 'f_also' : 'f_nearest'), others || null, true],
        [this._t('f_kind'), b.read ? this._t('beh_is_read') : this._t('beh_is_act')], [this._t('f_who'), this._t('family_' + b.who) || b.who],
        [this._t('f_confidence'), b.confidence], [this._t('f_slice'), b.tag],
        [this._t('f_class'), b.class ? this._classLink(b.class, esc) : null, true], [this._t('f_symbol'), b.symbol],
        [this._t('f_where'), `${b.file}:${b.line}`]], esc)
      + `<h4>${esc(this._t('s_source'))}</h4><pre class="tx-src" data-tx-src>${esc(this._t('loading'))}</pre>`;
  }

  _classSheet(name, esc) {
    const ix = this._index(), k = ix.cls.get(name);
    if (!k) return `<h3 class="tx-code">${esc(name)}</h3>`;
    const chain = [];
    for (let p = k.parent, n = 0; p && n < 12; n++) { chain.push(p); p = ix.cls.has(p) ? ix.cls.get(p).parent : null; }
    const kids = (ix.kids.get(name) || []).slice().sort(), behs = ix.behIn.get(name) || [];
    this._want = { file: k.file, from: k.from, to: k.to, hit: 0 };
    return `<h3 class="tx-code">${esc(k.kind)} ${esc(name)}</h3>
      <div class="tx-crumb">${[name].concat(chain).map((n, i) => i === 0 ? `<strong class="tx-code">${esc(n)}</strong>` : this._classLink(n, esc)).join(' <span class="tx-dim">→</span> ')}</div>
      ` + this._kv([[this._t('f_parent'), k.parent ? this._classLink(k.parent, esc) : this._t('none_parent'), !!k.parent],
                    [this._t('f_children'), kids.length ? kids.map(n => this._classLink(n, esc)).join(', ') : null, true],
                    [this._t('f_where'), `${k.file}:${k.from}–${k.to}`]], esc)
      + (k.doc ? `<h4>${esc(this._t('s_doc'))}</h4><div style="white-space:pre-wrap; font-size:0.84rem;">${esc(k.doc)}</div>` : '')
      + (behs.length ? `<h4>${esc(this._t('s_behaviours_in'))}</h4>` + behs.map(b => this._behaviourRow(b, esc)).join('') : '')
      + `<h4>${esc(this._t('s_source'))}</h4><pre class="tx-src" data-tx-src>${esc(this._t('loading'))}</pre>`;
  }

  // The C++ for the open sheet (game_engine_sources, via the backend).
  async _loadSource() {
    const want = this._want, pre = this.find('[data-tx-src]');
    if (!want || !pre) return;
    const key = `${want.file}:${want.from}:${want.to}`;
    let src = this.sourceCache.get(key);
    if (!src) {
      try {
        const res = await this.auth.fetch('/api/tactic-plans/taxonomy/source?' + new URLSearchParams({ file: want.file, from: want.from, to: want.to }));
        src = res.ok ? await res.json() : null;
      } catch (_) { src = null; }
      if (src) this.sourceCache.set(key, src);
    }
    const now = this.find('[data-tx-src]');
    if (!now || this._want !== want) return;
    if (!src) { now.textContent = this._t('no_source'); return; }
    const esc = (v) => this.escapeHtml(String(v));
    now.innerHTML = src.text.split('\n').map((line, i) => {
      const n = src.from + i;
      return `<span class="${n === want.hit ? 'hit' : ''}"><span class="ln">${n}</span>${esc(line)}</span>`;
    }).join('\n');
    const hit = now.querySelector('.hit');
    if (hit) now.scrollTop = Math.max(0, hit.offsetTop - now.offsetTop - 60);
  }
}
