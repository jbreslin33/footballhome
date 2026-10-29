// league-moves-mail.js — ✉️ the roster-moves email to a league's
// commissioner (mig 829), shown on #apsl-messages (mig 833).  Owner 2026-10-29: "need email
// in apsl for commish to make the rosters moves from roster. this email
// should also appear there if there are moves to make. so on load of that
// apsl page you should check roster page right?"
//
// On load: draw the moves the DB already knows (GET
// /api/mens-roster/league-moves → fh_league_moves: the #teams Roster
// pill's cuts, drops and adds), then re-pull each list from the league
// (the board's own 🌐 refresh, one at a time — TeamPass sign-ins race)
// and redraw, so a drop the league already made is gone before the email
// is written.  Nothing unasked → nothing drawn.  Send = Gmail compose to
// the list's contact; ✓ Sent logs the ask and moves the cards on
// (Dropping → Pending Drop, Has Docs → Awaiting Approval).
// Wording: message_templates kind 'league_moves'.
class LeagueMovesMail {
  constructor(screen, el) {
    this.screen = screen;
    this.el = el;
    this.lists = [];
    this.pulling = false;
    el.addEventListener('click', (e) => {
      const sent = e.target.closest('[data-lm-sent]');
      if (sent) this.markSent(sent);
    });
  }

  copy(tier, tokens = {}) { return window.MessageCopy ? MessageCopy.block('league_moves', tier, tokens) : ''; }

  async load({ pull = true } = {}) {
    await (window.MessageCopy ? MessageCopy.load(this.screen.auth) : null);
    await this.fetchMoves();
    if (!pull || this.pulling) return;
    this.pulling = true;
    this.render();
    let fresh = false;
    for (const l of this.lists) {
      try {
        const res = await this.screen.auth.fetch('/api/mens-roster/official-roster-refresh', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ teamId: l.teamId }),
        });
        const body = await res.json().catch(() => ({}));
        if (res.ok && !body.error && (body.names || []).length) fresh = true;
      } catch (err) { console.warn('[league-moves] list pull failed', l.teamId, err); }
    }
    this.pulling = false;
    if (fresh) await this.fetchMoves(); else this.render();
  }

  async fetchMoves() {
    try {
      const res = await this.screen.auth.fetch('/api/mens-roster/league-moves');
      const data = await res.json().catch(() => ({}));
      this.lists = res.ok ? (data.lists || []) : [];
    } catch (err) { this.lists = []; }
    this.render();
  }

  // One email per contact: every list he handles with something unasked.
  groups() {
    const by = new Map();
    for (const l of this.lists) {
      const open = (l.moves || []).filter(m => !m.askedOn);
      const asked = (l.moves || []).filter(m => m.askedOn);
      if (!open.length && !asked.length) continue;
      const k = l.contact.id;
      if (!by.has(k)) by.set(k, { contact: l.contact, lists: [] });
      by.get(k).lists.push({ ...l, open, asked });
    }
    return [...by.values()].filter(g => g.lists.some(l => l.open.length));
  }

  listName(l) { return l.league || l.teamName; }

  render() {
    const esc = (t) => this.screen.escapeHtml(t == null ? '' : String(t));
    const groups = this.groups();
    if (typeof this.onRender === 'function') this.onRender(groups.length > 0);
    if (!groups.length) { this.el.innerHTML = ''; return; }
    const u = (this.screen.auth.getUser && this.screen.auth.getUser()) || {};
    const sender = u.name || u.fullName || [u.first_name || u.firstName, u.last_name || u.lastName].filter(Boolean).join(' ');
    this.el.innerHTML = groups.map(g => {
      const c = g.contact;
      const first = String(c.name || '').split(/\s+/)[0];
      const blocks = g.lists.filter(l => l.open.length).map(l => this.copy('team_block', {
        team: this.listName(l),
        lines: l.open.map(m => this.copy(m.move === 'add' ? 'line_add' : 'line_drop', { name: m.name })).join('\n'),
      })).join('\n');
      const mail = window.MessageCopy && MessageCopy.render('league_moves', 'email',
        { contact_first: first, moves: blocks, sender });
      const href = mail && this.screen.buildGmailComposeHref({ to: c.email, subject: mail.subject, body: mail.body });
      const why = (m) => this.copy(m.move === 'add' ? (m.reason === 'needs_add' ? 'reason_needs_add' : 'reason_proposed')
        : (m.reason === 'cut' ? 'reason_cut' : 'reason_drop'));
      const row = (m) => `<div style="display:flex; gap:8px; align-items:baseline; font-size:0.85rem; padding:2px 0;">
          <b style="min-width:3.4em; color:${m.move === 'add' ? '#86efac' : '#fca5a5'};">${m.move === 'add' ? 'ADD' : 'DROP'}</b>
          <span style="font-weight:700;">${esc(m.name)}</span>
          <span style="font-size:0.72rem; opacity:0.7;">${esc(why(m))}</span></div>`;
      const lists = g.lists.map(l => `
          <div style="margin-top:8px;">
            <div style="font-weight:800; font-size:0.85rem;">${esc(this.listName(l))}</div>
            ${l.open.map(row).join('')}
            ${l.asked.length ? `<div style="font-size:0.72rem; opacity:0.6; margin-top:4px;">${esc(this.copy('asked_note', { date: l.asked[0].askedOn }))}
              ${l.asked.map(m => esc(`${m.move === 'add' ? '+' : '−'} ${m.name}`)).join(', ')}</div>` : ''}
          </div>`).join('');
      return `
        <div style="border:2px solid #f97316; border-radius:12px; padding:10px 12px; margin:0 auto var(--space-3); max-width:640px; background:rgba(249,115,22,0.08);">
          <div style="font-weight:900; font-size:1rem;">${esc(this.copy('panel_h', { contact: c.name || c.email }))}</div>
          <div style="font-size:0.75rem; opacity:0.75; margin-top:2px;">${esc(this.copy('panel_note'))}${this.pulling ? ' · 🟡' : ''}</div>
          ${lists}
          <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:10px;">
            ${href ? `<a class="btn btn-primary" href="${esc(href)}" target="_blank" rel="noopener" style="padding:6px 14px;">${esc(this.copy('send_btn', { contact: c.name || c.email }))}</a>` : ''}
            <button class="btn btn-secondary" data-lm-sent="${esc(c.id)}" style="padding:6px 14px;">${esc(this.copy('sent_btn'))}</button>
          </div>
        </div>`;
    }).join('');
  }

  async markSent(btn) {
    const g = this.groups().find(x => String(x.contact.id) === btn.dataset.lmSent);
    if (!g) return;
    btn.disabled = true;
    try {
      for (const l of g.lists.filter(x => x.open.length)) {
        const res = await this.screen.auth.fetch('/api/mens-roster/league-moves/sent', {
          method: 'POST', headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ sourceId: l.sourceId, moves: l.open.map(m => ({ personId: m.personId, move: m.move })) }),
        });
        if (!res.ok) throw new Error((await res.text()).slice(0, 200) || `HTTP ${res.status}`);
      }
      await this.fetchMoves();
    } catch (err) {
      btn.disabled = false;
      alert(`Could not mark the moves sent: ${err.message}`);
    }
  }
}
window.LeagueMovesMail = LeagueMovesMail;
