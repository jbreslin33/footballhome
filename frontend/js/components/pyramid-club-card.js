// pyramid-club-card.js — #apsl-pyramid: the club card (mig 856).  Owner
// 2026-10-29: "clubs need to be selectable on map or standings etc. and hud
// should show info. rosters, home field etc … year established etc."
//
// Opened from any view: a team's name in a table (flow chart, presentation,
// club pathway, standings — `data-club` on the name cell) or a team's dot on
// the map.  GET /api/pyramid/club?id= gives the crest, the year established
// (✏️ — no feed has it; POST /api/pyramid/club, club admins), and per live
// team its league · table, place, record, zone, home ground, staff and
// roster (read from the league's team page when a day old).  On the map the
// card sits in the map's own stage (so it comes along into full screen);
// elsewhere it floats over the page.
class PyramidClubCard {
  constructor(screen) { this.screen = screen; this.el = null; this.data = null; this.editing = false; }

  _esc(t) { return this.screen.escapeHtml(t == null ? '' : String(t)); }
  _copy(tier, tokens) { return this.screen._copy(tier, tokens); }

  static css() {
    return `
      .cc-card { z-index:1300; background:rgba(11,18,32,0.95); border:1px solid rgba(148,163,184,0.35); border-radius:12px;
                 box-shadow:0 8px 30px rgba(0,0,0,0.55); display:flex; flex-direction:column; color:#e5e7eb; }
      .cc-card.float { position:fixed; right:16px; top:84px; bottom:16px; width:min(400px, calc(100vw - 32px)); }
      .cc-card.in-map { position:absolute; left:12px; top:96px; bottom:12px; width:min(380px, calc(100% - 24px)); }
      .cc-head { display:flex; gap:10px; align-items:center; padding:10px 12px; border-bottom:1px solid rgba(148,163,184,0.2); }
      .cc-head img { width:44px; height:44px; object-fit:contain; background:#fff; border-radius:8px; padding:2px; }
      .cc-head .nm { flex:1; min-width:0; }
      .cc-head h3 { margin:0; font-size:1.05rem; }
      .cc-est { font-size:0.8rem; opacity:0.8; }
      .cc-est button, .cc-head > button { min-height:0; min-width:0; padding:1px 8px; font-size:0.75rem; }
      .cc-est input { width:72px; padding:1px 4px; }
      .cc-body { overflow:auto; padding:8px 12px 12px; flex:1; }
      .cc-team { border-top:1px solid rgba(148,163,184,0.15); padding:8px 0; }
      .cc-team:first-child { border-top:0; }
      .cc-team h4 { margin:0 0 3px; font-size:0.9rem; }
      .cc-rec { font-size:0.8rem; }
      .cc-zone { display:inline-block; padding:0 7px; border-radius:999px; font-size:0.72rem; font-weight:700; color:#111827; margin-left:4px; }
      .cc-k { font-size:0.68rem; font-weight:800; letter-spacing:0.06em; text-transform:uppercase; opacity:0.55; margin-top:6px; }
      .cc-v { font-size:0.82rem; }
      .cc-roster { width:100%; border-collapse:collapse; font-size:0.78rem; margin-top:2px; }
      .cc-roster td, .cc-roster th { padding:2px 4px; border-top:1px solid rgba(255,255,255,0.06); text-align:right; }
      .cc-roster td:first-child, .cc-roster th:first-child { text-align:left; }
      .cc-roster th { opacity:0.6; font-weight:700; }
      .cc-note { font-size:0.72rem; opacity:0.6; }
      [data-club].tm { cursor:pointer; }
      [data-club].tm:hover { text-decoration:underline; }`;
  }

  // host: an element to sit in (the map's stage), else the screen itself.
  async open(clubId, host) {
    this.close();
    const inMap = !!(host && host.classList.contains('mp-stage'));
    this.el = document.createElement('div');
    this.el.className = `cc-card ${inMap ? 'in-map' : 'float'}`;
    this.el.innerHTML = '<div class="cc-body"><div class="loading">Loading…</div></div>';
    (host || this.screen.element).appendChild(this.el);
    if (window.L && inMap) { window.L.DomEvent.disableClickPropagation(this.el); window.L.DomEvent.disableScrollPropagation(this.el); }
    this.el.addEventListener('click', (e) => this._action(e));
    this.clubId = clubId;
    try {
      const res = await this.screen.auth.fetch(`/api/pyramid/club?id=${clubId}`);
      const body = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
      if (this.clubId !== clubId || !this.el) return;
      this.data = body; this.editing = false;
      this._render();
    } catch (e) {
      if (this.el) this.el.innerHTML = `<div class="cc-body"><div class="error">${this._esc(e.message)}</div></div>`;
    }
  }

  close() { if (this.el) { this.el.remove(); this.el = null; } this.data = null; }

  _render() {
    const esc = (t) => this._esc(t);
    const c = this.data;
    const est = this.editing
      ? `${esc(this._copy('card_est_edit'))} <input type="number" min="1800" max="2100" data-cc="year" value="${c.founded || ''}"> <button class="btn btn-primary" data-cc="save">${esc(this._copy('save'))}</button>`
      : `${esc(c.founded ? this._copy('card_est', { year: c.founded }) : this._copy('card_est_unknown'))} <button class="btn btn-secondary" data-cc="edit">✏️</button>`;
    const teams = (c.teams || []).map((t) => {
      const zone = t.zone ? `<span class="cc-zone" style="background:${esc(t.zone_color || '#e5e7eb')}">${esc(t.zone)}</span>` : '';
      const rec = t.pos != null ? this._copy('card_record', { pos: t.pos, w: t.w, d: t.d, l: t.l, pts: t.pts }) : '';
      const ground = t.venue ? `${t.venue_name ? `<b>${esc(t.venue_name)}</b><br>` : ''}${esc(t.venue)}` : esc(this._copy('card_no_ground'));
      const staff = (t.staff || []).map((p) => `${esc(p.role)}: ${esc(p.name)}`).join('<br>');
      const cols = (this._copy('card_roster_cols') || '').split(/\s+/);
      const roster = (t.roster || []).length
        ? `<details><summary class="cc-k" style="cursor:pointer;">${esc(this._copy('card_roster', { n: t.roster.length }))}</summary>
            <table class="cc-roster"><thead><tr>${cols.map((h) => `<th>${esc(h)}</th>`).join('')}</tr></thead>
            <tbody>${t.roster.map((p) => `<tr><td>${esc(p.name)}</td><td>${p.goals ?? ''}</td><td>${p.assists ?? ''}</td></tr>`).join('')}</tbody></table>
            ${t.people_at ? `<div class="cc-note">${esc(this._copy('card_read', { when: t.people_at }))}</div>` : ''}</details>`
        : `<div class="cc-note">${esc(this._copy('card_no_roster'))}</div>`;
      return `
        <div class="cc-team">
          <h4>${esc(t.name)}</h4>
          <div class="cc-rec">${esc(t.league)} · ${esc(t.division)}<br>${esc(rec)}${zone}</div>
          <div class="cc-k">${esc(this._copy('card_ground'))}</div><div class="cc-v">${ground}</div>
          ${staff ? `<div class="cc-k">${esc(this._copy('card_staff'))}</div><div class="cc-v">${staff}</div>` : ''}
          ${roster}
        </div>`;
    }).join('');
    this.el.innerHTML = `
      <div class="cc-head">
        ${c.logo_url ? `<img src="${esc(c.logo_url)}" alt="">` : ''}
        <div class="nm"><h3>${esc(c.name)}</h3><div class="cc-est">${est}</div></div>
        <button class="btn btn-secondary" data-cc="close">${esc(this._copy('map_close'))}</button>
      </div>
      <div class="cc-body">${teams}</div>`;
  }

  async _action(e) {
    const b = e.target.closest('[data-cc]');
    if (!b || !this.data) return;
    const a = b.dataset.cc;
    if (a === 'close') { this.close(); return; }
    if (a === 'edit') { this.editing = true; this._render(); return; }
    if (a === 'save') {
      const v = this.el.querySelector('[data-cc="year"]').value.trim();
      try {
        const res = await this.screen.auth.fetch('/api/pyramid/club', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ club_id: this.data.id, founded: v ? Number(v) : null }),
        });
        const body = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
        this.data.founded = v ? Number(v) : null;
        this.editing = false;
        this._render();
      } catch (err) { b.textContent = err.message; }
    }
  }
}
window.PyramidClubCard = PyramidClubCard;
