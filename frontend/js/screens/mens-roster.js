// MensRosterScreen — Live Men's roster pulled from LeagueApps every page
// load, joined to football-home team assignments (Brazil / Puerto Rico /
// U23 / future APSL / Liga 1 / Liga 2).
//
// Each player card carries one toggle pill per configured column.  Tapping
// a pill saves an assignment (POST /api/mens-roster/assign) and re-renders
// the affected columns.  Pills sharing a `mutexGroup` (e.g. Brazil & PR)
// are at-most-one — adding one removes the other server-side.  A player
// with zero pills lit lives in the leftmost "Unassigned" column.
//
// Columns are DB-driven (mens_team_columns table); to add APSL / Liga 1 /
// Liga 2 later just insert rows there — no code change required.
//
// Dues reporting is baked in (2026-07-04) so selection == dues-awareness:
//   • Each card carries a color-coded days-overdue pill (1-3 yellow, 4-6
//     orange, 7+ red) that replaces the old tiny paid-dot.
//   • Each column header shows "⚠ N OVERDUE" when any current roster member
//     is behind on dues — the coach sees per-team risk without clicking in.
//   • A trailing "🚨 Dues Owed" column surfaces players the admin has
//     parked as delinquent — the column strips them off every other
//     roster (mens-selection mutex).  Two action buttons per card
//     (lifted from PaymentsScreen):
//       LA  — opens LA Manager memberDetails for manual pause
//       ⏸  — copies the canonical pause-warning message to clipboard
//   • Backend used to block /assign for delinquent players (HTTP 409);
//     that gate was REMOVED 2026-07-04 pm per user directive.  Admin
//     now decides roster + Dues Owed column placement manually.
class MensRosterScreen extends RosterScreenBase {
  render() {
    const div = document.createElement('div');
    div.className = 'screen';
    div.innerHTML = `
      <style>
        /* Hide the default triangle marker on the CONTACT / ROSTER
           <summary> popovers so they render as clean buttons.  Scoped
           to this screen via .roster-move-details / .mr-contact. */
        .roster-move-details > summary,
        .mr-contact          > summary { list-style: none; }
        .roster-move-details > summary::-webkit-details-marker,
        .mr-contact          > summary::-webkit-details-marker { display: none; }
        .roster-move-details > summary::marker,
        .mr-contact          > summary::marker { display: none; content: ''; }

        /* Drag-and-drop cursor + insertion indicator (2026-07-04 pm).
           Cards on real columns are grabbable; while dragging, a bright
           border appears on the target edge so the drop point is
           obvious.  See onDragStart / onDragOver in mens-roster.js. */
        .mr-card[draggable="true"]        { cursor: grab; }
        .mr-card[draggable="true"]:active { cursor: grabbing; }
        .mr-card.mr-dragging              { opacity: 0.35; }
        .mr-card.mr-drop-before           { box-shadow: 0 -3px 0 0 #10b981 inset; }
        .mr-card.mr-drop-after            { box-shadow: 0  3px 0 0 #10b981 inset; }
        .mr-drop-zone.mr-drop-empty       { box-shadow: 0 0 0 2px #10b981 inset; border-radius: 4px; }
      </style>
      <div class="screen-header">
        <button class="btn btn-secondary back-btn">← Back</button>
        <h1>🎽 Team Players Board</h1>
        <p class="subtitle">Live from LeagueApps — dues-aware team selection with per-team overdue counts</p>
      </div>

      <div style="padding: var(--space-2) 0;">
        <div id="mr-banner" style="margin: 0 var(--space-2) var(--space-3); padding: var(--space-3); border-radius: 6px; background: #f1f5f9; border: 1px solid #e2e8f0; display:flex; align-items:center; gap: var(--space-3); flex-wrap: wrap; font-size: 14px;">
          <span id="mr-banner-icon" style="font-size: 16px;">⏳</span>
          <span id="mr-banner-text" style="flex:1; min-width: 200px;">Pulling latest registrations from LeagueApps…</span>
          <button id="mr-refresh" class="btn btn-secondary" title="Force a fresh pull from LeagueApps (registrations + payments)" style="padding: 4px 10px; font-size: 13px;">🔄 Refresh</button>
        </div>
        <div id="mr-loading" style="text-align:center; padding: var(--space-6); opacity:0.6;">Loading…</div>
        <div id="mr-error"   style="display:none; color: var(--color-error); padding: var(--space-4); text-align:center;"></div>
        <div id="mr-list"    style="display:none;"></div>
      </div>
    `;
    this.element = div;
    return div;
  }

  onEnter() {
    RosterScreenBase.installMoveDropdownOutsideClose();
    this.element.addEventListener('click', e => {
      if (e.target.closest('.back-btn')) return this.navigation.goBack();
      if (e.target.closest('#mr-refresh')) return this.load({ refreshLa: true });
      const moveOpt = e.target.closest('.roster-move-option');
      if (moveOpt) return this.onMoveOptionClick(moveOpt);
      const toggle = e.target.closest('.mr-roster-toggle');
      if (toggle) return this.onRosterToggleClick(toggle);
      const pill = e.target.closest('.mr-pill');
      if (pill) return this.onPillClick(pill);
      const focusPill = e.target.closest('.mr-team-focus-pill');
      if (focusPill) return this.onTeamFocusPillClick(focusPill);
      const laBtn = e.target.closest('.mr-la-open');
      if (laBtn) { window.open(laBtn.dataset.laUrl, '_blank', 'noopener'); return; }
      const rsvpBtn = e.target.closest('.mr-rsvp-elig');
      if (rsvpBtn) return this.openRsvpEligibilityModal(rsvpBtn);
      const pauseBtn = e.target.closest('.mr-copy-pause');
      if (pauseBtn) return this._copyPauseMessage(pauseBtn);
      // PAY-reminder click (2026-07-09 rewrite).  Owner directive:
      // "we need to make those buttons generate 'message' on the fly
      // and hit db after button".  Instead of navigating the stale
      // sms: href immediately, we preventDefault, refetch the roster
      // with refreshLa=1 (forces a live LeagueApps sync), then find
      // the freshly-rendered anchor for this player and navigate to
      // its fresh href.  Guarantees the SMS body reflects the LA
      // outstandingBalance the coach just edited.
      const payLog = e.target.closest('.mr-pay-log');
      if (payLog) {
        this._handlePayClickRefresh(payLog, e);
        return;
      }
      // Dedicated 👤 PROFILE button → open the universal PersonScreen.
      // Whole-card click drill-down was removed 2026-07-14 because it
      // fired on drag-release + on tap-anywhere, hijacking every
      // move-a-player interaction.  Keep the button-only path so the
      // rest of the card (name, DOB, chips, empty space) is inert and
      // safe to drag / click without side-effects.
      // 👤 PROFILE / ✎ EDIT buttons are now rendered by the shared
      // PersonActions component (components/PersonActions.js) and
      // routed globally by a delegated document-level click handler
      // installed once at app bootstrap (see app.js).  No per-screen
      // wiring needed here — the buttons carry data-la-user-id +
      // data-return-to and land on the universal PersonScreen.  The
      // whole-card click drill-down was removed 2026-07-14 to stop
      // it hijacking drag-and-drop moves.
    });

    this.element.addEventListener('change', e => {
      const posSelect = e.target.closest('.roster-position-select');
      if (posSelect) return this.onPositionSelectChange(posSelect);
      const roleSelect = e.target.closest('.mr-role-select');
      if (roleSelect) return this.onLineupRoleSelectChange(roleSelect);
      const statusSelect = e.target.closest('.mr-status-select');
      if (statusSelect) return this.onRosterStatusSelectChange(statusSelect);
    });

    // Drag-and-drop reorder (2026-07-04 pm).  Native HTML5 events wired
    // via delegation on the screen element so re-renders don't leak
    // listeners.  See onDragStart / onDragOver / onDrop below.
    this.element.addEventListener('dragstart', e => this.onDragStart(e));
    this.element.addEventListener('dragend',   e => this.onDragEnd(e));
    this.element.addEventListener('dragover',  e => this.onDragOver(e));
    this.element.addEventListener('dragleave', e => this.onDragLeave(e));
    this.element.addEventListener('drop',      e => this.onDrop(e));

    // Billing badge click handling (edit + mark-billed) is owned by the
    // shared helper; it re-renders via this.load() on success.
    if (window.BillingBadge) {
      window.BillingBadge.wire(this.element, this.auth.fetch.bind(this.auth), () => this.load());
    }
    // Initial load always refreshes LA — the singleton model cache is
    // empty on backend boot, and this is the moment the operator opens
    // the board, so we want the truthiest possible snapshot.
    this.load({ refreshLa: true });
  }

  setBanner({ icon, text, showRefresh = true }) {
    // Refresh button is always visible now (user directive 2026-07-06:
    // "always for boys and men etc").  showRefresh is retained for API
    // compatibility but defaulted true; callers can pass false to hide.
    const i = this.find('#mr-banner-icon');
    const t = this.find('#mr-banner-text');
    const r = this.find('#mr-refresh');
    if (i) i.textContent = icon;
    if (t) t.textContent = text;
    if (r) r.style.display = showRefresh ? '' : 'none';
  }

  // Active/Inactive pill (RostersScreen host) — toggled via setIncludeInactive,
  // read here so a reload after the toggle actually asks the backend for
  // inactive teams' columns too (MensTeamColumns::loadAll's includeInactive
  // param, threaded through GET /api/mens-roster?includeInactive=1).
  setIncludeInactive(value) {
    this.includeInactive = !!value;
    return this.load();
  }

  // quiet (2026-08-21): skips the loading-skeleton/banner flash — used
  // after an optimistic local action (move/reorder) where the board
  // already shows the new state and this is just background
  // reconciliation with the server, not a first load.
  async load({ refreshLa = false, quiet = false } = {}) {
    const loading = this.find('#mr-loading');
    const errEl   = this.find('#mr-error');
    const list    = this.find('#mr-list');
    if (!quiet) {
      if (loading) loading.style.display = '';
      if (errEl)   errEl.style.display   = 'none';
      if (list)    list.style.display    = 'none';
      this.setBanner({
        icon: '⏳',
        text: refreshLa
          ? 'Pulling latest registrations from LeagueApps…'
          : 'Reloading roster from cache…',
      });
    }

    try {
      const t0  = performance.now();
      // refreshLa=1 → backend does a live LA fetch + payment sync.
      // Otherwise the backend serves its cached snapshot so mid-session
      // reloads (e.g. after a move) don't wait on LeagueApps.
      const params = new URLSearchParams();
      if (refreshLa) params.set('refreshLa', '1');
      if (this.includeInactive) params.set('includeInactive', '1');
      const qs = params.toString();
      const url = qs ? `/api/mens-roster?${qs}` : '/api/mens-roster';
      const res = await this.auth.fetch(url);
      if (!res.ok) {
        const body = await res.text();
        throw new Error(body.slice(0, 200) || `HTTP ${res.status}`);
      }
      const data = await res.json();
      const elapsed = ((performance.now() - t0) / 1000).toFixed(1);
      this._data = data;
      // Optional hook — RostersScreen (rosters.js) sets this so the
      // Teams panel can surface data.unassignedCount without reaching
      // into this screen's private DOM/state.
      if (typeof this.onDataLoaded === 'function') this.onDataLoaded(data);

      if (loading) loading.style.display = 'none';
      if (list)    list.style.display    = '';

      // Banner intentionally shows ONLY roster-pertinent counts.
      // Financial roll-ups (overdue count, dues owed) were removed
      // 2026-07-14 per user directive: "the financial stuff can be
      // on payments screen or in player card when we click edit".
      // Per-card overdue signal is retained via the tiny status
      // pill on each player card; the club-wide aggregate lives on
      // the dedicated /payments screen where it belongs.
      this.setBanner({
        icon: '✓',
        text: `${data.total} player${data.total === 1 ? '' : 's'} loaded in ${elapsed}s · ${data.unassignedCount} unassigned`,
        showRefresh: true,
      });
      this.renderRoster(data);
    } catch (err) {
      if (loading) loading.style.display = 'none';
      if (errEl) {
        errEl.style.display = '';
        errEl.textContent = `Failed to load team players: ${err.message}`;
      }
      this.setBanner({
        icon: '✗',
        text: `Could not reach LeagueApps: ${err.message}`,
        showRefresh: true,
      });
    }
  }

  _isPlayerView() {
    const role = (this.navigation?.context?.role || this.auth?.user?.role || '').toString().toLowerCase();
    return role === 'player';
  }

  renderRoster(data) {
    const container = this.find('#mr-list');

    if (this._isPlayerView()) {
      // Full column parity with the admin board (Unassigned + every
      // configured column) — players used to see a hardcoded 3-team
      // subset here, which meant "all rosters" from #my quietly
      // wasn't actually all of them.
      const renderRows = (players) => players.map((p) => {
        const fullName = this.escape(`${p.firstName || ''} ${p.lastName || ''}`.trim() || p.fullName || 'Player');
        const dob = this._formatPlayerDob(p.birthDate);
        return `
          <div style="display:flex; justify-content:space-between; gap:10px; padding:6px 0; border-bottom:1px solid rgba(255,255,255,0.08);">
            <div style="font-size:0.82rem; font-weight:600;">${fullName}</div>
            <div style="font-size:0.78rem; opacity:0.72; white-space:nowrap;">${this.escape(dob)}</div>
          </div>`;
      }).join('');
      const renderSection = (label, players) => `
        <section style="background:var(--bg-secondary); border:1px solid var(--color-border); border-radius:var(--radius-md); overflow:hidden; min-width:0;">
          <div style="padding:8px 10px; border-bottom:1px solid var(--color-border); background:rgba(255,255,255,0.04); font-weight:700; font-size:0.82rem;">
            ${this.escape(label)}
          </div>
          <div style="padding:8px 10px; display:flex; flex-direction:column; gap:2px;">
            ${renderRows(players) || '<div style="opacity:0.55; font-size:0.8rem;">No players</div>'}
          </div>
        </section>`;

      const columns = data.columns || [];
      const sections = [
        renderSection('📦 Unassigned', data.unassigned || []),
        ...columns.map((col) => renderSection(
          col.label || `Team ${col.teamId}`,
          (data.buckets && data.buckets[String(col.teamId)]) || [],
        )),
      ].join('');

      container.innerHTML = `
        <div style="padding:0 var(--space-2) var(--space-2); display:grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap:10px; align-items:start;">
          ${sections}
        </div>`;
      this.setBanner({ icon: '✓', text: 'Read-only team players · every column', showRefresh: false });
      return;
    }

    // Admin view below remains unchanged.
    const visibleColumns = (data.columns || []).filter((c) => true);
    const allCols = [
      { teamId: 0, label: '📦 Unassigned', color: '#475569', count: (data.unassigned || []).length, isUnassigned: true },
      ...visibleColumns,
    ];
    // columnScope (2026-08-16, rosters.js side-by-side layout): see the
    // identical block in boys-roster.js's renderRoster for the doc —
    // same opt-in filter, undefined/'all' leaves this board unchanged.
    const cols = this.columnScope === 'unassigned'
      ? allCols.filter(c => c.isUnassigned)
      : this.columnScope === 'teams'
        ? allCols.filter(c => !c.isUnassigned)
        : allCols;

    // Team-focus pills (2026-08-21): click a team's chip to isolate its
    // column; click again (or All) to bring every team back. Purely
    // client-side filter over the already-loaded data — no re-fetch.
    // Only offered on the Teams panel (columnScope==='unassigned' always
    // has exactly one column, nothing to focus down to).
    const showFocusPills = this.columnScope !== 'unassigned' && cols.length > 1;
    if (this.teamFocusId && !cols.some(c => c.teamId === this.teamFocusId)) {
      this.teamFocusId = null;
    }
    const visibleCols = this.teamFocusId ? cols.filter(c => c.teamId === this.teamFocusId) : cols;

    container.innerHTML = `
      <div style="display:flex; align-items:center; gap:var(--space-2); flex-wrap:wrap; margin: 0 var(--space-2) var(--space-3); padding:var(--space-2) var(--space-3); background:var(--bg-secondary); border-radius:var(--radius-md);">
        <span style="opacity:0.7; font-size:0.8rem; font-weight:600;">Columns:</span>
        ${showFocusPills ? `
          <button type="button" class="mr-team-focus-pill" data-team-focus-id="0"
                  style="font-size:0.8rem; font-weight:700; padding:2px 10px; border-radius:999px; cursor:pointer;
                         border:1px solid ${this.teamFocusId ? 'var(--border-color)' : '#94a3b8'};
                         background:${this.teamFocusId ? 'transparent' : '#94a3b8'};
                         color:${this.teamFocusId ? 'inherit' : '#0f172a'};">All</button>
        ` : ''}
        ${cols.map(c => {
          const count = c.isUnassigned ? c.count : ((data.buckets[String(c.teamId)] || []).length);
          const cap = c.maxRoster != null ? `(${count}/${c.maxRoster})` : `(${count})`;
          const active = this.teamFocusId === c.teamId;
          if (!showFocusPills) {
            return `
              <span style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; padding:2px 8px; border-radius:4px; border-left:3px solid ${c.color};">
                ${c.label} <span style="opacity:0.55;">${cap}</span>
              </span>`;
          }
          return `
            <button type="button" class="mr-team-focus-pill" data-team-focus-id="${c.teamId}"
                    title="${active ? `Showing only ${c.label} — click All to see every team` : `Show only ${c.label}`}"
                    style="display:inline-flex; align-items:center; gap:6px; font-size:0.8rem; font-weight:${active ? 700 : 400}; padding:2px 8px; border-radius:999px; cursor:pointer;
                           border:1px solid ${c.color}; border-left:3px solid ${c.color};
                           background:${active ? c.color : 'transparent'}; color:${active ? '#fff' : 'inherit'};">
              ${c.label} <span style="opacity:${active ? '0.85' : '0.55'};">${cap}</span>
            </button>`;
        }).join('')}
      </div>

      <div style="padding: 0 var(--space-2) var(--space-2);">
        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(${this.colMinWidth(visibleCols.length)}, max-content)); gap:var(--space-2); align-items:start;">
          ${visibleCols.map(c => this.renderColumn(c, data)).join('')}
        </div>
      </div>
    `;
  }

  // Purely client-side — re-renders from the already-loaded data, no
  // network round-trip (see renderRoster's showFocusPills block).
  onTeamFocusPillClick(btn) {
    const id = parseInt(btn.dataset.teamFocusId, 10) || 0;
    this.teamFocusId = id || null;
    if (this._data) this.renderRoster(this._data);
  }

  _formatPlayerDob(value) {
    if (!value) return 'DOB —';
    const d = new Date(`${value}T00:00:00Z`);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleDateString('en-US', { month: 'numeric', day: 'numeric', year: 'numeric', timeZone: 'UTC' });
  }

  // Cards get thinner when there are few columns (lots of room per col) and
  // wider when there are many (so the big move buttons still fit). Feeds
  // the wrapping grid's minmax() floor (see renderRoster) — columns that
  // don't fit on one row wrap to the next instead of needing overflow-x
  // scroll, which used to clip the move dropdown popover open below a
  // card near the bottom of a column (overflow-x:auto forces overflow-y
  // to auto too — a CSS quirk, not a real height shortage — found 2026-08-21).
  colMinWidth(n) {
    if (n <= 4) return '150px';
    if (n <= 6) return '130px';
    if (n <= 8) return '120px';
    return '110px';
  }

  renderColumn(col, data) {
    // Data source: Unassigned pulls from data.unassigned (no active team
    // rows); every real column pulls from data.buckets keyed by teamId.
    const players = col.isUnassigned
      ? (data.unassigned || [])
      : (data.buckets[String(col.teamId)] || []);

    let countHtml;
    if (col.maxRoster != null) {
      const overFull = players.length >= col.maxRoster;
      const pct      = col.maxRoster ? players.length / col.maxRoster : 0;
      const nearFull = !overFull && pct >= 0.85;
      const fc = overFull ? '#ef4444' : nearFull ? '#f59e0b' : '#10b981';
      const pctText  = `${Math.round(pct * 100)}%`;
      const left     = col.maxRoster - players.length;
      const detail   = overFull
        ? `${pctText} ⚠`
        : `${left} left · ${pctText}`;
      countHtml = `<span style="font-size:0.85rem; font-weight:600; color:${fc}; white-space:nowrap;">${players.length}/${col.maxRoster} · ${detail}</span>`;
    } else {
      countHtml = `<span style="opacity:0.6; font-size:0.85rem;">${players.length}</span>`;
    }

    const renderList = (list) => list.map((p, i) => this.renderPlayer(p, data.columns, col, i + 1, list.length)).join('');

    const body = players.length === 0
      ? '<div style="opacity:0.5; font-size:0.85rem;">(empty)</div>'
      : renderList(players);

    // Column-header financial roll-up ("⚠ N OVERDUE") was removed
    // 2026-07-14 — belongs on the /payments screen, not here.  The
    // per-card overdue pill keeps the signal at the row level where
    // it's actionable for roster picks.

    return `
      <div style="background:var(--bg-secondary); border-radius:var(--radius-md); padding:6px; border-top:3px solid ${col.color}; min-width:0;">
        <div style="display:flex; justify-content:space-between; align-items:baseline; margin-bottom:4px; gap:6px;">
          <strong style="font-size:0.8rem;">${col.label}</strong>
          ${countHtml}
        </div>
        <div class="mr-drop-zone" data-drop-team-id="${col.isUnassigned ? '' : col.teamId}"
             style="display:flex; flex-direction:column; gap:6px; min-height:8px; min-width:0;">
          ${body}
        </div>
      </div>
    `;
  }

  renderPlayer(p, columns, col, position, totalInColumn = 0) {
    // Card redesign (2026-07-04): the coach's primary action on this
    // board is "move player X to roster Y".  Everything else (contact,
    // dues action) is secondary.  So the card leads with a big 3-button
    // roster-selector row (Unassigned / APSL / Liga 1) and drops the
    // tiny legacy pills entirely.  Contact + dues actions are still
    // present but sized so they're readable, not decorative.

    // For the men’s roster we contact the PLAYER directly.  The card still
    // shows the player name, but every contact action now routes to the
    // player’s own phone/email when available.
    const contactName  = p.fullName || `${p.firstName || ''} ${p.lastName || ''}`.trim() || 'player';
    const contactFirst = p.firstName || '';
    const contactPhone = p.phone || p.parentPhone || null;
    const contactEmail = p.email || p.parentEmail || null;

    const greeting = p.firstName ? `Hi ${p.firstName},` : 'Hi,';
    const subject  = `Lighthouse 1893 Men's`;
    const emailBody = `${greeting}\n\nThis is your Lighthouse 1893 coach.\n\n`;
    const smsBody   = `Hi${p.firstName ? ' ' + p.firstName : ''}, this is Lighthouse 1893 coach.`;

    const emailHref = contactEmail
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       contactEmail,
          su:       subject,
          body:     emailBody,
        }).toString()}`
      : null;
    const smsHref = contactPhone ? `sms:${contactPhone}?&body=${encodeURIComponent(smsBody)}` : null;
    const telHref = contactPhone ? `tel:${contactPhone}` : null;

    // Full DOB (e.g. "3/10/2008").
    const dobShort = this.formatDobShort(p.birthDate);

    // Dues status — consolidated into BillingBadge.renderBalance().
    // User directive 2026-07-05 pm: "use only 1 section of card for
    // financial info".  The BAL cell now carries paid/owed/late signal
    // and its own colour scheme; a separate chip here was duplicative.
    // rawDays + hasUnpaidBalance are still computed so the delinquency
    // action buttons (PAY, card border colour) stay tier-aware.
    const rawDays          = p.daysOverdue || 0;
    const balanceNum       = Number(p.outstandingBalance) || 0;
    const paidStatus       = p.paymentStatus === 'PAID' || p.paymentStatus === 'WAIVED';
    const hasUnpaidBalance = balanceNum > 0 && !paidStatus;
    const days             = rawDays >= 1 ? rawDays : (hasUnpaidBalance ? 1 : 0);
    const daysAreExact     = rawDays >= 1;

    // Payment history is rendered exclusively by the shared BillingBadge
    // component (see billing-badge.js → renderLastPaid).  We used to
    // render a duplicate "Payments · May – Jul" block here but it was
    // showing the same data as "RECENT PAYMENTS" — dropped 2026-07-04 pm.

    // ---- Move-to-roster dropdown -----------------------------------
    //
    // Data-driven from `columns` (roster_columns rows with domain='mens',
    // not archived — currently APSL 35, Liga 1 120, Liga 2 121, Lighthouse
    // Adult League 122).  All non-Unassigned mens columns share
    // mutex_group='mens-selection' (see migration 104), so the DB
    // enforces "at most one active row per user across the mens-selection
    // group".  MensTeamAssignments::addAssignment mirrors the mutex by
    // atomically removing the sibling assignment on add — no extra
    // client-side remove call needed.  Rendering itself is identical to
    // boys (and girls/women's, which inherit BoysRosterScreen), so it
    // lives once in RosterScreenBase.
    const { rosterSelectHtml: moveSelect, canMove } = this._teamCardCapabilities(p, columns, col);
    // Shared button style — as thin as legible.  Zero vertical padding
    // plus a tight line-height give ~11-12 px total height while the
    // sides keep a proper 5 px cushion.  All actions (move, delinq,
    // contact, payments pill) share this base so they align.
    const btnBase = 'padding:0 4px; font-size:0.6rem; font-weight:800; letter-spacing:0.02em; border-radius:3px; line-height:1.2; white-space:nowrap;';

    // ---- Roster Role dropdown (2026-08-22) -----------------------------
    //
    // Coach-set "starter/bench eligible for APSL" designation, formerly a
    // two-button "Elig: Start" / "Elig: Bench" toggle on the per-match
    // game-lineup screen (migration 279/283) — moved here per owner
    // directive ("this can all be put on the Teams page") and given a
    // third state, "reserve" (migration 293), for Liga 1 players held as
    // the APSL call-up pool. A <select> reads as one line instead of two
    // buttons, so it's the compact option for a card this dense.
    // team_persons.lineup_role_id is independent per team row, so this
    // only makes sense on the two teams it was designed for (APSL 35,
    // Liga 1 120) — Liga 2 / Lighthouse Adult don't get the control.
    // Keyed by personId (not leagueAppsUserId) — see
    // TeamController::handleSetLineupRoleForPerson doc, same LA-userId-
    // drift immunity as the reorder/move endpoints.
    const roleSelect = (canMove && col && (col.teamId === 35 || col.teamId === 120) && p.personId)
      ? `<select class="mr-role-select" data-team-id="${col.teamId}" data-person-id="${p.personId}"
                 title="Roster Role — APSL Starter/Bench, or APSL Reserve for a Liga 1 call-up"
                 style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; max-width:92px;">
           <option value=""        ${!p.lineupRole ? 'selected' : ''}>Role: —</option>
           <option value="starter" ${p.lineupRole === 'starter' ? 'selected' : ''}>APSL Starter</option>
           <option value="bench"   ${p.lineupRole === 'bench'   ? 'selected' : ''}>APSL Bench</option>
           <option value="reserve" ${p.lineupRole === 'reserve' ? 'selected' : ''}>APSL Reserve</option>
         </select>`
      : '';

    // ---- Official Roster Status dropdown (2026-08-22) ------------------
    //
    // Tracks whether this player has actually been submitted/approved on
    // the official league roster (as opposed to just being on our own
    // internal team_persons board) — migration 294/295. Applies to any
    // real team column, not just APSL/Liga 1 (unlike the Roster Role
    // select above, which is specific to the starter/bench/reserve
    // selection pool). Keyed by personId — see
    // TeamController::handleSetRosterStatusForPerson.
    const statusSelect = (canMove && col && col.teamId && p.personId)
      ? `<select class="mr-status-select" data-team-id="${col.teamId}" data-person-id="${p.personId}"
                 title="Official league roster status"
                 style="font-size:0.6rem; font-weight:800; letter-spacing:0.01em; padding:0 2px; line-height:1.2; border-radius:3px; border:1px solid #475569; background:#0f172a; color:#fff; max-width:92px;">
           <option value=""                  ${!p.rosterStatus ? 'selected' : ''}>Status: —</option>
           <option value="not_on_roster"     ${p.rosterStatus === 'not_on_roster'     ? 'selected' : ''}>Not on Roster</option>
           <option value="awaiting_approval" ${p.rosterStatus === 'awaiting_approval' ? 'selected' : ''}>Awaiting Approval</option>
           <option value="on_roster"         ${p.rosterStatus === 'on_roster'         ? 'selected' : ''}>On Roster</option>
           <option value="suspended"         ${p.rosterStatus === 'suspended'         ? 'selected' : ''}>Suspended</option>
         </select>`
      : '';

    // Reserve/On-Roster toggle removed 2026-07-04 (pm) per user directive:
    // column membership is the whole game.  Match-day roster selection
    // lives on a separate lineups screen.

    // ---- Delinquency action buttons (LA + Pay + Pause) -----------------
    // Shortened labels (2026-07-04 pm) so they don't dominate the row.
    // "LA MANAGER" → "LA"; "⏸ COPY PAUSE" → "⏸ PAUSE".  Tooltip still
    // carries the full description for anyone hovering.
    //
    // 💸 PAY (2026-07-05) — opens native SMS with a pre-filled payment
    // reminder that includes the outstanding amount + LA dashboard link.
    // Covers two failure modes the coach can't fix from admin side:
    //   (a) card on file but charge failed / expired
    //   (b) no card on file at all (LA only saves on a successful $1)
    // In both cases the player must log in and either update the card
    // or add one.  LA's public API doesn't expose card-on-file status
    // (verified 2026-07-05), so one universal message covers both.
    //
    // LA quick-jump button (2026-07-05, per user): always visible for
    // any player with a leagueAppsUserId — not just overdue ones —
    // so the coach can eyeball LA payment status for PAID players too.
    // Hoisted out of the delinq-only block.
    const laBtn = p.leagueAppsUserId
      ? `<button class="mr-la-open" type="button" data-la-url="${this.laManagerUrl(p.leagueAppsUserId)}"
                 title="Open ${this.escape(p.firstName || 'player')} in LA Manager"
                 style="${btnBase} border:none; cursor:pointer; background:#7c3aed; color:#fff;">
           LA
         </button>`
      : '';
    // 👤 PROFILE button (2026-07-14) — dedicated drill-down into the
    // universal PersonScreen.  Replaces the old "click anywhere on the
    // card" wiring which hijacked drag-and-drop moves.  Kept small and
    // right next to LA so the two "look up this person" buttons live
    // together.  As of 2026-07-14 the actions are produced by the
    // shared PersonActions component so every screen renders the same
    // 👤 PROFILE / ✎ EDIT pair with consistent behaviour.
    const profileBtn = this.renderPersonActions(p, {
      returnTo: 'mens-roster',
      showEdit: false,
      // Sits next to the roster-move dropdown in a full-height strip
      // (renderCompactCard) — display:flex centering keeps the label
      // centered now that the button stretches taller than its text.
      // appearance:none + min-height:0 strip the native OS button-chrome
      // minimum height that browsers apply to real <button> elements
      // (the dropdown trigger is a <summary>, which has no such native
      // chrome, so it didn't need this — this button did).
      btnBaseStyle: 'font-size:0.68rem; padding:0 6px; line-height:1.2; appearance:none; -webkit-appearance:none; min-height:0; box-sizing:border-box; margin:0; display:flex; align-items:center; justify-content:center;',
    });
    let delinqBtns = '';
    // Prorate context (2026-07-09) — if the player is a mid-cycle
    // signup who hasn't yet paid the full $35 for the partial cycle,
    // the PAY reminder should explain the prorate math instead of
    // parroting a generic "$35 dues past due" line.  Also opens the
    // PAY button for fresh signups (days=0) so the coach can nudge
    // them BEFORE the invoice fails — the whole point of the prorate
    // cell is to prompt the coach to add the LA charge NOW.
    const pr = (window.BillingBadge && window.BillingBadge.projectedProrate)
      ? window.BillingBadge.projectedProrate(p)
      : null;
    const prorateOwed = !!(pr && pr.amount > 0);
    if ((days >= 1 || prorateOwed) && p.leagueAppsUserId) {
      // Amount preference order (2026-07-09 owner directive on LA
      // Balance Due being manually edited):
      //   1. LA outstandingBalance   (authoritative when set)
      //   2. computed prorate amount (mid-cycle signup fallback)
      //   3. nextBillAmount          (monthly expectation)
      //   4. EXPECTED_MONTHLY_AMOUNT (final fallback)
      const proAmt   = prorateOwed && pr && pr.amount > 0 ? pr.amount : null;
      const nbAmt    = p.nextBillAmount > 0 ? p.nextBillAmount : null;
      const amountNum = (p.outstandingBalance > 0)
        ? p.outstandingBalance
        : (proAmt != null ? proAmt : (nbAmt != null ? nbAmt : 35));
      const amountStr = Number.isInteger(amountNum) ? `$${amountNum}` : `$${amountNum.toFixed(2)}`;
      // daysStr carries the whole "N days past due" phrase (or the
      // generic "past due") so we don't have to sprinkle "past due"
      // into every template.
      const daysStr   = daysAreExact
        ? `${days} day${days === 1 ? '' : 's'} past due`
        : 'past due';
      const payUrl    = 'https://lighthouse1893.leagueapps.com/dashboard';
      // Three-tier body scaled to delinquency severity (2026-07-05):
      //   1–3 days  → gentle nudge; assume card-on-file issue
      //   4–6 days  → firmer, team-aware: mention *temporary* demotion
      //               one tier down (APSL→Liga 1, Liga 1→Liga 2)
      //   7+ days   → same tone; state the demotion is what has to happen
      //               to keep the higher-tier spot open for paid members
      //
      // Rewritten 2026-07-08 per user directive:
      //   • Drop "removed from all rosters / replaced" language — we do
      //     NOT have a Lighthouse League feeder yet, so those threats
      //     were fiction.  We're recruiting to fill APSL / Liga 1 /
      //     Liga 2 and don't want to cut anyone.
      //   • Lead with "check your card on file" — most overdue accounts
      //     are just declined/expired cards, not bad-faith non-payers.
      //   • Every tier ties back to the club goal: fill three teams.
      //   • Liga 2 + Lighthouse Adult → no demotion, collect only.
      //   • Voice: warm, signed from "Lighthouse 1893" (dropped the
      //     Financial Dept framing — felt collections-bot).
      const firstNameStr = p.firstName ? ` ${p.firstName}` : '';
      const isDuesOwedState = p.delinquencyState === 'dues_owed' || days >= 7;

      // Determine the player's top selection-team tier for demotion
      // wording.  Mens selection teams are mutex-grouped, so a player
      // should be on at most one of {APSL, Liga 1, Liga 2, LL Adult}.
      //   35  = APSL             → demote to Liga 1
      //   120 = Liga 1           → demote to Liga 2
      //   121 = Liga 2           → collect only
      //   122 = Lighthouse Adult → collect only
      //   (unassigned)           → collect only (no team spot to lose)
      const tids = Array.isArray(p.teamIds) ? p.teamIds : [];
      let demotionTarget = null;  // "Liga 1" | "Liga 2" | null
      let currentTierName = null; // "APSL"   | "Liga 1" | null
      if (tids.includes(35))        { currentTierName = 'APSL';   demotionTarget = 'Liga 1'; }
      else if (tids.includes(120))  { currentTierName = 'Liga 1'; demotionTarget = 'Liga 2'; }

      // Copy rewritten 2026-07-09 per user directive: "for Men we will
      // run the card. for parents we are not running cards until aug 7.
      // we are asking them to pay. if mens card don't run we are
      // asking them same as parents."
      //
      // → Mens IS running cards.  A PAY button on a mens card means
      //   the charge on the card on file didn't clear — so the copy
      //   leads with "card didn't clear, please pay or update card".
      //   Two variants:
      //     (a) prorate — mid-current-cycle signup: explain that July
      //         dues are prorated and use the LA outstandingBalance
      //         (which the owner manually edits per player) as the
      //         authoritative amount to pay — no on-the-fly $ math
      //         that could contradict what LA shows.
      //     (b) normal  — July $35 didn't clear on card, please pay
      //         / update card.
      //   Both point to the LA dashboard.
      let payBody;
      if (prorateOwed) {
        const regShort = pr.regDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
        payBody = `Hi${firstNameStr}, welcome to Lighthouse 1893! Since you registered on ${regShort} (mid-cycle), your July dues are prorated for the ${pr.daysRemain} of ${pr.cycleDays} days remaining — ${amountStr} for July. Looks like the card on file didn't clear — usually just an expired or declined card. Gentle reminder to log in and pay ${amountStr} or update your card on file when you get a moment: ${payUrl}. Thanks!`;
      } else {
        payBody = `Hi${firstNameStr}, gentle reminder from Lighthouse 1893 — your July dues (${amountStr}) didn't clear on the card on file. Usually just an expired or declined card. When you get a moment, please log in and pay or update your card: ${payUrl}. Thanks!`;
      }
      const payHref   = p.phone ? `sms:${p.phone}?&body=${encodeURIComponent(payBody)}` : null;
      const payBtn    = payHref
        ? `<a href="${payHref}"
              class="mr-pay-log"
              data-la-user-id="${p.leagueAppsUserId || ''}"
              data-method="sms"
              data-amount="${amountNum != null ? amountNum : ''}"
              data-days-overdue="${daysAreExact ? days : ''}"
              data-tier="${daysAreExact ? (isDuesOwedState ? '7+' : (days >= 4 ? '4-6' : '1-3')) : ''}"
              title="Text ${this.escape(this.formatPhone(p.phone))} a payment reminder with LA link"
              style="${btnBase} border:none; cursor:pointer; background:#059669; color:#fff; text-decoration:none;">
             💸 PAY
           </a>`
        : '';
      // Last-reminder pill so admin sees "already texted 2h ago" first.
      const lastReminderPill = window.BillingBadge && window.BillingBadge.renderLastPayReminder
        ? window.BillingBadge.renderLastPayReminder(p)
        : '';
      delinqBtns = `
        ${lastReminderPill}${payBtn}`;
    }

    // ── Football Home invite copy (2026-07-06) ─────────────────────
    //
    // Plain sms:/mailto: deep-links pre-filled with a short onboarding
    // message pointing at https://footballhome.org.  No magic-link
    // token is minted — the player logs in with Google (same email as
    // LeagueApps) or sets a password.  Magic-link is reserved for
    // event-specific "tap to RSVP for Tue" nudges.
    //
    // Built unconditionally so the CONTACT popover can always offer
    // an INVITE action, even for players who've already signed in
    // (useful for re-nudging lapsed users).  The outer JOIN cluster
    // next to the FH pill stays gated on "never signed in" so the
    // roster still visually flags who hasn't onboarded.
    const firstNameForJoin = p.firstName || 'there';
    const inviteUrl = 'https://footballhome.org';
    const inviteSmsBody = `Hey ${firstNameForJoin} — Lighthouse 1893 is using ${inviteUrl} for weekly RSVPs. Log in with the Google account you use for LeagueApps (or set a password) to see this week's practices, games and pickups and RSVP YES / NO to all of them. Thanks!`;
    const inviteEmailSubject = 'Football Home — Lighthouse 1893 weekly RSVPs';
    const inviteEmailBody = [
      `Hi ${firstNameForJoin},`,
      '',
      `Lighthouse 1893 is rolling out ${inviteUrl} so we have a clearer picture of who's coming each week.`,
      '',
      `Head to ${inviteUrl} and sign in with the same Google account you use for LeagueApps (or set a password on the sign-in page). From your home screen you'll see this week's practices, games and pickups and can RSVP YES / NO to all of them in one tap.`,
      '',
      'You can also set default availability by day-of-week + event type so the page auto-fills going forward.',
      '',
      '— Lighthouse Soccer',
    ].join('\n');
    const inviteSmsHref = p.phone
      ? `sms:${this.escape(p.phone)}?&body=${encodeURIComponent(inviteSmsBody)}`
      : null;
    // INVITE email uses Gmail compose (same authuser pattern as the
    // regular EMAIL button above) so clicking it lands on
    // mail.google.com pre-filled from soccer@lighthouse1893.org rather
    // than firing an OS mailto: handler (which on desktop typically
    // does nothing useful).  Matches the leads page.
    const inviteEmailHref = p.email
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       p.email,
          su:       inviteEmailSubject,
          body:     inviteEmailBody,
        }).toString()}`
      : null;
    const welcomeEmailSubject = 'Welcome to the club — set your availability on FootballHome';
    const welcomeEmailBody = [
      `Hi ${contactFirst || 'there'},`,
      '',
      'Welcome to the club! This is where practices, pickups, and games are listed on FootballHome.',
      '',
      'Please log in at https://footballhome.org and set your availability for the week.',
      'You do not need to attend every event, but you are expected to set your availability for every event so the club knows where you can help.',
      '',
      'Thanks,',
      'James Breslin',
      'Soccer Director at Lighthouse',
    ].join('\n');
    const welcomeEmailHref = contactEmail
      ? `https://mail.google.com/mail/?${new URLSearchParams({
          view:     'cm',
          fs:       '1',
          authuser: 'soccer@lighthouse1893.org',
          to:       contactEmail,
          su:       welcomeEmailSubject,
          body:     welcomeEmailBody,
        }).toString()}`
      : null;

    // ---- Contact popover -----------------------------------------------
    // One CONTACT button collapses EMAIL / SMS / CALL / SAVE and the
    // two INVITE actions into a native <details> popover.  Only the
    // methods the player actually has contact data for are rendered
    // inside.  Uses <details>/<summary> so there's no JS listener
    // wiring, no click-outside tracking.
    const contactBase = btnBase + ' border:none; text-decoration:none; display:inline-flex; align-items:center; gap:3px;';
    // 👤 SAVE (2026-07-05) — data-URL vCard so tapping opens the native
    // "Add Contact" sheet on iOS/Android (or downloads a .vcf on
    // desktop).  Only rendered if we have at least a phone or email.
    const vcardHref = (contactPhone || contactEmail)
      ? this.buildVcardHref({
          fullName: contactName,
          firstName: contactFirst,
          lastName: p.lastName,
          phone: contactPhone,
          email: contactEmail,
          org: `Lighthouse 1893 Men's`,
        })
      : null;
    const vcardFilename = ((contactName || `${p.firstName || 'player'}_${p.lastName || ''}`).trim().replace(/\s+/g, '_') || 'contact') + '.vcf';
    const contactItems = [
      emailHref       ? `<a href="${emailHref}"       target="_blank" rel="noopener noreferrer" title="${this.escape(contactEmail)}"                                            style="${contactBase} background:#3b82f6; color:#fff;">✉ EMAIL</a>` : '',
      smsHref         ? `<a href="${smsHref}"                                                   title="Text ${this.escape(this.formatPhone(contactPhone))}"                    style="${contactBase} background:#10b981; color:#fff;">💬 SMS</a>` : '',
      telHref         ? `<a href="${telHref}"                                                   title="Call ${this.escape(this.formatPhone(contactPhone))}"                    style="${contactBase} background:#6366f1; color:#fff;">📞 CALL</a>` : '',
      vcardHref       ? `<a href="${vcardHref}"       download="${this.escape(vcardFilename)}" title="Save ${this.escape(contactName)} to your phone contacts" style="${contactBase} background:#0ea5e9; color:#fff;">👤 SAVE</a>` : '',
      inviteSmsHref   ? `<a href="${inviteSmsHref}"                                            title="Text ${this.escape(this.formatPhone(contactPhone))} an invite to footballhome.org" style="${contactBase} background:#0d9488; color:#fff;">💬 INVITE (SMS)</a>` : '',
      inviteEmailHref ? `<a href="${inviteEmailHref}" target="_blank" rel="noopener noreferrer" title="Email ${this.escape(contactEmail)} an invite to footballhome.org"      style="${contactBase} background:#14b8a6; color:#fff;">✉ INVITE (email)</a>` : '',
      welcomeEmailHref ? `<a href="${welcomeEmailHref}" target="_blank" rel="noopener noreferrer" title="Welcome ${this.escape(contactName)} to the club" style="${contactBase} background:#8b5cf6; color:#fff;">👋 WELCOME</a>` : '',
    ].filter(Boolean);
    const contactBtns = contactItems.length > 0 ? `
      <details class="mr-contact" style="position:relative; display:inline-block;">
        <summary style="${btnBase} background:#334155; color:#fff; border:none; cursor:pointer; list-style:none; user-select:none;"
                 title="Contact ${this.escape(contactName)}">📇 CONTACT</summary>
        <div style="position:absolute; top:100%; left:0; z-index:20; margin-top:2px; display:flex; flex-direction:column; gap:2px; background:#0f172a; padding:3px; border-radius:4px; box-shadow:0 4px 12px rgba(0,0,0,0.45); border:1px solid #334155;">
          ${contactItems.join('')}
        </div>
      </details>` : '';


    // Under-16 warning (2026-08-02, user directive): league rules allow
    // 16+ in mens play — this is a visible flag for the coach to verify
    // eligibility, not a block. Only ever set on FH-only squad cards in
    // practice, since LA itself won't register anyone under 18 as Mens.
    const under16Flag = p.under16
      ? `<span title="Under 16 — mens play requires 16+, verify eligibility before fielding" style="display:inline-flex; align-items:center; gap:4px; font-size:0.68rem; line-height:1.2; padding:0 6px; border-radius:999px; color:#fbbf24; font-weight:700; border:1px solid #fbbf24;">⚠ Under 16</span>`
      : '';
    const duesLabel = this.renderDuesLabel(p) + under16Flag;
    const billingBadge = window.BillingBadge ? window.BillingBadge.render(p) : '';

    const cardId = `mr-card-${p.leagueAppsUserId}`;

    // Card border: bright yellow by default for clear separation on the
    // dark background.  Heavy-overdue (4+ days) cards get a red border
    // tint so risk states pop from a distance.  Dues Owed cards use the
    // same styling as every other column — the column header + hint
    // already communicate the parked state (2026-07-04 pm).
    const baseBorder = '2px solid #facc15';  // yellow-400
    const cardBorder = days >= 4 ? `2px solid ${this.daysOverdueColor(days)}` : baseBorder;
    const cardShadow = '';

    // Position number within the column (1-based).  Gives the coach a
    // running count so they can see "we've got 14 in APSL" while
    // scrolling, not just at the header.  White + full opacity so it's
    // legible from a distance (bumped from 0.62rem/0.55 opacity).
    const posChip = position
      ? `<span style="font-size:0.72rem; color:#fff; font-weight:800; letter-spacing:0.02em; white-space:nowrap;">#${position}</span>`
      : '';

    // Row 1: rank + name + roster-move dropdown (far right). Row 2: DOB +
    // age group + dues + view button (far right).
    //
    // Drag reorder: real columns only (col.teamId truthy — Unassigned
    // has no team_id row so it can't store a coach rank).  The card
    // carries data-user-id + data-team-id so the drop handler can
    // rebuild the ordered list and POST /api/mens-roster/reorder.
    const dragAttrs = col && col.teamId
      ? `draggable="true" data-user-id="${p.leagueAppsUserId}" data-team-id="${col.teamId}"`
      : '';
    // Separate from `data-user-id` (drag-only, real columns) — always
    // present so the delegated card-click drill-down works even for
    // Unassigned cards where drag is disabled.
    const laUidAttr = p.leagueAppsUserId
      ? `data-la-user-id="${p.leagueAppsUserId}"`
      : '';
    // Whole-card cursor:pointer was removed 2026-07-14 — clicking the
    // card no longer navigates (that job now belongs to the dedicated
    // 👤 PROFILE button).  Keeping the default cursor makes it visually
    // obvious that the card body is inert / drag-safe.
    return this.renderCompactCard({
      player: p,
      col,
      position,
      totalInColumn,
      cardClass: 'mr-card',
      cardId,
      dobShort,
      duesLabel,
      rosterSelectHtml: moveSelect,
      roleSelectHtml: roleSelect,
      statusSelectHtml: statusSelect,
      viewButtonHtml: profileBtn,
      borderColor: cardBorder,
      canMove,
    });
  }

  // ── vCard builder (2026-07-05) ───────────────────────────────────
  //
  // Builds a `data:text/vcard;charset=utf-8,...` URL that, when opened
  // via an <a href>, triggers the OS-native "Add Contact" flow on
  // iOS/Android or downloads a .vcf on desktop.  vCard 3.0 with CRLF
  // line endings per RFC 2426.  Field values are escaped (backslash,
  // comma, semicolon, newline) before the whole payload is
  // URI-encoded for the data URL.
  buildVcardHref({ fullName, firstName, lastName, phone, email, org, note }) {
    const esc = (s) => String(s == null ? '' : s)
      .replace(/\\/g, '\\\\')
      .replace(/\n/g, '\\n')
      .replace(/,/g, '\\,')
      .replace(/;/g, '\\;');
    const lines = ['BEGIN:VCARD', 'VERSION:3.0'];
    // N: Family;Given;Additional;Prefix;Suffix
    if (firstName || lastName) {
      lines.push(`N:${esc(lastName)};${esc(firstName)};;;`);
    }
    if (fullName) lines.push(`FN:${esc(fullName)}`);
    if (org) lines.push(`ORG:${esc(org)}`);
    if (phone) lines.push(`TEL;TYPE=CELL:${esc(phone)}`);
    if (email) lines.push(`EMAIL;TYPE=INTERNET:${esc(email)}`);
    if (note) lines.push(`NOTE:${esc(note)}`);
    lines.push('END:VCARD');
    const body = lines.join('\r\n');
    return `data:text/vcard;charset=utf-8,${encodeURIComponent(body)}`;
  }

  // Pulls the leading emoji + 1 short word from labels like "🇧🇷 Brazil"
  // → "🇧🇷 Brazil" stays short already; trims long names.
  shortLabel(label) {
    if (!label) return '';
    if (label.length <= 14) return this.escape(label);
    return this.escape(label.slice(0, 12)) + '…';
  }

  // ── Drag-and-drop reorder (2026-07-04 pm) ────────────────────────
  //
  // Native HTML5 DnD.  Cards on real columns are draggable (see
  // renderPlayer); Unassigned cards are not (no team_id row can hold a
  // coach rank).  Drops must land in the SAME column — cross-column
  // moves still go through the roster-move popover, which handles the
  // mutex_group DELETE atomically.
  //
  // While dragging, we show a green insertion indicator either above or
  // below the card the pointer is currently over (based on which half
  // of it the pointer hit).  Dropping into an empty column body works
  // via the mr-drop-empty state on the column's mr-drop-zone.
  //
  // After a drop, we rearrange the DOM in place, collect the ordered
  // list of userIds, POST /reorder, then reload the whole board so the
  // #N chips + coachSortOrder come back from the server.

  _dragClearMarkers() {
    this.element.querySelectorAll('.mr-drop-before, .mr-drop-after')
      .forEach(el => el.classList.remove('mr-drop-before', 'mr-drop-after'));
    this.element.querySelectorAll('.mr-drop-empty')
      .forEach(el => el.classList.remove('mr-drop-empty'));
  }

  // Resolves "where in this zone does clientY want to insert" from the
  // pointer's Y position alone — not from which element it's precisely
  // hovering. Old behavior required the pointer to be directly over a
  // card's rect to get any insertion marker at all; landing in the gap
  // between cards fell through to "no overCard" and silently
  // reinterpreted the drop as "append to end", which read as the drag
  // just not working. Walking every non-dragging card's vertical
  // midpoint instead makes the whole zone height — gaps included —
  // resolve to a sensible slot, matching ordinary Trello-style
  // drag-reorder behavior.
  _dragInsertionPoint(zone, clientY) {
    const cards = Array.from(zone.querySelectorAll('.mr-card[draggable="true"]'))
      .filter(el => !el.classList.contains('mr-dragging'));
    for (const card of cards) {
      const rect = card.getBoundingClientRect();
      if (clientY < rect.top + rect.height / 2) return { before: card, cards };
    }
    return { before: null, cards };
  }

  onDragStart(e) {
    const card = e.target.closest && e.target.closest('.mr-card[draggable="true"]');
    if (!card) return;
    this._dragSourceUserId = card.dataset.userId;
    this._dragSourceTeamId = card.dataset.teamId;
    card.classList.add('mr-dragging');
    // Firefox requires setData() for dragstart to succeed at all.
    if (e.dataTransfer) {
      try {
        e.dataTransfer.effectAllowed = 'move';
        e.dataTransfer.setData('text/plain', card.dataset.userId);
      } catch (_) { /* ignore */ }
    }
  }

  onDragEnd(_e) {
    this.element.querySelectorAll('.mr-card.mr-dragging')
      .forEach(el => el.classList.remove('mr-dragging'));
    this._dragClearMarkers();
    this._dragSourceUserId = null;
    this._dragSourceTeamId = null;
  }

  onDragOver(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.mr-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const zoneTeamId = zone.dataset.dropTeamId;
    // Empty string = Unassigned column (no team_id).  Reject.
    if (!zoneTeamId) return;
    // Same-column only.  Cross-column drops are ignored — the move
    // popover is the correct affordance for changing team assignments.
    if (zoneTeamId !== this._dragSourceTeamId) return;

    e.preventDefault();
    if (e.dataTransfer) e.dataTransfer.dropEffect = 'move';
    this._dragClearMarkers();

    const { before, cards } = this._dragInsertionPoint(zone, e.clientY);
    if (before) {
      before.classList.add('mr-drop-before');
    } else if (cards.length === 0) {
      // Nothing left to anchor to (empty column, or dragging the column's
      // only card) — highlight the whole zone so the user knows "drop here".
      zone.classList.add('mr-drop-empty');
    } else {
      cards[cards.length - 1].classList.add('mr-drop-after');
    }
  }

  onDragLeave(e) {
    // Only clear when the pointer leaves the drop zone entirely — not
    // when it moves between children within the same zone.  We check
    // relatedTarget: if it's still inside the same zone, do nothing.
    const zone = e.target.closest && e.target.closest('.mr-drop-zone');
    if (!zone) return;
    const to = e.relatedTarget;
    if (to && zone.contains(to)) return;
    zone.classList.remove('mr-drop-empty');
    zone.querySelectorAll('.mr-drop-before, .mr-drop-after')
      .forEach(el => el.classList.remove('mr-drop-before', 'mr-drop-after'));
  }

  async onDrop(e) {
    if (!this._dragSourceUserId) return;
    const zone = e.target.closest && e.target.closest('.mr-drop-zone[data-drop-team-id]');
    if (!zone) return;
    const teamId = parseInt(zone.dataset.dropTeamId, 10);
    if (!teamId || String(teamId) !== this._dragSourceTeamId) return;

    e.preventDefault();
    const sourceCard = this.element.querySelector(
      `.mr-card[draggable="true"][data-user-id="${this._dragSourceUserId}"][data-team-id="${this._dragSourceTeamId}"]`
    );
    if (!sourceCard) { this._dragClearMarkers(); return; }

    const { before } = this._dragInsertionPoint(zone, e.clientY);
    if (before) {
      before.parentNode.insertBefore(sourceCard, before);
    } else {
      zone.appendChild(sourceCard);
    }
    this._dragClearMarkers();

    // Collect ordered userIds (+ parallel personIds, when every card has
    // one) directly from the DOM (source of truth after the manual
    // insertBefore above) and persist. personIds is the drift-immune
    // path (see MensTeamAssignments::reorderTeamForPersons) — sent
    // whenever available so a stale persons.la_user_id can't make one
    // card's drag silently no-op and snap back after reload.
    const cardEls = Array.from(zone.querySelectorAll('.mr-card[draggable="true"]'));
    const orderedIds = cardEls
      .map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;
    const orderedPersonIds = cardEls.map(el => parseInt(el.dataset.personId, 10));
    const personIds = orderedPersonIds.every(n => Number.isFinite(n)) ? orderedPersonIds : null;

    try {
      const res = await this.auth.fetch('/api/mens-roster/reorder', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ teamId, userIds: orderedIds, ...(personIds ? { personIds } : {}) }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      // Quiet reload so #N chips + backend sort come back authoritative
      // without flashing the loading skeleton over an already-reordered board.
      await this.load({ quiet: true });
    } catch (err) {
      alert(`Could not save order: ${err.message}`);
      await this.load({ quiet: true });
    }
  }

  // Slot picker (2026-08-21) — alternative to drag-reorder for coaches
  // who find drag unreliable ("fails if you don't drag it just right").
  // Same persistence path as onDrop (DOM-first reorder, then POST the
  // rebuilt order to the reorder endpoint) — just triggered by a <select>
  // change instead of a drag gesture.
  async onPositionSelectChange(select) {
    const teamId = parseInt(select.dataset.teamId, 10);
    const targetPos = parseInt(select.value, 10);
    if (!teamId || !targetPos) return;

    const card = select.closest('.mr-card[draggable="true"]');
    const zone = card && card.closest('.mr-drop-zone[data-drop-team-id]');
    if (!card || !zone) return;

    const cardEls = Array.from(zone.querySelectorAll('.mr-card[draggable="true"]'));
    const fromIdx = cardEls.indexOf(card);
    const toIdx   = targetPos - 1;
    if (fromIdx === -1 || toIdx === fromIdx) return;

    cardEls.splice(fromIdx, 1);
    cardEls.splice(Math.max(0, Math.min(toIdx, cardEls.length)), 0, card);
    cardEls.forEach(el => zone.appendChild(el));

    const orderedIds = cardEls.map(el => parseInt(el.dataset.userId, 10)).filter(n => Number.isFinite(n));
    if (orderedIds.length === 0) return;
    const orderedPersonIds = cardEls.map(el => parseInt(el.dataset.personId, 10));
    const personIds = orderedPersonIds.every(n => Number.isFinite(n)) ? orderedPersonIds : null;

    try {
      const res = await this.auth.fetch('/api/mens-roster/reorder', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ teamId, userIds: orderedIds, ...(personIds ? { personIds } : {}) }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load({ quiet: true });
    } catch (err) {
      alert(`Could not save order: ${err.message}`);
      await this.load({ quiet: true });
    }
  }

  // Roster Role dropdown (2026-08-22) — coach-set APSL Starter/Bench/
  // Reserve designation, independent per team row (see roleSelect doc in
  // renderPlayer). Optimistic: flip the select's own state immediately,
  // roll back only on a failed save — no full-board reload needed since
  // this doesn't move the card between columns.
  async onLineupRoleSelectChange(select) {
    const teamId = parseInt(select.dataset.teamId, 10);
    const personId = parseInt(select.dataset.personId, 10);
    const lineupRole = select.value || null;
    if (!teamId || !personId) return;

    const prevValue = Array.from(select.options).find(o => o.defaultSelected)?.value ?? '';
    select.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/teams/${teamId}/roster/person/${personId}/lineup-role`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ lineupRole }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      select.querySelectorAll('option').forEach(o => { o.defaultSelected = o.selected; });
    } catch (err) {
      select.value = prevValue;
      alert(`Could not save Roster Role: ${err.message}`);
    } finally {
      select.disabled = false;
    }
  }

  // Official Roster Status dropdown (2026-08-22) — same optimistic
  // single-select pattern as onLineupRoleSelectChange above, just a
  // different endpoint/field.
  async onRosterStatusSelectChange(select) {
    const teamId = parseInt(select.dataset.teamId, 10);
    const personId = parseInt(select.dataset.personId, 10);
    const rosterStatus = select.value || null;
    if (!teamId || !personId) return;

    const prevValue = Array.from(select.options).find(o => o.defaultSelected)?.value ?? '';
    select.disabled = true;
    try {
      const res = await this.auth.fetch(`/api/teams/${teamId}/roster/person/${personId}/roster-status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ rosterStatus }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      select.querySelectorAll('option').forEach(o => { o.defaultSelected = o.selected; });
    } catch (err) {
      select.value = prevValue;
      alert(`Could not save Roster Status: ${err.message}`);
    } finally {
      select.disabled = false;
    }
  }

  async onPillClick(btn) {
    const userId = parseInt(btn.dataset.userId, 10);
    const teamId = parseInt(btn.dataset.teamId, 10);
    const action = btn.dataset.action;
    if (!userId || !teamId || !action) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      const res = await this.auth.fetch('/api/mens-roster/assign', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({ leagueAppsUserId: userId, teamId, action }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      // Easiest correct re-render: quiet reload (cheap — 53 records).
      await this.load({ quiet: true });
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not save assignment: ${err.message}`);
    }
  }

  // Move-to-roster <details> popover option handler (2026-07-04 pm).
  // 2026-08-16 (multi-assign): each card's dropdown owns exactly ONE
  // team_persons row (`currentTeamId`, threaded through from
  // RosterScreenBase.renderMoveDropdown):
  //   • target == 0 (Unassigned)  → POST remove on `currentTeamId`, the
  //     row THIS card represents. Never touches any other active row
  //     the player may hold. No-op if this card is already Unassigned.
  //   • target == 35 / 120 / 121   → POST add. Purely additive
  //     (MensTeamAssignments::addAssignmentForPerson no longer closes
  //     sibling rows) — the player keeps every other team they're on.
  async onMoveOptionClick(btn) {
    const userId        = parseInt(btn.dataset.userId, 10);
    const personId       = parseInt(btn.dataset.personId, 10) || undefined;
    const targetTeamId  = parseInt(btn.dataset.targetTeamId, 10);
    const currentTeamId = parseInt(btn.dataset.currentTeamId || '0', 10);
    if (!userId || Number.isNaN(targetTeamId)) return;

    // Close the popover immediately for snappier UX — also doubles as
    // "roll it back up" when the option clicked is the current team,
    // which is a no-op below.
    const details = btn.closest('details');
    if (details) details.open = false;
    if (targetTeamId === currentTeamId) return;

    // Instant feedback (2026-08-21): fade the whole card right away so
    // the coach sees the move registered immediately, instead of waiting
    // on the network + a full board reload to notice anything happened.
    // The card itself doesn't get moved/removed client-side — mens'
    // mutex_group (APSL/Liga1/etc. are mutually exclusive server-side,
    // MensTeamAssignments::addAssignmentForPerson silently drops a
    // sibling row on add) makes a hand-rolled DOM move unsafe to get
    // right from here; a quiet reload right after brings back the
    // authoritative board fast enough that the fade reads as "in progress"
    // rather than a stall.
    const card = btn.closest('.mr-card');
    if (card) { card.style.opacity = '0.35'; card.style.pointerEvents = 'none'; }

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      let body;
      if (targetTeamId === 0) {
        if (currentTeamId <= 0) { await this.load({ quiet: true }); return; }
        body = { leagueAppsUserId: userId, personId, teamId: currentTeamId, action: 'remove' };
      } else {
        body = { leagueAppsUserId: userId, personId, teamId: targetTeamId, action: 'add' };
      }
      const res = await this.auth.fetch('/api/mens-roster/assign', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(body),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load({ quiet: true });
      // Tell the sibling Unassigned/Teams panel (if RostersScreen has
      // wired one up) to quietly catch up too — this card's board just
      // reloaded itself, but the OTHER panel's cached data still thinks
      // this player is where they were before the move.
      if (typeof this.onMembershipChanged === 'function') this.onMembershipChanged();
    } catch (err) {
      if (card) { card.style.opacity = ''; card.style.pointerEvents = ''; }
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not move player: ${err.message}`);
    }
  }

  async onRosterToggleClick(btn) {
    const userId   = parseInt(btn.dataset.userId, 10);
    const teamId   = parseInt(btn.dataset.teamId, 10);
    const current  = btn.dataset.onRoster === '1';
    if (!userId || !teamId) return;

    btn.disabled = true;
    btn.style.opacity = '0.4';
    try {
      const res = await this.auth.fetch('/api/mens-roster/roster-status', {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify({
          leagueAppsUserId: userId,
          teamId,
          onRoster: !current,
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(text.slice(0, 200));
      }
      await this.load({ quiet: true });
    } catch (err) {
      btn.disabled = false;
      btn.style.opacity = '';
      alert(`Could not update roster status: ${err.message}`);
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────
  // Matches PaymentsScreen's LA deep-link scheme.  Hardcoded site id
  // mirrors PaymentsScreen.laSiteId (41983) — UI-only value; backend
  // canonical is LEAGUEAPPS_SITE_ID in env.
  laManagerUrl(uid) {
    return `https://manager.leagueapps.com/console/sites/41983/memberDetails?memberId=${uid}`;
  }

  // PAY-button per-click refresh (2026-07-09).  When the coach taps
  // 💸 PAY, refetch the full mens roster with refreshLa=1 first so
  // the message body reflects the balance the coach just edited in
  // LA.  Then find the freshly-rendered anchor and navigate to its
  // fresh href.  Mens is SMS-only (no Gmail-compose variant) so no
  // popup-blocker workaround needed.
  async _handlePayClickRefresh(payLog, e) {
    e.preventDefault();
    const uid          = payLog.dataset.laUserId;
    const method       = payLog.dataset.method;
    const fallbackHref = payLog.getAttribute('href');

    payLog.style.opacity = '0.55';

    try {
      await this.load({ refreshLa: true });
      const selector = `.mr-pay-log[data-la-user-id="${uid}"][data-method="${method || 'sms'}"]`;
      const freshAnchor = this.element.querySelector(selector);
      const targetHref  = freshAnchor ? freshAnchor.getAttribute('href') : fallbackHref;

      this._logPayReminder(freshAnchor || payLog);

      if (targetHref) window.location.href = targetHref;
    } catch (err) {
      console.warn('[mens] PAY refresh failed, using stale href:', err);
      this._logPayReminder(payLog);
      if (fallbackHref) window.location.href = fallbackHref;
    }
  }

  // ── RSVP-eligibility modal (2026-07-07) ─────────────────────────
  //
  // Per user directive "i think in the player card we can just have
  // popup to allow us to check off what they can rsvp to".  Six
  // checkboxes covering the mens teams the player can RSVP for:
  //   35  APSL
  //   120 Liga 1
  //   121 Liga 2
  //   122 Adult
  //   908 Practice
  //   909 Pickup
  // Server list must stay in sync — see
  // MensRosterController.cpp `kEligibilityTeams`.
  //
  // Read on open (GET), diff+write on save (PUT).  Modal is a
  // fixed-position overlay dropped straight into <body> so it's not
  // constrained by the card's stacking context.  Removed via close().
  async openRsvpEligibilityModal(btn) {
    const uid  = Number(btn.dataset.userId);
    const name = btn.dataset.name || 'this player';
    if (!uid) return;
    const teams = [
      { id: 35,  label: 'APSL',     color: '#2563eb' },
      { id: 120, label: 'Liga 1',   color: '#0891b2' },
      { id: 121, label: 'Liga 2',   color: '#14b8a6' },
      { id: 122, label: 'Adult',    color: '#a78bfa' },
      { id: 908, label: 'Practice', color: '#f59e0b' },
      { id: 909, label: 'Pickup',   color: '#10b981' },
      { id: 924, label: 'APSL Reserves',   color: '#60a5fa' },
      // Trialists (925/926) retired 2026-08-12 — teams deactivated,
      // dropped from every other eligibility catalog; this modal was
      // the one place still offering them as a grantable checkbox.
      // Women / boys grants are editable on the RSVP Eligibility board
      // and person profile; mens roster modal stays mens-focused.
    ];

    // Fetch current set first so we can pre-check the boxes.
    let currentIds = new Set();
    try {
      const r = await this.auth.fetch(
        `/api/mens-roster/rsvp-eligibility?leagueAppsUserId=${uid}`
      );
      if (r.ok) {
        const body = await r.json();
        currentIds = new Set(body.teamIds || []);
      }
    } catch (_e) { /* modal still opens with all unchecked */ }

    const overlay = document.createElement('div');
    overlay.style.cssText = `
      position:fixed; inset:0; z-index:9999;
      background:rgba(0,0,0,0.55);
      display:flex; align-items:center; justify-content:center;
      padding:16px;
    `;
    const cbs = teams.map(t => {
      const checked = currentIds.has(t.id) ? 'checked' : '';
      return `
        <label style="display:flex; align-items:center; gap:10px;
                      padding:10px 12px; border-radius:6px;
                      background:${t.color}22; color:#fff;
                      border:1px solid ${t.color}88; cursor:pointer;
                      font-size:0.95rem; font-weight:600;">
          <input type="checkbox" data-team-id="${t.id}" ${checked}
                 style="width:18px; height:18px; accent-color:${t.color}; cursor:pointer;">
          <span style="flex:1;">${t.label}</span>
          <span style="font-size:0.7rem; opacity:0.6;">#${t.id}</span>
        </label>`;
    }).join('');

    overlay.innerHTML = `
      <div style="background:#0f172a; border-radius:10px; padding:16px 18px;
                  min-width:min(360px, 96vw); max-width:420px;
                  border:1px solid #334155;
                  box-shadow:0 20px 60px rgba(0,0,0,0.6);">
        <div style="font-size:1.05rem; font-weight:800; color:#fff; margin-bottom:2px;">
          Event Access
        </div>
        <div style="font-size:0.85rem; color:#94a3b8; margin-bottom:12px;">
          ${this.escape(name)} — choose which teams they can RSVP for.
        </div>
        <div style="display:flex; flex-direction:column; gap:6px; margin-bottom:14px;">
          ${cbs}
        </div>
        <div id="mr-rsvp-elig-msg" style="min-height:1em; font-size:0.8rem; color:#fca5a5; margin-bottom:8px;"></div>
        <div style="display:flex; justify-content:flex-end; gap:8px;">
          <button id="mr-rsvp-elig-cancel" type="button"
                  style="padding:6px 14px; border-radius:5px; border:1px solid #475569;
                         background:transparent; color:#cbd5e1; font-weight:700; cursor:pointer;">
            Cancel
          </button>
          <button id="mr-rsvp-elig-save" type="button"
                  style="padding:6px 14px; border-radius:5px; border:none;
                         background:#0ea5e9; color:#fff; font-weight:800; cursor:pointer;">
            Save
          </button>
        </div>
      </div>
    `;
    document.body.appendChild(overlay);

    const close = () => overlay.remove();
    overlay.addEventListener('click', (e) => { if (e.target === overlay) close(); });
    overlay.querySelector('#mr-rsvp-elig-cancel').addEventListener('click', close);
    overlay.querySelector('#mr-rsvp-elig-save').addEventListener('click', async () => {
      const checked = Array.from(overlay.querySelectorAll('input[type=checkbox]:checked'))
        .map(el => Number(el.dataset.teamId));
      const msg = overlay.querySelector('#mr-rsvp-elig-msg');
      msg.textContent = '';
      try {
        const r = await this.auth.fetch('/api/mens-roster/rsvp-eligibility', {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ leagueAppsUserId: uid, teamIds: checked }),
        });
        if (!r.ok) {
          const t = await r.text();
          msg.textContent = `Save failed: ${t.slice(0, 200)}`;
          return;
        }
        close();
      } catch (err) {
        msg.textContent = `Save failed: ${err.message || err}`;
      }
    });
  }

  // Color scale (user directive 2026-07-04): 1-3 yellow · 4-6 orange · 7+ red.
  daysOverdueColor(days) {
    if (days >= 7) return '#ef4444';
    if (days >= 4) return '#f97316';
    if (days >= 1) return '#fbbf24';
    return null;
  }

  // Lifted verbatim from PaymentsScreen's [data-copy-pause] handler — the
  // canonical warning admin pastes into LA's Remind flow before flipping
  // a player to Paused Membership.
  async _copyPauseMessage(btn) {
    const first = btn.dataset.firstName || 'Player';
    const msg = `${first}, you have not made initial registration payment. We have to move you to a paused membership which makes you ineligible for practice and games until paid.`;
    try {
      await navigator.clipboard.writeText(msg);
      const orig = btn.innerHTML;
      const origBg = btn.style.background;
      btn.innerHTML = '✓';
      btn.style.background = '#10b981';
      setTimeout(() => {
        btn.innerHTML = orig;
        btn.style.background = origBg || '#f97316';
      }, 1400);
    } catch (_e) {
      alert('Could not copy to clipboard — you can retype the message from Payments → Copy Pause.');
    }
  }

  // Fire-and-forget POST /api/pay-reminder-log on 💸 PAY click.  Does
  // NOT preventDefault — sms: still opens.  keepalive:true lets the
  // request survive the tab switch on iOS/Android.  Also paints an
  // optimistic "just now" pill so the admin sees instant confirmation.
  _logPayReminder(anchor) {
    const laUserId = parseInt(anchor.dataset.laUserId, 10);
    const method   = anchor.dataset.method;
    if (!laUserId || !method) return;
    const body = {
      leagueAppsUserId: laUserId,
      method,
      club:  'mens',
      tier:  anchor.dataset.tier || null,
      amount: anchor.dataset.amount ? Number(anchor.dataset.amount) : null,
      daysOverdue: anchor.dataset.daysOverdue !== '' && anchor.dataset.daysOverdue != null
        ? parseInt(anchor.dataset.daysOverdue, 10)
        : null,
    };
    try {
      const token = this.auth && this.auth.token ? this.auth.token : null;
      const headers = { 'Content-Type': 'application/json' };
      if (token) headers['Authorization'] = `Bearer ${token}`;
      fetch('/api/pay-reminder-log', {
        method: 'POST',
        headers,
        keepalive: true,
        body: JSON.stringify(body),
      }).catch(() => { /* fire-and-forget */ });
    } catch (_e) { /* ignore */ }

    try {
      const nowIso = new Date().toISOString();
      const fresh = window.BillingBadge && window.BillingBadge.renderLastPayReminderInline
        ? window.BillingBadge.renderLastPayReminderInline({ method, sentAt: nowIso })
        : '';
      const slots = this.element.querySelectorAll(`.bb-pay-reminder-slot[data-uid="${laUserId}"]`);
      slots.forEach(s => { s.innerHTML = fresh; });
    } catch (_e) { /* non-fatal */ }
  }

  formatPhone(raw) {
    if (!raw) return '';
    const digits = String(raw).replace(/\D/g, '');
    const ten = digits.length === 11 && digits.startsWith('1') ? digits.slice(1) : digits;
    if (ten.length === 10) return `(${ten.slice(0, 3)}) ${ten.slice(3, 6)}-${ten.slice(6)}`;
    return raw;
  }

  escape(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
}
