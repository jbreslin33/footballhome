// apsl-pyramid.js — #apsl: the APSL pyramid as a flow chart (migrations
// 819, 823).  Owner 2026-10-29: "i want the conference shown in a container
// with relegation and playoff spots in red and green. then under it are the
// feeder leagues connected by arrows like a flow chart … same format for all
// conferences … use pill format. so 'All' for all conferences. then each one
// able to be turned on or off."
//
// GET /api/pyramid: competitions (APSL → conferences → affiliates), every
// mirrored table with its zones and standings, and the arrows between
// tables (pyramid_links: one link carries promotion up and relegation down;
// zone colour + meaning are pyramid_zone_kinds rows).  ONE chart (owner: "apsl conferences are all at
// same level"): the conferences side by side on the top row, each with its
// own tables in a container, and each level of feeder tables in the rows
// below, under the conference it feeds.  A table that feeds two
// conferences (North Jersey Liga 1 → Delaware River + Metropolitan) sits
// once, with an arrow to each.  Arrows are an SVG overlay measured from the
// laid-out boxes, redrawn on resize.  Wording: message_templates kind
// 'apsl_pyramid'.
class ApslPyramidScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.data = null; this.err = ''; this.loading = false;
    this.on = null;              // Set of conference ids shown; null = all
    try {
      const saved = JSON.parse(localStorage.getItem('apsl-pyramid-on') || 'null');
      if (Array.isArray(saved)) this.on = new Set(saved);
    } catch (_) { /* private mode */ }
    this._onResize = () => { clearTimeout(this._rt); this._rt = setTimeout(() => this._drawArrows(), 120); };
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('apsl_pyramid', tier, tokens) : ''; }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .ap-totals { text-align:center; font-size:1.2rem; font-weight:800; margin:var(--space-2) 0 var(--space-3); }
        .ap-pills { display:flex; gap:6px; justify-content:center; flex-wrap:wrap; margin-bottom:var(--space-3); }
        .ap-pill { padding:5px 14px; border-radius:999px; border:1px solid var(--border-color, #374151); background:transparent; color:inherit; font-weight:700; font-size:0.85rem; cursor:pointer; min-height:0; min-width:0; }
        .ap-pill.on { background:var(--primary-color, #2563eb); border-color:var(--primary-color, #2563eb); color:#fff; }
        .fc-scroll { overflow-x:auto; padding-bottom:var(--space-4); }
        .fc-chart { position:relative; display:grid; column-gap:22px; row-gap:46px; width:max-content; margin:0 auto; align-items:start; justify-items:center; }
        .fc-arrows { position:absolute; left:0; top:0; pointer-events:none; overflow:visible; z-index:0; }
        .fc-cell { display:flex; gap:10px; justify-content:center; position:relative; z-index:1; }
        .fc-conf { border:2px solid #2563eb; border-radius:14px; padding:10px; background:rgba(37,99,235,0.08); position:relative; z-index:1; }
        .fc-conf h2 { margin:0; font-size:1.1rem; text-align:center; }
        .fc-meta { font-size:0.78rem; opacity:0.7; text-align:center; margin:2px 0 8px; }
        .fc-meta a { color:#93c5fd; }
        .fc-tbl { background:var(--card-bg, #111827); border:1px solid var(--border-color, #374151); border-radius:10px; padding:6px 6px 4px; width:230px; }
        .fc-conf .fc-tbl { border-color:#1d4ed8; }
        .fc-tbl.feeder { border-color:#0f766e; }
        .fc-tbl .hd { font-weight:800; font-size:0.82rem; text-align:center; margin-bottom:3px; }
        .fc-tbl .hd .lg { opacity:0.65; font-weight:600; }
        .fc-tbl .note { font-size:0.7rem; opacity:0.65; text-align:center; margin-top:3px; }
        .fc-tbl.empty { opacity:0.6; font-size:0.78rem; text-align:center; padding:10px 6px; }
        .fc-tbl table { width:100%; border-collapse:collapse; font-size:0.76rem; }
        .fc-tbl th { font-size:0.66rem; opacity:0.6; font-weight:700; padding:1px 3px; text-align:center; }
        .fc-tbl td { padding:2px 3px; text-align:center; border-top:1px solid rgba(255,255,255,0.06); white-space:nowrap; }
        .fc-tbl td.tm, .fc-tbl th.tm { text-align:left; white-space:normal; width:100%; }
        .fc-tbl tr.ours td { font-weight:800; color:#fde68a; }
        .fc-tbl tr.z td:first-child { box-shadow:inset 4px 0 var(--zc); }
        .fc-tbl tr.z td { background:color-mix(in srgb, var(--zc) 20%, transparent); }
        .fc-legend { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; font-size:0.75rem; opacity:0.85; margin:-4px 0 12px; }
        .fc-legend i { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:4px; vertical-align:-1px; }
        .fc-none { text-align:center; font-size:0.8rem; opacity:0.55; margin-top:14px; }
        .ap-warn { color:#fca5a5; }
        .fc-tbl { position:relative; }
        .fc-edit { position:absolute; top:3px; right:4px; background:none; border:0; color:inherit; opacity:0.45; cursor:pointer; font-size:0.75rem; padding:2px; min-height:0; min-width:0; }
        .fc-edit:hover { opacity:1; }
        .ap-editor-bg { position:fixed; inset:0; background:rgba(0,0,0,0.6); z-index:1000; display:flex; align-items:center; justify-content:center; padding:16px; }
        .ap-editor { background:var(--card-bg, #111827); border:1px solid var(--border-color, #374151); border-radius:12px; padding:16px; width:min(460px, 100%); max-height:90vh; overflow:auto; }
        .ap-editor h3 { margin:0 0 10px; font-size:1rem; }
        .ap-editor .sec { border-top:1px solid var(--border-color, #374151); padding:10px 0; }
        .ap-editor .sec b { display:block; margin-bottom:6px; }
        .ap-editor label { margin-right:12px; font-size:0.88rem; }
        .ap-editor .hint { font-size:0.75rem; opacity:0.65; margin:4px 0; }
        .ap-editor .zr { display:flex; gap:6px; align-items:center; margin:6px 0; font-size:0.85rem; }
        .ap-editor .zr select { flex:1; min-width:0; }
        .ap-editor .zr input { width:52px; }
        .ap-editor .btns { display:flex; gap:8px; justify-content:flex-end; margin-top:10px; }
        .ap-editor .err { color:#fca5a5; font-size:0.82rem; }
      </style>
      <div class="screen-header" style="display:flex; align-items:center; gap:var(--space-3);">
        <button class="btn btn-secondary" id="ap-back">← Back</button>
        <div style="flex:1; min-width:0;"><h1 style="margin:0;" id="ap-title">🔺 APSL Pyramid</h1><div id="ap-sub" style="font-size:0.85rem; opacity:0.75;"></div></div>
        <button class="btn btn-secondary" id="ap-refresh" style="padding:4px 12px; font-size:0.85rem;">🔄</button>
      </div>
      <div class="screen-content" style="max-width:1400px; margin:0 auto;">
        <div id="ap-moves"></div>
        <div id="ap-body"><div class="loading">Loading…</div></div>
      </div>`;
    this.element = div;
    div.querySelector('#ap-back').addEventListener('click', () => this.navigation.goBack());
    div.querySelector('#ap-refresh').addEventListener('click', () => this.load(true));
    div.querySelector('#ap-body').addEventListener('click', (e) => {
      const pill = e.target.closest('[data-conf]');
      if (pill) { this._toggle(pill.dataset.conf); return; }
      const edit = e.target.closest('[data-edit]');
      if (edit) { this._openEditor(Number(edit.dataset.edit)); return; }
      const act = e.target.closest('[data-ed]');
      if (act) this._editorAction(act);
    });
    div.querySelector('#ap-body').addEventListener('change', (e) => {
      if (e.target.closest('.ap-editor')) this._editorRead();
    });
    return div;
  }

  onEnter() {
    window.addEventListener('resize', this._onResize);
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => {
      const t = this.find('#ap-title'); if (t && this._copy('title')) t.textContent = this._copy('title');
      const s = this.find('#ap-sub'); if (s) s.textContent = this._copy('subtitle');
      if (this.data) this._renderBody();
    });
    this.load(false);
    // ✉️ roster moves for the commissioner (mig 829, league-moves-mail.js)
    if (window.LeagueMovesMail) {
      this._moves = this._moves || new LeagueMovesMail(this, this.find('#ap-moves'));
      this._moves.load();
    }
  }

  onExit() { window.removeEventListener('resize', this._onResize); }

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

  // ── pills ────────────────────────────────────────────────────────────
  _conferences() { return (this.data.competitions || []).filter((c) => c.kind === 'conference'); }
  _isOn(id) { return !this.on || this.on.has(id); }
  _toggle(key) {
    const all = this._conferences().map((c) => c.id);
    if (key === 'all') this.on = null;
    else {
      const id = Number(key);
      const set = this.on ? new Set(this.on) : new Set(all);
      if (set.has(id)) set.delete(id); else set.add(id);
      this.on = set.size === all.length ? null : set;
    }
    try { localStorage.setItem('apsl-pyramid-on', JSON.stringify(this.on ? [...this.on] : null)); } catch (_) { /* private mode */ }
    this._renderBody();
  }

  // ── the chart: conferences on one row, feeder levels below ──────────
  // Each conference is a column; its feeders stack under it, level by level
  // (walking the arrows down).  A table that feeds two conferences sits in
  // the first one's column, once, with an arrow to each.  Rows are shared
  // across columns, so every level lines up.
  _layout(confs) {
    const divs = this.data.divisions || [];
    const links = this.data.links || [];
    const byId = new Map(divs.map((d) => [d.id, d]));
    const compOrder = new Map((this.data.competitions || []).map((c, i) => [c.id, i]));
    const confIds = new Set(confs.map((c) => c.id));
    const mirrored = new Set(divs.map((d) => d.competition_id));
    const placed = new Set();
    const edges = [];
    const columns = confs.map((conf) => {
      const levels = [];
      let current = links.filter((l) => l.upper_competition === conf.id && byId.has(l.lower)).map((l) => l.lower);
      current = [...new Set(current)].filter((id) => !placed.has(id));
      current.sort((a, b) => (compOrder.get(byId.get(a).competition_id) - compOrder.get(byId.get(b).competition_id)) || byId.get(a).name.localeCompare(byId.get(b).name));
      while (current.length) {
        current.forEach((id) => placed.add(id));
        levels.push(current);
        const next = [];
        for (const target of current)
          for (const l of links)
            if (l.upper_division === target && byId.has(l.lower) && !placed.has(l.lower) && !next.includes(l.lower)) next.push(l.lower);
        current = next;
      }
      // Every table feeding this conference, shared ones too — its counts.
      const reach = new Set(links.filter((l) => l.upper_competition === conf.id).map((l) => l.lower));
      for (let grew = true; grew;) {
        grew = false;
        for (const l of links) if (l.upper_division && reach.has(l.upper_division) && !reach.has(l.lower)) { reach.add(l.lower); grew = true; }
      }
      return {
        conf, levels,
        top: divs.filter((d) => d.competition_id === conf.id),
        reach: [...reach].map((id) => byId.get(id)).filter(Boolean),
        unmirrored: (this.data.competitions || []).filter((c) => c.parent_id === conf.id && !mirrored.has(c.id)),
      };
    });
    // One arrow per link: head up if it promotes, head down if it relegates.
    for (const l of links) {
      if (!placed.has(l.lower)) continue;
      const e = { from: l.lower, up: l.promotes, down: l.relegates };
      if (l.upper_competition && confIds.has(l.upper_competition)) edges.push({ ...e, to: `c${l.upper_competition}` });
      else if (l.upper_division && placed.has(l.upper_division)) edges.push({ ...e, to: `d${l.upper_division}` });
    }
    return { columns, edges, byId, depth: Math.max(0, ...columns.map((c) => c.levels.length + (c.unmirrored.length && !c.levels.length ? 1 : 0))) };
  }

  // Zone meaning and colour are pyramid_zone_kinds rows (mig 827).
  _kindColor(code) { const k = (this.data.zone_kinds || []).find((x) => x.code === code); return k ? k.color : '#64748b'; }
  _zoneOf(d, pos) { return (d.zones || []).find((x) => pos >= x.from && pos <= x.to) || null; }

  _tableHtml(d, title, cls, note) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const cols = (this._copy('table_head') || '').split(/\s+/).filter(Boolean);
    const head = cols.map((c, i) => `<th${i === 1 ? ' class="tm"' : ''}>${esc(c === '-' ? '' : c)}</th>`).join('');
    const rows = (d.teams || []).map((t) => {
      const z = this._zoneOf(d, t.pos);
      const tip = z ? (z.targets ? this._copy('moves_to', { zone: z.label, targets: z.targets }) : z.label) : '';
      return `
      <tr class="${t.ours ? 'ours' : ''} ${z ? 'z' : ''}"${z ? ` style="--zc:${esc(z.color)}" title="${esc(tip)}"` : ''}>
        <td>${t.pos == null ? '' : esc(t.pos)}</td><td class="tm">${esc(t.name)}</td>
        <td>${t.gp}</td><td>${t.gd > 0 ? '+' : ''}${t.gd}</td><td><b>${t.pts}</b></td>
      </tr>`;
    }).join('');
    return `
      <div class="fc-tbl ${cls}" data-div="${d.id}">
        <button class="fc-edit" data-edit="${d.id}" title="${esc(this._copy('edit_hint'))}">✏️</button>
        ${title ? `<div class="hd">${title}</div>` : ''}
        <table><thead><tr>${head}</tr></thead><tbody>${rows}</tbody></table>
        ${note ? `<div class="note">${esc(note)}</div>` : ''}
      </div>`;
  }

  _confHtml(col) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const comps = new Map((this.data.competitions || []).map((c) => [c.id, c]));
    const conf = col.conf;
    const counted = [...col.top, ...col.reach].filter((d) => d.counts);
    const teams = counted.reduce((a, d) => a + d.teams.length, 0);
    const clubs = new Set(counted.flatMap((d) => d.teams.map((t) => t.club))).size;
    const root = comps.get(conf.parent_id);
    const src = root && root.source;
    let meta = esc((conf.states || []).join(' · '));
    if (teams) meta += ` · ${esc(this._copy('node_counts', { clubs, teams }))}`;
    if (src && src.ok === false) meta += `<br><span class="ap-warn">${esc(this._copy('stale', { when: src.ok_at || '—' }))}</span>`;
    if (conf.standings_url) meta += ` · <a href="${esc(conf.standings_url)}" target="_blank" rel="noopener">${esc(this._copy('site_link'))}</a>`;
    // A conference's own tables: one, or its groups / sides — titled by the
    // part after the conference name ("Group A", "Chesapeake (Maryland)").
    const tables = col.top.map((d) => {
      const part = col.top.length > 1 ? (d.name.split(/\s-\s?/).slice(1).join(' - ') || d.name) : '';
      return this._tableHtml(d, part ? esc(part) : '', '', '');
    }).join('');
    return `
      <div class="fc-conf" data-node="c${conf.id}">
        <h2>${esc(conf.short_name || conf.name)}</h2>
        <div class="fc-meta">${meta}</div>
        <div class="fc-cell">${tables}</div>
      </div>`;
  }

  _chartHtml(confs) {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const comps = new Map((this.data.competitions || []).map((c) => [c.id, c]));
    const L = this._layout(confs);
    const links = this.data.links || [];
    const cells = [];
    L.columns.forEach((col, ci) => {
      cells.push(`<div style="grid-column:${ci + 1}; grid-row:1;">${this._confHtml(col)}</div>`);
      const rows = col.levels.map((ids) => ids.map((id) => {
        const d = L.byId.get(id);
        const lg = comps.get(d.competition_id);
        const fed = links.filter((l) => l.lower === id && l.upper_competition).map((l) => comps.get(l.upper_competition)).filter(Boolean);
        const note = fed.length > 1 ? this._copy('also_feeds', { conference: fed.filter((c) => c.id !== col.conf.id).map((c) => c.short_name || c.name).join(', ') }) : '';
        const title = `<span class="lg">${esc(lg ? (lg.short_name || lg.name) : '')}</span> · ${esc(d.name)}`;
        return this._tableHtml(d, title, 'feeder', note);
      }));
      const empty = col.unmirrored.map((c) => `<div class="fc-tbl feeder empty">${esc(this._copy('not_mirrored', { league: c.short_name || c.name }))}</div>`);
      if (empty.length) { if (rows.length) rows[0].push(...empty); else rows.push(empty); }
      rows.forEach((boxes, li) => cells.push(`<div class="fc-cell lv" style="grid-column:${ci + 1}; grid-row:${li + 2};">${boxes.join('')}</div>`));
    });
    const zones = new Map();
    for (const d of this.data.divisions || []) for (const z of d.zones || []) if (!zones.has(z.kind)) zones.set(z.kind, z);
    // Legend names the KIND (pyramid_zone_kinds); a row's tooltip keeps the
    // league's own wording for its zone.
    const kindLabel = (code) => ((this.data.zone_kinds || []).find((k) => k.code === code) || {}).label || code;
    const rank = new Map((this.data.zone_kinds || []).map((k, i) => [k.code, i]));
    const legend = [...zones.values()].sort((a, b) => (rank.get(a.kind) ?? 99) - (rank.get(b.kind) ?? 99)).map((z) => `<span><i style="background:${esc(z.color)}"></i>${esc(kindLabel(z.kind))}</span>`)
      .concat([`<span><b style="color:${esc(this._kindColor('promotion'))}">▲</b> ${esc(this._copy('arrow_up'))}</span>`,
               `<span><b style="color:${esc(this._kindColor('relegation'))}">▼</b> ${esc(this._copy('arrow_down'))}</span>`]).join('');
    return `
      ${legend ? `<div class="fc-legend">${legend}</div>` : ''}
      <div class="fc-scroll">
        <div class="fc-chart" style="grid-template-columns:repeat(${confs.length}, max-content);">
          <svg class="fc-arrows"></svg>
          ${cells.join('')}
        </div>
      </div>`;
  }

  _renderBody() {
    const el = this.find('#ap-body');
    if (!el) return;
    if (this.loading && !this.data) { el.innerHTML = '<div class="loading">Loading…</div>'; return; }
    if (this.err) { el.innerHTML = `<div class="error">${this.escapeHtml(this.err)}</div>`; return; }
    if (!this.data) return;
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const confs = this._conferences();
    const pills = [`<button class="ap-pill ${!this.on ? 'on' : ''}" data-conf="all">${esc(this._copy('pill_all'))}</button>`]
      .concat(confs.map((c) => `<button class="ap-pill ${this.on && this.on.has(c.id) ? 'on' : ''}" data-conf="${c.id}">${esc(c.short_name || c.name)}</button>`))
      .join('');
    const shown = confs.filter((c) => this._isOn(c.id));
    el.innerHTML = `
      <div class="ap-totals">${esc(this._copy('totals', this.data.totals || {}))}</div>
      <div class="ap-pills">${pills}</div>
      ${this.loading ? '<div class="loading" style="text-align:center;">Refreshing…</div>' : ''}
      ${shown.length ? this._chartHtml(shown) : `<div class="fc-none">${esc(this._copy('none_on'))}</div>`}
      ${this.edit ? this._editorHtml() : ''}`;
    requestAnimationFrame(() => this._drawArrows());
  }

  // ── ✏️ override editor (mig 828) ─────────────────────────────────────
  // Per direction: Default rules (pyramid_zone_rules defaults), None, or
  // this table's own zones.  Save = POST /api/pyramid/zone-rules per side.
  _openEditor(divId) {
    const d = (this.data.divisions || []).find((x) => x.id === divId);
    if (!d) return;
    const side = (dir) => {
      const o = d.overrides ? d.overrides[dir] : null;
      if (o == null) return { mode: 'default', zones: [] };
      if (!o.length) return { mode: 'none', zones: [] };
      return { mode: 'custom', zones: o.map((z) => ({ ...z })) };
    };
    this.edit = { divId, up: side('up'), down: side('down'), err: '', saving: false };
    this._renderBody();
  }

  _editorRead() {
    const box = this.find('.ap-editor');
    if (!box || !this.edit) return;
    for (const dir of ['up', 'down']) {
      const m = box.querySelector(`input[name="m-${dir}"]:checked`);
      if (m) this.edit[dir].mode = m.value;
      this.edit[dir].zones = [...box.querySelectorAll(`.zr[data-dir="${dir}"]`)].map((r) => ({
        kind: r.querySelector('select').value,
        from: Number(r.querySelector('[data-f]').value),
        to: Number(r.querySelector('[data-t]').value),
      }));
    }
  }

  async _editorAction(el) {
    if (!this.edit) return;
    this._editorRead();
    const act = el.dataset.ed, dir = el.dataset.dir;
    if (act === 'cancel') { this.edit = null; this._renderBody(); return; }
    if (act === 'mode') { this._renderBody(); return; }
    if (act === 'add') {
      const kinds = (this.data.zone_kinds || []).filter((k) => k.moves === dir);
      this.edit[dir].mode = 'custom';
      this.edit[dir].zones.push({ kind: kinds[0] ? kinds[0].code : '', from: 1, to: 1 });
      this._renderBody(); return;
    }
    if (act === 'del') { this.edit[dir].zones.splice(Number(el.dataset.i), 1); this._renderBody(); return; }
    if (act === 'save') {
      this.edit.saving = true; this.edit.err = ''; this._renderBody();
      try {
        for (const side of ['up', 'down']) {
          const e = this.edit[side];
          const res = await this.auth.fetch('/api/pyramid/zone-rules', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ division_id: this.edit.divId, direction: side, mode: e.mode, zones: e.mode === 'custom' ? e.zones : [] }),
          });
          const body = await res.json().catch(() => ({}));
          if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
        }
        this.edit = null;
        await this.load(false);
      } catch (err) {
        if (this.edit) { this.edit.saving = false; this.edit.err = err.message || 'Save failed.'; this._renderBody(); }
      }
    }
  }

  _editorHtml() {
    const esc = (t) => this.escapeHtml(t == null ? '' : String(t));
    const d = (this.data.divisions || []).find((x) => x.id === this.edit.divId);
    if (!d) return '';
    const comp = (this.data.competitions || []).find((c) => c.id === d.competition_id);
    const kinds = this.data.zone_kinds || [];
    const kindLabel = (code) => (kinds.find((k) => k.code === code) || {}).label || code;
    const sec = (dir) => {
      const e = this.edit[dir];
      // What the defaults give this table today (origin 'default' zones).
      const defs = (d.zones || []).filter((z) => z.origin === 'default' && z.moves === dir)
        .map((z) => `${kindLabel(z.kind)} ${z.from === z.to ? z.from : `${z.from}–${z.to}`}`).join(', ');
      const radio = (mode, tier) => `<label><input type="radio" name="m-${dir}" value="${mode}" data-ed="mode" ${e.mode === mode ? 'checked' : ''}> ${esc(this._copy(tier))}</label>`;
      const rows = e.mode === 'custom' ? e.zones.map((z, i) => `
        <div class="zr" data-dir="${dir}">
          <select>${kinds.filter((k) => k.moves === dir).map((k) => `<option value="${esc(k.code)}" ${k.code === z.kind ? 'selected' : ''}>${esc(k.label)}</option>`).join('')}</select>
          ${esc(this._copy('place_from'))} <input type="number" min="1" data-f value="${esc(z.from)}">
          ${esc(this._copy('place_to'))} <input type="number" min="1" data-t value="${esc(z.to)}">
          <button class="btn btn-secondary" data-ed="del" data-dir="${dir}" data-i="${i}" style="padding:2px 8px; min-height:0;">✕</button>
        </div>`).join('') : '';
      return `
        <div class="sec">
          <b>${esc(this._copy(dir === 'up' ? 'edit_up' : 'edit_down'))}</b>
          ${radio('default', 'mode_default')}${radio('none', 'mode_none')}${radio('custom', 'mode_custom')}
          <div class="hint">${esc(defs ? this._copy('defaults_are', { zones: defs }) : this._copy('defaults_none'))}</div>
          ${rows}
          ${e.mode === 'custom' ? `<button class="btn btn-secondary" data-ed="add" data-dir="${dir}" style="padding:2px 10px; min-height:0; font-size:0.8rem;">${esc(this._copy('add_zone'))}</button>` : ''}
        </div>`;
    };
    const table = `${comp ? (comp.short_name || comp.name) + ' · ' : ''}${d.name}`;
    return `
      <div class="ap-editor-bg">
        <div class="ap-editor">
          <h3>${esc(this._copy('edit_title', { table }))}</h3>
          ${sec('up')}${sec('down')}
          ${this.edit.err ? `<div class="err">${esc(this.edit.err)}</div>` : ''}
          <div class="btns">
            <button class="btn btn-secondary" data-ed="cancel">${esc(this._copy('cancel'))}</button>
            <button class="btn btn-primary" data-ed="save" ${this.edit.saving ? 'disabled' : ''}>${esc(this._copy('save'))}</button>
          </div>
        </div>
      </div>`;
  }

  // ── arrows: lower table's top edge → its target's bottom edge ────────
  _drawArrows() {
    if (!this.data || !this.element) return;
    const chart = this.element.querySelector('.fc-chart');
    const svg = chart && chart.querySelector('.fc-arrows');
    if (!svg) return;
    const confs = this._conferences().filter((c) => this._isOn(c.id));
    const box = chart.getBoundingClientRect();
    const paths = [];
    for (const e of this._layout(confs).edges) {
      const from = chart.querySelector(`.fc-cell.lv [data-div="${e.from}"]`);
      const to = e.to[0] === 'c' ? chart.querySelector(`[data-node="${e.to}"]`) : chart.querySelector(`.fc-cell.lv [data-div="${e.to.slice(1)}"]`);
      if (!from || !to) continue;
      const a = from.getBoundingClientRect(), b = to.getBoundingClientRect();
      const x1 = a.left + a.width / 2 - box.left, y1 = a.top - box.top;
      // Into a conference: aim above the feeder (clamped into the
      // container) so the arrows fan in instead of meeting mid-box.
      const x2 = e.to[0] === 'c' ? Math.min(Math.max(x1, b.left - box.left + 24), b.right - box.left - 24) : b.left + b.width / 2 - box.left;
      const y2 = b.bottom - box.top + 3;
      const my = (y1 + y2) / 2;
      paths.push(`<path d="M${x1},${y1 - 2} C${x1},${my} ${x2},${my} ${x2},${y2}"${e.up ? ' marker-end="url(#fc-up)"' : ''}${e.down ? ' marker-start="url(#fc-down)"' : ''} />`);
    }
    svg.setAttribute('width', chart.scrollWidth);
    svg.setAttribute('height', chart.scrollHeight);
    svg.innerHTML = `
      <defs>
        <marker id="fc-up" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M0,0 L10,5 L0,10 z" fill="${this._kindColor('promotion')}" /></marker>
        <marker id="fc-down" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
          <path d="M0,0 L10,5 L0,10 z" fill="${this._kindColor('relegation')}" /></marker>
      </defs>
      <g fill="none" stroke="#64748b" stroke-width="2">${paths.join('')}</g>`;
  }
}
window.ApslPyramidScreen = ApslPyramidScreen;
