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
// 📏 Roles, measures, Laws, placement rules · ⚙️ Engine (its own C++ vocabulary, mirrored
// in game_engine_terms).  Read-only.  One fetch: GET /api/tactic-plans/taxonomy.
// Every word is message_templates kind 'taxonomy'; the content is the tables' own.
class FootballTaxonomyScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null;
    this.error = false;
    this.tab = 'concepts';
    this.moment = '';       // '' = every moment
    this.reach = 'all';     // all | played | placed | job | named
    this.search = '';
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
        .tx-title { font-weight:700; font-size:0.9rem; }
        .tx-meta { font-size:0.72rem; opacity:0.75; margin-top:2px; }
        .tx-cue { font-size:0.8rem; margin-top:4px; opacity:0.9; }
        .tx-line { font-size:0.74rem; margin-top:4px; }
        .tx-h { margin: 18px 0 6px; font-size:0.95rem; font-weight:800; }
        .tx-list { margin:0; padding-left: 18px; font-size:0.85rem; line-height:1.55; }
        .tx-list ul { padding-left: 18px; }
        .tx-dim { opacity:0.7; }
      </style>
      <div class="tx-wrap" id="tx-body"></div>`;
    this.element = div;
    div.addEventListener('click', (e) => {
      const b = e.target.closest('[data-tx]');
      if (!b) return;
      const [k, v] = [b.dataset.tx, b.dataset.v];
      if (k === 'tab') this.tab = v;
      else if (k === 'moment') this.moment = v;
      else if (k === 'reach') this.reach = v;
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
    Promise.all([copy, this.data ? null : this._load()]).then(() => this._render());
  }

  async _load() {
    this.error = false;
    try {
      const res = await this.auth.fetch('/api/tactic-plans/taxonomy');
      if (!res.ok) throw new Error('HTTP ' + res.status);
      this.data = await res.json();
    } catch (_) { this.error = true; }
  }

  // How far a concept reaches.
  _reach(c) {
    if (c.act) return 'played';
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
    if (this.error) { el.innerHTML = head + `<p>${esc(this._t('failed'))}</p>`; return; }
    if (!this.data) { el.innerHTML = head + `<p class="tx-dim">${esc(this._t('loading'))}</p>`; return; }
    const d = this.data;
    const tabs = [['concepts', this._t('tab_concepts'), (d.concepts || []).length], ['techniques', this._t('tab_techniques'), (d.techniques || []).length],
                  ['more', this._t('tab_more'), null], ['engine', this._t('tab_engine'), null]]
      .map(([k, label, n]) => `<button type="button" class="tx-pill ${this.tab === k ? 'on' : ''}" data-tx="tab" data-v="${k}">${esc(label)}${n != null ? `<span class="n">${n}</span>` : ''}</button>`).join('');
    let body = '';
    if (this.tab === 'concepts') body = this._conceptsHtml(esc);
    else if (this.tab === 'techniques') body = this._techniquesHtml(esc);
    else if (this.tab === 'more') body = this._moreHtml(esc);
    else body = this._engineHtml(esc);
    el.innerHTML = head + `<div class="tx-pills">${tabs}</div>` + body;
    if (this.tab === 'concepts') this._renderConceptList();
  }

  // ── 🧠 Concepts ────────────────────────────────────────────────────────
  _conceptsHtml(esc) {
    const d = this.data, all = d.concepts || [];
    const inMoment = all.filter(c => !this.moment || c.moment === this.moment);
    const count = (r) => inMoment.filter(c => r === 'all' || this._reach(c) === r).length;
    const moments = [['', this._t('moment_all'), all.length]].concat((d.moments || []).map(m => [m.code, m.title, all.filter(c => c.moment === m.code).length]))
      .map(([k, label, n]) => `<button type="button" class="tx-pill ${this.moment === k ? 'on' : ''}" data-tx="moment" data-v="${esc(k)}">${esc(label)}<span class="n">${n}</span></button>`).join('');
    const reaches = ['all', 'played', 'placed', 'job', 'named']
      .map(r => `<button type="button" class="tx-pill ${this.reach === r ? 'on' : ''}" data-tx="reach" data-v="${r}">${esc(this._t('reach_' + r))}<span class="n">${count(r)}</span></button>`).join('');
    return `<div class="tx-pills">${moments}</div><div class="tx-pills">${reaches}</div>
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
    const shown = (d.concepts || []).filter(c => (!this.moment || c.moment === this.moment)
      && (this.reach === 'all' || this._reach(c) === this.reach)
      && (!q || (c.title + ' ' + c.name + ' ' + (c.cue || '')).toLowerCase().includes(q)));
    const card = (c) => {
      const reach = this._reach(c);
      const fam = this._t('family_' + c.family) || c.family;
      return `<div class="tx-card" data-reach="${reach}">
        <div class="tx-title">${esc(c.title)}</div>
        <div class="tx-meta">${esc(this._t('reach_' + reach))} · ${esc(fam)}${c.sources ? ' · ' + esc(this._t('sources', { n: c.sources })) : ''}</div>
        ${c.cue ? `<div class="tx-cue">${esc(c.cue)}</div>` : ''}
        ${reach === 'placed' ? `<div class="tx-line">${esc(this._t('placed_by', { rule: rules[c.rule] || c.rule }))}</div>` : ''}
        ${reach === 'played' ? `<div class="tx-line">${esc(this._t('played_by', { note: c.act_note || c.act }))}</div>` : ''}
      </div>`;
    };
    let html = `<div class="tx-dim" style="font-size:0.78rem; margin-top:8px;">${esc(this._t('count', { n: shown.length, total: (d.concepts || []).length }))}</div>`;
    for (const m of d.moments || []) {
      const mine = shown.filter(c => c.moment === m.code);
      if (!mine.length) continue;
      html += `<div class="tx-moment">${esc(m.title)}</div>`;
      const groups = (d.principles || []).filter(p => p.moment === m.code).map(p => [p.title, mine.filter(c => c.principle_id === p.id)]);
      const known = new Set((d.principles || []).filter(p => p.moment === m.code).map(p => p.id));
      groups.push([this._t('no_principle'), mine.filter(c => !known.has(c.principle_id))]);
      for (const [title, list] of groups) {
        if (!list.length) continue;
        html += `<div class="tx-principle">${esc(title)}</div><div class="tx-grid">${list.map(card).join('')}</div>`;
      }
    }
    el.innerHTML = html;
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

  // ── ⚙️ Engine: its own vocabulary, and the concepts it plays ───────────
  _engineHtml(esc) {
    const d = this.data, terms = d.engine || [];
    const sec = (kind) => {
      const rows = terms.filter(t => t.kind === kind);
      if (!rows.length) return '';
      return `<div class="tx-h">${esc(this._t('h_' + kind))} <span class="tx-dim">${rows.length}</span></div>
        <ul class="tx-list">${rows.map(t => `<li>${esc(t.title)}${t.note ? ` <span class="tx-dim">— ${esc(t.note)}</span>` : ''}</li>`).join('')}</ul>`;
    };
    const played = (d.concepts || []).filter(c => c.act);
    return `<div class="tx-dim" style="font-size:0.85rem; max-width:75ch;">${esc(this._t('engine_intro'))}</div>
      <div class="tx-h">${esc(this._t('reach_played'))} <span class="tx-dim">${played.length}</span></div>
      <ul class="tx-list">${played.map(c => `<li><strong>${esc(c.title)}</strong> <span class="tx-dim">— ${esc(c.act_note || '')}</span></li>`).join('')}</ul>
      ${sec('phase')}${sec('state')}${sec('decision')}${sec('role')}`;
  }
}
