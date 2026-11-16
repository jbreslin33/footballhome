// 🖨 Official roster + roster sheet — print panels (mig 501/560) and send to opponent
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterRosterPrint {
  // The league's own roster sheet — the PDF a referee checks players
  // against.  Owner 2026-09-30: "it has to be the official exact roster
  // from site … printed fresh for each game … to prove the roster is
  // current to refs".  The backend signs in to the league site and pulls
  // it on every tap; the game keeps only that latest copy (mig 501).
  // Coaches, club admins and everyone on the game's rosters get it; the
  // endpoint answers anyone else 403 and the panel stays away.
  async _loadOfficialRoster() {
    this._rosterPull = null;
    try {
      const res = await this.auth.fetch(`/api/official-roster/${this.matchId}`);
      const data = await res.json();
      this.officialRoster = res.ok && data.available ? data : null;
    } catch (err) {
      this.officialRoster = null;
    }
  }

  _renderOfficialRosterPanel() {
    const o = this.officialRoster;
    if (this.lineupView !== 'official' || !o) return '';
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('official_roster', tier, { league: o.league, ...tokens }) : '';
    const pull = this._rosterPull || {};
    const saved = o.saved;
    const when = saved && saved.fetchedAt ? new Date(saved.fetchedAt) : null;
    const whenText = when && !isNaN(when)
      ? when.toLocaleString('en-US', { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }) : '';
    let status = copy('none');
    if (pull.busy) status = copy('working');
    else if (pull.error) status = copy('failed', { reason: pull.error });
    else if (saved) status = saved.fetchedBy ? copy('saved', { when: whenText, name: saved.fetchedBy }) : copy('saved_anon', { when: whenText });
    return `
      ${this.panelFoldHtml('official_roster', `${esc(copy('title'))}`, `
        <div style="font-size:0.7rem; opacity:0.75; line-height:1.4;">${esc(copy('hint'))}</div>
        <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin-top:8px;">
          <button class="btn btn-primary" data-gc-roster-pull ${pull.busy ? 'disabled' : ''} style="padding:5px 12px; font-size:0.75rem;">${esc(copy('pull'))}</button>
          ${saved && !pull.busy ? `<button class="btn btn-secondary" data-gc-roster-open style="padding:3px 8px; font-size:0.68rem;">${esc(copy('reopen'))}</button>` : ''}
        </div>
        <div data-gc-roster-status style="font-size:0.68rem; margin-top:6px; line-height:1.4; ${pull.error ? 'color:#f87171;' : 'opacity:0.7;'}">${esc(status)}</div>
`)}`;
  }

  // The league roster sheet for this game (mig 561, owner 2026-10-09: "we
  // need rosters to be able to be printed from the game center for each
  // game" — "could we reproduce the youth roster"): drawn to the EPYSA /
  // GotSport Official Roster from the team's Football Home roster — the
  // coaches with a roster status (mig 560), every rostered player with
  // jersey number (Kit board) and birth year, ★ on starters once the
  // lineup is set.  Photos, registration numbers and approval dates are
  // the league's and print blank.  Every game, every league.
  _renderRosterSheetPanel() {
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('roster_sheet', tier, tokens) : '';
    const busy = this._sheetBusy;
    return `
      ${this.panelFoldHtml('roster_sheet', `${esc(copy('panel_title') || '🖨 Roster sheet')}`, `
        <div style="font-size:0.7rem; opacity:0.75; line-height:1.4;">${esc(copy('panel_hint') || "The league roster drawn from this team's Football Home roster.")}</div>
        <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; margin-top:8px;">
          <button class="btn btn-primary" data-gc-roster-sheet ${busy ? 'disabled' : ''} style="padding:5px 12px; font-size:0.75rem;">${esc(copy('print') || '🖨 Print roster')}</button>
        </div>
        ${this._sheetError ? `<div style="font-size:0.68rem; margin-top:6px; color:#f87171;">${esc(this._sheetError)}</div>` : ''}
`)}`;
  }
  async _printRosterSheet(btn) {
    this._sheetBusy = true; this._sheetError = ''; btn.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/roster-sheet/${this.matchId}`);
      const d = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(d.error || `HTTP ${res.status}`);
      GameCenterScreen.printRosterSheet(d, this);
    } catch (err) { this._sheetError = err.message; }
    this._sheetBusy = false; btn.disabled = false;
    this._render();
  }
  // The sheet, drawn to the form: title block + EPYSA badge, the header
  // pairs, the coaches table, the players table, the signature line.
  static rosterSheetHtml(d, screen) {
    const esc = (t) => (screen ? screen.escapeHtml(t) : String(t == null ? '' : t));
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('roster_sheet', tier, tokens) : '';
    const t = d.team || {}, m = d.match || {};
    const game = m.opponent ? `${t.label || ''} ${m.is_home === false ? 'at' : 'vs'} ${m.opponent}` : (t.label || '');
    const kv = (k, v) => `<div class="rs-kv"><span class="rs-k">${esc(k)}</span><span class="rs-v">${esc(v)}</span></div>`;
    const coachRows = (d.coaches || []).map(c => `<tr><td class="rs-img"><div class="rs-ph"></div></td><td>${esc(c.name)}</td><td>${esc(c.role_label)}</td><td></td><td>${esc(c.email)}</td><td>${esc(c.phone)}</td></tr>`).join('');
    // A name stored all in lower case (a few LeagueApps rows) prints in
    // title case; surname order ignores case so it lands in its place.
    const tidy = (n) => { const t = String(n || ''); return t === t.toLowerCase() ? t.replace(/(^|[\s\-'])(\S)/g, (m, a, b) => a + b.toUpperCase()) : t; };
    const players = (d.players || []).slice().sort((a, b) => String(a.last_name || '').toLowerCase().localeCompare(String(b.last_name || '').toLowerCase()) || String(a.first_name || '').toLowerCase().localeCompare(String(b.first_name || '').toLowerCase()));
    const playerRows = players.map((p, i) => `<tr><td class="rs-n">${i + 1}</td><td class="rs-img"><div class="rs-ph"></div></td><td>${p.starter ? '<span class="rs-star">★</span> ' : ''}${esc(tidy(p.last_name))}, ${esc(tidy(p.first_name))}</td><td class="rs-c">${esc(p.jersey)}</td><td></td><td>${esc(p.birthyear)}</td><td class="rs-c">P</td><td>${esc(p.assigned)}</td></tr>`).join('');
    return `<div class="rs-sheet">
      <div class="rs-title">
        <div class="rs-t1">${esc(t.roster_title)}</div>
        <div class="rs-t2">${esc(t.club_name)}</div>
        <div class="rs-t3">${esc(t.team_name)}</div>
        <img class="rs-badge" src="/images/epysa.png" alt="">
      </div>
      <div class="rs-head">
        <div class="rs-left">${kv('Association:', t.association)}${kv('Season:', t.season_label)}<div class="rs-kv"><span class="rs-k"></span><span class="rs-v">${esc(t.official_label)}</span></div>${kv('Division:', t.division)}${kv('Team Number:', t.external_team_id)}</div>
        <div class="rs-right">${kv('Age:', t.age)}${kv('Gender:', t.gender)}${kv('Level:', t.level)}<div class="rs-kv"><span class="rs-k">Color:</span><span class="rs-v"><span class="rs-sw" style="background:#111"></span><span class="rs-sw" style="background:#fff"></span> ${esc(t.color)}</span></div></div>
      </div>
      <table class="rs-table rs-coaches"><thead><tr><th class="rs-img">User Image</th><th>Name</th><th>Role</th><th>Reg#</th><th>Email/UserID</th><th>Phone</th></tr></thead><tbody>${coachRows || '<tr><td colspan="6" style="height:16pt;"></td></tr>'}</tbody></table>
      <table class="rs-table rs-players"><thead><tr><th class="rs-n"></th><th class="rs-img">User Image</th><th>Name</th><th class="rs-c">Jersey</th><th>Reg#</th><th>Birthyear</th><th class="rs-c">Status</th><th>Assignment/Approved Date</th></tr></thead><tbody>${playerRows}</tbody></table>
      <div class="rs-sign"><span>${esc(copy('signed') || 'Signed:')}</span><span class="rs-line"></span><span>${esc(copy('date') || 'Date:')}</span><span class="rs-line rs-short"></span></div>
      <div class="rs-coachword">${esc(copy('coach_word') || 'Coach')}</div>
      <div class="rs-foot">${esc(copy('printed_for', { game, when: m.when_text || '' }) || `${game} · ${m.when_text || ''}`)} · ${esc(d.printed_at || '')}</div>
    </div>`;
  }
  static rosterSheetCss() {
    return `
      .rs-sheet { position:relative; width:612pt; min-height:792pt; background:#fff; color:#111; font-family: Helvetica, Arial, sans-serif; font-size:7.5pt; box-sizing:border-box; padding:22pt 24pt 20pt 24pt; }
      .rs-sheet * { box-sizing:border-box; }
      .rs-title { text-align:center; position:relative; padding-right:70pt; padding-left:70pt; }
      .rs-t1 { font-weight:800; font-size:9.5pt; margin-top:4pt; } .rs-t2 { font-weight:800; font-size:9.5pt; margin-top:9pt; } .rs-t3 { font-weight:800; font-size:9.5pt; margin-top:9pt; }
      .rs-badge { position:absolute; right:0; top:0; width:56pt; }
      .rs-head { display:flex; justify-content:space-between; margin-top:26pt; }
      .rs-kv { display:flex; gap:4pt; line-height:1.45; } .rs-k { font-weight:800; width:52pt; text-align:right; } .rs-right .rs-k { width:36pt; }
      .rs-sw { display:inline-block; width:8pt; height:8pt; border:1px solid #333; margin-right:2pt; vertical-align:middle; }
      .rs-table { border-collapse:collapse; width:100%; margin-top:8pt; }
      .rs-table th { background:#d9d9d9; border:1px solid #777; text-align:left; padding:1pt 3pt; font-size:7pt; font-weight:800; }
      .rs-table td { border:1px solid #777; padding:1pt 3pt; vertical-align:top; font-size:7.3pt; }
      .rs-coaches td { height:28pt; } .rs-players td { height:30pt; }
      .rs-img { width:62pt; } .rs-n { width:14pt; } .rs-c { text-align:center; }
      .rs-ph { width:28pt; height:26pt; border:1px dashed #bbb; margin:0 auto; }
      .rs-star { color:#111; font-size:8pt; }
      .rs-sign { display:flex; align-items:flex-end; gap:8pt; margin:22pt 0 0 250pt; font-weight:700; }
      .rs-line { display:inline-block; border-bottom:1px solid #111; width:150pt; height:10pt; } .rs-short { width:80pt; }
      .rs-coachword { margin-left:292pt; font-size:7pt; }
      .rs-foot { position:absolute; left:24pt; bottom:14pt; font-size:6.5pt; color:#777; }
    `;
  }
  // Same print path as #invoices / #cup-rosters: the sheet alone on a
  // zero-margin letter page.
  static printRosterSheet(d, screen) {
    const was = document.title;
    const root = document.createElement('div'); root.className = 'rs-print-root'; root.innerHTML = GameCenterScreen.rosterSheetHtml(d, screen);
    const pageStyle = document.createElement('style'); pageStyle.textContent = '@page { size: letter; margin: 0; }';
    document.head.appendChild(pageStyle);
    const style = document.createElement('style');
    style.textContent = GameCenterScreen.rosterSheetCss() + `
      @media print { html, body { margin:0 !important; padding:0 !important; } body.rs-printing > :not(.rs-print-root) { display:none !important; } body.rs-printing { background:#fff !important; }
        .rs-print-root th { -webkit-print-color-adjust:exact; print-color-adjust:exact; } }
      @media screen { .rs-print-root { display:none; } }`;
    root.appendChild(style);
    document.body.appendChild(root);
    document.body.classList.add('rs-printing');
    document.title = `Roster-${String((d.team || {}).label || 'team').replace(/[^A-Za-z0-9]+/g, '-')}`;
    const done = () => { document.body.classList.remove('rs-printing'); root.remove(); pageStyle.remove(); document.title = was; window.removeEventListener('afterprint', done); };
    window.addEventListener('afterprint', done);
    setTimeout(() => window.print(), 50);
    setTimeout(done, 60000);
  }

  // fresh = pull from the league first; otherwise just reopen the copy
  // this game already holds.  The tab is opened inside the tap (so the
  // popup blocker allows it) and pointed at the PDF once it arrives.
  async _printOfficialRoster(fresh) {
    const o = this.officialRoster;
    if (!o || (this._rosterPull && this._rosterPull.busy)) return;
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('official_roster', tier, { league: o.league, ...tokens }) : '';
    const tab = window.open('', '_blank');
    if (tab && fresh) { try { tab.document.title = copy('title'); tab.document.body.textContent = copy('working'); } catch (e) { /* cosmetic */ } }
    this._rosterPull = { busy: true };
    this._render();
    try {
      if (fresh) {
        const res = await this.auth.fetch(`/api/official-roster/${this.matchId}/refresh`, { method: 'POST' });
        const data = await res.json().catch(() => ({}));
        if (!res.ok || !data.success) throw new Error(data.error || `HTTP ${res.status}`);
        this.officialRoster = data;
      }
      const res = await this.auth.fetch(`/api/official-roster/${this.matchId}/pdf`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const url = URL.createObjectURL(await res.blob());
      if (tab) tab.location = url;
      else { const a = document.createElement('a'); a.href = url; a.target = '_blank'; a.rel = 'noopener'; document.body.appendChild(a); a.click(); a.remove(); }
      setTimeout(() => URL.revokeObjectURL(url), 10 * 60 * 1000);   // long enough to print from the tab
      this._rosterPull = null;
    } catch (err) {
      if (tab) tab.close();
      this._rosterPull = { error: err.message };
    }
    this._render();
  }

  async _sendToOpponent(btn) {
    const contactId = Number(btn.dataset.contact); const channel = btn.dataset.gcOppSend;
    const sel = this.element && this.element.querySelector('[data-gc-opp-tier]');
    this._oppTier = sel ? sel.value : (this._oppTier || 'confirm');
    const original = btn.textContent; btn.disabled = true; btn.textContent = '⏳';
    try {
      const data = await this._postReminder('/api/opponents/message', { contact_id: contactId, channel, tier: this._oppTier, match_id: this.matchId, message: this._oppMsg || '' });
      const k = [...(((this.oppContacts || {}).club || {}).contacts || []), ...(((this.oppContacts || {}).league || {}).contacts || [])].find(x => x.id === contactId);
      if (k) { k.last_sent_at = 'just now'; k.last_channel = channel; }
      if (channel === 'email') this.openGmailCompose(data.gmail_href);
      else (window.DesktopSms ? DesktopSms.open(data.sms_href) : (window.location.href = data.sms_href));
      this._render();
    } catch (err) {
      console.error('[game-center] opponent message failed:', err);
      btn.textContent = original; btn.disabled = false;
      alert(`Could not open the message: ${err.message}`);
    }
  }

  // ✉️ Email all / 💬 Text all for a block: one compose to everyone in it.
  async _sendToOpponentAll(btn) {
    const channel = btn.dataset.gcOppSendAll;
    const ids = String(btn.dataset.ids || '').split(',').map(Number).filter(Boolean);
    const sel = this.element && this.element.querySelector('[data-gc-opp-tier]');
    if (!btn.dataset.tier) this._oppTier = sel ? sel.value : (this._oppTier || 'confirm');
    // A ⛔ cancel button carries its own message (mig 1094).
    const tier = btn.dataset.tier || this._oppTier;
    const original = btn.textContent; btn.disabled = true; btn.textContent = '⏳';
    try {
      const data = await this._postReminder('/api/opponents/message', { contact_ids: ids, channel, tier, match_id: this.matchId, message: this._oppMsg || '' });
      const all = [...(((this.oppContacts || {}).club || {}).contacts || []), ...(((this.oppContacts || {}).league || {}).contacts || [])];
      for (const k of all) if (ids.includes(k.id)) { k.last_sent_at = 'just now'; k.last_channel = channel; }
      if (channel === 'email') this.openGmailCompose(data.gmail_href);
      else (window.DesktopSms ? DesktopSms.open(data.sms_href) : (window.location.href = data.sms_href));
      this._render();
    } catch (err) {
      console.error('[game-center] opponent group message failed:', err);
      btn.textContent = original; btn.disabled = false;
      alert(`Could not open the message: ${err.message}`);
    }
  }

  async _saveOpponentContact(btn) {
    const form = btn.closest('[data-gc-opp-form]'); const club = this.oppContacts && this.oppContacts.club;
    if (!form || !club) return;
    const v = (f) => { const el = form.querySelector(`[data-f="${f}"]`); return el ? el.value.trim() : ''; };
    try {
      await this._postReminder('/api/opponents/contact', { club_id: club.id, match_id: this.matchId, name: v('name'), role: v('role'), phone: v('phone'), email: v('email') });
      this._oppAddOpen = false;
      await this._loadOpponentContacts();
      this._render();
    } catch (err) { alert(`Could not save: ${err.message}`); }
  }
}

Mixin.into(GameCenterScreen, GameCenterRosterPrint);
