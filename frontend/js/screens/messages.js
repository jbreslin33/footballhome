// MessagesScreen — 💬 Messages (📣 Marketing): the LeagueApps program
// description for each club, ready to paste.
//
// Owner 2026-11-19: "messaages is for copy and paste and i only need that
// for la desc" → "so clean that page root and stem" (mig 1597).  Pick a
// club, read its description, 📋 Copy writes text/html + text/plain so the
// LeagueApps Description editor keeps the bold, headings and bullets.
//
// The description is window.LighthouseProgramInfo.buildProgramDescription
// (the program_* message_templates rows, mig 370 — same text as the
// public program-info pages).  The page's own words are messages_page rows
// (mig 1597).  Lead follow-ups / broadcasts live on the Leads page, not here.

class MessagesScreen extends Screen {
  // One pill per club; `audience` is what buildProgramDescription reads.
  static CLUBS = [
    { key: 'boys',  audience: { isYouth: true } },
    { key: 'girls', audience: { isYouth: true } },
    { key: 'men',   audience: { isMensClub: true } },
    { key: 'women', audience: { isWomensClub: true } },
  ];

  constructor(navigation, auth) {
    super(navigation, auth);
    this._selected = MessagesScreen.CLUBS[0].key;
    this._ready = false;
  }

  _w(tier, tokens = {}) {
    return (window.MessageCopy && MessageCopy.block('messages_page', tier, tokens)) || '';
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div style="padding: var(--space-4); max-width: 900px;">
        <div id="msg-clubs" style="display:flex; flex-wrap:wrap; gap: var(--space-2); margin-bottom: var(--space-4);"></div>
        <div id="msg-body"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  async onEnter() {
    this.element.addEventListener('click', (e) => {
      const pill = e.target.closest('[data-club]');
      if (pill) {
        this._selected = pill.dataset.club;
        this._draw();
        return;
      }
      const btn = e.target.closest('[data-copy]');
      if (btn) this._copy(btn);
    });
    await Promise.all([
      window.MessageCopy ? MessageCopy.load(this.auth) : null,
      window.LighthouseProgramInfo.loadRegisterLinks(),
    ]);
    this._ready = true;
    this._draw();
  }

  _draw() {
    this.find('#msg-clubs').innerHTML = MessagesScreen.CLUBS.map((c) => {
      const on = c.key === this._selected;
      return `<button type="button" class="btn ${on ? 'btn-primary' : 'btn-secondary'}" data-club="${c.key}">${this.escapeHtml(this._w(`club_${c.key}`))}</button>`;
    }).join('');

    const body = this.find('#msg-body');
    if (!this._ready) return;
    const club = MessagesScreen.CLUBS.find((c) => c.key === this._selected);
    const desc = window.LighthouseProgramInfo.buildProgramDescription(club.audience);
    if (!desc || !desc.html) {
      body.innerHTML = `<p style="opacity:0.7;">${this.escapeHtml(this._w('empty'))}</p>`;
      return;
    }
    // White paper, black ink: a faithful preview of the LeagueApps page.
    body.innerHTML = `
      <section style="border: 1px solid var(--border-color); border-radius: 8px; padding: var(--space-3); background: var(--bg-surface); color: var(--text-primary);">
        <div style="display:flex; align-items:center; justify-content:space-between; gap: var(--space-2); margin-bottom: var(--space-2);">
          <div style="font-weight: 600;">${this.escapeHtml(this._w('card_title', { club: this._w(`club_${club.key}`) }))}</div>
          <button type="button" class="btn btn-secondary" data-copy>${this.escapeHtml(this._w('copy'))}</button>
        </div>
        <div id="msg-desc" style="padding: var(--space-3); background: #ffffff; color: #111111; border: 1px solid #d1d5db; border-radius: 4px; font-size: 0.9rem; line-height: 1.55;">${desc.html}</div>
      </section>
    `;
    this._text = desc.text;
  }

  async _copy(btn) {
    const html = this.find('#msg-desc').innerHTML;
    const text = this._text || this.find('#msg-desc').textContent;
    const flash = (tier) => {
      btn.textContent = this._w(tier);
      btn.disabled = true;
      setTimeout(() => { btn.textContent = this._w('copy'); btn.disabled = false; }, 1400);
    };
    try {
      if (typeof ClipboardItem !== 'undefined' && navigator.clipboard?.write) {
        await navigator.clipboard.write([new ClipboardItem({
          'text/html':  new Blob([html], { type: 'text/html' }),
          'text/plain': new Blob([text], { type: 'text/plain' }),
        })]);
      } else {
        await navigator.clipboard.writeText(text);
      }
      flash('copied');
    } catch (err) {
      console.error('Copy failed:', err);
      flash('copy_failed');
    }
  }
}
