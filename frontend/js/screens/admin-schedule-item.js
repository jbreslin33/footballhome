// ─────────────────────────────────────────────────────────────────
// ScheduleItemScreen — unified view + edit + delete for a single
// schedule row (match, practice, or pickup).  Reached from
// AdminScheduleScreen by clicking any card; also reachable from
// admin-club → schedule tile → card.
//
// Design goal: parity with PersonScreen — one detail surface that
// knows how to render the item and how to mutate it, so operators
// don't have to hop between practice-dashboard (edit practice),
// match-detail (view match), and admin-series-editor (recurring
// templates) to change one thing.
//
// Backend contract:
//   GET    /api/matches/:id
//     → returns id, title, event_date, match_date, match_time,
//       venue_id, venue_name/address, home_team_id/name,
//       away_team_id/name, match_type ('match'|'practice'|'pickup'
//       |'scrimmage'|'tournament'|'cup'|'custom'), match_status,
//       home_team_score, away_team_score, notes, manual_override,
//       series_id, is_cancelled.
//   PUT    /api/matches/:id            body = editable fields
//   DELETE /api/matches/:id
//   GET    /api/venues                 for the venue picker
//   GET    /api/matches/:id/rsvp-summary  best-effort attendance
//
// Navigation:
//   opened via navigation.goTo('admin-schedule-item', {
//     matchId, returnTo, returnToParams }).  Back-nav pops history
//   so the caller's snapshotted filter state is restored (same
//   contract as PersonScreen).
class AdminScheduleItemScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this._returnTo = null;
    this._returnToParams = null;
    this._match = null;
    this._venues = null;   // lazy-loaded list for edit mode
    this._editing = false;
    this._saving  = false;
  }

  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <div class="screen-header">
        <button class="back-btn">← Back</button>
        <h1 id="sched-item-title">Schedule Item</h1>
      </div>
      <div class="screen-body" style="padding:16px;">
        <div id="sched-item-loading" style="text-align:center; padding:24px; color:var(--text-secondary);">Loading…</div>
        <div id="sched-item-error"   style="display:none; padding:16px; background:#7f1d1d; color:#fecaca; border-radius:8px; margin-bottom:12px;"></div>
        <div id="sched-item-body"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    div.querySelector('.back-btn').addEventListener('click', () => this._goBack());
    return div;
  }

  onEnter(params) {
    const raw = params?.matchId ?? params?.id ?? null;
    this._matchId = raw != null ? String(raw) : null;
    this._returnTo = params?.returnTo || null;
    this._returnToParams = params?.returnToParams || null;
    this._editing = false;
    this._match = null;

    if (!this._matchId) {
      this._showError('No matchId provided');
      return;
    }
    this._load();
  }

  _goBack() {
    // Same contract as PersonScreen — pop history so the caller's
    // snapshotted filter state is restored.  Fallback to explicit
    // returnTo goTo only when there's no history to pop.
    if (window.history.length > 1) {
      window.history.back();
      return;
    }
    if (this._returnTo) {
      this.navigation.goTo(this._returnTo, this._returnToParams || {});
    }
  }

  _showError(msg) {
    const err = this.find('#sched-item-error');
    const loading = this.find('#sched-item-loading');
    if (loading) loading.style.display = 'none';
    if (err) { err.style.display = 'block'; err.textContent = msg; }
  }

  async _load() {
    const loading = this.find('#sched-item-loading');
    const body    = this.find('#sched-item-body');
    const err     = this.find('#sched-item-error');
    if (loading) loading.style.display = 'block';
    if (body)    body.style.display = 'none';
    if (err)     err.style.display  = 'none';

    try {
      const res = await this.auth.fetch(`/api/matches/${this._matchId}`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const bodyJson = await res.json();
      const data = bodyJson?.data || bodyJson;
      if (!data || !data.id) throw new Error('Match not found');
      this._match = data;

      // RSVP summary is a nice-to-have — never fail the screen on it.
      this._rsvp = null;
      try {
        const rsvpRes = await this.auth.fetch(`/api/matches/${this._matchId}/rsvp-summary`);
        if (rsvpRes.ok) {
          const rsvpBody = await rsvpRes.json();
          this._rsvp = rsvpBody?.data || rsvpBody;
        }
      } catch (_) { /* silent */ }

      this._renderBody();
    } catch (e) {
      this._showError(`Failed to load: ${e.message}`);
    }
  }

  _renderBody() {
    const loading = this.find('#sched-item-loading');
    const body    = this.find('#sched-item-body');
    if (loading) loading.style.display = 'none';
    if (!body) return;
    body.style.display = 'block';
    body.innerHTML = this._editing ? this._renderEdit() : this._renderView();
    this._wireBody();
  }

  // ── View mode ────────────────────────────────────────────────────
  _renderView() {
    const m = this._match;
    const kind = String(m.match_type || 'match').toLowerCase();
    const emoji = { match:'⚽', practice:'🏃', pickup:'🎯', scrimmage:'🥅',
                    tournament:'🏆', cup:'🏆', league:'⚽', custom:'📅' }[kind] || '📅';
    const kindLabel = kind.charAt(0).toUpperCase() + kind.slice(1);
    const dt = m.event_date ? new Date(m.event_date) : null;
    const dateStr = dt
      ? dt.toLocaleDateString(undefined, { weekday:'long', month:'short', day:'numeric', year:'numeric' })
      : '—';
    const timeStr = m.match_time || (dt
      ? dt.toLocaleTimeString(undefined, { hour:'numeric', minute:'2-digit' })
      : '');

    const hasScore = m.home_team_score !== undefined && m.home_team_score !== null;
    const isMatch  = ['match','league','custom','scrimmage','tournament','cup'].includes(kind);
    const homeName = this.escapeHtml(m.home_team_name || 'TBD');
    const awayName = this.escapeHtml(m.away_team_name || 'TBD');
    const status   = this.escapeHtml(m.match_status || 'scheduled');
    const venue    = this.escapeHtml(m.venue_name || '');
    const venueAddr = this.escapeHtml([m.venue_address, m.venue_city, m.venue_state].filter(Boolean).join(', '));
    const notes    = this.escapeHtml(m.notes || '');

    const badges = [];
    if (m.manual_override) badges.push('<span style="padding:2px 8px; border-radius:999px; background:#7c2d12; color:#fed7aa; font-size:0.75rem; font-weight:600;">🔒 Manual override</span>');
    if (m.series_id)       badges.push('<span style="padding:2px 8px; border-radius:999px; background:#1e3a8a; color:#dbeafe; font-size:0.75rem; font-weight:600;">🔁 Recurring series</span>');
    if (m.is_cancelled)    badges.push('<span style="padding:2px 8px; border-radius:999px; background:#7f1d1d; color:#fecaca; font-size:0.75rem; font-weight:600;">✕ Cancelled</span>');

    const rsvpBlock = this._renderRsvpBlock();
    const opponentBlock = isMatch
      ? `
        <div style="display:flex; align-items:center; justify-content:space-around; gap:12px; padding:16px 12px; background:var(--bg-secondary); border-radius:12px; margin-top:12px;">
          <div style="flex:1; text-align:center;">
            <div style="font-weight:700; font-size:1.05rem;">${homeName}</div>
            <div style="color:var(--text-secondary); font-size:0.8rem;">Home</div>
          </div>
          <div style="font-weight:700; font-size:1.6rem; color:var(--text-primary);">
            ${hasScore ? `${m.home_team_score} – ${m.away_team_score}` : 'vs'}
          </div>
          <div style="flex:1; text-align:center;">
            <div style="font-weight:700; font-size:1.05rem;">${awayName}</div>
            <div style="color:var(--text-secondary); font-size:0.8rem;">Away</div>
          </div>
        </div>`
      : `
        <div style="padding:16px 12px; background:var(--bg-secondary); border-radius:12px; margin-top:12px; text-align:center;">
          <div style="font-weight:700; font-size:1.05rem;">${homeName}</div>
          <div style="color:var(--text-secondary); font-size:0.8rem; margin-top:2px;">${kindLabel} team</div>
        </div>`;

    const openMatchSheet = isMatch
      ? `<button class="sched-item-open-match" style="padding:8px 14px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-secondary); color:var(--text-primary); cursor:pointer; font-weight:600;">Open match sheet →</button>`
      : '';

    const openSeries = m.series_id
      ? `<button class="sched-item-open-series" style="padding:8px 14px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-secondary); color:var(--text-primary); cursor:pointer; font-weight:600;">Open series →</button>`
      : '';

    return `
      <div style="max-width:720px; margin:0 auto; display:flex; flex-direction:column; gap:12px;">
        <div style="display:flex; align-items:center; gap:10px; flex-wrap:wrap;">
          <span style="font-size:1.8rem;">${emoji}</span>
          <div style="flex:1; min-width:200px;">
            <div style="font-weight:700; font-size:1.25rem; color:var(--text-primary);">${this.escapeHtml(m.title || kindLabel)}</div>
            <div style="color:var(--text-secondary); font-size:0.9rem;">${kindLabel}</div>
          </div>
          <div style="display:flex; gap:6px; flex-wrap:wrap;">${badges.join('')}</div>
        </div>

        <div style="background:var(--bg-secondary); padding:14px 16px; border-radius:12px; display:grid; grid-template-columns:auto 1fr; column-gap:16px; row-gap:8px;">
          <div style="color:var(--text-secondary); font-weight:600;">📅 Date</div>
          <div>${this.escapeHtml(dateStr)}${timeStr ? ` &middot; ${this.escapeHtml(timeStr)}` : ''}</div>
          <div style="color:var(--text-secondary); font-weight:600;">📍 Venue</div>
          <div>${venue || '<span style="color:var(--text-secondary);">— no venue set —</span>'}${venueAddr ? `<div style="color:var(--text-secondary); font-size:0.85rem;">${venueAddr}</div>` : ''}</div>
          <div style="color:var(--text-secondary); font-weight:600;">Status</div>
          <div><span style="padding:2px 10px; border-radius:999px; background:${this._statusColor(status)}; color:#fff; font-size:0.8rem; font-weight:600; text-transform:capitalize;">${status}</span></div>
          ${m.competition_name ? `
            <div style="color:var(--text-secondary); font-weight:600;">Competition</div>
            <div>${this.escapeHtml(m.competition_name)}</div>
          ` : ''}
        </div>

        ${opponentBlock}

        ${notes ? `
          <div style="background:var(--bg-secondary); padding:12px 14px; border-radius:12px;">
            <div style="color:var(--text-secondary); font-weight:600; margin-bottom:4px; font-size:0.85rem;">Notes</div>
            <div style="white-space:pre-wrap; color:var(--text-primary);">${notes}</div>
          </div>` : ''}

        ${rsvpBlock}

        <div style="display:flex; gap:8px; flex-wrap:wrap; margin-top:8px;">
          <button class="sched-item-edit" style="padding:10px 18px; border-radius:8px; border:none; background:var(--color-primary, #2563eb); color:#fff; cursor:pointer; font-weight:600;">✏️ Edit</button>
          ${openMatchSheet}
          ${openSeries}
          <div style="flex:1;"></div>
          <button class="sched-item-delete" style="padding:10px 18px; border-radius:8px; border:1px solid #b91c1c; background:transparent; color:#fca5a5; cursor:pointer; font-weight:600;">🗑️ Delete</button>
        </div>
      </div>
    `;
  }

  _renderRsvpBlock() {
    const r = this._rsvp;
    if (!r) return '';
    // Response shape varies — accept several common keys.
    const yes    = Number(r.attending ?? r.yes ?? r.going ?? 0) || 0;
    const maybe  = Number(r.maybe ?? r.tentative ?? 0) || 0;
    const no     = Number(r.not_attending ?? r.no ?? r.declined ?? 0) || 0;
    const total  = Number(r.total ?? (yes + maybe + no)) || 0;
    if (total === 0) return '';
    return `
      <div style="background:var(--bg-secondary); padding:12px 14px; border-radius:12px;">
        <div style="color:var(--text-secondary); font-weight:600; margin-bottom:6px; font-size:0.85rem;">RSVPs</div>
        <div style="display:flex; gap:12px; flex-wrap:wrap;">
          <span style="padding:4px 10px; border-radius:999px; background:#065f46; color:#a7f3d0; font-weight:600; font-size:0.85rem;">✓ ${yes} in</span>
          <span style="padding:4px 10px; border-radius:999px; background:#78350f; color:#fde68a; font-weight:600; font-size:0.85rem;">? ${maybe} maybe</span>
          <span style="padding:4px 10px; border-radius:999px; background:#7f1d1d; color:#fecaca; font-weight:600; font-size:0.85rem;">✕ ${no} out</span>
          <span style="color:var(--text-secondary); align-self:center; font-size:0.85rem;">of ${total}</span>
        </div>
      </div>`;
  }

  _statusColor(status) {
    const s = String(status || '').toLowerCase();
    if (s === 'completed')   return '#065f46';
    if (s === 'in_progress') return '#1e40af';
    if (s === 'cancelled')   return '#7f1d1d';
    if (s === 'postponed')   return '#78350f';
    return '#374151'; // scheduled / default
  }

  // ── Edit mode ────────────────────────────────────────────────────
  _renderEdit() {
    const m = this._match;
    const kind = String(m.match_type || 'match').toLowerCase();
    const isMatch = ['match','league','custom','scrimmage','tournament','cup'].includes(kind);

    // Venue options — lazy-loaded on _wireBody; renders as raw select
    // that will be populated after the first fetch.  We stash the
    // current venue as a fallback <option> so the field never
    // starts empty.
    const currentVenueOpt = m.venue_id
      ? `<option value="${m.venue_id}" selected>${this.escapeHtml(m.venue_name || `Venue #${m.venue_id}`)}</option>`
      : `<option value="" selected>— no venue —</option>`;

    const statuses = ['scheduled','in_progress','completed','cancelled','postponed'];
    const statusOpts = statuses.map(s =>
      `<option value="${s}"${(m.match_status || 'scheduled') === s ? ' selected' : ''}>${s}</option>`
    ).join('');

    const scoreRow = isMatch ? `
      <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
        <label style="display:flex; flex-direction:column; gap:4px;">
          <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Home score</span>
          <input type="number" min="0" step="1" id="sched-edit-home-score" value="${m.home_team_score ?? ''}" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);" />
        </label>
        <label style="display:flex; flex-direction:column; gap:4px;">
          <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Away score</span>
          <input type="number" min="0" step="1" id="sched-edit-away-score" value="${m.away_team_score ?? ''}" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);" />
        </label>
      </div>` : '';

    return `
      <form id="sched-edit-form" style="max-width:720px; margin:0 auto; display:flex; flex-direction:column; gap:12px;">
        <label style="display:flex; flex-direction:column; gap:4px;">
          <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Title</span>
          <input type="text" id="sched-edit-title" value="${this.escapeHtml(m.title || '')}" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);" />
        </label>

        <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px;">
          <label style="display:flex; flex-direction:column; gap:4px;">
            <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Date</span>
            <input type="date" id="sched-edit-date" value="${this.escapeHtml(m.match_date || '')}" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);" />
          </label>
          <label style="display:flex; flex-direction:column; gap:4px;">
            <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Time</span>
            <input type="time" id="sched-edit-time" value="${this.escapeHtml(m.match_time || '')}" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);" />
          </label>
        </div>

        <label style="display:flex; flex-direction:column; gap:4px;">
          <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Venue</span>
          <select id="sched-edit-venue" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);">
            ${currentVenueOpt}
          </select>
          <span style="color:var(--text-secondary); font-size:0.75rem;">Loading venues…</span>
        </label>

        <label style="display:flex; flex-direction:column; gap:4px;">
          <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Status</span>
          <select id="sched-edit-status" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary);">
            ${statusOpts}
          </select>
        </label>

        ${scoreRow}

        <label style="display:flex; flex-direction:column; gap:4px;">
          <span style="color:var(--text-secondary); font-size:0.85rem; font-weight:600;">Notes</span>
          <textarea id="sched-edit-notes" rows="4" style="padding:8px 10px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-primary); color:var(--text-primary); resize:vertical;">${this.escapeHtml(m.notes || '')}</textarea>
        </label>

        <div id="sched-edit-error" style="display:none; padding:8px 12px; background:#7f1d1d; color:#fecaca; border-radius:8px;"></div>

        <div style="display:flex; gap:8px; margin-top:4px;">
          <button type="submit" class="sched-edit-save" style="padding:10px 18px; border-radius:8px; border:none; background:var(--color-primary, #2563eb); color:#fff; cursor:pointer; font-weight:600;">Save changes</button>
          <button type="button" class="sched-edit-cancel" style="padding:10px 18px; border-radius:8px; border:1px solid var(--color-border); background:var(--bg-secondary); color:var(--text-primary); cursor:pointer; font-weight:600;">Cancel</button>
        </div>
      </form>
    `;
  }

  // ── Event wiring — called after every body re-render. ────────────
  _wireBody() {
    if (this._editing) {
      this._loadVenuesIfNeeded();
      const form = this.find('#sched-edit-form');
      if (form) form.addEventListener('submit', (e) => { e.preventDefault(); this._save(); });
      const cancel = this.find('.sched-edit-cancel');
      if (cancel) cancel.addEventListener('click', () => this._exitEdit());
      return;
    }
    // View mode wiring.
    const editBtn = this.find('.sched-item-edit');
    if (editBtn) editBtn.addEventListener('click', () => this._enterEdit());
    const delBtn  = this.find('.sched-item-delete');
    if (delBtn)   delBtn.addEventListener('click', () => this._delete());
    const openM   = this.find('.sched-item-open-match');
    if (openM)    openM.addEventListener('click', () => {
      this.navigation.goTo('match-detail', { matchId: Number(this._matchId) });
    });
    const openS   = this.find('.sched-item-open-series');
    if (openS && this._match?.series_id) {
      openS.addEventListener('click', () => {
        this.navigation.goTo('admin-series-editor', {
          seriesId: Number(this._match.series_id),
          returnTo: 'admin-schedule-item',
          returnToParams: { matchId: this._matchId, returnTo: this._returnTo, returnToParams: this._returnToParams },
        });
      });
    }
  }

  _enterEdit() {
    this._editing = true;
    this._renderBody();
  }
  _exitEdit() {
    this._editing = false;
    this._renderBody();
  }

  async _loadVenuesIfNeeded() {
    const select = this.find('#sched-edit-venue');
    if (!select) return;
    // If we've already loaded venues once this session, just re-fill.
    if (Array.isArray(this._venues)) {
      this._fillVenueSelect(select);
      return;
    }
    try {
      const res = await this.auth.fetch('/api/venues');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const body = await res.json();
      const list = Array.isArray(body?.data) ? body.data
                : Array.isArray(body?.venues) ? body.venues
                : Array.isArray(body) ? body : [];
      this._venues = list;
      this._fillVenueSelect(select);
    } catch (_) {
      // Non-fatal — leave the single-option select in place.
      const hint = select.parentElement?.querySelector('span:last-child');
      if (hint) hint.textContent = 'Could not load venue list — current venue kept.';
    }
  }

  _fillVenueSelect(select) {
    const currentId = String(this._match.venue_id ?? '');
    const opts = ['<option value="">— no venue —</option>'];
    for (const v of this._venues) {
      const id = String(v.id);
      const label = this.escapeHtml(v.name || `Venue #${id}`);
      opts.push(`<option value="${id}"${id === currentId ? ' selected' : ''}>${label}</option>`);
    }
    select.innerHTML = opts.join('');
    const hint = select.parentElement?.querySelector('span:last-child');
    if (hint) hint.textContent = `${this._venues.length} venue${this._venues.length === 1 ? '' : 's'} available`;
  }

  async _save() {
    if (this._saving) return;
    this._saving = true;
    const errEl = this.find('#sched-edit-error');
    if (errEl) errEl.style.display = 'none';

    const val = (id) => (this.find(id)?.value || '').trim();
    const body = {
      title:            val('#sched-edit-title'),
      date:             val('#sched-edit-date'),
      start_time:       val('#sched-edit-time'),
      venue_id:         val('#sched-edit-venue'),
      match_status:     val('#sched-edit-status'),
      notes:            val('#sched-edit-notes'),
      home_team_score:  val('#sched-edit-home-score'),
      away_team_score:  val('#sched-edit-away-score'),
    };

    try {
      const res = await this.auth.fetch(`/api/matches/${this._matchId}`, {
        method:  'PUT',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(body),
      });
      if (!res.ok) {
        const j = await res.json().catch(() => ({}));
        throw new Error(j?.message || `HTTP ${res.status}`);
      }
      // Reload from server so we display the truth after any server-side
      // normalization (e.g. status → status_id → status name).
      this._editing = false;
      await this._load();
    } catch (e) {
      if (errEl) { errEl.style.display = 'block'; errEl.textContent = `Save failed: ${e.message}`; }
    } finally {
      this._saving = false;
    }
  }

  async _delete() {
    const m = this._match || {};
    const label = m.title || 'this item';
    const ok = window.confirm(`Delete "${label}"?  This can't be undone.`);
    if (!ok) return;
    try {
      const res = await this.auth.fetch(`/api/matches/${this._matchId}`, { method: 'DELETE' });
      if (!res.ok) {
        const j = await res.json().catch(() => ({}));
        throw new Error(j?.message || `HTTP ${res.status}`);
      }
      // Back to caller — schedule board will re-fetch on entry.
      this._goBack();
    } catch (e) {
      this._showError(`Delete failed: ${e.message}`);
    }
  }
}
