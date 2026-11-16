// 📇 Opponent contacts — the panel (mig 483) and contact email drafts (mig 724)
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterOpponent {
  // The opponent club of this game with its contacts (mig 483) — feeds the
  // 📇 Contact <club> panel under Game details.  Coach-of-either-team or
  // admin endpoint; a 403 or an unmatched opponent just hides the panel's
  // buttons.  Owner 2026-09-28: "right on the game center i should be able
  // to contact them".
  async _loadOpponentContacts() {
    try {
      const res = await this.auth.fetch(`/api/opponents/for-match/${this.matchId}`);
      const data = await res.json();
      this.oppContacts = res.ok ? data : null;
    } catch (err) {
      this.oppContacts = null;
    }
    await this._loadPanelDrafts();
  }

  _renderOpponentContactsPanel() {
    const o = this.oppContacts;
    if (!this.isCoach || !o) return '';
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens) => window.MessageCopy ? MessageCopy.block('opponent', tier, tokens) : '';
    const club = o.club;
    // ⛔ Cancel this game (owner 11/5): forfeit / weather / field — ONE
    // email to the other club's contacts, the league directors and the
    // league's officers (ref assignor included), wording ready (kind
    // opponent tiers cancel_*, mig 1094).  Opponent contacts first, so the
    // email's {club} is the other club.
    const cancelRow = () => {
      const seen = new Set();
      const ids = [...((club && club.contacts) || []), ...((o.league && o.league.contacts) || [])]
        .filter(k => k.email && !seen.has(k.id) && seen.add(k.id)).map(k => k.id);
      const cancels = (o.tiers || []).filter(t => String(t.tier).startsWith('cancel_'));
      if (!cancels.length) return '';
      const head = copy('cancel_title', { n: ids.length }) || `⛔ Cancel this game — one email to the other club, the league and the ref assignor (${ids.length})`;
      return `<div style="margin:6px 0 8px; padding:6px 8px; border:1px solid #7f1d1d; border-radius:8px; background:rgba(127,29,29,0.15);">
        <div style="font-size:0.7rem; font-weight:700; margin-bottom:4px;">${esc(head)}</div>
        ${ids.length ? `<div style="display:flex; gap:6px; flex-wrap:wrap;">${cancels.map(t => `<button class="btn btn-secondary" data-gc-opp-send-all="email" data-tier="${esc(t.tier)}" data-ids="${ids.join(',')}"
              style="padding:3px 8px; font-size:0.7rem; border-color:#b91c1c;">✉️ ${esc(t.label)}</button>`).join('')}</div>`
          : `<div style="font-size:0.68rem; opacity:0.75;">${esc(copy('cancel_none') || 'No email on file for the other club or the league yet — add one below.')}</div>`}
      </div>`;
    };
    const wrap = (title, inner) => this.panelFoldHtml('opp_contacts', title, `
        ${club ? `<div style="display:flex; justify-content:flex-end; margin-bottom:4px;"><button class="btn btn-secondary" data-gc-opp-page="${club.id}" style="padding:2px 8px; font-size:0.66rem;">Opponents page ↗</button></div>` : ''}
        ${this._panelDraftButtons('data-gc-draft-open')}
        ${cancelRow()}
        ${inner}`);
    if (!club) {
      const lg0 = o.league;
      const lgBlock0 = lg0 && (lg0.contacts || []).length ? `<div style="margin-top:8px;"><div style="font-size:0.72rem; font-weight:700; opacity:0.8;">${esc(copy('game_center_league', { league: lg0.name || lg0.label }) || `🏛 ${lg0.name || lg0.label} league directors`)}</div>${lg0.contacts.map(k => `<div style="font-size:0.72rem; padding:3px 0;"><b>${esc(k.name || '')}</b> <span style="opacity:0.65;">${esc(k.role || '')}</span> <span style="opacity:0.7;">${esc([k.phone, k.email].filter(Boolean).join(' · '))}</span> ${this._oppContactButton(k)} ${this._draftBtn(k)}</div>${this._draftsArea(k, lg0)}`).join('')}</div>` : '';
      return wrap('📇 Contact opponent', `<div style="font-size:0.72rem; opacity:0.75; line-height:1.4;">${esc(copy('game_center_none', { opponent: o.opponent_text || '?' }) || `No club matched to "${o.opponent_text || '?'}".`)}
        <button class="btn btn-secondary" data-gc-opp-page="0" style="padding:2px 8px; font-size:0.66rem; margin-left:6px;">Open Opponents</button></div>${lgBlock0}`);
    }
    const tiers = o.tiers || [];
    const tierSel = `<select data-gc-opp-tier style="font-size:0.7rem; padding:3px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); max-width:100%;">
        ${tiers.map(t => `<option value="${esc(t.tier)}" ${t.tier === (this._oppTier || 'confirm') ? 'selected' : ''}>${esc(t.label)}</option>`).join('')}</select>`;
    // Owner 2026-10-09: "buttons to text or email them individually or
    // group" — a block's ✉️ Email all / 💬 Text all go to everyone in it
    // with that channel (one BCC email, one group text); the league body's
    // directors for this game's age group sit under the opponent (mig 558).
    const allBtns = (list, scope) => {
      const emails = list.filter(k => k.email).map(k => k.id), phones = list.filter(k => k.phone).map(k => k.id);
      if (emails.length + phones.length < 2) return '';
      return `<div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:6px;">
        ${phones.length > 1 ? `<button class="btn btn-secondary" data-gc-opp-send-all="sms" data-scope="${scope}" data-ids="${phones.join(',')}" style="padding:3px 8px; font-size:0.7rem;">${esc(copy('game_center_all_sms') || '💬 Text all')} (${phones.length})</button>` : ''}
        ${emails.length > 1 ? `<button class="btn btn-primary" data-gc-opp-send-all="email" data-scope="${scope}" data-ids="${emails.join(',')}" style="padding:3px 8px; font-size:0.7rem;">${esc(copy('game_center_all_email') || '✉️ Email all')} (${emails.length})</button>` : ''}
      </div>`;
    };
    const contactRows = (list, lgForDrafts = null) => list.map(k => `
      <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; padding:5px 0; border-top:1px solid var(--border-color); font-size:0.76rem;">
        <div style="flex:1; min-width:140px;">
          <b>${esc(k.name || k.role || 'Team mailbox')}</b>${k.name && k.role ? ` <span style="opacity:0.65;">· ${esc(k.role)}</span>` : ''}
          <div style="font-size:0.68rem; opacity:0.7; overflow-wrap:anywhere;">${esc([k.phone, k.email].filter(Boolean).join(' · '))}</div>
          ${k.last_sent_at ? `<div style="font-size:0.64rem; opacity:0.6;">Last ${k.last_channel === 'sms' ? 'text' : 'email'} ${esc(k.last_sent_at)}</div>` : ''}
        </div>
        ${this._oppContactButton(k)}
        ${lgForDrafts ? this._draftBtn(k) : ''}
      </div>${lgForDrafts ? this._draftsArea(k, lgForDrafts) : ''}`).join('');
    const rows = contactRows(club.contacts || []);
    const lg = o.league;
    const leagueBlock = lg && (lg.contacts || []).length ? `
      <div style="margin-top:10px; padding-top:6px; border-top:2px solid var(--border-color);">
        <div style="font-size:0.72rem; font-weight:700; opacity:0.8;">${esc(copy('game_center_league', { league: lg.name || lg.label }) || `🏛 ${lg.name || lg.label} league directors`)}${lg.age ? ` <span style="opacity:0.6; font-weight:400;">· U${esc(lg.age)}</span>` : ''}</div>
        ${contactRows(lg.contacts, lg)}
        ${allBtns(lg.contacts, 'league')}
      </div>` : '';
    const addForm = this._oppAddOpen ? `
      <div data-gc-opp-form style="display:grid; grid-template-columns:repeat(auto-fit, minmax(120px, 1fr)); gap:4px; margin-top:6px;">
        ${['name', 'role', 'phone', 'email'].map(f => `<input data-f="${f}" placeholder="${f[0].toUpperCase() + f.slice(1)}" style="font-size:0.72rem; padding:5px 6px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); min-width:0;">`).join('')}
        <button class="btn btn-primary" data-gc-opp-save style="padding:4px 8px; font-size:0.7rem;">Save</button>
      </div>` : '';
    return wrap(esc(copy('game_center_title', { club: club.name }) || `📇 Contact ${club.name}`), `
      <div style="display:flex; gap:6px; align-items:center; flex-wrap:wrap; font-size:0.7rem; opacity:0.85;">Message: ${tierSel}</div>
      ${(this._oppTier || 'confirm') === 'custom' ? `<textarea data-gc-opp-msg rows="4" placeholder="${esc(copy('custom_placeholder') || 'Type your message')}"
          style="width:100%; box-sizing:border-box; margin-top:6px; font-size:0.76rem; font-family:inherit; padding:6px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); resize:vertical;">${esc(this._oppMsg || '')}</textarea>` : ''}
      ${rows || `<div style="font-size:0.72rem; opacity:0.75; margin-top:4px;">${esc(copy('no_contacts') || 'No contact yet — add a name, phone or email.')}</div>`}
      ${allBtns(club.contacts || [], 'club')}
      <div style="margin-top:6px;"><button class="btn btn-secondary" data-gc-opp-add style="padding:2px 8px; font-size:0.66rem;">${this._oppAddOpen ? 'Cancel' : '＋ contact'}</button></div>
      ${addForm}${leagueBlock}`);
  }

  // 📝 Drafts to one league contact (mig 724) — owner 2026-10-26: email the
  // APSL commissioner our home-game times "without others being involved",
  // drafts kept until sent or deleted.  Send opens Gmail filled in (same
  // compose as every ✉️ button) and logs it; one-offs get deleted.
  _draftBtn(k) {
    if (!k.email) return '';
    const open = this._draftsFor === k.id;
    return `<button class="btn btn-secondary" data-gc-draft-toggle="${k.id}" style="padding:3px 8px; font-size:0.7rem;">${open ? '✕ Close' : '📝 Draft'}</button>`;
  }

  _draftsArea(k, lg) {
    if (this._draftsFor !== k.id) return '';
    const esc = (t) => this.escapeHtml(t);
    const copy = (tier, tokens = {}) => window.MessageCopy ? MessageCopy.block('contact_draft', tier, tokens) : '';
    const d = this._draftsData;
    const box = 'font-size:0.74rem; padding:6px 8px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); width:100%; box-sizing:border-box;';
    let inner;
    if (!d) inner = `<div style="font-size:0.72rem; opacity:0.7;">Loading…</div>`;
    else if (d.error) inner = `<div style="font-size:0.72rem; color:#fca5a5;">${esc(d.error)}</div>`;
    else if (this._draftEdit) {
      const e = this._draftEdit;
      // To (mig 726): the director stays; anyone else in this panel can be added.
      const rec = e.recipients || [];
      const o = this.oppContacts || {};
      const pool = [...(((o.club || {}).contacts) || []), ...(((o.league || {}).contacts) || [])]
        .filter(c => c.email && !rec.some(r => r.id === c.id));
      inner = `
        <div style="display:flex; gap:4px; flex-wrap:wrap; align-items:center; font-size:0.7rem; margin-bottom:4px;">
          <span style="opacity:0.7;">To:</span>
          ${rec.map(r => `<span style="padding:2px 6px; border-radius:10px; border:1px solid var(--border-color);">${esc(r.name || r.email)}${r.id !== this._draftsFor ? ` <button data-gc-draft-unrec="${r.id}" style="border:0; background:none; color:inherit; cursor:pointer; padding:0 2px; min-width:0; min-height:0;">✕</button>` : ''}</span>`).join('')}
          ${pool.length ? `<select data-gc-draft-addrec style="font-size:0.68rem; padding:2px 4px; border-radius:6px; border:1px solid var(--border-color); background:var(--bg-primary); color:var(--text-primary); max-width:160px;"><option value="">＋ add</option>${pool.map(c => `<option value="${c.id}">${esc(c.name || c.email)}</option>`).join('')}</select>` : ''}
        </div>
        <input data-gc-draft-subject value="${esc(e.subject)}" placeholder="Subject" style="${box}">
        <textarea data-gc-draft-body rows="8" style="${box} margin-top:4px; font-family:inherit; resize:vertical;">${esc(e.body)}</textarea>
        <div style="display:flex; gap:6px; flex-wrap:wrap; margin-top:4px;">
          <button class="btn btn-primary" data-gc-draft-send style="padding:3px 10px; font-size:0.72rem;">✉️ Send</button>
          <button class="btn btn-secondary" data-gc-draft-save style="padding:3px 10px; font-size:0.72rem;">💾 Save draft</button>
          <button class="btn btn-secondary" data-gc-draft-cancel style="padding:3px 10px; font-size:0.72rem;">Cancel</button>
          ${e.id ? `<button class="btn btn-secondary" data-gc-draft-delete="${e.id}" style="padding:3px 10px; font-size:0.72rem; margin-left:auto;">🗑 Delete</button>` : ''}
        </div>`;
    } else {
      const drafts = d.drafts || [], sent = d.sent || [];
      inner = `
        ${drafts.map(x => `
          <div style="display:flex; align-items:center; gap:6px; flex-wrap:wrap; padding:4px 0; border-top:1px dashed var(--border-color); font-size:0.72rem;">
            <div style="flex:1; min-width:140px;"><b>${esc(x.subject || '(no subject)')}</b> <span style="opacity:0.6;">· draft, ${esc(x.updated_label)}</span>
              ${(x.recipients || []).length > 1 ? `<div style="font-size:0.66rem; opacity:0.7;">To: ${esc(x.recipients.map(r => r.name || r.email).join(', '))}</div>` : ''}</div>
            <button class="btn btn-secondary" data-gc-draft-edit="${x.id}" style="padding:2px 8px; font-size:0.68rem;">Edit</button>
            <button class="btn btn-secondary" data-gc-draft-delete="${x.id}" style="padding:2px 8px; font-size:0.68rem;">🗑</button>
          </div>`).join('')}
        <button class="btn btn-primary" data-gc-draft-new style="padding:3px 10px; font-size:0.72rem; margin-top:4px;">＋ New email</button>
        ${sent.length ? `<div style="margin-top:6px; font-size:0.66rem; opacity:0.65;">${sent.map(x => `Sent ${esc(x.sent_label)}: ${esc(x.subject || '(no subject)')}`).join('<br>')}</div>` : ''}`;
    }
    return `
      <div data-gc-drafts style="margin:2px 0 6px; padding:8px; border-radius:8px; background:rgba(59,130,246,0.08); border:1px solid rgba(59,130,246,0.35);">
        <div style="font-size:0.68rem; opacity:0.8; margin-bottom:6px; line-height:1.4;">${esc(copy('note', { name: k.name || k.email }))}</div>
        ${inner}
      </div>`;
  }

  async _draftsLoad(contactId) {
    await this._loadPanelDrafts();
    try {
      const res = await this.auth.fetch(`/api/contact-drafts?contact_id=${contactId}`);
      const data = await res.json().catch(() => ({}));
      this._draftsData = res.ok ? data : { error: data.error || `HTTP ${res.status}` };
    } catch (err) { this._draftsData = { error: err.message }; }
    this._render();
  }

  // The prefilled subject/body for a new email: this game when we're on one.
  _draftNew(contactId) {
    const o = this.oppContacts || {}, lg = o.league || {};
    const k = (lg.contacts || []).find(x => x.id === contactId) || {};
    const recipients = [{ id: contactId, name: k.name, email: k.email }];
    const me = (this.auth && this.auth.getUser && this.auth.getUser()) || {};
    const m = this.matchDetails || {};
    const tokens = {
      first: String(k.name || '').split(/\s+/)[0] || 'there',
      league: lg.label || lg.name || '',
      matchup: m.home_team_name && m.away_team_name ? `${m.home_team_name} vs ${m.away_team_name}` : (this.title || ''),
      date: this._whenLabel() || '',
      sender: me.name || [me.first_name, me.last_name].filter(Boolean).join(' ') || '',
    };
    const tier = this.matchId ? 'new_game' : 'new_plain';
    const r = (window.MessageCopy && MessageCopy.render('contact_draft', tier, tokens)) || {};
    this._draftEdit = { id: 0, contactId, subject: r.subject || '', body: r.body || '', recipients };
  }

  _draftReadForm() {
    const el = this.element; if (!el || !this._draftEdit) return;
    const su = el.querySelector('[data-gc-draft-subject]'), bo = el.querySelector('[data-gc-draft-body]');
    if (su) this._draftEdit.subject = su.value;
    if (bo) this._draftEdit.body = bo.value;
  }

  async _draftSave() {
    this._draftReadForm();
    const e = this._draftEdit;
    const data = await this._postReminder('/api/contact-drafts', { id: e.id || 0, contact_id: e.contactId || this._draftsFor, match_id: this.matchId || 0, subject: e.subject, body: e.body,
      recipient_ids: (e.recipients || []).map(r => r.id) });
    return data.draft;
  }

  async _draftClick(btn) {
    try {
      if (btn.dataset.gcDraftToggle) {
        const id = Number(btn.dataset.gcDraftToggle);
        this._draftEdit = null; this._draftsData = null;
        this._draftsFor = this._draftsFor === id ? null : id;
        this._render();
        if (this._draftsFor) await this._draftsLoad(id);
        return;
      }
      if (btn.hasAttribute('data-gc-draft-new')) { this._draftNew(this._draftsFor); this._render(); return; }
      if (btn.dataset.gcDraftEdit) {
        const x = ((this._draftsData || {}).drafts || []).find(d => d.id === Number(btn.dataset.gcDraftEdit));
        if (x) { this._draftEdit = { id: x.id, contactId: x.contact_id, subject: x.subject, body: x.body, recipients: (x.recipients || []).slice() }; this._render(); }
        return;
      }
      if (btn.hasAttribute('data-gc-draft-cancel')) { this._draftEdit = null; this._render(); return; }
      if (btn.dataset.gcDraftUnrec) {
        this._draftReadForm();
        this._draftEdit.recipients = (this._draftEdit.recipients || []).filter(r => r.id !== Number(btn.dataset.gcDraftUnrec));
        this._render(); return;
      }
      if (btn.hasAttribute('data-gc-draft-save')) {
        btn.disabled = true;
        await this._draftSave();
        this._draftEdit = null;
        await this._draftsLoad(this._draftsFor);
        return;
      }
      if (btn.hasAttribute('data-gc-draft-send')) {
        btn.disabled = true;
        const d = await this._draftSave();
        const sent = await this._postReminder('/api/contact-drafts/sent', { id: d.id });
        this.openGmailCompose(this.buildGmailComposeHref({ to: sent.to, subject: d.subject, body: d.body }));
        this._draftEdit = null;
        await this._draftsLoad(this._draftsFor);
        return;
      }
      if (btn.dataset.gcDraftDelete) {
        if (!confirm('Delete this draft?')) return;
        const res = await this.auth.fetch(`/api/contact-drafts?id=${Number(btn.dataset.gcDraftDelete)}`, { method: 'DELETE' });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        this._draftEdit = null;
        await this._draftsLoad(this._draftsFor);
      }
    } catch (err) {
      console.error('[game-center] contact draft failed:', err);
      btn.disabled = false;
      alert(`Could not do that: ${err.message}`);
    }
  }
}

Mixin.into(GameCenterScreen, GameCenterOpponent);
