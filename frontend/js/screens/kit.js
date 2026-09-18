// KitBoardScreen — #kit: uniform numbers and kit handed out, one team at a
// time.
//
// Top-level 👕 Uniforms & Kit tile (admins; coaches see the teams they
// coach).  Pick a team, then per player: type a number (saved on blur /
// Enter; a number already worn on the team is refused with the wearer's
// name) and tick each kit item they have received.
//
// A number belongs to the uniform, not the team: teams wearing the same
// shirts (APSL / Reserves / Liga 1) share one pool, so a player has one
// number across them and nobody else in the pool can take it
// (person_uniform_numbers, migration 374).  Kit is per person
// (person_kit_issues), so a tick made on one team shows on every team the
// player is on.  The kit columns are kit_items rows (migration 373) —
// new equipment is a new row, not a change here.
//
//   GET /api/kit-board/teams
//   GET /api/kit-board/roster?team_id=
//   PUT /api/kit-board/number   { team_id, person_id, jersey_number }
//   PUT /api/kit-board/issued   { team_id, person_id, kit_item_id, issued }
class KitBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.teams = null;
    this.teamId = null;
    this.items = [];
    this.players = null;
    this.filter = 'all';      // all | no-number | missing-kit
    this.error = null;
    this.saving = new Set();
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-kit';
    div.innerHTML = `
      <style>
        .kit-chip { padding:4px 10px; border-radius:999px; cursor:pointer; font-size:0.78rem; font-weight:700;
                    border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .kit-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .kit-table { width:100%; border-collapse:collapse; font-size:0.9rem; }
        .kit-table th { font-size:0.7rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; opacity:0.75;
                        text-align:center; padding:6px 4px; border-bottom:1px solid var(--border-color); }
        .kit-table th:first-child, .kit-table td:first-child { text-align:left; }
        .kit-table td { padding:6px 4px; border-bottom:1px solid var(--border-color); text-align:center; }
        .kit-num { width:3.4em; text-align:center; font-weight:800; font-size:1rem; padding:4px; border-radius:6px;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .kit-num.bad { border-color:#ef4444; }
        .kit-check { width:22px; height:22px; cursor:pointer; }
        .kit-status { font-size:0.68rem; opacity:0.6; margin-left:6px; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>👕 Uniforms &amp; Kit</h1>
        <p class="subtitle">Assign numbers, tick off what each player has received</p>
      </div>
      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <div id="kit-teams" style="display:flex; gap:var(--space-1); flex-wrap:wrap; margin-bottom:var(--space-3);"></div>
        <div id="kit-body"></div>
      </div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter() {
    this.error = null;
    this._render();
    this._loadTeams();
  }

  // ── data ────────────────────────────────────────────────────────────
  async _json(url, options = {}) {
    const method = (options.method || 'GET').toUpperCase();
    const headers = { ...(options.headers || {}) };
    if (method !== 'GET') headers['Content-Type'] = 'application/json';
    const res = await this.auth.fetch(url, { ...options, headers });
    let body = null;
    try { body = await res.json(); } catch {}
    if (!res.ok) throw new Error((body && (body.message || body.error)) || `HTTP ${res.status}`);
    return body || {};
  }

  async _loadTeams() {
    try {
      const body = await this._json('/api/kit-board/teams');
      this.teams = body.teams || [];
      if (!this.teams.some(t => t.id === this.teamId)) this.teamId = this.teams.length ? this.teams[0].id : null;
    } catch (err) {
      console.error('[kit] teams load failed:', err);
      this.teams = [];
      this.error = err.message;
    }
    this._render();
    if (this.teamId != null) this._loadRoster();
  }

  async _loadRoster() {
    const teamId = this.teamId;
    this.players = null;
    this._render();
    try {
      const body = await this._json(`/api/kit-board/roster?team_id=${teamId}`);
      if (this.teamId !== teamId) return;
      this.items = body.items || [];
      this.sharedWith = body.shared_with || [];
      this.players = body.players || [];
      this.error = null;
    } catch (err) {
      console.error('[kit] roster load failed:', err);
      this.players = [];
      this.error = err.message;
    }
    this._render();
  }

  async _saveNumber(input) {
    const personId = Number(input.dataset.kitNumber);
    const player = (this.players || []).find(p => p.person_id === personId);
    if (!player) return;
    const value = input.value.trim();
    if (value === (player.jersey_number || '')) { input.classList.remove('bad'); return; }
    const note = this.find(`[data-kit-note="${personId}"]`);
    try {
      const body = await this._json('/api/kit-board/number', {
        method: 'PUT',
        body: JSON.stringify({ team_id: this.teamId, person_id: personId, jersey_number: value }),
      });
      player.jersey_number = body.jersey_number || null;
      input.value = player.jersey_number || '';
      input.classList.remove('bad');
      if (note) note.textContent = '';
      this._renderSummary();
    } catch (err) {
      // Keep what was typed so it can be corrected; say why it was refused.
      input.classList.add('bad');
      if (note) note.textContent = err.message;
    }
  }

  async _saveIssued(box) {
    const personId = Number(box.dataset.personId);
    const itemId = Number(box.dataset.kitItem);
    const player = (this.players || []).find(p => p.person_id === personId);
    if (!player) return;
    const issued = box.checked;
    box.disabled = true;
    try {
      await this._json('/api/kit-board/issued', {
        method: 'PUT',
        body: JSON.stringify({ team_id: this.teamId, person_id: personId, kit_item_id: itemId, issued }),
      });
      player.issued = issued ? [...new Set([...(player.issued || []), itemId])]
                             : (player.issued || []).filter(id => id !== itemId);
      this._renderSummary();
    } catch (err) {
      console.error('[kit] issue save failed:', err);
      box.checked = !issued;
      alert(`Could not save: ${err.message}`);
    } finally {
      box.disabled = false;
    }
  }

  // ── events ──────────────────────────────────────────────────────────
  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      let el;
      if ((el = e.target.closest('[data-kit-team]'))) {
        this.teamId = Number(el.dataset.kitTeam);
        this.filter = 'all';
        this._render();
        this._loadRoster();
        return;
      }
      if ((el = e.target.closest('[data-kit-filter]'))) { this.filter = el.dataset.kitFilter; this._render(); }
    });
    this.element.addEventListener('change', (e) => {
      if (e.target.matches('[data-kit-item]')) this._saveIssued(e.target);
      else if (e.target.matches('[data-kit-number]')) this._saveNumber(e.target);
    });
    this.element.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' && e.target.matches('[data-kit-number]')) e.target.blur();
    });
  }

  // ── render ──────────────────────────────────────────────────────────
  _missingKit(p) { return this.items.some(it => !(p.issued || []).includes(it.id)); }

  _summaryHtml() {
    const players = this.players || [];
    const numbered = players.filter(p => p.jersey_number).length;
    const parts = [`${numbered}/${players.length} numbered`].concat(this.items.map(it =>
      `${it.icon || ''} ${players.filter(p => (p.issued || []).includes(it.id)).length}/${players.length} ${this.escapeHtml(it.label.toLowerCase())}`));
    return parts.join(' · ');
  }

  _renderSummary() {
    const el = this.find('#kit-summary');
    if (el) el.innerHTML = this._summaryHtml();
  }

  _render() {
    const teamsEl = this.find('#kit-teams');
    const body = this.find('#kit-body');
    if (!teamsEl || !body) return;

    teamsEl.innerHTML = (this.teams || []).map(t =>
      `<button type="button" class="kit-chip ${t.id === this.teamId ? 'on' : ''}" data-kit-team="${t.id}">${this.escapeHtml(t.label || t.name)}</button>`).join('');

    const msg = (text) => `<div class="empty-state" style="text-align:center; opacity:0.75; padding:var(--space-6);">${this.escapeHtml(text)}</div>`;
    if (this.error)            { body.innerHTML = msg(this.error); return; }
    if (!this.teams)           { body.innerHTML = msg('Loading…'); return; }
    if (!this.teams.length)    { body.innerHTML = msg('No teams.'); return; }
    if (!this.players)         { body.innerHTML = msg('Loading…'); return; }
    if (!this.players.length)  { body.innerHTML = msg('Nobody is on this team.'); return; }

    const filters = [['all', 'Everyone'], ['no-number', 'No number'], ['missing-kit', 'Missing kit']];
    const shown = this.players.filter(p =>
      this.filter === 'no-number' ? !p.jersey_number :
      this.filter === 'missing-kit' ? this._missingKit(p) : true);

    body.innerHTML = `
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2);">
        ${filters.map(([k, label]) =>
          `<button type="button" class="kit-chip ${this.filter === k ? 'on' : ''}" data-kit-filter="${k}">${label}</button>`).join('')}
      </div>
 ${(this.sharedWith || []).length ? `<div style="font-size:0.8rem; opacity:0.75; margin-bottom:var(--space-1);">
        Same uniform as ${this.sharedWith.map(l => this.escapeHtml(l)).join(', ')} — numbers and kit carry across.</div>` : ''}
      <div id="kit-summary" style="font-size:0.8rem; opacity:0.75; margin-bottom:var(--space-2);">${this._summaryHtml()}</div>
      <div style="overflow-x:auto;">
        <table class="kit-table">
          <thead><tr>
            <th>Player</th><th>#</th>
            ${this.items.map(it => `<th>${it.icon || ''}<br>${this.escapeHtml(it.label)}</th>`).join('')}
          </tr></thead>
          <tbody>
            ${shown.map(p => `<tr>
              <td>
                ${this.escapeHtml([p.last_name, p.first_name].filter(Boolean).join(', ') || 'Unknown')}
                ${p.roster_status ? `<span class="kit-status">${this.escapeHtml(p.roster_status)}</span>` : ''}
                <div data-kit-note="${p.person_id}" style="font-size:0.72rem; color:#ef4444;"></div>
              </td>
              <td><input class="kit-num" type="text" inputmode="numeric" maxlength="3"
                         data-kit-number="${p.person_id}" value="${this.escapeHtml(p.jersey_number || '')}"></td>
              ${this.items.map(it => `<td><input type="checkbox" class="kit-check" data-kit-item="${it.id}"
                         data-person-id="${p.person_id}" ${(p.issued || []).includes(it.id) ? 'checked' : ''}></td>`).join('')}
            </tr>`).join('') || `<tr><td colspan="${2 + this.items.length}" style="opacity:0.6; text-align:center;">Nobody.</td></tr>`}
          </tbody>
        </table>
      </div>`;
  }
}
