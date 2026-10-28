// AwardsScreen — #awards: All-Stars and club awards, per team, per season
// (mig 800).
//
// Top-level 🏅 Awards tile (admins + coaches).  Season pills (year_terms,
// the current one lit) with ‹ › for the year, section pills, then one card
// per team that plays that season (team_terms, mig 795).  Each player row
// carries a chip per award (award_types) — tap to give, tap again to take
// back.  League awards (award_types.is_league — All-Star) get a strip on
// teams with a league director (team_league_directors): the list so far,
// ✉ Email / 💬 Text buttons that open the message to the director, and
// "sent ✓" once one went.  Message wording = message_templates kind=awards.
//
//   GET  /api/awards/board?term=&year=
//   POST /api/awards/toggle  { person_id, team_id, award_code, term, year, on }
//   POST /api/awards/sent    { team_id, award_code, term, year, channel }
class AwardsScreen extends Screen {
  static get SECTION_LABELS() { return { boys: '👦 Boys', mens: '👨 Men', womens: '👩 Women', girls: '👧 Girls' }; }

  constructor(navigation, auth) {
    super(navigation, auth);
    this.board = null;
    this.term = null;      // null → the server's current term
    this.year = null;
    this.section = 'boys';
    this.error = null;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        .aw-chip { padding:4px 10px; border-radius:999px; cursor:pointer; font-weight:600; font-size:0.78rem; min-height:0; min-width:0;
                   border:1px solid var(--border-color); background:var(--bg-secondary); color:var(--text-primary); }
        .aw-chip.on { background:var(--primary-color); color:#fff; border-color:transparent; }
        .aw-give { padding:3px 8px; border-radius:999px; cursor:pointer; font-size:0.72rem; min-height:0; min-width:0;
                   border:1px dashed var(--border-color); background:transparent; color:var(--text-primary); opacity:0.6; }
        .aw-give.on { border:1px solid #f59e0b; background:rgba(245,158,11,0.18); opacity:1; font-weight:700; }
        .aw-card { border:1px solid var(--border-color); border-radius:var(--radius-md); background:var(--bg-secondary); padding:var(--space-3); }
        .aw-row { display:flex; flex-wrap:wrap; align-items:center; gap:6px; padding:5px 0; border-top:1px solid var(--border-color); }
        .aw-league { border:1px solid #f59e0b; border-radius:var(--radius-md); padding:8px 10px; margin:6px 0 8px; background:rgba(245,158,11,0.08); }
        .aw-send { padding:6px 12px; border-radius:8px; cursor:pointer; font-weight:700; font-size:0.8rem; min-height:0;
                   border:1px solid var(--primary-color); background:var(--primary-color); color:#fff; }
      </style>
      <div class="screen-header" style="flex-wrap:wrap;">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1 id="aw-title">🏅 Awards</h1>
        <p class="subtitle" id="aw-sub"></p>
      </div>
      <div id="aw-body" style="padding: var(--space-4); max-width: 1100px; margin: 0 auto;"></div>
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

  // ── data ──────────────────────────────────────────────────────────────
  async _json(url, options = {}) {
    const headers = { ...(options.headers || {}) };
    if (options.body) headers['Content-Type'] = 'application/json';
    const res = await this.auth.fetch(url, { ...options, headers });
    const body = await res.json().catch(() => ({}));
    if (!res.ok) throw new Error(body.error || `HTTP ${res.status}`);
    return body;
  }

  async _load() {
    const qs = new URLSearchParams();
    if (this.term) qs.set('term', this.term);
    if (this.year) qs.set('year', this.year);
    try {
      this.board = await this._json(`/api/awards/board?${qs}`);
      this.term = this.board.term;
      this.year = this.board.year;
      this.error = null;
    } catch (err) {
      console.error('[awards] load failed:', err);
      this.error = err.message || 'Could not load awards.';
    }
    this._render();
  }

  _copy(tier, tokens, fallback) {
    return (window.MessageCopy && MessageCopy.block('awards', tier, tokens)) || fallback;
  }

  _seasonLabel() {
    const t = (this.board?.terms || []).find(x => x.code === this.term);
    return `${t ? t.label.replace(/^[^\p{L}]+/u, '') : this.term} ${this.year}`;
  }

  // ── events ────────────────────────────────────────────────────────────
  _wire() {
    this.element.addEventListener('click', (e) => {
      const t = (sel) => e.target.closest(sel);
      let el;
      if (t('.back-btn')) { this.navigation.goBack(); return; }
      if ((el = t('[data-aw-term]')))    { this.term = el.dataset.awTerm; this._load(); return; }
      if ((el = t('[data-aw-year]')))    { this.year = Number(this.year) + Number(el.dataset.awYear); this._load(); return; }
      if ((el = t('[data-aw-section]'))) { this.section = el.dataset.awSection; this._render(); return; }
      if ((el = t('[data-aw-give]')))    { this._toggle(el); return; }
      if ((el = t('[data-aw-send]')))    { this._send(el); return; }
    });
  }

  async _toggle(el) {
    const team = this._team(Number(el.dataset.teamId));
    if (!team) return;
    const personId = Number(el.dataset.personId), code = el.dataset.awGive;
    const on = !team.awards.some(a => a.person_id === personId && a.award_code === code);
    // Optimistic: flip it now, put it back if the save fails.
    if (on) team.awards.push({ person_id: personId, award_code: code });
    else team.awards = team.awards.filter(a => !(a.person_id === personId && a.award_code === code));
    this._render();
    try {
      await this._json('/api/awards/toggle', { method: 'POST', body: JSON.stringify({
        person_id: personId, team_id: team.id, award_code: code, term: this.term, year: this.year, on }) });
    } catch (err) {
      console.error('[awards] toggle failed:', err);
      this.error = err.message;
      this._load();
    }
  }

  // ✉ / 💬 to the league director: open the message, then record the send.
  async _send(el) {
    const team = this._team(Number(el.dataset.teamId));
    const type = (this.board.types || []).find(x => x.code === el.dataset.awCode);
    const d = team && team.director;
    if (!d || !type) return;
    const channel = el.dataset.awSend;
    const names = this._winners(team, type.code).map(p => p.name);
    const tokens = {
      director: String(d.name || '').split(' ')[0], league_team: d.league_team || team.label,
      award: type.label, season: this._seasonLabel(), players: names.join('\n'), sender: this.board.sender || '',
    };
    if (channel === 'email') {
      const r = window.MessageCopy && MessageCopy.render('awards', 'email', tokens);
      this.openGmailCompose(this.buildGmailComposeHref({
        to: d.email, subject: r ? r.subject : `Lighthouse ${tokens.league_team} — ${tokens.season} ${type.label}s`,
        body: r ? r.body : names.join('\n') }));
    } else {
      const body = this._copy('text', tokens, names.join('\n'));
      const href = this.buildSmsComposeHref({ to: String(d.phone || '').replace(/[^\d+]/g, ''), body });
      if (window.DesktopSms) DesktopSms.open(href); else window.location.href = href;
    }
    try {
      await this._json('/api/awards/sent', { method: 'POST', body: JSON.stringify({
        team_id: team.id, award_code: type.code, term: this.term, year: this.year, channel }) });
      team.sends.unshift({ award_code: type.code, channel, sent_at: new Date().toISOString() });
      this._render();
    } catch (err) {
      console.error('[awards] recording the send failed:', err);
    }
  }

  _team(id) { return (this.board?.teams || []).find(t => t.id === id); }

  _winners(team, code) {
    const ids = new Set(team.awards.filter(a => a.award_code === code).map(a => a.person_id));
    return team.players.filter(p => ids.has(p.person_id));
  }

  // ── render ────────────────────────────────────────────────────────────
  _render() {
    const body = this.find('#aw-body');
    if (!body) return;
    this.find('#aw-title').textContent = this._copy('title', {}, '🏅 Awards');
    this.find('#aw-sub').textContent = this._copy('sub', {}, 'Pick a season and a team, tap an award on a player');
    if (this.error && !this.board) { body.innerHTML = `<div class="empty-state">${this.escapeHtml(this.error)}</div>`; return; }
    if (!this.board) { body.innerHTML = `<div style="text-align:center; opacity:0.7; padding:var(--space-6);">Loading…</div>`; return; }
    const esc = (s) => this.escapeHtml(String(s ?? ''));
    const b = this.board;
    const sections = [...new Set(b.teams.map(t => t.section).filter(Boolean))];
    if (!sections.includes(this.section)) this.section = sections[0] || 'boys';
    const teams = b.teams.filter(t => t.section === this.section);

    const chip = (attr, val, label, on) => `<button type="button" class="aw-chip ${on ? 'on' : ''}" ${attr}="${esc(val)}">${esc(label)}</button>`;
    const pills = `
      <div style="display:flex; flex-wrap:wrap; gap:6px; align-items:center; margin-bottom:8px;">
        ${(b.terms || []).map(t => chip('data-aw-term', t.code, t.label, t.code === this.term)).join('')}
        <button type="button" class="aw-chip" data-aw-year="-1" aria-label="Previous year">‹</button>
        <span style="font-weight:800;">${esc(this.year)}</span>
        <button type="button" class="aw-chip" data-aw-year="1" aria-label="Next year">›</button>
      </div>
      <div style="display:flex; flex-wrap:wrap; gap:6px; margin-bottom:12px;">
        ${sections.map(s => chip('data-aw-section', s, AwardsScreen.SECTION_LABELS[s] || s, s === this.section)).join('')}
      </div>`;

    const leagueStrip = (team, type) => {
      const d = team.director;
      const winners = this._winners(team, type.code);
      const sent = team.sends.find(x => x.award_code === type.code);
      const when = sent && new Date(sent.sent_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
      const how = sent && ({ email: 'email', text: 'text', outside: 'hand' }[sent.channel] || sent.channel);
      return `<div class="aw-league">
        <div style="font-weight:800;">${esc(type.emoji)} ${esc(type.label)}s → ${esc(d.name)} <span style="font-weight:400; opacity:0.75;">· ${esc(d.league_team || '')}</span></div>
        <div style="font-size:0.85rem; margin:4px 0;">${winners.length ? winners.map(p => esc(p.name)).join(' · ') : '<span style="opacity:0.6;">nobody picked yet</span>'}</div>
        <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center;">
          ${d.email ? `<button type="button" class="aw-send" data-aw-send="email" data-aw-code="${esc(type.code)}" data-team-id="${team.id}" ${winners.length ? '' : 'disabled'}>✉ Email ${esc(String(d.name).split(' ')[0])}</button>` : ''}
          ${d.phone ? `<button type="button" class="aw-send" data-aw-send="text" data-aw-code="${esc(type.code)}" data-team-id="${team.id}" ${winners.length ? '' : 'disabled'}>💬 Text</button>` : ''}
          <span style="font-size:0.78rem; ${sent ? 'color:#16a34a; font-weight:700;' : 'opacity:0.7;'}">${esc(sent
            ? this._copy('sent', { when, channel: how }, `Sent ${when} by ${how} ✓`)
            : this._copy('not_sent', {}, 'Not sent to the league yet'))}</span>
        </div>
      </div>`;
    };

    const card = (team) => {
      const given = (code) => new Set(team.awards.filter(a => a.award_code === code).map(a => a.person_id));
      const sets = Object.fromEntries((b.types || []).map(t => [t.code, given(t.code)]));
      const league = team.director ? (b.types || []).filter(t => t.is_league).map(t => leagueStrip(team, t)).join('') : '';
      const rows = team.players.map(p => `<div class="aw-row">
          <span style="flex:1 1 160px; min-width:0; font-weight:600;">${esc(p.name)}${p.age ? ` <span style="font-size:0.72rem; opacity:0.7;">U${esc(p.age)}</span>` : ''}</span>
          ${(b.types || []).map(t => `<button type="button" class="aw-give ${sets[t.code].has(p.person_id) ? 'on' : ''}"
              data-aw-give="${esc(t.code)}" data-person-id="${p.person_id}" data-team-id="${team.id}">${esc(t.emoji)} ${esc(t.label)}</button>`).join('')}
        </div>`).join('');
      return `<div class="aw-card">
        <div style="display:flex; align-items:center; gap:8px; margin-bottom:4px;">
          <span style="background:${esc(team.color || 'var(--primary-color)')}; color:#fff; border-radius:6px; padding:2px 8px; font-weight:800;">${esc(team.label)}</span>
          <span style="font-size:0.8rem; opacity:0.7;">${team.players.length} players · ${team.awards.length} awards</span>
        </div>
        ${league}
        ${rows || '<div style="opacity:0.6;">No players on this team.</div>'}
      </div>`;
    };

    body.innerHTML = `${pills}
      ${this.error ? `<div style="color:#dc2626; margin-bottom:8px;">${esc(this.error)}</div>` : ''}
      <div style="display:grid; gap:12px;">${teams.length ? teams.map(card).join('') : '<div class="empty-state">No teams this season.</div>'}</div>`;
  }
}

window.AwardsScreen = AwardsScreen;
