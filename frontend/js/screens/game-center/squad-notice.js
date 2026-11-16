// 📣 Squad game reminder + player reminders (mig 383/384)
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterSquadNotice {
  // { squad, untold, sms: {sent_at}, email: {sent_at} } for this game.
  async _loadSquadNotice() {
    try {
      const res = await this.auth.fetch(`/api/rsvp-board/squad-notice?match_id=${this.matchId}`);
      const data = await res.json();
      this.squadNotice = (res.ok && data.status) || null;
    } catch (err) {
      this.squadNotice = null;
    }
  }


  _sentTitle(sent) {
    return `Reminded this week — last ${this._sentWhen(sent.sent_at)}` + (sent.count > 1 ? ` (${sent.count} times)` : '');
  }

  // A reminder lists the player's whole week, so either channel — from
  // this game, another game or #rsvps — dims both buttons.  The tally is
  // the week's sends on both channels.
  _weekSent(sent) {
    const each = ['sms', 'email'].map(c => sent[c]).filter(Boolean);
    if (!each.length) return null;
    return { count: each.reduce((n, x) => n + (x.count || 1), 0),
             sent_at: each.map(x => x.sent_at).sort().pop() };
  }

  // "text Sat 10:07 AM ×2 · email Fri 6:30 PM"
  _sentNote(sent) {
    return ['sms', 'email'].filter(c => sent[c]).map(c =>
      `${c === 'sms' ? 'text' : 'email'} ${this._sentWhen(sent[c].sent_at)}${sent[c].count > 1 ? ' ×' + sent[c].count : ''}`).join(' · ')
      + (sent.total ? ` · ${sent.total} all-time` : '');
  }

  // Dim the buttons of whoever a fresh send reached, without a re-render
  // (that would roll the No Response section up).
  _paintSent() {
    this.element.querySelectorAll('[data-gc-remind]').forEach(btn => {
      const sent = (this.reminders || {})[btn.dataset.personId] || {};
      const mine = this._weekSent(sent);
      if (!mine) return;
      btn.style.opacity = '0.4';
      btn.title = this._sentTitle(mine) + ' — click to send again';
      btn.textContent = `${btn.dataset.gcRemind === 'sms' ? '💬' : '✉'} REMIND ✓ ×${mine.count}`;
      const note = btn.parentElement.querySelector('[data-gc-remind-note]');
      if (note) note.textContent = this._sentNote(sent);
    });
  }


  // Card button — the same personal reminder #rsvps sends.  The DOM is
  // patched in place: a re-render would roll the No Response section up.
  async _remindPlayer(btn) {
    const channel = btn.dataset.gcRemind === 'email' ? 'email' : 'sms';
    const note = btn.parentElement.querySelector('[data-gc-remind-note]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      // fh_event_id: the message leads with this game and its link opens on
      // it, highlighted, above the rest of the week (mig 739).
      const data = await this._postReminder('/api/rsvp-board/remind', { person_id: Number(btn.dataset.personId), channel, fh_event_id: this._fhEventId() || 0 });
      this.openSends(data, channel);
      btn.textContent = original;
      await this._loadReminders();
      this._paintSent();
    } catch (err) {
      btn.textContent = original;
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.disabled = false;
  }

  // Bar button — one group message.  Carriers cap group MMS around 10
  // people (see my.js Text All), so a bigger group becomes several links.
  async _remindNoResponse(btn) {
    const channel = btn.dataset.gcRemindAll === 'email' ? 'email' : 'sms';
    const slot = btn.parentElement.querySelector('[data-gc-remind-result]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      const data = await this._postReminder('/api/rsvp-board/remind-event',
        // Players only — the No Response list above is players, so the
        // message matches it (owner 2026-10-06: coaches never in a player total).
        { match_id: Number(this.matchId), scope: 'week', channel, role: 'player' });
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      let html;
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        html = `✉ Email drafted to ${contacts.length} (BCC)${skipped}`;
      } else {
        const CHUNK_SIZE = 10;
        const chunks = [];
        chunks.push(...Screen.chunkContacts(contacts, data.kids, CHUNK_SIZE));   // parents of one kid never share a part (mig 682)
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        html = chunks.length === 1
          ? `💬 Group text drafted to ${contacts.length}${skipped}`
          : `Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a href="${this.escapeHtml(h)}" style="display:inline-block; padding:3px 9px; border-radius:6px; text-decoration:none; font-weight:800; font-size:0.68rem; color:#fff; background:#0284c7;">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ') + skipped;
        if (chunks.length === 1) (window.DesktopSms ? DesktopSms.open(hrefs[0]) : (window.location.href = hrefs[0]));
      }
      if (slot) slot.innerHTML = html;
      await this._loadReminders();
      this._paintSent();
    } catch (err) {
      if (slot) slot.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.textContent = original;
    btn.disabled = false;
  }

  // Squad bar button — one group message, same drafting as
  // _remindNoResponse (carriers cap a group text around 10 people).
  async _sendSquadNotice(btn) {
    const channel = btn.dataset.gcSquadNotice === 'email' ? 'email' : 'sms';
    const slot = btn.parentElement.querySelector('[data-gc-squad-result]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      // A role changed seconds ago must be in the DB before the send reads it.
      if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
      const data = await this._postReminder('/api/rsvp-board/squad-notice',
        { match_id: Number(this.matchId), channel, scope: btn.dataset.scope === 'changed' ? 'changed' : 'all' });
      const contacts = data.contacts || [];
      const skipped = data.no_contact
        ? ` · ${data.no_contact} skipped (no ${channel === 'sms' ? 'mobile' : 'email'} on file)` : '';
      let html;
      if (channel === 'email') {
        this.openGmailCompose(this.buildGmailComposeHref({ bcc: contacts.join(','), subject: data.subject, body: data.body }));
        html = `✉ Email drafted to ${contacts.length} (BCC)${skipped}`;
      } else {
        const CHUNK_SIZE = 10;
        const chunks = [];
        chunks.push(...Screen.chunkContacts(contacts, data.kids, CHUNK_SIZE));   // parents of one kid never share a part (mig 682)
        const hrefs = chunks.map(c => this.buildSmsComposeHref({ to: c.join(','), body: data.body }));
        html = chunks.length === 1
          ? `💬 Group text drafted to ${contacts.length}${skipped}`
          : `Carriers cap a group text around ${CHUNK_SIZE} people — open each part: ` +
            hrefs.map((h, i) => `<a href="${this.escapeHtml(h)}" style="display:inline-block; padding:3px 9px; border-radius:6px; text-decoration:none; font-weight:800; font-size:0.68rem; color:#fff; background:#0284c7;">💬 Part ${i + 1}/${chunks.length} (${chunks[i].length})</a>`).join(' ') + skipped;
        if (chunks.length === 1) (window.DesktopSms ? DesktopSms.open(hrefs[0]) : (window.location.href = hrefs[0]));
      }
      this.squadNotice = data.status || this.squadNotice;
      // Re-render so every card and the bar dim together; the result
      // line (the Part 1/2 links) goes back in afterwards.
      this._render();
      const fresh = this.element.querySelector('[data-gc-squad-result]');
      if (fresh) fresh.innerHTML = html;
      return;
    } catch (err) {
      if (slot) slot.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.textContent = original;
    btn.disabled = false;
  }

  // Card button — one player's own game reminder.
  async _sendSquadNoticeOne(btn) {
    const channel = btn.dataset.gcSquadOne === 'email' ? 'email' : 'sms';
    const note = (btn.closest('[data-gc-contact]') || btn.parentElement).querySelector('[data-gc-squad-note]');
    const original = btn.textContent;
    btn.disabled = true;
    btn.textContent = '⏳';
    try {
      if (this._saveTimer) { clearTimeout(this._saveTimer); this._saveTimer = null; await this._saveLineup(); }
      const data = await this._postReminder('/api/rsvp-board/squad-notice',
        { match_id: Number(this.matchId), person_id: Number(btn.dataset.personId), channel });
      this.openSends(data, channel);
      this.squadNotice = data.status || this.squadNotice;
      this._render();
      return;
    } catch (err) {
      if (note) note.innerHTML = `<span style="color:#f87171;">${this.escapeHtml(err.message)}</span>`;
    }
    btn.textContent = original;
    btn.disabled = false;
  }
}

Mixin.into(GameCenterScreen, GameCenterSquadNotice);
