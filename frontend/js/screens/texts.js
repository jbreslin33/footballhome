// SmsOptInBoardScreen — #texts: who has opted in to club texts, nudge the
// rest (migration 537).  Owner 2026-10-07: "we need an opt in message?
// that tracks who opted in and we can remind them manually until they
// do? have a tracker page for that at top level? ... like we do for
// numbers/kits".
//
// Top-level 📲 Texts tile (admins; coaches see the teams they coach).
// Pick a team, then per player: the mobile we would text (the parent's
// for a youth player), a ✅ with the date when a consent is on file for
// that person or that number (sms_opt_ins — the proof the Twilio A2P
// campaign rests on), how many times they have been nudged, and 💬.
//
// 💬 is a text from YOUR phone (sms: link), not Twilio — asking for
// consent by A2P text is itself unsolicited.  The server drafts it with
// a personal magic link to footballhome.org/sms, which lands pre-filled,
// and logs the nudge; the tick appears once they send the form.
//
//   GET  /api/texts-board/teams
//   GET  /api/texts-board/roster?team_id=
//   POST /api/texts-board/nudge   { team_id, person_id }
//
// Wording: message_templates kind 'sms_opt_in'.
class SmsOptInBoardScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.teams = null;
    this.teamId = null;
    this.players = null;
    this.filter = 'all';      // all | not | in | none
    this.error = null;
  }

  _copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('sms_opt_in', tier, tokens) : ''; }
  _md(iso) { if (!iso) return ''; const d = new Date(iso); return isNaN(d) ? '' : `${d.getMonth() + 1}/${d.getDate()}`; }
  _digits(s) { return String(s || '').replace(/\D/g, '').replace(/^1(?=\d{10}$)/, ''); }
  _fmtPhone(s) { const d = this._digits(s); return d.length === 10 ? `(${d.slice(0, 3)}) ${d.slice(3, 6)}-${d.slice(6)}` : (s || ''); }

  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-texts';
    div.innerHTML = `
      <style>
        .tx-chip { padding:4px 10px; border-radius:999px; cursor:pointer; font-size:0.78rem; font-weight:700;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .tx-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .tx-table { width:100%; border-collapse:collapse; font-size:0.9rem; }
        .tx-table th { font-size:0.7rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; opacity:0.75;
                       text-align:left; padding:6px 4px; border-bottom:1px solid var(--border-color); }
        .tx-table td { padding:6px 4px; border-bottom:1px solid var(--border-color); vertical-align:middle; }
        .tx-status { font-size:0.68rem; opacity:0.6; margin-left:6px; }
        .tx-tag { font-size:0.65rem; font-weight:800; letter-spacing:0.04em; text-transform:uppercase; opacity:0.6; margin-left:6px; }
        .tx-in { color:#22c55e; font-weight:700; white-space:nowrap; }
        .tx-none { opacity:0.55; font-size:0.8rem; }
        .tx-nudge { padding:4px 10px; border-radius:999px; border:1px solid var(--border-color); background:var(--bg-secondary);
                    color:var(--text-primary); cursor:pointer; font-size:0.8rem; font-weight:700; white-space:nowrap; }
        .tx-nudge.sent { opacity:0.7; }
        .tx-nudge:disabled { opacity:0.5; cursor:default; }
        .tx-note { font-size:0.72rem; color:#ef4444; }
        tr.tx-done td { opacity:0.75; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="tx-title">📲 Texts</h1>
        <p class="subtitle" id="tx-sub"></p>
      </div>
      <div style="padding: var(--space-4); max-width: 900px; margin: 0 auto;">
        <div id="tx-teams" style="display:flex; gap:var(--space-1); flex-wrap:wrap; margin-bottom:var(--space-3);"></div>
        <div id="tx-body"></div>
      </div>
    `;
    this.element = div;
    this._wire();
    return div;
  }

  onEnter() {
    this.error = null;
    this._render();
    const copyReady = window.MessageCopy ? MessageCopy.load(this.auth) : Promise.resolve();
    Promise.resolve(copyReady).then(() => this._render());
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
      const body = await this._json('/api/texts-board/teams');
      this.teams = body.teams || [];
      if (!this.teams.some(t => t.id === this.teamId)) this.teamId = this.teams.length ? this.teams[0].id : null;
    } catch (err) {
      console.error('[texts] teams load failed:', err);
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
      const body = await this._json(`/api/texts-board/roster?team_id=${teamId}`);
      if (this.teamId !== teamId) return;
      this.players = body.players || [];
      this.error = null;
    } catch (err) {
      console.error('[texts] roster load failed:', err);
      this.players = [];
      this.error = err.message;
    }
    this._render();
  }

  // 💬: the server drafts the text (DB copy + a personal link to /sms),
  // logs the nudge, and hands back the sms: href this phone opens.
  async _nudge(btn) {
    const personId = Number(btn.dataset.nudge);
    const player = (this.players || []).find(p => p.person_id === personId);
    if (!player) return;
    const note = this.find(`[data-tx-note="${personId}"]`);
    btn.disabled = true;
    const was = btn.textContent;
    btn.textContent = '⏳';
    try {
      const body = await this._json('/api/texts-board/nudge', {
        method: 'POST',
        body: JSON.stringify({ team_id: this.teamId, person_id: personId }),
      });
      if (body.nudges) player.nudges = body.nudges;
      if (note) note.textContent = '';
      this._render();
      if (body.sms_href) window.location.href = body.sms_href;
    } catch (err) {
      btn.disabled = false;
      btn.textContent = was;
      if (note) note.textContent = err.message;
    }
  }

  // ── events ──────────────────────────────────────────────────────────
  _wire() {
    this.element.addEventListener('click', (e) => {
      if (e.target.closest('.back-btn')) { this.navigation.goBack(); return; }
      let el;
      if ((el = e.target.closest('[data-tx-team]'))) {
        this.teamId = Number(el.dataset.txTeam);
        this.filter = 'all';
        this._render();
        this._loadRoster();
        return;
      }
      if ((el = e.target.closest('[data-tx-filter]'))) { this.filter = el.dataset.txFilter; this._render(); return; }
      if ((el = e.target.closest('[data-nudge]'))) { this._nudge(el); }
    });
  }

  // ── render ──────────────────────────────────────────────────────────
  _state(p) { return !p.phone ? 'none' : (p.consented_at ? 'in' : 'not'); }

  _summaryHtml() {
    const players = this.players || [];
    const withPhone = players.filter(p => p.phone);
    return this.escapeHtml(this._copy('summary', {
      in: players.filter(p => p.consented_at).length,
      total: withPhone.length,
      nudged: players.filter(p => p.nudges && p.nudges.count > 0).length,
    }) || `${players.filter(p => p.consented_at).length}/${withPhone.length} opted in`);
  }

  _render() {
    const title = this.find('#tx-title'); if (title) title.textContent = this._copy('title') || '📲 Texts';
    const sub = this.find('#tx-sub'); if (sub) sub.textContent = this._copy('subtitle');
    const teamsEl = this.find('#tx-teams');
    const body = this.find('#tx-body');
    if (!teamsEl || !body) return;

    teamsEl.innerHTML = (this.teams || []).map(t =>
      `<button type="button" class="tx-chip ${t.id === this.teamId ? 'on' : ''}" data-tx-team="${t.id}">${this.escapeHtml(t.label || t.name)}</button>`).join('');

    const msg = (text) => `<div class="empty-state" style="text-align:center; opacity:0.75; padding:var(--space-6);">${this.escapeHtml(text)}</div>`;
    if (this.error)            { body.innerHTML = msg(this.error); return; }
    if (!this.teams)           { body.innerHTML = msg('Loading…'); return; }
    if (!this.teams.length)    { body.innerHTML = msg('No teams.'); return; }
    if (!this.players)         { body.innerHTML = msg('Loading…'); return; }
    if (!this.players.length)  { body.innerHTML = msg(this._copy('empty') || 'Nobody is on this team.'); return; }

    const filters = [
      ['all',  this._copy('filter_all')  || 'Everyone'],
      ['not',  this._copy('filter_not')  || 'Not yet'],
      ['in',   this._copy('filter_in')   || 'Opted in'],
      ['none', this._copy('filter_none') || 'No mobile'],
    ];
    const counts = { all: this.players.length, not: 0, in: 0, none: 0 };
    this.players.forEach(p => { counts[this._state(p)]++; });
    const shown = this.players.filter(p => this.filter === 'all' || this._state(p) === this.filter);

    const statusCell = (p) => {
      const st = this._state(p);
      if (st === 'in')   return `<span class="tx-in">${this.escapeHtml(this._copy('status_in', { date: this._md(p.consented_at) }) || `✅ ${this._md(p.consented_at)}`)}</span>`;
      if (st === 'none') return `<span class="tx-none">${this.escapeHtml(this._copy('status_none') || 'no mobile on file')}</span>`;
      return `<span class="tx-none">${this.escapeHtml(this._copy('status_not') || '—')}</span>`;
    };
    const nudgedCell = (p) => {
      const n = p.nudges || { count: 0, last_at: null };
      if (!n.count) return `<span class="tx-none">—</span>`;
      return this.escapeHtml(this._copy('nudged_cell', { sent: n.count, date: this._md(n.last_at) }) || `×${n.count}, last ${this._md(n.last_at)}`);
    };
    const nudgeBtn = (p) => {
      if (!p.phone) return '';
      const n = p.nudges || { count: 0 };
      const label = n.count
        ? (this._copy('nudge_btn_sent', { sent: n.count }) || `💬 Nudge ×${n.count}`)
        : (this._copy('nudge_btn') || '💬 Nudge');
      return `<button type="button" class="tx-nudge ${n.count ? 'sent' : ''}" data-nudge="${p.person_id}">${this.escapeHtml(label)}</button>`;
    };

    body.innerHTML = `
      <div style="display:flex; gap:var(--space-1); flex-wrap:wrap; align-items:center; margin-bottom:var(--space-2);">
        ${filters.map(([k, label]) =>
          `<button type="button" class="tx-chip ${this.filter === k ? 'on' : ''}" data-tx-filter="${k}">${this.escapeHtml(label)} <span style="opacity:0.7; font-weight:400;">${counts[k]}</span></button>`).join('')}
      </div>
      <div id="tx-summary" style="font-size:0.8rem; opacity:0.75; margin-bottom:var(--space-2);">${this._summaryHtml()}</div>
      <div style="overflow-x:auto;">
        <table class="tx-table">
          <thead><tr>
            <th>${this.escapeHtml(this._copy('col_player') || 'Player')}</th>
            <th>${this.escapeHtml(this._copy('col_mobile') || 'Mobile')}</th>
            <th>${this.escapeHtml(this._copy('col_optin') || 'Opted in')}</th>
            <th>${this.escapeHtml(this._copy('col_nudged') || 'Nudged')}</th>
            <th></th>
          </tr></thead>
          <tbody>
            ${shown.map(p => `<tr class="${p.consented_at ? 'tx-done' : ''}">
              <td>
                ${this.escapeHtml([p.last_name, p.first_name].filter(Boolean).join(', ') || 'Unknown')}
                ${p.roster_status ? `<span class="tx-status">${this.escapeHtml(p.roster_status)}</span>` : ''}
                <div data-tx-note="${p.person_id}" class="tx-note"></div>
              </td>
              <td style="white-space:nowrap;">
                ${p.phone ? this.escapeHtml(this._fmtPhone(p.phone)) : `<span class="tx-none">—</span>`}
                ${p.youth && p.phone ? `<span class="tx-tag">${this.escapeHtml(this._copy('parent_tag') || 'parent')}${p.recipient_first_name ? ' · ' + this.escapeHtml(p.recipient_first_name) : ''}</span>` : ''}
              </td>
              <td>${statusCell(p)}</td>
              <td style="white-space:nowrap;">${nudgedCell(p)}</td>
              <td style="text-align:right;">${nudgeBtn(p)}</td>
            </tr>`).join('') || `<tr><td colspan="5" style="opacity:0.6; text-align:center;">Nobody.</td></tr>`}
          </tbody>
        </table>
      </div>`;
  }
}
