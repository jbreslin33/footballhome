// LineupsScreen — multi-team game-day lineup overview.
//
// Lives under Club Admin → 🧩 Lineup. One column per team, each showing
// that team's NEXT match plus all eligible players bucketed by their
// RSVP + practice/pickup attendance. Tap a player card to cycle through
// none → Starter → Bench → none. Selections persist to the same lineup
// endpoint used by the dedicated lineup page (so changes here flow
// through to the pitch/list view and vice versa).
//
// Top toolbar lets you hide/show teams (state persisted in localStorage)
// so you can focus on the matches you actually care about right now.

class LineupsScreen extends Screen {
  constructor(navigation, auth) {
    super(navigation, auth);
    this.clubId = null;
    this.clubName = null;
    // 'mens' (default) or 'womens'.  Drives:
    //   - which teams /api/clubs/:id returns (gender_category filter)
    //   - which LA program /api/clubs/:id/la-pool sources from
    //   - the screen header copy + storage key for hidden-team prefs.
    this.gender = 'mens';
    // teamData = [{ team, nextMatch, players, trainingEvents, zones:{starting,bench,alternates}, rosterSize, loaded, error }]
    this.teamData = [];
    this.hiddenTeams = new Set();
    // Populated by /api/mens-roster when the club has mens_team_columns rows;
    // null otherwise (e.g. youth clubs).  When non-null, an extra leftmost
    // "📦 Unassigned" column is rendered so registered players who haven't
    // been bucketed are visible and one-click-assignable to a team.
    this.mensRoster = null;
    // LA pool — every LA-registered person in the club, rendered as the
    // leftmost column with one team-name pill per club team.  Persons
    // never leave the pool when toggled onto/off a roster.
    //   { teams: [{id, name, shortLabel}],
    //     persons: [{personId, firstName, lastName, leagueAppsUserId,
    //                onRosterOn: [teamId, ...]}] }
    this.laPool = null;
    this.poolSearch = '';
    this._listenersAttached = false;
    this._saveTimers = new Map(); // teamId -> timeout handle for debounced save
  }

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------
  render() {
    const div = document.createElement('div');
    div.className = 'screen screen-lineups';
    div.innerHTML = `
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🧩 Lineup</h1>
        <p class="subtitle">Pick starters &amp; bench across every team's next match in one place.</p>
      </div>

      <div id="lineups-toolbar" style="
        padding: var(--space-3) var(--space-4);
        border-bottom: 1px solid var(--border-color);
        display: flex; flex-wrap: wrap; align-items: center;
        gap: var(--space-2); background: var(--bg-surface);
        position: sticky; top: 0; z-index: 10;
      ">
        <span style="font-size:0.85em; color: var(--text-muted); margin-right: var(--space-2);">Teams:</span>
        <div id="lineups-team-chips" style="display:flex; flex-wrap:wrap; gap: var(--space-1);"></div>
      </div>

      <div id="lineups-loading" style="padding: var(--space-6); text-align:center;">
        <div class="spinner"></div>
        <p style="margin-top: var(--space-2); color: var(--text-muted);">Loading teams &amp; next matches…</p>
      </div>

      <div id="lineups-columns" style="
        display: none;
        gap: var(--space-3);
        padding: var(--space-3) var(--space-4) var(--space-6);
        overflow-x: auto;
        align-items: flex-start;
      "></div>
    `;
    this.element = div;
    return div;
  }

  onEnter(params) {
    this.clubId = params?.clubId;
    this.clubName = params?.clubName;
    this.gender = (params?.gender === 'womens') ? 'womens' : 'mens';
    // matchType filter — 'game' (default) shows league/scrimmage/etc,
    // 'practice' shows only practices, 'pickup' shows only pickups.
    // Match types: 1=league, 2=custom, 3=practice, 4=scrimmage,
    // 5=tournament, 6=cup, 7=pickup.  We filter by match_type_id if
    // present, falling back to a title regex.
    const mt = params?.matchType;
    this.matchType = (mt === 'practice' || mt === 'pickup') ? mt : 'game';
    this.division  = params?.division  || null;   // future: 'apsl' | 'liga1' | 'liga2' | 'tricounty'
    this.ageGroup  = params?.ageGroup  || null;   // future: 'u8' | 'u10' | 'u12'
    // Update header copy to reflect the chosen gender + match type.
    const h1 = this.element.querySelector('.screen-header h1');
    if (h1) {
      const genderLabel = this.gender === 'womens' ? 'Women’s' : 'Men’s';
      const typeLabel = this.matchType === 'practice'
        ? '🏃 ' + genderLabel + ' Practice Dashboard'
        : this.matchType === 'pickup'
          ? '⚡ ' + genderLabel + ' Pickup Dashboard'
          : '🧩 ' + genderLabel + ' Lineup';
      h1.textContent = typeLabel;
    }
    this.hiddenTeams = this._loadHiddenTeams();

    if (!this._listenersAttached) {
      this._attachListeners();
      this._listenersAttached = true;
    }

    this._connectStream();
    this.loadData();
  }

  onExit() {
    this._disconnectStream();
  }

  // ── Real-time push (Postgres LISTEN/NOTIFY → SSE → here) ──────────
  // Webhook holds a LISTEN on channel `fh_lineups` and forwards every
  // payload to GET /api/stream.  Payload shape:
  //   { kind: 'rsvp'|'lineup'|'roster'|'coach'|'chat_member',
  //     affected_team_ids: [903, 905] | "all" }
  // We re-fetch + re-render only the affected team columns (debounced).
  _connectStream() {
    if (this._eventSource) return;
    const token = localStorage.getItem('token');
    if (!token) return;
    try {
      const es = new EventSource(`/api/stream?token=${encodeURIComponent(token)}`);
      es.onmessage = (ev) => this._handleStreamMessage(ev);
      es.onerror = () => {
        // EventSource auto-reconnects with exponential backoff; nothing to do
        // here.  Heartbeats every 25s confirm health.
      };
      this._eventSource = es;
      this._teamRefreshTimers = new Map();
    } catch (err) {
      console.warn('[lineups] failed to open SSE:', err);
    }
  }

  _disconnectStream() {
    if (this._eventSource) {
      try { this._eventSource.close(); } catch {}
      this._eventSource = null;
    }
    if (this._teamRefreshTimers) {
      for (const t of this._teamRefreshTimers.values()) clearTimeout(t);
      this._teamRefreshTimers.clear();
    }
  }

  _handleStreamMessage(ev) {
    if (!ev || !ev.data) return;
    let msg = null;
    try { msg = JSON.parse(ev.data); } catch { return; }
    const ids = msg?.affected_team_ids;
    if (!ids) return;
    if (ids === 'all') {
      for (const td of (this.teamData || [])) {
        this._scheduleTeamRefresh(td.team.id);
      }
      return;
    }
    if (Array.isArray(ids)) {
      for (const id of ids) this._scheduleTeamRefresh(id);
    }
  }

  _scheduleTeamRefresh(teamId) {
    if (!this._teamRefreshTimers) this._teamRefreshTimers = new Map();
    const existing = this._teamRefreshTimers.get(teamId);
    if (existing) clearTimeout(existing);
    const handle = setTimeout(async () => {
      this._teamRefreshTimers.delete(teamId);
      const td = (this.teamData || []).find(t => t?.team?.id === teamId);
      if (!td) return;
      try {
        await this._loadTeamPlayers(td);
        this._renderColumn(td);
      } catch (err) {
        console.warn('[lineups] stream refresh failed for team', teamId, err);
      }
    }, 250);
    this._teamRefreshTimers.set(teamId, handle);
  }

  _attachListeners() {
    // Team-visibility checkboxes (leads-style) + modal roster toggle
    this.element.addEventListener('change', (e) => {
      const cb = e.target.closest('input.team-toggle[data-team-chip]');
      if (cb) {
        const tid = parseInt(cb.dataset.teamChip, 10);
        if (cb.checked) this.hiddenTeams.delete(tid);
        else this.hiddenTeams.add(tid);
        this._saveHiddenTeams();
        this._renderToolbar();
        this._renderColumns();
        return;
      }
      const rosterCb = e.target.closest('input[data-card-modal-roster]');
      if (rosterCb) {
        this._onRosterStatusChange(rosterCb);
        return;
      }
    });

    this.element.addEventListener('click', (e) => {
      const back = e.target.closest('.back-btn');
      if (back) { this.navigation.goBack(); return; }

      // Cross-team assignment (Unassigned column pills)
      const assignBtn = e.target.closest('[data-mens-assign]');
      if (assignBtn) {
        e.preventDefault();
        e.stopPropagation();
        this._onMensAssignClick(assignBtn);
        return;
      }

      // LA Pool team-name pill — toggle person on/off the team's roster.
      const poolPill = e.target.closest('[data-team-pill]');
      if (poolPill) {
        e.preventDefault();
        e.stopPropagation();
        this._onTeamPillClick(poolPill);
        return;
      }

      // Card Edit button — open detail modal
      const editBtn = e.target.closest('[data-edit-card]');
      if (editBtn) {
        e.preventDefault();
        e.stopPropagation();
        const kind     = editBtn.dataset.editCard; // 'player'|'coach'|'laPool'
        const personIdRaw = editBtn.dataset.personId;
        const personId = personIdRaw ? parseInt(personIdRaw, 10) : null;
        if (kind === 'laPool' && personId) {
          this._openLaPoolModal(personId);
          return;
        }
        const teamId   = parseInt(editBtn.dataset.teamId, 10);
        const externalUserId = editBtn.dataset.externalUserId || null;
        const chatId         = editBtn.dataset.chatId ? parseInt(editBtn.dataset.chatId, 10) : null;
        this._openCardModal(teamId, { personId, externalUserId, chatId }, kind);
        return;
      }

      // FH-native magic-link mint buttons (📧 / 📱) — admin clicks → POST to
      // mint endpoint → open mailto:/sms: in admin's own email/SMS client.
      const mintBtn = e.target.closest('[data-rsvp-mint]');
      if (mintBtn && !mintBtn.disabled) {
        e.preventDefault();
        e.stopPropagation();
        this._onMintLinkClick(mintBtn);
        return;
      }

      // Card modal — close / action buttons
      const modalClose = e.target.closest('[data-card-modal-close]');
      if (modalClose) {
        e.preventDefault();
        e.stopPropagation();
        this._closeCardModal();
        return;
      }
      const modalCoach = e.target.closest('[data-card-modal-coach]');
      if (modalCoach) {
        e.preventDefault();
        e.stopPropagation();
        const teamId   = parseInt(modalCoach.dataset.teamId, 10);
        const personId = parseInt(modalCoach.dataset.personId, 10);
        const action   = modalCoach.dataset.cardModalCoach; // 'add' | 'remove'
        this._closeCardModal();
        this._toggleCoach(teamId, personId, action);
        return;
      }

      // Diagnostic-report controls
      if (e.target.closest('#lineups-report-continue')) {
        this._showColumns();
        return;
      }
      if (e.target.closest('#lineups-report-rerun')) {
        this.loadData();
        return;
      }

      // Starter / Bench / Alternate / Null — single dropdown per card.
      // The new value comes through the 'change' listener below; the click
      // listener just stops propagation so the modal doesn't open.
      const zoneSelect = e.target.closest('[data-zone-select]');
      if (zoneSelect) {
        e.stopPropagation();
        return;
      }

      // Mark-as-coach / un-mark-as-coach buttons on player or coach cards.
      const coach = e.target.closest('[data-coach-mark]');
      if (coach) {
        e.preventDefault();
        e.stopPropagation();
        const teamId   = parseInt(coach.dataset.teamId, 10);
        const personId = parseInt(coach.dataset.personId, 10);
        const action   = coach.dataset.coachMark; // 'add' | 'remove'
        this._toggleCoach(teamId, personId, action);
        return;
      }

      // Team-hub deep link: click the team name in the column header to
      // open that team's home page (roster + schedule + attendance +
      // chat).  Coaches use Men's Lineups daily; this is the shortest
      // path from there to any given team's page.
      const hubOpen = e.target.closest('[data-team-hub-open]');
      if (hubOpen) {
        e.preventDefault();
        e.stopPropagation();
        const teamId = parseInt(hubOpen.dataset.teamHubOpen, 10);
        const td = (this.teamData || []).find(t => t?.team?.id === teamId);
        const teamName = td?.team?.name || 'Team';
        this.navigation.goTo('team-hub', {
          teamId,
          teamName,
          clubId: this.clubId,
          lineupTeamId: teamId,
        });
        return;
      }

      // Add-match: toggle form open in team column header.
      const addOpen = e.target.closest('[data-add-match-open]');
      if (addOpen) {
        e.preventDefault();
        e.stopPropagation();
        const teamId = parseInt(addOpen.dataset.addMatchOpen, 10);
        const td = (this.teamData || []).find(t => t?.team?.id === teamId);
        if (td) {
          // "+ Match" always opens the form in ADD mode — clear any
          // in-progress edit so a re-open doesn't inherit stale
          // prefill values.
          td._matchFormEditId = null;
          td._addMatchOpen = !td._addMatchOpen;
          this._renderColumn(td);
        }
        return;
      }
      // Edit-match: open the same match form pre-filled with the
      // current match's opponent/date/time and switched to PUT mode.
      // Reuses _renderAddMatchForm / _onAddMatchSave so create + edit
      // share one form and one save code path.
      const editOpen = e.target.closest('[data-edit-match-open]');
      if (editOpen) {
        e.preventDefault();
        e.stopPropagation();
        const teamId = parseInt(editOpen.dataset.editMatchOpen, 10);
        const td = (this.teamData || []).find(t => t?.team?.id === teamId);
        if (td && td.nextMatch?.id) {
          td._matchFormEditId = td.nextMatch.id;
          td._addMatchOpen = true;
          this._renderColumn(td);
        }
        return;
      }
      // Add-match: cancel button — close the form.
      const addCancel = e.target.closest('[data-add-match-cancel]');
      if (addCancel) {
        e.preventDefault();
        e.stopPropagation();
        const teamId = parseInt(addCancel.dataset.addMatchCancel, 10);
        const td = (this.teamData || []).find(t => t?.team?.id === teamId);
        if (td) {
          td._addMatchOpen = false;
          td._matchFormEditId = null;
          this._renderColumn(td);
        }
        return;
      }
      // Add-match: save button — POST (create) or PUT (edit) based on
      // whether td._matchFormEditId is set.  _onAddMatchSave reads that
      // flag to route.
      const addSave = e.target.closest('[data-add-match-save]');
      if (addSave) {
        e.preventDefault();
        e.stopPropagation();
        const teamId = parseInt(addSave.dataset.addMatchSave, 10);
        this._onAddMatchSave(teamId);
        return;
      }
    });

    // Zone select change handler — picks Starter / Bench / Alternate / Null.
    this.element.addEventListener('change', (e) => {
      const zoneSelect = e.target.closest('[data-zone-select]');
      if (!zoneSelect) return;
      e.stopPropagation();
      const teamId   = parseInt(zoneSelect.dataset.teamId, 10);
      const playerId = parseInt(zoneSelect.dataset.playerId, 10);
      this._setZone(teamId, playerId, zoneSelect.value);
    });

    // LA-pool search box — debounced re-render of the pool column only.
    this.element.addEventListener('input', (e) => {
      if (e.target?.id !== 'lineups-pool-search') return;
      this.poolSearch = e.target.value || '';
      // Re-render just the pool — keep caret position by replacing innerHTML
      // of the existing pool section if present.
      const old = this.element.querySelector('[data-la-pool]');
      if (!old) return;
      const tmp = document.createElement('div');
      tmp.innerHTML = this._renderPoolColumn();
      const fresh = tmp.firstElementChild;
      if (fresh) {
        old.replaceWith(fresh);
        const inp = this.element.querySelector('#lineups-pool-search');
        if (inp) { inp.focus(); inp.setSelectionRange(this.poolSearch.length, this.poolSearch.length); }
      }
    });

    // Drag-to-merge removed with the GroupMe cutover — no more loose-end
    // (LA-only / GM-only) cards exist to drag, and the merge modal can be
    // reached directly from Club Admin if a stray duplicate appears.
  }

  // -------------------------------------------------------------------------
  // Data loading
  // -------------------------------------------------------------------------
  _setLoading(html) {
    const el = this.find('#lineups-loading');
    if (el) el.innerHTML = html;
  }

  _appendLoading(line) {
    const el = this.find('#lineups-loading-log');
    if (!el) return;
    const div = document.createElement('div');
    div.style.cssText = 'font-size:0.78em; color: var(--text-muted); font-family: monospace; margin-top:2px;';
    div.textContent = line;
    el.appendChild(div);
    el.scrollTop = el.scrollHeight;
  }

  async loadData() {
    if (!this.clubId) {
      this.find('#lineups-loading').innerHTML =
        '<p style="color:#ef4444;">No club in context.</p>';
      return;
    }

    // Reset UI back to loading state (for Rerun)
    this.find('#lineups-loading').style.display = 'block';
    this.find('#lineups-columns').style.display = 'none';
    this._setLoading(`
      <div class="spinner"></div>
      <p style="margin-top: var(--space-2); color: var(--text-muted);">Loading teams &amp; next matches…</p>
      <div id="lineups-loading-log" style="
        margin: var(--space-3) auto 0; max-width: 720px; text-align: left;
        max-height: 240px; overflow-y: auto;
        border: 1px solid var(--border-color); border-radius: 6px;
        padding: var(--space-2) var(--space-3); background: var(--bg-surface);
      "></div>
    `);

    try {
      this._appendLoading(`GET /api/clubs/${this.clubId}?gender=${this.gender}`);
      const res = await this.auth.fetch(`/api/clubs/${this.clubId}?gender=${this.gender}`);
      const data = await res.json();
      if (!data.success) throw new Error(data.message || 'Failed to load club');

      // Show every team on the club — including the two pool teams
      // (Practice / Pickup, teams.is_pool=true) — so admins can see who's
      // RSVP'd to training + pickup alongside the league teams.  The seven
      // mens teams are: APSL, Liga 1, Liga 2, Puerto Rico, U23, Practice,
      // Pickup.
      const teams = ((data.data?.teams) || []);
      this._appendLoading(`Club has ${teams.length} match-playing team(s).`);

      // Fire mens-roster fetch in parallel — it's only meaningful when the
      // club has mens_team_columns configured; otherwise silently null.
      this._appendLoading(`GET /api/mens-roster (best-effort — mens clubs only)`);
      this._loadMensRoster(); // fire-and-forget; re-renders Unassigned column on completion

      // Fire LA-pool fetch in parallel — drives the leftmost column.
      // Keep its promise so we can AWAIT it below before showing columns,
      // which guarantees pool status (success/error count) appears in the
      // loading log and the column never opens in indefinite "spinner" mode.
      this._appendLoading(`GET /api/clubs/${this.clubId}/la-pool?gender=${this.gender}`);
      this.laPool = null;
      this.laPoolError = null;
      const laPoolPromise = this._loadLaPool();

      // Initialize team data shells; matches load in parallel below.
      // Two roster sizes per team:
      //   rosterSize         — game-day cap (starting 11 + bench, ~20).
      //                        Drives bench-slot math in the lineup zones.
      //   internalRosterSize — full club-internal target (~35).  Drives
      //                        the "x/35 · % full · need N" header display
      //                        on the LEFT of every team column.
      // Both default uniformly; team-specific overrides live in the DB
      // (mens_team_columns.roster_size / internal_roster_size — TODO).
      this.teamData = teams.map(team => ({
        team,
        nextMatch: null,
        players: [],
        trainingEvents: [],
        diagnostics: null,
        // Reconciliation is the canonical bucket source: {players,coaches,laOnly}.
        // Cross-referenced with `players` by personId for RSVP / jersey enrichment.
        reconciliation: null,
        zones: { starting: [], bench: [], alternates: [] },
        rosterSize: 20,
        internalRosterSize: 35,
        matchesLoaded: false,
        loaded: false,
        error: null,
      }));

      this._appendLoading(`Fetching next match for each team…`);
      await Promise.all(this.teamData.map(td => this._loadTeamNextMatch(td)));

      // Wait for the LA pool too so we report success/error BEFORE the
      // user clicks Continue and is staring at a spinning column.
      await laPoolPromise;

      // Keep all teams — including those without an upcoming match (e.g. APSL,
      // Liga 1, Pool) — so their LA-only section is reachable for linking.
      // Users can hide noisy dormant teams via the toolbar checkboxes; choice
      // persists per-club in localStorage.
      const withNext = this.teamData.filter(td => td.nextMatch).length;
      this._appendLoading(`Teams: ${this.teamData.length} total · ${withNext} with upcoming match.`);

      this._renderToolbar();
      // Keep loading panel visible; columns wait for user to click Continue.

      // Now load players for each team in parallel; each column self-updates.
      this._appendLoading(`Fetching roster-players + admin RSVP linkage for each team…`);
      await Promise.all(this.teamData.map(td => this._loadTeamPlayers(td)));

      this._renderReport();
    } catch (err) {
      console.error('LineupsScreen.loadData:', err);
      this.find('#lineups-loading').innerHTML =
        `<p style="color:#ef4444;">❌ ${this._escape(err.message)}</p>`;
    }
  }

  _showColumns() {
    this.find('#lineups-loading').style.display = 'none';
    this.find('#lineups-columns').style.display = 'flex';
    this._renderColumns();
  }

  _renderReport() {
    const totalTeams = this.teamData.length;
    const errored = this.teamData.filter(td => td.error);
    const okTeams = this.teamData.filter(td => !td.error);

    const teamRows = this.teamData.map(td => {
      if (td.error) {
        return `
          <tr>
            <td style="padding:6px 8px;">${this._escape(td.team.name)}</td>
            <td colspan="6" style="padding:6px 8px; color:#ef4444;">
              ❌ ${this._escape(td.error)}
            </td>
          </tr>`;
      }
      const d = td.diagnostics || {};
      const m = td.nextMatch || {};
      return `
        <tr>
          <td style="padding:6px 8px;">${this._escape(td.team.name)}</td>
          <td style="padding:6px 8px; color:var(--text-muted);">
            ${this._escape(m.title || '')}
          </td>
          <td style="padding:6px 8px; text-align:right;">${d.rosterSize ?? td.players.length}</td>
          <td style="padding:6px 8px; text-align:right;">
            ${d.chatName ? this._escape(d.chatName) : '—'}
          </td>
          <td style="padding:6px 8px; text-align:right;">
            ${d.gmRsvpTotal ?? 0}
            <span style="color:var(--text-muted);font-size:0.85em;">
              (${d.gmRsvpLinkedToPerson ?? 0}✓ / ${d.gmRsvpUnlinked ?? 0}✗)
            </span>
          </td>
          <td style="padding:6px 8px; text-align:right;">
            <span style="color:#22c55e;">${d.rosterWithGmRsvp ?? 0}</span>
          </td>
          <td style="padding:6px 8px; text-align:right;">
            <span style="color:#60a5fa;">${d.rosterWithAdminRsvp ?? 0}</span>
          </td>
        </tr>`;
    }).join('');

    // (chat-sync removed — no more aggregated unlinked-RSVP author list)
    const unlinkedHtml = '';

    const errorBanner = errored.length
      ? `<p style="color:#ef4444; margin: 0 0 var(--space-2);">
           ❌ ${errored.length} team(s) failed to load — see table.
         </p>`
      : '';

    this._setLoading(`
      <div style="max-width: 920px; margin: 0 auto; text-align:left;">
        <h2 style="margin: 0 0 var(--space-2);">📋 Lineup load report</h2>
        <p style="color: var(--text-muted); margin: 0 0 var(--space-3);">
          ${totalTeams} team(s) loaded · RSVPs joined from <code>chat_event_rsvps</code>
          and <code>player_rsvps_current</code> (admin overrides).
        </p>
        ${errorBanner}
        <div style="overflow-x:auto; border:1px solid var(--border-color); border-radius:6px;">
          <table style="width:100%; border-collapse:collapse; font-size:0.85em;">
            <thead>
              <tr style="background: var(--bg-secondary, rgba(255,255,255,0.04)); color: var(--text-muted);">
                <th style="padding:6px 8px; text-align:left;">Team</th>
                <th style="padding:6px 8px; text-align:left;">Next match</th>
                <th style="padding:6px 8px; text-align:right;">Roster</th>
                <th style="padding:6px 8px; text-align:right;">Chat</th>
                <th style="padding:6px 8px; text-align:right;">RSVPs (linked/unlinked)</th>
                <th style="padding:6px 8px; text-align:right;">Roster w/ RSVP</th>
                <th style="padding:6px 8px; text-align:right;">Roster w/ admin RSVP</th>
              </tr>
            </thead>
            <tbody>${teamRows}</tbody>
          </table>
        </div>
        ${unlinkedHtml}
        <div style="margin-top: var(--space-4); display:flex; gap: var(--space-2); justify-content:flex-end;">
          <button id="lineups-report-rerun" class="btn btn-secondary">↻ Rerun</button>
          <button id="lineups-report-continue" class="btn btn-primary">Continue to lineup →</button>
        </div>
      </div>
    `);
  }


  async _loadTeamNextMatch(td) {
    try {
      const res = await this.auth.fetch(`/api/matches/team/${td.team.id}`);
      const data = await res.json();
      if (!data.success) return;
      const matches = Array.isArray(data.data) ? data.data : [];
      // match_type_id: 1=league, 2=custom, 3=practice, 4=scrimmage,
      // 5=tournament, 6=cup, 7=pickup.  Practices+pickups also often
      // show up with match_type_id=3 due to the chat_event trigger and
      // have "practice"/"pickup" in their title, so we combine both
      // signals to classify.
      const isPractice = (m) => Number(m.match_type_id) === 3 || /practice/i.test(m.title || '');
      const isPickup   = (m) => Number(m.match_type_id) === 7 || /pickup/i.test(m.title || '');
      const typeFilter = this.matchType === 'practice'
        ? isPractice
        : this.matchType === 'pickup'
          ? isPickup
          : (m) => !isPractice(m) && !isPickup(m);   // default 'game'
      // Soonest non-ended match matching the type filter.
      const upcoming = matches
        .filter(m => !m.has_ended)
        .filter(m => !this._isFinished(m.match_status))
        .filter(typeFilter)
        .sort((a, b) => String(a.event_date || '').localeCompare(String(b.event_date || '')));
      td.nextMatch = upcoming[0] || null;
      td.matchesLoaded = true;
    } catch (err) {
      console.warn(`Could not load matches for team ${td.team.id}:`, err);
    }
  }

  // Safely parse a fetch Response as JSON. If the body isn't valid JSON
  // (e.g. nginx 502 HTML, gateway timeout, empty body), return an object
  // with an `error` field so callers can keep loading other teams.
  async _safeJson(res) {
    const text = await res.text();
    try {
      return JSON.parse(text);
    } catch (_e) {
      const snippet = (text || '').slice(0, 80).replace(/\s+/g, ' ').trim();
      return { error: `non-JSON response (HTTP ${res.status})${snippet ? `: ${snippet}` : ''}` };
    }
  }

  async _loadTeamPlayers(td) {
    const teamId = td.team.id;
    const matchId = td.nextMatch ? td.nextMatch.id : null;
    try {
      // No upcoming match (e.g. APSL, Liga 1, Pool): skip roster-players,
      // but still pull reconciliation so the LA-only section is reachable.
      // We then fall through to _augmentPlayersWithMensRoster so every
      // player assigned to this team (via mens_team_assignments on the
      // LEFT side pills) still appears in the column — bucketed as
      // "NO RESPONSE" until they RSVP or an admin sets it manually.
      if (!matchId) {
        this._appendLoading(`  [${td.team.name}] no upcoming match — reconciliation + mens roster only`);
        const recRes = await this.auth.fetch(`/api/teams/${teamId}/reconciliation`);
        const rec = await this._safeJson(recRes);
        if (recRes.ok && !rec.error) {
          td.reconciliation = rec;
          this._appendLoading(
            `  [${td.team.name}] reconciliation: ` +
            `coaches=${(rec.coaches || []).length} laOnly=${(rec.laOnly || []).length}` +
            (rec.supported ? '' : ' (no LA source)')
          );
        } else {
          td.reconciliation = null;
          this._appendLoading(`  [${td.team.name}] reconciliation failed: ${rec.error || recRes.status}`);
        }
        td.players = [];
        td.zones = { starting: [], bench: [], alternates: [] };
        this._augmentPlayersWithMensRoster(td);
        td.loaded = true;
        return;
      }
      const url = `/api/matches/${matchId}/roster-players?teamId=${teamId}`;
      this._appendLoading(`  [${td.team.name}] GET ${url}`);
      // Fire roster-players + reconciliation in parallel — reconciliation is
      // the source of truth for which 3-section bucket each person falls in
      // (Players / Coaches / LA only); roster-players supplies RSVP
      // + jersey enrichment we cross-reference by personId.
      const [playersRes, recRes] = await Promise.all([
        this.auth.fetch(url),
        this.auth.fetch(`/api/teams/${teamId}/reconciliation`),
      ]);
      const data = await playersRes.json();
      if (!data.success) throw new Error(data.message || 'Failed to load players');

      td.players = data.data || [];
      td.trainingEvents = data.trainingEvents || [];
      td.diagnostics = data.diagnostics || null;

      // Reconciliation endpoint returns plain JSON (no `success` wrapper).
      // 4xx/5xx still parse — they just have an `error` field. Use _safeJson
      // so an nginx 502 / HTML body doesn't blow up the whole load report.
      const rec = await this._safeJson(recRes);
      if (recRes.ok && !rec.error) {
        td.reconciliation = rec;
        this._appendLoading(
          `  [${td.team.name}] reconciliation: ` +
          `coaches=${(rec.coaches || []).length} laOnly=${(rec.laOnly || []).length}` +
          (rec.supported ? '' : ' (no LA source)')
        );
      } else {
        td.reconciliation = null;
        this._appendLoading(`  [${td.team.name}] reconciliation failed: ${rec.error || recRes.status}`);
      }

      if (td.diagnostics) {
        const d = td.diagnostics;
        this._appendLoading(
          `  [${td.team.name}] roster=${d.rosterSize} · chat="${d.chatName || '—'}" · ` +
          `gm rsvps=${d.gmRsvpTotal} (linked ${d.gmRsvpLinkedToPerson}, unlinked ${d.gmRsvpUnlinked}) · ` +
          `roster-matched: gm=${d.rosterWithGmRsvp}, admin=${d.rosterWithAdminRsvp}`
        );
      } else {
        this._appendLoading(`  [${td.team.name}] loaded ${td.players.length} players (no diagnostics)`);
      }

      // Seed zones from any saved lineup on the players. Coerce playerId
      // to Number so it matches the click-handler path (which parseInts
      // dataset attributes) — otherwise reloads show saved starters back
      // in their RSVP bucket because `[ '22221' ].includes(22221)` is false.
      td.zones = { starting: [], bench: [], alternates: [] };
      for (const p of td.players) {
        if (!p.onLineup) continue;
        const pid = p.playerId != null && p.playerId !== '' ? Number(p.playerId) : null;
        if (pid == null) continue;
        const zone = p.lineupZone || (p.isStarter ? 'starter' : 'bench');
        if (zone === 'starter') td.zones.starting.push(pid);
        else if (zone === 'alternate') td.zones.alternates.push(pid);
        else td.zones.bench.push(pid);
      }

      // Union in every person assigned to this team on the LEFT (via
      // mens_team_assignments / /api/mens-roster).  Anyone not already in
      // td.players from roster-players gets a synthetic row so they show
      // in the column bucketed as "NO RESPONSE" — the coach can then
      // manually set their RSVP.
      this._augmentPlayersWithMensRoster(td);

      td.loaded = true;
    } catch (err) {
      console.error(`LineupsScreen team ${teamId} load:`, err);
      td.error = err.message;
      this._appendLoading(`  [${td.team.name}] ❌ ${err.message}`);
    }
    // Don't re-render columns here — we render the report panel first and
    // only show columns after the user clicks Continue.
  }

  // -------------------------------------------------------------------------
  // Cross-team assignment (Men's-Club style) — Unassigned column + pills
  // -------------------------------------------------------------------------
  //
  // Mirrors the old #mens-roster page: pulls the live LeagueApps roster for
  // the club via /api/mens-roster (which honors the mens_team_columns table),
  // and surfaces players who haven't been bucketed yet so they don't get
  // missed.  Silently no-ops for clubs that don't have mens_team_columns
  // configured (the endpoint returns 409 in that case).
  async _loadMensRoster() {
    try {
      const res = await this.auth.fetch('/api/mens-roster');
      if (!res.ok) {
        // 409 = no mens_team_columns configured for this club; that's fine.
        this.mensRoster = null;
        return;
      }
      this.mensRoster = await res.json();
      // Union the freshly-loaded assignments into every already-loaded
      // team column so people show even before their next match exists.
      for (const td of (this.teamData || [])) {
        if (td && td.loaded) this._augmentPlayersWithMensRoster(td);
      }
      // Re-render columns if they're already on screen
      if (this.find('#lineups-columns')?.style.display === 'flex') {
        this._renderColumns();
      }
    } catch {
      this.mensRoster = null;
    }
  }

  // Union every person assigned to this team on the LEFT side
  // (mens_team_assignments, surfaced via /api/mens-roster) into
  // td.players.  Anyone missing from the roster-players response gets
  // a synthetic row (no personId / no playerId / rsvpStatus=''); the
  // renderer buckets those under "NO RESPONSE" so the column always
  // reflects the full team roster.
  //
  // De-dup key priority:
  //   1. leagueAppsUserId  (most reliable — comes from LA registration)
  //   2. lowercase "first last" name  (fallback for FH-native persons)
  _augmentPlayersWithMensRoster(td) {
    if (!this.mensRoster || !Array.isArray(this.mensRoster.columns)) return;
    const bucket = this.mensRoster.buckets?.[String(td.team.id)];
    if (!Array.isArray(bucket) || bucket.length === 0) return;

    if (!Array.isArray(td.players)) td.players = [];

    const seenLaUid = new Set();
    const seenName  = new Set();
    const nameKey = (f, l) =>
      `${(f || '').toString().trim().toLowerCase()} ${(l || '').toString().trim().toLowerCase()}`.trim();

    for (const p of td.players) {
      if (p?.leagueAppsUserId != null) seenLaUid.add(String(p.leagueAppsUserId));
      const nk = nameKey(p?.firstName, p?.lastName);
      if (nk) seenName.add(nk);
    }

    let added = 0;
    for (const m of bucket) {
      const laUid = m?.leagueAppsUserId != null ? String(m.leagueAppsUserId) : null;
      const nk    = nameKey(m?.firstName, m?.lastName);
      if (laUid && seenLaUid.has(laUid)) continue;
      if (!laUid && nk && seenName.has(nk)) continue;

      td.players.push({
        // Identity — no personId/playerId because this row hasn't been
        // linked to a persons/players record yet (or the team has no
        // upcoming match so the roster-players join never ran).
        personId:         null,
        playerId:         null,
        leagueAppsUserId: m.leagueAppsUserId ?? null,
        firstName:        m.firstName || '',
        lastName:         m.lastName  || '',
        birthDate:        m.birthDate || null,
        // No response by default — an admin can manually set this from
        // the card once the manual-RSVP override lands.
        rsvpStatus:       '',
        practice:         [],
        // Roster-flag from mens_team_assignments (surface the R badge).
        laOnRoster:       !!m.onRoster,
        // Jersey / contact enrichment when present.
        jerseyNumber:     m.jerseyNumber ?? null,
        // Marker so downstream code can tell these apart from real
        // roster-players rows.
        _fromMensRoster:  true,
      });
      if (laUid) seenLaUid.add(laUid);
      if (nk)    seenName.add(nk);
      added++;
    }

    if (added > 0) {
      this._appendLoading?.(`  [${td.team.name}] +${added} from mens roster (assigned, no match RSVP yet)`);
    }
  }

  // -------------------------------------------------------------------------
  // LA Pool — every LA-registered person, team-name pills for one-tap assign
  // -------------------------------------------------------------------------
  //
  // The pool replaces the per-team "LA only" sections.  It loads once at
  // screen entry, then each pill click hits POST /api/teams/:teamId/roster/
  // :personId to flip roster status without removing the person from the
  // pool.  After a successful toggle we refresh both the pool (so the pill
  // re-tints) and the affected team column (so the player appears/leaves).
  async _loadLaPool() {
    if (!this.clubId) {
      this.laPoolError = 'No clubId in context';
      return;
    }
    const url = `/api/clubs/${this.clubId}/la-pool?gender=${this.gender}`;
    try {
      const res = await this.auth.fetch(url);
      if (!res.ok) {
        const text = await res.text().catch(() => '');
        this.laPool = null;
        this.laPoolError = `${res.status} ${res.statusText}${text ? ' — ' + text.slice(0, 200) : ''}`;
        this._appendLoading(`  ❌ LA pool fetch failed: ${this.laPoolError}`);
        return;
      }
      this.laPool = await res.json();
      this.laPoolError = null;
      // Build a personId-keyed index so team-column cards can render the
      // same team-pill row without an O(n) scan per card.
      this._laPoolByPersonId = new Map(
        (this.laPool.persons || [])
          .filter(p => p.personId)
          .map(p => [p.personId, p])
      );
      const total = this.laPool.persons?.length || 0;
      const unmatched = (this.laPool.persons || []).filter(p => p.unmatched).length;
      this._appendLoading(
        `  ✅ LA pool loaded: ${total} mens registration(s)` +
        (unmatched ? ` · ${unmatched} unmatched (need marrying)` : '')
      );
      // Re-render columns if they're already on screen
      if (this.find('#lineups-columns')?.style.display === 'flex') {
        this._renderColumns();
      }
    } catch (err) {
      this.laPool = null;
      this.laPoolError = err.message || String(err);
      this._appendLoading(`  ❌ LA pool fetch threw: ${this.laPoolError}`);
    }
  }

  _renderPoolColumn() {
    const lp = this.laPool;

    // Loading / error / empty placeholder — keep column footprint visible
    // even before the LA mens-program fetch resolves, so users can see
    // what's coming, and surface the failure if the API call broke.
    if (!lp || !Array.isArray(lp.persons)) {
      const errMsg = this.laPoolError;
      return `
        <section
          data-la-pool="1"
          style="
            flex: 0 0 280px; min-width: 280px; max-width: 320px;
            background: var(--bg-surface);
            border: 1px solid ${errMsg ? '#ef4444' : 'var(--border-color)'};
            border-radius: 8px;
            display: flex; flex-direction: column;
            max-height: calc(100vh - 200px);
          "
        >
          <header style="
            padding: var(--space-3);
            border-bottom: 1px solid var(--border-color);
            background: ${errMsg ? 'rgba(239,68,68,0.10)' : 'rgba(34, 197, 94, 0.10)'};
            border-radius: 8px 8px 0 0;
          ">
            <strong style="font-size: 1em;">🅻🅰 LA Players</strong>
            <div style="margin-top:2px; font-size:0.78em; color: var(--text-muted);">
              ${errMsg ? '❌ failed to load' : 'Loading mens-program registrations…'}
            </div>
          </header>
          <div style="padding: var(--space-3); color: var(--text-muted); font-size:0.85em;">
            ${errMsg
              ? `<div style="color:#ef4444; word-break:break-word;">${this._escape(errMsg)}</div>`
              : '<div class="spinner"></div>'}
          </div>
        </section>
      `;
    }

    // Pills cover EVERY team in the club, not just toolbar-visible ones.
    // The toolbar controls which team COLUMNS render to the right; the LA
    // column is a master assignment console and always shows all teams so
    // you can place a player without first toggling its column on.
    const teams = (lp.teams || []);

    const q = (this.poolSearch || '').trim().toLowerCase();
    const persons = q
      ? lp.persons.filter(p => {
          const n = `${p.firstName || ''} ${p.lastName || ''}`.toLowerCase();
          return n.includes(q);
        })
      : lp.persons;

    const unmatchedCount = lp.persons.filter(p => p.unmatched).length;

    const cards = persons.map(p => {
      const name = this._escape(`${p.firstName || ''} ${p.lastName || ''}`.trim() || '(unnamed)');
      const dob = this._formatDob(p.birthDate);
      const age = this._ageFromDob(p.birthDate);
      const band = this._ageBand(age);
      // Age color: >= 18 needs SafeSport (amber warning), < 18 is a minor
      // (soft blue).  Both are legible against the surface color; the
      // point is to make "will this person need SafeSport?" a glance.
      const ageColor = age == null
        ? 'var(--text-muted)'
        : (age >= 18 ? '#f59e0b' : '#38bdf8');
      const onSet = new Set(p.onRosterOn || []);
      // Edit button — only render for matched persons (need a personId).
      // Opens a dedicated LA-pool modal showing email/phone/payment etc.
      const editBtnHTML = p.personId ? `
        <button
          type="button"
          data-edit-card="laPool"
          data-person-id="${p.personId}"
          title="Edit ${name}"
          style="
            background: transparent; border: 1px solid var(--border-color);
            color: var(--text-muted); border-radius: 4px;
            padding: 1px 6px; font-size: 0.75em; cursor: pointer;
            line-height: 1.2;
          "
        >✏️</button>
      ` : '';
      // Unmatched LA users (no local person row) can't be added to a roster
      // until they're married to a person, so suppress pills and show flag.
      // Layout: 3 rows grouped by team purpose so the eye can scan quickly.
      //   Row 1 — league teams:     APSL (35), Liga 1 (120), Liga 2 (121)
      //   Row 2 — pool teams:       Pickup (909), Practice (908)
      //   Row 3 — internal squads:  U23 (903), Brazil (904), Puerto Rico (905)
      // Any additional team the club adds later falls into a trailing
      // "other" row so it still renders (no lost pills).
      const rowGroups = [
        [35, 120, 121],
        [909, 908],
        [903, 904, 905],
      ];
      const groupedIds = new Set(rowGroups.flat());
      const otherIds = teams.map(t => t.id).filter(id => !groupedIds.has(id));
      if (otherIds.length) rowGroups.push(otherIds);
      const teamById = new Map(teams.map(t => [t.id, t]));
      const renderPill = (t) => {
        const on = onSet.has(t.id);
        const bg = on ? '#22c55e' : 'transparent';
        const fg = on ? '#0b1220' : 'var(--text-muted)';
        const border = on ? '#22c55e' : 'var(--border-color)';
        return `
          <button
            type="button"
            data-team-pill="${on ? 'remove' : 'add'}"
            data-team-id="${t.id}"
            data-person-id="${p.personId}"
            title="${this._escape(t.name)} — tap to ${on ? 'remove' : 'add'}"
            style="
              background:${bg}; color:${fg}; border:1px solid ${border};
              padding: 2px 8px; border-radius: 999px;
              font-size: 0.7em; font-weight: 700; cursor: pointer;
              line-height: 1.2;
            "
          >${this._escape(t.shortLabel || t.name.slice(0, 4).toUpperCase())}</button>
        `;
      };
      const pillsHTML = p.unmatched
        ? `<span style="font-size:0.7em;color:#f59e0b;font-weight:700;">⚠ unmatched — needs marrying</span>`
        : rowGroups
            .map(ids => ids.map(id => teamById.get(id)).filter(Boolean))
            .filter(row => row.length > 0)
            .map(row => `<div style="display:flex; gap:4px; flex-wrap:wrap;">${row.map(renderPill).join('')}</div>`)
            .join('');
      const bgRow = p.unmatched
        ? 'rgba(245, 158, 11, 0.08)'
        : 'var(--bg-secondary, rgba(255,255,255,0.04))';
      const borderRow = p.unmatched ? '#f59e0b' : 'var(--border-color)';
      return `
        <div style="
          padding: 6px 8px; border-radius: 6px;
          background: ${bgRow};
          border: 1px solid ${borderRow};
          display: flex; flex-direction: column; gap: 4px;
        ">
          <div style="font-size:0.85em; color: var(--text-primary); display:flex; justify-content:space-between; gap:6px; align-items:baseline;">
            <strong>${name}</strong>
            <div style="display:flex; gap:6px; align-items:center;">
              ${dob ? `
                <span style="font-size:0.85em; font-family:monospace; color:var(--text-primary); font-weight:600;"
                      title="Born ${dob}${age != null ? ` · age ${age}` : ''}${band ? ` · ${band}` : ''}${age != null && age >= 18 ? ' · SafeSport required' : ''}">
                  ${dob}
                </span>
                ${age != null ? `<span style="font-size:0.8em; font-weight:700; color:${ageColor};">${age}</span>` : ''}
                ${band ? `<span style="
                  font-size:0.7em; font-weight:700; letter-spacing:0.04em;
                  padding:1px 6px; border-radius:4px;
                  background:rgba(56,189,248,0.15); color:#38bdf8;
                  border:1px solid rgba(56,189,248,0.35);
                ">${band}</span>` : ''}
              ` : ''}
              ${editBtnHTML}
            </div>
          </div>
          <div style="display:flex; flex-direction:column; gap:4px;">${pillsHTML}</div>
        </div>
      `;
    }).join('');

    return `
      <section
        data-la-pool="1"
        style="
          flex: 0 0 280px; min-width: 280px; max-width: 320px;
          background: var(--bg-surface);
          border: 1px solid var(--border-color);
          border-radius: 8px;
          display: flex; flex-direction: column;
        "
      >
        <header style="
          padding: var(--space-3);
          border-bottom: 1px solid var(--border-color);
          background: rgba(34, 197, 94, 0.10);
          border-radius: 8px 8px 0 0;
        ">
          <strong style="font-size: 1em; color: var(--text-primary);">🅻🅰 LA Players</strong>
          <div style="margin-top:2px; font-size:0.78em; color: var(--text-muted);">
            ${lp.persons.length} mens · ${unmatchedCount ? `<span style="color:#f59e0b;">${unmatchedCount} unmatched</span> · ` : ''}tap a pill to toggle a team
          </div>
          <input
            type="search"
            id="lineups-pool-search"
            placeholder="Search name…"
            value="${this._escape(this.poolSearch || '')}"
            style="
              margin-top: var(--space-2); width:100%;
              padding: 4px 8px; font-size: 0.85em;
              border: 1px solid var(--border-color); border-radius: 4px;
              background: var(--bg-input, var(--bg-surface)); color: var(--text-primary);
            "
          >
        </header>
        <div style="padding: var(--space-2) var(--space-3) var(--space-3); display:flex; flex-direction:column; gap: 6px;">
          ${cards || `<div style="color:var(--text-muted);font-size:0.85em;padding:8px;">No matches.</div>`}
        </div>
      </section>
    `;
  }

  // Toggle a person on/off a team's roster.  Optimistic update of the pool
  // (pill flips immediately), then refresh team data so the column updates.
  async _onTeamPillClick(btn) {
    const teamId   = parseInt(btn.dataset.teamId, 10);
    const personId = parseInt(btn.dataset.personId, 10);
    const action   = String(btn.dataset.teamPill || 'add');
    if (!teamId || !personId) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';

    // Look up leagueAppsUserId so we can also update mens_team_assignments
    // (the FH-member gate on /api/matches/:matchId/roster-players).  The
    // pool always carries this for matched persons; unmatched persons
    // don't get a pill rendered so we should always have it, but be
    // defensive in case the pool wasn't loaded yet.
    const laPerson = this.laPool?.persons?.find(x => x.personId === personId);
    const laUid = laPerson?.leagueAppsUserId
      ? String(laPerson.leagueAppsUserId).trim()
      : '';

    try {
      // Fire both writes in parallel:
      //   1. /api/teams/:teamId/roster/:personId   → rosters (JOIN target)
      //   2. /api/mens-roster/assign               → mens_team_assignments
      //                                              (FH-member gate)
      // The roster-players SQL requires BOTH for the player to render in
      // the team column, so previously the pill toggled visibility of
      // the pill but the player never appeared on the right.
      const rosterReq = this.auth.fetch(`/api/teams/${teamId}/roster/${personId}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ action }),
      });
      const assignReq = laUid
        ? this.auth.fetch('/api/mens-roster/assign', {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({
              leagueAppsUserId: Number(laUid),
              teamId,
              action,
            }),
          })
        : Promise.resolve(null);

      const [rosterRes, assignRes] = await Promise.all([rosterReq, assignReq]);

      if (!rosterRes.ok) {
        const txt = await rosterRes.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${rosterRes.status}`);
      }
      if (assignRes && !assignRes.ok) {
        const txt = await assignRes.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${assignRes.status}`);
      }

      // Local pill-state flip (immediate visual feedback on the LEFT pool).
      if (this.laPool) {
        const p = this.laPool.persons.find(x => x.personId === personId);
        if (p) {
          const set = new Set(p.onRosterOn || []);
          if (action === 'add') set.add(teamId); else set.delete(teamId);
          p.onRosterOn = Array.from(set);
        }
      }
      // Refetch /api/mens-roster (source of truth for internal assignments)
      // so the affected team's bucket is authoritative, then re-augment
      // and re-load the affected team column so the player appears /
      // disappears on the RIGHT.  _loadMensRoster() also re-augments
      // every loaded team + re-renders columns if visible, which covers
      // the case where the same person is on multiple teams.
      await this._loadMensRoster();
      const td = this.teamData.find(t => t.team.id === teamId);
      if (td) {
        await this._loadTeamPlayers(td);
        this._renderColumn(td);
      }
      // Toolbar counts depend on td.players.length — refresh so the
      // chip pill count next to the team name updates too.
      this._renderToolbar();
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not update roster: ${err.message}`);
    }
  }

  // FH-native magic-link mint click handler.
  //   Admin taps 📧 or 📱 on a player card → POST /api/auth/magic-link/mint
  //   → backend returns { mailto_href | sms_href } → we open it in the
  //   admin's own email/SMS client (the admin sends the message manually).
  //   The link in the body is the verify URL — tapping it on any device
  //   creates a session for that person and redirects to /#rsvp/<id>.
  async _onMintLinkClick(btn) {
    const channel    = String(btn.dataset.rsvpMint || '');
    const personId   = parseInt(btn.dataset.personId, 10);
    const matchId    = parseInt(btn.dataset.matchId, 10);
    const teamId     = parseInt(btn.dataset.teamId, 10);
    const contact    = String(btn.dataset.contact || '').trim();
    if (!channel || !personId || !matchId || !teamId || !contact) return;

    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.style.opacity = '0.5';
    btn.innerHTML = '⏳';

    try {
      const res = await this.auth.fetch('/api/auth/magic-link/mint', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({
          person_id: personId,
          match_id:  matchId,
          team_id:   teamId,
          channel,
          contact,
        }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      // Email → open Gmail web compose in a new tab (same pattern as the
      // leads page); SMS → hand off to the native SMS handler via _self.
      if (channel === 'email') {
        const href = data.gmail_href || data.mailto_href;
        if (!href) throw new Error('No email href returned');
        window.open(href, '_blank', 'noopener');
      } else {
        const href = data.sms_href;
        if (!href) throw new Error('No SMS href returned');
        window.location.href = href;
      }
    } catch (err) {
      console.error('mint link failed:', err);
      alert(`Could not generate sign-in link: ${err.message}`);
    } finally {
      // Restore state after a short delay (the page may not navigate if
      // there is no handler for mailto:/sms: in this browser).
      setTimeout(() => {
        btn.disabled = false;
        btn.style.opacity = '';
        btn.innerHTML = originalText;
      }, 1500);
    }
  }

  _renderUnassignedColumn() {
    const mr = this.mensRoster;
    if (!mr || !Array.isArray(mr.unassigned) || mr.unassigned.length === 0) {
      return '';
    }
    const cols = Array.isArray(mr.columns) ? mr.columns : [];
    const cards = mr.unassigned.map(p => {
      const name = this._escape(`${p.firstName || ''} ${p.lastName || ''}`.trim() || 'Unknown');
      const grade = p.grade ? `<span style="opacity:0.55; font-size:0.75em; margin-left:6px;">${this._escape(String(p.grade))}</span>` : '';
      const pills = cols.map(c => `
        <button
          type="button"
          data-mens-assign="add"
          data-user-id="${p.leagueAppsUserId}"
          data-team-id="${c.teamId}"
          title="Assign to ${this._escape(c.label)}"
          style="
            background:${c.color || '#475569'}; color:#fff; border:0;
            padding: 2px 8px; border-radius: 999px;
            font-size: 0.72em; cursor: pointer; font-weight: 600;
          "
        >+ ${this._escape(c.shortLabel || c.label)}</button>
      `).join('');
      return `
        <div style="
          padding: 6px 8px; border-radius: 6px;
          background: var(--bg-secondary, rgba(255,255,255,0.04));
          border: 1px solid var(--border-color);
          display: flex; flex-direction: column; gap: 4px;
        ">
          <div style="font-size:0.85em; color: var(--text-primary);">
            <strong>${name}</strong>${grade}
          </div>
          <div style="display:flex; gap:4px; flex-wrap:wrap;">${pills}</div>
        </div>
      `;
    }).join('');

    return `
      <section
        data-unassigned-col="1"
        style="
          flex: 0 0 280px; min-width: 280px; max-width: 320px;
          background: var(--bg-surface);
          border: 1px solid var(--border-color);
          border-radius: 8px;
          display: flex; flex-direction: column;
        "
      >
        <header style="
          padding: var(--space-3);
          border-bottom: 1px solid var(--border-color);
          background: rgba(71, 85, 105, 0.15);
          border-radius: 8px 8px 0 0;
        ">
          <strong style="font-size: 1em; color: var(--text-primary);">📭 Unassigned</strong>
          <div style="margin-top:2px; font-size:0.78em; color: var(--text-muted);">
            ${mr.unassignedCount} registered · not on any team yet
          </div>
        </header>
        <div style="padding: var(--space-2) var(--space-3) var(--space-3); display:flex; flex-direction:column; gap: 6px;">
          ${cards}
        </div>
      </section>
    `;
  }

  async _onMensAssignClick(btn) {
    const userId = parseInt(btn.dataset.userId, 10);
    const teamId = parseInt(btn.dataset.teamId, 10);
    const action = String(btn.dataset.mensAssign || 'add');
    if (!userId || !teamId) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      const res = await this.auth.fetch('/api/mens-roster/assign', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ leagueAppsUserId: userId, teamId, action }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${res.status}`);
      }
      // Reload mens-roster only (cheap) — also reload team players so the
      // newly-assigned player shows up in their column's bucket if RSVPs hit.
      await this._loadMensRoster();
      await Promise.all(this.teamData.map(td => this._loadTeamPlayers(td)));
      this._renderColumns();
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not assign: ${err.message}`);
    }
  }

  // -------------------------------------------------------------------------
  // Card detail modal (Edit ✏️) — surfaces everything that's not Starter/Bench
  // -------------------------------------------------------------------------
  //
  // The lineup card stays minimal (S / B / ✏️).  Tapping ✏️ pops a modal
  // where lower-frequency actions live — currently just "mark / un-mark as
  // coach", but jersey #, RSVP override, etc. will land here next.
  // Find a card entry in this team's reconciliation by personId.
  _findEntry(teamId, ident) {
    const td = this.teamData.find(t => t.team.id === teamId);
    if (!td || !td.reconciliation) return { td: null, entry: null, kind: null };
    const rec = td.reconciliation;

    const personId = ident.personId;
    const buckets = [
      ['player', rec.players  || []],
      ['coach',  rec.coaches  || []],
      ['laOnly', rec.laOnly   || []],
    ];
    for (const [kind, list] of buckets) {
      const entry = list.find(e => e.personId === personId);
      if (entry) return { td, entry, kind };
    }
    return { td, entry: null, kind: null };
  }

  // Look up a player's official-roster flag for a team from the cached
  // mens-roster payload.  Returns true/false when found, null when we don't
  // have data for this player/team (in which case the toggle is hidden).
  _mensOnRosterFor(teamId, leagueAppsUserId) {
    if (!this.mensRoster || !leagueAppsUserId) return null;
    const bucket = this.mensRoster.buckets?.[String(teamId)];
    if (!Array.isArray(bucket)) return null;
    const row = bucket.find(b => Number(b.leagueAppsUserId) === Number(leagueAppsUserId));
    return row ? !!row.onRoster : null;
  }

  async _onRosterStatusChange(cb) {
    const teamId = parseInt(cb.dataset.teamId, 10);
    const userId = parseInt(cb.dataset.userId, 10);
    const onRoster = !!cb.checked;
    if (!teamId || !userId) return;

    cb.disabled = true;
    try {
      const res = await this.auth.fetch('/api/mens-roster/roster-status', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ leagueAppsUserId: userId, teamId, onRoster }),
      });
      if (!res.ok) {
        const txt = await res.text();
        throw new Error(txt.slice(0, 200) || `HTTP ${res.status}`);
      }
      // Refresh cached mens-roster so subsequent modal opens see the new flag.
      await this._loadMensRoster();

      // Optimistic local update so the player card's R badge flips
      // immediately without waiting for a full reload.
      const td = this.teamData.find(t => t.team.id === teamId);
      if (td && td.reconciliation) {
        const rec = td.reconciliation;
        for (const list of [rec.players || [], rec.laOnly || []]) {
          for (const e of list) {
            if (Number(e.leagueAppsUserId) === Number(userId)) {
              e.laOnRoster = onRoster;
            }
          }
        }
        this._renderColumn(td);
      }

      // Keep LA-pool pill state in sync too (so its on-roster indicator
      // for this team reflects the new value without a reload).
      if (this.laPool && Array.isArray(this.laPool.persons)) {
        const p = this.laPool.persons.find(x =>
          Number(x.leagueAppsUserId) === Number(userId)
        );
        if (p) {
          const set = new Set(p.onRosterOn || []);
          if (onRoster) set.add(teamId); else set.delete(teamId);
          p.onRosterOn = Array.from(set);
        }
      }

      cb.disabled = false;
    } catch (err) {
      cb.checked = !onRoster; // revert
      cb.disabled = false;
      alert(`Could not update roster status: ${err.message}`);
    }
  }

  _openCardModal(teamId, ident, kindHint) {
    const { td, entry, kind } = this._findEntry(teamId, ident);
    if (!entry) return;
    const effectiveKind = kind || kindHint;
    const personId = entry.personId || null;
    const name = `${entry.firstName || ''} ${entry.lastName || ''}`.trim() || 'Unknown';
    const p = entry._player || {};

    let coachActionBtn = '';
    if (effectiveKind === 'player' && personId) {
      coachActionBtn = `
        <button
          data-card-modal-coach="add"
          data-team-id="${teamId}"
          data-person-id="${personId}"
          style="
            background: transparent; color: var(--text-primary);
            border: 1px solid var(--border-color); border-radius: 6px;
            padding: 8px 14px; font-size: 0.9em; cursor: pointer;
          "
        >🧑‍🏫 Mark as coach</button>
      `;
    } else if (effectiveKind === 'coach' && personId) {
      coachActionBtn = `
        <button
          data-card-modal-coach="remove"
          data-team-id="${teamId}"
          data-person-id="${personId}"
          style="
            background: transparent; color: var(--text-primary);
            border: 1px solid var(--border-color); border-radius: 6px;
            padding: 8px 14px; font-size: 0.9em; cursor: pointer;
          "
        >↩️ Un-mark as coach</button>
      `;
    }

    const jersey = p.jerseyNumber != null && p.jerseyNumber !== ''
      ? `#${this._escape(String(p.jerseyNumber))}`
      : '—';
    const rsvp = (p.rsvpStatus || '').toLowerCase() || '—';

    // Official-roster toggle (Men's-Club only for now — needs /api/mens-roster
    // data so we know the player's current on_roster flag for this team).
    const laUserId = entry.leagueAppsUserId != null ? Number(entry.leagueAppsUserId) : null;
    const onRoster = this._mensOnRosterFor(teamId, laUserId);
    const rosterToggleHTML = (laUserId && onRoster !== null) ? `
      <label
        style="
          display:flex; align-items:center; justify-content:space-between;
          gap: var(--space-2); cursor:pointer;
          padding: 10px 12px; border-radius: 6px;
          border: 1px solid var(--border-color);
          background: ${onRoster ? 'rgba(34,197,94,0.10)' : 'transparent'};
        "
      >
        <span style="font-size:0.9em;">
          <strong>⚖️ Official roster</strong>
          <div style="font-size:0.72em; color: var(--text-muted); margin-top:2px;">
            Eligible for sanctioned matches
          </div>
        </span>
        <input
          type="checkbox"
          data-card-modal-roster="1"
          data-team-id="${teamId}"
          data-user-id="${laUserId}"
          ${onRoster ? 'checked' : ''}
          style="width:20px; height:20px; cursor:pointer;"
        >
      </label>
    ` : '';

    // Remove any prior modal first
    this._closeCardModal();

    const overlay = document.createElement('div');
    overlay.id = 'lineups-card-modal';
    overlay.setAttribute('data-card-modal-close', '1');
    overlay.style.cssText = `
      position: fixed; inset: 0; z-index: 1000;
      background: rgba(0,0,0,0.55);
      display: flex; align-items: center; justify-content: center;
      padding: var(--space-3);
    `;
    overlay.innerHTML = `
      <div
        role="dialog"
        aria-modal="true"
        style="
          background: var(--bg-surface); color: var(--text-primary);
          border: 1px solid var(--border-color); border-radius: 10px;
          width: 100%; max-width: 420px;
          max-height: 90vh; overflow-y: auto;
          box-shadow: 0 10px 40px rgba(0,0,0,0.45);
        "
        onclick="event.stopPropagation()"
      >
        <header style="
          padding: var(--space-3) var(--space-4);
          border-bottom: 1px solid var(--border-color);
          display:flex; align-items:center; justify-content:space-between; gap: var(--space-2);
        ">
          <div>
            <div style="font-size: 1.05em; font-weight: 700;">${this._escape(name)}</div>
            <div style="font-size: 0.78em; color: var(--text-muted); margin-top: 2px;">
              ${this._escape(td.team.name)} · ${this._escape(effectiveKind)}
            </div>
          </div>
          <button
            data-card-modal-close="1"
            aria-label="Close"
            style="all:unset; cursor:pointer; font-size: 1.4em; padding: 4px 10px; border-radius: 6px; color: var(--text-muted);"
          >×</button>
        </header>

        <div style="padding: var(--space-3) var(--space-4); display:flex; flex-direction:column; gap: var(--space-3);">
          <div style="display:flex; gap: var(--space-4); flex-wrap:wrap; font-size:0.85em;">
            <div><span style="color:var(--text-muted);">Jersey:</span> <strong>${jersey}</strong></div>
            <div><span style="color:var(--text-muted);">RSVP:</span> <strong>${this._escape(rsvp)}</strong></div>
          </div>

          ${coachActionBtn ? `
            <div style="display:flex; flex-direction:column; gap: var(--space-2);">
              <div style="font-size:0.75em; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.04em;">Actions</div>
              ${rosterToggleHTML}
              ${coachActionBtn}
            </div>
          ` : (rosterToggleHTML ? `
            <div style="display:flex; flex-direction:column; gap: var(--space-2);">
              <div style="font-size:0.75em; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.04em;">Actions</div>
              ${rosterToggleHTML}
            </div>
          ` : '')}

          <div style="font-size: 0.72em; color: var(--text-muted); padding-top: var(--space-2); border-top: 1px dashed var(--border-color);">
            More edit options (jersey #, RSVP override) coming soon.
          </div>
        </div>
      </div>
    `;

    // Append inside the screen element so the existing delegated click /
    // change listeners on `this.element` catch modal interactions.
    this.element.appendChild(overlay);
    this._cardModalOverlay = overlay;
    this._cardModalKeyHandler = (e) => {
      if (e.key === 'Escape') this._closeCardModal();
    };
    document.addEventListener('keydown', this._cardModalKeyHandler);
  }

  _closeCardModal() {
    const existing = document.getElementById('lineups-card-modal');
    if (existing) existing.remove();
    this._cardModalOverlay = null;
    if (this._cardModalKeyHandler) {
      document.removeEventListener('keydown', this._cardModalKeyHandler);
      this._cardModalKeyHandler = null;
    }
  }

  // -------------------------------------------------------------------------
  // LA-pool detail modal — opened from the LA column's ✏️ edit button.
  // Renders LA-sourced fields (email, phone, payment status, etc.) for the
  // matched person.  Uses the same overlay slot/close handler as the
  // per-team card modal, so Escape and the × button keep working.
  // -------------------------------------------------------------------------
  _openLaPoolModal(personId) {
    const lp = this.laPool;
    const p  = lp?.persons?.find(x => x.personId === personId);
    if (!p) {
      alert('Could not find LA registration in pool.');
      return;
    }

    const name = `${p.firstName || ''} ${p.lastName || ''}`.trim() || '(unnamed)';
    const dob  = this._formatDob(p.birthDate) || '—';

    // Active teams the player is on, named via the pool's `teams` list.
    const teamNameById = new Map((lp.teams || []).map(t => [t.id, t.name]));
    const onTeams = (p.onRosterOn || [])
      .map(id => teamNameById.get(id))
      .filter(Boolean);

    const balanceStr = (p.outstandingBalance != null)
      ? `$${Number(p.outstandingBalance).toFixed(2)}`
      : '—';
    const paymentColor = p.paymentStatus === 'PAID' ? '#22c55e'
                       : p.paymentStatus === 'PARTIAL' ? '#f59e0b'
                       : p.paymentStatus === 'UNPAID' ? '#ef4444'
                       : 'var(--text-muted)';

    // Row helper — label + value, hides when value is empty.
    const row = (label, value, opts = {}) => {
      if (value == null || value === '' || value === '—') {
        if (!opts.alwaysShow) return '';
      }
      const v = value == null || value === '' ? '—' : value;
      const color = opts.color || 'var(--text-primary)';
      const mono  = opts.mono ? 'font-family:ui-monospace,monospace;' : '';
      const safeV = opts.html ? v : this._escape(String(v));
      return `
        <div style="display:flex; justify-content:space-between; gap:12px; font-size:0.85em;">
          <span style="color:var(--text-muted);">${this._escape(label)}</span>
          <span style="color:${color}; text-align:right; ${mono}">${safeV}</span>
        </div>
      `;
    };

    // Tappable mailto / tel links for quick contact.
    const emailHTML = p.email
      ? `<a href="mailto:${encodeURIComponent(p.email)}" style="color:#3b82f6; text-decoration:none;">${this._escape(p.email)}</a>`
      : null;
    const phoneHTML = p.phone
      ? `<a href="tel:${encodeURIComponent(p.phone)}" style="color:#3b82f6; text-decoration:none;">${this._escape(p.phone)}</a>`
      : null;

    this._closeCardModal();
    const overlay = document.createElement('div');
    overlay.id = 'lineups-card-modal';
    overlay.setAttribute('data-card-modal-close', '1');
    overlay.style.cssText = `
      position: fixed; inset: 0; z-index: 1000;
      background: rgba(0,0,0,0.55);
      display: flex; align-items: center; justify-content: center;
      padding: var(--space-3);
    `;
    overlay.innerHTML = `
      <div
        role="dialog"
        aria-modal="true"
        style="
          background: var(--bg-surface); color: var(--text-primary);
          border: 1px solid var(--border-color); border-radius: 10px;
          width: 100%; max-width: 420px;
          max-height: 90vh; overflow-y: auto;
          box-shadow: 0 10px 40px rgba(0,0,0,0.45);
        "
        onclick="event.stopPropagation()"
      >
        <header style="
          padding: var(--space-3) var(--space-4);
          border-bottom: 1px solid var(--border-color);
          display:flex; align-items:center; justify-content:space-between; gap: var(--space-2);
        ">
          <div>
            <div style="font-size: 1.05em; font-weight: 700;">${this._escape(name)}</div>
            <div style="font-size: 0.78em; color: var(--text-muted); margin-top: 2px;">
              LeagueApps · ${this._escape(p.programName || 'Mens program')}
            </div>
          </div>
          <button
            data-card-modal-close="1"
            aria-label="Close"
            style="all:unset; cursor:pointer; font-size: 1.4em; padding: 4px 10px; border-radius: 6px; color: var(--text-muted);"
          >×</button>
        </header>

        <div style="padding: var(--space-3) var(--space-4); display:flex; flex-direction:column; gap: var(--space-3);">

          <div style="display:flex; flex-direction:column; gap: 6px;">
            <div style="font-size:0.72em; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">Contact</div>
            ${row('Email', emailHTML, { html: true, alwaysShow: true })}
            ${row('Phone', phoneHTML, { html: true, alwaysShow: true })}
          </div>

          <div style="display:flex; flex-direction:column; gap: 6px;">
            <div style="font-size:0.72em; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">Player</div>
            ${row('Date of birth', dob, { mono: true, alwaysShow: true })}
            ${row('Gender', p.gender)}
            ${row('Role', p.role)}
            ${row('Season', p.season)}
          </div>

          <div style="display:flex; flex-direction:column; gap: 6px;">
            <div style="font-size:0.72em; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">Registration</div>
            ${row('Status', p.registrationStatus, { alwaysShow: true })}
            ${row('Payment', p.paymentStatus, { color: paymentColor, alwaysShow: true })}
            ${row('Outstanding', balanceStr, { color: paymentColor, mono: true, alwaysShow: true })}
            ${row('Registration #', p.registrationId, { mono: true })}
            ${row('LA user #', p.leagueAppsUserId, { mono: true, alwaysShow: true })}
          </div>

          <div style="display:flex; flex-direction:column; gap: 6px;">
            <div style="font-size:0.72em; color:var(--text-muted); text-transform:uppercase; letter-spacing:0.04em;">On rosters</div>
            <div style="font-size:0.85em; color:var(--text-primary);">
              ${onTeams.length
                ? onTeams.map(n => `<span style="display:inline-block;background:#22c55e;color:#0b1220;border-radius:999px;padding:2px 8px;font-size:0.78em;font-weight:700;margin:2px 4px 2px 0;">${this._escape(n)}</span>`).join('')
                : '<span style="color:var(--text-muted);font-style:italic;">Not on any team yet — tap a pill on the LA card to assign.</span>'}
            </div>
          </div>

          <div style="font-size: 0.72em; color: var(--text-muted); padding-top: var(--space-2); border-top: 1px dashed var(--border-color);">
            Source: LeagueApps · Live fetch.
          </div>
        </div>
      </div>
    `;
    this.element.appendChild(overlay);
    this._cardModalOverlay = overlay;
    this._cardModalKeyHandler = (e) => {
      if (e.key === 'Escape') this._closeCardModal();
    };
    document.addEventListener('keydown', this._cardModalKeyHandler);
  }

  // -------------------------------------------------------------------------
  // Toolbar (team visibility checkboxes — leads-style)
  // -------------------------------------------------------------------------
  _renderToolbar() {
    const wrap = this.find('#lineups-team-chips');
    if (!wrap) return;
    if (!this.teamData.length) {
      wrap.innerHTML = '<span style="color:var(--text-muted);font-size:0.85em;">No teams with upcoming matches.</span>';
      return;
    }
    wrap.innerHTML = this.teamData.map(td => {
      const tid = td.team.id;
      const hidden = this.hiddenTeams.has(tid);
      const count = Array.isArray(td.players) ? td.players.length : 0;
      return `
        <label
          style="
            display:inline-flex; align-items:center; gap:6px;
            font-size:0.8rem; cursor:pointer; user-select:none;
            padding:2px 8px; border-radius:4px;
            border-left:3px solid var(--border-color);
            opacity:${hidden ? '0.6' : '1'};
          "
          title="${hidden ? 'Show' : 'Hide'} ${this._escape(td.team.name)}"
        >
          <input
            type="checkbox"
            class="team-toggle"
            data-team-chip="${tid}"
            ${hidden ? '' : 'checked'}
            style="cursor:pointer;"
          >
          ${this._escape(td.team.name)} <span style="opacity:0.55;">(${count})</span>
        </label>
      `;
    }).join('');
  }

  // -------------------------------------------------------------------------
  // Columns
  // -------------------------------------------------------------------------
  _renderColumns() {
    const cols = this.find('#lineups-columns');
    if (!cols) return;
    const visible = this.teamData.filter(td => !this.hiddenTeams.has(td.team.id));
    const poolHTML = this._renderPoolColumn();
    if (!visible.length && !poolHTML) {
      cols.innerHTML = `
        <div style="padding: var(--space-6); color: var(--text-muted); text-align:center; width:100%;">
          All teams hidden — turn one on above to start picking lineups.
        </div>
      `;
      return;
    }
    cols.innerHTML = (poolHTML || '') + visible.map(td => `
      <section
        data-team-col="${td.team.id}"
        style="
          flex: 0 0 320px; min-width: 320px; max-width: 360px;
          background: var(--bg-surface);
          border: 1px solid var(--border-color);
          border-radius: 8px;
          display: flex; flex-direction: column;
        "
      >${this._renderColumnInner(td)}</section>
    `).join('');
  }

  _renderColumn(td) {
    if (this.hiddenTeams.has(td.team.id)) return;
    const el = this.find(`[data-team-col="${td.team.id}"]`);
    if (!el) return;
    el.innerHTML = this._renderColumnInner(td);
  }

  _renderColumnInner(td) {
    const m = td.nextMatch;
    const teamId = td.team.id;
    const teamName = this._escape(td.team.name);

    // Build match-card header — or a placeholder when there's no upcoming
    // match (APSL, Liga 1, Pool, etc.). Reconciliation still renders below.
    let matchHeaderBody;
    let startCount = 0, benchCount = 0, totalOn = 0;
    let maxBench = (td.rosterSize || 20) - 11;
    if (m) {
      const matchTitle = this._escape(m.title || 'Next match');
      const { dateStr, timeStr } = this._splitEventDate(m.event_date || m.match_date, m.match_time);
      const venue = (m.venue_address ? String(m.venue_address).trim() : '') ||
                    (m.venue_name ? String(m.venue_name).trim() : '');
      startCount = td.zones.starting.length;
      benchCount = td.zones.bench.length;
      totalOn = startCount + benchCount;
      matchHeaderBody = `
        <div style="margin-top: var(--space-1); font-size: 0.9em; color: var(--text-primary); display:flex; align-items:center; gap:6px;">
          <strong>${matchTitle}</strong>
          <button
            type="button"
            data-edit-match-open="${teamId}"
            title="Edit this match — opponent, date, or time"
            style="
              all:unset; cursor:pointer;
              font-size:0.72em; font-weight:500;
              padding:1px 6px; border-radius:4px;
              background:transparent; color:var(--text-muted);
              border:1px solid var(--border-color);
            "
          >Edit</button>
        </div>
        <div style="margin-top: 2px; font-size: 0.78em; color: var(--text-muted);">
          📅 ${this._escape(dateStr)}${timeStr ? ` &middot; 🕒 ${this._escape(timeStr)}` : ''}
        </div>
        ${venue ? `<div style="margin-top: 2px; font-size: 0.78em; color: var(--text-muted);">📍 ${this._escape(venue)}</div>` : ''}
        <div style="
          margin-top: var(--space-2);
          display:flex; gap: var(--space-2); flex-wrap:wrap;
          font-size: 0.78em; color: var(--text-muted);
        ">
          <span style="color:#22c55e;">⚽ ${startCount}/11 starters</span>
          <span style="color:#f59e0b;">🪑 ${benchCount}/${maxBench} bench</span>
          <span>· ${totalOn}/${td.rosterSize} total</span>
        </div>
      `;
    } else {
      matchHeaderBody = `
        <div style="margin-top: var(--space-1); font-size: 0.85em; color: var(--text-muted); font-style: italic;">
          No upcoming match — chat roster only
        </div>
      `;
    }

    const header = `
      <header style="
        padding: var(--space-3);
        border-bottom: 1px solid var(--border-color);
        background: var(--bg-secondary, rgba(255,255,255,0.04));
        border-radius: 8px 8px 0 0;
      ">
        <div style="display:flex; align-items:center; justify-content:space-between; gap:var(--space-2);">
          <strong style="font-size: 1em; color: var(--text-primary); display:flex; align-items:center; flex-wrap:wrap; gap:6px;">
            <a
              href="#"
              data-team-hub-open="${teamId}"
              title="Open ${teamName} team page — roster, schedule, attendance, chat"
              style="color: var(--text-primary); text-decoration: none; border-bottom: 1px dotted var(--text-muted); cursor: pointer;"
            >${teamName}</a>
            ${(() => {
              const cur = Array.isArray(td.players) ? td.players.length : 0;
              const cap = td.internalRosterSize || 35;
              const pct = cap > 0 ? Math.round((cur / cap) * 100) : 0;
              const need = Math.max(0, cap - cur);
              // Ratio color: red < 60%, amber < 90%, green ≥ 90%.  Gives a
              // fast "how full is this team" scan across the columns.
              const ratioColor = pct >= 90 ? '#22c55e' : (pct >= 60 ? '#f59e0b' : '#ef4444');
              const needColor  = need === 0  ? 'var(--text-muted)' : '#f59e0b';
              return `
                <span style="font-size:0.78em; font-weight:600; color:${ratioColor}; font-family:monospace;"
                      title="Internal roster size · ${cur} of ${cap} · ${pct}% full · ${need} more to fill">
                  ${cur}/${cap}
                </span>
                <span style="font-size:0.72em; font-weight:500; color:var(--text-muted);"
                      title="${pct}% of roster filled">
                  · ${pct}%
                </span>
                ${need > 0 ? `
                  <span style="font-size:0.72em; font-weight:600; color:${needColor};"
                        title="${need} more player${need === 1 ? '' : 's'} needed to reach ${cap}">
                    · need ${need}
                  </span>
                ` : `
                  <span style="font-size:0.72em; font-weight:600; color:#22c55e;"
                        title="Roster full">
                    · full
                  </span>
                `}
              `;
            })()}
          </strong>
          <button
            type="button"
            data-add-match-open="${teamId}"
            title="Add a match / game for this team"
            style="
              all:unset; cursor:pointer;
              font-size:0.72em; font-weight:600;
              padding:2px 8px; border-radius:4px;
              background:#3b82f6; color:#fff;
              border:1px solid #2563eb;
            "
          >+ Match</button>
        </div>
        ${matchHeaderBody}
        ${td._addMatchOpen ? this._renderAddMatchForm(td) : ''}
      </header>
    `;

    if (td.error) {
      return header + `
        <div style="padding: var(--space-3); color: #ef4444; font-size:0.85em;">
          ❌ ${this._escape(td.error)}
        </div>
      `;
    }
    if (!td.loaded) {
      return header + `
        <div style="padding: var(--space-3); color: var(--text-muted); font-size:0.85em;">
          <div class="spinner" style="display:inline-block; vertical-align:middle;"></div>
          Loading players…
        </div>
      `;
    }

    return header + this._renderReconciliationSections(td);
  }

  // -------------------------------------------------------------------------
  // Add-match inline form (per team column) — also serves as the edit form.
  // -------------------------------------------------------------------------
  //
  // Rendered inside the column header when td._addMatchOpen is true.  Three
  // fields: opponent (free text), date, time.  Submits to
  // POST /api/lineups/games (create) or PUT /api/lineups/games/:matchId
  // (edit — when td._matchFormEditId is set).  Both endpoints return
  // the same match shape so _onAddMatchSave doesn't branch on the response.
  //
  // Edit-mode prefill: opponent strips the "vs " prefix (auto-added on
  // save server-side, so we round-trip cleanly); date and time come from
  // td.nextMatch.  When _matchFormEditId isn't set, we fall through to
  // the "new match" defaults (today's date, 19:00).
  _renderAddMatchForm(td) {
    const tid = td.team.id;
    const editId = td._matchFormEditId || null;
    const isEdit = !!editId;

    // Prefill values.  Only touched in edit mode; add mode keeps the
    // original "today at 7pm" defaults for a fast common-case create.
    let defaultOpponent = '';
    let defaultDate;
    let defaultTime = '19:00';
    if (isEdit && td.nextMatch) {
      // Strip auto-added "vs " prefix so the user sees & edits just the
      // opponent name — server re-adds it on save if not already there.
      defaultOpponent = String(td.nextMatch.title || '').replace(/^vs\s+/i, '');
      defaultDate = td.nextMatch.match_date || '';
      // match_time may be "HH:MM:SS" from the DB; <input type=time>
      // accepts "HH:MM" or "HH:MM:SS" so pass through as-is (empty → no
      // preselected time, same as add mode when time isn't set).
      defaultTime = td.nextMatch.match_time || '';
    }
    if (!defaultDate) {
      const today = new Date();
      const y = today.getFullYear();
      const m = String(today.getMonth() + 1).padStart(2, '0');
      const d = String(today.getDate()).padStart(2, '0');
      defaultDate = `${y}-${m}-${d}`;
    }
    const headingLabel = isEdit ? 'Edit match' : 'New match';
    const saveLabel    = isEdit ? 'Save changes' : 'Save';
    // Escape prefill to keep an opponent name with quotes (e.g. `"The
    // Reds"`) from breaking out of the value attribute.
    const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
    return `
      <div
        data-add-match-form="${tid}"
        data-match-edit-id="${isEdit ? editId : ''}"
        style="
          margin-top: var(--space-2);
          padding: var(--space-2);
          background: var(--bg-surface);
          border: 1px solid var(--border-color);
          border-radius: 6px;
          display: flex; flex-direction: column; gap: 6px;
        "
      >
        <div style="display:flex; align-items:center; justify-content:space-between; gap:6px;">
          <span style="font-size:0.78em; font-weight:600; color:var(--text-primary);">${headingLabel}</span>
          <button
            type="button"
            data-add-match-cancel="${tid}"
            style="all:unset; cursor:pointer; font-size:0.78em; color:var(--text-muted);"
          >✕</button>
        </div>
        <input
          type="text"
          data-add-match-field="opponent"
          data-team-id="${tid}"
          placeholder="Opponent (e.g., Real Madrid)"
          value="${esc(defaultOpponent)}"
          style="
            padding: 6px 8px; font-size: 0.85em;
            background: var(--bg-secondary, rgba(255,255,255,0.04));
            border: 1px solid var(--border-color);
            border-radius: 4px; color: var(--text-primary);
          "
        />
        <div style="display:flex; gap:6px;">
          <input
            type="date"
            data-add-match-field="date"
            data-team-id="${tid}"
            value="${esc(defaultDate)}"
            style="
              flex:1; padding: 6px 8px; font-size: 0.85em;
              background: var(--bg-secondary, rgba(255,255,255,0.04));
              border: 1px solid var(--border-color);
              border-radius: 4px; color: var(--text-primary);
            "
          />
          <input
            type="time"
            data-add-match-field="time"
            data-team-id="${tid}"
            value="${esc(defaultTime)}"
            style="
              width: 100px; padding: 6px 8px; font-size: 0.85em;
              background: var(--bg-secondary, rgba(255,255,255,0.04));
              border: 1px solid var(--border-color);
              border-radius: 4px; color: var(--text-primary);
            "
          />
        </div>
        <div style="display:flex; justify-content:flex-end; gap:6px; margin-top:2px;">
          <button
            type="button"
            data-add-match-save="${tid}"
            style="
              all:unset; cursor:pointer;
              padding: 4px 12px; border-radius: 4px;
              font-size: 0.8em; font-weight: 600;
              background: #22c55e; color: #0b1220;
              border: 1px solid #16a34a;
            "
          >${saveLabel}</button>
        </div>
        <div
          data-add-match-error="${tid}"
          style="font-size:0.75em; color:#ef4444; display:none;"
        ></div>
      </div>
    `;
  }

  async _onAddMatchSave(teamId) {
    const td = (this.teamData || []).find(t => t?.team?.id === teamId);
    if (!td) return;
    const root = this.find(`[data-add-match-form="${teamId}"]`);
    if (!root) return;
    const err = (msg) => {
      const el = root.querySelector(`[data-add-match-error="${teamId}"]`);
      if (el) { el.textContent = msg; el.style.display = 'block'; }
    };
    const clearErr = () => {
      const el = root.querySelector(`[data-add-match-error="${teamId}"]`);
      if (el) { el.textContent = ''; el.style.display = 'none'; }
    };
    clearErr();

    const opponent = (root.querySelector(`[data-add-match-field="opponent"][data-team-id="${teamId}"]`)?.value || '').trim();
    const date     = (root.querySelector(`[data-add-match-field="date"][data-team-id="${teamId}"]`)?.value || '').trim();
    const time     = (root.querySelector(`[data-add-match-field="time"][data-team-id="${teamId}"]`)?.value || '').trim();
    if (!opponent) return err('Opponent required');
    if (!date)     return err('Date required');

    // Edit vs create — the form's data-match-edit-id attribute is the
    // source of truth (mirrors td._matchFormEditId at render time so a
    // stale td state can't cause a wrong-endpoint POST).
    const editIdRaw = root.getAttribute('data-match-edit-id') || '';
    const editId = editIdRaw ? parseInt(editIdRaw, 10) : null;
    const isEdit = Number.isFinite(editId) && editId > 0;

    const saveBtn = root.querySelector(`[data-add-match-save="${teamId}"]`);
    const savingLabel = isEdit ? 'Saving…' : 'Saving…';
    const idleLabel   = isEdit ? 'Save changes' : 'Save';
    if (saveBtn) { saveBtn.disabled = true; saveBtn.style.opacity = '0.6'; saveBtn.textContent = savingLabel; }

    try {
      const url = isEdit
        ? `/api/lineups/games/${editId}`
        : '/api/lineups/games';
      const method = isEdit ? 'PUT' : 'POST';
      const body = isEdit
        ? { opponent, date, time: time || undefined }
        : { team_id: teamId, opponent, date, time: time || undefined };
      const res = await this.auth.fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = await this._safeJson(res);
      if (!res.ok || data.error) {
        err(data.error || `HTTP ${res.status}`);
        if (saveBtn) { saveBtn.disabled = false; saveBtn.style.opacity = '1'; saveBtn.textContent = idleLabel; }
        return;
      }

      // Adopt as td.nextMatch immediately so the header shows the new
      // (or updated) match without waiting for a round-trip.  Match
      // shape from /api/matches/team/:teamId uses event_date =
      // "YYYY-MM-DD HH:MM:SS" — build the same combined string so
      // _splitEventDate is happy.  Both POST (create) and PUT (edit)
      // return the same shape so this path is shared.
      const eventDate = data.match_time
        ? `${data.match_date} ${data.match_time}`
        : `${data.match_date}`;
      td.nextMatch = {
        id:         data.id,
        title:      data.title,
        event_date: eventDate,
        match_date: data.match_date,
        match_time: data.match_time || null,
      };
      td._addMatchOpen = false;
      td._matchFormEditId = null;
      this._renderColumn(td);
      // Reload players against the (possibly-new) match so RSVP buckets
      // stay in sync.  For an edit that only tweaks the title, this is a
      // no-op refresh; for a date/time change, it re-computes eligibility.
      this._scheduleTeamRefresh(teamId);
    } catch (e) {
      err(e?.message || 'Network error');
      if (saveBtn) { saveBtn.disabled = false; saveBtn.style.opacity = '1'; saveBtn.textContent = idleLabel; }
    }
  }

  // -------------------------------------------------------------------------
  // Reconciliation sections (4 buckets, no inner scroll, drag-merge enabled)
  // -------------------------------------------------------------------------
  //
  // The reconciliation endpoint partitions every person attached to this team
  // into buckets:
  //
  //   1. Players  — has an LA registration and is not currently a coach.
  //                 These are the only people the lineup actually picks from;
  //                 they get Starter / Bench toggles and contribute to the
  //                 11-starter cap.
  //
  //   2. Coaches  — has an active team_coaches row.  Shown for context but
  //                 not eligible for the lineup; can be un-marked back into
  //                 Players via the coach toggle.
  //
  //   3. LA only  — registered with LeagueApps but not yet picked up by the
  //                 official roster; surfaced so admins can complete linking.
  //
  // Sections render bottom-to-top in importance — empty sections are skipped
  // entirely so a fully-reconciled team just shows Players + Coaches.
  _renderReconciliationSections(td) {
    if (td.reconciliation === null) {
      // Reconciliation fetch failed — fall back to roster-players only.
      return this._renderFallbackList(td);
    }
    const rec = td.reconciliation;

    // Build personId → roster-players row for RSVP/jersey/practice enrichment.
    const playerByPerson = new Map();
    for (const p of td.players) {
      if (p.personId) playerByPerson.set(p.personId, p);
    }
    const enrich = (e) => Object.assign({}, e, { _player: playerByPerson.get(e.personId) || null });

    // Count of practice/pickup events this player RSVP'd 'yes' to.
    // td.players[].practice is an array of {v, o} aligned with trainingEvents.
    const goingTrainingCount = (p) => {
      if (!p || !Array.isArray(p.practice)) return 0;
      return p.practice.filter(e => e && (e.v || '').toLowerCase() === 'yes').length;
    };

    // Eleven-bucket partition.  Each matched player lands in exactly one
    // bucket; zone assignment wins over RSVP/training state.
    const starter = [], bench = [], alternate = [];
    const going2plus = [], going1 = [], going0 = [];
    const maybe = [];
    const notGoing = [], noResponse = [];

    // Source of truth = td.players (C++ /api/matches/:id/roster-players),
    // which filters to FH members only: LA-mens registrants
    // (external_person_aliases JOIN mens_team_assignments) OR self-
    // registered FH members (persons.fh_member_at IS NOT NULL).
    for (const p of td.players) {
      const e = {
        personId:  p.personId,
        firstName: p.firstName,
        lastName:  p.lastName,
        _player:   p,
      };
      // playerId arrives as a string from the API; zones store numbers from
      // the click handler's parseInt. Coerce to keep .includes() honest.
      const pid = p?.playerId != null ? Number(p.playerId) : null;
      if (pid != null && td.zones.starting.includes(pid))    { starter.push(e);  continue; }
      if (pid != null && td.zones.bench.includes(pid))       { bench.push(e);    continue; }
      if (pid != null && td.zones.alternates.includes(pid))  { alternate.push(e); continue; }
      const rsvp = (p?.rsvpStatus || '').toLowerCase();
      if (rsvp === 'yes') {
        const n = goingTrainingCount(p);
        if (n >= 2)      going2plus.push(e);
        else if (n === 1) going1.push(e);
        else              going0.push(e);
      } else if (rsvp === 'maybe') {
        maybe.push(e);
      } else if (rsvp === 'no') {
        notGoing.push(e);
      } else {
        noResponse.push(e);
      }
    }

    // Order: lineup zones first (starter → bench → alternate), then unpicked
    // matched players tiered by going-readiness, then declines / silence,
    // then coaches, then the reconciliation junk drawer (LA only).
    // `alwaysShow` keeps a banner visible even when empty — used for the
    // three lineup zones so the user always sees where their clicks land.
    const sections = [
      { kind: 'player', title: 'STARTER',              color: '#22c55e', entries: starter,    alwaysShow: true, subtitle: `${starter.length}/11` },
      { kind: 'player', title: 'BENCH',                color: '#f59e0b', entries: bench,      alwaysShow: true, subtitle: `${bench.length}/${Math.max(0, td.rosterSize - 11)}` },
      { kind: 'player', title: 'ALTERNATE',            color: '#a78bfa', entries: alternate,  alwaysShow: true },
      { kind: 'player', title: 'GOING · 2+ TRAININGS', color: '#16a34a', entries: going2plus },
      { kind: 'player', title: 'GOING · 1 TRAINING',   color: '#65a30d', entries: going1 },
      { kind: 'player', title: 'GOING · 0 TRAININGS',  color: '#a3a32d', entries: going0 },
      { kind: 'player', title: 'MAYBE',                color: '#f59e0b', entries: maybe },
      { kind: 'player', title: 'NOT GOING',            color: '#ef4444', entries: notGoing },
      { kind: 'player', title: 'NO RESPONSE',          color: '#94a3b8', entries: noResponse },
      { kind: 'coach',  title: 'COACHES',              color: '#0ea5e9', entries: (rec.coaches || []).map(enrich) },
      // LA-only / GM-only intentionally OMITTED — post June 2026 cutover
      // the lineup is FH-membership driven and only shows FH members
      // (LA mens registrants OR persons.fh_member_at IS NOT NULL).
      // GM-only ghosts no longer surface here; if someone needs to be
      // added to a team, promote them via Club Admin → Mens or have
      // them fill out the FH member form.
    ];

    const bodyHtml = sections
      .filter(s => s.alwaysShow || s.entries.length > 0)
      .map(s => this._renderSection(td, s))
      .join('');

    return `<div>${bodyHtml || `<div style="padding:var(--space-3);color:var(--text-muted);font-size:0.85em;">No one on this team yet.</div>`}</div>`;
  }

  _renderSection(td, { kind, title, subtitle, color, entries }) {
    // Build the bold full-width banner header for the section.
    const headerHtml = `
      <div style="
        padding: 8px var(--space-3);
        font-size: 0.78em; font-weight: 700; letter-spacing: 0.08em;
        color: ${color};
        background: ${this._hexToBg(color)};
        border-top: 1px solid var(--border-color);
        border-bottom: 1px solid var(--border-color);
        border-left: 4px solid ${color};
      ">
        ${title} <span style="opacity:0.7;font-weight:600;">· ${entries.length}</span>
        ${subtitle ? `<div style="font-size:0.78em;font-weight:400;letter-spacing:0;color:var(--text-muted);margin-top:2px;">${subtitle}</div>` : ''}
      </div>`;

    return `
      <div>
        ${headerHtml}
        ${entries.map(e => this._renderPersonCard(td, e, kind)).join('')}
      </div>
    `;
  }

  // Convert a #rrggbb accent color into a low-opacity translucent fill so
  // the banner strip reads as tinted but doesn't overwhelm the cards below.
  _hexToBg(hex) {
    const m = /^#([0-9a-f]{6})$/i.exec(hex);
    if (!m) return 'rgba(255,255,255,0.04)';
    const n = parseInt(m[1], 16);
    const r = (n >> 16) & 0xff, g = (n >> 8) & 0xff, b = n & 0xff;
    return `rgba(${r},${g},${b},0.12)`;
  }

  _renderFallbackList(td) {
    // Reconciliation API failed — render roster-players flat so the screen
    // still works without merge/coach features.
    if (!td.players.length) {
      return `<div style="padding:var(--space-3);color:var(--text-muted);font-size:0.85em;">No players on roster yet.</div>`;
    }
    const items = td.players.map(p => this._renderPersonCard(td, { ...p, _player: p }, 'player')).join('');
    return `<div>
      <div style="padding:6px var(--space-3);font-size:0.72em;color:#f59e0b;background:var(--bg-secondary,rgba(255,255,255,0.03));">
        ⚠️ reconciliation unavailable — showing roster-players only
      </div>
      ${items}
    </div>`;
  }

  // Card renderer — one shape for both rendered kinds, behavior varies by `kind`:
  //   • 'player'  → Starter/Bench toggles + coach button
  //   • 'coach'   → coach button only (un-mark)
  _renderPersonCard(td, entry, kind) {
    const p = entry._player || {};
    // entry has {personId, firstName, lastName, birthDate, leagueAppsUserId,
    //            isCoach, laOnRoster, ...}
    // playerId may come in as a string from the API — normalize so all
    // downstream comparisons against td.zones.* (which hold numbers) work.
    const playerId = p.playerId != null && p.playerId !== '' ? Number(p.playerId) : null;
    const personId = entry.personId;
    const name = `${this._escape(entry.firstName || '')} ${this._escape(entry.lastName || '')}`.trim();
    const jersey = p.jerseyNumber != null && p.jerseyNumber !== ''
      ? `<span style="display:inline-block;min-width:22px;text-align:center;font-size:0.7em;padding:1px 4px;border-radius:3px;background:var(--bg-secondary,rgba(255,255,255,0.08));color:var(--text-muted);margin-right:4px;">#${this._escape(String(p.jerseyNumber))}</span>`
      : '';

    const rsvp = (p.rsvpStatus || '').toLowerCase();
    // RSVP pill — single letter, color-coded background, matches the S/B/A/N
    // zone selector visual language.
    //   G = green   (going)
    //   M = yellow  (maybe)
    //   N = red     (not going)
    //   ? = orange  (no response / unknown)
    const rsvpInfo =
      rsvp === 'yes'   ? { letter: 'G', bg: '#22c55e', fg: '#0b1220', title: 'Going' } :
      rsvp === 'maybe' ? { letter: 'M', bg: '#eab308', fg: '#0b1220', title: 'Maybe' } :
      rsvp === 'no'    ? { letter: 'N', bg: '#ef4444', fg: '#fff',    title: 'Not going' } :
                         { letter: '?', bg: '#f97316', fg: '#0b1220', title: 'No response' };
    const rsvpDot = `
      <span title="${rsvpInfo.title}"
            style="display:inline-block;width:18px;height:18px;line-height:18px;
                   text-align:center;border-radius:4px;font-size:0.7em;font-weight:700;
                   background:${rsvpInfo.bg};color:${rsvpInfo.fg};">${rsvpInfo.letter}</span>`;

    // FH-native magic-link mint buttons — appear inline with the RSVP dot
    // when a player has NO response yet AND a next match is loaded for this
    // team.  Two icon buttons (📧 / 📱) call POST /api/auth/magic-link/mint
    // and open the resulting mailto:/sms: URI in the admin's own client.
    //   • Hidden once the player has any RSVP (yes/maybe/no).
    //   • Hidden for coach kind (no chat_event scope).
    //   • Each button disabled when the corresponding contact (email/phone)
    //     is missing from LeagueApps.
    let mintBtns = '';
    if (kind === 'player' && rsvp === '' && td.nextMatch?.id && personId) {
      const laPerson = this._laPoolByPersonId?.get(personId) || null;
      const email    = laPerson?.email || '';
      const phone    = laPerson?.phone || '';
      const matchId  = td.nextMatch.id;
      const teamId   = td.team.id;
      const baseAttrs = (channel, contact, disabled) => `
        data-rsvp-mint="${channel}"
        data-person-id="${personId}"
        data-match-id="${matchId}"
        data-team-id="${teamId}"
        data-contact="${this._escape(contact)}"
        ${disabled ? 'disabled' : ''}
        title="${disabled
          ? (channel === 'email' ? 'No email on LeagueApps' : 'No phone on LeagueApps')
          : (channel === 'email' ? `Email RSVP link to ${this._escape(contact)}` : `Text RSVP link to ${this._escape(contact)}`)}"
        style="all:unset;cursor:${disabled ? 'not-allowed' : 'pointer'};
               width:22px;height:22px;line-height:20px;text-align:center;
               border-radius:4px;font-size:0.85em;
               border:1px solid var(--border-color);
               opacity:${disabled ? '0.3' : '1'};"`;
      mintBtns = `
        <button ${baseAttrs('email', email, !email)}>📧</button>
        <button ${baseAttrs('sms',   phone, !phone)}>📱</button>`;
    }

    // Practice attendance: count of "yes" RSVPs across the last-5 training
    // events.  Only shown for player kind.  Green ≥2, yellow =1, red =0.
    let practicePill = '';
    if (kind === 'player' && Array.isArray(p.practice) && p.practice.length > 0) {
      const events = (td.trainingEvents || []).slice(0, 5);
      const total  = events.length || p.practice.length;
      const going  = p.practice.slice(0, total).filter(e => e && (e.v || '').toLowerCase() === 'yes').length;
      const color  =
        going >= 2 ? '#22c55e' :
        going === 1 ? '#f59e0b' :
                      '#ef4444';
      practicePill = `
        <span title="Training RSVPs (last ${total}): ${going} going"
              style="font-size:0.7em; padding:1px 5px; border-radius:3px;
                     background:${color}; color:#0b1220;
                     font-weight:700; white-space:nowrap;">
          T ${going}/${total}
        </span>`;
    }

    const badges = [];
    if (p.isKeeper) badges.push('<span title="Goalkeeper" style="font-size:0.7em;">🧤</span>');
    // Official roster indicator — only meaningful for LA-registered people
    // (players + laOnly).  Green R = on official roster; red R = LA-registered
    // but not yet rostered.  Skipped for coach (no LA registration).
    if (kind === 'player' || kind === 'laOnly') {
      if (entry.laOnRoster === true) {
        badges.push('<span title="On official roster" style="font-size:0.7em; font-weight:700; padding:1px 5px; border-radius:3px; background:#22c55e; color:#0b1220;">R</span>');
      } else if (entry.laOnRoster === false) {
        badges.push('<span title="LA-registered, not yet on official roster" style="font-size:0.7em; font-weight:700; padding:1px 5px; border-radius:3px; background:#ef4444; color:#fff;">R</span>');
      }
    }

    // Drag-to-merge removed with the GroupMe cutover — no draggable cards.
    const draggable = '';

    // Toggle / edit controls.  Edit (✏️) shows for EVERY card kind so the
    // detail modal is always reachable; S/B only when we have a playerId.
    //   Player kind — Starter (S) + Bench (B) + Edit (✏️)
    //   Coach  kind — Edit only
    const editBtn = `
      <button
        data-edit-card="${kind}"
        data-team-id="${td.team.id}"
        ${personId
          ? `data-person-id="${personId}"`
          : `data-external-user-id="${this._escape(entry.externalUserId || '')}" data-chat-id="${entry.chatId || ''}"`}
        title="Edit…"
        style="all:unset;cursor:pointer;width:22px;height:22px;line-height:20px;text-align:center;border-radius:4px;font-size:0.75em;border:1px solid var(--border-color);color:var(--text-muted);"
      >✏️</button>
    `;
    let controls = '';
    if (kind === 'player' && playerId != null) {
      // Single zone dropdown — N (null/uninvited) is the default.  Tapping
      // it opens the native menu with all four options.
      //   N = red    (default; not invited to this match)
      //   S = green  (starter)
      //   B = yellow (bench)
      //   A = red    (alternate)
      let currentZone = 'null';
      if (td.zones.starting.includes(playerId))        currentZone = 'starter';
      else if (td.zones.bench.includes(playerId))      currentZone = 'bench';
      else if (td.zones.alternates.includes(playerId)) currentZone = 'alternate';
      const zoneColors = {
        starter:   { bg: '#22c55e', fg: '#0b1220' },
        bench:     { bg: '#eab308', fg: '#0b1220' },
        alternate: { bg: '#ef4444', fg: '#fff'   },
        null:      { bg: '#ef4444', fg: '#fff'   },
      };
      const zoneLetter = { starter: 'S', bench: 'B', alternate: 'A', null: 'N' }[currentZone];
      const c = zoneColors[currentZone];
      controls = `
        <span style="display:inline-flex;gap:4px;align-items:center;">
          <select
            data-zone-select="1"
            data-team-id="${td.team.id}"
            data-player-id="${playerId}"
            title="Lineup zone"
            style="appearance:none;-webkit-appearance:none;-moz-appearance:none;
                   width:22px;height:22px;padding:0;text-align:center;text-align-last:center;
                   border-radius:4px;font-size:0.7em;font-weight:700;cursor:pointer;
                   background:${c.bg};color:${c.fg};border:1px solid ${c.bg};
                   line-height:20px;">
            <option value="null"      ${currentZone === 'null'      ? 'selected' : ''}>N</option>
            <option value="starter"   ${currentZone === 'starter'   ? 'selected' : ''}>S</option>
            <option value="bench"     ${currentZone === 'bench'     ? 'selected' : ''}>B</option>
            <option value="alternate" ${currentZone === 'alternate' ? 'selected' : ''}>A</option>
          </select>
          ${editBtn}
        </span>
      `;
    } else {
      // player without playerId (column with no match) OR coach
      controls = editBtn;
    }

    return `
      <div
        data-person-id="${personId}"
        data-kind="${kind}"
        style="
          display:flex; flex-direction:column; gap:3px;
          padding: 6px var(--space-3);
          border-bottom: 1px solid var(--border-color);
        "
      >
        <div style="display:flex; align-items:center; gap: var(--space-2);">
          <span style="font-size:0.85em;">${rsvpDot}</span>
          ${mintBtns}
          ${jersey}
          <span style="flex:1; font-size: 0.88em; color: var(--text-primary);">${name || '(unnamed)'}</span>
          ${entry.birthDate ? `<span style="font-size:0.7em;color:var(--text-muted);font-family:monospace;">${this._formatDob(entry.birthDate)}</span>` : ''}
          <span style="display:flex; gap:2px;">${badges.join('')}</span>
          ${practicePill}
          ${controls}
        </div>
      </div>
    `;
  }

  // -------------------------------------------------------------------------
  // Zone toggle (replaces the old 3-tap cycle)
  // -------------------------------------------------------------------------
  //
  // Each player card has two independent toggle buttons: Starter (S) and
  // Bench (B).  They behave like mutually-exclusive radio buttons — flipping
  // one on automatically flips the other off.  Both off = "uninvited",
  // which is the lineup-position equivalent of not being on this match.
  //
  // The user only invokes one button at a time so we don't need to handle
  // "S+B both pressed" — but we DO defensively clear the other zone before
  // applying the new one to keep the data clean in case of a bug.
  _setZone(teamId, playerId, target) {
    const td = this.teamData.find(t => t.team.id === teamId);
    if (!td) return;

    const idxStart = td.zones.starting.indexOf(playerId);
    const idxBench = td.zones.bench.indexOf(playerId);
    const idxAlt   = td.zones.alternates.indexOf(playerId);
    if (idxStart >= 0) td.zones.starting.splice(idxStart, 1);
    if (idxBench >= 0) td.zones.bench.splice(idxBench, 1);
    if (idxAlt   >= 0) td.zones.alternates.splice(idxAlt, 1);

    // Direct assignment to the target zone.  'null' / '' / 'none' = uninvited.
    if (target === 'starter')        td.zones.starting.push(playerId);
    else if (target === 'bench')     td.zones.bench.push(playerId);
    else if (target === 'alternate') td.zones.alternates.push(playerId);
    // else: leave them out of all zones (null = uninvited)

    this._renderColumn(td);
    this._scheduleSave(td);
  }

  // -------------------------------------------------------------------------
  // Coach toggle
  // -------------------------------------------------------------------------
  //
  // POSTing to /api/teams/:teamId/coaches/:personId moves the person from
  // the Players bucket to the Coaches bucket (a person counted as coach is
  // intentionally excluded from the lineup pool, per the user's rule).
  // DELETE soft-ends the assignment and the person flips back to Players.
  async _toggleCoach(teamId, personId, action) {
    try {
      const url = `/api/teams/${teamId}/coaches/${personId}`;
      const res = await this.auth.fetch(url, {
        method: action === 'add' ? 'POST' : 'DELETE',
      });
      if (!res.ok) {
        const body = await res.json().catch(() => ({}));
        throw new Error(body.error || `HTTP ${res.status}`);
      }
      // Refresh reconciliation for this team so the bucket flip is reflected.
      const td = this.teamData.find(t => t.team.id === teamId);
      if (td) await this._refreshReconciliation(td);
    } catch (err) {
      console.error('coach toggle failed:', err);
      alert(`Could not ${action === 'add' ? 'mark' : 'un-mark'} coach: ${err.message}`);
    }
  }

  // -------------------------------------------------------------------------
  // Merge confirm modal removed with the GroupMe cutover — no loose-end
  // (LA-only / GM-only) cards exist to drag, so there's no drag-merge flow.
  // /api/persons/merge is still callable from Club Admin tools if needed.
  // -------------------------------------------------------------------------

  async _refreshReconciliation(td) {
    try {
      const res = await this.auth.fetch(`/api/teams/${td.team.id}/reconciliation`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      td.reconciliation = await res.json();
      this._renderColumn(td);
    } catch (err) {
      console.error('reconciliation refresh failed:', err);
    }
  }

  _scheduleSave(td) {
    const teamId = td.team.id;
    if (this._saveTimers.has(teamId)) {
      clearTimeout(this._saveTimers.get(teamId));
    }
    const t = setTimeout(() => {
      this._saveTimers.delete(teamId);
      this._saveLineup(td);
    }, 600);
    this._saveTimers.set(teamId, t);
  }

  async _saveLineup(td) {
    if (!td.nextMatch) return; // no match → nothing to save
    const matchId = td.nextMatch.id;
    const starters = td.zones.starting.map((playerId, idx) =>
      ({ playerId, slotNumber: idx }));
    const bench = td.zones.bench.map(playerId => ({ playerId }));
    const alternates = td.zones.alternates.map(playerId => ({ playerId }));

    try {
      const res = await this.auth.fetch(`/api/eligibility/lineup/${matchId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          starters, bench, alternates,
          formationId: 0,
          rosterSize: td.rosterSize,
        }),
      });
      const data = await res.json();
      if (!data.success) throw new Error(data.message || 'Save failed');
    } catch (err) {
      console.error('Lineup save failed for team', td.team.id, err);
    }
  }

  // -------------------------------------------------------------------------
  // localStorage (hidden-team prefs)
  // -------------------------------------------------------------------------
  _hiddenKey() { return `footballhome:lineups:hidden:${this.gender}:${this.clubId}`; }

  _loadHiddenTeams() {
    try {
      const raw = window.localStorage.getItem(this._hiddenKey());
      if (!raw) return new Set();
      const arr = JSON.parse(raw);
      return new Set(Array.isArray(arr) ? arr.map(n => parseInt(n, 10)).filter(n => !isNaN(n)) : []);
    } catch { return new Set(); }
  }

  _saveHiddenTeams() {
    try {
      window.localStorage.setItem(
        this._hiddenKey(),
        JSON.stringify(Array.from(this.hiddenTeams))
      );
    } catch {}
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  _todayISO() {
    const d = new Date();
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
  }

  // event_date arrives as 'YYYY-MM-DD HH:MM:SS' from /api/matches/team/:teamId,
  // or as separate match_date + match_time elsewhere.
  _splitEventDate(eventDate, matchTimeFallback) {
    if (!eventDate) return { dateStr: 'TBD', timeStr: '' };
    const s = String(eventDate);
    const [datePart, timePart] = s.includes(' ') ? s.split(' ') : [s, matchTimeFallback || ''];
    return {
      dateStr: this._formatDate(datePart),
      timeStr: this._formatTime(timePart),
    };
  }

  _isFinished(status) {
    if (!status) return false;
    const s = String(status).toLowerCase();
    return s.includes('complete') || s.includes('final')
        || s.includes('cancel')   || s.includes('forfeit')
        || s.includes('postpon');
  }

  _opponentName(td) {
    const m = td.nextMatch;
    if (!m) return '';
    return m.home_team_name === td.team.name
      ? (m.away_team_name || 'TBD')
      : (m.home_team_name || 'TBD');
  }

  _formatDate(iso) {
    if (!iso) return 'TBD';
    // iso is YYYY-MM-DD — render as locale short.
    const [y, m, d] = iso.split('-').map(n => parseInt(n, 10));
    if (!y || !m || !d) return iso;
    const dt = new Date(y, m - 1, d);
    return dt.toLocaleDateString(undefined, { weekday: 'short', month: 'short', day: 'numeric' });
  }

  _formatTime(t) {
    if (!t) return '';
    // t may be 'HH:MM:SS' or 'HH:MM' — strip seconds, render 12h.
    const parts = String(t).split(':');
    let h = parseInt(parts[0], 10);
    const mins = parts[1] || '00';
    if (isNaN(h)) return String(t);
    const am = h < 12 ? 'am' : 'pm';
    h = h % 12; if (h === 0) h = 12;
    return `${h}:${mins}${am}`;
  }

  _escape(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
  }

  // M/D/YYYY — display only.  Accepts ISO-ish 'YYYY-MM-DD…' or null.
  _formatDob(iso) {
    if (!iso || typeof iso !== 'string' || iso.length < 10) return '';
    const [y, m, d] = iso.slice(0, 10).split('-');
    if (!y || !m || !d) return '';
    return `${parseInt(m, 10)}/${parseInt(d, 10)}/${y}`;
  }

  // Current age (in whole years) from an ISO 'YYYY-MM-DD…' string.
  // Returns null on bad input so callers can suppress the badge.
  _ageFromDob(iso) {
    if (!iso || typeof iso !== 'string' || iso.length < 10) return null;
    const [ys, ms, ds] = iso.slice(0, 10).split('-');
    const y = parseInt(ys, 10), m = parseInt(ms, 10), d = parseInt(ds, 10);
    if (!y || !m || !d) return null;
    const today = new Date();
    let age = today.getFullYear() - y;
    const beforeBirthday =
      (today.getMonth() + 1) < m ||
      ((today.getMonth() + 1) === m && today.getDate() < d);
    if (beforeBirthday) age--;
    return age >= 0 && age < 130 ? age : null;
  }

  // Youth-model age band: smallest U-bracket that still contains the
  // player's current age.  Used for the LA pool card so an admin can
  // eyeball who could play down into a U21 / U23 slot.  Falls through
  // to "O40" for anyone over 40 (Open / Over-40 leagues).
  _ageBand(age) {
    if (age == null) return '';
    if (age < 21) return 'U21';
    if (age < 23) return 'U23';
    if (age < 25) return 'U25';
    if (age < 30) return 'U30';
    if (age < 35) return 'U35';
    if (age < 40) return 'U40';
    return 'O40';
  }
}
