// WelcomeDuePanel — 👋 new registrations still owed a welcome, in the 🚦
// band's popup (mig 1599).  Owner 2026-11-20: "any new registration show as
// a todo like missing rsvp etc at top of page. action items. for me admin.
// they would show until i send welcome right?" + "the button for them
// should take me right to contact for them right? and pre selegct welcome
// message to club?"
//
// The band shows a red "👋 Welcome — N new: …  Welcome ›" box while anyone
// is owed (club/super admins, never while viewing as).  This is its popup:
//
//   Tap a name — their contact opens with the welcome ready …
//   [👋 Asif Nifaz      Boys · registered Nov 20 · to Fatima]
//   [👋 John Williams   Boys · registered Nov 18 · to Mary  ]
//
// A name opens the one 📇 Contact popup (SectionContact list for their
// section) with 👋 Welcome preselected; sending records person_welcomes and
// the list reloads, so they leave the band.  Words: event_center welcome_*.
//
//   const p = new WelcomeDuePanel(el, { fetchJson, escapeHtml, auth, onChange(list) });
//   p.load();   p.render();
class WelcomeDuePanel {
  constructor(el, ctx) {
    this.el = el;
    this.ctx = ctx;
    this.due = [];
    this.busy = false;
    this.err = '';
    if (el) el.addEventListener('click', (e) => {
      const done = e.target.closest('[data-wd-done]');
      if (done) { this.done([Number(done.getAttribute('data-wd-done'))]); return; }
      if (e.target.closest('[data-wd-done-all]')) { this.done(this.due.map(p => Number(p.person_id))); return; }
      const b = e.target.closest('[data-wd-person]');
      if (b) this.contact(Number(b.getAttribute('data-wd-person')));
    });
  }

  static cp(tier, tokens, fb) {
    return (window.MessageCopy && MessageCopy.has && MessageCopy.has('event_center', tier))
      ? MessageCopy.block('event_center', tier, tokens) : fb;
  }

  // Admins only, and only as themselves — a 403 just means no box.
  static wanted(auth) {
    const role = auth && auth.user && auth.user.role;
    return !!auth && !auth.viewAsPersonId && ['club', 'super'].includes(role);
  }

  async load() {
    if (!WelcomeDuePanel.wanted(this.ctx.auth)) { this.set([]); return; }
    try { this.set((await this.ctx.fetchJson('/api/welcomes/due')).due || []); }
    catch (_) { /* the band just shows no box */ }
  }

  set(list) {
    this.due = Array.isArray(list) ? list : [];
    this.render();
    if (this.ctx.onChange) this.ctx.onChange(this.due);
  }

  // ✓ Done / ✓ Done all (mig 1602, owner 11/20 "done all or done each one
  // indivicually … pretty much all are old"): off the list, nothing sent.
  async done(ids) {
    if (this.busy || !ids.length) return;
    this.busy = true; this.err = ''; this.render();
    try {
      await this.ctx.fetchJson('/api/welcomes/dismiss', { method: 'POST', body: JSON.stringify({ person_ids: ids }) });
      const gone = new Set(ids);
      this.busy = false;
      this.set(this.due.filter(p => !gone.has(Number(p.person_id))));
    } catch (e) {
      this.busy = false; this.err = e.message || 'Could not mark done'; this.render();
    }
  }

  static nameOf(p) { return `${p.first_name || ''} ${p.last_name || ''}`.trim(); }

  recipientsOf(p) {
    const pid = Number(p.person_id);
    const list = (p.recipients || []).map(r => ({
      personId: Number(r.person_id), name: r.name || WelcomeDuePanel.nameOf(p),
      phone: r.phone || null, email: r.email || null, forPersonId: pid }));
    return list.length ? list : [{ personId: pid, name: WelcomeDuePanel.nameOf(p), phone: null, email: null, forPersonId: pid }];
  }

  contact(personId) {
    const p = this.due.find(x => Number(x.person_id) === personId);
    if (!p || !window.ContactPopup || !window.SectionContact) return;
    const recipients = this.recipientsOf(p);
    const parent = recipients.find(r => r.personId !== personId);
    // A Screen (its Gmail / sms compose helpers) carrying the band's auth — the
    // popup sends through screen.openGmailCompose etc. (11/20 "screen.openGmailCompose
    // is not a function" with a bare {auth}).
    const screen = Object.assign(Object.create(Screen.prototype), { auth: this.ctx.auth });
    ContactPopup.open({
      key: `welcome-due:${personId}`, screen, recipients,
      messages: SectionContact.messages(p.section, {
        screen, playerId: personId, first: p.first_name || '',
        parentFirst: parent ? String(parent.name || '').split(' ')[0] : '',
        onWelcomeSent: () => this.load(),
      }),
      defaultKey: 'welcome',
      title: `Contact ${WelcomeDuePanel.nameOf(p)}`,
    });
  }

  render() {
    if (!this.el) return;
    const esc = this.ctx.escapeHtml;
    const cp = WelcomeDuePanel.cp;
    if (!this.due.length) {
      this.el.innerHTML = `<p style="margin:4px 0; color:#475569;">${esc(cp('welcome_empty', {}, 'Everyone new has been welcomed. ✓'))}</p>`;
      return;
    }
    const SECTION = { mens: "Men's", womens: "Women's", boys: 'Boys', girls: 'Girls' };
    const day = (ymd) => {
      const d = new Date(`${ymd}T12:00:00`);
      return isNaN(d) ? ymd : d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    };
    const rows = this.due.map(p => {
      const parents = (p.recipients || []).filter(r => r.is_guardian && Number(r.person_id) !== Number(p.person_id));
      const bits = [SECTION[p.section] || '', p.registered_at ? cp('welcome_reg_on', { date: day(p.registered_at) }, `registered ${day(p.registered_at)}`) : '',
                    parents.length ? cp('welcome_via', { parent: parents.map(r => String(r.name || '').split(' ')[0]).join(' & ') }, `to ${parents.map(r => r.name).join(' & ')}`) : '']
        .filter(Boolean).join(' · ');
      return `<div style="display:flex; gap:6px; margin:0 0 6px;">
          <button type="button" data-wd-person="${esc(p.person_id)}" title="${esc(p.programs || '')}"
            style="flex:1; min-width:0; display:flex; align-items:center; gap:8px; text-align:left; padding:9px 10px;
                   border:1px solid #f0abfc; border-left:4px solid #c026d3; border-radius:6px; background:#fdf4ff; cursor:pointer; font:inherit;">
            <span style="font-weight:800; color:#0f172a;">👋 ${esc(WelcomeDuePanel.nameOf(p))}</span>
            <span style="margin-left:auto; font-size:0.78rem; color:#64748b; text-align:right;">${esc(bits)}</span>
          </button>
          <button type="button" data-wd-done="${esc(p.person_id)}" ${this.busy ? 'disabled' : ''}
            style="flex:none; padding:0 12px; border-radius:6px; border:1px solid #22c55e; background:transparent; color:#22c55e; font:inherit; font-weight:800; cursor:pointer;">${esc(cp('welcome_done', {}, '✓ Done'))}</button>
        </div>`;
    }).join('');
    const all = `<button type="button" data-wd-done-all ${this.busy ? 'disabled' : ''}
        style="align-self:flex-start; margin:0 0 10px; padding:7px 14px; border-radius:8px; border:0; background:#16a34a; color:#fff; font:inherit; font-weight:800; cursor:pointer;">
        ${esc(cp('welcome_done_all', { n: this.due.length }, `✓ Done all (${this.due.length})`))}</button>`;
    const err = this.err ? `<p style="margin:0 0 8px; color:#fca5a5; font-size:0.8rem;">${esc(this.err)}</p>` : '';
    this.el.innerHTML = `<p style="margin:0 0 8px; font-size:0.85rem; color:#94a3b8;">${esc(cp('welcome_intro', {},
      'Tap a name — their contact opens with the welcome ready. ✓ Done takes someone off without sending.'))}</p>${all}${err}${rows}`;
  }
}

window.WelcomeDuePanel = WelcomeDuePanel;
