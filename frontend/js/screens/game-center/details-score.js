// 📝 Game details + score — the announcement's details panel and the result's score (slice C)
//
// Part of GameCenterScreen (screens/game-center.js), split into its own file
// 2026-11-16 (owner: "practice and games should be consistent interface and
// extend from same base class") so the game child of EventScreen stays slim:
// these methods are copied onto GameCenterScreen's prototype by Mixin.into
// (lib/mixin.js) — `this` is the screen, exactly as before the move.

class GameCenterDetailsScore {
  // Date/time line for the frame. `when` arrives from the My page card
  // (gcal-derived, already formatted) when we got here from there; any
  // other entry point (team dashboard, a saved #game-center link) leaves
  // it empty, so fall back to the same gcal start the trailing "game"
  // practice pill uses, then to the matches row's own date for an
  // unlinked game. Cleared after a details save so the new date shows.
  _whenLabel() {
    if (this.when) return this.when;
    const m = this.matchDetails;
    let d = null;
    if (m && m.gcal_linked && this.matchStartsAt) {
      // EligibilityController renders gcal_events.starts_at through a
      // UTC session with no offset marker ("2026-09-13T16:00:00" for a
      // noon ET kickoff) — parse it as UTC so the local time is right.
      const raw = String(this.matchStartsAt);
      d = new Date(/Z$|[+-]\d\d:?\d\d$/.test(raw) ? raw : raw + 'Z');
    } else if (m && m.event_date) {
      d = new Date(String(m.event_date).replace(' ', 'T')); // naive local date+time on the matches row
    }
    if (!d || isNaN(d.getTime())) return '';
    const date = d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
    const hasTime = !(m && !m.gcal_linked && !m.match_time);
    const time = hasTime ? d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' }) : '';
    return [date, time].filter(Boolean).join(' · ');
  }

  // Which side of the fixture is us — the pill labels and the details
  // panel read "Opponent" from the other side.
  _isHomeSide() {
    const m = this.matchDetails;
    return !!(m && this.teamId != null && String(m.home_team_id) === String(this.teamId));
  }

  // Coach-only panel under the Game Announcement frame (slice C).
  //
  // Two shapes, decided by the match's ownership:
  //  - gcal_linked (every real fixture): opponent, kick-off, venue and
  //    league are read-only with a pointer to the club Google Calendar.
  //    Writing them into `matches` would be a dead edit — the My page
  //    and the RSVP flow read fh_events/gcal_events, so players would
  //    keep seeing the calendar's values while this page drifted.
  //  - unlinked (ad-hoc lineup games, scrimmages): the fields
  //    #match-form used to own — home/away, opponent team, date, time,
  //    venue — edited in place via PUT /api/matches/:matchId.
  _renderGameDetailsPanel() {
    const m = this.matchDetails;
    if (!this.isCoach || !m) return '';
    const isHome = this._isHomeSide();
    const opponent = isHome ? (m.away_team_name || '') : (m.home_team_name || '');
    const venue = m.venue_location || m.venue_name || '';
    const row = (label, value) => `
      <div style="display:flex; justify-content:space-between; gap:12px; padding:5px 0; border-bottom:1px solid var(--border-color); font-size:0.78rem;">
        <span style="opacity:0.7; flex:0 0 auto;">${label}</span>
        <span style="text-align:right; overflow-wrap:anywhere;">${value ? this.escapeHtml(value) : '<span style="opacity:0.5;">—</span>'}</span>
      </div>`;
    const listHtml = `
      ${row('Opponent', opponent)}
      ${row('Home / Away', m.home_team_id ? (isHome ? 'Home' : 'Away') : '')}
      ${row('Kick-off', this._whenLabel())}
      ${row('Venue', venue)}
      ${row('League', m.league_tag || m.competition_name || '')}`;

    const wrap = (inner) => `
      ${this.panelFoldHtml('game_details', `⚽ Game details`, `
        ${inner}
`)}`;

    if (m.gcal_linked) {
      return wrap(`
        ${listHtml}
        <div style="font-size:0.7rem; opacity:0.75; margin-top:8px; line-height:1.4;">
          📅 These come from the club schedule — change them there.
        </div>`);
    }

    if (!this.announceEditing) {
      return wrap(`
        ${listHtml}
        <div style="display:flex; justify-content:flex-end; margin-top:8px;">
          <button type="button" id="gc-announce-edit" class="btn btn-secondary" style="font-size:0.75rem; padding:4px 10px;">✏️ Edit details</button>
        </div>
        ${this._detailsMsg ? `<div style="font-size:0.7rem; margin-top:6px; opacity:0.8;">${this.escapeHtml(this._detailsMsg)}</div>` : ''}`);
    }

    // Edit form — the same fields #match-form carried, minus the ones
    // that aren't about the fixture (title, competition, status, notes).
    const opponentId = isHome ? m.away_team_id : m.home_team_id;
    const teamOpts = (this.teamList || [])
      .filter(t => String(t.id) !== String(this.teamId))
      .map(t => `<option value="${t.id}" ${String(t.id) === String(opponentId) ? 'selected' : ''}>${this.escapeHtml(t.name || '')}</option>`)
      .join('');
    const venueOpts = (this.venueList || [])
      .map(v => `<option value="${v.id}" ${String(v.id) === String(m.venue_id) ? 'selected' : ''}>${this.escapeHtml(`${v.name || ''}${v.city ? ' - ' + v.city : ''}`)}</option>`)
      .join('');
    const loading = (!this.teamList || !this.venueList) ? '<span style="font-size:0.68rem; opacity:0.6;">loading lists…</span>' : '';
    const timeVal = m.match_time ? String(m.match_time).slice(0, 5) : '';
    const field = (label, inner) => `
      <label style="display:flex; flex-direction:column; gap:3px; font-size:0.7rem; opacity:0.9;">
        <span style="opacity:0.75;">${label}</span>${inner}
      </label>`;
    return wrap(`
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:8px; margin-top:6px;">
        ${field('Home / Away', `
          <select id="gc-ann-home-away" class="form-input" style="font-size:0.8rem; padding:6px 8px;">
            <option value="home" ${isHome || !m.home_team_id ? 'selected' : ''}>Home</option>
            <option value="away" ${!isHome && m.home_team_id ? 'selected' : ''}>Away</option>
          </select>`)}
        ${field('Opponent', `
          <select id="gc-ann-opponent" class="form-input" style="font-size:0.8rem; padding:6px 8px;">
            <option value="">${opponent ? this.escapeHtml(opponent) + ' (unchanged)' : 'Select opponent…'}</option>${teamOpts}
          </select>`)}
        ${field('Date', `<input type="date" id="gc-ann-date" class="form-input" style="font-size:0.8rem; padding:6px 8px;" value="${this.escapeHtml(m.match_date || '')}">`)}
        ${field('Kick-off', `<input type="time" id="gc-ann-time" class="form-input" style="font-size:0.8rem; padding:6px 8px;" value="${this.escapeHtml(timeVal)}">`)}
      </div>
      <div style="margin-top:8px;">
        ${field('Venue', `
          <select id="gc-ann-venue" class="form-input" style="font-size:0.8rem; padding:6px 8px;">
            <option value="">${venue ? this.escapeHtml(venue) + ' (unchanged)' : 'Select a venue…'}</option>${venueOpts}
          </select>`)}
      </div>
      <div style="display:flex; justify-content:space-between; align-items:center; gap:8px; margin-top:10px;">
        ${loading}
        <div style="display:flex; gap:8px; margin-left:auto;">
          <button type="button" id="gc-announce-edit" class="btn btn-secondary" style="font-size:0.75rem; padding:4px 10px;">Cancel</button>
          <button type="button" id="gc-announce-save" class="btn btn-primary" style="font-size:0.75rem; padding:4px 10px;" ${this._matchSaving ? 'disabled' : ''}>Save details</button>
        </div>
      </div>
      ${this._detailsMsg ? `<div style="font-size:0.7rem; margin-top:6px; opacity:0.8;">${this.escapeHtml(this._detailsMsg)}</div>` : ''}`);
  }

  // Team + venue dropdown sources for the edit form, fetched once per
  // visit and only when the form actually opens — no coach pays for two
  // list fetches just to look at the announcement.
  async _ensureDetailOptions() {
    if (this.teamList && this.venueList) return;
    try {
      const [tRes, vRes] = await Promise.all([
        this.auth.fetch('/api/teams'),
        this.auth.fetch('/api/venues'),
      ]);
      const tData = await tRes.json().catch(() => null);
      const vData = await vRes.json().catch(() => null);
      this.teamList  = (tData && Array.isArray(tData.data)) ? tData.data : [];
      this.venueList = (vData && Array.isArray(vData.data)) ? vData.data : [];
    } catch (err) {
      console.error('[game-center] failed to load team/venue lists:', err);
      this.teamList = this.teamList || [];
      this.venueList = this.venueList || [];
      this._detailsMsg = 'Could not load team and venue lists.';
    }
    if (this.announceEditing && this.pill === 'game_day') this._render();
  }

  async _saveGameDetails() {
    if (this._matchSaving) return;
    const homeAway = this.find('#gc-ann-home-away')?.value || 'home';
    const opponentId = this.find('#gc-ann-opponent')?.value || '';
    const date = this.find('#gc-ann-date')?.value || '';
    const time = this.find('#gc-ann-time')?.value || '';
    const venueId = this.find('#gc-ann-venue')?.value || '';
    const body = {};
    if (date) body.date = date;
    if (time) body.start_time = time;
    if (venueId) body.venue_id = Number(venueId);
    // Team ids only move together, and only when an opponent was chosen —
    // the backend skips absent keys, so an untouched dropdown changes nothing.
    if (opponentId && this.teamId != null) {
      body.home_team_id = homeAway === 'home' ? Number(this.teamId) : Number(opponentId);
      body.away_team_id = homeAway === 'home' ? Number(opponentId) : Number(this.teamId);
    }
    if (!Object.keys(body).length) { this._detailsMsg = 'Nothing to save.'; this._render(); return; }
    const ok = await this._putMatch(body, 'details');
    if (ok) {
      this.announceEditing = false;
      this.when = ''; // re-derive the frame's date line from the saved row
      this._detailsMsg = 'Details saved.';
    }
    this._render();
  }

  // Coach-only score entry under the Match Result frame (slice C). Save
  // writes both scores and flips match_status to completed; Clear sends
  // explicit nulls (the backend treats an absent key as "leave alone")
  // and puts the match back to scheduled.
  _renderScorePanel() {
    const m = this.matchDetails;
    if (!this.isCoach || !m) return '';
    const hs = m.home_team_score ?? m.home_score;
    const as = m.away_team_score ?? m.away_score;
    const hasScore = hs != null && as != null;
    const scoreInput = (id, label, val) => `
      <label style="display:flex; flex-direction:column; gap:3px; font-size:0.7rem; min-width:0;">
        <span style="opacity:0.75; text-transform:uppercase; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">${this.escapeHtml(label)}</span>
        <input type="number" inputmode="numeric" min="0" max="999" id="${id}" class="form-input"
               style="font-size:1.2rem; font-weight:700; text-align:center; padding:6px;"
               value="${val != null ? this.escapeHtml(String(val)) : ''}" ${this._matchSaving ? 'disabled' : ''}>
      </label>`;
    return `
      ${this.panelFoldHtml('score', `🏆 ${hasScore ? 'Result' : 'Record the result'}`, `
        <div style="display:grid; grid-template-columns:1fr auto 1fr; gap:10px; align-items:end;">
          ${scoreInput('gc-score-home', m.home_team_name || 'Home', hs)}
          <span style="font-size:1.2rem; font-weight:700; opacity:0.6; padding-bottom:8px;">–</span>
          ${scoreInput('gc-score-away', m.away_team_name || 'Away', as)}
        </div>
        <div style="display:flex; justify-content:flex-end; gap:8px; margin-top:10px;">
          ${hasScore ? `<button type="button" id="gc-score-clear" class="btn btn-secondary" style="font-size:0.75rem; padding:4px 10px;" ${this._matchSaving ? 'disabled' : ''}>Clear</button>` : ''}
          <button type="button" id="gc-score-save" class="btn btn-primary" style="font-size:0.75rem; padding:4px 10px;" ${this._matchSaving ? 'disabled' : ''}>${hasScore ? 'Update result' : 'Save result'}</button>
        </div>
        ${this._scoreMsg ? `<div style="font-size:0.7rem; margin-top:6px; opacity:0.8;">${this.escapeHtml(this._scoreMsg)}</div>` : ''}
`)}`;
  }

  async _saveScore(clear) {
    if (this._matchSaving) return;
    let body;
    if (clear) {
      body = { home_team_score: null, away_team_score: null, match_status: 'scheduled' };
    } else {
      const h = (this.find('#gc-score-home')?.value || '').trim();
      const a = (this.find('#gc-score-away')?.value || '').trim();
      if (!/^\d{1,3}$/.test(h) || !/^\d{1,3}$/.test(a)) {
        this._scoreMsg = 'Enter both scores as whole numbers.';
        this._render();
        return;
      }
      body = { home_team_score: Number(h), away_team_score: Number(a), match_status: 'completed' };
    }
    const ok = await this._putMatch(body, 'score');
    if (ok) this._scoreMsg = clear ? 'Score cleared.' : 'Result saved.';
    this._render();
  }

  // One PUT /api/matches/:matchId, then a re-read of the same GET the
  // bootstrap uses so matchDetails (header, result summary, Instagram
  // card) reflects the row as saved rather than what we think we sent.
  // Returns true on success; the message slot named by `which` gets the
  // failure text otherwise.
  async _putMatch(body, which) {
    if (!this.matchId) return false;
    this._matchSaving = true;
    this._render();
    let ok = false;
    try {
      const res = await this.auth.fetch(`/api/matches/${this.matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = await res.json().catch(() => null);
      if (!res.ok || !data || !data.success) {
        throw new Error((data && data.message) || `Save failed (${res.status})`);
      }
      const fresh = await this.auth.fetch(`/api/matches/${this.matchId}`);
      const freshData = await fresh.json().catch(() => null);
      if (freshData && freshData.success) {
        this.matchDetails = freshData.data;
        // The post_game Instagram card builds its preview graphic from this
        // same object inside its render() — hand it the fresh row and
        // repaint, so the "? - ?" placeholder becomes the scoreline without
        // a remount (which would drop a caption mid-draft).
        if (this.socialCard) {
          this.socialCard.matchContext = this.matchDetails || {};
          try { this.socialCard.render(); } catch (err) { console.warn('[game-center] social card repaint failed:', err); }
        }
      }
      ok = true;
    } catch (err) {
      console.error('[game-center] match save failed:', err);
      if (which === 'score') this._scoreMsg = err.message || 'Could not save the result.';
      else this._detailsMsg = err.message || 'Could not save the details.';
    } finally {
      this._matchSaving = false;
    }
    return ok;
  }
}

Mixin.into(GameCenterScreen, GameCenterDetailsScore);
